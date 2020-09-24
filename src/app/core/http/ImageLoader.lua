require("lfs")

local ImageLoader = class("ImageLoader")
local logger = g.Logger.new("ImageLoader"):enabled(true)
local coreUtilFunc = require("app.core.util.functions")

ImageLoader.CACHE_TYPE_NONE = "CACHE_TYPE_NONE"
ImageLoader.DEFAULT_TMP_DIR = device.writablePath .. "cache" .. device.directorySeparator .. "tmpimg" .. device.directorySeparator

function ImageLoader:ctor()
    self.loadId_ = 0
    self.cacheConfig_ = {}
    self.loadingJobs_ = {}
    coreUtilFunc.mkdir(ImageLoader.DEFAULT_TMP_DIR)
    self:registerCacheType(ImageLoader.CACHE_TYPE_NONE, {path=ImageLoader.DEFAULT_TMP_DIR})
end

function ImageLoader.getInstance()
    if not ImageLoader.singleInstance then
        ImageLoader.singleInstance = ImageLoader.new()
    end
    return ImageLoader.singleInstance
end

function ImageLoader:registerCacheType(cacheType, cacheConfig)
    self.cacheConfig_[cacheType] = cacheConfig
    if cacheConfig.path then
        coreUtilFunc.mkdir(cacheConfig.path)
    else
        cacheConfig.path = ImageLoader.DEFAULT_TMP_DIR
    end
end

function ImageLoader:clearCache()
    for k,v in pairs(self.cacheConfig_) do
        coreUtilFunc.rmdir(v.path)
    end
end

function ImageLoader:nextLoaderId()
    self.loadId_ = self.loadId_ + 1
    return self.loadId_
end

function ImageLoader:loadAndCacheImage(loadId, url, callback, cacheType, isForce)
    self:cancelJobByLoaderId(loadId)
    cacheType = cacheType or ImageLoader.CACHE_TYPE_NONE
    self:addJob_(loadId, url, self.cacheConfig_[cacheType], callback, isForce)
end

function ImageLoader:loadImage(url, callback, cacheType)
    local loadId = self:nextLoaderId()
    cacheType = cacheType or ImageLoader.CACHE_TYPE_NONE
    local config = self.cacheConfig_[cacheType]
    logger:debugf("loadImage(%s, %s, %s)", loadId, url, cacheType)
    self:addJob_(loadId, url, config, callback)
end

function ImageLoader:cancelJobByUrl_(url)
    local loadingJob = self.loadingJobs_[url]
    if loadingJob then
        loadingJob.callbacks = {}
    end
end

function ImageLoader:cancelJobByLoaderId(loaderId)
    if loaderId then
        for url, loadingJob in pairs(self.loadingJobs_) do
            loadingJob.callbacks[loaderId] = nil
        end
    end
end

function ImageLoader:addJob_(loadId, url, config, callback, isForce)
    local hash = crypto.md5(url)
    local path = config.path .. hash
    if io.exists(path) and isForce then
        os.remove(path)
    end
    if io.exists(path) then
        logger:debugf("file exists (%s, %s, %s)", loadId, url, path)
        lfs.touch(path)
        local tex = cc.Director:getInstance():getTextureCache():addImage(path)
        if not tex then
            os.remove(path)
        elseif callback ~= nil then
            callback(tex ~= nil, cc.Sprite:createWithTexture(tex), loadId)
        end
    else
        local loadingJob = self.loadingJobs_[url]
        if loadingJob then
            logger:debugf("job is loading -> %s", url)
            loadingJob.callbacks[loadId] = callback
        else
            logger:debugf("start job -> %s", url)
            loadingJob = {}
            loadingJob.callbacks = {}
            loadingJob.callbacks[loadId] = callback
            self.loadingJobs_[url] = loadingJob
            local function onRequestFinished(evt)
                if evt.name ~= "inprogress" then
                    local ok = (evt.name == "completed")
                    local request = evt.request

                    if not ok then
                        --请求失败，显示错误代码和错误消息
                        logger:debugf("[%d] errCode=%s errmsg=%s", loadId, request:getErrorCode(), request:getErrorMessage())
                        local values = table.values(loadingJob.callbacks)
                        for i,v in ipairs(values) do
                            if v ~= nil then
                                v(false, request:getErrorCode() .. " " .. request:getErrorMessage())
                            end
                        end
                        self.loadingJobs_[url] = nil
                        return
                    end

                    local code = request:getResponseStatusCode()
                    if code ~= 200 then
                        --请求结束，但没有返回200响应代码
                        logger:debugf("[%d] code = %s", loadId, code)
                        local values = table.values(loadingJob.callbacks)
                        for i,v in ipairs(values) do
                            if v ~= nil then
                                v(false, code)
                            end
                        end
                        self.loadingJobs_[url] = nil
                        return
                    end

                    --请求成功，显示服务器返回的内容 
                    local content = request:getResponseData()
                    logger:debugf("loaded from network, save to file -> %s", path)
                    io.writefile(path, content, "w+b")

                    if coreUtilFunc.isFileExist(path) then
                        local tex = nil
                        for k,v in pairs(loadingJob.callbacks) do
                            logger:debugf("call callback ->" .. k)
                            if v then
                                if not tex then
                                    lfs.touch(path)
                                    if isForce then
                                        cc.Director:getInstance():getTextureCache():reloadTexture(path)
                                    end
                                    tex = cc.Director:getInstance():getTextureCache():addImage(path)
                                end
                                if not tex then
                                    os.remove(path)
                                    v(false, nil, k)
                                else
                                    v(true, cc.Sprite:createWithTexture(tex),k)  
                                end
                            end
                        end
                        if config.onCacheChanged then
                            config.onCacheChanged(config.path)
                        end
                    else
                        logger:debug("file not exists - >" .. path)
                    end
                    self.loadingJobs_[url] = nil
                end
            end
            --创建一个请求，并以指定method发送数据到服务器HttpService.cloneDefaultParams初始化
            local request = network.createHTTPRequest(onRequestFinished, url, "GET")
            loadingJob.request = request
            request:start()
        end
    end
end

return ImageLoader

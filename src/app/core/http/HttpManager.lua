require("zlib")
local HttpManager = class("HttpManager")
local ErrorCode = require("app.core.protocol.ErrorCode")

HttpManager.defaultURL = g.Const.HOST_URL
HttpManager.defaultParams = {}

function HttpManager:ctor()
    self:initialize()
end

function HttpManager:initialize()
    self.requestId_ = 1
    self.requests = {}
    self.requestsSuccCbs = {} -- 成功回调集合
    self.requestsFailCbs = {} -- 失败回调集合
end

--[[
    @func getRequestId: 递增请求id
    @return: 当前请求id
--]]
function HttpManager:getRequestId()
    self.requestId_ = self.requestId_ + 1
    return self.requestId_
end

--[[
    @func request_: http请求函数, 类内部私有函数
    @param method: 请求方式get/post, string类型
    @param url: 请求的url地址
    @param isAddDefaultParams: 是否添加默认参数, boolean类型
    @param params: 传入的用户请求参数, table类型, 默认为{}
    @param resultCallback: 正常返回回调
    @param errorCallback: 错误回调
    @return: 请求id, 取消该请求时会用到
--]]
function HttpManager:request_(method, url, isAddDefaultParams, params, resultCallback, errorCallback)
    local requestId = self:getRequestId()
    self.requestsSuccCbs[requestId] = resultCallback
    self.requestsFailCbs[requestId] = errorCallback
    
    local function onRequestFinished(evt)
        if evt.name == "inprogress" or evt.name == "cancelled" then return end
        local request = evt.request
        -- self.requests[requestId] = nil
        local ok = (evt.name =="completed")
        if not ok then
            if request:getErrorCode() ~= 0 then
                -- 请求失败，显示错误代码和错误信息
                print(string.format("[%d] errCode=%s errmsg=%s", requestId, request:getErrorCode(), request:getErrorMessage()))
                if errorCallback ~= nil then
                    errorCallback(request:getErrorCode(), request:getErrorMessage())
                end
            end
            return
        end

        local code = request:getResponseStatusCode()
        if code ~= 200 then 
            -- 请求结束，但没有返回200响应代码
            print(string.format("[%d] code=%s", requestId, code))
            if errorCallback ~= nil then
                errorCallback(code)
            end
            return
        end

        --请求成功，显示服务器返回的内容
        local response = request:getResponseData()
        local headerStr = request:getResponseHeadersString()
        if string.find(headerStr,"gzip") then
              response = zlib.inflate()(response)
        end
        if string.len(response) <= 10000 then -- todo:better, string太长了打印日志报错
            print(string.format("[%d] [RESPONSE]=%s", requestId, response))
        end
        if resultCallback ~= nil then
            resultCallback(response)
        end
    end

    -- 创建一个请求，并以指定method发送数据到服务器HttpManager.cloneDafaultParams初始化
    local request = network.createHTTPRequest(onRequestFinished, url, method)
    self.requests[requestId] = request

    local allParams = self:getFinalRequestParams(isAddDefaultParams, params)
    self:addParamsToRequest(method, request, allParams)
    print(string.format("[%s][%s][%s] %s", requestId, method, url, json.encode(allParams)))
    request:addRequestHeader("Accept-Encoding:gzip")
    -- 开始请求，当请求完成时会调用callback()函数
    request:start()
    return requestId
end

--[[
    @func getFinalRequestParams: 得到最终的请求参数(默认请求参数 + 传入请求参数)
    @param isAddDefaultParams: 是否传入默认参数, boolean类型
    @param params: 用户请求参数, table类型
    @return: 返回最终合并的参数, table类型
--]]
function HttpManager:getFinalRequestParams(isAddDefaultParams, params)
    local allParams
    if isAddDefaultParams then
        allParams = clone(HttpManager.defaultParams)
        table.merge(allParams, params)
    else
        allParams = params
    end
    return allParams
end

--[[
    @func addParamsToRequest: 添加请求参数
    @param method: 请求类型post/get, string类型
    @param httpRequst: 底层创建的http请求对象
    @param params: 用户请求参数, table类型
--]]
function HttpManager:addParamsToRequest(method, httpRequst, params)
    for k,v in pairs(params) do
        if method == "GET" then
            httpRequst:addGETValue(tostring(k), tostring(v))
        else
            if type(v) == "table" then
                httpRequst:addPOSTValue(tostring(k), json.encode(v))
            else
                httpRequst:addPOSTValue(tostring(k), tostring(v))
            end
        end
    end
end

function HttpManager:getDefaultURL()
    return self.defaultURL or ""
end

function HttpManager:setDefaultURL(url)
    self.defaultURL = url
end


--------
-- interface begin
--------

function HttpManager.getInstance()
    if not HttpManager.singleInstance then
        HttpManager.singleInstance = HttpManager.new()
    end
    return HttpManager.singleInstance
end

--[[
    @func get: (http)get到默认URL，并附加默认参数
    @param params: get时传入的用户请求参数, table类型
    @param resultCallback: 正常返回时回调
    @param errorCallback: 出错时回调
    @return: 一个句柄, 取消get请求时使用该句柄
]]
function HttpManager:get(params, resultCallback, errorCallback)
    return self:request_("GET", self.defaultURL, true, params or {}, resultCallback, errorCallback)
end

--[[
    @func post: (http)post到默认URL，并附加默认参数
    @param params: post时传入的用户请求参数, table类型
    @param resultCallback: 正常返回时回调
    @param errorCallback: 出错时回调
    @return: 一个句柄, 取消post请求时使用该句柄
--]]
function HttpManager:post(params, resultCallback, errorCallback)
    params = params or {}
    local url = self.defaultURL
    if params._interface then
        url = url .. params._interface
    end
    return self:request_("POST", url, true, params or {}, resultCallback, errorCallback)
end

--[[
    @func simplePost: (http)post到默认URL，并附加默认参数, 简化版
    @param succCallback: 与@func post 同名参数相同
    @param failCallback: 与@func post 同名参数相同
    @param resetHandler: 设置传递handler的值为空
    @return: 与@func post相同
--]]
function HttpManager:simplePost(params, succCallback, failCallback, resetHandler)
    local resultCallback = function (data)
        if resetHandler then
            resetHandler()
        end
        g.myUi.miniLoading:hide()
        local decodedData = json.decode(data)
        if type(decodedData) == "table" and decodedData.ret == 0 then
            if succCallback then
                succCallback(decodedData)
            end
        else
            if failCallback then
                failCallback(decodedData)
            end
						if type(decodedData) == "table" and decodedData.ret == ErrorCode.TOKEN_EXPIRED then
								local tokenTipsDelayId = g.mySched:doDelay(function ()
									g.myUi.topTip:showText(g.lang:getText("HTTP", "TOKEN_EXPIRED_TIPS"))
									g.mySched:cancel(tokenTipsDelayId)
								end, 0.5)
                g.myApp:enterScene("LoginScene")
            end
        end
    end

    local errorCallback = function (data)
        if resetHandler then
            resetHandler()
        end
        g.myUi.miniLoading:hide()
        local decodedData = data
        if type(data) == "table" then
            decodedData = json.decode(data)
        end
        if failCallback then
            failCallback(decodedData)
        end
    end

    return self:post(params, resultCallback, errorCallback)
end

--[[
    @func cancel: (http)cancel, 取消指定requestId请求
    @param requestId: 需要取消的句柄
--]]
function HttpManager:cancel(requestId)
    if self.requests[requestId] and not tolua.isnull(self.requests[requestId]) then
        -- self.requests[requestId]:cancel()
        if self.requestsSuccCbs[requestId] then
            self.requestsSuccCbs[requestId] = nil
        end
        if self.requestsFailCbs[requestId] then
            self.requestsFailCbs[requestId] = nil
        end
        self.requests[requestId] = nil
    end
end

function HttpManager:cancelBatch(requestIds)
    requestIds = requestIds or {}
    for k, v in pairs(requestIds) do
        self:cancel(v)
        v = nil
    end
end

function HttpManager:setToken(token)
    HttpManager.defaultParams.token = token
end

--------
-- interface end
--------

return HttpManager

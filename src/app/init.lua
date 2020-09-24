-- global table in app
g = g or {}

-- set elements
local mt = {}
mt.__index = function(t, k)
    if k == "runningScene" then
        return cc.Director:getInstance():getRunningScene()
    elseif k == "userDefault" then
        return cc.UserDefault:getInstance()
    end
end
setmetatable(g, mt)

-- Many things rely on language, put it first
g.lang = require("app.language.LangUtil").getInstance()
g.mySched = require("app.util.MySchedulerPool").getInstance()
g.timeUtil = require("app.util.TimeUtil").getInstance()

g.Res = require("app.common.Res")
g.Const = require("app.common.Const")
g.SubGameDef = require("app.model.baseDef.SubGameDef")
g.Var = require("app.common.Var")
g.cookieKey = require("app.common.CookieKey")
g.eventNames = require("app.common.EventNames")

-- core module
g.event = require("app.core.event.EventCenter")
g.Logger = require("app.core.util.Logger")
g.dbMgr = require("app.core.db.DbManager").getInstance()
g.http = require("app.core.http.HttpManager").getInstance()
g.mySocket = require("app.core.socket.MySocket").getInstance()

g.native = require("app.bridge.BridgeAdapter").new()

-- custom ui components
g.myUi = require("app.myUi.UiUtil")
g.windowMgr = require("app.myUi.window.WindowManager").getInstance()

-- UserManger
g.myDevice = require("app.model.user.MyDevice").getInstance()
g.user = require("app.model.user.User").getInstance()
g.userMgr = require("app.model.user.UserManager").getInstance()
g.nameUtil = require("app.util.NameUtil").getInstance()
g.moneyUtil = require("app.util.MoneyUtil").getInstance()


g.myFunc = require("app.util.MyFunc").getInstance()
g.audio = require("app.util.AudioUtil").getInstance()

--加载远程图像
g.imageLoader = require("app.core.http.ImageLoader").getInstance()
g.imageLoader.CACHE_TYPE_USER_HEAD_IMG = "CACHE_TYPE_USER_HEAD_IMG"
g.imageLoader:registerCacheType(g.imageLoader.CACHE_TYPE_USER_HEAD_IMG, {
    path = device.writablePath .. "cache" .. device.directorySeparator .. "headpics" .. device.directorySeparator,
    onCacheChanged = function(path)
        require("lfs")
        local fileDic = {}
        local fileIdx = {}
        local MAX_FILE_NUM = 500
        for file in lfs.dir(path) do
            if file ~= "." and file ~= ".." then
                local f = path .. device.directorySeparator .. file
                local attr = lfs.attributes(f)
                assert(type(attr) == "table")
                if attr.mode ~= "directory" then
                    fileDic[attr.access] = f
                    fileIdx[#fileIdx + 1] = attr.access
                end
            end
        end
        if #fileIdx > MAX_FILE_NUM then
            table.sort(fileIdx)
            repeat
                local file = fileDic[fileIdx[1]]
                print("remove file ->" .. file)
                os.remove(file)
                table.remove(fileIdx, 1)
            until #fileIdx <= MAX_FILE_NUM
        end 
    end
})

g.imageLoader.CACHE_TYPE_GIFT = "CACHE_TYPE_GIFT"
g.imageLoader:registerCacheType(g.imageLoader.CACHE_TYPE_GIFT, {
    path = device.writablePath .. "cache" .. device.directorySeparator .. "gift" .. device.directorySeparator,
    onCacheChanged = function(path) 
        require("lfs")
        local fileDic = {}
        local fileIdx = {}
        local MAX_FILE_NUM = 400
        for file in lfs.dir(path) do
            if file ~= "." and file ~= ".." then
                local f = path.. device.directorySeparator ..file
                --print ("\t "..f)
                local attr = lfs.attributes(f)
                assert(type(attr) == "table")
                if attr.mode ~= "directory" then
                    --for name, value in pairs(attr) do
                    --  print(name, value)
                    --end
                    fileDic[attr.access] = f
                    fileIdx[#fileIdx + 1] = attr.access
                end
            end
        end
        if #fileIdx > MAX_FILE_NUM then
            table.sort(fileIdx)
            repeat
                local file = fileDic[fileIdx[1]]
                print("remove file -> " .. file)
                os.remove(file)
                table.remove(fileIdx, 1)
            until #fileIdx <= MAX_FILE_NUM
        end
    end,
})

return g

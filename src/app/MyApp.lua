
require("config")
require("cocos.init")
require("framework.init")

require("app.util.MyDebugUtil")
require("app.init")

local AppBase = require("framework.AppBase")
local MyApp = class("MyApp", AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)

    g = g or {}
    g.myApp = self
end

function MyApp:run()
    cc.FileUtils:getInstance():addSearchPath("res/")
    self:addRes()
    g.lang:addPlatformSearchPath()
    self:enterScene("LoginScene")
end

function MyApp:addRes()
    display.addSpriteFrames("textures/pokers.plist", "textures/pokers.png")
end

return MyApp

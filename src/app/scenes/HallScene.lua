local HallScene = class("HallScene", function()
    return display.newScene("HallScene")
end)

local HallView = require("app.view.hall.HallView")

local UpdateConfig = require("app.update.UpdateConfig")
local m_configs = UpdateConfig.m_configs
local lobby_configs = UpdateConfig.gold_lobby_configs

function HallScene:ctor()
    self.hallView = HallView.new():pos(display.cx, display.cy):addTo(self)
end

function HallScene:onEnter()
    if self.hallView and self.hallView.playShowAnim then
        self.hallView:playShowAnim()
    end
end

function HallScene:onExit()
end

return HallScene

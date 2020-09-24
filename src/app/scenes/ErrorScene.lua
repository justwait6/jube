local ErrorScene = class("ErrorScene", function()
    return display.newScene("ErrorScene")
end)
function ErrorScene:ctor(msg)
	-- app.name = "ErrorScene"
	-- g.keypadManager:addToScene(self)
    display.newSprite(g.Res.errorBg):pos(display.cx, display.cy):addTo(self)
    local tipsHeadStr = "Biu~ 恭喜你颜值爆表，成功使程序崩溃~"
    cc.ui.UILabel.new({text = tipsHeadStr, color = cc.c3b(128, 0, 0), size = 30})
        :align(display.CENTER, display.cx, display.height - 50)
        :addTo(self):enableShadow(cc.c4b(255,255, 153, 153), cc.size(3,-3))

    cc.ui.UILabel.new({ text = msg, color = cc.c3b(224, 40, 40), size = 20})
        :pos(10, display.height - 90)
        :setDimensions(620, 0)
        :setAnchorPoint(cc.p(0, 1))
        :addTo(self)
end

return ErrorScene

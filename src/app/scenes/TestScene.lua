local TestScene = class("TestScene", function()
    return display.newScene("TestScene")
end)

function TestScene:ctor()
    display.newSprite(g.Res.loginBg):pos(display.cx, display.cy):addTo(self)

    g.myUi.ScaleButton.new({normal = g.Res.common_btnBlueS})
        :setButtonLabel(display.newTTFLabel({size = 24, text = "打开"}))
        :onClick(handler(self, self.openWindow))
        :pos(display.cx, display.cy)
        :addTo(self, 1)
end

function TestScene:onEnter()
end

function TestScene:openWindow()
    local Dialog = g.myUi.Dialog
	Dialog.new({
        type = Dialog.Type.NORMAL,
        text = "fjasi asjdfiosdf jasjf\nraasfdfafs",
        onConfirm = function ( ... )
            print("确认点击")
        end,
        onCancel = function ( ... )
            print("取消点击")
        end,

    })
end

function TestScene:onExit()
end

return TestScene

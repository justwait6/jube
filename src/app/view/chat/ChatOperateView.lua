local ChatOperateView = class("ChatOperateView", function ()
	return display.newNode()
end)

local ChatOperateCtrl = require("app.controller.chat.ChatOperateCtrl")

local LIST_WIDTH = 582
local LIST_HEIGHT = 94

function ChatOperateView:ctor()
	self.ctrl = ChatOperateCtrl.new(self)
	self:setNodeEventEnabled(true)
	self:initialize()
end

function ChatOperateView:initialize()
	local itemBg = display.newScale9Sprite(g.Res.black, 0, 0, cc.size(LIST_WIDTH, LIST_HEIGHT))
        :pos(0, 0):addTo(self)

    -- 聊天输入框
	self._chatEditBox = g.myUi.EditBox.new({
            -- image = g.Res.moneytreeinvite_codeBg,
            imageOffset = cc.p(94, 0),
			size = cc.size(450, 54),
			fontColor = cc.c3b(248, 248, 242),
			fontSize = 20,
			maxLength = 600,
			placeHolder = g.lang:getText("CHAT", "INPUT_TIPS"),
			holderColor = cc.c3b(64, 97, 179),
		})
		:pos(-450/2, 0)
		:addTo(self)

	-- 发送按钮
	g.myUi.ScaleButton.new({normal = g.Res.common_btnBlueS, scale = 0.8})
		:setButtonLabel(display.newTTFLabel({size = 24, text = g.lang:getText("CHAT", "SEND")}))
		:onClick(handler(self, self.sendChat))
		:pos(218, 0)
		:addTo(self)
end

function ChatOperateView:bindChatUser(uid)
	if self.ctrl then
		self.ctrl:bindChatUser(uid)
	end
end

function ChatOperateView:sendChat()
	local msg = self._chatEditBox:getText()
	if msg == '' then
		g.myUi.topTip:showText(g.lang:getText("CHAT", "INPUT_EMPTY_TIPS"))
		return
	end

	if self.ctrl then
		self.ctrl:sendChat(msg)
	end
end

function ChatOperateView:resetInput()
	if self._chatEditBox then
		self._chatEditBox:setText("");
	end
end

function ChatOperateView:XXXX()
	
end

function ChatOperateView:XXXX()
	
end

function ChatOperateView:onCleanup()
end

return ChatOperateView

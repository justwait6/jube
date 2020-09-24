local FriendView = class("FriendView", g.myUi.Window)

local FriendSearchView = import(".FriendSearchView")
local FriendListView = import(".FriendListView")
local ChatListView = import(".ChatListView")
local FriendAddView = import(".FriendAddView")

local FriendCtrl = require("app.controller.hallBase.friend.FriendCtrl")
local UserCtrl = require("app.controller.user.UserCtrl")

FriendView.WIDTH = 1035
FriendView.HEIGHT = 643

local Tab = {}
Tab.CHAT = 1
Tab.LIST = 2
Tab.SEARCH = 3
Tab.ADD = 4

local LeftBarConf = {
	{iconRes = g.Res.common_chatIcon, funcName = "onTab", tab = Tab.CHAT},
	{iconRes = g.Res.common_friendIcon, funcName = "onTab", tab = Tab.LIST},
	{iconRes = g.Res.common_searchIcon, funcName = "onTab", tab = Tab.SEARCH},
	{iconRes = g.Res.common_friendAddIcon, funcName = "onTab", tab = Tab.ADD},
}

function FriendView:ctor()    
	self.ctrl = FriendCtrl.new()
	self.userCtrl = UserCtrl.new()
	FriendView.super.ctor(self, {width = self.WIDTH, height = self.HEIGHT, monoBg = true, bgColor = cc.c3b(40, 41, 35), isCoverClose = false})
	self:initialize()

	g.event:on(g.eventNames.FRIEND_RED_DOT, handler(self, self.refresh), self)
end

function FriendView:onShow()
	if self.ctrl then
		self.ctrl:reqFriendList(handler(self, self.onFriendListSucc), handler(self, self.onFriendListFail))
		self.ctrl:reqReqAddList(handler(self, self.onReqAddListSucc))
		self.ctrl:asyncFetchChatUserInfos(handler(self, self.onChatUserInfos))
		self.ctrl:reqFriendMessageList(handler(self, self.reqFriendMessageListSucc))
	end
end

function FriendView:refresh()
	if self.ctrl then
		self.ctrl:reqReqAddList(handler(self, self.onReqAddListSucc))
		self.ctrl:asyncFetchChatUserInfos(handler(self, self.onChatUserInfos))
		self.ctrl:reqFriendMessageList(handler(self, self.reqFriendMessageListSucc))
	end
end

function FriendView:initialize()
	-- 纵向分割线
	local line = cc.DrawNode:create()
	line:drawSegment(cc.p(0, 316), cc.p(0, -316), 2, cc.c4f(0.8, 0.8, 0.8, 0.8))
	line:pos(-430, 0):addTo(self)
	-- 关闭按钮
	g.myUi.ScaleButton.new({normal = g.Res.common_back, scale = 0.8})
			:onClick(handler(self, self.close))
			:pos(-476, 266)
			:addTo(self)
	-- 侧边栏按钮(依次往下): 消息列表按钮, 好友列表按钮, 搜索好友按钮, 添加好友按钮
	local leftX, beginY, gapY = -476, 266 - 86, 86
	self.tabRedDots = {}
	for i = 1, #LeftBarConf do
		local curY = beginY - (i - 1) * gapY
		g.myUi.ScaleButton.new({normal = LeftBarConf[i].iconRes, scale = 0.8})
			:onClick(function () self[LeftBarConf[i].funcName](self, LeftBarConf[i].tab) end)
			:pos(leftX, curY)
			:addTo(self)
		self.tabRedDots[i] = display.newSprite(g.Res.common_redDot)
			:pos(leftX + 22, curY + 14):addTo(self):hide()
	end

	self.views = {}
	self.views[Tab.CHAT] = ChatListView.new(self):addTo(self):hide()
	self.views[Tab.LIST] = FriendListView.new(self):addTo(self):hide()
	self.views[Tab.SEARCH] = FriendSearchView.new(self):addTo(self):hide()
	self.views[Tab.ADD] = FriendAddView.new(self):addTo(self):hide()
	self:onTab(Tab.CHAT)
end

function FriendView:onTab(tab)
	local view = self.views[tab]
    if self._curView == view then return end
    if self._curView then
			self._curView:hide()
    end
    view:show()
    self._curView = view
end

function FriendView:reqUserinfo(...)
	if self.userCtrl then
		self.userCtrl:reqUserinfo(...)
	end
end

function FriendView:reqAcceptFriend(...)
	if self.ctrl then
		self.ctrl:reqAcceptFriend(...)
	end
end

function FriendView:onFriendListSucc(data)
	data = data or {}
	if self.views[Tab.LIST] then
		self.views[Tab.LIST]:onUpdate(data.friendList)
	end
end

function FriendView:onFriendListFail()
	g.myUi.topTip:showText(g.lang:getText("FRIEND", "GET_FRIEND_LIST_FAIL"))
end

function FriendView:onChatUserInfos(chatList)
	if self.views[Tab.CHAT] then
		self.views[Tab.CHAT]:onUpdate(chatList)
	end
end

function FriendView:onReqAddListSucc(data)
	local data = data or {}
	if type(data.reqAddList) and table.nums(data.reqAddList) > 0 then
		self:showRedDotByTab(Tab.ADD)
	end
	if self.views[Tab.ADD] then
		self.views[Tab.ADD]:onUpdate(data.reqAddList)
	end
end

function FriendView:onAddFriendClick(friendUid)
	if self.ctrl then
		self.ctrl:reqSendFriendRequest({friendUid = friendUid}, 
		handler(self, self.onSendFriendRequestSucc),
		handler(self, self.onSendFriendRequestFail))
	end
end

function FriendView:onSendFriendRequestSucc()
	g.myUi.topTip:showText(g.lang:getText("FRIEND", "REQ_SEND_SUCC"))
end

function FriendView:onSendFriendRequestFail(data)
	if type(data) == "table" and data.ret == -100 then
		g.myUi.topTip:showText(g.lang:getText("FRIEND", "CAN_NOT_ADD_SELF"))
	else
		g.myUi.topTip:showText(g.lang:getText("FRIEND", "REQ_SEND_FAIL"))
	end
end

function FriendView:onFriendRemarkModify(...)
	if self.ctrl then
		self.ctrl:onFriendRemarkModify(...)
	end
end

function FriendView:asyncGetFriendInfo(...)
	if self.ctrl then self.ctrl:asyncGetFriendInfo(...) end
end

function FriendView:goToChat(...)
	self:onTab(Tab.CHAT)
	if self.views[Tab.CHAT] then
		self.views[Tab.CHAT]:checkAndStickTop(...)
	end
end

function FriendView:reqFriendMessageListSucc(data)
	local data = data or {}
	data.msgList = data.msgList or {}
	for _, v in pairs(data.msgList) do
		self.views[Tab.CHAT]:checkAndStickTop(v.srcUid, v.total)
	end
end

function FriendView:asyncReqFriendMessage(friendUid, succCallback)
	if self.ctrl then
		self.ctrl:reqFriendMessage({friendUid = friendUid}, handler(self, function(self, data)
			self:reqFriendMessageSucc(data)
			if succCallback then succCallback() end
		end))
	end	
end

function FriendView:reqFriendMessageSucc(data)
	local data = data or {}
	local friendUid = tonumber(data.friendUid)
	if self.views[Tab.CHAT] then
		self.views[Tab.CHAT]:batchAddChatItem(friendUid, data.msgs)
		-- 收到消息后, 向服务器上传已读
		self:setMessageRead(friendUid)
	end
end

function FriendView:showRedDotByTab(tab)
	if self.tabRedDots[tab] then
		self.tabRedDots[tab]:show()
	end
end

function FriendView:setMessageRead(...)
	if self.ctrl then self.ctrl:setMessageRead(...) end
end

function FriendView:XXXX()
end

function FriendView:XXXX()
end

function FriendView:XXXX()
end

function FriendView:onWindowRemove()
	g.event:removeByTag(self)

	if self.ctrl then
		self.ctrl:checkFriendsRemarkChange()
	end
	if self.userCtrl then
		self.userCtrl:dispose()
	end
	if self.ctrl then
		self.ctrl:dispose()
	end
end

return FriendView

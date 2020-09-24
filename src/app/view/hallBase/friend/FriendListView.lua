local FriendListView = class("FriendListView", function ()
    return display.newNode()
end)

local FriendInfoView = import(".FriendInfoView")

function FriendListView:ctor(mainViewObj)
	self.mainViewObj = mainViewObj
	self:setNodeEventEnabled(true)
	self:initialize()
	self:addEventListeners()
end

function FriendListView:setCtrl(ctrl, createIfNull)
	self.ctrl = ctrl
	if ctrl == nil and createIfNull then
		self.ctrl = MoneyTreeCtrl.new()
	end
end

local LIST_WIDTH = 350
local LIST_HEIGHT = 620
function FriendListView:initialize()
	display.newScale9Sprite(g.Res.black, 0, 0, cc.size(LIST_WIDTH, LIST_HEIGHT + 16))
		:pos(-250, 0)
		:addTo(self)
	self._friendListView = g.myUi.UIListView.new(LIST_WIDTH, LIST_HEIGHT)
		:pos(-250, 0)
		:addTo(self)
end

function FriendListView:addEventListeners()
	-- g.event:on(g.eventNames.XXXX, handler(self, self.XXXX), self)
end

function FriendListView:onUpdate(friendsData)
	friendsData = friendsData or {}
	self._friendListView:removeAllItems()

	if table.nums(friendsData) <= 0 then
		self:showNoFriendTips()
	else
		self:hideNoFriendTips()
	end
	self.friendSelLbls = {}

	local itemHeight = 100
	for i, v in pairs(friendsData) do
		local friendItem = self:newFriendItem(v, i)
		self.friendSelLbls[i] = display.newScale9Sprite(g.Res.moneytree_selected, 0, 0, cc.size(LIST_WIDTH + 2, 100))
			:pos(LIST_WIDTH/2, 0):addTo(friendItem):hide()

		-- 横向分割线
		if i ~= 1 then
			local line = cc.DrawNode:create()
			line:drawSegment(cc.p(10, 0), cc.p(LIST_WIDTH - 10, 0), 1, cc.c4f(0.8, 0.8, 0.8, 0.8))
			line:pos(0, itemHeight/2):addTo(friendItem)
		end

		friendItem:pos(0, itemHeight/2)
		self._friendListView:addNode(friendItem, LIST_WIDTH, itemHeight)
	end
end

function FriendListView:newFriendItem(v, listId)
	local node = display.newNode()

	local itemBg = display.newScale9Sprite(g.Res.blank, 0, 0, cc.size(LIST_WIDTH - 2, 94))
		:pos(LIST_WIDTH/2, 0):addTo(node)
	g.myUi.TouchHelper.new(itemBg, function (target, evt)
		self:onFriendItemClick(target, evt, listId, v.uid)
	end)
		:enableTouch()
		:setTouchSwallowEnabled(false)
		:setMoveNoResponse(true)

	g.myUi.AvatarView.new({
		radius = 46,
		gender = v.gender,
		frameRes = g.Res.common_headFrame,
		avatarUrl = v.iconUrl,
		clickCallback = handler(self, function () self:showOtherUserinfo(uid) end)
	})
		:addTo(node)
		:pos(50, 0)
		:setFrameScale(0.59)

	-- 备注(无备注则显示昵称)
	display.newTTFLabel({text = g.nameUtil:getLimitName(v.remark or v.nickname, 14), size = 28, color = cc.c3b(237, 226, 201)})
		:setAnchorPoint(cc.p(0, 0.5))
		:pos(120, 0)
		:addTo(node)

	return node
end

function FriendListView:onFriendItemClick(target, evt, id, uid)
	if evt ~= g.myUi.TouchHelper.CLICK then return end
	if self.lastItemSelected then
		if self.friendSelLbls and self.friendSelLbls[self.lastItemSelected] then
			self.friendSelLbls[self.lastItemSelected]:hide()
		end
	end
	if self.friendSelLbls and self.friendSelLbls[id] then
		self.friendSelLbls[id]:show()
	end
	self.lastItemSelected = id

	self:showUserInfoView(uid)
end

function FriendListView:showUserInfoView(uid)
	if not self._friendInfoView then
		self._friendInfoView = FriendInfoView.new(self.mainViewObj):pos(220, 50):show():addTo(self)
	end
	self._friendInfoView:refreshByUid(uid)

	self.goToChatUid = uid
    if not self._goChatBtn then
		self._goChatBtn = g.myUi.ScaleButton.new({normal = g.Res.common_btnBlueS, scale = 0.8})
			:setButtonLabel(display.newTTFLabel({size = 24, text = g.lang:getText("FRIEND", "GO_CHAT")}))
			:onClick(function () self:goToChat(self.goToChatUid) end)
			:pos(220, -266)
			:addTo(self)
    end
end

function FriendListView:showNoFriendTips()
	if not self._noFriendTips then
		self._noFriendTips = display.newTTFLabel({text = g.lang:getText("FRIEND", "NO_FRIEND_TIPS"), size = 26, color = cc.c3b(137, 190, 224)})
			:pos(-250, 0)
			:addTo(self)
			:hide()
	end
	self._noFriendTips:show()
end

function FriendListView:hideNoFriendTips()
	if self._noFriendTips then
		self._noFriendTips:hide()
	end
end

function FriendListView:showOtherUserinfo(uid)
	print("待完成")
end

function FriendListView:goToChat(...)
	if self.mainViewObj then
		self.mainViewObj:goToChat(...)
	end
end

function FriendListView:onCleanup(uid)
	g.event:removeByTag(self)
end

return FriendListView

local FriendInfoView = class("FriendInfoView", function ()
	return display.newNode()
end)

local LIST_WIDTH = 582
local LIST_HEIGHT = 536

function FriendInfoView:ctor(mainViewObj)
	self.mainViewObj = mainViewObj
	self:setNodeEventEnabled(true)
	self:initialize()
	self:addEventListeners()
end

function FriendInfoView:initialize()
	local itemBg = display.newScale9Sprite(g.Res.black, 0, 0, cc.size(LIST_WIDTH, LIST_HEIGHT))
		:pos(0, 0):addTo(self)
	
	-- 头像
	self.avatar = g.myUi.AvatarView.new({
		radius = 52,
		gender = g.user:getGender(),
		frameRes = g.Res.common_headFrame,
		avatarUrl = g.user:getIconUrl(),
		clickOptions = nil,
	})
        :pos(-140, 110)
		:addTo(self)
		:hide()
	self.avatar:setFrameScale(0.67)

	-- 性别
	self.genderRes =  display.newSprite(g.Res.common_headMask)
		:pos(-30, 110)
		:scale(0.5)
		:addTo(self)
		:hide()
    self.gender0 = display.newSprite(g.Res.common_gender0):pos(-30, 110):addTo(self)
    self.gender1 = display.newSprite(g.Res.common_gender1):pos(-30, 110):addTo(self)
    -- 初始化
    self.curGender = g.user:getGender()
    self:changeToGender(self.curGender)

	-- 昵称
	display.newTTFLabel({text = g.lang:getText("COMMON", "NICKNAME") .. ":", size = 28, color = cc.c3b(255, 255, 255)})
		:pos(-160, -30)
		:addTo(self)
	self.name = display.newTTFLabel({text = g.user:getCatName(), size = 28, color = cc.c3b(237, 226, 201)})
		:setAnchorPoint(cc.p(0, 0.5))
        :pos(-112, -30)
		:addTo(self)
		:hide()

	-- 备注
	local remarkY = 18
	display.newTTFLabel({text = g.lang:getText("FRIEND", "REMARK") .. ":", size = 28, color = cc.c3b(255, 255, 255)})
		:pos(-160, remarkY)
		:addTo(self)
	self.remark = display.newTTFLabel({text = "", size = 28, color = cc.c3b(237, 226, 201)})
		:setAnchorPoint(cc.p(0, 0.5))
		:pos(-112, remarkY)
		:addTo(self)
		:hide()
	
	-- 备注输入框
    self.remarkEditBox = g.myUi.EditBox.new({
		image = g.Res.blank,
		imageOffset = cc.p(94, 0),
		size = cc.size(280, 54),
		fontColor = cc.c3b(254, 255, 151),
		fontSize = 20,
		maxLength = 20,
		holderColor = cc.c3b(64, 97, 179),
		callback = handler(self, self.onEditOk),
		beginCallback = handler(self, self.onStartEdit),
	})
		:pos(-112, remarkY)
		:addTo(self)

	-- 铅笔
	self.pencel = display.newSprite(g.Res.common_editIcon)
		:pos(128, remarkY)
		:scale(0.5)
		:addTo(self)
end

function FriendInfoView:addEventListeners()
	-- g.event:on(g.eventNames.XXXX, handler(self, self.XXXX), self)
end

function FriendInfoView:refreshByUid(uid)
	self.curUid = uid
	self:asyncGetFriendInfo(uid, handler(self, self._refresh))
end

function FriendInfoView:_refresh(userInfos)
	if self.avatar then
		self.avatar:updateGender(userInfos.gender)
		self.avatar:setAvatarUrl(userInfos.iconUrl)
		self.avatar:show()
	end

	if self.genderRes then
		self:changeToGender(userInfos.gender)
		self.genderRes:show()
	end

	if self.name then
		self.name:setString(userInfos.nickname)
		self.name:show()
	end

	if self.remark then
		self.remark:setString(userInfos.remark or g.lang:getText("COMMON", "NOT_HAVE"))
		self.remark:show()
	end
end

function FriendInfoView:changeToGender(gender)
    if tonumber(gender) == 1 then
        self.gender0:hide()
        self.gender1:show()
    else
        self.gender0:show()
        self.gender1:hide()
    end
end

function FriendInfoView:onStartEdit()
    self:hideWhenEditStart()
end

function FriendInfoView:hideWhenEditStart()
	if self.remark then
        self.remark:hide()
    end
    if self.pencel then
        self.pencel:hide()
    end
end

function FriendInfoView:onEditOk()
		local newRemark = self.remarkEditBox:getText()
		-- reset edit remark to empty
    if self.remarkEditBox then
			self.remarkEditBox:setText('')
		end
		
		if newRemark == "" or newRemark == self.remark:getString() then
        self:showWhenEditOk()
        return
    end

		self.remark:setString(newRemark)
		self:onFriendRemarkModify(self.curUid, newRemark)
    self:showWhenEditOk()
end

function FriendInfoView:onFriendRemarkModify(...)
    if self.mainViewObj then
        self.mainViewObj:onFriendRemarkModify(...)
    end
end

function FriendInfoView:showWhenEditOk()
    if self.remark then
        self.remark:show()
    end
    if self.pencel then
        self.pencel:show()
    end
end

function FriendInfoView:asyncGetFriendInfo(...)
	if self.mainViewObj then self.mainViewObj:asyncGetFriendInfo(...) end
end

function FriendInfoView:XXXX()
	
end

function FriendInfoView:XXXX()
	
end

function FriendInfoView:onCleanup()
	
end

return FriendInfoView

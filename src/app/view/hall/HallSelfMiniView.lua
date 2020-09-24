local HallSelfMiniView = class("HallSelfMiniView", function ()
	return display.newNode()
end)

function HallSelfMiniView:ctor()
	self:setNodeEventEnabled(true)
	self:initialize()
	self:addEventListeners()
end

function HallSelfMiniView:initialize()
	display.newSprite(g.Res.hall_userInfoBg):pos(0, 0):addTo(self)

	self.avatar = g.myUi.AvatarView.new({
		radius = 52,
		gender = g.user:getGender(),
		frameRes = g.Res.common_headFrame,
		avatarUrl = g.user:getIconUrl(),
		clickOptions = {default = true, uid = g.user:getUid()},
	})
        :pos(-120, 10)
        :addTo(self)
	self.avatar:setFrameScale(0.67)

	self.name = display.newTTFLabel({text = g.user:getCatName(), size = 28, color = cc.c3b(237, 226, 201)})
        :pos(-52, 18)
        :setAnchorPoint(cc.p(0, 0.5))
        :addTo(self)

    display.newSprite(g.Res.common_coinIcon):pos(-40, -12):addTo(self)
    self.money = display.newTTFLabel({text = g.user:getMoney(), size = 28, color = cc.c3b(255, 255, 255)})
        :pos(24, -11)
        :addTo(self)

end

function HallSelfMiniView:playShowAnim()
	
end

function HallSelfMiniView:addEventListeners()
	g.event:on(g.eventNames.USER_INFO_UPDATE, handler(self, self.onUpdate), self)
end

function HallSelfMiniView:onUpdate(data)
	if self.name and data.nickname then
		self.name:setString(data.nickname)
	end

	if self.money and data.money then
		self.money:setString(data.money)
	end

	if self.avatar and data.gender then
		self.avatar:updateGender(data.gender)
	end
end

function HallSelfMiniView:XXXX()
	
end

function HallSelfMiniView:XXXX()
	
end

function HallSelfMiniView:onCleanup()
	g.event:removeByTag(self)
end

return HallSelfMiniView

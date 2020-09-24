local HallBaseListView = class("HallBaseListView", function ()
	return display.newNode()
end)

local HallBaseListCtrl = require("app.controller.hall.HallBaseListCtrl")

function HallBaseListView:ctor()
	self.ctrl = HallBaseListCtrl.new(self)

	self:setNodeEventEnabled(true)
	self:initialize()
end

function HallBaseListView:initialize()
	self:renderIconsList()
end

function HallBaseListView:renderIconsList()
	local baseConfs = self.ctrl:getConfList()
	local startX = 0
	local distanceGap = 160
	self.icons = {}
	self.redDots = {}
	for i, conf in pairs(baseConfs) do
		self.icons[i] = g.myUi.ScaleButton.new({normal = conf.hallIconRes})
			:onClick(handler(self.ctrl, function ()
				self.ctrl:onBaseIconClick(conf.baseId)
			end))
			:pos(startX + (i - 1) * distanceGap, 0)
			:addTo(self)
			:opacity(0)
		self.redDots[i] = display.newSprite(g.Res.common_redDot)
			:pos(startX + (i - 1) * distanceGap + 24, 0 + 20)
			:addTo(self)
			:hide()
	end
end

function HallBaseListView:playShowAnim()
	if self.icons then
		for i, icon in pairs(self.icons) do
			icon:stopAllActions()
			icon:runAction(cc.Sequence:create({
				cc.FadeTo:create(0.16, 0.25 * 256),
				cc.DelayTime:create(0.2 + i * 0.05),
				cc.JumpBy:create(0.16, cc.p(0, 0), (i % 2) * 6 + 6, 1),
				cc.FadeIn:create(0.6),
			}))
		end
	end
end

function HallBaseListView:updateRedDots(baseIds)
	if not self.redDots then return end

	local baseConfs = self.ctrl:getConfList()
	for i, conf in pairs(baseConfs) do
		if baseIds[baseConfs.id] then
			self.redDots[i]:show()
		else
			self.redDots[i]:hide()
		end
	end
end

function HallBaseListView:updateRedDot(baseId, isShow)
	if not self.redDots then return end

	local baseConfs = self.ctrl:getConfList()
	for i, conf in pairs(baseConfs) do
		if conf.baseId == baseId then
			if isShow then
				self.redDots[i]:show()
			else
				self.redDots[i]:hide()
			end
		end
	end
end

function HallBaseListView:XXXX()
	
end

function HallBaseListView:XXXX()
	
end

function HallBaseListView:XXXX()
	
end

function HallBaseListView:onCleanup()
	if self.ctrl then
        self.ctrl:dispose()
    end
end

return HallBaseListView

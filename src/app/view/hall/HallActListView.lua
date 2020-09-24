local HallActListView = class("HallActListView", function ()
	return display.newNode()
end)

local HallActListCtrl = require("app.controller.hall.HallActListCtrl")

function HallActListView:ctor()
	self.ctrl = HallActListCtrl.new()

	self:setNodeEventEnabled(true)
	self:initialize()
	self:addEventListeners()
end

function HallActListView:initialize()
	self:renderIconsList()
end

function HallActListView:renderIconsList()
	local actConfs = self.ctrl:getActConfList()
	self.icons = {}
	for i, conf in pairs(actConfs) do
		self.icons[i] = g.myUi.ScaleButton.new({normal = conf.hallIconRes})
			:onClick(handler(self.ctrl, function ()
				self.ctrl:onActIconClick(conf.actId)
			end))
			:addTo(self)
			:opacity(0)
	end
end

function HallActListView:addEventListeners()
	-- g.event:on(g.eventNames.XX, handler(self, self.XX), self)
end

function HallActListView:playShowAnim()
	if self.icons then
		local timeGap = 0.32
		local startX = 120
		local distanceGap = 100
		for i, icon in pairs(self.icons) do
			icon:stopAllActions()
			icon:pos(startX, 0)
			icon:rotation(-180)
			icon:runAction(cc.Sequence:create({
				cc.FadeTo:create(0.16, 0.25 * 256),
				cc.Spawn:create({
					cc.MoveTo:create(i * timeGap, cc.p(startX - i * distanceGap, 0)),
					cc.RotateTo:create(i * timeGap, 0)
				}),
				cc.DelayTime:create(0.8 + i * 0.1),
				cc.JumpBy:create(0.26, cc.p(0, 0), (i % 2) * 10 + 10, 1),
				cc.FadeIn:create(0.8),
			}))
		end
	end
end

function HallActListView:XXXX()
	
end

function HallActListView:XXXX()
	
end

function HallActListView:XXXX()
	
end

function HallActListView:removeEventListeners()
	g.event:removeByTag(self)
end

function HallActListView:onCleanup()
	self:removeEventListeners()
end

return HallActListView

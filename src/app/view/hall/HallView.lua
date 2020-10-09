local HallView = class("HallView", function ()
	return display.newNode()
end)

local HallCtrl = require("app.controller.hall.HallCtrl")

local HallSelfMiniView = import(".HallSelfMiniView")
local HallActListView = import(".HallActListView")
local HallBaseListView = import(".HallBaseListView")

function HallView:ctor()
	self.ctrl = HallCtrl.new()

	self:setNodeEventEnabled(true)
	self:initialize()
end

function HallView:initialize()
	display.newSprite(g.Res.hall_hallBg):addTo(self)

    display.newTTFLabel({
        	text = g.lang:getText("HALL", "HALL_TIPS"), size = 28, color = cc.c3b(128, 0, 0)})
    	:pos(0, 100)
		:addTo(self)
	
		g.myUi.ScaleButton.new({normal = g.Res.common_btnBlueS})
		:setButtonLabel(display.newTTFLabel({size = 24, text = g.lang:getText("HALL", "DIZHU")}))
		:onClick(handler(self.ctrl, self.ctrl.getDizhuTable))
		:pos(0, 0)
		:addTo(self)

	g.myUi.ScaleButton.new({normal = g.Res.common_btnBlueS})
		:setButtonLabel(display.newTTFLabel({size = 24, text = g.lang:getText("HALL", "RUMMY")}))
		:onClick(handler(self.ctrl, self.ctrl.getRummyTable))
		:pos(0, -100)
		:addTo(self)

	g.myUi.ScaleButton.new({normal = g.Res.common_btnBlueS})
		:setButtonLabel(display.newTTFLabel({size = 24, text = g.lang:getText("COMMON", "LOGOUT")}))
		:onClick(handler(self.ctrl, self.ctrl.logout))
		:pos(0, -200)
		:addTo(self)

	-- 自己头像
	HallSelfMiniView.new()
		:pos(-display.cx + 190, display.cy - 80)
		:addTo(self)

	-- 活动列表
	self.actListView = HallActListView.new()
		:pos(display.width/2 - 80, display.height/2 - 80)
		:addTo(self, 1)

	-- 基础功能列表
	self.baseListView = HallBaseListView.new()
		:pos(-display.width/2 + 80, -display.height/2 + 70)
		:addTo(self, 1)
end

function HallView:playShowAnim()
	if self.actListView and self.actListView.playShowAnim then
		self.actListView:playShowAnim()
	end
	if self.baseListView and self.baseListView.playShowAnim then
		self.baseListView:playShowAnim()
	end
end

function HallView:XXXX()
	
end

function HallView:XXXX()
	
end

function HallView:XXXX()
	
end

function HallView:onCleanup()
	self.ctrl:dispose()
end

return HallView

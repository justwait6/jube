local RummyView = class("RummyView", function ()
	return display.newNode()
end)

local RummyCtrl = require("app.controller.rummy.RummyCtrl")
local DownMenuView = require("app.view.rummy.DownMenuView")

local RummyConst = require("app.model.rummy.RummyConst")
local RVP = require("app.model.rummy.RoomViewPosition")
local P1 = RVP.SeatPosition

local mResDir = "image/rummy/" -- module resource directory

function RummyView:ctor(scene)
	self.scene = scene
	self.ctrl = RummyCtrl.new(self)
	self:setNodeEventEnabled(true)
	self:initialize()
	self:addEventListeners()
end

function RummyView:initialize()
	-- table bg
	local roombg = display.newSprite(mResDir .. "room_bg.png")
		:pos(display.cx, display.cy)
        :addTo(self.scene.nodes.bgNode)
	g.myFunc:checkScaleBg(roombg)
	
	-- return button
	local clickEvent = {self.menu, self.requestChangeTable, self.openRulePop, self.ctrl.backClick}
	 g.myUi.ScaleButton.new({normal = g.Res.commonroom_back})
	 	:onClick(handler(self, function(sender) 
			DownMenuView.new(clickEvent):show()
        end))
        :pos(display.left + 53, display.top - 55)
		:addTo(self.scene.nodes.bgNode)

	self.ctrl:initRoomNode(self.scene.nodes.roomNode)
	self.ctrl:initSeatNode(self.scene.nodes.seatNode)
	self.ctrl:initAnimNode(self.scene.nodes.animNode)
end

function RummyView:addEventListeners()
	g.event:on(g.eventNames.LOBBY_UPDATE, handler(self, self.XXXX), self)
end

function RummyView:menu()
	print(1)
end

function RummyView:requestChangeTable()
	print(2)
end

function RummyView:openRulePop()
	print(3)
end

function RummyView:XXXX()
	
end

function RummyView:onCleanup()
	g.event:removeByTag(self)
	self.ctrl:dispose()
end

return RummyView

local RoomView = class("RoomView", function ()
	return display.newNode()
end)

local RoomCtrl = require("app.controller.rummy.RoomCtrl")
local DownMenuView = require("app.view.rummy.DownMenuView")

local RoomConst = require("app.model.rummy.RoomConst")
local RVP = require("app.model.rummy.RoomViewPosition")
local P1 = RVP.SeatPosition

local mResDir = "image/rummy/" -- module resource directory

function RoomView:ctor(scene)
	self.scene = scene
	self.ctrl = RoomCtrl.new(self)
	self:setNodeEventEnabled(true)
	self:initialize()
	self:addEventListeners()
end

function RoomView:initialize()
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

function RoomView:addEventListeners()
	g.event:on(g.eventNames.LOBBY_UPDATE, handler(self, self.XXXX), self)
end

function RoomView:menu()
	print(1)
end

function RoomView:requestChangeTable()
	print(2)
end

function RoomView:openRulePop()
	print(3)
end

function RoomView:XXXX()
	
end

function RoomView:onCleanup()
	g.event:removeByTag(self)
	self.ctrl:dispose()
end

return RoomView

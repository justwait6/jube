local RoomManager = class("RoomManager")

local roomInfo = require("app.model.dizhu.RoomInfo").getInstance()
local seatMgr = require("app.model.dizhu.SeatManager").getInstance()
local RoomUtil = require("app.model.dizhu.RoomUtil")
local RoomConst = require("app.model.dizhu.RoomConst")

local RVP = require("app.model.dizhu.RoomViewPosition")
local P = RVP.OperBtnPosition

local mResDir = "image/dizhu/" -- module resource directory
local commonRoomResDir = "image/commonroom/" -- module resource directory

function RoomManager:ctor()
	self:initialize()
end

function RoomManager:initialize()
    self.operBtns = {}
    self:addEventListeners()
end

function RoomManager:addEventListeners()
end

function RoomManager:setRoomCtrl(roomCtrl)
	self.roomCtrl_ = roomCtrl
end

function RoomManager:initRoomNode(sceneRoomNode)
    self.sceneRoomNode_ = sceneRoomNode

	-- operate btns
	self:initOperBtn()
end

function RoomManager.getInstance()
    if not RoomManager.singleInstance then
        RoomManager.singleInstance = RoomManager.new()
    end
    return RoomManager.singleInstance
end

function RoomManager:initOperBtn()
    self.addOddsBtn = g.myUi.ScaleButton.new({normal = mResDir .. "buttons/bt_green_bg.png"})
	:onClick(handler(self.roomCtrl_, self.roomCtrl_.onAddOddsClick))
		:addTo(self.sceneRoomNode_)
		:pos(P[0].x, P[0].y)
		:hide()
        :setSwallowTouches(false)
    self.addOddsBtn:setButtonLabel(display.newSprite(mResDir .. "buttons/orange_visible_cards_mul5.png"))
    table.insert(self.operBtns, self.beginBtn)

    self.beginBtn = g.myUi.ScaleButton.new({normal = mResDir .. "buttons/bt_orange_bg.png"})
	:onClick(handler(self.roomCtrl_, self.roomCtrl_.onBeginClick))
		:addTo(self.sceneRoomNode_)
		:pos(P[1].x, P[1].y)
		:hide()
        :setSwallowTouches(false)
    self.beginBtn:setButtonLabel(display.newSprite(mResDir .. "buttons/begin.png"))
	table.insert(self.operBtns, self.beginBtn)
end

function RoomManager:updateOperBtns(tableState)
    if tableState == RoomConst.TState_NotPlay then
        self.addOddsBtn:show()
        self.beginBtn:show()
    end
end
function RoomManager:selfReady()
    self.addOddsBtn:hide()
    self.beginBtn:hide()
end

function RoomManager:clearAll()
end

function RoomManager:dispose()
	self:clearAll()
	g.mySched:cancelAll()
end

return RoomManager

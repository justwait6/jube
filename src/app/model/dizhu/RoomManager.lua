local RoomManager = class("RoomManager")

local roomInfo = require("app.model.dizhu.RoomInfo").getInstance()
local seatMgr = require("app.model.dizhu.SeatManager").getInstance()
local RoomUtil = require("app.model.dizhu.RoomUtil")

local RVP = require("app.model.dizhu.RoomViewPosition")
local P2 = RVP.OperBtnPosition

local mResDir = "image/dizhu/" -- module resource directory
local commonRoomResDir = "image/commonroom/" -- module resource directory

function RoomManager:ctor()
	self:initialize()
end

function RoomManager:initialize()
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
end

function RoomManager:clearAll()
end

function RoomManager:dispose()
	self:clearAll()
	g.mySched:cancelAll()
end

return RoomManager

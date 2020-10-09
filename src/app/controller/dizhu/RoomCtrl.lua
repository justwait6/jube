local RoomCtrl = class("RoomCtrl")

local CmdDef = require("app.core.protocol.CommandDef")
local roomMgr = require("app.model.dizhu.RoomManager").getInstance()
local seatMgr = require("app.model.dizhu.SeatManager").getInstance()
local RoomConst = require("app.model.dizhu.RoomConst")
local roomInfo = require("app.model.dizhu.RoomInfo").getInstance()
local RoomUtil = require("app.model.dizhu.RoomUtil")

local PACKET_PROC_FRAME_INTERVAL = 2

function RoomCtrl:ctor()
	self.packetCache_ = {}
	self.frameNo_ = 1
	self:initialize()
	self:addEventListeners()

	g.mySched:doLoop(function()
		if self.onEnterFrame_ then
			return self:onEnterFrame_()
		end
    end, 1 / 60)
end

function RoomCtrl:initialize()
end

function RoomCtrl:addEventListeners()
	g.event:on(g.eventNames.PACKET_RECEIVED, handler(self, self.onPackReceived_), self)
end

function RoomCtrl:initSeatNode(sceneSeatNode)
	seatMgr:setRoomCtrl(self)
	seatMgr:initSeatNode(sceneSeatNode)
end

function RoomCtrl:initRoomNode(sceneRoomNode)
	roomMgr:setRoomCtrl(self)
	roomMgr:initRoomNode(sceneRoomNode)
end

function RoomCtrl:initAnimNode(sceneAnimNode)
	seatMgr:initAnimNode(sceneAnimNode)
end

function RoomCtrl:onPackReceived_(packet)
	table.insert(self.packetCache_, packet)
end

function RoomCtrl:onEnterFrame_()
	if #self.packetCache_ > 0 then		
		if #self.packetCache_ == 1 then
            self.frameNo_ = 1
			local pack = table.remove(self.packetCache_, 1)
			self:processPacket_(pack)
		else					
            -- 先检查并干掉累计的超过一局的包
            local removeFromIdx = 0
            local removeEndIdx = 0
            for i, v in ipairs(self.packetCache_) do
				if v.cmd == CmdDef.SVR_GAME_OVER then
                    if removeFromIdx == 0 then
                        removeFromIdx = removeFromIdx + 1
                        -- 这里从结束包的下一个开始干掉
                    else
                        removeEndIdx = i
                        -- 到最后一个结束包
                    end
                end
			end
			if removeFromIdx ~= 0 and removeEndIdx ~= 0 then
                -- 干掉超过一局的包，但是要保留坐下站起包，已保证座位数据正确
                local keepPackets = { }
                for i = removeFromIdx, removeEndIdx do
                    local pack = table.remove(self.packetCache_, i)
                    if not pack then return true end
                    if pack.cmd == CmdDef.SVR_BROADCAST_OFF or pack.cmd == CmdDef.SVR_STAND_UP then
                        keepPackets[#keepPackets + 1] = pack
                        pack.fastForward = true
                    end
                end
                if #keepPackets > 0 then
                    table.insertto(self.packetCache_, keepPackets, removeFromIdx)
                end
            end
            self.frameNo_ = self.frameNo_ + 1
            if self.frameNo_ > PACKET_PROC_FRAME_INTERVAL then
                self.frameNo_ = 1
								local pack = table.remove(self.packetCache_, 1)
                self:processPacket_(pack)
            end
        end
    end
    return true
end

function RoomCtrl:processPacket_(pack)
	local cmd = pack.cmd
	if cmd == CmdDef.SVR_ENTER_ROOM then
		self:enterRoom(pack)
	end
end

function RoomCtrl:enterRoom(pack)
	if pack.ret == 0 then
		g.Var.level = tonumber(pack.level)
		
	else 
		local msg = "unknown error"
		if pack.ret == 3 then
			msg = g.lang:getText("RUMMY", "LOGIN_ERROR")
		elseif pack.ret == 4 then
			msg = g.lang:getText("RUMMY", "TABLE_NOT_EXIST")
		elseif pack.ret == 6 then
			msg = g.lang:getText("RUMMY", "TABLE_FULL")
		elseif pack.ret == 14 then
			msg = g.lang:getText("RUMMY", "LESS_MONEY")
		elseif pack.ret == 15 then
			msg = g.lang:getText("RUMMY", "TOO_MUCH_MONEY")
		end
		g.myUi.topTip:showText(msg)
		local id = g.mySched:doDelay(function()
				g.mySched:cancel(id)
				g.myApp:enterScene("HallScene")
			end, 1.5)
	end
end

function RoomCtrl:backClick()
	if RoomConst.isMeInGames then
		g.myUi.Dialog.new({
			type = g.myUi.Dialog.Type.NORMAL,
			text = g.lang:getText("RUMMY", "EXITTIPS"),
			onConfirm = RoomCtrl.logoutRoom,	
		}):show()
 	else
		RoomCtrl.logoutRoom()
 	end
end

function RoomCtrl:logoutRoom()
	if g.mySocket:isConnected() then
		g.mySocket:send(g.mySocket:createPacketBuilder(CmdDef.CLI_EXIT_ROOM)
	   :setParameter("uid", tonumber(g.user:getUid()))
	   :setParameter("tid", tonumber(g.Var.tid)):build())
	end
end

function RoomCtrl:exitRoom(pack)
	if not pack then return end
	if pack.ret == 0 then
		if pack.money and pack.money >= 0 then
			g.user:setMoney(pack.money)
		end
		g.myApp:enterScene("HallScene")
	end
end

function RoomCtrl:castUserSit(pack)
	if not pack then return end
	seatMgr:castUserSit(pack)
end

function RoomCtrl:castUserExit(pack)
	if not pack then return end
	seatMgr:castUserExit(pack)
end

function RoomCtrl:XXXX()
	
end

function RoomCtrl:XXXX()
	
end

function RoomCtrl:dispose()
	seatMgr:dispose()
	roomMgr:dispose()
	g.event:removeByTag(self)
end

return RoomCtrl

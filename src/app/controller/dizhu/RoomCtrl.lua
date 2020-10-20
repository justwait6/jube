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
	elseif cmd == CmdDef.SVR_EXIT_ROOM then
		self:exitRoom(pack)
	elseif cmd == CmdDef.SVR_CAST_EXIT_ROOM then
		self:castUserExit(pack)
	elseif cmd == CmdDef.SVR_CAST_USER_SIT then
		self:castUserSit(pack)
	elseif cmd == CmdDef.SVR_DIZHU_READY then
		self:ready(pack)
	elseif cmd == CmdDef.SVR_CAST_DIZHU_READY then
		self:castReady(pack)
	elseif cmd == CmdDef.SVR_DIZHU_GAME_START then
		self:gameStart(pack)
	elseif cmd == CmdDef.SVR_DIZHU_GRAB_TURN then
		self:grabTurn(pack)
	elseif cmd == CmdDef.SVR_DIZHU_GRAB then
		self:grab(pack)
	elseif cmd == CmdDef.SVR_CAST_DIZHU_GRAB then
		self:castGrab(pack)
	elseif cmd == CmdDef.SVR_DIZHU_GRAB_RESULT then
		self:castGrabResult(pack)
	elseif cmd == CmdDef.SVR_DIZHU_TURN then
		self:userTurn(pack)
	elseif cmd == CmdDef.SVR_DIZHU_OUT_CARD then
		self:outCard(pack)
	elseif cmd == CmdDef.SVR_CAST_DIZHU_OUT_CARD then
		self:castOutCard(pack)
	end
end

function RoomCtrl:enterRoom(pack)
	if pack.ret == 0 then
		g.Var.level = tonumber(pack.level)
		pack.mPlayer = self:mPlayerLoginInfo(pack.players, pack.users)
		seatMgr:initSeats(pack)
		roomMgr:updateOperBtns(pack.state)
		if pack.mPlayer.state == RoomConst.UserState_Ready then self:simulateReady() end
		if pack.state == RoomConst.TState_InPlay then
			roomInfo:setMCards(pack.cards)
			seatMgr:updateMCards()
			if pack.detailState == RoomConst.TDetailState_Grab then
				seatMgr:reconnectWhenGrab(pack.users)
				self:simulateGrabTurn(pack.operUid, pack.leftOperSec, pack.odds)
			elseif pack.detailState == RoomConst.TDetailState_Play then
				roomMgr:updateDizhuArea(pack.bottomCards, pack.odds)
				if pack.isNewRound == 0 then roomInfo:setLatestOutCards(pack.latestOutCards) end
				seatMgr:doShowDizhuIcon(pack.dUid, true)
				seatMgr:reconnectWhenPlay(pack.users)
				self:simulateUserTurn(pack.operUid, pack.leftOperSec, pack.isNewRound)
			end
		end
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

function RoomCtrl:mPlayerLoginInfo(players, users)
	local mPlayer = {}
	if type(players) == "table" and (#players) > 0 then
		for i = 1, #players do
			if g.user:getUid() == tonumber(players[i].uid) then
				for k, v in pairs(players[i]) do
					mPlayer[k] = v
				end
			end
		end
    end
    if type(users) == "table" and (#users) > 0 then
		for i = 1, #users do
			if g.user:getUid() == tonumber(users[i].uid) then
				for k, v in pairs(users[i]) do
					mPlayer[k] = v
				end
			end
		end
	end
	roomInfo:setMSeatId(mPlayer.seatId or -1)

	return mPlayer
end

function RoomCtrl:castUserSit(pack)
	if not pack then return end
	seatMgr:castUserSit(pack)
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

function RoomCtrl:ready(pack)
	if not pack then return end
	if pack.ret == 0 then
		seatMgr:doReady(g.user:getUid())
		roomMgr:selfReady()
	end
end

function RoomCtrl:castReady(pack)
	if not pack then return end
	seatMgr:doCastReady(pack.uid)
end

function RoomCtrl:gameStart(pack)
	if not pack then return end
	seatMgr:clearTable()
	roomInfo:setMCards(pack.cards)
	seatMgr:doDealCardsAnim(pack.cards)
end

function RoomCtrl:grabTurn(pack)
	if not pack then return end
	seatMgr:startCountDown(pack.time, pack.uid)
	if pack.uid == g.user:getUid() then
		seatMgr:hideWordText(g.user:getUid())
		roomMgr:doWhenGrabTurn(pack.odds)
	else
		roomMgr:hideGrabBtns()
	end
end

function RoomCtrl:simulateGrabTurn(uid_, time_, odds_)
	self:grabTurn({uid = uid_, time = time_, odds = odds_})
end

function RoomCtrl:grab(pack)
	if not pack then return end
	if pack.ret == 0 then
		seatMgr:doGrab(pack.isGrab, pack.odds)
		roomMgr:hideGrabBtns()
	end
end

function RoomCtrl:castGrab(pack)
	if not pack then return end
	seatMgr:doCastGrab(pack.uid, pack.isGrab, pack.odds)
end

function RoomCtrl:castGrabResult(pack)
	if not pack then return end
	roomMgr:updateDizhuArea(pack.cards, pack.odds)
	seatMgr:doGrabResult(pack.uid)
	if pack.uid == g.user:getUid() then
		local cards = RoomUtil.addCards(roomInfo:getMCards(), pack.cards)
		roomInfo:setMCards(cards);
		seatMgr:insertCardsAnim(pack.cards)
	end
end

function RoomCtrl:userTurn(pack)
	if not pack then return end
	seatMgr:startCountDown(pack.time, pack.uid)
	if pack.uid == g.user:getUid() then
		seatMgr:doWhenSelfTurn()
		roomMgr:doWhenSelfTurn(pack.isNewRound)
	else
		roomMgr:hideTurnBtns()
	end
end

function RoomCtrl:simulateUserTurn(uid_, time_, isNewRound_)
	self:userTurn({uid = uid_, time = time_, isNewRound = isNewRound_})
end

function RoomCtrl:outCard(pack)
	if not pack then return end
	if pack.ret == 0 then
		roomMgr:hideTurnBtns()
		seatMgr:hideMCardsTip()
		seatMgr:stopCountDown(g.user:getUid())
		if pack.isOut == 1 then
			local cards = RoomUtil.minusCards(roomInfo:getMCards(), roomInfo:getSelCards())
			roomInfo:setMCards(cards)
			seatMgr:clearOutCardArea(g.user:getUid())
			local selCards = roomInfo:getSelCards()
    		local cardType = RoomUtil.getCardType(selCards)
			seatMgr:selfOutCardsAnim(cardType, selCards)
		else
			seatMgr:doUserNoOut(g.user:getUid())
		end
	end
end

function RoomCtrl:castOutCard(pack)
	if not pack then return end
	seatMgr:stopCountDown(pack.uid)
	if pack.isOut == 1 then
		roomInfo:setLatestOutCards(pack.cards)
		seatMgr:clearOutCardArea(pack.uid)
		seatMgr:otherOutCardsAnim(pack.uid, pack.cardType, pack.cards)
	else
		seatMgr:doUserNoOut(pack.uid)
	end
end

-- 前提: 重连包, 用户在玩(桌子状态在玩)
function RoomCtrl:simulateReady(pack)
	local simulatePack = {}
    simulatePack.ret = 0
    self:ready(simulatePack)
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
	   :setParameter("uid", g.user:getUid())
	   :setParameter("tid", tonumber(g.Var.tid)):build())
	end
end

function RoomCtrl:onAddOddsClick()
	print("todo, shown cards play")
end

function RoomCtrl:onBeginClick()
	if g.mySocket:isConnected() then
		g.mySocket:send(g.mySocket:createPacketBuilder(CmdDef.CLI_DIZHU_READY)
	   :setParameter("uid", g.user:getUid()):build())
	end
end

function RoomCtrl:onGrabClick()
	self:cliSendGrab(1)
end

function RoomCtrl:onNoGrabClick()
	self:cliSendGrab(0)
end

function RoomCtrl:onNoOutClick()
	self:cliSendOutCards(0)
end

function RoomCtrl:onOutCardClick()
	local selCards = roomInfo:getSelCards()
	local cardType = RoomUtil.getCardType(selCards)
	local isOk = false
	if cardType == RoomConst.CARD_T_NONE then
		seatMgr:outCardsInvalid()
		return
	end
	if roomInfo:isSelfNewRound() then
		isOk = true
	else
		local ret = RoomUtil.vsCards(selCards, roomInfo:getLatestOutCards())
		printVgg("onOutCardClick vs ret: ", ret)
		if ret == 1 then
			isOk = true
		end
	end
	if isOk then
		printVgg("onOutCardClick", cardType)
		dump(selCards, "onOutCardClick selCards")
		self:cliSendOutCards(1, cardType, selCards)
	end
end

function RoomCtrl:onPromptClick()
	local promptCards = RoomUtil.promptOutCards(roomInfo:getMCards(), roomInfo:getLatestOutCards())
	if promptCards then
		seatMgr:raisePromptCards(promptCards)
	end
end

function RoomCtrl:cliSendGrab(isGrab)
	if g.mySocket:isConnected() then
		g.mySocket:send(g.mySocket:createPacketBuilder(CmdDef.CLI_DIZHU_GRAB)
	   :setParameter("uid", g.user:getUid())
	   :setParameter("isGrab", isGrab):build())
	end
end

function RoomCtrl:cliSendOutCards(isOutNum, cardType, cards)
	if g.mySocket:isConnected() then
		local pack = g.mySocket:createPacketBuilder(CmdDef.CLI_DIZHU_OUT_CARD)
			:setParameter("uid", g.user:getUid())
			:setParameter("isOut", isOutNum)
		if isOutNum == 1 then
			pack:setParameter("cardType", cardType)
			local rfCards = {}
			for _, sCard in pairs(cards) do
				table.insert(rfCards, {card = sCard})
			end
			pack:setParameter("cards", rfCards)
			print("cliSendOutCards... cardType", cardType)
			dump(rfCards, "rfCards")
		end
		g.mySocket:send(pack:build())
	end
end

function RoomCtrl:showCannotTips()
	seatMgr:selfCannotOut()
end

function RoomCtrl:XXXX()
	
end

function RoomCtrl:XXXX()
	
end

function RoomCtrl:XXXX()
	
end

function RoomCtrl:XXXX()
	
end

function RoomCtrl:vggTest()

	print("todo, test function")
	local testSim_ = {
		cards = {3, 35, 51, 52, 5, 37, 25, 57, 10, 26, 42, 59, 12, 44, 14, 46, 78,},
		cmd = 5281,
	}
	self:gameStart(testSim_)
end

function RoomCtrl:vggTest2()
	print("todo, test function")

	-- local testSim_ = {
	-- 	cards = {7, 8, 30,},
	-- 	cmd = 5283,
	-- 	odds = 3,
	-- 	uid = 1,
	-- }
	-- self:castGrabResult(testSim_)
	local promptCards = RoomUtil.promptOutCards(roomInfo:getMCards(), {4,23,39,55,})
	if promptCards then
		seatMgr:raisePromptCards(promptCards)
	end
	-- seatMgr:outCardsInvalid()
end

function RoomCtrl:dispose()
	seatMgr:dispose()
	roomMgr:dispose()
	g.event:removeByTag(self)
end

return RoomCtrl

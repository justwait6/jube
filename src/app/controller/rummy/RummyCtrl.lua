local RummyCtrl = class("RummyCtrl")

local CmdDef = require("app.core.protocol.CommandDef")
local roomMgr = require("app.model.rummy.RoomManager").getInstance()
local seatMgr = require("app.model.rummy.SeatManager").getInstance()
local RummyConst = require("app.model.rummy.RummyConst")
local roomInfo = require("app.model.rummy.RoomInfo").getInstance()
local RummyUtil = require("app.model.rummy.RummyUtil")

local DropCardsView = require("app.view.rummy.DropCardsView")

local PACKET_PROC_FRAME_INTERVAL = 2

function RummyCtrl:ctor()
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

function RummyCtrl:initialize()
end

function RummyCtrl:addEventListeners()
	g.event:on(g.eventNames.PACKET_RECEIVED, handler(self, self.onPackReceived_), self)
end

function RummyCtrl:initSeatNode(sceneSeatNode)
	seatMgr:setRummyCtrl(self)
	seatMgr:initSeatNode(sceneSeatNode)
end

function RummyCtrl:initRoomNode(sceneRoomNode)
	roomMgr:setRummyCtrl(self)
	roomMgr:initRoomNode(sceneRoomNode)
end

function RummyCtrl:initAnimNode(sceneAnimNode)
	seatMgr:initAnimNode(sceneAnimNode)
end

function RummyCtrl:onPackReceived_(packet)
	table.insert(self.packetCache_, packet)
end

function RummyCtrl:onEnterFrame_()
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

function RummyCtrl:processPacket_(pack)
	local cmd = pack.cmd
	if cmd == CmdDef.SVR_ENTER_ROOM then
		self:enterRoom(pack)
	elseif cmd == CmdDef.SVR_EXIT_ROOM then
		self:exitRoom(pack)
	elseif cmd == CmdDef.SVR_CAST_EXIT_ROOM then
		self:castUserExit(pack)
	elseif cmd == CmdDef.SVR_CAST_USER_SIT then
		self:castUserSit(pack)
	elseif cmd == CmdDef.SVR_RUMMY_COUNTDOWN then
		self:gameStartCountDown(pack)
	elseif cmd == CmdDef.SVR_RUMMY_GAME_START then
		self:gameStart(pack)
	elseif cmd == CmdDef.SVR_RUMMY_DEAL_CARDS then
		self:startDealCards(pack, true)
	elseif cmd == CmdDef.SVR_RUMMY_USER_TURN then
		self:castUserTurn(pack)
	elseif cmd == CmdDef.SVR_RUMMY_DRAW_CARD then
		self:selfDraw(pack)
	elseif cmd == CmdDef.SVR_CAST_RUMMY_DRAW_CARD then
		self:castUserDraw(pack)
	elseif cmd == CmdDef.SVR_RUMMY_DISCARD_CARD then
		self:selfDiscard(pack)
	elseif cmd == CmdDef.SVR_CAST_RUMMY_DISCARD then
		self:castUserDiscard(pack)
	elseif cmd == CmdDef.SVR_RUMMY_FINISH then
		self:selfFinish(pack)
	elseif cmd == CmdDef.SVR_CAST_RUMMY_FINISH then
		self:castUserFinish(pack)
	elseif cmd == CmdDef.SVR_RUMMY_DECLARE then
		self:selfDeclare(pack)
	elseif cmd == CmdDef.SVR_CAST_RUMMY_DECLARE then
		self:castUserDeclare(pack)
	elseif cmd == CmdDef.SVR_RUMMY_DROP then
		self:selfDrop(pack)
	elseif cmd == CmdDef.SVR_CAST_RUMMY_DROP then
		self:castUserDrop(pack)
	elseif cmd == CmdDef.SVR_RUMMY_UPLOAD_GROUPS then
		printVgg("upload groups, ret: ", pack.ret)
	elseif cmd == CmdDef.SVR_RUMMY_GET_DROP_CARDS then
		DropCardsView.new(pack):show()
	end
end

function RummyCtrl:enterRoom(pack)
	if pack.ret == 0 then
		g.Var.level = tonumber(pack.level)
		pack.mPlayer = self:mPlayerLoginInfo(pack.players, pack.users)
		pack.dSeatId = seatMgr:querySeatIdByUid(pack.dUid)
		roomMgr:enterRoomInfo(pack, pack.mPlayer.money)
		seatMgr:initSeats(pack)
		-- if pack.state and tonumber(pack.state) == 1 then -- 游戏正在进行
		-- 	RummyConst.isFinalGame = false
		-- 	self:simulateStartDealCards(pack)
		-- 	self:simulateUserTurn(pack)
		-- 	seatMgr:inGameReconnectInfo(pack)
		-- 	print("enterRoom: isSelfInGame", self:isSelfInGame(pack.users))
		-- 	if self:isSelfInGame(pack.users) then -- 自己正在玩
		-- 		pack.cards = RummyUtil.calcMCardsByReconnect(pack.groups, pack.drawCardPos)
		-- 		roomInfo:setMCards(pack.cards)
		-- 		roomMgr:selfInGameReconnectInfo(pack)
		-- 		seatMgr:selfInGameReconnectInfo(pack)
		-- 		local isOk = RummyUtil.refreshGroupsByReconnect(pack.groups, pack.drawCardPos)
		-- 		print("enterRoom: refreshGroupsByReconnect", isOk)
		-- 		if isOk then
		-- 			seatMgr:updateMCards(roomInfo:getCurGroups(), true)
		-- 		end
		-- 		if tonumber(pack.mPlayer.isNeedDeclare) == 1 then -- 需要declare
		-- 			seatMgr:updateFinishSlotCard(pack.finishCard)
		-- 			self:simulateNotifyLeftMeDeclare({time = pack.leftOperSec})
		-- 		elseif tonumber(pack.mPlayer.isFinishDeclare) == 1 then -- 自己已完成declare, 结算界面
		-- 			print("todo, 展示结算界面")
		-- 		end
		-- 	elseif tonumber(pack.mPlayer.isDrop) == 1 then -- 自己已经弃牌
		-- 		self:simulateSelfDrop({ret = 0})
		-- 	else -- 等待, 观战中
		-- 		roomMgr:showWaitNextGameTips()
		-- 	end
		-- end
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

function RummyCtrl:mPlayerLoginInfo(players, users)
	local mPlayer = {}
	if type(players) == "table" and (#players) > 0 then
		for i = 1, #players do
			if tonumber(g.user:getUid()) == tonumber(players[i].uid) then
				for k, v in pairs(players[i]) do
					mPlayer[k] = v
				end
			end
		end
    end
    if type(users) == "table" and (#users) > 0 then
		for i = 1, #users do
			if tonumber(g.user:getUid()) == tonumber(users[i].uid) then
				for k, v in pairs(users[i]) do
					mPlayer[k] = v
				end
			end
		end
	end
	roomInfo:setMSeatId(mPlayer.seatId or -1)

	return mPlayer
end

function RummyCtrl:gameStartCountDown(pack)
	if not pack then return end
	roomMgr:clearTable()
	seatMgr:clearTable()
	roomMgr:countDownTips(pack.leftSec)
end

function RummyCtrl:gameStart(pack)
	if not pack then return end
	pack.dSeatId = seatMgr:querySeatIdByUid(pack.dUid)
	roomInfo:setDSeatId(pack.dSeatId or -1)
	seatMgr:gameStart(pack, function()
		roomMgr:updateDSeat(roomInfo:getDSeatId(), true)
	end)
end

function RummyCtrl:startDealCards(pack, needAnim)
	if not pack then return end
	roomInfo:setMCards(pack.cards)
	roomInfo:setMagicCard(pack.magicCard)
	seatMgr:startDealCards(pack, needAnim, function()
		roomMgr:onStartDealCardsFinish()
	end)
end

function RummyCtrl:castUserTurn(pack)
	if not pack then return end
	local name = seatMgr:queryUsernameByUid(pack.uid)
	local str = string.format(g.lang:getText("RUMMY", "TURN_TO_PLAY_FMT"), (name or pack.uid))
	roomMgr:playMiddleTips(str)
	if pack.uid == tonumber(g.user:getUid()) then
		-- g.audio:playSound(g.audio.YOUR_TURN)
		roomMgr:onSelfTurn()
		roomInfo:resetWhenSelfTurn()
		seatMgr:showAreaLightsDrawStage() -- 轮到用户自己, 进入摸牌阶段
	else
		roomMgr:onNotSelfTurn()
		seatMgr:hideAllAreaLights() -- 不到用户自己, 隐藏亮光
	end
	seatMgr:startCountDown(pack.time or 0, pack.uid)
end

function RummyCtrl:selfDraw(pack)
    if not pack then return end
    if tonumber(pack.ret) == 0 then
        local mCards = roomInfo:getMCards()
        table.insert(mCards, pack.card)
		roomInfo:setMCards(mCards)
		
		local name = seatMgr:queryUsernameByUid(uid)
		roomMgr:playDrawCardTips(name, uid, pack.region)

        RummyUtil.refreshGroupsByDraw(pack.card)
        seatMgr:selfDrawCardAnim(pack, handler(self, function()
			seatMgr:updateMCards(roomInfo:getCurGroups())
			seatMgr:showAreaLightsDiscardStage() -- 摸牌后, 进入弃牌阶段
        end))
        roomMgr:AfterSelfDrawCard()
    end
end

function RummyCtrl:castUserDraw(pack)        
	if tonumber(pack.uid) ~= tonumber(g.user:getUid()) then
		local name = seatMgr:queryUsernameByUid(uid)
		roomMgr:playDrawCardTips(name, uid, pack.region)
		seatMgr:otherDrawCardAnim(pack)
	end
end
--自己弃一张牌操作
function RummyCtrl:selfDiscard(pack)
	if not pack then return end
	if pack.ret == 0 then
		local cardIdx = pack.index
		if cardIdx == -1 then -- 系统帮玩家出牌(摸的那张牌, 牌id标记为14)
			cardIdx = RummyConst.DRAW_CARD_ID
		end
		if cardIdx >= 1 and cardIdx <= RummyConst.DRAW_CARD_ID then
			local mCards = roomInfo:getMCards()
			table.remove(mCards, cardIdx)
			if cardIdx ~= RummyConst.DRAW_CARD_ID then
				local lastCard = table.remove(mCards)
				table.insert(mCards, cardIdx, lastCard)
			end
			roomInfo:setMCards(mCards)
			RummyUtil.refreshGroupsByDiscard(cardIdx)
		end
		print("selfDiscardCard: cardIdx, pack.dropCard", cardIdx, pack.dropCard)
		-- g.audio:playSound(g.Audio.SANGONG_FOLD)
		seatMgr:onSelfDiscardCard(pack.dropCard, cardIdx)
		roomMgr:onNotSelfTurn()
	end
end

function RummyCtrl:castUserDiscard(pack)
	if not pack then return end
	if tonumber(pack.uid) == tonumber(g.user:getUid()) then return end
	seatMgr:stopCountDown(pack.uid)
	seatMgr:otherDiscardCardAnim(pack)
	-- g.audio:playSound(g.Audio.SANGONG_FOLD)
end

function RummyCtrl:selfFinish(pack)
    if not pack then return end
    if pack.ret == 0 then -- 成功
        local mCards = roomInfo:getMCards()
        local cardIdx = roomInfo:getFinishCardIndex()
        local finishCard = mCards[cardIdx]
        if cardIdx >= 1 and cardIdx <= RummyConst.DRAW_CARD_ID then
            local mCards = roomInfo:getMCards()
            table.remove(mCards, cardIdx)
            if cardIdx ~= RummyConst.DRAW_CARD_ID then
                local lastCard = table.remove(mCards)
                table.insert(mCards, cardIdx, lastCard)
            end
            roomInfo:setMCards(mCards)
            RummyUtil.refreshGroupsByDiscard(cardIdx)
        end

        roomMgr:hideOperBtn()
        print("-- todo, 自己finish动画")

        seatMgr:selfFinishCardAnim(finishCard, cardIdx, function()
            seatMgr:updateMCards(roomInfo:getCurGroups())

            -- 提示玩家组牌
            roomMgr:showDeclareTips("Please group your cards and declare.", pack.time or 0)
            seatMgr:startCountDown(pack.time or 0, g.user:getUid())
        end)
    end
end

function RummyCtrl:castUserFinish(pack)
    if not pack then return end
    if tonumber(pack.uid) == tonumber(g.user:getUid()) then return end -- 如果是自己, 返回
    seatMgr:startCountDown(pack.time or 0, pack.uid)
    seatMgr:otherFinishCardAnim(pack)
    print("-- todo, 广播用户finish牌动画")
	-- g.audio:playSound(g.audio.SANGONG_FOLD)
end

function RummyCtrl:selfDeclare(pack)
	if not pack then return end
	-- ret为0, 合法declare; ret为10, 尝试[first-valid-declare]失败; ret为11, 剩余玩家declare
    if tonumber(pack.ret) == 0 or tonumber(pack.ret) == 10 or tonumber(pack.ret) == 11 then
        seatMgr:stopCountDown(g.user:getUid())
		seatMgr:clearTable()
		roomMgr:clearTable()
		seatMgr:selfDeclare(pack)
        if tonumber(pack.ret) == 10 then -- 尝试[first-valid-declare]失败, 弃牌
            self:simulateSelfDrop({ret = 0})
        end
    end
end

function RummyCtrl:simulateSelfDeclare(pack)
    self:selfDeclare(pack)
end

function RummyCtrl:castUserDeclare(pack)
    if not pack then return end
    seatMgr:stopCountDown(pack.uid)
    if pack.ret == 0 then -- declare成功
        seatMgr:showFinishSlotCard()
        if tonumber(pack.uid) ~= tonumber(g.user:getUid())
            and #(roomInfo:getMCards() or {}) > 0 then -- 不是自己, 且在玩
            self:simulateNotifyLeftMeDeclare({declareUid = pack.uid, time = pack.time})
        end
        -- 保存其他玩家declare时间
        roomInfo:setDeclareTime(pack.time)
        roomInfo:setDeclareTimeMinus(g.timeUtil:getSocketTime())
        roomInfo:setIsNewRoundCount(false)
    else -- declare失败
        -- finish牌移动到弃牌区域
        seatMgr:cardFinishAreaToDiscardArea()
        self:simulateCastUserDrop({uid = pack.uid})
    end
    if tonumber(pack.uid) == tonumber(g.user:getUid()) then
        self:simulateSelfDeclare({ret = pack.ret})
    end
end

function RummyCtrl:simulateNotifyLeftMeDeclare(pack)
    roomMgr:hideOperBtn()
    seatMgr:startCountDown(pack.time or 0, g.user:getUid())
    local str = "Please group your cards and declare."
    if pack.declareUid then
        local name = seatMgr:queryUsernameByUid(pack.declareUid)
        str = string.format("%s has made a valid declaration, Please group your cards and declare.", (name or pack.declareUid))
    end
    roomMgr:showDeclareTips(str, pack.time)
end

function RummyCtrl:selfDrop(pack)
    if not pack then return end
	if tonumber(pack.ret) == 0 then -- 弃牌成功
		pack.uid = g.user:getUid()
        roomInfo:clearMCards()
        seatMgr:stopCountDown(g.user:getUid())
		seatMgr:selfDrop(pack)
        roomMgr:onSelfDrop()
    end
end

function RummyCtrl:simulateSelfDrop(pack)
    self:selfDrop(pack)
end

function RummyCtrl:castUserDrop(pack)
    if not pack then return end
    seatMgr:stopCountDown(pack.uid)
    if tonumber(pack.uid) == tonumber(g.user:getUid()) then
        self:simulateSelfDrop({ret = 0})
    end
    seatMgr:userDrop(pack)
end

function RummyCtrl:simulateCastUserDrop(pack)
    self:castUserDrop(pack)
end

function RummyCtrl:backClick()
	if RummyConst.isMeInGames then
		g.myUi.Dialog.new({
			type = g.myUi.Dialog.Type.NORMAL,
			text = g.lang:getText("RUMMY", "EXITTIPS"),
			onConfirm = RummyCtrl.logoutRoom,	
		}):show()
 	else
		RummyCtrl.logoutRoom()
 	end
end

function RummyCtrl:logoutRoom()
	if g.mySocket:isConnected() then
		g.mySocket:send(g.mySocket:createPacketBuilder(CmdDef.CLI_EXIT_ROOM)
	   :setParameter("uid", tonumber(g.user:getUid()))
	   :setParameter("tid", tonumber(g.Var.tid)):build())
	end
end

function RummyCtrl:exitRoom(pack)
	if not pack then return end
	if pack.ret == 0 then
		if pack.money and pack.money >= 0 then
			g.user:setMoney(pack.money)
		end
		g.myApp:enterScene("HallScene")
	end
end

function RummyCtrl:castUserSit(pack)
	if not pack then return end
	seatMgr:castUserSit(pack)
end

function RummyCtrl:castUserExit(pack)
	if not pack then return end
	seatMgr:castUserExit(pack)
end


function RummyCtrl:sendCliDrawCard(regionId)
	if g.mySocket:isConnected() then
		g.mySocket:send(g.mySocket:createPacketBuilder(CmdDef.CLI_RUMMY_DRAW_CARD)
		:setParameter("uid", tonumber(g.user:getUid()))
		:setParameter("region", regionId) -- 摸牌区域: 0, 新牌堆; 1, 旧牌堆
		:build())
  	end
end

function RummyCtrl:sendCliDiscardCard(cardIdx)
	local mCards = roomInfo:getMCards()
	if g.mySocket:isConnected() then
			g.mySocket:send(g.mySocket:createPacketBuilder(CmdDef.CLI_RUMMY_DISCARD_CARD)
			:setParameter("uid", tonumber(g.user:getUid()))
			:setParameter("card", mCards[cardIdx])
			:setParameter("index", cardIdx)
			:build())
	end
end
function RummyCtrl:sendCliFinish(cardIdx)
	local mCards = roomInfo:getMCards()
	roomInfo:setFinishCardIndex(cardIdx)
	if g.mySocket:isConnected() then
		g.mySocket:send(g.mySocket:createPacketBuilder(CmdDef.CLI_RUMMY_FINISH)
		:setParameter("uid", tonumber(g.user:getUid()))
		:setParameter("card", mCards[cardIdx])
		:build())
	end
end
function RummyCtrl:sendCliDrop()
	if g.mySocket:isConnected() then
		g.mySocket:send(g.mySocket:createPacketBuilder(CmdDef.CLI_RUMMY_DROP)
		:setParameter("uid", tonumber(g.user:getUid()))
		:build())
	end
end

function RummyCtrl:sendCliDeclare()
	local groups = roomInfo:getCurGroups()
	local mCards = roomInfo:getMCards()
    if g.mySocket:isConnected() then
        local pack = g.mySocket:createPacketBuilder(CmdDef.CLI_RUMMY_DECLARE)
        pack:setParameter("uid", tonumber(g.user:getUid()))
        local simuGroups = {}
        for i, group in pairs(groups) do
            simuGroups[i] = {}
            simuGroups[i].cards = {}
            for j = 1, #group do
                table.insert(simuGroups[i].cards, {card = mCards[group[j]]})
            end
        end
		pack:setParameter("groups", simuGroups)
		print("-- test begin, onDeclareClick cards begin")
		for i, group in pairs(simuGroups) do
			local str = ""
			for j = 1, #group.cards do
				str = str .. string.format("%x", group.cards[j].card) .. ", "
			end
			print(str)
		end
		print("-- test end, onDeclareClick cards end")
        g.mySocket:send(pack:build())
  	end
end

function RummyCtrl:vggSortCards()
    local isOk = RummyUtil.refreshGroupsBySort()
    if isOk then
        seatMgr:updateMCards(roomInfo:getCurGroups())
    end
end

function RummyCtrl:vggGroupCards()
    local isOk = RummyUtil.refreshGroupsByGroup(roomInfo:getMCardChooseList())
    if isOk then
        seatMgr:updateMCards(roomInfo:getCurGroups())        
    end
    seatMgr:cancelCardsSel()
    seatMgr:clearMCardChooseList()
end

function RummyCtrl:XXXX()
	
end

function RummyCtrl:XXXX()
	
end

function RummyCtrl:dispose()
	seatMgr:dispose()
	roomMgr:dispose()
	g.event:removeByTag(self)
end

return RummyCtrl

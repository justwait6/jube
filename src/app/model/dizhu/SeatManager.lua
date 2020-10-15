local SeatManager = class("SeatManager")

local CmdDef = require("app.core.protocol.CommandDef")
local RoomConst = require("app.model.dizhu.RoomConst")
local RoomUtil = require("app.model.dizhu.RoomUtil")
local SeatView = require("app.view.dizhu.SeatView")
local roomInfo = require("app.model.dizhu.RoomInfo").getInstance()

local mResDir = "image/dizhu/" -- module resource directory

local RVP = require("app.model.dizhu.RoomViewPosition")
local P1 = RVP.SeatPosition
local P2 = RVP.ReadyPosition
local P3 = RVP.WordPosition
local P4 = RVP.DizhuIconPosition

function SeatManager:ctor()
    self.playerInfo = {}
    self.seats_ = {}
    self.cardList_ = {}

	self:initialize()
end

function SeatManager:initialize()
end

function SeatManager:setRoomCtrl(roomCtrl)
	self.roomCtrl_ = roomCtrl
end

function SeatManager:initSeatNode(sceneSeatNode)
    self.sceneSeatNode_ = sceneSeatNode
    -- seats
	for i = 0, RoomConst.UserNum - 1 do
        self.seats_[i] = SeatView.new(i):pos(P1[i].x,P1[i].y):addTo(self.sceneSeatNode_):hide()
	end
end

function SeatManager:initAnimNode(sceneAnimNode)
    self.sceneAnimNode_ = sceneAnimNode
end

function SeatManager.getInstance()
    if not SeatManager.singleInstance then
        SeatManager.singleInstance = SeatManager.new()
    end
    return SeatManager.singleInstance
end

function SeatManager:initSeats(pack)
    self:initPlayerData(pack)
    self:initPlayerView(pack)
end

function SeatManager:initPlayerData(pack)
	if pack.players then
        for _, v in pairs(pack.players) do
            table.insert(self.playerInfo, v)
        end
	end
end

function SeatManager:initPlayerView(pack)
    local seatOffset = 0
    for _, v in ipairs(self.playerInfo) do
         if v.seatId >= 0 and v.seatId <= RoomConst.UserNum - 1 then
              self:initPlayerViewWithSeatId(v)
              local fromSeatId = v.seatId
              local toSeatId = RoomUtil.getFixSeatId(v.seatId) 
              seatOffset = toSeatId - fromSeatId
         end
    end
    if pack.isReconnect then --房间里重连
		self:startAllSeatMove(seatOffset, true)
	else
        self:startAllSeatMove(seatOffset)
    end
end

function SeatManager:initPlayerViewWithSeatId(user)
    local seatId = user.seatId or -1
    if seatId >= 0 then
		local seat = self.seats_[seatId]
		seat:show()
        seat:setUid(user.uid or -1)
        seat:setServerSeatId(seatId)
        seat:updateSeatConfig()
        self:updateMoney(seatId, user.carry or user.money or 0)
        self:updateUserinfo(seat, json.decode(user.userinfo))
        if user.state == RoomConst.UserState_Ready then
            self:showReadyText(user.uid)
        end
    end
end

local CARD_GAP = 40
local CARD_WIDTH = 114
local CARD_ARISE_Y = 40
function SeatManager:doDealCardsAnim(cards)
    g.myFunc:safeRemoveNode(self.mCardLayer)
    local layer = ccui.Layout:create()
    self.mCardLayer = layer
    layer:setContentSize(cc.size(300, 300))
    layer:setPosition(cc.p(display.cx, display.cy + 30))
    layer:setAnchorPoint(cc.p(0.5, 0.5))
    self.sceneAnimNode_:addChild(layer)

    local HAND_CARD_COUNT = #cards
    for i = 1, HAND_CARD_COUNT do
        self.cardList_[i] = g.myUi.PokerCard.new():setCard(cards[i]):addTo(layer)
        self.cardList_[i]:showBack()
        self:mCardEvent(self.cardList_[i])
    end
    local sCardAnim = function(card, delayTime, destPos, finishCb)
        card:stopAllActions()
        card:runAction(cc.Sequence:create({
            cc.DelayTime:create(delayTime),
            cc.MoveTo:create(0.5, destPos),
            cc.CallFunc:create(function()
                card:showFront()
                if finishCb and finishCb then finishCb() end
            end),
            }))
    end
    local cardAnim = function(initPos, gapTime, showInitBack, finishCb)
        for i = 1, HAND_CARD_COUNT do
            self.cardList_[i]:setCard(cards[i])
            local card = self.cardList_[i]
            if showInitBack then card:showBack() end
            card:setPosition(initPos.x, initPos.y)
            local destX = layer:getContentSize().width/2 + (i - 1) * CARD_GAP - (HAND_CARD_COUNT - 1) * CARD_GAP / 2
            sCardAnim(card, i * gapTime, cc.p(destX, 0), (i == HAND_CARD_COUNT) and finishCb)
        end
    end
    local cardAnim2 = function(finishCb)
        for i = 1, HAND_CARD_COUNT do
            sCardAnim(self.cardList_[i], 0.2, cc.p(layer:getContentSize().width/2, 0), (i == HAND_CARD_COUNT) and finishCb)
        end
    end
    cardAnim(cc.p(layer:getContentSize().width/2, layer:getContentSize().height/2), 0.04, true, function()
        table.sort(cards, function(a, b) return not RoomUtil.sortCard(a, b, true) end)
        cardAnim2(function()
            cardAnim(cc.p(layer:getContentSize().width/2, 0), 0, false)
        end)
    end)
end

function SeatManager:doGrabResult(uid)
    self:doShowDizhuIcon(uid)
    self:hideAllWordText()
end

function SeatManager:doShowDizhuIcon(uid)
    g.myFunc:safeRemoveNode(self.dizhuIcon_)
    self.dizhuIcon_ = display.newSprite(mResDir .. "lord_icon.png"):opacity(0)
        :pos(display.cx, display.cy)
        :addTo(self.sceneAnimNode_)
    local seatId = self:querySeatIdByUid(uid)
    local fixSeatId = RoomUtil.getFixSeatId(seatId)
    if seatId >= 0 then
        self.dizhuIcon_:stopAllActions()
        self.dizhuIcon_:runAction(cc.Sequence:create({
            cc.Spawn:create({
                cc.FadeIn:create(0.5),
                cc.MoveTo:create(0.5, P4[fixSeatId])
            })
        }))
    end
end

function SeatManager:insertCardsAnim(cards)
    if not self.cardList_ then return end
    table.sort(cards, function(a, b) return not RoomUtil.sortCard(a, b, true) end)
    local cardList = {}
    local newCards = {}
    for i = 1, #cards do
        newCards[i] = g.myUi.PokerCard.new():setCard(cards[i]):pos(0, CARD_ARISE_Y):addTo(self.mCardLayer)
        self:mCardEvent(newCards[i])
        newCards[i]:showFront()
    end
    local idx = 1
    for i = 1, #self.cardList_ do
        if idx <= #cards then
            while (idx <= #cards and RoomUtil.compareCard(cards[idx], self.cardList_[i]:getCard()) <= 0) do
                table.insert(cardList, newCards[idx])
                idx = idx + 1
            end
        end
        table.insert(cardList, self.cardList_[i])
    end
    for j = idx, #cards do -- 添加余下的牌(如果有的话)
        table.insert(cardList, newCards[j])
    end
    local midX = self.mCardLayer:getContentSize().width/2
    dump(cardList, "cardList")
    local cardCnt = #self.cardList_ + #cards
    for i = 1, cardCnt do
        cardList[i]:setPositionX(midX + (i - 1) * CARD_GAP - (cardCnt - 1) * CARD_GAP / 2)
        cardList[i]:setLocalZOrder(i)
    end
    for i = 1, #newCards do
        newCards[i]:stopAllActions()
        newCards[i]:runAction(cc.Sequence:create({
            cc.DelayTime:create(1),
            cc.MoveTo:create(0.5, cc.p(newCards[i]:getPositionX(), 0)),
        }))
    end
    self.cardList_ = cardList
end

function SeatManager:mCardEvent(node)
    node:getFrontSprite():addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        -- dump(event)
        if event.name == "began" then
            posX = node:getPositionX()
            posY = node:getPositionY()
            preX = event.startX
            preY = event.startY
            self:onTouchBegin(node, preX)
            return true
        elseif event.name == "moved" then
            if math.abs(event.y - preY) < 150 then
                self:onTouchMove(node, self.nodeStartX + event.x - preX)
            end
        elseif event.name == "ended" then
            if math.abs(event.x - preX) <= 10 and math.abs(event.y - preY) <= 10 then -- 点击事件
                self:onMCardClick(node, posX)
            end
            self:onTouchEnd(node)
        elseif event.name == "cancelled" then
            self:onTouchEnd(node)
        end
    end)
    node:getFrontSprite():setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    node:getFrontSprite():setTouchEnabled(true)
    node:getFrontSprite():setTouchSwallowEnabled(true)
end

function SeatManager:onTouchBegin(node, startX)
    local nsp = self.mCardLayer:convertToWorldSpace(cc.p(0, 0))
    self.nodeStartX = math.floor(startX - nsp.x)
    self.selBeginIdx = 999
    self.selEndIdx = -1
end

function SeatManager:onTouchMove(node, curX)
    local leftX = math.min(self.nodeStartX, curX)
    local rightX = math.max(self.nodeStartX, curX)
    for i, node in pairs(self.cardList_) do
        local showLeft = node:getPositionX() - CARD_WIDTH / 2
        local showRight = showLeft + CARD_GAP
        if (i == #self.cardList_) then
            showRight = showLeft + CARD_WIDTH
        end
        if (leftX < showLeft and showLeft < rightX) or (leftX < showRight and showRight < rightX) then
            self.selBeginIdx = math.min(self.selBeginIdx, i)
            self.selEndIdx = math.max(self.selEndIdx, i)
            node:showDark()
        else
            node:hideDark()
        end
    end
end

function SeatManager:onMCardClick(node)
    if node:getPositionY() == 0 then
        node:setPositionY(CARD_ARISE_Y)
    else
        node:setPositionY(0)
    end
end

function SeatManager:onTouchEnd(node, cardlist)
    for _, node in pairs(self.cardList_) do
        node:hideDark()
    end
    print(self.selBeginIdx, self.selEndIdx)
    self.selCards_ = {}
    for i = self.selBeginIdx, self.selEndIdx do
        self:onMCardClick(self.cardList_[i])
    end
    for _, node in pairs(self.cardList_) do
        if node:getPositionY() == CARD_ARISE_Y then
            table.insert(self.selCards_, node:getCard())
        end
    end
end

function SeatManager:doReady(uid)
    self:showReadyText(uid)
end

function SeatManager:doCastReady(uid)
    self:showReadyText(uid)
end

function SeatManager:showReadyText(uid)
    local seatId = self:querySeatIdByUid(uid)
    local fixSeatId = RoomUtil.getFixSeatId(seatId)
    if seatId >= 0 then
        self.seats_[seatId]:showReadyText(P2[fixSeatId])
    end
end

function SeatManager:hideAllReadyText()
    for _, seat in pairs(self.seats_) do
        seat:hideReadyText()
    end
end

function SeatManager:doGrab(isGrab, odds)
    self:doUserGrab(g.user:getUid(), isGrab, odds)
end

function SeatManager:doCastGrab(uid, isGrab, odds)
    self:doUserGrab(uid, isGrab, odds)
end

function SeatManager:doUserGrab(uid, isGrab, odds)
    self:stopCountDown(uid)
    local wordRes = nil
    if isGrab == 1 and odds <= 1 then
        wordRes = mResDir .. "player_call_landlord.png"
        print("todo, jiao di zhu...")
    elseif isGrab == 1 and odds > 1 then
        wordRes = mResDir .. "player_grab_landlord.png"
        print("todo, qiang di zhu...")
    elseif isGrab == 0 and odds < 1 then
        wordRes = mResDir .. "player_pass_1.png"
        print("todo, no call 1...")
    elseif isGrab == 0 and odds >= 1 then
        wordRes = mResDir .. "player_pass_2.png"
        print("todo, no call 2...")
    end
    self:showWordText(uid, wordRes)
end

function SeatManager:showWordText(uid, wordRes)
    local seatId = self:querySeatIdByUid(uid)
    local fixSeatId = RoomUtil.getFixSeatId(seatId)
    if seatId >= 0 then
        self.seats_[seatId]:showWordText(P3[fixSeatId], wordRes)
    end
end

function SeatManager:hideWordText(uid)
    local seatId = self:querySeatIdByUid(uid)
    local fixSeatId = RoomUtil.getFixSeatId(seatId)
    if seatId >= 0 then
        self.seats_[seatId]:hideWordText()
    end
end

function SeatManager:hideAllWordText()
    for _, seat in pairs(self.seats_) do
        seat:hideWordText()
    end
end

function SeatManager:startCountDown(time,uid,finishCallback)
    local seatId = self:querySeatIdByUid(uid)
    if seatId and seatId >=0 then
        local seat = self.seats_[seatId]
        seat:startCountDown(time,function()
            if seat and seatId == roomInfo:getMSeatId() then
                 seat:stopShakeCard()
            end
            if finishCallback then
                 finishCallback()
            end
        end)
    end
end

function SeatManager:stopCountDown(uid)
    local seatId = self:querySeatIdByUid(uid)
    if seatId and seatId >=0 then
        local seat = self.seats_[seatId]
        if seat then
            seat:stopCountDown()
        end
    end
end

function SeatManager:updateMoney(seatId, money)
    if seatId and seatId >= 0 and money and money >=0 then
        local seat = self.seats_[seatId]
        seat:updateMoney(money)
    end
end

function SeatManager:updateUserinfo(seat, userinfo)
    if userinfo then
        seat:showHeader()
        local uid = seat:getUid()
        seat:setHeaderConfig(userinfo.icon, userinfo.gender)
        seat:setNickName(userinfo.nickName)
    end
end

function SeatManager:startAllSeatMove(seatOffset, isInstant)
	for i = 0, RoomConst.UserNum - 1 do
		local seat = self.seats_[i]
        local fromSeatId = seat:getServerSeatId()
        if fromSeatId ~= RoomConst.NoPlayerSeatId then
			seat:show()
			local toSeatId = fromSeatId + seatOffset
			if toSeatId < 0 then
				toSeatId = toSeatId + RoomConst.UserNum
			elseif toSeatId > RoomConst.UserNum - 1 then
				toSeatId = toSeatId - RoomConst.UserNum
			end
			self:startSeatMove(seat, fromSeatId, toSeatId)
		else
			seat:hide()
		end                  
	end
end

function SeatManager:startSeatMove(seat, fromSeatId, toSeatId)
    if isInstant then
        self:setToIndexSeat(seat, toSeatId)
    else
        self:startMoveSeatAnimation(seat, fromSeatId, toSeatId)
    end
end

function SeatManager:setToIndexSeat(seat,toSeatId)
    seat:pos(P1[toSeatId].x, P1[toSeatId].y)
    seat:setNowPos(toSeatId)
end

function SeatManager:startMoveToNotFix()
    for i = 0, RoomConst.UserNum-1 do
        local seat = self.seats_[i]
        seat:updateSeatConfig()
        self:startMoveSeatAnimation(seat, seat:getNowPos(), i)
    end
end

function SeatManager:startMoveSeatAnimation(seat, fromSeatId, toSeatId)
    local moveActions = {}
    seat:pos(P1[toSeatId].x, P1[toSeatId].y)
    local sequence = cc.Sequence:create(cc.CallFunc:create(function()
        seat:setNowPos(toSeatId)
        end))
    seat:stopAllActions()
    seat:runAction(sequence)
end
function SeatManager:castUserSit(pack)
    if pack.seatId >= 0 and pack.seatId <= RoomConst.UserNum - 1 then
        local user = self:insertUser(pack)
        self:initPlayerViewWithSeatId(user)  
        local seat = self:getSeatByUid(user.uid)
        local toSeatId = RoomUtil.getFixSeatId(pack.seatId or -1)
        seat:show()
        self:startSeatMove(seat, user.seatId, toSeatId)
    end
end

function SeatManager:castUserExit(pack)
    self:standUp(pack.uid)
end

function SeatManager:standUp(uid)
    self:deleteUser(uid)
	for i = 0, #self.seats_ do
		if tonumber(uid) == tonumber(self.seats_[i]:getUid()) then
			self.seats_[i]:standUp()
		end
	end
	if tonumber(uid) == g.user:getUid() then
		roomInfo:setMSeatId(-1)
		roomInfo:clearMCards()
		self:startMoveToNotFix()
	end
end

function SeatManager:getSeatByUid(uid)
	for i = 0, RoomConst.UserNum - 1 do
		local seat = self.seats_[i]
		if seat:getUid() == uid then
			return seat
		end
	end
end

function SeatManager:getSeatByServerSeatId(serverSeatId)
	for i = 0, RoomConst.UserNum - 1 do
		local seat = self.seats_[i]
		if seat:getServerSeatId() == serverSeatId then
			return seat
		end
	end
end

function SeatManager:querySeatIdByUid(uid)
    local player = self:queryUser(uid)
    if player then
        return player.seatId
    end
    return -1
end

function SeatManager:queryUser(uid)
    if not uid then return end
    if self.playerInfo and #self.playerInfo > 0 then
        for i = 1, #self.playerInfo do
            local player = self.playerInfo[i]
            if player then
                if player.uid and tonumber(player.uid) == tonumber(uid) then
                    return player
                end
            end
        end
    end
end

function SeatManager:insertUser(pack)
    local user = {}
    user.uid = pack.uid or -1
    user.seatId = pack.seatId or -1
    user.userinfo = pack.userinfo or ""
    user.state = pack.state or RoomConst.USER_USER_SEAT
    user.money = pack.money or 0
    user.gold = pack.gold or 0
    table.insert(self.playerInfo, user)
    return user
end

function SeatManager:deleteUser(id)
    if not id then return end
    if self.playerInfo and #self.playerInfo > 0 then
        for i = 1, #self.playerInfo do
            local player = self.playerInfo[i]
            if player then
                if player.uid and tonumber(player.uid) == tonumber(id) then
                    table.remove(self.playerInfo, i)
                    return
                end
            end
        end
    end
end

function SeatManager:queryUserinfo(uid)
	local player = self:queryUser(uid)
	if player and player.userinfo then
		return json.decode(player.userinfo)
	end
	return {}
end

function SeatManager:queryUsernameByUid(uid)
    local userinfo = self:queryUserinfo(uid) or {}
    return userinfo.nickName
end

function SeatManager:clearAll()
    self.playerInfo = {}
    self.seats_ = {}
end

function SeatManager:clearMCardsArea()
    g.myFunc:safeRemoveNode(self.mCardLayer)
end

function SeatManager:clearTable()
    for i = 0, RoomConst.UserNum - 1 do
        self.seats_[i]:clearTable()
    end
    self:clearMCardsArea()
    self:hideAllReadyText()
    self:hideAllWordText()
end

function SeatManager:XXXX()
    
end

function SeatManager:dispose()
    self:clearAll()
end

return SeatManager

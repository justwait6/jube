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
local P5 = RVP.OutCardPosition

function SeatManager:ctor()
    self.playerInfo = {}
    self.seats_ = {}
    self.cardList_ = {}
    self.otherOutCardNodes = {}

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

    local layer = ccui.Layout:create()
    self.mCardLayer = layer
    layer:setContentSize(cc.size(300, 300))
    layer:setPosition(cc.p(display.cx, display.cy + 20))
    layer:setAnchorPoint(cc.p(0.5, 0.5))
    self.sceneAnimNode_:addChild(layer)
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

function SeatManager:getMCardsY()
    return self.mCardLayer:getPositionY() - self.mCardLayer:getContentSize().width / 2
end

function SeatManager:doDealCardsAnim(cards)
    local layer = self.mCardLayer
    local HAND_CARD_COUNT = #cards
    for i = 1, HAND_CARD_COUNT do
        self.cardList_[i] = g.myUi.PokerCard.new():setCard(cards[HAND_CARD_COUNT + 1 - i]):addTo(layer)
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
            self.cardList_[i]:setCard(cards[HAND_CARD_COUNT + 1 - i])
            local card = self.cardList_[i]
            if showInitBack then card:showBack() end
            card:setPosition(initPos.x, initPos.y)
            local destX = layer:getContentSize().width/2 + (i - 1) * RoomConst.CARD_GAP - (HAND_CARD_COUNT - 1) * RoomConst.CARD_GAP / 2
            sCardAnim(card, i * gapTime, cc.p(destX, 0), (i == HAND_CARD_COUNT) and finishCb)
        end
    end
    local cardAnim2 = function(finishCb)
        for i = 1, HAND_CARD_COUNT do
            sCardAnim(self.cardList_[i], 0.2, cc.p(layer:getContentSize().width/2, 0), (i == HAND_CARD_COUNT) and finishCb)
        end
    end
    cardAnim(cc.p(layer:getContentSize().width/2, layer:getContentSize().height/2), 0.04, true, function()
        table.sort(cards, function(a, b) return RoomUtil.sortCard(a, b) end)
        cardAnim2(function()
            cardAnim(cc.p(layer:getContentSize().width/2, 0), 0, false)
        end)
    end)
end

function SeatManager:doGrabResult(uid)
    self:doShowDizhuIcon(uid)
    self:hideAllWordText()
end

function SeatManager:doShowDizhuIcon(uid, noAnim)
    g.myFunc:safeRemoveNode(self.dizhuIcon_)
    self.dizhuIcon_ = display.newSprite(mResDir .. "lord_icon.png"):opacity(0)
        :pos(display.cx, display.cy)
        :addTo(self.sceneAnimNode_)
    local seatId = self:querySeatIdByUid(uid)
    local fixSeatId = RoomUtil.getFixSeatId(seatId)
    if seatId >= 0 then
        if noAnim then
            self.dizhuIcon_:opacity(255):pos(P4[fixSeatId].x, P4[fixSeatId].y)
        else
            self.dizhuIcon_:stopAllActions()
            self.dizhuIcon_:runAction(cc.Sequence:create({
                cc.Spawn:create({
                    cc.FadeIn:create(0.5),
                    cc.MoveTo:create(0.5, P4[fixSeatId])
                })
            }))
        end
    end
end

function SeatManager:doWhenSelfTurn()
    self:clearOutCardArea(g.user:getUid())
end

function SeatManager:insertCardsAnim(cards)
    if not self.cardList_ then return end
    table.sort(cards, function(a, b) return RoomUtil.sortCard(a, b) end)
    local cardList = {}
    local newCards = {}
    for i = 1, #cards do
        newCards[i] = g.myUi.PokerCard.new():setCard(cards[i]):pos(0, RoomConst.CARD_ARISE_Y):addTo(self.mCardLayer)
        self:mCardEvent(newCards[i])
        newCards[i]:showFront()
    end

    local cardCnt = #self.cardList_ + #cards
    local idx1 = #cards
    local idx2 = 1
    for i = 1, cardCnt do
        if idx1 >= 1 and idx2 <= #self.cardList_ then
            if not RoomUtil.sortCard(cards[idx1], self.cardList_[idx2]:getCard()) then
                table.insert(cardList, newCards[idx1])
                idx1 = idx1 - 1
            else
                table.insert(cardList, self.cardList_[idx2])
                idx2 = idx2 + 1
            end
        elseif idx1 >= 1 then
            table.insert(cardList, newCards[idx1])
            idx1 = idx1 - 1
        elseif idx2 <= #self.cardList_ then
            table.insert(cardList, self.cardList_[idx2])
                idx2 = idx2 + 1
        end
    end
    local midX = self.mCardLayer:getContentSize().width/2
    dump(cardList, "cardList")
    
    for i = 1, cardCnt do
        cardList[i]:setPositionX(midX + (i - 1) * RoomConst.CARD_GAP - (cardCnt - 1) * RoomConst.CARD_GAP / 2)
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

function SeatManager:selfOutCardsAnim(cardType, cards, noAnim)
    local formatedCards = RoomUtil.formatCards(cardType, cards)
    g.myFunc:safeRemoveNode(self.outCardNode)
    self.outCardNode = display.newNode():pos(P5[RoomConst.MSeatId].x, P5[RoomConst.MSeatId].y):addTo(self.sceneAnimNode_)
    for i = 1, #formatedCards do
        local cardSprite = g.myUi.PokerCard.new():setCard(formatedCards[i]):addTo(self.outCardNode):scale(0.67):opacity(0)
        cardSprite:pos((i - 1) * RoomConst.S_CARD_GAP - (#formatedCards - 1) * RoomConst.S_CARD_GAP/2, 4)
        cardSprite:showFront()
        if noAnim then
            cardSprite:setPositionY(0)
        else
            cardSprite:stopAllActions()
            cardSprite:runAction(cc.Sequence:create(cc.Spawn:create({
                cc.FadeIn:create(0.2),
                cc.MoveBy:create(0.2, cc.p(0, -4))
            })))
        end
    end

    self:updateMCards()
end

function SeatManager:otherOutCardsAnim(uid, cardType, cards, noAnim)
    local seatId = self:querySeatIdByUid(uid)
    if seatId < 0 then return end
    local fixSeatId = RoomUtil.getFixSeatId(seatId)
    local formatedCards = RoomUtil.formatCards(cardType, cards)
    g.myFunc:safeRemoveNode(self.otherOutCardNodes[fixSeatId])
    self.otherOutCardNodes[fixSeatId] = display.newNode():pos(P5[fixSeatId].x, P5[fixSeatId].y):addTo(self.sceneAnimNode_)
    for i = 1, #formatedCards do
        local cardSprite = g.myUi.PokerCard.new():setCard(formatedCards[i]):addTo(self.otherOutCardNodes[fixSeatId]):scale(0.67):opacity(0)
        cardSprite:pos((i - 1) * RoomConst.S_CARD_GAP - (#formatedCards - 1) * RoomConst.S_CARD_GAP/2, 2)
        cardSprite:showFront()
        if noAnim then
            cardSprite:setPositionY(0)
        else
            cardSprite:stopAllActions()
            cardSprite:runAction(cc.Sequence:create(cc.Spawn:create({
                cc.FadeIn:create(0.2),
                cc.MoveBy:create(0.2, cc.p(0, -2))
            })))
        end
    end
end


function SeatManager:showOutCards(uid, cards)
    local cardType = RoomUtil.getCardType(cards)
    if uid == g.user:getUid() then
        self:selfOutCardsAnim(cardType, cards, true)
    else
        self:otherOutCardsAnim(uid, cardType, cards, true)
    end
end

function SeatManager:updateMCards()
    local cards = roomInfo:getMCards()
    self:clearMCards()

    local midX = self.mCardLayer:getContentSize().width/2
    for i = 1, #cards do
        self.cardList_[i] = g.myUi.PokerCard.new():setCard(cards[#cards + 1 - i]):addTo(self.mCardLayer)
        self.cardList_[i]:setPositionX(midX + (i - 1) * RoomConst.CARD_GAP - (#cards - 1) * RoomConst.CARD_GAP / 2)
        self.cardList_[i]:showFront()
        self:mCardEvent(self.cardList_[i])
    end
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
        local showLeft = node:getPositionX() - RoomConst.CARD_WIDTH / 2
        local showRight = showLeft + RoomConst.CARD_GAP
        if (i == #self.cardList_) then
            showRight = showLeft + RoomConst.CARD_WIDTH
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
        node:setPositionY(RoomConst.CARD_ARISE_Y)
    else
        node:setPositionY(0)
    end
end

function SeatManager:onTouchEnd(node)
    for _, node in pairs(self.cardList_) do
        node:hideDark()
    end
    print(self.selBeginIdx, self.selEndIdx)
    local cards = {}
    for i = self.selBeginIdx, self.selEndIdx do
        self:onMCardClick(self.cardList_[i])
    end
    for i = #self.cardList_, 1 , -1 do -- Choosen Card Order must be ascending order
        if self.cardList_[i]:getPositionY() == RoomConst.CARD_ARISE_Y then
            table.insert(cards, self.cardList_[i]:getCard())
        end
    end
    roomInfo:setSelCards(cards)
end

function SeatManager:cancelAllCardsSel()
    roomInfo:setSelCards({})
    for _, node in pairs(self.cardList_) do
        node:hideDark()
        node:setPositionY(0)
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
        wordRes = mResDir .. "player_grab_landlord.png"
        print("todo, jiao di zhu...")
    elseif isGrab == 1 and odds > 1 then
        wordRes = mResDir .. "player_grab_call_landlord.png"
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

function SeatManager:doUserNoOut(uid)
    self:clearOutCardArea(uid)
    self:showWordText(uid, mResDir .. "player_pass.png")
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

function SeatManager:outCardsInvalid()
    self:cancelAllCardsSel()
    self:showMCardsTip(mResDir .. "tips_outerror.png")
end

function SeatManager:selfCannotOut()
    self:cancelAllCardsSel()
    self:showMCardsTip(mResDir .. "tips_onlypass.png")
end

function SeatManager:showMCardsTip(tipRes)
    g.myFunc:safeRemoveNode(self.mCardsTipNode)
    self.mCardsTipNode = display.newNode():pos(display.cx, self:getMCardsY()):addTo(self.sceneAnimNode_)
    local cardsW = RoomConst.CARD_WIDTH + (#self.cardList_ - 1) * RoomConst.CARD_GAP
    display.newScale9Sprite(mResDir .. "pass_mask.png", 0, 2, cc.size(cardsW, RoomConst.CARD_HEIGHT + 2)):addTo(self.mCardsTipNode)
    display.newSprite(tipRes):addTo(self.mCardsTipNode)
end

function SeatManager:hideMCardsTip()
    g.myFunc:safeRemoveNode(self.mCardsTipNode)
end

function SeatManager:startCountDown(time,uid,finishCallback)
    local seatId = self:querySeatIdByUid(uid)
    if time <= 0 then return end
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

function SeatManager:reconnectWhenGrab(users)
    for _, user in pairs(users) do
        local wordRes = nil
        if user.grabState == RoomConst.PLAYER_GRAB_NO_GRAB then
            wordRes = mResDir .. "player_pass_1.png"
        elseif user.grabState == RoomConst.PLAYER_GRAB_NO_CALL then
            wordRes = mResDir .. "player_pass_2.png"
        elseif user.grabState == RoomConst.PLAYER_GRAB_GRAB then
            wordRes = mResDir .. "player_grab_landlord.png"
        elseif user.grabState == RoomConst.PLAYER_GRAB_CALL_GRAB then
            wordRes = mResDir .. "player_grab_call_landlord.png"
        end
        if user.grabState == RoomConst.PLAYER_GRAB_NONE then
            self:hideWordText(user.uid)
        else
            self:showWordText(user.uid, wordRes)
        end
    end
end

function SeatManager:reconnectWhenPlay(users)
    for _, user in pairs(users) do
        local wordRes = nil
        if user.outCardState == RoomConst.PLAYER_GRAB_NONE then
            self:hideWordText(user.uid)
        elseif user.outCardState == RoomConst.OUT_CARD_STATE_NO_OUT then
            self:showWordText(user.uid, mResDir .. "player_pass.png")
        elseif user.outCardState == RoomConst.OUT_CARD_STATE_OUT then
            self:showOutCards(user.uid, user.outCards)
        end
    end
end

function SeatManager:clearAll()
    self.playerInfo = {}
    self.seats_ = {}
end

function SeatManager:clearMCardsArea()
    if self.mCardLayer then
        self.mCardLayer:removeAllChildren()
    end
end

function SeatManager:clearTable()
    for i = 0, RoomConst.UserNum - 1 do
        self.seats_[i]:clearTable()
    end
    self:clearMCardsArea()
    self:hideAllReadyText()
    self:hideAllWordText()
end

function SeatManager:clearMCards()
    for i = 1, #self.cardList_ do
        g.myFunc:safeRemoveNode(self.cardList_[i])
        self.cardList_[i] = nil
    end
    self.cardList_ = {}
end

function SeatManager:clearOutCardArea(uid)
    self:hideWordText(uid)
    if uid == g.user:getUid() then
        g.myFunc:safeRemoveNode(self.outCardNode)
    else
        local seatId = self:querySeatIdByUid(uid)
        if seatId >= 0 then
            local fixSeatId = RoomUtil.getFixSeatId(seatId)
            g.myFunc:safeRemoveNode(self.otherOutCardNodes[fixSeatId])
        end
    end
end

function SeatManager:XXXX()
    
end

function SeatManager:XXXX()
    
end

function SeatManager:dispose()
    self:clearAll()
end

return SeatManager

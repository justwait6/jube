local SeatManager = class("SeatManager")

local CmdDef = require("app.core.protocol.CommandDef")
local RoomConst = require("app.model.rummy.RoomConst")
local RoomUtil = require("app.model.rummy.RoomUtil")
local SeatView = require("app.view.rummy.SeatView")
local roomInfo = require("app.model.rummy.RoomInfo").getInstance()

local mResDir = "image/rummy/" -- module resource directory

local RVP = require("app.model.rummy.RoomViewPosition")
local P1 = RVP.SeatPosition
local P2 = RVP.DeliverCardPosition
local P3 = RVP.LightAngle
local P4 = RVP.Lightscale
local P5 = RVP.PotPosition
local P6 = RVP.MoveCoinBegin
local TAG_DISCARD_CARD = 1
local TAG_MAGIC_CARD = 2
local TAG_FINISH_CARD = 3
local TAG_OLD_AREA = 4
local TAG_NEW_AREA = 5
local TAG_FINISH_AREA = 6

function SeatManager:ctor()
    self.playerInfo = {}
    self.seats_ = {}

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
        -- seat:setUState(user.state or RoomConst.USER_SEAT)
        self:updateMoney(seatId, user.carry or user.money or 0)
		self:updateUserinfo(seat, json.decode(user.userinfo))
    end
end

function SeatManager:gameStart(pack, animFinishCb)
    self:changeUserState(RoomConst.USER_PLAY) --游戏开始所有坐下玩家置为在玩状态
    self:chooseDealerAnim(pack, animFinishCb)
end

function SeatManager:chooseDealerAnim(pack, finishCallback)
    g.myFunc:safeRemoveNode(self.chooseDealerNode)
    local dNode = display.newNode():addTo(self.sceneAnimNode_)
    self.chooseDealerNode = dNode
    
    local refinedPlayers = self:getChooseDealerFixedPlayers(pack.players, pack.dUid)
    dump(refinedPlayers, "refinedPlayers")

    local dealCardTime = 1
    local fixCardNum = 5
    local idleSpritesNode = display.newNode():pos(display.cx, display.cy):scale(0):addTo(dNode, -1)
    for i = 1, fixCardNum do
        g.myUi.PokerCard.new():pos((i - 1 - fixCardNum) * 2, 0)
            :addTo(idleSpritesNode, -1):setRotation(-180):showBack()
    end
    idleSpritesNode:stopAllActions()
    idleSpritesNode:runAction(cc.Sequence:create({
        cc.ScaleTo:create(0.2, 1 * RoomConst.toSFactor)
    }))

    for i = 1, #refinedPlayers do
        local fixSeatId = refinedPlayers[i].fixSeatId
        if fixSeatId >= 0 then
            local cardSprite = g.myUi.PokerCard.new():setCard(refinedPlayers[i].card)
                :pos(display.cx + (#refinedPlayers - i) * 2, display.cy):addTo(dNode, #refinedPlayers - i)
            cardSprite:setRotation(-180)
            cardSprite:setScale(0)
            cardSprite:showBack()
            cardSprite:stopAllActions()
            cardSprite:runAction(cc.Sequence:create({
                cc.ScaleTo:create(0.2, 1 * RoomConst.toSFactor),
                cc.DelayTime:create(i * 0.2),
                cc.Spawn:create({cc.MoveTo:create(0.18, P2[fixSeatId]), cc.RotateTo:create(0.18, 0)}),
                cc.DelayTime:create(dealCardTime - i * 0.2),
                cc.CallFunc:create(function()
                    cardSprite:flip()
                    idleSpritesNode:runAction(cc.Sequence:create({
                        cc.ScaleTo:create(0.2, 0.2),
                        cc.CallFunc:create(function()
                            g.myFunc:safeRemoveNode(idleSpritesNode)
                            idleSpritesNode = nil
                        end),
                    }))
                end),
                cc.DelayTime:create(0.8),
                cc.CallFunc:create(function()
                    if refinedPlayers[i].isScaleCardAnim then
                        cardSprite:runAction(cc.Sequence:create({
                            cc.ScaleTo:create(0.2, 1.2 * RoomConst.toSFactor), cc.ScaleTo:create(0.2, 1.1 * RoomConst.toSFactor), cc.ScaleTo:create(0.2, 1.2 * RoomConst.toSFactor), cc.ScaleTo:create(0.2, 1.1 * RoomConst.toSFactor),
                        }))
                    end
                end),
                cc.DelayTime:create(0.8),
                cc.CallFunc:create(function()
                    if i == #refinedPlayers then
                        if finishCallback then finishCallback() end
                    end
                end),
                cc.DelayTime:create(1.2),
                cc.CallFunc:create(function()
                    g.myFunc:safeRemoveNode(cardSprite)
                    cardSprite = nil
                end),
            }))
        end	
    end
end

function SeatManager:getChooseDealerFixedPlayers(users, dealerUid)	
    local refinedPlayers = clone(users or {})
    local isSelfInPlay = false
    for i = 1, #refinedPlayers do
        local seatId = self:querySeatIdByUid(refinedPlayers[i].uid or -1)
        refinedPlayers[i].fixSeatId = RoomUtil.getFixSeatId(seatId)

        if tonumber(refinedPlayers[i].uid) == tonumber(g.user:getUid()) then
            isSelfInPlay = true
        end
        if tonumber(refinedPlayers[i].uid) == tonumber(dealerUid) then
            if i == 1 then
                refinedPlayers[#refinedPlayers].isScaleCardAnim = true
            else
                refinedPlayers[i - 1].isScaleCardAnim = true
            end
        end
    end
    if isSelfInPlay then -- 自己在玩, 保证自己最后一个
        while (true) do
            local user = table.remove(refinedPlayers, 1)
            table.insert(refinedPlayers, user)
            if tonumber(user.uid) == tonumber(g.user:getUid()) then
                break
            end
        end
    end
    return refinedPlayers
end

function SeatManager:startDealCards(pack, needAnim, animFinishCb)
    -- 设置一开始的组, 即一个组, 里边有全部牌
    local groups = {}
    if pack.cards and #pack.cards > 0 then -- 玩家自己有牌才建立组
        groups[1] = {}
        for i = 1, #pack.cards do
            table.insert(groups[1], i)
        end
    end
    roomInfo:setCurGroups(groups)

    g.myFunc:safeRemoveNode(self.chooseDealerNode)

    self:initInfoCardsNode(pack.dropCard, needAnim)
    self:dealCardsAnim(needAnim, handler(self, function()
        self:showMagicCard(needAnim)
        if animFinishCb then animFinishCb() end
    end))
end

function SeatManager:showMagicCard(needAnim)
    local magicCard = roomInfo:getMagicCard()
    local newHeapPos = RVP.NewHeapPos
    g.myFunc:safeRemoveNode(self.newHeapNode:getChildByTag(TAG_MAGIC_CARD))
    local mCard = g.myUi.PokerCard.new():setCard(magicCard):setTag(TAG_MAGIC_CARD):setRotation(-90):opacity(0)
        :pos(-24, -10):addTo(self.newHeapNode, -2)
        mCard:showFront()
        mCard:setMagicVisible(true)
        mCard:setMagicPos(cc.p(30, 46))
        mCard:stopAllActions()
        mCard:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.21),
        cc.Spawn:create({
            cc.MoveTo:create(0.3, cc.p(-46, -10)),
            cc.FadeIn:create(0.3),
    })))
end

function SeatManager:initInfoCardsNode(dropCard, needAnim)
    g.myFunc:safeRemoveNode(self.infoCardsNode)
	local iNode = display.newNode():addTo(self.sceneAnimNode_)
    self.infoCardsNode = iNode

    -- 弃牌堆按钮
    g.myUi.ScaleButton.new({normal = mResDir .. "dropcards_icon.png"})
        :onClick(handler(self, function(sender)
            if g.mySocket:isConnected() then
                g.mySocket:send(g.mySocket:createPacketBuilder(CmdDef.CLI_RUMMY_GET_DROP_CARDS)
                    :setParameter("uid", tonumber(g.user:getUid())):build())
            end
        end))
        :addTo(iNode)
        :pos(display.cx + 246, display.cy + 116)
        :setSwallowTouches(false)

    -- 弃牌堆第一张牌
    local oldHeapPos = RVP.OldHeapPos
    display.newSprite(mResDir .. "slot_bg.png"):pos(oldHeapPos.x, oldHeapPos.y):addTo(iNode)
    display.newTTFLabel({text = g.lang:getText("RUMMY", "OPEN_DECK"), size = 18})
        :pos(oldHeapPos.x, oldHeapPos.y):addTo(iNode)
    local dCard = g.myUi.PokerCard.new():setTag(TAG_DISCARD_CARD):scale(RoomConst.toSFactor)
        :pos(oldHeapPos.x, oldHeapPos.y):addTo(iNode):showFront()
    self:updateSlotCard(TAG_DISCARD_CARD, dropCard)
    -- 旧牌堆提示光
    display.newSprite(mResDir .. "area_light.png"):setTag(TAG_OLD_AREA)
        :pos(oldHeapPos.x, oldHeapPos.y):addTo(iNode):hide()
    

    -- Finish Slot
    local slotPos = RVP.FinishSlotPos
    display.newSprite(mResDir .. "slot_bg.png"):pos(slotPos.x, slotPos.y):addTo(iNode)
    display.newTTFLabel({text = g.lang:getText("RUMMY", "FINISH_SLOT"), size = 18})
        :pos(slotPos.x, slotPos.y):addTo(iNode)
    g.myUi.PokerCard.new():setTag(TAG_FINISH_CARD):scale(RoomConst.toSFactor)
        :pos(slotPos.x, slotPos.y):addTo(iNode):hide()
    -- Finish牌堆提示光
    display.newSprite(mResDir .. "area_light.png"):setTag(TAG_FINISH_AREA)
        :pos(slotPos.x, slotPos.y):addTo(iNode):hide()

    -- 初始牌堆
    local newHeapPos = RVP.NewHeapPos
    local fixCardNum = 5
    display.newSprite(mResDir .. "slot_bg.png"):pos(newHeapPos.x, newHeapPos.y):addTo(iNode)
    display.newTTFLabel({text = g.lang:getText("RUMMY", "CLOSED_DECK"), size = 18})
        :pos(newHeapPos.x, newHeapPos.y):addTo(iNode)
    self.newHeapNode = display.newNode():pos(newHeapPos.x, newHeapPos.y):scale(0):addTo(iNode)
    -- 新牌堆提示光
    display.newSprite(mResDir .. "area_light.png"):setTag(TAG_NEW_AREA)
        :pos(newHeapPos.x, newHeapPos.y):addTo(iNode):hide()
    for i = 1, fixCardNum do
        g.myUi.PokerCard.new():pos((i - 1 - fixCardNum) * 0, 0):opacity(0)
            :addTo(self.newHeapNode, -1):showBack()
    end
    self.newHeapNode:stopAllActions()
    self.newHeapNode:runAction(cc.Sequence:create({
        cc.ScaleTo:create(0.2, RoomConst.toSFactor),
        cc.FadeIn:create(0.2),
    }))
end

function SeatManager:showFinishSlotCard()
    if not g.myFunc:checkNodeExist(self.infoCardsNode) then return end
    local card = self.infoCardsNode:getChildByTag(TAG_FINISH_CARD)
    card:showFront()
end

function SeatManager:updateFinishSlotCard(cardUint)
    self:updateSlotCard(TAG_FINISH_CARD, cardUint)
end

function SeatManager:updateSlotCard(slotTag, cardUint, isShowCardBack)
    if not g.myFunc:checkNodeExist(self.infoCardsNode) then return end
    local card = self.infoCardsNode:getChildByTag(slotTag)
    if  tonumber(cardUint) > 0 then
        card:setCard(cardUint)
        card:setMagicVisible(RoomUtil.isMagicCard(cardUint))
        card:show()
        card:showFront()
        if isShowCardBack then
            card:showBack()
        end
    else
        card:hide()
    end
end

function SeatManager:showAreaLightsDrawStage()
    self:hideAllAreaLights()
    self:showAreaLights({TAG_NEW_AREA, TAG_OLD_AREA})
end

function SeatManager:showAreaLightsDiscardStage()
    self:hideAllAreaLights()
    self:showAreaLights({TAG_OLD_AREA, TAG_FINISH_AREA})
end

function SeatManager:showAreaLights(tags)
    for _, tag in pairs(tags) do
        local child = self.infoCardsNode:getChildByTag(tag)
        child:stopAllActions()
        child:show()
        child:runAction(cc.RepeatForever:create(
            cc.Sequence:create(
            cc.DelayTime:create(0.7),
            cc.EaseBackOut:create(cc.ScaleTo:create(0.7, 1)),
            cc.FadeIn:create(0.7), 
            cc.FadeOut:create(0.7)
            )
        ))
    end
end

function SeatManager:hideAllAreaLights()
    if not g.myFunc:checkNodeExist(self.infoCardsNode) then return end
    local tags = {TAG_NEW_AREA, TAG_OLD_AREA, TAG_FINISH_AREA}
    for i, tag in pairs(tags) do
        local child = self.infoCardsNode:getChildByTag(tag)
        child:stopAllActions()
        child:hide()
    end
end

function SeatManager:dealCardsAnim(needAnim, finishCallback)
    g.myFunc:safeRemoveNode(self.mCardsNode)
    self.mCardsNode = display.newNode():addTo(self.sceneAnimNode_)
    -- 自己的牌
    local cards = roomInfo:getMCards()
    if not cards or #cards <= 0 then
        if finishCallback then finishCallback() end
        return
    end
    local newHeapPos = RVP.NewHeapPos
    local mCardCenter = RVP.MCardCenter
    local rPosXList = RoomUtil.getRelativePosXList(roomInfo:getCurGroups())
    local leftX = mCardCenter.x - (rPosXList[#rPosXList] - rPosXList[1])/2
    
    for i = 1, #cards do
        local mCard = g.myUi.PokerCard.new():setCard(cards[i]):setTag(i)
            :pos(newHeapPos.x, newHeapPos.y):addTo(self.mCardsNode, i):opacity(0):scale(RoomConst.toSFactor)
        mCard:showBack()
        mCard:setMagicVisible(RoomUtil.isMagicCard(cards[i]))
        local callback = handler(self, function (self)
            g.event:emit(g.eventNames.RUMMY_CARD_GROUPS_CHANGE)
            if finishCallback then finishCallback() end
        end)
        if needAnim then
            mCard:hide()
            self:cardFlyAnim(mCard, cc.p(leftX + rPosXList[i], mCardCenter.y), i, #cards, callback)
        else
            mCard:pos(leftX + rPosXList[i], mCardCenter.y):opacity(255):scale(1):flip(0.2)
            if callback then callback() end
        end
    end
    self:mCardDrag(self.mCardsNode)
end

function SeatManager:cardFlyAnim(cardNode, destPos, i, totalCardNum, finishCallback)
    cardNode:stopAllActions()
    cardNode:runAction(cc.Sequence:create({
                cc.DelayTime:create(0.2),
                cc.CallFunc:create(function()
                    cardNode:show()
                end),
                cc.FadeIn:create(0.2),
                cc.DelayTime:create(0.02 * i),
                cc.Spawn:create({
                    cc.EaseQuadraticActionOut:create(
                        cc.JumpTo:create(0.4, destPos, 0, 1)
                    ),
                    cc.ScaleTo:create(0.4, 1)
                }),
                cc.CallFunc:create(function()
                    cardNode:setLocalZOrder(i)
                end),
                cc.MoveTo:create(0.0, cc.p(destPos.x + (-4) * (i - totalCardNum/2) , destPos.y)),
                cc.Spawn:create({
                    cc.MoveTo:create(0.0, destPos),
                    cc.CallFunc:create(function()
                        cardNode:flip(0)
                        if i == totalCardNum then
                            if finishCallback then finishCallback() end
                        end
                    end)
                })
            }))
end

function SeatManager:mCardDrag(cardsNode)
    local children = cardsNode:getChildren()
    local posX, posY, preX, preY
    local cardGap = RoomUtil.getCardGap()
    for i, child in pairs(children) do
        child:getFrontSprite():addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
            -- dump(event)
            if event.name == "began" then
                posX = child:getPositionX()
                posY = child:getPositionY()
                preX = event.startX
                preY = event.startY
                self:onCardMoveBegan(child)
                return true
            elseif event.name == "moved" then
                child:pos(event.x - preX + posX, event.y - preY + posY)
                if math.abs(event.x - preX) > 10 then
                    self:showNewGroupBg()-- 显示new group提示区域
                end
                if math.abs(event.y - preY) < 150 then
                    self:onCardMoveTrigger(child, event.x - preX + posX)
                end
            elseif event.name == "ended" then
                if math.abs(event.x - preX) <= 10 and math.abs(event.y - preY) <= 10 then -- 点击事件
                    self:onMCardClick(child, posX)
                elseif self:isInNewGroupArea(event.x, event.y) then -- 移动到新Group区域事件
                    self:onDragToNewGroup(child)
                elseif self:isInOldArea(event.x, event.y) then -- 移动到旧牌堆区域事件
                    self:onDragToOldArea(child)
                elseif self:isInFinishArea(event.x, event.y) then -- 移动到finish堆区域事件
                    self:onDragToFinishArea(child)
                elseif self:isInMoveCardArea(event.x, event.y) then -- 在移牌区, 触发移牌事件
                    self:onMoveCard(self.moveBeginIndex, self.insertIndex, self.frontBack)
                else
                    self:cardsToOrigin()
                end
                self:onCardMoveEnd(child)
            end
        end)
        child:getFrontSprite():setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
        child:getFrontSprite():setTouchEnabled(true)
        child:getFrontSprite():setTouchSwallowEnabled(true)
    end
end

function SeatManager:cardsToOrigin()
    local children = self.mCardsNode:getChildren()
    local mCardCenter = RVP.MCardCenter
    for i, child in pairs(children) do
        local originConf = self.originConfs[child:getTag()]
        child:setPositionX(originConf.posX)
        child:scale(1)
        child:setLocalZOrder(originConf.index)
        if originConf.index == self.moveBeginIndex then -- 自己
            child:setPositionY(mCardCenter.y)
        end
    end
end

function SeatManager:onCardMoveBegan(card)
    local tag = card:getTag()
    self.operTags = RoomUtil.getArrayFormOfCurGroups()
    self.originConfs = {}
    self.hasLeftCard = false
    self.hasRightCard = false
    for i = 1, #self.operTags do
        local curTag = self.operTags[i]
        self.originConfs[curTag] = {}
        self.originConfs[curTag].posX = self.mCardsNode:getChildByTag(curTag):getPositionX()
        self.originConfs[curTag].index = i
        if tag == curTag then
            self.moveBeginIndex = i
            self.moveIndex = i
            self.curMoveTag = tag
            if i - 1 >= 1 then
                self.hasLeftCard = true
                self.leftCardX = self.mCardsNode:getChildByTag(self.operTags[self.moveIndex - 1]):getPositionX()
            end
            if i + 1 <= #self.operTags then
                self.hasRightCard = true
                self.rightCardX = self.mCardsNode:getChildByTag(self.operTags[self.moveIndex + 1]):getPositionX()
            end
        end
    end
end

function SeatManager:onCardMoveTrigger(moveCard, curCardPosX)
    local cardGap = RoomUtil.getCardGap()
    local children = self.mCardsNode:getChildren()
    local minDistance = display.width
    self.insertIndex = -1 -- -1, unset
    self.frontBack = -1 -- -1, unset; 0, insert before; 1, insert after
    for i, child in pairs(children) do
        local originConf = self.originConfs[child:getTag()]
        
        if originConf.index < self.moveBeginIndex then -- 移动开始时, 在移动牌左边
            if originConf.posX > curCardPosX then -- 现在, 在移动牌右边
                child:setPositionX(originConf.posX + cardGap)
                if minDistance > math.abs(originConf.posX + cardGap - curCardPosX) then
                    minDistance = math.abs(originConf.posX + cardGap - curCardPosX)
                    self.insertIndex = originConf.index
                    self.frontBack = 0 -- front
                end
            else -- 仍然在移动牌左边
                child:setPositionX(originConf.posX)
                if minDistance > math.abs(originConf.posX - curCardPosX) then
                    minDistance = math.abs(originConf.posX - curCardPosX) 
                    self.insertIndex = originConf.index
                    self.frontBack = 1 -- back
                end
            end
        elseif originConf.index > self.moveBeginIndex then -- 移动开始时, 在移动牌右边
            if originConf.posX < curCardPosX then -- 现在, 在移动牌左边
                child:setPositionX(originConf.posX - cardGap)
                if minDistance > math.abs(originConf.posX - cardGap - curCardPosX) then
                    minDistance = math.abs(originConf.posX - cardGap - curCardPosX)
                    self.insertIndex = originConf.index
                    self.frontBack = 1 -- back
                end
            else -- 仍然在移动牌右边
                child:setPositionX(originConf.posX)
                if minDistance > math.abs(originConf.posX - curCardPosX) then
                    minDistance = math.abs(originConf.posX - curCardPosX)
                    self.insertIndex = originConf.index
                    self.frontBack = 0 -- front
                end
            end
        end
    end
    if self.frontBack == 0 then
        moveCard:setLocalZOrder(self.insertIndex - 1)
    else
        moveCard:setLocalZOrder(self.insertIndex)
    end
end

function SeatManager:onCardMoveEnd()
    self:hideNewGroupBg()
end

function SeatManager:onMCardClick(card, originX)
    local cardOldY = card:getPositionY()
    self:cardsToOrigin()
    local chooseList = roomInfo:getMCardChooseList()
    local mCardCenter = RVP.MCardCenter
    if cardOldY == mCardCenter.y then -- 未选中牌, 升牌动画, 添加到选中列表中
        card:stopAllActions()
        card:runAction(cc.Sequence:create({
            cc.MoveTo:create(0.1, cc.p(originX, mCardCenter.y + 14)),
            cc.CallFunc:create(function()
                self:refreshCardSel_()
            end),
        }))    
    else -- 已选中牌, 降牌动画, 从选中列表中删除
        card:stopAllActions()
        card:runAction(cc.Sequence:create({
            cc.MoveTo:create(0.1, cc.p(originX, mCardCenter.y)),
            cc.CallFunc:create(function()
                self:refreshCardSel_()
            end),
        }))
    end
end

function SeatManager:refreshCardSel_() -- 下移选中牌到最初位置
    local children = self.mCardsNode:getChildren()
    local chooseList = {}
    if type(children) ~= "table" then return end
    local mCardCenter = RVP.MCardCenter
    for _, child in pairs(children) do
        if g.myFunc:checkNodeExist(child) then
            if child:getPositionY() ~= mCardCenter.y then
                table.insert(chooseList, child:getTag())
            end
        end
    end
    roomInfo:setMCardChooseList(chooseList)
    g.event:emit(g.eventNames.RUMMY_CHOSEN_CARD_CHANGE, {count = #chooseList})
end

function SeatManager:cancelCardsSel() -- 下移选中牌到最初位置
    local children = self.mCardsNode:getChildren()
    if type(children) ~= "table" then return end
    local mCardCenter = RVP.MCardCenter
    for _, child in pairs(children) do
        if g.myFunc:checkNodeExist(child) then
            child:setPositionY(mCardCenter.y)
        end
    end
end

function SeatManager:clearMCardChooseList()
    roomInfo:setMCardChooseList({})
    g.event:emit(g.eventNames.RUMMY_CHOSEN_CARD_CHANGE, {count = 0})
end

function SeatManager:isInNewGroupArea(x, y)
    local pos = RVP.NewGroupDragPos
    return math.abs(pos.x - x) < 80 and math.abs(pos.y - y) < 150
end

function SeatManager:onDragToNewGroup(cardSprite)
    local tag = cardSprite:getTag()
    local isOk = RoomUtil.refreshGroupsByGroup({tag})
    if isOk then
        local destPos = RVP.NewGroupDragPos
        cardSprite:stopAllActions()
        cardSprite:runAction(cc.Sequence:create({
            cc.Spawn:create({
                cc.MoveTo:create(0.2, destPos),
                cc.ScaleTo:create(0.2, 0.94),
                cc.FadeOut:create(0.2)
            }),
            cc.CallFunc:create(function()
                self:updateMCards(roomInfo:getCurGroups()) -- 更改后牌堆
            end)
        }))
    else
        self:cardsToOrigin() -- 更改前牌堆
    end
end

function SeatManager:isInOldArea(x, y)
    local pos = RVP.OldHeapPos
    return math.abs(pos.x - x) < 80 and math.abs(pos.y - y) < 150
end

function SeatManager:onDragToOldArea(cardSprite)
    if not roomInfo:isInSelfDiscardStage() then
        print("不在弃牌阶段")
        self:cardsToOrigin()
        return
    end
    roomInfo:setDragDiscard(true)
    self.roomCtrl_:sendCliDiscardCard(cardSprite:getTag())

    local destPos = RVP.OldHeapPos
    cardSprite:stopAllActions()
    cardSprite:runAction(cc.Sequence:create({
        cc.Spawn:create({
            cc.MoveTo:create(0.2, destPos),
            cc.ScaleTo:create(0.2, RoomConst.toSFactor)
        }),
        cc.CallFunc:create(function()
            self:updateMCards(roomInfo:getCurGroups()) -- 更改后牌堆
        end)
    }))
end

function SeatManager:isInFinishArea(x, y)
    local pos = RVP.FinishSlotPos
    return math.abs(pos.x - x) < 80 and math.abs(pos.y - y) < 150
end

function SeatManager:onDragToFinishArea(cardSprite)
    if not roomInfo:isInSelfDiscardStage() then
        print("不在弃牌阶段")
        self:cardsToOrigin()
        return
    end
    local destPos = RVP.FinishSlotPos
    cardSprite:stopAllActions()
    cardSprite:runAction(cc.Sequence:create({
        cc.Spawn:create({
            cc.MoveTo:create(0.2, destPos),
            cc.ScaleTo:create(0.2, RoomConst.toSFactor)
        }),
        cc.CallFunc:create(function()
            self:showFinishConfirmPopup(cardSprite:getTag())
        end)
    }))
end

function SeatManager:showFinishConfirmPopup(cardIdx)
    g.myUi.Dialog.new({
		type = g.myUi.Dialog.Type.NORMAL,
		text = g.lang:getText("RUMMY", "CONFIRM_FINISH_TIPS"),
        onConfirm = handler(self, function()
            roomInfo:setDragFinish(true)
            self.roomCtrl_:sendCliFinish(cardIdx)
            self:updateMCards(roomInfo:getCurGroups()) -- 更改后牌堆
        end),
        onCancel = handler(self,self.cardsToOrigin)
	}):show()
end

function SeatManager:isInMoveCardArea(x, y)
    local pos = RVP.MCardCenter
    return math.abs(pos.x - x) < 590 and math.abs(pos.y - y) < 150
end

function SeatManager:onMoveCard(beginIdx, endIdx, frontBack)
    print("触发移牌事件, ", beginIdx, endIdx, frontBack)
    local isOk = RoomUtil.refreshGroupsByMove(beginIdx, endIdx, frontBack)
        
    if isOk then
        self:updateMCards(roomInfo:getCurGroups()) -- 更改后牌堆
    end
end

function SeatManager:selfDrawCardAnim(pack, moveToTargetCb)
    local rPosXList = RoomUtil.getRelativePosXList(roomInfo:getCurGroups())
    local mCardCenter = RVP.MCardCenter
    local leftX = mCardCenter.x - (rPosXList[#rPosXList] - rPosXList[1])/2
    local targetPos = cc.p(leftX + rPosXList[#rPosXList], mCardCenter.y)

    if tonumber(pack.region) == 0 then -- 新牌堆
        local newHeapPos = RVP.NewHeapPos
        local card = g.myUi.PokerCard.new():setCard(pack.card)
            :pos(newHeapPos.x, newHeapPos.y):addTo(self.sceneAnimNode_)
        card:showBack()
        card:stopAllActions()
        card:runAction(cc.Sequence:create({
            cc.Spawn:create({
                cc.MoveTo:create(0.6, targetPos),
                cc.ScaleTo:create(0.6, 1)
            }),
            cc.CallFunc:create(function()
                card:flip(0)
            end),
            cc.DelayTime:create(0.1),
            cc.CallFunc:create(function()
                g.myFunc:safeRemoveNode(card)
                if moveToTargetCb then moveToTargetCb() end
            end)
        }))
    elseif tonumber(pack.region) == 1 then -- 旧牌堆
        local oldHeapPos = RVP.OldHeapPos
        local card = g.myUi.PokerCard.new():setCard(pack.card):pos(oldHeapPos.x, oldHeapPos.y):addTo(self.sceneAnimNode_)
        card:showFront()
        self:updateSlotCard(TAG_DISCARD_CARD, pack.dropCard)
        card:setMagicVisible(RoomUtil.isMagicCard(pack.card))
        card:stopAllActions()
        card:runAction(cc.Sequence:create({
            cc.Spawn:create({
                cc.MoveTo:create(0.6, targetPos),
                cc.ScaleTo:create(0.6, 1)
            }),
            cc.CallFunc:create(function()
                g.myFunc:safeRemoveNode(card)
                if moveToTargetCb then moveToTargetCb() end
            end)
        }))
    end
end

function SeatManager:onSelfDiscardCard(dropCard, cardIdx)
    self:stopCountDown(g.user:getUid())
    self:selfDiscardCardAnim(dropCard, cardIdx, function()
        self:updateMCards(roomInfo:getCurGroups())
    end)
    self:clearMCardChooseList()
    self:hideAllAreaLights()
end

function SeatManager:selfDiscardCardAnim(dropCard, cardIdx, finishCallback)
    if not g.myFunc:checkNodeExist(self.infoCardsNode) then return end    
    local oldHeapPos = RVP.OldHeapPos
    local card = self.mCardsNode:getChildByTag(cardIdx)
    if not g.myFunc:checkNodeExist(card) then return end
    if roomInfo:isDragDiscard() then -- 已经拖牌到弃牌区域
        card:pos(oldHeapPos.x, oldHeapPos.y)
    end
    card:stopAllActions()
    card:runAction(cc.Sequence:create({
        cc.Spawn:create({
            cc.MoveTo:create(0.4, oldHeapPos),
            cc.ScaleTo:create(0.4, RoomConst.toSFactor),
            cc.FadeOut:create(0.4),
        }),
        cc.CallFunc:create(function()
            self:updateSlotCard(TAG_DISCARD_CARD, dropCard)
            g.myFunc:safeRemoveNode(card)
            if finishCallback then finishCallback() end
        end),
    }))

    if cardIdx ~= RoomConst.DRAW_CARD_ID then -- 弃牌不是摸牌, 需要将摸牌和弃牌的cardTag对调
        local child = self.mCardsNode:getChildByTag(RoomConst.DRAW_CARD_ID)
        if g.myFunc:checkNodeExist(child) then child:setTag(cardIdx) end
    end
end

function SeatManager:selfFinishCardAnim(finishCard, cardIdx, finishCallback)
    if not g.myFunc:checkNodeExist(self.infoCardsNode) then return end

    local destPos = RVP.FinishSlotPos
    local card = self.mCardsNode:getChildByTag(cardIdx)
    if not g.myFunc:checkNodeExist(card) then return end
    if roomInfo:isDragFinish() then -- 已经拖牌到Finish区域
        card:pos(destPos.x, destPos.y)
    end
    card:stopAllActions()
    card:runAction(cc.Sequence:create({
        cc.Spawn:create({
            cc.MoveTo:create(0.4, destPos),
            cc.ScaleTo:create(0.4, RoomConst.toSFactor),
            cc.FadeOut:create(0.4),
        }),
        cc.CallFunc:create(function()
            self:updateSlotCard(TAG_FINISH_CARD, finishCard)
            g.myFunc:safeRemoveNode(card)
            if finishCallback then finishCallback() end
        end),
    }))
    if cardIdx ~= RoomConst.DRAW_CARD_ID then -- finish牌不是摸牌, 需要将摸牌和弃牌的cardTag对调
        local child = self.mCardsNode:getChildByTag(RoomConst.DRAW_CARD_ID)
        if g.myFunc:checkNodeExist(child) then child:setTag(cardIdx) end
    end
end

function SeatManager:selfDrop(pack)
    self:clearMCardsArea()
    self:hideAllAreaLights()
    self:userDrop(pack)
end

function SeatManager:selfDeclare(pack)
    self:clearMCardsArea()
    self:hideAllAreaLights()
end

function SeatManager:otherDrawCardAnim(pack)
    if not g.myFunc:checkNodeExist(self.infoCardsNode) then return end
    local seatId = self:querySeatIdByUid(pack.uid)
    local fixSeatId = RoomUtil.getFixSeatId(seatId)
    if fixSeatId < 0 then return end
    if tonumber(pack.region) == 0 then -- 新牌堆
        local newHeapPos = RVP.NewHeapPos
        local card = g.myUi.PokerCard.new():pos(newHeapPos.x, newHeapPos.y):addTo(self.sceneAnimNode_):scale(RoomConst.toSFactor)
        card:showBack()
        card:stopAllActions()
        card:runAction(cc.Sequence:create({
            cc.Spawn:create({
                cc.MoveTo:create(0.6, P1[fixSeatId]),
                cc.ScaleTo:create(0.6, RoomConst.toSFactor * 0.8),
                cc.FadeOut:create(0.6),
            }),
            cc.CallFunc:create(function()
                g.myFunc:safeRemoveNode(card)
            end)
        }))
    elseif tonumber(pack.region) == 1 then -- 旧牌堆
        local dropCard = self.infoCardsNode:getChildByTag(TAG_DISCARD_CARD)
        local oldHeapPos = RVP.OldHeapPos
        local oldCardUint = dropCard:getCard()
        local card = g.myUi.PokerCard.new():setCard(oldCardUint):scale(RoomConst.toSFactor)
            :pos(oldHeapPos.x, oldHeapPos.y):addTo(self.sceneAnimNode_)
        card:showFront()
        card:setMagicVisible(RoomUtil.isMagicCard(oldCardUint))
        self:updateSlotCard(TAG_DISCARD_CARD, pack.dropCard)
        card:stopAllActions()
        card:runAction(cc.Sequence:create({
            cc.Spawn:create({
                cc.MoveTo:create(0.6, P1[fixSeatId]),
                cc.ScaleTo:create(0.6, RoomConst.toSFactor * 0.8),
                cc.FadeOut:create(0.6),
            }),
            cc.CallFunc:create(function()
                g.myFunc:safeRemoveNode(card)
            end)
        }))
    end
end

function SeatManager:otherDiscardCardAnim(pack)
    if not g.myFunc:checkNodeExist(self.infoCardsNode) then return end
    local seatId = self:querySeatIdByUid(pack.uid)
    local fixSeatId = RoomUtil.getFixSeatId(seatId)
    if fixSeatId < 0 then return end
    
    local oldHeapPos = RVP.OldHeapPos
    local card = g.myUi.PokerCard.new():setCard(pack.dropCard):scale(RoomConst.toSFactor * 0.6)
        :pos(P1[fixSeatId].x, P1[fixSeatId].y):addTo(self.infoCardsNode)
    card:showFront()
    card:stopAllActions()
    card:runAction(cc.Sequence:create({
        cc.Spawn:create({
            cc.ScaleTo:create(0.4, RoomConst.toSFactor * 1),
            cc.FadeIn:create(0.4),
        }),
        cc.Spawn:create({
            cc.MoveTo:create(0.4, oldHeapPos),
            cc.FadeOut:create(0.4),
        }),
        cc.CallFunc:create(function()
            self:updateSlotCard(TAG_DISCARD_CARD, pack.dropCard)
            g.myFunc:safeRemoveNode(card)
        end)
    }))
end

function SeatManager:otherFinishCardAnim(pack)
    if not g.myFunc:checkNodeExist(self.infoCardsNode) then return end
    local seatId = self:querySeatIdByUid(pack.uid)
    local fixSeatId = RoomUtil.getFixSeatId(seatId)
    if fixSeatId < 0 then return end
    local destPos = RVP.FinishSlotPos
    local card = g.myUi.PokerCard.new():setCard(pack.card):scale(RoomConst.toSFactor * 0.6)
        :pos(P1[fixSeatId].x, P1[fixSeatId].y):addTo(self.infoCardsNode)
    card:showFront()
    card:showBack()
    card:stopAllActions()
    card:runAction(cc.Sequence:create({
        cc.Spawn:create({
            cc.ScaleTo:create(0.4, RoomConst.toSFactor * 1),
            cc.FadeIn:create(0.4),
        }),
        cc.Spawn:create({
            cc.MoveTo:create(0.4, destPos),
            cc.FadeOut:create(0.4),
        }),
        cc.CallFunc:create(function()
            self:updateSlotCard(TAG_FINISH_CARD, pack.card, true)
            g.myFunc:safeRemoveNode(card)
        end)
    }))
end

function SeatManager:cardFinishAreaToDiscardArea()
    if not g.myFunc:checkNodeExist(self.infoCardsNode) then return end
    local card = self.infoCardsNode:getChildByTag(TAG_FINISH_CARD)
    if not g.myFunc:checkNodeExist(card) then return end
    local cardUint = card:getCard()
    
    self:updateSlotCard(TAG_FINISH_CARD, -1) -- 隐藏finish牌
    self:updateSlotCard(TAG_DISCARD_CARD, cardUint)
    
end

function SeatManager:userDrop(pack)
    local seatId = self:querySeatIdByUid(pack.uid)
    if seatId >= 0 then
        local seat = self:getSeatByServerSeatId(seatId)
        seat:setHeadDark()
        seat:showFoldTxt()
    end
end

function SeatManager:updateMCards(groups, noUpload)
    dump(groups, "cur Group", 5)
    roomInfo:setCurGroups(groups)

    g.myFunc:safeRemoveNode(self.mCardsNode)
    self.mCardsNode = display.newNode():addTo(self.sceneAnimNode_)
    local rPosXList = RoomUtil.getRelativePosXList(groups)
    local mCards = roomInfo:getMCards()
    
    local mCardCenter = RVP.MCardCenter
    local leftX = mCardCenter.x - (rPosXList[#rPosXList] - rPosXList[1])/2
    local curIndex = 0
    local newDrawCardPos = -1
    for _, group in pairs(groups) do
        for j = 1, #group do
            local idx = group[j]
            curIndex = curIndex + 1
            local mCard = g.myUi.PokerCard.new():setCard(mCards[idx]):setTag(idx)
                :pos(leftX + rPosXList[curIndex], mCardCenter.y):addTo(self.mCardsNode)
                :setLocalZOrder(curIndex)
            mCard:showFront()
            mCard:setMagicVisible(RoomUtil.isMagicCard(mCards[idx]))
            if idx == RoomConst.DRAW_CARD_ID then newDrawCardPos = curIndex end
        end
    end
    self:mCardDrag(self.mCardsNode)
    self:updateMGroupInfo(groups, rPosXList[1], rPosXList[#rPosXList])
    if not noUpload then
        self:uploadGroups(groups, newDrawCardPos)
    end
    g.event:emit(g.eventNames.RUMMY_CARD_GROUPS_CHANGE)
end

function SeatManager:updateMGroupInfo(groups, firstCardPosX, lastCardPosX)
    g.myFunc:safeRemoveNode(self.mGroupInfoNode)
    self.mGroupInfoNode = display.newNode():addTo(self.sceneAnimNode_)
    local mGroupInfoCenter = RVP.MGroupInfoCenter
    local confiPosXList = RoomUtil.getGroupTipRelativePosXList(groups)
    local confs = RoomUtil.getGroupConfs(groups)
    -- dump(confiPosXList, "confiPosXList")
    local leftX = mGroupInfoCenter.x - (lastCardPosX - firstCardPosX)/2
    for i, group in pairs(groups) do
        local groupInfoNode = display.newNode():pos(leftX + confiPosXList[i], mGroupInfoCenter.y):addTo(self.mGroupInfoNode)
        local conf = confs[i]
        self:renderGroupInfoNode(conf, groupInfoNode)
    end
end

function SeatManager:renderGroupInfoNode(conf, node)
    if conf.isValid then -- 符合条件group组
        local icon = display.newSprite(mResDir .. "check_ok.png"):addTo(node)
        local lbl = display.newTTFLabel({size = 18}):addTo(node)
        if conf.cardType == RoomConst.STRAIGHT_FLUSH then
            lbl:setString(g.lang:getText("RUMMY", "STRAIGHT_FLUSH"))
        elseif conf.cardType == RoomConst.STRAIGHT then
            lbl:setString(g.lang:getText("RUMMY", "STRAIGHT"))
        elseif conf.cardType == RoomConst.SANGONG then
            lbl:setString(g.lang:getText("RUMMY", "SANGONG"))
        end
        g.myFunc:setNodesAlignCenter({icon, lbl}, 4)
    elseif conf.cardType == RoomConst.OTHERS then -- 非法, 且不是条或顺子
        if conf.cardNum >= 2 and conf.point <= 0 then -- 大于等于两张牌, 点数为0
            local icon = display.newSprite(mResDir .. "check_ok.png"):addTo(node)
        elseif conf.cardNum >= 2 then -- 大于等于两张牌, 点数大于0
            local icon = display.newSprite(mResDir .. "check_fail.png"):addTo(node)
            local str = "Invalid (" .. conf.point .. ")"
            local lbl = display.newTTFLabel({size = 18, text = str}):addTo(node)
            g.myFunc:setNodesAlignCenter({icon, lbl}, 4)
        else -- 单张牌
            display.newTTFLabel({size = 18, text = conf.point .. " Pts"}):addTo(node)
        end
    else -- 非法, 条或顺子
        local str = ""
        if conf.cardType == RoomConst.STRAIGHT_FLUSH then
            str = str .. g.lang:getText("RUMMY", "STRAIGHT_FLUSH")
        elseif conf.cardType == RoomConst.STRAIGHT then
            str = str .. g.lang:getText("RUMMY", "STRAIGHT")
        elseif conf.cardType == RoomConst.SANGONG then
            str = str .. g.lang:getText("RUMMY", "SANGONG")
        end
        str = str .. " (" .. conf.point .. ")"
        local lbl = display.newTTFLabel({size = 18, text = str}):addTo(node)
    end
end

function SeatManager:uploadGroups(groups, newDrawCardPos)
    if RoomUtil.isGroupsEqual(groups, roomInfo:getLastReportGroups()) then
        print("groups equal to last reported groups")
        return
    end
    local mCards = roomInfo:getMCards()
    if g.mySocket:isConnected() then
        local pack = g.mySocket:createPacketBuilder(CmdDef.CLI_RUMMY_UPLOAD_GROUPS)
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
        pack:setParameter("drawCardPos", newDrawCardPos)
        printVgg("drawCardPos", newDrawCardPos)
        g.mySocket:send(pack:build())
  end
  roomInfo:setLastReportGroups(clone(groups))
end

function SeatManager:showNewGroupBg()
    if g.myFunc:checkNodeExist(self.newGroupBg) and self.newGroupBg:isVisible() then return end
    local pos = RVP.NewGroupDragPos
    if not self.newGroupBg then
        self.newGroupBg = display.newSprite(mResDir .. "new_group_bg.png"):pos(pos.x, pos.y):addTo(self.sceneSeatNode_)
            :opacity(0):hide()
        display.newTTFLabel({text = "  " .. g.lang:getText("RUMMY", "NEW_GROUP"), size = 18})
            :pos(self.newGroupBg:getContentSize().width/2, self.newGroupBg:getContentSize().height/2 - 24):addTo(self.newGroupBg)
    end
    self.newGroupBg:opacity(0)
    self.newGroupBg:show()
    self.newGroupBg:stopAllActions()
    self.newGroupBg:runAction(cc.Sequence:create({
       cc.FadeIn:create(0.2)
    }))
end

function SeatManager:hideNewGroupBg()
    if g.myFunc:checkNodeExist(self.newGroupBg) then
        self.newGroupBg:hide()
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

function SeatManager:changeUserState(uState)
    for _, v in ipairs(self.playerInfo) do
            v.state = uState
            if v.seatId >= 0 and v.seatId <= RoomConst.UserNum - 1 then
                local seat = self.seats_[v.seatId]
                seat:setUState(uState)
                if uState == RoomConst.USER_PLAY then
                    seat:setHeadBright()
                end
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

function SeatManager:startMoveToNotFix()
    for i = 0, RoomConst.UserNum-1 do
        local seat = self.seats_[i]
        seat:updateSeatConfig()
        self:startMoveSeatAnimation(seat, seat:getNowPos(), i)
    end
end

function SeatManager:setToIndexSeat(seat,toSeatId)
    seat:pos(P1[toSeatId].x, P1[toSeatId].y)
    seat:setNowPos(toSeatId)
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
	if tonumber(uid) == tonumber(g.user:getUid()) then
		roomInfo:setMSeatId(-1)
		roomInfo:clearMCards()
		self:startMoveToNotFix()  
		-- self.scene:showChgTableBtn()
		-- self.scene:hideStandUpBtn()
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

function SeatManager:inGameReconnectInfo(pack)
    -- 更新弃牌玩家
    if type(pack.users) == "table" then
        for _, user in pairs(pack.users) do
            if user and tonumber(user.isDrop) == 1 then
                if tonumber(user.uid) == tonumber(g.user:getUid()) then
                    self:selfDrop({uid = user.uid})
                end
                self:userDrop({uid = user.uid})
            end
        end
    end 
end

function SeatManager:selfInGameReconnectInfo(pack)
    if pack.mPlayer then
        if tonumber(pack.mPlayer.operStatus) == 0 then -- 不该玩家操作
            self:hideAllAreaLights()
        elseif tonumber(pack.mPlayer.operStatus) == 1 then -- 该拿牌
            self:showAreaLightsDrawStage()
        elseif tonumber(pack.mPlayer.operStatus) == 2 then -- 该出牌
            self:showAreaLightsDiscardStage()
		end
    end
end

function SeatManager:clearMCardsArea()
    g.myFunc:safeRemoveNode(self.mCardsNode)
    g.myFunc:safeRemoveNode(self.mGroupInfoNode)
end

function SeatManager:clearAll()
    self.playerInfo = {}
    self.seats_ = {}
end

function SeatManager:clearTable()
    for i = 0, RoomConst.UserNum - 1 do
        self.seats_[i]:clearTable()
    end
    self:clearMCardsArea()
    g.myFunc:safeRemoveNode(self.infoCardsNode)
end

function SeatManager:XXXX()
    
end

function SeatManager:dispose()
    self:clearAll()
end

return SeatManager

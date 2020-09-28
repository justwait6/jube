-- Author: Jam
-- Date: 2020.04.14
local funplaypoker = "没有用处，代码混淆用"

local RoomInfo = class("RoomInfo")

function RoomInfo:ctor()
    self:reset()
end
function RoomInfo:reset()
    self.mSeatId = -1 -- 我的座位id
    self.dSeatId = -1 -- 庄家座位id
    self.smallBet = 1 -- 房间底注
    self.mCards = {} -- 我的手牌
    self.isLastRound = false
    self.declareTime = 0
    self.declareTimeMinus = 0
    self.isNewRoundCount = false
end

function RoomInfo.getInstance()
   if not RoomInfo.instance then
       RoomInfo.instance = RoomInfo:new()
   end
   return RoomInfo.instance
end
function RoomInfo:setMSeatId(mSeatId)
    self.mSeatId = mSeatId
end
function RoomInfo:getMSeatId()
    return self.mSeatId
end
function RoomInfo:setDSeatId(dSeatId)
    self.dSeatId = dSeatId
end
function RoomInfo:getDSeatId()
    return self.dSeatId
end
function RoomInfo:setSmallBet(smallBet)
    self.smallBet = smallBet
end
function RoomInfo:getSmallBet()
    return self.smallBet or 1
end
function RoomInfo:setMagicCard(card)
    self.magicCard = card
end
function RoomInfo:getMagicCard()
    return self.magicCard or -1
end
function RoomInfo:setMCards(cards)
    self.mCards = cards
end
function RoomInfo:getMCards()
    return self.mCards
end
function RoomInfo:setDragDiscard(isDragAction)
    self.isDragDiscardAction_ = isDragAction
end
function RoomInfo:isDragDiscard()
    return self.isDragDiscardAction_
end
function RoomInfo:setDragFinish(isDragAction)
    self.isDragFinishAction_ = isDragAction
end
function RoomInfo:isDragFinish()
    return self.isDragFinishAction_
end
function RoomInfo:isInSelfDiscardStage()
    return #(self.mCards or {}) == 14
end
function RoomInfo:setFinishCardIndex(index)
    self.finishCardIndex = index
end
function RoomInfo:getFinishCardIndex()
    return self.finishCardIndex or -1
end
function RoomInfo:resetFinishCardIndex()
    self.finishCardIndex = -1
end
function RoomInfo:setCurGroups(groups)
    self.curGroups = groups
end
function RoomInfo:getCurGroups()
    return self.curGroups or {}
end
function RoomInfo:getMCardChooseList()
    return self.mCardChooseList or {}
end
function RoomInfo:setMCardChooseList(cardChooseList)
    self.mCardChooseList = cardChooseList
end
function RoomInfo:setLastReportGroups(groups)
    self.lastReportGroups = groups
end
function RoomInfo:getLastReportGroups()
    return self.lastReportGroups or {}
end
function RoomInfo:resetWhenSelfTurn()
    self:resetFinishCardIndex()
    self:setDragDiscard(false)
    self:setDragFinish(false)
end

function RoomInfo:setLastRound(lastRound)
    self.isLastRound = lastRound
end

function RoomInfo:getLastRound()
    return self.isLastRound
end

function RoomInfo:setDeclareTime(declareTime)
    self.declareTime = declareTime
end

function RoomInfo:getDeclareTime()
    return self.declareTime
end

function RoomInfo:setDeclareTimeMinus(declareTimeMinus)
    self.declareTimeMinus = declareTimeMinus
end

function RoomInfo:getDeclareTimeMinus()
    return self.declareTimeMinus
end

function RoomInfo:setDeclareResultDataPack(pack)
    self.declareResultPack_ = pack
end

function RoomInfo:getDeclareResultDataPack()
    return self.declareResultPack_ or {}
end

function RoomInfo:clearMCards()
   self.mCards = {}
   self.curGroups = {}
   self.mCardChooseList = {}
   self.lastReportGroups = {}
end

return RoomInfo

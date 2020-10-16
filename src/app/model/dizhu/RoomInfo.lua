local RoomInfo = class("RoomInfo")

function RoomInfo:ctor()
    self:reset()
end
function RoomInfo:reset()
    self.mSeatId = -1 -- 我的座位id
    self.mCards = {} -- 我的手牌
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
function RoomInfo:setMCards(cards)
    self.mCards = cards
end
function RoomInfo:getMCards()
    return self.mCards
end
function RoomInfo:setLatestOutCards(cards)
    self.lastestOutCards_ = cards
end
function RoomInfo:getLatestOutCards()
    return self.lastestOutCards_
end
function RoomInfo:setSelCards(cards)
    self.mSelCards_ = cards
end
function RoomInfo:getSelCards()
    return self.mSelCards_
end
function RoomInfo:setSelfNewRound(isNewRound)
    self.isNewRound_ = isNewRound
end
function RoomInfo:isSelfNewRound()
    return self.isNewRound_
end

function RoomInfo:clearMCards()
   self.mCards = {}
end

return RoomInfo

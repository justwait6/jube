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

function RoomInfo:clearMCards()
   self.mCards = {}
end

return RoomInfo

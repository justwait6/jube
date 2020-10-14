local RoomUtil = class("RoomUtil")
local roomInfo = require("app.model.dizhu.RoomInfo").getInstance()
local RoomConst = require("app.model.dizhu.RoomConst")
local CardDef = require("app.model.baseDef.CardDef")
--我移位后的座位
function RoomUtil.getFixSeatId(seatId)
     if roomInfo:getMSeatId() < 0 then --我是站起的
          return seatId
     end
     local fixSeatId = RoomConst.MSeatId + (seatId - roomInfo:getMSeatId())
     if fixSeatId > RoomConst.UserNum - 1 then 
         fixSeatId = fixSeatId - RoomConst.UserNum
     elseif fixSeatId < 0 then
         fixSeatId = fixSeatId + RoomConst.UserNum
     end
     return fixSeatId
end

-- Compare single card, a < b returns 1, a = b returns 0, a > b returns -1
function RoomUtil.compareCard(a, b)
    -- if has joker card
    if a == CardDef.SMALL_JOKER or a == CardDef.BIG_JOKER or b == CardDef.SMALL_JOKER or b == CardDef.BIG_JOKER then
        if a < b then
            return 1
        else
            return -1
        end
    end
    -- if card value equal
    if a % 16 == b % 16 then return 0 end
    -- if not has joker card and has 2 card
    if (a % 16 == 2) then return -1 end
    if (b % 16 == 2) then return 1 end
    if (a % 16 < b % 16) then return 1 end
    if (a % 16 > b % 16) then return -1 end
end

-- Sort single card, a <= b returns true, a > b returns false
function RoomUtil.sortCard(a, b)
    -- if has joker card
    if a == CardDef.SMALL_JOKER or a == CardDef.BIG_JOKER or b == CardDef.SMALL_JOKER or b == CardDef.BIG_JOKER then
        return a < b
    end
    -- if card value equal
    if a % 16 == b % 16 then return true end
    -- if not has joker card and has 2 card
    if (a % 16 == 2) then return false end
    if (b % 16 == 2) then return true end
    return a % 16 < b % 16
end

return RoomUtil

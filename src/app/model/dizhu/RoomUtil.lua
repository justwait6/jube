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

local isCardEqual = function(a, b)
    return a % 16 == b % 16
end

local isHas2OrJoker = function(cards)
    for i = 1, #cards do
        if cards[i] % 16 == 2 or bit.brshift(cards[i], 4) == CardDef.VARIETY_JOKER then
            return true
        end
    end
    return false
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
    if (isCardEqual(a, b)) then return 0 end
    -- if not has joker card and has 2 card
    if (a % 16 == 2) then return -1 end
    if (b % 16 == 2) then return 1 end
    if (a % 16 < b % 16) then return 1 end
    if (a % 16 > b % 16) then return -1 end
end

-- Sort single card, a <= b returns true, a > b returns true
-- If isVerse == true, a == b returns false, otherwise, a == b returns true
-- [Warn] for lua SPECIFY that table sort function only can return false when a == b
function RoomUtil.sortCard(a, b, isVerse)
    -- if has joker card
    if a == CardDef.SMALL_JOKER or a == CardDef.BIG_JOKER or b == CardDef.SMALL_JOKER or b == CardDef.BIG_JOKER then
        return a < b
    end
    -- if card value equal
    if isVerse then
        if (isCardEqual(a, b)) then return true end 
    else
        if (isCardEqual(a, b)) then return false end 
    end
    -- if not has joker card and has 2 card
    if (a % 16 == 2) then return false end
    if (b % 16 == 2) then return true end
    return a % 16 < b % 16
end

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
    if (isCardEqual(a, b)) then return 0 end
    -- if not has joker card and has 2 card
    if (a % 16 == 2) then return -1 end
    if (b % 16 == 2) then return 1 end
    if (a % 16 < b % 16) then return 1 end
    if (a % 16 > b % 16) then return -1 end
end

function RoomUtil.getCardType(cards)
    local cardType = RoomConst.CARD_T_NONE
    if #cards == 1 then
        cardType = RoomConst.CARD_T_SINGLE
    elseif RoomUtil.isPair(cards) then
        cardType = RoomConst.CARD_T_PAIR
    elseif RoomUtil.isThree(cards) then
        cardType = RoomConst.CARD_T_THREE
    elseif RoomUtil.isThreeOne(cards) then
        cardType = RoomConst.CARD_T_THREE_ONE
    elseif RoomUtil.isThreeTwo(cards) then
        cardType = RoomConst.CARD_T_THREE_TWO
    elseif RoomUtil.isSeq(cards) then
        cardType = RoomConst.CARD_T_SEQ
    elseif RoomUtil.isTwinSeq(cards) then
        cardType = RoomConst.CARD_T_TWIN_SEQ
    elseif RoomUtil.isThreeSeq(cards) then
        cardType = RoomConst.CARD_T_THREE_SEQ
    elseif RoomUtil.isPlaneOne(cards) then
        cardType = RoomConst.CARD_T_PLANE_ONE
    elseif RoomUtil.isPlaneTwo(cards) then
        cardType = RoomConst.CARD_T_PLANE_TWO
    elseif RoomUtil.isFourTwo(cards) then
        cardType = RoomConst.CARD_T_FOUR_TWO
    elseif RoomUtil.isFourBoom(cards) then
        cardType = RoomConst.CARD_T_FOUR_BOOM
    elseif RoomUtil.isJokerBoom(cards) then
        cardType = RoomConst.CARD_T_JOKER_BOOM
    end
    return cardType
end

function RoomUtil.isPair(cards)
    if #cards ~= 2 then return false end
    return isCardEqual(cards[1], cards[2]) and bit.brshift(cards[1], 4) ~= CardDef.VARIETY_JOKER
end

function RoomUtil.isThree(cards)
    if #cards ~= 3 then return false end
    return isCardEqual(cards[1], cards[2]) and isCardEqual(cards[2], cards[3])
end

function RoomUtil.isThreeOne(cards)
    if #cards ~= 4 then return false end
    print("sort result: ", RoomUtil.sortCard(cards[1], cards[2]))
    table.sort(cards, function(a, b) return RoomUtil.sortCard(a, b) end)
    return ( RoomUtil.isThree({cards[1], cards[2], cards[3]}) and not isCardEqual(cards[3], cards[4]) )
        or ( not isCardEqual(cards[1], cards[2]) and RoomUtil.isThree({cards[2], cards[3], cards[4]}) )
end

function RoomUtil.isThreeTwo(cards)
    if #cards ~= 5 then return false end
    table.sort(cards, function(a, b) return RoomUtil.sortCard(a, b) end)
    return ( RoomUtil.isThree({cards[1], cards[2], cards[3]}) and isCardEqual(cards[4], cards[5]) )
        or ( isCardEqual(cards[1], cards[2]) and RoomUtil.isThree({cards[3], cards[4], cards[5]}) )
end

function RoomUtil.isSeq(cards)
    if #cards < 5 or 12 < #cards then return false end

    -- 不能含有2和王
    if isHas2OrJoker(cards) then return false end

    table.sort(cards, function(a, b) return RoomUtil.sortCard(a, b) end)
    -- 检查是否顺序递增
    local values = {}
    for _, card in pairs(cards) do
        table.insert(values, card % 16)
    end
    for i = 1, #values - 1 do
        if values[i] ~= values[i + 1] - 1 then -- 不顺序递增, 不能连成顺子
            return false
        end
    end
    return true
end

function RoomUtil.isTwinSeq(cards)
    if #cards < 6 then return false end
    if #cards % 2 ~= 0 then return false end -- 偶数张牌

    -- 不能含有2和王
    if isHas2OrJoker(cards) then return false end

    table.sort(cards, function(a, b) return RoomUtil.sortCard(a, b) end)
    -- 检查是否顺序对子递增
    local values = {}
    for _, card in pairs(cards) do
        table.insert(values, card % 16)
    end
    for i = 1, #values - 2, 2 do -- (注意不要越界)
        if values[i] ~= values[i + 1] then -- 与其后第一张牌不等值, 不能组成连对
            return false
        end
        if values[i] ~= values[i + 2] - 1 then -- 与其后第二张牌不递增, 不能组成连对
            return false
        end
    end
    return true
end

function RoomUtil.isThreeSeq(cards)
    if #cards < 6 then return false end
    if #cards % 3 ~= 0 then return false end -- 3的倍数

    -- 不能含有2和王
    if isHas2OrJoker(cards) then return false end

    table.sort(cards, function(a, b) return RoomUtil.sortCard(a, b) end)
    -- 检查是否3顺
    local values = {}
    for _, card in pairs(cards) do
        table.insert(values, card % 16)
    end
    for i = 1, #values, 3 do -- (注意不要越界)
        if (values[i] ~= values[i + 1] or values[i + 1] ~= values[i + 2])  then -- 与其后两张牌不等值, 不能组成3顺
            return false
        end
        if i < #values - 3 and values[i] ~= values[i + 3] - 1 then -- 与其后第三张牌不递增, 不能组成连对
            return false
        end
    end
    return true 
end

function RoomUtil.isPlaneOne(cards)
    if #cards < 8 then return false end
    if #cards % 4 ~= 0 then return false end -- 4的倍数

    table.sort(cards, function(a, b) return RoomUtil.sortCard(a, b) end)
    local threeSeqCards = {}
    local sigleCards = {}

    local i = 1
    while (i <= #cards) do
        if i < #cards - 1 and RoomUtil.isThree({cards[i], cards[i + 1], cards[i + 2]}) then
            table.insert(threeSeqCards, cards[i])
            table.insert(threeSeqCards, cards[i + 1])
            table.insert(threeSeqCards, cards[i + 2])
            i = i + 3
        else
            table.insert(sigleCards, cards[i])
            i = i + 1
        end
    end

    dump(threeSeqCards, "isPlaneOne: 1")
    dump(sigleCards, "isPlaneOne: 2")
    return RoomUtil.isThreeSeq(threeSeqCards) and #threeSeqCards / 3 == #sigleCards
end

function RoomUtil.isPlaneTwo(cards)
    if #cards < 10 then return false end
    if #cards % 5 ~= 0 then return false end -- 5的倍数

    table.sort(cards, function(a, b) return RoomUtil.sortCard(a, b) end)
    local threeSeqCards = {}
    local pairCards = {}

    local i = 1
    while (i < #cards) do
        if i < #cards - 1 and RoomUtil.isThree({cards[i], cards[i + 1], cards[i + 2]}) then -- 注意不要越界
            table.insert(threeSeqCards, cards[i])
            table.insert(threeSeqCards, cards[i + 1])
            table.insert(threeSeqCards, cards[i + 2])
            i = i + 3
        elseif RoomUtil.isPair({cards[i], cards[i + 1]}) then
            table.insert(pairCards, cards[i])
            table.insert(pairCards, cards[i + 1])
            i = i + 2
        else -- 既不是三顺, 又不是对子, 直接返回false
            return false
        end
    end

    return RoomUtil.isThreeSeq(threeSeqCards) and #threeSeqCards / 3 == #pairCards / 2
end

function RoomUtil.isFourTwo(cards)
    if #cards ~= 6 then return false end
    table.sort(cards, function(a, b) return RoomUtil.sortCard(a, b) end)
    for i = 1, 3 do
        if (RoomUtil.isFourBoom({cards[i], cards[i + 1], cards[i + 2], cards[i + 3]})) then
            return true
        end
    end
    return false
end

function RoomUtil.isFourBoom(cards)
    if #cards ~= 4 then return false end
    return isCardEqual(cards[1], cards[2]) and isCardEqual(cards[2], cards[3]) and isCardEqual(cards[3], cards[4])
end

function RoomUtil.isJokerBoom(cards)
    if #cards ~= 2 then return false end
    table.sort(cards, function(a, b) return RoomUtil.sortCard(a, b) end)
    return cards[1] == CardDef.SMALL_JOKER and cards[2] == CardDef.BIG_JOKER
end

function RoomUtil.canOut(mCards, cmpCards)
    return true
end

return RoomUtil

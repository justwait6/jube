local RoomUtil = class("RoomUtil")
local roomInfo = require("app.model.dizhu.RoomInfo").getInstance()
local RoomConst = require("app.model.dizhu.RoomConst")
local CardsDef = require("app.model.baseDef.CardsDef")
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

local isHas2OrJoker = function(cards, startIdx, endIndx)
    local begin__ = startIdx or 1
    local end__ = endIdx or #cards
    for i = begin__, end__ do
        if cards[i] % 16 == 2 or bit.brshift(cards[i], 4) == CardsDef.VARIETY_JOKER then
            return true
        end
    end
    return false
end
-- Compare single card, a < b returns -1, a = b returns 0, a > b returns 1
function RoomUtil.compareCard(a, b)
    -- if has joker card
    if a == CardsDef.SMALL_JOKER or a == CardsDef.BIG_JOKER or b == CardsDef.SMALL_JOKER or b == CardsDef.BIG_JOKER then
        if a < b then
            return -1
        else
            return 1
        end
    end
    -- if card value equal
    if (a % 16 == b % 16) then return 0 end
    -- if not has joker card and has 2 card
    if (a % 16 == 2) then return 1 end
    if (b % 16 == 2) then return -1 end
    if (a % 16 < b % 16) then return -1 end
    if (a % 16 > b % 16) then return 1 end
end

-- Sort single card, a < b returns true, a > b returns false (if card value a == b, compare card variety)
-- [Warn] for lua SPECIFY that table sort function only can return false when a == b
function RoomUtil.sortCard(a, b)
    -- if has joker card
    if a == CardsDef.SMALL_JOKER or a == CardsDef.BIG_JOKER or b == CardsDef.SMALL_JOKER or b == CardsDef.BIG_JOKER then
        return a < b
    end
    -- if card value equal
    if (a % 16 == b % 16) then return bit.brshift(a, 4) < bit.brshift(b, 4) end
    -- if not has joker card and has 2 card
    if (a % 16 == 2) then return false end
    if (b % 16 == 2) then return true end
    return a % 16 < b % 16
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
    return isCardEqual(cards[1], cards[2]) and bit.brshift(cards[1], 4) ~= CardsDef.VARIETY_JOKER
end

function RoomUtil.isThree(cards)
    if #cards ~= 3 then return false end
    for i = 1, 3 do -- no joker card
        if bit.brshift(cards[i], 4) == CardsDef.VARIETY_JOKER then
            return false
        end
    end
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

local canMapPlaneSeq = function(tags, startIdx, endIdx)
    if isHas2OrJoker(tags, startIdx, endIndx) then return false end
    for i = startIdx, endIdx - 1 do
        if (tags[i] % 16 ~= tags[i + 1] % 16 - 1) then
            return false
        end
    end
    return true
end

function RoomUtil.isPlaneOne(cards)
    if #cards < 8 then return false end
    if #cards % 4 ~= 0 then return false end -- 4的倍数

    table.sort(cards, function(a, b) return RoomUtil.sortCard(a, b) end)
    local threeCardTags = {}

    local i = 1
    while (i <= #cards) do
        if i < #cards - 1 and RoomUtil.isThree({cards[i], cards[i + 1], cards[i + 2]}) then
            table.insert(threeCardTags, cards[i])
            i = i + 2
        end
        i = i + 1
    end

    if #threeCardTags == #cards / 4 then
        return canMapPlaneSeq(threeCardTags, 1, #threeCardTags)
    elseif #threeCardTags > #cards / 4 then
        return canMapPlaneSeq(threeCardTags, 1, #threeCardTags - 1) or canMapPlaneSeq(threeCardTags, 2, #threeCardTags)
    else
        return false
    end
end

function RoomUtil.isPlaneTwo(cards)
    if #cards < 10 then return false end
    if #cards % 5 ~= 0 then return false end -- 5的倍数

    table.sort(cards, function(a, b) return RoomUtil.sortCard(a, b) end)
    local threeCardTags = {}

    local i = 1
    while (i < #cards) do
        if i < #cards - 1 and RoomUtil.isThree({cards[i], cards[i + 1], cards[i + 2]}) then -- 注意不要越界
            table.insert(threeCardTags, cards[i])
            i = i + 3
        elseif RoomUtil.isPair({cards[i], cards[i + 1]}) then
            i = i + 2
        else -- 既不是三顺, 又不是对子, 直接返回false
            return false
        end
    end
    if #threeCardTags == #cards / 5 then
        return canMapPlaneSeq(threeCardTags, 1, #threeCardTags)
    elseif #threeCardTags > #cards / 5 then
        return canMapPlaneSeq(threeCardTags, 1, #threeCardTags - 1) or canMapPlaneSeq(threeCardTags, 2, #threeCardTags)
    else
        return false
    end
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
    return cards[1] == CardsDef.SMALL_JOKER and cards[2] == CardsDef.BIG_JOKER
end

-- 使用前提: 牌组已排序, 有炸弹返回最大炸弹, 没有返回false
function RoomUtil.findLargestBoom(cards)
    if #cards >= 2 and (RoomUtil.isJokerBoom({cards[#cards - 1], cards[#cards - 2]})) then
        return {cards[#cards - 1], cards[#cards - 2]}
    end
    if #cards >= 4 then
        for i = #cards, 4, -1 do
            if (RoomUtil.isFourBoom({cards[i], cards[i - 1], cards[i - 2], cards[i - 3]})) then
                return {cards[i], cards[i - 1], cards[i - 2], cards[i - 3]}
            end
        end
    end
    return false
end

-- 使用前提: 牌已排序, 比较牌组和自己牌组都不含炸弹牌或[四带二], 有更大的牌返回更大的牌, 没有返回false
function RoomUtil.findLargerCards(cards, cmpCardType, cmpCardNum, cmpKeyCard)
    if #cards < cmpCardNum then return false end
    if cmpCardType == RoomConst.CARD_T_SINGLE then
        for i = 1, #cards do
            if RoomUtil.compareCard(cards[i], cmpKeyCard) == 1 then return {cards[i]} end
        end
    elseif cmpCardType == RoomConst.CARD_T_PAIR then
        for i = 1, #cards - 1 do
            if RoomUtil.compareCard(cards[i], cmpKeyCard) == 1 then
                if RoomUtil.isPair({cards[i], cards[i + 1]}) then return {cards[i], cards[i + 1]} end
            end
        end
    elseif cmpCardType == RoomConst.CARD_T_THREE then
        for i = 1, #cards - 2 do
            if RoomUtil.compareCard(cards[i], cmpKeyCard) == 1 then
                if RoomUtil.isThree({cards[i], cards[i + 1], cards[i + 2]}) then return {cards[i], cards[i + 1], cards[i + 2]} end
            end
        end  
    elseif cmpCardType == RoomConst.CARD_T_THREE_ONE then
        local fCards = nil
        for i = 1, #cards - 2 do
            if RoomUtil.compareCard(cards[i], cmpKeyCard) == 1 then
                if RoomUtil.isThree({cards[i], cards[i + 1], cards[i + 2]}) then fCards = {cards[i], cards[i + 1], cards[i + 2]} end
            end
        end
        if fCards then
            for i = 1, #cards do
                if cards[i] % 16 ~= fCards[1] % 16 then
                    table.insert(fCards, cards[i])
                    break
                end
            end
            return fCards
        end
    elseif cmpCardType == RoomConst.CARD_T_THREE_TWO then
        local fCards = nil
        for i = 1, #cards - 2 do
            if RoomUtil.compareCard(cards[i], cmpKeyCard) == 1 then
                if RoomUtil.isThree({cards[i], cards[i + 1], cards[i + 2]}) then fCards = {cards[i], cards[i + 1], cards[i + 2]} end
            end
        end
        if fCards then
            for i = 1, #cards do
                if cards[i] % 16 ~= fCards[1] % 16 and cards[i] % 16 == cards[i + 1] % 16 then
                    table.insert(fCards, cards[i])
                    table.insert(fCards, cards[i + 1])
                    break
                end
            end
            return fCards
        end
    elseif cmpCardType == RoomConst.CARD_T_SEQ then
        local sCards = {}
        for i = 1, #cards do
            if RoomUtil.compareCard(cards[i], cmpKeyCard) == 1 and not isHas2OrJoker({cards[i]}) then
                if #sCards == 0 then
                    table.insert(sCards, cards[i])
                elseif sCards[#sCards] % 16 ~= cards[i] % 16 then
                    table.insert(sCards, cards[i])
                end
            end
        end
        if #sCards < cmpCardNum then return false end
        for i = 1, #sCards - (cmpCardNum - 1) do
            local testCards = {}
            for j = 0, cmpCardNum - 1 do
                table.insert(testCards, sCards[i + j])
            end
            if RoomUtil.isSeq(testCards) then
                return testCards
            end
        end
    elseif cmpCardType == RoomConst.CARD_T_TWIN_SEQ then
        local pairCards = {}
        local i = 1
        while (i <= #cards - 1) do
            if RoomUtil.compareCard(cards[i], cmpKeyCard) == 1 and not isHas2OrJoker({cards[i]})
                and cards[i] % 16 == cards[i + 1] % 16 then
                if #pairCards == 0 or (#pairCards > 0 and pairCards[#pairCards] % 16 ~= cards[i] % 16) then
                    table.insert(pairCards, cards[i])
                    table.insert(pairCards, cards[i + 1])
                    i = i + 1
                end
            end
            i = i + 1
        end
        if #pairCards < cmpCardNum then return false end
        for i = 1, #pairCards - (cmpCardNum - 2), 2 do
            local testCards = {}
            for j = 0, cmpCardNum / 2 - 1 do
                table.insert(testCards, pairCards[i + j * 2])
                table.insert(testCards, pairCards[i + j * 2 + 1])
            end
            if RoomUtil.isTwinSeq(testCards) then
                return testCards
            end
        end
    elseif cmpCardType == RoomConst.CARD_T_THREE_SEQ then
        local threeCards = {}
        local i = 1
        while (i <= #cards - 2) do
            if RoomUtil.compareCard(cards[i], cmpKeyCard) == 1 and not isHas2OrJoker({cards[i]})
                and RoomUtil.isThree({cards[i], cards[i + 1], cards[i + 2]}) then
                    table.insert(threeCards, cards[i])
                    table.insert(threeCards, cards[i + 1])
                    table.insert(threeCards, cards[i + 2])
                    i = i + 2
            end
            i = i + 1
        end
        if #threeCards < cmpCardNum then return false end
        for i = 1, #threeCards - (cmpCardNum - 3), 3 do
            local testCards = {}
            for j = 0, cmpCardNum / 3 - 1 do
                table.insert(testCards, sCards[i + j * 3])
                table.insert(testCards, sCards[i + j * 3 + 1])
                table.insert(testCards, sCards[i + j * 3 + 2])
            end
            if RoomUtil.isThreeSeq(testCards) then
                return testCards
            end
        end
    elseif cmpCardType == RoomConst.CARD_T_PLANE_ONE then
        local cmpThreeCards = {}
        local nowCard = cmpKeyCard
        local flyNum = cmpCardNum / 4 * 3
        for i = 1, flyNum do
            table.insert(cmpThreeCards, nowCard % 16)
            table.insert(cmpThreeCards, nowCard % 16 + 16)
            table.insert(cmpThreeCards, nowCard % 16 + 32)
            nowCard = nowCard + 1
        end 
        local fCards = RoomUtil.findLargerCards(cards, RoomConst.CARD_T_THREE_SEQ, #cmpThreeCards, cmpKeyCard)
        if fCards then
            local flyCards = {}
            local idx = 1
            for i = 1, #cards do
                if idx <= flyNum and (cards[i] % 16 < cmpKeyCard % 16 or cards[i] % 16 > (cmpKeyCard + flyNum - 1) % 16) then
                    table.insert(flyCards, cards[i])
                    idx = idx + 1
                end
            end
            if #flyCards ~= flyNum then return false end
            for _, card in pairs(flyCards) do
                table.insert(fCards, card)
            end
            return fCards
        end
    elseif cmpCardType == RoomConst.CARD_T_PLANE_TWO then
        local cmpThreeCards = {}
        local nowCard = cmpKeyCard
        local flyNum = cmpCardNum / 5 * 3
        for i = 1, flyNum do
            table.insert(cmpThreeCards, nowCard % 16)
            table.insert(cmpThreeCards, nowCard % 16 + 16)
            table.insert(cmpThreeCards, nowCard % 16 + 32)
            nowCard = nowCard + 1
        end
        local fCards = RoomUtil.findLargerCards(cards, RoomConst.CARD_T_THREE_SEQ, #cmpThreeCards, cmpKeyCard)
        if fCards then
            local flyPairs = {}
            local idx = 1
            local i = 1
            while (i <= #cards - 1) do
                if idx <= flyNum and (cards[i] % 16 < cmpKeyCard % 16 or cards[i] % 16 > (cmpKeyCard + flyNum - 1) % 16)
                    and (cards[i] % 16 == cards[i + 1] % 16) then
                    table.insert(flyPairs, cards[i])
                    idx = idx + 1
                    i = i + 1
                end
                i = i + 1
            end
            if #flyCards ~= flyNum * 2 then return false end
            for _, card in pairs(flyCards) do
                table.insert(fCards, card)
            end
            return fCards
        end
    end
    return false
end

function RoomUtil.promptOutCards(mCards, cmpCards)
    table.sort(mCards, function(a, b) return RoomUtil.sortCard(a, b) end)
    table.sort(cmpCards, function(a, b) return RoomUtil.sortCard(a, b) end)

    local cmpType = RoomUtil.getCardType(cmpCards)
    if cmpType == RoomConst.CARD_T_JOKER_BOOM then return false end -- 王炸快速判断

    local assumeBoom1 = RoomUtil.findLargestBoom(mCards)
    local assumeBoom2 = RoomUtil.findLargestBoom(mCards)
    if assumeBoom1 then -- 自己有炸弹牌
        if RoomUtil.vsCards(assumeBoom1, cmpCards) == 1 then return assumeBoom1 end
    elseif cmpType == RoomConst.CARD_T_FOUR_BOOM or cmpType == RoomConst.CARD_T_FOUR_TWO then -- 自己没有炸弹牌, 比较牌组为炸弹牌或[四带二], 返回false
        return false
    end

    -- 自己不含炸弹牌, 且比较牌组不是炸弹牌
    local keyCard = RoomUtil.getKeyCard(cmpType, cmpCards)
    print("keyCard, cmpType", keyCard, cmpType)
    local fCards = RoomUtil.findLargerCards(mCards, cmpType, #cmpCards, keyCard)
    dump(fCards, "fCards")
    return fCards
end

--[[ 比较牌型以及牌大小
    返回值: 1, 能比较, 且cards1大; 0, 能比较, 且大小相等; -1, 能比较, 且且cards2大;
        2, 不能比较, 含有非法牌型 3, 不能比较(牌型不一样且无炸弹), 4, 不能比较, 牌型一样但牌不一样数量
--]]
function RoomUtil.vsCards(cards1, cards2)
    local type1 = RoomUtil.getCardType(cards1)
    local type2 = RoomUtil.getCardType(cards2)
    if type1 == RoomConst.CARD_T_NONE or type2 == RoomConst.CARD_T_NONE then -- 含有非法牌型
        return 2
    end
    if type1 ~= type2 then -- 牌型不一样
        if type1 == RoomConst.CARD_T_JOKER_BOOM then return 1 end
        if type2 == RoomConst.CARD_T_JOKER_BOOM then return -1 end
        if type1 == RoomConst.CARD_T_FOUR_BOOM then return 1 end
        if type2 == RoomConst.CARD_T_FOUR_BOOM then return -1 end
        return 3 -- 牌型不一样, 且没有炸弹, 非法
    end
    if #cards1 ~= #cards2 then return 4 end
    -- 牌型相等, 且数量相同, 取关键牌比较即可
    local keyCard1 = RoomUtil.getKeyCard(type1, cards1)
    local keyCard2 = RoomUtil.getKeyCard(type2, cards2)
    return RoomUtil.compareCard(keyCard1, keyCard2)
end
-- 使用前提: 两组牌牌型相等(且牌型不为炸弹), 且数量相同 
function RoomUtil.getKeyCard(cardType, cards)
    table.sort(cards, function(a, b) return RoomUtil.sortCard(a, b) end)

    if cardType == RoomConst.CARD_T_SINGLE or cardType == RoomConst.CARD_T_PAIR
        or cardType == RoomConst.CARD_T_THREE or cardType == RoomConst.CARD_T_FOUR_BOOM
        or cardType == RoomConst.CARD_T_SEQ or cardType == RoomConst.CARD_T_TWIN_SEQ
        or cardType == RoomConst.CARD_T_THREE_SEQ then
        return cards[1]
    elseif cardType == RoomConst.CARD_T_THREE_ONE or cardType == RoomConst.CARD_T_THREE_TWO then
        if (RoomUtil.isThree({cards[1], cards[2], cards[3]})) then
            return cards[1]
        else
            return cards[#cards]
        end
    elseif RoomUtil.isFourTwo(cards) then
        for i = 1, 3 do -- 注意不要越界
            if (RoomUtil.isFourBoom({cards[i], cards[i + 1], cards[i + 2], cards[i + 3]})) then
                return cards[i]
            end
        end
    elseif cardType == RoomConst.CARD_T_PLANE_ONE then
        return RoomUtil.getPlaneOneKeyCard(cards)
    elseif cardType == RoomConst.CARD_T_PLANE_TWO then
        return RoomUtil.getPlaneTwoKeyCard(cards)
    end
end

-- 使用前提: 牌型已经为飞机带单牌组
function RoomUtil.getPlaneOneKeyCard(cards)
    table.sort(cards, function(a, b) return RoomUtil.sortCard(a, b) end)
    local threeCardTags = {}
    local i = 1
    while (i <= #cards) do
        if i < #cards - 1 and RoomUtil.isThree({cards[i], cards[i + 1], cards[i + 2]}) then
            table.insert(threeCardTags, cards[i])
            i = i + 3
        else
            i = i + 1
        end
    end
    if #threeCardTags == cards / 4 then
        return threeCardTags[1]
    elseif #threeCardTags > cards / 4 then
        if canMapPlaneSeq(threeCardTags, 1, #threeCardTags - 1) then
            return threeCardTags[1]
        end
        if canMapPlaneSeq(threeCardTags, 2, #threeCardTags) then
            return threeCardTags[2]
        end
    end
end

-- 使用前提: 牌型已经为飞机带对牌组
function RoomUtil.getPlaneTwoKeyCard(cards)
    table.sort(cards, function(a, b) return RoomUtil.sortCard(a, b) end)
    local threeCardTags = {}
    local i = 1
    while (i < #cards) do
        if i < #cards - 1 and RoomUtil.isThree({cards[i], cards[i + 1], cards[i + 2]}) then -- 注意不要越界
            table.insert(threeCardTags, cards[i])
            i = i + 3
        elseif RoomUtil.isPair({cards[i], cards[i + 1]}) then
            i = i + 2
        end
    end
    if #threeCardTags == cards / 5 then
        return threeCardTags[1]
    elseif #threeCardTags > cards / 5 then
        if canMapPlaneSeq(threeCardTags, 1, #threeCardTags - 1) then
            return threeCardTags[1]
        end
        if canMapPlaneSeq(threeCardTags, 2, #threeCardTags) then
            return threeCardTags[2]
        end
    end
end

function RoomUtil.formatCards(cardType, cards)
    table.sort(cards, function(a, b) return RoomUtil.sortCard(a, b) end)

    if cardType == RoomConst.CARD_T_THREE_ONE or cardType == RoomConst.CARD_T_THREE_TWO then
        if (not RoomUtil.isThree({cards[1], cards[2], cards[3]})) then
            for i = 1, #cards - 3 do
                local card = table.remove(cards, 1)
                table.insert(cards, card)
            end
        end
    elseif cardType == RoomConst.CARD_T_FOUR_TWO then
        local startIdx = -1
        for i = 1, 3 do -- 注意不要越界
            if (RoomUtil.isFourBoom({cards[i], cards[i + 1], cards[i + 2], cards[i + 3]})) then
                startIdx = i
                break
            end
        end
        for i = 1, startIdx - 1 do
            local card = table.remove(cards, 1)
            table.insert(cards, card)
        end
    elseif cardType == RoomConst.CARD_T_PLANE_ONE then
        local kCard = RoomUtil.getPlaneOneKeyCard(cards)
        local planeLength = #cards / 4
        local rfCards = {}
        for i = 1, #cards do
            if (kCard % 16 <= cards[i] % 16 and cards[i] % 16 <= kCard % 16 + planeLength - 1) then
                table.insert(rfCards, cards[i])
            end
        end
        for i = 1, #cards do
            if not (kCard % 16 <= cards[i] % 16 and cards[i] % 16 <= kCard % 16 + planeLength - 1) then
                table.insert(rfCards, cards[i])
            end
        end
        return rfCards
    elseif cardType == RoomConst.CARD_T_PLANE_TWO then
        local kCard = RoomUtil.getPlaneTwoKeyCard(cards)
        local planeLength = #cards / 5
        local rfCards = {}
        for i = 1, #cards do
            if (kCard % 16 <= cards[i] % 16 and cards[i] % 16 <= kCard % 16 + planeLength - 1) then
                table.insert(rfCards, cards[i])
            end
        end
        for i = 1, #cards do
            if not (kCard % 16 <= cards[i] % 16 and cards[i] % 16 <= kCard % 16 + planeLength - 1) then
                table.insert(rfCards, cards[i])
            end
        end
        return rfCards
    end

    return cards
end

function RoomUtil.addCards(cards, addCards)
    for i = 1, #addCards do
        table.insert(cards, addCards[i])
    end
    return cards
end

function RoomUtil.minusCards(cards, deleteCards)
    table.sort(cards, function(a, b) return RoomUtil.sortCard(a, b) end)
    table.sort(deleteCards, function(a, b) return RoomUtil.sortCard(a, b) end)
    
    local moveA = #deleteCards
    local moveB = #cards
    local backUpCards = {}
    for _, card in pairs(cards) do table.insert(backUpCards, card) end
    for i = moveA, 1, -1 do
        local toDeleteCard = deleteCards[i];
        local isFound = false
        for j = moveB, 1, -1 do
            if (toDeleteCard == cards[j]) then
                isFound = true
                table.remove(cards, j)
                moveB = j - 1
                break
            end
        end
        if (not isFound) then
            cards = backUpCards
            return nil
        end
    end
    return cards
end

return RoomUtil

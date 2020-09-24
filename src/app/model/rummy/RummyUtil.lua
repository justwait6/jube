-- Author: Jam
-- Date: 2020.04.14
local funplaypoker = "没有用处，代码混淆用"

local RummyUtil = class("RummyUtil")
local roomInfo = require("app.model.rummy.RoomInfo").getInstance()
local RummyConst = require("app.model.rummy.RummyConst")
--我移位后的座位
function RummyUtil.getFixSeatId(seatId)
     if roomInfo:getMSeatId() < 0 then --我是站起的
          return seatId
     end
     local fixSeatId = RummyConst.MSeatId + (seatId - roomInfo:getMSeatId())
     if fixSeatId > RummyConst.UserNum - 1 then 
         fixSeatId = fixSeatId - RummyConst.UserNum
     elseif fixSeatId < 0 then
         fixSeatId = fixSeatId + RummyConst.UserNum
     end
     return fixSeatId
end
-- function RummyUtil.getCoinTextures(bet)
-- 		local chipRes = "#roomchip_chip.png"
-- 		if app.gameId >= 10000 then
-- 			chipRes = "#roomchip_gold.png"
-- 		end

--     local node = {}
-- 		local smallBet = roomInfo:getSmallBet()
-- 		local MAX_COIN = 5
-- 		local coin_num = math.ceil(tonumber(bet) / smallBet)
-- 		if coin_num > MAX_COIN then
-- 			coin_num = MAX_COIN
-- 		end
-- 		for i = 1, coin_num do
-- 			table.insert(node, display.newSprite(chipRes))
-- 		end
-- 		return node
-- end
function RummyUtil.refreshGroupsBySort()
    local mCards = roomInfo:getMCards()
    local VARIETY_DIAMOND = 0 -- 方块
    local VARIETY_CLUB    = 1 -- 梅花
    local VARIETY_HEART   = 2 -- 红桃
    local VARIETY_SPADE   = 3 -- 黑桃
    local VARIETY_JOKER   = 4 -- Joker牌

    local function getValue(cardUint)
        return cardUint % 16
    end

    local function getVariety(cardUint)
        return bit.brshift(tonumber(cardUint),4);
    end

    local groups = {}
    for i = 1, #mCards do
        local variety = getVariety(mCards[i])
        groups[variety + 1] = groups[variety + 1] or {}
        table.insert(groups[variety + 1], i)
    end
    for _, group in pairs(groups) do
        table.sort(group, function(a, b) return mCards[a] < mCards[b] end)
    end
    -- 有可能是不以1为索引开头的group(例如牌缺方块), 重排列(变为以1索引开头的)
    -- dump(groups, "vgg groups befor sort", #groups)
    local idx = 0
    local modGroups = {}
    for i, group in pairs(groups) do
        idx = idx + 1
        modGroups[idx] = group
    end
    -- dump(modGroups, "vgg resort")
    roomInfo:setCurGroups(modGroups)
    
    return true
end
function RummyUtil.calcMCardsByReconnect(svrGroups, pos)
    local cards = {}
    for _, group in pairs(svrGroups) do
        if #group > 0 then
            for j = 1, #group do
                table.insert(cards, group[j])
            end
        end
    end
    if #cards >= RummyConst.DRAW_CARD_ID then -- 有新摸牌
        local drawCardPos = RummyConst.DRAW_CARD_ID
        if pos > 0 then 
            drawCardPos = pos
        end
        local cardUint = table.remove(cards, drawCardPos) --新摸牌放最后
        table.insert(cards, cardUint)
    end
    dump(cards, "cards resort")
    return cards
end
function RummyUtil.refreshGroupsByReconnect(svrGroups, pos)
    local groups = {}
    local abMCards = clone(roomInfo:getMCards() or {})
    if #abMCards <= 0 then return false end -- 没牌
    local drawCardPos = RummyConst.DRAW_CARD_ID
    if roomInfo:isInSelfDiscardStage() then
        if pos > 0 then 
            drawCardPos = pos
        end
    end

    local curIdx = 0
    for i, groupCards in pairs(svrGroups) do
        if #groupCards > 0 then
            groups[i] = {}
            for j = 1, #groupCards do
                curIdx = curIdx + 1
                if curIdx < drawCardPos then
                    table.insert(groups[i], curIdx)
                elseif curIdx == drawCardPos then
                    table.insert(groups[i], RummyConst.DRAW_CARD_ID)
                elseif curIdx > drawCardPos then
                    table.insert(groups[i], curIdx - 1)
                end
            end
        end
    end
    -- svr group index数据不按次序来, 需要重排列
    local idx = 0
    local modGroups = {}
    for i, group in pairs(groups) do
        idx = idx + 1
        modGroups[idx] = group
    end
    dump(modGroups, "svrGroups resort")
    roomInfo:setCurGroups(modGroups)
    return true
end
function RummyUtil.refreshGroupsByDraw(drawCard)
    -- 新摸牌id为RummyConst.DRAW_CARD_ID(弃牌后, id变为出牌id)
    local operGroups = roomInfo:getCurGroups()
    if #operGroups == 1 or #operGroups >= RummyConst.MAX_GROUP_NUM then -- 只有一堆牌, 或者牌堆达到最大限制, 新摸牌放到最后牌堆
        for _, group in pairs(operGroups) do
            if _ == #operGroups then
                table.insert(group, RummyConst.DRAW_CARD_ID)
            end
        end
    else -- 牌堆没有达到最大限制, 新建牌堆放新摸的牌
        table.insert(operGroups, {RummyConst.DRAW_CARD_ID})
    end
end
function RummyUtil.refreshGroupsByDiscard(cardIdx)
    print("card,. cardIdx", string.format("%x", cardIdx))
    local operGroups = roomInfo:getCurGroups()
    local flag = false
    for gIdx, group in pairs(operGroups) do
        for curIdx = 1, #group do
            if group[curIdx] == cardIdx then
                if #group > 1 then -- 该组大于一项, 删除该组的选中项
                    table.remove(group, curIdx)
                else -- 该组只有这一项,  删除该组
                    table.remove(operGroups, gIdx)
                end
                flag = true
                break
            end
        end
        if flag then break end
    end
    if cardIdx ~= RummyConst.DRAW_CARD_ID then -- 弃牌不为新摸的牌, 需要将弃牌idx变为摸牌idx
        for gIdx, group in pairs(operGroups) do
            for curIdx = 1, #group do
                if group[curIdx] == RummyConst.DRAW_CARD_ID then
                    group[curIdx] = cardIdx
                    break
                end
            end
        end
    end
    if flag then
        roomInfo:setCurGroups(operGroups)
    end
end
function RummyUtil.refreshGroupsByGroup(chooseCards)
    local bkupGroups = clone(roomInfo:getCurGroups())
    local operGroups = roomInfo:getCurGroups()
    -- 删掉选中的idxs
    for i = 1, #chooseCards do
        local flag = false
        local toDel = chooseCards[i]
        for gIdx, group in pairs(operGroups) do
            for curIdx = 1, #group do
                if group[curIdx] == toDel then
                    if #group > 1 then -- 该组大于一项, 删除该组的选中项
                        table.remove(group, curIdx)
                    else -- 该组只有这一项,  删除该组
                        table.remove(operGroups, gIdx)
                    end
                    flag = true
                    break
                end
            end
            if flag then break end
        end
    end
    -- 新添加选中idxs到group最后一项
    local mCards = roomInfo:getMCards()
    table.sort(chooseCards, function(a, b) return mCards[a] < mCards[b] end)
    table.insert(operGroups, chooseCards)
    if #operGroups > RummyConst.MAX_GROUP_NUM then
        g.myUi.topTip:showText("达到最大Group限制")
        roomInfo:setCurGroups(bkupGroups) -- 更新group项
        return false
    end
    roomInfo:setCurGroups(operGroups) -- 更新group项
    return true
end
function RummyUtil.refreshGroupsByMove(fromIndex, toIndex, frontBack) -- front, 0; back, 1
    if fromIndex == toIndex then return true end
    
    local operGroups = roomInfo:getCurGroups()
    local moveTag = -1
    local curIndex = 0
    local removeSucc = false
    for gIdx, group in pairs(operGroups) do
        for i = 1, #group do
            curIndex = curIndex + 1
            if fromIndex == curIndex then
                moveTag = group[i]
                if #group > 1 then -- 该组大于一项, 删除该组的选中项
                    table.remove(group, i)
                else -- 该组只有这一项,  删除该组
                    table.remove(operGroups, gIdx)
                end
                removeSucc = true
                break
            end
        end
        if removeSucc then break end
    end
    
    local flag = false
    if not removeSucc then return false end -- 移除不成功, 返回false
    if toIndex > fromIndex then toIndex = toIndex - 1 end -- 由于moveTag被移除, toIndex要减1
    local curIndex = 0
    local insertSucc = false
    for gIdx, group in pairs(operGroups) do
        for i = 1, #group do
            curIndex = curIndex + 1
            if toIndex == curIndex then
                if frontBack == 0 then -- 插在前面
                    table.insert(group, i, moveTag)
                else -- 插在后面
                    table.insert(group, i + 1, moveTag)
                end
                insertSucc = true
                break
            end
        end
        if insertSucc then break end
    end
    if not insertSucc then return false end -- 插入不成功, 返回false
    
    roomInfo:setCurGroups(operGroups) -- 更新group项
    return true
end
function RummyUtil.isMagicCard(cardUint)
    local originMagic = roomInfo:getMagicCard() or -1

    if originMagic == RummyConst.JOKER then -- Joker是魔法牌, Ace作魔法牌
        return cardUint == RummyConst.JOKER or cardUint % 16 == 0x0e
    else
        return cardUint ~= RummyConst.JOKER and cardUint % 16 == originMagic % 16 and originMagic ~= -1
    end
end
function RummyUtil.getCardScore(cardUint)
    local cardScore = 0

    local cardValue = cardUint % 16
    if cardUint == RummyConst.JOKER then -- Joker牌
        cardScore = 0
    elseif RummyUtil.isMagicCard(cardUint) then -- 万能牌
        cardScore = 0
    elseif cardValue >= 11 then -- J, Q, K, A
        cardScore = 10
    elseif 2 <= cardValue and cardValue <= 10 then -- 2-10分数为本身
        cardScore = cardValue
    end

    return cardScore
end
-- 使用前提, group牌大于2张
function RummyUtil.isPureSequence(group)
    local firstVariety = -1
    local mCards = roomInfo:getMCards()
    
    -- 有Joker牌, 不能组成纯顺子(可以有魔法牌, 魔法牌当普通牌)
    for _, cardIdx in pairs(group) do
        if mCards[cardIdx] == RummyConst.JOKER then
            return false
        end
    end

    -- 判断同花色
    for _, cardIdx in pairs(group) do
        local curVariety = bit.brshift(tonumber(mCards[cardIdx]),4)
        if firstVariety == -1 then
            firstVariety = curVariety
        elseif firstVariety ~= curVariety then
            return false
        end
    end

    -- 判断能连成顺子
    local values = {}
    local hasAce = false
    local hasKing = false
    for _, cardIdx in pairs(group) do
        local value = tonumber(mCards[cardIdx]) % 16
        table.insert(values, value)
        if value == 14 then
            hasAce = true
        elseif value == 13 then
            hasKing = true
        end
    end
    table.sort(values, function(a, b) return a < b end)
    if (hasAce and not hasKing)  then -- 有Ace牌, 没King牌: Ace牌能连成[A, 2, 3, ...]
        if values[1] ~= 2 then -- 首张牌不是2, 不能练成顺子
            return false
        end
        for i = 1, #values - 2 do
            if values[i] ~= values[i + 1] - 1 then -- 前 n - 1 张牌不顺序递增, 不能连成顺子
                return false
            end
        end
    else -- (情形1)无Ace牌, (情形2)有Ace牌和King牌: 不能连成[A, 2, 3, ...]
        for i = 1, #values - 1 do
            if values[i] ~= values[i + 1] - 1 then -- 前 n 张牌不顺序递增, 不能连成顺子
                return false
            end
        end
    end

    return true
end
-- 使用前提, group牌大于2张
function RummyUtil.isSequence(group) -- 是顺子, 且不是纯顺子
    if #group > 13 then -- 大于13张牌, 不能组成顺子
        return false
    end
    local mCards = roomInfo:getMCards()
    local variableCardNum = 0
    local commonCards = {}
    for _, cardIdx in pairs(group) do
        if mCards[cardIdx] == RummyConst.JOKER or RummyUtil.isMagicCard(mCards[cardIdx]) then
            variableCardNum = variableCardNum + 1
        else
            table.insert(commonCards, mCards[cardIdx])
        end
    end
    if variableCardNum <= 0 then -- 没有Joker牌或魔法牌, 不能组成顺子
        return false
    end
    if #commonCards <= 0 then -- 没有普通牌, 能组成顺子
        return true
    elseif #commonCards == 1 then -- 只有一张普通牌, 函数前提传入3张以上牌, 意味着两张以上可变牌, 能组成顺子
        return true
    end

    -- 下面的逻辑, #commonCards > 1
    -- 判断普通牌是否同花色
    local firstVariety = -1
    for _, card in pairs(commonCards) do
        local curVariety = bit.brshift(tonumber(card),4)
        if firstVariety == -1 then
            firstVariety = curVariety
        elseif firstVariety ~= curVariety then
            return false
        end
    end

    -- 判断是否有相同的牌
    table.sort(commonCards, function(a, b) return a < b end)
    for i = 1, #commonCards - 1 do
        if commonCards[i] == commonCards[i + 1] then
            return false
        end
    end

    -- 获取同花色牌点数集合
    local values = {}
    local hasAce = false
    local hasKing = false
    for _, card in pairs(commonCards) do
        local value = tonumber(card) % 16
        table.insert(values, value)
        if value == 14 then
            hasAce = true
        elseif value == 13 then
            hasKing = true
        end
    end
    -- 组成顺子需要的可变牌数量
    table.sort(values, function(a, b) return a < b end)
    if hasKing then -- 有King牌, 不能组成含A开头的顺子
        return (values[#values] - values[1] + 1) - #values <= variableCardNum -- 首尾两张牌夹着的空缺牌, 小于等于可变牌, 可组成, 否则不可组成
    elseif not hasAce then -- 无King, 无Ace
        return (values[#values] - values[1] + 1) - #values <= variableCardNum
    else -- 无King牌有Ace牌, [A, 2, ...]和[..., K, A]作比较
        local candidate1 = (values[#values - 1] - 1 + 1) - #values
        local candidate2 = (values[#values] - values[1] + 1) - #values -- 减去的1表示减去Ace牌(当作1)牌值
        return math.min(candidate1, candidate2) <= variableCardNum
    end
end
-- 使用前提, group牌大于2张
function RummyUtil.isCardTypeSet(group) -- 判断是否是条
    if #group > 4 then -- 大于4张牌, 不能组成条
        return false
    end
    local mCards = roomInfo:getMCards()
    local variableCardNum = 0
    local commonCards = {}
    for _, cardIdx in pairs(group) do
        if mCards[cardIdx] == RummyConst.JOKER or RummyUtil.isMagicCard(mCards[cardIdx]) then
            variableCardNum = variableCardNum + 1
        else
            table.insert(commonCards, mCards[cardIdx])
        end
    end
    if #commonCards <= 0 then -- 没有普通牌, 不能组成条
        return false
    elseif #commonCards == 1 then -- 只有一张普通牌, 函数前提传入3张以上牌, 意味着两张以上可变牌, 能组成条
        return true
    end

    -- 下面的逻辑, #commonCards > 1, 也即#values > 1
    -- 判断是否有相同的普通牌, 含有相同的普通牌不能组成条(条定义: 值相同, 且里不能含有相同花色的牌)
    table.sort(commonCards, function(a, b) return a < b end)
    for i = 1, #commonCards - 1 do
        if commonCards[i] == commonCards[i + 1] then
            return false
        end
    end
    local values = {}
    for _, card in pairs(commonCards) do
        local value = tonumber(card) % 16
        table.insert(values, value)
    end
    -- 判断普通牌value值是否相同
    for i = 1, #values - 1 do
        if values[i] ~= values[i + 1] then
            return false
        end
    end

    return true
end
function RummyUtil.getGroupConfs(inspectGroups)
    local confs = {}
    local mCards = roomInfo:getMCards()
    for i, group in pairs(inspectGroups) do
        confs[i] = confs[i] or {}
        confs[i].point = 0
        confs[i].cardType = RummyUtil.getGroupCardType(group)
        confs[i].cardNum = #group
        for _, cardIdx in pairs(group) do
            confs[i].point = confs[i].point + RummyUtil.getCardScore(mCards[cardIdx])
        end
        if confs[i].point > RummyConst.MAX_SCORE then -- 最大分数
            confs[i].point = RummyConst.MAX_SCORE
        end
    end

    local isHasPureSequence = false
    local sequenceCount = 0
    for i, conf in pairs(confs) do
        if conf.cardType == RummyConst.STRAIGHT_FLUSH then
            isHasPureSequence = true
        end
        if conf.cardType == RummyConst.STRAIGHT_FLUSH or conf.cardType == RummyConst.STRAIGHT then
            sequenceCount = sequenceCount + 1
        end
    end

    for i, conf in pairs(confs) do
        conf.isValid = false
        if conf.cardType == RummyConst.STRAIGHT_FLUSH then
            conf.isValid = true
            conf.point = 0
        elseif conf.cardType == RummyConst.STRAIGHT then
            if isHasPureSequence then
                conf.isValid = true
                conf.point = 0
            end
        elseif conf.cardType == RummyConst.SANGONG then
            if isHasPureSequence and sequenceCount >= 2 then
                conf.isValid = true
                conf.point = 0
            end
        end
    end
    return confs
end
-- 使用前提, group牌大于2张
function RummyUtil.getGroupCardType(group)
    local cardType = RummyConst.OTHERS
    local mCards = roomInfo:getMCards()
    if #group <= 2 then
        cardType = RummyConst.OTHERS
    elseif RummyUtil.isPureSequence(group) then -- 纯顺子
        cardType = RummyConst.STRAIGHT_FLUSH
    elseif RummyUtil.isSequence(group) then -- 顺子
        cardType = RummyConst.STRAIGHT
    elseif RummyUtil.isCardTypeSet(group) then -- 条
        cardType = RummyConst.SANGONG
    end
    return cardType
end
function RummyUtil.isGroupsEqual(groups1, groups2)
    print(table.nums(groups1))
    print(table.nums(groups2))
    if table.nums(groups1) ~= table.nums(groups2) then
        return false
    end
    for i = 1, #groups1 do
        local g1 = groups1[i]
        local g2 = groups2[i]
        if type(g1) ~= "table" or type(g2) ~= "table" then
            return false
        end
        if table.nums(g1) ~= table.nums(g2) then
            return false
        end

        for j = 1, #g1 do
            if g1[j] ~= g2[j] then
                return false
            end
        end
    end

    return true
end
function RummyUtil.getArrayFormOfCurGroups()
    local groups = roomInfo:getCurGroups()
    local array = {}
    local curIndex = 0
    for _, group in pairs(groups) do
        for i = 1, #group do
            curIndex = curIndex + 1
            array[curIndex] = group[i]
        end
    end
    return array
end
local CARD_GAP = 40
local PILE_GAP = 146
local CARD_WIDTH = 120
function RummyUtil.getCardGap()
    return CARD_GAP
end
function RummyUtil.getRelativePosXList(groups)
    local posXList = {}
    local cardsCnt = 0
    for _, group in pairs(groups) do
        cardsCnt = cardsCnt + #group
    end
    local curX = 0
    for _, group in pairs(groups) do
        for j = 1, #group do
            table.insert(posXList, curX)
            curX = curX + CARD_GAP
        end
        curX = curX + PILE_GAP - CARD_GAP
    end
    return posXList
end
-- 关于组点数和牌型信息的位置x列表
function RummyUtil.getGroupTipRelativePosXList(groups)
    local posXList = {}
    local cardsCnt = 0
    for _, group in pairs(groups) do
        cardsCnt = cardsCnt + #group
    end
    local curX = 0
    for _, group in pairs(groups) do
        table.insert(posXList, curX + ((#group - 1) * CARD_GAP)/2)
        curX = curX + (#group - 1) * CARD_GAP
        curX = curX + PILE_GAP
    end
    return posXList
end
return RummyUtil

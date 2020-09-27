local DropCardsView = class("DropCardsView", g.myUi.Window)

DropCardsView.WIDTH = 712
DropCardsView.HEIGHT = 418

local mResDir = "image/rummy/dropcardsview/" -- module resource directory
local roomInfo = require("app.model.rummy.RoomInfo").getInstance()

local VARIETY_DIAMOND = 0 -- 方块
local VARIETY_CLUB    = 1 -- 梅花
local VARIETY_HEART   = 2 -- 红桃
local VARIETY_SPADE   = 3 -- 黑桃
local VARIETY_JOKER   = 4 -- Joker牌(目前只有一张, server定义是0x4f)

function DropCardsView:ctor(pack)
	DropCardsView.super.ctor(self, {width = self.WIDTH, height = self.HEIGHT, bgRes = mResDir .. "bg.png", isCoverClose = true})

    -- Close Btn
    local closeBtn = g.myUi.ScaleButton.new({normal = g.Res.blank})
        :onClick(handler(self, self.close))
        :addTo(self)
        :pos(self.WIDTH / 2 - 37, 0)
        :setSwallowTouches(false)
        :setButtonSize(cc.size(70, 70))
    display.newSprite(mResDir .. "close.png"):pos(closeBtn:getContentSize().width/2, closeBtn:getContentSize().height/2):addTo(closeBtn)

    display.newSprite(mResDir .. "icon_1.png")
        :pos(-310, 150)
        :addTo(self)

    display.newSprite(mResDir .. "icon_2.png")
        :pos(-310, 150 - 100)
        :addTo(self)

    display.newSprite(mResDir .. "icon_3.png")
        :pos(-310, 150 - 200)
        :addTo(self)

    display.newSprite(mResDir .. "icon_4.png")
        :pos(-310, 150 - 300)
        :addTo(self)

    self.node = display.newNode():addTo(self)

    if DEBUG > 0 then
        dump(pack)
    end
    if pack and pack.cards then
        self:updateData(pack.cards)
    end
    -- self:updateData({41, 19, 42, 43, 56, 62, 54, 28, 24, 30, 27, 62, 21, 46, 40, 40, 56, 45, 61, 59, 44, 5, 30})
end

function DropCardsView:updateData(cards)
    local originMagic = roomInfo:getMagicCard() or -1
    if cards then
        local diamond = {}
        local club = {}
        local heart = {}
        local spade = {}
        for i=1,#cards do
            local variety = self:getVariety(cards[i])
            if variety == VARIETY_DIAMOND then
                table.insert(diamond, cards[i])
            elseif variety == VARIETY_CLUB then
                table.insert(club, cards[i])
            elseif variety == VARIETY_HEART then
                table.insert(heart, cards[i])
            elseif variety == VARIETY_SPADE then
                table.insert(spade, cards[i])
            end
        end
        if #diamond > 0 then
            table.sort(diamond, function(a,b)
                    return a < b
                end)
            self:calValue(diamond, -310, 150, originMagic)
        end
        if #club > 0 then
            table.sort(club, function(a,b)
                    return a < b
                end)
            self:calValue(club, -310, 150 - 100, originMagic)
        end
        if #heart > 0 then
            table.sort(heart, function(a,b)
                    return a < b
                end)
            self:calValue(heart, -310, 150 - 200, originMagic)
        end
        if #spade > 0 then
            table.sort(spade, function(a,b)
                    return a < b
                end)
            self:calValue(spade, -310, 150 - 300, originMagic)
        end 
    end
end

function DropCardsView:calValue(cards, x, y, originMagic)
    -- body
    local card1 = {}
    local card2 = {}
    table.insert(card1, cards[1])
    if #cards > 1 then
        for i=2,#cards do
            if cards[i - 1] == cards[i] then
                table.insert(card2, cards[i])
            else
                table.insert(card1, cards[i])
            end
        end
    end
    for i=1,#card1 do
        local value = self:getValue(card1[i])
        self:addCard(value, i, x, y, 20, originMagic)
    end
    if #card2 > 0 then
        for i=1,#card2 do
            local value = self:getValue(card2[i])
            self:addCard(value, i, x, y, -20, originMagic)
        end
    end
end

function DropCardsView:addCard(value, index, x, y, moveY, originMagic)
    -- body
    local originMagicvalue
    if originMagic and originMagic > 0 then
        originMagicvalue = self:getValue(originMagic)
        if originMagicvalue == value then
            display.newSprite(mResDir .. "circle.png")
                :pos(x + index * 43 + 7, y + moveY)
                :addTo(self)
        end
    end
    display.newSprite(mResDir .. "card_" .. value .. ".png")
        :pos(x + index * 43 + 7, y + moveY)
        :addTo(self)
end

function DropCardsView:getValue(cardUint)
    return cardUint % 16
end

function DropCardsView:getVariety(cardUint)
    return bit.brshift(tonumber(cardUint),4);
end

function DropCardsView:onClearPopup()
    PushCenter.removeListenersByTag(self)
end

return DropCardsView

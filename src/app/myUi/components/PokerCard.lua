-- Author: Jam
-- Date: 2020.04.14
local funplaypoker = "没有用处，代码混淆用"

local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

local CARD_WIDTH    = 120
local CARD_HEIGHT   = 152

local VARIETY_DIAMOND = 0 -- 方块
local VARIETY_CLUB    = 1 -- 梅花
local VARIETY_HEART   = 2 -- 红桃
local VARIETY_SPADE   = 3 -- 黑桃
local VARIETY_JOKER   = 4 -- Joker牌(0x4e小王; 0x4f大王)
local SMALL_JOKER     = 0x4e -- 小Joker牌
local BIG_JOKER       = 0x4f -- 大Joker牌

local function getValue(cardUint)
    return cardUint % 16
end

local function getVariety(cardUint)
    return bit.brshift(tonumber(cardUint),4);
end

local getFrame = display.newSpriteFrame

local PokerCard = class("PokerCard", function()
    return display.newNode()
end)

function PokerCard:ctor()
    -- 初始数值
    self.cardUint_ = 0x2e
    self.cardValue_ = 14
    self.cardVariety_ = 2
    self.isBack_ = true
    
    -- 初始化batch node
    self.frontBatch_ = display.newBatchNode("textures/pokers.png"):pos(0, 0)
    self.frontBatch_:retain()

    -- 牌背
    self.backBg_ = display.newSprite("#back_bg.png")
        -- :pos(0, 0)
    self.backBg_:setScaleX(-1)
    self.backBg_:retain()

    -- 前背景
    self.frontBg_ = display.newSprite("#front_bg.png")
    if self.frontBg_ then
        self.frontBg_:addTo(self.frontBatch_)
    else
        self.frontBg_ = display.newSprite("#poker_dark.png"):addTo(self.frontBatch_)
    end
    -- 大花色
    self.bigVarietySpr_ = display.newSprite("#big_heart.png"):pos(10,-22):addTo(self.frontBatch_)

    -- 小花色
    self.smallVarietySpr_ = display.newSprite("#small_heart.png"):pos(-38, 30):addTo(self.frontBatch_)

    -- 数字
    self.numberSpr_ = display.newSprite("#red_14.png"):pos(-38, 56):addTo(self.frontBatch_)
    self.jokerSpr_ = display.newSprite("#red_joker.png"):pos(-38, 26):addTo(self.frontBatch_):hide()
    self.magicSpr_ = display.newSprite("#magic.png"):pos(-38, -40):addTo(self.frontBatch_):hide()

    -- 帧事件
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.onEnterFrame))

    -- 打开node event
    self:setNodeEventEnabled(true) 
end

function PokerCard:setMagicVisible(isVisible)
    if isVisible then
        self.magicSpr_:show() 
    else
        self.magicSpr_:hide() 
    end
    return self
end

function PokerCard:setMagicPos(vPos)
    self.magicSpr_:pos(vPos.x, vPos.y) 
end
function PokerCard:showDark()
    
    -- self.dark:show()

    if not self.halfTrans_ then
        self.halfTrans_ = display.newSprite("#poker_dark.png")
    end
    if not self.halfTrans_:getParent() then
        self.halfTrans_:addTo(self.frontBatch_)--:pos(2, -2)
    end
    return self
end

function PokerCard:hideDark()
    -- self.dark:hide()
    if self.halfTrans_ then
        self.halfTrans_:removeFromParent()
        self.halfTrans_ = nil
    end
end

-- 设置扑克牌面
function PokerCard:setCard(cardUint)
    if self.cardUint_ == cardUint then
        return self
    end
    self.cardUint_ = cardUint

    -- 获取值与花色
    self.cardValue_ = getValue(cardUint)
    self.cardVariety_ = getVariety(cardUint)

    -- 设置纹理
    if self.cardVariety_ == VARIETY_DIAMOND then
        self.smallVarietySpr_:setSpriteFrame(getFrame("small_diamond.png"))
        self.numberSpr_:setSpriteFrame(getFrame("red_" .. self.cardValue_ .. ".png"))
        self.bigVarietySpr_:setSpriteFrame(getFrame("big_diamond.png"))
        -- if self.cardValue_ > 10 and self.cardValue_ < 14 then
        --     self.bigVarietySpr_:setSpriteFrame(getFrame("character_red_" .. self.cardValue_ ..".png"))
        -- else
        --     self.bigVarietySpr_:setSpriteFrame(getFrame("big_diamond.png"))
        -- end
    elseif self.cardVariety_ == VARIETY_HEART then
        self.smallVarietySpr_:setSpriteFrame(getFrame("small_heart.png"))
        self.numberSpr_:setSpriteFrame(getFrame("red_" .. self.cardValue_ .. ".png"))
        self.bigVarietySpr_:setSpriteFrame(getFrame("big_heart.png"))
        -- if self.cardValue_ > 10 and self.cardValue_ < 14 then
        --     self.bigVarietySpr_:setSpriteFrame(getFrame("character_red_" .. self.cardValue_ ..".png"))
        -- else
        --     self.bigVarietySpr_:setSpriteFrame(getFrame("big_heart.png"))
        -- end
    elseif self.cardVariety_ == VARIETY_CLUB then
        self.smallVarietySpr_:setSpriteFrame(getFrame("small_club.png"))
        self.numberSpr_:setSpriteFrame(getFrame("black_" .. self.cardValue_ .. ".png"))
        self.bigVarietySpr_:setSpriteFrame(getFrame("big_club.png"))
        -- if self.cardValue_ > 10 and self.cardValue_ < 14 then
        --     self.bigVarietySpr_:setSpriteFrame(getFrame("character_black_" .. self.cardValue_ ..".png"))
        -- else
        --     self.bigVarietySpr_:setSpriteFrame(getFrame("big_club.png"))
        -- end
    elseif self.cardVariety_ == VARIETY_SPADE then
        self.smallVarietySpr_:setSpriteFrame(getFrame("small_spade.png"))
        self.numberSpr_:setSpriteFrame(getFrame("black_" .. self.cardValue_ .. ".png"))
        self.bigVarietySpr_:setSpriteFrame(getFrame("big_spade.png"))
        -- if self.cardValue_ > 10 and self.cardValue_ < 14 then
        --     self.bigVarietySpr_:setSpriteFrame(getFrame("character_black_" .. self.cardValue_ ..".png"))
        -- else
        --     self.bigVarietySpr_:setSpriteFrame(getFrame("big_spade.png"))
        -- end
    elseif self.cardVariety_ == VARIETY_JOKER then
        self.numberSpr_:hide()
        self.smallVarietySpr_:hide()
        if cardUint == SMALL_JOKER then
            self.bigVarietySpr_:setSpriteFrame(getFrame("character_black_joker.png"))
            self.jokerSpr_:setSpriteFrame(getFrame("black_joker.png"))
        elseif cardUint == BIG_JOKER then
            self.bigVarietySpr_:setSpriteFrame(getFrame("character_red_joker.png"))
            self.jokerSpr_:setSpriteFrame(getFrame("red_joker.png"))
        end
        self.jokerSpr_:show()
    end
    if self.cardVariety_ ~= VARIETY_JOKER then
        self.numberSpr_:show()
        self.smallVarietySpr_:show()
        self.jokerSpr_:hide()
    end
    local bigVarietySize = self.bigVarietySpr_:getContentSize()
    self.bigVarietySpr_:pos(CARD_WIDTH * 0.5 - bigVarietySize.width * 0.5 - 10, bigVarietySize.height * 0.5 - CARD_HEIGHT * 0.5 + 14)
    return self
end

function PokerCard:getCard()
    return self.cardUint_
end

-- 翻牌动画
function PokerCard:flip(time)
    local time = time or 0.25
    self.isBack_ = false
    local delayAction = cc.DelayTime:create(0)
    local orbitAction = cc.OrbitCamera:create(time, 1, 0, 0, 90, 0, 0)
    local callback = cc.CallFunc:create(handler(self, self.onBackActionComplete_))
    local flipBackAction_ = cc.Sequence:create({delayAction, orbitAction, callback})
    self:showBack_()
    self.backBg_:runAction(flipBackAction_)
    self.delayHandle_ = scheduler.performWithDelayGlobal(handler(self, self.playSoundDelayCall_), 0.25)
    return self
end

function PokerCard:playSoundDelayCall_()
end

function PokerCard:onBackActionComplete_()
    self:showFront()
    local orbitAction = cc.OrbitCamera:create(0.06, 1, 0, -15, 15, 0, 0)
    local callback = cc.CallFunc:create(handler(self, self.onFrontActionComplete_))
    local flipFrontAction_ = cc.Sequence:create({orbitAction, callback})
    self.frontBatch_:runAction(flipFrontAction_)
end

function PokerCard:onFrontActionComplete_()
    self.backBg_:runAction(cc.OrbitCamera:create(0, 1, 0, 0, 0, 0, 0))
    self.frontBatch_:runAction(cc.OrbitCamera:create(0, 1, 0, 0, 0, 0, 0))
end

-- 显示正面
function PokerCard:showFront()
    self.isBack_ = false
    g.myFunc:safeRemoveNode(self.backBg_)
    if not self.frontBatch_:getParent() then
        self.frontBatch_:addTo(self, 5, 5)
        self.frontBatch_:runAction(cc.OrbitCamera:create(0, 1, 0, 0, 0, 0, 0))
    end

    return self
end

function PokerCard:getFrontSprite()
    return self.frontBg_
end

-- 显示背面
function PokerCard:showBack(time)
    self.isBack_ = true
    if self.backBg_ then 
        self.backBg_:removeAllChildren()
    end
    self:showBack_(time)
end

function PokerCard:showBack_(time)
		local time = time or 0
    g.myFunc:safeRemoveNode(self.frontBatch_)
    if not self.backBg_:getParent() then
        self.backBg_:addTo(self, 5, 5)
        self.backBg_:runAction(cc.OrbitCamera:create(time, 1, 0, 0, 0, 0, 0))
    end
    return self
end

function PokerCard:isBack()
    return self.isBack_
end

-- 震动扑克牌
function PokerCard:shake()
    if self._isShaking then
        self:unscheduleUpdate()
    end
    self:scheduleUpdate()
    self._isShaking = true

    return self
end

function PokerCard:onEnterFrame(dt)
    local posX, posY = self.frontBatch_:getPosition()
    if posX <= -1 or posX >= 1 then
        posX = 0
        self.frontBatch_:setPositionX(posX)
    end
    if posY <= -1 or posY >= 1 then
        posY = 0
        self.frontBatch_:setPositionY(posY)
    end
    posX = posX + math.random(-1, 1)
    posY = posY + math.random(-1, 1)
    self.frontBatch_:pos(posX, posY)

    return self
end

-- 停止震动扑克牌
function PokerCard:stopShake()
    if self._isShaking then
        self:unscheduleUpdate()
    end
    self.frontBatch_:pos(0, 0)
    self._isShaking = false

    return self
end

-- 暗化牌
function PokerCard:addDark()
    if not self.darkOverlay_ then
        self.darkOverlay_ = display.newSprite("#poker_light_overlay.png")
    end
    if not self.darkOverlay_:getParent() then
        self.darkOverlay_:addTo(self.frontBatch_):pos(0 + 1.5, 0 - 1)
        self.darkOverlay_:setScaleX(0.98)
        self.darkOverlay_:setScaleY(0.98)
    end
    return self
end

-- 移除暗化
function PokerCard:removeDark()
    if self.darkOverlay_ then
        self.darkOverlay_:removeFromParent()
        self.darkOverlay_ = nil
    end
end

-- 获取扑克牌宽度（不包括阴影）
function PokerCard:getCardWidth()
    return CARD_WIDTH
end

-- 获取扑克牌高度（不包括阴影）
function PokerCard:getCardHeight()
    return CARD_HEIGHT
end

-- 重置扑克牌（移除舞台时自动调用）
function PokerCard:onCleanup()
    -- 恢复扑克
    self:stopShake()
    self:removeDark()

    -- 移除scheduler的handle
    if self.delayHandle_ then
        scheduler.unscheduleGlobal(self.delayHandle_)
    end

    -- 移除扑克视图
    g.myFunc:safeRemoveNode(self.frontBatch_)
    g.myFunc:safeRemoveNode(self.backBg_)
end

-- 清理
function PokerCard:dispose()
    -- 释放retain的对象
    self.backBg_:release()
    self.frontBatch_:release()

    -- 移除node事件
    self:unscheduleUpdate()
    self:removeAllNodeEventListeners()

    -- 移除scheduler的handle
    if self.delayHandle_ then
        scheduler.unscheduleGlobal(self.delayHandle_)
    end
end

return PokerCard

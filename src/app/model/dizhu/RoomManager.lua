local RoomManager = class("RoomManager")

local roomInfo = require("app.model.dizhu.RoomInfo").getInstance()
local seatMgr = require("app.model.dizhu.SeatManager").getInstance()
local RoomUtil = require("app.model.dizhu.RoomUtil")
local RoomConst = require("app.model.dizhu.RoomConst")

local RVP = require("app.model.dizhu.RoomViewPosition")
local P = RVP.OperBtnPosition

local mResDir = "image/dizhu/" -- module resource directory
local commonRoomResDir = "image/commonroom/" -- module resource directory

function RoomManager:ctor()
	self:initialize()
end

function RoomManager:initialize()
    self.operBtns = {}
    self:addEventListeners()
end

function RoomManager:addEventListeners()
end

function RoomManager:setRoomCtrl(roomCtrl)
	self.roomCtrl_ = roomCtrl
end

function RoomManager:initRoomNode(sceneRoomNode)
    self.sceneRoomNode_ = sceneRoomNode

	-- operate btns
    self:initOperBtn()
    self:initDizhuArea()
end

function RoomManager.getInstance()
    if not RoomManager.singleInstance then
        RoomManager.singleInstance = RoomManager.new()
    end
    return RoomManager.singleInstance
end

function RoomManager:initOperBtn()
    self.cardsSeenBtn = g.myUi.ScaleButton.new({normal = mResDir .. "buttons/bt_green_bg.png"})
	:onClick(handler(self.roomCtrl_, self.roomCtrl_.onAddOddsClick))
		:addTo(self.sceneRoomNode_)
		:pos(P[0].x, P[0].y)
		:hide()
        :setSwallowTouches(false)
    self.cardsSeenBtn:setButtonLabel(display.newSprite(mResDir .. "buttons/orange_visible_cards_mul5.png"))
    table.insert(self.operBtns, self.beginBtn)

    self.beginBtn = g.myUi.ScaleButton.new({normal = mResDir .. "buttons/bt_orange_bg.png"})
	:onClick(handler(self.roomCtrl_, self.roomCtrl_.onBeginClick))
		:addTo(self.sceneRoomNode_)
		:pos(P[1].x, P[1].y)
		:hide()
        :setSwallowTouches(false)
    self.beginBtn:setButtonLabel(display.newSprite(mResDir .. "buttons/begin.png"))
    table.insert(self.operBtns, self.beginBtn)
    
    self.noGrabBtn = g.myUi.ScaleButton.new({normal = mResDir .. "buttons/bt_green_bg.png"})
	:onClick(handler(self.roomCtrl_, self.roomCtrl_.onNoGrabClick))
		:addTo(self.sceneRoomNode_)
		:pos(P[2].x, P[2].y)
		:hide()
        :setSwallowTouches(false)
    self.noGrabBtn:setButtonLabel(display.newSprite(mResDir .. "buttons/green_pass_call.png"))
    table.insert(self.operBtns, self.noGrabBtn)

    self.grabBtn = g.myUi.ScaleButton.new({normal = mResDir .. "buttons/bt_orange_bg.png"})
	:onClick(handler(self.roomCtrl_, self.roomCtrl_.onGrabClick))
		:addTo(self.sceneRoomNode_)
		:pos(P[3].x, P[3].y)
		:hide()
        :setSwallowTouches(false)
    self.grabBtn:setButtonLabel(display.newSprite(mResDir .. "buttons/orange_call_landlord.png"))
    table.insert(self.operBtns, self.grabBtn)

    self.noOutBtn = g.myUi.ScaleButton.new({normal = mResDir .. "buttons/bt_green_bg.png"})
	:onClick(handler(self.roomCtrl_, self.roomCtrl_.onNoOutClick))
		:addTo(self.sceneRoomNode_)
		:pos(P[4].x, P[4].y)
		:hide()
        :setSwallowTouches(false)
    self.noOutBtn:setButtonLabel(display.newSprite(mResDir .. "buttons/green_pass_card.png"))
    table.insert(self.operBtns, self.noOutBtn)

    self.promptBtn = g.myUi.ScaleButton.new({normal = mResDir .. "buttons/bt_green_bg.png"})
	:onClick(handler(self.roomCtrl_, self.roomCtrl_.onPromptClick))
		:addTo(self.sceneRoomNode_)
		:pos(P[5].x, P[5].y)
		:hide()
        :setSwallowTouches(false)
    self.promptBtn:setButtonLabel(display.newSprite(mResDir .. "buttons/green_prompt_card.png"))
    table.insert(self.operBtns, self.promptBtn)

    self.outCardBtn = g.myUi.ScaleButton.new({normal = mResDir .. "buttons/bt_orange_bg.png"})
	:onClick(handler(self.roomCtrl_, self.roomCtrl_.onOutCardClick))
		:addTo(self.sceneRoomNode_)
		:pos(P[5].x, P[5].y)
		:hide()
        :setSwallowTouches(false)
    self.outCardBtn:setButtonLabel(display.newSprite(mResDir .. "buttons/orange_out_card.png"))
    table.insert(self.operBtns, self.outCardBtn)

    self.cannotOutBtn = g.myUi.ScaleButton.new({normal = mResDir .. "buttons/bt_orange_bg.png"})
	:onClick(handler(self.roomCtrl_, self.roomCtrl_.onNoOutClick))
		:addTo(self.sceneRoomNode_)
		:pos(P[5].x, P[5].y)
		:hide()
        :setSwallowTouches(false)
    self.cannotOutBtn:setButtonLabel(display.newSprite(mResDir .. "buttons/pass_only.png"))
    table.insert(self.operBtns, self.cannotOutBtn)
end

local dizhuBarNum = {}
dizhuBarNum["0"] = mResDir .. "/number/number0.png"
dizhuBarNum["1"] = mResDir .. "/number/number1.png"
dizhuBarNum["2"] = mResDir .. "/number/number2.png"
dizhuBarNum["3"] = mResDir .. "/number/number3.png"
dizhuBarNum["4"] = mResDir .. "/number/number4.png"
dizhuBarNum["5"] = mResDir .. "/number/number5.png"
dizhuBarNum["6"] = mResDir .. "/number/number6.png"
dizhuBarNum["7"] = mResDir .. "/number/number7.png"
dizhuBarNum["8"] = mResDir .. "/number/number8.png"
dizhuBarNum["9"] = mResDir .. "/number/number9.png"
function RoomManager:initDizhuArea()
    self.dizhuBarNode = display.newNode():pos(display.cx, display.top):addTo(self.sceneRoomNode_)
    display.newSprite(mResDir .. "dizhuBar/dizhu_bottom_card_bg.png")
        :setAnchorPoint(cc.p(0.5, 1))
        :addTo(self.dizhuBarNode)
    display.newSprite(mResDir .. "dizhuBar/base_tag.png")
        :pos(-168, -26)
        :addTo(self.dizhuBarNode)
    self.baseNum_ = g.myUi.NumberImage.new(dizhuBarNum)
    :setAnchorPoint(cc.p(0.5, 0.5))
    :pos(-168, -46)
    :setNumber("1234", -6) -- todo
    :addTo(self.dizhuBarNode)
    display.newSprite(mResDir .. "dizhuBar/multiple_tag.png")
        :pos(168, -26)
        :addTo(self.dizhuBarNode)
    self.betOdds_ = g.myUi.NumberImage.new(dizhuBarNum)
        :setAnchorPoint(cc.p(0.5, 0.5))
        :pos(168, -46)
        :setNumber("5678", -6) -- todo
        :addTo(self.dizhuBarNode)
    local gap = 60
    self.dizhuCards = {}
    for i = 1, RoomConst.LEFT_DIZHU_CARD_NUM do
        local x = (i - 1) * gap - (RoomConst.LEFT_DIZHU_CARD_NUM - 1) * gap/2
        self.dizhuCards[i] = g.myUi.PokerCard.new():pos(x, -42):addTo(self.dizhuBarNode):scale(0.4)
        self.dizhuCards[i]:showBack()
    end
end

function RoomManager:updateDizhuArea(cards, odds)
    for i = 1, RoomConst.LEFT_DIZHU_CARD_NUM do
        self.dizhuCards[i]:setCard(cards[i])
        self.dizhuCards[i]:stopAllActions()
        self.dizhuCards[i]:runAction(cc.Sequence:create({
            cc.DelayTime:create(0.01 * i),
            cc.CallFunc:create(function()
                self.dizhuCards[i]:flip(0.1)
            end),
            cc.DelayTime:create(0.2),
            cc.CallFunc:create(function()
                if (i == RoomConst.LEFT_DIZHU_CARD_NUM) then
                    g.myFunc:safeRemoveNode(self.initOddsMark)
                    self.initOddsMark = display.newSprite(mResDir .. "dizhuBar/mulMark" .. (odds + 1) .. ".png")
                        :pos(0, -60):addTo(self.dizhuBarNode)
                end
            end)
        }))
    end
end

function RoomManager:updateOperBtns(tableState)
    if tableState == RoomConst.TState_NotPlay then
        self.cardsSeenBtn:show()
        self.beginBtn:show()
    end
end

function RoomManager:selfReady()
    self.cardsSeenBtn:hide()
    self.beginBtn:hide()
end

function RoomManager:doWhenGrabTurn(odds)
    if odds < 1 then
        self.noGrabBtn:setButtonLabel(display.newSprite(mResDir .. "buttons/green_pass_call.png"))
        self.grabBtn:setButtonLabel(display.newSprite(mResDir .. "buttons/orange_call_landlord.png"))
    else
        self.noGrabBtn:setButtonLabel(display.newSprite(mResDir .. "buttons/green_pass_grab.png"))
        self.grabBtn:setButtonLabel(display.newSprite(mResDir .. "buttons/orange_grab_landlord.png"))
    end
    self.noGrabBtn:show()
    self.grabBtn:show()
end

function RoomManager:hideGrabBtns()
    self.noGrabBtn:hide()
    self.grabBtn:hide()
end

function RoomManager:doWhenSelfTurn(isNewRound)
    print(1)
    if (isNewRound == 1) then
        print(2)
        self.outCardBtn:pos(P[5].x, P[5].y):show()
        self.noOutBtn:hide()
        self.promptBtn:hide()
        self.cannotOutBtn:hide()
    elseif (not RoomUtil.canOut(roomInfo:getMCards(), roomInfo:getLatestOutCards())) then -- 要不起
        print(3)
        self.cannotOutBtn:show()
    else
        print(4)
        self.outCardBtn:pos(P[6].x, P[6].y):show()
        self.noOutBtn:show()
        self.promptBtn:show()
        self.cannotOutBtn:hide()
    end
end

function RoomManager:clearAll()
end

function RoomManager:dispose()
	self:clearAll()
	g.mySched:cancelAll()
end

return RoomManager

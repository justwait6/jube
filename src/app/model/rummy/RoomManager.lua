local RoomManager = class("RoomManager")

local roomInfo = require("app.model.rummy.RoomInfo").getInstance()
local seatMgr = require("app.model.rummy.SeatManager").getInstance()
local RummyUtil = require("app.model.rummy.RummyUtil")
local RichTextEx = require("app.core.utils.RichTextEx")

local RVP = require("app.model.rummy.RoomViewPosition")
local P2 = RVP.OperBtnPosition
local P3 = RVP.RDPosition

local mResDir = "image/rummy/" -- module resource directory
local commonRoomResDir = "image/commonroom/" -- module resource directory

function RoomManager:ctor()
	self:initialize()
end

function RoomManager:initialize()
    self:addEventListeners()
end

function RoomManager:addEventListeners()
	g.event:on(g.eventNames.RUMMY_CARD_GROUPS_CHANGE, handler(self, self.onCardGroupsChange), self)
	g.event:on(g.eventNames.RUMMY_CHOSEN_CARD_CHANGE, handler(self, self.onChosenCardChange), self)
end

function RoomManager:setRummyCtrl(rummyCtrl)
	self.rummyCtrl_ = rummyCtrl
end

function RoomManager:initRoomNode(sceneRoomNode)
    self.sceneRoomNode_ = sceneRoomNode

    -- dealer icon
	self.dIcon = display.newSprite(mResDir .. "d_icon.png"):pos(display.cx, display.cy):addTo(self.sceneRoomNode_):hide()

	-- room info bar
	local pos = cc.p(display.cx, display.top - 30)
	display.newScale9Sprite(mResDir .. "room_miniinfo_bg.png", pos.x, pos.y, cc.size(556, 50))
		:addTo(self.sceneRoomNode_)
	display.newSprite(mResDir .. "room_miniinfo_sep.png"):pos(pos.x - 76, pos.y):addTo(self.sceneRoomNode_)
	display.newSprite(mResDir .. "room_miniinfo_sep.png"):pos(pos.x + 76, pos.y):addTo(self.sceneRoomNode_)
	display.newTTFLabel({text = g.lang:getText("RUMMY", "POINTS_RUMMY"), size = 20})
				 :pos(pos.x - 180, pos.y)
				 :addTo(self.sceneRoomNode_)
    self.blindText = display.newTTFLabel({text = "", size = 20})
				 :pos(pos.x, pos.y)
				 :addTo(self.sceneRoomNode_)
	self.balanceText = display.newTTFLabel({text = g.lang:getText("RUMMY", "BALANCE"), size = 20})
		:pos(pos.x + 180, pos.y)
		:addTo(self.sceneRoomNode_)
	
	-- operate btns
	self:initOperBtn()
end

function RoomManager.getInstance()
    if not RoomManager.singleInstance then
        RoomManager.singleInstance = RoomManager.new()
    end
    return RoomManager.singleInstance
end

function RoomManager:initOperBtn()	
	self.operBtn = {}
	-- 新牌堆摸牌按钮
	local newHeapPos = RVP.NewHeapPos
	self.drawCardBtn1 = g.myUi.ScaleButton.new({normal = g.Res.blank})
	:onClick(handler(self, function(sender)
		printVgg("drawCardBtn1 onclick...")
		self.rummyCtrl_:sendCliDrawCard(0)
	end))
	:addTo(self.sceneRoomNode_)
	:pos(newHeapPos.x, newHeapPos.y)
	:hide()
	:setSwallowTouches(false)
	:setButtonSize(cc.size(92, 118))

	-- 旧牌堆摸牌按钮
	local oldHeapPos = RVP.OldHeapPos
	self.drawCardBtn2 = g.myUi.ScaleButton.new({normal = g.Res.blank})
	:onClick(handler(self, function(sender)
		self.rummyCtrl_:sendCliDrawCard(1)
	end))
	:addTo(self.sceneRoomNode_)
	:pos(oldHeapPos.x, oldHeapPos.y)
	:hide()
	:setSwallowTouches(false)
	:setButtonSize(cc.size(92, 118))

	-- Drop整副牌按钮
	self.dropBtn = g.myUi.ScaleButton.new({normal = commonRoomResDir .. "oper_orange_btn.png"})
	:setButtonLabel(display.newTTFLabel({size = 30, text = "Drop"}), cc.p(0, 4))
	:onClick(handler(self, function(sender)
		if self.dropBtn:getChildByTag(1):isVisible() then -- 有check框
			self:onPreDropClick()
		else
			self.rummyCtrl_:sendCliDrop()
		end
	end))
		:addTo(self.sceneRoomNode_)
		:pos(P2[1].x, P2[1].y)
		:hide()
		:setSwallowTouches(false)
	table.insert(self.operBtn, self.dropBtn)

	local size = self.dropBtn:getContentSize()
	display.newSprite(commonRoomResDir .. "check_b_bg.png"):setTag(1):pos(size.width/2 - 40, size.height/2 + 6):addTo(self.dropBtn)
	display.newSprite(commonRoomResDir .. "check_b.png"):setTag(2):pos(size.width/2 - 40, size.height/2 + 6):addTo(self.dropBtn)
	
	self.finishBtn = g.myUi.ScaleButton.new({normal = commonRoomResDir .. "oper_green_btn.png"})
		:setButtonLabel(display.newTTFLabel({size = 30, text = "Finish"}), cc.p(0, 4))
		:onClick(handler(self, self.onFinishBtnClick))
		:addTo(self.sceneRoomNode_)
		:pos(P2[1].x,P2[1].y)
		:hide()
		:setSwallowTouches(false)
	table.insert(self.operBtn, self.finishBtn)

	-- discard弃单张牌按钮
	self.discardBtn = g.myUi.ScaleButton.new({normal = commonRoomResDir .. "oper_orange_btn.png"})
		:setButtonLabel(display.newTTFLabel({size = 30, text = "Discard"}), cc.p(0, 4))
		:onClick(handler(self, function(sender) 
			-- self:hideOperBtn()
			local chooseCards = roomInfo:getMCardChooseList()
			if #chooseCards ~= 1 then return end
			local cardIdx = chooseCards[1]
			self.rummyCtrl_:sendCliDiscardCard(cardIdx)
		end))
		:addTo(self.sceneRoomNode_)
		:pos(P2[2].x, P2[2].y)
		:hide()
		:setSwallowTouches(false)
	table.insert(self.operBtn, self.discardBtn)

	self.groupBtn = g.myUi.ScaleButton.new({normal = commonRoomResDir .. "oper_yellow_btn.png"})
		:setButtonLabel(display.newTTFLabel({size = 30, text = "Group"}), cc.p(0, 4))
		:onClick(self.rummyCtrl_.vggGroupCards)
		:addTo(self.sceneRoomNode_)
		:pos(P2[2].x, P2[2].y)
		:hide()
		:setSwallowTouches(false)
	table.insert(self.operBtn, self.groupBtn)

	self.sortBtn = g.myUi.ScaleButton.new({normal = commonRoomResDir .. "oper_yellow_btn.png"})
		:setButtonLabel(display.newTTFLabel({size = 30, text = "Sort"}), cc.p(0, 4))
		:onClick(self.rummyCtrl_.vggSortCards)
		:addTo(self.sceneRoomNode_)
		:pos(P2[2].x,P2[2].y)
		:hide()
		:setSwallowTouches(false)
	table.insert(self.operBtn, self.sortBtn)
end

function RoomManager:showDrawCardBtns()
	self.drawCardBtn1:show()
	self.drawCardBtn2:show()
end

function RoomManager:hideDrawCardBtns()
	self.drawCardBtn1:hide()
	self.drawCardBtn2:hide()
end

function RoomManager:onStartDealCardsFinish() -- 开始发牌完成
	self:updateDropBtn()
end

function RoomManager:onSelfTurn() -- Svr返回自己操作
	self.isSelfTurn = true
	self:showDrawCardBtns()
	self:updateDropBtn()
	-- 检查predrop
	if self.dropWhenTurn then -- 自动弃整副牌
		self.rummyCtrl_:sendCliDrop()
	end
end

function RoomManager:AfterSelfDrawCard() -- Svr返回自己摸牌
	self.isSelfTurn = true
	self:updateDropBtn()
end

function RoomManager:onNotSelfTurn() -- Svr返回自己弃单张牌
	self:hideOperBtn()
	self:hideDrawCardBtns()

	self.isSelfTurn = false
	self:onChosenCardChange({count = 0})
	self:updateDropBtn()
end

function RoomManager:onSelfDrop() -- Svr返回自己弃整副牌
	self:hideOperBtn()
end

function RoomManager:onCardGroupsChange()
	self:setSortBtnVisible(#roomInfo:getCurGroups() == 1)
end

function RoomManager:setSortBtnVisible(visible)
	if visible then
		self.sortBtn:show()
	else
		self.sortBtn:hide()
	end
end

function RoomManager:onChosenCardChange(data)
	local data = data or {}
	local chosenCardNum = data.count or 0
	self:updateFinishBtn(chosenCardNum)
	self:updateDiscardBtn(chosenCardNum)
	self:updateGroupBtn(chosenCardNum)
end

function RoomManager:enterRoomInfo(pack, mMoney)
	self:updateSmallBet(pack.smallbet or 1)
	self:updateDSeat(pack.dSeatId, false)
	self:updateMBalance(mMoney)
end

function RoomManager:updateDropBtn()
	local mCards = roomInfo:getMCards()
	local inDiscard = roomInfo:isInSelfDiscardStage()
	if self.isSelfTurn and inDiscard then -- 轮到玩家, 弃牌阶段
		self.dropBtn:hide()
	elseif self.isSelfTurn then -- 轮到玩家, 但没有在弃牌阶段
		self.dropBtn:show()
		self:setDropCheckVisible(false)
	else -- 未轮到玩家
		self.dropBtn:show()
		self:setDropCheckVisible(true)
	end
	if not mCards or #mCards <= 0 then -- 没牌, 说明已弃牌或是没有在玩
		self.dropBtn:hide()
	end
end

function RoomManager:updateFinishBtn(chosenCardNum)
	-- 轮到玩家, 弃牌阶段, 且选中牌为一张
	local inDiscard = roomInfo:isInSelfDiscardStage()
	local needVisible = (self.isSelfTurn and inDiscard and tonumber(chosenCardNum) == 1)
	-- group数量小于等于1, 不展示finish
	if #roomInfo:getCurGroups() <= 1 then
		needVisible = false
	end
	self.finishBtn:setVisible(needVisible)
end

function RoomManager:updateDiscardBtn(chosenCardNum)
	-- 轮到玩家, 弃牌阶段, 且选中牌为一张
	local inDiscard = roomInfo:isInSelfDiscardStage()
	local needVisible = (self.isSelfTurn and inDiscard and tonumber(chosenCardNum) == 1)
	self.discardBtn:setVisible(needVisible)
end

function RoomManager:updateGroupBtn(chosenCardNum)
	self.groupBtn:setVisible(chosenCardNum >= 2)
	if self.groupBtn:isVisible() then -- group显示时候, 不显示sort btn
		self:setSortBtnVisible(false)
	else -- group不显示的时候, 检查sort btn是否显示
		self:setSortBtnVisible(#roomInfo:getCurGroups() == 1)
	end
end

function RoomManager:setDropCheckVisible(visible)
	if visible then
		self.dropBtn:getChildByTag(1):show()
		self.dropBtn:getChildByTag(2):hide()
		self.dropBtn:getLabel():setPositionX(self.dropBtn:getContentSize().width/2 + 30)
	else
		self.dropBtn:getChildByTag(1):hide()
		self.dropBtn:getChildByTag(2):hide()
		self.dropBtn:getLabel():setPositionX(self.dropBtn:getContentSize().width/2)
	end
end

function RoomManager:hideOperBtn(isImmedite)
	for k,v in ipairs(self.operBtn) do
		v:hide()
    end
end

function RoomManager:onPreDropClick()
	local check = self.dropBtn:getChildByTag(2)
	if check:isVisible() then
		check:hide()
		self.dropWhenTurn = false
	else
		check:show()
		self.dropWhenTurn = true
	end
end
function RoomManager:onFinishBtnClick()
	g.myUi.Dialog.new({
		type = g.myUi.Dialog.Type.NORMAL,
		text = g.lang:getText("RUMMY", "CONFIRM_FINISH_TIPS"),
		onConfirm = handler(self, function()
			local chooseCards = roomInfo:getMCardChooseList()
			if #chooseCards ~= 1 then return end
			local cardIdx = chooseCards[1]
			self.rummyCtrl_:sendCliFinish(cardIdx)
		end),	
	}):show()
end

function RoomManager:updateMBalance(money)
	local str = g.lang:getText("RUMMY", "BALANCE") .. ": "
	str = str .. g.moneyUtil:splitMoney(g.moneyUtil:formatGold(money))
    self.balanceText:setString(str)
end

function RoomManager:updateSmallBet(smallBet)
	roomInfo:setSmallBet(blindBet or 1)
    self.blindText:setString(g.moneyUtil:splitMoney(g.moneyUtil:formatGold(smallBet)))
end

function RoomManager:showDIcon(fixSeatId,needAnim)
    if fixSeatId < 0 then return end
    self.dIcon:show()
    if needAnim then
        local moveAction = cc.MoveTo:create(0.4,P3[fixSeatId])
        self.dIcon:stopAllActions()
        self.dIcon:runAction(cc.EaseSineOut:create(moveAction))
    else
        self.dIcon:pos(P3[fixSeatId].x,P3[fixSeatId].y)
    end
end

function RoomManager:hideDIcon()
    self.dIcon:hide()
end

function RoomManager:updateDSeat(dSeatId, needAnim)
	roomInfo:setDSeatId(dSeatId or -1)
	if dSeatId >= 0 then
		local fixSeatId = RummyUtil.getFixSeatId(dSeatId)
		if fixSeatId >= 0 then
			self:showDIcon(fixSeatId, needAnim)
		end
	else
		self:hideDIcon()
	end
end

function RoomManager:countDownTips(sec)
	-- 判断一下是否选择了最后一局 如果选择了最后一句退出到大厅
	local isCheck = roomInfo:getLastRound()
	if isCheck then
		self.scene:logoutRoom()
	end

	if type(sec) ~= "number" then return end
	self:tipsMiddle_(string.format(g.lang:getText("RUMMY", "GAME_START_COUNTDOWN_FMT"), sec) )
	g.event:emit(g.eventNames.RUMMY_SCORE_POPUP_COUNT, {time = sec, flag = 2})
	g.mySched:cancel(self.schedLoopId_)
	self.schedLoopId_ = g.mySched:doLoop(function()
		sec = sec - 1
		if sec > 0 then
			self:tipsMiddle_(string.format(g.lang:getText("RUMMY", "GAME_START_COUNTDOWN_FMT"), sec) )
    		g.event:emit(g.eventNames.RUMMY_SCORE_POPUP_COUNT, {time = sec, flag = 2})
			return true
		else
			self:hideTipsMiddle_()
			g.mySched:cancel(self.schedLoopId_)
		end
	end, 1)
end
function RoomManager:playMiddleTips(str)
	self:tipsMiddle_(str, 2)
end
function RoomManager:tipsMiddle_(str, sec)
	self:hideAllMiddleTips_() -- 时序优先级
	local width = 320
	local txtWidth = display.newTTFLabel({text = str, size = 24, color = cc.c3b(0xb4, 0xb3, 0xb3)}):getContentSize().width + 20
	if txtWidth > width then
		width = txtWidth
	end
	g.myFunc:safeRemoveNode(self.middleBg)
	self.middleBg = display.newScale9Sprite(mResDir .. "tip_mid_bg.png", display.cx, display.cy + 20, cc.size(width, 54)):addTo(self.sceneRoomNode_)
	self.middleBg:setCapInsets(cc.rect(94/2, 54/2, 1, 1))
	display.newTTFLabel({text = str, size = 24, color = cc.c3b(0xff, 0xff, 0xff)})
		:pos(self.middleBg:getContentSize().width/2, self.middleBg:getContentSize().height/2):addTo(self.middleBg)
	self.middleBg:show()
	if type(sec) == "number" then
		g.mySched:cancel(self.schedId_)
		self.schedId_ = g.mySched:doDelay(function()
			g.mySched:cancel(self.schedId_)
			self:hideTipsMiddle_()
		end, sec)
	end
end

function RoomManager:hideTipsMiddle_()
	if g.myFunc:checkNodeExist(self.middleBg) then self.middleBg:hide() end
end

function RoomManager:showWaitNextGameTips()
	local str = g.lang:getText("RUMMY", "WAIT_NEXT_GAME_TIP")
	local width = 320
	local txtWidth = display.newTTFLabel({text = str, size = 24, color = cc.c3b(0xb4, 0xb3, 0xb3)}):getContentSize().width + 180
	if txtWidth > width then
		width = txtWidth
	end
	g.myFunc:safeRemoveNode(self.waitNextGameBg)
	
	self.waitNextGameBg = display.newScale9Sprite(mResDir .. "tip_mid_bg.png", display.cx, display.cy - 150, cc.size(width, 54)):addTo(self.sceneRoomNode_)
	self.waitNextGameBg:setCapInsets(cc.rect(94/2, 54/2, 1, 1))
	display.newTTFLabel({text = str, size = 24, color = cc.c3b(0xff, 0xff, 0xff)})
		:pos(self.waitNextGameBg:getContentSize().width/2, self.waitNextGameBg:getContentSize().height/2):addTo(self.waitNextGameBg)
	self.waitNextGameBg:show()
end

function RoomManager:hideWaitNextGameTips_()
	if g.myFunc:checkNodeExist(self.waitNextGameBg) then self.waitNextGameBg:hide() end
end

function RoomManager:playDrawCardTips(name, uid, region)
	local str = ""
    if tonumber(region) == 0 then
        str = string.format(g.lang:getText("RUMMY", "DRAW_CART_TIP_1_FMT"), (name or uid))
    elseif tonumber(region) == 1 then
        str = string.format(g.lang:getText("RUMMY", "DRAW_CART_TIP_2_FMT"), (name or uid))
    end
    self:playMiddleTips(str)
end

function RoomManager:showDeclareTips(str, sec)
	self:hideAllMiddleTips_() -- 时序优先级
	local width = 320
	local txtWidth = display.newTTFLabel({text = str, size = 24, color = cc.c3b(0xb4, 0xb3, 0xb3)}):getContentSize().width + 200
	if txtWidth > width then
		width = txtWidth
	end
	g.myFunc:safeRemoveNode(self.declareBg)
	self.declareBg = display.newScale9Sprite(mResDir .. "tip_mid_bg.png", display.cx, display.cy + 20, cc.size(width, 54)):addTo(self.sceneRoomNode_)
	self.declareBg:setCapInsets(cc.rect(94/2, 54/2, 1, 1))
	display.newTTFLabel({text = str, size = 24, color = cc.c3b(0xff, 0xff, 0xff)})
		:pos(self.declareBg:getContentSize().width/2 - 80, self.declareBg:getContentSize().height/2):addTo(self.declareBg)
	self.declareBg:show()

	g.myUi.ScaleButton.new({normal = commonRoomResDir .. "oper_green_btn_2.png"})
		:setButtonLabel(display.newTTFLabel({size = 30, text = "Declare"}), cc.p(0, 4))
		:onClick(self.rummyCtrl_.sendCliDeclare)
		:addTo(self.declareBg)
		:pos(self.declareBg:getContentSize().width - 70, self.declareBg:getContentSize().height/2 - 1)
		:setSwallowTouches(false)
		
	if type(sec) == "number" then
		local id = g.mySched:doDelay(function()
			g.mySched:cancel(id)
			self:hideDeclareTips_()
		end, sec)
	end
end

function RoomManager:hideDeclareTips_()
	if g.myFunc:checkNodeExist(self.declareBg) then self.declareBg:hide() end
end

function RoomManager:showViewResultTips(vStr, callback)
	local str = vStr or g.lang:getText("RUMMY", "VIEW_RESULT_TIP")
	self:hideAllMiddleTips_() -- 时序优先级
	local width = 320
	local txtWidth = display.newTTFLabel({text = str, size = 24, color = cc.c3b(0xb4, 0xb3, 0xb3)}):getContentSize().width + 180
	if txtWidth > width then
		width = txtWidth
	end
	g.myFunc:safeRemoveNode(self.declareBg)
	self.viewResultBg = display.newScale9Sprite(mResDir .. "tip_mid_bg.png", display.cx, display.cy + 20, cc.size(width, 54)):addTo(self.sceneRoomNode_)
	self.viewResultBg:setCapInsets(cc.rect(94/2, 54/2, 1, 1))
	display.newTTFLabel({text = str, size = 24, color = cc.c3b(0xff, 0xff, 0xff)})
		:pos(self.viewResultBg:getContentSize().width/2 - 70, self.viewResultBg:getContentSize().height/2):addTo(self.viewResultBg)
	self.viewResultBg:show()

	local richTextStr = string.format([==[
      <t c="#86eb2c" s="24" id="click">%s</t>
      ]==], g.lang:getText("RUMMY","CLICK_HERE"))
    local richTextEx = RichTextEx.new(richTextStr, callback)
        :addTo(self.viewResultBg)
        :pos(self.viewResultBg:getContentSize().width - 80, self.viewResultBg:getContentSize().height/2 + 2)
end

function RoomManager:hideViewResultTips_()
	if g.myFunc:checkNodeExist(self.viewResultBg) then self.viewResultBg:hide() end
end

function RoomManager:hideAllMiddleTips_()
	self:hideTipsMiddle_()
	self:hideDeclareTips_()
	self:hideViewResultTips_()
end

function RoomManager:clearTable()
	self.isSelfTurn = false
	self.dropWhenTurn = false
	self:hideOperBtn(true)
	self:hideAllMiddleTips_()
	self:hideWaitNextGameTips_()
end

function RoomManager:clearAll()
end

function RoomManager:dispose()
	self:clearAll()
	g.mySched:cancelAll()
end

return RoomManager

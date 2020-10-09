local MoneyTreeView = class("MoneyTreeView", g.myUi.Window)
local MoneyTreeInviteView = import(".MoneyTreeInviteView")
-- local FriendUtil = import("app.module.hall.popup.util.FriendUtil")

local MoneyTreeCtrl = require("app.controller.activity.moneytree.MoneyTreeCtrl")

MoneyTreeView.WIDTH = display.width
MoneyTreeView.HEIGHT = display.height

MoneyTreeView.GOLD = "gold" -- 金币
MoneyTreeView.CHIP = "money" -- 筹码

local CoinField = {}
CoinField.INVITE = "invited"
CoinField.CREDIT = "credit"
CoinField.WATER = "water"
CoinField.MONEY = "money"
CoinField.GOLD = "money"

local goldCoinNum = {}
goldCoinNum["0"] = "image/activity/moneytree/goldCoinNum/0.png"
goldCoinNum["1"] = "image/activity/moneytree/goldCoinNum/1.png"
goldCoinNum["2"] = "image/activity/moneytree/goldCoinNum/2.png"
goldCoinNum["3"] = "image/activity/moneytree/goldCoinNum/3.png"
goldCoinNum["4"] = "image/activity/moneytree/goldCoinNum/4.png"
goldCoinNum["5"] = "image/activity/moneytree/goldCoinNum/5.png"
goldCoinNum["6"] = "image/activity/moneytree/goldCoinNum/6.png"
goldCoinNum["7"] = "image/activity/moneytree/goldCoinNum/7.png"
goldCoinNum["8"] = "image/activity/moneytree/goldCoinNum/8.png"
goldCoinNum["9"] = "image/activity/moneytree/goldCoinNum/9.png"
goldCoinNum["B"] = "image/activity/moneytree/goldCoinNum/B.png"
goldCoinNum["."] = "image/activity/moneytree/goldCoinNum/dot.png"

function MoneyTreeView:ctor(treeType)
    self.ctrl = MoneyTreeCtrl.new(self)
    MoneyTreeView.super.ctor(self, {width = self.WIDTH, height = self.HEIGHT})
    display.addSpriteFrames("image/activity/moneytree/tree_water.plist", "image/activity/moneytree/tree_water.png")
    display.addSpriteFrames("image/activity/moneytree/newMoneyTreeAnimChip.plist", "image/activity/moneytree/newMoneyTreeAnimChip.png")
    display.addSpriteFrames("image/activity/moneytree/newMoneyTreeAnimGold.plist", "image/activity/moneytree/newMoneyTreeAnimGold.png")

    self.treeType = treeType or MoneyTreeView.CHIP
    self:initConfig(treeType)
    self:initUI()
    self:checkNeedGuide()
    -- self.friendUtil = FriendUtil.new()
end

function MoneyTreeView:onShow()
    if self.ctrl then
        self.ctrl:requestTreeInfo(handler(self, self.onRequestTreeInfoSucc))
    end
    self.ctrl:requestRankList(handler(self, self.onRequestRankListSucc))
end

function MoneyTreeView:initConfig(treeType)
    self.currencyMiniIconName = g.Res.moenytree_samllGoldIcon
    self.currencyIconName = g.Res.moenytree_goldCoin
    self.capacityMaxName = "max_capacity_gold"
    self.treePoolName = "goldpool"
    self.fruitNumName ="gold_branch_num"
    self.alreadyGetName = "give_gold"
    self.iconMidName = g.Res.moneytree_goldIconMid

    if treeType == MoneyTreeView.CHIP then
        self.currencyMiniIconName = g.Res.moenytree_samllChipIcon
        self.currencyIconName = g.Res.moenytree_chipCoin
        self.capacityMaxName = "max_capacity_money"
        self.treePoolName = "moneypool"
        self.fruitNumName = "money_branch_num"
        self.alreadyGetName = "give_money"
        self.iconMidName = g.Res.moneytree_chipIconMid
    end
end

function MoneyTreeView:initUI()
    display.newSprite(g.Res.moneytree_bg):addTo(self)
    -- 摇钱树标题
    display.newSprite(g.Res.moneytree_titleBar)
        :pos(0, display.height/2 - 44)
        :addTo(self)
    -- 帮助按钮
    g.myUi.ScaleButton.new({normal = g.Res.moneytree_questionIcon})
        :onClick(handler(self.ctrl, self.ctrl.onHelpClick))
        :pos(-300, -312)
        :addTo(self)
    -- 邀请按钮
    g.myUi.ScaleButton.new({normal = g.Res.moneytree_shareIcon})
        :onClick(handler(self.ctrl, self.ctrl.onInviteClick))
        :pos(296, -312)
        :addTo(self)
    -- 关闭按钮
    g.myUi.ScaleButton.new({normal = g.Res.moneytree_backIcon})
        :onClick(handler(self, self.close))
        :pos(-display.width/2 + 82, display.height/2 - 46)
        :addTo(self)

    -- 浇水按钮
    local canButton = g.myUi.ScaleButton.new({normal = g.Res.moneytree_canButton})
        :onClick(handler(self.ctrl, self.ctrl.onWaterButtonClick))
        :pos(-278, 66)
        :addTo(self)

    display.newSprite(g.Res.moneytree_waterLbl)
        :pos(0 + canButton:getContentSize().width/2, -34 + canButton:getContentSize().height/2)
        :addTo(canButton)
    self.waterRedDot = display.newSprite(g.Res.moneytree_redDot)
        :pos(30 + canButton:getContentSize().width/2, 30 + canButton:getContentSize().height/2)
        :addTo(canButton)
        :hide()
    if self.treeType == MoneyTreeView.GOLD then
        canButton:hide()
    end

    self:initMoneyTree()
    self:initMyTreeView()
    self:initOtherTreeView()
    self:initMyInvitesList()
end

function MoneyTreeView:initMyTreeView()
    self.myTreeViewNode = display.newNode():addTo(self):hide()
    self:initMyInfoPanel()
    self:initMyDynamicsPanel()
end

function MoneyTreeView:initOtherTreeView()
    self.otherTreeViewNode = display.newNode():addTo(self):hide()
    -- 图标 我的树
    local homeButton = g.myUi.ScaleButton.new({normal = g.Res.moneytree_myTreeIcon})
        :onClick(handler(self, self.onHomeClick))
        :pos(-278, 176)
        :addTo(self.otherTreeViewNode)

    display.newSprite(g.Res.moneytree_myTreeLbl)
        :pos(homeButton:getContentSize().width / 2, 0)
        :addTo(homeButton)

    self:initComparePanel()
end

function MoneyTreeView:initMyInfoPanel()
    -- 当前金币(筹码)显示
    self.myInfoNode = display.newNode():pos(490, 176):addTo(self):hide()
    g.myFunc:setAllCascadeOpacityEnabled(self.myInfoNode)
    display.newSprite(g.Res.moneytree_myInfoBg)
        :addTo(self.myInfoNode)

    -- 头像
    g.myUi.AvatarView.new({
        radius = 37,
        gender = g.user:getGender(),
        frameRes = g.Res.moneytree_imageFrameR,
        avatarUrl = g.user:getIconUrl(),
				clickOptions = {default = false, enable = false},
    })
        :pos(-88, 0)
        :addTo(self.myInfoNode)

    -- 姓名
    display.newTTFLabel({
            text = g.user:getCatName(14), size = 30, color = cc.c3b(255, 255, 255)})
        :align(display.LEFT_CENTER, -34, 20)
        :addTo(self.myInfoNode)
    
    -- 金币(筹码)背景
    local currencyNode = display.newNode():pos(34, -20):addTo(self.myInfoNode)
    display.newSprite(g.Res.moneytree_chipBg)
        :addTo(currencyNode)
    -- 金币(筹码)图标
    self.myGoldIcon = display.newSprite(self.iconMidName)
        :pos(-58, 0)
        :addTo(currencyNode)
    -- 金币(筹码)数量
    self.myGoldNum = display.newTTFLabel({
            text = g.moneyUtil:splitMoney(g.user:getMoney()), size = 26, color = cc.c3b(255, 255, 255)})
        :align(display.CENTER, 8, 0)
        :addTo(currencyNode)
end

local LIST_WIDTH_2 = 272
local LIST_HEIGHT_2 = 372
function MoneyTreeView:initMyDynamicsPanel()
    self.myDynamicsNode = display.newNode():pos(490, -122):addTo(self):hide()
    display.newSprite(g.Res.moneytree_myDynamicsBg):pos(0, 0):addTo(self.myDynamicsNode)
    display.newSprite(g.Res.moneytree_friendDynamics):pos(0, 196):addTo(self.myDynamicsNode)
    self.myDynamicsListView = g.myUi.UIListView.new(LIST_WIDTH_2, LIST_HEIGHT_2)
        :pos(0, -32)
        :addTo(self.myDynamicsNode)
end

function MoneyTreeView:updateMyDynamicsPanel(data)

    if table.nums(data) == 0 then
        if not self.myDynamicNoneTips then
            self.myDynamicNoneTips = display.newTTFLabel({text = g.lang:getText("MONEYTREE", "NO_DYNAMICS"), size = 20})
                :pos(0, -32)
                :addTo(self.myDynamicsNode, 1)
        end
        return
    else
        if self.myDynamicNoneTips then
            self.myDynamicNoneTips:hide()
        end
    end

    self.myDynamicsListView:removeAllItems()

    local contentNode = display.newNode()
    display.newScale9Sprite(g.Res.blank, 0, 0, cc.size(LIST_WIDTH_2, 1)):addTo(contentNode)
    local lastDay = nil
    local curY, leftX = 72, LIST_WIDTH_2/2
    for i, v in ipairs(data) do
        local curDay = os.date("%m.%d", tonumber(v.time))
        if lastDay ~= curDay then
            curY = curY - 72
            -- 日期
            display.newTTFLabel({text = curDay, size = 22, color = cc.c3b(255, 255, 255)})
                :align(display.LEFT_CENTER, -leftX + 6, curY)
                :addTo(contentNode)
            curY = curY - 24
            -- 白点
            display.newSprite(g.Res.moneytree_whiteDot)
                :pos(-leftX + 24, curY)
                :addTo(contentNode, 1)
            -- 白线
            display.newScale9Sprite(g.Res.moneytree_whiteBar, 0, 0, cc.size(3, 24))
                :pos(-leftX + 24, curY - 14)
                :addTo(contentNode)
            curY = curY - 24
            -- 图标
            self:newMyDynamicsIcon(v.type)
                :pos(-leftX + 24, curY)
                :addTo(contentNode)
            -- 时间(hh:mm)
            local curHhmm = os.date("%H:%M", tonumber(v.time))
            display.newTTFLabel({text = curHhmm, size = 18, color = cc.c3b(133, 191, 255)})
                :align(display.LEFT_CENTER, -leftX + 42, curY)
                :addTo(contentNode)
            -- 名字
            display.newTTFLabel({text = g.nameUtil:getLimitName(v.name, 14), size = 18, color = cc.c3b(32, 252, 255)})
                :align(display.LEFT_CENTER, -leftX + 104, curY)
                :addTo(contentNode)
            -- 文字
            display.newTTFLabel({text = v.text, size = 18, color = cc.c3b(133, 191, 255)})
                :align(display.LEFT_CENTER, -leftX + 104, curY - 30)
                :addTo(contentNode)
            lastDay = curDay
        else
            -- 白线
            display.newScale9Sprite(g.Res.moneytree_whiteBar, 0, 0, cc.size(3, 64))
                :pos(-leftX + 24, curY - 34)
                :addTo(contentNode)
            curY = curY - 64
            self:newMyDynamicsIcon(v.type)
                :pos(-leftX + 24, curY)
                :addTo(contentNode)
            -- 时间(hh:mm)
            local curHhmm = os.date("%H:%M", tonumber(v.time))
            display.newTTFLabel({text = curHhmm, size = 18, color = cc.c3b(133, 191, 255)})
                :align(display.LEFT_CENTER, -leftX + 42, curY)
                :addTo(contentNode)
            -- 名字
            display.newTTFLabel({text = g.nameUtil:getLimitName(v.name, 14), size = 18, color = cc.c3b(32, 252, 255)})
                :align(display.LEFT_CENTER, -leftX + 104, curY)
                :addTo(contentNode)
            -- 文字
            display.newTTFLabel({text = v.text, size = 18, color = cc.c3b(133, 191, 255)})
                :align(display.LEFT_CENTER, -leftX + 104, curY - 30)
                :addTo(contentNode)

        end
    end

    contentNode:pos(LIST_WIDTH_2/2, 0 - curY + 50)
    self.myDynamicsListView:addNode(contentNode, LIST_WIDTH_2, 0 - curY + 72)
end

function MoneyTreeView:newMyDynamicsIcon(actionType)
    local actionIconRes = g.Res.moneytree_waterDrop
    if tonumber(actionType) == 2 then
        actionIconRes = g.Res.moneytree_stealIcon
    end
    return display.newSprite(actionIconRes)
end

function MoneyTreeView:initComparePanel()
    self.compareNode = display.newNode():pos(490, -65):addTo(self):hide()
    g.myFunc:setAllCascadeOpacityEnabled(self.compareNode)
    -- 比较面板己方
    self.vsMyAttrs = {}
    self.vsMyNode = self:createVsPanel(self.vsMyAttrs):pos(0, 170):addTo(self.compareNode)
    g.myFunc:setAllCascadeOpacityEnabled(self.vsMyNode)
    self.vsMyWaterCount = self.vsMyAttrs.waterCount

    -- VS标签
    display.newSprite(g.Res.moneytree_VS):pos(0, 0):addTo(self.compareNode)

    -- 比较面板对方
    self.vsHisAttrs = {}
    self.vsHisNode = self:createVsPanel(self.vsHisAttrs):pos(0, -170):addTo(self.compareNode)
    g.myFunc:setAllCascadeOpacityEnabled(self.vsHisNode)
end

function MoneyTreeView:createVsPanel(attributes)
    local node = display.newNode()
    display.newSprite(g.Res.moneytree_vsInfoBg):addTo(node)

    local imageLevelY = 70
    -- 头像
    attributes.headerImage = g.myUi.AvatarView.new({
        radius = 74,
        gender = g.user:getGender(),
        frameRes = g.Res.moneytree_imageFrameR,
    })
        :pos(-88, imageLevelY)
        :addTo(node)
    
    -- 姓名
    attributes.name = display.newTTFLabel({
            text = g.user:getCatName(14), size = 30, color = cc.c3b(255, 255, 255)})
        :align(display.LEFT_CENTER, -34, imageLevelY + 20)
        :addTo(node)

    -- 金币(筹码)背景
    local currencyNode = display.newNode():pos(34, imageLevelY - 20):addTo(node)
    display.newSprite(g.Res.moneytree_chipBg)
        :pos(0, 1)
        :addTo(currencyNode)
    -- 金币(筹码)图标
    self.vsPanelGoldIcon = display.newSprite(self.iconMidName)
        :pos(-58, 1)
        :addTo(currencyNode)
    -- 金币(筹码)数量
    attributes.currencyCount = display.newTTFLabel({
            text = "", size = 26, color = cc.c3b(255, 255, 255)})
        :align(display.CENTER, 8, 0)
        :addTo(currencyNode)

    -- 树等级
    local treeLevelPosY = 6
    display.newSprite(g.Res.moneytree_rankTreeIcon)
        :pos(-88, treeLevelPosY)
        :addTo(node)
    attributes.treeLevel = display.newTTFLabel({
            text = "", size = 18, color = cc.c3b(108, 255, 0)})
        :align(display.CENTER, -50, treeLevelPosY - 4)
        :addTo(node)

    attributes.progress = g.myUi.ProgressBar.new(g.Res.common_progressBg2, g.Res.common_progress2, {bgWidth = 112, bgHeight = 12, fillWidth = 6, fillHeight = 8})
        :pos(-12, treeLevelPosY)
        :addTo(node)
    attributes.progress:setValue(0.5)

    -- 玩家交互情况
    local vsInteractivePosY = -62
    display.newSprite(g.Res.moneytree_vsInfoBg2):pos(0, vsInteractivePosY):addTo(node)
    attributes.moneyStealDesc = display.newTTFLabel({
            text = "", size = 24, color = cc.c3b(71, 150, 229)})
        :align(display.LEFT_CENTER, -124, vsInteractivePosY + 20)
        :addTo(node)
    attributes.moneyStealCount = display.newTTFLabel({
            text = "", size = 24, color = cc.c3b(255, 255, 255)})
        :align(display.LEFT_CENTER, 46, vsInteractivePosY + 20)
        :addTo(node)
    attributes.waterDesc = display.newTTFLabel({
            text = "", size = 24, color = cc.c3b(71, 150, 229)})
        :align(display.LEFT_CENTER, -124, vsInteractivePosY - 20)
        :addTo(node)
    attributes.waterCount = display.newTTFLabel({
            text = "", size = 24, color = cc.c3b(255, 255, 255)})
        :align(display.LEFT_CENTER, 46, vsInteractivePosY - 20)
        :addTo(node)

    return node
end

function MoneyTreeView:updateVsPanel(node, vsAttrs, data)
    vsAttrs = vsAttrs or {}
    data = data or {}
    if vsAttrs.headerImage then
        vsAttrs.headerImage:removeFromParent()
        -- 重新创建头像
        vsAttrs.headerImage = g.myUi.AvatarView.new({
            radius = 74 / 2,
            gender = g.user:getGender(),
            frameRes = g.Res.moneytree_imageFrameR,
            avatarUrl = data.icon,
            clickOptions = {default = true, uid = data.uid},
        })
        :pos(-88, 70)
        :addTo(node)
    end
    if vsAttrs.name then
        vsAttrs.name:setString(g.nameUtil:getLimitName(data.name, 10))
    end
    if vsAttrs.currencyCount then
        local faceValue = g.moneyUtil:splitMoney(self:getTransferAmount(data.currencyCount or 0, self.treeType))
        vsAttrs.currencyCount:setString(faceValue)
    end
    if vsAttrs.treeLevel then
        vsAttrs.treeLevel:setString("Lv." .. (data.treeLevel or 0))
    end
    if vsAttrs.progress then
        vsAttrs.progress:setValue(data.progress)
    end
    if vsAttrs.moneyStealDesc then
        vsAttrs.moneyStealDesc:setString(data.moneyStealDesc)
    end
    if vsAttrs.moneyStealCount then
        local faceValue = g.moneyUtil:splitMoney(self:getTransferAmount(data.moneyStealCount, self.treeType))
        vsAttrs.moneyStealCount:setString(faceValue)
    end
    if vsAttrs.waterDesc then
        vsAttrs.waterDesc:setString(data.waterDesc)
    end
    if vsAttrs.waterCount then
        vsAttrs.waterCount:setString(data.waterCount)
    end
end

function MoneyTreeView:updateVsWaterCountLbl(waterCount)
    if self.vsMyWaterCount then
        self.vsMyWaterCount:setString(waterCount)
    end
end

function MoneyTreeView:initMoneyTree()
    self:renderTreeLevelInfo()
end

function MoneyTreeView:renderTreeLevelInfo()
    local node = display.newNode():pos(0, -320):addTo(self, 1)
    display.newSprite(g.Res.moneytree_treeLevelBg):pos(0, 0):addTo(node)

    self.treeLevelLbl = display.newTTFLabel({
            text = "", size = 22, color = cc.c3b(108, 255, 0)})
        :align(display.CENTER, -118, 0)
        :addTo(node)

    self.treeExpLbl = display.newTTFLabel({
            text = "", size = 22, color = cc.c3b(255, 255, 255)})
        :align(display.CENTER, 34, 12)
        :addTo(node)
    self.treeLevelProgress = g.myUi.ProgressBar.new(g.Res.common_progressBg2, g.Res.common_progress2, {bgWidth = 212, bgHeight = 12, fillWidth = 6, fillHeight = 8})
        :pos(-82, -10)
        :addTo(node)
    self.treeLevelProgress:setValue(0)
end

function MoneyTreeView:updateTreeLevelInfo(level, exp, expLevelUp)
    if self.treeLevelLbl then
        self.treeLevelLbl:setString("Lv." .. (level or 0))
    end
    if self.treeExpLbl then
        self.treeExpLbl:setString((exp or 0) .. "/" .. (expLevelUp or 1))
    end
    if self.treeLevelProgress then
        self.treeLevelProgress:setValue((exp or 0)/((expLevelUp or 1)))
    end
end

local MAX_SHOW_COINS = 10
local coinPosList = {cc.p(49, -45), cc.p(-210, -50), cc.p(0, 72),
    cc.p(105, -120), cc.p(-129, 34), cc.p(176, -45), cc.p(-139, -126),
    cc.p(109, 47), cc.p(-61, -49), cc.p(213, 67),}
function MoneyTreeView:renderCoins(amountList, treeNode)
    local amountList = amountList or {}

    for i, v in ipairs(amountList) do
        if i > MAX_SHOW_COINS then break end
        local params = {}
        params.canSteal = tonumber(amountList[i].steal)
        params.moneyAmount = amountList[i].money
        params.isButtonEnabled = params.isSelf or (not params.isSelf and params.canSteal)
        params.field = CoinField.MONEY
        if self.treeType == MoneyTreeView.GOLD then
            params.field = CoinField.GOLD
        end
        params.moneyinfo = {}
        params.moneyinfo.money = amountList[i].money
        params.moneyinfo.uid = amountList[i].uid -- 产出果实的uid
        local coin = self:newStealCoin(params)
            :pos(coinPosList[i].x, coinPosList[i].y)
            :addTo(treeNode)
        self:playCoinAnim(coin, 0.1 * i)
    end
end

function MoneyTreeView:newWaterCoin(waterCount, waterMoney, isSelf)
    local waterCoinStr = (waterCount or 0) .. "/5"
    if tonumber(waterMoney or 0) > 0 then
        waterCoinStr = g.moneyUtil:splitMoney(waterMoney or 0)
    end
    local params = {}
    params.isButtonEnabled = isSelf and tonumber(waterMoney) > 0
    params.moneyAmount = waterMoney or 0
    params.faceString = waterCoinStr
    params.desc = g.lang:getText("MONEYTREE", "WATER_GET")
    params.field = CoinField.WATER
    params.moneyinfo = {}
    params.moneyinfo[tostring(self.treeType)] = waterMoney
    params.moneyinfo.uid = g.user:getUid()
    return self:newDescCoin(params)
end

function MoneyTreeView:newInviteCoin(invitedMoney, isSelf)
    local params = {}
    params.isButtonEnabled = isSelf and tonumber(invitedMoney) > 0
    params.moneyAmount = invitedMoney or 0
    params.desc = g.lang:getText("MONEYTREE", "INVITE_GET")
    params.field = CoinField.INVITE
    params.moneyinfo = {}
    params.moneyinfo[tostring(self.treeType)] = invitedMoney
    params.moneyinfo.uid = g.user:getUid()
    return self:newDescCoin(params)
end

function MoneyTreeView:newCreditCoin(creaditMoney, isSelf)
    local params = {}
    params.isButtonEnabled = isSelf and tonumber(creaditMoney) > 0
    params.moneyAmount = creaditMoney or 0
    params.desc = g.lang:getText("MONEYTREE", "CREDIT_GET")
    params.field = CoinField.CREDIT
    params.moneyinfo = {}
    params.moneyinfo[tostring(self.treeType)] = creaditMoney
    params.moneyinfo.uid = g.user:getUid()
    return self:newDescCoin(params)
end

function MoneyTreeView:newDescCoin(params)
    local clickCallback = function (moneyAmount, coinButton)
        self.curReqCoinMoneyAmount = moneyAmount
        self.curReqCoin = coinButton
        self.curReqCoinField = params.field
        self:requestCollectOwnCoin(params, 
            handler(self, self.onRequestCollectOwnCoinSucc),
            handler(self, self.onRequestCollectOwnCoinFail))
    end

    local descCoin = self:newSingleCoin(params.moneyAmount, clickCallback, params.isButtonEnabled, params.faceString)
    display.newTTFLabel({
            text = params.desc, size = 18, color = cc.c3b(255, 255, 255)})
        :align(display.CENTER, 0 + descCoin:getContentSize().width/2, -48 + descCoin:getContentSize().height/2)
        :addTo(descCoin)
    return descCoin
end

local CoinTag = {}
CoinTag.STEAL_LBL = 1
CoinTag.STEAL_ICON = 2
CoinTag.FACE_LBL = 3
function MoneyTreeView:newStealCoin(params)
    local clickCallback = function (moneyAmount, coinButton)
        self.curReqCoinMoneyAmount = moneyAmount
        self.curReqCoin = coinButton
        self.curReqCoinField = params.field
        if tonumber(self:getCurTreeShowUid()) == tonumber(g.user:getUid()) then
            self:requestCollectOwnCoin(params, 
                handler(self, self.onRequestCollectOwnCoinSucc),
                handler(self, self.onRequestCollectOwnCoinFail), true)
        else
            self:requestCollectOtherCoin(params, 
                handler(self, self.onRequestCollectOtherCoinSucc),
                handler(self, self.onRequestCollectOtherCoinFail), true)
        end
    end
    local stealCoin = self:newSingleCoin(params.moneyAmount, clickCallback, params.isButtonEnabled)
    if tonumber(params.canSteal) == 1 then
        local lbl = display.newTTFLabel({
                text = g.lang:getText("MONEYTREE", "CAN_STEAL"), size = 18, color = cc.c3b(255, 255, 255)})
            :align(display.CENTER, 0 + stealCoin:getContentSize().width/2, -48 + stealCoin:getContentSize().height/2)
            :addTo(stealCoin)
        lbl:setTag(CoinTag.STEAL_LBL) -- 摘取后需要删掉
        local handIcon = display.newSprite(g.Res.moneytree_hand)
            :pos(0 + stealCoin:getContentSize().width/2, -48 + stealCoin:getContentSize().height/2)
            :addTo(stealCoin)
        handIcon:setTag(CoinTag.STEAL_ICON) -- 摘取后需要删掉
        g.myFunc:setNodesAlignCenter({lbl, handIcon}, 4)
        lbl:setPositionX(lbl:getPositionX() + stealCoin:getContentSize().width/2)
        handIcon:setPositionX(handIcon:getPositionX() + stealCoin:getContentSize().width/2)
    end
    return stealCoin
end

function MoneyTreeView:newSingleCoin(moneyAmount, clickCallback, enabled, forcedFaceString)
    local enabled = enabled ~= false
    local coinButton = g.myUi.ScaleButton.new({normal = self.currencyIconName})
        :onClick(handler(self, function (self, sender)
            if clickCallback then
                clickCallback(moneyAmount, sender)
            end
        end))
        :setButtonEnabled(enabled)
        :pos(-300, -312)
        :addTo(self)
    coinButton:setCascadeOpacityEnabled(true)

    self:setCoinButtonEnabled(coinButton, enabled)
    display.newSprite(g.Res.moenytree_bubble)
        :pos(coinButton:getContentSize().width/2, coinButton:getContentSize().height/2)
        :addTo(coinButton)
    local faceAmount = self:getTransferAmount(moneyAmount, self.treeType)
    local faceString = forcedFaceString or g.moneyUtil:splitMoney(faceAmount or 0)
    if self.treeType == MoneyTreeView.GOLD then
        local number = g.myUi.NumberImage.new(goldCoinNum)
            :setAnchorPoint(cc.p(0.5, 0.5))
            :pos(0 + coinButton:getContentSize().width/2, 10 + coinButton:getContentSize().height/2)
            :setNumber(tostring(faceString), 4)
            :addTo(coinButton)
        number:setTag(CoinTag.FACE_LBL)
    elseif self.treeType == MoneyTreeView.CHIP then
        local lbl = display.newTTFLabel({
                text = faceString, size = 16, color = cc.c3b(65, 170, 85)})
            :align(display.CENTER, 0 + coinButton:getContentSize().width/2, 0 + coinButton:getContentSize().height/2)
            :addTo(coinButton)
        lbl:setTag(CoinTag.FACE_LBL)
    end
    return coinButton
end

function MoneyTreeView:playCoinAnim(coinNode, delayTime)
    if coinNode then
        coinNode:stopAllActions()
        local coinRoundAction = cc.Sequence:create(
            cc.DelayTime:create(delayTime),
            cc.MoveBy:create(1, cc.p(0, 8)),
            cc.MoveBy:create(1, cc.p(0, -8))
            )
        coinNode:runAction(cc.RepeatForever:create(coinRoundAction))
    end
end

function MoneyTreeView:requestCollectOwnCoin(reqParams, successCallback, failCallback)
    self:setForbidOperation(true)
    if self.httpCollectMyCoinId then return end

    local param = {}
    param.cmd = "NewMoneyTree-giveOwnTree"
    param.param = {}
    param.param.type = self.treeType
    param.param.field = reqParams.field
    param.param.moneyinfo = reqParams.moneyinfo
    if self.curReqCoinField == CoinField.WATER then
        param.param.moneyinfo.money = self:getWaterMoneyAward()
    end
    param.param[tostring(self.treeType)] = faceValue
    self.httpCollectMyCoinId = g.http:post(param,
        function(data)
            self.httpCollectMyCoinId = nil
            local result = json.decode(data)
            -- dump(result)
            if result and result.ret == 0 then
                if successCallback then
                    successCallback(result)
                end
            else
                if failCallback then
                    failCallback(result)
                end
            end
        end,
        handler(self, function(self, errCode)
            self.httpCollectMyCoinId = nil
            if tonumber(errCode) == 28 or tonumber(errCode) == 7 then 
                g.myUi.topTip:showText(g.lang:getText("HTTP", "TIMEOUT"))
            end
        end)) 
end

function MoneyTreeView:onRequestCollectOwnCoinSucc(data)
    local data = data or {}
    local dataInfo = data.info or {}
    -- printVgg("MoneyTreeView:onRequestCollectOwnCoinSucc: ", dump(data))

    local completeCallback = handler(self, function ()
        self.ctrl:requestRankList(handler(self, self.onRequestRankListSucc), nil, true)
        self.ctrl:requestTreeInfo(handler(self, self.onRequestTreeInfoSucc), nil, true)
        self:setForbidOperation(false)
    end)
    if self.curReqCoinField == CoinField.WATER then
        self:setWaterMoneyAward(dataInfo.waterMoney)
        self:playCollectSpecialCoinAnim(dataInfo.waterMoney, self.curReqCoin, (dataInfo.waterMoneyCount or 0) .. "/5", nil)
    elseif self.curReqCoinField == CoinField.INVITE or self.curReqCoinField == CoinField.CREDIT then
        self:playCollectSpecialCoinAnim(dataInfo.giveMoney, self.curReqCoin, 0, nil)
    else
        self:playCollectCoinAnim(self.curReqCoinMoneyAmount, self.curReqCoin, nil)
        self:setForbidOperation(false)
    end
    self:playCoinMoveAvatarAnim(self.iconMidName, cc.p(self.curReqCoin:getPositionX(), self.curReqCoin:getPositionY()), cc.p(466, 156), true, completeCallback)

    self:updateTreeLevelInfo(dataInfo.level, dataInfo.exp, dataInfo.maxExp)
    self:playAddExpAnim(dataInfo.incExp)
end

function MoneyTreeView:onRequestCollectOwnCoinFail(data)
    if type(data) == "table" and tonumber(data.ret) == 5 then
        self.ctrl:requestTreeInfo(handler(self, self.onRequestTreeInfoSucc))
    end
    self:setForbidOperation(false)
end

function MoneyTreeView:requestCollectOtherCoin(reqParams, successCallback, failCallback)
    self:setForbidOperation(true)
    if self.httpCollectOtherCoinId then return end

    local param = {}
    param.cmd = "NewMoneyTree-giveOtherTree"
    param.param = {}
    param.param.type = self.treeType
    param.param.moneyinfo = reqParams.moneyinfo
    param.param.frienduid = self:getCurTreeShowUid()
    self.httpCollectOtherCoinId = g.http:post(param,
        function(data)
            self.httpCollectOtherCoinId = nil
            local result = json.decode(data)
            -- dump(result)
            if result and result.ret == 0 then
                if successCallback then
                    successCallback(result)
                end
            else
                if failCallback then
                    failCallback(result)
                end
            end
        end,
        handler(self, function(self, errCode)
            self.httpCollectOtherCoinId = nil
            if tonumber(errCode) == 28 or tonumber(errCode) == 7 then 
                g.myUi.topTip:showText(g.lang:getText("HTTP", "TIMEOUT"))
            end
        end))
end

function MoneyTreeView:onRequestCollectOtherCoinSucc(data)
    local data = data or {}
    local dataInfo = data.info or {}
    local completeCallback = handler(self, function ()
        self.ctrl:requestRankList(handler(self, self.onRequestRankListSucc), nil, true)
        self.ctrl:requestTreeInfo(handler(self, self.onRequestTreeInfoSucc))
        self:setForbidOperation(false)
    end)
    self:playCollectStealCoinAnim(dataInfo.temmoney, self.curReqCoin, dataInfo.temoney or 0, nil)
    self:playCoinMoveAvatarAnim(self.iconMidName, cc.p(self.curReqCoin:getPositionX(), self.curReqCoin:getPositionY()), cc.p(466, 156), true, completeCallback)
end

function MoneyTreeView:onRequestCollectOtherCoinFail(data)
    if type(data) == "table" and tonumber(data.ret) == 5 then
        self.ctrl:requestTreeInfo(handler(self, self.onRequestTreeInfoSucc))
    end
    self:setForbidOperation(false)
end

function MoneyTreeView:playCollectCoinAnim(moneyAmount, coinNode, completeCallback)
    if not coinNode then return end
    local faceAmount = self:getTransferAmount(moneyAmount, self.treeType)
    local coinLabel = display.newTTFLabel({
            text = "+" .. g.moneyUtil:splitMoney(faceAmount or 0), size = 30, color = cc.c3b(255, 255, 160)})
        :align(display.CENTER, 0, 20)
        :addTo(coinNode)
    coinNode:stopAllActions()
    local coinRoundAction = cc.Spawn:create(
        cc.MoveBy:create(0.4, cc.p(0, 20)),
        cc.FadeOut:create(0.4)
        )
    coinNode:runAction(cc.Sequence:create(
        cc.CallFunc:create(function ()
                coinLabel:stopAllActions()
                coinLabel:runAction(cc.Sequence:create(cc.MoveBy:create(0.2, cc.p(0, 30))))
            end),
        cc.DelayTime:create(0.2),
        coinRoundAction,
        cc.CallFunc:create(handler(self, function ()
                if coinNode then
                    coinNode:stopAllActions()
                    coinNode:removeFromParent()
                    if completeCallback then
                        completeCallback()
                    end
                end
            end))
        ))
end

function MoneyTreeView:playCollectSpecialCoinAnim(oldValue, coinNode, curFaceValue, completeCallback)
    if not coinNode then return end
    local coinLabel = display.newTTFLabel({
            text = "+" .. g.moneyUtil:splitMoney(oldValue or 0), size = 30, color = cc.c3b(255, 255, 160)})
        :align(display.CENTER, 0, 20)
        :addTo(coinNode)
    coinNode:stopAllActions()
    coinNode:runAction(cc.Sequence:create(
        cc.CallFunc:create(function ()
                coinLabel:stopAllActions()
                coinLabel:runAction(cc.Sequence:create(cc.MoveBy:create(0.2, cc.p(0, 30))))
            end),
        cc.DelayTime:create(0.4),
        cc.CallFunc:create(handler(self, function ()
                if coinNode then
                    coinNode:stopAllActions()
                    self:playCoinAnim(coinNode, 0)
                    if coinLabel then
                        coinLabel:removeFromParent()
                    end
                    self:setCoinFaceString(coinNode, curFaceValue)
                    self:setCoinButtonEnabled(coinNode, false)
                    if completeCallback then
                        completeCallback()
                    end
                end
            end))
        ))
end

function MoneyTreeView:playCoinMoveAvatarAnim(coinRes, frompos, topos, isPatical, completeCallback)
    if not self.animNode then
        self.animNode = display.newNode():addTo(self, 99)
    end
    -- 帧动画
    -- g.audio:playSound(g.Audio.GAPLE_CHIPSFLY)
    for i = 1, 4 do
        local sprite = display.newSprite(coinRes)
            :pos(frompos.x, frompos.y)
            :opacity(0)
            :addTo(self.animNode)

        local moveBackAction = cc.MoveTo:create(1, cc.p(topos.x, topos.y))
        local fade = cc.FadeIn:create(0.1)
        sprite:runAction(cc.Sequence:create(cc.DelayTime:create(0.1*i), fade, moveBackAction, cc.CallFunc:create(function() 
                sprite:stopAllActions()
                sprite:removeAllChildren()
                g.myFunc:safeRemoveNode(sprite)
                if i == 1 and isPatical then
                    cc.ParticleSystemQuad:create("gaple_dian.plist")
                        :pos(topos.x, topos.y)
                        :addTo(self.animNode)
                end
            end)))

        local lightRes = "image/gaple/coin_light_user.png"

        local light = display.newSprite(lightRes)
            :pos(frompos.x, frompos.y)
            :opacity(0)
            :addTo(self.animNode)
        light:runAction(cc.Sequence:create(cc.DelayTime:create(0.1*i + 0.1), 
            cc.Spawn:create(cc.FadeIn:create(1), cc.MoveTo:create(1, cc.p(topos.x, topos.y))),
            cc.CallFunc:create(function() 
                if i == 1 then
                    light:runAction(cc.Sequence:create(cc.DelayTime:create(1.2), cc.CallFunc:create(function() 
                            if light then
                                light:stopAllActions()
                                g.myFunc:safeRemoveNode(light)
                            end
                            if isPatical then
                                self:playCoinSmall_(topos, completeCallback)
                            end
                        end)))
                else
                    if light then
                        light:stopAllActions()
                        g.myFunc:safeRemoveNode(light)
                    end
                end
            end)))

    end
end

function MoneyTreeView:playCoinSmall_(pos, completeCallback)
    local resNameFormat = "newMoneyTreeAnimChip"
    if self.treeType == MoneyTreeView.GOLD then
        resNameFormat = "newMoneyTreeAnimGold"
    end
    local coin = display.newSprite("#" .. resNameFormat .. "1.png")
        :pos(pos.x, pos.y)
        :addTo(self.animNode)
    local frames = display.newFrames((resNameFormat .. "%d.png"), 1, 4)
    local animation = display.newAnimation(frames, 0.4/4)
    coin:runAction(cc.Sequence:create(cc.Animate:create(animation), cc.CallFunc:create(function()
            coin:stopAllActions()
            g.myFunc:safeRemoveNode(coin)
            if completeCallback then
                completeCallback()
            end
        end)))
end

function MoneyTreeView:stopPlayCoinMoveAvatarAnimIf()
    if self.animNode then
        self.animNode:stopAllActions()
        self.animNode:removeFromParent()
        self.animNode = nil
    end
end

function MoneyTreeView:setCoinButtonEnabled(button, enabled)
    if button then
        button:setButtonEnabled(enabled)
        if not enabled then
            button:opacity(255 * 1)
        else
            button:opacity(255)
        end
    end
end

function MoneyTreeView:playCollectStealCoinAnim(stealValue, coinNode, curFaceValue, completeCallback)
    if not coinNode then return end
    local stealFaceValue = self:getTransferAmount(stealValue, self.treeType)
    local coinLabel = display.newTTFLabel({
            text = "+" .. g.moneyUtil:splitMoney(stealFaceValue or 0), size = 30, color = cc.c3b(255, 255, 160)})
        :align(display.CENTER, 0, 20)
        :addTo(coinNode)
    coinNode:stopAllActions()
    coinNode:runAction(cc.Sequence:create(
        cc.CallFunc:create(function ()
                coinLabel:stopAllActions()
                coinLabel:runAction(cc.Sequence:create(cc.MoveBy:create(0.2, cc.p(0, 30))))
            end),
        cc.DelayTime:create(0.4),
        cc.CallFunc:create(handler(self, function ()
                if coinNode then
                    coinNode:stopAllActions()
                    self:playCoinAnim(coinNode, 0)
                    if coinLabel then
                        coinLabel:removeFromParent()
                    end
                    self:removeStealLbl(coinNode)
                    self:setCoinFaceString(coinNode, g.moneyUtil:splitMoney(curFaceValue or 0))
                    if completeCallback then
                        completeCallback()
                    end
                end
            end))
        ))
end

function MoneyTreeView:removeStealLbl(coinNode)
    local nodes = coinNode:getChildren()
    for i, node in pairs(nodes) do
        if node then
            if node:getTag() == CoinTag.STEAL_LBL or node:getTag() == CoinTag.STEAL_ICON then
                node:removeFromParent()
            end
        end
    end
end

function MoneyTreeView:setCoinFaceString(coinNode, curFaceValue)
    local nodes = coinNode:getChildren()
    for i, node in pairs(nodes) do
        if node then
            if node:getTag() == CoinTag.FACE_LBL then
                if self.treeType == MoneyTreeView.GOLD then
                    local faceAmount = self:getTransferAmount(curFaceValue, self.treeType)
                    node:setNumber(tostring(faceAmount), 4)
                else
                    node:setString(curFaceValue)
                end
            end
        end
    end
end

-- 邀请列表UiListView
local LIST_WIDTH = 276
local LIST_HEIGHT = 396
function MoneyTreeView:initMyInvitesList()
    self.myInvitesNode = display.newNode():pos(-488, -64):addTo(self)

    -- 邀请列表背景
    display.newSprite(g.Res.moneytree_rankBg)
        :pos(0, 0)
        :addTo(self.myInvitesNode)

    display.newSprite(g.Res.moneytree_friendRank)
        :pos(0, 258)
        :addTo(self.myInvitesNode)

    self.myInvitesListView = g.myUi.UIListView.new(LIST_WIDTH, LIST_HEIGHT)
        :pos(0, 18)
        :addTo(self.myInvitesNode)

    -- 邀请引导按钮(打开邀请页面)
    g.myUi.ScaleButton.new({normal = g.Res.common_btnYellowM})
        :setButtonLabel(display.newTTFLabel({size = 24, text = g.lang:getText("MONEYTREE", "INVITE")}))
        :onClick(handler(self.ctrl, self.ctrl.onInviteGuideButtonClick))
        :pos(0, -224)
        :addTo(self.myInvitesNode)

    -- 邀请列表底部栏目文字
    local inviteLbl = display.newTTFLabel({
            text = g.lang:getText("MONEYTREE", "INVITE"), size = 18, color = cc.c3b(255, 255, 255)})
        :align(display.CENTER, 0, -266)
        :addTo(self.myInvitesNode)
end

function MoneyTreeView:newMyInviteItem(itemParams, itemSize, outerId)
    local itemParams = itemParams or {}
    local item = display.newNode()

    local itemBgRes = g.Res.moneytree_rankItemBg
    if tonumber(itemParams.uid) == tonumber(g.user:getUid()) then
        itemBgRes = g.Res.moneytree_rankItemSelfBg
    end
    local itemBg = display.newSprite(itemBgRes):addTo(item)
    g.myUi.TouchHelper.new(itemBg, function (target, evt)
        self:onRankItemClick(target, evt, outerId, itemParams.uid)
    end)
        :enableTouch()
        :setTouchSwallowEnabled(false)
        :setMoveNoResponse(true)

    -- 用户头像
    g.myUi.AvatarView.new({
        radius = 39,
        gender = itemParams.gender,
        frameRes = g.Res.moneytree_imageFrameL,
        avatarUrl = itemParams.icon,
        clickOptions = {default = true, uid = itemParams.uid},
    })
        :pos(-88, 0)
        :addTo(item)

    -- 用户姓名
    display.newTTFLabel({
            text = g.nameUtil:getLimitName(itemParams.name, 12), size = 24, color = cc.c3b(255, 255, 255)})
        :align(display.LEFT_CENTER, -34, 30)
        :addTo(item)

    -- 摇钱树等级
    display.newSprite(g.Res.moneytree_rankTreeIcon):pos(-22, 0):addTo(item)
    display.newTTFLabel({
            text = "Lv." .. (itemParams.level or 0), size = 18, color = cc.c3b(108, 255, 0)})
        :align(display.LEFT_CENTER, -4, 0)
        :addTo(item)

    -- 用户金币/筹码
    display.newSprite(self.currencyMiniIconName):pos(-22, -30):addTo(item)
    local money = itemParams.money or 0
    if self.treeType == MoneyTreeView.GOLD then
        money = g.moneyUtil:formatGold(money, true)
    end
    display.newTTFLabel({
            text = g.moneyUtil:splitMoney(tonumber(money)), size = 18, color = cc.c3b(255, 255, 255)})
        :align(display.LEFT_CENTER, -5, -30)
        :addTo(item)

    -- 是否可偷取
    if tonumber(itemParams.isSteal) == 1 then
        display.newSprite(g.Res.moneytree_stealBg):pos(116, 28):addTo(item)
        display.newSprite(g.Res.moneytree_hand):pos(116 + 4, 28 + 3):addTo(item)
    end
    
    return item
end

function MoneyTreeView:onRankItemClick(target, evt, id, uid)
    if evt ~= g.myUi.TouchHelper.CLICK then return end
    if self.lastItemSelected then
        if self.myInvitesSelectedLbls and self.myInvitesSelectedLbls[self.lastItemSelected] then
            self.myInvitesSelectedLbls[self.lastItemSelected]:hide()
        end
    end
    if self.myInvitesSelectedLbls and self.myInvitesSelectedLbls[id] then
        self.myInvitesSelectedLbls[id]:show()
    end
    self.lastItemSelected = id
    self.ctrl:requestTreeInfo(handler(self, self.onRequestTreeInfoSucc), nil, true, uid)

    -- g.audio:playSound(g.Audio.Effects.CLICK_BUTTON)
end

function MoneyTreeView:hideItemSelected()
    if self.lastItemSelected then
        if self.myInvitesSelectedLbls and self.myInvitesSelectedLbls[self.lastItemSelected] then
            self.myInvitesSelectedLbls[self.lastItemSelected]:hide()
        end
    end
end

local GuideStep = {}
GuideStep.FIRST_STEP = 1
GuideStep.SHOW_STEP_ONE = 1
GuideStep.FINAL_STEP = 1
function MoneyTreeView:checkNeedGuide()
    -- 如果没有引导过, 进入引导
    if not guided then
        self:setGuideClickPrompt(nil, handler(self, self.showNextGuide))
        self:showGuideStep()
    end
end

function MoneyTreeView:showNextGuide()
    if self.curGuideStep then
        self.curGuideStep = self.curGuideStep + 1
        self:showGuideStep(self.curGuideStep)
    end
end

function MoneyTreeView:showGuideStep(guideStep)
    self.curGuideStep = guideStep or GuideStep.FIRST_STEP
    if self.lastGuideNode then
        self.lastGuideNode:removeFromParent()
        self.lastGuideNode = nil
    end
    if self.curGuideSchedId then g.mySched:cancel(self.curGuideSchedId) end
    if self.curGuideStep <= GuideStep.FINAL_STEP then
        self.curGuideSchedId = g.mySched:doDelay(handler(self, self.showNextGuide), 5.5)
    end
    
    local mountNode = display.newNode():addTo(self, 1)
    self.lastGuideNode = mountNode
    if self.curGuideStep == GuideStep.SHOW_STEP_ONE then
        local node1 = display.newNode():pos(-142 + 398, -238):addTo(mountNode):scale(0)
        display.newSprite(g.Res.moneytree_guideTipArrow):pos(-154 + 198, -28):addTo(node1)
        display.newScale9Sprite(g.Res.moneytree_guideTipBg, 0, 0, cc.size(180, 55))
            :addTo(node1)
        display.newTTFLabel({
                text = g.lang:getText("MONEYTREE", "INVITE_DESC2"), size = 18, color = cc.c3b(255, 255, 255), align = cc.TEXT_ALIGNMENT_CENTER})
            :align(display.CENTER, 0, 0)
            :addTo(node1)

        -- local node2 = display.newNode():pos(260, -240):addTo(mountNode):scale(0)
        -- display.newScale9Sprite(g.Res.moenytree_descBgBoarder, 0, 0, cc.size(186, 100))
        --     :addTo(node2)
        -- display.newSprite(g.Res.moenytree_descBgLinker):pos(108, 0):addTo(node2):rotation(180)
        -- display.newTTFLabel({
        --         text = g.lang:getText("MONEYTREE", "INVITE_DESC"), size = 18, color = cc.c3b(255, 255, 255), align = cc.TEXT_ALIGNMENT_CENTER})
        --     :align(display.CENTER, 0, 0)
        --     :addTo(node2)

        node1:stopAllActions()
        node1:runAction(cc.Sequence:create({
            cc.DelayTime:create(0.5),
            cc.ScaleTo:create(0.15, 1.1),
            cc.ScaleTo:create(0.1, 1.0),
            cc.CallFunc:create(function ()
                -- 引导结束
            end)
        }))
        -- node2:stopAllActions()
        -- node2:runAction(cc.Sequence:create({
        --     cc.DelayTime:create(0.5),
        --     cc.ScaleTo:create(0.15, 1.1),
        --     cc.ScaleTo:create(0.1, 1.0)
        -- }))
    else
        self:setGuideClickPrompt(false)
    end
end

function MoneyTreeView:onRequestTreeInfoSucc(data)
    local treeUid = data.treeUid
    
    if tonumber(treeUid) == tonumber(g.user:getUid()) then
        data = {
            treeUid = g.user:getUid(),
            info = {
                own = {
                    dyInfo = {{
                        name = "MuMu",
                        text = "?????????????",
                        time = 1574308156,
                        type = 2,
                    }},
                    exp = 6,
                    isWater = 1,
                    level = 1,
                    maxExp = 50,
                    ownPokerMoney = 140,
                    timerMoney = 0,
                    timerTxt = "18:00??????????????",
                    timerVal = 10000,
                    waterMoney = 0,
                    waterMoneyCount = 1,
                }
            },
            ret = 0
        }
        self:onRequestMyTreeInfoSucc(data)
    else
        data = {
            treeUid = g.user:getUid(),
            info = {
                own = {
                    dyInfo = {{
                        name = "MuMu",
                        text = "?????????????",
                        time = 1574308156,
                        type = 2,
                    }},
                    exp = 6,
                    isWater = 1,
                    level = 1,
                    maxExp = 50,
                    ownPokerMoney = 140,
                    timerMoney = 0,
                    timerTxt = "18:00??????????????",
                    timerVal = 10000,
                    waterMoney = 0,
                    waterMoneyCount = 1,
                },
                vsInfo = {
                    {takeMoney = 10, waterCount = 2},
                    {uid = 123, icon = "", name = "some name", gender = 0, money = 100, takeMoney = 12, waterCount = 1},
                }
            },
            ret = 0
        }
        self:onRequestOtherTreeInfoSucc(data, treeUid)
    end
end

function MoneyTreeView:onRequestMyTreeInfoSucc(data)
    local data = data or {}
    local dataInfo = data.info or {}
    local dataOwnInfo = dataInfo.own or {}
    local dataDyInfo = dataOwnInfo.dyInfo or {}
    -- printVgg("MoneyTreeView:onRequestMyTreeInfoSucc dump(data)", dump(data))
    -- printVgg("MoneyTreeView:onRequestMyTreeInfoSucc dump(dataInfo.friend)", dump(dataInfo.friend))
    self.myTreeInfoData = data
    self:showTreeView(g.user:getUid())
    self:updateMyDynamicsPanel(dataDyInfo)
    if tonumber(self:getCurTreeShowUid()) == tonumber(g.user:getUid()) then
        if dataOwnInfo then
            self:setCanWater(tonumber(dataOwnInfo.isWater) == 1)
        end
        self:playCoinSrcDescAnim(dataInfo.friend)
    end
end

function MoneyTreeView:onRequestOtherTreeInfoSucc(data, uid)
    local data = data or {}
    local dataInfo = data.info or {}
    local dataVsInfo = dataInfo.vsInfo or {}
    local dataOwnInfo = dataInfo.own or {}

    -- printVgg("onRequestOtherTreeInfoSucc dataInfo", uid, dump(dataInfo))
    -- printVgg("onRequestOtherTreeInfoSucc vsInfo", uid, dump(dataVsInfo))
    self:updateVsPanel(self.vsMyNode, self.vsMyAttrs, {
        uid = g.user:getUid(),
        icon = g.user:getIconUrl(),
        name = g.user:getName(),
        gender = g.user:getGender(),
        currencyCount = dataVsInfo[1].money,
        treeLevel = self.myTreeLevel,
        progress = 0.32,
        moneyStealDesc = g.lang:getText("MONEYTREE", "YOU_GET_HIM"),
        moneyStealCount = dataVsInfo[1].takeMoney,
        waterDesc = g.lang:getText("MONEYTREE", "YOU_WATER_HIM"),
        waterCount = dataVsInfo[1].waterCount,
    })
    self:updateVsPanel(self.vsHisNode, self.vsHisAttrs, {
        uid = dataVsInfo[2].uid,
        icon = dataVsInfo[2].icon,
        name = dataVsInfo[2].name,
        gender = dataVsInfo[2].gender,
        currencyCount = dataVsInfo[2].money,
        treeLevel = dataOwnInfo.level,
        progress = (dataOwnInfo.exp or 0)/(dataOwnInfo.maxExp or 1),
        moneyStealDesc = g.lang:getText("MONEYTREE", "HE_GET_YOU"),
        moneyStealCount = dataVsInfo[2].takeMoney,
        waterDesc = g.lang:getText("MONEYTREE", "HE_WATER_YOU"),
        waterCount = dataVsInfo[2].waterCount,
    })
    self.otherTreeInfoData = data
    self:showTreeView(uid)

    -- 好友红点
    if dataOwnInfo and tonumber(self:getCurTreeShowUid()) == tonumber(dataOwnInfo.uid) then
        self:setCanWater(tonumber(dataOwnInfo.isWater) == 1)
    end
end

function MoneyTreeView:onRequestWaterTreeSucc(data)
    dump(data, "hh")
    local treeUid = data.treeUid
    
    if tonumber(treeUid) == tonumber(g.user:getUid()) then
        data = {
            treeUid = g.user:getUid(),
            info = {
                incExp = 1,
                level = 2,
                exp = 7,
                maxExp = 50,
                waterMoney = 10,
                waterMoneyCount = 12,
            },
            ret = 0
        }
        self:onRequestWaterMyTreeSucc(data)
    else
        data = {
            treeUid = g.user:getUid(),
            info = {
                incExp = 2,
                level = 2,
                exp = 8,
                maxExp = 50,
                waterMoney = 10,
                waterMoneyCount = 13,
            },
            ret = 0
        }
        self:onRequestWaterOtherTreeSucc(data, treeUid)
    end
end

function MoneyTreeView:onRequestWaterMyTreeSucc(data)
    local data = data or {}
    local dataInfo = data.info or {}
    -- printVgg("onRequestWaterMyTreeSucc dump(data)", dump(data))
    self:playWaterAnim(handler(self, function ()
        self:playAddExpAnim(dataInfo.incExp)
        self:updateTreeLevelInfo(dataInfo.level, dataInfo.moneyExp, dataInfo.maxExp)
        self:refreshWaterCoin(dataInfo)
    end))

    if dataInfo and tonumber(self:getCurTreeShowUid()) == tonumber(g.user:getUid()) then
        self:setCanWater(tonumber(dataInfo.isWater) == 1)
    end
end

function MoneyTreeView:refreshWaterCoin(dataInfo)
    -- 更新
    self:setWaterMoneyAward(dataInfo.waterMoney)
    local str = g.moneyUtil:splitMoney(dataInfo.waterMoney or 0)
    if tonumber(dataInfo.waterMoney or 0) <= 0 then
        str = tonumber(dataInfo.waterMoneyCount or 0) .. "/5"
    end
    self:setCoinFaceString(self.waterCoin, str)
    if tonumber(self:getCurTreeShowUid()) == tonumber(g.user:getUid()) then
        if tonumber(dataInfo.waterMoney or 0) > 0 then
            self:setCoinButtonEnabled(self.waterCoin, true)
        end
    end
end

function MoneyTreeView:onRequestWaterOtherTreeSucc(data, uid)
    local data = data or {}
    local dataInfo = data.info or {}
    -- printVgg("onRequestWaterOtherTreeSucc 111 dump(data)", dump(data))
    self:playWaterAnim(handler(self, function ()
        self:playAddExpAnim(dataInfo.incExp)
        self:updateTreeLevelInfo(dataInfo.level, dataInfo.exp, dataInfo.maxExp)
        self:updateVsWaterCountLbl(dataInfo.waterCount)
        self:refreshWaterCoin(dataInfo)
    end))

    if dataInfo and tonumber(self:getCurTreeShowUid()) == tonumber(dataInfo.uid) then
        self:setCanWater(tonumber(dataInfo.isWater) == 1)
    end
end

function MoneyTreeView:onRequestRankListSucc(data)
    local data = {
		info = {
			{
                uid = 123,
                gender = 0,
                icon = "",
                name = "some name",
                money = 100,
                level = 1,
                isSteal = 0,
        
            },
            {
                uid = g.user:getUid(),
                gender = g.user:getGender(),
                icon = "",
                name = g.user:getName(),
                money = g.user:getMoney(),
                level = 1,
                isSteal = 1,
        
            },
		},
		ret = 0
	}
    -- printVgg("MoneyTreeView:onRequestRankListSucc dump(data)", dump(data))
    local dataInfo = data.info or {}

    if self.myInvitesListView then
        self.myInvitesListView:removeAllItems()
    end

    local itemHeight = 98
    self.myInvitesSelectedLbls = {}
    for i, v in ipairs(dataInfo) do
        local itemView = self:newMyInviteItem(v, cc.size(LIST_WIDTH, itemHeight), i)
        self.myInvitesSelectedLbls[i] = display.newSprite(g.Res.moneytree_selected):addTo(itemView):hide()
        if tonumber(v.uid) == tonumber(self:getCurTreeShowUid())  then
            self.myInvitesSelectedLbls[i]:show()
            self.lastItemSelected = i
        end

        itemView:pos(LIST_WIDTH/2, itemHeight/2)
        self.myInvitesListView:addNode(itemView, LIST_WIDTH, itemHeight)
    end
end

function MoneyTreeView:onBindCodeSucc()
    self.ctrl:requestRankList(handler(self, self.onRequestRankListSucc))
    self.ctrl:requestTreeInfo(handler(self, self.onRequestTreeInfoSucc))
end

function MoneyTreeView:showMoneyTreeInvitePopup()
    local inviteView = MoneyTreeInviteView.new(self.treeType, self):show()
    inviteView:setCtrl(self.ctrl, true)
end


function MoneyTreeView:onHomeClick()
    self:hideItemSelected()
    self:showTreeView(g.user:getUid(), true)
end

function MoneyTreeView:requestCallback(data)
    if data then
        if data.ret == 0 then
            local info = data.info
            local title = info.title or ""
            local description = info.desc
            local url = info.url
            if title and description and url then
                g.native:socialShare(title, description .. " " .. url)
            end
        end
    end
end

function MoneyTreeView:getTransferAmount(amount, treeType)
    local transferAmount = amount
    if treeType == MoneyTreeView.GOLD then
        transferAmount = g.moneyUtil:formatGold(amount or 0, true)
    end
    return transferAmount
end

function MoneyTreeView:setForbidOperation(isForbidden)
    if isForbidden == true then
        if not self.noOperationCover then
            self.noOperationCover = display.newScale9Sprite(g.Res.blank, 0, -46, cc.size(1282, 635))
                :addTo(self, 99)
            g.myUi.TouchHelper.new(self.noOperationCover, nil):enableTouch()
        end
        self.noOperationCover:show()
    else
        if self.noOperationCover then
            self.noOperationCover:hide()
        end
    end
end

function MoneyTreeView:setGuideClickPrompt(isShowCover, callback)
    if isShowCover == true then
        if not self.guideClickNextCover then
            self.guideClickNextCover = display.newScale9Sprite(g.Res.blank, 0, 0, cc.size(1029, 635))
                :addTo(self, 99)
            self.guideClickNextCover:setTouchEnabled(true)
            self.guideClickNextCover:setTouchSwallowEnabled(true)
            self.guideClickNextCover:addNodeEventListener(cc.NODE_TOUCH_EVENT, callback)
        end
        self.guideClickNextCover:show()
    else
        if self.guideClickNextCover then
            self.guideClickNextCover:hide()
        end
    end
end

function MoneyTreeView:showTreeView(uid, isReverse)
    local moveX = -120
    if isReverse then moveX = 120 end

    -- 首次展示树页面(自己的树UI)
    if not self.lastTrunkNode then
        self.lastTrunkNode = self:newTrunkNode(self.myTreeInfoData, true):addTo(self):hide()
        self:playTrunkShowAnimIf(self.lastTrunkNode, cc.p(0, 0), cc.p(0, 0))
        self:showMyTreeOtherUIs()
        self:setCurTreeShowUid(tonumber(uid))
        return
    end

    if self:getCurTreeShowUid() == tonumber(uid) then return end

    -- 创建新的树
    local data = self.otherTreeInfoData
    local isSelf = false
    if tonumber(uid) == tonumber(g.user:getUid()) then
        data = self.myTreeInfoData
        isSelf = true
    end
    self.curTrunkNode = self:newTrunkNode(data, isSelf):addTo(self):hide()

    -- trunk动画
    self:playTrunkHideAnimIf(self.lastTrunkNode, cc.p(0, 0), cc.p(0 - moveX, 0), handler(self, function ()
        self.lastTrunkNode = self.curTrunkNode
        self:playTrunkShowAnimIf(self.curTrunkNode, cc.p(moveX, 0), cc.p(0, 0), handler(self, function ()
            self.lastTrunkNode = self.curTrunkNode
        end))
    end), true)

    -- other UIs
    if self:getCurTreeShowUid() ~= tonumber(g.user:getUid()) then
        if tonumber(uid) == tonumber(g.user:getUid()) then
            self:showMyTreeOtherUIs()
            self:hideOtherTreeOtherUIs()
        end
    else
        self:stopPlayCoinSrcDescAnimIf()
        if tonumber(uid) ~= tonumber(g.user:getUid()) then
            self:showOtherTreeOtherUIs()
            self:hideMyTreeOtherUIs()
        end
    end

    self:stopWaterAnimIf()
    self:stopPlayCoinMoveAvatarAnimIf()

    self:setCurTreeShowUid(tonumber(uid))
end

function MoneyTreeView:newTrunkNode(data, isSelf)
    -- printVgg("newTrunkNode dump(data)", dump(data))
    local data = data or {}
    local dataInfo = data.info or {}
    local dataInfoOwn = dataInfo.own or {}

    local trunkNode = display.newNode():hide()
    trunkNode:setCascadeOpacityEnabled(true)
    local treeLevel = tonumber(dataInfoOwn.level)
    if isSelf then
        self.myTreeLevel = treeLevel
    end
    local treeTrunkRes = string.format(g.Res.moneytree_treeFormat, math.floor((treeLevel + 1)/2))
    display.newSprite(treeTrunkRes):pos(-10, -88):addTo(trunkNode)
		--[[
    -- 渲染浇水金币
    self:setWaterMoneyAward(dataInfoOwn.waterMoney or 0)
    local waterCoin = self:newWaterCoin(dataInfoOwn.waterMoneyCount or 0, dataInfoOwn.waterMoney or 0, isSelf)
        :pos(0, 182)
        :addTo(trunkNode)
    self:playCoinAnim(waterCoin, 0.1)
    self.waterCoin = waterCoin
    if self.treeType == MoneyTreeView.GOLD then
        self.waterCoin:hide()  
    end

    -- 渲染邀请金币
    local inviteCoin = self:newInviteCoin(dataInfoOwn.invitedMoney or 0, isSelf)
        :pos(-130, 144)
        :addTo(trunkNode)
    self:playCoinAnim(inviteCoin, 0.2)
    if self.treeType == MoneyTreeView.GOLD then
        inviteCoin:hide()  
    end

    -- 渲染充值金币
    local creditCoin = self:newCreditCoin(dataInfoOwn.creditMoney or 0, isSelf)    
        :pos(132, 148)
        :addTo(trunkNode)
    self:playCoinAnim(creditCoin, 0.3)
    if self.treeType == MoneyTreeView.GOLD then
        creditCoin:hide()  
    end

    -- 渲染好友贡献金币
    self:renderCoins(dataInfo.friend or {}, trunkNode)
		--]]
    -- 树等级经验条
    self:updateTreeLevelInfo(dataInfoOwn.level, dataInfoOwn.exp, dataInfoOwn.maxExp)

    return trunkNode
end

function MoneyTreeView:setCurTreeShowUid(uid)
    self.curTreeShowUid = uid
end

function MoneyTreeView:getCurTreeShowUid()
    return self.curTreeShowUid
end

function MoneyTreeView:getTreeType()
	return self.treeType
end

function MoneyTreeView:setWaterMoneyAward(money)
    self.awardWaterMoney = money
end

function MoneyTreeView:getWaterMoneyAward()
    return self.awardWaterMoney
end

function MoneyTreeView:setCanWater(canWater)
    self.canWater = canWater
    if self.canWater then
        self.waterRedDot:show()
    else
        self.waterRedDot:hide()
    end
end

function MoneyTreeView:getCanWater()
    return self.canWater
end

function MoneyTreeView:showMyTreeOtherUIs()
    self:playStaticShowAnimIf({self.myInfoNode, self.myDynamicsNode})
    if self.myDynamicsListView then
        self.myDynamicsListView:show()
    end
    if self.myTreeViewNode then
        self.myTreeViewNode:show()
    end
end

function MoneyTreeView:hideMyTreeOtherUIs()
    self:playStaticHideAnimIf({self.myInfoNode, self.myDynamicsNode})
    if self.myDynamicsListView then
        self.myDynamicsListView:hide()
    end
    if self.myTreeViewNode then
        self.myTreeViewNode:hide()
    end
end

function MoneyTreeView:showOtherTreeOtherUIs()
    self:playStaticShowAnimIf({self.compareNode})
    if self.vsHisAttrs and self.vsHisAttrs.headerImage then
        self.vsHisAttrs.headerImage:show()
    end
    if self.vsMyAttrs and self.vsMyAttrs.headerImage then
        self.vsMyAttrs.headerImage:show()
    end
    if self.otherTreeViewNode then
        self.otherTreeViewNode:show()
    end
end

function MoneyTreeView:hideOtherTreeOtherUIs()
    self:playStaticHideAnimIf({self.compareNode})
    if self.vsHisAttrs and self.vsHisAttrs.headerImage then
        self.vsHisAttrs.headerImage:hide()
    end
    if self.vsMyAttrs and self.vsMyAttrs.headerImage then
        self.vsMyAttrs.headerImage:hide()
    end
    if self.otherTreeViewNode then
        self.otherTreeViewNode:hide()
    end
end

function MoneyTreeView:playStaticShowAnimIf(nodeList, completeCallback)
    for i, node in pairs(nodeList) do
        if node then
            node:stopAllActions()
            node:runAction(cc.Sequence:create({
                cc.CallFunc:create(function ()
                    node:opacity(255 * 0.3)
                    node:show()
                end),
                cc.FadeIn:create(0.6),
                cc.CallFunc:create(function ()
                    if completeCallback then
                        completeCallback()
                    end
                end)
            }))
        end
    end
end

function MoneyTreeView:playStaticHideAnimIf(nodeList, completeCallback)
    for i, node in pairs(nodeList) do
        if node then
            node:stopAllActions()
            node:runAction(cc.Sequence:create({
                cc.CallFunc:create(function ()
                    -- node:show()
                    -- node:opacity(255)
                end),
                cc.FadeOut:create(0.6),
                cc.CallFunc:create(function ()
                    if completeCallback then
                        completeCallback()
                    end
                end)
            }))
        end
    end 
end

function MoneyTreeView:playTrunkShowAnimIf(treeNode, srcPos, destPos, completeCallback)
    if treeNode then
        treeNode:stopAllActions()
        treeNode:runAction(cc.Sequence:create({
            cc.CallFunc:create(function ()
                treeNode:opacity(0)
                treeNode:pos(srcPos.x, srcPos.y)
                treeNode:show()
            end),
            cc.Spawn:create({
                cc.FadeIn:create(0.4),
                cc.MoveTo:create(0.4, cc.p(destPos.x, destPos.y))
            }),
            cc.CallFunc:create(function ()
                if completeCallback then
                    completeCallback()
                end
            end)
        }))
    end 
end

function MoneyTreeView:playTrunkHideAnimIf(treeNode, srcPos, destPos, completeCallback, isRemove)
    if treeNode then
        treeNode:stopAllActions()
        treeNode:runAction(cc.Sequence:create({
            cc.CallFunc:create(function ()
                treeNode:opacity(255)
                treeNode:pos(srcPos.x, srcPos.y)
                treeNode:show()
            end),
            cc.Spawn:create({
                cc.FadeOut:create(0.4),
                cc.MoveTo:create(0.4, cc.p(destPos.x, destPos.y))
            }),
            cc.CallFunc:create(function ()
                if completeCallback then
                    completeCallback()
                end
                if isRemove then
                    treeNode:removeFromParent()
                    treeNode = nil
                end
            end)
        }))
    end 
end

function MoneyTreeView:playAddExpAnim(deltaExp)
    local deltaExp = deltaExp or 0
    if deltaExp <= 0 then return end
    local addExpLbl =display.newTTFLabel({text = "+" .. deltaExp .. " exp", size = 24, color = cc.c3b(108, 255, 0)})
        :pos(22 + 52, -212 + 40)
        :addTo(self, 1)
        :hide()
    local spwanAction = cc.Spawn:create(
        cc.MoveBy:create(0.4, cc.p(0, 20)),
        cc.FadeOut:create(0.4)
    )
    addExpLbl:stopAllActions()
    addExpLbl:runAction(cc.Sequence:create({
        cc.CallFunc:create(function ()
            addExpLbl:show()
        end),
        cc.MoveBy:create(0.4, cc.p(0, 20)),
        spwanAction,
        cc.CallFunc:create(handler(self, function ()
                if addExpLbl then
                    addExpLbl:stopAllActions()
                    addExpLbl:removeFromParent()
                end
                if completeCallback then
                    completeCallback()
                end
            end)),
    }))
end

function MoneyTreeView:playWaterAnim(completeCallback)
    if not self.waterNode then
        self.waterNode = display.newNode():pos(0, 0):addTo(self)
    end

    local waterPos = cc.p(22, -212)
    
    local can = display.newSprite(g.Res.moneytree_can)
        :pos(waterPos.x + 52, waterPos.y + 40)
        :addTo(self.waterNode, 1)
        :hide()

    local waterStream = display.newSprite("#tree_water_1.png")
        :pos(waterPos.x, waterPos.y)
        :addTo(self.waterNode, 1)
        :hide()

    local playWaterStreamAnim = function (waterStream)
        local frames = display.newFrames("tree_water_%d.png", 1, 5)
        local animation = display.newAnimation(frames, 0.5/5)
        waterStream:show()
        waterStream:runAction(cc.Sequence:create(cc.Animate:create(animation), cc.CallFunc:create(function()
                waterStream:runAction(cc.Sequence:create(cc.Animate:create(animation), cc.CallFunc:create(function()
                    waterStream:runAction(cc.Sequence:create(cc.Animate:create(animation), cc.CallFunc:create(function()
                        waterStream:stopAllActions()
                        g.myFunc:safeRemoveNode(waterStream)
                        can:stopAllActions()
                        can:runAction(cc.Sequence:create({
                            cc.FadeOut:create(0.3),
                            cc.DelayTime:create(0.2),
                            cc.CallFunc:create(function ()
                                g.myFunc:safeRemoveNode(can)
                                if completeCallback then
                                    completeCallback()
                                end
                            end)
                        }))
                    end)))
                end)))
            end)))
    end

    can:stopAllActions()
    can:runAction(cc.Sequence:create({
        cc.CallFunc:create(function ()
            can:opacity(0)
            can:show()
        end),
        cc.FadeIn:create(0.3),
        cc.RotateBy:create(0.4, -45),
        cc.CallFunc:create(function ()
            playWaterStreamAnim(waterStream)
        end)
    }))
end

function MoneyTreeView:stopWaterAnimIf()
    if self.waterNode then
        self.waterNode:stopAllActions()
        self.waterNode:removeFromParent()
        self.waterNode = nil
    end
end

function MoneyTreeView:playCoinSrcDescAnim(friendList)
    if type(friendList) ~= "table" then return end
    if table.nums(friendList) == 0 then return end
    if table.nums(friendList) == 1 then 
        friendList[#friendList + 1] = friendList[1]
    end

    self:stopPlayCoinSrcDescAnimIf()
    if not self.myCoinSrcNode then
        self.myCoinSrcNode = display.newNode():pos(0, 0):addTo(self)
    end

    local recordCount = 1
    
    local tip = self:createCoinSrcDescTip(friendList[recordCount])
        :pos(-332, -246)
        :addTo(self.myCoinSrcNode)
    self.curCoinSrcDescTipCb = handler(self, function ()
        recordCount = recordCount or 1
        recordCount = recordCount + 1
        if recordCount > #friendList then
            recordCount = 1
        end
        local tip = self:createCoinSrcDescTip(friendList[recordCount])
            :pos(-332, -246)
            :addTo(self.myCoinSrcNode)
        self:startRunCoinSrcDescTipAction(tip, self.curCoinSrcDescTipCb)
    end)
    self:startRunCoinSrcDescTipAction(tip, self.curCoinSrcDescTipCb)
end

function MoneyTreeView:createCoinSrcDescTip(recordInfo)
    local node = display.newNode()

    local curXPos = 16
    -- 头像
    g.myUi.AvatarView.new({
        radius = 15,
        gender = g.user:getGender(),
        frameRes = g.Res.moneytree_imageFrameR,
        avatarUrl = recordInfo.icon,
        clickOptions = {default = true, uid = g.user:getUid()},
    })
    :pos(curXPos, 0)
    :addTo(node)
        
    curXPos = curXPos + 24

    -- 姓名
    local nameLbl = display.newTTFLabel({
            text = g.nameUtil:getLimitName(recordInfo.name, 14), size = 18, color = cc.c3b(32, 252, 255)})
        :align(display.LEFT_CENTER, curXPos, 0)
        :addTo(node)
    curXPos = curXPos + nameLbl:getContentSize().width + 4
    -- 产出Lbl
    local produceLbl = display.newTTFLabel({
            text = g.lang:getText("MONEYTREE", "PRODUCE"), size = 18, color = cc.c3b(133, 191, 255)})
        :align(display.LEFT_CENTER, curXPos, 0)
        :addTo(node)
    curXPos = curXPos + produceLbl:getContentSize().width + 20
    -- 金币/筹码小图标
    -- 用户金币/筹码
    local icon =display.newSprite(self.currencyMiniIconName):pos(curXPos, 0):addTo(node)
    curXPos = curXPos + icon:getContentSize().width
    local money = self:getTransferAmount(recordInfo.money, self.treeType)
    local moneyLbl = display.newTTFLabel({
            text = g.moneyUtil:splitMoney(tonumber(money)), size = 18, color = cc.c3b(255, 246, 3)})
        :align(display.LEFT_CENTER, curXPos, 0)
        :addTo(node)
    curXPos = curXPos + moneyLbl:getContentSize().width

    -- 背景
    display.newScale9Sprite(g.Res.moneytree_coinSrcRecordBg, 0, 0, cc.size(curXPos + 10 - 0, 30))
        :setAnchorPoint(cc.p(0, 0.5))
        :pos(0, 0)
        :addTo(node, -1)

    node:setCascadeOpacityEnabled(true)

    return node
end

function MoneyTreeView:stopPlayCoinSrcDescAnimIf()
    if self.myCoinSrcNode then
        self.myCoinSrcNode:stopAllActions()
        self.myCoinSrcNode:removeFromParent()
        self.myCoinSrcNode = nil
    end
end

function MoneyTreeView:startRunCoinSrcDescTipAction(node, nextCallback)
    local spawnAction = cc.Spawn:create({
        cc.MoveBy:create(0.6, cc.p(0, 34)),
        cc.FadeTo:create(0.6, 256 * 0.5)
    })
    local spawnAction2 = cc.Spawn:create({
        cc.MoveBy:create(0.6, cc.p(0, 34)),
        cc.FadeOut:create(0.6)
    })
    if not node then return end
    node:stopAllActions()
    node:opacity(0)
    node:runAction(cc.Sequence:create({
        cc.FadeIn:create(0.8),
        cc.DelayTime:create(1.2),
        spawnAction,
        -- cc.DelayTime:create(1),
        cc.CallFunc:create(handler(self, function ()
            if nextCallback then
                nextCallback()
            end
        end)),
        cc.DelayTime:create(1),
        spawnAction2,
        cc.CallFunc:create(handler(self, function ()
            if node then
                g.myFunc:safeRemoveNode(node)
                node = nil
            end
        end))
    }))
end

function MoneyTreeView:onClearPopup()
    if self.curGuideSchedId then g.mySched:cancel(self.curGuideSchedId) end
    display.removeSpriteFramesWithFile("image/activity/moneytree/tree_water.plist", "image/activity/moneytree/tree_water.png")
end

return MoneyTreeView

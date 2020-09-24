local MoneyTreeInviteView = class("MoneyTreeInviteView", g.myUi.Window)

local MoneyTreeCtrl = require("app.controller.activity.moneytree.MoneyTreeCtrl")
-- local FriendUtil = import("app.module.hall.popup.util.FriendUtil")

MoneyTreeInviteView.WIDTH = 1035
MoneyTreeInviteView.HEIGHT = 643

MoneyTreeInviteView.GOLD = "gold" -- 金币
MoneyTreeInviteView.CHIP = "money" -- 筹码

function MoneyTreeInviteView:ctor(treeType, moneyTreeViewObj)	
    self.treeType = treeType
    self.moneyTreeViewObj = moneyTreeViewObj

    MoneyTreeInviteView.super.ctor(self, {width = self.WIDTH, height = self.HEIGHT, bgRes = g.Res.moneytreeinvite_bg, isCoverClose = true})

	self:initUI()
    self:checkNeedGuide()
    -- self.friendUtil = FriendUtil.new()
end

function MoneyTreeInviteView:setCtrl(ctrl, createIfNull)
    self.ctrl = ctrl
    if ctrl == nil and createIfNull then
    	self.ctrl = MoneyTreeCtrl.new()
    end
end

function MoneyTreeInviteView:onShow()
	if self.ctrl then
    	self.ctrl:requestInviteCodeInfo(handler(self, self.onRequestInviteInfoSucc), nil, true)
    end
end

function MoneyTreeInviteView:initUI()
 	-- 关闭按钮
 	local closeBtn = g.myUi.ScaleButton.new({normal = g.Res.blank})
        :onClick(handler(self, self.close))
        :pos(474, 282)
        :setButtonSize(cc.size(70, 70))
        :addTo(self)

    display.newSprite(g.Res.moneytreeinvite_close)
    	:pos(474, 282)
        :addTo(self)

    self:initMyInvitePanel()
end

function MoneyTreeInviteView:initMyInvitePanel()
    local leftNode = display.newNode():pos(-380, -28):addTo(self)
    -- 我的邀请码文字
    display.newTTFLabel({
            text = g.lang:getText("MONEYTREE", "MY_CODE"), size = 28, color = cc.c3b(131, 192, 255)})
        :align(display.CENTER, 0, 278)
        :addTo(leftNode)
    -- 我的邀请码背景
    display.newSprite(g.Res.moneytreeinvite_codeBg)
        :pos(0, 208)
        :addTo(leftNode)
    -- 我的邀请码数字
    self.myCodeLbl = display.newTTFLabel({
            text = "", size = 36, color = cc.c3b(254, 255, 151)})
        :align(display.CENTER, 0, 208)
        :addTo(leftNode)
    -- 复制按钮
    g.myUi.ScaleButton.new({normal = g.Res.common_btnGreenB})
    	:setButtonLabel(display.newTTFLabel({text = g.lang:getText("COMMON", "COPY"), size = 36}))
        :onClick(handler(self, self.onCopyCodeClick))
        :pos(0, 108)
        :addTo(leftNode)

    -- 绑定好友提示文字
    self.bindTipsLbl = display.newTTFLabel({
            text = "", size = 28, color = cc.c3b(131, 192, 255)})
        :align(display.CENTER, 0, -40)
        :addTo(leftNode)
        :hide()

    -- 邀请码输入框
	self.editBox = g.myUi.EditBox.new({
            image = g.Res.moneytreeinvite_codeBg,
            imageOffset = cc.p(94, 0),
			size = cc.size(180, 54),
			fontColor = {R = 254, G = 255, B = 151},
			fontSize = 20,
			maxLength = 6,
			placeHolder = g.lang:getText("MONEYTREE", "INPUT_CODE"),
			holderColor = cc.c3b(64, 97, 179)
		})
		:pos(-94, -115)
		:addTo(leftNode)
        :hide()
	
    -- 绑定按钮
    self.bindButton = g.myUi.ScaleButton.new({normal = g.Res.Common_btn_green_big})
    	:setButtonLabel(display.newTTFLabel({text = g.lang:getText("MONEYTREE", "BIND_SIMPLE"), size = 36}))
        :onClick(handler(self, self.onBindCodeClick))
        :pos(0, -210)
        :addTo(leftNode)
        :hide()

    -- 邀请文字
    local infoRes = g.Res.moneytreeinvite_infoChip
    if self.treeType == MoneyTreeInviteView.GOLD then
        infoRes = g.Res.moneytreeinvite_infoGold
    end
    display.newSprite(infoRes):pos(154, 6):addTo(self)

    -- 邀请按钮
    g.myUi.ScaleButton.new({normal = g.Res.common_btnYellowB})
    	:setButtonLabel(display.newTTFLabel({text = g.lang:getText("MONEYTREE", "INVITE"), size = 36}))
        :onClick(handler(self, self.onInviteClick))
        :pos(134, -246)
        :addTo(self)
end

local GuideStep = {}
GuideStep.FIRST_STEP = 1
GuideStep.SHOW_STEP_ONE = 1
GuideStep.FINAL_STEP = 1
function MoneyTreeInviteView:checkNeedGuide()
    -- 金币场不弹提示
    if self.treeType == MoneyTreeInviteView.GOLD then return end
    -- 如果没有引导过, 进入引导
    if not guided then
        self:setGuideClickPrompt(true, handler(self, self.showNextGuide))
        self:showGuideStep()
    end
end

function MoneyTreeInviteView:onRequestInviteInfoSucc(data)
    -- printVgg("MoneyTreeInviteView:onRequestInviteInfoSucc: ", dump(data))
    local data = data or {}
    self.myInviteCode = data.code or 0

    if self.myCodeLbl then
        self.myCodeLbl:setString(data.code or 0)
    end

    if tonumber(data.isBind) == 1 then
        self:setBindedUi(data.bindInfo)
    else
        if self.bindButton then
            self.bindButton:show()
        end
        if self.editBox then
            self.editBox:show()
        end
        if self.bindTipsLbl then
            self.bindTipsLbl:setString(g.lang:getText("MONEYTREE", "BIND"))
            self.bindTipsLbl:show()
        end
    end
end

function MoneyTreeInviteView:requestBindCode(successCallback, failCallback)
    if self.httpBindCodeId then return end
    g.myUi.miniLoading:show()
    local param = {}
    param.cmd = "NewMoneyTree-friendInvited"
    param.param = {}
    param.param.type = self.treeType
    param.param.code = self.editBox:getText() or 0
    self.httpBindCodeId = poker.HttpService.POST(param,
        function(data)
            g.myUi.miniLoading:hide()
            self.httpBindCodeId = nil
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
            g.myUi.miniLoading:hide()
            -- dump(errCode)
            self.httpBindCodeId = nil
            if tonumber(errCode) == 28 or tonumber(errCode) == 7 then 
                g.myUi.topTip:showText(g.lang:getText("HTTP", "TIMEOUT"))
            end
        end))
end

function MoneyTreeInviteView:onCopyCodeClick()
	-- g.native:setClipData(self.myInviteCode or "")
	g.myUi.topTip:showText(g.lang:getText("COMMON", "COPY_SUCCESS"))
end

function MoneyTreeInviteView:onBindCodeClick()
    self:requestBindCode(handler(self, self.onBindCodeSucc), handler(self, self.onBindCodeFail))
end

function MoneyTreeInviteView:onInviteClick()
    -- g.user:requestInvite("tree", handler(self, self.requestCallback))
end

function MoneyTreeInviteView:requestCallback(data)
    if data then
        if data.ret == 0 then
            local info = data.info
            local title = info.title or ""
            local description = info.desc
            local url = info.url
            if title and description and url then
                -- g.native:socialShare(title, description .. " " .. url)
            end
        end
    end
end

function MoneyTreeInviteView:onBindCodeSucc(data)
    local data = data or {}
    local dataInfo = data.info or {}
    self:setBindedUi(dataInfo)
    if self.moneyTreeViewObj then
        self.moneyTreeViewObj:onBindCodeSucc()
    end
end

function MoneyTreeInviteView:onBindCodeFail(data)
    dump(data)
    local data = data or {}
    if type(data) == "table" then
        -- code(1) -- 参数有误
        -- code(2) -- 邀请码为空
        -- code(3) -- 不能绑定自己
        -- code(4) -- 邀请码有误
        -- code(5) -- 已经被绑定
        -- code(6) -- 不能相互绑定
        if tonumber(data.ret) == 2 or tonumber(data.ret) == 4 then
            g.myUi.topTip:showText(g.lang:getText("MONEYTREE", "CODE_NOT_EXIST"))
        else
            g.myUi.topTip:showText(g.lang:getText("MONEYTREE", "BIND_ERROR"))
        end
    end
end

function MoneyTreeInviteView:setBindedUi(dataInfo)
    local dataInfo = dataInfo or {}
    if self.bindButton then
        self.bindButton:hide()
    end
    if self.editBox then
        self.editBox:hide()
    end
    if not self.bindedUserNode then
    	g.myUi.AvatarView.new({
	        radius = 36,
	        gender = dataInfo.gender,
	        frameRes = g.Res.moenytree_avatarMask,
	        avatarUrl = dataInfo.icon,
            clickOptions = {default = true, uid = dataInfo.uid},
	    })
	        :pos(-380, -154)
	        :scale(1.2)
	        :addTo(self)

        display.newTTFLabel({
            text = g.nameUtil:getLimitName(dataInfo.name, 14), size = 24, color = cc.c3b(54, 177, 97)})
            :align(display.CENTER, 0, -64)
            :addTo(self.bindedUserNode)
        if self.bindTipsLbl then
            self.bindTipsLbl:setString(g.lang:getText("MONEYTREE", "BINDED"))
            self.bindTipsLbl:show()
        end
    end
end

function MoneyTreeInviteView:onBindCodeFail(data)
    dump(data)
    local data = data or {}
    if type(data) == "table" then
        -- code(1) -- 参数有误
        -- code(2) -- 邀请码为空
        -- code(3) -- 不能绑定自己
        -- code(4) -- 邀请码有误
        -- code(5) -- 已经被绑定
        -- code(6) -- 不能相互绑定
        if tonumber(data.ret) == 2 or tonumber(data.ret) == 4 then
            g.myUi.topTip:showText(g.lang:getText("MONEYTREE", "CODE_NOT_EXIST"))
        else
            g.myUi.topTip:showText(g.lang:getText("MONEYTREE", "BIND_ERROR"))
        end
    end
end

function MoneyTreeInviteView:showGuideStep(guideStep)
    self.curGuideStep = guideStep or GuideStep.FIRST_STEP
    if self.lastGuideNode then
        self.lastGuideNode:removeFromParent()
        self.lastGuideNode = nil
    end
    if self.curGuideSchedId then g.mySched:cancel(self.curGuideSchedId) end
    if self.curGuideStep <= GuideStep.FINAL_STEP then
        self.curGuideSchedId = g.mySched:doDelay(handler(self, self.showNextGuide), 5.5)
    end
    
    local mountNode = display.newNode():addTo(self)
    self.lastGuideNode = mountNode
    if self.curGuideStep == GuideStep.SHOW_STEP_ONE then
        local node1 = display.newNode():pos(-130, 86):addTo(mountNode):scale(0)
        display.newSprite(g.Res.moenytree_descBgLinker):pos(-154, 0):addTo(node1)
        display.newScale9Sprite(g.Res.moenytree_descBgBoarder, 0, 0, cc.size(280, 170))
            :addTo(node1)
        display.newTTFLabel({
                text = g.lang:getText("MONEYTREE", "COPY_DESC"), size = 18, color = cc.c3b(254, 255, 151), align = cc.TEXT_ALIGNMENT_CENTER})
            :align(display.CENTER, 0, 0)
            :addTo(node1)

        local node2 = display.newNode():pos(340, -242):addTo(mountNode):scale(0)
        display.newSprite(g.Res.moenytree_descBgLinker):pos(-108, 0):addTo(node2)
        display.newScale9Sprite(g.Res.moenytree_descBgBoarder, 0, 0, cc.size(186, 100))
            :addTo(node2)
        display.newTTFLabel({
                text = g.lang:getText("MONEYTREE", "INVITE_DESC"), size = 18, color = cc.c3b(254, 255, 151), align = cc.TEXT_ALIGNMENT_CENTER})
            :align(display.CENTER, 0, 0)
            :addTo(node2)

        node1:stopAllActions()
        node1:runAction(cc.Sequence:create({
            cc.DelayTime:create(0.5),
            cc.ScaleTo:create(0.15, 1.1),
            cc.ScaleTo:create(0.1, 1.0),
            cc.CallFunc:create(function ()
                -- 引导结束
            end)
        }))
        node2:stopAllActions()
        node2:runAction(cc.Sequence:create({
            cc.DelayTime:create(0.5),
            cc.ScaleTo:create(0.15, 1.1),
            cc.ScaleTo:create(0.1, 1.0)
        }))
    else
        self:setGuideClickPrompt(false)
    end
end

function MoneyTreeInviteView:showNextGuide()
    self.curGuideStep = self.curGuideStep + 1
    self:showGuideStep(self.curGuideStep)
end

function MoneyTreeInviteView:setGuideClickPrompt(isShowCover, callback)
    if isShowCover == true then
        if not self.guideClickNextCover then
            -- self.guideClickNextCover = display.newScale9Sprite(g.Res.blank, 0, 0, cc.size(1029, 635))
            self.guideClickNextCover = display.newScale9Sprite(g.Res.black, 0, 0, cc.size(1029, 635))
                :addTo(self, 99)
            
            self.guideClickNextCover:addNodeEventListener(cc.NODE_TOUCH_EVENT, callback)
            self.guideClickNextCover:setTouchEnabled(true)
            self.guideClickNextCover:setTouchSwallowEnabled(true)
        end
        self.guideClickNextCover:show()
    else
        if self.guideClickNextCover then
            self.guideClickNextCover:hide()
        end
    end
end

function MoneyTreeInviteView:onWindowRemove()
	if self.ctrl then
		self.ctrl:dispose()
	end
    if self.curGuideSchedId then g.mySched:cancel(self.curGuideSchedId) end
end

return MoneyTreeInviteView

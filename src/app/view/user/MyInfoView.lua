local MyInfoView = class("MyInfoView", function ()
    return display.newNode()
end)

function MyInfoView:ctor(mainViewObj)    
    self.mainViewObj = mainViewObj
    self:initialize()
end

function MyInfoView:initialize()
    -- 游戏号
    local curX = -70
    local idNameDescLbl = display.newTTFLabel({text = g.lang:getText("USER", "IDENTIFY_NAME"), size = 28, color = cc.c3b(237, 226, 201)})
        :pos(curX, 180)
        :addTo(self)
    -- 标志名
    curX = curX + idNameDescLbl:getContentSize().width/2 + 40
    local idNameLbl = display.newTTFLabel({text = g.user:getIdentifyName(), size = 28})
        :pos(curX, 180)
        :addTo(self)
    -- 复制
    curX = curX + idNameLbl:getContentSize().width/2 + 90
    local copyLbl = display.newTTFLabel({text = g.lang:getText("COMMON", "COPY"), size = 28, color = cc.c3b(237, 226, 201)})
    g.myUi.ScaleButton.new({normal = g.Res.common_btnBlueS})
        :setButtonLabel(copyLbl, cc.p(0, 4))
        :onClick(handler(self, self.onCopy))
        :pos(curX, 180)
        :addTo(self)

    -- 头像
    self.avatar = g.myUi.AvatarView.new({
            radius = 66,
            gender = g.user:getGender(),
            frameRes = g.Res.common_headFrame,
            avatarUrl = g.user:getIconUrl(),
            clickOptions = {enable = false},
        })
            :addTo(self)
            :pos(-170, 0)
    self.avatar:setFrameScale(0.87)
    display.newSprite(g.Res.common_cameraIcon)
        :pos(-230, -50)
        :scale(0.4)
        :addTo(self)

    -- 姓名
    self.name = display.newTTFLabel({text = g.user:getCatName(), size = 28, color = cc.c3b(237, 226, 201)})
        :setAnchorPoint(cc.p(0, 0.5))
        :pos(-70, 30)
        :addTo(self)

    -- 好友输入框
    self.nameEditBox = g.myUi.EditBox.new({
            image = g.Res.blank,
            imageOffset = cc.p(94, 0),
            size = cc.size(280, 54),
            fontColor = cc.c3b(254, 255, 151),
            fontSize = 20,
            maxLength = 20,
            holderColor = cc.c3b(64, 97, 179),
            callback = handler(self, self.onEditOk),
            beginCallback = handler(self, self.onStartEdit),
        })
        :pos(-70, 30)
        :addTo(self)

    -- 铅笔
    self.pencel = display.newSprite(g.Res.common_editIcon)
        :pos(170, 30)
        :scale(0.6)
        :addTo(self)

    -- 性别
    g.myUi.ScaleButton.new({normal = g.Res.common_headMask, scale = 0.5})
        :onClick(handler(self, self.onChangeGender))
        :pos(-50, -36)
        :addTo(self)

    self.gender0 = display.newSprite(g.Res.common_gender0):pos(-50, -36):addTo(self)
    self.gender1 = display.newSprite(g.Res.common_gender1):pos(-50, -36):addTo(self)
    -- 初始化
    self.curGender = g.user:getGender()
    self:changeToGender(self.curGender)
end

function MyInfoView:onStartEdit()
    self:hideWhenEditStart()
end

function MyInfoView:onChangeGender(gender) 
    self.curGender = 1 - self.curGender
    self:changeToGender(self.curGender)

    self:onRecordModify('gender', self.curGender)
    self.avatar:updateGender(self.curGender)
end

function MyInfoView:changeToGender(gender)
    if gender == 1 then
        self.gender0:hide()
        self.gender1:show()
    else
        self.gender0:show()
        self.gender1:hide()
    end
end

function MyInfoView:showWhenEditOk()
    if self.name then
        self.name:show()
    end
    if self.pencel then
        self.pencel:show()
    end
end

function MyInfoView:hideWhenEditStart()
    if self.name then
        self.name:hide()
    end
    if self.pencel then
        self.pencel:hide()
    end
end

function MyInfoView:onEditOk()
		local newName = self.nameEditBox:getText()
		-- reset edit name to empty
    if self.nameEditBox then
			self.nameEditBox:setText('')
		end
		
    if newName == "" or newName == g.user:getName() then
				self:showWhenEditOk()
        return
    end

    self.name:setString(newName)
    self:onRecordModify('nickname', newName)
    self:showWhenEditOk()
end

function MyInfoView:onRecordModify(...)
    if self.mainViewObj then
        self.mainViewObj:onRecordModify(...)
    end
end

function MyInfoView:onCopy()
    g.myUi.topTip:showText(g.lang:getText("COMMON", "COPY_SUCC"))
end

return MyInfoView

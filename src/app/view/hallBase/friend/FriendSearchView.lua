local FriendSearchView = class("FriendSearchView", function ()
    return display.newNode()
end)

function FriendSearchView:ctor(mainViewObj)  
    self.mainViewObj = mainViewObj
    self:initialize()
end

function FriendSearchView:initialize()
    -- 搜索好友
    display.newTTFLabel({
            text = g.lang:getText("FRIEND", "SEARCH_FRIEND"), size = 28, color = cc.c3b(0, 128, 128)})
        :pos(0, 160)
        :addTo(self)

    -- 好友输入框
    self.nameEditBox = g.myUi.EditBox.new({
            image = g.Res.moneytreeinvite_codeBg,
            imageOffset = cc.p(94, 0),
            size = cc.size(180, 54),
            fontColor = cc.c3b(254, 255, 151),
            fontSize = 20,
            maxLength = 20,
            placeHolder = g.lang:getText("FRIEND", "NAME_TIPS"),
            holderColor = cc.c3b(64, 97, 179)
        })
        :pos(-94, 80)
        :addTo(self)

    -- 搜索按钮
    g.myUi.ScaleButton.new({normal = g.Res.common_btnBlueS})
        :setButtonLabel(display.newTTFLabel({size = 24, text = g.lang:getText("FRIEND", "SEARCH")}))
        :onClick(handler(self, self.onSearchClick))
        :pos(0, -22)
        :addTo(self)
end

function FriendSearchView:showUserFoundNode(data)
    if not self.userFoundNode then
        self.userFoundNode = display.newNode():pos(0, -140):addTo(self)
    end
    self.userFoundNode:removeAllChildren()
    g.myUi.AvatarView.new({
            radius = 52,
            gender = data.gender,
            frameRes = g.Res.common_headFrame,
            avatarUrl = data.icon,
            clickOptions = {default = true, uid = data.uid},
        })
            :addTo(self.userFoundNode)
            :pos(-170, 0)
            :setFrameScale(0.67)

    display.newTTFLabel({text = g.nameUtil:getLimitName(data.nickname, 14), size = 28, color = cc.c3b(237, 226, 201)})
        :setAnchorPoint(cc.p(0, 0.5))
        :pos(-70, 20)
        :addTo(self.userFoundNode)

    display.newSprite(g.Res['common_gender' .. data.gender])
        :pos(-64, -20)
        :addTo(self.userFoundNode)
    g.myUi.ScaleButton.new({normal = g.Res.common_btnGreenB, scale = 0.7})
        :setButtonLabel(display.newTTFLabel({size = 28, text = g.lang:getText("FRIEND", "ADD")}))
        :onClick(function () self:onAddFriendClick(data.uid) end)
        :pos(200, 0)
        :addTo(self.userFoundNode)
    self.userFoundNode:show()
end

function FriendSearchView:hideUserFoundNode()
    if self.userFoundNode then
        self.userFoundNode:hide()
    end
end

function FriendSearchView:showUserNotFoundNode()
    if not self.userNotFoundNode then
        self.userNotFoundNode = display.newNode():addTo(self)

        display.newTTFLabel({
            text = g.lang:getText("FRIEND", "USER_NOT_FOUND"), size = 28, color = cc.c3b(128, 128, 128)})
        :pos(0, -140)
        :addTo(self.userNotFoundNode)
    end
    self.userNotFoundNode:show()
end

function FriendSearchView:hideUserNotFoundNode()
    if self.userNotFoundNode then
        self.userNotFoundNode:hide()
    end
end

function FriendSearchView:showSearchingNode()
    if not self.searchingTips then
        self.searchingTips = display.newSprite(g.Res.common_searchIcon)
            :addTo(self)
    end
    self.searchingTips:show()
    self.searchingTips:stopAllActions()
    self.searchingTips:pos(0, -140)
    self.searchingTips:runAction(cc.RepeatForever:create(
        cc.Sequence:create({
            cc.Spawn:create({
                cc.ScaleTo:create(0.8, 0.8),
                cc.MoveTo:create(0.8, cc.p(100, -140))
            }),
            cc.Spawn:create({
                cc.ScaleTo:create(0.8, 1),
                cc.MoveTo:create(0.8, cc.p(0, -140))
            }),
        })
    ))
end

function FriendSearchView:hideSearchingNode()
    if self.searchingTips then
        self.searchingTips:stopAllActions()
        self.searchingTips:hide()
    end
end

function FriendSearchView:onSearchClick()
    if not self.mainViewObj then return end
    
    local username = self.nameEditBox:getText()
    if not username or username == '' then
        g.myUi.topTip:showText(g.lang:getText("FRIEND", "USER_NAME_EMPTY"))
        return
    end

    self:hideUserFoundNode()
    self:hideUserNotFoundNode()
    self:showSearchingNode()

    local params = {}
    params.name = username
    params.fields = {'uid', 'nickname', 'gender', 'iconUrl'}

    self.mainViewObj:reqUserinfo(params,
        handler(self, self.onSearchOk),
        handler(self, self.onSearchFail))
end

function FriendSearchView:onSearchOk(data)
    self:hideSearchingNode()
    self:hideUserNotFoundNode()
    dump(data, "searched ok")
    self:showUserFoundNode(data)
end

function FriendSearchView:onSearchFail(data)
    self:hideSearchingNode()
    if data.ret == -1 then
        self:showUserNotFoundNode()
    end
    self:hideUserFoundNode()
end

function FriendSearchView:onAddFriendClick(friendUid)
    if self.mainViewObj then
        self.mainViewObj:onAddFriendClick(friendUid)
    end
end

return FriendSearchView

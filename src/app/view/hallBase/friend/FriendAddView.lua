local FriendAddView = class("FriendAddView", function ()
    return display.newNode()
end)

function FriendAddView:ctor(mainViewObj)
    self.mainViewObj = mainViewObj   
    self:initialize()
end

function FriendAddView:setCtrl(ctrl, createIfNull)
    self.ctrl = ctrl
    if ctrl == nil and createIfNull then
        self.ctrl = MoneyTreeCtrl.new()
    end
end

local LIST_WIDTH = 460
local LIST_HEIGHT = 620
function FriendAddView:initialize()
    self._addBg = display.newScale9Sprite(g.Res.black, 0, 0, cc.size(LIST_WIDTH + 16, LIST_HEIGHT + 16))
        :pos(0, 0)
        :addTo(self)
        :hide()
    self._friendAddView = g.myUi.UIListView.new(LIST_WIDTH, LIST_HEIGHT)
        :pos(0, 0)
        :addTo(self)
end

function FriendAddView:onUpdate(reqAddList)
	reqAddList = reqAddList or {}
    -- dump(reqAddList, "reqAddList")
    self._friendAddView:removeAllItems()

    if table.nums(reqAddList) <= 0 then
        self:showNoReqAddTips()
    else
        self:hideNoReqAddTips()
    end

    local itemHeight = 100
    for k, v in pairs(reqAddList) do
        local node = display.newNode()
        g.myUi.AvatarView.new({
            radius = 46,
            gender = v.gender,
            frameRes = g.Res.common_headFrame,
            avatarUrl = v.iconUrl,
            clickCallback = handler(self, function ()
                self:startChat(uid)
            end)
        })
            :addTo(node)
            :pos(50, 0)
            :setFrameScale(0.59)

        display.newTTFLabel({text = g.nameUtil:getLimitName(v.nickname, 14), size = 28, color = cc.c3b(237, 226, 201)})
            :setAnchorPoint(cc.p(0, 0.5))
            :pos(120, 0)
            :addTo(node)

        -- 接受按钮
        g.myUi.ScaleButton.new({normal = g.Res.common_btnBlueS})
        	:setButtonLabel(display.newTTFLabel({size = 24, text = g.lang:getText("FRIEND", "ACCEPT")}))
	        :onClick(handler(self, function(self) self:onAcceptClick(v.uid) end))
	        :pos(394, 0)
	        :addTo(node)

        -- 横向分割线
        if k ~= 1 then
            local line = cc.DrawNode:create()
            line:drawSegment(cc.p(10, 0), cc.p(LIST_WIDTH - 10, 0), 1, cc.c4f(0.8, 0.8, 0.8, 0.8))
            line:pos(0, itemHeight/2):addTo(node)
        end

        node:pos(0, itemHeight/2)
        self._friendAddView:addNode(node, LIST_WIDTH, itemHeight)
    end
end

function FriendAddView:onAcceptClick(requestUid)
    if not self.mainViewObj then return end

    local params = {}
    params.requestUid = requestUid

    self.mainViewObj:reqAcceptFriend(params,
        handler(self, self.onAcceptFriendOk),
        handler(self, self.onAcceptFriendFail))
end

function FriendAddView:onAcceptFriendOk(data)
    g.myUi.topTip:showText(g.lang:getText("FRIEND", "ADD_SUCC"))
end

function FriendAddView:onAcceptFriendFail(data)
    g.myUi.topTip:showText(g.lang:getText("FRIEND", "ADD_FAIL"))
end

function FriendAddView:showNoReqAddTips()
    if not self._noReqAddTips then
        self._noReqAddTips = display.newTTFLabel({text = g.lang:getText("FRIEND", "NO_REQ_ADD_TIPS"), size = 26, color = cc.c3b(137, 190, 224)})
            :pos(0, 0)
            :addTo(self)
            :hide()
    end
    self._noReqAddTips:show()
    if self._addBg then
        self._addBg:hide()
    end
end

function FriendAddView:hideNoReqAddTips()
    if self._noReqAddTips then
        self._noReqAddTips:hide()
    end
    if self._addBg then
        self._addBg:show()
    end
end

return FriendAddView

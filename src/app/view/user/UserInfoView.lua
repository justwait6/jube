local UserInfoView = class("UserInfoView", g.myUi.Window)

local MyInfoView = import(".MyInfoView")
-- local OtherUserInfoView = import(".OtherUserInfoView")

local UserCtrl = require("app.controller.user.UserCtrl")

UserInfoView.WIDTH = 1035
UserInfoView.HEIGHT = 643

local Tab = {}
Tab.LIST = 1
Tab.SEARCH = 2

function UserInfoView:ctor(uid)
    self.ctrl = UserCtrl.new() 
    UserInfoView.super.ctor(self, {width = self.WIDTH, height = self.HEIGHT, monoBg = true, bgColor = cc.c3b(40, 41, 35), isCoverClose = true})
    
    self:initialize(uid)
end

function UserInfoView:onShow()
    if self.ctrl then
    end
end

function UserInfoView:initialize(uid)
    -- Close
    self:addClose(cc.p(482, 288))

    -- 纵向分割线
    local line = cc.DrawNode:create()
    line:drawSegment(cc.p(0, 316), cc.p(0, -316), 2, cc.c4f(0.8, 0.8, 0.8, 0.8))
    line:pos(-430, 0):addTo(self)

    -- 侧边栏我的信息
    g.myUi.ScaleButton.new({normal = g.Res.common_baseInfoIcon, scale = 0.8})
        :onClick(handler(self, function () self:onTab(Tab.LIST) end))
        :pos(-476, 266)
        :addTo(self)

    -- 侧边栏搜索好友按钮
    g.myUi.ScaleButton.new({normal = g.Res.common_searchIcon, scale = 0.8})
        :onClick(handler(self, function () self:onTab(Tab.SEARCH) end))
        :pos(-476, 180)
		:addTo(self)
		
    self.myInfoView = MyInfoView.new(self):addTo(self):hide()
    if tonumber(uid) == g.user:getUid() then
        self.myInfoView:show()
    end
end

function UserInfoView:onTab(tab)
    if tab == Tab.LIST then
        if self.friendListView then self.friendListView:show() end
        if self.searchView then self.searchView:hide() end
    elseif tab == Tab.SEARCH then
        if self.friendListView then self.friendListView:hide() end
        if self.searchView then self.searchView:show() end
    end
end

function UserInfoView:onRecordModify(...)
    if self.ctrl then
        self.ctrl:onRecordModify(...)
    end
end

function UserInfoView:XXXX()
end

function UserInfoView:XXXX()
end

function UserInfoView:onWindowRemove()
    if self.ctrl then
        self.ctrl:checkUserInfoChange()
    end
end

return UserInfoView

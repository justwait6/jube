local AvatarView = class("AvatarView", function() 
	return display.newNode()
end)

local Gender = require("app.model.baseDef.Gender")
AvatarView.Gender = Gender
local Shape = require("app.model.baseDef.Shape")
AvatarView.Shape = Shape

local userMgr = require("app.model.user.UserManager").getInstance()

function AvatarView:ctor(params)
    local params = params or {}
    self.shape = params.shape or Shape.CIRCLE
    self.gender = tonumber(params.gender) or Gender.MALE
    self.avatarUrl = params.avatarUrl or self:getDefaultImage(self.gender)
	self.frameRes = params.frameRes
    self.clickCallback = params.clickCallback
    self.clickOptions = params.clickOptions
    self.uid = params.uid
    if self.shape == Shape.CIRCLE then
        self.radius = params.radius or 48
        self.avatarSize = cc.size(self.radius * 2, self.radius * 2)
    else
        self.length = params.length or 88
        self.avatarSize = cc.size(self.length, self.length)
    end

    self:initialize()
end

function AvatarView:initialize()
    if self.shape == Shape.CIRCLE then
        self:_createCircleAvatar()
    else
        self:_createSquareAvatar()
		end
		
    local avatarBtn = g.myUi.ScaleButton.new({normal = g.Res.blank})
        :onClick(handler(self, self._onAvatarClick))
        :setButtonSize(self.avatarSize)
				:addTo(self)
		if self.clickOptions and self.clickOptions.enable == false then
			avatarBtn:setButtonEnabled(false)
		end

    if self.frameRes then
        self.frame = display.newSprite(self.frameRes):addTo(self)
    end
end

function AvatarView:_createCircleAvatar()
    local stencil = display.newCircle(self.radius, {x = 0, y = 0, borderColor = cc.c4f(0, 0, 0, 0), borderWidth = 0})
    
    self._clippingNode = cc.ClippingNode:create():addTo(self)
    self._clippingNode:setStencil(stencil)

    self:_recreateAvatarSpriteIf()
end

function AvatarView:_createSquareAvatar()
    local stencil = cc.DrawNode:create()
    local w, h = self.avatarSize.width - 2, self.avatarSize.height - 2
    stencil:drawSolidRect(cc.p(-w/2, -h/2), cc.p(w/2, h/2), cc.c4f(0, 0, 0, 0))

    self._clippingNode = cc.ClippingNode:create():addTo(self)
    self._clippingNode:setStencil(stencil)

    self:_recreateAvatarSpriteIf()
end

function AvatarView:_recreateAvatarSpriteIf()
    if not self._avatarSprite then
        self._avatarSprite = display.newSprite(g.Res.blank):addTo(self._clippingNode)
        self._defaultAvatar0 = display.newSprite(g.Res.common_defaultWoman):scale(self.avatarSize.width/146):addTo(self._clippingNode)
        self._defaultAvatar1 = display.newSprite(g.Res.common_defaultMan):scale(self.avatarSize.width/146):addTo(self._clippingNode)
    end

    if self:isDefaultImage(self.avatarUrl) or self.avatarUrl == "" then
            self:_setDefaultAvatar(self.gender)
    else
        self:_setUrlAvatar(self.avatarUrl)
    end
end

function AvatarView:_setDefaultAvatar(gender)
    if tonumber(gender) == 0 then
        if self._defaultAvatar0 then self._defaultAvatar0:show() end
        if self._defaultAvatar1 then self._defaultAvatar1:hide() end
    else
        if self._defaultAvatar0 then self._defaultAvatar0:hide() end
        if self._defaultAvatar1 then self._defaultAvatar1:show() end
    end
    if self._avatarSprite then self._avatarSprite:hide() end
end

--[[
    @func _setUrlAvatar 设置url头像(若要设置默认头像, 请使用@func _setDefaultAvatar)
    @param url: 请求的url
--]]
function AvatarView:setAvatarTex(sprite)
    local size = sprite:getContentSize()
    local minImageLength = math.min(size.width, size.height)
    self._avatarSprite:setSpriteFrame(sprite:getSpriteFrame())
    self._avatarSprite:scale(self.avatarSize.width/minImageLength)
    if self._avatarSprite then self._avatarSprite:show() end
    if self._defaultAvatar0 then self._defaultAvatar0:hide() end
    if self._defaultAvatar1 then self._defaultAvatar1:hide() end
end
function AvatarView:_setUrlAvatar(url)
    self:_asyncGetAvatarSprite(url,
        function (sprite)
            local size = sprite:getContentSize()
            local minImageLength = math.min(size.width, size.height)
            self._avatarSprite:setSpriteFrame(sprite:getSpriteFrame())
            self._avatarSprite:scale(self.avatarSize.width/minImageLength)
            if self._avatarSprite then self._avatarSprite:show() end
            if self._defaultAvatar0 then self._defaultAvatar0:hide() end
            if self._defaultAvatar1 then self._defaultAvatar1:hide() end
        end,
        function ()
            -- 请求失败设置默认
            self:_setDefaultAvatar(self.gender)
        end)
end

function AvatarView:_onAvatarClick()
		if self.clickOptions and self.clickOptions.enable == false then
			return
		end

    self:_playClickAnim()
    if self.clickOptions and self.clickOptions.default then
        print('头像点击: 默认模式打开 uid: ', self.clickOptions.uid)
        userMgr:showUserInfoView(self.clickOptions.uid)
    end
    if self.clickCallback then
        self.clickCallback()
    end
end

function AvatarView:_playClickAnim()
    self:stopAllActions()
    self:scale(1)
    self:runAction(cc.Sequence:create({
        cc.ScaleTo:create(0.06, 0.96),
        cc.ScaleTo:create(0.06, 1),
    }))
end

function AvatarView:_asyncGetAvatarSprite(url, succCb, failCb)
    local imageId = g.imageLoader:nextLoaderId()
    g.imageLoader:loadAndCacheImage(imageId, g.myFunc:calcIconUrl(url), function(success, sprite)
        if success and sprite then
            if succCb then
                succCb(sprite)
            end
        else
            if failCb then
                failCb()
            end
        end
    end, g.imageLoader.CACHE_TYPE_USER_HEAD_IMG)
end

function AvatarView:setAvatarUrl(avatarUrl)
    if self.avatarUrl ~= avatarUrl then
        self.avatarUrl = avatarUrl or self:getDefaultImage(self.gender)
        self:_recreateAvatarSpriteIf()
    end
end

function AvatarView:updateGender(gender)
    if self.gender ~= gender then
        self.gender = gender
        if self:isDefaultImage(self.avatarUrl) or self.avatarUrl == "" then
            self:_setDefaultAvatar(self.gender)
        end
    end
end

function AvatarView:getDefaultImage(gender)
    local defaultImage
    gender = tonumber(gender)
    if gender == Gender.MALE or gender == "m" then
        defaultImage = g.Res.common_defaultMan
    else
        defaultImage = g.Res.common_defaultWoman
    end

    return defaultImage
end

function AvatarView:isDefaultImage(url)
    return url == g.Res.common_defaultMan or
        url == g.Res.common_defaultWoman
end

function AvatarView:setFrameScale(scale)
    if self.frame then
        self.frame:scale(scale)
    end
end

return AvatarView

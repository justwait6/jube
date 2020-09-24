-- Author: Jam
-- Date: 2015.04.09
--[[
    用法：
    1.纯文本：
    2.文本加图标：
]]

local TopTip = class("TopTip")

local scheduler = require(cc.PACKAGE_NAME..".scheduler")
local DEFAULT_STAY_TIME = 3
local Y_GAP = 0
local TIP_HEIGHT = 56
local LABEL_X_GAP = -10
local ICON_SIZE = 56
local LABEL_ROLL_VELOCITY = 80
local BG_CONTENT_SIZE = cc.size(display.width - 10 * 2, TIP_HEIGHT)
local Z_ORDER = 1001

local HIDE_Y = display.top + TIP_HEIGHT * 0.5
local SHOW_Y = display.top - Y_GAP - TIP_HEIGHT * 0.5
local PADDING_LEFT = 40
local MAX_SHOW_LABEL_WIDTH = BG_CONTENT_SIZE.width - 2 * PADDING_LEFT
local LABEL_LEFT_X = -MAX_SHOW_LABEL_WIDTH / 2

local MAX_STORAGE_TIPS = 10

function TopTip:ctor()
	self:checkCreateTopTip()
	-- 等待队列
	self.waitQueue_ = {}
end

function TopTip:checkCreateTopTip()
	local scene = display.getRunningScene()
	if not scene then return end

	if tolua.isnull(self.container_) then
		self.isPlaying_ = false
		self.container_ = display.newNode():pos(display.cx, HIDE_Y):addTo(scene, Z_ORDER)

		display.newScale9Sprite(g.Res.common_topTipBg, 0, 0, BG_CONTENT_SIZE)
			:addTo(self.container_)

		local stencil = display.newScale9Sprite(g.Res.blank, 0, 0, cc.size(MAX_SHOW_LABEL_WIDTH, BG_CONTENT_SIZE.height))
		local clipNode = cc.ClippingNode:create():addTo(self.container_)
		clipNode:setStencil(stencil)
		clipNode:setAlphaThreshold(1)
		-- clipNode:setInverted(false)

        self.label_ = display.newTTFLabel({size = 28}):addTo(clipNode)
	end

	-- 检查是否重新添加到场景
    if self.container_:getParent() ~= scene then
    	self.container_:retain()
    	self.container_:addTo(scene, Z_ORDER)
	    self.container_:release()
    end
end

function TopTip:showTopTip(topTipData)
	assert(type(topTipData) == "table", "TopTipData should be a table!")

	-- 检查能否放入播放队列
	if self:canAddToPlayList(topTipData) then
		table.insert(self.waitQueue_, topTipData)
		-- topTipData.imageOptions
		
		if not self.isPlaying_ then
			-- 如果当前没有在播放, 消耗
			self:consume()
		end
	end
end

function TopTip:canAddToPlayList(tipItem)
	-- 超过最大缓存限制限制, 丢弃
	if table.nums(self.waitQueue_) > MAX_STORAGE_TIPS then return false end

	-- 队列里已有该提示消息, 丢弃
	for _, v in pairs(self.waitQueue_) do
		if v.text == tipItem.text then
			return false
		end
	end

	return true
end

--[[
	播放下一条
--]]
function TopTip:consume()
	if table.nums(self.waitQueue_) <= 0 then
		self.isPlaying_ = false
		return
	end

	self.isPlaying_ = true
	
	self:checkCreateTopTip()

	local currentPlayTip = table.remove(self.waitQueue_, 1)
	assert(type(currentPlayTip) == "table", "TopTipData should be a table!")
	self.label_:setString(currentPlayTip.text)
	self.label_:hide()

	local labelWidth = self.label_:getContentSize().width
	local scrollWidth = self:calcScrollWidth(labelWidth, MAX_SHOW_LABEL_WIDTH)

	self.animCompleteCb = self.animCompleteCb or handler(self, function ()
		self.isPlaying_ = false
		self:consume()
	end)

	if scrollWidth == 0 then
		self:playNoScrollAnim(self.animCompleteCb)
	else
		local targetXPos = -scrollWidth + self.label_:getPositionX()
		self:playScrollAnim(scrollWidth, targetXPos, self.animCompleteCb)
	end
end

function TopTip:playNoScrollAnim(callback)
	if tolua.isnull(self.container_) then return end

	self.container_:stopAllActions()
    self.container_:runAction(cc.Sequence:create({
    	cc.MoveTo:create(0.3, cc.p(display.cx, SHOW_Y)),
    	cc.CallFunc:create(handler(self, function ()
    		self.label_:stopAllActions()
			-- 默认居中
			self.label_:setAnchorPoint(0.5, 0.5)
			self.label_:setPositionX(0)
			self.label_:show()
    	end)),
    	cc.DelayTime:create(DEFAULT_STAY_TIME),
    	cc.MoveTo:create(0.3, cc.p(display.cx, HIDE_Y)),
    	cc.CallFunc:create(function ()
			if callback then callback() end
		end)
    }))
end

function TopTip:playScrollAnim(scrollWidth, targetXPos, callback)
	if tolua.isnull(self.container_) then return end
	local scrollTime = scrollWidth / LABEL_ROLL_VELOCITY

	self.container_:stopAllActions()
    self.container_:runAction(cc.Sequence:create({
    	cc.MoveTo:create(0.3, cc.p(display.cx, SHOW_Y)),
    	cc.CallFunc:create(handler(self, function ()
    		self.label_:stopAllActions()
			-- 居左, 左对齐
			self.label_:align(display.LEFT_CENTER)
			self.label_:setPositionX(LABEL_LEFT_X)
    		self.label_:moveTo(scrollTime, targetXPos)
    		self.label_:show()
    	end)),
    	cc.DelayTime:create(DEFAULT_STAY_TIME + scrollTime),
    	cc.MoveTo:create(0.3, cc.p(display.cx, HIDE_Y)),
    	cc.CallFunc:create(function ()
			if callback then callback() end
		end)
    }))
end

function TopTip:calcScrollWidth(labelWidth, maxLabelWidth)
	local scrollWidth = 0
	if labelWidth - maxLabelWidth > 0 then
		scrollWidth = labelWidth - maxLabelWidth
	end

	return scrollWidth
end

--------
-- interface begin
--------

function TopTip:getInstance()
	if not TopTip.singleInstance then
		TopTip.singleInstance = TopTip.new()
	end
	return TopTip.singleInstance
end

function TopTip:showText(textContent)
	self:showTopTip({text = textContent})
end

function TopTip:clearAll()
	self.waitQueue_ = {}

	self.animCompleteCb = nil

	if self.container_ then
		self.container_:stopAllActions()
		self.container_:pos(display.cx, HIDE_Y)
	end
end

--------
-- interface end
--------

return TopTip

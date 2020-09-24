local ScaleButton = class("ScaleButton", function() 
	return ccui.Button:create()
end)

--[[
	@func ctor: 构造函数
	@param params: table类型
		|=>params.scale 缩放系数
		|=>params.isNeedAnim 按钮是否需要动画(绑定节点上的不被禁止)
		|=>params.noAnim 禁止缩放动画(绑定节点上的也禁止), 默认false
--]]
function ScaleButton:ctor(params)
	local params = params or {}
	self.scale = params.scale or 1
	self.isNeedAnim = (params.isNeedAnim ~= false) -- 默认为true

    self:loadTextures(params.normal, params.press and params.press or params.normal, params.disable and params.disable or params.normal)
    self:setScale(self.scale)

	if not params.noAnim then
		self:addTouchEventListener(function(sender, eventType)
	        if eventType == 2 then
                self:targetScaleTo(sender, 1.0 * (self.scale or 1))
                local endTime = g.timeUtil:getSocketTime()
                if (endTime - self.clickTime) >= 2.0 and params.longcallback then
                    params.longcallback(sender)
                else
                    if g.timeUtil:getSocketTime() - self.lastClickTime >= 0.1 then
                        if self.clickCallback then
                            self.clickCallback(sender)
                        end
                	end
                end
                self:setLastClickTime()
            elseif eventType == 0 then
                self.clickTime = g.timeUtil:getSocketTime()
            	-- 播放音效
    			if self.isPlaySound ~= false then
    				-- g.audio:playSound(g.audio.Effects.CLICK_BUTTON)
    			end
            	if params and not params.noAnim then
                	self:targetScaleTo(sender, 0.95 * self.scale)
            	end
                if self.pressCallback then
                    self.pressCallback()
                end
            elseif eventType == 3 then
                if self.releaseCallback then
                    self.releaseCallback()
                end
                self:targetScaleTo(sender, 1.0 * (self.scale or 1))
            end
	    end)
	end
	self.lastClickTime = 0
	self.isPlaySound = false
end

--[[
	@func targetScaleTo: 当按钮有动画时, 对目标节点进行缩放
	@param target: 目标节点
	@param scaleFactor: 缩放系数
--]]
function ScaleButton:targetScaleTo(target, scaleFactor)
	if self.isNeedAnim then
        local scaleAction = cc.ScaleTo:create(0.07, scaleFactor)
        target:runAction(scaleAction)
	end
end

function ScaleButton:setLastClickTime()
    self.lastClickTime = g.timeUtil:getSocketTime()
end

function ScaleButton:onPress(callback)
    self.pressCallback = callback
    return self
end

function ScaleButton:onRelease(callback)
    self.releaseCallback = callback
    return self
end

function ScaleButton:onClick(callback)
    self.clickCallback = callback
    return self
end

function ScaleButton:setButtonLabel(lbl, offset)
    offset = offset or cc.p(0, 0)
    if self.label then
        self.label:removeFromParent()
    end
    self.label = lbl
    self.label:addTo(self)
    local size = self:getContentSize()
    self.label:pos(size.width/2 + offset.x, size.height/2 + offset.y)

    return self
end

function ScaleButton:getLabel()
    return self.label
end

--[[
	@func setBinding: 点击1按钮可以触发2按钮的点击效果
	@param tab: 要关联按键
--]]
function ScaleButton:setBinding(tab)
    self.bindingTab = tab
    return self
end

--[[
	@func isPlaySound: 按钮点击时是否播放声音
	@param enableSound: boolean类型, 是否允许按钮声音
--]]
function ScaleButton:isPlaySound(enableSound)
	self.isPlaySound = enableSound
	return self
end

--[[
	@func setIsNeeAnim: 设置按钮点击是否需要动画
	@param isNeedAnim: boolean类型, 是否需要动画
--]]
function ScaleButton:setIsNeeAnim(isNeedAnim)
    self.isNeedAnim = isNeedAnim
    return self
end

function ScaleButton:setButtonEnabled(enable)
    self:setEnabled(enable)
    return self
end

function ScaleButton:setButtonSize(size)
    self:setScale9Enabled(true)
    self:setContentSize(size)
    return self
end

return ScaleButton

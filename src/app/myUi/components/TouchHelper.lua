local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local TouchHelper = class("TouchHelper")

TouchHelper.CLICK = "CLICK"
TouchHelper.TOUCH_BEGIN = "TOUCH_BEGIN"
TouchHelper.TOUCH_MOVE = "TOUCH_MOVE"
TouchHelper.TOUCH_END = "TOUCH_END"

function TouchHelper:ctor(target, callback)
    self.callback_ = callback
    self.target_ = target
    self:enableTouch()
end

function TouchHelper:setTouchSwallowEnabled(isEnable)
    if self.target_ then
        self.target_:setTouchSwallowEnabled(isEnable)
    end
    return self
end

--[[
    @func setMoveNoResponse: 设置滑动不响应
        如touchHelper放在uiListView里, 滑动uiListView不响应touchHelper点击事件
    @param isEnable: boolean类型, true表示设置滑动不响应
--]]
function TouchHelper:setMoveNoResponse(isEnable)
    if isEnable then
        self.moveNoResponse = true
    end
    return self
end

function TouchHelper:enableTouch()
    self.target_:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onTouch))
    self.target_:setTouchEnabled(true)
    self.target_:setTouchSwallowEnabled(true)
    return self
end

function TouchHelper:onTouch(evt)
    if not self.target_ or not g.myFunc:checkNodeExist(self.target_) then return true end
    local name, x, y, prevX, prevY = evt.name, evt.x, evt.y, evt.prevX, evt.prevY
    local isTouchInSprite = cc.rectContainsPoint(self.target_:getCascadeBoundingBox(), cc.p(x, y))
    if name == "began" then
        self._startX = evt.x
        self._startY = evt.y
        self.endX_ = evt.x
        self.endY_ = evt.y
        if isTouchInSprite then
            self.isTouching_ = true
            self:notifyTarget(TouchHelper.TOUCH_BEGIN)
            return true
        else
            return false    
        end
    elseif not self.isTouching_ then
        return false
    elseif name == "moved" then
        self.endX_ = evt.x
        self.endY_ = evt.y
        self:notifyTarget(TouchHelper.TOUCH_MOVE, isTouchInSprite)
    elseif name == "ended" or name == "cancelled" then
        self.isTouching_ = false
        if not self.cancelClick_ and isTouchInSprite then
            if self.moveNoResponse then
                if math.abs(self.endX_ - self._startX) < 20 and math.abs(self.endY_ - self._startY) < 20 then
                    self:notifyTarget(TouchHelper.CLICK)
                end
            else
                self:notifyTarget(TouchHelper.CLICK)
            end
        else
            self:notifyTarget(TouchHelper.TOUCH_END)
        end
    end
    return true
end

function TouchHelper:notifyTarget(evtName, ...)
    if self.callback_ then
        self.callback_(self.target_, evtName, ...)
    end
end

return TouchHelper

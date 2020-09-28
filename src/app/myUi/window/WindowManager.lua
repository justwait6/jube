local WindowManager = class("WindowManager")

local Z_ORDER = 1000

function WindowManager:ctor()
    self:resetContainer()
end

function WindowManager.getInstance()
    if not WindowManager.singleInstance then
        WindowManager.singleInstance = WindowManager.new()
    end
    return WindowManager.singleInstance
end

--[[
    @func resetContainer: 重置视图容器, 将容器内容清空
--]]
function WindowManager:resetContainer()
    -- 数据容器
    self.windowStack_ = {}

    -- 视图容器
    if not self.viewContainer_ then
        self.viewContainer_ = display.newNode()
        self.viewContainer_:retain()
        self.viewContainer_:setNodeEventEnabled(true)
        self.viewContainer_.onCleanup = handler(self, function()
            -- 移除模态
            g.myFunc:safeRemoveNode(self.modalBg_)

            -- 移除所有弹框
            self:removeAllWindows()
            self.zOrder_ = 2
        end)
    end
    self.viewContainer_:removeAllChildren()

    self.transBgCover = display.newScale9Sprite(g.Res.blank, 0, 0, cc.size(display.width, display.height))
    -- self.transBgCover = display.newScale9Sprite(g.Res.black, 0, 0, cc.size(display.width, display.height))
        :pos(display.cx, display.cy)
        :addTo(self.viewContainer_)
    self.transBgCover:setTouchSwallowEnabled(true)
    self.transBgCover:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onBgCoverTouch_))
    self.transBgCover:setTouchEnabled(true)
    -- zOrder
    self.zOrder_ = 2
end

--[[
    @func onBgCoverTouch_: 透明背景遮罩点击
        |=>检测弹窗的isBgCoverTouchClose属性, 该属性为true时关闭弹窗
--]]
function WindowManager:onBgCoverTouch_(event)
    if event.name == "began" then
        local windowData = self.windowStack_[#self.windowStack_]
        if windowData and windowData.window and windowData.isBgCoverTouchClose then
            self:removeWindow(windowData.window)
        end
        return true
    end
end

--[[
    @func addWindow: 添加一个window弹框
    @param window: 添加的window对象
    @param isModal: 是否是模态框, boolean类型
    @param isBgCoverTouchClose: 点击透明背景遮罩后是否关闭弹窗, true表示要关闭
    @param noOpenAnim: 禁止弹窗开启时动画, true表示禁止, 默认false
    @param background: window背景, string类型
--]]
function WindowManager:addWindow(window, name, isModal, isBgCoverTouchClose, noOpenAnim, background)
    -- 添加模态
    isModal = (isModal ~= false) -- 默认为true, 当传入false时为false
    if isModal then
        if not self:isHasModal() then
            local modalBgRes = background or g.Res.common_halfTrans
            self.modalBg_ = display.newScale9Sprite(modalBgRes, 0, 0, cc.size(display.width, display.height))
                :pos(display.cx, display.cy)
                :addTo(self.viewContainer_)
            self.modalBg_:setTouchSwallowEnabled(true)
            self.modalBg_:addNodeEventListener(cc.NODE_TOUCH_EVENT, function () end)
            self.modalBg_:setTouchEnabled(true)
            self:playBgInAnim(self.modalBg_)
        end
    end

    -- 添加至场景
    if self:isHasWindow(window) then
        self:removeWindow(window)
    end
    table.insert(self.windowStack_, {window = window, name = name, isBgCoverTouchClose = isBgCoverTouchClose, isModal = isModal})

    -- 设置层级
    window:addTo(self.viewContainer_, self.zOrder_)
    self.zOrder_ = self.zOrder_ + 2
    if not self.viewContainer_:getParent() then
        self.viewContainer_:addTo(display.getRunningScene(), Z_ORDER)
    end
    -- 更改模态的zOrder
    if isModal then
        self.modalBg_:setLocalZOrder(window:getLocalZOrder() - 1)
    end
    self.transBgCover:setLocalZOrder(window:getLocalZOrder() - 1):show()

    if not noOpenAnim then
        -- 播放弹窗出现动画
        self:playShowWindowAnim(window, function()
            if window.onShow then
                window:onShow()
            end
        end)
    end
end

--[[
    @func playShowWindowAnim: 播放弹窗出现动画
    @param windowNode: window节点, 需要播放动画的window
    @param callback: 播放完成后回调
--]]
function WindowManager:playShowWindowAnim(windowNode, callback)
         g.myFunc:setAllCascadeOpacityEnabled(windowNode)
         local fadeAction = cc.FadeIn:create(0.17)
         local ScaleAction = cc.EaseBackOut:create(cc.ScaleTo:create(0.29,1))
         local spawnAction = cc.Spawn:create(fadeAction,ScaleAction)
         local sequence = cc.Sequence:create(spawnAction,cc.CallFunc:create(function()
              if callback then
                  callback()
              end
         end)) 
         windowNode:opacity(0.85 * 255):setScale(0.82)
         windowNode:stopAllActions()
         windowNode:runAction(sequence)
end

--[[
    @func playBgInAnim: 背景入场动画(淡入)
    @param node: 需要播放动画的node节点
--]]
function WindowManager:playBgInAnim(node)
    local fadeAction = cc.FadeIn:create(0.18)
    node:opacity(0.65 * 255)
    node:stopAllActions()
    node:runAction(fadeAction)
end

--[[
    @func isHasModal: 判断是否已经有模态框
    @return: boolean类型, true表示已有模态框
--]]
function WindowManager:isHasModal()
    for k= 1,#self.windowStack_ do
        if self.windowStack_[k] and self.windowStack_[k].isModal then
            return true
        end  
    end
end

--[[
    @func isHasWindow: 判断是否有某个window
    @param window: 被检测的弹窗
    @return: boolean类型, true表示已有
--]]
function WindowManager:isHasWindow(windowName)
    for i, windowData in ipairs(self.windowStack_) do
        if windowData.name == windowName then
            return true
        end
    end
    return false
end

function WindowManager:removeWindowIfByName(windowName)
    for i, windowData in ipairs(self.windowStack_) do
        if windowData.name == windowName then
            self:removeWindow(windowData.window);
            return true;
        end
    end
    return false
end

--[[
    @func getWindowIndex: 查找某个window的索引值, -1表示没有找到
    @param window: 被检测的弹窗
    @return: 索引值, 返回等于-1时表示没有
--]]
function WindowManager:getWindowIndex(window)
    for i, windowData in ipairs(self.windowStack_) do
        if windowData.window == window then
            return i
        end
    end
    return -1
end

--[[
    @func removeWindow: 移除指定弹框
    @param window: 需要移除的window节点
    @param immediate: 是否立即移除
--]]
function WindowManager:removeWindow(window, immediate)
    if not window or not g.myFunc:checkNodeExist(window) then return end

    local removePopupFunc = function()
        g.myFunc:safeRemoveNode(window)
        local index = self:getWindowIndex(window)
        table.remove(self.windowStack_, index)
        if #self.windowStack_ == 0 then
            self:resetContainer()
            self.transBgCover:hide()
        end
        if not self:isHasModal() then
            self:playBgDismissAnim(self.modalBg_)
            g.myFunc:safeRemoveNode(self.modalBg_)
        end
        -- 更改模态的zOrder
        self.zOrder_ = self.zOrder_ - 2
        for k = #self.windowStack_, 1, -1 do
            local windowData = self.windowStack_[k]
            if k == #self.windowStack_ then
                self.transBgCover:setLocalZOrder(windowData.window:getLocalZOrder() - 1)
            end  
            if windowData.isModal then
                if self.modalBg_ and self.modalBg_.setLocalZOrder and g.myFunc:checkNodeExist(self.modalBg_) then
                    local tempLoaclZOrder = windowData.window:getLocalZOrder()
                    if tempLoaclZOrder then
                        self.modalBg_:setLocalZOrder(tempLoaclZOrder - 1)
                    end
                end
                break
            end 
        end
    end

    if window.onWindowRemove then
        window:onWindowRemove(function() end)
    end
    if immediate then
        removePopupFunc()
    else
        self:playDismissAnim(window, function() removePopupFunc() end)
    end
end

--[[
    @func playDismissAnim: 播放关闭动画
    @param node: 需要关闭的node节点
    @param callback: 关闭动画完成后的回调
--]]
function WindowManager:playDismissAnim(node, callback)
    g.myFunc:setAllCascadeOpacityEnabled(node)
    local sequence = cc.Sequence:create({
        cc.Spawn:create({
            cc.FadeOut:create(0.15),
            cc.ScaleTo:create(0.15, 0.88)
        }),
        cc.CallFunc:create(function()
            if callback then callback() end
        end)
    }) 
    node:stopAllActions()
    node:runAction(sequence)
end

--[[
    @func playBgDismissAnim: 播放背景关闭动画
    @param node: 需要关闭的node节点
--]]
function WindowManager:playBgDismissAnim(node)
    if node and g.myFunc:checkNodeExist(node) then
        local fadeAction = cc.FadeOut:create(0.15)
        node:stopAllActions()
        node:runAction(fadeAction)
    end
end

--[[
    @func removeAllWindows: 移除所有弹框
--]]
function WindowManager:removeAllWindows()
    if #self.windowStack_ > 0 then
        for k, v in ipairs(self.windowStack_) do
            if v and v.window and g.myFunc:checkNodeExist(v.window) then
                 self:removeWindow(v.window, true)
            end
        end
    end
    self:resetContainer()
end

--[[
    @func getAllWindows: 取得所有弹框
    @return: 返回由windowData组成的栈
--]]
function WindowManager:getAllWindows()
    return self.windowStack_
end

return WindowManager

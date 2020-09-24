local SeatCircleProgress = class("SeatCircleProgress",function() 
		return display.newNode()
	end)
	
function SeatCircleProgress:ctor(scale,path)
    path = path or g.Res.common_progress_img
    self.progressTimer = cc.ProgressTimer:create(display.newSprite(path)):setScale(scale)
                          :addTo(self)
                          -- :setReverseDirection(true)
                          :hide()
end 
function SeatCircleProgress:setScale(scale)
    self.progressTimer:setScale(scale)
end
function SeatCircleProgress:setProgress(progress)
    if progress >= 65 then
       
       if self.state~= 1 then
             -- self.progressTimer:setColor(cc.c3b(200,0,0)) 
             self.state = 1
             self.progressTimer:tintTo(2,254,61,41)
       end
    elseif progress >= 33 then
       if self.state ~= 2 then
             -- self.progressTimer:setColor(cc.c3b(200,200,0))
             self.state = 2
             self.progressTimer:tintTo(1.4,255,235,30)
       end
    elseif progress >=0 then
       if self.state ~= 3 then
             self.state = 3
             self.progressTimer:setColor(cc.c3b(75,253,85))
             -- self.progressTimer:tintTo(0.4,75,253,85)
       end  
    end
    self.progressTimer:setPercentage(progress)
end 

function SeatCircleProgress:setColor(color)
    self.progressTimer:setColor(color)
end

function SeatCircleProgress:stopCountDown()
    self:removeAllNodeEventListeners()
    self:unscheduleUpdate()
    self:setProgress(0)
    self.progressTimer:stopAllActions()
    self.progressTimer:hide()
    if self.finishCallback then
        self.finishCallback()
    end
end

function SeatCircleProgress:setFinishCallback(finishCallback)
    self.finishCallback = finishCallback
end

function SeatCircleProgress:startCountDown(time)
    self.state = 3
    self.progressTimer:setColor(cc.c3b(75,253,85))
    self.countTime = time
    self.startTime = g.timeUtil:getSocketTime()
    if(self.countTime ~= 0) then
        -- 添加帧事件
        self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt)
            self:update_(dt)
        end)
        self:setNodeEventEnabled(true)
        self:scheduleUpdate()
        
        self.progressTimer:show()
    end
end

function SeatCircleProgress:update_(dt)
    local progress = (g.timeUtil:getSocketTime() - self.startTime)/self.countTime*100
    self:setProgress(progress)
    if progress >= 100 then
        self:stopCountDown()
    end

    if progress >= 75 and progress < 100 then
        if self.shakeCallback then
            self.shakeCallback()
        end
    end

    if progress >= 50 and progress < 55 then
        if self.clicktableCallback then 
            self.clicktableCallback()
        end
    end
end

function SeatCircleProgress:setShakeCallback(shakeCallback)
    self.shakeCallback = shakeCallback
end

function SeatCircleProgress:setClickTableCallback(clicktableCallback)
    self.clicktableCallback = clicktableCallback
end

return SeatCircleProgress

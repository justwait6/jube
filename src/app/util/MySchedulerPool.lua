local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

local MySchedulerPool = class("MySchedulerPool")

function MySchedulerPool:ctor()
    self.pool_ = {}
    self.id_ = 0
end

--[[
    @func getNextId: 封装递增变量
    @return: 返回下一个调度id
--]]
function MySchedulerPool:getNextId()
    self.id_ = self.id_ + 1
    return self.id_
end

function MySchedulerPool.getInstance()
    if not MySchedulerPool.singleInstance then
        MySchedulerPool.singleInstance = MySchedulerPool.new()
    end
    return MySchedulerPool.singleInstance
end

--[[
    @func cancel: 取消某个调度器
    @param id: 调度器句柄
--]]
function MySchedulerPool:cancel(id)
    if self.pool_[id] then
        scheduler.unscheduleGlobal(self.pool_[id])
        self.pool_[id] = nil
    end
end

--[[
    @func cancelAll: 取消全部调度器
--]]
function MySchedulerPool:cancelAll()
    for k,v in pairs(self.pool_) do
        scheduler.unscheduleGlobal(v)
    end
    self.pool_ = {}
end

--[[
    @func doDelay: 延时调度器, 延迟一段时间调用callback
    @param callback: 被调度的函数回调(最多执行一次)
    @param interval: 延迟时间
    @return: 返回一个调度器句柄, 可使用该句柄执行cancel等操作
--]]
function MySchedulerPool:doDelay(callback, delay, ...)
    local id = self:getNextId()
    local args = {...}
    local handle = scheduler.performWithDelayGlobal(function() 
        self.pool_[id] = nil
        if callback then
            callback(self, unpack(args))
        end
    end, delay)
    self.pool_[id] = handle
    return id
end

--[[
    @func doLoop: 循环调度器, 每间隔一段时间调用callback一次
    @param callback: 被调度的函数回调(注意,该回调需要返回true才会继续下一次执行)
    @param interval: 间隔时间
    @return: 返回一个调度器句柄, 可使用该句柄执行cancel等操作
--]]
function MySchedulerPool:doLoop(callback, interval, ...)
    local id = self:getNextId()
    local args = {...}
    local handle = scheduler.scheduleGlobal(function()
        if callback then
            if not callback(self, id, unpack(args)) then
                self:cancel(self.pool_[id])
                self.pool_[id] = nil
            end
        end
    end, interval)
    self.pool_[id] = handle
    return id
end

return MySchedulerPool
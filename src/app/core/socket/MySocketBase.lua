local CURRENT_MODULE_NAME = ...

local ProxySelector = import(".ProxySelector")
local SocketService = import(".SocketService")

local MySocketBase = class("MySocketBase")

local MAX_RETRY_LIMIT = 3

function MySocketBase:ctor(socketName, CmdDef)
    self.CmdDef = CmdDef

    self.socketService_ = SocketService.new(socketName, CmdDef):setMySocket(self)
    self.socketName_ = socketName
    self.shouldConnect_ = false
    self.isConnected_ = false
    self.isConnecting_ = false
    self.isPaused_ = false
    self.delayPackCache_ = {}
    self.logger_ = g.Logger.new(self.socketName_)
end

function MySocketBase:isConnected()
    return self.isConnected_
end

function MySocketBase:connect(ip, port)
    self:disconnect()
    self.shouldConnect_ = true
    self.ip_ = ip
    self.port_ = port
    if self:isConnected() then
        self.logger_:warn("connect: isConnected true")
    elseif self.isConnecting_ then
        self.logger_:warn("connect: isConnecting true")
    else
        self.isConnecting_ = true
        self.proxySelector_ = nil
        self.proxy_ = nil
        self.logger_:warnf("connect: direct connect to %s:%s", self.ip_, self.port_)
        self.socketService_:connect(self.ip_, self.port_)
    end
end

function MySocketBase:disconnect()
    self.shouldConnect_ = false
    self.isConnecting_ = false
    self:unscheduleHeartBeat()
    if self:isConnected() then
        self.socketService_:disconnect()
        self.isConnected_ = false
    end
end

function MySocketBase:pause()
    self.isPaused_ = true
    self.logger_:warn("pause: paused event dispatching")
end

function MySocketBase:resume()
    self.isPaused_ = false
    self.logger_:warn("resume: resume event dispatching")
    if self.delayPackCache_ and #self.delayPackCache_ > 0 then
        for i,v in ipairs(self.delayPackCache_) do
            g.event:emit(g.eventNames.PACKET_RECEIVED, v)
        end
        self.delayPackCache_ = {}
    end
end

function MySocketBase:createPacketBuilder(cmd)
    return self.socketService_:createPacketBuilder(cmd)
end

function MySocketBase:send(pack)
    if self:isConnected() then
        self.socketService_:send(pack)
    else
        self.logger_:error("send: sending packet when socket is not connected")
    end
end

function MySocketBase:onConnected()
    self.isConnected_ = true
    self.isConnecting_ = false
end

function MySocketBase:startHeartBeat()
    self.logger_:info(":startHeartBeat send startHeartBeat")
    if not self.heartBeatSchedId then
        self.heartBeatSchedId = g.mySched:doLoop(handler(self, self.onHeartBeat_), 10)
    end
end

function MySocketBase:unscheduleHeartBeat()
    if self.heartBeatSchedId then
        g.mySched:cancel(self.heartBeatSchedId)
        self.heartBeatSchedId = nil
    end
    self:cancelHeartBeatTimeOut()
end

function MySocketBase:onHeartBeat_()
    local heartBeatPack = self:buildHeartBeatPack()
    if heartBeatPack then
        self.heartBeatPackSendTime_ = g.timeUtil:getSocketTime()
        self:send(heartBeatPack)
        if not self.heartBeatTimeoutId_ then
            self.heartBeatTimeoutId_ = g.mySched:doDelay(handler(self, self.onHeartBeatTimeout_), 5)
        end
        self.logger_:warnf("onHeartBeat_: send heart beat packet time %s", self.heartBeatPackSendTime_)
    end
    return true
end

function MySocketBase:onHeartBeatTimeout_()
    self.heartBeatTimeoutId_ = nil
    self.heartBeatTimeoutCount_ = (self.heartBeatTimeoutCount_ or 0) + 1
    print("self.heartBeatTimeoutCount_", self.heartBeatTimeoutCount_)
    if self.heartBeatTimeoutCount_ >= 2 then
        print('1')
        self:disconnect()
    end
    self.logger_:warnf("onHeartBeatTimeout_: heart beat timeout = %s", self.heartBeatTimeoutCount_)
end

function MySocketBase:cancelHeartBeatTimeOut()
    self.heartBeatTimeoutCount_ = 0
    if self.heartBeatTimeoutId_ then
        g.mySched:cancel(self.heartBeatTimeoutId_)
        self.heartBeatTimeoutId_ = nil
    end
end

function MySocketBase:onHeartBeatReceived_()
    local delaySeconds = g.timeUtil:getSocketTime() - self.heartBeatPackSendTime_
    if self.heartBeatTimeoutId_ then
				self:cancelHeartBeatTimeOut()
				if ENABLE_HEART_BEATS_LOG then
					self.logger_:warnf("onHeartBeatReceived_: received delaySeconds = %s", delaySeconds)
				end
		else
				if ENABLE_HEART_BEATS_LOG then
					self.logger_:warnf("onHeartBeatReceived_: timeout received delaySeconds = %s", delaySeconds)
				end
    end
end

function MySocketBase:buildHeartBeatPack()
    local data = {}
    local num = math.random(1, 2)
    if num == 1 then
        table.insert(data, {value = math.random(0, 2147483647)})
    elseif num == 2 then
        table.insert(data, {value = math.random(0, 2147483647)})
        table.insert(data, {value = math.random(0, 2147483647)})
    end
    return self:createPacketBuilder(self.CmdDef.CLI_HEART_BEAT)
        :setParameter("uid", g.user:getUid())
        :setParameter("random", data)
        :build()
end

function MySocketBase:onConnectFailed(evt)
    self.isConnected_ = false
    self.logger_:warn("onConnectFailed: connect failure ...")

    self.ipIndex = self.ipIndex or 1
    self.ipIndex = self.ipIndex + 1
    if self.ipIndex > 1 then
        local backupIp = g.user:getBackupIp()
        if backupIp and (self.ipIndex <= (#backupIp + 1)) then
            local ipportsbackupIp = g.myFunc:split(backupIp[self.ipIndex - 1], ":")
            if ipportsbackupIp and #ipportsbackupIp == 2 then
                g.Const.IP = ipportsbackupIp[1]
                g.Const.PORT = ipportsbackupIp[2]
            end
        else
            local ipPort = g.user:getHallIp()
            if ipPort then
                local ipports = g.myFunc:split(ipPort, ":")
                if #ipports == 2 then
                    self.ipIndex = 1
                    g.Const.IP = ipports[1]
                    g.Const.PORT = ipports[2]
                end
            end
        end
    end
    --g.Native:umengError(errorMsg)
    if not self:reconnect_() then
    end
end

function MySocketBase:onError(evt)
    self.isConnected_ = false
    self:disconnect()
    self.logger_:warn("onError: data error ...")
    self:reconnect_()
end

function MySocketBase:onClosed(evt)
    self.isConnected_ = false
    self:unscheduleHeartBeat()
    if self.shouldConnect_ then
        if not self:reconnect_() then
        else
            self.logger_:warn("onClosed: closed and reconnecting")
        end
    else
        self.logger_:warn("onClosed: closed and do not reconnect")
    end
end

function MySocketBase:onClose()
    self:unscheduleHeartBeat()
end

function MySocketBase:reconnect_()
    self.logger_:warn("reconnect_: reconnecting ip port", self.ip_, self.port_)
    if self:isConnected() then
        self:disconnect()
    end
    self.retryLimit_ = (self.retryLimit_ or 0) + 1
    local isRetrying = true
    if self.retryLimit_ > MAX_RETRY_LIMIT then
        self.socketService_:connect(self.ip_, self.port_)
    else
        isRetrying = false
        self.isConnecting_ = false
    end
    return isRetrying
end

function MySocketBase:onReceivePacket(pack)
		if pack.cmd == self.CmdDef.SVR_HEART_BEAT and not ENABLE_HEART_BEATS_LOG then
			-- 心跳包不打印日志时不显示
        else
            printVgg("0x" .. string.format("%x", pack.cmd))
            dump(pack, "on pack received")
		end

    if pack.cmd == self.CmdDef.SVR_HEART_BEAT then
        self:onHeartBeatReceived_()
    elseif pack.cmd == self.CmdDef.SVR_PUSH then
        if pack.uid == g.user:getUid() then
            g.event:emit(g.eventNames.SERVER_PUSH, pack)
        end
    elseif pack.cmd == self.CmdDef.SVR_SEND_CHAT_RESP then
        if pack.uid == g.user:getUid() then
            g.event:emit(g.eventNames.SEND_CHAT_RESP, pack)
        end
    elseif pack.cmd == self.CmdDef.SVR_GET_TABLE then
        g.event:emit(g.eventNames.GET_TABLE_RESP, pack)
    else
        if self.isPaused_ then
            self.delayPackCache_[#self.delayPackCache_ + 1] = pack
        else
            local ret, errMsg = pcall(function() g.event:emit(g.eventNames.PACKET_RECEIVED, pack) end)
            if errMsg then
                self.logger_:errorf("onReceivePacket: dispatching. ", string.format("%x", pack.cmd), errMsg)
            end
        end
    end
end

return MySocketBase

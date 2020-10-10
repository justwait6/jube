local MySocketBase = import(".MySocketBase")
local MySocket = class("MySocket", MySocketBase)

local CmdDef = require("app.core.protocol.CommandDef")

local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

function MySocket:ctor()
    MySocket.super.ctor(self, "MySocket", CmdDef)
    self.level = 0
    self.gameId = 0
end

function MySocket:cliConnectHall()
	if not self.timerScheduleId then
		self:timer_()
		self.timerScheduleId = g.mySched:doLoop(handler(self, self.timer_), 10)
	end
end

function MySocket:cancelCliConnectHall()
	if self.timerScheduleId then
		g.mySched:cancel(self.timerScheduleId)
		self.timerScheduleId = nil
	end
	self:disconnect()
end

function MySocket.getInstance()
	if not MySocket.singleInstance then
		MySocket.singleInstance = MySocket.new()
	end
	return MySocket.singleInstance
end

--倒计时
function MySocket:timer_(dt)
    print("MySocket:timer_ current time: ", os.time())
    if not self:isConnected() then
        print("MySocket:timer_ isConnected: FALSE")
        self:connectServer()
    end
    return true
end

function MySocket:connectServer()
    local ip = g.user:getHallIp()
    local port = g.user:getHallPort()
    print("MySocket:connectServer INFO ip-port: ", ip, port)
    if ip and port then
        -- 设置定时器
        self:removeConnectScheduler()
        self.connectSchedulerHandle_ = g.mySched:doDelay(handler(self, self.onConnectTimeout_), 15)
        self:connect(ip, port)
    end
end

function MySocket:removeConnectScheduler()
    if self.connectSchedulerHandle_ then
        g.mySched:cancel(self.connectSchedulerHandle_)
        self.connectSchedulerHandle_ = nil
		end
end

function MySocket:removeLoginTimeoutScheduler()
    if self.loginTimeoutHandle_ then
        g.mySched:cancel(self.loginTimeoutHandle_)
        self.loginTimeoutHandle_ = nil
    end
end

function MySocket:onConnectTimeout_()
    -- g.umeng:report(KUmengServerLoginFail)
    self:removeConnectScheduler()
    self:disconnect()
end

function MySocket:onConnected()
    self.super.onConnected(self)
    self.logoutRequested_ = false
    self:removeConnectScheduler()
    -- 请求桌子
    -- 登录房间超时检测
    -- 暂时不要
    -- self:removeLoginTimeoutScheduler()
    -- self.loginTimeoutHandle_ = g.mySched:doDelay(handler(self, self.disconnect), 4)
    
    print("g.Const.SERVER_CHANNEL = %s", g.Const.SERVER_CHANNEL)
    if tonumber(g.user:getUid()) ~= 0 then
        self:sendLogin(tonumber(g.user:getUid()), g.Const.version, g.Const.SERVER_CHANNEL, g.Const.SERVER_PLATFORM, g.user:getAccessServerToken())
    else
        local errorMsg = "server login success but uid id == 0"
        -- g.native:umengError(errorMsg)
    end

    -- 发送心跳包
    -- test comment
    self:startHeartBeat()
    -- g.umeng:report(KUmengServerLoginOk)
end

function MySocket:sendLogin(uid, version, channel, deviceId, token)
    local pack = self:createPacketBuilder(CmdDef.CLI_HALL_LOGIN)
        :setParameter("uid", uid)
        :setParameter("token", token or '')
        :setParameter("version", version)
        :setParameter("channel", channel)
        :setParameter("deviceId", deviceId)
        :build()
    self:send(pack)
end
function MySocket:setRoomCmdConfig(gameId)
    if self.socketService_ then
        self.socketService_:setSubCmdConfig(gameId)
    end
end

function MySocket:cliGetTable(gameId)
    local pack = self:createPacketBuilder(CmdDef.CLI_GET_TABLE)
        :setParameter("uid", g.user:getUid())
        :setParameter("gameId", gameId)
        :setParameter("level", g.Var.level)
        :build()
    self:send(pack)
end

function MySocket:cliEnterRoom()
    local pack = self:createPacketBuilder(CmdDef.CLI_ENTER_ROOM)
        :setParameter("uid", g.user:getUid())
        :setParameter("gameId", g.Var.gameId)
        :setParameter("tid", g.Var.tid)
        :setParameter("userinfo", g.user:getUserinfo())
        :build()
    self:send(pack)
end

function MySocket:sendChat(params)
    params = params or {}
    local pack = self:createPacketBuilder(CmdDef.CLI_SEND_CHAT)
        :setParameters(params)
        :build()
    self:send(pack)
end

function MySocket:sendLogout()
    self.logoutRequested_ = true
    self:send(self:createPacketBuilder(SocketProtocol.CLI_DICE_EXIT_ROOM):build())
end

return MySocket

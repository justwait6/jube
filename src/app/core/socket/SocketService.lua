-- Author: Jam
-- Date: 2015.04.15
local SimpleTCP = require("framework.SimpleTCP")
local ByteArray = require("app.core.utils.ByteArray")
local PacketBuilder = import(".PacketBuilder")
local PacketParser = import(".PacketParser")
local SocketService = class("SocketService")

local CmdConfig = require("app.core.protocol.CommandConfig")
local RummyCmdConfig = require("app.core.protocol.RummyCmdConfig")
local DizhuCmdConfig = require("app.core.protocol.DizhuCmdConfig")

local SOCKET_ID = 1

function SocketService:ctor(name)
    self.socketName_ = name
    self.parser_ = PacketParser.new(CmdConfig, self.socketName_)
end

function SocketService:getSocketId(mySocket)
    SOCKET_ID = SOCKET_ID + 1
    return SOCKET_ID
end

function SocketService:setMySocket(mySocket)
    self.mySocket = mySocket
    return self
end

function SocketService:createPacketBuilder(cmd)
    local cmdItem = CmdConfig[cmd]
    if self.subCmdConfig_ and self.subCmdConfig_[cmd] then
        cmdItem = self.subCmdConfig_[cmd]
    end
    return PacketBuilder.new(cmd, cmdItem, self.socketName_)
end

function SocketService:setSubCmdConfig(gameId)
    self.subCmdConfig_ = nil
    if gameId == g.SubGameDef.RUMMY then
        self.subCmdConfig_ = RummyCmdConfig
    elseif gameId == g.SubGameDef.DIZHU then
        self.subCmdConfig_ = DizhuCmdConfig
    end
    self.parser_:setSubCmdConfig(self.subCmdConfig_)
end

function SocketService:connect(host, port)
    if not self.socket_ then
        self.socket_ = SimpleTCP.new(host, port, handler(self, self.onTCPEvent))
        self.socket_.socketId_ = self:getSocketId()
    end
    self.socket_:connect()
end

function SocketService:onTCPEvent(event, data)
    if event == SimpleTCP.EVENT_DATA then
        print("onTCPEvent receive data:", data)
        self:onData(data)
    elseif event == SimpleTCP.EVENT_CONNECTING then
        print("onTCPEvent connecting")
    elseif event == SimpleTCP.EVENT_CONNECTED then
        print('onTCPEvent connected')
        self:onConnected()
    elseif event == SimpleTCP.EVENT_CLOSED then
        print('onTCPEvent closed')
        self:onClosed()
    elseif event == SimpleTCP.EVENT_FAILED then
        print('onTCPEvent failed')
        self:onConnectFailed()
    end
end

function SocketService:send(data)
    if self.socket_ then
        if type(data) == "string" then
            self.socket_:send(data)
        else
            self.socket_:send(data:getPack())
        end
    end
end

function SocketService:disconnect()
    if self.socket_ then
        local socket = self.socket_
        self.socket_ = nil
        socket:close()
    end
end

function SocketService:onConnected()
    self.parser_:reset()
    if self.mySocket then self.mySocket:onConnected() end
end

function SocketService:onClose()
    print("SocketService:onClose [%d] onClose. %s")
    if self.mySocket then self.mySocket:onClose() end
end

function SocketService:onClosed()
    if self.mySocket then self.mySocket:onClosed() end
end

function SocketService:onConnectFailed()
    if self.mySocket then self.mySocket:onConnectFailed() end
end

function SocketService:onData(data)
    print("socket receive raw data: %s", ByteArray.toString(data, 16))
    local buf = ByteArray.new(ByteArray.ENDIAN_BIG)
    buf:writeBuf(data)
    buf:setPos(1)
    local success, packets = self.parser_:read(buf)
    if not success then
        if self.mySocket then self.mySocket:onError(data) end
    else
       for i,v in ipairs(packets) do
						if v and v.cmd then
                if self.mySocket then self.mySocket:onReceivePacket(v) end
            end
       end 
    end
end

return SocketService

local ProtocolManager = class("ProtocolManager")

function ProtocolManager:ctor()
    self:initialize()
end

function ProtocolManager:initialize()
end

function ProtocolManager:getProtocolConfig()
end

function ProtocolManager.getInstance()
    if not ProtocolManager.singleInstance then
        ProtocolManager.singleInstance = ProtocolManager.new()
    end
    return ProtocolManager.singleInstance
end

return ProtocolManager

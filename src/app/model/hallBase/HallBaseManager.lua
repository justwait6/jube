local HallBaseManager = class("HallBaseManager")

local HallBaseDef = import(".HallBaseDef")
local HallBaseConf = import(".HallBaseConfig")

HallBaseManager.VIEW_DIR_PATH = "app.view.hallBase"

function HallBaseManager:ctor()
	self:initialize()
end

function HallBaseManager:initialize()
    
end

function HallBaseManager.getInstance()
    if not HallBaseManager.singleInstance then
        HallBaseManager.singleInstance = HallBaseManager.new()
    end
    return HallBaseManager.singleInstance
end

function HallBaseManager:getHallBaseList()
    local hallSequence = {}

    local hallBaseSet = HallBaseDef.HALL_BASE_SEQUENCE
    for _, baseId in pairs(hallBaseSet) do
        table.insert(hallSequence, baseId)
    end

    return hallSequence
end

function HallBaseManager:getHallBaseConfs()
    local hallBaseConfs = {}
    local hallSequence = self:getHallBaseList()
    for _, baseId in pairs(hallSequence) do
        table.insert(hallBaseConfs, HallBaseConf[baseId])
    end
    return hallBaseConfs
end

function HallBaseManager:onBaseIconClick(baseId)
    local view = require(HallBaseManager.VIEW_DIR_PATH .. HallBaseConf[baseId].baseWindowPath)
    view.new():show()
end

return HallBaseManager

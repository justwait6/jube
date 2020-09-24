local HallActListCtrl = class("HallActListCtrl")

local actMgr = require("app.model.activity.ActManager").getInstance()

function HallActListCtrl:ctor()
	self:initialize()
end

function HallActListCtrl:initialize()
end

function HallActListCtrl:getActConfList()
	return actMgr:getHallActConfs()
end

function HallActListCtrl:onActIconClick(actId)
	return actMgr:onHallActIconClick(actId)
end

function HallActListCtrl:XXXX()
	
end

function HallActListCtrl:XXXX()
	
end

return HallActListCtrl

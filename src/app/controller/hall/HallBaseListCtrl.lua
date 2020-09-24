local HallBaseListCtrl = class("HallBaseListCtrl")

local HallBaseDef = import("app.model.hallBase.HallBaseDef")
local baseManager = require("app.model.hallBase.HallBaseManager").getInstance()

function HallBaseListCtrl:ctor(viewObj)
	self.viewObj = viewObj
	self:initialize()
	self:addEventListeners()
end

function HallBaseListCtrl:initialize()
end

function HallBaseListCtrl:addEventListeners()
	g.event:on(g.eventNames.FRIEND_RED_DOT, handler(self, self.updateFriendRedDot), self)
end

function HallBaseListCtrl:getConfList()
	return baseManager:getHallBaseConfs()
end

function HallBaseListCtrl:onBaseIconClick(baseId)
	baseManager:onBaseIconClick(baseId)
end

function HallBaseListCtrl:updateFriendRedDot(data)
	data = data or {}
	if self.viewObj then
		self.viewObj:updateRedDot(HallBaseDef.FRIEND, data.isShow)
	end
end

function HallBaseListCtrl:XXXX()
	
end

function HallBaseListCtrl:XXXX()
	
end

function HallBaseListCtrl:dispose()
	g.event:removeByTag(self)
end

return HallBaseListCtrl

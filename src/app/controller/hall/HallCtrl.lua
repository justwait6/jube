local HallCtrl = class("HallCtrl")

function HallCtrl:ctor()
	self:initialize()
	self:addEventListeners()
end

function HallCtrl:initialize()
end

function HallCtrl:addEventListeners()
	g.event:on(g.eventNames.SVR_SEND_HALL_LOGIN, handler(self, self.onSvrSendHallLogin), self)
	g.event:on(g.eventNames.GET_TABLE_RESP, handler(self, self.onGetTableResp), self)
end

function HallCtrl:logout()
	g.myApp:enterScene("LoginScene")
end

function HallCtrl:getTable()
	g.mySocket:cliGetTable()
end

function HallCtrl:onSvrSendHallLogin(pack)
	if pack and tonumber(pack.ret) == 1 then -- need reconnect room
		self:getTable()
	end
end

function HallCtrl:onGetTableResp(pack)
	g.mySocket:setRoomCmdConfig(pack.gameId)
	g.Var.tid = pack.tid
	g.myApp:enterScene("RummyScene")
end

function HallCtrl:XXXX()
end

function HallCtrl:XXXX()
end

function HallCtrl:dispose()
	g.event:removeByTag(self)
end

return HallCtrl

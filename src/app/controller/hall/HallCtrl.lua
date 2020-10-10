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

function HallCtrl:getTable(gameId)
	g.mySocket:cliGetTable(gameId)
end

function HallCtrl:onSvrSendHallLogin(pack)
	if pack and tonumber(pack.ret) == 1 then -- need reconnect room
		self:getTable(0)
	end
end

function HallCtrl:onGetTableResp(pack)
	g.Var.gameId = pack.gameId
	g.Var.tid = pack.tid
	g.mySocket:setRoomCmdConfig(pack.gameId)
	if pack.gameId == g.SubGameDef.RUMMY then
		g.myApp:enterScene("RummyScene")
	elseif pack.gameId == g.SubGameDef.DIZHU then
		g.myApp:enterScene("DizhuScene")
	end
end

function HallCtrl:getDizhuTable()
	self:getTable(g.SubGameDef.DIZHU)
end

function HallCtrl:getRummyTable()
	self:getTable(g.SubGameDef.RUMMY)
end

function HallCtrl:XXXX()
end

function HallCtrl:dispose()
	g.event:removeByTag(self)
end

return HallCtrl

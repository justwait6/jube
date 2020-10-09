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
		g.Var.gameId = g.userDefault:getIntegerForKey(g.cookieKey.GAME_ID)
		self:getTable()
	end
end

function HallCtrl:onGetTableResp(pack)
	g.userDefault:setIntegerForKey(g.cookieKey.GAME_ID, pack.gameId)
	g.mySocket:setRoomCmdConfig(pack.gameId)
	g.Var.tid = pack.tid
	if pack.gameId == g.SubGameDef.RUMMY then
		g.myApp:enterScene("RummyScene")
	elseif pack.gameId == g.SubGameDef.DIZHU then
		g.myApp:enterScene("DizhuScene")
	end
end

function HallCtrl:getDizhuTable()
	g.Var.gameId = g.SubGameDef.DIZHU
	self:getTable()
end

function HallCtrl:getRummyTable()
	g.Var.gameId = g.SubGameDef.RUMMY
	self:getTable()
end

function HallCtrl:XXXX()
end

function HallCtrl:dispose()
	g.event:removeByTag(self)
end

return HallCtrl

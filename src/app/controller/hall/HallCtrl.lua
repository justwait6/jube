local HallCtrl = class("HallCtrl")

function HallCtrl:ctor()
	self:initialize()
end

function HallCtrl:initialize()
end

function HallCtrl:logout()
	g.myApp:enterScene("LoginScene")
end

function HallCtrl:getTable()
	g.mySocket:cliGetTable()
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

return HallCtrl

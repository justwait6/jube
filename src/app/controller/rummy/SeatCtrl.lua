local SeatCtrl = class("SeatCtrl")

function SeatCtrl:ctor()
	self:initialize()
end

function SeatCtrl:initialize()
end

function SeatCtrl:doAvatarClick()
    print("-- todo, on Avatar click...")
    -- if self.serverSeatId < 0 and RoomInfo.getInstance():getMSeatId() == -1 then -- 我站起点击空座位
    --     self:requestSitDown()
    -- elseif self.uid > 0 and app.gameId >= 10000 then
    --     RoomUserInfoPopup.new(self.uid):show()
    -- end
end

--请求坐下
function SeatCtrl:requestSitDown()
end

function SeatCtrl:XXXX()
	
end

function SeatCtrl:XXXX()
	
end

return SeatCtrl

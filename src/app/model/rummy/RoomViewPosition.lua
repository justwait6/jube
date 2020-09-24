local RoomViewPosition = {}
local P = RoomViewPosition

P.NewHeapPos = cc.p(display.cx - 156, display.cy + 116)
P.FinishSlotPos = cc.p(display.cx, display.cy + 116)
P.OldHeapPos = cc.p(display.cx + 156, display.cy + 116)
P.MCardCenter = cc.p(display.cx, display.cy - 126)
P.MGroupInfoCenter = cc.p(display.cx, display.cy - 26)
P.NewGroupDragPos = cc.p(display.cx + 580, display.cy - 126)

-- 座位位置
P.SeatPosition = {
		[0] = cc.p(display.cx + 158, display.cy + 246),
		[1] = cc.p(display.cx + 402, display.cy + 216),
		[2] = cc.p(display.cx, display.cy - 280),
		[3] = cc.p(display.cx - 402, display.cy + 216),
		[4] = cc.p(display.cx - 158, display.cy + 246),
		[5] = cc.p(display.cx +2, display.top - 89),  --荷官位置，用于发互动道具
}
P.CardPosition = {
    [0] = cc.p(0, -140),                
    [1] = cc.p(0, -140),                
    [2] = cc.p(0, 140),               
    [3] = cc.p(0, -140),               
    [4] = cc.p(0, -140),       
}
--用户发牌的终点位置（由于和手牌添加到不同node，所以相对坐标不一致，需两套坐标） 
P.DeliverCardPosition = {
    [0] = cc.p(P.SeatPosition[0].x + P.CardPosition[0].x, P.SeatPosition[0].y + P.CardPosition[0].y),  
    [1] = cc.p(P.SeatPosition[1].x + P.CardPosition[1].x, P.SeatPosition[1].y + P.CardPosition[1].y), 
    [2] = cc.p(P.SeatPosition[2].x + P.CardPosition[2].x, P.SeatPosition[2].y + P.CardPosition[2].y),  
    [3] = cc.p(P.SeatPosition[3].x + P.CardPosition[3].x, P.SeatPosition[3].y + P.CardPosition[3].y), 
    [4] = cc.p(P.SeatPosition[4].x + P.CardPosition[4].x, P.SeatPosition[4].y + P.CardPosition[4].y),  
}
P.CoinPosition = {
    [0] = cc.p(-160, -94),              
    [1] = cc.p(-160 , 80),                
    [2] = cc.p(0, 130),                 
    [3] = cc.p(160, 80),                
    [4] = cc.p(160, -94),
}

--移动筹码起始位置
P.MoveCoinBegin = {
		[0] = cc.p(P.SeatPosition[0].x + P.CoinPosition[0].x - 60, P.SeatPosition[0].y + P.CoinPosition[0].y - 2),
		[1] = cc.p(P.SeatPosition[1].x + P.CoinPosition[1].x - 60, P.SeatPosition[1].y + P.CoinPosition[1].y - 2),
		[2] = cc.p(P.SeatPosition[2].x + P.CoinPosition[2].x - 60, P.SeatPosition[2].y + P.CoinPosition[2].y - 2),
		[3] = cc.p(P.SeatPosition[3].x + P.CoinPosition[3].x - 60, P.SeatPosition[3].y + P.CoinPosition[3].y - 2),
		[4] = cc.p(P.SeatPosition[4].x + P.CoinPosition[4].x - 60, P.SeatPosition[4].y + P.CoinPosition[4].y - 2),
}

P.RDPosition = {
    [0] = cc.p(P.SeatPosition[0].x + 80, P.SeatPosition[0].y),           
    [1] = cc.p(P.SeatPosition[1].x + 80, P.SeatPosition[1].y),              
    [2] = cc.p(P.SeatPosition[2].x + 90, P.SeatPosition[2].y),                 
    [3] = cc.p(P.SeatPosition[3].x + 80, P.SeatPosition[3].y),   
    [4] = cc.p(P.SeatPosition[4].x + 80, P.SeatPosition[4].y),   
}

P.PotPosition = cc.p(display.cx , display.cy + 110)

-- 房间灯光角度
P.LightAngle = {
    [0] = 172, 
    [1] = 206,
    [2] = -80,
    [3] = -6,
    [4] = 28,
}
P.Lightscale = {
    [0] = 0.8, 
    [1] = 0.6,
    [2] = 0.28,
    [3] = 0.8,
    [4] = 0.7,
}
P.ShowCardRotation = {
    [1] = -10,
    [2] = 6,
    [3] = 18,
}

--用户操作按钮
local operY = display.bottom + 56
P.OperBtnPosition = {
    cc.p(display.cx + 212, operY),  
    cc.p(display.cx + 476, operY), 
}


return RoomViewPosition
local RoomViewPosition = {}
local P = RoomViewPosition

P.SeatPosition = {
    [0] = cc.p(display.cx - 402, display.cy + 216),
    [1] = cc.p(display.cx, display.cy - 280),
    [2] = cc.p(display.cx + 402, display.cy + 216),
}

P.ReadyPosition = {
    [0] = cc.p(160, -100),
    [1] = cc.p(0, 150),
    [2] = cc.p(-160, -100),
}

P.WordPosition = {
    [0] = cc.p(160, -100),
    [1] = cc.p(0, display.cy + 10 - P.SeatPosition[1].y),
    [2] = cc.p(-160, -100),
}

P.DizhuIconPosition = {
    [0] = cc.p(P.SeatPosition[0].x + 80, P.SeatPosition[0].y),
    [1] = cc.p(P.SeatPosition[1].x + 96, P.SeatPosition[1].y),
    [2] = cc.p(P.SeatPosition[2].x + 80, P.SeatPosition[2].y),
}

P.OutCardPosition = {
    [0] = cc.p(P.SeatPosition[0].x + 160, P.SeatPosition[0].y - 100),
    [1] = cc.p(P.SeatPosition[1].x, display.cy + 10),
    [2] = cc.p(P.SeatPosition[2].x - 160, P.SeatPosition[2].y - 100),
}

P.OperBtnPosition = {
    [0] = cc.p(display.cx - 120, display.cy - 130), -- seencards button, left
    [1] = cc.p(display.cx + 120, display.cy - 130), -- ready button, right
    [2] = cc.p(display.cx - 120, display.cy + 10), -- Two opeare button, left
    [3] = cc.p(display.cx + 120, display.cy + 10), -- Two opeare button, right
    [4] = cc.p(display.cx - 240, display.cy + 10), -- Three opeare button, left
    [5] = cc.p(display.cx, display.cy + 10), -- Three opeare button, middle
    [6] = cc.p(display.cx + 240, display.cy + 10), -- Three opeare button, right
}

return RoomViewPosition

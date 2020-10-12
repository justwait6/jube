local RoomViewPosition = {}
local P = RoomViewPosition

P.SeatPosition = {
    [0] = cc.p(display.cx - 402, display.cy + 216),
    [1] = cc.p(display.cx, display.cy - 280),
    [2] = cc.p(display.cx + 402, display.cy + 216),
}

P.WordPosition = {
    [0] = cc.p(160, -100),
    [1] = cc.p(0, 160),
    [2] = cc.p(-160, -100),
}

P.OperBtnPosition = {
    [0] = cc.p(display.cx - 120, display.cy - 120), -- Two operate button, left
    [1] = cc.p(display.cx + 120, display.cy - 120), -- Two opeare button, right
    [2] = cc.p(display.cx - 240, display.cy), -- Three opeare button, left
    [3] = cc.p(display.cx, display.cy), -- Three opeare button, middle
    [4] = cc.p(display.cx + 240, display.cy), -- Three opeare button, right
}

return RoomViewPosition

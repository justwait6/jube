local RoomViewPosition = {}
local P = RoomViewPosition

P.SeatPosition = {
    [0] = cc.p(display.cx - 402, display.cy + 216),
    [1] = cc.p(display.cx, display.cy - 280),
    [2] = cc.p(display.cx + 402, display.cy + 216),
}

return RoomViewPosition

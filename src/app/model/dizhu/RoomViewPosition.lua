local RoomViewPosition = {}
local P = RoomViewPosition

P.SeatPosition = {
    [0] = cc.p(display.cx + 158, display.cy + 246),
    [1] = cc.p(display.cx, display.cy - 280),
    [2] = cc.p(display.cx - 158, display.cy + 246),
}

return RoomViewPosition

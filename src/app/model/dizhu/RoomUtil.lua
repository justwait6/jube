local RoomUtil = class("RoomUtil")
local roomInfo = require("app.model.dizhu.RoomInfo").getInstance()
local RoomConst = require("app.model.dizhu.RoomConst")
--我移位后的座位
function RoomUtil.getFixSeatId(seatId)
     if roomInfo:getMSeatId() < 0 then --我是站起的
          return seatId
     end
     local fixSeatId = RoomConst.MSeatId + (seatId - roomInfo:getMSeatId())
     if fixSeatId > RoomConst.UserNum - 1 then 
         fixSeatId = fixSeatId - RoomConst.UserNum
     elseif fixSeatId < 0 then
         fixSeatId = fixSeatId + RoomConst.UserNum
     end
     return fixSeatId
end

return RoomUtil

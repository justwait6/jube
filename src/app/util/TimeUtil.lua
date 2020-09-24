local TimeUtil = class("TimeUtil")

local socket = require("socket")

function TimeUtil:ctor()
end

function TimeUtil.getInstance()
	if not TimeUtil.singleInstance then
		TimeUtil.singleInstance = TimeUtil.new()
	end
	return TimeUtil.singleInstance
end

--[[
	@func getSocketTime 获取socket时间
	@return: 一个socket时间戳
--]]
function TimeUtil:getSocketTime()
    return socket.gettime()
end

--[[
	@func formatTime: 将秒数转化为HH:MM:SS格式
	@param seconds: 要格式化的秒数
	@param separator: 选择的分隔符(如为"-", 则"HH-MM-SS")
	@return: 返回格式化好的字符串
--]]
function TimeUtil:formatTime(seconds, separator)
	if not separator then print("format time ERROR: no separator specified") end

	local hh = math.floor(seconds / 3600)
	local mm = math.floor(seconds % 3600 / 60)
	local ss = math.floor(seconds % 60)

	local timeString = ""
	if hh < 10 then
		timeString = timeString .. "0" .. hh
	else
		timeString = timeString .. hh
	end

	timeString = timeString .. separator
	if mm < 10 then
		timeString = timeString .. "0" .. mm
	else
		timeString = timeString .. mm
	end

	timeString = timeString .. separator
	if ss < 10 then
		timeString = timeString .. "0" .. ss
	else
		timeString = timeString .. ss
	end

	return timeString
end

return TimeUtil

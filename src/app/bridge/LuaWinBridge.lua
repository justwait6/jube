local LuaWinBridge = class("LuaWinBridge")

function LuaWinBridge:ctor()

end

function LuaWinBridge:getFixedWidthText(font, size, text, width)
	return text
end

return LuaWinBridge

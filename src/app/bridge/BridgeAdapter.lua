local BridgeAdapter = class("BridgeAdapter")

local LuaJavaBridge = import(".LuaJavaBridge")
local LuaIOSBridge = import(".LuaIOSBridge")
local LuaWinBridge = import(".LuaWinBridge")

function BridgeAdapter:ctor()
	self._bridge = nil
	if device.platform == "android" then
    self._bridge = LuaJavaBridge.new()
	elseif device.platform == "ios" then
		self._bridge = LuaIOSBridge.new()
	else
		self._bridge = LuaWinBridge.new()
	end
end

function BridgeAdapter:getFixedWidthText(font, size, text, width)
	return self._bridge:getFixedWidthText(font, size, text, width)
end

return BridgeAdapter

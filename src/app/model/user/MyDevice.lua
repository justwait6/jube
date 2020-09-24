local MyDevice = class("MyDevice")

function MyDevice:ctor()
	self:initialize()
end

function MyDevice.getInstance()
	if not MyDevice.singleInstance then
		MyDevice.singleInstance = MyDevice.new()
	end
	return MyDevice.singleInstance
end

function MyDevice:initialize()

end

function MyDevice:getAccessToken()
	return nil
end

function MyDevice:getImei()
	local imei = device.getOpenUDID()  --设备号
	if DEBUG > 0 and g.Const.TEST_IMEI and g.Const.TEST_IMEI ~= "" then
        imei = g.Const.TEST_IMEI
	end
	return imei
end

function MyDevice:getMacAddress()
	return ""
end

function MyDevice:getOs()
	return ""
end

-- 接入方式，例如wifi
function MyDevice:getInternetAccess()
	return ""
end

-- 移动终端设备机型 iphone7
function MyDevice:getPhoneModel()
	local model = ""
	if device.platform == "ios" then
		model = device.model
	else
		model = "unknown"
	end
	return model
end

-- 移动设备平台ID号, 用于登录时web传输. 1-安卓 2-ios
function MyDevice:getPlatformId()
	local pid = 1
	if device.platform == "ios" then
		pid = 2
	end
	return pid
end

return MyDevice
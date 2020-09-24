local LoginCtrl = class("LoginCtrl")

local LoginType = require("app.model.login.LoginType")

local actMgr = require("app.model.activity.ActManager").getInstance()

function LoginCtrl:ctor(viewObj)
	self.viewObj = viewObj
	self:initialize()
end

function LoginCtrl:initialize()
end

function LoginCtrl:addEventListeners()
	-- g.event:on(g.eventNames.XX, handler(self, self.XX), self)
end

function LoginCtrl:requestGuestLogin()
	g.user:setLoginType(LoginType.GUEST)
	self:login(handler(self, self.onLoginSucc), handler(self, self.onLoginFail))
end

function LoginCtrl:requestFaceBookLogin()
	g.user:setLoginType(LoginType.FACEBOOK)
	self:login(handler(self, self.onLoginSucc), handler(self, self.onLoginFail))
end

function LoginCtrl:login(successCallback, failCallback)
	local resetWrapHandler = handler(self, function ()
        self.postLoginId = nil
    end)
	g.myUi.miniLoading:show()

	g.user:setIdentifyName(self:getInputUserName())
	local loginParams = self:getLoginParams()
	
	-- timeout连接显示一次
	self.postLoginId = g.http:simplePost(loginParams,
        successCallback, failCallback, resetWrapHandler)
end

function LoginCtrl:getLoginParams(data)
	local loginParams = {}
	loginParams.name 			= g.user:getIdentifyName()
	loginParams.password 		= self:getInputUserPassword()
	loginParams._interface		= '/login'

	loginParams.sig = self:getEncryptSiganature(loginParams)
   
    if referrer and referrer ~= "" and device.platform == "android" then
          loginParams.ads = g.myFunc:encodeURI(referrer)
    end
    if device.platform == "android" then
          loginParams.timezone = g.myFunc:encodeURI(g.Const.TIME_ZONE)
	end
	return loginParams
end

function LoginCtrl:getEncryptSiganature(params)
	local key_table = {}
	for key, _ in pairs(params) do
		table.insert(key_table, key)
	end
	table.sort(key_table)
	local str = ""
	for _,key in pairs(key_table) do
		str = str .. key .. "=" .. params[key] .. "&"
	end
	str = str .. "!@#$iop"
	return crypto.md5(str)
end

function LoginCtrl:onLoginSucc(data)
	local data = data or {}

	g.user:setHallIpAndPort(data.hallSocket)
	g.user:setLoginInfo(data.user)
	g.http:setToken(data.token)
	actMgr:setActSwitches(data.switches)
	g.mySocket:cliConnectHall()

	g.myApp:enterScene("HallScene")
end

function LoginCtrl:onLoginFail(errData)
    if tonumber(errData) == 28 or tonumber(errData) == 7 or tonumber(errData) == 6 then
    	g.myUi.topTip:showText(g.lang:getText("HTTP", "TIMEOUT"))
    elseif type(errData) == "table" then
    	errData.info = errData.info or {}
    	g.myUi.topTip:showText(errData.message)
    	print("LoginScene:onLoginFail ERROR: ", errData.info.msg)
    else
    	g.myUi.topTip:clearAll()
    	g.myUi.topTip:showText(g.lang:getText("COMMON", "NO_NETWORK"))
    end
end

function LoginCtrl:getInputUserName()
	if self.viewObj then
		return self.viewObj:getInputUserName()
	end
end

function LoginCtrl:getInputUserPassword()
	if self.viewObj then
		return self.viewObj:getInputUserPassword()
	end
end

function LoginCtrl:XXXX()
	
end

return LoginCtrl

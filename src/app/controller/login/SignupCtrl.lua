local SignupCtrl = class("SignupCtrl")

local LoginType = require("app.model.login.LoginType")

function SignupCtrl:ctor(viewObj)
	self.viewObj = viewObj
	self:initialize()
end

function SignupCtrl:initialize()
end

function SignupCtrl:requestSignup()
	self:signup(handler(self, self.onSignupSucc), handler(self, self.onSignupFail))
end

function SignupCtrl:signup(successCallback, failCallback)
	local resetWrapHandler = handler(self, function ()
        self.postLoginId = nil
    end)
	g.myUi.miniLoading:show()

	g.user:setIdentifyName(self:getInputUserName())
	local signupParams = self:getSignupParams()
	
	-- timeout连接显示一次
	self.postLoginId = g.http:simplePost(signupParams,
        successCallback, failCallback, resetWrapHandler)
end

function SignupCtrl:getSignupParams(data)
	local loginParams = {}
	loginParams.name 			= g.user:getIdentifyName()
	loginParams.password 		= self:getInputUserPassword()
	loginParams.email 			= self:getInputUserEmail()
	loginParams._interface		= '/register'

	loginParams.sig = self:getEncryptSiganature(loginParams)
   
    if referrer and referrer ~= "" and device.platform == "android" then
          loginParams.ads = g.myFunc:encodeURI(referrer)
    end
    if device.platform == "android" then
          loginParams.timezone = g.myFunc:encodeURI(g.Const.TIME_ZONE)
	end
	return loginParams
end

function SignupCtrl:getEncryptSiganature(params)
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

function SignupCtrl:onSignupSucc(data)
	if self.viewObj then
		self.viewObj:onSignupSucc(data)
	end
end

function SignupCtrl:onSignupFail(data)
	if self.viewObj then
		self.viewObj:onSignupFail(data)
	end
end

function SignupCtrl:getInputUserName()
	if self.viewObj then
		return self.viewObj:getInputUserName()
	end
end

function SignupCtrl:getInputUserPassword()
	if self.viewObj then
		return self.viewObj:getInputUserPassword()
	end
end

function SignupCtrl:getInputUserEmail()
	if self.viewObj then
		return self.viewObj:getInputUserEmail()
	end
end

function SignupCtrl:XXXX()
	
end

return SignupCtrl

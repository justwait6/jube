local User = class("User")

local Gender = require("app.model.baseDef.Gender")
User.Gender = Gender

function User:ctor()
	self:initialize()
end

function User.getInstance()
	if not User.singleInstance then
		User.singleInstance = User.new()
	end
	return User.singleInstance
end

function User:initialize()

end

function User:setUid(uid)
	self.uid = tonumber(uid)
end

function User:getUid()
	return self.uid
end

function User:setIdentifyName(identifyName)
	self.identifyName = identifyName
end

function User:getIdentifyName()
	return self.identifyName
end

function User:setName(name)
	self.name = name
end

function User:getName()
	return self.name
end

function User:getCatName(nMaxCount)
	nMaxCount = nMaxCount or 12
	return g.nameUtil:getLimitName(self.name, nMaxCount)
end

function User:setGender(gender)
	self.gender = tonumber(gender)
end

function User:getGender()
	return self.gender or Gender.FEMALE
end

function User:setExp(exp)
	self.exp = tonumber(exp)
end

function User:getExp()
	return self.exp or 0
end

function User:setVip(vip)
	self.vip = tonumber(vip)
end

function User:getVip()
	return self.vip or 0
end

function User:setIconUrl(iconUrl, isRelative)
	if isRelative then
		self.iconUrl = self:getImageBase() .. iconUrl
    else
        self.iconUrl = iconUrl
    end
end

function User:getIconUrl()
	return self.iconUrl or ""
end

function User:setImageBase(imageBase)
	self.imageBase = imageBase
end

function User:getImageBase()
	return self.imageBase or ""
end

function User:setMoney(money)
	self.money = tonumber(money)
end

function User:getMoney()
	return self.money
end

function User:setGold(gold)
	self.gold = gold
end

function User:getGold()
	return self.gold
end

function User:getAccessToken()

end

--大厅ip
function User:_setHallIp(hallip)
    self.hallip = hallip
end

function User:getHallIp()
    return self.hallip
end

--大厅port
function User:_setHallPort(hallPort)
    self.hallPort = hallPort
end

function User:getHallPort()
    return self.hallPort
end

function User:setHallIpAndPort(hallIpPort)
    if not hallIpPort then return end
    local ipports = g.myFunc:split(hallIpPort, ":")
    if #ipports ~= 2 then return end
    g.user:_setHallIp(ipports[1])
    g.user:_setHallPort(ipports[2])
end

function User:setBackupIp(backupip)
    self.backupIp = backupip
end

function User:getBackupIp()
    return self.backupIp
end

function User:setAccessServerToken(serverToken)
	self.serverToken = serverToken
end

--[[
	访问Server所需要的token
--]]
function User:getAccessServerToken()
	return self.serverToken
end

function User:getLoginType()
	return self.loginType
end

--[[
	设置登录类型: LoginType.FACEBOOK, LoginType.GUEST
--]]
function User:setLoginType(loginType)
	self.loginType = loginType
end

function User:setLoginInfo(loginUser)
	loginUser = loginUser or {}
	self:setUid(loginUser.uid)
	self:setName(loginUser.nickname)
	self:setMoney(loginUser.money or 0)
	self:setGender(loginUser.gender or 0)
	self:setIconUrl(loginUser.iconUrl)
	self:setExp(loginUser.exp or 0)
	self:setVip(loginUser.vip or 0)
end

function User:updateUserInfo(userInfo)
	userInfo = userInfo or {}
	if userInfo.nickname then
		self:setName(userInfo.nickname)
	end
	if userInfo.money then
		self:setMoney(userInfo.money or 0)
	end
	if userInfo.gender then
		self:setGender(userInfo.gender or 0)
	end
	if userInfo.iconUrl then
		self:setIconUrl(userInfo.iconUrl)
	end
	if userInfo.exp then
		self:setExp(userInfo.exp or 0)
	end
	if userInfo.vip then
		self:setVip(userInfo.vip or 0)
	end
end

function User:getUserinfo()
	return json.encode({nickName = self:getName(), icon = self:getIconUrl(), gender = self:getGender(), 
		exp = self:getExp(), money = self:getMoney(), gold = self:getGold(), 
		vip =self:getVip()})
end

return User
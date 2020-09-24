local UserManager = class("UserManager")

UserManager.VIEW_DIR_PATH = "app.view.user"

local SvrPushTypeDef = require("app.model.serverPush.PushTypeDef")

function UserManager:ctor()
	self.httpIds = {}
	self:initialize()
	self:addEventListeners()
end

function UserManager:initialize()
    
end

function UserManager:addEventListeners()
    g.event:on(g.eventNames.SERVER_PUSH, handler(self, self.onServerPush), self)
end

function UserManager.getInstance()
    if not UserManager.singleInstance then
        UserManager.singleInstance = UserManager.new()
    end
    return UserManager.singleInstance
end

function UserManager:showUserInfoView(uid)
    require("app.view.user.UserInfoView").new(uid)
end

function UserManager:uploadUserinfo(updFields)
    self:requestModifyUserinfo({fields = updFields},
    	function (updatedData)
    		g.user:updateUserInfo(updatedData)
    		g.event:emit(g.eventNames.USER_INFO_UPDATE, updatedData)
    	end,
    	function ()
    		g.myUi.topTip:showText(g.lang:getText("COMMON", "UPDATE_FAIL"))
    	end, true)
end

function UserManager:requestModifyUserinfo(params, successCallback, failCallback, noLoading)
	if self.httpIds["modifyUser"] then return end
    local resetWrapHandler = handler(self, function ()
        self.httpIds["modifyUser"] = nil
    end)

    if not noLoading then
        g.myUi.miniLoading:show()
    end

    local reqParams = {}
    reqParams._interface = "/users/modifyBaseInfo"
    reqParams.fields = params.fields or {}
    
    self.httpIds["modifyUser"] = g.http:simplePost(reqParams,
        successCallback, failCallback, resetWrapHandler)
end

function UserManager:onServerPush(data)
    if type(data) == "table" and data.pushType == SvrPushTypeDef.FRIEND then
        g.event:emit(g.eventNames.FRIEND_RED_DOT, {isShow = true})
    end
end

function UserManager:XXXX()
    
end

function UserManager:XXXX()
    
end

return UserManager

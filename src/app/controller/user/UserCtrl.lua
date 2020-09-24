local UserCtrl = class("UserCtrl")

function UserCtrl:ctor()
    self.httpIds = {}
	self:initialize()
end

function UserCtrl:initialize()
end

function UserCtrl:reqUserinfo(params, successCallback, failCallback, noLoading)
    if self.httpIds['userInfo'] then return end
    local resetWrapHandler = handler(self, function ()
        self.httpIds['userInfo'] = nil
    end)

    if not noLoading then
        g.myUi.miniLoading:show()
    end

    local reqParams = {}
    reqParams._interface = "/users/userinfo"
    reqParams.name = params.name
    reqParams.fields = params.fields or {'nickname'}
    
    self.httpSearchUserId = g.http:simplePost(reqParams,
        successCallback, failCallback, resetWrapHandler)
end

function UserCtrl:onRecordModify(key, value)
	self.toModifys = self.toModifys or {}
    if self.toModifys[key] ~= value then
        self.toModifys[key] = value
    end
end

function UserCtrl:checkUserInfoChange()
    if not self.toModifys then return end
    local fields = {}
    if self.toModifys['gender'] and g.user:getGender() ~= self.toModifys['gender'] then
        fields['gender'] = self.toModifys['gender']
    end
    if self.toModifys['nickname'] and g.user:getName() ~= self.toModifys['nickname'] then
        fields['nickname'] = self.toModifys['nickname']
    end
    if table.nums(fields) ~= 0 then
        g.userMgr:uploadUserinfo(fields)
    end
end

function UserCtrl:XXXX()
    
end

function UserCtrl:dispose()
    g.http:cancelBatch(self.httpIds)
end


return UserCtrl

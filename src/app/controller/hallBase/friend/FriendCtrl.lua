local FriendCtrl = class("FriendCtrl")

local friendMgr = require("app.model.hallBase.friend.FriendManager").getInstance()
local chatMgr = require("app.model.chat.ChatManager").getInstance()

function FriendCtrl:ctor()
	self.httpIds = {}
	self:initialize()
end

function FriendCtrl:initialize()
end

function FriendCtrl:reqFriendList(successCallback, failCallback)
	local resetWrapHandler = handler(self, function ()
        self.httpIds['friendList'] = nil
    end)
	g.myUi.miniLoading:show()

	local ctrlSuccCb = function (data)
		friendMgr:storeFriendList(data.friendList or {})
		if successCallback then successCallback(data) end
	end

	local reqParams = {}
	reqParams._interface 	= '/friend/friendList'

	self.httpIds['friendList'] = g.http:simplePost(reqParams,
		ctrlSuccCb, failCallback, resetWrapHandler)
end

function FriendCtrl:reqReqAddList(successCallback, failCallback)
	local resetWrapHandler = handler(self, function ()
        self.httpIds['reqAddList'] = nil
    end)
	g.myUi.miniLoading:show()

	local reqParams = {}
	reqParams._interface 	= '/friend/reqAddList'

	self.httpIds['reqAddList'] = g.http:simplePost(reqParams,
        successCallback, failCallback, resetWrapHandler)
end

function FriendCtrl:reqSendFriendRequest(params, successCallback, failCallback)
	local params = params or {}
	local resetWrapHandler = handler(self, function ()
        self.httpIds['friendAdd'] = nil
    end)
	g.myUi.miniLoading:show()

	local reqParams = {}
	reqParams._interface 	= '/friend/reqAdd'
	reqParams.friendUid 	= params.friendUid

	self.httpIds['friendAdd'] = g.http:simplePost(reqParams,
        successCallback, failCallback, resetWrapHandler)
end

function FriendCtrl:reqAcceptFriend(params, successCallback, failCallback)
	params = params or {}
	local resetWrapHandler = handler(self, function ()
        self.httpIds['acceptFriend'] = nil
    end)
    g.myUi.miniLoading:show()

    local reqParams = {}
    reqParams._interface 	= '/friend/accpetFriend'
    reqParams.requestUid 	= params.requestUid

    self.httpIds['acceptFriend'] = g.http:simplePost(reqParams,
        successCallback, failCallback, resetWrapHandler)
end

function FriendCtrl:reqDeleteFriend(friendUid, successCallback, failCallback)
	local params = params or {}
	local resetWrapHandler = handler(self, function ()
        self.httpIds['friendDelete'] = nil
    end)
	g.myUi.miniLoading:show()

	local reqParams = {}
	reqParams._interface 	= '/friend/deleteOne'
	reqParams.friendUid 	= params.friendUid

	self.httpIds['friendDelete'] = g.http:simplePost(reqParams,
        successCallback, failCallback, resetWrapHandler)
end

function FriendCtrl:onFriendRemarkModify(friendUid, newRemark)
	self.friendsRemarkModifys = self.friendsRemarkModifys or {}
	if friendUid and newRemark then
		self.friendsRemarkModifys[tostring(friendUid)] = newRemark
	end
end

function FriendCtrl:checkFriendsRemarkChange()
	if type(self.friendsRemarkModifys) == "table" and table.nums(self.friendsRemarkModifys) > 0 then
		friendMgr:uploadFriendRemarkList(self.friendsRemarkModifys)
	end
end

function FriendCtrl:asyncGetFriendInfo(...)
	friendMgr:asyncGetFriendInfo(...)
end

function FriendCtrl:asyncFetchChatUserInfos(callback)
	local uids = chatMgr:fetchChatUids()
	-- printVgg("uids userdefault.xml: ", dump(uids))
	if type(uids) ~= "table" then return end

	friendMgr:asyncGetFriendInfoBatch(uids, callback)
end

function FriendCtrl:reqFriendMessageList(successCallback, failCallback)
	local resetWrapHandler = handler(self, function ()
		self.httpIds['friendMessageList'] = nil
	end)
	g.myUi.miniLoading:show()

	local reqParams = {}
	reqParams._interface 	= '/friend/messageList'

	self.httpIds['friendMessageList'] = g.http:simplePost(reqParams,
			successCallback, failCallback, resetWrapHandler)
end

function FriendCtrl:reqFriendMessage(params, successCallback)
	local params = params or {}
	local resetWrapHandler = handler(self, function ()
		self.httpIds['friendMessage'] = nil
	end)
	g.myUi.miniLoading:show()

	local ctrlSuccCb = function (data)
		chatMgr:batchStoreFriendChat(data.friendUid, data.msgs)
		if successCallback then successCallback(data) end
	end

	local reqParams = {}
	reqParams._interface 	= '/friend/someFriendMessage'
	reqParams.friendUid 	= params.friendUid
	chatMgr:asyncGetLastSvrMsgId(params.friendUid, handler(self, function(self, lastSvrMsgId)
		reqParams.lastSvrMsgId = lastSvrMsgId or 0
		printVgg(lastSvrMsgId, "lastSvrMsgId")
		self.httpIds['friendMessage'] = g.http:simplePost(reqParams,
		ctrlSuccCb, failCallback, resetWrapHandler)
	end))
end

function FriendCtrl:setMessageRead(friendUid)
	-- 更新本地内存
	friendMgr:setMessageRead(friendUid)
	-- 上传服务器
	self:uploadMessageRead(friendUid)
end

function FriendCtrl:uploadMessageRead(friendUid)
	local params = params or {}
	local resetWrapHandler = handler(self, function ()
		self.httpIds['updMsgRead'] = nil
	end)

	local reqParams = {}
	reqParams._interface 	= '/friend/updateMessageRead'
	reqParams.friendUid 	= friendUid
	chatMgr:asyncGetLastSvrMsgId(friendUid, handler(self, function(self, lastSvrMsgId)
		reqParams.lastSvrMsgId = lastSvrMsgId or 0
		self.httpIds['updMsgRead'] = g.http:simplePost(reqParams,
		nil, nil, resetWrapHandler)
	end))
end

function FriendCtrl:XXXX()
	
end

function FriendCtrl:XXXX()
	
end

function FriendCtrl:XXXX()
	
end

function FriendCtrl:dispose()
	g.http:cancelBatch(self.httpIds)
end

return FriendCtrl

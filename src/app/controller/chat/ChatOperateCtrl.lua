local ChatOperateCtrl = class("ChatOperateCtrl")

local chatMgr = require("app.model.chat.ChatManager").getInstance()
local MessageType = require("app.model.message.MessageType")

function ChatOperateCtrl:ctor(viewObj)
    self.viewObj = viewObj
    self.httpIds = {}
    self:initialize()
end

function ChatOperateCtrl:initialize()
end

function ChatOperateCtrl:bindChatUser(uid)
    self._chatUid = uid
end

function ChatOperateCtrl:sendChat(msg, msgType)
    -- -- clear friend database
    -- if true then
    --     chatMgr:storeFriendChat(self._chatUid, {msg = msg})
    --     return
    -- end
    local data = {
        type = msgType or MessageType.TEXT,
        srcUid = g.user:getUid(),
        destUid = self._chatUid,
        sentTime = os.time(),
        msg = msg,
    }

    -- 对于刚发送(但server没有给与回应)的消息, 先缓存
    local keyId = chatMgr:cacheSentMessage(data)
    data.keyId = keyId

    -- 发送给对方自己的消息
    g.mySocket:sendChat(data)

    -- 清空输入框
    if self.viewObj then
        self.viewObj:resetInput()
    end
end

function ChatOperateCtrl:XXXX()
    
end

function ChatOperateCtrl:XXXX()
    
end

function ChatOperateCtrl:XXXX()
    
end

function ChatOperateCtrl:dispose()
    g.http:cancelBatch(self.httpIds)
end

return ChatOperateCtrl

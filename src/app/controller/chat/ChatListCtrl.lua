local ChatListCtrl = class("ChatListCtrl")

local chatMgr = require("app.model.chat.ChatManager").getInstance()

function ChatListCtrl:ctor()
    self:initialize()
end

function ChatListCtrl:initialize()
end

function ChatListCtrl:asyncFetchChatData(...)
    chatMgr:asyncFetchChatData(...)
end

function ChatListCtrl:insertChatUid(...)
	chatMgr:insertChatUid(...)
end

function ChatListCtrl:deleteChatUidIf(uid)
	chatMgr:deleteChatUidIf(uid)
end

function ChatListCtrl:XXXX()
    
end

function ChatListCtrl:XXXX()
    
end

function ChatListCtrl:dispose()
	chatMgr:storeChatUids()
end

return ChatListCtrl

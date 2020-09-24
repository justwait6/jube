local ChatStoreUtil = class("ChatStoreUtil")

function ChatStoreUtil:ctor()
	self:initialize()
    self:addEventListeners()
end

function ChatStoreUtil:initialize()
    
end

function ChatStoreUtil:addEventListeners()
    -- g.event:on(g.eventNames.XXXX, handler(self, self.XXXX), self)
end

function ChatStoreUtil:storeFriendChat(friendUid, data)
    local data = data or {}
    local tableName = self:getFriendChatTableName(friendUid)

		--[[
		-- test begin
		if data.msg == '1' then
    	local t_search_sql = string.format([=[
			SELECT * FROM %s;
		]=], tableName);

		g.dbMgr:query(t_search_sql, 'search_' .. tableName, function (data)
			dump(data, 'query data')
		end)
    	return
    elseif data.msg == '2' then
    	g.dbMgr:dropTable(tableName);
    	return
    end
    -- test end
		--]]

    local function insert()
    	local changedMsg = self:replaceString(data.msg)
    	local t_insert_sql = string.format([=[
			INSERT INTO %s (MSG_ID, SVR_MSG_ID, TYPE, SRCUID, DESTUID, SENTTIME, MSG)
			VALUES ( NULL, %d, %d, %d, %d, %d, '%s' );
		]=], tableName, data.msgId, data.type, data.srcUid, data.destUid, data.sentTime, changedMsg);

    	print(t_insert_sql);
			g.dbMgr:executeSql(t_insert_sql, function (isOk)
				if isOk then print("insert success") end
			end)
    end

		self:createTableIf({tableName = tableName, completeCallback = insert})
end

function ChatStoreUtil:batchStoreFriendChat(friendUid, messages)
	local messages = messages or {}
	local tableName = self:getFriendChatTableName(friendUid)

	local function batchInsert()
		local t_insert_sql = "\nBEGIN  TRANSACTION;\n"
		local insert_template = "INSERT INTO %s (MSG_ID, SVR_MSG_ID, TYPE, SRCUID, DESTUID, SENTTIME, MSG)\nVALUES ( NULL, %d, %d, %d, %d, %d, '%s' );\n"
		for _, data in pairs(messages) do
			local changedMsg = self:replaceString(data.msg)
			t_insert_sql = t_insert_sql .. string.format(insert_template, tableName, data.msgId, data.type, data.srcUid, data.destUid, data.sentTime, changedMsg)
		end
		t_insert_sql = t_insert_sql .. "END TRANSACTION;\n"

		g.dbMgr:executeTransaction(t_insert_sql, function (isOk)
			if isOk then print("batch insert success") end
		end)

	end

	self:createTableIf({tableName = tableName, completeCallback = batchInsert})
end

function ChatStoreUtil:createTableIf(params)
	local params = params or {}
	local tableName = params.tableName or ""
	local completeCallback = params.completeCallback

	g.dbMgr:isTableExist(tableName, function (isExist)
		if not isExist then
			print("table not exist, try creating: ", tableName)
			self:createFriendChatTable(tableName, function (isOk)
				if isOk and completeCallback then completeCallback() end
			end)
		else
			if completeCallback then completeCallback() end
		end
	end)
end

function ChatStoreUtil:createFriendChatTable(tableName, callback)
	printVgg("tablename", tableName)
	local t_friend_chat_sql = string.format([=[
		CREATE TABLE %s (
			MSG_ID INTEGER PRIMARY KEY AUTOINCREMENT,
			SVR_MSG_ID INTEGER,
			TYPE TINYINT,
			SRCUID INT NOT NULL,
			DESTUID INT NOT NULL,
			SENTTIME INT NOT NULL,
			MSG TEXT
		);
	]=], tableName)
	g.dbMgr:executeSql(t_friend_chat_sql, callback)
end

function ChatStoreUtil:fetchFriendChat(friendUid, callback)
	local tableName = self:getFriendChatTableName(friendUid)

	-- query (at most) last 20 messages
    local t_search_sql = string.format([=[
		SELECT * FROM (SELECT * FROM %s ORDER BY MSG_ID DESC LIMIT 20) AA ORDER BY MSG_ID;
	]=], tableName);

	g.dbMgr:query(t_search_sql, 'search_' .. tableName, function (data)
		local retData = {}
		for _, v in pairs(data) do
			local changedMsg = self:unreplaceString(v[7]);			
			table.insert(retData, {
				type = tonumber(v[3]),
				srcUid = tonumber(v[4]),
				destUid = tonumber(v[5]),
				sentTime = tonumber(v[6]),
				msg = changedMsg,
			})
		end
		if callback then callback(retData) end
	end)
end

function ChatStoreUtil:getFriendChatTableName(friendUid)
    return "ChatFriend" .. g.user:getUid() .. "_" .. friendUid
end

function ChatStoreUtil:replaceString(msg)
    local changedMsg = string.gsub(msg, "\'", "&lquote;");
	changedMsg = string.gsub(changedMsg, "\"", "&quote;");
	changedMsg = string.gsub(changedMsg, '\\', "&\\\\;");

	return changedMsg
end

function ChatStoreUtil:unreplaceString(enmsg)
    local changedMsg = string.gsub(enmsg, "&lquote;", "\'");
	changedMsg = string.gsub(changedMsg, "&quote;", "\"");
	changedMsg = string.gsub(changedMsg, '&\\\\;', "\\");

	return changedMsg
end

function ChatStoreUtil:asyncGetLastSvrMsgId(friendUid, callback)
	local tableName = self:getFriendChatTableName(friendUid)
	local function query()
		local t_search_sql = string.format([=[
			SELECT SVR_MSG_ID FROM %s ORDER BY MSG_ID DESC LIMIT 1;
		]=], tableName);
		g.dbMgr:query(t_search_sql, 'last_msg_id' .. tableName, function (data)
			local svrMsgId = -1
			for _, v in pairs(data) do
				svrMsgId = tonumber(v[1])
			end
			if callback then callback(svrMsgId) end
		end)
	end

	self:createTableIf({tableName = tableName, completeCallback = query})
end

function ChatStoreUtil:XXXX()
    
end

function ChatStoreUtil:XXXX()
    
end

function ChatStoreUtil:XXXX()
    
end

return ChatStoreUtil

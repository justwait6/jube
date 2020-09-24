local ChatScreenView = class("ChatScreenView", function ()
	return display.newNode()
end)

local LIST_WIDTH = 582
local LIST_HEIGHT = 536

function ChatScreenView:ctor()
	self:setNodeEventEnabled(true)
	self:initialize()
	self:addEventListeners()
end

function ChatScreenView:initialize()
	local itemBg = display.newScale9Sprite(g.Res.black, 0, 0, cc.size(LIST_WIDTH, LIST_HEIGHT))
    :pos(0, 0):addTo(self)
  self._chatHistoryView = g.myUi.UIListView.new(LIST_WIDTH, LIST_HEIGHT)
    :pos(0, 0)
    :addTo(self)
end

function ChatScreenView:addEventListeners()
	-- g.event:on(g.eventNames.XXXX, handler(self, self.XXXX), self)
end

local DEFAULT_ITEM_HEIGHT = 50
local MAX_CHAT_LBL_WIDTH = 450
function ChatScreenView:onUpdate(historyList)
	local historyList = historyList or {}

	self._chatHistoryView:removeAllItems()

	for i, v in pairs(historyList) do
		self:_addItem(v)
	end
	self._delayShowId = g.mySched:doDelay(handler(self, self.delayScroll), 0.05)
end

function ChatScreenView:_addItem(data)
	-- 时间
  if self:isShowTime(data.time) then
    local timeLbl = display.newTTFLabel({text = self:getTimeFormat(data.sentTime), size = 20, color = cc.c3b(208, 198, 202)})
      :pos(LIST_WIDTH/2, 15)
      self._chatHistoryView:addNode(timeLbl, LIST_WIDTH, 30)
  end

	-- 聊天项
	local chatItem = self:_newChatItem(data)
	local itemHeight = self:getCurItemHeight()
	chatItem:pos(0, itemHeight/2)
  self._chatHistoryView:addNode(chatItem, LIST_WIDTH, itemHeight)    
end

function ChatScreenView:_newChatItem(data)
	local SELF_TEXT_COLOR = nil

	self._curItemHeight = nil -- 重置当前Item高度

	local node = display.newNode()
	-- 聊天文字
	local lbl = display.newTTFLabel({text = data.msg, size = 20, color = cc.c3b(248, 248, 242)})
    :setAnchorPoint(cc.p(0, 0.5))
    :addTo(node)
  local lblWidth = lbl:getContentSize().width

  if lbl:getContentSize().width > MAX_CHAT_LBL_WIDTH then
    lblWidth = MAX_CHAT_LBL_WIDTH
    lbl:setDimensions(MAX_CHAT_LBL_WIDTH, 0)
  end

  self._curItemHeight = lbl:getContentSize().height
  if self._curItemHeight < DEFAULT_ITEM_HEIGHT then
   	self._curItemHeight = DEFAULT_ITEM_HEIGHT
  else
   	self._curItemHeight = self._curItemHeight + 20
  end
	if data.srcUid == g.user:getUid() then
		lbl:pos(LIST_WIDTH - lblWidth - 20, 0)
	else
		lbl:pos(20, 0)
	end

	return node
end

function ChatScreenView:getCurItemHeight()
	return self._curItemHeight
end

function ChatScreenView:isShowTime(time)
	local isShowTime = false
	if not self._lastChatTime or time - (self._lastChatTime or 0) > 60 then
		isShowTime = true
		self._lastChatTime = time
	end
	return isShowTime
end

function ChatScreenView:getTimeFormat(time)
	local todayZeroTime = g.myFunc:getTodayTimeStamp()
	if time > todayZeroTime then
		-- 今天某个时候
		return os.date("%H:%M", time)
	elseif todayZeroTime - 86400 < time and time < todayZeroTime then
		-- 昨天某个时候
		return g.lang:getText("TIME", "YESTERDAY") .. " " .. os.date("%H:%M", time)
	else
		-- 显示日期
		return os.date("%Y-%m-%d %H:%M", time)
	end
end

function ChatScreenView:addChatItem(data)
	self:_addItem(data)
	self._delayShowId = g.mySched:doDelay(handler(self, self.delayScroll), 0.05)
end

function ChatScreenView:batchAddChatItem(data)
	for _, v in pairs(data) do
		self:_addItem(v)
	end
	self._delayShowId = g.mySched:doDelay(handler(self, self.delayScroll), 0.05)
end

function ChatScreenView:getCurItemHeight()
	return self._curItemHeight
end

function ChatScreenView:delayScroll()
	if self and self._chatHistoryView then
		self._chatHistoryView:jumpToBottom()
	end
end

function ChatScreenView:XXXX()
	
end

function ChatScreenView:XXXX()
	
end

function ChatScreenView:XXXX()
	
end

function ChatScreenView:XXXX()
	
end

function ChatScreenView:onCleanup()
	if self._delayShowId then g.mySched:cancel(self._delayShowId) end
end

return ChatScreenView

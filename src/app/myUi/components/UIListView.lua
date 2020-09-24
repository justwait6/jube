local UIListView = class("UIListView", function()
    return display.newNode()
end)

function UIListView:ctor(width, height)

    self.width = width
    -- create listview, or get listview from csb
    self.lv = ccui.ListView:create()
    self.lv:setContentSize(cc.size(width, height))
    -- self.lv:center():addTo(self)
    self.lv:addTo(self)
    -- self.lv:setBackGroundColorType(1)
    self.lv:setBackGroundColorType(0)
    self.lv:setBackGroundColor(cc.c3b(0, 0, 0))
    self.lv:setAnchorPoint(cc.p(0.5, 0.5))
    self.lv:setItemsMargin(0)
end

function UIListView:addScrollViewEventListener(callback)
    self.lv:addScrollViewEventListener(function(ref, type)
            if callback and type == 1 then
                callback()
            end
        end)
end

function UIListView:getItems()
	return self.lv:getItems()
end

function UIListView:getAddedBeginNode()
	local node = nil
	local item = self.lv:getItem(0)
	if not tolua.isnull(item) then
		local childs = item:getChildren()
		if childs[1] then
			node = childs[1]
		end
	end

	return node
end

function UIListView:getAddedNodes()
	local nodes = {}
	local items = self:getItems()
	for _, item in pairs(items) do
		local childs = item:getChildren()
		for _, child in pairs(childs) do
			table.insert(nodes, child)
		end
	end

	return nodes
end

function UIListView:getAddedNodeByTag(tag)
	local selNodeIf = nil
	local nodes = self:getAddedNodes() or {}
	for _, node in pairs(nodes) do
		if node and tonumber(node:getTag()) == tag then
			selNodeIf = node
			break
		end
	end

	return selNodeIf
end

function UIListView:removeAddedNode(node)
	if not tolua.isnull(node) then
		local viewLayout = node:getParent()
		self.lv:removeItem(self.lv:getIndex(viewLayout))
	end
end

function UIListView:removeAllItems()
	self.lv:removeAllItems()
end

function UIListView:addNode(node, width, height)
	local layer = ccui.Layout:create()
    node:addTo(layer)
    layer:setContentSize(cc.size(width, height))
	self.lv:pushBackCustomItem(layer)
end

function UIListView:addNodeInBegin(node, width, height)
    local layer = ccui.Layout:create()
    node:addTo(layer)
    layer:setContentSize(cc.size(width, height))
    self.lv:insertCustomItem(layer, 0)
end

function UIListView:setInnerSize(width, height)
	self.lv:setInnerContainerSize(cc.size(width, height))
end

function UIListView:getInnerSize()
    return self.lv:getInnerContainerSize()
end

function UIListView:requestRefreshView()
    self.lv:requestRefreshView()
end

function UIListView:refreshView()
    self.lv:refreshView()
end

function UIListView:jumpToBottom()
    self.lv:jumpToBottom()
end

function UIListView:scrollToBottom(time, attenuated)
    self.lv:scrollToBottom(time or 0.01, attenuated or false)
end

return UIListView

local MiniLoading = class("MiniLoading")

function MiniLoading:ctor(params)
	self:initialize()
end

function MiniLoading:initialize()
	self.currentAddedScene = display.getRunningScene()
	if self.currentAddedScene then
		self.uiNode = self:createMiniLoading()
			:addTo(self.currentAddedScene, 99)
	end
end

function MiniLoading:createMiniLoading()
	local node = display.newNode()
		:pos(display.cx, display.cy)

		display.newSprite(g.Res.loadingBg):addTo(node)
		self.miniLoader = display.newSprite(g.Res.loadingIcon)
			:addTo(node)
	return node
end

function MiniLoading.getInstance()
	if not MiniLoading.singleInstance then
		MiniLoading.singleInstance = MiniLoading.new()
	end
	return MiniLoading.singleInstance
end

function MiniLoading:show()
	local scene = display.getRunningScene()
	if not scene then return end
	if scene ~= self.currentAddedScene then
		if not tolua.isnull(self.uiNode) then
			self.uiNode:retain()
			self.uiNode:removeFromParent()
			self.uiNode:addTo(scene, 99)
			self.uiNode:release()
			self.currentAddedScene = scene
		else
			self.uiNode = self:createMiniLoading()
				:addTo(scene, 99)
		end
	end

	self.uiNode:show()

	if self.miniLoader then
		self.miniLoader:runAction(cc.RepeatForever:create(cc.RotateBy:create(1.5, 360)))
	end
	return self
end

function MiniLoading:hide()
	if tolua.isnull(self.miniLoader) then return end
	if self.miniLoader then
		self.miniLoader:stopAllActions()
	end
	if self.uiNode then
		self.uiNode:hide()
	end
	return self
end

function MiniLoading:pos(x, y)
	if self.uiNode then
		self.uiNode:pos(display.cx + x, display.cy + y)
	end
	return self
end

return MiniLoading
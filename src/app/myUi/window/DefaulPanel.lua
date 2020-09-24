local DefaulPanel = class("DefaulPanel", function ()
	return display.newNode()
end)

DefaulPanel.WIDTH = 420
DefaulPanel.HEIGHT = 260

function DefaulPanel:ctor(params)
	local params = params or {}
	self:initilize(params)
end

function DefaulPanel:initilize(params)
	local width = params.width or self.WIDTH
	local height = params.height or self.HEIGHT
	local bgRes = params.bgRes or g.Res.blank
	local transBg = display.newScale9Sprite(bgRes, 0, 0, cc.size(width, height))
		:addTo(self)
	transBg:setTouchSwallowEnabled(true)
	transBg:addNodeEventListener(cc.NODE_TOUCH_EVENT, function() return true end)
	transBg:setTouchEnabled(true)

	if params.monoBg then
		local draw = cc.DrawNode:create()
		local startPoint = cc.p(-width/2, -height/2)
		local endPoint = cc.p(width/2, height/2)
		local color = params.bgColor or cc.c3b(255, 255, 255)
		draw:drawSolidRect(startPoint, endPoint, cc.c4f(color.r/255, color.g/255, color.b/255, 1))
		self:addChild(draw)
	end
end

return DefaulPanel

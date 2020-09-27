local Window = class("Window", function ()
	return display.newNode()
end)

local DefaulPanel = import(".DefaulPanel")

function Window:ctor(params)
	local pos = params.pos or cc.p(display.cx, display.cy)
	self:pos(pos.x, pos.y)
	self.panel = DefaulPanel.new(params):addTo(self)

	local isModal = params.isModal or false
	local isCoverClose = params.isCoverClose or false
	local name = params.name or ""
	if isModal then
		-- 模态框点击背景透明遮罩区域不会关闭
		isCoverClose = false
	end
	local noShowAnim = false
	g.windowMgr:addWindow(self, name, isModal, isCoverClose, noShowAnim)
end

function Window:addClose(point)
	local redClose = cc.DrawNode:create()
    redClose:drawSegment(cc.p(-10, -10), cc.p(10, 10), 2, cc.c4f(0.8,0,0,0.8))
    redClose:drawSegment(cc.p(-10, 10), cc.p(10, -10), 2, cc.c4f(0.8,0,0,0.8))
    redClose:pos(point.x, point.y):addTo(self)
    g.myUi.ScaleButton.new({normal = g.Res.blank})
        :pos(point.x, point.y)
        :setButtonSize(cc.size(70, 70))
        :onClick(handler(self, self.close))
        :addTo(self)
end

function Window:close()
	g.windowMgr:removeWindow(self)
end

return Window

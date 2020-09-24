local Window = import("..window.Window")
local Dialog = class("Dialog", Window)

local ScaleButton = import("..components.ScaleButton")

local DialogType = import(".DialogType")
Dialog.Type = DialogType

Dialog.WIDTH = 420
Dialog.HEIGHT = 260

--[[
	@func ctor: 构造函数
	@param params: table类型, 构造时传入的参数
		|=>params.type: 对话框类型, 与DialogType里类型相对应
		|=>params.isModal: 是否是模态框, 默认为true
		|=>params.text: 对话框文字, 提示内容
		|=>params.confirmCb: 确认点击回调
--]]
function Dialog:ctor(params)
	local params = params or {}
	self.text = params.text or ""
	self.type = params.type or DialogType.NORMAL
	self.isModal = (params.isModal ~= false)
	self.confirmCb = params.onConfirm
	self.cancelCb = params.onCancel

	self.super.ctor(self, {noBg = true, isModal = self.isModal})

	self:initilize()
end

function Dialog:initilize()
	-- background
	display.newRect(cc.rect(-self.WIDTH/2, -self.HEIGHT/2, self.WIDTH, self.HEIGHT),
        {fillColor = cc.c4f(1, 1, 1, 1), borderWidth = 0})
		:addTo(self, -1)

	-- content text
	display.newTTFLabel({text = self.text, size = 24, color = cc.c3b(40, 41, 35)})
		:pos(0, 10)
		:addTo(self)

	-- confirm button
	local buttonSize = cc.size(106, 42)
	self.confirmButton = ScaleButton.new({normal = g.Res.blank}, {scale9 = true})
		:setButtonLabel(display.newTTFLabel({size = 26, text = g.lang:getText("COMMON", "CONFIRM"), color = cc.c3b(137, 190, 224)}))
		:onClick(handler(self, self.onConfirmClick))
		:addTo(self)

	-- cancel button
	self.cancelButton = ScaleButton.new({normal = g.Res.blank}, {scale9 = true})
		:setButtonLabel(display.newTTFLabel({size = 26, text = g.lang:getText("COMMON", "CANCEL"), color = cc.c3b(137, 190, 224)}))
		:onClick(handler(self, self.onCancelClick))
		:addTo(self)

	if self.type == DialogType.NORMAL then
		self.confirmButton:pos(self.WIDTH/5, -self.HEIGHT/2 + buttonSize.height/2 + 20):show()
		self.cancelButton:pos(-self.WIDTH/5, -self.HEIGHT/2 + buttonSize.height/2 + 20):show()
	elseif self.type == DialogType.ALERT then
		self.confirmButton:pos(0, -self.HEIGHT/2 + buttonSize.height/2 + 20):show()
		self.cancelButton:hide()
	end
end

--[[
	@func onConfirmClick: [确认按钮]点击回调
--]]
function Dialog:onConfirmClick()
	if self.confirmCb then
		self.confirmCb()
	end

	self:close()
end

--[[
	@func onCancelClick: [取消按钮]点击回调
--]]
function Dialog:onCancelClick()
	if self.cancelCb then
		self.cancelCb()
	end

	self:close()
end

return Dialog

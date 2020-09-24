local EditBox = class("EditBox", function()
    return display.newNode()
end)

function EditBox:ctor(param)
	-- lua sample
	local function editboxEventHandler(eventType)
	    if eventType == "began" then
	        -- triggered when an edit box gains focus after keyboard is shown
	        if param.beginCallback then
	        	param.beginCallback(self)
	        end
	    elseif eventType == "ended" then
	        -- triggered when an edit box loses focus after keyboard is hidden.
	        if param.callback then
				param.callback(1, self)
			end
	    elseif eventType == "changed" then
	        -- triggered when the edit box text was changed.
	    elseif eventType == "return" then
	    	if param.returnCallback then
	    		param.returnCallback(self)
	    	end
	        -- triggered when the return button was pressed or the outside area of keyboard was touched.
	    end
	end

	local fontSize = param.fontSize or 24
	local size = param.size or cc.size(190, 63)
	self.inputNode = ccui.EditBox:create(cc.size(size.width, fontSize + 16), "", 1)
    self.inputNode:pos(0, 0)
    self.inputNode:setFontSize(fontSize)
    if param.fontColor then
    	if param.fontColor.R then
    		self.inputNode:setFontColor(cc.c3b(param.fontColor and param.fontColor.R or 255, param.fontColor and param.fontColor.G or 255, param.fontColor and param.fontColor.B or 255))
    	else
    		self.inputNode:setFontColor(param.fontColor or cc.c3b(255, 255, 255))
    	end
    end
    -- self.inputNode:setFontColor(param.fontColor or cc.c3b(255, 255, 255 ))
    self.inputNode:setPlaceholderFontColor(param.holderColor or cc.c3b(0, 0, 0))
    self.inputNode:setPlaceholderFontSize(fontSize)
    self.inputNode:setPlaceHolder(param.placeHolder or "")
    self.inputNode:setMaxLength(param.maxLength or 190)
    self.inputNode:registerScriptEditBoxHandler(editboxEventHandler)
    self.inputNode:addTo(self)
    self.inputNode:setAnchorPoint(cc.p(0, 0.5))

    if param.inputFlag then
    	self.inputNode:setInputFlag(param.inputFlag)
    end
    
	if param.image then
		local imageOffset = param.imageOffset or cc.p(0, 0)
		display.newSprite(param.image):pos(imageOffset.x, imageOffset.y):addTo(self, -1)
	end
end

function EditBox:setString(text)
	if self.inputNode then
		self.inputNode:setText(text or "")
	end
	return self
end

function EditBox:getString()
	if self.inputNode then
		return self.inputNode:getText()
	end
	return ""
end

function EditBox:setText(text)
	if self.inputNode then
		self.inputNode:setText(text or "")
	end
	return self
end

function EditBox:getText()
	if self.inputNode then
		return self.inputNode:getText()
	end
	return ""
end

return EditBox

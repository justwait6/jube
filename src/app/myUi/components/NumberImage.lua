local NumberImage = class("NumberImage", function()
    return display.newNode()
end)

function NumberImage:ctor(uiPath, ...)
    self.muiPath = uiPath
    self.w = 0
    self.h = 0
end

function NumberImage:setNumber(formatNumber,xoffset)
    xoffset = xoffset or 0
    self:removeAllChildren()
    
    local x,y = 0,0
    local len = string.len(formatNumber)
    for i = 1,len do
    	   local c = string.sub(formatNumber,i,i)
    	   if self.muiPath[c] then
    	       local numImg = display.newSprite(self.muiPath[c])
    	       if numImg then
    	           local size = numImg:getContentSize()
    	           numImg:align(display.CENTER_LEFT)
    	           numImg:pos(x, y)
    	           x = x + size.width + xoffset
    	           self.w = x
    	           self.h = size.height
    	           self:addChild(numImg)
    	           self:setContentSize(x-xoffset, size.height)
    	       end
    	   end
    end

    return self
end

return NumberImage

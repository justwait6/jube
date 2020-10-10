local DizhuScene = class("DizhuScene", function()
    return display.newScene("DizhuScene")
end)

local RoomView = require("app.view.dizhu.RoomView")

function DizhuScene:ctor()
    self:initialize()
end

function DizhuScene:initialize()
    self:createNodes()
    self.dizhuView = RoomView.new(self):pos(display.cx, display.cy):addTo(self)
end

function DizhuScene:createNodes()
    self.nodes = { }
    self.nodes.bgNode = display.newNode():addTo(self)
    self.nodes.seatNode = display.newNode():addTo(self)
    self.nodes.roomNode = display.newNode():addTo(self)
    self.nodes.buttonNode = display.newNode():addTo(self)
    -- self.nodes.batchNode = display.newBatchNode("roomchip.png"):addTo(self)
    self.nodes.animNode = display.newNode():addTo(self)
end

function DizhuScene:onEnter()
    g.mySocket:cliEnterRoom()
end

function DizhuScene:onExit()
end

return DizhuScene

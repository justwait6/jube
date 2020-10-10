local RummyScene = class("RummyScene", function()
    return display.newScene("RummyScene")
end)

local RoomView = require("app.view.rummy.RoomView")

function RummyScene:ctor()
    self:initialize()
end

function RummyScene:initialize()
    self:createNodes()
    self.roomView = RoomView.new(self):pos(display.cx, display.cy):addTo(self)
end

function RummyScene:createNodes()
    self.nodes = { }
    self.nodes.bgNode = display.newNode():addTo(self)
    self.nodes.seatNode = display.newNode():addTo(self)
    self.nodes.roomNode = display.newNode():addTo(self)
    self.nodes.buttonNode = display.newNode():addTo(self)
    -- self.nodes.batchNode = display.newBatchNode("roomchip.png"):addTo(self)
    self.nodes.animNode = display.newNode():addTo(self)
end

function RummyScene:onEnter()
    g.mySocket:cliEnterRoom()
end

function RummyScene:onExit()
end

return RummyScene

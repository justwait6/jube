local RummyScene = class("RummyScene", function()
    return display.newScene("RummyScene")
end)

local RummyView = require("app.view.rummy.RummyView")

function RummyScene:ctor()
    self:initialize()
end

function RummyScene:initialize()
    self:createNodes()
    self.rummyView = RummyView.new(self):pos(display.cx, display.cy):addTo(self)
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
    g.mySocket:cliEnterRoom(g.Var.tid)
end

function RummyScene:onExit()
end

return RummyScene

local DownMenuView = class("DownMenuView", g.myUi.Window)

DownMenuView.WIDTH = 265
DownMenuView.HEIGHT = 480
local itemHeight = 80
local roomInfo = require("app.model.rummy.RoomInfo").getInstance()

local mResDir = "image/commonroom/menu/" -- module resource directory

function DownMenuView:ctor(clickEvent)
    local posX = display.left + self.WIDTH/2
    local posY = display.top - self.HEIGHT/2
    DownMenuView.super.ctor(self, {width = self.WIDTH, height = self.HEIGHT, bgRes = mResDir .. "bg.png", pos = cc.p(posX, posY), isCoverClose = true})
    self.panelNode = display.newNode():addTo(self)
    self.clickItem = 0
	self.clickEvent = clickEvent
		
    self:initConfig()
    self:createItems()
end

--各游戏各自实现这个方法
function DownMenuView:initConfig()
    self.config = {
			{click = "click", res = mResDir .. "icon_back.png", text = g.lang:getText("RUMMY", "BACK")},
            {click = "click", res = mResDir .. "icon_switch_table.png", text=g.lang:getText("RUMMY", "SWITCH_TABLE")},
            {click = "click", res = mResDir .. "icon_card_type.png", text=g.lang:getText("RUMMY", "HAND_RANKING")},
			{click = "click", res = mResDir .. "icon_exit_room.png", text=g.lang:getText("RUMMY", "EXIT_TO_LOBBY")},
			{res = mResDir .. "icon_last_round.png", text=g.lang:getText("RUMMY", "LAST_ROUND"), check = "check"},
        }
end

function DownMenuView:createItems()
    if not self.config then return end

	for k,v in ipairs(self.config) do
		local node = display.newNode()
			:setContentSize(150, 50)
        	:pos(0, self.HEIGHT/2 - 40 - (k-1)*itemHeight)
		if v.text then
			display.newTTFLabel( { text = v.text, color = cc.c3b(0xff, 0xff, 0xff), size = 24})
  				:pos(-60, 0)
  				:addTo(node)
				:setAnchorPoint(cc.p(0, 0.5))
		end
		if v.click then
            g.myUi.ScaleButton.new({normal = g.Res.blank})
                :onClick(handler(self, function(sender) 
                    if self.clickEvent and self.clickEvent[k] then
                        self.clickEvent[k]()
                    end
                    self:close()
                end))
				:pos(0, 0)
				:addTo(node)
				:setSwallowTouches(true)
				:setScale9Enabled(true)
				:setContentSize(cc.size(226, 64))
		end
		if v.check then
			local isCheck = roomInfo:getLastRound()
            local check = g.myUi.ScaleButton.new({normal = mResDir .. "check_no.png"})
                :onClick(handler(self, function(sender)
                    if isCheck then
                        isCheck = false
                        local child = node:getChildByTag(110)
                        if child then
                            child:hide()
                        end
                        roomInfo:setLastRound(false)
                    else 
                        isCheck = true
                        local child = node:getChildByTag(110)
                        if child then
                            child:show()
                        end
                        roomInfo:setLastRound(true)
                    end
                end))
                :pos(88, 0)
                :addTo(node)
                :setSwallowTouches(true)
			local yes = display.newSprite(mResDir .. "check_yes.png")
				:pos(88 + 5, 0 + 5)
				:addTo(node)
				:setTag(110)
			if isCheck then
				yes:show()
			else
				yes:hide()
			end
		end
		if v.res then
			display.newSprite(v.res):addTo(node):pos(-94, 0)
		end
        node:addTo(self.panelNode)
	end
end

function DownMenuView:onShowPopUp()
	self.backGround_:stopAllActions()
	g.myFunc:setAllCascadeOpacityEnabled(self.backGround_)
	self.backGround_:setScale(0.88):opacity(0.85*255)
	local fadeAction = cc.FadeIn:create(0.18)
	local scaleAction = cc.ScaleTo:create(0.15,1)
	local spawnAction = cc.Spawn:create(fadeAction,scaleAction)
	self:runAction(spawnAction)
end

function DownMenuView:onWindowRemove()
	local fadeAction = cc.FadeOut:create(0.18)
    local scaleAction = cc.ScaleTo:create(0.18,0.88)
    local spawnAction = cc.Spawn:create(fadeAction,scaleAction)
    local sequence = cc.Sequence:create(spawnAction,cc.CallFunc:create(function()
        removeFunc()
    end))
    self:stopAllActions()
    self:runAction(sequence)
end

return DownMenuView

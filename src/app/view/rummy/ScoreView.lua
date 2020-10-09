local ScoreView = class("ScoreView", g.myUi.Window)
local roomInfo = require("app.model.rummy.RoomInfo").getInstance()
local RoomUtil = require("app.model.rummy.RoomUtil")

ScoreView.WIDTH = 1082
ScoreView.HEIGHT = 648

local mResDir = "image/rummy/scoreview/" -- module resource directory

local posY = {
    0 + 190 - 63/2 - 77/2,
    0 + 190 - 63/2 - 77/2 - 77,
    0 + 190 - 63/2 - 77/2 - 77 * 2,
    0 + 190 - 63/2 - 77/2 - 77 * 3,
    0 + 190 - 63/2 - 77/2 - 77 * 4
}

function ScoreView:ctor(pack, rummyCtrl)
    self.name = "ScoreView" -- 名字用于检测window是否存在

    self.rummyCtrl_ = rummyCtrl
	ScoreView.super.ctor(self, {name = self.name, width = self.WIDTH, height = self.HEIGHT, bgRes = mResDir .. "bg.png", isCoverClose = true})

    g.event:on(g.eventNames.RUMMY_UPDATE_SCORE_VIEW, handler(self, self.updateData), self)
    g.event:on(g.eventNames.RUMMY_SCORE_POPUP_COUNT, handler(self, self.updateGameStartCountDown), self)

    -- Close Btn
    local closeBtn = g.myUi.ScaleButton.new({normal = g.Res.blank})
        :onClick(handler(self, self.close))
        :addTo(self)
        :pos(self.WIDTH/2 - 47, self.HEIGHT/2 - 40)
        :setSwallowTouches(false)
        :setButtonSize(cc.size(70, 70))
    display.newSprite(mResDir .. "close.png"):pos(closeBtn:getContentSize().width/2, closeBtn:getContentSize().height/2):addTo(closeBtn)



    display.newSprite(mResDir .. "title.png")
        :pos(0, 150 + 134)
        :addTo(self)

    display.newScale9Sprite(mResDir .. "header_bg.png", 0, 0 + 190, cc.size(1020, 63)):addTo(self)
    
    display.newTTFLabel({
                text = g.lang:getText("RUMMY", "USER_NAME"),
                size = 24,
                color = cc.c3b(0xfd, 0xdf, 0xb3),
                align = cc.TEXT_ALIGNMENT_CENTER
            })
        :addTo(self)
        :pos(0 - 435, 190)
        :setAnchorPoint(cc.p(0.5, 0.5))

    display.newTTFLabel({
                text = g.lang:getText("RUMMY", "RESULT"),
                size = 24, 
                color = cc.c3b(0xfd, 0xdf, 0xb3),
                align = cc.TEXT_ALIGNMENT_CENTER
            })
        :addTo(self)
        :pos(0 - 435 + 155, 190)
        :setAnchorPoint(cc.p(0.5, 0.5))

    display.newTTFLabel({
                text = g.lang:getText("RUMMY", "CARDS"),
                size = 24, 
                color = cc.c3b(0xfd, 0xdf, 0xb3),
                align = cc.TEXT_ALIGNMENT_CENTER
            })
        :addTo(self)
        :pos(0 + 30, 190)
        :setAnchorPoint(cc.p(0.5, 0.5))

    display.newTTFLabel({
                text = g.lang:getText("RUMMY", "POINTS"),
                size = 24, 
                color = cc.c3b(0xfd, 0xdf, 0xb3),
                align = cc.TEXT_ALIGNMENT_CENTER
            })
        :addTo(self)
        :pos(0 + 155 + 188, 190)
        :setAnchorPoint(cc.p(0.5, 0.5))

    display.newTTFLabel({
                text = g.lang:getText("RUMMY", "TOTAL_SCORE"),
                size = 24, 
                color = cc.c3b(0xfd, 0xdf, 0xb3),
                align = cc.TEXT_ALIGNMENT_CENTER
            })
        :addTo(self)
        :pos(0 + 155 + 188 + 110, 190)
        :setAnchorPoint(cc.p(0.5, 0.5))

    display.newScale9Sprite(mResDir .. "light_bg.png", 0, 0 + 190 - 63/2 - 77/2, cc.size(1020, 77)):addTo(self)

    display.newScale9Sprite(mResDir .. "gray_bg.png", 0, 0 + 190 - 63/2 - 77/2 - 77, cc.size(1020, 77)):addTo(self)

    display.newScale9Sprite(mResDir .. "light_bg.png", 0, 0 + 190 - 63/2 - 77/2 - 77 * 2, cc.size(1020, 77)):addTo(self)

    display.newScale9Sprite(mResDir .. "gray_bg.png", 0, 0 + 190 - 63/2 - 77/2 - 77 * 3, cc.size(1020, 77)):addTo(self)

    display.newScale9Sprite(mResDir .. "light_bg.png", 0, 0 + 190 - 63/2 - 77/2 - 77 * 4, cc.size(1020, 77)):addTo(self)

    display.newSprite(mResDir .. "line.png"):pos(0 - 356, -2):addTo(self)

    display.newSprite(mResDir .. "line.png"):pos(0 - 196, -2):addTo(self)

    display.newSprite(mResDir .. "line.png"):pos(0 + 196 + 84, -2):addTo(self)

    display.newSprite(mResDir .. "line.png"):pos(0 + 196 + 206, -2):addTo(self)

    self.countLabel = display.newTTFLabel({
                text = "",
                size = 20, 
                color = cc.c3b(0xff, 0xff, 0xf3),
                align = cc.TEXT_ALIGNMENT_CENTER
            })
        :addTo(self)
        :pos(-422 + 142, 0 - 300 + 28)
        :setAnchorPoint(cc.p(0, 0.5))

    self.node = display.newNode(mResDir .. "header_bg.png"):addTo(self)

    g.myUi.ScaleButton.new({normal = mResDir .. "btn_yellow.png"})
        :onClick(handler(self, self.rummyCtrl_.logoutRoom))
        :setButtonLabel(display.newTTFLabel({size = 24, text = g.lang:getText("RUMMY", "LEAVE_TABLE")}), cc.p(0, 2))
        :pos(0 - 422, 0 - 300 + 28)
        :addTo(self)
        :setSwallowTouches(true)

    self:updateData(pack)
    
    if tonumber(pack.endtype) ~= 0 then
        local declaretime = roomInfo:getDeclareTime()
        local declaretimeMinus = roomInfo:getDeclareTimeMinus()
        g.mySched:cancel(self.loopSchedId_)
        local t1 = declaretime - math.floor(g.timeUtil:getSocketTime() - declaretimeMinus)
        if t1 > 0 then
            self:updateCountStr({time = t1, flag = 1})
        end
        self.loopSchedId_ = g.mySched:doLoop(function()
                t1 = declaretime - math.floor(g.timeUtil:getSocketTime() - declaretimeMinus)
                if t1 > 0 then
                    self:updateCountStr({time = t1, flag = 1})
                else
                    g.mySched:cancel(self.loopSchedId_)
                end
                return true
            end, 1)
    end
end

function ScoreView:updateGameStartCountDown(pack)
    g.mySched:cancel(self.loopSchedId_)
    if self and self.updateCountStr then
        self:updateCountStr(pack)
    end
end

function ScoreView:updateCountStr(pack)
    if pack then
        if pack.flag and pack.flag == 1 then
            self.countLabel:setString(string.format(g.lang:getText("RUMMY", "SCORE_WINDOW_DECLARE_COUNT"), pack.time or 0))
        else
            self.countLabel:setString(string.format(g.lang:getText("RUMMY", "GAME_START_COUNTDOWN_FMT"), pack.time or 0))
        end
    end
end

function ScoreView:updateData(pack)
    if not pack then return end
    if not pack.users then return end
    local users = pack.users
    self.node:removeAllChildren()
    for i=1,#users do
        local user = users[i]
        
        if DEBUG > 0 then
            dump(user)
        end

        local nickName = user.name or user.uid

        local colorCurrent = cc.c3b(0xff, 0xff, 0xff)
        if tonumber(user.uid) == tonumber(g.user:getUid()) then
            colorCurrent = cc.c3b(0xf8, 0xf1, 0x24)
        end

        display.newTTFLabel({
                    text = g.nameUtil:getShortName(nickName or "", 13, 26),
                    size = 24, 
                    color = colorCurrent,
                    align = cc.TEXT_ALIGNMENT_CENTER
                })
            :addTo(self.node)
            :pos(0 - 435, posY[i])
            :setAnchorPoint(cc.p(0.5, 0.5))

        local stateLabel = display.newTTFLabel({
                    text = "",
                    size = 24, 
                    color = colorCurrent,
                    align = cc.TEXT_ALIGNMENT_CENTER
                })
            :addTo(self.node)
            :pos(0 - 435 + 155, posY[i])
            :setAnchorPoint(cc.p(0.5, 0.5))

        if tonumber(pack.endtype) == 0 then -- 自己不用declare, 自己是赢家
            if tonumber(user.uid) == tonumber(pack.winUid) then
                display.newSprite(mResDir .. "winner.png")
                    :pos(0 - 435 + 155, posY[i])
                    :addTo(self.node)
                for j=1,13 do
                    display.newSprite(mResDir .. "card_back.png"):pos(0 - 148 + (j - 1) * 23, posY[i]):addTo(self.node)
                end
            end
        end
        if user and user.isDrop and user.isDrop == 1 and user.isFinishDeclare ~= 1 then
            stateLabel:setString(g.lang:getText("RUMMY", "DROPPED"))
            for j=1,13 do
                display.newSprite(mResDir .. "card_back.png"):pos(0 - 148 + (j - 1) * 23, posY[i]):addTo(self.node)
            end
        else
            if user.isFinishDeclare and tonumber(user.isFinishDeclare) == 1 then
                if tonumber(user.uid) == tonumber(pack.winUid) then
                    display.newSprite(mResDir .. "winner.png")
                        :pos(0 - 435 + 155, posY[i])
                        :addTo(self.node)
                else
                    stateLabel:setString(g.lang:getText("RUMMY", "LOST"))
                end
                local x = -154 - 38 - 16
                local groups = user.groups
                if groups and #groups > 0 then
                    for k=1,#groups do
                        local pokerc = groups[k]
                        if #pokerc > 0 then
                            x = x + 38
                            for j=1,#pokerc do
                                x = x + 16
                                g.myUi.PokerCard.new():setCard(pokerc[j]):setMagicVisible(RoomUtil.isMagicCard(pokerc[j])):pos(x, posY[i]):addTo(self.node):showFront():scale(0.42)
                            end
                        end
                    end
                end
            elseif tonumber(pack.endtype) == 1 then
                stateLabel:setString(g.lang:getText("RUMMY", "WAITING"))
            end
        end

        display.newTTFLabel({
                    text = user.score or "0",
                    size = 24, 
                    color = colorCurrent,
                    align = cc.TEXT_ALIGNMENT_CENTER
                })
            :addTo(self.node)
            :pos(0 + 155 + 188, posY[i])
            :setAnchorPoint(cc.p(0.5, 0.5))

        local winMoney = user.winMoney or "0"
        if g.Var.gameId >= 10000 then
            winMoney = g.moneyUtil:formatGold(user.winMoney or 0, true)
        end
        display.newTTFLabel({
                    text = winMoney,
                    size = 24, 
                    color = colorCurrent,
                    align = cc.TEXT_ALIGNMENT_CENTER
                })
            :addTo(self.node)
            :pos(0 + 155 + 188 + 110, posY[i])
            :setAnchorPoint(cc.p(0.5, 0.5))
    end
end

function ScoreView:onWindowRemove()
    g.event:removeByTag(self)
    g.mySched:cancel(self.loopSchedId_)
end

return ScoreView

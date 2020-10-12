local SeatView = class("SeatView", function ()
	return display.newNode()
end)

local SeatCtrl = require("app.controller.dizhu.SeatCtrl")
local RoomConst = require("app.model.dizhu.RoomConst")
local roomInfo = require("app.model.dizhu.RoomInfo").getInstance()

local mResDir = "image/dizhu/seat/" -- module resource directory

function SeatView:ctor(scene)
	self.scene = scene
	self.ctrl = SeatCtrl.new(self)
	self:initialize()
end

function SeatView:initialize()
    self.sitdown = display.newNode():addTo(self):hide()
	display.newSprite(mResDir .. "seat_down_arrow.png"):addTo(self.sitdown)
    display.newSprite(mResDir .. "seat_bg.png"):addTo(self.sitdown)
    
    self.headCircleLight1 = display.newSprite(mResDir .. "head_circle_light1.png"):addTo(self):hide()
    self.headCircleLight2 = display.newSprite(mResDir .. "head_circle_light2.png"):addTo(self):hide():opacity(127)
    -- 用户头像
    self.headerNode = g.myUi.AvatarView.new({
        radius = 54,
        frameRes = mResDir .. "common_head_bg_small.png",
        avatarUrl = "",
        clickOptions = {default = true},
        clickCallback = handler(self, self.ctrl.doAvatarClick)
    }):addTo(self)
    self.headMask = display.newSprite(mResDir .. "head_mask.png"):addTo(self):hide()

    -- 头像显示的钱
    self.miniInfoNode = display.newNode():pos(0, -50):addTo(self):hide()
    display.newSprite(mResDir .. "mini_info_bg.png"):addTo(self.miniInfoNode)
    self.nickName = display.newTTFLabel({color = cc.c3b(255, 255, 255), text = "", size = 20})
        :addTo(self.miniInfoNode)

    -- 头像倒计时
    self.circleProgress = g.myUi.SeatCircleProgress.new(0.9)
       :addTo(self)
    self.countDownNumBg = display.newSprite(mResDir .. "count_down_num_bg.png"):pos(-66, -10):addTo(self, -1):hide()
    self.countDownNum = display.newTTFLabel({size = 24, text = ""})
        :pos(self.countDownNumBg:getContentSize().width/2 - 8, self.countDownNumBg:getContentSize().height/2)
        :addTo(self.countDownNumBg)
    
    -- ready text
    self.readyText = display.newSprite(mResDir .. "player_ready.png"):addTo(self):hide()
end

function SeatView:onAvatarClick()
    if self.serverSeatId < 0 and roomInfo:getMSeatId() == -1 then -- 我站起点击空座位
          self.ctrl:requestSitDown()
    elseif self.uid > 0 and app.gameId >= 10000 then
          RoomUserInfoPopup.new(self.uid):show()
    end
end

function SeatView:setHeadDark()
    if self.headMask then
        self.headMask:show()
    end
end

function SeatView:setHeadBright()
    if self.headMask then
        self.headMask:hide()
        end
        self:hideFoldTxt()
        -- self:hideAwayTxt()
end

function SeatView:updateSeatConfig()
    if self:getUid() == g.user:getUid() then
        self.headScale =1.25
        self.headMaskScale = 1.29
        self.headCircleLightScale = 1.25
        self.miniInfoNode:hide()
        self.circleProgress:setScale(1.1)
        self.countDownNumBg:pos(-80, -16)
    else
        self.headScale = 1
        self.headMaskScale = 1.02
        self.headCircleLightScale = 1
        self.miniInfoNode:show()
        self.circleProgress:setScale(0.9)
        self.countDownNumBg:pos(-66, -10)
    end
    if self:getUid() < 0 and roomInfo:getMSeatId() < 0 then--我站起且当前座位没人，显示坐下图标
        self.sitdown:show()
    else
        self.sitdown:hide()
    end
    if self:getUid() < 0 then
        self.miniInfoNode:hide()
    end
end

function SeatView:setUid(uid)
	self.uid_ = uid
end

function SeatView:getUid()
	return self.uid_ or -1
end

function SeatView:setServerSeatId(seatId)
	self.svrSeatId = seatId
end

function SeatView:getServerSeatId()
	return self.svrSeatId or RoomConst.NoPlayerSeatId
end

function SeatView:updateMoney(money)
    if not money then return end
    if self:getServerSeatId() < 0 then return end
    self:checkShowMiniInfoBg()
end

function SeatView:setNickName(name)
	if self.nickName then self.nickName:setString(g.nameUtil:getShortName(name, 11, 34)) end
end

function SeatView:setNowPos(nowPos)
    self.nowPos = nowPos
end

function SeatView:getNowPos()
    return self.nowPos
end

function SeatView:showHeader()
    self.headerNode:show()
end

function SeatView:hideHeader()
	self.headerNode:hide()
end

function SeatView:setHeaderConfig(icon, gender)
	self.h_Icon = icon
	self.h_gender = gender
	self.h_loadIndex = (self.h_loadIndex or 0) + 1

    self:asyncLoadHeaderImg(self.h_loadIndex)
end

function SeatView:asyncLoadHeaderImg(loadIndex)
	--更新图像
	local headerImageLoaderId_ = g.imageLoader:nextLoaderId()
	if self.h_gender then
		if tonumber(self.h_gender) == 1 then
			self:updateHeader(display.newSprite(g.Res.common_defaultMan), loadIndex)
		else
			self:updateHeader(display.newSprite(g.Res.common_defaultWoman), loadIndex)
		end
	end
	if self.h_Icon ~= nil and self.h_Icon ~= "" and self.h_Icon ~= "NULL" then
			local url = g.user:getImageBase() .. self.h_Icon
			g.imageLoader:loadAndCacheImage(headerImageLoaderId_, url,
					function(success, sprite)
							if not (self and self.updateHeader) then return end
							if success then
									self:updateHeader(sprite, loadIndex)
							end
					end,
					g.imageLoader.CACHE_TYPE_USER_HEAD_IMG)
	else
			
	end
end

--更新头像
function SeatView:updateHeader(tex, loadIndex)
	if self.h_loadIndex ~= loadIndex then return end
    if self.headerNode then
        self.headerNode:setScale(self.headScale)
        
        self.headerNode:setAvatarTex(tex)
        self.headMask:setScale(self.headMaskScale)
        self.headCircleLight2:setScale(self.headCircleLightScale * 0.92)
        self.headCircleLight1:setScale(self.headCircleLightScale * 0.8)
        if self.uid and self.uid > 0 then 
            if self.uState ==  RoomConst.USER_PLAY then
                self:setHeadBright()
            else
                self:setHeadDark()
            end
        end
    end
end

function SeatView:checkShowMiniInfoBg()
    self.miniInfoNode:show()
    if self:getUid() == g.user:getUid() then
        self.miniInfoNode:pos(0, -60)
    else
        self.miniInfoNode:pos(0, -50)
    end
end

function SeatView:hideMiniInfoBg()
	if self.miniInfoNode then self.miniInfoNode:hide() end
end

function SeatView:showReadyText(pos)
	if self.readyText then self.readyText:pos(pos.x, pos.y):show() end
end

function SeatView:hideReadyText()
	if self.readyText then self.readyText:hide() end
end

function SeatView:showFoldTxt()
	if not self.foldTxt then
		self.foldTxt = display.newTTFLabel({text = g.lang:getText("RUMMY", "FOLDED"), size = 20, color = cc.c3b(0xb4, 0xb3, 0xb3)})
			:setRotation(-25)
			:addTo(self)
	end
    self.foldTxt:show()
    -- self:hideAwayTxt() -- 优先显示drop, 有drop隐藏away
end

function SeatView:hideFoldTxt()
	if self.foldTxt then self.foldTxt:hide() end
end

function SeatView:startCountDown(time,finishCallback)
    if self.circleProgress then
        if finishCallback then
          self.circleProgress:setFinishCallback(finishCallback)
        end
        if self.serverSeatId == roomInfo:getMSeatId() then
           self.circleProgress:setShakeCallback(function()
                self:shakeCard()
           end)
        else
          self.circleProgress:setShakeCallback(nil)
        end
        self.circleProgress:startCountDown(time)
    end
    if self.countDownNumBg then
      self.countDownNumBg:show()
      self.countDownNum:setString(time)
      local useTime = time
      self:clearSchedule()
      self.schedId = g.mySched:doLoop(function()
          useTime = useTime - 1
          if useTime > 0 then
              self.countDownNum:setString(useTime)
              return true
          else
              self.countDownNumBg:hide()
              self:clearSchedule()
          end
      end, 1)
    end
end

function SeatView:stopCountDown()
    if self.circleProgress then
        self.circleProgress:stopCountDown()
    end
    if self.countDownNumBg then
      self.countDownNumBg:hide()
    end
    self:clearSchedule()
end

function SeatView:setUState(uState)
    self.uState = uState
end

function SeatView:getUState()
    return self.uState
end

-- 增加换牌功能，抖牌逻辑去掉
function SeatView:shakeCard()
    if self.needShake then
       self.needShake = false
    --    self.soundHandle = g.audio:playSound(g.audio.SANGONG_COUNTDOWN)
   end
end

function SeatView:stopShakeCard()
    self.needShake = true
    g.audio:stopSound(self.soundHandle)
    self.soundHandle = nil
end

function SeatView:clearSchedule()
    if self.schedId then
        g.mySched:cancel(self.schedId)
        self.schedId = nil
    end
end

function SeatView:standUp()
    self:updateMoney(-1)
    self:hideMiniInfoBg()
    self.headMask:hide()
	self:hideHeader()
	if roomInfo:getMSeatId() < 0 then --我是站起的
        self.sitdown:show()
    end
    self:setUid(-1)
	self:clearTable()
	self:setServerSeatId(RoomConst.NoPlayerSeatId)
    self:updateSeatConfig()
    -- self:stopCountDown()
end

function SeatView:clearTable()
    self:hideFoldTxt()
    self:hideReadyText()
    -- self:hideAwayTxt()
    self:clearSchedule()
end

function SeatView:XXXX()
	
end

function SeatView:XXXX()
	
end

function SeatView:XXXX()
	
end

function SeatView:XXXX()
	
end

return SeatView

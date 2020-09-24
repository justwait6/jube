local SignupView = class("SignupView", function ()
	return display.newNode()
end)

local SignupCtrl = require("app.controller.login.SignupCtrl")

function SignupView:ctor(scene)
	self.scene = scene
	self.ctrl = SignupCtrl.new(self)
	self:setNodeEventEnabled(true)
	self:initialize()
end

function SignupView:initialize()
	display.newSprite(g.Res.login_loginBg):addTo(self)

	display.newTTFLabel({
        	text = g.lang:getText("LOGIN", "SIGNUP_TIPS"), size = 28, color = cc.c3b(0, 128, 128)})
    	:pos(0, 160)
    	:addTo(self)

    local yOffset = -236
    -- 用户输入框
	self.nameEditBox = g.myUi.EditBox.new({
            image = g.Res.moneytreeinvite_codeBg,
            imageOffset = cc.p(94, 0),
			size = cc.size(180, 54),
			fontColor = cc.c3b(254, 255, 151),
			fontSize = 20,
			maxLength = 20,
			placeHolder = g.lang:getText("LOGIN", "NAME_TIPS"),
			holderColor = cc.c3b(64, 97, 179)
		})
		:pos(-94, 160 + yOffset)
		:addTo(self)

    -- 密码输入框
	self.pwdEditBox = g.myUi.EditBox.new({
            image = g.Res.moneytreeinvite_codeBg,
            imageOffset = cc.p(94, 0),
			size = cc.size(180, 54),
			fontColor = cc.c3b(254, 255, 151),
			fontSize = 20,
			maxLength = 20,
			placeHolder = g.lang:getText("LOGIN", "PWD_TIPS"),
			holderColor = cc.c3b(64, 97, 179),
			inputFlag = cc.EDITBOX_INPUT_FLAG_PASSWORD,
		})
		:pos(-94, 80 + yOffset)
		:addTo(self)

	-- 邮箱输入框
	self.emailEditBox = g.myUi.EditBox.new({
            image = g.Res.moneytreeinvite_codeBg,
            imageOffset = cc.p(94, 0),
			size = cc.size(180, 54),
			fontColor = cc.c3b(254, 255, 151),
			fontSize = 20,
			maxLength = 20,
			placeHolder = g.lang:getText("LOGIN", "EMAIL_TIPS"),
			holderColor = cc.c3b(64, 97, 179),
		})
		:pos(-94, 0 + yOffset)
		:addTo(self)

	-- 登录按钮
	g.myUi.ScaleButton.new({normal = g.Res.common_btnBlueS})
		:setButtonLabel(display.newTTFLabel({size = 24, text = g.lang:getText("LOGIN", "SIGNUP")}))
		:onClick(handler(self.ctrl, self.ctrl.requestSignup))
		:pos(0, -80 + yOffset)
		:addTo(self)

	-- 注册按钮
	g.myUi.ScaleButton.new({normal = g.Res.common_btnBlueS})
		:setButtonLabel(display.newTTFLabel({size = 24, text = g.lang:getText("LOGIN", "GO_LOGIN")}))
		:onClick(handler(self.scene, self.scene.switchToLoginView))
		:pos(200, -80 + yOffset)
		:addTo(self)
end

function SignupView:getInputUserName()
	if self.nameEditBox then
		return self.nameEditBox:getText()
	end
end

function SignupView:getInputUserPassword()
	if self.pwdEditBox then
		return self.pwdEditBox:getText()
	end
end

function SignupView:getInputUserEmail()
	if self.emailEditBox then
		return self.emailEditBox:getText()
	end
end

function SignupView:onSignupSucc(data)
	g.myUi.topTip:showText(g.lang:getText("LOGIN", "SIGNUP_SUCC"))
	self.routeDelayId = g.mySched:doDelay(handler(self.scene, self.scene.switchToLoginView), 2)
end

function SignupView:onSignupFail(data)
	
end

function SignupView:XXXX()
	
end

function SignupView:XXXX()
	
end

function SignupView:XXXX()
	
end

function SignupView:XXXX()
	
end

function SignupView:onCleanup()
	g.mySched:cancel(self.routeDelayId)
end

return SignupView

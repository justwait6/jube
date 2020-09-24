local LoginScene = class("LoginScene", function()
    return display.newScene("LoginScene")
end)

local LoginView = require("app.view.login.LoginView")
local SignupView = require("app.view.login.SignupView")

local Tab = {}
Tab.LOG_IN = 1
Tab.SIGN_UP = 2

function LoginScene:ctor()
    self:initialize()
end

function LoginScene:initialize()
	self.loginView = LoginView.new(self):pos(display.cx, display.cy):addTo(self)
	self.signupView = SignupView.new(self):pos(display.cx, display.cy):addTo(self)
	self:switchToLoginView()
end

function LoginScene:switchToLoginView()
	self:onTab(Tab.LOG_IN)
end

function LoginScene:switchToSignupView()
	self:onTab(Tab.SIGN_UP)
end

function LoginScene:onTab(tab)
	if tab == Tab.SIGN_UP then
		if self.loginView then self.loginView:hide() end
		if self.signupView then self.signupView:show() end
	elseif tab == Tab.LOG_IN then
		if self.loginView then self.loginView:show() end
		if self.signupView then self.signupView:hide() end
	end
end

function LoginScene:onEnter()
	g.mySocket:cancelCliConnectHall()
end

function LoginScene:onExit()
end

return LoginScene

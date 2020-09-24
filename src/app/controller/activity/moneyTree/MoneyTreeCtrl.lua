local MoneyTreeCtrl = class("MoneyTreeCtrl")

function MoneyTreeCtrl:ctor(viewObj)
	self.viewObj = viewObj
	self.httpIds = {}
	self:initialize()
end

function MoneyTreeCtrl:initialize()
end

function MoneyTreeCtrl:onHelpClick()
	self:showMoneyTreeInvitePopup()
end

function MoneyTreeCtrl:onInviteClick()
	print("点击了邀请")
	-- g.user:requestInvite("tree", handler(self, self.requestCallback))
end

function MoneyTreeCtrl:getCurTreeShowUid()
	if self.viewObj then
		return self.viewObj:getCurTreeShowUid()
	end
end

function MoneyTreeCtrl:getTreeType()
	if self.viewObj then
		return self.viewObj:getTreeType()
	end
end

function MoneyTreeCtrl:onWaterButtonClick()
    if self:getCurTreeShowUid() == tonumber(g.user:getUid()) then
        self:requestWaterMyTree(handler(self, self.onRequestWaterMyTreeSucc))
    else
        local params = {}
        params.uid = self:getCurTreeShowUid()
        self:requestWaterOtherTree(params, handler(self, function (self, data)
            self:onRequestWaterOtherTreeSucc(data, params.uid)
        end))
    end
end

function MoneyTreeCtrl:onInviteGuideButtonClick()
    self:showMoneyTreeInvitePopup()
end

function MoneyTreeCtrl:showMoneyTreeInvitePopup()
	if self.viewObj then
        self.viewObj:showMoneyTreeInvitePopup()
    end
end

function MoneyTreeCtrl:requestMyTreeInfo(successCallback, failCallback, noLoading)
	if self.httpIds['myTreeInfo'] then return end
	local resetWrapHandler = handler(self, function ()
			self.httpIds['myTreeInfo'] = nil
	end)

	if not noLoading then
			g.myUi.miniLoading:show()
	end

	local reqParams = {}
	reqParams._interface = "/moneyTree/myTreeInfo"
	reqParams.treeType = self:getTreeType()
	reqParams.uid = g.user:getUid()
	self.httpIds['myTreeInfo'] = g.http:simplePost(reqParams,
			successCallback, failCallback, resetWrapHandler)
end

function MoneyTreeCtrl:requestTreeInfo(successCallback, failCallback, noLoading)
	if self.httpIds['treeInfo'] then return end
	local resetWrapHandler = handler(self, function ()
			self.httpIds['treeInfo'] = nil
	end)

	if not noLoading then
			g.myUi.miniLoading:show()
	end

	local reqParams = {}
	reqParams._interface = "/moneyTree/treeInfo"
	reqParams.treeType = self:getTreeType()
	reqParams.uid = self:getCurTreeShowUid()
	self.httpIds['treeInfo'] = g.http:simplePost(reqParams,
			successCallback, failCallback, resetWrapHandler)
end

function MoneyTreeCtrl:requestInviteCodeInfo(successCallback, failCallback, noLoading)
    if self.httpIds['inviteCodeInfo'] then return end
    local resetWrapHandler = handler(self, function ()
        self.httpIds['inviteCodeInfo'] = nil
    end)

    if not noLoading then
        g.myUi.miniLoading:show()
    end

    local reqParams = {}
    reqParams._interface = "/moneyTree/inviteCodeInfo"
    reqParams.treeType = self:getTreeType()
    self.httpIds['inviteCodeInfo'] = g.http:simplePost(reqParams,
        successCallback, failCallback, resetWrapHandler)
end

function MoneyTreeCtrl:XXXX()
    
end

function MoneyTreeCtrl:XXXX()
    
end

function MoneyTreeCtrl:XXXX()
    
end

function MoneyTreeCtrl:dispose()
    g.http:cancelBatch(self.httpIds)
end

return MoneyTreeCtrl

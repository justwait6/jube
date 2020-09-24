local ProxySelector = class("ProxySelector")

ProxySelector.proxyList = {}

function ProxySelector.hasProxy()
    return ProxySelector.proxyList and #ProxySelector.proxyList > 0
end

function ProxySelector.setProxyList(proxyList)
    ProxySelector.proxyList = proxyList
end

function ProxySelector.getProxyList()
    return ProxySelector.proxyList
end

function ProxySelector:ctor()
    self.proxyList_ = clone(ProxySelector.proxyList)
    self.currentProxyIndex_ = 1
end

function ProxySelector:hasMoreProxy()
    return #self.proxyList_ > self.currentProxyIndex_
end

function ProxySelector:getCurrentProxy()
    if #self.proxyList_ >= self.currentProxyIndex_ then
        return self.proxyList_[self.currentProxyIndex_]
    else
        return nil,nil
    end
end

function ProxySelector:getNextProxy()
    if self:hasMoreProxy() then
        self.currentProxyIndex_ = self.currentProxyIndex_ + 1
    end
    return self:getCurrentProxy()
end

function ProxySelector:leftProxyNum()
    return #self.proxyList_ - self.currentProxyIndex_ + 1
end

return ProxySelector

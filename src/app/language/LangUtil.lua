local LangUtil = class("LangUtil")

local langConf = import(".config")

local langRes = langConf[tostring(LANG)].langRes -- 根据语言选择对应的语言包
local lang = require(langRes)

function LangUtil:ctor()
end

function LangUtil.getInstance()
    if not LangUtil.singleInstance then
        LangUtil.singleInstance = LangUtil.new()
    end
    return LangUtil.singleInstance
end

--[[
    @func getText: 获取一个指定键值的text
    @param primeKey: 第一个键
    @param secondKey:第二个键
    @return: 键所对应的值(text)
--]]
function LangUtil:getText(primeKey, secondKey, ...)
    assert(primeKey ~= nil and secondKey ~= nil, "must set prime key and secondary key")
    if LangUtil:hasKey(primeKey, secondKey) then
        if (type(lang[primeKey][secondKey]) == "string") then
            return LangUtil:formatString(lang[primeKey][secondKey], ...)
        else
            return lang[primeKey][secondKey]
        end
    else
        return ""
    end
end

--[[
    @func hasKey: 判断是否存在指定键值的text
    @param primeKey: 第一个键
    @param secondKey:第二个键
    @return: boolean类型, true表示存在
--]]
function LangUtil:hasKey(primeKey, secondKey)
    return lang[primeKey] ~= nil and lang[primeKey][secondKey] ~= nil
end

--[[
    @func formatString: Formats a string in .Net-style, with curly braces ("{1}, {2}").
    @param str: 字符串
    @return: 结果字符串
--]]
function LangUtil:formatString(str, ...)
    local numArgs = select("#", ...)
    if numArgs >= 1 then
        local output = str
        for i =1, numArgs do
            local value = select(i, ...)
            output = string.gsub(output, "{" .. i .. "}", value)
        end
        return output
    else
        return str
    end
end

--[[
    @func getDefaultHostUrl: 默认Url
    @return: boolean类型, true表示存在
--]]
function LangUtil:getDefaultHostUrl()
    return langConf[tostring(LANG)].hostUrl
end

function LangUtil:addPlatformSearchPath()
    local pathName = langConf[tostring(LANG)].platformResPath
    cc.FileUtils:getInstance():addSearchPath(pathName)
end

return LangUtil

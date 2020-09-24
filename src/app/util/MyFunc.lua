local MyFunc = class("MyFunc")

require("lfs")

function MyFunc:ctor()
end

function MyFunc.getInstance()
	if not MyFunc.singleInstance then
		MyFunc.singleInstance = MyFunc.new()
	end
	return MyFunc.singleInstance
end

--[[
    @func split: 按照分隔号对字符串进行分割
    @param inputstr: 待分割字符串, string类型
    @sep: 分割符号, string类型
    @return: 一个分割好的table
--]]
function MyFunc:split(inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end

--[[
    @func encodeURI: 编码uri
    @param s: 待编码的字符串
    @return: 编码好的uri
--]]
function MyFunc:encodeURI(s)
    s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return string.gsub(s, " ", "+")
end

--[[
    @func checkNodeExist: 检查节点是否存在
    @param node: 待检查节点
    @return: boolean类型
--]]
function MyFunc:checkNodeExist(node)
    return node and not tolua.isnull(node) and node:getParent()
end

--[[
    @func safeRemoveNode: 安全移除节点
    @param node: 待移除节点
--]]
function MyFunc:safeRemoveNode(node)
    if self:checkNodeExist(node) then
        node:stopAllActions()
        node:removeSelf()
        node = nil
    end
end

--[[
    @func setAllCascadeOpacityEnabled: 设置子sprite随父sprite透明度变化而变化
    @param node: 根节点, 它下面的所有节点会跟着被设置
--]]
function MyFunc:setAllCascadeOpacityEnabled(node)
    node:setCascadeOpacityEnabled(true)
    if node:getChildrenCount() ~= 0 then
        for _, v in ipairs(node:getChildren()) do
            self:setAllCascadeOpacityEnabled(v)
        end
    end
end

--[[
    @func setNodesAlignCenter: 设置(多个)节点居中
    @param nodeItemList: table类型, 提供各个节点(如{a, b}, a, b为要居中的节点)
    @param gap: 各个节点之间的空隙, 单位px, 默认为0
--]]
function MyFunc:setNodesAlignCenter(nodeItemList, gap)
    local elementNum = #nodeItemList
    local gap = gap or 0
    local totalLength = 0

    for i = 1, elementNum do
        totalLength = totalLength + nodeItemList[i]:getBoundingBox().width
    end
    totalLength = totalLength + (elementNum - 1) * gap

    local curLen = 0
    for i = 1, elementNum do
        local itemWidth = nodeItemList[i]:getBoundingBox().width
        curLen = curLen + itemWidth/2
        nodeItemList[i]:setPositionX(curLen - totalLength/2)
        curLen = curLen + itemWidth/2 + gap
    end
end

--[[
    @func checkScaleBg: 检查全面屏适配, 只做横向拉伸
    @param bgSprite: 背景精灵
--]]
function MyFunc:checkScaleBg(bgSprite)
    if bgSprite then
        local sz = bgSprite:getContentSize()
        -- 图片本身已做2:1适配
        if sz.width >= sz.height * 2 then
            -- 分辨率大于2:1, 横向拉伸
            if display.width > display.height * 2 then
                local scaleX = display.width / 1440
                bgSprite:setScaleX(scaleX)
            end
            -- 其他情况不管
            return
        end
        -- 全面屏横向拉伸
        if display.width * 9 > 16 * display.height then
            local scaleX = display.width / 1280
            bgSprite:setScaleX(scaleX)
        end
    end
end

function MyFunc:calcIconUrl(iconUrl, isRelative)
    if isRelative then
        return g.user:getImageBase() .. iconUrl
    else
        return iconUrl
    end
end

--[[
    @func findLast: equal to func lastIndexOf in other language
    @param haystack: string to be found
    @param needle: char to find, NOTE to find . you need to escape it(use %.)
--]]
function MyFunc:findLast(haystack, needle)
    local i=haystack:match(".*"..needle.."()")
    if i==nil then return nil else return i-1 end
end

function MyFunc:getTodayTimeStamp()
    local cDateCurrectTime = os.date("*t")
    local cDateTodayTime = os.time({year=cDateCurrectTime.year, month=cDateCurrectTime.month, day=cDateCurrectTime.day, hour=0,min=0,sec=0})
    return cDateTodayTime
end

return MyFunc

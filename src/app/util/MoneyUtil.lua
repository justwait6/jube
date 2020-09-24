local MoneyUtil = class("MoneyUtil")

function MoneyUtil:ctor()
end

function MoneyUtil:dtor()
end

function MoneyUtil.getInstance()
    if not MoneyUtil.singleInstance then
        MoneyUtil.singleInstance = MoneyUtil.new()
    end
    return MoneyUtil.singleInstance
end


--将字符串分割为 xxx,xxx,xxx格式
function MoneyUtil:splitMoneyForThree(money)
    local retString = ""
    local arr = string.split(money,".")--此处针对小数处理
    money = arr[1]
    for i = 1 , string.len(money) do
        retString = string.format(retString..string.sub(money,i,i))
        index = string.len(money) - i
        if index > 0 and 0 == (index % 3)  then
            retString = string.format(retString..",")
        end
    end
    if arr[2] then
        retString = retString.."."..arr[2]
    end
    return retString
end

-- 分割字符串
function MoneyUtil:splitMoney(money)
    if money and tonumber(money) < 10000 then
        return tonumber(money)
    else
        return self:splitCoinFormat_(money)
    end
end

--金币显示需要统一除以100
function MoneyUtil:formatGold(gold,ifForceGode)
    if LANG == LANG_ID then
        return tonumber(gold)
    else
        if g.Var.gameId >= 10000 or ifForceGode then --金币场
            gold = tonumber(gold or 0)
            gold = gold / 100
            return tonumber(string.format("%.2f",gold))
        else
            return tonumber(gold)
        end
    end
end

function MoneyUtil:splitCoinFormat_(money)
    money = tonumber(money or 0)
    if money < 1000 then 
        return money
    end
    
    local curMoney = money/1000
    local isMoneyInt = (math.floor(money/1000) * 1000 == money)
    
    if curMoney < 1000 then 
        if isMoneyInt then
            return curMoney.."k"
        elseif curMoney + 0.5 < 1000 then 
            return string.format("%.1f", curMoney) .. "k"
        else
            return string.format("%.1f", curMoney/1000) .. "m"
        end
    end

    if curMoney < 1000 * 1000 then 
        if (math.floor(curMoney/1000) * 1000 == curMoney) then
            return (curMoney/1000).."m"
        elseif curMoney + 0.5 < 1000 * 1000 then 
            return string.format("%.1f", curMoney / 1000) .. "m"
        else
            return string.format("%.1f", curMoney / 1000000) .. "b"
        end
    end

    if curMoney < 1000 * 1000 * 1000 then 
        if (math.floor(curMoney/1000000) * 1000000 == curMoney) then
            return (curMoney / 1000000) .. "b"
        elseif curMoney + 0.5 < 1000 * 1000 * 1000 then 
            return string.format("%.1f", curMoney / 1000000) .. "b"
        else
            return string.format("%.1f", curMoney / 1000000000) .. "t"
        end
    end

    if curMoney < 1000 * 1000 * 1000 * 1000 then 
        if  (math.floor(curMoney/1000000000) * 1000000000 == curMoney) then
            return (curMoney / 1000000000).."t"
        elseif curMoney + 0.5 < 1000 * 1000 * 1000 * 1000 then 
            return string.format("%.1f", curMoney / 1000000000) .. "t"
        else
            return self:splitMoneyForThree(curMoney / 1000000000) .. "t"
        end
    end
    return self:splitMoneyForThree(curMoney / 1000000000) .. "t"
end

-- 分割字符串money
function MoneyUtil:splitMoneyFormat(curMoney)
    curMoney = tonumber(curMoney or 0)

    if not curMoney then
        return 0
    end

    if curMoney < 1000 then 
        return curMoney
    end

    curMoney = curMoney/1000
    
    if curMoney < 1000 then 
        return curMoney .. "k"
    else
        curMoney = curMoney/1000
        return curMoney .. "m"
    end

    -- return curMoney * 1000

end

return MoneyUtil

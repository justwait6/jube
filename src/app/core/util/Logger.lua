-- Author: Jam
-- Date: 2015.04.07

local Logger = class("Logger")

Logger.LEVEL_DEBUG  = 5
Logger.LEVEL_INFO   = 4
Logger.LEVEL_WARN   = 3
Logger.LEVEL_ERROR  = 2
Logger.LEVEL_FETAL  = 1

Logger.LEVEL_TAGS   = {"FETAL", "ERROR", "WARN", "INFO", "DEBUG"}

if device.platform == "windows" then
    Logger.outputs = {print}
else
    Logger.outputs = {printInfo}
end

function Logger:ctor(name)
    self.name_ = name
    self.isEnabled_ = true 
end

function Logger.addOutputFunc(func)
    local  exists = false
    for i,v in ipairs(Logger.outputs) do
        if v == func then
            exists = true
            break
        end
    end
    if not exists then
        Logger.outputs[#Logger.outputs + 1] = func
    end
end

function Logger:setTag(name)
    self.name_ = name
    return self
end

function Logger:enabled(isEnabled)
    self.isEnabled_ = isEnabled
    return self
end

function Logger:debug(...)
    return self.isEnabled_ and self:log_(false, Logger.LEVEL_DEBUG, self.name_, "%s", self:concatParams(...)) or self
end

function Logger:debugf(fmt, ...)
    return self.isEnabled_ and self:log_(false, Logger.LEVEL_DEBUG, self.name_, fmt, ...) or self
end

function Logger:info(...)
    return self.isEnabled_ and self:log_(false, Logger.LEVEL_INFO, self.name_, "%s", self:concatParams(...)) or self
end

function Logger:infof(fmt, ...)
    return self.isEnabled_ and self:log_(false, Logger.LEVEL_INFO, self.name_, fmt, ...) or self
end

function Logger:warn(...)
    return self.isEnabled_ and self:log_(false, Logger.LEVEL_WARN, self.name_, "%s", self:concatParams(...)) or self
end

function Logger:warnf(fmt, ...)
    return self.isEnabled_ and self:log_(false, Logger.LEVEL_WARN, self.name_, fmt, ...) or self
end

function Logger:error(...)
    return self.isEnabled_ and self:log_(true, Logger.LEVEL_ERROR, self.name_, "%s", self:concatParams(...)) or self
end

function Logger:errorf(fmt, ...)
    return self.isEnabled_ and self:log_(true, Logger.LEVEL_ERROR, self.name_, fmt, ...) or self
end

function Logger:fetal(...)
    return self.isEnabled_ and self:log_(true, Logger.LEVEL_FETAL, self.name_, "%s", self:concatParams(...)) or self
end

function Logger:fetalf(fmt, ...)
    return self.isEnabled_ and self:log_(true, Logger.LEVEL_FETAL, self.name_, fmt, ...) or self
end

function Logger:normalPrint(msg)
    if DEBUG >= Logger.LEVEL_DEBUG then 
        print(msg);
    end
end

function Logger:log_(stackTrace, level, tag, fmt, ...)
    if DEBUG >= level then
        for i,v in ipairs(Logger.outputs) do
            v(string.format("[%s][%s][%s]" .. fmt, Logger.LEVEL_TAGS[level], tag, debug.getinfo(3).name or "main", ...))
            if stackTrace then
                v(debug.traceback("", 3))
            end
        end
    end
    return self
end

function Logger:concatParams(...)
    local para = {...}
    local spara = {}
    for i,v in ipairs(para) do
        if type(v) == "table" then
            spara[#spara + 1] = json.encode(v)
        else
            spara[#spara + 1] = tostring(v)
        end
    end
    return table.concat(spara, " ")
end

return Logger
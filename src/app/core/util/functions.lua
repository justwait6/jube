-- Author: Jam
-- Date: 2015.04.23
require("lfs")
local socket = require("socket")

local functions = {}

function functions.getTime()
    return socket.gettime()
end

function functions.isFileExist(path)
    return path and cc.FileUtils:getInstance():isFileExist(path)
end

function functions.isDirExist(path)
    local success, msg = lfs.chdir(path)
    return success
end

function functions.mkdir(path)
    if DEBUG > 0 then
        print("=====mkdir " .. path)
    end
    if not functions.isDirExist(path) then
        local prefix = ""
        if string.sub(path, 1, 1) == device.directorySeparator then
            prefix = device.directorySeparator
        end
        local pathInfo = string.split(path, device.directorySeparator)
        local i = 1
        while(true) do
            if i > #pathInfo then
                break
            end
            local p = string.trim(pathInfo[i] or "")
            if p == "" or p == "." then
                table.remove(pathInfo, i)
            elseif p == ".." then
                if i > 1 then
                    table.remove(pathInfo, i)
                    table.remove(pathInfo, i - 1)
                    i = i - 1
                else
                    return false
                end
            else
                i = i + 1
            end
        end
        for i = 1, #pathInfo do
            local curPath = prefix .. table.concat(pathInfo, device.directorySeparator, 1, i) .. device.directorySeparator
            if not functions.isDirExist(curPath) then
                local succ, err = lfs.mkdir(curPath)
                if not succ then
                    if DEBUG > 0 then
                        print("=== mkdir" .. path .. " failed, " .. err)
                    end
                    return false
                end
            else
                if DEBUG > 0 then
                    print("curPath exists")
                end
            end 
        end
    end
    if DEBUG > 0 then
        print("===== done mkdir")
    end
    return true
end

function functions.rmdir(path)
    if DEBUG > 0 then
        print("rmdir " .. path)
    end
    if functions.isDirExist(path) then
        local function _rmdir(path) 
            local iter,dir_obj = lfs.dir(path)
            while true do
                local dir = iter(dir_obj)
                if dir == nil then break end
                if dir ~= "." and dir ~= ".." then
                    local curDir = path..dir
                    local mode = lfs.attributes(curDir, "mode")
                    if mode == "directory" then
                        _rmdir(curDir.."/")
                    elseif mode == "file" then
                        os.remove(curDir)
                    end
                end
            end
            local succ,des = lfs.rmdir(path)
            if not succ then 
                if DEBUG > 0 then
                    print("remove dir " .. path .. " failed, " .. des) 
                end
            end
            return succ
        end
        _rmdir(path)
    end
    if DEBUG > 0 then
        print("done rmdir " .. path)
    end
    return true
end

functions.exportMethods = function(target)
    for k,v in pairs(functions) do
        if k ~= "exportMethods" then
            target[k] = v
        end
    end
end

function functions.formatBigNumber(num)
    local len = string.len(tostring(num))
    local temp = tonumber(num)
    local ret 
    if len >= 13 then
        temp = temp / 1000000000000
        ret = string.format("%.3f", temp)
        ret = string.sub(ret, 1, string.len(ret) - 1)
        ret = ret .. "T"
    elseif len >= 10 then
        temp = temp / 1000000000
        ret = string.format("%.3f", temp)
        ret = string.sub(ret, 1, string.len(ret) - 1)
        ret = ret .. "B"
    elseif len >= 7 then
        temp = temp / 1000000
        ret = string.format("%.3f", temp)
        ret = string.sub(ret, 1, string.len(ret) - 1)
        ret = ret .. "M"
    elseif len >= 5 then
        temp = temp / 1000
        ret = string.format("%.3f", temp)
        ret = string.sub(ret, 1, string.len(ret) - 1)
        ret = ret .. "K"
    else
        return tostring(temp)
    end

    if string.find(ret, "%.") then
        while true do
            local len = string.len(ret)
            local c = string.sub(ret, len - 1, string.len(ret) - 1)
            if c == "." then
                ret = string.sub(ret, 1, len - 2) .. string.sub(ret, len)
                break
            else
                c = tonumber(c)
                if c == 0 then
                    ret = string.sub(ret, 1, len - 2) .. string.sub(ret, len)
                else
                    break
                end
            end
        end
    end

    return ret
end

-- json数据解析
function functions.decode(str)
    if str == nil or str == "" then return nil end
    if type(str) == "string" then
        return json.decode(str)
    elseif type(str) == "table" then
        return str
    end
    return nil
end

function functions.formatTime(time)  
    local hour = math.floor(time/3600);  
    local minute = math.fmod(math.floor(time/60), 60)  
    local second = math.fmod(time, 60)  
    local rtTime = string.format("%02d:%02d:%02d", hour, minute, second)  
  
    return rtTime  
end

function functions.formatTime1(time)  
    local hour = math.floor(time/3600);  
    local minute = math.fmod(math.floor(time/60), 60)  
    local second = math.fmod(time, 60)  
    local rtTime = string.format("%02d:%02d", minute, second) 
  
    return rtTime  
end

function functions.tablecopy(ori_tab)
    if (type(ori_tab) ~= "table") then
        return nil
    end
    local new_tab = {}
    for i,v in pairs(ori_tab) do
        local vtyp = type(v)
        if (vtyp == "table") then
            new_tab[i] = functions.tablecopy(v)
        elseif (vtyp == "thread") then
            new_tab[i] = v
        elseif (vtyp == "userdata") then
            new_tab[i] = v
        else
            new_tab[i] = v
        end
    end
    return new_tab
end

function functions.decodeURI(s)
    s = string.gsub(s, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
    return s
end

function functions.encodeURI(s)
    s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return string.gsub(s, " ", "+")
end

function functions.enterScene(name)
    g.windowManager:removeAllWindow()
    app:enterScene(name)
    -- app:enterScene(name, nil, "ZOOMFLIPANGULAR", 0.35)
end

function functions.outScene(name)
    g.windowManager:removeAllWindow()
    app:enterScene(name)
    -- app:enterScene(name, nil, "slideInL", 0.35)
end

function functions.ToBase64(source_str)
    local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    local s64 = ''
    local str = source_str

    while #str > 0 do
        local bytes_num = 0
        local buf = 0

        for byte_cnt=1,3 do
            buf = (buf * 256)
            if #str > 0 then
                buf = buf + string.byte(str, 1, 1)
                str = string.sub(str, 2)
                bytes_num = bytes_num + 1
            end
        end

        for group_cnt=1,(bytes_num+1) do
            b64char = math.fmod(math.floor(buf/262144), 64) + 1
            s64 = s64 .. string.sub(b64chars, b64char, b64char)
            buf = buf * 64
        end

        for fill_cnt=1,(3-bytes_num) do
            s64 = s64 .. '='
        end
    end

    return s64
end


function functions.getNum(a, m)
    if a/m == 0 then
        local x = a/m
        return x,0
    else
        local x = math.floor(a/m)
        local y = math.fmod(a, m)
        return x,y
    end
end
function functions.setAllCascadeOpacityEnabled(node)
    node:setCascadeOpacityEnabled(true)
    if node:getChildrenCount() ~= 0 then
        for _, v in ipairs(node:getChildren()) do
            functions.setAllCascadeOpacityEnabled(v)
        end
    end
end
function functions.setImgGray(node,isGray)

    local vertDefaultSource = 
                       [[
                       attribute vec4 a_position;
                       attribute vec2 a_texCoord;
                       attribute vec4 a_color;  

                       #ifdef GL_ES
                           varying lowp vec4 v_fragmentColor;
                           varying mediump vec2 v_texCoord;
                       #else
                           varying vec4 v_fragmentColor;
                           varying vec2 v_texCoord;
                       #endif 

                       void main()
                       {
                           gl_Position = CC_PMatrix * a_position; 
                           v_fragmentColor = a_color;
                           v_texCoord = a_texCoord;
                       }
                    ]]
    
    local pszFragSource = [[
                       #ifdef GL_ES 
                            precision mediump float;
                        #endif 
                        varying vec4 v_fragmentColor; 
                        varying vec2 v_texCoord; 

                        void main(void) 
                        { 
                            vec4 c = texture2D(CC_Texture0, v_texCoord);
                            gl_FragColor.xyz = vec3(0.4*c.r + 0.4*c.g +0.4*c.b);
                            gl_FragColor.w = c.w; 
                        }
                        ]] 
    local pProgram 
    if isGray then
         pProgram = cc.GLProgram:createWithByteArrays(vertDefaultSource,pszFragSource)
    else
         pProgram = cc.GLProgram:createWithByteArrays("","")
    end
    node:setGLProgram(pProgram)
end

return functions 

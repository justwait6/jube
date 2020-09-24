local LuaJavaBridge = class("LuaJavaBridge")

function LuaJavaBridge:ctor()

end

function LuaJavaBridge:call_(javaClassName, javaMethodName, javaParams, javaMethodSig)
	local ok,ret = luaj.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
	if not ok then
			if ret == -1 then
				print("call %s failed, -1 不支持的参数类型或返回值类型", javaMethodName)
			elseif ret == -2 then
				print("call %s failed, -2 无效的签名", javaMethodName)
			elseif ret == -3 then
				print("call %s failed, -3 没有找到指定的方法", javaMethodName)
			elseif ret == -4 then
				print("call %s failed, -4 Java 方法执行抛出了异常", javaMethodName)
			elseif ret == -5 then
				print("call %s failed, -5 Java 虚拟机出错", javaMethodName)
			elseif ret == -6 then
				print("call %s failed, -6 Java 虚拟机出错", javaMethodName)
			end
	else
			return ok,ret 
	end
	return false, nil
end

function LuaJavaBridge:getFixedWidthText(font, size, text, width)
	local ok, ret = self:call_("com/jujube/core/Function", "getFixedWidthText", {font or "", size or 20, text or "", width or device.display.widthInPixels}, "(Ljava/lang/String;ILjava/lang/String;I)Ljava/lang/String;")
	if ok then
		return ret 
	end
  return ""
end

return LuaJavaBridge

local K = {}
local COOKIE_KEYS = K

K.index = 1
function K.getIndex()
	K.index = K.index + 1
	return K.index
end

function K.getName()
	return tostring(K.getIndex())
end

K.VOLUME = K.getName()
K.CHAT_UIDS = K.getName()

return COOKIE_KEYS

local E = {}

E.index = 1
function E.getIndex()
	E.index = E.index + 1
	return E.index
end

function E.getName()
	return tostring(E.getIndex())
end

E.LOBBY_UPDATE = E.getName()
E.USER_INFO_UPDATE = E.getName()
E.SERVER_PUSH = E.getName()
E.PACKET_RECEIVED = E.getName()
E.SEND_CHAT_RESP = E.getName()
E.GET_TABLE_RESP = E.getName()
E.XXXX = E.getName()

E.FRIEND_RED_DOT = E.getName()
E.FRIENDS_REMARKS_UPDATE = E.getName()

E.RUMMY_CARD_GROUPS_CHANGE = E.getName()
E.RUMMY_CHOSEN_CARD_CHANGE = E.getName()
E.RUMMY_SCORE_POPUP_COUNT = E.getName()
E.RUMMY_UPDATE_SCORE_VIEW = E.getName()

return E

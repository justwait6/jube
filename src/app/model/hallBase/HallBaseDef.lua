-- hall base_function definition, consistent with backend
local HallBaseDef = {}

-- definition, unique number
HallBaseDef.MAILBOX = 1
HallBaseDef.FRIEND = 2
HallBaseDef.TASK = 3
HallBaseDef.FEEDBACK = 4
HallBaseDef.SETTING = 5

HallBaseDef.SEQUENCE = {
	HallBaseDef.MAILBOX,
	HallBaseDef.FRIEND,
	HallBaseDef.TASK,
	HallBaseDef.FEEDBACK,
	HallBaseDef.SETTING,
}

HallBaseDef.HALL_BASE_SEQUENCE = {
	HallBaseDef.MAILBOX,
	HallBaseDef.FRIEND,
	HallBaseDef.TASK,
	HallBaseDef.FEEDBACK,
	HallBaseDef.SETTING,
}

return HallBaseDef

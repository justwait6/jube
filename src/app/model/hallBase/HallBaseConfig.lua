local HallBaseConfig = {}

local HallBaseDef = import(".HallBaseDef")
local hallBaseIconDir = "image/hall/baseIcons"

HallBaseConfig[HallBaseDef.MAILBOX] = {
	baseId = HallBaseDef.MAILBOX,
	baseName = "mailBox",
	baseWindowPath = ".mailBox.MailBoxView",
	hallIconRes = hallBaseIconDir .. "/mailBoxIcon.png",
}

HallBaseConfig[HallBaseDef.FRIEND] = {
	baseId = HallBaseDef.FRIEND,
	baseName = "friend",
	baseWindowPath = ".friend.FriendView",
	hallIconRes = hallBaseIconDir .. "/friendIcon.png",
}

HallBaseConfig[HallBaseDef.TASK] = {
	baseId = HallBaseDef.TASK,
	baseName = "task",
	baseWindowPath = ".task.TaskView",
	hallIconRes = hallBaseIconDir .. "/taskIcon.png",
}

HallBaseConfig[HallBaseDef.FEEDBACK] = {
	baseId = HallBaseDef.FEEDBACK,
	baseName = "feedback",
	baseWindowPath = ".feedback.FeedbackView",
	hallIconRes = hallBaseIconDir .. "/feedbackIcon.png",
}

HallBaseConfig[HallBaseDef.SETTING] = {
	baseId = HallBaseDef.SETTING,
	baseName = "setting",
	baseWindowPath = ".setting.SettingView",
	hallIconRes = hallBaseIconDir .. "/settingIcon.png",
}

return HallBaseConfig

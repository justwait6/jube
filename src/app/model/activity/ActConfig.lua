local ActConfig = {}

local ActDef = import(".ActDef")
local hallIconDir = "image/hall/actIcons"

ActConfig[ActDef.MONEY_TREE] = {
	actId = ActDef.MONEY_TREE,
	actName = "moenyTree",
	actWindowPath = ".moneyTree.MoneyTreeView",
	hallIconRes = hallIconDir .. "/moentyTreeIcon.png",
}

ActConfig[ActDef.SHARE] = {
	actId = ActDef.SHARE,
	actName = "share",
	actWindowPath = ".share.ShareView",
	hallIconRes = hallIconDir .. "/shareIcon.png",
}

ActConfig[ActDef.SEE_VIDEO] = {
	actId = ActDef.SEE_VIDEO,
	actName = "seeVideo",
	actWindowPath = ".seeVideo.SeeVideoView",
	hallIconRes = hallIconDir .. "/videoIcon.png",
}

return ActConfig

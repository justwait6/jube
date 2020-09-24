-- activity definition, consistent with backend
local ActDef = {}

-- definition, unique number
ActDef.MONEY_TREE = 1
ActDef.SHARE = 2
ActDef.SEE_VIDEO = 3

ActDef.SEQUENCE = {
	ActDef.SEE_VIDEO,
	ActDef.MONEY_TREE,
	ActDef.SHARE,
}

ActDef.HALL_ACT_SEQUENCE = {
	ActDef.SEE_VIDEO,
	ActDef.MONEY_TREE,
	ActDef.SHARE,
}

return ActDef

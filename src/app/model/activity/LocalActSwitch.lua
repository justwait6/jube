local LocalActSwitch = {}

local ActDef = import(".ActDef")

LocalActSwitch[ActDef.MONEY_TREE] = true
LocalActSwitch[ActDef.SHARE] = true
LocalActSwitch[ActDef.SEE_VIDEO] = true

LocalActSwitch.getLocalOpenActIds = function ()
	local openIds = {}
	for _, actId in pairs(ActDef.SEQUENCE) do
		if LocalActSwitch[actId] then
			table.insert(openIds, actId)
		end
	end

	return openIds
end

return LocalActSwitch

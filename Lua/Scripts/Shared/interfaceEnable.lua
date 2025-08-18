--enable item usage in health interface without XML overwriting
--[thanks Nebual (NTCyb) for this]
NTEYE.AllowInHealthInterface = {
	-- general compatability if anything has a higher mod load order than us
	"screwdriver",
	"screwdriverhardened",
	"screwdriverdementonite",
	"repairpack",
	"fpgacircuit",
}

local function evaluateExtraUseInHealthInterface()
	LuaUserData.MakeMethodAccessible(Descriptors["Barotrauma.ItemPrefab"], "set_UseInHealthInterface")
	for _, tool in ipairs(NTEYE.AllowInHealthInterface) do
		if ItemPrefab.Prefabs.ContainsKey(tool) then
			ItemPrefab.Prefabs[tool].set_UseInHealthInterface(true)
		end
	end
end

Timer.Wait(function()
	evaluateExtraUseInHealthInterface()
end, 1)

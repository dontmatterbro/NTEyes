--client side counter to update visual eye effects
NTEYE.ClientUpdateCooldown = 0
NTEYE.ClientUpdateInterval = 120

Hook.Add("think", "NTEYE.ClientUpdate", function()
	if HF.GameIsPaused() or not Level.Loaded then
		return
	end

	if NTEYE.ClientUpdateCooldown > 0 then
		NTEYE.ClientUpdateCooldown = NTEYE.ClientUpdateCooldown - 1
	else
		NTEYE.ClientUpdateCooldown = NTEYE.ClientUpdateInterval
		NTEYE.ClientUpdate()
	end
end)

--function to initiate client updates
function NTEYE.ClientUpdate()
	NTEYE.UpdateLights()
end

--update the light effects for eyes
function NTEYE.UpdateLights()
	local ControlledCharacter = Character.Controlled
	local LevelLight = Level.Loaded.LevelData.GenerationParams
	local HullLight = nil

	--these values will need to be adjusted
	local LevelColor = Color(100, 100, 100, 100)
	local HullColor = Color(100, 100, 100, 100)

	--eye client effect definitions
	--"ce" stands for "client effect"
	NTEYE.ClientEffects = {
		ce_human = {},
		ce_cyber = {},
		ce_enhanced = {},
		ce_plastic = {},
		ce_crawler = {},
		ce_mudraptor = {},
		ce_watcher = {},
		ce_husk = {},
		ce_charybdis = {},
		ce_latcher = {},
		ce_terror = {},
		--lens types
		ce_medical = {},
		ce_electrical = {},
		ce_zoom = {},
		ce_night = {},
		ce_thermal = {},
	}

	LevelLight.AmbientLightColor = Color(50, 0, 0, 45)

	for k, HullLight in pairs(Hull.HullList) do
		HullLight.AmbientLight = Color(60, 0, 0, 75)
	end
end

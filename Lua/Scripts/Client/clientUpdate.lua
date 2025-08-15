--client side counter to update visual eye effects
NTEYE.ClientUpdateCooldown = 0
NTEYE.ClientUpdateInterval = 60

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
	NTEYE.WriteHUD()
end

--table for eye client effect definitions
--"ce" stands for "client effect"
NTEYE.ClientEffects = {
	-- lens types
	ce_medical = {
		affliction = "lt_medical",
		levelColor = Color(100, 0, 0, 55),
		hullColor = Color(100, 0, 0, 85),
	},
	ce_electrical = {
		affliction = "lt_electrical",
		levelColor = Color(100, 100, 0, 65),
		hullColor = Color(100, 100, 0, 90),
	},
	ce_zoom = {
		affliction = "lt_zoom",
		levelColor = Color(0, 45, 100, 55),
		hullColor = Color(0, 45, 100, 85),
	},
	ce_night = {
		affliction = "lt_night",
		levelColor = Color(0, 200, 0, 200),
		hullColor = Color(0, 200, 0, 200),
	},
	ce_thermal = {
		affliction = "lt_thermal",
		levelColor = Color(125, 0, 125, 65),
		hullColor = Color(125, 0, 125, 90),
	},
	--eye types
	ce_human = {
		affliction = "vi_human",
		levelColor = Color(27, 30, 36, 55),
		hullColor = Color(27, 30, 36, 80),
	},
	ce_cyber = {
		affliction = "vi_cyber",
		levelColor = Color(65, 65, 65, 65),
		hullColor = Color(65, 65, 65, 90),
	},
	ce_enhanced = {
		affliction = "vi_enhanced",
		levelColor = Color(27, 30, 36, 60),
		hullColor = Color(27, 30, 36, 80),
	},
	ce_plastic = {
		affliction = "vi_plastic",
		levelColor = Color(0, 0, 255, 0),
		hullColor = Color(0, 0, 255, 0),
	},
	ce_crawler = {
		affliction = "vi_crawler",
		levelColor = Color(65, 20, 0, 80),
		hullColor = Color(50, 0, 0, 40),
	},
	ce_mudraptor = {
		affliction = "vi_mudraptor",
		levelColor = Color(0, 65, 65, 70),
		hullColor = Color(0, 50, 50, 55),
	},
	ce_watcher = {
		affliction = "vi_watcher",
		levelColor = Color(255, 0, 0, 115),
		hullColor = Color(255, 0, 0, 115),
	},
	ce_husk = {
		affliction = "vi_husk",
		levelColor = Color(85, 15, 150, 35),
		hullColor = Color(85, 15, 150, 35),
	},
	ce_charybdis = {
		affliction = "vi_charybdis",
		levelColor = Color(75, 15, 30, 115),
		hullColor = Color(75, 15, 30, 65),
	},
	ce_latcher = {
		affliction = "vi_latcher",
		levelColor = Color(0, 130, 130, 150),
		hullColor = Color(0, 130, 130, 150),
	},
	ce_terror = {
		affliction = "vi_terror",
		levelColor = Color(255, 0, 0, 255),
		hullColor = Color(255, 0, 0, 255),
	},
}

--function to blend colors by averaging
local function BlendColors(colors)
	if #colors == 0 then
		return Color(0, 0, 0, 0)
	end
	local r, g, b, a = 0, 0, 0, 0
	for _, c in ipairs(colors) do
		r = r + c.R
		g = g + c.G
		b = b + c.B
		a = a + c.A
	end
	local n = #colors
	return Color(math.floor(r / n), math.floor(g / n), math.floor(b / n), math.floor(a / n))
end

--function to update light colors
function NTEYE.UpdateLights()
	local ControlledCharacter = Character.Controlled
	local LevelLight = Level.Loaded.LevelData.GenerationParams
	--check if the player controls a character
	--if not reset color values
	if not ControlledCharacter or not (ControlledCharacter.IsMale or ControlledCharacter.IsFemale) then
		LevelLight.AmbientLightColor = Color(100, 100, 100, 100)

		for _, HullLight in pairs(Hull.HullList) do
			HullLight.AmbientLight = Color(100, 100, 100, 100)
		end
		return
	end

	--check if the controlled character is a robot
	if not () then 

	local levelColors, hullColors = {}, {}

	for _, effect in pairs(NTEYE.ClientEffects) do
		if HF.HasAffliction(ControlledCharacter, effect.affliction) then
			levelColors[#levelColors + 1] = effect.levelColor
			hullColors[#hullColors + 1] = effect.hullColor
		end
	end
	if #levelColors == 0 and #hullColors == 0 then
		return
	end
	local LevelColor = BlendColors(levelColors)
	local HullColor = BlendColors(hullColors)

	LevelLight.AmbientLightColor = LevelColor

	for _, HullLight in pairs(Hull.HullList) do
		HullLight.AmbientLight = HullColor
	end
end

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

--table for eye client effect definitions
--"ce" stands for "client effect"
NTEYE.ClientEffects = {
	-- lens types
	ce_medical = {
		affliction = "lt_medical",
		levelColor = Color(100, 0, 0, 65),
		hullColor = Color(100, 0, 0, 95),
	},
	ce_electrical = {
		affliction = "lt_electrical",
		levelColor = Color(100, 100, 0, 75),
		hullColor = Color(100, 100, 0, 100),
	},
	ce_zoom = {
		affliction = "lt_zoom",
		levelColor = Color(0, 45, 100, 65),
		hullColor = Color(0, 45, 100, 95),
	},
	ce_night = {
		affliction = "lt_night",
		levelColor = Color(20, 160, 30, 255),
		hullColor = Color(20, 160, 20, 255),
	},
	ce_thermal = {
		affliction = "lt_thermal",
		levelColor = Color(125, 0, 125, 75),
		hullColor = Color(125, 0, 125, 100),
	},
	--eye types
	ce_human = {
		affliction = "vi_human",
		levelColor = Color(27, 30, 36, 75),
		hullColor = Color(27, 30, 36, 100),
	},
	ce_cyber = {
		affliction = "vi_cyber",
		levelColor = Color(65, 65, 65, 75),
		hullColor = Color(65, 65, 65, 100),
	},
	ce_enhanced = {
		affliction = "vi_enhanced",
		levelColor = Color(27, 30, 36, 75),
		hullColor = Color(27, 30, 36, 100),
	},
	ce_plastic = {
		affliction = "vi_plastic",
		levelColor = Color(0, 0, 255, 0),
		hullColor = Color(0, 0, 255, 0),
	},
	ce_crawler = {
		affliction = "vi_crawler",
		levelColor = Color(65, 20, 0, 90),
		hullColor = Color(50, 0, 0, 50),
	},
	ce_mudraptor = {
		affliction = "vi_mudraptor",
		levelColor = Color(0, 65, 65, 80),
		hullColor = Color(0, 50, 50, 65),
	},
	ce_watcher = {
		affliction = "vi_watcher",
		levelColor = Color(255, 0, 0, 125),
		hullColor = Color(255, 0, 0, 125),
	},
	ce_husk = {
		affliction = "vi_husk",
		levelColor = Color(85, 15, 150, 45),
		hullColor = Color(85, 15, 150, 45),
	},
	ce_charybdis = {
		affliction = "vi_charybdis",
		levelColor = Color(75, 15, 30, 125),
		hullColor = Color(75, 15, 30, 75),
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
	local LevelLight = Level.Loaded.LevelData.GenerationParams

	local levelColors = {}
	local hullColors = {}

	for _, effect in pairs(NTEYE.ClientEffects) do
		if HF.HasAffliction(Character.Controlled, effect.affliction) then
			table.insert(levelColors, effect.levelColor)
			table.insert(hullColors, effect.hullColor)
		end
	end

	local LevelColor = BlendColors(levelColors)
	local HullColor = BlendColors(hullColors)

	LevelLight.AmbientLightColor = LevelColor

	for _, HullLight in pairs(Hull.HullList) do
		HullLight.AmbientLight = HullColor
	end
end

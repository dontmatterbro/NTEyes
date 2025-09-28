--define the config options needed
NTEYE.ConfigData = {
	NTEYE_header1 = { name = NTEYE.Name, type = "category" },

	NTEYE_lightBoost = {
		name = "Light Boost",
		default = 0,
		range = { -255, 255 },
		type = "float",
		description = "Boosts the amount of light (RGB alpha value) each eye has. 'cl_reloadlua' is required to take effect.",
	},
	NTEYE_eyeDamageMultiplier = {
		name = "Eye Biological Damage Multiplier",
		default = 1,
		range = { 0, 10 },
		type = "float",
		description = "Multiplies the biological eye damage amount by the number set.",
	},
	NTEYE_pressureDamageMultiplier = {
		name = "Eye Pressure Damage Multiplier",
		default = 1,
		range = { 0, 10 },
		type = "float",
		description = "Multiplies the water presure eye damage amount by the number set.",
	},
	NTEYE_cataractChanceMultiplier = {
		name = "Cataract Chance Multiplier",
		default = 1,
		range = { 0, 10 },
		type = "float",
		description = "Multiplies the cataract chance value (0.03) by the number set.",
	},
	NTEYE_disableRetinopathy = {
		name = "Disable Retinopathy",
		default = false,
		type = "bool",
		description = "Disables the retinopathy chance upon having a dead eye and not removing it.",
	},
}

--this adds above config options to the Neurotrauma config menu
NTConfig.AddConfigOptions(NTEYE)

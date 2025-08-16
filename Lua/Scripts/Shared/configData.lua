--define the config options needed
NTEYE.ConfigData = {
	NTEYE_header1 = { name = NTEYE.Name, type = "category" },

	NTEYE_lightBoost = {
		name = "Light Boost",
		default = 0,
		range = { -255, 255 },
		type = "float",
	},
	NTEYE_eyeDamageMultiplier = {
		name = "Eye Damage Multiplier",
		default = 1,
		range = { 0, 10 },
		type = "float",
	},
	NTEYE_cataractChance = {
		name = "Cataract Chance",
		default = 0.03,
		range = { 0, 10 },
		type = "float",
	},
}

--this adds above config options to the Neurotrauma config menu
NTConfig.AddConfigOptions(NTEYE)

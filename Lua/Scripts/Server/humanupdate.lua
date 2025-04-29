--set local functions
local function PressureDamageCalculation(c)
	if c.IsProtectedFromPressure or c.IsImmuneToPressure then
		return 0
	else
		return 1
	end
end

local function HasEyes(c)
	--placeholder
end

--define afflictions for humanupdate
NT.Afflictions = {

	--surgery afflictions
	sr_removedeyes = {},
	sr_removedeye = {},
	sr_heldlid = {},
	sr_poppedeye = {},
	sr_eyeconnector = {},
	sr_corneaincision = {},
	sr_emulsification = {},
	sr_eyedrops = {},
	sr_lasersurgery = {},
	--mechanical afflictions
	mc_deadeyes = {},
	mc_deadeye = {},
	mc_eyedamage = {},
	mc_retinopathy = {},
	mc_cataract = {},
	mc_visionsickness = {},
	mc_mismatch = {},
	--eye type afflictions
	et_human = {
		max = 100,
		update = function(c, i)
			if c.stats.stasis then
				return
			end

			local gain = (
				-0.1 * c.stats.healingrate -- passive regen
				+ c.afflictions.hypoxemia.strength / 100 -- from hypoxemia
				+ HF.Clamp(c.afflictions.stroke.strength, 0, 20) * 0.1 -- from stroke
				+ c.afflictions.sepsis.strength / 100 * 0.4 -- from sepsis
				+ PressureDamageCalculation(c) -- from pressure
			) * NT.Deltatime

			if gain > 0 then
				gain = gain
					* NTC.GetMultiplier(c.character, "eyedamagegain") -- NTC multiplier
					* NTConfig.Get("NT_eyedamageGain", 1) -- Config multiplier
			end
			c.afflictions[i].strength = c.afflictions[i].strength + gain

			if (c.afflictions.mc_deadeye or c.afflictions.sr_removedeye) and c.afflictions[i].strength >= 50 then
				c.afflictions[i].strength = 50
			else
				c.afflictions[i].strength = HF.Clamp(c.afflictions[i].strength, 0, 100)
			end
		end,
	},
	et_cyber = {},
	et_enhanced = {},
	et_plastic = {},
	et_crawler = {},
	et_mudraptor = {},
	et_watcher = {},
	et_husk = {},
	et_charybdis = {},
	et_latcher = {},
	et_terror = {},
	--lens afflictions
	et_medical = {},
	et_electrical = {},
	et_zoom = {},
	et_night = {},
	et_thermal = {},
}

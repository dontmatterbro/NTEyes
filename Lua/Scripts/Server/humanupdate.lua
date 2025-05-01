--set local functions
local function PressureDamageCalculation(c)
	if c.InPressure and not (c.IsProtectedFromPressure or c.IsImmuneToPressure) then
		return 3
	else
		return 0
	end
end

--define afflictions for humanupdate
NTEYE.Afflictions = {

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
	--eye damage afflictions
	dm_human = {
		max = 100,
		update = function(c, i)
			--check if the correct eye type
			if not (c.afflictions.vi_human.strength > 0) then
				return
			end
			--check if stasis
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
			if --blind the player in one eye
				c.afflictions[i].strength >= 50
				and (not (c.afflictions.mc_deadeye.strength > 0) and not (c.afflictions.sr_removedeye.strength > 0))
			then
				c.afflictions[i].strength = c.afflictions[i].strength - 50
				c.afflictions.mc_deadeye.strength = 2
				if --if the player has a mismatch, remove only this eye
					c.afflictions.mc_mismatch.strength > 0
				then
					c.afflictions.vi_human.strength = 0
				end
			elseif --if there is only one eye, fully blind the player
				(c.afflictions[i].strength >= 50)
				and (HF.HasAffliction(c.character, "mc_deadeye") or HF.HasAffliction(c.character, "sr_removedeye"))
			then
				c.afflictions[i].strength = 0
				c.afflictions.vi_human.strength = 0
				c.afflictions.dm_human.strength = 0
				c.afflictions.sr_removedeye.strength = 0
				c.afflictions.mc_deadeye.strength = 0
				c.afflictions.mc_deadeyes.strength = 2
			else --if no issues, apply normal damage
				c.afflictions[i].strength = HF.Clamp(c.afflictions[i].strength, 0, 100)
			end
		end,
	},
	dm_cyber = {},
	dm_enhanced = {},
	dm_plastic = {},
	dm_crawler = {},
	dm_mudraptor = {},
	dm_watcher = {},
	dm_husk = {},
	dm_charybdis = {},
	dm_latcher = {},
	dm_terror = {},
	--lens afflictions
	et_medical = {},
	et_electrical = {},
	et_zoom = {},
	et_night = {},
	et_thermal = {},

	--visual indicators
	vi_human = {},
	vi_cyber = {},
	vi_plastic = {},
	vi_crawler = {},
	vi_mudraptor = {},
	vi_watcher = {},
	vi_husk = {},
	vi_charybdis = {},
	vi_latcher = {},
	vi_terror = {},
}

for k, v in pairs(NTEYE.Afflictions) do
	NT.Afflictions[k] = v
end

--pressure damage calculation
local function PressureDamageCalculation(character)
	local pressureDamage = 3
	return (
		(character.InPressure and not (character.IsProtectedFromPressure or character.IsImmuneToPressure))
		and pressureDamage
	) or 0
end

local function PassiveEyeRemoval(afflictionsTable, statsTable, character, limb, i)
	if --blind the player in one eye
		afflictionsTable[i].strength >= 80
		and (not (afflictionsTable.mc_deadeye.strength > 0) and not (afflictionsTable.sr_removedeye.strength > 0))
	then
		afflictionsTable[i].strength = afflictionsTable[i].strength - 50
		HF.SetAfflictionLimb(character, "mc_deadeye", limb, 100) --add deadeye
		if --if the player has a mismatch, remove only this eye
			afflictionsTable.mc_mismatch.strength > 0
		then
			HF.SetAfflictionLimb(character, "vi_human", limb, 0) --remove eye indicator
			HF.SetAfflictionLimb(character, "mc_deadeye", limb, 100) --add deadeye
		end
	elseif --if there is only one eye, fully blind the player
		(afflictionsTable[i].strength >= 50)
		and (afflictionsTable.mc_deadeye.strength >= 1 or afflictionsTable.sr_removedeye.strength >= 1)
	then
		afflictionsTable[i].strength = 0
		HF.SetAfflictionLimb(character, "vi_human", limb, 0) --remove eye indicator
		HF.SetAfflictionLimb(character, "dm_human", limb, 0) --remove damage
		HF.SetAfflictionLimb(character, "sr_removedeye", limb, 0) --remove removedeye
		HF.SetAfflictionLimb(character, "mc_deadeye", limb, 0) --remove deadeye

		HF.SetAfflictionLimb(character, "mc_deadeyes", limb, 100) --add deadeyes
	else --if no issues, apply normal damage
		afflictionsTable[i].strength = HF.Clamp(afflictionsTable[i].strength, 0, 100)
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
			--variables for optimization
			local afflictionsTable = c.afflictions
			local statsTable = c.stats
			local character = c.character
			local limb = LimbType.Head

			--check if the correct eye type
			if not (afflictionsTable.vi_human.strength > 0) then
				return
			end
			--check if stasis
			if statsTable.stasis then
				return
			end

			local gain = (
				-0.1 * statsTable.healingrate -- passive regen
				+ afflictionsTable.hypoxemia.strength / 100 -- from hypoxemia
				+ HF.Clamp(afflictionsTable.stroke.strength, 0, 20) * 0.1 -- from stroke
				+ afflictionsTable.sepsis.strength / 100 * 0.4 -- from sepsis
				+ PressureDamageCalculation(character) -- from pressure
			) * NT.Deltatime

			if gain > 0 then
				gain = gain
					* NTC.GetMultiplier(character, "eyedamagegain") -- NTC multiplier
					* NTConfig.Get("NT_eyedamageGain", 1) -- Config multiplier
			end
			afflictionsTable[i].strength = afflictionsTable[i].strength + gain
			--function to check for eye death
			PassiveEyeRemoval(afflictionsTable, statsTable, character, limb, i)
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
	vi_human = {
		--add eye if no eye afflictions
		max = 2,
		update = function(c, i)
			local character = c.character
			local limb = LimbType.Head
			local afflictionTags = {
				"vi_type",
				"eye_type",
				"eye_surgery",
				"eye_mechanic",
			}

			--check if character has any eye afflictions
			for _, affliction in ipairs(afflictionTags) do
				if character.CharacterHealth.GetAfflictionOfType(affliction) ~= nil then
					return
				end
			end
			--if no eye afflictions, give default eye indicator (human)
			HF.SetAfflictionLimb(character, "vi_human", limb, 100)
		end,
	},
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

--add afflictions to NT.Afflictions
for k, v in pairs(NTEYE.Afflictions) do
	NT.Afflictions[k] = v
end

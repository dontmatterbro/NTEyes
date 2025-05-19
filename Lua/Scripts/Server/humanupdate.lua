--pressure damage calculation
local function PressureDamageCalculation(character)
	local pressureDamage = 3
	return (
		(character.InPressure and not (character.IsProtectedFromPressure or character.IsImmuneToPressure))
		and pressureDamage
	) or 0
end

local function PassiveEyeRemoval(afflictionsTable, statsTable, character, limb, i)
	if
		afflictionsTable[i].strength >= 80
		and (
			not (afflictionsTable.mc_deadeye and afflictionsTable.mc_deadeye.strength > 0)
			and not (afflictionsTable.sr_removedeye and afflictionsTable.sr_removedeye.strength > 0)
		)
	then
		if HF.Chance(0.1) then
			print("test1")
			afflictionsTable[i].strength = afflictionsTable[i].strength - 50
			HF.SetAfflictionLimb(character, "mc_deadeye", limb, 100)
			if afflictionsTable.mc_mismatch and afflictionsTable.mc_mismatch.strength > 0 then
				local base = i:match("^dm_(.+)$")
				if base then
					HF.SetAfflictionLimb(character, "vi_" .. base, limb, 0)
					HF.SetAfflictionLimb(character, "dm_" .. base, limb, 0)
				end
				HF.SetAfflictionLimb(character, "mc_deadeye", limb, 100)
			end
		end
	elseif
		(afflictionsTable[i].strength >= 45)
		and (
			(afflictionsTable.mc_deadeye and afflictionsTable.mc_deadeye.strength >= 1)
			or (afflictionsTable.sr_removedeye and afflictionsTable.sr_removedeye.strength >= 1)
			or (afflictionsTable.mc_mismatch and afflictionsTable.mc_mismatch.strength >= 1)
		)
	then
		if HF.Chance(0.1) then
			print("test2")
			afflictionsTable[i].strength = 0
			local base = i:match("^dm_(.+)$")
			if base then
				HF.SetAfflictionLimb(character, "vi_" .. base, limb, 0)
				HF.SetAfflictionLimb(character, "dm_" .. base, limb, 0)
			end
			if afflictionsTable.mc_mismatch and afflictionsTable.mc_mismatch.strength >= 1 then
				--dead eye
				HF.SetAfflictionLimb(character, "mc_deadeye", limb, 100)
				HF.SetAfflictionLimb(character, "mc_mismatch", limb, 0)
			else
				HF.NukeEyeAfflictions(character)
				HF.SetAfflictionLimb(character, "mc_deadeyes", limb, 100)
			end
		end
	else
		afflictionsTable[i].strength = HF.Clamp(afflictionsTable[i].strength, 0, 100)
	end
end

--define afflictions for humanupdate
NTEYE.UpdateAfflictions = {

	--surgery afflictions
	sr_removedeyes = {},
	sr_removedeye = {},
	sr_heldlid = {},
	sr_poppedeye = {},
	sr_eyeconnector = {},
	sr_corneaincision = {},
	sr_emulsification = {},
	sr_eyedrops = {
		max = 100,
		update = function(c, i)
			local afflictionsTable = c.afflictions
			local statsTable = c.stats
			local character = c.character
			local limb = LimbType.Head
			--check if stasis
			if statsTable.stasis then
				return
			end
			if c.afflictions[i].strength <= 0 then
				return
			end
			for affKey, aff in pairs(afflictionsTable) do
				if affKey:sub(1, 3) == "dm_" and affKey ~= "dm_cyber" and affKey ~= "dm_plastic" then
					local viKey = "vi_" .. affKey:sub(4)
					if afflictionsTable[viKey] and afflictionsTable[viKey].strength > 0 then
						aff.strength = (aff.strength or 0) - 0.03
					end
				end
			end
		end,
	},
	sr_lasersurgery = {
		max = 100,
		update = function(c, i)
			local afflictionsTable = c.afflictions
			local statsTable = c.stats
			local character = c.character
			local limb = LimbType.Head
			--check if stasis
			if statsTable.stasis then
				return
			end
			if c.afflictions[i].strength <= 0 then
				return
			end
			for affKey, aff in pairs(afflictionsTable) do
				if affKey:sub(1, 3) == "dm_" and affKey ~= "dm_cyber" and affKey ~= "dm_plastic" then
					local viKey = "vi_" .. affKey:sub(4)
					if afflictionsTable[viKey] and afflictionsTable[viKey].strength > 0 then
						aff.strength = (aff.strength or 0) - 0.1
					end
				end
			end
		end,
	},
	--mechanical afflictions
	mc_deadeyes = {},
	mc_deadeye = {
		--having a dead eye will have a chance to cause autoimmune retinopathy
		max = 100,
		update = function(c, i)
			--variables for optimization
			local afflictionsTable = c.afflictions
			local statsTable = c.stats
			local character = c.character
			local limb = LimbType.Head
			--check if stasis
			if statsTable.stasis then
				return
			end
			if afflictionsTable.mc_deadeye.strength > 0 then
				if HF.Chance(0.005) then -- 0.5% chance to cause retinopathy
					HF.SetAfflictionLimb(character, "mc_retinopathy", limb, 1)
				end
			end
		end,
	},
	mc_retinopathy = {
		max = 100,
		update = function(c, i)
			local afflictionsTable = c.afflictions
			local statsTable = c.stats
			local character = c.character
			local limb = LimbType.Head
			--check if stasis
			if statsTable.stasis then
				return
			end
			if c.afflictions[i].strength <= 0 then
				return
			end
			for affKey, aff in pairs(afflictionsTable) do
				if affKey:sub(1, 3) == "dm_" and affKey ~= "dm_cyber" and affKey ~= "dm_plastic" then
					local viKey = "vi_" .. affKey:sub(4)
					if afflictionsTable[viKey] and afflictionsTable[viKey].strength > 0 then
						aff.strength = (aff.strength or 0) + 2.5
					end
				end
			end
		end,
	},
	mc_cataract = {
		max = 100,
		update = function(c, i)
			local afflictionsTable = c.afflictions
			local statsTable = c.stats
			local character = c.character
			local limb = LimbType.Head
			--check if stasis
			if statsTable.stasis then
				return
			end
			if c.afflictions[i].strength >= 80 then
				NTC.SetSymptomTrue(character, "sym_blurredvision", 10)
			end
		end,
	},
	mc_visionsickness = {
		max = 100,
		update = function(c, i)
			local afflictionsTable = c.afflictions
			local statsTable = c.stats
			local character = c.character
			local limb = LimbType.Head
			--check if stasis
			if statsTable.stasis then
				return
			end
			if c.afflictions[i].strength >= 20 then
				NTC.SetSymptomTrue(character, "sym_confusion", 10)
			end
			if c.afflictions[i].strength >= 50 then
				NTC.SetSymptomTrue(character, "sym_headache", 10)
			end
		end,
	},
	mc_mismatch = {
		max = 100,
		update = function(c, i)
			local afflictionsTable = c.afflictions
			local statsTable = c.stats
			local character = c.character
			local limb = LimbType.Head
			--check if stasis
			if statsTable.stasis then
				return
			end
			if c.afflictions[i].strength <= 0 then
				return
			end
			NTC.SetSymptomTrue(character, "sym_headache", 10)
			if HF.Chance(0.07) then
				NTC.SetSymptomTrue(character, "sym_nausea", 10)
			end
		end,
	},
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
	dm_cyber = {
		max = 100,
		update = function(c, i)
			--variables for optimization
			local afflictionsTable = c.afflictions
			local statsTable = c.stats
			local character = c.character
			local limb = LimbType.Head

			--check if the correct eye type
			if not (afflictionsTable.vi_cyber.strength > 0) then
				return
			end
			--check if stasis
			if statsTable.stasis then
				return
			end

			--cyber eyes won't receive biological damage

			--function to check for eye death
			PassiveEyeRemoval(afflictionsTable, statsTable, character, limb, i)
		end,
	},
	dm_enhanced = {
		max = 100,
		update = function(c, i)
			--variables for optimization
			local afflictionsTable = c.afflictions
			local statsTable = c.stats
			local character = c.character
			local limb = LimbType.Head

			--check if the correct eye type
			if not (afflictionsTable.vi_enhanced.strength > 0) then
				return
			end
			--check if stasis
			if statsTable.stasis then
				return
			end

			local gain = (
				-0.1 * statsTable.healingrate -- passive regen
				+ afflictionsTable.hypoxemia.strength / 120 -- from hypoxemia
				+ HF.Clamp(afflictionsTable.stroke.strength, 0, 20) * 0.08 -- from stroke
				+ afflictionsTable.sepsis.strength / 100 * 0.35 -- from sepsis
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
	dm_plastic = {
		max = 100,
		update = function(c, i)
			--variables for optimization
			local afflictionsTable = c.afflictions
			local statsTable = c.stats
			local character = c.character
			local limb = LimbType.Head

			--check if the correct eye type
			if not (afflictionsTable.vi_plastic.strength > 0) then
				return
			end
			--check if stasis
			if statsTable.stasis then
				return
			end

			--plastic eyes won't receive biological damage

			--function to check for eye death
			PassiveEyeRemoval(afflictionsTable, statsTable, character, limb, i)
		end,
	},
	dm_crawler = {
		max = 100,
		update = function(c, i)
			--variables for optimization
			local afflictionsTable = c.afflictions
			local statsTable = c.stats
			local character = c.character
			local limb = LimbType.Head

			--check if the correct eye type
			if not (afflictionsTable.vi_crawler.strength > 0) then
				return
			end
			--check if stasis
			if statsTable.stasis then
				return
			end

			local gain = (
				-0.1 * statsTable.healingrate -- passive regen
				+ afflictionsTable.hypoxemia.strength / 80 -- from hypoxemia
				+ HF.Clamp(afflictionsTable.stroke.strength, 0, 20) * 0.1 -- from stroke
				+ afflictionsTable.sepsis.strength / 100 * 0.4 -- from sepsis			--monster eyes won't receive pressure damage

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
	dm_mudraptor = {
		max = 100,
		update = function(c, i)
			--variables for optimization
			local afflictionsTable = c.afflictions
			local statsTable = c.stats
			local character = c.character
			local limb = LimbType.Head

			--check if the correct eye type
			if not (afflictionsTable.vi_mudraptor.strength > 0) then
				return
			end
			--check if stasis
			if statsTable.stasis then
				return
			end

			local gain = (
				-0.1 * statsTable.healingrate -- passive regen
				+ afflictionsTable.hypoxemia.strength / 80 -- from hypoxemia
				+ HF.Clamp(afflictionsTable.stroke.strength, 0, 20) * 0.1 -- from stroke
				+ afflictionsTable.sepsis.strength / 100 * 0.4 -- from sepsis			--monster eyes won't receive pressure damage

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
	dm_hammerhead = {
		max = 100,
		update = function(c, i)
			--variables for optimization
			local afflictionsTable = c.afflictions
			local statsTable = c.stats
			local character = c.character
			local limb = LimbType.Head

			--check if the correct eye type
			if not (afflictionsTable.vi_hammerhead.strength > 0) then
				return
			end
			--check if stasis
			if statsTable.stasis then
				return
			end

			local gain = (
				-0.1 * statsTable.healingrate -- passive regen
				+ afflictionsTable.hypoxemia.strength / 80 -- from hypoxemia
				+ HF.Clamp(afflictionsTable.stroke.strength, 0, 20) * 0.1 -- from stroke
				+ afflictionsTable.sepsis.strength / 100 * 0.4 -- from sepsis			--monster eyes won't receive pressure damage

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
	dm_watcher = {
		max = 100,
		update = function(c, i)
			--variables for optimization
			local afflictionsTable = c.afflictions
			local statsTable = c.stats
			local character = c.character
			local limb = LimbType.Head

			--check if the correct eye type
			if not (afflictionsTable.vi_watcher.strength > 0) then
				return
			end
			--check if stasis
			if statsTable.stasis then
				return
			end

			local gain = (
				-0.1 * statsTable.healingrate -- passive regen
				+ afflictionsTable.hypoxemia.strength / 80 -- from hypoxemia
				+ HF.Clamp(afflictionsTable.stroke.strength, 0, 20) * 0.1 -- from stroke
				+ afflictionsTable.sepsis.strength / 100 * 0.4 -- from sepsis			--monster eyes won't receive pressure damage

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
	dm_husk = {
		max = 100,
		update = function(c, i)
			--variables for optimization
			local afflictionsTable = c.afflictions
			local statsTable = c.stats
			local character = c.character
			local limb = LimbType.Head

			--check if the correct eye type
			if not (afflictionsTable.vi_husk.strength > 0) then
				return
			end
			--check if stasis
			if statsTable.stasis then
				return
			end

			local gain = (
				-0.2 * statsTable.healingrate -- passive regen
				+ afflictionsTable.hypoxemia.strength / 400 -- from hypoxemia
				+ HF.Clamp(afflictionsTable.stroke.strength, 0, 20) * 0.01 -- from stroke
				+ afflictionsTable.sepsis.strength / 100 * 0.05 -- from sepsis			--monster eyes won't receive pressure damage

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
	dm_charybdis = {
		max = 100,
		update = function(c, i)
			--variables for optimization
			local afflictionsTable = c.afflictions
			local statsTable = c.stats
			local character = c.character
			local limb = LimbType.Head

			--check if the correct eye type
			if not (afflictionsTable.vi_charybdis.strength > 0) then
				return
			end
			--check if stasis
			if statsTable.stasis then
				return
			end

			local gain = (
				-0.1 * statsTable.healingrate -- passive regen
				+ afflictionsTable.hypoxemia.strength / 200 -- from hypoxemia
				+ HF.Clamp(afflictionsTable.stroke.strength, 0, 20) * 0.05 -- from stroke
				+ afflictionsTable.sepsis.strength / 100 * 0.02 -- from sepsis			--monster eyes won't receive pressure damage

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
	dm_latcher = {
		max = 100,
		update = function(c, i)
			--variables for optimization
			local afflictionsTable = c.afflictions
			local statsTable = c.stats
			local character = c.character
			local limb = LimbType.Head

			--check if the correct eye type
			if not (afflictionsTable.vi_latcher.strength > 0) then
				return
			end
			--check if stasis
			if statsTable.stasis then
				return
			end

			local gain = (
				-0.1 * statsTable.healingrate -- passive regen
				+ afflictionsTable.hypoxemia.strength / 160 -- from hypoxemia
				+ HF.Clamp(afflictionsTable.stroke.strength, 0, 20) * 0.08 -- from stroke
				+ afflictionsTable.sepsis.strength / 100 * 0.2 -- from sepsis			--monster eyes won't receive pressure damage

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
	dm_terror = {
		max = 100,
		update = function(c, i)
			--variables for optimization
			local afflictionsTable = c.afflictions
			local statsTable = c.stats
			local character = c.character
			local limb = LimbType.Head

			--check if the correct eye type
			if not (afflictionsTable.vi_terror.strength > 0) then
				return
			end
			--check if stasis
			if statsTable.stasis then
				return
			end

			local gain = (
				-0.15 * statsTable.healingrate -- passive regen

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
	--lens afflictions
	lt_medical = {},
	lt_electrical = {},
	lt_zoom = {},
	lt_night = {},
	lt_thermal = {},

	--visual indicators
	vi_human = {
		--add eye if no eye afflictions // works like the blood pressure from NT
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
	vi_enhanced = {},
	vi_plastic = {},
	vi_crawler = {},
	vi_mudraptor = {},
	vi_hammerhead = {},
	vi_watcher = {},
	vi_husk = {},
	vi_charybdis = {},
	vi_latcher = {},
	vi_terror = {},
}

--add afflictions to NT.Afflictions
for k, v in pairs(NTEYE.UpdateAfflictions) do
	NT.Afflictions[k] = v
end

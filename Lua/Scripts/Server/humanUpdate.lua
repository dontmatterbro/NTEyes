--pressure damage calculation
local function PressureDamageCalculation(character, pressureDamageValue)
	--this may be redundant, not a big deal tho
	local pressureDamageValue = pressureDamage

	--check if there is a pressureDamage value, if not set it 0
	if pressureDamage == nil then
		pressureDamage = 0
	end

	--return the damage value
	return (
		(character.InPressure and not (character.IsProtectedFromPressure or character.IsImmuneToPressure))
		and pressureDamage
	) or 0
end

--remove eye upon death on passive check
local function PassiveEyeRemoval(afflictionsTable, statsTable, character, limb, i, biological)
	--check if damage is above 80 and if there are 2 eyes
	if
		afflictionsTable[i].strength >= 80
		and (
			not (afflictionsTable.mc_deadeye and afflictionsTable.mc_deadeye.strength > 0)
			and not (afflictionsTable.sr_removedeye and afflictionsTable.sr_removedeye.strength > 0)
		)
	then
		--at a chance every tick, remove the eye
		local removalChance = (afflictionsTable[i].strength / 8) --for mercy, every tick has a damage/8 (10% at 80 damage) chance to remove the eye
		if HF.Chance(removalChance) then
			--remove the dead eye's damage from total eye health
			afflictionsTable[i].strength = afflictionsTable[i].strength - 50

			--add dead or removed eye affliction depending on if the eye is biological
			--biological eyes get dead eye, non-biological ones get removedeye
			--this is important for retinopathy checks
			if biological then
				HF.SetAfflictionLimb(character, "mc_deadeye", limb, 100)
			else
				HF.SetAfflictionLimb(character, "sr_removedeye", limb, 100)
			end
			--if there is a mismatch, remove only the damaged eye and leave the other as is
			if afflictionsTable.mc_mismatch and afflictionsTable.mc_mismatch.strength > 0 then
				local base = i:match("^dm_(.+)$")
				if base then
					HF.SetAfflictionLimb(character, "vi_" .. base, limb, 0)
					HF.SetAfflictionLimb(character, "dm_" .. base, limb, 0)
				end
				--HF.SetAfflictionLimb(character, "mc_deadeye", limb, 100) --this seems redundant aint it??
			end
		end
	elseif --check the status of the other eye if only 1 of the same type can be found
		(afflictionsTable[i].strength >= 45)
		and (
			(afflictionsTable.mc_deadeye and afflictionsTable.mc_deadeye.strength >= 1)
			or (afflictionsTable.sr_removedeye and afflictionsTable.sr_removedeye.strength >= 1)
			or (afflictionsTable.mc_mismatch and afflictionsTable.mc_mismatch.strength >= 1) --character may have 2 eyes of different types
		)
	then
		local removalChance = (afflictionsTable[i].strength / 10) --for mercy (again), every tick has a damage/10 (4.5% at 45 damage) chance to remove the eye
		if HF.Chance(removalChance) then
			--remove the eye damage
			afflictionsTable[i].strength = 0
			--check for the eye again, then remove it
			local base = i:match("^dm_(.+)$")
			if base then
				HF.SetAfflictionLimb(character, "vi_" .. base, limb, 0)
				HF.SetAfflictionLimb(character, "dm_" .. base, limb, 0)
			end
			--remove the mismatch if there is one
			if afflictionsTable.mc_mismatch and afflictionsTable.mc_mismatch.strength >= 1 then
				--dead or removed eye depending on if it is biological
				if biological then
					HF.SetAfflictionLimb(character, "mc_deadeye", limb, 100)
				else
					HF.SetAfflictionLimb(character, "sr_removedeye", limb, 100)
				end
				HF.SetAfflictionLimb(character, "mc_mismatch", limb, 0)
			else --if no mismatch, kill the remaining eye
				HF.NukeEyeAfflictions(character)
				--dead or removed eye depending on if it is biological
				if biological then
					HF.SetAfflictionLimb(character, "mc_deadeyes", limb, 100)
				else
					HF.SetAfflictionLimb(character, "sr_removedeyes", limb, 100)
				end
			end
		end
	else
		--I do not remember what this does (could be something important, too lazy to check rn, too afraid to delete)
		--I am adding these comments 3 months after writing the inital code lmao
		afflictionsTable[i].strength = HF.Clamp(afflictionsTable[i].strength, 0, 100)
	end
end

--define afflictions for humanupdate (this is added the Neurotrauma humanupdate table)
NTEYE.UpdateAfflictions = {

	--surgery afflictions
	sr_removedeyes = {},
	sr_removedeye = {},
	sr_heldlid = {},
	sr_poppedeye = {},
	sr_eyeconnector = {},
	sr_corneaincision = {},
	sr_emulsification = {},
	--increases eye health
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
	--increases eye health more
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
	--causes retinopathy at a chance
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
	--increases retinopathy if the player has it
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
	--triggers vision debuffs upon having cataracts
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
	--used for blur after surgery
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
	--used when character has incompatible eyes
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

			--variable declaration for gain
			--divided by; higher value, less damage
			local hypoxemiaResistance = 200
			local strokeResistance = 0.1
			local sepsisResistance = 0.4
			--set by; lower value, less damage
			local pressureDamage = 3
			local regenRate = -0.1 --inverse for passive healing
			--set if the eye is biological or not
			local biological = true

			--sets biological damage gain for eyes (can be negative or positive)
			local gain = (
				regenRate * statsTable.healingrate -- passive regen
				+ afflictionsTable.hypoxemia.strength / hypoxemiaResistance -- from hypoxemia
				+ HF.Clamp(afflictionsTable.stroke.strength, 0, 20) * strokeResistance -- from stroke
				+ afflictionsTable.sepsis.strength / 100 * sepsisResistance -- from sepsis
				+ PressureDamageCalculation(character, pressureDamage) -- from pressure
			) * NT.Deltatime

			if gain > 0 then
				gain = gain
					* NTC.GetMultiplier(character, "eyedamagegain") -- NTC multiplier
					* NTConfig.Get("NT_eyedamageGain", 1) -- Config multiplier
			end
			afflictionsTable[i].strength = afflictionsTable[i].strength + gain
			--function to check for eye death
			PassiveEyeRemoval(afflictionsTable, statsTable, character, limb, i, biological)
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

			--set if the eye is biological or not
			local biological = false
			--cyber eyes won't receive biological damage

			--function to check for eye death
			PassiveEyeRemoval(afflictionsTable, statsTable, character, limb, i, biological)
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

			--variable declaration for gain
			--divided by; higher value, less damage
			local hypoxemiaResistance = 250
			local strokeResistance = 0.08
			local sepsisResistance = 0.3
			--set by; lower value, less damage
			local pressureDamage = 2.5
			local regenRate = -0.1 --inverse for passive healing
			--set if the eye is biological or not
			local biological = true

			--sets biological damage gain for eyes (can be negative or positive)
			local gain = (
				regenRate * statsTable.healingrate -- passive regen
				+ afflictionsTable.hypoxemia.strength / hypoxemiaResistance -- from hypoxemia
				+ HF.Clamp(afflictionsTable.stroke.strength, 0, 20) * strokeResistance -- from stroke
				+ afflictionsTable.sepsis.strength / 100 * sepsisResistance -- from sepsis
				+ PressureDamageCalculation(character, pressureDamage) -- from pressure
			) * NT.Deltatime

			if gain > 0 then
				gain = gain
					* NTC.GetMultiplier(character, "eyedamagegain") -- NTC multiplier
					* NTConfig.Get("NT_eyedamageGain", 1) -- Config multiplier
			end
			afflictionsTable[i].strength = afflictionsTable[i].strength + gain
			--function to check for eye death
			PassiveEyeRemoval(afflictionsTable, statsTable, character, limb, i, biological)
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

			--set if the eye is biological or not
			local biological = false
			--plastic eyes won't receive biological damage

			--function to check for eye death
			PassiveEyeRemoval(afflictionsTable, statsTable, character, limb, i, biological)
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

			--variable declaration for gain
			--divided by; higher value, less damage
			local hypoxemiaResistance = 100
			local strokeResistance = 0.1
			local sepsisResistance = 0.4
			--set by; lower value, less damage
			local pressureDamage = 0
			local regenRate = -0.1 --inverse for passive healing
			--set if the eye is biological or not
			local biological = true

			--sets biological damage gain for eyes (can be negative or positive)
			local gain = (
				regenRate * statsTable.healingrate -- passive regen
				+ afflictionsTable.hypoxemia.strength / hypoxemiaResistance -- from hypoxemia
				+ HF.Clamp(afflictionsTable.stroke.strength, 0, 20) * strokeResistance -- from stroke
				+ afflictionsTable.sepsis.strength / 100 * sepsisResistance -- from sepsis
				+ PressureDamageCalculation(character, pressureDamage) -- from pressure
			) * NT.Deltatime

			if gain > 0 then
				gain = gain
					* NTC.GetMultiplier(character, "eyedamagegain") -- NTC multiplier
					* NTConfig.Get("NT_eyedamageGain", 1) -- Config multiplier
			end
			afflictionsTable[i].strength = afflictionsTable[i].strength + gain
			--function to check for eye death
			PassiveEyeRemoval(afflictionsTable, statsTable, character, limb, i, biological)
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

			--variable declaration for gain
			--divided by; higher value, less damage
			local hypoxemiaResistance = 100
			local strokeResistance = 0.1
			local sepsisResistance = 0.4
			--set by; lower value, less damage
			local pressureDamage = 0
			local regenRate = -0.1 --inverse for passive healing
			--set if the eye is biological or not
			local biological = true

			--sets biological damage gain for eyes (can be negative or positive)
			local gain = (
				regenRate * statsTable.healingrate -- passive regen
				+ afflictionsTable.hypoxemia.strength / hypoxemiaResistance -- from hypoxemia
				+ HF.Clamp(afflictionsTable.stroke.strength, 0, 20) * strokeResistance -- from stroke
				+ afflictionsTable.sepsis.strength / 100 * sepsisResistance -- from sepsis
				+ PressureDamageCalculation(character, pressureDamage) -- from pressure
			) * NT.Deltatime

			if gain > 0 then
				gain = gain
					* NTC.GetMultiplier(character, "eyedamagegain") -- NTC multiplier
					* NTConfig.Get("NT_eyedamageGain", 1) -- Config multiplier
			end
			afflictionsTable[i].strength = afflictionsTable[i].strength + gain
			--function to check for eye death
			PassiveEyeRemoval(afflictionsTable, statsTable, character, limb, i, biological)
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

			--variable declaration for gain
			--divided by; higher value, less damage
			local hypoxemiaResistance = 100
			local strokeResistance = 0.1
			local sepsisResistance = 0.4
			--set by; lower value, less damage
			local pressureDamage = 0
			local regenRate = -0.1 --inverse for passive healing
			--set if the eye is biological or not
			local biological = true

			--sets biological damage gain for eyes (can be negative or positive)
			local gain = (
				regenRate * statsTable.healingrate -- passive regen
				+ afflictionsTable.hypoxemia.strength / hypoxemiaResistance -- from hypoxemia
				+ HF.Clamp(afflictionsTable.stroke.strength, 0, 20) * strokeResistance -- from stroke
				+ afflictionsTable.sepsis.strength / 100 * sepsisResistance -- from sepsis
				+ PressureDamageCalculation(character, pressureDamage) -- from pressure
			) * NT.Deltatime

			if gain > 0 then
				gain = gain
					* NTC.GetMultiplier(character, "eyedamagegain") -- NTC multiplier
					* NTConfig.Get("NT_eyedamageGain", 1) -- Config multiplier
			end
			afflictionsTable[i].strength = afflictionsTable[i].strength + gain
			--function to check for eye death
			PassiveEyeRemoval(afflictionsTable, statsTable, character, limb, i, biological)
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

			--variable declaration for gain
			--divided by; higher value, less damage
			local hypoxemiaResistance = 100
			local strokeResistance = 0.1
			local sepsisResistance = 0.4
			--set by; lower value, less damage
			local pressureDamage = 0
			local regenRate = -0.1 --inverse for passive healing
			--set if the eye is biological or not
			local biological = true

			--sets biological damage gain for eyes (can be negative or positive)
			local gain = (
				regenRate * statsTable.healingrate -- passive regen
				+ afflictionsTable.hypoxemia.strength / hypoxemiaResistance -- from hypoxemia
				+ HF.Clamp(afflictionsTable.stroke.strength, 0, 20) * strokeResistance -- from stroke
				+ afflictionsTable.sepsis.strength / 100 * sepsisResistance -- from sepsis
				+ PressureDamageCalculation(character, pressureDamage) -- from pressure
			) * NT.Deltatime

			if gain > 0 then
				gain = gain
					* NTC.GetMultiplier(character, "eyedamagegain") -- NTC multiplier
					* NTConfig.Get("NT_eyedamageGain", 1) -- Config multiplier
			end
			afflictionsTable[i].strength = afflictionsTable[i].strength + gain
			--function to check for eye death
			PassiveEyeRemoval(afflictionsTable, statsTable, character, limb, i, biological)
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

			--variable declaration for gain
			--divided by; higher value, less damage
			local hypoxemiaResistance = 1000
			local strokeResistance = 0.03
			local sepsisResistance = 0.03
			--set by; lower value, less damage
			local pressureDamage = 0
			local regenRate = -0.2 --inverse for passive healing
			--set if the eye is biological or not
			local biological = true

			--sets biological damage gain for eyes (can be negative or positive)
			local gain = (
				regenRate * statsTable.healingrate -- passive regen
				+ afflictionsTable.hypoxemia.strength / hypoxemiaResistance -- from hypoxemia
				+ HF.Clamp(afflictionsTable.stroke.strength, 0, 20) * strokeResistance -- from stroke
				+ afflictionsTable.sepsis.strength / 100 * sepsisResistance -- from sepsis
				+ PressureDamageCalculation(character, pressureDamage) -- from pressure
			) * NT.Deltatime

			if gain > 0 then
				gain = gain
					* NTC.GetMultiplier(character, "eyedamagegain") -- NTC multiplier
					* NTConfig.Get("NT_eyedamageGain", 1) -- Config multiplier
			end
			afflictionsTable[i].strength = afflictionsTable[i].strength + gain
			--function to check for eye death
			PassiveEyeRemoval(afflictionsTable, statsTable, character, limb, i, biological)
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

			--variable declaration for gain
			--divided by; higher value, less damage
			local hypoxemiaResistance = 300
			local strokeResistance = 0.05
			local sepsisResistance = 0.02
			--set by; lower value, less damage
			local pressureDamage = 0
			local regenRate = -0.1 --inverse for passive healing
			--set if the eye is biological or not
			local biological = true

			--sets biological damage gain for eyes (can be negative or positive)
			local gain = (
				regenRate * statsTable.healingrate -- passive regen
				+ afflictionsTable.hypoxemia.strength / hypoxemiaResistance -- from hypoxemia
				+ HF.Clamp(afflictionsTable.stroke.strength, 0, 20) * strokeResistance -- from stroke
				+ afflictionsTable.sepsis.strength / 100 * sepsisResistance -- from sepsis
				+ PressureDamageCalculation(character, pressureDamage) -- from pressure
			) * NT.Deltatime

			if gain > 0 then
				gain = gain
					* NTC.GetMultiplier(character, "eyedamagegain") -- NTC multiplier
					* NTConfig.Get("NT_eyedamageGain", 1) -- Config multiplier
			end
			afflictionsTable[i].strength = afflictionsTable[i].strength + gain
			--function to check for eye death
			PassiveEyeRemoval(afflictionsTable, statsTable, character, limb, i, biological)
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

			--variable declaration for gain
			--divided by; higher value, less damage
			local hypoxemiaResistance = 250
			local strokeResistance = 0.08
			local sepsisResistance = 0.2
			--set by; lower value, less damage
			local pressureDamage = 0
			local regenRate = -0.1 --inverse for passive healing
			--set if the eye is biological or not
			local biological = true

			--sets biological damage gain for eyes (can be negative or positive)
			local gain = (
				regenRate * statsTable.healingrate -- passive regen
				+ afflictionsTable.hypoxemia.strength / hypoxemiaResistance -- from hypoxemia
				+ HF.Clamp(afflictionsTable.stroke.strength, 0, 20) * strokeResistance -- from stroke
				+ afflictionsTable.sepsis.strength / 100 * sepsisResistance -- from sepsis
				+ PressureDamageCalculation(character, pressureDamage) -- from pressure
			) * NT.Deltatime

			if gain > 0 then
				gain = gain
					* NTC.GetMultiplier(character, "eyedamagegain") -- NTC multiplier
					* NTConfig.Get("NT_eyedamageGain", 1) -- Config multiplier
			end
			afflictionsTable[i].strength = afflictionsTable[i].strength + gain
			--function to check for eye death
			PassiveEyeRemoval(afflictionsTable, statsTable, character, limb, i, biological)
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

			--set if the eye is biological or not
			local biological = false --very cool lore reasons I promise

			--terror eyes do not receive biological damage and heal really fast
			local gain = (
				-0.3 * statsTable.healingrate -- passive regen
			) * NT.Deltatime

			if gain > 0 then
				gain = gain
					* NTC.GetMultiplier(character, "eyedamagegain") -- NTC multiplier
					* NTConfig.Get("NT_eyedamageGain", 1) -- Config multiplier
			end
			afflictionsTable[i].strength = afflictionsTable[i].strength + gain
			--function to check for eye death
			PassiveEyeRemoval(afflictionsTable, statsTable, character, limb, i, biological)
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

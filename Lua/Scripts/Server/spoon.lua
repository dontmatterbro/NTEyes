--hook to item to extract eyes upon hit
Hook.Add("NTEYE.Spoon", "NTEYE.Spoon", function(effect, deltaTime, item, targets, worldPosition, element)
	local limb = LimbType.Head
	local usingCharacter = item.Equipper

	for k, targetCharacter in pairs(targets) do
		--check if target exists, has eyes
		if not (targetCharacter and HF.HasEyes(targetCharacter)) then
			return
		end

		--if target character is human
		if targetCharacter.IsHuman then
			NTEYE.ScoopHuman(targetCharacter, usingCharacter)
			HF.NukeEyeAfflictions(targetCharacter) --remove eye afflictions
			HF.SetAfflictionLimb(targetCharacter, "sr_removedeyes", limb, 100, usingCharacter) --add removed eyes to patient
			if not targetCharacter.IsDead then
				local randomFigure --variable for RNG

				randomFigure = math.random(25, 85)
				HF.AddAfflictionLimb(targetCharacter, "traumaticshock", limb, randomFigure) --give traumatic shock

				randomFigure = math.random(1, 25)
				HF.AddAfflictionLimb(targetCharacter, "bleeding", limb, randomFigure) --give bleeding
			end
		else
			--if target character is not human	// temporarily disabled
			--NTEYE.ScoopMonster(targetCharacter, usingCharacter)
			--HF.SetAffliction(targetCharacter, "sr_removedeyes", 100) --add removed eyes to monster
			return --temporarily disabled
		end
		--manually update the afflictions if target is already dead
		if targetCharacter.IsDead then
			Networking.CreateEntityEvent(targetCharacter, Character.CharacterStatusEventData.__new(true))
		end --thanks ydrec
		--remove my beloved spoon upon use
		item.Condition = 0
	end
end)

--function to scoop eyes from humans
function NTEYE.ScoopHuman(targetCharacter, usingCharacter)
	local limb = LimbType.Head

	for _, eye in ipairs(NTEYE.EyeProperty) do
		local randomDamage
		if targetCharacter.IsDead then
			randomDamage = math.random(25, 100)
		else
			randomDamage = math.random(10, 35)
		end

		if HF.HasAffliction(targetCharacter, eye.type) then
			if eye.damage ~= nil then
				local afflictionDamage = HF.GetAfflictionStrength(targetCharacter, eye.damage, 0)
				if
					HF.HasAffliction(targetCharacter, "sr_removedeye")
					or HF.HasAffliction(targetCharacter, "mc_deadeye")
					or HF.HasAffliction(targetCharacter, "mc_mismatch")
				then
					if (usingCharacter ~= nil) and (eye.item ~= "") then
						--give one item
						HF.GiveItemAtCondition(usingCharacter, eye.item, (100 - afflictionDamage * 2) - randomDamage)
					end
				else
					if (usingCharacter ~= nil) and (eye.item ~= "") then
						--give two items
						HF.GiveItemAtCondition(usingCharacter, eye.item, (100 - afflictionDamage) - randomDamage)
						HF.GiveItemAtCondition(usingCharacter, eye.item, (100 - afflictionDamage) - randomDamage)
					end
				end
			end
		end
	end
end

--function to scoop eyes from monsters
function NTEYE.ScoopMonster(targetCharacter, usingCharacter)
	local speciesList = {
		--{ type = "Crawler", item = "it_crawlereye" }, disabled for now
		--{ type = "Mudraptor", item = "it_mudraptoreye" },
		--{ type = "Hammerhead", item = "it_hammerheadeye" },
		--{ type = "Watcher", item = "it_watchereye" },
		{ type = "Husk", item = "it_huskeye" },
		--{ type = "Charybdis", item = "it_charybdiseye" },
		--{ type = "Latcher", item = "it_latchereye" },
	}
	for _, species in ipairs(speciesList) do
		if targetCharacter.MatchesSpeciesNameOrGroup(species.type) or targetCharacter.SpeciesName == species.type then
			local randomDamage = math.random(35, 100)
			HF.GiveItemAtCondition(usingCharacter, species.item, (100 - randomDamage))
			HF.GiveItemAtCondition(usingCharacter, species.item, (100 - randomDamage))
		end
	end
end

function NTEYE.DamageEye(targetCharacter, damage, damageType)
	--fill this functinon
	if damage == nil then
		return
	end
	local limb = LimbType.Head
	if HF.HasEyes(targetCharacter) then
		for _, eye in ipairs(NTEYE.EyeProperty) do
			if HF.HasAffliction(targetCharacter, eye.type) then
				--apply damage to the eye
				HF.AddAfflictionLimb(targetCharacter, eye.damage, limb, damage)
			end
		end
	end
end

--lifted from NT ondamaged.lua, gets a damage reduction value based on armor worn
local function getCalculatedDamageReduction(armor, strength)
	if armor == nil then
		return 0
	end
	local reduction = 0

	if armor.HasTag("deepdiving") or armor.HasTag("deepdivinglarge") then
		local modifiers = armor.GetComponentString("Wearable").DamageModifiers
		for modifier in modifiers do
			if string.find(modifier.AfflictionIdentifiers, "concussion") ~= nil then
				reduction = strength - strength * modifier.DamageMultiplier
			end
		end
	elseif armor.HasTag("smallitem") then
		local modifiers = armor.GetComponentString("Wearable").DamageModifiers
		for modifier in modifiers do
			if string.find(modifier.AfflictionIdentifiers, "concussion") ~= nil then
				reduction = strength - strength * modifier.DamageMultiplier
			end
		end
	end
	return reduction
end

--code lifted from NT fork ondamaged.lua
Hook.Add("character.applyDamage", "NTEYE.ondamaged", function(characterHealth, attackResult, hitLimb)
	if -- invalid attack data, don't do anything
		--hitLimb ~= LimbType.Head --if limb isn't head return
		hitLimb == nil
		or hitLimb.IsSevered
		or characterHealth == nil
		or characterHealth.Character == nil
		or characterHealth.Character.IsDead
		or not characterHealth.Character.IsHuman
		or attackResult == nil
		or attackResult.Afflictions == nil
		or #attackResult.Afflictions <= 0
	then
		return
	end

	local afflictions = attackResult.Afflictions

	-- ntc
	-- modifying ondamaged hooks
	for key, val in pairs(NTC.ModifyingOnDamagedHooks) do
		afflictions = val(characterHealth, afflictions, hitLimb)
	end

	local identifier = ""
	local methodtorun = nil
	for value in afflictions do
		-- execute fitting method, if available
		identifier = value.Prefab.Identifier.Value
		methodtorun = NTEYE.OnDamagedMethods[identifier]
		if methodtorun ~= nil then
			-- make resistance from afflictions apply
			local resistance = HF.GetResistance(characterHealth.Character, identifier, hitLimb.type)
			local strength = value.Strength * (1 - resistance)

			methodtorun(characterHealth.Character, strength, hitLimb.type)
		end
	end

	-- ntc
	-- ondamaged hooks
	for key, val in pairs(NTC.OnDamagedHooks) do
		val(characterHealth, attackResult, hitLimb)
	end
end)

NTEYE.OnDamagedMethods = {}

--cause eye damage by gunshots
NTEYE.OnDamagedMethods.gunshotwound = function(character, strength, limbtype)
	--normalize limb value
	limbtype = HF.NormalizeLimbType(limbtype)

	--check if the head has been hit, if not return
	if limbtype ~= LimbType.Head then
		return
	end

	--define variables to be used
	local damage
	local damageType = "gunshotwound"
	--start the damage function if strength is above 1
	if strength >= 1 then
		--eyes only get his at a chance
		local hitChance = strength / 200
		if HF.Chance(hitChance) then
			--reduce damage strength based on armor
			local armor1 = character.Inventory.GetItemInLimbSlot(InvSlotType.OuterClothes)
			local armor2 = character.Inventory.GetItemInLimbSlot(InvSlotType.Head)
			damage = strength
				- getCalculatedDamageReduction(armor1, strength)
				- getCalculatedDamageReduction(armor2, strength)
		end
	end
	--run the actual function that does damage
	NTEYE.DamageEye(character, damage, damageType)
end

--cause eye damage by explosion
NTEYE.OnDamagedMethods.explosiondamage = function(character, strength, limbtype)
	--normalize limb value
	limbtype = HF.NormalizeLimbType(limbtype)

	--check if the head has been hit, if not return
	if limbtype ~= LimbType.Head then
		return
	end

	--define variables to be used
	local damage
	local damageType = "explosiondamage"

	--start the damage function if strength is above 1
	if strength >= 1 then
		--eyes only get his at a chance
		local hitChance = strength / 200
		if HF.Chance(hitChance) then
			--reduce damage strength based on armor
			local armor1 = character.Inventory.GetItemInLimbSlot(InvSlotType.OuterClothes)
			local armor2 = character.Inventory.GetItemInLimbSlot(InvSlotType.Head)
			damage = strength
				- getCalculatedDamageReduction(armor1, strength)
				- getCalculatedDamageReduction(armor2, strength)
		end
	end
	--run the actual function that does damage
	NTEYE.DamageEye(character, damage, damageType)
end

--cause eye damage by bitewounds
NTEYE.OnDamagedMethods.bitewounds = function(character, strength, limbtype)
	--normalize limb value
	limbtype = HF.NormalizeLimbType(limbtype)

	--check if the head has been hit, if not return
	if limbtype ~= LimbType.Head then
		return
	end

	--define variables to be used
	local damage
	local damageType = "bitewounds"

	--start the damage function if strength is above 1
	if strength >= 1 then
		--eyes only get his at a chance
		local hitChance = strength / 200
		if HF.Chance(hitChance) then
			--reduce damage strength based on armor
			local armor1 = character.Inventory.GetItemInLimbSlot(InvSlotType.OuterClothes)
			local armor2 = character.Inventory.GetItemInLimbSlot(InvSlotType.Head)
			damage = strength
				- getCalculatedDamageReduction(armor1, strength)
				- getCalculatedDamageReduction(armor2, strength)
		end
	end
	--run the actual function that does damage
	NTEYE.DamageEye(character, damage, damageType)
end

--cause eye damage by laceration
NTEYE.OnDamagedMethods.lacerations = function(character, strength, limbtype)
	--normalize limb value
	limbtype = HF.NormalizeLimbType(limbtype)

	--check if the head has been hit, if not return
	if limbtype ~= LimbType.Head then
		return
	end

	--define variables to be used
	local damage
	local damageType = "lacerations"

	--start the damage function if strength is above 1
	if strength >= 1 then
		--eyes only get his at a chance
		local hitChance = strength / 200
		if HF.Chance(hitChance) then
			--reduce damage strength based on armor
			local armor1 = character.Inventory.GetItemInLimbSlot(InvSlotType.OuterClothes)
			local armor2 = character.Inventory.GetItemInLimbSlot(InvSlotType.Head)
			damage = strength
				- getCalculatedDamageReduction(armor1, strength)
				- getCalculatedDamageReduction(armor2, strength)
		end
	end
	--run the actual function that does damage
	NTEYE.DamageEye(character, damage, damageType)
end

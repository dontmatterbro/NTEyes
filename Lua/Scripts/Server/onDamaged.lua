function NTEYE.DamageEye(character, limbtype, strength)
	--fill this functinon
end

--code lifted from NT fork ondamaged.lua
Hook.Add("character.applyDamage", "NTEYE.ondamaged", function(characterHealth, attackResult, hitLimb)
	if -- invalid attack data, don't do anything
		hitLimb ~= LimbType.Head --if limb isn't head return
		or characterHealth == nil
		or characterHealth.Character == nil
		or characterHealth.Character.IsDead
		or not characterHealth.Character.IsHuman
		or attackResult == nil
		or attackResult.Afflictions == nil
		or #attackResult.Afflictions <= 0
		or hitLimb == nil
		or hitLimb.IsSevered
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

NTEYE.OnDamagedMethods.gunshotwound = function(character, strength, limbtype)
	limbtype = HF.NormalizeLimbType(limbtype)
	if strength >= 1 then
		if HF.Chance(strength / 200) then
			NTEYE.DamageEye(character, strength)
		end
	end
end

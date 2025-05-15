NTEYE.ScannerActive = false

-- Helper to get color config or default
local function getColorConfig(key, default)
	return table.concat(NTConfig.Get(key, 1) or default, ",")
end

-- Helper to check if identifier is in any category
local function inCategory(categories, identifier)
	for _, category in ipairs(categories) do
		if HF.TableContains(category, identifier) then
			return true
		end
	end
	return false
end

function NTEYE.HealthScanner(usingCharacter, targetCharacter, limb)
	local limbtype = HF.NormalizeLimbType(limb)
	NTEYE.PlayScannerSound(usingCharacter)

	-- Color configs
	local defaultColor = "127,255,255"
	local colorKeys = {
		BaseColor = "NTSCAN_basecolor",
		NameColor = "NTSCAN_namecolor",
		LowColor = "NTSCAN_lowcolor",
		MedColor = "NTSCAN_medcolor",
		HighColor = "NTSCAN_highcolor",
		VitalColor = "NTSCAN_vitalcolor",
		RemovalColor = "NTSCAN_removalcolor",
		CustomColor = "NTSCAN_customcolor",
	}
	local colors = {}
	if NTConfig.Get("NTSCAN_enablecoloredscanner", 1) then
		for k, v in pairs(colorKeys) do
			colors[k] = getColorConfig(v, { 127, 255, 255 })
		end
	else
		for k in pairs(colorKeys) do
			colors[k] = defaultColor
		end
	end

	local LowMedThreshold = NTConfig.Get("NTSCAN_lowmedThreshold", 1)
	local MedHighThreshold = NTConfig.Get("NT_medhighThreshold", 1)

	local VitalCategory = NTConfig.Get("NTSCAN_VitalCategory", 1)
	local RemovalCategory = NTConfig.Get("NTSCAN_RemovalCategory", 1)
	local CustomCategory = NTConfig.Get("NTSCAN_CustomCategory", 1)
	local PressureCategory = { "bloodpressure" }
	local IgnoredCategory = NTConfig.Get("NTSCAN_IgnoredCategory", 1)

	local startReadout = string.format(
		"‖color:%s‖Affliction readout for ‖color:end‖‖color:%s‖%s‖color:end‖‖color:%s‖ on limb %s:\n‖color:end‖",
		colors.BaseColor,
		colors.NameColor,
		targetCharacter.Name,
		colors.BaseColor,
		HF.LimbTypeToString(limbtype)
	)

	local readouts = {
		LowPressure = "",
		HighPressure = "",
		LowStrength = "",
		MediumStrength = "",
		HighStrength = "",
		Vital = "",
		Removal = "",
		Custom = "",
	}

	local afflictionlist = targetCharacter.CharacterHealth.GetAllAfflictions()
	local afflictionsdisplayed = 0

	for value in afflictionlist do
		local strength = HF.Round(value.Strength)
		local prefab = value.Prefab
		local limb = targetCharacter.CharacterHealth.GetAfflictionLimb(value)
		local afflimbtype = prefab.LimbSpecific and (limb and limb.type or LimbType.Torso) or prefab.IndicatorLimb
		afflimbtype = HF.NormalizeLimbType(afflimbtype)

		if strength >= prefab.ShowInHealthScannerThreshold and afflimbtype == limbtype then
			local id = value.Identifier
			local name = value.Prefab.Name.Value .. ": " .. strength .. "%"

			local isVital = HF.TableContains(VitalCategory, id)
			local isRemoval = HF.TableContains(RemovalCategory, id)
			local isPressure = HF.TableContains(PressureCategory, id)
			local isCustom = HF.TableContains(CustomCategory, id)
			local isIgnored = HF.TableContains(IgnoredCategory, id)

			if not (isVital or isRemoval or isPressure or isCustom or isIgnored) then
				if strength < LowMedThreshold then
					readouts.LowStrength = readouts.LowStrength .. "\n" .. name
				elseif strength < MedHighThreshold then
					readouts.MediumStrength = readouts.MediumStrength .. "\n" .. name
				else
					readouts.HighStrength = readouts.HighStrength .. "\n" .. name
				end
			end

			if isVital and not isIgnored then
				readouts.Vital = readouts.Vital .. "\n" .. name
			end
			if isRemoval and not isIgnored then
				readouts.Removal = readouts.Removal .. "\n" .. name
			end
			if isCustom and not isIgnored then
				readouts.Custom = readouts.Custom .. "\n" .. name
			end
			if isPressure and not isIgnored then
				if strength > 130 or strength < 70 then
					readouts.HighPressure = readouts.HighPressure .. "\n" .. name
				else
					readouts.LowPressure = readouts.LowPressure .. "\n" .. name
				end
			end

			afflictionsdisplayed = afflictionsdisplayed + 1
		end
	end

	if afflictionsdisplayed <= 0 then
		readouts.LowStrength = readouts.LowStrength .. "\nNo afflictions! Good work!"
	end

	Timer.Wait(function()
		HF.DMClient(
			HF.CharacterToClient(usingCharacter),
			startReadout
				.. "‖color:"
				.. colors.LowColor
				.. "‖"
				.. readouts.LowPressure
				.. "‖color:end‖"
				.. "‖color:"
				.. colors.HighColor
				.. "‖"
				.. readouts.HighPressure
				.. "‖color:end‖"
				.. "‖color:"
				.. colors.LowColor
				.. "‖"
				.. readouts.LowStrength
				.. "‖color:end‖"
				.. "‖color:"
				.. colors.MedColor
				.. "‖"
				.. readouts.MediumStrength
				.. "‖color:end‖"
				.. "‖color:"
				.. colors.HighColor
				.. "‖"
				.. readouts.HighStrength
				.. "‖color:end‖"
				.. "‖color:"
				.. colors.VitalColor
				.. "‖"
				.. readouts.Vital
				.. "‖color:end‖"
				.. "‖color:"
				.. colors.RemovalColor
				.. "‖"
				.. readouts.Removal
				.. "‖color:end‖"
				.. "‖color:"
				.. colors.CustomColor
				.. "‖"
				.. readouts.Custom
				.. "‖color:end‖"
		)
		NTEYE.ScannerActive = false
	end, 1075)
end

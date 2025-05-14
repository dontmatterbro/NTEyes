--enable screwdriver to be used in health interface
--[thanks Nebual (NTCyb) for this]
NTEYE.AllowInHealthInterface = {
	-- general compatability if anything has a higher mod load order than us
	"screwdriver",
	"screwdriverhardened",
	"screwdriverdementonite",
	"repairpack",
	"fpgacircuit",
}

local function evaluateExtraUseInHealthInterface()
	LuaUserData.MakeMethodAccessible(Descriptors["Barotrauma.ItemPrefab"], "set_UseInHealthInterface")
	for _, tool in ipairs(NTEYE.AllowInHealthInterface) do
		if ItemPrefab.Prefabs.ContainsKey(tool) then
			ItemPrefab.Prefabs[tool].set_UseInHealthInterface(true)
		end
	end
end

Timer.Wait(function()
	evaluateExtraUseInHealthInterface()
end, 1)

--table to define eye afflictions/items
eyeProperty = {
	{ type = "vi_human", damage = "dm_human", item = "it_humaneye" },
	{ type = "vi_cyber", damage = "dm_cyber", item = "it_cybereye" },
	{ type = "vi_enhanced", damage = "dm_enhanced", item = "it_enhancedeye" },
	{ type = "vi_plastic", damage = "dm_plastic", item = "it_plasticeye" },
	{ type = "vi_crawler", damage = "dm_crawler", item = "it_crawlereye" },
	{ type = "vi_mudraptor", damage = "dm_mudraptor", item = "it_mudraptoreye" },
	{ type = "vi_watcher", damage = "dm_watcher", item = "it_watchereye" },
	{ type = "vi_husk", damage = "dm_husk", item = "it_huskeye" },
	{ type = "vi_charybdis", damage = "dm_charybdis", item = "it_charybdiseye" },
	{ type = "vi_latcher", damage = "dm_latcher", item = "it_latchereye" },
	{ type = "vi_terror", damage = "dm_terror", item = "it_terroreye" },
	{ type = "sr_removedeyes", damage = 0, item = "" },
	{ type = "mc_deadeyes", damage = 0, item = "" },
}

lensProperty = {
	{ affliction = "lt_medical", item = "it_medicallens" },
	{ affliction = "lt_electrical", item = "it_electricallens" },
	{ affliction = "lt_magnification", item = "it_magnificationlens" },
	{ affliction = "lt_night", item = "it_nightlens" },
	{ affliction = "lt_thermal", item = "it_thermallens" },
}

--define helper functions
--checks if targetCharacter has eyes
function HF.HasEyes(targetCharacter)
	return not HF.HasAffliction(targetCharacter, "sr_removedeyes")
		and not HF.HasAffliction(targetCharacter, "th_amputation")
		and not HF.HasAffliction(targetCharacter, "sh_amputation")
end

--removes all eye afflictions from the targetCharacter
function HF.NukeEyeAfflictions(targetCharacter)
	for key, affliction in pairs(NTEYE.Afflictions) do
		local afflictionName = tostring(key)
		targetCharacter.CharacterHealth.ReduceAfflictionOnAllLimbs(afflictionName, 1000)
	end
end

--gives item based on the eye affliction
function HF.GiveEyeItem(targetCharacter, usingCharacter)
	if not HF.HasEyes(targetCharacter) then
		return
	end

	for _, eye in ipairs(eyeProperty) do
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
						HF.GiveItemAtCondition(usingCharacter, eye.item, (100 - afflictionDamage * 2))
					end
				else
					if (usingCharacter ~= nil) and (eye.item ~= "") then
						--give two items
						HF.GiveItemAtCondition(usingCharacter, eye.item, (100 - afflictionDamage))
						HF.GiveItemAtCondition(usingCharacter, eye.item, (100 - afflictionDamage))
					end
				end
			end
		end
	end
end

--gives eye affliction based on item
function HF.ApplyEyeItem(targetCharacter, usingCharacter, item)
	local limb = LimbType.Head

	--eye application
	if --check if eye(s) removed, lid open
		(HF.HasAffliction(targetCharacter, "sr_removedeyes") or HF.HasAffliction(targetCharacter, "sr_removedeye"))
		and HF.HasAffliction(targetCharacter, "sr_heldlid", 99)
		and HF.HasAffliction(targetCharacter, "sr_eyeconnector", 99)
	then
		local skillrequired = 45

		--check for skill requirement
		if HF.GetSkillRequirementMet(usingCharacter, "medical", skillrequired) then
			for _, eye in ipairs(eyeProperty) do
				--check if right property in the table is selected
				if (item.Prefab.Identifier == eye.item) and not (item.Prefab.Identifier == "") then
					--get eye damage affliction strength
					local strength = (100 - item.Condition) / 2

					--check how many eyes target has
					--if one eye removed:
					if HF.HasAffliction(targetCharacter, "sr_removedeye") then
						--add single eye
						--check if eye affliction matches the item
						if HF.HasAffliction(targetCharacter, eye.type) then
							HF.SetAfflictionLimb(targetCharacter, "sr_removedeye", limb, 0, usingCharacter) --remove eye affliction
							HF.SetAfflictionLimb(targetCharacter, "sr_eyeconnector", limb, 0, usingCharacter) --remove eye connector affliction

							HF.SetAfflictionLimb(targetCharacter, eye.type, limb, 100, usingCharacter) --add eye indicator affliction
							HF.AddAfflictionLimb(targetCharacter, eye.damage, limb, strength, usingCharacter) --add eye damage affliction

							item.Condition = 0 --remove item
						else
							HF.SetAfflictionLimb(targetCharacter, "sr_removedeye", limb, 0, usingCharacter) --remove eye affliction
							HF.SetAfflictionLimb(targetCharacter, "sr_eyeconnector", limb, 0, usingCharacter) --remove eye connector affliction

							HF.SetAfflictionLimb(targetCharacter, "mc_mismatch", limb, 100, usingCharacter) --add mismatch affliction
							HF.SetAfflictionLimb(targetCharacter, eye.type, limb, 100, usingCharacter) --add eye affliction
							HF.AddAfflictionLimb(targetCharacter, eye.damage, limb, strength, usingCharacter) --add eye damage affliction

							item.Condition = 0 --remove item
						end
					else --if two eyes removed:
						if HF.HasAffliction(targetCharacter, "sr_removedeyes") then
							--add double eye
							HF.SetAfflictionLimb(targetCharacter, "sr_removedeyes", limb, 0, usingCharacter) --remove eye affliction
							HF.SetAfflictionLimb(targetCharacter, "sr_eyeconnector", limb, 0, usingCharacter) --remove eye connector affliction

							HF.SetAfflictionLimb(targetCharacter, "sr_removedeye", limb, 100, usingCharacter) --add eye affliction
							HF.SetAfflictionLimb(targetCharacter, eye.type, limb, 100, usingCharacter) --add eye affliction
							HF.AddAfflictionLimb(targetCharacter, eye.damage, limb, strength, usingCharacter) --add eye damage affliction

							item.Condition = 0 --remove item
						end
					end
				end
			end
		else
			item.Condition = item.Condition - 5 --damage eye item on fail
		end
	end
end

--gives lens item based on affliction
function HF.GiveLensItem(targetCharacter, usingCharacter)
	local limb = LimbType.Head
	for _, lens in ipairs(lensProperty) do
		if HF.HasAffliction(targetCharacter, lens.affliction) then
			HF.GiveItemAtCondition(usingCharacter, lens.item, 100)
		end
		HF.SetAfflictionLimb(targetCharacter, lens.affliction, limb, 0, usingCharacter)
	end
end

--gives lens affliction based on item
function HF.ApplyLensItem(targetCharacter, usingCharacter, item)
	local limb = LimbType.Head

	--lens application
	if --check if correct eyes are present, no mismatch, lid open, eyes popped
		HF.HasEyes(targetCharacter)
		and (HF.HasAffliction(targetCharacter, "vi_cyber") or HF.HasAffliction(targetCharacter, "vi_enhanced"))
		--and (not HF.HasAffliction(targetCharacter, "mc_mismatch")) --not sure if I should keep this or not
		and (
			HF.HasAffliction(targetCharacter, "sr_heldlid", 99)
			and HF.HasAffliction(targetCharacter, "sr_poppedeye", 99)
		)
	then
		for _, lens in ipairs(lensProperty) do
			--check if right property is selected
			if item.Prefab.Identifier == lens.item then
				HF.SetAfflictionLimb(targetCharacter, lens.affliction, limb, 100, usingCharacter)
				item.Condition = 0
			end
		end
	end
end

--overwrite NT functions to add usage (tried hooks, didn't work, let's hope this doesn't cause compatibility issues)

--skin retractors
local originaladvretractors = NT.ItemMethods.advretractors
NT.ItemMethods.advretractors = function(item, usingCharacter, targetCharacter, targetLimb)
	--call the original function
	if originaladvretractors then
		originaladvretractors(item, usingCharacter, targetCharacter, targetLimb)
	end
	local limb = LimbType.Head

	--check if the item is used on the head
	if targetLimb.type ~= limb then
		return
	end

	--check if targetCharacter has head
	if HF.HasAffliction(targetCharacter, "th_amputation") or HF.HasAffliction(targetCharacter, "sh_amputation") then
		return
	end

	--hold eye lids
	local skillrequired = 25

	--try to close lids first
	if HF.HasAffliction(targetCharacter, "sr_heldlid") then
		HF.SetAfflictionLimb(targetCharacter, "sr_heldlid", limb, 0, usingCharacter) --remove held lids
		HF.SetAfflictionLimb(targetCharacter, "sr_poppedeye", limb, 0, usingCharacter) --remove popped eyes
	else
		--check if surgery can be performed
		if not HF.CanPerformSurgeryOn(targetCharacter) then
			return
		end

		--check for skill requirement
		if HF.GetSkillRequirementMet(usingCharacter, "medical", skillrequired) then
			HF.SetAfflictionLimb(
				targetCharacter,
				"sr_heldlid",
				limb,
				1 + HF.GetSurgerySkill(usingCharacter) / 2,
				usingCharacter
			) --add removed eyes to patient
		else
			--cause bleeding if fail
			HF.AddAfflictionLimb(targetCharacter, "bleeding", limb, math.random(0, 7), usingCharacter)
			if --give eye damage on fail
				HF.HasEyes(targetCharacter)
			then
				for _, eye in ipairs(eyeProperty) do
					if HF.HasAffliction(targetCharacter, eye.type) then
						HF.AddAfflictionLimb(targetCharacter, eye.damage, limb, math.random(0, 3), usingCharacter)
					end
				end
			end
		end
	end
end

--tweezers
local originaltweezers = NT.ItemMethods.tweezers
NT.ItemMethods.tweezers = function(item, usingCharacter, targetCharacter, targetLimb)
	--call the original function
	if originaltweezers then
		originaltweezers(item, usingCharacter, targetCharacter, targetLimb)
	end
	local limb = LimbType.Head

	--check if the item is used on the head
	if targetLimb.type ~= limb then
		return
	end
	--check if surgery can be performed
	if not HF.CanPerformSurgeryOn(targetCharacter) then
		return
	end
	--check if targetCharacter has eyes
	if not HF.HasEyes(targetCharacter) then
		return
	end

	--pop eyes out
	if HF.HasAffliction(targetCharacter, "sr_heldlid", 99) then
		local skillrequired = 30

		--check for skill requirement
		if HF.GetSkillRequirementMet(usingCharacter, "medical", skillrequired) then
			HF.SetAfflictionLimb(
				targetCharacter,
				"sr_poppedeye",
				limb,
				1 + HF.GetSurgerySkill(usingCharacter) / 2,
				usingCharacter
			) --add removed eyes to patient
		else
			--cause bleeding and pain if fail
			HF.AddAfflictionLimb(targetCharacter, "severepain", limb, 50, usingCharacter)
			HF.AddAfflictionLimb(targetCharacter, "bleeding", limb, math.random(0, 10), usingCharacter)
			if --give eye damage on fail
				HF.HasEyes(targetCharacter)
			then
				for _, eye in ipairs(eyeProperty) do
					if HF.HasAffliction(targetCharacter, eye.type) then
						HF.AddAfflictionLimb(targetCharacter, eye.damage, limb, math.random(0, 5), usingCharacter)
					end
				end
			end
		end
	end
end

--needle
local originalneedle = NT.ItemMethods.needle
NT.ItemMethods.needle = function(item, usingCharacter, targetCharacter, targetLimb)
	---run the original function
	if originalneedle then
		originalneedle(item, usingCharacter, targetCharacter, targetLimb)
	end
	local limb = LimbType.Head
	--check if the item is used on the head
	if targetLimb.type ~= limb then
		return
	end
	--check if surgery can be performed
	if not HF.CanPerformSurgeryOn(targetCharacter) then
		return
	end
	--check if target has eyes
	if not HF.HasEyes(targetCharacter) then
		return
	end

	--emulsification
	if
		HF.HasAffliction(targetCharacter, "sr_heldlid", 99)
		and HF.HasAffliction(targetCharacter, "sr_corneaincision", 99)
		and not HF.HasAffliction(targetCharacter, "sr_poppedeye", 99)
	then
		local skillrequired = 50
		if HF.GetSkillRequirementMet(usingCharacter, "medical", skillrequired) then
			HF.AddAfflictionLimb(
				targetCharacter,
				"sr_emulsification",
				limb,
				1 + HF.GetSurgerySkill(usingCharacter) / 2,
				usingCharacter
			) --add emulsification
		else
			if --give eye damage on fail
				HF.HasEyes(targetCharacter)
			then
				for _, eye in ipairs(eyeProperty) do
					if HF.HasAffliction(targetCharacter, eye.type) then
						HF.AddAfflictionLimb(targetCharacter, eye.damage, limb, math.random(0, 7), usingCharacter)
					end
				end
			end
		end
	end
end

--eye organscalpel
NT.ItemMethods.it_scalpel_eye = function(item, usingCharacter, targetCharacter, targetLimb)
	local limb = LimbType.Head

	--check if the item is used on the head
	if targetLimb.type ~= limb then
		return
	end
	--check if surgery can be performed
	if not HF.CanPerformSurgeryOn(targetCharacter) then
		return
	end

	--eye removal
	if
		HF.HasAffliction(targetCharacter, "sr_poppedeye", 99) and HF.HasAffliction(targetCharacter, "sr_heldlid", 99)
	then
		local skillrequired = 45
		--check for skill requirement
		if HF.GetSkillRequirementMet(usingCharacter, "medical", skillrequired) then
			--remove dead eye if there is one first
			if HF.HasAffliction(targetCharacter, "mc_deadeye") then
				HF.AddAfflictionLimb(targetCharacter, "mc_deadeye", limb, -100, usingCharacter) --remove dead eye
				HF.AddAfflictionLimb(targetCharacter, "sr_removedeye", limb, 100, usingCharacter) --add removed eye
				return --exit if dead eye is removed
			end
			HF.GiveEyeItem(targetCharacter, usingCharacter) --give eye items to usingCharacter
			HF.NukeEyeAfflictions(targetCharacter) --remove all eye afflictions from patient

			HF.SetAfflictionLimb(targetCharacter, "sr_removedeyes", limb, 100, usingCharacter) --add removed eyes to patient
			HF.SetAfflictionLimb(targetCharacter, "sr_heldlid", limb, 100, usingCharacter) --revert held lids removal
			HF.SetAfflictionLimb(targetCharacter, "sr_poppedeye", limb, 100, usingCharacter) --revert popped eyes removal
		else
			--cause bleeding and pain if fail
			HF.AddAfflictionLimb(targetCharacter, "severepain", limb, 100, usingCharacter)
			HF.AddAfflictionLimb(targetCharacter, "bleeding", limb, math.random(0, 25), usingCharacter)
			if --give eye damage on fail
				HF.HasEyes(targetCharacter)
			then
				for _, eye in ipairs(eyeProperty) do
					if HF.HasAffliction(targetCharacter, eye.type) then
						HF.AddAfflictionLimb(targetCharacter, eye.damage, limb, math.random(0, 15), usingCharacter)
					end
				end
			end
		end
	end

	--cornea incision
	if HF.HasAffliction(targetCharacter, "sr_heldlid") and not HF.HasAffliction(targetCharacter, "sr_poppedeye") then
		local skillrequired = 50
		if HF.GetSkillRequirementMet(usingCharacter, "medical", skillrequired) then
			HF.AddAfflictionLimb(
				targetCharacter,
				"sr_corneaincision",
				1 + HF.GetSurgerySkill(usingCharacter) / 2,
				usingCharacter
			) --add cornea incision
		else
			if --give eye damage on fail
				HF.HasEyes(targetCharacter)
			then
				for _, eye in ipairs(eyeProperty) do
					if HF.HasAffliction(targetCharacter, eye.type) then
						HF.AddAfflictionLimb(targetCharacter, eye.damage, limb, math.random(0, 15))
					end
				end
			end
		end
	end
end

--organic lens
NT.ItemMethods.it_organiclens = function(item, usingCharacter, targetCharacter, targetLimb)
	local limb = LimbType.Head
	--check if the item is used on the head
	if targetLimb.type ~= limb then
		return
	end
	--check if surgery can be performed
	if not HF.CanPerformSurgeryOn(targetCharacter) then
		return
	end
	--check if target has eyes
	if not HF.HasEyes(targetCharacter) then
		return
	end

	--organic lens application
	if
		HF.HasAffliction(targetCharacter, "sr_corneaincision", 99)
		and HF.HasAffliction(targetCharacter, "sr_emulsification", 99)
		and HF.HasAffliction(targetCharacter, "sr_heldlid", 99)
		and not HF.HasAffliction(targetCharacter, "sr_poppedeye", 99)
	then
		HF.AddAfflictionLimb(targetCharacter, "mc_cataract", limb, -100, usingCharacter) --remove cataracts
		HF.AddAfflictionLimb(targetCharacter, "sr_emulsification", limb, -100, usingCharacter) --remove emulsification
		HF.AddAfflictionLimb(targetCharacter, "sr_corneaincision", limb, -100, usingCharacter) --remove cornea incision
		item.Condition = 0 --remove item
	end
end

--lens removal
local originalscrewdriver = NT.ItemMethods.screwdriver
NT.ItemMethods.screwdriver = function(item, usingCharacter, targetCharacter, targetLimb)
	--call the original function
	if originalscrewdriver then
		originalscrewdriver(item, usingCharacter, targetCharacter, targetLimb)
	end

	local limb = LimbType.Head

	--check if the item is used on the head
	if targetLimb.type ~= limb then
		return
	end
	--check if surgery can be performed
	if not HF.CanPerformSurgeryOn(targetCharacter) then
		return
	end

	--lens removal
	if
		HF.HasAffliction(targetCharacter, "sr_poppedeye", 99) and HF.HasAffliction(targetCharacter, "sr_heldlid", 99)
	then
		local skillrequired = 40
		--check for skill requirement
		if HF.GetSkillRequirementMet(usingCharacter, "medical", skillrequired) then
			HF.GiveLensItem(targetCharacter, usingCharacter)
		else
			--cause bleeding and pain if fail
			HF.AddAfflictionLimb(targetCharacter, "severepain", limb, 100, usingCharacter)
			HF.AddAfflictionLimb(targetCharacter, "bleeding", limb, math.random(0, 5), usingCharacter)
			if --give eye damage on fail
				HF.HasEyes(targetCharacter)
			then
				if --give eye damage on fail
					HF.HasEyes(targetCharacter)
				then
					for _, eye in ipairs(eyeProperty) do
						if HF.HasAffliction(targetCharacter, eye.type) then
							HF.AddAfflictionLimb(targetCharacter, eye.damage, limb, math.random(0, 7), usingCharacter)
						end
					end
				end
			end
		end
	end
end

--cyber lens removal
NT.ItemMethods.screwdriverdementonite = function(item, usingCharacter, targetCharacter, targetLimb)
	NT.ItemMethods.screwdriver(item, usingCharacter, targetCharacter, targetLimb)
end

--cyber lens removal
NT.ItemMethods.screwdriverhardened = function(item, usingCharacter, targetCharacter, targetLimb)
	NT.ItemMethods.screwdriver(item, usingCharacter, targetCharacter, targetLimb)
end

--cyber lens removal
NT.ItemMethods.repairpack = function(item, usingCharacter, targetCharacter, targetLimb)
	NT.ItemMethods.screwdriver(item, usingCharacter, targetCharacter, targetLimb)
end

--eye connectors
NT.ItemMethods.it_eyeconnector = function(item, usingCharacter, targetCharacter, targetLimb)
	local limb = LimbType.Head
	--check if the item is used on the head
	if targetLimb.type ~= limb then
		return
	end
	--check if surgery can be performed
	if not HF.CanPerformSurgeryOn(targetCharacter) then
		return
	end

	--application
	if --check if eye(s) removed, lid open
		(HF.HasAffliction(targetCharacter, "sr_removedeyes") or HF.HasAffliction(targetCharacter, "sr_removedeye"))
		and HF.HasAffliction(targetCharacter, "sr_heldlid")
	then
		local skillrequired = 45
		--check for skill requirement
		if HF.GetSkillRequirementMet(usingCharacter, "medical", skillrequired) then
			--apply connector
			HF.SetAfflictionLimb(
				targetCharacter,
				"sr_eyeconnector",
				limb,
				1 + HF.GetSurgerySkill(usingCharacter) / 2,
				usingCharacter
			)
			item.Condition = 0 --remove item
		else --cause pain on fail
			HF.AddAfflictionLimb(targetCharacter, "severepain", limb, 10)
		end
	end
end

--human eye
NT.ItemMethods.it_humaneye = function(item, usingCharacter, targetCharacter, targetLimb)
	local limb = LimbType.Head
	--check if the item is used on the head
	if targetLimb.type ~= limb then
		return
	end
	--check if surgery can be performed
	if not HF.CanPerformSurgeryOn(targetCharacter) then
		return
	end

	--give eye affliction
	HF.ApplyEyeItem(targetCharacter, usingCharacter, item)
end
--plastic eye
NT.ItemMethods.it_plasticeye = function(item, usingCharacter, targetCharacter, targetLimb)
	local limb = LimbType.Head
	--check if the item is used on the head
	if targetLimb.type ~= limb then
		return
	end
	--check if surgery can be performed
	if not HF.CanPerformSurgeryOn(targetCharacter) then
		return
	end

	--give eye affliction
	HF.ApplyEyeItem(targetCharacter, usingCharacter, item)
end
--enhanced eye
NT.ItemMethods.it_enhancedeye = function(item, usingCharacter, targetCharacter, targetLimb)
	local limb = LimbType.Head
	--check if the item is used on the head
	if targetLimb.type ~= limb then
		return
	end
	--check if surgery can be performed
	if not HF.CanPerformSurgeryOn(targetCharacter) then
		return
	end

	--give eye affliction
	HF.ApplyEyeItem(targetCharacter, usingCharacter, item)
end
--cyber eye
NT.ItemMethods.it_cybereye = function(item, usingCharacter, targetCharacter, targetLimb)
	local limb = LimbType.Head
	--check if the item is used on the head
	if targetLimb.type ~= limb then
		return
	end
	--check if surgery can be performed
	if not HF.CanPerformSurgeryOn(targetCharacter) then
		return
	end

	--give eye affliction
	HF.ApplyEyeItem(targetCharacter, usingCharacter, item)
end
--crawler eye
NT.ItemMethods.it_crawlereye = function(item, usingCharacter, targetCharacter, targetLimb)
	local limb = LimbType.Head
	--check if the item is used on the head
	if targetLimb.type ~= limb then
		return
	end
	--check if surgery can be performed
	if not HF.CanPerformSurgeryOn(targetCharacter) then
		return
	end

	--give eye affliction
	HF.ApplyEyeItem(targetCharacter, usingCharacter, item)
end
--mudraptor eye
NT.ItemMethods.it_mudraptoreye = function(item, usingCharacter, targetCharacter, targetLimb)
	local limb = LimbType.Head
	--check if the item is used on the head
	if targetLimb.type ~= limb then
		return
	end
	--check if surgery can be performed
	if not HF.CanPerformSurgeryOn(targetCharacter) then
		return
	end

	--give eye affliction
	HF.ApplyEyeItem(targetCharacter, usingCharacter, item)
end
--huskified eye
NT.ItemMethods.it_huskifiedeye = function(item, usingCharacter, targetCharacter, targetLimb)
	local limb = LimbType.Head
	--check if the item is used on the head
	if targetLimb.type ~= limb then
		return
	end
	--check if surgery can be performed
	if not HF.CanPerformSurgeryOn(targetCharacter) then
		return
	end

	--give eye affliction
	HF.ApplyEyeItem(targetCharacter, usingCharacter, item)
end
--watcher eye
NT.ItemMethods.it_watchereye = function(item, usingCharacter, targetCharacter, targetLimb)
	local limb = LimbType.Head
	--check if the item is used on the head
	if targetLimb.type ~= limb then
		return
	end
	--check if surgery can be performed
	if not HF.CanPerformSurgeryOn(targetCharacter) then
		return
	end

	--give eye affliction
	HF.ApplyEyeItem(targetCharacter, usingCharacter, item)
end
--charybdis eye
NT.ItemMethods.it_charybdiseye = function(item, usingCharacter, targetCharacter, targetLimb)
	local limb = LimbType.Head
	--check if the item is used on the head
	if targetLimb.type ~= limb then
		return
	end
	--check if surgery can be performed
	if not HF.CanPerformSurgeryOn(targetCharacter) then
		return
	end

	--give eye affliction
	HF.ApplyEyeItem(targetCharacter, usingCharacter, item)
end
--latcher eye
NT.ItemMethods.it_latchereye = function(item, usingCharacter, targetCharacter, targetLimb)
	local limb = LimbType.Head
	--check if the item is used on the head
	if targetLimb.type ~= limb then
		return
	end
	--check if surgery can be performed
	if not HF.CanPerformSurgeryOn(targetCharacter) then
		return
	end

	--give eye affliction
	HF.ApplyEyeItem(targetCharacter, usingCharacter, item)
end
--terror eye
NT.ItemMethods.it_terroreye = function(item, usingCharacter, targetCharacter, targetLimb)
	local limb = LimbType.Head
	--check if the item is used on the head
	if targetLimb.type ~= limb then
		return
	end
	--check if surgery can be performed
	if not HF.CanPerformSurgeryOn(targetCharacter) then
		return
	end

	--give eye affliction
	HF.ApplyEyeItem(targetCharacter, usingCharacter, item)
end

--cyber/enhanced eye lenses
--medical lens
NT.ItemMethods.it_medicallens = function(item, usingCharacter, targetCharacter, targetLimb)
	local limb = LimbType.Head
	HF.ApplyLensItem(targetCharacter, usingCharacter, item)
end
--electrical lens
NT.ItemMethods.it_electricallens = function(item, usingCharacter, targetCharacter, targetLimb)
	local limb = LimbType.Head
	HF.ApplyLensItem(targetCharacter, usingCharacter, item)
end
--magnification lens
NT.ItemMethods.it_magnificationlens = function(item, usingCharacter, targetCharacter, targetLimb)
	local limb = LimbType.Head
	HF.ApplyLensItem(targetCharacter, usingCharacter, item)
end
--nightvision lens
NT.ItemMethods.it_nightlens = function(item, usingCharacter, targetCharacter, targetLimb)
	local limb = LimbType.Head
	HF.ApplyLensItem(targetCharacter, usingCharacter, item)
end
NT.ItemMethods.it_thermallens = function(item, usingCharacter, targetCharacter, targetLimb)
	local limb = LimbType.Head
	HF.ApplyLensItem(targetCharacter, usingCharacter, item)
end

--eye drop
NT.ItemMethods.it_eyedrop = function(item, usingCharacter, targetCharacter, targetLimb)
	local limb = LimbType.Head
	--check if the item is used on the head
	if targetLimb.type ~= LimbType.Head then
		return
	end
	--check if character has eyes
	if not HF.HasEyes(targetCharacter) then
		return
	end
	--give affliction if able
	if not HF.HasAffliction(targetCharacter, "vi_cyber") and not HF.HasAffliction(targetCharacter, "vi_plastic") then
		HF.AddAfflictionLimb(targetCharacter, "sr_eyedrops", limb, 100)
		item.Condition = item.Condition - 25 --remove item condition
	end
end

--[[ this will have a different execution system
--The Spoon
NT.ItemMethods.it_spoon = function(item, usingCharacter, targetCharacter, targetLimb)
	local limb = LimbType.Head
end 
]]

--cyber eye repair
originalfpgacircuit = NT.ItemMethods.fpgacircuit
NT.ItemMethods.fpgacircuit = function(item, usingCharacter, targetCharacter, targetLimb)
	--call the original function
	if originalfpgacircuit then
		originalfpgacircuit(item, usingCharacter, targetCharacter, targetLimb)
	end
	local limb = LimbType.Head

	-- check if the item is used on the head
	if targetLimb.type ~= limb then
		return
	end

	-- check if surgery can be performed
	if not HF.CanPerformSurgeryOn(targetCharacter) then
		return
	end

	-- check if target has held lid, popped eye, cyber eye
	if
		HF.HasAffliction(targetCharacter, "vi_cyber")
		and (
			HF.HasAffliction(targetCharacter, "sr_heldlid", 99)
			and HF.HasAffliction(targetCharacter, "sr_poppedeye", 99)
		)
	then
		if --if target has 1 cyber eye
			HF.HasAffliction(targetCharacter, "sr_removedeye")
			or HF.HasAffliction(targetCharacter, "mc_deadeye")
			or HF.HasAffliction(targetCharacter, "mc_mismatch")
		then
			HF.AddAfflictionLimb(targetCharacter, "dm_cyber", limb, -(item.Condition / 2.5), usingCharacter) --reduce eye damage
			item.Condition = 0 --remove item
		else --if target has 2 cyber eyes
			HF.AddAfflictionLimb(targetCharacter, "dm_cyber", limb, -(item.Condition / 5), usingCharacter) --reduce eye damage
			item.Condition = 0 --remove item
		end
	end
end

--Laser Surgery Tool
NT.ItemMethods.it_lasersurgerytool = function(item, usingCharacter, targetCharacter, targetLimb)
	local limb = LimbType.Head
end

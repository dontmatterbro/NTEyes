--table to define eye afflictions/items
local eyeProperty = {
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

--define helper functions
--checks if targetCharacter has eyes
function HF.HasEyes(targetCharacter)
	if
		not HF.HasAffliction(targetCharacter, "sr_removedeyes")
		and not HF.HasAffliction(targetCharacter, "th_amputation")
		and not HF.HasAffliction(targetCharacter, "sh_amputation")
	then
		return true
	else
		return false
	end
end

--removes all eye afflictions from the targetCharacter
function HF.NukeEyeAfflictions(targetCharacter)
	for _, affliction in ipairs(NTEYE.Afflictions) do
		targetCharacter.CharacterHealth.ReduceAfflictionOnAllLimbs(affliction, 1000)
	end
end

--gives item based on the eye affliction
function HF.GiveEyeItem(targetCharacter, usingCharacter)
	if not HF.HasEyes(targetCharacter) then
		return
	end

	for _, eye in ipairs(eyeProperty) do
		if HF.HasAffliction(targetCharacter, eye.type) then
			local damage = HF.GetAfflictionStrength(targetCharacter, eye.damage, 0)
			if
				HF.HasAffliction(targetCharacter, "sr_removedeye")
				or HF.HasAffliction(targetCharacter, "mc_deadeye")
				or HF.HasAffliction(targetCharacter, "mc_mismatch")
			then
				if (usingCharacter ~= nil) and (eye.item ~= "") then
					--give one item
					HF.GiveItemAtCondition(usingCharacter, eye.item, 100 - damage * 2)
				end
			else
				if (usingCharacter ~= nil) and (eye.item ~= "") then
					--give two items
					HF.GiveItemAtCondition(usingCharacter, eye.item, 100 - damage / 2)
					HF.GiveItemAtCondition(usingCharacter, eye.item, 100 - damage / 2)
				end
			end
		end
	end
end

--gives eye affliction based on item
function HF.GiveEyeAffliction(targetCharacter, usingCharacter, item)
	--application
	if --check if eye(s) removed, lid open
		(HF.HasAffliction(targetCharacter, "sr_removedeyes") or HF.HasAffliction(targetCharacter, "sr_removedeye"))
		and HF.HasAffliction(targetCharacter, "sr_heldlid")
		and HF.HasAffliction(targetCharacter, "sr_eyeconnector")
	then
		local skillrequired = 45

		--check for skill requirement
		if HF.GetSkillRequirementMet(usingCharacter, "medical", skillrequired) then
			for _, eye in ipairs(eyeProperty) do
				if (item.Prefab.Identifier ~= eye.item) and not (item.Prefab.Identifier == "") then
					return
				end

				--get eye damage affliction strength
				local damage = HF.GetAfflictionStrength(targetCharacter, eye.damage, 0)

				--check how many eyes target has
				--if one eye removed:
				if HF.HasAffliction(targetCharacter, "sr_removedeye") then
					--add single eye
					--check if eye affliction matches the item
					if HF.HasAffliction(targetCharacter, eye.type) then
						HF.SetAfflictionLimb(targetCharacter, "sr_removedeye", LimbType.Head, 0, usingCharacter) --remove eye affliction
						HF.SetAfflictionLimb(targetCharacter, "sr_eyeconnector", LimbType.Head, 0, usingCharacter) --remove eye connector affliction

						HF.SetAfflictionLimb(targetCharacter, eye.type, LimbType.Head, 100, usingCharacter) --add eye indicator affliction
						HF.SetAfflictionLimb(targetCharacter, eye.damage, LimbType.Head, damage, usingCharacter) --add eye damage affliction

						eye.item.Condition = 0 --remove item
					else
						HF.SetAfflictionLimb(targetCharacter, "sr_removedeye", LimbType.Head, 0, usingCharacter) --remove eye affliction
						HF.SetAfflictionLimb(targetCharacter, "sr_eyeconnector", LimbType.Head, 0, usingCharacter) --remove eye connector affliction

						HF.SetAfflictionLimb(targetCharacter, "mc_mismatch", LimbType.Head, 100, usingCharacter) --add mismatch affliction
						HF.SetAfflictionLimb(targetCharacter, eye.type, LimbType.Head, 100, usingCharacter) --add eye affliction
						HF.SetAfflictionLimb(targetCharacter, eye.damage, LimbType.Head, damage, usingCharacter) --add eye damage affliction

						eye.item.Condition = 0 --remove item
					end
				else --if two eyes removed:
					if HF.HasAffliction(targetCharacter, "sr_removedeyes") then
						--add double eye
						HF.SetAfflictionLimb(targetCharacter, "sr_removedeyes", LimbType.Head, 0, usingCharacter) --remove eye affliction
						HF.SetAfflictionLimb(targetCharacter, "sr_eyeconnector", LimbType.Head, 0, usingCharacter) --remove eye connector affliction

						HF.SetAfflictionLimb(targetCharacter, "sr_removedeye", LimbType.Head, 100, usingCharacter) --add eye affliction
						HF.SetAfflictionLimb(targetCharacter, eye.type, LimbType.Head, 100, usingCharacter) --add eye affliction

						eye.item.Condition = 0 --remove item
					end
				end
			end
		else
			eye.item.Condition = eye.item.Condition - 5 --damage eye item on fail
		end
	end
end

--overwrite NT functions to add usage (tried hooks, didn't work, let's hope this doesn't cause compatibility issues)

--Skin Retractors
local originaladvretractors = NT.ItemMethods.advretractors
NT.ItemMethods.advretractors = function(item, usingCharacter, targetCharacter, limb)
	--call the original function
	if originaladvretractors then
		originaladvretractors(item, usingCharacter, targetCharacter, limb)
	end

	--check if the item is used on the head
	if limb.type ~= LimbType.Head then
		return
	end
	--check if surgery can be performed
	if not HF.CanPerformSurgeryOn(targetCharacter) then
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
		HF.SetAfflictionLimb(targetCharacter, "sr_heldlid", LimbType.Head, 0, usingCharacter) --add removed eyes to patient
		HF.SetAfflictionLimb(targetCharacter, "sr_poppedeye", LimbType.Head, 0, usingCharacter) --add removed eyes to patient
	else
		--check for skill requirement
		if HF.GetSkillRequirementMet(usingCharacter, "medical", skillrequired) then
			HF.SetAfflictionLimb(targetCharacter, "sr_heldlid", LimbType.Head, 100, usingCharacter) --add removed eyes to patient
		else
			--cause bleeding if fail
			HF.AddAfflictionLimb(targetCharacter, "bleeding", LimbType.Head, math.random(0, 7))
			if --give eye damage on fail
				HF.HasEyes(targetCharacter)
			then
				HF.AddAfflictionLimb(targetCharacter, "mc_eyedamage", LimbType.Head, math.random(0, 3))
			end
		end
	end
end

--tweezers
local originaltweezers = NT.ItemMethods.tweezers
NT.ItemMethods.tweezers = function(item, usingCharacter, targetCharacter, limb)
	--call the original function
	if originaltweezers then
		originaltweezers(item, usingCharacter, targetCharacter, limb)
	end

	--check if the item is used on the head
	if limb.type ~= LimbType.Head then
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
	if HF.HasAffliction(targetCharacter, "sr_heldlid") then
		local skillrequired = 30

		--check for skill requirement
		if HF.GetSkillRequirementMet(usingCharacter, "medical", skillrequired) then
			HF.SetAfflictionLimb(targetCharacter, "sr_poppedeye", LimbType.Head, 100, usingCharacter) --add removed eyes to patient
		else
			--cause bleeding and pain if fail
			HF.AddAfflictionLimb(targetCharacter, "severepain", LimbType.Head, 50)
			HF.AddAfflictionLimb(targetCharacter, "bleeding", LimbType.Head, math.random(0, 10))
			if --give eye damage on fail
				HF.HasEyes(targetCharacter)
			then
				HF.AddAfflictionLimb(targetCharacter, "mc_eyedamage", LimbType.Head, math.random(0, 5))
			end
		end
	end
end

--organscalpel (placeholder item name, change this)
NT.ItemMethods.it_scalpel_eye = function(item, usingCharacter, targetCharacter, limb)
	--check if the item is used on the head
	if limb.type ~= LimbType.Head then
		return
	end
	--check if surgery can be performed
	if not HF.CanPerformSurgeryOn(targetCharacter) then
		return
	end

	--eye removal
	if HF.HasAffliction(targetCharacter, "sr_poppedeye") and HF.HasAffliction(targetCharacter, "sr_heldlid") then
		local skillrequired = 45

		--check for skill requirement
		if HF.GetSkillRequirementMet(usingCharacter, "medical", skillrequired) then
			HF.GiveEyeItem(targetCharacter, usingCharacter) --give eye items to usingCharacter
			HF.NukeEyeAfflictions(targetCharacter) --remove all eye afflictions from patient
			HF.SetAfflictionLimb(targetCharacter, "sr_removedeyes", LimbType.Head, 100, usingCharacter) --add removed eyes to patient
		else
			--cause bleeding and pain if fail
			HF.AddAfflictionLimb(targetCharacter, "severepain", LimbType.Head, 100)
			HF.AddAfflictionLimb(targetCharacter, "bleeding", LimbType.Head, math.random(0, 25))
			if --give eye damage on fail
				HF.HasEyes(targetCharacter)
			then
				HF.AddAfflictionLimb(targetCharacter, "mc_eyedamage", LimbType.Head, math.random(0, 20))
			end
		end
	end
end

--eye connectors
NT.ItemMethods.it_eyeconnector = function(item, usingCharacter, targetCharacter, limb)
	--check if the item is used on the head
	if limb.type ~= LimbType.Head then
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
			HF.SetAfflictionLimb(targetCharacter, "sr_eyeconnector", LimbType.Head, 100, usingCharacter)
			item.Condition = 0 --remove item
		else --cause pain on fail
			HF.AddAfflictionLimb(targetCharacter, "severepain", LimbType.Head, 10)
		end
	end
end

--human eye
NT.ItemMethods.it_humaneye = function(item, usingCharacter, targetCharacter, limb)
	--check if the item is used on the head
	if limb.type ~= LimbType.Head then
		return
	end
	--check if surgery can be performed
	if not HF.CanPerformSurgeryOn(targetCharacter) then
		return
	end

	--give eye affliction
	HF.GiveEyeAffliction(targetCharacter, usingCharacter, item)
end
--plastic eye
NT.ItemMethods.it_plasticeye = function(item, usingCharacter, targetCharacter, limb) end
--enhanced eye
NT.ItemMethods.it_enhancedeye = function(item, usingCharacter, targetCharacter, limb) end
--cyber eye
NT.ItemMethods.it_cybereye = function(item, usingCharacter, targetCharacter, limb) end
--crawler eye
NT.ItemMethods.it_crawlereye = function(item, usingCharacter, targetCharacter, limb) end
--mudraptor eye
NT.ItemMethods.it_mudraptoreye = function(item, usingCharacter, targetCharacter, limb) end
--huskified eye
NT.ItemMethods.it_huskifiedeye = function(item, usingCharacter, targetCharacter, limb) end
--watcher eye
NT.ItemMethods.it_watchereye = function(item, usingCharacter, targetCharacter, limb) end
--charybdis eye
NT.ItemMethods.it_charybdiseye = function(item, usingCharacter, targetCharacter, limb) end
--latcher eye
NT.ItemMethods.it_latchereye = function(item, usingCharacter, targetCharacter, limb) end
--terror eye
NT.ItemMethods.it_terroreye = function(item, usingCharacter, targetCharacter, limb) end

--eye lenses
--organic lens
NT.ItemMethods.it_organiclens = function(item, usingCharacter, targetCharacter, limb) end
--medical lens
NT.ItemMethods.it_medicallens = function(item, usingCharacter, targetCharacter, limb) end
--electrical lens
NT.ItemMethods.it_electricallens = function(item, usingCharacter, targetCharacter, limb) end
--magnification lens
NT.ItemMethods.it_magnificationlens = function(item, usingCharacter, targetCharacter, limb) end
--nightvision lens
NT.ItemMethods.it_nightvisionlens = function(item, usingCharacter, targetCharacter, limb) end

--eye drop
NT.ItemMethods.it_eyedrop = function(item, usingCharacter, targetCharacter, limb) end

--deusizine drop
NT.ItemMethods.it_deusizinedrop = function(item, usingCharacter, targetCharacter, limb) end

--The Spoon
NT.ItemMethods.it_spoon = function(item, usingCharacter, targetCharacter, limb) end

--Laser Surgery Tool
NT.ItemMethods.it_lasersurgerytool = function(item, usingCharacter, targetCharacter, limb) end

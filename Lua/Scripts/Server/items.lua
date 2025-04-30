--define local functions
--checks if the eyes are alive
local function HasEyes(c)
	if not HF.HasAffliction(c, "sr_removedeyes") or not HF.HasAffliction(c, "mc_deadeyes") then
		return true
	else
		return false
	end
end

--write function for eye removal
local function EyeRemoval(c, user)
	if not HasEyes(c) then
		return
	end

	--I am finally optimizing my code UwU
	local eyeAfflictions = {
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
	}

	for _, eye in ipairs(eyeAfflictions) do
		if HF.HasAffliction(c, eye.type) then
			local damage = HF.GetAfflictionStrength(c, eye.damage, 0)

			if
				HF.HasAffliction(c, "sr_removedeye")
				or HF.HasAffliction(c, "mc_deadeye")
				or HF.HasAffliction(c, "mc_mismatch")
			then
				HF.GiveItemAtCondition(user, eye.item, 100 - damage)
			else
				HF.GiveItemAtCondition(user, eye.item, 100 - damage / 2)
				HF.GiveItemAtCondition(user, eye.item, 100 - damage / 2)
			end
		end
	end
end

--use hooks to prevent compatibility issues
--Skin Retractors
Hook.Add(
	"NT.ItemMethods.advretractors",
	"NTEYE.ItemMethods.AdvRetractors",
	function(item, usingCharacter, targetCharacter, limb) end
)

--tweezers
Hook.Add(
	"NT.ItemMethods.tweezers",
	"NTEYE.ItemMethods.tweezers",
	function(item, usingCharacter, targetCharacter, limb) end
)

--dont forget to add the rest

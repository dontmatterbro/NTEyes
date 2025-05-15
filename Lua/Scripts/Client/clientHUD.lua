--variables to set HUD values
NTEYE.HUDEnabled = false
NTEYE.DrawnHUD = nil
NTEYE.DisableHoverTextHUD = false

-- there will be a table this time instead of individual variables
NTEYE.HUDValues = {
	thermal = {
		active = false,
		item = nil,
		itemPrefab = "misc_thermalhud",
		affliction = "lt_thermal",
	},
	medical = {
		active = false,
		item = nil,
		itemPrefab = "misc_medicalhud",
		affliction = "lt_medical",
	},
	electrical = {
		active = false,
		item = nil,
		itemPrefab = "misc_electricalhud",
		affliction = "lt_electrical",
	},
}

function NTEYE.WriteHUD()
	for _, hud in pairs(NTEYE.HUDValues) do
		if HF.HasAffliction(Character.Controlled, hud.affliction) then
			if NTEYE.DrawnHUD == nil then
				if hud.item == nil or hud.item.Removed then
					NTEYE.ResetHUDValues()
					NTEYE.GetHUDItemValues()
					NTEYE.SendItemSpawnRequest()
					return
				end
				hud.active = true
				hud.item.Equip(Character.Controlled)
				NTEYE.DrawnHUD = hud.item.GetComponentString("StatusHUD") --get hud component
				NTEYE.HUDEnabled = true

				--check to disable hover text if medical hud
				if hud.affliction == "lt_medical" then
					NTEYE.DisableHoverTextHUD = true
				end

				return
			end
		else
			NTEYE.DisableHUDs() --if you implement multiple huds at the same time this will cause issues
		end
	end
end

--get the item values for the HUDs
function NTEYE.GetHUDItemValues()
	for item in Item.ItemList do
		for _, hud in pairs(NTEYE.HUDValues) do
			if item.Prefab.Identifier == hud.itemPrefab then
				hud.item = item
			end
		end
	end
end

function NTEYE.DisableHUDs()
	for _, hud in pairs(NTEYE.HUDValues) do
		if hud.active then
			if hud.item then
				hud.item.Unequip(Character.Controlled)
			end
			hud.active = false
			if hud.affliction == "lt_medical" then
				NTEYE.DisableHoverTextHUD = false
			end
			NTEYE.DrawnHUD = nil
			NTEYE.HUDEnabled = false
		end
	end
end

--sends a request for HUD items to spawn in case lua fucks up
function NTEYE.SendItemSpawnRequest()
	if not Game.IsMultiplayer then
		NTEYE.SpawnHUDItems()
		return
	end --singleplayer comp

	local message = Networking.Start("NTEYE.ItemSpawnRequest")

	message.WriteString("")

	Networking.Send(message)
end

--resets HUD values to prevent bugs
function NTEYE.ResetHUDValues()
	for _, hud in pairs(NTEYE.HUDValues) do
		hud.active = false
		hud.item = nil
		NTEYE.DrawnHUD = nil
		NTEYE.HUDEnabled = false
		NTEYE.DisableHoverTextHUD = false
	end
end

--resets hud parameters for client when character changes (for MCM and singleplayer)
Hook.Patch("Barotrauma.Character", "set_Controlled", function(instance, ptable)
	--disables all HUDs
	for _, hud in pairs(NTEYE.HUDValues) do
		hud.active = false
	end
	--sets the global variable to false
	NTEYE.HUDEnabled = false
	NTEYE.DrawnHUD = nil

	NTEYE.DisableHoverTextHUD = false
end)

--deletes duplicate player text from medical hud
Hook.Patch("Barotrauma.CharacterHUD", "DrawCharacterHoverTexts", function(instance, ptable)
	ptable.PreventExecution = NTEYE.DisableHoverTextHUD
	return nil
end, Hook.HookMethodType.Before)

--draws the written eye huds
Hook.Patch("Barotrauma.CharacterHUD", "Draw", function(instance, ptable)
	if NTEYE.DrawnHUD == nil then
		return
	end
	NTEYE.DrawnHUD.DrawHUD(ptable["spriteBatch"], Character.Controlled) --draws the huds
end)

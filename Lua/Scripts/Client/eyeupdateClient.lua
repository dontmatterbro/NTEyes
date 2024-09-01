--timer values
NTEYE.ClientUpdateCooldown = 0
NTEYE.ClientUpdateInterval = 120

--HUD values
local thermalHUDActive = nil
local medicalHUDActive = nil
local electricalHUDActive = nil
local eyeHUD = nil
local DisableHoverTextHUD = false

DeactivatedHUDs = nil --global - used by clientControls.lua

--item values
local eyethermalHUDitem=nil
local eyemedicalHUDitem=nil
local eyeelectricalHUDitem=nil


-- updates client effects every 0.5 seconds, this will be configurable once modding tool kit releases
Hook.Add("think", "NTEYE.updatetriggerclient", function()

    if HF.GameIsPaused() or (not Level.Loaded) then return end
	
    NTEYE.ClientUpdateCooldown = NTEYE.ClientUpdateCooldown-4
	
    if (NTEYE.ClientUpdateCooldown <= 0) then
        NTEYE.ClientUpdateCooldown = NTEYE.ClientUpdateInterval
        NTEYE.UpdateHumanEyeEffect()
    end
	
end)


--resets hud parameters at the start of the round
Hook.Add("roundStart", "NTEYE.resetHUDvalues", function()

	--HUD values
	thermalHUDActive = nil
	medicalHUDActive = nil
	electricalHUDActive = nil
	eyeHUD = nil
	DisableHoverTextHUD = false
	DeactivatedHUDs = nil
	
	--item values
	eyethermalHUDitem=nil
	eyemedicalHUDitem=nil
	eyeelectricalHUDitem=nil
	
end)

--resets hud parameters for client when character changes for mcm and singplayer switches
Hook.Patch("Barotrauma.Character", "set_Controlled", function(character)

	thermalHUDActive = nil
	medicalHUDActive = nil
	electricalHUDActive = nil
	eyeHUD = nil
	DisableHoverTextHUD = false
	DeactivatedHUDs = nil
	
end)

--deletes player text for medical hud
Hook.Patch("Barotrauma.CharacterHUD", "DrawCharacterHoverTexts", function(instance, ptable)

	ptable.PreventExecution = DisableHoverTextHUD
	return nil
	
end, Hook.HookMethodType.Before)


--this hook draws the written eye huds
Hook.Patch("Barotrauma.CharacterHUD", "Draw", function(instance, ptable)

	if eyeHUD==nil then return end 
	eyeHUD.DrawHUD(ptable["spriteBatch"], Character.Controlled) --draws the huds

end)


--[[ these are pretty much outdated and will be nuked, I'll keep them for know in case somethings breaks
--draw written HUDs
Hook.Patch("Barotrauma.CharacterHUD", "Draw", function(instance, ptable)
	
		if HF.GameIsPaused() or (not Level.Loaded) then return end
		if not HF.HasAffliction(Character.Controlled, "eyeinfrared") then return end

		if eyeHUD==nil then
			for item in Item.ItemList do --make this global, when adding more eyes
				if item.Prefab.Identifier == "eyethermalHUDitem" then
					if item==nil then NTEYE.SendItemSpawnRequest() end
					item.Equip(Character.Controlled)
					eyeHUD = item.GetComponentString("StatusHUD")
					thermalHUDActive = 1
					break
				end
			end
		end

		if eyeHUD==nil then NTEYE.SendItemSpawnRequest() return end
		eyeHUD.DrawHUD(ptable["spriteBatch"], Character.Controlled) --draws the thermal vision hud
	
end)


--medical eye hud
Hook.Patch("Barotrauma.CharacterHUD", "Draw", function(instance, ptable)
		
		if HF.GameIsPaused() or (not Level.Loaded) then return end
		if not HF.HasAffliction(Character.Controlled, "medicallens") then return end

		if DeactivatedHUDs==1 then return end --check if hud is disabled by player

		if eyeHUD==nil then
			for item in Item.ItemList do
				if item.Prefab.Identifier == "eyemedicalHUDitem" then
					if item==nil then NTEYE.SendItemSpawnRequest() end
					item.Equip(Character.Controlled)
					eyeHUD = item.GetComponentString("StatusHUD")
					medicalHUDActive = 1
					DeactivatedHUDs = 0
					DisableHoverTextHUD = true --disables text hud
					break
				end
			end
		end
		
		if eyeHUD==nil then NTEYE.SendItemSpawnRequest() return end
		eyeHUD.DrawHUD(ptable["spriteBatch"], Character.Controlled) --draws the medical hud

end)


--electrical eye hud
Hook.Patch("Barotrauma.CharacterHUD", "Draw", function(instance, ptable)

		if HF.GameIsPaused() or (not Level.Loaded) then return end
		if not HF.HasAffliction(Character.Controlled, "electricallens") then return end
		
		if DeactivatedHUDs==1 then return end --check if hud is disabled by player

		if eyeHUD==nil then
			for item in Item.ItemList do
				if item.Prefab.Identifier == "eyeelectricalHUDitem" then
					item.Equip(Character.Controlled)
					eyeHUD = item.GetComponentString("StatusHUD")
					electricalHUDActive = 1
					DeactivatedHUDs = 0
					break
				end
			end
		end

		if eyeHUD==nil then NTEYE.SendItemSpawnRequest() return end
		eyeHUD.DrawHUD(ptable["spriteBatch"], Character.Controlled) --removing this doesnt make any difference but then again the other huds need it for some reason, better to keep it I suppose

end)
--]]


--Eye Effect Check Functions - this function got really fucked over time, needs to be rewritten
function NTEYE.UpdateHumanEyeEffect()
 
local LevelLight = Level.Loaded.LevelData.GenerationParams 
	
if HF.HasAffliction(Character.Controlled, "eyebionic") then
	
		--medical lens
		if HF.HasAffliction(Character.Controlled, "medicallens") then
			
			LevelLight.AmbientLightColor = Color(50, 0, 0, 45)
		
			for k, HullLight in pairs(Hull.HullList) do
				HullLight.AmbientLight = Color(60, 0, 0, 75)
			end
		
			NTEYE.writeHUDs()
		
		--electrical lens
		elseif HF.HasAffliction(Character.Controlled, "electricallens") then
			
			LevelLight.AmbientLightColor = Color(50, 50, 0, 45)
			
			for k, HullLight in pairs(Hull.HullList) do
				HullLight.AmbientLight = Color(60, 60, 0, 75)
			end
			
			NTEYE.writeHUDs()
			
		--zoom lens
		elseif HF.HasAffliction(Character.Controlled, "zoomlens") then --zoom has seperate file
			
			LevelLight.AmbientLightColor = Color(0, 17, 50, 45)

			for k, HullLight in pairs(Hull.HullList) do
				HullLight.AmbientLight = Color(0, 20, 60, 75)
			end
		
		--default bionic eyes
		else
			
			
			LevelLight.AmbientLightColor = Color(50, 50, 50, 45)
		
			for k, HullLight in pairs(Hull.HullList) do
				HullLight.AmbientLight = Color(60, 60, 60, 75) 
			end
			
			NTEYE.disableHUDs()
			
		end
  
  
elseif HF.HasAffliction(Character.Controlled, "eyenight") then

		LevelLight.AmbientLightColor = Color(20, 160, 30, 200)
		
		for k, HullLight in pairs(Hull.HullList) do
			HullLight.AmbientLight = Color(20, 160, 20, 150) 
		end
		
elseif HF.HasAffliction(Character.Controlled, "eyeinfrared") then

		LevelLight.AmbientLightColor = Color(25, 0, 75, 40)
		
		for k, HullLight in pairs(Hull.HullList) do
			HullLight.AmbientLight = Color(50, 0, 200, 75) 
		end
		
		NTEYE.writeHUDs()
		
elseif HF.HasAffliction(Character.Controlled, "eyeplastic") then

		LevelLight.AmbientLightColor = Color(0, 0, 255, 5)
		
		for k, HullLight in pairs(Hull.HullList) do
			HullLight.AmbientLight = Color(0, 0, 255, 5) 
		end
		
elseif HF.HasAffliction(Character.Controlled, "eyemonster") then

		if Game.IsMultiplayer then Character.Controlled.TeamID = 0 end

		LevelLight.AmbientLightColor = Color(50, 0, 50, 5)
		
		for k, HullLight in pairs(Hull.HullList) do
			HullLight.AmbientLight = Color(160, 160, 70, 25) 
		end
		
elseif HF.HasAffliction(Character.Controlled, "eyehusk") then

		if Game.IsMultiplayer then Character.Controlled.TeamID = 4 end
		
		LevelLight.AmbientLightColor = Color(115, 115, 20, 5)
		
		for k, HullLight in pairs(Hull.HullList) do
			HullLight.AmbientLight = Color(115, 115, 30, 30) 
		end

elseif HF.HasAffliction(Character.Controlled, "eyeterror") then

		if Game.IsMultiplayer then Character.Controlled.TeamID = 2 end
		
		LevelLight.AmbientLightColor = Color(255, 0, 0, 125)
		
		for k, HullLight in pairs(Hull.HullList) do
			HullLight.AmbientLight = Color(255, 0, 0, 125) 
		end
		
else--regular eyes/no eyes
		LevelLight.AmbientLightColor = Color(10, 10, 10, 25)
		
		for k, HullLight in pairs(Hull.HullList) do
			HullLight.AmbientLight = Color(20, 20, 20, 35) 
		end
		
		--disables eye HUDs
		NTEYE.disableHUDs() 
		DeactivatedHUDs = 0
		
		--resets character team
		if Character.Controlled ~= nil then 
			if(Character.Controlled.IsHuman and not Character.Controlled.IsDead) then Character.Controlled.TeamID = 1 end
		end
		
		--increases robot brightness
		NTEYE.RobotraumaClientPatch(LevelLight)
		
	end
end

--sends a request for HUD items to spawn in case lua fucks up
function NTEYE.SendItemSpawnRequest() 

	if not Game.IsMultiplayer then NTEYE.SpawnEffectItems() return end --singleplayer comp

	print("boogeraids")
	
	local message = Networking.Start("SendItemSpawnRequest")

	message.WriteString("")

	Networking.Send(message)

end

function NTEYE.writeHUDs()

	--medical lens
	if HF.HasAffliction(Character.Controlled, "medicallens") then
	
		if DeactivatedHUDs==1 then return end --check if hud is disabled by player

		if eyeHUD==nil then

			if eyemedicalHUDitem==nil then NTEYE.GetClientItemValues() NTEYE.SendItemSpawnRequest() return end
			
			eyemedicalHUDitem.Equip(Character.Controlled) --equip item
			
			eyeHUD = eyemedicalHUDitem.GetComponentString("StatusHUD") --get hud component
			
			medicalHUDActive = 1 --activate hud
			
			DeactivatedHUDs = 0 --set the manual activation figure
			
			DisableHoverTextHUD = true --disable text hud
			
		end
	end
	
	--electrical lens
	if HF.HasAffliction(Character.Controlled, "electricallens") then 
	
		if DeactivatedHUDs==1 then return end --check if hud is disabled by player

		if eyeHUD==nil then
			
			if eyeelectricalHUDitem==nil then NTEYE.GetClientItemValues() NTEYE.SendItemSpawnRequest() return end
			
			eyeelectricalHUDitem.Equip(Character.Controlled) --equip item
			
			eyeHUD = eyeelectricalHUDitem.GetComponentString("StatusHUD") --get hud component
			
			electricalHUDActive = 1 --activate hud
			
			DeactivatedHUDs = 0 --set the manual activation figure

		end
	end
	
	--infrared eyes
	if HF.HasAffliction(Character.Controlled, "eyeinfrared") then 
	
		if eyeHUD==nil then

			if eyethermalHUDitem==nil then NTEYE.GetClientItemValues() NTEYE.SendItemSpawnRequest() return end
			
			eyethermalHUDitem.Equip(Character.Controlled) --equip item
			
			eyeHUD = eyethermalHUDitem.GetComponentString("StatusHUD") --get hud component
			
			thermalHUDActive = 1 --activate hud
			
		end
	end

end

--checks if any HUDs are enabled
function NTEYE.checkHUDs()

	if 
		   thermalHUDActive == 1
		or medicalHUDActive == 1
		or electricalHUDActive == 1
	
	then return true end
	
end

--[[ OUTDATED
--disables HUDs if they are enabled
function NTEYE.disableHUDs()

	if NTEYE.checkHUDs() then 
	
		for item in Item.ItemList do
			
			if item.Prefab.Identifier == "eyethermalHUDitem" then
				item.Unequip(Character.Controlled)
				thermalHUDActive = nil
			end
			
			if item.Prefab.Identifier == "eyemedicalHUDitem" then
				item.Unequip(Character.Controlled)	
				medicalHUDActive = nil
				DisableHoverTextHUD = false
			end
			
			if item.Prefab.Identifier == "eyeelectricalHUDitem" then
				item.Unequip(Character.Controlled)	
				electricalHUDActive = nil
			end

			eyeHUD = nil
			
			--break
		end
	
	end

end		
--]]

function NTEYE.disableHUDs()

	if NTEYE.checkHUDs() then 
	
		--infrared eyes
		eyethermalHUDitem.Unequip(Character.Controlled)
		thermalHUDActive = nil

		--medical lens
		eyemedicalHUDitem.Unequip(Character.Controlled)	
		medicalHUDActive = nil
		DisableHoverTextHUD = false

		--electrical lens
		eyeelectricalHUDitem.Unequip(Character.Controlled)	
		electricalHUDActive = nil
			
		eyeHUD = nil
	
	end

end


--get the item values ONCE
function NTEYE.GetClientItemValues()

	for item in Item.ItemList do

		if item.Prefab.Identifier == "eyethermalHUDitem" then
			eyethermalHUDitem=item
		end
		
		if item.Prefab.Identifier == "eyemedicalHUDitem" then
			eyemedicalHUDitem=item
		end

		if item.Prefab.Identifier == "eyeelectricalHUDitem" then
			eyeelectricalHUDitem=item
		end
		
	end
	
end


--this gets overwritten when robotrauma is activated
function NTEYE.RobotraumaClientPatch() end 


--this hook draws the special eye huds
Hook.Patch("Barotrauma.CharacterHUD", "Draw", function(instance, ptable)

	eyeHUD.DrawHUD(ptable["spriteBatch"], Character.Controlled) --draws the medical hud

end)


function NTEYE.writeHUDs()

	--medical lens
	if HF.HasAffliction(Character.Controlled, "medicallens") then 
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
			
			if eyeHUD==nil then NTEYE.SendItemSpawnRequest() end
			
		end
	end
	
	--electrical lens
	if HF.HasAffliction(Character.Controlled, "electricallens") then 
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
			
			if eyeHUD==nil then NTEYE.SendItemSpawnRequest() end
			
		end
	end
	
	--infrared eyes
	if HF.HasAffliction(Character.Controlled, "eyeinfrared") then 
	
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
			
			if eyeHUD==nil then NTEYE.SendItemSpawnRequest() end
			
		end
	end
	
	

end






eyethermalHUDitem=nil
eyemedicalHUDitem=nil
eyeelectricalHUDitem=nil

--get the item values ONCE
function NTEYE.GetClientItemValues()
	for item in Item.Itemlist do 

		if item.Prefab.Identifier == "eyethermalHUDitem" then
			item=eyethermalHUDitem
		end
		
		if item.Prefab.Identifier == "eyemedicalHUDitem" then
			item=eyemedicalHUDitem
		end

		if item.Prefab.Identifier == "eyeelectricalHUDitem" then
			item=eyeelectricalHUDitem
		end
	end
end



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

end	









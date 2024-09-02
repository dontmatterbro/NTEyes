
local zSpeed=0.02 -- zoom speed
local zMin=0.5 -- minimum zoom modifier
local zMax=9 -- maximum zoom modifier
local zStart=1 -- default zoom level

--Zoom Lenses
local decreaseZoomKey1=Keys.Subtract -- decrease zoom key
local increaseZoomKey1=Keys.Add -- increase zoom key 
	
local decreaseZoomKey2=Keys.OemMinus -- decrease zoom key
local increaseZoomKey2=Keys.OemPlus -- increase zoom key

--Common Lenses	
local disableeffectkey=Keys.F -- disable effect key

--Medical Scanner
local MedicalScannerKey=Keys.F

local zoomOn=true
local gzsDefault=false
local gzsDefaultMin=0.1
local gzsDefaultMax=2
local zStart=math.max(math.min(zMax,zStart),zMin)
local gzsNew=zStart
local gzsMin=zMin
local gzsMax=zMax
local gzsUpd=false

local dHeld=false
local iHeld=false
local zHeld=false


--Zoom
LuaUserData.MakeFieldAccessible(Descriptors["Barotrauma.Camera"],"globalZoomScale")
LuaUserData.MakeMethodAccessible(Descriptors["Barotrauma.Camera"],"CreateMatrices")

--Health Scanner
LuaUserData.MakeFieldAccessible(Descriptors["Barotrauma.CharacterHealth"], "selectedLimbIndex")

Hook.HookMethod("Barotrauma.Camera","CreateMatrices",function(instance,ptable)
	

	gzsDefault=instance.globalZoomScale


	gzsDefaultMin=instance.MinZoom
	gzsDefaultMax=instance.MaxZoom
	gzsMin=math.max(zMin,gzsDefault*zMin)
	gzsMax=math.min(zMax,gzsDefault*zMax)
	gzsNew=math.max(math.min(gzsMax,gzsDefault*zStart),gzsMin)
	gzsUpd=true
	instance.MinZoom=math.min(gzsMin/2,instance.MinZoom)
	instance.MaxZoom=math.max(gzsMax*2,instance.MaxZoom)
	
end,Hook.HookMethodType.After)

Hook.HookMethod("Barotrauma.Character","ControlLocalPlayer",function(instance,ptable)

	NTEYE.Zoom(instance,ptable)
	NTEYE.MedicalLens()
	NTEYE.HUDActivation()
	
end,Hook.HookMethodType.After) 


--send info to server to play beep sound
function NTEYE.PlayBeepSound(soundTarget)

	if not Game.IsMultiplayer then HF.GiveItem(soundTarget,"nteye_beep") return end ----singleplayer comp
	
	local message = Networking.Start("PlayBeepSound")

	message.WriteString(soundTarget.ID)

	Networking.Send(message)

end

--check for input to activate/deactivate certain HUDs
function NTEYE.HUDActivation()

	if --medical and electrical activation
			   HF.HasAffliction(Character.Controlled, "electricallens")
		   or (HF.HasAffliction(Character.Controlled, "medicallens") and CharacterHealth.OpenHealthWindow==nil)
	then
		if 
			PlayerInput.KeyHit(disableeffectkey)
			and DeactivatedHUDs==0
		then
			NTEYE.disableHUDs()
			DeactivatedHUDs=1
			NTEYE.PlayBeepSound(Character.Controlled)
		elseif
		
			PlayerInput.KeyHit(disableeffectkey)
			and DeactivatedHUDs==1
		then
			DeactivatedHUDs=0
			NTEYE.PlayBeepSound(Character.Controlled)
		end
	end

end


function NTEYE.Zoom(instance,ptable)

	if --checks to see if default zoom value exists
		not gzsDefault
	then
		ptable.cam.CreateMatrices()
	end

	--zoom types
	if --Zoom Lens
		HF.HasAffliction(Character.Controlled, "zoomlens")
	then
		
		gzsUpd=false

		if 
			not Character.DisableControls 
			and Character.Controlled 
		then

				if --Decrease Zoom
					   PlayerInput.KeyDown(decreaseZoomKey1) 
					or PlayerInput.KeyDown(decreaseZoomKey2) 
				then
					gzsNew=math.max(gzsMin,gzsNew*(1-zSpeed))
					gzsUpd=true
				else
					dHeld=false
				end
					
					
					
				if --Increase Zoom
					   PlayerInput.KeyDown(increaseZoomKey1) 
					or PlayerInput.KeyDown(increaseZoomKey2) 
				then
					gzsNew=math.min(gzsMax,gzsNew*(1+zSpeed))
					gzsUpd=true
				else
					iHeld=false
				end
		end
			
		if gzsUpd then
			ptable.cam.globalZoomScale=zoomOn and gzsNew or gzsDefault
		end
		
			
	elseif --Plastic Eyes
		HF.HasAffliction(Character.Controlled, "eyeplastic")
	then
		ptable.cam.globalZoomScale=gzsDefault+0.7
	
	elseif --Glasses
		HF.HasAffliction(Character.Controlled, "hasglasses")
	then
		ptable.cam.globalZoomScale=gzsDefault
		
	else --Eye Damage
		ptable.cam.globalZoomScale=gzsDefault+HF.GetAfflictionStrength(Character.Controlled,"eyedamage",0)/135
	end


end

--enables medical lens controls
function NTEYE.MedicalLens()

	if HF.HasAffliction(Character.Controlled, "medicallens") then
		if 
			CharacterHealth.OpenHealthWindow ~= nil
			and NTEYE.ScannerActive==0
		then
			if --Scan Limb
				PlayerInput.KeyDown(MedicalScannerKey) 
			then
				local limb = nil
				
				local scannerTarget = nil
				
				local scannerUser = Character.Controlled
				
				local limbIndex = CharacterHealth.OpenHealthWindow.selectedLimbIndex

				if --Which Character to scan
					Character.Controlled.SelectedCharacter ~= nil
				then
					scannerTarget = Character.Controlled.SelectedCharacter

				else
					scannerTarget = Character.Controlled
				end

				if --client can't scan own head
					limbIndex == 0
					and (scannerUser == scannerTarget)
				then 
					HF.DMClient(HF.CharacterToClient(usingCharacter), "‖color:255,100,100‖".."You can't see your own head.".."‖color:end‖")
					NTEYE.ScannerActive = 1
					NTEYE.PlayScannerSound(scannerTarget)
					Timer.Wait(function() NTEYE.ScannerActive = 0 end, 500)
				return end
				
				if --limb index, there probably an easier way to do this
					limbIndex == 0
				then
					limb = LimbType.Head

				elseif
					limbIndex == 1
				then
					limb = LimbType.Torso
				
				elseif
					limbIndex == 2
				then
					limb = LimbType.LeftArm
				
				elseif
					limbIndex == 3
				then
					limb = LimbType.RightArm
				
				elseif
					limbIndex == 4
				then
					limb = LimbType.LeftLeg
				
				elseif
					limbIndex == 5
				then
					limb = LimbType.RightLeg
				else
				return end
				
				
				
				
				NTEYE.HealthScanner(scannerUser, scannerTarget, limb)
				
				NTEYE.ScannerActive = 1
			end
		
		end
	end

end

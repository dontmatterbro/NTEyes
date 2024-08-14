
	zStep=0.5 -- step size for when smoothZoom=false
	zSpeed=0.02 -- speed for when smoothZoom=true
	zMin=0.5 -- minimum zoom modifier
	zMax=9 -- maximum zoom modifier
	zStart=1 -- default zoom level

	decreaseZoomKey=Keys.Subtract -- decrease zoom key
	increaseZoomKey=Keys.Add -- increase zoom key

zoomOn=true
gzsDefault=false
gzsDefaultMin=0.1
gzsDefaultMax=2
zStart=math.max(math.min(zMax,zStart),zMin)
gzsNew=zStart
gzsMin=zMin
gzsMax=zMax
gzsUpd=false

dHeld=false
iHeld=false
zHeld=false

LuaUserData.MakeFieldAccessible(Descriptors["Barotrauma.Camera"],"globalZoomScale")
LuaUserData.MakeMethodAccessible(Descriptors["Barotrauma.Camera"],"CreateMatrices")

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

	if
		HF.HasAffliction(Character.Controlled, "zoomlens")
	then
		
		gzsUpd=false
		
		if
			not gzsDefault
		then
			ptable.cam.CreateMatrices()
		else
			if 
				not Character.DisableControls 
				and Character.Controlled 
			then

					if --Decrease Zoom
						PlayerInput.KeyDown(decreaseZoomKey) 
					then
						gzsNew=math.max(gzsMin,gzsNew*(1-zSpeed))
						gzsUpd=true
					else
						dHeld=false
					end
					
					
					
					if --Increase Zoom
						PlayerInput.KeyDown(increaseZoomKey) 
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
		end
			
	elseif 
		HF.HasAffliction(Character.Controlled, "eyeplastic")
	then
		ptable.cam.globalZoomScale=1.7
	
	elseif 
		HF.HasAffliction(Character.Controlled, "hasglasses")
	then
		ptable.cam.globalZoomScale=1.33
		
	else
		ptable.cam.globalZoomScale=1.33+HF.GetAfflictionStrength(Character.Controlled,"eyedamage",0)/150
	end

end,Hook.HookMethodType.After) 

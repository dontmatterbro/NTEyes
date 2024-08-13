if SERVER then return end


	-- customization
	isToggle=true -- toggle or hold behaviour
	smoothZoom=true -- smooth or step

	zStep=0.5 -- step size for when smoothZoom=false
	zSpeed=0.02 -- speed for when smoothZoom=true
	zMin=0.3 -- minimum zoom modifier
	zMax=9 -- maximum zoom modifier
	zStart=1.5 -- default zoom level

	zKey=Keys.F -- zoom key
	dKey=Keys.Subtract -- decrease zoom key
	iKey=Keys.Add -- increase zoom key
	rKey=Keys.Back -- reset zoom key
	-- customization end
--end

zoomOn=false -- default zoom state
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
	gzsUpd=false
	if not gzsDefault then
		ptable.cam.CreateMatrices()
	else
		if not Character.DisableControls and Character.Controlled then
			if zoomOn then
				if PlayerInput.KeyDown(dKey) then
					if smoothZoom then
						gzsNew=math.max(gzsMin,gzsNew*(1-zSpeed))
						gzsUpd=true
					elseif not dHeld then
						gzsNew=math.max(gzsMin,gzsNew-zStep)
						dHeld=true
						gzsUpd=true
					end
				else
					dHeld=false
				end
				if PlayerInput.KeyDown(iKey) then
					if smoothZoom then
						gzsNew=math.min(gzsMax,gzsNew*(1+zSpeed))
						gzsUpd=true
					elseif not iHeld then
						gzsNew=math.min(gzsMax,gzsNew+zStep)
						iHeld=true
						gzsUpd=true
					end
				else
					iHeld=false
				end
				if PlayerInput.KeyDown(rKey) then
					gzsNew=gzsDefault*zStart
					gzsUpd=true
				end
			end
			if PlayerInput.KeyDown(zKey) then
				if isToggle then
					if not zHeld then
						zoomOn=not zoomOn
						zHeld=true
						gzsUpd=true
					end
				else
					zoomOn=true
					gzsUpd=true
				end
			elseif isToggle then
				zHeld=false
			elseif zoomOn then
				zoomOn=false
				gzsUpd=true
			end
		else
			zoomOn=false
		end
		if gzsUpd then
			ptable.cam.globalZoomScale=zoomOn and gzsNew or gzsDefault
		end
	end
end,Hook.HookMethodType.After)

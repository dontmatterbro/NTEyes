NTEYE.UpdateCooldown = 0
NTEYE.UpdateInterval = 120

-- updates NTEYE.UpdateHumanEyeEffect every 2 seconds
Hook.Add("think", "NTEYE.update", function()
    if HF.GameIsPaused() or not Level.Loaded then return end

    NTEYE.UpdateCooldown = NTEYE.UpdateCooldown-1
    if (NTEYE.UpdateCooldown <= 0) then
        NTEYE.UpdateCooldown = NTEYE.UpdateInterval
        NTEYE.UpdateHumanEyeEffect(character)
    end
end)


--Eye Effect Check Functions shouldn't run on server
function NTEYE.UpdateHumanEyeEffect(character)
print("debug:UpdateHumanEyeEffect")
if HF.HasAffliction(Character.Controlled, "eyebionic") then
		local parameters = Level.Loaded.LevelData.GenerationParams
		parameters.AmbientLightColor = Color(50, 50, 0, 35)
		for k, hull in pairs(Hull.HullList) do
        hull.AmbientLight = Color(60, 60, 0, 75) 
        end
  
elseif HF.HasAffliction(Character.Controlled, "eyenight") then
		local parameters = Level.Loaded.LevelData.GenerationParams
		parameters.AmbientLightColor = Color(20, 160, 30, 200)
		for k, hull in pairs(Hull.HullList) do
        hull.AmbientLight = Color(20, 160, 20, 150) 
        end
 
elseif HF.HasAffliction(Character.Controlled, "eyeinfrared") then
		local parameters = Level.Loaded.LevelData.GenerationParams
		parameters.AmbientLightColor = Color(25, 0, 75, 25)
		for k, hull in pairs(Hull.HullList) do
        hull.AmbientLight = Color(50, 0, 200, 75) 
        end
 
elseif HF.HasAffliction(Character.Controlled, "eyeplastic") then
		local parameters = Level.Loaded.LevelData.GenerationParams
		parameters.AmbientLightColor = Color(0, 0, 255, 0)
		for k, hull in pairs(Hull.HullList) do
        hull.AmbientLight = Color(0, 0, 255, 0) 
        end
 
elseif HF.HasAffliction(Character.Controlled, "eyemonster") then
		Character.Controlled.TeamID = 0
		local parameters = Level.Loaded.LevelData.GenerationParams
		parameters.AmbientLightColor = Color(50, 0, 50, 5)
		for k, hull in pairs(Hull.HullList) do
        hull.AmbientLight = Color(160, 160, 70, 25) 
        end
 
elseif HF.HasAffliction(Character.Controlled, "eyehusk") then
		Character.Controlled.TeamID = 4 
		local parameters = Level.Loaded.LevelData.GenerationParams
		parameters.AmbientLightColor = Color(115, 115, 20, 5)
		for k, hull in pairs(Hull.HullList) do
        hull.AmbientLight = Color(115, 115, 30, 30) 
        end
 
elseif HF.HasAffliction(Character.Controlled, "eyeterror") then
		Character.Controlled.TeamID = 2 
		local parameters = Level.Loaded.LevelData.GenerationParams
		parameters.AmbientLightColor = Color(255, 0, 0, 125)
		for k, hull in pairs(Hull.HullList) do
        hull.AmbientLight = Color(255, 0, 0, 125) 
        end

else	local parameters = Level.Loaded.LevelData.GenerationParams
		parameters.AmbientLightColor = Color(10, 10, 10, 10)
		for k, hull in pairs(Hull.HullList) do
        hull.AmbientLight = Color(20, 20, 20, 20) 
        end
		if (Character.Controlled.IsHuman and not Character.Controlled.IsDead) then Character.Controlled.TeamID = 1 end
	end
end
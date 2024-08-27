function NTEYE.RobotraumaClientPatch(character)

	if 
		not (character.IsFemale or character.IsMale)
	then
	
		local parameters = Level.Loaded.LevelData.GenerationParams
		
		parameters.AmbientLightColor = Color(100, 100, 100, 100)
		
		for k, hull in pairs(Hull.HullList) do
			hull.AmbientLight = Color(100, 100, 100, 100) 
        end
	
	end

end
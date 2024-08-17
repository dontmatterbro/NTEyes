local function isHealthInterfaceFocused()
	return CharacterHealth.OpenHealthWindow ~= nil
	and GUI.GUI.KeyboardDispatcher.Subscriber == nil
	and Game.GameSession.CrewManager.commandFrame == nil
	and Character.Controlled.AllowInput
end


Hook.HookMethod("Barotrauma.Character","ControlLocalPlayer",function(instance,ptable)

	if 
		CharacterHealth.OpenHealthWindow ~= nil
	then
		if --Decrease Zoom
			PlayerInput.KeyDown(Keys.Add) 
		then
			print("test succ")
		
		end
	
	end





end,Hook.HookMethodType.After) 
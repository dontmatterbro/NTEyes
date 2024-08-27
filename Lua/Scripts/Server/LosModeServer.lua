--warns the players if LOS isn't opaque
Hook.Add("roundStart", "LosModeWarning", function()

	if Game.ServerSettings==nil then return end

	if Game.ServerSettings.LosMode==2 then return end
	 
	Timer.Wait(function() --do this 15~ seconds later to increase visibility
		for key, client in pairs(Client.ClientList) do
			if 
				Game.ServerSettings.LosMode==0 
			then
			
				local chatMessage = ChatMessage.Create("NT Eyes",
				
				"\n"
				.."‖color:255,100,100‖".."Line of Sight mode is set to".."‖color:end‖".."‖color:255,75,75‖".." none.".."‖color:end‖"
				.."\n".."‖color:200,200,200‖".."For intended experince set it opaque by typing".."‖color:end‖".."‖color:100,255,100‖".."  !LOS ".."‖color:end‖".."‖color:200,200,200‖".." in the chat.".."‖color:end‖"
				
				,ChatMessageType.Default, nil, nil)

				Game.SendDirectChatMessage(chatMessage, client)
				
			else
			
				local chatMessage = ChatMessage.Create("NT Eyes",
				
				"\n"
				.."‖color:255,100,100‖".."Line of Sight mode is set to".."‖color:end‖".."‖color:255,75,75‖".." translucent.".."‖color:end‖"
				.."\n".."‖color:200,200,200‖".."For intended experince set it opaque by typing".."‖color:end‖".."‖color:100,255,100‖".."  !LOS ".."‖color:end‖".."‖color:200,200,200‖".." in the chat.".."‖color:end‖"
				
				,ChatMessageType.Default, nil, nil)

				Game.SendDirectChatMessage(chatMessage, client)
				
			end
		end
	end, 15000)
	
end)

--sets the los to opaque if the client has perms
Hook.Add("chatMessage", "setLosCommand", function (message, client)
	
	if 
		   message=="!los" 
		or message=="!LOS"
	then
		if
			client.HasPermission(512)
		then
			
			if 
				Game.ServerSettings.LosMode==2 
			then
				Timer.Wait(function()
					local chatMessage = ChatMessage.Create("NT Eyes",
					
					"‖color:0,255,0‖".."Line of Sight mode is already set to opaque.".."‖color:end‖"
					
					,ChatMessageType.Default, nil, nil)

					Game.SendDirectChatMessage(chatMessage, client)
				end, 20)
			else
				Game.ServerSettings.LosMode=2 
				Game.ServerSettings.ForcePropertyUpdate()
				
				Timer.Wait(function()
					local chatMessage = ChatMessage.Create("NT Eyes",
					
					"‖color:0,255,0‖".."Line of Sight mode has been set to opaque.".."‖color:end‖"
					.."\n".."‖color:0,255,0‖".."Changes will apply at the beginning of the next round.".."‖color:end‖"
					
					,ChatMessageType.Default, nil, nil)

					Game.SendDirectChatMessage(chatMessage, client)
				end, 20)
			end
		
		else
			Timer.Wait(function()
				local chatMessage = ChatMessage.Create("NT Eyes",
					
				"‖color:255,0,0‖".."You do not have permission to change this setting. (Manage Settings)".."‖color:end‖"
					
				,ChatMessageType.Default, nil, nil)

				Game.SendDirectChatMessage(chatMessage, client)
			end, 20)
		end
		
	end

end)
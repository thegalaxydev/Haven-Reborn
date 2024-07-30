local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local Directory = require(ReplicatedStorage:FindFirstChild("Directory"))

local ChatMessage = Directory.Retrieve("Classes/ChatMessage")

local CommandService = Directory.Retrieve("Services/CommandService")
local NameColorService = Directory.Retrieve("Services/NameColorService")

local ServerScriptService = game:GetService("ServerScriptService")

local PlayerService = require(ServerScriptService.Galaxy_Server.Services.PlayerService)

local StarterGui = game:GetService("StarterGui")

local Chat = StarterGui:WaitForChild("Main").Chat
script.Parent.Chat.Parent = Chat


local NetworkService = Directory.Retrieve("Services/NetworkService")

local ReplicationFunctions = {
	["SendMessage"] = function(player: Player, message: string, recipient: Player?)
		if message == "" then return end
		 
		local messageObject = ChatMessage.new(message)
		messageObject:AddSender(player, NameColorService.GetNameColor(player))

		messageObject.Prefixes = PlayerService.GetPrefixesForPlayer(player)

		if recipient then
			local success, result = pcall(function()
				return TextService:FilterStringAsync(message, player.UserId)
			end)

			local text = ""

			if success then
				text = result:GetChatForUserAsync(recipient.UserId)
			end


			messageObject.Message = text

			
			NetworkService.Fire("ReceiveMessage", recipient, messageObject)
			NetworkService.Fire("BubbleChat", recipient, player, text)
		else
			for _, recipient in pairs(game.Players:getPlayers()) do
				local filteredMessage = ""
				local success, result = pcall(function()
					filteredMessage = TextService:FilterStringAsync(message, player.UserId):GetChatForUserAsync(recipient.UserId)
				end)
	
				if not success then
					warn("Error filtering message: " .. result)
				else
					messageObject.Message = filteredMessage
				end

				NetworkService.Fire("ReceiveMessage", recipient, messageObject)
				NetworkService.Fire("BubbleChat", recipient, player, filteredMessage)
			end
		end
	end,

	["GetCommands"] = function(player: Player)
		local cmds = {}
	
		for command, _ in pairs(CommandService.Commands) do
			table.insert(cmds, command)
		end

		return cmds
	end,

	["ExecuteCommand"] = function(player: Player, command: string, args: {any})
		local success, msg = CommandService.ExecuteCommand(player, command, args)
		
		if not success then
			NetworkService.Fire("ReceiveMessage", player, ChatMessage.new(msg, Enum.Font.SourceSansBold, Color3.fromRGB(255, 0, 0)))
			return false
		end

		return true
	end
}

for name, func in pairs(ReplicationFunctions) do
	NetworkService.Create(name, func)
end



return true
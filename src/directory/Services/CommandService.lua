local CommandService = {}

CommandService.Commands = {}

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

function CommandService.RegisterCommand(command: string, callback: (player: Player, args: {string}) -> boolean)
	CommandService.Commands[command] = callback
end

function CommandService.ExecuteCommand(player: Player, command: string, args: {string}) : (boolean, string)
	if RunService:IsClient() then
		return false, "Cannot execute commands on the client."
	end

	if CommandService.Commands[command] then
		return CommandService.Commands[command](player, args)
	end

	return false, "Command not found."
end


return CommandService

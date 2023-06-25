local ContextActionService = game:GetService("ContextActionService")
local Directory = require(game:GetService("ReplicatedStorage").Directory)
local ControlService = {}

local Player = game.Players.LocalPlayer
local CharacterService = Directory.Retrieve("Services/CharacterService")

local ServerReplication = game.ReplicatedStorage.Remotes.ServerReplication


ControlService.Keybinds = {


}

function ControlService.InitializeKeybinds()
	for bind, keyInfo in pairs(ControlService.Keybinds) do
		ContextActionService:BindAction(bind, keyInfo[2] or function(actionName, inputState, inputObject)
			if inputState ~= Enum.UserInputState.Begin then return end
			warn("No callback available for " .. bind .. ".")
		end, false, unpack(keyInfo[1]))
	end
end

return ControlService
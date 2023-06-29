local ContextActionService = game:GetService("ContextActionService")
local Directory = require(game:GetService("ReplicatedStorage").Directory)
local ControlService = {}

local Player = game.Players.LocalPlayer

local NetworkService = Directory.Retrieve("Services/NetworkService")

local UIService = require(script.Parent.UIService)

local PlayerGui = Player.PlayerGui


ControlService.Keybinds = {
	["OPEN_INVENTORY"] = {{Enum.KeyCode.E, Enum.KeyCode.ButtonX}, 
	function(actionName: string, inputState: Enum.UserInputState, inputObject: InputObject)
		if inputState ~= Enum.UserInputState.Begin then return end
		
		UIService.Toggle("Inventory")
	end},
}

function ControlService.InitializeKeybinds()
	for bind in pairs(ControlService.Keybinds) do
		ContextActionService:UnbindAction(bind)
	end

	for bind, keyInfo in pairs(ControlService.Keybinds) do
		ContextActionService:BindAction(bind, keyInfo[2] or function(actionName, inputState, inputObject)
			if inputState ~= Enum.UserInputState.Begin then return end
			warn("No callback available for " .. bind .. ".")
		end, false, unpack(keyInfo[1]))
	end
end

return ControlService
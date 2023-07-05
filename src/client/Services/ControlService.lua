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

	["TOGGLE_PLAYERLIST"] = {{Enum.KeyCode.Tab}, 
	function(actionName: string, inputState: Enum.UserInputState, inputObject: InputObject)
		if inputState ~= Enum.UserInputState.Begin then return end
		
		UIService.ToggleLeaderboard()
	end},

	["WITHDRAW_ITEM"] = {{Enum.KeyCode.Z},
	function(actionName: string, inputState: Enum.UserInputState, inputObject: InputObject)
		if inputState ~= Enum.UserInputState.Begin then return end
		
		UIService.WithdrawSelected()
	end},

	["OPEN_SHOP"] = {{Enum.KeyCode.F},
	function(actionName: string, inputState: Enum.UserInputState, inputObject: InputObject)
		if inputState ~= Enum.UserInputState.Begin then return end
		
		UIService.Toggle("Shop")
	end},

	["SELL_ITEM"] = {{Enum.KeyCode.X},
	function(actionName: string, inputState: Enum.UserInputState, inputObject: InputObject)
		if inputState ~= Enum.UserInputState.Begin then return end
		
		UIService.SellSelected()
	end},

	["MOVE_ITEM"] = {{Enum.KeyCode.R},
	function(actionName: string, inputState: Enum.UserInputState, inputObject: InputObject)
		if inputState ~= Enum.UserInputState.Begin then return end
		
		UIService.MoveSelected()
	end},

	["SELECT_ITEM"] = {{Enum.UserInputType.MouseButton1},
	function(actionName: string, inputState: Enum.UserInputState, inputObject: InputObject)

		local playerBase = Player.PlayerPlot.Value 
		if inputState ~= Enum.UserInputState.Begin then return end

		local mouse : Mouse = Player:GetMouse()
		local hit = mouse.Hit

		local cameraPos = workspace.CurrentCamera.CFrame.Position
		local rayParams = RaycastParams.new()
		rayParams.FilterType = Enum.RaycastFilterType.Include
	
		local include = {}
		for _, child in pairs(playerBase.Items:GetChildren()) do
			table.insert(include, child.Hitbox)
		end
	
		rayParams.FilterDescendantsInstances = include
	
		local rayResult = workspace:Raycast(cameraPos, (hit.p - cameraPos).Unit * 1000, rayParams)
	
		if rayResult then
			local Item = rayResult.Instance.Name == "Hitbox" and rayResult.Instance.Parent or rayResult.Instance.Parent.Parent
					
			UIService.SelectItem(Item)
			
			return
		end
	
		UIService.DeselectItem()
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
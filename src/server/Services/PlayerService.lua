local PlayerService = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Directory = require(ReplicatedStorage:FindFirstChild("Directory"))

local BigNumber = Directory.Retrieve("Classes/BigNumber")
local DataService = require(script.Parent.DataService)

local BaseService = require(script.Parent.BaseService)


local Items = ReplicatedStorage.Storage.Items


local DeveloperList = {
	1319532389
}

PlayerService.PlayerData = DataService.CreateDataStoreInstance {
	Name = "PlayerData",
	ShouldAutoSave = true,
	AutoSaveInterval = 60,

	DefaultData = {
		["SaveSlot1"] = {
			["Money"] = "500",

			-- Crates
			["Crates"] = {
				["Regular"] = 0,
				["Unreal"] = 0,
				["Inferno"] = 0
			},
	
			["RebirthLevel"] = 1,
			["LifeCount"] = 1,
	
			["Clovers"] = {
				["Regular"] = 0,
				["Gold"] = 0
			},

			Inventory = {},

			["BaseData"] = {
				PlacementInformation = {},

				-- Default size IN 3x3 GRID SQUARES NOT STUDS
				BaseSize = Vector2.new(25, 25)
			}
		}

	}
}

function PlayerService.CharacterAdded(character: Model, player: Player)
	local HumanoidRootPart = character:WaitForChild("HumanoidRootPart")

	local Plot = player:WaitForChild("PlayerPlot")

	HumanoidRootPart.CFrame = Plot.Value:FindFirstChild("Spawn").CFrame + Vector3.new(0, 25, 0)
	

	require(Items.Test):Place(player, Plot.Value, Vector2.new(-1,-1), 1)

end

function PlayerService.PlayerAdded(player: Player)
	player.CharacterAdded:Connect(function(character)
		PlayerService.CharacterAdded(character, player)
	end)	

	local PlayerData = PlayerService.PlayerData:Load(player.UserId)
	
	local PlayerDataLoaded = Instance.new("BoolValue")
	PlayerDataLoaded.Name = "PlayerDataLoaded"
	PlayerDataLoaded.Parent = player

	BaseService.LoadBaseForPlayer(player)
end

function PlayerService.PlayerRemoving(player: Player)
	BaseService.UnloadBaseForPlayer(player)
end

function PlayerService.GetPrefixesForPlayer(player: Player) : {{string | Color3}}
	local prefixes : {{string | Color3}} = {}

	if table.find(DeveloperList, player.UserId) then
		table.insert(prefixes, {"[DEV] ", Color3.fromRGB(199, 86, 26)})
	end

	return prefixes
end

return PlayerService
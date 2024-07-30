local PlayerService = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Directory = require(ReplicatedStorage:FindFirstChild("Directory"))

local BigNumber = Directory.Retrieve("Classes/BigNumber")
local DataService = require(script.Parent.DataService)

local BaseService = require(script.Parent.BaseService)

local NetworkService = Directory.Retrieve("Services/NetworkService")

local Items = ReplicatedStorage.Storage.Items


local DeveloperList = {
	1319532389
}

PlayerService.PlayerData = DataService.CreateDataStoreInstance {
	Name = "PlayerData",
	ShouldAutoSave = true,
	AutoSaveInterval = 60,
	FailedRetryWaitTime = 5,

	DefaultData = (function()
		local maxSaveSlots = 10
		local defaultData = {}
		for i = 1, maxSaveSlots do
			defaultData[`SaveSlot{i}`] = table.clone({
				["Money"] = "500",
				["Unobtanium"] = 0,
				-- I'm not using RP it's a dumb mechanic
				--["RP"] = 0
			
				-- Crates
				["Crates"] = {
					["Regular"] = 0,
					["Unreal"] = 0,
					["Inferno"] = 0,
					["Exotic"] = 0,
					["Holiday"] = 0,
					["Godly"] = 0,
					["Galaxy"] = 0
				},
			
				["SacrificeLevel"] = 0,
				["LifeCount"] = 1,
			
				["Clovers"] = {
					["Regular"] = 0,
					["Gold"] = 0
				},
			
				Inventory = {
					{3, 1},
					{2, 20},
					{5, 1}
				},
			
				["BaseData"] = {
					PlacementInformation = {},
				}
			})
		end
		return defaultData
	end)()
}

function PlayerService.CharacterAdded(character: Model, player: Player)
	local HumanoidRootPart = character:WaitForChild("HumanoidRootPart")

	local Plot = player:WaitForChild("PlayerPlot")

	task.wait()
	HumanoidRootPart.CFrame = Plot.Value:FindFirstChild("Spawn").CFrame + Vector3.new(0, 25, 0)
end

function PlayerService.PlayerAdded(player: Player)
	for _, player in pairs(game.Players:GetPlayers()) do
		NetworkService.Fire("UpdateLeaderboard", player)
	end
	
	player.CharacterAdded:Connect(function(character)
		PlayerService.CharacterAdded(character, player)
	end)	

	local PlayerData = PlayerService.PlayerData:Load(player.UserId)

	local PlayerDataLoaded = Instance.new("BoolValue")
	PlayerDataLoaded.Name = "PlayerDataLoaded"
	PlayerDataLoaded.Parent = player

	local CurrentSaveSlot = Instance.new("StringValue")
	CurrentSaveSlot.Name = "CurrentSaveSlot"
	CurrentSaveSlot.Value = "SaveSlot1"
	CurrentSaveSlot.Parent = player

	PlayerData[CurrentSaveSlot.Value]["Money"] = "50"

	local Money = Instance.new("StringValue")
	Money.Name = "Money"
	Money.Parent = player

	Money.Value = PlayerData[CurrentSaveSlot.Value]["Money"] 

	Money.Changed:Connect(function()
		PlayerData[CurrentSaveSlot.Value]["Money"] = Money.Value

		for _, player in pairs(game.Players:GetPlayers()) do
			NetworkService.Fire("UpdateLeaderboard", player)
		end
	end)

	local Life = Instance.new("NumberValue")
	Life.Name = "Life"
	Life.Parent = player

	Life.Value = PlayerData[CurrentSaveSlot.Value]["LifeCount"] 

	Life.Changed:Connect(function()
		PlayerData[CurrentSaveSlot.Value]["LifeCount"] = Life.Value
		
		for _, player in pairs(game.Players:GetPlayers()) do
			NetworkService.Fire("UpdateLeaderboard", player)
		end
	end)

	BaseService.LoadBaseForPlayer(player)
end

function PlayerService.PlayerRemoving(player: Player)
	local basePlacement = BaseService.SerializeBaseForPlayer(player)

	local playerData = PlayerService.PlayerData:GetData(player.UserId)

	local currentSaveSlot = (player:FindFirstChild("CurrentSaveSlot") :: StringValue).Value
	playerData[currentSaveSlot]["BaseData"]["PlacementInformation"] = basePlacement

	PlayerService.PlayerData:Save(player.UserId)

	BaseService.UnloadBaseForPlayer(player)

	for _, player in pairs(game.Players:GetPlayers()) do
		NetworkService.Fire("UpdateLeaderboard", player)
	end
end

function PlayerService.GetPrefixesForPlayer(player: Player) : {{string | Color3}}
	local prefixes : {{string | Color3}} = {}

	if table.find(DeveloperList, player.UserId) then
		table.insert(prefixes, {"[DEV] ", Color3.fromRGB(199, 86, 26)})
	end

	return prefixes
end




return PlayerService
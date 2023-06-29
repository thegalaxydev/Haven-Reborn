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

local defaultData = {
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

	Inventory = {},

	["BaseData"] = {
		PlacementInformation = {},

		-- Default size IN 3x3 GRID SQUARES NOT STUDS
		BaseSize = {X = 25, Y = 25}
	}
}

PlayerService.PlayerData = DataService.CreateDataStoreInstance {
	Name = "PlayerData",
	ShouldAutoSave = true,
	AutoSaveInterval = 60,

	DefaultData = {
		["SaveSlot1"] = table.clone(defaultData),
		["SaveSlot2"] = table.clone(defaultData),
		["SaveSlot3"] = table.clone(defaultData),
		["SaveSlot4"] = table.clone(defaultData),
		["SaveSlot5"] = table.clone(defaultData),
		["SaveSlot6"] = table.clone(defaultData),
		["SaveSlot7"] = table.clone(defaultData),
		["SaveSlot8"] = table.clone(defaultData),
		["SaveSlot9"] = table.clone(defaultData),
		["SaveSlot10"] = table.clone(defaultData),

	}
}

function PlayerService.CharacterAdded(character: Model, player: Player)
	local HumanoidRootPart = character:WaitForChild("HumanoidRootPart")

	local Plot = player:WaitForChild("PlayerPlot")

	task.wait()
	HumanoidRootPart.CFrame = Plot.Value:FindFirstChild("Spawn").CFrame + Vector3.new(0, 25, 0)
end

function PlayerService.PlayerAdded(player: Player)
	player.CharacterAdded:Connect(function(character)
		PlayerService.CharacterAdded(character, player)
	end)	

	local PlayerData = PlayerService.PlayerData:Load(player.UserId)

	PlayerData["SaveSlot1"]["Inventory"] = {
		{3, 1},
		{2, 20},
		{4, 1},
		{5, 1}
	}

	
	
	local PlayerDataLoaded = Instance.new("BoolValue")
	PlayerDataLoaded.Name = "PlayerDataLoaded"
	PlayerDataLoaded.Parent = player

	local CurrentSaveSlot = Instance.new("StringValue")
	CurrentSaveSlot.Name = "CurrentSaveSlot"
	CurrentSaveSlot.Value = "SaveSlot1"
	CurrentSaveSlot.Parent = player

	PlayerData[CurrentSaveSlot.Value]["Money"] = "1"..("0"):rep(312)

	local Money = Instance.new("StringValue")
	Money.Name = "Money"
	Money.Parent = player

	Money.Value = PlayerData[CurrentSaveSlot.Value]["Money"] 


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
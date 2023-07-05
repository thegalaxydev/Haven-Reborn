local BaseService = {}

local BasePlots = workspace:FindFirstChild("BasePlots")
local DataService = require(script.Parent.DataService)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Directory = require(ReplicatedStorage:FindFirstChild("Directory"))

local NetworkService = Directory.Retrieve("Services/NetworkService")

BaseService.DefaultBaseSize = Vector2.new(50, 50)

local ItemDirectory = Directory.Retrieve("ItemDirectory")

--[[
	Grabs a base plot that's unowned.
	@return The first open plot found.
]]--
function BaseService.GetOpenBasePlot() : BasePart?
	if not BasePlots then return nil end

	for _, Plot in ipairs(BasePlots:GetChildren()) do
		if Plot:GetAttribute("Owner") == "" then
			return Plot
		end
	end

	return nil
end

--[[
	Loads a base for a player on an unowned base plot.
	@param player The player to load the base for.

]]--
function BaseService.LoadBaseForPlayer(player: Player)
	if not BasePlots then return end

	local Plot = BaseService.GetOpenBasePlot()
	if not Plot then return end

	Plot:SetAttribute("Owner", player.UserId)

	player:WaitForChild("PlayerDataLoaded")

	local PlayerData = DataService.DataInstances["PlayerData"]:GetData(player.UserId)
	local currentSaveSlot = player:FindFirstChild("CurrentSaveSlot")
	

	if not PlayerData then return end

	local BaseData = PlayerData[currentSaveSlot.Value]["BaseData"]
	local BaseSize = BaseService.DefaultBaseSize

	Plot.Base.Size = Vector3.new(BaseSize.X * 3, Plot.Base.Size.Y, BaseSize.Y * 3)
	
	local PlayerPlot = Instance.new("ObjectValue")
	PlayerPlot.Name = "PlayerPlot"
	PlayerPlot.Value = Plot
	PlayerPlot.Parent = player

	local PlacementInformation = BaseData.PlacementInformation

	for _, itemInfo in pairs(PlacementInformation) do
		local itemID = itemInfo[1]
		local itemPosition = itemInfo[2]
		local itemRotation = itemInfo[3]

		local item = ItemDirectory[itemID]

		local pos = Vector3.new(table.unpack(itemPosition)) + Plot.Base.Position
		local cf = CFrame.new(pos) * CFrame.fromEulerAnglesXYZ(table.unpack(itemRotation))

		item:Place(player, Plot, cf)
	end

	
end

--[[
	Unloads a base for a player.
	@param player The player to unload the base for.
]]--
function BaseService.UnloadBaseForPlayer(player: Player)
	if not BasePlots then return end

	for _, Plot in ipairs(BasePlots:GetChildren()) do
		if Plot:GetAttribute("Owner") == player.UserId then
			Plot:SetAttribute("Owner", "")

			
			for _, Item in pairs(Plot.Items:GetChildren()) do
				Item:Destroy()
			end

			Plot:FindFirstChild("Base").Size = Vector3.new(75, 1, 75)
		end
	end
end

function BaseService.GetBaseForPlayer(player: Player) : BasePart?
	if not BasePlots then return nil end

	for _, Plot in ipairs(BasePlots:GetChildren()) do
		if Plot:GetAttribute("Owner") == player.UserId then
			return Plot
		end
	end

	local PlayerPlot = player:FindFirstChild("PlayerPlot")
	if PlayerPlot then
		return PlayerPlot.Value
	end

	return nil
end

function getItemID(name: string)
	for id, item in pairs(ItemDirectory) do
		if item.Model.Name == name then
			return id
		end
	end

	return nil
end

function positionToBaseGrid(base: BasePart, position: Vector3) : Vector3
	local basePosition = base.Position


	local x = (position.X - basePosition.X)
	local y = (position.Y - basePosition.Y)
	local z = (position.Z - basePosition.Z)

	return x, y, z
end

function BaseService.SerializeBaseForPlayer(player: Player) : {any}
	local base = BaseService.GetBaseForPlayer(player)
	if not base then return {} end

	local Items = base:FindFirstChild("Items")
	if not Items then return {} end

	local ItemsData = {}

	for _, Item in ipairs(Items:GetChildren()) do
		local id = getItemID(Item.Name)

		if id then
			table.insert(ItemsData, {
				id, 
				{positionToBaseGrid(base.Base, Item.Hitbox.Position)}, 
				{Item.Hitbox.CFrame:ToEulerAnglesXYZ()}
			})
		end
	end

	return ItemsData
end


return BaseService
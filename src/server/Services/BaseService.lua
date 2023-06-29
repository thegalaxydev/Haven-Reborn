local BaseService = {}

local BasePlots = workspace:FindFirstChild("BasePlots")
local DataService = require(script.Parent.DataService)

BaseService.BaseData = DataService

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
	
	if not PlayerData then return end

	local BaseData = PlayerData["SaveSlot1"]["BaseData"]
	local BaseSize = BaseData.BaseSize

	Plot.Base.Size = Vector3.new(BaseSize.X * 3, Plot.Base.Size.Y, BaseSize.Y * 3)
	
	local PlayerPlot = Instance.new("ObjectValue")
	PlayerPlot.Name = "PlayerPlot"
	PlayerPlot.Value = Plot
	PlayerPlot.Parent = player
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

	return nil
end


return BaseService
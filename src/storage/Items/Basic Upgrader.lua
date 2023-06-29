local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Directory = require(ReplicatedStorage.Directory)
local Upgrader = Directory.Retrieve("Classes/Upgrader")

local Storage = ReplicatedStorage:FindFirstChild("ModelStorage")
local Model = Storage:FindFirstChild("Ore Purifier Machine")

return Upgrader.new{
	Name = "Basic Upgrader", 
	Model = Model,
	ID = 4,
	Image = "rbxassetid://205328631",
	Description = "Basic Upgrader Test",
	ConveyorSpeed = 10,
	Tier = 1,
	Cost = 100,
	DropRate = 0.5,
	DropSize = 1,
	DropWorth = 100,
	SellPrice = 50,

	UpgradeCallback = function(self, model, hit: BasePart, player: Player)
		if hit.Name ~= "Drop" then return end

		if hit:FindFirstChild("Upgraded") then
			print("Already Upgraded!")
			model.Model.Upgrade.Color = Color3.fromRGB(255, 0, 0)
			model.Model.Upgrade.Error:Play()
			task.wait(1)
			model.Model.Upgrade.Color = Color3.fromRGB(110, 153, 202)
			return 
		end

		local worth = hit:FindFirstChild("Worth")
		if not worth then return end

		worth.Value *= 2


		local tag = Instance.new("BoolValue")
		tag.Name = "Upgraded"
		tag.Parent = hit

		hit.Color = Color3.fromRGB(255, 0, 0)
	end
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Directory = require(ReplicatedStorage.Directory)
local Upgrader = Directory.Retrieve("Classes/Upgrader")

local Storage = ReplicatedStorage:FindFirstChild("ModelStorage")
local Model = Storage:FindFirstChild("Ore Purifier Machine")

return Upgrader.new{
	Name = "Basic Upgrader", 
	Model = Model,
	ID = 4,
	Image = "rbxassetid://211364004",
	Description = "Your first upgrader! Doubles the value of your ore, but only once.",
	ConveyorSpeed = 15,
	Tier = 1,
	Cost = 250,
	ShopCategory = "Upgraders",
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

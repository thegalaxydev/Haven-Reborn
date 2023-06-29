local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Directory = require(ReplicatedStorage.Directory)
local Furnace = Directory.Retrieve("Classes/Furnace")

local BigNumber = Directory.Retrieve("Classes/BigNumber")

local Storage = ReplicatedStorage:FindFirstChild("ModelStorage")
local Model = Storage:FindFirstChild("Basic Furnace")

return Furnace.new{
	Name = "Basic Furnace", 
	Model = Model,
	ID = 5,
	Image = "rbxassetid://205328631",
	Description = "Basic Upgrader Test",
	Tier = 1,
	Cost = 100,
	DropRate = 0.5,
	DropSize = 1,
	DropWorth = 100,
	SellPrice = 50,
	SellMultiplier = 1,

	SellCallback = function(self, hit: BasePart, player: Player)
		if hit.Name ~= "Drop" then return end

		local worth = hit:FindFirstChild("Worth")
		if not worth then return end

		local amount = BigNumber.new(worth.Value)
		local multiplier = BigNumber.new(self.SellMultiplier)

		local money = player:FindFirstChild("Money")
		if not money then return end

		local moneySerialized = BigNumber.new(money.Value)

		money.Value = tostring(moneySerialized + (amount * multiplier))

		hit:Destroy()
	end
}

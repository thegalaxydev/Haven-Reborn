local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Directory = require(ReplicatedStorage.Directory)
local Furnace = Directory.Retrieve("Classes/Furnace")

local BigNumber = Directory.Retrieve("Classes/BigNumber")

local Storage = ReplicatedStorage:FindFirstChild("ModelStorage")
local Model = Storage:FindFirstChild("Santa's Flying Sleigh")

return Furnace.new{
	Name = "Santa's Flying Sleigh", 
	Model = Model,
	ID = 6,
	Image = "rbxassetid://13947220495",
	Description = "Upgrades your ore a jolly x750 during the Christmas season, and x150 otherwise!",
	Tier = 44,
	Cost = 0,
	SellPrice = 0,
	SellMultiplier = os.date("*t").month == 12 and 750 or 150,

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

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Directory = require(ReplicatedStorage.Directory)
local Dropper = Directory.Retrieve("Classes/Dropper")

local Storage = ReplicatedStorage:FindFirstChild("ModelStorage")
local Model = Storage:FindFirstChild("Basic Iron Mine")

return Dropper.new{
	Name = "Basic Iron Mine", 
	Model = Model,
	ID = 3,
	Image = "rbxassetid://205328631",
	Description = "The first mine you can buy!",
	Tier = 1,
	Cost = 100,
	DropRate = 0.5,
	DropSize = 1,
	ShopCategory = "Droppers",
	DropWorth = 1,
	SellPrice = 20,

	DropCallback = function(self, dropPart: BasePart, player: Player)
		local plot = (player:FindFirstChild("PlayerPlot") :: ObjectValue).Value

		while dropPart.Parent ~= nil and player.Parent ~= nil do
			

			local drop = Instance.new("Part")
			drop.Name = "Drop"
			drop.Parent = plot.Drops

			drop.Material = Enum.Material.Metal
			drop.Color = Color3.fromRGB(183, 182, 182)

			drop.Size = Vector3.new(self.DropSize, self.DropSize, self.DropSize)
			drop.CFrame = dropPart.CFrame
			drop.Anchored = false

			local worth = Instance.new("NumberValue")
			worth.Name = "Worth"
			worth.Parent = drop
			worth.Value = self.DropWorth

			drop.Touched:Connect(function(hit)
				if not hit then return end
				if hit.Name == "Base" or hit.Parent.Name == "Map" then
					drop:Destroy()
				end
			end)		

			task.wait(self.DropRate)
		end
	end
}

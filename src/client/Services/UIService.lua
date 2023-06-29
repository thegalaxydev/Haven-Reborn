local UIService = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Directory = require(ReplicatedStorage:FindFirstChild("Directory"))
local BigNumber =  Directory.Retrieve("Classes/BigNumber")
local NetworkService = Directory.Retrieve("Services/NetworkService")

local UserInputService = game:GetService("UserInputService")
local Player = game.Players.LocalPlayer

local Main = Player.PlayerGui:WaitForChild("Main")

local HUD = Main.HUD

local Left = HUD.Left
local Right = HUD.Right

local InventoryButton = Left.Inventory.Holder.ImageButton

local Rarity = Directory.Retrieve("Classes/Rarity")

local Inventory = Main:WaitForChild("Inventory")

local Money = Player:WaitForChild("Money")

local Placeable = require(ReplicatedStorage.Directory.Classes.Placeable)
local ClientInformation = require(script.Parent.ClientInformation)

local ClientPlacementService = require(script.Parent.ClientPlacementService)

local Background = Inventory.InventoryBackground
local ItemHolder = Background.Inventory

local ItemSample = Inventory.Samples.ItemSample

local Info = Inventory.Info
local Search = Inventory.Search

local SortButtons = {}
for _, button in pairs(Search.SortOrder:GetChildren()) do
	if not button:IsA("TextButton") then continue end

	table.insert(SortButtons, button)
end

local buttonSelectedColor = Color3.fromRGB(143, 143, 143)
local buttonDeselectedColor = Color3.fromRGB(70, 70, 70)

local SortOrder = "Rarity"

local function UpdateInfo(item)
	Info.ItemImage.Image = item.Image
	Info.Rarity.Text = Rarity[item.Tier].Name
	Info.Rarity.TextColor3 = Rarity[item.Tier].TextColor
	Info.Rarity.BackgroundColor3 = Rarity[item.Tier].BackgroundColor
	Info.Description.Text = item.Description
	Info.ItemName.Text = item.Name
end

local function startswith(str: string, start: string)
	return string.sub(str, 1, string.len(start)) == start
end

function updateMoney()
	local value = BigNumber.new(Money.Value)
	local num, suffix = value:Unserialize("mh-notation", 2)
	Main.Money.Label.Text = num..suffix
end

updateMoney()
Money:GetPropertyChangedSignal("Value"):Connect(function()
	updateMoney()
end)


local function SortInventory()
	local items = {}

	local query = Search.SearchBox.Text

	for _, item in pairs(ItemHolder:GetChildren()) do
		if not item:IsA("TextButton") then continue end

		if query ~= "" then
			if not startswith(item.Name, query) then
				item.Visible = false
				continue
			end
		end
		item.Visible = true
		table.insert(items, item)
	end

	table.sort(items, function(a, b)
		if SortOrder == "Amount" then
			return a:GetAttribute("Amount") > b:GetAttribute("Amount")
		elseif SortOrder == "Sell" then
			return a:GetAttribute("Cost") > b:GetAttribute("Cost")
		end

		return a:GetAttribute("Tier") > b:GetAttribute("Tier")
	end)

	for index, item in pairs(items) do
		item.LayoutOrder = index
	end
end

Search.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
	SortInventory()
end)

for _, button in pairs(SortButtons) do
	button.MouseButton1Click:Connect(function()
		for _, button in pairs(SortButtons) do
			button.BackgroundColor3 = buttonDeselectedColor
		end

		button.BackgroundColor3 = buttonSelectedColor

		SortOrder = button.Name

		SortInventory()
	end)
end

function UIService.Toggle(name: string)
	if ClientInformation.IsPlacing then return end

	local frame = Main:FindFirstChild(name)

	if not frame then return end

	frame.Visible = not frame.Visible
end

function UIService.ToggleHUD(bool: boolean?)
	if bool ~= nil then
		Main.Enabled = bool
	else
		Main.Enabled = not Main.Enabled
	end
end

NetworkService.Create("UpdateInventory", function(inventory: {Placeable.Placeable})
	for _, item in pairs(ItemHolder:GetChildren()) do
		if not item:IsA("TextButton") then continue end
		item:Destroy()
	end

	for _, itemInfo in pairs(inventory) do
		local item = itemInfo[1]
		local count = itemInfo[2]

		local sample = ItemSample:Clone()
		sample.Name = item.Name
		sample.Icon.Image = item.Image

		sample.BackgroundColor3 = Rarity[item.Tier].BackgroundColor

		sample.Amount.Text = "x"..count

		sample:SetAttribute("Description", item.Description)
		sample:SetAttribute("Tier", item.Tier)
		sample:SetAttribute("Cost", item.Cost)
		sample:SetAttribute("Amount", count)

		sample.Parent = ItemHolder
		sample.Visible = true

		sample.MouseEnter:Connect(function()
			UpdateInfo(item)

			sample.Amount.Visible = true
		end)

		sample.MouseLeave:Connect(function()
			sample.Amount.Visible = false
		end)

		sample.MouseButton1Click:Connect(function()
			if ClientInformation.IsPlacing then return end
			ClientPlacementService.BeginPlacement(item)

			UIService.ToggleHUD(false)
		end)
	end

	SortInventory()
end)

NetworkService.Fire("RequestInventory")

InventoryButton.MouseButton1Click:Connect(function()
	UIService.Toggle("Inventory")
end)


return UIService
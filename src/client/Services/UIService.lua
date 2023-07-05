local UIService = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StarterGui = game:GetService("StarterGui")

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

local Directory = require(ReplicatedStorage:FindFirstChild("Directory"))
local BigNumber =  Directory.Retrieve("Classes/BigNumber")
local NetworkService = Directory.Retrieve("Services/NetworkService")

local UserInputService = game:GetService("UserInputService")
local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()
local Main = Player.PlayerGui:WaitForChild("Main")

local HUD = Main.HUD

local Left = HUD.Left
local Right = HUD.Right

local Leaderboard = Main.Leaderboard
local PlayerLeaderSample = Leaderboard.Sample.PlayerSample
local PlayerList = Leaderboard.Holder.PlayerList

local ControlsDisabled = false

local InventoryButton = Left.Inventory.Holder.Button

local ItemDirectory = Directory.Retrieve("ItemDirectory")

local Rarity = Directory.Retrieve("Classes/Rarity")

local Inventory = Main:WaitForChild("Inventory")

local Shop = Main:WaitForChild("Shop")
local ShopSearch = Shop.Search
local ShopBackground = Shop.Background
local ShopItemSample = Shop.Samples.ItemSample
local ShopInfo = Shop.Info
local ShopTabs = ShopSearch.Tab
local ShopSearchBox = ShopSearch.SearchBox
local Buy = ShopInfo.Buy
local BuyAmount = ShopInfo.Amount
local ShopPage = ShopBackground.PageLayout

local ItemGui = ReplicatedStorage.ItemGui
local InfoGui = ReplicatedStorage.InfoGui

local Money = Player:WaitForChild("Money")
local Life = Player:WaitForChild("Life")

local Placeable = require(ReplicatedStorage.Directory.Classes.Placeable)
local ClientInformation = require(script.Parent.ClientInformation)

local ClientPlacementService = require(script.Parent.ClientPlacementService)

local Background = Inventory.InventoryBackground
local ItemHolder = Background.Inventory

local ItemSample = Inventory.Samples.ItemSample

local InfoSample = Inventory.Samples.InfoSample
local Search = Inventory.Search

local selectedItem = nil
local highlightedItem = nil

local SortButtons = {}
for _, button in pairs(Search.SortOrder:GetChildren()) do
	if not button:IsA("TextButton") then continue end

	table.insert(SortButtons, button)
end

local buttonSelectedColor = Color3.fromRGB(143, 143, 143)
local buttonDeselectedColor = Color3.fromRGB(70, 70, 70)

local SortOrder = "Rarity"

local CurrentShopItem = nil

local function startswith(str: string, start: string)
	return string.sub(str, 1, string.len(start)) == start
end

local oldMoney = nil
Main.Money.Holder.Change.Visible = false
function updateMoney()
	local value = BigNumber.new(Money.Value)
	local num, suffix = value:Unserialize("mh-notation", 2)
	Main.Money.Holder.Label.Text = "$"..num..suffix

	if oldMoney then
		local change = value - oldMoney
		print(change)
		oldMoney = value

		local changeNum, changeSuffix = change:Unserialize("mh-notation", 1)
		
		Main.Money.Holder.Change.Text = change.Sign..changeNum..changeSuffix

		if change.Sign == "+" then
			Main.Money.Holder.Change.TextColor3 = Color3.fromRGB(81, 180, 89)
		else
			Main.Money.Holder.Change.TextColor3 = Color3.fromRGB(188, 2, 2)
		end

		Main.Money.Holder.Change.Visible = true

		task.wait(2)

		Main.Money.Holder.Change.Visible = false
	else
		oldMoney = value
		Main.Money.Holder.Change.Visible = false
	end

	
end

updateMoney()
Money:GetPropertyChangedSignal("Value"):Connect(function()
	updateMoney()
end)

for _, gui in pairs(Main:GetDescendants()) do
	if gui:IsA("GuiObject") and gui.Name == "XboxButton" then
		gui.Visible = UserInputService.GamepadEnabled
	end
end

UserInputService.GamepadConnected:Connect(function()
	for _, gui in pairs(Main:GetDescendants()) do
		if gui:IsA("GuiObject") and gui.Name == "XboxButton" then
			gui.Visible = true
		end
	end
end)



UserInputService.GamepadDisconnected:Connect(function()
	for _, gui in pairs(Main:GetDescendants()) do
		if gui:IsA("GuiObject") and gui.Name == "XboxButton" then
			gui.Visible = false
		end
	end
end)

function getItemID(name: string)
	for id, item in pairs(ItemDirectory) do
		if item.Model.Name == name then
			return id
		end
	end

	return nil
end

function UIService.WithdrawSelected()
	if not selectedItem then return end

	local id = getItemID(selectedItem.Name)
	if not id then return end

	
	NetworkService.Fire("WithdrawItem", id, selectedItem)
	selectedItem = nil
end

function UIService.SellSelected()
	if not selectedItem then return end

	local id = getItemID(selectedItem.Name)
	if not id then return end

	
	NetworkService.Fire("SellItem", id, selectedItem)
	selectedItem = nil
end

function UIService.MoveSelected()
	if not selectedItem then return end
end

function UIService.SelectItem(item)
	UIService.UnhighlightItem()
	if selectedItem then
		if selectedItem.Hitbox:FindFirstChild("ItemGui") then
			selectedItem.Hitbox.ItemGui:Destroy()
		end

		if selectedItem == item then 
			selectedItem = nil
			return
		end 

		selectedItem = nil
	end

	local itemInfo = ItemDirectory[getItemID(item.Name)]
	local gui = ItemGui:Clone()
	gui.Parent = item.Hitbox
	gui.Holder.NameText.Text = item.Name
	gui.Holder.Rarity.Text = Rarity[itemInfo.Tier].Name

	local selectionBox = Instance.new("SelectionBox")
	selectionBox.Name = "SelectBox"
	selectionBox.LineThickness = 0.15
	selectionBox.Parent = item.Hitbox
	selectionBox.Adornee = item.Hitbox
	selectionBox.Transparency = 0
	selectionBox.SurfaceTransparency= 1
	selectionBox.Color3 = Color3.fromRGB(33, 115, 230)


	gui.Holder.Move.MouseButton1Click:Connect(function()
		UIService.MoveSelected()
	end)

	gui.Holder.Sell.MouseButton1Click:Connect(function()
		UIService.SellSelected()
	end)

	gui.Holder.Withdraw.MouseButton1Click:Connect(function()
		UIService.WithdrawSelected()
	end)

	selectedItem = item
end

function UIService.HighlightItem(item)
	if selectedItem then 
		UIService.UnhighlightItem()
		return 
	end
	if highlightedItem then return end

	local selectionBox = Instance.new("SelectionBox")
	selectionBox.Name = "HighlightBox"
	selectionBox.LineThickness = 0.15
	selectionBox.Parent = item.Hitbox
	selectionBox.Adornee = item.Hitbox
	selectionBox.Transparency = 0
	selectionBox.SurfaceTransparency= 1
	selectionBox.Color3 = item.Hitbox.Color

	local itemInfo = ItemDirectory[getItemID(item.Name)]
	local gui = InfoGui:Clone()
	gui.Parent = item.Hitbox
	gui.Holder.NameText.Text = item.Name
	gui.Holder.Rarity.Text = Rarity[itemInfo.Tier].Name

	

	local beam = Instance.new("Part")
	beam.Name = "Beam"
	beam.Parent = workspace
	beam.Color = item.Hitbox.Color
	beam.Size = Vector3.new(item.Hitbox.Size.X, 900, item.Hitbox.Size.Z)
	beam.Material = Enum.Material.Neon
	beam.Transparency = 0.9
	beam.Anchored = true
	beam.CanCollide = false
	beam.PivotOffset = CFrame.new(Vector3.new(0, -450, 0))
	beam.CFrame = item.Hitbox.CFrame * CFrame.new(Vector3.new(0, -(item.Hitbox.Size.Y / 2), 0))


	highlightedItem = item
end

function UIService.UnhighlightItem()
	if highlightedItem then
		if highlightedItem.Hitbox:FindFirstChild("HighlightBox") then
			highlightedItem.Hitbox.HighlightBox:Destroy()
		end

		if highlightedItem.Hitbox:FindFirstChild("InfoGui") then
			highlightedItem.Hitbox.InfoGui:Destroy()
		end

		if workspace:FindFirstChild("Beam") then
			workspace.Beam:Destroy()
		end
	end

	highlightedItem = nil
end

function UIService.DeselectItem()
	if selectedItem then
		if selectedItem.Hitbox:FindFirstChild("ItemGui") then
			selectedItem.Hitbox.ItemGui:Destroy()
		end

		if selectedItem.Hitbox:FindFirstChild("SelectBox") then
			selectedItem.Hitbox.SelectBox:Destroy()
		end
	end

	selectedItem = nil
end

local function SortShop()
	local items = {}

	local query = ShopSearch.SearchBox.Text

	for _, item in pairs(ShopPage.CurrentPage:GetChildren()) do
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

	for _, page in pairs(ShopBackground:GetChildren()) do
		if not page:IsA("ScrollingFrame") then continue end

		if page == ShopPage.CurrentPage then continue end
		for _, item in pairs(page:GetChildren()) do
			if not item:IsA("TextButton") then continue end

			item.Visible = true
		end
	end

	table.sort(items, function(a, b)
		return a:GetAttribute("Cost") < b:GetAttribute("Cost")
	end)

	for index, item in pairs(items) do
		item.LayoutOrder = index
	end	
end

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

for _, tab in pairs(ShopTabs:GetChildren()) do
	if not tab:IsA("TextButton") then continue end

	tab.MouseButton1Click:Connect(function()
		for _, tab in pairs(ShopTabs:GetChildren()) do
			if not tab:IsA("TextButton") then continue end
			tab.BackgroundColor3 = buttonDeselectedColor
		end

		tab.BackgroundColor3 = buttonSelectedColor

		ShopPage:JumpTo(ShopBackground[tab.Name])

		SortShop()
	end)
end

ShopSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
	SortShop()
end)

function UIService.Toggle(name: string)
	if ClientInformation.IsPlacing then return end
	if ControlsDisabled then return end

	local frame = Main:FindFirstChild(name)

	if not frame then return end

	frame.Visible = not frame.Visible

	UIService.DeselectItem()
end

function UIService.ToggleHUD(bool: boolean)
	if not bool then
		Left:TweenPosition(UDim2.new(-0.5, 0, 0.5, 0), "Out", "Quad", 0.5, true)
		Right:TweenPosition(UDim2.new(1.5, 0, 0.5, 0), "Out", "Quad", 0.5, true)
		
		Inventory.Visible = false
		ControlsDisabled = true
	else
		Left:TweenPosition(UDim2.new(0, 0, 0.5, 0), "Out", "Quad", 0.5, true)
		Right:TweenPosition(UDim2.new(1, 0, 0.5, 0), "Out", "Quad", 0.5, true)	

		ControlsDisabled = false
	end
end

function UpdateShopInfo(item)
	ShopInfo.ItemImage.Image = item.Image
	ShopInfo.Rarity.Text = Rarity[item.Tier].Name
	ShopInfo.Rarity.TextColor3 = Rarity[item.Tier].TextColor
	ShopInfo.Rarity.BackgroundColor3 = Rarity[item.Tier].BackgroundColor
	ShopInfo.Description.Text = item.Description
	ShopInfo.ItemName.Text = item.Name
	ShopInfo.Cost.Text = item.Cost

	CurrentShopItem = item


end

Buy.MouseButton1Click:Connect(function()
	if not CurrentShopItem then 
		warn("No item selected")
		return 
	end

	NetworkService.Fire("BuyItem", CurrentShopItem)
end)

ShopInfo.Amount:GetPropertyChangedSignal("Text"):Connect(function()
	ShopInfo.Amount.Text = string.gsub(ShopInfo.Amount.Text, "%D", "")

	local amount = tonumber(ShopInfo.Amount.Text)

	if not amount then
		ShopInfo.Amount.Text = 1
		return
	end

	if amount > 999 then
		ShopInfo.Amount.Text = 999
		return
	end

	if amount < 1 then
		ShopInfo.Amount.Text = 1
		return
	end
end)

local function UpdateShop()
	for id, item in pairs(ItemDirectory) do
		if not item.ShopCategory then 
			print("Item " .. item.Name .. " does not have a shop category")
			continue 
		end

		local sample = ShopItemSample:Clone()
		sample.Name = item.Name
		sample.Icon.Image = item.Image

		sample.BackgroundColor3 = Rarity[item.Tier].BackgroundColor

		sample.Icon.ItemName.Text = item.Name

		sample:SetAttribute("Description", item.Description)
		sample:SetAttribute("Tier", item.Tier)
		sample:SetAttribute("Cost", item.Cost)

		sample.Parent = ShopBackground[item.ShopCategory]
		sample.Visible = true

		sample.MouseEnter:Connect(function()
			sample.BackgroundColor3 = Color3.new(1,1,1)
			sample.Icon.ItemName.Visible = true
		end)

		sample.MouseLeave:Connect(function()
			sample.BackgroundColor3 = Rarity[item.Tier].BackgroundColor
			sample.Icon.ItemName.Visible = false
		end)

		sample.MouseButton1Click:Connect(function()
			UpdateShopInfo(item)
		end)		

		SortShop()
	end
end

NetworkService.Create("UpdateInventory", function(inventory: {Placeable.Placeable})
	for _, item in pairs(ItemHolder:GetChildren()) do
		if not item:IsA("TextButton") then continue end
		item:Destroy()
	end

	for _, itemInfo in pairs(inventory) do
		local itemId = itemInfo[1]
		local count = itemInfo[2]

		local item = ItemDirectory[itemId]

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

		local infoSample = nil
		local event = nil

		sample.MouseEnter:Connect(function()
			infoSample = InfoSample:Clone()
			infoSample.ItemImage.Image = item.Image
			infoSample.Rarity.Text = Rarity[item.Tier].Name
			infoSample.Rarity.TextColor3 = Rarity[item.Tier].TextColor
			infoSample.Rarity.BackgroundColor3 = Rarity[item.Tier].BackgroundColor
			infoSample.Description.Text = item.Description
			infoSample.ItemName.Text = item.Name
			infoSample.Visible = true
			infoSample.Parent = Main

			
			local mousePos = UserInputService:GetMouseLocation()
			InfoSample.Position = UDim2.new(0, mousePos.X + 10, 0, mousePos.Y + 10)

			sample.BackgroundColor3 = Color3.new(1,1,1)
			sample.Amount.Visible = true

			event = game:GetService("RunService").RenderStepped:Connect(function()
				local mousePos = UserInputService:GetMouseLocation()
				infoSample.Position = UDim2.new(0, mousePos.X + 10, 0, mousePos.Y + 10)
			end)
		end)

		sample.MouseLeave:Connect(function()
			if infoSample then
				infoSample:Destroy()
			end
			if event then
				event:Disconnect()
			end

			sample.Amount.Visible = false
			sample.BackgroundColor3 = Rarity[item.Tier].BackgroundColor
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

Left.Shop.Holder.Button.MouseButton1Click:Connect(function()
	UIService.Toggle("Shop")
end)

ClientPlacementService.PlacementEnded:Connect(function()
	UIService.ToggleHUD(true)
end)

local function formatLife(text: string)
	-- add numeric suffix

	local suffix = "th"

	if text:sub(-1) == "1" then
		suffix = "st"
	elseif text:sub(-1) == "2" then
		suffix = "nd"
	elseif text:sub(-1) == "3" then
		suffix = "rd"
	end

	return text..suffix

end

local leaderboardActive = true
function UIService.ToggleLeaderboard()
	if not leaderboardActive then
		Leaderboard:TweenPosition(UDim2.new(1, 0, 0, 0), "Out", "Quad", 0.5, true)
	else
		Leaderboard:TweenPosition(UDim2.new(1.25, 0, 0, 0), "In", "Quad", 0.5, true)
	end

	leaderboardActive = not leaderboardActive
end

function UIService.UpdateLeaderboard()
	for _, v in pairs(PlayerList:GetChildren()) do
		if not v:IsA("Frame") then continue end
		v:Destroy()
	end

	local playerFrame = PlayerLeaderSample:Clone()
	playerFrame.Name = Player.Name
	playerFrame.Parent = PlayerList
	playerFrame.PlayerName.Text = Player.Name
	playerFrame.PlayerName.TextColor3 = Color3.fromRGB(246, 238, 89)
	local playerMoney, moneySuffix = BigNumber.new(Money.Value):Unserialize("mh-notation")
	playerFrame.Money.Text = "$"..playerMoney..moneySuffix
	playerFrame.Life.Text = formatLife(tostring(Life.Value))
	playerFrame.LayoutOrder = -math.huge
	playerFrame.Visible = true

	for _, player in pairs(game.Players:GetPlayers()) do
		if player == Player then continue end

		local life = player:WaitForChild("Life").Value
		local sample = PlayerLeaderSample:Clone()
		sample.Name = player.Name
		sample.Parent = PlayerList
		sample.PlayerName.Text = player.Name
		local money, suffix = BigNumber.new(player:WaitForChild("Money").Value):Unserialize("mh-notation")
		sample.Money.Text = "$"..money..suffix
		sample.Life.Text = formatLife(tostring(life))
		sample.Visible = true
		sample.LayoutOrder = -life

		-- sort by Life

	end
end

UIService.UpdateLeaderboard()

UpdateShop()

NetworkService.Create("UpdateLeaderboard", UIService.UpdateLeaderboard)

local base = Player:FindFirstChild("PlayerPlot").Value

game:GetService("RunService"):BindToRenderStep("DisplayItemInfo", 1, function()
	local hit = Mouse.Hit

	local cameraPos = workspace.CurrentCamera.CFrame.Position
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Include

	local include = {}
	for _, child in pairs(base.Items:GetChildren()) do
		table.insert(include, child.Hitbox)
	end

	rayParams.FilterDescendantsInstances = include

	local rayResult = workspace:Raycast(cameraPos, (hit.p - cameraPos).Unit * 1000, rayParams)

	if rayResult then
		local Item = rayResult.Instance.Parent
	
		UIService.HighlightItem(Item)
		
		return
	end

	UIService.UnhighlightItem()
end)

return UIService
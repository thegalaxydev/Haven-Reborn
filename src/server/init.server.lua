local Services = script.Services

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Directory = require(ReplicatedStorage:FindFirstChild("Directory"))

local DataService = require(Services.DataService)
local BigNumber = Directory.Retrieve("Classes/BigNumber")

local ChatService = Directory.Retrieve("Services/ChatService")
local CommandService = Directory.Retrieve("Services/CommandService")
local NameColorService = Directory.Retrieve("Services/NameColorService")

local TextService = game:GetService("TextService")

local NetworkService = Directory.Retrieve("Services/NetworkService")

local ChatMessage = Directory.Retrieve("Classes/ChatMessage")

local PlayerService = require(Services.PlayerService)

game.Players.PlayerAdded:Connect(PlayerService.PlayerAdded)
game.Players.PlayerRemoving:Connect(PlayerService.PlayerRemoving)

local ItemDirectory = require(ReplicatedStorage.Directory.ItemDirectory)

NetworkService.Create("RequestInventory", function(player: Player)
	local playerData = DataService.DataInstances["PlayerData"]:GetData(player.UserId)

	if not playerData then return false end

	local currentSaveSlot = player:FindFirstChild("CurrentSaveSlot")
	if not currentSaveSlot then return false end

	local inventory = {}

	local playerInventory = playerData[currentSaveSlot.Value].Inventory
	for index, info in pairs(playerInventory) do
		table.insert(inventory, {
			[1] = info[1], [2] = info[2]
		})
	end

	NetworkService.Fire("UpdateInventory", player, inventory)

	return true
end)

NetworkService.Create("PlaceItem", function(player: Player, itemName: string, cf: CFrame)
	local items = ReplicatedStorage.Storage.Items

	local currentSaveSlot = player:FindFirstChild("CurrentSaveSlot")
	if not currentSaveSlot then 
		print("No save slot") 
		return 
	end

	local base = (player:FindFirstChild("PlayerPlot")::ObjectValue).Value

	if not base then 
		print("no base") 
		return 
	end

	local item = items:FindFirstChild(itemName)

	if not item then 
		print("no item")
		return 
	end

	item = require(item)

	local playerData = DataService.DataInstances["PlayerData"]:GetData(player.UserId)
	local playerInventory = playerData[currentSaveSlot.Value].Inventory
	for index, info in pairs(playerInventory) do
		local id = info[1]
		local amount = info[2]

		if id == item.ID then
			if amount <= 0 then 
				table.remove(playerInventory, index)
				return 
			end

			playerInventory[index][2] -= 1

			if playerInventory[index][2] <= 0 then 
				table.remove(playerInventory, index)
				NetworkService.Fire("CancelPlaceItem", player)
			end
			break
		end
	end

	local inventory = {}

	for index, info in pairs(playerInventory) do
		local id = info[1]
		local amount = info[2]

		table.insert(inventory, {
			[1] = id, [2] = amount
		})
	end

	NetworkService.Fire("UpdateInventory", player, inventory)
	item:Place(player, base, cf)
end)

NetworkService.Create("WithdrawItem", function(player: Player, id: number, item: Model)
	 print("Withdrawing item")
	local playerData = DataService.DataInstances["PlayerData"]:GetData(player.UserId)

	if not playerData then 
		print("No playerdata.")
		return false 
	end

	local currentSaveSlot = player:FindFirstChild("CurrentSaveSlot")
	if not currentSaveSlot then 
		print("No save slot")
		return false 
	end

	local inventory = {}

	local itemFound = false
	for index, info in pairs(playerData[currentSaveSlot.Value].Inventory) do
		local itemId = info[1]
		local amount = info[2]
		
		if itemId == id then
			print("Item found")
			playerData[currentSaveSlot.Value].Inventory[index][2] += 1
			amount += 1
			itemFound = true
		end

		table.insert(inventory, {
			[1] = itemId, [2] = amount
		})
	end

	if not itemFound then
		print("Creating item")
		table.insert(playerData[currentSaveSlot.Value].Inventory, {
			[1] = id, [2] = 1
		})

		table.insert(inventory, {
			[1] = id, [2] = 1
		})
	end


	NetworkService.Fire("UpdateInventory", player, inventory)
	item:Destroy()
	return true
end)

NetworkService.Create("SellItem", function(player: Player, id: number, item: Model)
	local itemData = ItemDirectory[id]
	if itemData == nil or itemData.SellPrice == 0 then return end
	item:Destroy()

	local playerData = DataService.DataInstances["PlayerData"]:GetData(player.UserId)

	if not playerData then return false end

	local currentSaveSlot = player:FindFirstChild("CurrentSaveSlot")
	if not currentSaveSlot then return false end

	
	
	local money = BigNumber.new(playerData[currentSaveSlot.Value].Money)

	money += BigNumber.new(itemData.SellPrice)

	local playerMoney = player:FindFirstChild("Money")
	playerMoney.Value = tostring(money)

	return true
end)

NetworkService.Create("BuyItem", function(player: Player, item, numberOfItems: number?)
	local itemData = ItemDirectory[item.ID]
	if itemData == nil then return end

	local playerData = DataService.DataInstances["PlayerData"]:GetData(player.UserId)

	if not playerData then 
		print("No playerdata.")
		return false 
	end

	local currentSaveSlot = player:FindFirstChild("CurrentSaveSlot")
	if not currentSaveSlot then return false end

	local money = BigNumber.new(playerData[currentSaveSlot.Value].Money)
	local price = BigNumber.new(itemData.Cost * numberOfItems or 1)

	if money < price then return false end

	money -= price

	local playerMoney = player:FindFirstChild("Money")
	playerMoney.Value = tostring(money)

	local inventory = {}

	local itemFound = false
	for index, info in pairs(playerData[currentSaveSlot.Value].Inventory) do
		local itemId = info[1]
		local amount = info[2]
		
		if itemId == item.ID then
			playerData[currentSaveSlot.Value].Inventory[index][2] += numberOfItems or 1
			amount += numberOfItems or 1
			itemFound = true
		end

		table.insert(inventory, {
			[1] = itemId, [2] = amount
		})
	end

	if not itemFound then
		print("Creating item")
		table.insert(playerData[currentSaveSlot.Value].Inventory, {
			[1] = item.ID, [2] = numberOfItems or 1
		})

		table.insert(inventory, {
			[1] = item.ID, [2] = numberOfItems or 1
		})
	end

	NetworkService.Fire("UpdateInventory", player, inventory)

	return true
end)

function randomColor()
	return Color3.fromRGB(math.random(125,255), math.random(125,255), math.random(125,255))
end


CommandService.RegisterCommand("/shout", function(player: Player, args: {any})
	if player.Name ~= "7F4X" then
		return false, "You do not have permission to use this command."
	end

	local filteredText = ""
	pcall(function()
		filteredText = TextService:FilterStringAsync(table.concat(args, " "), player.UserId, 
			Enum.TextFilterContext.PublicChat):GetNonChatStringForBroadcastAsync()
	end)

	local color = randomColor()
	local shoutMsg = ChatMessage.new(filteredText, Enum.Font.SourceSansBold, color)
	shoutMsg:AppendPrefix(`[{player.DisplayName}'s Shout] `, color)

	ChatService.SendMessage(shoutMsg, game.Players:GetPlayers())

	return true
end)

CommandService.RegisterCommand("/w", function(player: Player, args: {any})
	local recipient = game.Players:FindFirstChild(args[1])
	if not recipient then
		return false, "Player not found."
	end

	if player == recipient then
		return false, "You cannot send a private message to yourself."
	end

	local senderNameColor = NameColorService.GetNameColor(player)

	local sendMsg = ChatMessage.new(table.concat(args, " ", 2))
	sendMsg:AppendPrefix(`\{To {recipient.Name}} `, Color3.new(1,1,1))
	sendMsg:AddSender(player, senderNameColor)

	local confirmMsgSender = ChatMessage.new(`You are now privately chatting with {recipient.Name}.`)
	confirmMsgSender:AppendPrefix(`\{To {recipient.Name}} `, Color3.new(1,1,1))
	
	ChatService.SendMessage(confirmMsgSender, {player})
	ChatService.SendMessage(sendMsg, {player})

	local filteredText = ""
	local success, error = pcall(function()
		filteredText = TextService:FilterStringAsync(table.concat(args, " ", 2), player.UserId, 
			Enum.TextFilterContext.PrivateChat):GetChatForUserAsync(recipient.UserId)
	end)
	
	if not success then
		return false, error
	end

	local receiveMsg = ChatMessage.new(filteredText)
	receiveMsg:AppendPrefix(`\{From {player.Name}} `, Color3.new(1,1,1))
	receiveMsg:AddSender(player, senderNameColor)

	local confirmMsgReceiver = ChatMessage.new(`You are now privately chatting with {player.Name}.`)
	confirmMsgReceiver:AppendPrefix(`\{From {player.Name}} `, Color3.new(1,1,1))

	ChatService.SendMessage(confirmMsgReceiver, {recipient})
	ChatService.SendMessage(receiveMsg, {recipient})

	return true
end)
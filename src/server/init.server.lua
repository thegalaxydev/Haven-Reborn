local Services = script.Services

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Directory = require(ReplicatedStorage:FindFirstChild("Directory"))

local DataService = require(Services.DataService)
local BigNumber = Directory.Retrieve("Classes/BigNumber")

local ChatService = Directory.Retrieve("Services/ChatService")
local CommandService = Directory.Retrieve("Services/CommandService")
local NameColorService = Directory.Retrieve("Services/NameColorService")

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
		local id = info[1]
		local amount = info[2]


		local item = ItemDirectory[id]


		if item then
			table.insert(inventory, {
				[1] = item, [2] = amount
			})
		end
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

		local i = ItemDirectory[id]

		if i then
			table.insert(inventory, {
				[1] = i, [2] = amount
			})
		end
	end

	NetworkService.Fire("UpdateInventory", player, inventory)
	item:Place(player, base, cf)
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

	local receiveMsg = ChatMessage.new(table.concat(args, " ", 2))
	receiveMsg:AppendPrefix(`\{From {player.Name}} `, Color3.new(1,1,1))
	receiveMsg:AddSender(player, senderNameColor)

	local confirmMsgReceiver = ChatMessage.new(`You are now privately chatting with {player.Name}.`)
	confirmMsgReceiver:AppendPrefix(`\{From {player.Name}} `, Color3.new(1,1,1))

	ChatService.SendMessage(confirmMsgReceiver, {recipient})
	ChatService.SendMessage(receiveMsg, {recipient})

	return true
end)

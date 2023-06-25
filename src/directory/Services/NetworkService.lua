local RunService = game:GetService("RunService")

local Event = require(script.Parent.Parent.Classes.Event)

local RemoteEvent = Instance.new("RemoteEvent")
local RemoteFunction = Instance.new("RemoteFunction")

local ServerNetwork = Instance.new("Folder")
ServerNetwork.Name = "ServerNetwork"
ServerNetwork.Parent = game:GetService("ServerStorage")

local Bindable = Event.new()

local NetworkService = {}

NetworkService.Log = {}

local Methods = {
	["FireServer"] = RemoteEvent.FireServer,
	["FireClient"] = RemoteEvent.FireClient,
	["FireAllClients"] = RemoteEvent.FireAllClients,
	["InvokeServer"] = RemoteFunction.InvokeServer,
	["InvokeClient"] = RemoteFunction.InvokeClient,

	["Fire"] = Bindable.Fire,

	["FireClients"] = function(obj: RemoteEvent, players: {Player}, ...)
		for _, player in pairs(players) do
			obj:FireClient(player, ...)
		end
	end,

	["FireAllClientsWithExclude"] = function(obj: RemoteEvent, excluded: {Player}, ...)
		for _, player in pairs(game.Players:GetPlayers()) do
			if not table.find(excluded, player) then
				obj:FireClient(player, ...)
			end
		end
	end,

	["FireAllClientWithCheck"] = function(obj: RemoteEvent, callback: (Player) -> boolean, ...)
		for _, player in pairs(game.Players:GetPlayers()) do
			if callback(player) then
				obj:FireClient(player, ...)
			end
		end
	end,

	["InvokeClients"] = function(obj: RemoteFunction, players: {Player}, ...)
		local results = {}

		for _, player in pairs(players) do
			table.insert(results, obj:InvokeClient(player, ...))
		end

		return results
	end,

	["InvokeAllClients"] = function(obj: RemoteFunction, ...)
		local results = {}

		for _, player in pairs(game.Players:GetPlayers()) do
			table.insert(results, obj:InvokeClient(player, ...))
		end

		return results
	end,

	["InvokeAllClientsWithExclude"] = function(obj: RemoteFunction, excluded: {Player}, ...)
		local results = {}

		for _, player in pairs(game.Players:GetPlayers()) do
			if not table.find(excluded, player) then
				table.insert(results, obj:InvokeClient(player, ...))
			end
		end

		return results
	end,

	["InvokeAllClientsWithCheck"] = function(obj: RemoteFunction, callback: (Player) -> boolean, ...)
		local results = {}

		for _, player in pairs(game.Players:GetPlayers()) do
			if callback(player) then
				table.insert(results, obj:InvokeClient(player, ...))
			end
		end

		return results
	end,
}

function NetworkService.Create(name: string, class: string, connection: string, func: ()->())
	if script:FindFirstChild(name) == nil then
		local obj = Instance.new(class)
		obj.Name = name		
						
		if connection and func then
			if class == "BindableEvent" or class == "RemoteEvent" then
				local event = obj[connection]:connect(func)
				obj.Parent = script
				
				return obj, event
			elseif class == "BindableFunction" or class == "RemoteFunction" then
				obj[connection] = func
				obj.Parent = script
				
				return obj
			end
		end
		
		obj.Parent = script

		return obj
	else
		local obj = script[name]
		if connection ~= nil and func ~= nil then
			if class == "BindableEvent" or class == "RemoteEvent" then
				local event = obj[connection]:connect(func)
				obj.Parent = script
				
				return obj, event
			elseif class == "BindableFunction" or class == "RemoteFunction" then
				obj[connection] = func
				obj.Parent = script
				
				return obj
			end
		end
		
		return obj
	end
end

function NetworkService:Connect(name: string, connection: string, func: ()->())
	local obj
	
	if RunService:IsServer() then
		if connection == "OnServerInvoke" then
			connection = "OnInvoke"
			obj = game.ServerStorage.serverNetwork:WaitForChild(name)	
		elseif connection == "Event" or connection == "OnInvoke" then
			obj = game.ServerStorage.serverNetwork:WaitForChild(name)	
		else
			obj = script:WaitForChild(name)
		end
	else
		obj = script:WaitForChild(name)
	end		
	
	if obj.ClassName == "BindableEvent" or obj.ClassName == "RemoteEvent" then
		local event = obj[connection]:connect(func)
		return obj, event
	elseif obj.ClassName == "BindableFunction" or obj.ClassName == "RemoteFunction" then
		obj[connection] = func
	end

	return obj
end

local function report(name: string, method: string)
	NetworkService.Log[method] = NetworkService.Log [method] or {}
	NetworkService.Log[method][name] = (NetworkService.Log[method][name] or 0) + 1
end

function NetworkService:InvokeServer(name: string, ...)
	report(name, "invokeServer")
	local playerRequest = game.ReplicatedStorage:WaitForChild("PlayerRequest")
	if playerRequest then
		return playerRequest:InvokeServer(name, ...)
	else
		error("playerRequest not found.")
	end
end

setmetatable(NetworkService, {
	__index = function(self, index)
		return function(self, name: string, ...)
			script:WaitForChild(name, 60)
			report(name, index)

			return Methods[index](script[name], ...)
		end
	end
})


return NetworkService
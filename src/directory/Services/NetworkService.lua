local NetworkService = {}

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Event = require(ReplicatedStorage.Directory.Classes.Event)

NetworkService.Callbacks = {}
NetworkService.Connections = {}

NetworkService.Events = {}

if RunService:IsServer() then
	local Remotes = Instance.new("Folder")
	Remotes.Name = "Remotes"
	Remotes.Parent = ReplicatedStorage

	local ServerReplicator = Instance.new("RemoteFunction")
	ServerReplicator.Name = "ServerReplicator"
	ServerReplicator.Parent = Remotes

	ServerReplicator.OnServerInvoke = function(player: Player, name: string, ...)
		if not NetworkService.Callbacks[name] then return nil end
		
		return NetworkService.Callbacks[name](player, ...)
	end

	local ClientReplicator = Instance.new("RemoteEvent")
	ClientReplicator.Name = "ClientReplicator"
	ClientReplicator.Parent = Remotes
end

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local ServerReplicator = Remotes:WaitForChild("ServerReplicator")
local ClientReplicator = Remotes:WaitForChild("ClientReplicator")

if RunService:IsClient() then
	ClientReplicator.OnClientEvent:Connect(function(name: string, ...)
		if NetworkService.Callbacks[name] then
			NetworkService.Callbacks[name](...)
		end
	end)
end


function NetworkService.Create(name: string, callback: (any) -> any)
	NetworkService.Callbacks[name] = callback
end

function NetworkService.Connect(name: string, callback: (any) -> any)
	if not NetworkService.Connections[name] then
		NetworkService.Connections[name] = Event.new()
	end

	NetworkService.Connections[name]:Connect(callback)
end

function NetworkService.FireBind(name: string, ...)
	if NetworkService.Connections[name] then
		NetworkService.Connections[name]:Fire(...)
	end
end

function NetworkService.Fire(name: string, ...) : any?

	if RunService:IsServer() then
		local args = {...}
		ClientReplicator:FireClient(args[1], name, table.unpack(args, 2))

		return nil
	else
		return ServerReplicator:InvokeServer(name, ...)
	end
end

function NetworkService.FireAllClients(name: string, ...)
	if RunService:IsServer() then
		local args = {...}
		ClientReplicator:FireAllClients(name, table.unpack(args))
	end
end



return NetworkService
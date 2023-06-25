local DataService = {}
local DataStoreInstance = require(script.DataStoreInstance)

type DataStoreInstance = DataStoreInstance.DataStoreInstance

DataService.DataInstances = {}

function DataService.CreateDataStoreInstance(params: DataStoreInstance.DataStoreParameters) : DataStoreInstance
	local DataStore = DataStoreInstance.new(params)

	DataService.DataInstances[params.Name] = DataStore

	return DataStore
end


return DataService
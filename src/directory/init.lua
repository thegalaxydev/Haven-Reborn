local Directory = {}

Directory.Cache = {}

function Directory.Retrieve<T>(path: string) : (T? | Instance, string)
	local split = string.split(path, "/")
	local current = script
	for i = 1, #split do
		if current then
			current = current:FindFirstChild(split[i])
		else
			return nil, "Path not found."
		end
	end

	if not current then return nil, "Path not found." end

	if current:IsA("ModuleScript") then
		current = require(current)
		return current :: typeof(current), "Module retrieved."
	end

	

	return current, "Directory retrieved."
end


return Directory

local lmaoget = {}

print("Registering cli commands...")
require("src.cli.cli")

print("Updating package cache...")
local api = require("src.core.api")

local success, error = api.update()
if not success then
    print(string.format("Failed to update: %s", error))
    return
end

print("Package cache updated")

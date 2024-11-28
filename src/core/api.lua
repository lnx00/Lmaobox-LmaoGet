local Common = require("src.common.common")
local Packages = require("src.core.packages")

local fs = Common.lmaolib.utils.fs

local WORKSPACE_PATH = "./LmaoGet"
local PACKAGE_PATH = string.format("%s/packages", WORKSPACE_PATH)

filesystem.CreateDirectory(WORKSPACE_PATH)
filesystem.CreateDirectory(PACKAGE_PATH)

---@class LmaoGetApi
local LmaoGetApi = {}

-- Updates the package cache
function LmaoGetApi.update()
    Packages.update_cache()
end

-- Returns package ids that match the given name
---@param package_name string
---@return string[]
function LmaoGetApi.find(package_name)
    local packages = Packages.find(package_name)
    local results = {}

    for full_id, _ in pairs(packages) do
        table.insert(results, full_id)
    end

    return results
end

-- Installs a package by repo and package id
---@param repo_id string
---@param package_id string
---@return boolean, string?
function LmaoGetApi.install(repo_id, package_id)
    local package = Packages.get(repo_id, package_id)
    if not package then
        return false, string.format("Package '%s' not found in repository '%s'", package_id, repo_id)
    end

    local package_data = http.Get(package.url)
    if not package_data then
        return false, string.format("Failed to download package '%s'", package_id)
    end

    local file_name = string.format("%s_%s.lua", repo_id, package_id)
    --local file_path = string.format("%s/%s", os.getenv("localappdata"), file_name)
    local file_path = string.format("%s/%s", PACKAGE_PATH, file_name)
    fs.write(file_path, package_data)

    return true
end

return LmaoGetApi
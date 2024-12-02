local common = require("src.common.common")
local packages = require("src.core.packages")
local installer = require("src.core.installer")

local WORKSPACE_PATH = "./LmaoGet"
filesystem.CreateDirectory(WORKSPACE_PATH)

---@class LmaoGetApi
local LmaoGetApi = {}

-- Updates the package cache
function LmaoGetApi.update()
    packages.update_cache()
end

-- Returns package ids that match the given name
---@param package_name string
---@return string[]
function LmaoGetApi.find(package_name)
    local package_list = packages.find(package_name)
    local results = {}

    for full_id, _ in pairs(package_list) do
        table.insert(results, full_id)
    end

    return results
end

-- Installs a package by repo and package id
---@param repo_id string
---@param package_id string
---@return boolean, string?
function LmaoGetApi.install(repo_id, package_id)
    if installer.is_installed(repo_id, package_id) then
        return false, "Package is already installed! Use 'upgrade' to update it."
    end

    local package_info = packages.get(repo_id, package_id)
    if not package_info then
        return false, string.format("Package '%s' not found in repository '%s'", package_id, repo_id)
    end

    return installer.install_package(repo_id, package_info)
end

-- Uninstalls a package by repo and package id
---@param repo_id string
---@param package_id string
---@return boolean, string?
function LmaoGetApi.uninstall(repo_id, package_id)
    if not installer.is_installed(repo_id, package_id) then
        return false, "Package is not installed!"
    end

    return installer.uninstall_package(repo_id, package_id)
end

return LmaoGetApi
local Common = require("src.common.common")
local Packages = require("src.core.packages")
local installer = require("src.core.installer")

local fs = Common.lmaolib.utils.fs

local WORKSPACE_PATH = "./LmaoGet"
filesystem.CreateDirectory(WORKSPACE_PATH)

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
    if installer.is_installed(repo_id, package_id) then
        return false, "Package is already installed! Use 'upgrade' to update it."
    end

    local package_info = Packages.get(repo_id, package_id)
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
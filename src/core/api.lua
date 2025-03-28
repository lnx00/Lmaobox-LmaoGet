local common = require("src.common.common")
local config = require("src.common.config")
local packages = require("src.core.package_manager")
local installer = require("src.core.installer")

filesystem.CreateDirectory(config.get_workspace_path())

---@class LmaoGetApi
local api = {}

-- Updates the package cache
function api.update()
    packages.update_cache()
    installer.load_info()
end

-- Returns package ids that match the given name
---@param package_name string
---@return string[]
function api.find(package_name)
    local package_list = packages.find(package_name)
    local results = {}

    for full_id, _ in pairs(package_list) do
        table.insert(results, full_id)
    end

    return results
end

-- Returns a list of installed packages
---@return string[]
function api.list()
    local results = {}

    for full_id, _ in pairs(installer.installed) do
        table.insert(results, full_id)
    end

    return results
end

-- Installs a package by repo and package id
---@param full_id string
---@return boolean, string?
function api.install(full_id)
    local package_info = packages.get(full_id)
    if not package_info then
        return false, "package not found"
    end

    return installer.install_package(package_info)
end

-- Uninstalls a package by repo and package id
---@param full_id string
---@return boolean, string?
function api.uninstall(full_id)
    if not installer.is_installed(full_id) then
        return false, "package is not installed"
    end

    return installer.uninstall_package(full_id)
end

-- Upgrades a package by repo and package id
---@param full_id string
---@return boolean, string?
function api.upgrade(full_id)
    local installed_package = installer.find(full_id)
    if not installed_package then
        return false, "no such package installed"
    end

    local package_info = packages.get(full_id)
    if not package_info then
        return false, "package does not exist anymore"
    end

    -- Is the package already up to date?
    if common.compare_versions(installed_package.version, package_info.version) >= 0 then
        return false, "package is already up to date"
    end

    -- Uninstall old package
    local success, err = installer.uninstall_package(full_id)
    if not success then
        return false, err
    end

    return installer.install_package(package_info)
end

return api

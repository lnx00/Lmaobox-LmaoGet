local utils = require("src.common.utils")
local config = require("src.common.config")
local packages = require("src.core.package_manager")
local installer = require("src.core.installer")
local logger = require("src.common.logger")

---@class LmaoGetApi
local api = {}

function api.get_version()
    return config.get_version()
end

-- Updates the package cache
function api.update()
    filesystem.CreateDirectory(config.get_workspace_path())

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

    -- Install package
    local result, err = installer.install_package(package_info)
    if not result then
        return false, err
    end

    -- Install dependencies if any
    if package_info.dependencies then
        for _, dependency in ipairs(package_info.dependencies) do
            logger.info(string.format("Installing dependency '%s'", dependency))

            local result, err = api.install(dependency)
            if not result then
                logger.warn(string.format("Failed to install dependency '%s': %s", dependency, err))
            end
        end
    end

    return true
end

-- Uninstalls a package by repo and package id
---@param full_id string
---@return boolean, string?
function api.uninstall(full_id)
    if not installer.is_installed(full_id) then
        return false, "no such package installed"
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
    if utils.compare_versions(installed_package.version, package_info.version) >= 0 then
        return false, "package is already up to date"
    end

    -- Uninstall old package
    local success, err = installer.uninstall_package(full_id)
    if not success then
        return false, err
    end

    return installer.install_package(package_info)
end

-- Loads an installed script
---@param full_id string
---@return boolean, string?
function api.load_script(full_id)
    local installed_package = installer.find(full_id)
    if not installed_package then
        return false, "no such package installed"
    end

    local file_path = string.format("%s/%s", config.get_package_path(), installed_package.file_name)
    if not utils.file_exists(file_path) then
        return false, "package file does not exist"
    end

    local package_data = utils.read_file(file_path)
    if not package_data then
        return false, "failed to read package file"
    end

    dofile(file_path)

    return true
end

return api

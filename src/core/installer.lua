local utils = require("src.common.utils")
local config = require("src.common.config")
local logger = require("src.common.logger")
local json = require("src.common.json")

local fs = utils.lmaolib.utils.fs

filesystem.CreateDirectory(config.get_package_path())

---@class installer
---@field installed table<string, InstalledPackage>
local installer = {
    installed = {}
}

-- Reloads the installed package info
function installer.load_info()
    local installed_data = fs.read(config.get_package_info_path())
    if not installed_data then
        return
    end

    ---@type table<string, InstalledPackage>?
    local installed = json.decode(installed_data)
    if not installed then
        return
    end

    installer.installed = installed
end

-- Saves the installed package info
function installer.save_info()
    local installed_data = json.encode(installer.installed)
    if not installed_data then
        logger.warn("Failed to encode installed package info")
        return
    end

    fs.write(config.get_package_info_path(), installed_data)
end

-- Find info for an installed package
---@param full_id string
---@return InstalledPackage?
function installer.find(full_id)
    --[[local full_id = common.get_full_id(repo_id, package_id)
    for _, installed_package in ipairs(installer.installed) do
        if installed_package.full_id == full_id then
            return installed_package
        end
    end]]

    return installer.installed[full_id]
end

-- Check if a package is installed
---@param full_id string
function installer.is_installed(full_id)
    return installer.find(full_id) ~= nil
end

-- Adds a new package to the installed list
---@param package InstalledPackage
function installer.add_package(package)
    --table.insert(installer.installed, installed_package)
    installer.installed[package.full_id] = package
    installer.save_info()
end

-- Removes a package from the installed list
---@param full_id string
function installer.remove_package(full_id)
    --[[for i, installed_package in ipairs(installer.installed) do
        if installed_package.id == full_id then
            table.remove(installer.installed, i)
            installer.save_info()
            return
        end
    end]]

    installer.installed[full_id] = nil
    installer.save_info()
end

-- Download and install a package if it doesn't already exist
---@param package_info PackageCacheEntry
---@return boolean, string?
function installer.install_package(package_info)
    if installer.is_installed(package_info.full_id) then
        return false, "package already installed"
    end

    -- Download package data
    local package_data = http.Get(package_info.url)
    if not package_data then
        return false, "failed to download package data"
    end

    -- Save package data
    local file_name = string.format("%s.lua", package_info.full_id)
    local file_path = string.format("%s/%s", config.get_package_path(), file_name)
    if not fs.write(file_path, package_data) then
        return false, "failed to save package data"
    end

    -- Add to installed packages
    installer.add_package({
        full_id = package_info.full_id,
        name = package_info.name,
        description = package_info.description,
        version = package_info.version,
        file_name = file_name
    })

    return true
end

-- Uninstall a package if it exists
---@param full_id string
---@return boolean, string?
function installer.uninstall_package(full_id)
    local installed_package = installer.find(full_id)
    if not installed_package then
        return false, "no such package installed"
    end

    -- Delete package file
    local file_path = string.format("%s/%s", config.get_package_path(), installed_package.file_name)
    if not fs.delete(file_path) then
        return false, "failed to delete package file"
    end

    -- Remove from installed packages
    installer.remove_package(installed_package.full_id)

    return true
end

return installer
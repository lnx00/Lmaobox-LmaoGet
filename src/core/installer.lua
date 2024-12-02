local common = require("src.common.common")
local fs = common.lmaolib.utils.fs

local PACKAGE_INFO_PATH = "./LmaoGet/installed-packages.json"
local PACKAGE_PATH = "./LmaoGet/packages"

filesystem.CreateDirectory(PACKAGE_PATH)

---@class installer
---@field installed InstalledPackage[]
local installer = {
    installed = {}
}

-- Reloads the installed package info
function installer.load_info()
    local installed_data = fs.read(PACKAGE_INFO_PATH)
    if not installed_data then
        return
    end

    ---@type InstalledPackage[]?
    local installed = common.dkjson.decode(installed_data)
    if not installed then
        return
    end

    installer.installed = installed
end

-- Saves the installed package info
function installer.save_info()
    local installed_data = common.dkjson.encode(installer.installed)
    if not installed_data then
        warn("Failed to encode installed package info.")
        return
    end

    fs.write(PACKAGE_INFO_PATH, installed_data)
end

---@return InstalledPackage?
function installer.find(repo_id, package_id)
    local full_id = common.get_full_id(repo_id, package_id)
    for _, installed_package in ipairs(installer.installed) do
        if installed_package.id == full_id then
            return installed_package
        end
    end

    return nil
end

function installer.is_installed(repo_id, package_id)
    return installer.find(repo_id, package_id) ~= nil
end

-- Adds a new package to the installed list
---@param installed_package InstalledPackage
function installer.add_package(installed_package)
    table.insert(installer.installed, installed_package)
    installer.save_info()
end

-- Removes a package from the installed list
---@param full_id string
function installer.remove_package(full_id)
    for i, installed_package in ipairs(installer.installed) do
        if installed_package.id == full_id then
            table.remove(installer.installed, i)
            installer.save_info()
            return
        end
    end
end

---@param repo_id string
---@param package_info RepositoryPackage
---@return boolean, string?
function installer.install_package(repo_id, package_info)
    if installer.is_installed(repo_id, package_info.id) then
        return false, "Package is already installed!"
    end

    -- Download package data
    local package_data = http.Get(package_info.url)
    if not package_data then
        return false, "Failed to download package data."
    end

    -- Save package data
    local file_name = string.format("%s_%s.lua", repo_id, package_info.id)
    local file_path = string.format("%s/%s", PACKAGE_PATH, file_name)
    if not fs.write(file_path, package_data) then
        return false, "Failed to write package data."
    end

    -- Add to installed packages
    local full_id = common.get_full_id(repo_id, package_info.id)
    installer.add_package({
        id = full_id,
        name = package_info.name,
        description = package_info.description,
        version = package_info.version,
        file_name = file_name
    })

    return true
end

---@param repo_id string
---@param package_id string
---@return boolean, string?
function installer.uninstall_package(repo_id, package_id)
    local installed_package = installer.find(repo_id, package_id)
    if not installed_package then
        return false, "Package is not installed."
    end

    -- Delete package file
    local file_path = string.format("%s/%s", PACKAGE_PATH, installed_package.file_name)
    if not fs.delete(file_path) then
        return false, "Failed to remove package file."
    end

    -- Remove from installed packages
    installer.remove_package(installed_package.id)

    return true
end

return installer
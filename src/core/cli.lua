local common = require("src.common.common")
local Api = require("src.core.api")

---@class LmaoGetCLI
local LmaoGetCLI = {}

function LmaoGetCLI.show_help()
    print(string.format("Lmaobox Package Manager v%s\n", common.version()))
    print("Usage: lmaoget <command> [options]\n")
    print("Available commands:")
    print("  list \t\t\t List installed packages")
    print("  update \t\t\t Update the package cache")
    print("  find <package> \t\t Find a package by id")
    print("  install <package> \t\t Install a package by id")
    print("  uninstall <package> \t\t Uninstall an installed package")
    print("  upgrade <package> \t\t Upgrade an installed package")
end

function LmaoGetCLI.update()
    print("Updating package cache...")
    Api.update()
    print("Package cache updated")
end

function LmaoGetCLI.find(package_name)
    local results = Api.find(package_name)

    if #results == 0 then
        print(string.format("No packages found for '%s'", package_name))
        return
    end

    print(string.format("Found %d packages for '%s':", #results, package_name))
    for _, full_id in ipairs(results) do
        print(string.format("- %s", full_id))
    end
end

function LmaoGetCLI.install(package_name)
    local repo_id, package_id = common.get_split_id(package_name)

    print(string.format("Installing package '%s'...", package_name))
    local success, err = Api.install(repo_id, package_id)

    if not success then
        print(string.format("Failed to install package '%s': %s", package_name, err))
        return
    end

    print(string.format("Successfully installed package '%s'", package_name))
end

function LmaoGetCLI.uninstall(package_name)
    local repo_id, package_id = common.get_split_id(package_name)

    print(string.format("Uninstalling package '%s'...", package_name))
    local success, err = Api.uninstall(repo_id, package_id)

    if not success then
        print(string.format("Failed to uninstall package '%s': %s", package_name, err))
        return
    end

    print(string.format("Successfully uninstalled package '%s'", package_name))
end

function LmaoGetCLI.upgrade(package_name)
    local repo_id, package_id = common.get_split_id(package_name)

    print(string.format("Upgrading package '%s'...", package_name))
    local success, err = Api.upgrade(repo_id, package_id)

    if not success then
        print(string.format("Failed to upgrade package '%s': %s", package_name, err))
        return
    end

    print(string.format("Successfully upgraded package '%s'", package_name))
end

function LmaoGetCLI.on_command(args)
    local n_args = #args

    if n_args < 2 then
        LmaoGetCLI.show_help()
        return
    end

    local action = args[2]

    if action == "update" then
        LmaoGetCLI.update()
        return
    elseif action == "list" then
        print("WIP")
        return
    end

    if n_args < 3 then
        print("Usage: lmaoget <command> [options]")
        return
    end

    local package_name = args[3]

    if action == "find" then
        LmaoGetCLI.find(package_name)
        return
    elseif action == "install" then
        LmaoGetCLI.install(package_name)
        return
    elseif action == "uninstall" then
        LmaoGetCLI.uninstall(package_name)
        return
    elseif action == "upgrade" then
        LmaoGetCLI.upgrade(package_name)
        return
    else
        print(string.format("Unknown command '%s'", action))
        return
    end
end

---@param string_cmd StringCmd
local function on_string_cmd(string_cmd)
    local cmd = string_cmd:Get()

    if cmd:sub(1, 7) ~= "lmaoget" then
        return
    end

    local args = {}
    for arg in cmd:gmatch("%S+") do
        table.insert(args, arg)
    end

    LmaoGetCLI.on_command(args)
    string_cmd:Set("")
end

callbacks.Register("SendStringCmd", on_string_cmd)

return LmaoGetCLI
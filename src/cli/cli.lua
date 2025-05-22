local api = require("src.core.api")
local utils = require("src.common.utils")

---@class LmaoGetCLI
---@field handlers table<string, fun(args: string[])>
local cli = {
    handlers = {},
}

function cli.show_help()
    print(string.format("Lmaobox Package Manager v%s\n", api.get_version()))
    print("Usage: lmaoget <command> [options]\n")
    print("Available commands:")
    print(string.format("  %-25s %s", "list", "List installed packages"))
    print(string.format("  %-25s %s", "update", "Update the package cache"))
    print(string.format("  %-25s %s", "find <package>", "Find a package by id"))
    print(string.format("  %-25s %s", "install <package>", "Install a package by id"))
    print(string.format("  %-25s %s", "uninstall <package>", "Uninstall an installed package"))
    print(string.format("  %-25s %s", "upgrade <package>", "Upgrade an installed package"))
    print(string.format("  %-25s %s", "load <package>", "Load a package by id"))
end

cli.handlers["help"] = function(_)
    cli.show_help()
end

cli.handlers["update"] = function(args)
    if #args > 2 then
        print("Too many args for the 'update' command. Did you intend to 'upgrade' instead?")
        return
    end

    print("Updating package cache...")

    api.update(function(success, error)
        if not success then
            print(string.format("Failed to update: %s", error))
            return
        end

        print("Package cache updated")
    end)
end

cli.handlers["list"] = function(_)
    local results = api.list()

    if next(results) == nil then
        print("No packages installed")
        return
    end

    print(string.format("Installed packages (%d):", utils.count_table(results)))
    for full_id, package in pairs(results) do
        print(string.format("- %-30s (%s)", full_id, package.version))
    end
end

cli.handlers["find"] = function(args)
    if #args < 3 then
        print("Usage: lmaoget find <package>")
        return
    end

    local package_name = args[3]
    local results = api.find(package_name)

    if next(results) == nil then
        print(string.format("No packages found for '%s'", package_name))
        return
    end

    print(string.format("Found %d packages for '%s':", utils.count_table(results), package_name))
    for full_id, package in pairs(results) do
        print(string.format("- %-30s %-50s", full_id, package.name))
    end
end

cli.handlers["install"] = function(args)
    if #args < 3 then
        print("Usage: lmaoget install <package>")
        return
    end

    local package_name = args[3]
    print(string.format("Installing package '%s'...", package_name))
    local success, err = api.install(package_name)

    if not success then
        print(string.format("Failed to install: %s", err))
        return
    end

    print("Successfully installed")
end

cli.handlers["uninstall"] = function(args)
    if #args < 3 then
        print("Usage: lmaoget uninstall <package>")
        return
    end

    local package_name = args[3]
    print(string.format("Uninstalling package '%s'...", package_name))
    local success, err = api.uninstall(package_name)

    if not success then
        print(string.format("Failed to uninstall: %s", err))
        return
    end

    print("Successfully uninstalled")
end

cli.handlers["upgrade"] = function(args)
    if #args < 3 then
        print("Usage: lmaoget upgrade <package>")
        return
    end

    local package_name = args[3]
    print(string.format("Upgrading package '%s'...", package_name))
    local success, err = api.upgrade(package_name)

    if not success then
        print(string.format("Failed to upgrade: %s", err))
        return
    end

    print("Successfully upgraded")
end

cli.handlers["load"] = function(args)
    if #args < 3 then
        print("Usage: lmaoget load <package>")
        return
    end

    local package_name = args[3]
    print(string.format("Loading package '%s'...", package_name))
    local success, err = api.load_script(package_name)

    if not success then
        print(string.format("Failed to load: %s", err))
        return
    end

    print("Successfully loaded")
end

---@param args string[]
function cli.on_command(args)
    local n_args = #args

    if n_args < 2 then
        cli.show_help()
        return
    end

    local action = string.lower(args[2])
    local handler = cli.handlers[action]
    if handler then
        handler(args)
        return
    else
        print(string.format("Invalid operation: %s", action))
        print("Use 'lmaoget help' for a list of available commands")
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

    cli.on_command(args)
    string_cmd:Set("")
end

callbacks.Register("SendStringCmd", on_string_cmd)

return cli

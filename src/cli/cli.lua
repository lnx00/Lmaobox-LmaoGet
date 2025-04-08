local api = require("src.core.api")

---@class LmaoGetCLI
---@field handlers table<string, fun(args: string[])>
local cli = {
    handlers = {},
}

function cli.show_help()
    print(string.format("Lmaobox Package Manager v%s\n", api.get_version()))
    print("Usage: lmaoget <command> [options]\n")
    print("Available commands:")
    print("  list \t\t\t List installed packages")
    print("  update \t\t\t Update the package cache")
    print("  find <package> \t\t Find a package by id")
    print("  install <package> \t\t Install a package by id")
    print("  uninstall <package> \t\t Uninstall an installed package")
    print("  upgrade <package> \t\t Upgrade an installed package")
end

cli.handlers["help"] = function(_)
    cli.show_help()
end

cli.handlers["update"] = function(_)
    print("Updating package cache...")
    api.update()
    print("Package cache updated")
end

cli.handlers["list"] = function(_)
    local results = api.list()

    if #results == 0 then
        print("No packages installed")
        return
    end

    print(string.format("Installed packages (%d):", #results))
    for _, full_id in ipairs(results) do
        print(string.format("- %s", full_id))
    end
end

cli.handlers["find"] = function(args)
    if #args < 3 then
        print("Usage: lmaoget find <package>")
        return
    end

    local package_name = args[3]
    local results = api.find(package_name)

    if #results == 0 then
        print(string.format("No packages found for '%s'", package_name))
        return
    end

    print(string.format("Found %d packages for '%s':", #results, package_name))
    for _, full_id in ipairs(results) do
        print(string.format("- %s", full_id))
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

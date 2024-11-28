local lmaolib = require("LmaoLib")
local dkjson = load(http.Get("http://dkolf.de/dkjson-lua/dkjson-2.8.lua"))()

assert(lmaolib, "Failed to load LmaoLib")
assert(dkjson, "Failed to load dkjson")

---@class Common
---@field lmaolib LmaoLib
---@field dkjson dkjson
local Common = {
    lmaolib = lmaolib,
    dkjson = dkjson
}

function Common.version()
    return "0.1.0"
end

function Common.sanitize_name(name)
    return name:gsub("[^%w]", "")
end

function Common.compare_versions(v1, v2)
    local v1_parts = {}
    for part in v1:gmatch("%d+") do
        table.insert(v1_parts, tonumber(part))
    end

    local v2_parts = {}
    for part in v2:gmatch("%d+") do
        table.insert(v2_parts, tonumber(part))
    end

    for i = 1, math.max(#v1_parts, #v2_parts) do
        local v1_part = v1_parts[i] or 0
        local v2_part = v2_parts[i] or 0

        if v1_part < v2_part then
            return -1
        elseif v1_part > v2_part then
            return 1
        end
    end

    return 0
end

function Common.get_full_id(repo_id, package_id)
    repo_id = Common.sanitize_name(repo_id)
    package_id = Common.sanitize_name(package_id)

    return string.format("%s.%s", repo_id, package_id)
end

function Common.get_split_id(full_id)
    local repo_id, package_id = full_id:match("([^%.]+)%.(.+)")
    return repo_id, package_id
end

return Common
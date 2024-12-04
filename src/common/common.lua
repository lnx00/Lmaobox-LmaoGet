local lmaolib = require("LmaoLib")

assert(lmaolib, "Failed to load LmaoLib")

---@class Common
---@field lmaolib LmaoLib
local common = {
    lmaolib = lmaolib
}

function common.version()
    return "0.1.0"
end

function common.sanitize_name(name)
    return name:gsub("[^%w]", "")
end

function common.compare_versions(v1, v2)
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

function common.get_full_id(repo_id, package_id)
    repo_id = common.sanitize_name(repo_id)
    package_id = common.sanitize_name(package_id)

    return string.format("%s.%s", repo_id, package_id)
end

function common.get_split_id(full_id)
    local repo_id, package_id = full_id:match("([^%.]+)%.(.+)")
    return repo_id, package_id
end

return common

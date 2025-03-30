---@class utils
local utils = {}

function utils.sanitize_name(name)
    return name:gsub("[^%w]", "")
end

function utils.compare_versions(v1, v2)
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

function utils.get_full_id(repo_id, package_id)
    repo_id = utils.sanitize_name(repo_id)
    package_id = utils.sanitize_name(package_id)

    return string.format("%s.%s", repo_id, package_id)
end

function utils.get_split_id(full_id)
    local repo_id, package_id = full_id:match("([^%.]+)%.(.+)")
    return repo_id, package_id
end

---@param path string
---@return any?
function utils.read_file(path)
    local file = io.open(path, "rb") -- r read mode and b binary mode
    if not file then return nil end
    local content = file:read "*a" -- *a or *all reads the whole file
    file:close()
    return content
end

---@param path string
---@param content any
---@return boolean
function utils.write_file(path, content)
    local file = io.open(path, "wb") -- w write mode and b binary mode
    if not file then return false end
    file:write(content)
    file:close()
    return true
end

return utils

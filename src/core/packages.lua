local Common = require("src.common.common")
local fs, dkjson = Common.lmaolib.utils.fs, Common.dkjson

local repo_index_url = "./LmaoGet/lmaoget-index.json"

---@param repo_entry RepositoryIndexEntry
---@return table<string, RepositoryPackage>?
local function fetch_repo(repo_entry)
    local repo_data = fs.read(repo_entry.url)
    if not repo_data then
        warn(string.format("Failed to load repo %s", repo_entry.id))
        return nil
    end

    ---@type Repository?
    local repo_json = dkjson.decode(repo_data)
    if not repo_json then
        warn(string.format("Failed to decode repo %s", repo_entry.id))
        return nil
    end

    local repo_cache = {}
    for _, package in ipairs(repo_json.packages) do
        local package_id = Common.sanitize_name(package.id)

        print(string.format("- Found package '%s'", package_id))
        repo_cache[package_id] = package
    end

    return repo_cache
end

-- Manages available and installed packages
---@class Packages
---@field cache table<string, table<string, RepositoryPackage>>
local Packages = {
    cache = {}
}

function Packages.update_cache()
    local package_index_json = fs.read(repo_index_url)
    if not package_index_json then
        error("Failed to load package index")
        return
    end

    ---@type RepositoryIndex?
    local package_index = dkjson.decode(package_index_json)
    if not package_index then
        error("Failed to decode package index")
        return
    end

    for _, repo_entry in ipairs(package_index.repos) do
        print(string.format("Updating repo '%s'...", repo_entry.id))

        local repo_id = Common.sanitize_name(repo_entry.id)
        local repo_cache = fetch_repo(repo_entry)
        Packages.cache[repo_id] = repo_cache
    end
end

-- Find a package with partial matching name
---@return table<string, RepositoryPackage>
function Packages.find(package_name)
    local results = {}
    for repo_id, repo_cache in pairs(Packages.cache) do
        for package_id, package in pairs(repo_cache) do
            local full_id = Common.get_full_id(repo_id, package_id)
            if full_id:lower():find(package_name:lower()) then
                results[full_id] = package
            end
        end
    end

    return results
end

-- Get a package by repo and package id
---@return RepositoryPackage?
function Packages.get(repo_id, package_id)
    local repo_cache = Packages.cache[repo_id]
    if not repo_cache then
        return nil
    end

    return repo_cache[package_id]
end

return Packages

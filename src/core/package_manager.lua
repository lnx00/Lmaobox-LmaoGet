local utils = require("src.common.utils")
local config = require("src.common.config")
local logger = require("src.common.logger")
local json = require("src.common.json")

-- Fetches a repo and returns its table of packages
---@param repo_entry RepositoryIndexEntry
---@return table<string, PackageCacheEntry>?
local function fetch_repo(repo_entry)
    local repo_data = http.Get(repo_entry.url)
    if not repo_data then
        logger.warn(string.format("Failed to load repo '%s'", repo_entry.id))
        return nil
    end

    ---@type Repository?
    local repo_json = json.decode(repo_data)
    if not repo_json then
        logger.warn(string.format("Failed to decode repo '%s'", repo_entry.id))
        return nil
    end

    ---@type table<string, PackageCacheEntry>
    local repo_cache = {}
    for _, package in ipairs(repo_json.packages) do
        local package_id = utils.sanitize_name(package.id)

        logger.debug(string.format("- Found package '%s'", package_id))
        repo_cache[package_id] = {
            full_id = utils.get_full_id(repo_entry.id, package_id),
            name = package.name,
            version = package.version,
            description = package.description,
            url = package.url,
            dependencies = package.dependencies,
        }
    end

    return repo_cache
end

-- Manages available packages
---@class PackageManager
---@field cache table<string, table<string, PackageCacheEntry>>
local package_manager = {
    cache = {}
}

-- Updates the local package cache
function package_manager.update_cache()
    local package_index_json = http.Get(config.get_repo_index_url())
    if not package_index_json then
        logger.error("Failed to load package index")
        return
    end

    ---@type RepositoryIndex?
    local package_index = json.decode(package_index_json)
    if not package_index then
        logger.error("Failed to decode package index")
        return
    end

    package_manager.cache = {}
    for _, repo_entry in ipairs(package_index.repos) do
        logger.debug(string.format("Updating repo '%s'...", repo_entry.id))

        local repo_id = utils.sanitize_name(repo_entry.id)
        local repo_cache = fetch_repo(repo_entry)

        package_manager.cache[repo_id] = repo_cache
    end
end

-- Find a package with partial matching name
---@param needle string
---@return table<string, RepositoryPackage>
function package_manager.find(needle)
    local results = {}
    for repo_id, repo_cache in pairs(package_manager.cache) do
        for package_id, package in pairs(repo_cache) do
            local full_id = utils.get_full_id(repo_id, package_id)
            if full_id:lower():find(needle:lower()) then
                results[full_id] = package
            end
        end
    end

    return results
end

-- Get a package by repo and package id
---@return PackageCacheEntry?
function package_manager.get(full_id)
    local repo_id, package_id = utils.get_split_id(full_id)

    local repo_cache = package_manager.cache[repo_id]
    if not repo_cache then
        return nil
    end

    return repo_cache[package_id]
end

return package_manager

local utils = require("src.common.utils")
local config = require("src.common.config")
local logger = require("src.common.logger")
local json = require("src.common.json")

-- Fetches a repo asynchronously and returns its table of packages
---@param repo_entry RepositoryIndexEntry
---@param callback fun(repo_cache: table<string, PackageCacheEntry>?)
local function fetch_repo_async(repo_entry, callback)
    http.GetAsync(repo_entry.url, function(repo_data)
        if not repo_data then
            logger.warn(string.format("Failed to load repo '%s'", repo_entry.id))
            return callback(nil)
        end

        ---@type Repository?
        local repo_json = json.decode(repo_data)
        if not repo_json then
            logger.warn(string.format("Failed to decode repo '%s'", repo_entry.id))
            return callback(nil)
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

        callback(repo_cache)
    end)
end

-- Manages available packages
---@class PackageManager
---@field cache table<string, table<string, PackageCacheEntry>>
---@field pending_updates number
local package_manager = {
    cache = {},
    pending_updates = 0,
}

-- Updates the local package cache asynchronously
---@param callback fun(success: boolean, error: string?)
function package_manager.update_cache(callback)
    if package_manager.pending_updates > 0 then
        return callback(false, "update already in progress")
    end

    http.GetAsync(config.get_repo_index_url(), function(package_index_json)
        if not package_index_json then
            return callback(false, "failed to load package index")
        end

        ---@type RepositoryIndex?
        local package_index = json.decode(package_index_json)
        if not package_index then
            return callback(false, "failed to decode package index")
        end

        local new_cache = {}
        package_manager.pending_updates = #package_index.repos
        logger.debug(string.format("Found %d repos", package_manager.pending_updates))

        -- Fetch each repo asynchronously
        for _, repo_entry in ipairs(package_index.repos) do
            logger.debug(string.format("Updating repo '%s'...", repo_entry.id))

            local repo_id = utils.sanitize_name(repo_entry.id)
            fetch_repo_async(repo_entry, function(repo_cache)
                logger.debug(string.format("Repo '%s' updated", repo_id))

                new_cache[repo_id] = repo_cache
                package_manager.pending_updates = package_manager.pending_updates - 1

                if package_manager.pending_updates <= 0 then
                    logger.debug("All repos updated")
                    return callback(true, nil)
                end
            end)
        end

        package_manager.cache = new_cache
    end)
end

-- Find a package with partial matching name
---@param needle string
---@return table<string, RepositoryPackage> (full_id, package)
function package_manager.find(needle)
    local results = {}
    for repo_id, repo_cache in pairs(package_manager.cache) do
        if repo_cache then
            for package_id, package in pairs(repo_cache) do
                local full_id = utils.get_full_id(repo_id, package_id)
                if full_id:lower():find(needle:lower()) then
                    results[full_id] = package
                end
            end
        end
    end

    return results
end

-- Get a package by repo and package id
---@param full_id string
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

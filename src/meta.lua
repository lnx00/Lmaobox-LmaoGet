---@meta

--[[ Remote ]]

---A repository entry in the repository index
---@class RepositoryIndexEntry
---@field id string
---@field url string
local RepositoryIndexEntry = {}

---The global repository index containing all repositories
---@class RepositoryIndex
---@field repos RepositoryIndexEntry[]
local RepositoryIndex = {}

---A package entry in the repository
---@class RepositoryPackage
---@field id string
---@field name string
---@field version string
---@field description string
---@field url string
---@field dependencies string[]?
local RepositoryPackage = {}

---A repository
---@class Repository
---@field name string
---@field packages RepositoryPackage[]
local Repository = {}

--[[ Local ]]

---Information about a installed package
---@class InstalledPackage
---@field full_id string
---@field name string
---@field description string
---@field version string
---@field file_name string
local InstalledPackage = {}

---Entry in the package cache
---@class PackageCacheEntry
---@field full_id string
---@field name string
---@field version string
---@field description string
---@field url string
---@field dependencies string[]?
local PackageCacheEntry = {}

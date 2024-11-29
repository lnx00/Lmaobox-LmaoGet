---@meta

---A repository entry in the repository index
---@class RepositoryIndexEntry
---@field id string
---@field url string
local RepositoryIndexEntry = {}

---The repository index
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
local RepositoryPackage = {}

---A repository
---@class Repository
---@field name string
---@field packages RepositoryPackage[]
local Repository = {}

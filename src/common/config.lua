local LMAOGET_VERSION = "0.1.0"

local WORKSPACE_PATH = "./.lmaoget/"
local PACKAGE_PATH = WORKSPACE_PATH .. "packages/"
local PACKAGE_INFO_PATH = WORKSPACE_PATH .. "installed-packages.json"

--local REPO_INDEX_URL = "https://gist.githubusercontent.com/lnx00/634792a910870ca563da47f6285aaf00/raw/lmaoget-index.json" .. "?v=1"
local REPO_INDEX_URL = "https://raw.githubusercontent.com/lnx00/Lmaobox-LmaoGet/refs/heads/main/repo/lmaoget-index.json"

---@class config
local config = {}

function config.get_version()
    return LMAOGET_VERSION
end

function config.get_workspace_path()
    return WORKSPACE_PATH
end

function config.get_package_path()
    return PACKAGE_PATH
end

function config.get_package_info_path()
    return PACKAGE_INFO_PATH
end

function config.get_repo_index_url()
    return REPO_INDEX_URL
end

return config
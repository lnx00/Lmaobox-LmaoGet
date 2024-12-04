---@type dkjson
local dkjson = load(http.Get("http://dkolf.de/dkjson-lua/dkjson-2.8.lua"))()
assert(dkjson, "Failed to load dkjson")

---@class json
local json = {}

function json.encode(data)
    return dkjson.encode(data)
end

function json.decode(data)
    return dkjson.decode(data)
end

return json

local Config = import("Config")

local HttpService = game:GetService("HttpService")

local API_BASE = Config.API_BASE
local Api = {}

local function decode(response)
    local ok, value = pcall(function() return HttpService:JSONDecode(response.Body) end)
    if not ok then error("MoonHub returned an invalid response.") end
    return value
end

-- Returns an array of animation summaries. Pass offset to page.
function Api.list(query, category, offset, limit)
    local url = API_BASE .. "/animations?view=summary&limit=" .. limit
    if offset > 0 then url = url .. "&offset=" .. offset end
    if query ~= "" then url = url .. "&q=" .. HttpService:UrlEncode(query) end
    if category then url = url .. "&category=" .. HttpService:UrlEncode(category) end
    local response = HttpService:RequestAsync({Url = url, Method = "GET"})
    if not response.Success then error("Library request failed (" .. tostring(response.StatusCode) .. ").") end
    local rows = decode(response)
    if type(rows) ~= "table" or rows.error then
        error(type(rows) == "table" and tostring(rows.error) or "MoonHub returned an invalid library response.")
    end
    return rows
end

function Api.get(normalized)
    local response = HttpService:RequestAsync({Url = API_BASE .. "/anim/" .. normalized, Method = "GET"})
    if not response.Success then error("Could not fetch " .. normalized .. " (" .. tostring(response.StatusCode) .. ").") end
    return decode(response)
end

function Api.upload(key, body)
    local response = HttpService:RequestAsync({
        Url = API_BASE .. "/upload", Method = "POST",
        Headers = { ["Content-Type"] = "application/json", Authorization = "Bearer " .. key },
        Body = HttpService:JSONEncode(body),
    })
    if not response.Success then error("Upload failed (" .. tostring(response.StatusCode) .. "): " .. response.Body) end
    return decode(response)
end

-- Returns the username, or nil when the key is invalid or revoked.
function Api.me(key)
    local response = HttpService:RequestAsync({Url = API_BASE .. "/me", Method = "GET", Headers = {Authorization = "Bearer " .. key}})
    if response.StatusCode == 401 then return nil end
    if not response.Success then error("MoonHub returned " .. tostring(response.StatusCode) .. ".") end
    return decode(response).username
end

-- Returns the HTTP status code of a cheap public request.
function Api.ping()
    return HttpService:RequestAsync({Url = API_BASE .. "/animations?view=summary&limit=1", Method = "GET"}).StatusCode
end

return Api

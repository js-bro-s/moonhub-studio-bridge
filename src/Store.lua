local Store = {}

local listeners = {}

local function load(name, fallback)
    local value = plugin:GetSetting("MoonHub_" .. name)
    if value == nil then return fallback end
    return value
end

Store.state = {
    apiKey = load("ApiKey", ""),
    category = load("Category", "Locomotion"),
    rig = load("Rig", "R15"),
    username = nil,
}

function Store.save(name, value)
    plugin:SetSetting("MoonHub_" .. name, value)
end

function Store.subscribe(listener)
    table.insert(listeners, listener)
end

function Store.notify()
    for _, listener in ipairs(listeners) do listener() end
end

return Store

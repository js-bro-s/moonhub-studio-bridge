local Api = import("Api")
local Config = import("Config")
local Shell = import("Shell")
local Store = import("Store")
local Ui = import("Ui")

return function()
    local state = Store.state
    local tab = Shell.addTab("Settings", 3)

    Ui.label(tab, "API KEY", 15, true)
    local keyField = Ui.field(tab, "mh_live_…", "")
    local keyShown = false
    local function renderKey()
        keyField.Text = keyShown and state.apiKey or string.rep("•", #state.apiKey)
    end
    renderKey()
    keyField.Focused:Connect(function() keyField.Text = state.apiKey end)
    keyField.FocusLost:Connect(function()
        state.apiKey = (keyField.Text:gsub("%s", ""))
        state.username = nil
        Store.save("ApiKey", state.apiKey)
        Shell.refreshKeyDot(); renderKey(); Store.notify()
    end)
    local showButton = Ui.button(tab, "SHOW KEY", false)
    showButton.Activated:Connect(function()
        keyShown = not keyShown
        showButton.Text = keyShown and "HIDE KEY" or "SHOW KEY"
        renderKey()
    end)
    local validateButton = Ui.button(tab, "VALIDATE KEY", false)
    validateButton.Activated:Connect(function()
        local key = state.apiKey
        if key == "" then Shell.setStatus("Add API key first.", true); return end
        Shell.setStatus("Validating…", false)
        task.spawn(function()
            local ok, username = pcall(Api.me, key)
            if not ok then
                Shell.setStatus(tostring(username):find("not enabled") and "HTTP blocked. Enable in Game Settings → Security." or tostring(username), true)
            elseif not username then
                state.username = nil; Shell.refreshKeyDot(); Shell.setStatus("Key invalid or revoked.", true)
            else
                state.username = username; Shell.refreshKeyDot()
                Shell.setStatus("Key valid. Signed in as " .. username .. ".", false)
            end
        end)
    end)
    Ui.label(tab, "Create keys at " .. Config.SITE_URL .. "/dashboard", 18, true)

    Ui.label(tab, "CONNECTION", 15, true)
    local httpButton = Ui.button(tab, "CHECK HTTP ACCESS", false)
    httpButton.Activated:Connect(function()
        Shell.setStatus("Checking…", false)
        task.spawn(function()
            local ok, status = pcall(Api.ping)
            if not ok then Shell.setStatus("HTTP blocked. Enable in Game Settings → Security.", true)
            elseif status >= 400 then Shell.setStatus("MoonHub returned " .. tostring(status) .. ".", true)
            else Shell.setStatus("HTTP enabled. MoonHub reachable.", false) end
        end)
    end)

    Ui.label(tab, "PREFERENCES", 15, true)
    local resetButton = Ui.button(tab, "RESET SAVED SETTINGS", false)
    resetButton.Activated:Connect(function()
        for _, name in ipairs({"ApiKey", "Category", "Rig"}) do Store.save(name, nil) end
        state.apiKey, state.category, state.rig, state.username = "", "Locomotion", "R15", nil
        keyShown = false; showButton.Text = "SHOW KEY"; renderKey(); Shell.refreshKeyDot(); Store.notify()
        Shell.setStatus("Saved settings cleared.", false)
    end)
    Ui.label(tab, "Docs: " .. Config.DOCS_URL, 34, true)
end

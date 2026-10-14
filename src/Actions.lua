local Api = import("Api")
local Sequence = import("Sequence")
local Shell = import("Shell")

local Actions = {}

function Actions.importByCode(code, title)
    local normalized = tostring(code or ""):upper():gsub("%s", "")
    if not normalized:match("^MH%-%d%d%d%d$") then Shell.setStatus("Enter a code like MH-8492.", true); return end
    Shell.setStatus("Fetching " .. tostring(title or normalized) .. "…", false)
    task.spawn(function()
        local ok, err = pcall(function()
            Sequence.restoreAnimation(Api.get(normalized), normalized)
        end)
        if ok then Shell.setStatus("Imported " .. normalized .. " into ServerStorage.MoonAnimator2Saves.", false)
        else Shell.setStatus(tostring(err), true) end
    end)
end

return Actions

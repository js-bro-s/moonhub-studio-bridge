local Api = import("Api")
local Config = import("Config")
local Sequence = import("Sequence")
local Shell = import("Shell")
local Store = import("Store")
local Theme = import("Theme")
local Ui = import("Ui")

local Selection = game:GetService("Selection")

local function describe(entry)
    local frames = entry.sequence:GetKeyframes()
    local maxTime, poses, count = 0, {}, 0
    for _, keyframe in ipairs(frames) do
        maxTime = math.max(maxTime, keyframe.Time)
        for _, pose in ipairs(keyframe:GetDescendants()) do
            if pose:IsA("Pose") and not poses[pose.Name] then poses[pose.Name] = true; count += 1 end
        end
    end
    return #frames, math.floor(maxTime * 60 + 0.5), count, poses
end

local function detectRig(poses)
    if poses.UpperTorso or poses.LowerTorso then return "R15" end
    if poses.Torso then return "R6" end
    return nil
end

return function()
    local state = Store.state
    local tab = Shell.addTab("Export", 2)
    local candidates, chosen = {}, nil -- candidates: {sequence, root}
    local refresh

    Ui.label(tab, "SELECTION", 15, true)
    local _, selectionText = Ui.card(tab)
    local pickerHolder = Instance.new("Frame")
    pickerHolder.BackgroundTransparency = 1; pickerHolder.Size = UDim2.new(1, 0, 0, 0); pickerHolder.AutomaticSize = Enum.AutomaticSize.Y
    pickerHolder.LayoutOrder = Ui.nextOrder(); pickerHolder.Parent = tab
    Ui.stack(pickerHolder, 2)
    Ui.label(tab, "TITLE", 15, true)
    local titleField = Ui.field(tab, "Animation title", "")
    Ui.label(tab, "CATEGORY", 15, true)
    local setCategoryChoice = Ui.dropdown(tab, Config.CATEGORIES, state.category, function(value) state.category = value; Store.save("Category", value) end)
    Ui.label(tab, "RIG TYPE", 15, true)
    local setRigChoice = Ui.dropdown(tab, Config.RIGS, state.rig, function(value) state.rig = value; Store.save("Rig", value) end)
    Ui.label(tab, "TAGS (comma separated)", 15, true)
    local tagsField = Ui.field(tab, "moon-animator, studio", "moon-animator, studio")
    local exportButton = Ui.button(tab, "UPLOAD SELECTED SAVE TO MOONHUB", true)
    local resultCard, resultText = Ui.card(tab)
    resultCard.Visible = false
    local resultLink = Ui.field(tab, "", "")
    resultLink.TextEditable = false; resultLink.Visible = false

    local function renderPicker()
        for _, child in ipairs(pickerHolder:GetChildren()) do
            if child:IsA("GuiObject") then child:Destroy() end
        end
        if #candidates < 2 then return end
        for index, entry in ipairs(candidates) do
            local option = Ui.button(pickerHolder, entry.sequence.Name, false)
            option.LayoutOrder = index
            if entry == chosen then option.TextColor3 = Theme.ACCENT end
            option.Activated:Connect(function() chosen = entry; titleField.Text = entry.sequence.Name; refresh() end)
        end
    end

    refresh = function()
        renderPicker()
        exportButton.BackgroundTransparency = (chosen ~= nil and state.apiKey ~= "") and 0 or 0.6
        setRigChoice(state.rig)
        setCategoryChoice(state.category)
        if #candidates == 0 then
            selectionText.Text = #Selection:Get() == 0
                and "Nothing selected.\nSelect a KeyframeSequence or a folder holding saves."
                or '<font color="#f06e5a">No KeyframeSequence found in selection.</font>'
            return
        end
        local keyframes, frames, poseCount = describe(chosen)
        local lines = {"<b>" .. Ui.escapeRich(chosen.sequence.Name) .. "</b>", keyframes .. " keyframes · " .. frames .. " frames @60fps · " .. poseCount .. " poses"}
        if keyframes == 0 or poseCount == 0 then
            table.insert(lines, '<font color="#f06e5a">Save has no animated poses.</font>')
        elseif #candidates > 1 then
            table.insert(lines, "Pick one below (" .. #candidates .. " found).")
        end
        if state.apiKey == "" then table.insert(lines, '<font color="#f06e5a">Add API key in Settings.</font>') end
        selectionText.Text = table.concat(lines, "\n")
    end

    local function onSelectionChanged()
        local previous = chosen and chosen.sequence
        candidates = {}
        for _, item in ipairs(Selection:Get()) do
            for _, sequence in ipairs(Sequence.findAll(item)) do
                table.insert(candidates, {sequence = sequence, root = item})
            end
        end
        chosen = nil
        for _, entry in ipairs(candidates) do
            if entry.sequence == previous then chosen = entry end
        end
        if not chosen then
            chosen = candidates[1]
            if chosen then
                titleField.Text = chosen.sequence.Name
                local _, _, _, poses = describe(chosen)
                local rig = detectRig(poses)
                if rig then state.rig = rig end
            end
        end
        refresh()
    end
    Selection.SelectionChanged:Connect(onSelectionChanged)
    Store.subscribe(refresh)
    onSelectionChanged()

    local publishing = false
    exportButton.Activated:Connect(function()
        if publishing then return end
        local key = state.apiKey
        if key == "" then Shell.setStatus("Add API key in Settings. Create one at moonhub.dev/dashboard.", true); Shell.selectTab("Settings"); return end
        if not chosen then Shell.setStatus("Select a KeyframeSequence or save folder first.", true); return end
        local title = titleField.Text:match("^%s*(.-)%s*$")
        if title == "" then Shell.setStatus("Title is empty.", true); return end
        local entry = chosen
        publishing = true
        exportButton.Text = "UPLOADING…"
        Shell.setStatus("Uploading " .. title .. "…", false)
        task.spawn(function()
            local ok, result = pcall(function()
                local payload, duration = Sequence.serialize(entry.sequence, entry.root, state.rig)
                return Api.upload(key, { title = title, category = state.category, rig_type = state.rig, duration_frames = math.max(duration, 1), fps = 60, payload_json = payload, tags = tagsField.Text })
            end)
            publishing = false
            exportButton.Text = "UPLOAD SELECTED SAVE TO MOONHUB"
            if ok then
                Shell.setStatus("Published " .. result.short_code, false)
                resultText.Text = "<b>Published " .. Ui.escapeRich(result.short_code) .. "</b>\nCopy the link below."
                resultLink.Text = tostring(result.url)
                resultCard.Visible = true; resultLink.Visible = true
            else Shell.setStatus(tostring(result), true) end
        end)
    end)
end

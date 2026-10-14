local Actions = import("Actions")
local Api = import("Api")
local Config = import("Config")
local Shell = import("Shell")
local Theme = import("Theme")
local Ui = import("Ui")

local GUIDE = Enum.StudioStyleGuideColor
local BROWSE_LIMIT = 30

return function()
    local tab = Shell.addTab("Browse", 1)
    local browse = {query = "", category = nil, token = 0, selected = nil, rows = {}}

    Ui.label(tab, "SEARCH", 15, true)
    local searchField = Ui.field(tab, "title, code, or tag", "")

    local chipBar = Instance.new("ScrollingFrame")
    chipBar.Size = UDim2.new(1, 0, 0, 36); chipBar.LayoutOrder = Ui.nextOrder(); chipBar.BackgroundTransparency = 1
    chipBar.BorderSizePixel = 0; chipBar.ScrollBarThickness = 3; chipBar.CanvasSize = UDim2.new()
    chipBar.AutomaticCanvasSize = Enum.AutomaticSize.X; chipBar.ScrollingDirection = Enum.ScrollingDirection.X; chipBar.Parent = tab
    local chipLayout = Instance.new("UIListLayout")
    chipLayout.FillDirection = Enum.FillDirection.Horizontal; chipLayout.Padding = UDim.new(0, 6)
    chipLayout.SortOrder = Enum.SortOrder.LayoutOrder; chipLayout.Parent = chipBar

    local detailCard, detailText = Ui.card(tab)
    detailCard.Visible = false
    local importSelected = Ui.button(tab, "IMPORT TO SERVERSTORAGE", true)
    importSelected.Visible = false
    local linkField = Ui.field(tab, "", "")
    linkField.TextEditable = false; linkField.Visible = false

    local listStatus = Ui.label(tab, "", 20, true)
    local resultsHolder = Instance.new("Frame")
    resultsHolder.BackgroundTransparency = 1; resultsHolder.Size = UDim2.new(1, 0, 0, 0); resultsHolder.AutomaticSize = Enum.AutomaticSize.Y
    resultsHolder.LayoutOrder = Ui.nextOrder(); resultsHolder.Parent = tab
    Ui.stack(resultsHolder, 6)
    local moreButton = Ui.button(tab, "LOAD MORE", false)
    moreButton.Visible = false
    local refreshButton = Ui.button(tab, "REFRESH", false)

    Ui.label(tab, "IMPORT BY SHORT CODE", 15, true)
    local codeField = Ui.field(tab, "MH-8492", "")
    local importButton = Ui.button(tab, "IMPORT CODE INTO SERVERSTORAGE", false)
    importButton.Activated:Connect(function() Actions.importByCode(codeField.Text) end)

    local function showDetail(row)
        browse.selected = row
        local tags = (row.tags and #row.tags > 0) and table.concat(row.tags, ", ") or "none"
        detailText.Text = "<b>" .. Ui.escapeRich(row.title) .. "</b>\n" ..
            Ui.escapeRich(row.short_code .. " · " .. row.category .. " · " .. row.rig_type) .. "\n" ..
            Ui.escapeRich(row.description or "No description.") .. "\nTags: " .. Ui.escapeRich(tags)
        detailCard.Visible = true; importSelected.Visible = true
        linkField.Text = Config.SITE_URL .. "/anim/" .. row.short_code; linkField.Visible = true
        tab.CanvasPosition = Vector2.zero
    end
    importSelected.Activated:Connect(function()
        local animation = browse.selected
        if animation then Actions.importByCode(animation.short_code, animation.title) end
    end)

    local function renderRows(rows)
        for _, child in ipairs(resultsHolder:GetChildren()) do
            if child:IsA("GuiObject") then child:Destroy() end
        end
        for index, row in ipairs(rows) do
            if type(row) == "table" and type(row.short_code) == "string" then
                local item = Instance.new("TextButton")
                item.Size = UDim2.new(1, 0, 0, 62); item.LayoutOrder = index; item.BorderSizePixel = 0; item.AutoButtonColor = true
                item.Font = Enum.Font.Gotham; item.TextSize = 12; item.RichText = true; item.TextWrapped = true
                item.TextXAlignment = Enum.TextXAlignment.Left; item.TextYAlignment = Enum.TextYAlignment.Top
                item.Text = "<b>" .. Ui.escapeRich(row.title or "Untitled animation") .. "</b>\n" ..
                    Ui.escapeRich(row.short_code .. " · " .. tostring(row.rig_type) .. " · " .. tostring(row.fps) .. "fps · " .. tostring(row.duration_frames) .. "f") .. "\n" ..
                    Ui.escapeRich("by " .. tostring(row.author or "MoonHub creator") .. "   ♥ " .. tostring(row.likes_count or 0) .. "   ⬇ " .. tostring(row.downloads_count or 0))
                item.Parent = resultsHolder
                Theme.bind(item, "BackgroundColor3", GUIDE.InputFieldBackground)
                Theme.bind(item, "TextColor3", GUIDE.MainText)
                Ui.corner(item); Ui.padding(item, 8)
                item.Activated:Connect(function() showDetail(row) end)
            end
        end
    end

    local function loadBrowse(append)
        browse.token += 1
        local token = browse.token
        listStatus.Text = "Loading…"; listStatus.TextColor3 = Theme.color(GUIDE.SubText)
        local ok, result = pcall(Api.list, browse.query, browse.category, append and #browse.rows or 0, BROWSE_LIMIT)
        if token ~= browse.token then return end
        if not ok then
            if not append then browse.rows = {}; renderRows({}); moreButton.Visible = false end
            listStatus.Text = tostring(result):find("not enabled") and "HTTP blocked. Enable in Game Settings → Security." or tostring(result)
            listStatus.TextColor3 = Theme.ERR
            return
        end
        if append then table.move(result, 1, #result, #browse.rows + 1, browse.rows) else browse.rows = result end
        renderRows(browse.rows)
        moreButton.Visible = #result == BROWSE_LIMIT
        listStatus.Text = #browse.rows == 0 and "No animations match." or (#browse.rows .. " animations")
    end

    local chipButtons = {}
    local function renderChips()
        for name, chip in pairs(chipButtons) do
            local selected = (browse.category == nil and name == "All") or name == browse.category
            chip.BackgroundColor3 = selected and Theme.ACCENT or Theme.color(GUIDE.Button)
            chip.TextColor3 = selected and Theme.ACCENT_TEXT or Theme.color(GUIDE.ButtonText)
        end
    end
    local chipNames = {"All", table.unpack(Config.CATEGORIES)}
    for index, name in ipairs(chipNames) do
        local chip = Instance.new("TextButton")
        chip.AutomaticSize = Enum.AutomaticSize.X; chip.Size = UDim2.new(0, 0, 0, 28); chip.LayoutOrder = index
        chip.BorderSizePixel = 0; chip.Font = Enum.Font.GothamMedium; chip.TextSize = 12; chip.Text = name; chip.Parent = chipBar
        Ui.corner(chip)
        local chipPad = Ui.padding(chip, 0)
        chipPad.PaddingLeft = UDim.new(0, 12); chipPad.PaddingRight = UDim.new(0, 12)
        chip.Activated:Connect(function()
            browse.category = name ~= "All" and name or nil
            renderChips(); task.spawn(loadBrowse)
        end)
        chipButtons[name] = chip
    end
    renderChips()

    searchField:GetPropertyChangedSignal("Text"):Connect(function()
        local text = searchField.Text:match("^%s*(.-)%s*$")
        task.delay(0.3, function()
            if searchField.Text:match("^%s*(.-)%s*$") ~= text or browse.query == text then return end
            browse.query = text
            loadBrowse()
        end)
    end)
    refreshButton.Activated:Connect(function() task.spawn(loadBrowse) end)
    moreButton.Activated:Connect(function() task.spawn(loadBrowse, true) end)

    local loaded = false
    tab:GetPropertyChangedSignal("Visible"):Connect(function()
        if tab.Visible and not loaded then loaded = true; task.spawn(loadBrowse) end
    end)
end

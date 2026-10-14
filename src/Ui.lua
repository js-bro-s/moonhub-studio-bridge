local Theme = import("Theme")

local Ui = {}
local GUIDE = Enum.StudioStyleGuideColor
local RADIUS = UDim.new(0, 5)
local order = 0

function Ui.nextOrder()
    order += 1
    return order
end

function Ui.corner(parent)
    local item = Instance.new("UICorner"); item.CornerRadius = RADIUS; item.Parent = parent
end

function Ui.padding(parent, all)
    local item = Instance.new("UIPadding")
    item.PaddingTop = UDim.new(0, all); item.PaddingBottom = UDim.new(0, all)
    item.PaddingLeft = UDim.new(0, all); item.PaddingRight = UDim.new(0, all); item.Parent = parent
    return item
end

function Ui.stack(parent, gap)
    local item = Instance.new("UIListLayout")
    item.Padding = UDim.new(0, gap or 8); item.SortOrder = Enum.SortOrder.LayoutOrder; item.Parent = parent
end

function Ui.label(parent, text, height, small)
    local item = Instance.new("TextLabel")
    item.BackgroundTransparency = 1; item.Size = UDim2.new(1, 0, 0, height or 20); item.LayoutOrder = Ui.nextOrder()
    item.Font = Enum.Font.GothamMedium; item.TextSize = small and 11 or 13; item.TextWrapped = true
    item.TextXAlignment = Enum.TextXAlignment.Left; item.TextYAlignment = Enum.TextYAlignment.Top
    item.Text = text; item.Parent = parent
    Theme.bind(item, "TextColor3", small and GUIDE.SubText or GUIDE.MainText)
    return item
end

function Ui.field(parent, placeholder, value)
    local item = Instance.new("TextBox")
    item.Size = UDim2.new(1, 0, 0, 34); item.LayoutOrder = Ui.nextOrder(); item.BorderSizePixel = 0
    item.ClearTextOnFocus = false; item.Font = Enum.Font.Code; item.TextSize = 13; item.TextXAlignment = Enum.TextXAlignment.Left
    item.PlaceholderText = placeholder; item.Text = value or ""; item.Parent = parent
    Theme.bind(item, "BackgroundColor3", GUIDE.InputFieldBackground)
    Theme.bind(item, "TextColor3", GUIDE.MainText)
    Theme.bind(item, "PlaceholderColor3", GUIDE.SubText)
    Ui.corner(item); Ui.padding(item, 8)
    return item
end

function Ui.button(parent, text, accent)
    local item = Instance.new("TextButton")
    item.Size = UDim2.new(1, 0, 0, accent and 40 or 34); item.LayoutOrder = Ui.nextOrder(); item.BorderSizePixel = 0
    item.Font = Enum.Font.GothamBold; item.TextSize = 12; item.Text = text; item.Parent = parent
    if accent then
        item.BackgroundColor3 = Theme.ACCENT; item.TextColor3 = Theme.ACCENT_TEXT
    else
        Theme.bind(item, "BackgroundColor3", GUIDE.Button)
        Theme.bind(item, "TextColor3", GUIDE.ButtonText)
    end
    Ui.corner(item)
    return item
end

-- Returns a setter that updates the shown value without firing `changed`.
function Ui.dropdown(parent, values, initial, changed)
    local holder = Instance.new("Frame")
    holder.BackgroundTransparency = 1; holder.Size = UDim2.new(1, 0, 0, 34); holder.AutomaticSize = Enum.AutomaticSize.Y
    holder.LayoutOrder = Ui.nextOrder(); holder.Parent = parent
    Ui.stack(holder, 2)
    local head = Ui.button(holder, "", false)
    head.LayoutOrder = 0
    local options = {}
    local function set(index, silent)
        head.Text = values[index] .. "  ▾"
        for _, option in ipairs(options) do option.Visible = false end
        if not silent then changed(values[index]) end
    end
    for index, value in ipairs(values) do
        local option = Ui.button(holder, value, false)
        option.LayoutOrder = index; option.Visible = false
        option.Activated:Connect(function() set(index) end)
        options[index] = option
    end
    head.Activated:Connect(function()
        local open = not options[1].Visible
        for _, option in ipairs(options) do option.Visible = open end
    end)
    set(table.find(values, initial) or 1, true)
    return function(value) set(table.find(values, value) or 1, true) end
end

-- Rich-text info card. Returns the frame and its text label.
function Ui.card(parent)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 0); frame.AutomaticSize = Enum.AutomaticSize.Y; frame.BorderSizePixel = 0
    frame.LayoutOrder = Ui.nextOrder(); frame.Parent = parent
    Theme.bind(frame, "BackgroundColor3", GUIDE.InputFieldBackground)
    Ui.corner(frame); Ui.padding(frame, 10)
    local text = Instance.new("TextLabel")
    text.BackgroundTransparency = 1; text.Size = UDim2.new(1, 0, 0, 0); text.AutomaticSize = Enum.AutomaticSize.Y
    text.Font = Enum.Font.Gotham; text.TextSize = 12; text.TextWrapped = true; text.RichText = true
    text.TextXAlignment = Enum.TextXAlignment.Left; text.TextYAlignment = Enum.TextYAlignment.Top; text.Parent = frame
    Theme.bind(text, "TextColor3", GUIDE.MainText)
    return frame, text
end

function Ui.escapeRich(text)
    return (tostring(text):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

return Ui

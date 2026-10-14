local Config = import("Config")
local Store = import("Store")
local Theme = import("Theme")
local Ui = import("Ui")

local Shell = {}
local GUIDE = Enum.StudioStyleGuideColor
local HEADER, TABS, STATUS = 40, 32, 30
local TAB_COUNT = 3

local toolbar = plugin:CreateToolbar("MoonHub")
local toggle = toolbar:CreateButton("MoonHub", "Browse animations and upload Studio saves", "rbxassetid://6031075931")
toggle.ClickableWhenViewportHidden = true
local widgetInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, true, false, 400, 560, 360, 480)
local widget = plugin:CreateDockWidgetPluginGui("MoonHubBridge_v1", widgetInfo)
widget.Title = "MoonHub · Animation bridge"
widget.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
toggle.Click:Connect(function() widget.Enabled = not widget.Enabled end)

local root = Instance.new("Frame")
root.Name = "Root"; root.Size = UDim2.fromScale(1, 1); root.BorderSizePixel = 0; root.Parent = widget
Theme.bind(root, "BackgroundColor3", GUIDE.MainBackground)

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, HEADER); header.BorderSizePixel = 0; header.Parent = root
Theme.bind(header, "BackgroundColor3", GUIDE.Titlebar)
local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1; title.Size = UDim2.new(1, -150, 1, 0); title.Position = UDim2.fromOffset(14, 0)
title.Font = Enum.Font.GothamBold; title.TextSize = 13; title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "MOONHUB  /  STUDIO BRIDGE"; title.TextColor3 = Theme.ACCENT; title.Parent = header
local keyDot = Instance.new("TextLabel")
keyDot.BackgroundTransparency = 1; keyDot.Size = UDim2.new(0, 130, 1, 0); keyDot.Position = UDim2.new(1, -140, 0, 0)
keyDot.Font = Enum.Font.Gotham; keyDot.TextSize = 12; keyDot.TextXAlignment = Enum.TextXAlignment.Right
keyDot.TextTruncate = Enum.TextTruncate.AtEnd; keyDot.Parent = header

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, 0, 0, TABS); tabBar.Position = UDim2.fromOffset(0, HEADER)
tabBar.BorderSizePixel = 0; tabBar.Parent = root
Theme.bind(tabBar, "BackgroundColor3", GUIDE.Titlebar)
local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal; tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Parent = tabBar

local statusBar = Instance.new("TextButton")
statusBar.Size = UDim2.new(1, 0, 0, STATUS); statusBar.Position = UDim2.new(0, 0, 1, -STATUS)
statusBar.BorderSizePixel = 0; statusBar.AutoButtonColor = false; statusBar.Font = Enum.Font.Gotham; statusBar.TextSize = 12
statusBar.TextXAlignment = Enum.TextXAlignment.Left; statusBar.TextTruncate = Enum.TextTruncate.AtEnd
statusBar.Text = ""; statusBar.Parent = root
Theme.bind(statusBar, "BackgroundColor3", GUIDE.Titlebar)

function Shell.setStatus(message, failed)
    statusBar.Text = "   " .. message
    statusBar.TextColor3 = failed and Theme.ERR or Theme.OK
end
statusBar.Activated:Connect(function() statusBar.Text = "" end)
Shell.setStatus("Ready. Click this bar to dismiss messages.", false)

function Shell.refreshKeyDot()
    local state = Store.state
    local hasKey = state.apiKey ~= ""
    keyDot.Text = state.username and ("● " .. state.username) or (hasKey and "● key set" or "○ no key")
    keyDot.TextColor3 = hasKey and Theme.OK or Theme.ERR
end
Shell.refreshKeyDot()

local tabs, tabButtons = {}, {}

function Shell.selectTab(name)
    for tabName, frame in pairs(tabs) do frame.Visible = tabName == name end
    for tabName, tabButton in pairs(tabButtons) do
        local selected = tabName == name
        tabButton.TextColor3 = selected and Theme.ACCENT or Theme.color(GUIDE.SubText)
        tabButton.Font = selected and Enum.Font.GothamBold or Enum.Font.Gotham
    end
end

-- Returns the scrolling body frame for a new tab.
function Shell.addTab(name, order)
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(1 / TAB_COUNT, 0, 1, 0); tabButton.BackgroundTransparency = 1
    tabButton.TextSize = 12; tabButton.Text = name; tabButton.LayoutOrder = order; tabButton.Parent = tabBar
    tabButton.Activated:Connect(function() Shell.selectTab(name) end)
    tabButtons[name] = tabButton
    local body = Instance.new("ScrollingFrame")
    body.Name = name; body.Visible = false; body.BorderSizePixel = 0; body.BackgroundTransparency = 1
    body.Position = UDim2.fromOffset(0, HEADER + TABS); body.Size = UDim2.new(1, 0, 1, -(HEADER + TABS + STATUS))
    body.AutomaticCanvasSize = Enum.AutomaticSize.Y; body.CanvasSize = UDim2.new()
    body.ScrollBarThickness = 6; body.Parent = root
    Ui.padding(body, 14); Ui.stack(body)
    tabs[name] = body
    return body
end

Shell.docsUrl = Config.DOCS_URL

return Shell

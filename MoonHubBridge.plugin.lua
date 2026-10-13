-- MoonHub Studio bridge. Allow HTTP requests in Studio settings before use.
local HttpService = game:GetService("HttpService")
local Selection = game:GetService("Selection")
local ServerStorage = game:GetService("ServerStorage")

local API_BASE = "https://moonhub.dev/api"
local CATEGORIES = {"FPS Viewmodel", "Melee & Combat", "Locomotion", "Emote", "Cinematic"}
local RIGS = {"R6", "R15", "FPS Arms", "Custom"}
local toolbar = plugin:CreateToolbar("MoonHub")
local toggle = toolbar:CreateButton("MoonHub", "Browse animations and upload Studio saves", "rbxassetid://6031075931")
toggle.ClickableWhenViewportHidden = true
local widgetInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, true, false, 420, 620, 360, 460)
local widget = plugin:CreateDockWidgetPluginGui("MoonHubBridge_v1", widgetInfo)
widget.Title = "MoonHub · Library & upload"
widget.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
toggle.Click:Connect(function() widget.Enabled = not widget.Enabled end)

local function getSetting(name, fallback)
    local value = plugin:GetSetting("MoonHub_" .. name)
    return value ~= nil and value or fallback
end
local function setSetting(name, value)
    plugin:SetSetting("MoonHub_" .. name, value)
end

local root = Instance.new("Frame")
root.Name = "Root"
root.Size = UDim2.fromScale(1, 1)
root.BackgroundColor3 = Color3.fromRGB(25, 27, 31)
root.BorderSizePixel = 0
root.Parent = widget

local function label(parent, text, height, color)
    local item = Instance.new("TextLabel")
    item.BackgroundTransparency = 1; item.Size = UDim2.new(1, 0, 0, height or 22)
    item.Font = Enum.Font.GothamMedium; item.TextSize = 13; item.TextXAlignment = Enum.TextXAlignment.Left
    item.TextColor3 = color or Color3.fromRGB(224, 224, 219); item.Text = text; item.Parent = parent
    return item
end
local function field(parent, placeholder, value, height)
    local item = Instance.new("TextBox")
    item.Size = UDim2.new(1, 0, 0, height or 38); item.BackgroundColor3 = Color3.fromRGB(38, 41, 46)
    item.BorderSizePixel = 0; item.ClearTextOnFocus = false; item.Font = Enum.Font.Code; item.TextSize = 13
    item.TextColor3 = Color3.fromRGB(238, 237, 231); item.PlaceholderColor3 = Color3.fromRGB(145, 148, 151)
    item.PlaceholderText = placeholder; item.Text = value or ""; item.Parent = parent
    local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 5); corner.Parent = item
    return item
end
local function button(parent, text, height, accent)
    local item = Instance.new("TextButton")
    item.Size = UDim2.new(1, 0, 0, height or 40); item.BackgroundColor3 = accent and Color3.fromRGB(230, 105, 52) or Color3.fromRGB(48, 51, 56)
    item.BorderSizePixel = 0; item.Font = Enum.Font.GothamBold; item.TextSize = 12; item.TextColor3 = Color3.fromRGB(255, 255, 249)
    item.Text = text; item.Parent = parent
    local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 5); corner.Parent = item
    return item
end
local function cycle(parent, values, initial, changed)
    local current = table.find(values, initial) or 1
    local item = button(parent, "", 36, false)
    local function update() item.Text = values[current] .. "   ·   click to change" end
    update()
    item.Activated:Connect(function() current = current % #values + 1; update(); changed(values[current]) end)
    return function() return values[current] end, item
end

local titleLabel = label(root, "MOONHUB   /   STUDIO", 25, Color3.fromRGB(238, 112, 60))
titleLabel.Position = UDim2.fromOffset(16, 11)
local subtitle = label(root, "Browse public animations. Upload Studio saves.", 20, Color3.fromRGB(165, 168, 168))
subtitle.Position = UDim2.fromOffset(16, 34)

local browseTab = button(root, "BROWSE LIBRARY", 34, true)
browseTab.Position = UDim2.fromOffset(16, 62)
browseTab.Size = UDim2.new(0.5, -21, 0, 34)
local uploadTab = button(root, "UPLOAD SAVE", 34, false)
uploadTab.Position = UDim2.new(0.5, 5, 0, 62)
uploadTab.Size = UDim2.new(0.5, -21, 0, 34)

local function makePage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.Position = UDim2.fromOffset(16, 105)
    page.Size = UDim2.new(1, -32, 1, -166)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 5
    page.ScrollBarImageColor3 = Color3.fromRGB(105, 109, 114)
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = root
    local padding = Instance.new("UIPadding")
    padding.PaddingRight = UDim.new(0, 5)
    padding.PaddingBottom = UDim.new(0, 8)
    padding.Parent = page
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 9)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page
    return page
end

local browsePage = makePage("BrowsePage")
local uploadPage = makePage("UploadPage")
local status = label(root, "Browse MoonHub or upload a selected KeyframeSequence.", 42, Color3.fromRGB(171, 174, 176))
status.Position = UDim2.new(0, 16, 1, -52)
status.Size = UDim2.new(1, -32, 0, 40)
status.TextWrapped = true
status.TextYAlignment = Enum.TextYAlignment.Center

local function setStatus(message, failed)
    status.Text = message
    status.TextColor3 = failed and Color3.fromRGB(255, 130, 107) or Color3.fromRGB(153, 213, 160)
end

local function showPage(pageName)
    browsePage.Visible = pageName == "browse"
    uploadPage.Visible = pageName == "upload"
    browseTab.BackgroundColor3 = pageName == "browse" and Color3.fromRGB(230, 105, 52) or Color3.fromRGB(48, 51, 56)
    uploadTab.BackgroundColor3 = pageName == "upload" and Color3.fromRGB(230, 105, 52) or Color3.fromRGB(48, 51, 56)
end

local selectedCategory = getSetting("Category", "Locomotion")
local selectedRig = getSetting("Rig", "R15")
local apiKey = field(uploadPage, "mh_live_…", getSetting("ApiKey", ""), 38)
local category, categorySelector = cycle(uploadPage, CATEGORIES, selectedCategory, function(value) selectedCategory = value; setSetting("Category", value) end)
local rigType, rigTypeSelector = cycle(uploadPage, RIGS, selectedRig, function(value) selectedRig = value; setSetting("Rig", value) end)
apiKey.FocusLost:Connect(function() setSetting("ApiKey", apiKey.Text:gsub("%s", "")) end)

local apiKeyLabel = label(uploadPage, "API KEY  ·  used only for uploads", 18, Color3.fromRGB(165, 168, 168))
apiKeyLabel.LayoutOrder = 1
apiKey.LayoutOrder = 2
local categoryLabel = label(uploadPage, "EXPORT CATEGORY", 18, Color3.fromRGB(165, 168, 168))
categoryLabel.LayoutOrder = 3
categorySelector.LayoutOrder = 4
local rigLabel = label(uploadPage, "RIG TYPE", 18, Color3.fromRGB(165, 168, 168))
rigLabel.LayoutOrder = 5
rigTypeSelector.LayoutOrder = 6

local exportButton = button(uploadPage, "UPLOAD SELECTED SAVE TO MOONHUB", 42, true)
exportButton.LayoutOrder = 7
label(uploadPage, "Select a KeyframeSequence or folder in Explorer first.", 34, Color3.fromRGB(165, 168, 168)).LayoutOrder = 8
label(uploadPage, "IMPORT BY SHORT CODE", 18, Color3.fromRGB(165, 168, 168)).LayoutOrder = 9
local codeField = field(uploadPage, "MH-8492", "", 38)
codeField.LayoutOrder = 10
local importButton = button(uploadPage, "IMPORT CODE INTO SERVERSTORAGE", 40, false)
importButton.LayoutOrder = 11
showPage("browse")

local searchField = field(browsePage, "Search title or MH code", "", 36)
searchField.LayoutOrder = 1
local browseCategories = {"All animations"}
for _, value in ipairs(CATEGORIES) do table.insert(browseCategories, value) end
local browseCategoryValue = getSetting("BrowseCategory", "All animations")
local browseCategory, browseCategorySelector = cycle(browsePage, browseCategories, browseCategoryValue, function(value)
    browseCategoryValue = value
    setSetting("BrowseCategory", value)
end)
browseCategorySelector.LayoutOrder = 2
local browseButton = button(browsePage, "LOAD LIBRARY", 38, true)
browseButton.LayoutOrder = 3
local browseSummary = label(browsePage, "Public animation library", 22, Color3.fromRGB(165, 168, 168))
browseSummary.LayoutOrder = 4

local resultCards = {}
local importByCode
local browseLoading = false

local function findSequence(instance)
    if instance:IsA("KeyframeSequence") then return instance end
    return instance:FindFirstChildWhichIsA("KeyframeSequence", true)
end
local function quaternion(cf)
    local axis, angle = cf:ToAxisAngle()
    local half = angle / 2
    local sinHalf = math.sin(half)
    return axis.X * sinHalf, axis.Y * sinHalf, axis.Z * sinHalf, math.cos(half)
end
local function transformValues(cf)
    local qx, qy, qz, qw = quaternion(cf)
    return {cf.X, cf.Y, cf.Z, qx, qy, qz, qw}
end
local function serializeSequence(sequence, sourceRoot)
    local frames = sequence:GetKeyframes()
    table.sort(frames, function(a, b) return a.Time < b.Time end)
    if #frames == 0 then error("Selected save has no keyframes.") end
    local byName, maxFrame, motors = {}, 0, {}
    for _, item in ipairs(sourceRoot:GetDescendants()) do
        if item:IsA("Motor6D") then
            local offsets = {c0 = transformValues(item.C0), c1 = transformValues(item.C1)}
            motors[item.Name] = offsets
            if item.Part1 then motors[item.Part1.Name] = offsets end
        end
    end
    for _, keyframe in ipairs(frames) do
        local frame = math.max(0, math.floor(keyframe.Time * 60 + 0.5))
        maxFrame = math.max(maxFrame, frame)
        for _, pose in ipairs(keyframe:GetDescendants()) do
            if pose:IsA("Pose") then
                local name = pose.Name
                local motorOffsets = motors[name] or {}
                byName[name] = byName[name] or { boneName = name, times = {}, values = {}, c0 = motorOffsets.c0, c1 = motorOffsets.c1 }
                local track = byName[name]
                local cf = pose.CFrame
                table.insert(track.times, frame)
                for _, value in ipairs(transformValues(cf)) do table.insert(track.values, value) end
            end
        end
    end
    local tracks = {}
    for _, track in pairs(byName) do table.insert(tracks, track) end
    table.sort(tracks, function(a, b) return a.boneName < b.boneName end)
    if #tracks == 0 then error("No animated poses found in selected save.") end
    return {schemaVersion = 1, rigType = rigType(), tracks = tracks}, maxFrame
end

local function poseParent(name, rig)
    if name == "HumanoidRootPart" or name == "Root" then return nil end
    if rig == "R6" then
        if name == "Torso" then return "HumanoidRootPart" end
        if name == "Head" or name == "Left Arm" or name == "Right Arm" or name == "Left Leg" or name == "Right Leg" then return "Torso" end
        return "Torso"
    end
    if name == "LowerTorso" then return "HumanoidRootPart" end
    if name == "UpperTorso" then return "LowerTorso" end
    if name == "Head" or name == "LeftUpperArm" or name == "RightUpperArm" then return "UpperTorso" end
    if name == "LeftLowerArm" then return "LeftUpperArm" end
    if name == "RightLowerArm" then return "RightUpperArm" end
    if name == "LeftHand" then return "LeftLowerArm" end
    if name == "RightHand" then return "RightLowerArm" end
    if name == "LeftUpperLeg" or name == "RightUpperLeg" then return "LowerTorso" end
    if name == "LeftLowerLeg" then return "LeftUpperLeg" end
    if name == "RightLowerLeg" then return "RightUpperLeg" end
    if name == "LeftFoot" then return "LeftLowerLeg" end
    if name == "RightFoot" then return "RightLowerLeg" end
    return "HumanoidRootPart"
end

local function restoreAnimation(animation, code)
    local payload = animation.payload_json
    if not payload or type(payload.tracks) ~= "table" then error("Save has no supported normalized keyframe data.") end
    local times = {}
    for _, track in ipairs(payload.tracks) do
        if type(track.times) ~= "table" or type(track.values) ~= "table" then error("Animation has an invalid keyframe track.") end
        for _, frame in ipairs(track.times) do
            if type(frame) ~= "number" or frame < 0 or frame % 1 ~= 0 then error("Animation has an invalid frame time.") end
            times[frame] = true
        end
    end
    local sortedTimes = {}
    for frame in pairs(times) do table.insert(sortedTimes, frame) end
    table.sort(sortedTimes)
    if #sortedTimes == 0 then error("Save has no keyframes to import.") end

    local sequence = Instance.new("KeyframeSequence")
    sequence.Name = tostring(animation.title or "MoonHub animation") .. " (" .. code .. ")"
    sequence.Loop = false
    for _, frame in ipairs(sortedTimes) do
        local keyframe = Instance.new("Keyframe")
        keyframe.Name = "Frame " .. tostring(frame)
        keyframe.Time = frame / (animation.fps or 60)
        keyframe.Parent = sequence
        local poseCache = {}
        local function ensurePose(name)
            if poseCache[name] then return poseCache[name] end
            local pose = Instance.new("Pose")
            pose.Name = name
            pose.CFrame = CFrame.new()
            poseCache[name] = pose
            local parentName = poseParent(name, animation.rig_type or "R15")
            pose.Parent = parentName and ensurePose(parentName) or keyframe
            return pose
        end
        ensurePose("HumanoidRootPart")
        for _, track in ipairs(payload.tracks) do
            for index, trackFrame in ipairs(track.times) do
                if trackFrame == frame then
                    local offset = (index - 1) * 7
                    local values = track.values
                    local pose = ensurePose(tostring(track.boneName or "HumanoidRootPart"))
                    pose.CFrame = CFrame.new(values[offset+1], values[offset+2], values[offset+3], values[offset+4], values[offset+5], values[offset+6], values[offset+7])
                    break
                end
            end
        end
    end
    local folder = ServerStorage:FindFirstChild("MoonAnimator2Saves")
    if not folder then folder = Instance.new("Folder"); folder.Name = "MoonAnimator2Saves"; folder.Parent = ServerStorage end
    sequence.Parent = folder
    Selection:Set({sequence})
end

importByCode = function(code, title)
    local normalized = tostring(code or ""):upper():gsub("%s", "")
    if not normalized:match("^MH%-%d%d%d%d$") then setStatus("Enter a code like MH-8492.", true); return end
    setStatus("Fetching " .. tostring(title or normalized) .. "…", false)
    task.spawn(function()
        local ok, err = pcall(function()
            local response = HttpService:RequestAsync({Url = API_BASE .. "/anim/" .. normalized, Method = "GET"})
            if not response.Success then error("Could not fetch " .. normalized .. " (" .. tostring(response.StatusCode) .. ").") end
            restoreAnimation(HttpService:JSONDecode(response.Body), normalized)
        end)
        if ok then setStatus("Imported " .. normalized .. " into ServerStorage.MoonAnimator2Saves.", false)
        else setStatus(tostring(err), true) end
    end)
end

local function createResultCard(animation, order)
    if type(animation) ~= "table" or type(animation.short_code) ~= "string" then return false end
    local card = Instance.new("Frame")
    card.Name = "AnimationResult"
    card.Size = UDim2.new(1, 0, 0, 94)
    card.BackgroundColor3 = Color3.fromRGB(34, 37, 42)
    card.BorderSizePixel = 0
    card.LayoutOrder = 100 + order
    card.Parent = browsePage
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = card

    local animationTitle = label(card, tostring(animation.title or "Untitled animation"), 36, Color3.fromRGB(238, 237, 231))
    animationTitle.Position = UDim2.fromOffset(11, 8)
    animationTitle.Size = UDim2.new(1, -120, 0, 36)
    animationTitle.Font = Enum.Font.GothamBold
    animationTitle.TextWrapped = true
    animationTitle.TextYAlignment = Enum.TextYAlignment.Top
    local metadata = label(card, tostring(animation.category or "Animation") .. "  ·  " .. tostring(animation.rig_type or "Custom") .. "  ·  " .. animation.short_code, 18, Color3.fromRGB(238, 112, 60))
    metadata.Position = UDim2.fromOffset(11, 49)
    metadata.Size = UDim2.new(1, -120, 0, 18)
    metadata.TextSize = 11
    local author = label(card, "by " .. tostring(animation.author or "MoonHub creator"), 16, Color3.fromRGB(165, 168, 168))
    author.Position = UDim2.fromOffset(11, 69)
    author.Size = UDim2.new(1, -120, 0, 16)
    author.TextSize = 11
    local importResult = button(card, "IMPORT", 32, false)
    importResult.Position = UDim2.new(1, -101, 0.5, -16)
    importResult.Size = UDim2.fromOffset(90, 32)
    importResult.Activated:Connect(function() importByCode(animation.short_code, animation.title) end)
    table.insert(resultCards, card)
    return true
end

local function loadLibrary()
    if browseLoading then return end
    browseLoading = true
    browseButton.Active = false
    browseButton.Text = "LOADING LIBRARY…"
    local url = API_BASE .. "/animations?view=summary&limit=20"
    local query = searchField.Text:gsub("^%s+", ""):gsub("%s+$", "")
    if query ~= "" then url = url .. "&q=" .. HttpService:UrlEncode(query) end
    local chosenCategory = browseCategory()
    if chosenCategory ~= "All animations" then url = url .. "&category=" .. HttpService:UrlEncode(chosenCategory) end
    task.spawn(function()
        local ok, result = pcall(function()
            local response = HttpService:RequestAsync({Url = url, Method = "GET"})
            if not response.Success then error("Library request failed (" .. tostring(response.StatusCode) .. ").") end
            local rows = HttpService:JSONDecode(response.Body)
            if type(rows) ~= "table" or rows.error then error(type(rows) == "table" and tostring(rows.error) or "MoonHub returned an invalid library response.") end
            for _, card in ipairs(resultCards) do card:Destroy() end
            table.clear(resultCards)
            local count = 0
            for _, animation in ipairs(rows) do
                if createResultCard(animation, count + 1) then count += 1 end
            end
            return count
        end)
        browseLoading = false
        browseButton.Active = true
        browseButton.Text = "LOAD LIBRARY"
        if not ok then
            browseSummary.Text = "Could not load library. Check HTTP settings and connection."
            setStatus(tostring(result), true)
        elseif result == 0 then
            browseSummary.Text = "No animations match. Change search or category."
            setStatus("No public animations found.", false)
        else
            browseSummary.Text = tostring(result) .. " recent public animations"
            setStatus("Library loaded. Select an animation to import.", false)
        end
    end)
end

browseButton.Activated:Connect(loadLibrary)
searchField.FocusLost:Connect(function(enterPressed) if enterPressed then loadLibrary() end end)
importButton.Activated:Connect(function() importByCode(codeField.Text) end)

exportButton.Activated:Connect(function()
    local key = apiKey.Text:gsub("%s", "")
    if key == "" then setStatus("Add API key. Create one at moonhub.dev/dashboard.", true); return end
    local selection = Selection:Get()
    if #selection == 0 then setStatus("Select a KeyframeSequence or save folder first.", true); return end
    local sequence = findSequence(selection[1])
    if not sequence then setStatus("No KeyframeSequence found in selected object.", true); return end
    exportButton.Active = false
    exportButton.Text = "UPLOADING…"
    setStatus("Uploading " .. sequence.Name .. "…", false)
    task.spawn(function()
        local ok, result = pcall(function()
            local payload, duration = serializeSequence(sequence, selection[1])
            local response = HttpService:RequestAsync({
                Url = API_BASE .. "/upload", Method = "POST",
                Headers = { ["Content-Type"] = "application/json", Authorization = "Bearer " .. key },
                Body = HttpService:JSONEncode({ title = sequence.Name, category = category(), rig_type = rigType(), duration_frames = math.max(duration, 1), fps = 60, payload_json = payload, tags = "moon-animator,studio" }),
            })
            if not response.Success then error("Upload failed (" .. tostring(response.StatusCode) .. "): " .. response.Body) end
            return HttpService:JSONDecode(response.Body)
        end)
        exportButton.Active = true
        exportButton.Text = "UPLOAD SELECTED SAVE TO MOONHUB"
        if ok then setStatus("Published " .. result.short_code .. " · " .. result.url, false)
        else setStatus(tostring(result), true) end
    end)
end)

browseTab.Activated:Connect(function() showPage("browse") end)
uploadTab.Activated:Connect(function() showPage("upload") end)

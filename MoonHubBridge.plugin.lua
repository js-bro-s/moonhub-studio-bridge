-- MoonHub Studio bridge. Allow HTTP requests in Studio settings before use.
local HttpService = game:GetService("HttpService")
local Selection = game:GetService("Selection")
local ServerStorage = game:GetService("ServerStorage")

local API_BASE = "https://moonhub.dev/api"
local CATEGORIES = {"FPS Viewmodel", "Melee & Combat", "Locomotion", "Emote", "Cinematic"}
local RIGS = {"R6", "R15", "FPS Arms", "Custom"}
local toolbar = plugin:CreateToolbar("MoonHub")
local toggle = toolbar:CreateButton("MoonHub", "Open MoonHub animation bridge", "rbxassetid://6031075931")
toggle.ClickableWhenViewportHidden = true
local widgetInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, true, false, 380, 510, 330, 410)
local widget = plugin:CreateDockWidgetPluginGui("MoonHubBridge_v1", widgetInfo)
widget.Title = "MoonHub · Animation bridge"
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
local pad = Instance.new("UIPadding")
pad.PaddingTop = UDim.new(0, 18); pad.PaddingBottom = UDim.new(0, 16)
pad.PaddingLeft = UDim.new(0, 18); pad.PaddingRight = UDim.new(0, 18); pad.Parent = root
local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 10); list.SortOrder = Enum.SortOrder.LayoutOrder; list.Parent = root

local function label(text, height, color)
    local item = Instance.new("TextLabel")
    item.BackgroundTransparency = 1; item.Size = UDim2.new(1, 0, 0, height or 22)
    item.Font = Enum.Font.GothamMedium; item.TextSize = 13; item.TextXAlignment = Enum.TextXAlignment.Left
    item.TextColor3 = color or Color3.fromRGB(224, 224, 219); item.Text = text; item.Parent = root
    return item
end
local function field(placeholder, value, height)
    local item = Instance.new("TextBox")
    item.Size = UDim2.new(1, 0, 0, height or 38); item.BackgroundColor3 = Color3.fromRGB(38, 41, 46)
    item.BorderSizePixel = 0; item.ClearTextOnFocus = false; item.Font = Enum.Font.Code; item.TextSize = 13
    item.TextColor3 = Color3.fromRGB(238, 237, 231); item.PlaceholderColor3 = Color3.fromRGB(145, 148, 151)
    item.PlaceholderText = placeholder; item.Text = value or ""; item.Parent = root
    local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 5); corner.Parent = item
    return item
end
local function button(text, height, accent)
    local item = Instance.new("TextButton")
    item.Size = UDim2.new(1, 0, 0, height or 40); item.BackgroundColor3 = accent and Color3.fromRGB(230, 105, 52) or Color3.fromRGB(48, 51, 56)
    item.BorderSizePixel = 0; item.Font = Enum.Font.GothamBold; item.TextSize = 12; item.TextColor3 = Color3.fromRGB(255, 255, 249)
    item.Text = text; item.Parent = root
    local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 5); corner.Parent = item
    return item
end
local function cycle(values, initial, changed)
    local current = table.find(values, initial) or 1
    local item = button("", 36, false)
    local function update() item.Text = values[current] .. "   ·   click to change" end
    update()
    item.Activated:Connect(function() current = current % #values + 1; update(); changed(values[current]) end)
    return function() return values[current] end
end

label("MOONHUB   /   STUDIO BRIDGE", 25, Color3.fromRGB(238, 112, 60))
label("Export animation saves. Import by short code.", 20, Color3.fromRGB(165, 168, 168))
label("API KEY", 15, Color3.fromRGB(165, 168, 168))
local apiKey = field("mh_live_…", getSetting("ApiKey", ""), 38)
apiKey.FocusLost:Connect(function() setSetting("ApiKey", apiKey.Text:gsub("%s", "")) end)
label("EXPORT CATEGORY", 15, Color3.fromRGB(165, 168, 168))
local selectedCategory = getSetting("Category", "Locomotion")
local category = cycle(CATEGORIES, selectedCategory, function(value) selectedCategory = value; setSetting("Category", value) end)
label("RIG TYPE", 15, Color3.fromRGB(165, 168, 168))
local selectedRig = getSetting("Rig", "R15")
local rigType = cycle(RIGS, selectedRig, function(value) selectedRig = value; setSetting("Rig", value) end)
local status = label("Select a Moon Animator KeyframeSequence or save folder.", 34, Color3.fromRGB(171, 174, 176))
status.TextWrapped = true

local function setStatus(message, failed)
    status.Text = message
    status.TextColor3 = failed and Color3.fromRGB(255, 130, 107) or Color3.fromRGB(153, 213, 160)
end
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

local exportButton = button("EXPORT SELECTED SAVE TO MOONHUB", 42, true)
exportButton.Activated:Connect(function()
    local key = apiKey.Text:gsub("%s", "")
    if key == "" then setStatus("Add API key. Create one at moonhub.dev/dashboard.", true); return end
    local selection = Selection:Get()
    if #selection == 0 then setStatus("Select a KeyframeSequence or save folder first.", true); return end
    local sequence = findSequence(selection[1])
    if not sequence then setStatus("No KeyframeSequence found in selected object.", true); return end
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
    if ok then setStatus("Published " .. result.short_code .. " · " .. result.url, false)
    else setStatus(tostring(result), true) end
end)

label("IMPORT BY SHORT CODE", 15, Color3.fromRGB(165, 168, 168))
local codeField = field("MH-8492", "", 38)
local importButton = button("FETCH SAVE INTO SERVERSTORAGE", 40, false)
importButton.Activated:Connect(function()
    local code = codeField.Text:upper():gsub("%s", "")
    if not code:match("^MH%-%d%d%d%d$") then setStatus("Enter code like MH-8492.", true); return end
    local ok, err = pcall(function()
        local response = HttpService:RequestAsync({Url = API_BASE .. "/anim/" .. code, Method = "GET"})
        if not response.Success then error("Could not fetch " .. code .. " (" .. tostring(response.StatusCode) .. ").") end
        local animation = HttpService:JSONDecode(response.Body)
        local payload = animation.payload_json
        if not payload or type(payload.tracks) ~= "table" then error("Save has no supported normalized keyframe data.") end
        local times = {}
        for _, track in ipairs(payload.tracks) do for _, frame in ipairs(track.times) do times[frame] = true end end
        local sortedTimes = {}
        for frame in pairs(times) do table.insert(sortedTimes, frame) end
        table.sort(sortedTimes)
        if #sortedTimes == 0 then error("Save has no keyframes to import.") end
        local sequence = Instance.new("KeyframeSequence")
        sequence.Name = animation.title .. " (" .. code .. ")"
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
                        local v = track.values
                        local pose = ensurePose(track.boneName)
                        pose.CFrame = CFrame.new(v[offset+1], v[offset+2], v[offset+3], v[offset+4], v[offset+5], v[offset+6], v[offset+7])
                        break
                    end
                end
            end
        end
        local folder = ServerStorage:FindFirstChild("MoonAnimator2Saves")
        if not folder then folder = Instance.new("Folder"); folder.Name = "MoonAnimator2Saves"; folder.Parent = ServerStorage end
        sequence.Parent = folder
        Selection:Set({sequence})
    end)
    if ok then setStatus("Imported " .. code .. " into ServerStorage.MoonAnimator2Saves.", false)
    else setStatus(tostring(err), true) end
end)

label("Enable Studio HTTP requests in Game Settings → Security.", 22, Color3.fromRGB(145, 148, 151))

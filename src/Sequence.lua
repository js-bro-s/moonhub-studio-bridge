local ServerStorage = game:GetService("ServerStorage")
local Selection = game:GetService("Selection")

local Sequence = {}

function Sequence.findAll(instance)
    local found = {}
    if instance:IsA("KeyframeSequence") then table.insert(found, instance) end
    for _, item in ipairs(instance:GetDescendants()) do
        if item:IsA("KeyframeSequence") then table.insert(found, item) end
    end
    return found
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
function Sequence.serialize(sequence, sourceRoot, rig)
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
    return {schemaVersion = 1, rigType = rig, tracks = tracks}, maxFrame
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

function Sequence.restoreAnimation(animation, code)
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


return Sequence

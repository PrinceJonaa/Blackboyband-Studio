-- BBB Crew Showcase HUD. Separate from the original rooftop solo jam.
-- Visual-only beats until owned/approved BBB audio is published to Roblox.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("BBBShowtimeEvent")
local gui = Instance.new("ScreenGui")
gui.Name = "BBBShowtimeHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Name = "ShowtimePanel"
panel.AnchorPoint = Vector2.new(0.5, 1)
panel.Position = UDim2.new(0.5, 0, 0.92, 0)
panel.Size = UDim2.new(0.86, 0, 0, 152)
panel.BackgroundColor3 = Color3.fromRGB(16, 20, 39)
panel.BackgroundTransparency = 0.07
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = gui
local maxWidth = Instance.new("UISizeConstraint")
maxWidth.MaxSize = Vector2.new(480, 180)
maxWidth.MinSize = Vector2.new(220, 130)
maxWidth.Parent = panel
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = panel

local function label(name, pos, size, fontSize, tint)
    local t = Instance.new("TextLabel")
    t.Name = name
    t.Position = pos
    t.Size = size
    t.BackgroundTransparency = 1
    t.TextColor3 = tint or Color3.fromRGB(237, 245, 255)
    t.Font = Enum.Font.GothamBold
    t.TextSize = fontSize
    t.TextWrapped = true
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Parent = panel
    return t
end

local title = label("Title", UDim2.new(0, 14, 0, 7),
    UDim2.new(1, -145, 0, 28), 18, Color3.fromRGB(120, 242, 239))
title.Text = "BBB CREW SHOW"
local details = label("Details", UDim2.new(0, 14, 0, 37),
    UDim2.new(1, -145, 0, 48), 15)
details.Text = "Join the rooftop showcase!"
local feedback = label("Feedback", UDim2.new(0, 14, 0, 91),
    UDim2.new(1, -145, 0, 46), 16, Color3.fromRGB(244, 194, 111))
feedback.Text = ""

local hit = Instance.new("TextButton")
hit.Name = "PerformanceHit"
hit.Position = UDim2.new(1, -132, 0, 19)
hit.Size = UDim2.fromOffset(116, 112)
hit.Text = "HIT"
hit.TextSize = 28
hit.TextColor3 = Color3.fromRGB(255, 255, 255)
hit.BackgroundColor3 = Color3.fromRGB(112, 70, 181)
hit.Font = Enum.Font.GothamBlack
hit.BorderSizePixel = 0
hit.Visible = false
hit.Parent = panel
local hitCorner = Instance.new("UICorner")
hitCorner.CornerRadius = UDim.new(0, 12)
hitCorner.Parent = hit

local state = "idle"
local role = ""
local startAt = 0
local bpm, beats = 96, 16
local hideVersion = 0

local function targetFor(beat)
    if role == "LEAD" then return beat % 2 == 0 end
    if role == "CREW" then return beat % 4 == 0 or beat % 4 == 3 end
    if role == "LIGHTS" then return beat % 2 == 1 end
    if role == "HYPE" then return beat % 4 == 3 end
    return false
end

local function tap()
    if state ~= "playing" then return end
    remote:FireServer("hit")
end
hit.Activated:Connect(tap)
UserInputService.InputBegan:Connect(function(input, processed)
    if processed or state ~= "playing" then return end
    if input.KeyCode == Enum.KeyCode.G or input.KeyCode == Enum.KeyCode.ButtonX then
        tap()
    end
end)

remote.OnClientEvent:Connect(function(kind, data)
    if kind == "lobby" then
        hideVersion += 1
        state = "lobby"
        role = data.role
        startAt = data.startAt
        panel.Visible = true
        hit.Visible = false
        feedback.Text = "Invite friends through the game's INVITE button."
        title.Text = "BBB SHOWCASE • " .. role
    elseif kind == "go" then
        hideVersion += 1
        state = "playing"
        role = data.role
        bpm, beats = data.bpm, data.beats
        startAt = data.startAt
        panel.Visible = true
        hit.Visible = true
        feedback.Text = "Use G / X / HIT on your role's beats!"
        title.Text = "BBB SHOWCASE • " .. role
    elseif kind == "grade" then
        feedback.Text = string.format("%s • %d hits • %d pts",
            data.grade, data.hits, data.points)
    elseif kind == "finish" then
        state = "ended"
        hit.Visible = false
        panel.Visible = true
        details.Text = string.format("Crowd energy %d%% • %d people", data.audience, data.members)
        feedback.Text = string.format("Your take: %d hits • +%d Fans today",
            data.hits, data.fans)
        hideVersion += 1
        local version = hideVersion
        task.delay(6, function()
            if hideVersion == version then
                panel.Visible = false
                state = "idle"
            end
        end)
    elseif kind == "notice" then
        if state == "idle" or state == "ended" then
            hideVersion += 1
            local version = hideVersion
            state = "ended"
            panel.Visible = true
            hit.Visible = false
            details.Text = data
            feedback.Text = "Use the rooftop show prompt to join the next performance."
            task.delay(4, function()
                if hideVersion == version then
                    panel.Visible = false
                    state = "idle"
                end
            end)
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if state ~= "playing" and state ~= "lobby" then return end
    local remaining = startAt - workspace:GetServerTimeNow()
    if state == "lobby" then
        details.Text = string.format("Role: %s • %d seconds until show",
            role, math.max(0, math.ceil(remaining)))
        return
    end
    if remaining > 0 then
        details.Text = string.format("Show begins in %.1f seconds", remaining)
        hit.Text = "READY"
        hit.BackgroundColor3 = Color3.fromRGB(112, 70, 181)
    else
        local interval = 60 / bpm
        local elapsed = -remaining
        local beat = math.clamp(math.floor(elapsed / interval + 0.5), 0, beats - 1)
        local desired = targetFor(beat)
        hit.Text = desired and "HIT!" or "WAIT"
        hit.BackgroundColor3 = desired and Color3.fromRGB(27, 154, 149)
            or Color3.fromRGB(86, 80, 113)
        details.Text = string.format("%s • Beat %d/%d • %s",
            role, math.clamp(beat + 1, 1, beats), beats,
            desired and "YOUR CUE" or "WAIT FOR CUE")
    end
end)

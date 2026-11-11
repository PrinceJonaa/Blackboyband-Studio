-- BBB World M0: independent server-owned Roblox greybox.
-- BBB-only world and progression; no assets, code, or saves imported from another game.
local Players = game:GetService("Players")
local Progression = require(script.Parent:WaitForChild("Progression"))
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local BPM, BEATS = 96, 16
local INTERVAL = 60 / BPM
local STAGE = Vector3.new(68, 17, 70)
local POSTER_IDS = {"shop", "mel", "noel"}
local profiles = {}
local sessions = {}
local recordQuest -- forward declaration for TV interaction, populated after profile setup
local updateFans -- forward declaration for daily dance events

local action = Instance.new("RemoteEvent")
action.Name = "BBBWorldEvent"
action.Parent = ReplicatedStorage

local root = Instance.new("Folder")
root.Name = "BBBWorldM0"
root.Parent = workspace
Lighting.ClockTime = 20

local function block(name, size, position, color, material, parent)
    local item = Instance.new("Part")
    item.Name = name
    item.Size = size
    item.Position = position
    item.Color = color
    item.Material = material or Enum.Material.SmoothPlastic
    item.Anchored = true
    item.Parent = parent or root
    return item
end

local function sign(text, position, color)
    local anchor = block("Sign: " .. text, Vector3.new(1, 1, 1),
        position, Color3.new(1, 1, 1), Enum.Material.SmoothPlastic)
    anchor.Transparency = 1
    anchor.CanCollide = false
    local gui = Instance.new("BillboardGui")
    gui.Name = "WorldLabel"
    gui.Adornee = anchor
    gui.Size = UDim2.fromOffset(220, 56)
    gui.StudsOffset = Vector3.new(0, 2.5, 0)
    gui.AlwaysOnTop = true
    gui.MaxDistance = 120
    gui.Parent = anchor
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundColor3 = Color3.fromRGB(8, 10, 22)
    label.BackgroundTransparency = 0.12
    label.BorderSizePixel = 0
    label.TextColor3 = color or Color3.fromRGB(235, 243, 255)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Text = text
    label.Parent = gui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = label
    return anchor
end

local function interaction(name, position, verb, callback)
    local target = block(name .. "Trigger", Vector3.new(2, 2, 2), position,
        Color3.new(1, 1, 1))
    target.Transparency = 1
    target.CanCollide = false
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = verb
    prompt.ObjectText = name
    prompt.MaxActivationDistance = 12
    prompt.HoldDuration = 0.25
    prompt.RequiresLineOfSight = false
    prompt.Parent = target
    prompt.Triggered:Connect(function(player)
        -- Prompt activation is not sufficient authority by itself.
        -- Check the player's server-observed avatar position for every prompt.
        local character = player.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not rootPart or not humanoid or humanoid.Health <= 0
            or (rootPart.Position - position).Magnitude > 16 then
            return
        end
        callback(player)
    end)
    return target
end

local function near(player, destination, radius)
    local character = player.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    return rootPart ~= nil and (rootPart.Position - destination).Magnitude <= radius
end

local function notify(player, message)
    action:FireClient(player, "notice", message)
end

local function site(name, center, color)
    block(name .. " Platform", Vector3.new(52, 2, 42),
        center + Vector3.new(0, 0, 0), color)
    sign(name, center + Vector3.new(0, 3, -12))
    block(name .. " Back Wall", Vector3.new(52, 15, 2),
        center + Vector3.new(0, 8, -21), Color3.fromRGB(23, 27, 45))
    block(name .. " Light", Vector3.new(45, 1, 1),
        center + Vector3.new(0, 12, -19.5), color, Enum.Material.Neon)
end

-- One traversable neighborhood; raised roof uses an explicit in-world lift.
block("Street", Vector3.new(320, 2, 320), Vector3.new(0, -2, 0),
    Color3.fromRGB(27, 30, 44), Enum.Material.Asphalt)
block("BBB Plaza", Vector3.new(58, 2, 58), Vector3.new(0, 0, 0),
    Color3.fromRGB(35, 37, 64))
sign("BLACK BOY BAND / THE BLOCK", Vector3.new(0, 5, -14),
    Color3.fromRGB(103, 244, 245))

site("JONA STUDIO", Vector3.new(84, 0, -54), Color3.fromRGB(66, 117, 163))
site("RECORD SHOP", Vector3.new(-84, 0, -54), Color3.fromRGB(166, 77, 103))
site("MEL COMIC CORNER", Vector3.new(-84, 0, 64), Color3.fromRGB(125, 77, 173))
site("NOEL SOUND YARD", Vector3.new(84, 0, 4), Color3.fromRGB(50, 151, 132))

local spawn = Instance.new("SpawnLocation")
spawn.Name = "BBB Plaza Spawn"
spawn.Size = Vector3.new(12, 1, 12)
spawn.Position = Vector3.new(0, 2, 10)
spawn.Color = Color3.fromRGB(78, 202, 216)
spawn.Anchored = true
spawn.Neutral = true
spawn.Parent = root

block("Rooftop", Vector3.new(60, 2, 60), Vector3.new(68, 15, 70),
    Color3.fromRGB(65, 73, 98))
for _, wall in ipairs({
    {Vector3.new(68, 19, 40), Vector3.new(60, 6, 2)},
    {Vector3.new(68, 19, 100), Vector3.new(60, 6, 2)},
    {Vector3.new(38, 19, 70), Vector3.new(2, 6, 60)},
    {Vector3.new(98, 19, 70), Vector3.new(2, 6, 60)},
}) do
    block("Rooftop Parapet", wall[2], wall[1], Color3.fromRGB(36, 42, 62))
end
sign("ROOFTOP JAM", Vector3.new(68, 20, 60), Color3.fromRGB(255, 199, 90))
block("Stage", Vector3.new(26, 1.5, 16), Vector3.new(68, 17, 75),
    Color3.fromRGB(111, 70, 153))
sign("96 BPM / 16 BEATS", Vector3.new(68, 21, 81), Color3.fromRGB(242, 191, 255))

local function teleport(player, position)
    if player.Character then
        player.Character:PivotTo(CFrame.new(position))
    end
end

-- The signature BBB TV works as an in-world channel selector, not a dialog.
block("BBB CRT Frame", Vector3.new(15, 11, 3), Vector3.new(-19, 6.5, 0),
    Color3.fromRGB(12, 11, 25))
block("BBB CRT Screen", Vector3.new(11.5, 8, 0.4), Vector3.new(-19, 7, 1.7),
    Color3.fromRGB(58, 183, 208), Enum.Material.Neon)
block("BBB CRT Tuner", Vector3.new(1, 4, 1), Vector3.new(-12.5, 6, 2.2),
    Color3.fromRGB(231, 158, 83), Enum.Material.Neon)
sign("TUNE INTO BBB", Vector3.new(-19, 14, 0), Color3.fromRGB(137, 233, 255))
local channelStops = {
    {name = "Jona Studio", at = Vector3.new(84, 5, -42)},
    {name = "Record Shop", at = Vector3.new(-84, 5, -42)},
    {name = "Mel Comic Corner", at = Vector3.new(-84, 5, 75)},
    {name = "Noel Sound Yard", at = Vector3.new(84, 5, 18)},
    {name = "Rooftop Jam", at = Vector3.new(57, 20, 54)},
}
local channelNumber = {}
interaction("BBB Channel TV", Vector3.new(-19, 3, 5), "Tune channel", function(player)
    local index = (channelNumber[player] or 0) % #channelStops + 1
    channelNumber[player] = index
    local channel = channelStops[index]
    teleport(player, channel.at)
    notify(player, "BBB TV channel " .. index .. ": " .. channel.name)
    recordQuest(player, "tune")
end)
Players.PlayerRemoving:Connect(function(player)
    channelNumber[player] = nil
end)

sign("ROOFTOP LIFT", Vector3.new(22, 4, 25))
interaction("Rooftop Lift", Vector3.new(22, 3, 25), "Go up", function(player)
    teleport(player, Vector3.new(57, 20, 54))
end)
interaction("Return to Plaza", Vector3.new(49, 19, 51), "Go down", function(player)
    teleport(player, Vector3.new(12, 5, 10))
end)


-- Persistent profile owns data (with a single server lock); local profiles are
-- references only, to keep existing map interactions narrowly scoped.
updateFans = function(player)
    local profile = profiles[player]
    local stats = player:FindFirstChild("leaderstats")
    local fans = stats and stats:FindFirstChild("Fans")
    if profile and fans then
        fans.Value = profile.fans
        local daily = Progression.daily(player)
        if daily then action:FireClient(player, "quests", daily) end
        player:SetAttribute("BBBStampCount", profile.stamps or 0)
        player:SetAttribute("BBBArtistTitleUnlocked", (profile.stamps or 0) >= 3)
        player:SetAttribute("BBBSpotlightUnlocked", (profile.stamps or 0) >= 7)
    end
end

local function giveFans(player, count)
    if Progression.reward(player, count) then updateFans(player) end
end

recordQuest = function(player, kind)
    local done, stamp = Progression.record(player, kind)
    if done then
        updateFans(player)
        notify(player, stamp and "DAILY SET COMPLETE! +1 B-Side Stamp +40 Fans"
            or "Daily mission completed! +20 Fans")
    end
end

Players.PlayerAdded:Connect(function(player)
    local stats = Instance.new("Folder")
    stats.Name = "leaderstats"
    stats.Parent = player
    local fans = Instance.new("IntValue")
    fans.Name = "Fans"
    fans.Parent = stats

    local profile, persistent = Progression.load(player)
    if not profile then return end
    profiles[player] = profile
    updateFans(player)
    if not persistent then
        notify(player, "Progress is temporary this session; saved data is protected.")
    end
end)

Players.PlayerRemoving:Connect(function(player)
    Progression.release(player)
    profiles[player] = nil
    sessions[player] = nil
end)

game:BindToClose(function()
    local pending = 0
    for _, player in ipairs(Players:GetPlayers()) do
        pending += 1
        task.spawn(function()
            Progression.release(player)
            pending -= 1
        end)
    end
    local deadline = os.clock() + 24
    while pending > 0 and os.clock() < deadline do task.wait(0.1) end
end)

action.OnServerEvent:Connect(function(player, kind)
    if kind == "quest-view" and profiles[player] then
        local daily = Progression.daily(player)
        if daily then action:FireClient(player, "quests", daily) end
    end
end)

local posterPlaces = {
    {id = "shop", at = Vector3.new(-86, 4, -39), color = Color3.fromRGB(250, 126, 175)},
    {id = "mel", at = Vector3.new(-85, 4, 81), color = Color3.fromRGB(194, 135, 253)},
    {id = "noel", at = Vector3.new(82, 4, 18), color = Color3.fromRGB(107, 252, 192)},
}
for _, poster in ipairs(posterPlaces) do
    local id = poster.id
    local at = poster.at
    block("Poster " .. id, Vector3.new(5, 5, 0.5), at, poster.color, Enum.Material.Neon)
    sign("BBB POSTER / " .. string.upper(id), at + Vector3.new(0, 2, 0))
    interaction("BBB Poster " .. id, at + Vector3.new(0, 0, 3), "Collect", function(player)
        if not near(player, at, 16) then return end
        local profile = profiles[player]
        if not profile then return end
        if profile.posters[id] then
            notify(player, "You already discovered this poster.")
            return
        end
        profile.posters[id] = true
        giveFans(player, 10)
        notify(player, "Poster found! +10 Fans")
        local allFound = true
        for _, otherId in ipairs(POSTER_IDS) do
            if not profile.posters[otherId] then allFound = false; break end
        end
        if allFound then
            giveFans(player, 25)
            notify(player, "All 3 posters! +25 bonus Fans")
        end
    end)
end

-- MIT-source study: Velmora's DanceFloorService inspired server-owned occupancy.
-- This implementation uses original BBB geometry and avatar-root checks.
local DANCE_CENTER = Vector3.new(-15, 1.5, 36)
local DANCE_HALF_WIDTH = 14
local danceFloor = block("BBB Dance Floor", Vector3.new(28, 0.6, 28),
    Vector3.new(-15, 0.5, 36), Color3.fromRGB(96, 57, 153), Enum.Material.Neon)
sign("BBB DANCE FLOOR", Vector3.new(-15, 4, 36), Color3.fromRGB(252, 137, 231))
local lightTiles = {}
local danceSeconds = {}
local crewSeconds = {}
local dancedDay = {}
local crewDay = {}
Players.PlayerRemoving:Connect(function(player)
    danceSeconds[player], crewSeconds[player] = nil, nil
    dancedDay[player], crewDay[player] = nil, nil
end)
for x = -2, 2 do
    for z = -2, 2 do
        local tile = block("Dance Tile", Vector3.new(4.7, 0.15, 4.7),
            Vector3.new(-15 + x * 5.3, 0.88, 36 + z * 5.3),
            (x + z) % 2 == 0 and Color3.fromRGB(93, 212, 223) or Color3.fromRGB(207, 87, 200),
            Enum.Material.Neon)
        tile.CanCollide = false
        table.insert(lightTiles, tile)
    end
end
task.spawn(function()
    local phase = false
    while danceFloor.Parent do
        local dancers = 0
        local onFloor = {}
        for _, player in ipairs(Players:GetPlayers()) do
            local character = player.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if character then
                local here = rootPart ~= nil and humanoid ~= nil and humanoid.Health > 0
                    and math.abs(rootPart.Position.X - DANCE_CENTER.X) <= DANCE_HALF_WIDTH
                    and math.abs(rootPart.Position.Z - DANCE_CENTER.Z) <= DANCE_HALF_WIDTH
                    and math.abs(rootPart.Position.Y - DANCE_CENTER.Y) <= 8
                if character:GetAttribute("BBBDanceFloor") ~= here then
                    character:SetAttribute("BBBDanceFloor", here)
                end
                if here then
                    dancers += 1
                    table.insert(onFloor, player)
                    danceSeconds[player] = (danceSeconds[player] or 0) + 0.35
                    local day = math.floor(os.time() / 86400)
                    if danceSeconds[player] >= 20 and dancedDay[player] ~= day then
                        dancedDay[player] = day
                        recordQuest(player, "dance")
                    end
                else
                    danceSeconds[player] = 0
                    crewSeconds[player] = 0
                end
            end
        end
        for _, player in ipairs(onFloor) do
            if dancers >= 2 then
                crewSeconds[player] = (crewSeconds[player] or 0) + 0.35
                local day = math.floor(os.time() / 86400)
                if crewSeconds[player] >= 15 and crewDay[player] ~= day then
                    crewDay[player] = day
                    if Progression.crew(player) then
                        updateFans(player)
                        notify(player, "CREW DANCE! +15 Fans for dancing together")
                    end
                end
            else
                crewSeconds[player] = 0
            end
        end
        phase = not phase
        for i, tile in ipairs(lightTiles) do
            tile.Transparency = (i % 2 == 0) == phase and 0.08 or 0.35
        end
        danceFloor:SetAttribute("DancerCount", dancers)
        task.wait(0.35)
    end
end)

-- Backstage obby: a small optional parkour detour with one saved completion.
-- Round/checkpoint patterns were studied from MIT-licensed Sky Scramble;
-- BBB geometry, rules, reward, and implementation are newly authored.
local obbyStart = Vector3.new(107, 11, 42)
local obbyEnd = Vector3.new(147, 16, 42)
local obbyRuns = {}
Players.PlayerRemoving:Connect(function(player) obbyRuns[player] = nil end)
local obbySteps = {
    {Vector3.new(107, 8, 42), Color3.fromRGB(93, 180, 214)},
    {Vector3.new(117, 9.5, 42), Color3.fromRGB(178, 93, 220)},
    {Vector3.new(127, 11, 42), Color3.fromRGB(93, 180, 214)},
    {Vector3.new(137, 12.5, 42), Color3.fromRGB(178, 93, 220)},
    {Vector3.new(147, 14, 42), Color3.fromRGB(233, 189, 87)}
}
for i, entry in ipairs(obbySteps) do
    local platform = block("Backstage Jump " .. i, Vector3.new(7.5, 1.5, 8),
        entry[1], entry[2], Enum.Material.Neon)
    platform.Touched:Connect(function(hit)
        local player = Players:GetPlayerFromCharacter(hit.Parent)
        local run = player and obbyRuns[player]
        if run and run.step == i - 1 and os.clock() - run.started <= 120 then
            run.step = i
        end
    end)
end
sign("BACKSTAGE PARKOUR", Vector3.new(107, 14, 42))
sign("FINISH / +30 FANS", Vector3.new(147, 20, 42))
interaction("Backstage Challenge", Vector3.new(92, 3, 30), "Try parkour", function(player)
    if not near(player, Vector3.new(92, 3, 30), 13) then return end
    obbyRuns[player] = {step = 0, started = os.clock()}
    teleport(player, obbyStart)
    notify(player, "Jump across all five platforms in order!")
end)
interaction("Backstage Finish", obbyEnd, "Finish challenge", function(player)
    if not near(player, obbyEnd, 10) then return end
    local run = obbyRuns[player]
    if not run or run.step < #obbySteps or os.clock() - run.started > 120 then
        notify(player, "Touch each backstage platform in order first.")
        return
    end
    obbyRuns[player] = nil
    local profile = profiles[player]
    if not profile then return end
    if not profile.posters.backstage then
        profile.posters.backstage = true
        giveFans(player, 30)
        notify(player, "Backstage cleared! +30 Fans")
    else
        notify(player, "Backstage already completed. Nice run!")
    end
    recordQuest(player, "backstage")
end)
interaction("Backstage Exit", Vector3.new(147, 17, 46), "Return to plaza", function(player)
    if near(player, obbyEnd, 16) then
        teleport(player, Vector3.new(10, 5, 10))
    end
end)

interaction("Jona Studio Console", Vector3.new(85, 3, -47), "Inspect", function(player)
    notify(player, "Jona Studio: collaborative beat-making is a future milestone.")
end)
interaction("Noel Sound Yard", Vector3.new(84, 3, 8), "Listen", function(player)
    notify(player, "Noel's sound yard: approved songs will play here after Roblox upload.")
end)
interaction("Mel Comic Corner", Vector3.new(-84, 3, 68), "Explore", function(player)
    notify(player, "Mel's comic arcade: in-world playable comics are coming later.")
end)

local function finishJam(player, expectedSession)
    if sessions[player] ~= expectedSession then return end
    sessions[player] = nil
    local qualifies = expectedSession.attempts >= 4 and expectedSession.hits >= 2
    local earned = qualifies and Progression.jamReward(player, expectedSession.points) or 0
    if qualifies then recordQuest(player, "jam") end
    if earned > 0 then updateFans(player) end
    action:FireClient(player, "jam-end", {
        earned = earned, attempts = expectedSession.attempts,
        hits = expectedSession.hits, points = expectedSession.points,
    })
end

interaction("Rooftop Jam", STAGE + Vector3.new(0, 2, 0), "Start jam", function(player)
    if not near(player, STAGE, 32) or sessions[player] then return end
    local session = {
        startAt = workspace:GetServerTimeNow() + 2.5,
        attempts = 0, hits = 0, points = 0, used = {},
    }
    sessions[player] = session
    action:FireClient(player, "jam-start", {
        startAt = session.startAt, bpm = BPM, beats = BEATS
    })
    task.delay(2.5 + BEATS * INTERVAL + 0.4, function()
        finishJam(player, session)
    end)
end)

action.OnServerEvent:Connect(function(player, kind)
    if kind ~= "tap" then return end
    local session = sessions[player]
    if not session or not near(player, STAGE, 32) then return end
    local elapsed = workspace:GetServerTimeNow() - session.startAt
    if elapsed < -0.08 or elapsed > BEATS * INTERVAL then return end
    local beat = math.floor(elapsed / INTERVAL + 0.5)
    if beat < 0 or beat >= BEATS or session.used[beat] then return end
    session.used[beat] = true
    session.attempts += 1
    local deltaMs = math.abs(elapsed - beat * INTERVAL) * 1000
    local grade = deltaMs <= 90 and "PERFECT"
        or (deltaMs <= 175 and "GOOD" or "OFF")
    local points = grade == "PERFECT" and 100
        or (grade == "GOOD" and 50 or 0)
    if points > 0 then session.hits += 1 end
    session.points += points
    action:FireClient(player, "jam-grade", {grade = grade, points = session.points})
end)

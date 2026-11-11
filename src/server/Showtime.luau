-- BBB Crew Showcase: opt-in 1-4 player rhythm teamwork on the rooftop.
-- Server owns lobby membership, clock, target roles, tap receipts, and rewards.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rules = require(script.Parent:WaitForChild("ShowtimeRules"))

local Showtime = {}
local remote = Instance.new("RemoteEvent")
remote.Name = "BBBShowtimeEvent"
remote.Parent = ReplicatedStorage

local current = nil
local rewardCallback = nil
local nearCallback = nil
local validPlayerCallback = nil
local flashCallback = nil
local eventSerial = 0

local function deliver(player, kind, payload)
    if player and player.Parent == Players then remote:FireClient(player, kind, payload) end
end

local function memberCount(event)
    local n = 0
    for _, member in ipairs(event.members) do
        if member.player.Parent == Players then n += 1 end
    end
    return n
end

local function membersSnapshot(event)
    local all = {}
    for _, member in ipairs(event.members) do
        if member.player.Parent == Players then table.insert(all, member) end
    end
    return all
end

local function findMember(event, player)
    for _, member in ipairs(event.members) do
        if member.player == player then return member end
    end
    return nil
end

local function publishLobby(event)
    for _, member in ipairs(event.members) do
        deliver(member.player, "lobby", {
            count = memberCount(event), maxPlayers = 4, startAt = event.startAt,
            role = member.role,
        })
    end
end

local function finish(event)
    if current ~= event or event.phase ~= "playing" then return end
    event.phase = "ended"
    local all = membersSnapshot(event)
    local totalHits, targetCount = 0, 0
    for _, member in ipairs(all) do
        totalHits += member.hits
        for beat = 0, Rules.BEATS - 1 do
            if Rules.isTarget(member.role, beat) then targetCount += 1 end
        end
    end
    local audience = Rules.crowd(totalHits, targetCount)
    local participants = #all
    for _, member in ipairs(all) do
        local base = Rules.reward(member.hits, participants, totalHits)
        local received = 0
        if base > 0 and rewardCallback then
            received = rewardCallback(member.player, base) or 0
        end
        deliver(member.player, "finish", {
            hits = member.hits, points = member.points,
            audience = audience, members = participants, fans = received,
        })
    end
    if flashCallback then flashCallback(-1) end
    task.delay(3, function()
        if current == event then current = nil end
    end)
end

local function launch(event)
    if current ~= event or event.phase ~= "lobby" then return end
    local members = membersSnapshot(event)
    if #members == 0 then current = nil; return end
    event.phase = "playing"
    event.startAt = workspace:GetServerTimeNow() + 2
    event.liveCount = #members
    for _, member in ipairs(members) do
        deliver(member.player, "go", {
            role = member.role, bpm = Rules.BPM,
            beats = Rules.BEATS, startAt = event.startAt,
            count = #members,
        })
    end
    for beat = 0, Rules.BEATS - 1 do
        local index = beat
        task.delay(2 + beat * Rules.INTERVAL, function()
            if current == event and event.phase == "playing" and flashCallback then
                flashCallback(index)
            end
        end)
    end
    task.delay(2 + Rules.BEATS * Rules.INTERVAL + 0.25, function()
        finish(event)
    end)
end

function Showtime.join(player)
    if not nearCallback or not nearCallback(player) or not validPlayerCallback
        or not validPlayerCallback(player) then return false end
    if current and current.phase == "ended" then
        deliver(player, "notice", "Showcase resetting — try again.")
        return false
    end
    if current and current.phase == "playing" then
        deliver(player, "notice", "A performance is live! Join the next show.")
        return false
    end
    if not current then
        eventSerial += 1
        local newEvent = {
            id = eventSerial, phase = "lobby", members = {},
            startAt = workspace:GetServerTimeNow() + 9,
        }
        current = newEvent
        task.delay(9, function() launch(newEvent) end)
    end
    local event = current
    if findMember(event, player) then
        publishLobby(event)
        return true
    end
    if #event.members >= 4 then
        deliver(player, "notice", "Showcase full (4 performers max).")
        return false
    end
    local seat = #event.members + 1
    table.insert(event.members, {
        player = player, role = Rules.roleForSeat(seat),
        hits = 0, points = 0, used = {},
    })
    publishLobby(event)
    return true
end

function Showtime.isOnStage()
    return current ~= nil and (current.phase == "lobby" or current.phase == "playing")
end

function Showtime.isPlaying(player)
    return current ~= nil and current.phase == "playing"
        and findMember(current, player) ~= nil
end

function Showtime.configure(options)
    nearCallback = options.near
    validPlayerCallback = options.validPlayer
    rewardCallback = options.reward
    flashCallback = options.flash
end

remote.OnServerEvent:Connect(function(player, kind)
    if kind ~= "hit" then return end -- never accept claimed points, roles, or client timestamps.
    local event = current
    if not event or event.phase ~= "playing" then return end
    local member = findMember(event, player)
    if not member or not nearCallback or not nearCallback(player) then return end
    -- Cap per-client network work even when an exploit fires rapid remote calls.
    local receipt = os.clock()
    if member.lastPacketAt and receipt - member.lastPacketAt < 0.075 then return end
    member.lastPacketAt = receipt
    local now = workspace:GetServerTimeNow() - event.startAt
    local beat, grade, points = Rules.judge(member.role, now, member.used)
    if beat then
        member.used[beat] = true
        member.points += points
        if points > 0 then member.hits += 1 end
        deliver(player, "grade", {
            grade = grade, points = member.points, hits = member.hits,
        })
    end
end)

Players.PlayerRemoving:Connect(function(player)
    local event = current
    if not event then return end
    if event.phase == "lobby" then
        for i = #event.members, 1, -1 do
            if event.members[i].player == player then
                table.remove(event.members, i)
            end
        end
        for i, member in ipairs(event.members) do
            member.role = Rules.roleForSeat(i)
        end
        if #event.members == 0 then
            current = nil -- pending launch checks current identity.
        else
            publishLobby(event)
        end
    end
end)

return Showtime

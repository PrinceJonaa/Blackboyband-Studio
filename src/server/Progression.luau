--!strict
-- Session-owned progression, migrating existing BBBWorldM0_v1 fan/poster records.
-- Safe on unavailable DataStore: temporary session play, NEVER write fallback
-- or stale data back over a player's persistent profile.
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local QuestRules = require(script.Parent:WaitForChild("QuestRules"))

local Progression = {}
local STORE = DataStoreService:GetDataStore("BBBWorldM0_v1")
local TOKEN = HttpService:GenerateGUID(false)
local LOCK_SECONDS = 300
local profiles = {}
local owned = {}
local writing = {}

local function emptyProfile()
    return {
        version = 2, fans = 0, posters = {}, stamps = 0,
        daily = nil, jamRewardDay = -1,
    }
end

local function saneCount(value, maxAmount)
    if typeof(value) ~= "number" or not (value >= 0) then return 0 end
    if value == math.huge then return 0 end
    return math.min(maxAmount, math.floor(value))
end

local function hydrate(value)
    local result = emptyProfile()
    if typeof(value) ~= "table" then return result end
    result.fans = saneCount(value.fans, 100000000)
    result.stamps = saneCount(value.stamps, 100000)
    result.jamRewardDay = typeof(value.jamRewardDay) == "number"
        and value.jamRewardDay or -1
    if typeof(value.posters) == "table" then
        for _, id in ipairs({"shop", "mel", "noel", "backstage"}) do
            result.posters[id] = value.posters[id] == true
        end
    end
    if typeof(value.daily) == "table" then
        local source = value.daily
        result.daily = {
            day = source.day,
            setClaimed = source.setClaimed == true,
            crewClaimed = source.crewClaimed == true,
            completed = {},
        }
        if typeof(source.completed) == "table" then
            for _, id in ipairs({"tune", "jam", "backstage", "dance"}) do
                result.daily.completed[id] = source.completed[id] == true
            end
        end
    end
    return result
end

local function snapshot(profile)
    return {
        version = 2, fans = profile.fans,
        posters = table.clone(profile.posters), stamps = profile.stamps,
        daily = profile.daily and {
            day = profile.daily.day,
            setClaimed = profile.daily.setClaimed,
            crewClaimed = profile.daily.crewClaimed,
            completed = table.clone(profile.daily.completed),
        } or nil,
        jamRewardDay = profile.jamRewardDay,
    }
end

local function key(player)
    return "p" .. player.UserId -- legacy key retained for migration.
end

function Progression.load(player)
    local loaded
    local acquired = false
    local ok, err = pcall(function()
        loaded = STORE:UpdateAsync(key(player), function(old)
            local previous = typeof(old) == "table" and old or {}
            local lock = previous.__session
            if typeof(lock) == "table" and lock.id ~= TOKEN
                and typeof(lock.at) == "number"
                and os.time() - lock.at < LOCK_SECONDS then
                return nil
            end
            local result = hydrate(previous)
            result.__session = {id = TOKEN, at = os.time()}
            acquired = true -- callback can rerun; final returned record checked below.
            return result
        end)
    end)
    if not ok or not acquired or typeof(loaded) ~= "table"
        or typeof(loaded.__session) ~= "table"
        or loaded.__session.id ~= TOKEN then
        warn("BBB profile is session-only for " .. player.UserId .. ": " .. tostring(err))
        profiles[player] = emptyProfile()
        owned[player] = false
        return profiles[player], false
    end
    if player.Parent ~= Players then
        -- Late load after disconnect; release on the way out.
        profiles[player] = hydrate(loaded)
        owned[player] = true
        Progression.save(player, true)
        profiles[player] = nil
        owned[player] = nil
        return nil, false
    end
    profiles[player] = hydrate(loaded)
    owned[player] = true
    return profiles[player], true
end

function Progression.get(player)
    return profiles[player]
end

function Progression.isPersistent(player)
    return owned[player] == true
end

function Progression.save(player, release)
    local profile = profiles[player]
    if not profile or not owned[player] then return false end
    local attempts = 0
    while writing[player] do
        attempts += 1
        if attempts > 40 then return false end
        task.wait(0.1)
    end
    writing[player] = true
    local data = snapshot(profile)
    local ok, result = pcall(function()
        return STORE:UpdateAsync(key(player), function(previous)
            if typeof(previous) ~= "table" or typeof(previous.__session) ~= "table"
                or previous.__session.id ~= TOKEN then
                return nil
            end
            local nextValue = table.clone(data)
            if not release then
                nextValue.__session = {id = TOKEN, at = os.time()}
            end
            return nextValue
        end)
    end)
    writing[player] = nil
    if not ok or typeof(result) ~= "table" then
        warn("BBB profile save failed for " .. player.UserId .. ": " .. tostring(result))
        -- A transient datastore outage isn't proof the lock was lost.
        -- Keep the profile retryable, but stop if UpdateAsync explicitly
        -- refused our lock (nil result without a network error).
        if ok and result == nil then owned[player] = false end
        return false
    end
    if release then
        owned[player] = false
    end
    return true
end

function Progression.release(player)
    Progression.save(player, true)
    profiles[player] = nil
    owned[player] = nil
    writing[player] = nil
end

function Progression.reward(player, amount)
    local profile = profiles[player]
    if not profile then return false end
    if typeof(amount) ~= "number" or amount <= 0 or amount > 100 then return false end
    profile.fans = math.min(100000000, profile.fans + math.floor(amount))
    return true
end

function Progression.daily(player)
    local profile = profiles[player]
    if not profile then return nil end
    return QuestRules.describe(profile, QuestRules.dayIndex(os.time()), owned[player] == true)
end

function Progression.record(player, actionId)
    local profile = profiles[player]
    if not profile then return false, false end
    return QuestRules.recordAction(profile, actionId, QuestRules.dayIndex(os.time()))
end

function Progression.crew(player)
    local profile = profiles[player]
    if not profile then return false end
    return QuestRules.recordCrew(profile, QuestRules.dayIndex(os.time()))
end

function Progression.jamReward(player, points)
    local profile = profiles[player]
    if not profile then return 0 end
    local today = QuestRules.dayIndex(os.time())
    if profile.jamRewardDay == today then return 0 end
    local earned = math.min(50, math.max(0, math.floor(points / 10)))
    if earned > 0 then
        profile.jamRewardDay = today
        Progression.reward(player, earned)
    end
    return earned
end

-- Background autosaves staggered per-server; no per-frame datastore requests.
task.spawn(function()
    task.wait(75 + math.random(0, 30))
    while true do
        for _, player in ipairs(Players:GetPlayers()) do
            if owned[player] then Progression.save(player, false) end
            task.wait(0.3)
        end
        task.wait(100 + math.random(0, 30))
    end
end)

return Progression

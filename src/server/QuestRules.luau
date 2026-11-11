--!strict
-- Pure-ish daily quest rules: only the server may call recordAction().
-- One stamp per UTC day, no streak resets, no microtransaction shortcuts.
local QuestRules = {}

local QUESTS = {
    {id = "tune", name = "Channel Surf", description = "Tune the BBB TV"},
    {id = "jam", name = "Rooftop Take", description = "Finish a qualifying rooftop jam"},
    {id = "backstage", name = "Backstage Run", description = "Finish the parkour route"},
    {id = "dance", name = "Dance Break", description = "Spend 20 seconds on the dance floor"},
}
QuestRules.DAILY_REWARD = 20
QuestRules.SET_REWARD = 40
QuestRules.CREW_REWARD = 15

function QuestRules.dayIndex(timestamp)
    return math.floor(timestamp / 86400) -- UTC day, no client-provided time.
end

function QuestRules.questsForDay(day)
    local exclude = (day % #QUESTS) + 1
    local result = {}
    for i, quest in ipairs(QUESTS) do
        if i ~= exclude then
            table.insert(result, quest)
        end
    end
    return result
end

function QuestRules.ensureDay(profile, day)
    if typeof(profile.daily) ~= "table" or profile.daily.day ~= day then
        profile.daily = {day = day, completed = {}, setClaimed = false, crewClaimed = false}
    end
    if typeof(profile.daily.completed) ~= "table" then
        profile.daily.completed = {}
    end
    return profile.daily
end

function QuestRules.recordAction(profile, actionId, day)
    local daily = QuestRules.ensureDay(profile, day)
    if daily.completed[actionId] == true then return false, false end
    local relevant = false
    for _, quest in ipairs(QuestRules.questsForDay(day)) do
        if quest.id == actionId then relevant = true end
    end
    if not relevant then return false, false end
    daily.completed[actionId] = true
    profile.fans += QuestRules.DAILY_REWARD
    local allDone = true
    for _, quest in ipairs(QuestRules.questsForDay(day)) do
        if daily.completed[quest.id] ~= true then allDone = false; break end
    end
    local earnedStamp = false
    if allDone and not daily.setClaimed then
        daily.setClaimed = true
        profile.fans += QuestRules.SET_REWARD
        profile.stamps = (profile.stamps or 0) + 1
        earnedStamp = true
    end
    return true, earnedStamp
end

function QuestRules.recordCrew(profile, day)
    local daily = QuestRules.ensureDay(profile, day)
    if daily.crewClaimed then return false end
    daily.crewClaimed = true
    profile.fans += QuestRules.CREW_REWARD
    return true
end

function QuestRules.describe(profile, day, persistent)
    local daily = QuestRules.ensureDay(profile, day)
    local quests = {}
    for _, quest in ipairs(QuestRules.questsForDay(day)) do
        table.insert(quests, {
            id = quest.id,
            name = quest.name,
            description = quest.description,
            done = daily.completed[quest.id] == true,
            reward = QuestRules.DAILY_REWARD,
        })
    end
    return {
        day = day,
        quests = quests,
        stamps = profile.stamps or 0,
        crewClaimed = daily.crewClaimed == true,
        fanTotal = profile.fans,
        persistent = persistent,
        -- These are free progress unlock indicators, not paid entitlements.
        titleUnlocked = (profile.stamps or 0) >= 3,
        spotlightUnlocked = (profile.stamps or 0) >= 7,
    }
end

return QuestRules

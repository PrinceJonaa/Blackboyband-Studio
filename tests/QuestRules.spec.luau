-- BBB QuestRules checks. Run this file as a Script in ServerScriptService
-- inside a Rojo-built BBB Studio test place (or adapt to a Luau test runner).
local Rules = require(game:GetService("ServerScriptService"):WaitForChild("QuestRules"))

local function profile()
    return {fans = 0, stamps = 0}
end
local day = 25000
assert(#Rules.questsForDay(day) == 3)
local p = profile()
local quests = Rules.questsForDay(day)
for i, quest in ipairs(quests) do
    local recorded, stamped = Rules.recordAction(p, quest.id, day)
    assert(recorded == true)
    assert(stamped == (i == 3))
    assert(p.fans == i * Rules.DAILY_REWARD + (i == 3 and Rules.SET_REWARD or 0))
    assert(select(1, Rules.recordAction(p, quest.id, day)) == false)
end
assert(p.stamps == 1)
local excluded = {"tune", "jam", "backstage", "dance"}
for _, quest in ipairs(quests) do
    for i, id in ipairs(excluded) do
        if quest.id == id then table.remove(excluded, i); break end
    end
end
assert(#excluded == 1)
assert(select(1, Rules.recordAction(p, excluded[1], day)) == false)
assert(Rules.recordCrew(p, day) == true)
assert(Rules.recordCrew(p, day) == false)
assert(p.fans == 3 * 20 + 40 + 15)

local previousFans = p.fans
local tomorrow = day + 1
local newQuests = Rules.questsForDay(tomorrow)
assert(#newQuests == 3)
assert(Rules.describe(p, tomorrow, true).stamps == 1)
assert(Rules.describe(p, tomorrow, true).quests[1].done == false)
assert(select(1, Rules.recordAction(p, newQuests[1].id, tomorrow)) == true)
assert(p.fans == previousFans + 20)
assert(p.stamps == 1)
assert(Rules.dayIndex(86400 * 10 - 1) == 9)
assert(Rules.dayIndex(86400 * 10) == 10)
print("BBB QuestRules daily/repeat/rollover tests passed")

-- Manual Roblox Studio server-side test. Place this as a Script next to
-- ShowtimeRules (ServerScriptService); not included in production Rojo mapping.
local Rules = require(game:GetService("ServerScriptService"):WaitForChild("ShowtimeRules"))
assert(Rules.BPM == 96)
assert(Rules.BEATS == 16)
assert(Rules.roleForSeat(1) == "LEAD")
assert(Rules.roleForSeat(2) == "LIGHTS")
assert(Rules.roleForSeat(3) == "HYPE")
assert(Rules.roleForSeat(4) == "CREW")
assert(Rules.roleForSeat(5) == nil)

local expectedTargets = {LEAD = 8, LIGHTS = 8, HYPE = 4, CREW = 8}
for role, targetCount in pairs(expectedTargets) do
    local total = 0
    for beat = 0, Rules.BEATS - 1 do
        if Rules.isTarget(role, beat) then total += 1 end
    end
    assert(total == targetCount)
end
assert(Rules.isTarget("LEAD", 0))
assert(Rules.isTarget("LIGHTS", 1))
assert(Rules.isTarget("HYPE", 3))
assert(not Rules.isTarget("HYPE", 2))
assert(not Rules.isTarget("LEAD", -1))
assert(not Rules.isTarget("LEAD", 16))

local beat = Rules.INTERVAL * 2
local used = {}
local index, grade, points = Rules.judge("LEAD", beat + 0.01, used)
assert(index == 2 and grade == "PERFECT" and points == 100)
used[index] = true
assert(select(2, Rules.judge("LEAD", beat + 0.01, used)) == "REPEAT")
assert(select(2, Rules.judge("LEAD", beat + 0.12, {})) == "GOOD")
assert(select(2, Rules.judge("LEAD", beat + 0.23, {})) == "OFF")
assert(select(2, Rules.judge("LIGHTS", beat, {})) == "WAIT")
assert(select(2, Rules.judge("LEAD", -5, {})) == "WAIT")
assert(Rules.reward(1, 3, 9) == 0)
assert(Rules.reward(2, 1, 8) == 15)
assert(Rules.reward(2, 2, 7) == 15)
assert(Rules.reward(2, 2, 8) == 25)
assert(Rules.crowd(4, 8) == 50)
assert(Rules.crowd(40, 8) == 100)
print("BBB ShowtimeRules tests passed")

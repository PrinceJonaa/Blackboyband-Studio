-- Pure BBB Showtime scoring rules. No Roblox services, client clock, or assets.
local Rules = {}

Rules.BPM = 96
Rules.BEATS = 16
Rules.INTERVAL = 60 / Rules.BPM
Rules.ROLES = {"LEAD", "LIGHTS", "HYPE", "CREW"}

function Rules.roleForSeat(seat)
    if typeof(seat) ~= "number" or seat < 1 or seat > 4 or seat % 1 ~= 0 then return nil end
    return Rules.ROLES[seat]
end

function Rules.isTarget(role, beat)
    if typeof(beat) ~= "number" or beat % 1 ~= 0 or beat < 0 or beat >= Rules.BEATS then return false end
    if role == "LEAD" or role == "CREW" then return beat % 2 == 0 end
    if role == "LIGHTS" then return beat % 2 == 1 end
    if role == "HYPE" then return beat % 4 == 3 end
    return false
end

-- elapsed is derived solely from workspace:GetServerTimeNow() in the server.
-- Returns closest beat index and grade; off-target or out-of-window actions are ignored.
function Rules.judge(role, elapsed, used)
    if typeof(elapsed) ~= "number" or elapsed ~= elapsed then return nil, "INVALID", 0 end
    if elapsed < -0.19 or elapsed > Rules.BEATS * Rules.INTERVAL then
        return nil, "WAIT", 0
    end
    local beat = math.floor(elapsed / Rules.INTERVAL + 0.5)
    if not Rules.isTarget(role, beat) then return nil, "WAIT", 0 end
    if used[beat] then return nil, "REPEAT", 0 end
    local delta = math.abs(elapsed - beat * Rules.INTERVAL)
    if delta > 0.28 then return nil, "WAIT", 0 end
    if delta <= 0.095 then return beat, "PERFECT", 100 end
    if delta <= 0.195 then return beat, "GOOD", 60 end
    return beat, "OFF", 0
end

function Rules.reward(hits, participantCount, totalHits)
    if typeof(hits) ~= "number" or hits < 2 then return 0 end
    local score = 15
    if participantCount >= 2 and totalHits >= 8 then score += 10 end
    return score
end

function Rules.crowd(totalHits, targetCount)
    if targetCount <= 0 then return 0 end
    return math.clamp(math.floor(100 * totalHits / targetCount + 0.5), 0, 100)
end

return Rules

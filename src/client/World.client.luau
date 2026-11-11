-- BBB World M0: minimal in-world rhythm HUD, with keyboard and touch input.
-- The server validates every tap and alone awards points.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local SocialService = game:GetService("SocialService")

local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("BBBWorldEvent")
local activeSession = nil
local feedback = ""
local noticeSerial = 0

local screen = Instance.new("ScreenGui")
screen.Name = "BBBWorldHUD"
screen.ResetOnSpawn = false
screen.IgnoreGuiInset = false
screen.Parent = player:WaitForChild("PlayerGui")

local function label(name, position, size, textSize)
    local view = Instance.new("TextLabel")
    view.Name = name
    view.AnchorPoint = Vector2.new(0.5, 0)
    view.Position = position
    view.Size = size
    view.BackgroundColor3 = Color3.fromRGB(9, 10, 24)
    view.BackgroundTransparency = 0.17
    view.BorderSizePixel = 0
    view.Font = Enum.Font.GothamBold
    view.TextSize = textSize
    view.TextWrapped = true
    view.TextColor3 = Color3.fromRGB(239, 246, 255)
    view.Visible = true
    view.Parent = screen
    local round = Instance.new("UICorner")
    round.CornerRadius = UDim.new(0, 10)
    round.Parent = view
    return view
end

local header = label("WorldTitle", UDim2.fromScale(0.5, 0.02),
    UDim2.new(0.7, 0, 0, 42), 18)
header.Text = "BLACK BOY BAND  •  THE BLOCK"

local status = label("RhythmBar", UDim2.new(0.5, 0, 0.65, 0),
    UDim2.new(0.8, 0, 0, 58), 18)
status.Visible = false

local dance = label("DanceStatus", UDim2.new(0.5, 0, 0.18, 0),
    UDim2.new(0.6, 0, 0, 38), 16)
dance.Text = "BBB DANCE FLOOR  •  DANCE WITH YOUR CREW"
dance.Visible = false
local attributeConnection
local function watchCharacter(character)
    if attributeConnection then attributeConnection:Disconnect() end
    local function refresh()
        dance.Visible = character:GetAttribute("BBBDanceFloor") == true
    end
    attributeConnection = character:GetAttributeChangedSignal("BBBDanceFloor"):Connect(refresh)
    refresh()
end
if player.Character then watchCharacter(player.Character) end
player.CharacterAdded:Connect(watchCharacter)

local notice = label("Notice", UDim2.new(0.5, 0, 0.13, 0),
    UDim2.new(0.7, 0, 0, 54), 16)
notice.Visible = false

local button = Instance.new("TextButton")
button.Name = "BeatTap"
button.AnchorPoint = Vector2.new(1, 1)
button.Position = UDim2.new(0.95, 0, 0.97, 0)
button.Size = UDim2.fromOffset(115, 58)
button.BackgroundColor3 = Color3.fromRGB(142, 64, 197)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextSize = 26
button.Font = Enum.Font.GothamBold
button.Text = "TAP"
button.Visible = false
button.Parent = screen
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = button

local function showNotice(message)
    noticeSerial += 1
    local serial = noticeSerial
    notice.Text = tostring(message)
    notice.Visible = true
    task.delay(4, function()
        if serial == noticeSerial then notice.Visible = false end
    end)
end

-- Quest board is user-opened, not an intrusive mandatory modal.
local function smallButton(name, text, y)
    local control = Instance.new("TextButton")
    control.Name = name
    control.AnchorPoint = Vector2.new(1, 0)
    control.Position = UDim2.new(0.97, 0, 0, y)
    control.Size = UDim2.fromOffset(90, 32)
    control.BackgroundColor3 = Color3.fromRGB(41, 48, 85)
    control.BorderSizePixel = 0
    control.Text = text
    control.TextSize = 14
    control.TextColor3 = Color3.fromRGB(255, 255, 255)
    control.Font = Enum.Font.GothamBold
    control.Parent = screen
    local round = Instance.new("UICorner")
    round.CornerRadius = UDim.new(0, 7)
    round.Parent = control
    return control
end

local questsButton = smallButton("Quests", "QUESTS", 55)
local inviteButton = smallButton("Invite", "INVITE", 94)
local questBoard = label("DailyQuestBoard", UDim2.new(0.5, 0, 0, 140),
    UDim2.new(0.86, 0, 0, 206), 16)
questBoard.TextYAlignment = Enum.TextYAlignment.Top
questBoard.TextXAlignment = Enum.TextXAlignment.Left
questBoard.TextWrapped = true
questBoard.Text = "Loading today's BBB set..."
questBoard.Visible = false
local shownQuests = nil
local function drawQuests()
    if not shownQuests then return end
    local details = {"TODAY'S BBB SET  •  3 free missions"}
    for _, quest in ipairs(shownQuests.quests) do
        table.insert(details, (quest.done and "[DONE] " or "[    ] ")
            .. quest.name .. "  +20 Fans")
        table.insert(details, "   " .. quest.description)
    end
    table.insert(details, "Complete all three: +1 B-Side Stamp & +40 Fans")
    table.insert(details, "Stamps: " .. tostring(shownQuests.stamps)
        .. "  •  Crew dance: " .. (shownQuests.crewClaimed and "DONE" or "+15 Fans"))
    if not shownQuests.persistent then
        table.insert(details, "SESSION ONLY — saving unavailable")
    end
    questBoard.Text = table.concat(details, "\n")
end
questsButton.Activated:Connect(function()
    questBoard.Visible = not questBoard.Visible
    if questBoard.Visible then remote:FireServer("quest-view") end
end)
inviteButton.Activated:Connect(function()
    -- This native friend invite only opens after a player's explicit click.
    -- No reward for opening or sending the invite.
    local ok, canInvite = pcall(function()
        return SocialService:CanSendGameInviteAsync(player)
    end)
    if ok and canInvite then
        local prompted, err = pcall(function()
            SocialService:PromptGameInvite(player)
        end)
        if not prompted then showNotice("Invites aren't available here.") end
    else
        showNotice("Invites aren't supported in this session.")
    end
end)

local function tap()
    if activeSession then remote:FireServer("tap") end
end
button.Activated:Connect(tap)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed or not activeSession then return end
    if input.KeyCode == Enum.KeyCode.F or input.KeyCode == Enum.KeyCode.Space then
        tap()
    end
end)

remote.OnClientEvent:Connect(function(kind, payload)
    if kind == "notice" then
        showNotice(payload)
    elseif kind == "quests" then
        shownQuests = payload
        drawQuests()
    elseif kind == "jam-start" then
        activeSession = payload
        feedback = "GET READY"
        status.Visible = true
        button.Visible = true
    elseif kind == "jam-grade" then
        feedback = string.format("%s  |  %d pts", payload.grade, payload.points)
    elseif kind == "jam-end" then
        activeSession = nil
        button.Visible = false
        status.Text = string.format("Jam finished • %d hits / %d taps • +%d Fans",
            payload.hits, payload.attempts, payload.earned)
        showNotice("Rooftop session complete! Come back anytime.")
        task.delay(5, function()
            if not activeSession then status.Visible = false end
        end)
    end
end)

-- UI-only frame updates. The server's synchronized time and tap receipts are authoritative.
RunService.RenderStepped:Connect(function()
    local session = activeSession
    if not session then return end
    local t = workspace:GetServerTimeNow() - session.startAt
    if t < 0 then
        status.Text = string.format("ROOFTOP JAM  |  STARTING IN %.1f  |  %s",
            -t, feedback)
    else
        local current = math.clamp(math.floor(t * session.bpm / 60) + 1, 1, session.beats)
        local secondsPerBeat = 60 / session.bpm
        local phase = (t % secondsPerBeat) / secondsPerBeat
        local marker = phase < 0.18 and "●" or "○"
        status.Text = string.format("ROOFTOP JAM  %s  %d/%d  •  F or TAP  •  %s",
            marker, current, session.beats, feedback)
    end
end)

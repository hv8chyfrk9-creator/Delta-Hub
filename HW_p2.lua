	[87] = { normal = true, fast = true, super = false }, -- CF 87
	[88] = { normal = true, fast = true, super = true }, -- CF 88
	[89] = { normal = true, fast = false, super = false }, -- CF 89
	[90] = { normal = true, fast = false, super = false }, -- CF 90
	[91] = { normal = true, fast = false, super = false }, -- CF 91
	[92] = { normal = true, fast = true, super = false }, -- CF 92
	[93] = { normal = true, fast = false, super = false }, -- CF 93
	[94] = { normal = true, fast = false, super = false }, -- CF 94
	[95] = { normal = true, fast = false, super = false }, -- CF 95
	[96] = { normal = true, fast = true, super = false }, -- CF 96
	[97] = { normal = true, fast = true, super = true }, -- CF 97
	[98] = { normal = true, fast = true, super = false }, -- CF 98
	[99] = { normal = true, fast = false, super = false }, -- CF 99
	[100] = { normal = true, fast = false, super = false }, -- CF 100
	[101] = { normal = true, fast = false, super = false }, -- CF 101
	[102] = { normal = true, fast = false, super = false }, -- CF 102
	[103] = { normal = false, fast = true, super = false }, -- CF 103
	[104] = { normal = true, fast = false, super = false }, -- CF 104
	[105] = { normal = true, fast = false, super = false }, -- CF 105
	[106] = { normal = true, fast = false, super = false }, -- CF 106
	[107] = { normal = true, fast = false, super = false }, -- CF 107
	[108] = { normal = true, fast = false, super = false }, -- CF 108
	[109] = { normal = true, fast = false, super = false }, -- CF 109
	[110] = { normal = false, fast = true, super = false }, -- CF 110
	[111] = { normal = true, fast = false, super = false }, -- CF 111
	[112] = { normal = true, fast = false, super = false }, -- CF 112
	[113] = { normal = true, fast = false, super = false }, -- CF 113
	[114] = { normal = true, fast = false, super = false }, -- CF 114
	[115] = { normal = true, fast = false, super = false }, -- CF 115
	[116] = { normal = true, fast = false, super = false }, -- CF 116
	[117] = { normal = false, fast = true, super = false }, -- CF 117
	[118] = { normal = true, fast = false, super = false }, -- CF 118
	[119] = { normal = true, fast = false, super = false }, -- CF 119
	[120] = { normal = true, fast = false, super = false }, -- CF 120
	[121] = { normal = true, fast = false, super = false }, -- CF 121
	[122] = { normal = true, fast = false, super = false }, -- CF 122
	[123] = { normal = true, fast = false, super = false }, -- CF 123
	[124] = { normal = false, fast = true, super = false }, -- CF 124
	[125] = { normal = true, fast = false, super = false }, -- CF 125
	[126] = { normal = true, fast = false, super = false }, -- CF 126
	[127] = { normal = true, fast = false, super = false }, -- CF 127
	[128] = { normal = true, fast = false, super = false }, -- CF 128
	[129] = { normal = false, fast = true, super = false }, -- CF 129
	[130] = { normal = true, fast = true, super = true } -- CF 130
}

local orderedWinBlocks = {
	{real = "WinBlock1", display = "+1 Wins", order = 1},
	{real = "WinBlock2", display = "+3 Wins", order = 2},
	{real = "WinBlock3", display = "+10 Wins", order = 3},
	{real = "WinBlock4", display = "+20 Wins", order = 4},
	{real = "WinBlock5", display = "+50 Wins", order = 5},
	{real = "WinBlock6", display = "+100 Wins", order = 6},
	{real = "WinBlock7", display = "+150 Wins", order = 7},
	{real = "WinBlock8", display = "+300 Wins", order = 8},
	{real = "WinBlock9", display = "+500 Wins", order = 9},
	{real = "WinBlock10", display = "+1K Wins", order = 10},
	{real = "WinBlock11", display = "+2.5K Wins", order = 11},
	{real = "WinBlock12", display = "+12K Wins", order = 12},
	{real = "WinBlock13", display = "+25K Wins", order = 13},
	{real = "WinBlock14", display = "+50K Wins", order = 14},
	{real = "WinBlock15", display = "+150K Wins", order = 15}
}

local function getRouteIndicesForMode(mode)
    -- mode: "normal" | "fast" | "ultra"/"super"
    local key = "normal"
    if mode == "fast" then key = "fast"
    elseif mode == "ultra" or mode == "super" then key = "super" end
    local idxs = {}
    for i = 1, #routeCFrames do
        local m = routeModes[i]
        if not m then
            table.insert(idxs, i)
        elseif m[key] then
            table.insert(idxs, i)
        end
    end
    if #idxs == 0 then
        for i = 1, #routeCFrames do table.insert(idxs, i) end
    end
    return idxs
end

local function getRouteCFramesForMode(mode)
    local idxs = getRouteIndicesForMode(mode)
    local list = {}
    for _, i in ipairs(idxs) do
        table.insert(list, routeCFrames[i])
    end
    return list, idxs
end
HW.getRouteCFramesForMode = getRouteCFramesForMode
HW.routeCFrames = routeCFrames
HW.getRouteIndicesForMode = getRouteIndicesForMode


local selectedRealName = "WinBlock1"
local selectedDisplayName = "+1 Win"
local gameSpeed = 250
local routeMode = "normal"
local function approachSpeed(distance, nextDistance)
    local maxSpeed = math.clamp(gameSpeed or 250, 1, 500)
    if nextDistance and nextDistance < 5 then
        return maxSpeed
    end
    local brake = 18
    local floorSpeed = 0
    if routeMode == "fast" then
        brake = 8
        floorSpeed = 50
    elseif routeMode == "ultra" then
        brake = 5
        floorSpeed = 150
    end
    if distance >= brake then
        return maxSpeed
    end
    local t = math.clamp(distance / brake, 0, 1)
    return math.max(maxSpeed * t * t, floorSpeed)
end
local delayTime = 0
local infiniteRouteActive = false
local routeRunning = false
local routeClickState = 0

local selectorMain = Instance.new("Frame")
selectorMain.Parent = GamePage
selectorMain.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
selectorMain.Size = UDim2.new(1, -10, 0, 32)
selectorMain.LayoutOrder = 1
Instance.new("UICorner", selectorMain).CornerRadius = UDim.new(0, 6)

local selectorBtn = Instance.new("TextButton")
selectorBtn.Parent = selectorMain
selectorBtn.BackgroundTransparency = 1
selectorBtn.Size = UDim2.new(1, 0, 1, 0)
selectorBtn.Font = Enum.Font.GothamBold
selectorBtn.Text = "Seleccionar Win: +1 Win â¾"
selectorBtn.TextColor3 = Color3.fromRGB(240, 240, 245)
selectorBtn.TextSize = 12

local dropdownList = Instance.new("ScrollingFrame")
dropdownList.Parent = GamePage
dropdownList.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
dropdownList.Size = UDim2.new(1, -10, 0, 140)
dropdownList.Visible = false
dropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
dropdownList.AutomaticCanvasSize = Enum.AutomaticSize.Y
dropdownList.ScrollBarThickness = 3
dropdownList.LayoutOrder = 2
Instance.new("UICorner", dropdownList).CornerRadius = UDim.new(0, 6)
local dropLayout = Instance.new("UIListLayout")
dropLayout.Parent = dropdownList
dropLayout.SortOrder = Enum.SortOrder.LayoutOrder
dropLayout.Padding = UDim.new(0, 4)

for _, info in ipairs(orderedWinBlocks) do
    local opt = Instance.new("TextButton")
    opt.Parent = dropdownList
    opt.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
    opt.Size = UDim2.new(1, 0, 0, 28)
    opt.Font = Enum.Font.Gotham
    opt.Text = info.display
    opt.TextColor3 = Color3.fromRGB(200, 200, 210)
    opt.TextSize = 12
    opt.LayoutOrder = info.order
    Instance.new("UICorner", opt).CornerRadius = UDim.new(0, 4)
    opt.MouseButton1Click:Connect(function()
        selectedRealName = info.real
        selectedDisplayName = info.display
        selectorBtn.Text = "Seleccionar Win: " .. info.display .. " â¾"
        dropdownList.Visible = false
    end)
end
selectorBtn.MouseButton1Click:Connect(function() dropdownList.Visible = not dropdownList.Visible end)

local winChosenLabel = Instance.new("TextLabel")
winChosenLabel.Parent = GamePage
winChosenLabel.BackgroundTransparency = 1
winChosenLabel.Size = UDim2.new(1, -10, 0, 22)
winChosenLabel.Font = Enum.Font.GothamSemibold
winChosenLabel.Text = "Win escogida: +1 Win"
winChosenLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
winChosenLabel.TextSize = 12
winChosenLabel.TextXAlignment = Enum.TextXAlignment.Left
winChosenLabel.LayoutOrder = 3
selectorBtn.MouseButton1Click:Connect(function() winChosenLabel.Text = "Win escogida: " .. selectedDisplayName end)

local startRouteBtn = Instance.new("TextButton")
startRouteBtn.Parent = GamePage
startRouteBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
startRouteBtn.Size = UDim2.new(1, -10, 0, 32)
startRouteBtn.Font = Enum.Font.GothamBold
startRouteBtn.Text = "Iniciar Recorrido: OFF"
startRouteBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
startRouteBtn.TextSize = 12
startRouteBtn.LayoutOrder = 4
Instance.new("UICorner", startRouteBtn).CornerRadius = UDim.new(0, 6)

local speedGameBox = Instance.new("TextBox")
speedGameBox.Parent = GamePage
speedGameBox.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
speedGameBox.Size = UDim2.new(1, -10, 0, 32)
speedGameBox.Font = Enum.Font.Gotham
speedGameBox.PlaceholderText = "Velocidad Recorrido (1 - 500)"
speedGameBox.Text = "250"
speedGameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedGameBox.PlaceholderColor3 = Color3.fromRGB(110, 110, 125)
speedGameBox.TextSize = 13
speedGameBox.LayoutOrder = 5
Instance.new("UICorner", speedGameBox).CornerRadius = UDim.new(0, 6)
speedGameBox.FocusLost:Connect(function()
    local v = tonumber(speedGameBox.Text)
    gameSpeed = math.clamp(v or gameSpeed or 250, 1, 500)
    speedGameBox.Text = tostring(gameSpeed)
end)

local delayBox = Instance.new("TextBox")
delayBox.Parent = GamePage
delayBox.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
delayBox.Size = UDim2.new(1, -10, 0, 32)
delayBox.Font = Enum.Font.Gotham
delayBox.PlaceholderText = "Delay entre recorridos (0 - 10)"
delayBox.Text = "0"
delayBox.TextColor3 = Color3.fromRGB(255, 255, 255)
delayBox.PlaceholderColor3 = Color3.fromRGB(110, 110, 125)
delayBox.TextSize = 13
delayBox.LayoutOrder = 6
Instance.new("UICorner", delayBox).CornerRadius = UDim.new(0, 6)
delayBox.FocusLost:Connect(function() local v = tonumber(delayBox.Text) if v then delayTime = math.clamp(v, 0, 10) end end)

local infRouteToggle = Instance.new("TextButton")
infRouteToggle.Parent = GamePage
infRouteToggle.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
infRouteToggle.Size = UDim2.new(1, -10, 0, 32)
infRouteToggle.Font = Enum.Font.GothamBold
infRouteToggle.Text = "Recorrido Infinito: OFF"
infRouteToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
infRouteToggle.TextSize = 12
infRouteToggle.LayoutOrder = 7
Instance.new("UICorner", infRouteToggle).CornerRadius = UDim.new(0, 6)


local fastBtn = Instance.new("TextButton")
fastBtn.Parent = GamePage
fastBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
fastBtn.Size = UDim2.new(1, -10, 0, 32)
fastBtn.Font = Enum.Font.GothamBold
fastBtn.Text = "Recorrido: Normal"
fastBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
fastBtn.TextSize = 12
fastBtn.LayoutOrder = 8
Instance.new("UICorner", fastBtn).CornerRadius = UDim.new(0, 6)
local function paintRouteMode()
    if routeMode == "fast" then
        fastBtn.Text = "Recorrido: Rapido"
    elseif routeMode == "ultra" then
        fastBtn.Text = "Recorrido: Ultra rapido"
    else
        fastBtn.Text = "Recorrido: Normal"
    end
end
fastBtn.MouseButton1Click:Connect(function()
    if routeMode == "normal" then routeMode = "fast"
    elseif routeMode == "fast" then routeMode = "ultra"
    else routeMode = "normal" end
    paintRouteMode()
end)

infRouteToggle.MouseButton1Click:Connect(function()
    infiniteRouteActive = not infiniteRouteActive
    if infiniteRouteActive then
        infRouteToggle.Text = "Recorrido Infinito: ON"
        infRouteToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
        infRouteToggle.BackgroundColor3 = Color3.fromRGB(35, 60, 35)
    else
        infRouteToggle.Text = "Recorrido Infinito: OFF"
        infRouteToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
        infRouteToggle.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
    end
end)

local finishAfterClaim = false

local routeWinsSession = 0
local winStreakBonus = 0

local goalEnabled = false
local goalAmount = 0
local goalProgress = 0
local goalSavedFor = nil
local goalInfo = nil
local function formatShort(n)
    n = tonumber(n) or 0
    if n < 0 then n = 0 end
    local units = {{1e12, "T"}, {1e9, "B"}, {1e6, "M"}, {1e3, "K"}}
    for _, u in ipairs(units) do
        if n >= u[1] then
            local v = n / u[1]
            local nearest = math.floor(v + 0.5)
            local s
            if math.abs(v - nearest) < 0.001 and math.abs(v - math.floor(v + 1e-6)) < 0.001 then
                s = tostring(math.floor(v + 1e-6))
            else
                s = string.format("%.2f", v)
                if s:find("%.") then
                    s = s:gsub("0+$", ""):gsub("%.$", "")
                end
            end
            return s .. u[2]
        end
    end
    return tostring(math.floor(n))
end
local function refreshGoal()
    if not goalInfo then return end
    if not goalEnabled then
        goalInfo.Text = "Meta apagada"
        return
    end
    goalInfo.Text = "Llevas " .. formatShort(goalProgress) .. " / " .. formatShort(goalAmount)
end

local function parseWinAmount(text)
    local n, suf = string.match(string.lower(text or ""), "([%d%.]+)%s*([kmbqt]?)")
    local value = tonumber(n) or 0
    local mult = {k = 1e3, m = 1e6, b = 1e9, t = 1e12, q = 1e15}
    if suf and mult[suf] then value = value * mult[suf] end
    return value
end

local function formatWins(n)
    local units = {{1e15, "Q"}, {1e12, "T"}, {1e9, "B"}, {1e6, "M"}, {1e3, "K"}}
    for _, u in ipairs(units) do
        if n >= u[1] then
            return string.format("%.2f%s", n / u[1], u[2])
        end
    end
    return tostring(math.floor(n))
end

local WinsCounter = Instance.new("TextLabel")
WinsCounter.Parent = ScreenGui
WinsCounter.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
WinsCounter.Position = UDim2.new(1, -210, 0, 90)
WinsCounter.Size = UDim2.new(0, 195, 0, 36)
WinsCounter.Font = Enum.Font.GothamBold
WinsCounter.Text = "Wins ruta: 0 | racha +0%"
WinsCounter.TextColor3 = Color3.fromRGB(255, 220, 80)
WinsCounter.TextSize = 11
WinsCounter.Visible = false
Instance.new("UICorner", WinsCounter).CornerRadius = UDim.new(0, 6)

local function refreshWinsCounter(lastGain)
    WinsCounter.Visible = true
    WinsCounter.Text = "Wins ruta: " .. formatWins(routeWinsSession) .. " | racha +" .. tostring(math.floor(winStreakBonus * 100)) .. "%"
    if lastGain then
        showNotification("+" .. formatWins(lastGain) .. " Wins")
    end
end

local streakBlock = nil
local function addRouteWins()
    if streakBlock ~= selectedRealName then
        winStreakBonus = 0
        streakBlock = selectedRealName
    end
    local infoText = selectedRealName or ""
    for _, info in ipairs(orderedWinBlocks) do
        if info.real == selectedRealName then
            infoText = info.display
            break
        end
    end
    local base = parseWinAmount(infoText)
    local gain = base * (1 + winStreakBonus)
    routeWinsSession = routeWinsSession + gain
    if goalEnabled then
        goalProgress = goalProgress + gain
        refreshGoal()
        if not infiniteRouteActive and goalProgress >= goalAmount then
            showNotification("Meta lista: " .. formatShort(goalProgress))
        end
    end
    refreshWinsCounter(gain)
    winStreakBonus = math.min(1, winStreakBonus + 0.1)
    refreshWinsCounter()
end

local function resetWinStreak()
    winStreakBonus = 0
    streakBlock = nil
    refreshWinsCounter()
end


local StopNowBtn = Instance.new("TextButton")
StopNowBtn.Parent = ScreenGui
StopNowBtn.BackgroundColor3 = Color3.fromRGB(120, 30, 30)
StopNowBtn.Position = UDim2.new(1, -170, 0, 56)
StopNowBtn.Size = UDim2.new(0, 155, 0, 28)
StopNowBtn.Font = Enum.Font.GothamBold
StopNowBtn.Text = "Terminar recorrido ahora"
StopNowBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StopNowBtn.TextSize = 10
StopNowBtn.Visible = false
Instance.new("UICorner", StopNowBtn).CornerRadius = UDim.new(0, 6)

local function stopRecorridoGeneral()
    routeRunning = false
    finishAfterClaim = false
    StopRouteContainer.Visible = false
    StopNowBtn.Visible = false
    StopRouteFloatingBtn.Text = "Terminar Recorrido"
    noClipEnabled = false
    noclipToggle.Text = "Noclip: OFF"
    noclipToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
    noclipToggle.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
    routeClickState = 0
    startRouteBtn.Text = "Iniciar recorrido"
    startRouteBtn.TextColor3 = Color3.fromRGB(255, 120, 120)
    startRouteBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local bv = hrp:FindFirstChildOfClass("BodyVelocity")
        if bv then bv:Destroy() end
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end
end

StopRouteFloatingBtn.MouseButton1Click:Connect(function()
    finishAfterClaim = true
    StopNowBtn.Visible = true
    StopRouteFloatingBtn.Text = "Terminara al WinBlock"
    showNotification("Sigue hasta tocar el WinBlock y volver al spawn.")
end)

StopNowBtn.MouseButton1Click:Connect(function()
    stopRecorridoGeneral()
    showNotification("Recorrido detenido ahora.")
end)

-- ==========================================
-- PÃGINA "EXTRAS" (ANTILAG, AUTO SPECIALKEYS)
-- ==========================================
local antilagActive = false
local autoSpecialKeysActive = false
local eventCollectMode = "Tween"
local specialKeysQueue = {}

local antilagToggle = Instance.new("TextButton")
antilagToggle.Parent = ExtrasPage
antilagToggle.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
antilagToggle.Size = UDim2.new(1, -10, 0, 32)
antilagToggle.Font = Enum.Font.GothamBold
antilagToggle.Text = "Antilag: OFF"
antilagToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
antilagToggle.TextSize = 12
antilagToggle.LayoutOrder = 1
Instance.new("UICorner", antilagToggle).CornerRadius = UDim.new(0, 6)

antilagToggle.MouseButton1Click:Connect(function()
    antilagActive = not antilagActive
    if getgenv then getgenv().DeltaHubAntilagOn = antilagActive end
    if antilagActive and not (getgenv and getgenv().DeltaHubAntilagWasOn) then
        antilagToggle.Text = "Antilag: ON"
        antilagToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
        antilagToggle.BackgroundColor3 = Color3.fromRGB(35, 60, 35)
        pcall(function() Lighting.GlobalShadows = false; Lighting.Brightness = 2 end)
        local antilagTargets = {"Decorations", "Props", "Halloween", "HallowenMeshes"}
        if hideKeycaps then hideKeycaps() end
        for _, obj in pairs(Workspace:GetDescendants()) do
            for _, name in ipairs(antilagTargets) do
                if obj.Name == name then pcall(function() obj:Destroy() end) end
            end
        end
    else
        antilagToggle.Text = "Antilag: OFF"
        antilagToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
        antilagToggle.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
        pcall(function() Lighting.GlobalShadows = true end)
    end
end)

local autoRebirth = false
local rebirthBtn = Instance.new("TextButton")
rebirthBtn.Parent = ExtrasPage
rebirthBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
rebirthBtn.Size = UDim2.new(1, -10, 0, 32)
rebirthBtn.Font = Enum.Font.GothamBold
rebirthBtn.Text = "Auto Rebirth: OFF"
rebirthBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
rebirthBtn.TextSize = 12
rebirthBtn.LayoutOrder = 6
Instance.new("UICorner", rebirthBtn).CornerRadius = UDim.new(0, 6)
rebirthBtn.MouseButton1Click:Connect(function()
    autoRebirth = not autoRebirth
    rebirthBtn.Text = autoRebirth and "Auto Rebirth: ON" or "Auto Rebirth: OFF"
    rebirthBtn.TextColor3 = autoRebirth and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    rebirthBtn.BackgroundColor3 = autoRebirth and Color3.fromRGB(35, 60, 35) or Color3.fromRGB(26, 26, 34)
end)
task.spawn(function()
    while true do
        task.wait(1.5)
        if autoRebirth then
            pcall(function()
                game:GetService("ReplicatedStorage").Remotes.Rebirth:FireServer()
            end)
        end
    end
end)

local autoLoadScript = false
local autoLoadBtn = Instance.new("TextButton")
autoLoadBtn.Parent = ExtrasPage
autoLoadBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
autoLoadBtn.Size = UDim2.new(1, -10, 0, 32)
autoLoadBtn.Font = Enum.Font.GothamBold
autoLoadBtn.Text = "Auto Load Script: OFF"
autoLoadBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
autoLoadBtn.TextSize = 12
autoLoadBtn.LayoutOrder = 8
Instance.new("UICorner", autoLoadBtn).CornerRadius = UDim.new(0, 6)
local function queueThisScript()
    local url = getgenv and getgenv().DeltaHubCurrentUrl
    if not url then return end
    local src = 'loadstring(game:HttpGet("' .. url .. '"))()'
    pcall(function()
        if queue_on_teleport then queue_on_teleport(src)
        elseif syn and syn.queue_on_teleport then syn.queue_on_teleport(src) end
    end)
end
autoLoadBtn.MouseButton1Click:Connect(function()
    autoLoadScript = not autoLoadScript
    autoLoadBtn.Text = autoLoadScript and "Auto Load Script: ON" or "Auto Load Script: OFF"
    autoLoadBtn.TextColor3 = autoLoadScript and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    autoLoadBtn.BackgroundColor3 = autoLoadScript and Color3.fromRGB(35, 60, 35) or Color3.fromRGB(26, 26, 34)
    if autoLoadScript then queueThisScript() end
end)

local configFile = "DeltaHub_Configs_Keyboard.json"
local configs = {default = {}}
local autoConfigName = "default"
local rememberOverwrite = false
local function readConfigs()
    pcall(function()
        if isfile and isfile(configFile) then
            local data = game:GetService("HttpService"):JSONDecode(readfile(configFile))
            configs = data.configs or {default = {}}
            autoConfigName = data.autoConfigName or "default"
            rememberOverwrite = data.rememberOverwrite and true or false
            if not configs.default then configs.default = {} end
        end
    end)
end
local function writeConfigs()
    pcall(function()
        writefile(configFile, game:GetService("HttpService"):JSONEncode({
            configs = configs,
            autoConfigName = autoConfigName,
            rememberOverwrite = rememberOverwrite,
        }))
    end)
end
local function captureConfig()
    return {
        gameSpeed = gameSpeed,
        delayTime = delayTime,
        infiniteRouteActive = infiniteRouteActive,
        routeMode = routeMode,
        antilagActive = antilagActive,
        autoRebirth = autoRebirth,
        autoLoadScript = autoLoadScript,
    }
end
local function applyConfig(data)
    data = data or {}
    if data.gameSpeed then gameSpeed = data.gameSpeed speedGameBox.Text = tostring(gameSpeed) end
    if data.delayTime then delayTime = data.delayTime delayBox.Text = tostring(delayTime) end
    if data.routeMode then routeMode = data.routeMode paintRouteMode() end
    infiniteRouteActive = data.infiniteRouteActive and true or false
    infRouteToggle.Text = infiniteRouteActive and "Recorrido Infinito: ON" or "Recorrido Infinito: OFF"
    if data.antilagActive and not antilagActive then antilagToggle.Text = "Antilag: ON" antilagActive = true end
    if data.autoRebirth ~= nil and autoRebirth ~= nil then autoRebirth = data.autoRebirth end
end
readConfigs()

local configNameBox = Instance.new("TextBox")
configNameBox.Parent = ExtrasPage
configNameBox.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
configNameBox.Size = UDim2.new(1, -10, 0, 32)
configNameBox.Font = Enum.Font.Gotham
configNameBox.PlaceholderText = "Nombre de configuracion"
configNameBox.Text = ""
configNameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
configNameBox.TextSize = 13
configNameBox.LayoutOrder = 9
Instance.new("UICorner", configNameBox).CornerRadius = UDim.new(0, 6)

local saveConfigBtn = Instance.new("TextButton")
saveConfigBtn.Parent = ExtrasPage
saveConfigBtn.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
saveConfigBtn.Size = UDim2.new(1, -10, 0, 32)
saveConfigBtn.Font = Enum.Font.GothamBold
saveConfigBtn.Text = "Guardar configuracion"
saveConfigBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
saveConfigBtn.TextSize = 12
saveConfigBtn.LayoutOrder = 10
Instance.new("UICorner", saveConfigBtn).CornerRadius = UDim.new(0, 6)

local configListOpen = false
local configSelector = Instance.new("TextButton")
configSelector.Parent = ExtrasPage
configSelector.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
configSelector.Size = UDim2.new(1, -10, 0, 32)
configSelector.Font = Enum.Font.GothamBold
configSelector.Text = "Configuraciones: default"
configSelector.TextColor3 = Color3.fromRGB(255, 255, 255)
configSelector.TextSize = 12
configSelector.LayoutOrder = 11
Instance.new("UICorner", configSelector).CornerRadius = UDim.new(0, 6)
local configList = Instance.new("Frame")
configList.Parent = ExtrasPage
configList.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
configList.Size = UDim2.new(1, -10, 0, 120)
configList.Visible = false
configList.LayoutOrder = 12
Instance.new("UICorner", configList).CornerRadius = UDim.new(0, 6)
local configScroll = Instance.new("ScrollingFrame")
configScroll.Parent = configList
configScroll.BackgroundTransparency = 1
configScroll.Size = UDim2.new(1, 0, 1, 0)
configScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
configScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
configScroll.ScrollBarThickness = 4
local configLayout = Instance.new("UIListLayout")
configLayout.Parent = configScroll
configLayout.Padding = UDim.new(0, 4)

local selectedConfigName = "default"
local function rebuildConfigList()
    for _, child in ipairs(configScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for name, _ in pairs(configs) do
        local b = Instance.new("TextButton")
        b.Parent = configScroll
        b.Size = UDim2.new(1, -8, 0, 26)
        b.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        b.Font = Enum.Font.Gotham
        b.Text = name .. (name == autoConfigName and "  [auto]" or "")
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
        b.TextSize = 12
        b.MouseButton1Click:Connect(function()
            selectedConfigName = name
            configSelector.Text = "Configuraciones: " .. name
        end)
    end
end
configSelector.MouseButton1Click:Connect(function()
    configListOpen = not configListOpen
    configList.Visible = configListOpen
    if configListOpen then rebuildConfigList() end
end)

local function doSave(name)
    configs[name] = captureConfig()
    writeConfigs()
    configSelector.Text = "Configuraciones: " .. name
    selectedConfigName = name
    showNotification("Configuracion guardada: " .. name)
end
local pendingOverwrite = nil
saveConfigBtn.MouseButton1Click:Connect(function()
    local name = configNameBox.Text
    if name == "" or name == "default" then
        showNotification("Escribe un nombre. default no se puede borrar.")
        return
    end
    if configs[name] and not rememberOverwrite then
        pendingOverwrite = name
        showNotification("Ya existe " .. name .. ". Vuelve a picar Guardar para reemplazarla.")
        return
    end
    if pendingOverwrite == name or rememberOverwrite or not configs[name] then
        doSave(name)
        pendingOverwrite = nil
    end
end)
local rememberBtn = Instance.new("TextButton")
rememberBtn.Parent = ExtrasPage
rememberBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
rememberBtn.Size = UDim2.new(1, -10, 0, 32)
rememberBtn.Font = Enum.Font.GothamBold
rememberBtn.Text = "Recordar reemplazo: OFF"
rememberBtn.TextColor3 = Color3.fromRGB(255, 180, 80)
rememberBtn.TextSize = 12
rememberBtn.LayoutOrder = 15
Instance.new("UICorner", rememberBtn).CornerRadius = UDim.new(0, 6)
rememberBtn.MouseButton1Click:Connect(function()
    rememberOverwrite = not rememberOverwrite
    writeConfigs()
    rememberBtn.Text = rememberOverwrite and "Recordar reemplazo: ON" or "Recordar reemplazo: OFF"
    rememberBtn.TextColor3 = rememberOverwrite and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 180, 80)
end)

local loadConfigBtn = Instance.new("TextButton")
loadConfigBtn.Parent = ExtrasPage
loadConfigBtn.BackgroundColor3 = Color3.fromRGB(45, 70, 110)
loadConfigBtn.Size = UDim2.new(1, -10, 0, 32)
loadConfigBtn.Font = Enum.Font.GothamBold
loadConfigBtn.Text = "Cargar configuracion"
loadConfigBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
loadConfigBtn.TextSize = 12
loadConfigBtn.LayoutOrder = 13
Instance.new("UICorner", loadConfigBtn).CornerRadius = UDim.new(0, 6)
loadConfigBtn.MouseButton1Click:Connect(function()
    applyConfig(configs[selectedConfigName] or configs.default)
    showNotification("Configuracion cargada: " .. selectedConfigName)
end)

local autoConfigBtn = Instance.new("TextButton")
autoConfigBtn.Parent = ExtrasPage
autoConfigBtn.BackgroundColor3 = Color3.fromRGB(70, 55, 30)
autoConfigBtn.Size = UDim2.new(1, -10, 0, 32)
autoConfigBtn.Font = Enum.Font.GothamBold
autoConfigBtn.Text = "Autoload config: " .. autoConfigName
autoConfigBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoConfigBtn.TextSize = 12
autoConfigBtn.LayoutOrder = 14
Instance.new("UICorner", autoConfigBtn).CornerRadius = UDim.new(0, 6)
autoConfigBtn.MouseButton1Click:Connect(function()
    autoConfigName = selectedConfigName or "default"
    writeConfigs()
    autoConfigBtn.Text = "Autoload config: " .. autoConfigName
    showNotification("Al iniciar cargara: " .. autoConfigName)
end)
if configs[autoConfigName] then applyConfig(configs[autoConfigName]) end

task.spawn(function()
    while true do
        task.wait(0.3)
        if antilagActive then
            -- Decorations al activar anti-lag (master)
            pcall(function()
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj.Name == "Decorations" or obj.Name == "Props" then
                        obj:Destroy()
                    end
                end
            end)
            if hideKeycaps then hideKeycaps() end
        end
    end
end)


local specialKeysToggle = Instance.new("TextButton")
specialKeysToggle.Parent = ExtrasPage
specialKeysToggle.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
specialKeysToggle.Size = UDim2.new(1, -10, 0, 32)
specialKeysToggle.Font = Enum.Font.GothamBold
specialKeysToggle.Text = "Auto SpecialKeys: OFF"
specialKeysToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
specialKeysToggle.TextSize = 12
specialKeysToggle.LayoutOrder = 2
Instance.new("UICorner", specialKeysToggle).CornerRadius = UDim.new(0, 6)

specialKeysToggle.MouseButton1Click:Connect(function()
    autoSpecialKeysActive = not autoSpecialKeysActive
    if autoSpecialKeysActive then
        specialKeysToggle.Text = "Auto SpecialKeys: ON"
        specialKeysToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
        specialKeysToggle.BackgroundColor3 = Color3.fromRGB(35, 60, 35)
    else
        specialKeysToggle.Text = "Auto SpecialKeys: OFF"
        specialKeysToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
        specialKeysToggle.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
    end
end)

local skSelectorMain = Instance.new("Frame")
skSelectorMain.Parent = ExtrasPage
skSelectorMain.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
skSelectorMain.Size = UDim2.new(1, -10, 0, 32)
skSelectorMain.LayoutOrder = 3
Instance.new("UICorner", skSelectorMain).CornerRadius = UDim.new(0, 6)

local skSelectorBtn = Instance.new("TextButton")
skSelectorBtn.Parent = skSelectorMain
skSelectorBtn.BackgroundTransparency = 1
skSelectorBtn.Size = UDim2.new(1, 0, 1, 0)
skSelectorBtn.Font = Enum.Font.GothamBold
skSelectorBtn.Text = "Modo SpecialKey: Tween â¾"
skSelectorBtn.TextColor3 = Color3.fromRGB(240, 240, 245)
skSelectorBtn.TextSize = 12

local skDropdown = Instance.new("Frame")
skDropdown.Parent = ExtrasPage
skDropdown.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
skDropdown.Size = UDim2.new(1, -10, 0, 60)
skDropdown.Visible = false
skDropdown.LayoutOrder = 4
Instance.new("UICorner", skDropdown).CornerRadius = UDim.new(0, 6)
local skDropLayout = Instance.new("UIListLayout")
skDropLayout.Parent = skDropdown
skDropLayout.SortOrder = Enum.SortOrder.LayoutOrder
skDropLayout.Padding = UDim.new(0, 4)

local function createSKOption(text, order)
    local opt = Instance.new("TextButton")
    opt.Parent = skDropdown
    opt.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
    opt.Size = UDim2.new(1, 0, 0, 28)
    opt.Font = Enum.Font.Gotham
    opt.Text = text
    opt.TextColor3 = Color3.fromRGB(200, 200, 210)
    opt.TextSize = 12
    opt.LayoutOrder = order
    Instance.new("UICorner", opt).CornerRadius = UDim.new(0, 4)
    opt.MouseButton1Click:Connect(function()
        eventCollectMode = text
        skSelectorBtn.Text = "Modo SpecialKey: " .. text .. " â¾"
        skDropdown.Visible = false
    end)
end
createSKOption("Tween", 1)
createSKOption("Tp", 2)
skSelectorBtn.MouseButton1Click:Connect(function() skDropdown.Visible = not skDropdown.Visible end)



local bestTreadmill = "Normal"

local conveyorHome = nil
local conveyorPart = nil
local millWins = false
local function partOf(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") then return obj end
    if obj:IsA("Model") then
        return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
    end
    return nil
end
local function treadmillFolder()
    local lobby = Workspace:FindFirstChild("Lobby")
    return lobby and lobby:FindFirstChild("Treadmills")
end
local function findConveyor(model)
    if not model then return nil end
    local exact = model:FindFirstChild("Conveyor", true)
    if exact then
        local part = partOf(exact)
        if part then return part end
    end
    for _, d in ipairs(model:GetDescendants()) do
        if d.Name == "Conveyor" or string.lower(d.Name) == "conveyor" then
            local part = partOf(d)
            if part then return part end
        end
    end
    return nil
end
local function bestConveyor()
    local folder = treadmillFolder()
    if not folder then return nil end
    local names = {Admin = "TreadmillAdmin", Candy = "TreadmillCandy", Diamond = "TreadmillDiamond", Gold = "TreadmillGold"}
    if bestTreadmill ~= "Normal" then
        return findConveyor(folder:FindFirstChild(names[bestTreadmill]))
    end
    local gold = folder:FindFirstChild("TreadmillGold")
    local goldPos = gold and (gold:IsA("Model") and gold:GetPivot().Position or (partOf(gold) and partOf(gold).Position)) or Vector3.new()
    local chosen, chosenDist
    for _, child in ipairs(folder:GetChildren()) do
        if child.Name == "Treadmill" then
            local conv = findConveyor(child)
            if conv then
                local pos = conv.Position
                local dist = (pos - goldPos).Magnitude
                if not chosenDist or dist < chosenDist then
                    chosen = conv
                    chosenDist = dist
                end
            end
        end
    end
    return chosen
end
local function sendToBestTreadmill()
    local conv = bestConveyor()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not conv then
        showNotification("No encontre el conveyor de la treadmill")
        return false
    end
    local cf = conv:IsA("BasePart") and conv.CFrame or (conv:IsA("Model") and conv:GetPivot())
    if not cf then
        showNotification("No encontre el Conveyor")
        return false
    end
    hrp.CFrame = cf + Vector3.new(0, 4, 0)
    showNotification("Enviado a Conveyor " .. tostring(bestTreadmill))
    return true
end
local function restoreConveyor()
    if conveyorPart and conveyorHome then
        conveyorPart.CFrame = conveyorHome
    end
    conveyorPart = nil
    conveyorHome = nil
end
task.spawn(function()
    while true do
        task.wait(0.1)
        if millWins and routeRunning then
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if not conveyorPart then
                conveyorPart = bestConveyor()
                if conveyorPart then conveyorHome = conveyorPart.CFrame end
            end
            if hrp and conveyorPart then
                conveyorPart.Anchored = true
                conveyorPart.CFrame = hrp.CFrame * CFrame.new(0, -3, 0)
            end
        elseif conveyorPart then
            restoreConveyor()
        end
    end
end)
local function treadmillShop()
    local gui = player:FindFirstChild("PlayerGui")
    local speedUi = gui and gui:FindFirstChild("SpeedGameUI")
    local modals = speedUi and speedUi:FindFirstChild("Modals")
    return modals and modals:FindFirstChild("RobuxShopModal")
end
local function closeTreadmillShop()
    local modal = treadmillShop()
    if modal and modal:IsA("GuiObject") then
        modal.Visible = false
    end
end
local function visiblePurchase()
    local gui = player:FindFirstChild("PlayerGui")
    if not gui then return false end
    for _, d in ipairs(gui:GetDescendants()) do
        if d:IsA("GuiObject") and d.Visible then
            local n = string.lower(d.Name)
            if n:find("robux") or n:find("purchase") or n:find("prompt") or n:find("shopmodal") or n:find("buy") then
                if d:IsA("Frame") or d:IsA("ImageLabel") or d:IsA("TextButton") then
                    return true
                end
            end
        end
    end
    return false
end
local function detectBestTreadmill(hrp)
    bestTreadmill = "Normal"
    local folder = treadmillFolder()
    if not folder then
        if getgenv then getgenv().DeltaHubBestTreadmill = bestTreadmill end
        return
    end
    local checks = {
        {name = "Admin", remote = "PromptAdminTreadmill"},
        {name = "Candy", remote = "PromptCandyTreadmill"},
        {name = "Diamond", remote = "PromptDiamondTreadmill"},
        {name = "Gold", remote = "PromptGoldTreadmill"},
    }
    local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
    for _, info in ipairs(checks) do
        local remote = remotes and remotes:FindFirstChild(info.remote)
        if remote then
            closeTreadmillShop()
            local before = visiblePurchase()
            pcall(function() remote:FireServer() end)
            task.wait(0.45)
            local opened = visiblePurchase() and not before
            local modal = treadmillShop()
            if modal and modal:IsA("GuiObject") and modal.Visible then opened = true end
            closeTreadmillShop()
            if not opened then
                bestTreadmill = info.name
                break
            end
        end
    end
    closeTreadmillShop()
    if bestTreadmill ~= "Normal" then
        showNotification("Treadmill confirmada: " .. bestTreadmill)
    else
        showNotification("Treadmill: x1 basica")
    end
    if getgenv then getgenv().DeltaHubBestTreadmill = bestTreadmill end
end

-- ==========================================
-- ==========================================

end

local function __hw_B()
-- CARGA EN 14 PARTES (~7.1% c/u) agrupadas en 4 bloques
-- ==========================================
-- Bloque 1/4: partes 1-4 | 2/4: 5-8 | 3/4: 9-11 | 4/4: 12-14
pcall(function()
    if MainFrame then MainFrame.Visible = false end
    if FloatingLogo then FloatingLogo.Visible = false end
    if StopRouteContainer then StopRouteContainer.Visible = false end
end)

local LOAD_PART_NAMES = {
    "Boot / PlaceId / PlayerGui",
    "Limpieza (datos)",
    "Pantalla de carga",
    "Notificaciones + chrome UI",
    "PÃ¡gina Player (base)",
    "Ruta + WinBlocks + modes",
    "LÃ³gica de farm",
    "PÃ¡gina Extras (base)",
    "Treadmills",
    "Preparar UI Farm",
    "Preparar UI Player/Events",
    "Special Keys / eventos",
    "Bucle de recorridos (listo)",
    "UI final (buildHubUi)",
}

local function partProgress(partIndex)
    -- partIndex 1..14 â porcentaje. La 14 cierra a 100
    if partIndex >= 14 then return 100 end
    return (partIndex / 14) * 100
end

local function blockLabel(partIndex)
    if partIndex <= 4 then return "Bloque 1/4"
    elseif partIndex <= 8 then return "Bloque 2/4"
    elseif partIndex <= 11 then return "Bloque 3/4"
    else return "Bloque 4/4" end
end

local function finishPart(partIndex)
    local p = partProgress(partIndex)
    local name = LOAD_PART_NAMES[partIndex] or ("Parte " .. partIndex)
    setProgress(p, blockLabel(partIndex) .. "  Â·  Parte " .. partIndex .. "/14", name)
    task.wait()
end
HW.finishPart = finishPart
HW.partProgress = partProgress
HW.blockLabel = blockLabel

task.spawn(function()
    local function loadFail(err)
        warn("[Delta Hub] load error: " .. tostring(err))
        pcall(function()
            if LoadingSub then LoadingSub.Text = "ERROR: " .. tostring(err):sub(1, 80) end
            if LoadingText then LoadingText.Text = "Fallo al cargar" end
            if PctLabel then PctLabel.TextColor3 = Color3.fromRGB(255, 100, 100) end
        end)
    end
    local okAll, errAll = pcall(function()
    if getgenv and getgenv().DeltaHubSkipAssets then
        if LoadingScreen and LoadingScreen.Parent then LoadingScreen:Destroy() end
        scriptReady = true
        pcall(function() buildHubUi() end)
        if MainFrame then MainFrame.Visible = true end
        return
    end

    setProgress(0, "Bloque 1/4", "Iniciando...")
    task.wait(0.05)

    -- 1 Boot (ya corriÃ³ al parsear; marcamos)
    finishPart(1)
    -- 2 Limpieza datos
    pcall(function()
        if targetNamesToDestroy then
            local _ = #targetNamesToDestroy
        end
    end)
    finishPart(2)
    -- 3 Pantalla carga (ya visible)
    finishPart(3)
    -- 4 Notificaciones + chrome
    pcall(function()
        if FloatingLogo then local _ = FloatingLogo.Name end
        if MainFrame then local _ = MainFrame.Name end
    end)
    finishPart(4)

    -- 5 Player page refs
    pcall(function()
        if PlayerPage then local _ = PlayerPage.Name end
    end)
    finishPart(5)
    -- 6 Ruta + modes
    pcall(function()
        local n = #routeCFrames
        for i = 1, n do
            local _ = routeCFrames[i]
            local __ = routeModes and routeModes[i]
            if i % 15 == 0 then task.wait() end
        end
    end)
    finishPart(6)
    -- 7 Farm logic warm
    pcall(function()
        if approachSpeed then local _ = approachSpeed(10, 5) end
        if orderedWinBlocks then local _ = #orderedWinBlocks end
    end)
    finishPart(7)
    -- 8 Extras base
    pcall(function()
        if ExtrasPage then local _ = ExtrasPage.Name end
    end)
    finishPart(8)

    -- 9 Treadmills (sin prompts largos si se puede)
    pcall(function()
        if typeof(bestTreadmill) == "string" then
            -- ok
        end
    end)
    finishPart(9)
    -- 10 UI Farm piece
    finishPart(10)
    -- 11 UI Player/Events piece
    finishPart(11)

    -- 12 Special keys / events systems warm
    pcall(function()
        if type(processSpecialKey) == "function" then end
    end)
    finishPart(12)
    -- 13 Route loop ready
    finishPart(13)

    -- 14 buildHubUi (el pesado, ya partido en 3)
    -- Antes: elecciÃ³n de limpieza + TP por ruta
    setProgress(partProgress(13), "Bloque 4/4  Â·  Parte 14/14", "Elige tipo de limpieza")
    local CleanChoiceFrame = HW.CleanChoiceFrame or CleanChoiceFrame
    local btnCleanNormal = HW.btnCleanNormal or btnCleanNormal
    local btnCleanFast = HW.btnCleanFast or btnCleanFast
    local btnCleanSuper = HW.btnCleanSuper or btnCleanSuper
    local setProgress = HW.setProgress or setProgress
    local partProgress = HW.partProgress or partProgress
    local getRouteCFramesForMode = HW.getRouteCFramesForMode or getRouteCFramesForMode
    local routeCFrames = HW.routeCFrames or routeCFrames
    local waitAliveHrp = HW.waitAliveHrp or waitAliveHrp
    local runExactCleanup = HW.runExactCleanup or runExactCleanup
    local fadeAndDestroyLoading = HW.fadeAndDestroyLoading or fadeAndDestroyLoading
    local buildHubUi = HW.buildHubUi or buildHubUi
    local MainFrame = HW.MainFrame or MainFrame

    if CleanChoiceFrame then CleanChoiceFrame.Visible = true end
    local chosenMode = nil
    local bindN, bindF, bindS
    if btnCleanNormal then
        bindN = btnCleanNormal.MouseButton1Click:Connect(function() chosenMode = "normal" end)
        bindF = btnCleanFast.MouseButton1Click:Connect(function() chosenMode = "fast" end)
        bindS = btnCleanSuper.MouseButton1Click:Connect(function() chosenMode = "super" end)
    else
        warn("[HW] botones de limpieza nil")
        chosenMode = "normal"
    end
    local waitStart = tick()
    while not chosenMode and tick() - waitStart < 90 do
        task.wait(0.1)
    end
    if not chosenMode then chosenMode = "normal" end
    pcall(function()
        if bindN then bindN:Disconnect() end
        if bindF then bindF:Disconnect() end
        if bindS then bindS:Disconnect() end
    end)
    if CleanChoiceFrame then CleanChoiceFrame.Visible = false end

    setProgress(95, "Bloque 4/4  Â·  Limpieza", "Limpiando (" .. chosenMode .. ")...")
    local routeList = select(1, getRouteCFramesForMode(chosenMode == "super" and "super" or chosenMode))
    local hrp = waitAliveHrp((routeList and routeList[1]) or routeCFrames[1])
    local nRoute = math.max(1, #(routeList or {}))
    for i, spot in ipairs(routeList or {}) do
        hrp = waitAliveHrp(spot)
        if not hrp then break end
        hrp.CFrame = spot
        hrp.AssemblyLinearVelocity = Vector3.new()
        if runExactCleanup then runExactCleanup() end
        local p = 95 + (i / nRoute) * 4
        setProgress(math.min(p, 99.5), "Bloque 4/4  Â·  Limpieza", string.format("%s %d/%d", chosenMode, i, nRoute))
        task.wait(0.05)
    end
    if runExactCleanup then runExactCleanup() end

    pcall(function()
        buildHubUi()
    end)
    if hrp and routeCFrames[1] then
        hrp.CFrame = routeCFrames[1]
    end
    finishPart(14)
    fadeAndDestroyLoading()
    if MainFrame then MainFrame.Visible = true end
    showNotification("Hallowen world listo")
    end) -- pcall okAll
    if not okAll then loadFail(errAll) end
end)




-- ==========================================
-- LÃGICA DE RECOGIDA DE SPECIALKEY CON RETORNO A POSICIÃN ORIGINAL
-- ==========================================
local specialKeyCount = 0
local specialKeyWins = 0
local function readExactWins()
    local ls = player:FindFirstChild("leaderstats")
    local w = ls and ls:FindFirstChild("Wins")
    return w and tonumber(w.Value) or 0
end
local function processSpecialKey(obj, hrp)
    local beforeWins = readExactWins()
    local itemPos = obj.Position or obj:GetPrimaryPartCFrame().Position
    local originalPos = hrp.CFrame
    
    if eventCollectMode == "Tp" then
        specialKeyCount = specialKeyCount + 1
        specialKeyWins = specialKeyWins + math.max(0, readExactWins() - beforeWins)
        showNotification("SpecialKey encontrada haciendo tp a ella")
        hrp.CFrame = CFrame.new(itemPos + Vector3.new(0, 3, 0))
    elseif eventCollectMode == "Tween" then
        showNotification("SpecialKey encontrada usando ruta de Wins")
        local closestIdx = 1
        local shortestDist = math.huge
        for idx, cf in ipairs(routeCFrames) do
            local dist = (cf.Position - itemPos).Magnitude
            if dist < shortestDist then shortestDist = dist; closestIdx = idx end
        end
        
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Parent = hrp
        
        hrp.CFrame = routeCFrames[1]
        for i = 2, closestIdx do
            local targetPos = routeCFrames[i].Position
            while hrp and (hrp.Position - targetPos).Magnitude > 1 and autoSpecialKeysActive do
                bv.Velocity = (targetPos - hrp.Position).Unit * approachSpeed((targetPos - hrp.Position).Magnitude, routeCFrames[i + 1] and (routeCFrames[i + 1].Position - targetPos).Magnitude)
                RunService.Stepped:Wait()
            end
        end
        while hrp and (hrp.Position - itemPos).Magnitude > 3 and autoSpecialKeysActive do
            bv.Velocity = (itemPos - hrp.Position).Unit * approachSpeed((itemPos - hrp.Position).Magnitude)
            RunService.Stepped:Wait()
        end
        if bv then bv:Destroy() end
    end
    
    local tStart = tick()
    while obj and obj.Parent and autoSpecialKeysActive and (tick() - tStart < 10) do
        pcall(function()
            local fwd = hrp.CFrame.LookVector
            hrp.CFrame = hrp.CFrame + (fwd * 3)
            task.wait(0.15)
            hrp.CFrame = hrp.CFrame - (fwd * 3)
            task.wait(0.15)
        end)
    end
    
    if hrp then
        hrp.CFrame = originalPos
    end
end

-- ==========================================
-- BUCLE PRINCIPAL DE RECORRIDOS Y MONITOREO DE VIDA
-- ==========================================
startRouteBtn.MouseButton1Click:Connect(function()
    if not scriptReady then
        showNotification("Espera a que termine la carga")
        return
    end
    if routeRunning then return end
    local typed = tonumber(speedGameBox.Text)
    gameSpeed = math.clamp(typed or gameSpeed or 250, 1, 500)
    speedGameBox.Text = tostring(gameSpeed)
    routeRunning = true
    StopRouteContainer.Visible = false
    startRouteBtn.Text = "Iniciando Recorrido..."
    startRouteBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
    startRouteBtn.BackgroundColor3 = Color3.fromRGB(35, 60, 35)
    
    task.spawn(function()
        while routeRunning do
            local char = player.Character or player.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart", 5)
            local hum = char:WaitForChild("Humanoid", 5)
            
            if hrp and hum and hum.Health > 0 then
                noClipEnabled = true
                noclipToggle.Text = "Noclip: ON"
                noclipToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
                noclipToggle.BackgroundColor3 = Color3.fromRGB(35, 60, 35)
                
                -- Ruta filtrada por modo (normal / fast / ultra|super)
                local activeRoute = select(1, getRouteCFramesForMode(routeMode))
                if not activeRoute or #activeRoute == 0 then activeRoute = routeCFrames end
                
                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Parent = hrp
                
                hrp.CFrame = activeRoute[1]
                
                local targetObject = nil
                local targetFound = false
                local closestIndex = #activeRoute
                
                task.spawn(function()
                    while not targetFound and routeRunning and hum.Health > 0 do
                        targetObject = Workspace:FindFirstChild(selectedRealName, true)
                        if targetObject and (targetObject:IsA("BasePart") or (targetObject:IsA("Model") and targetObject.PrimaryPart)) then
                            targetFound = true
                            local objPos = targetObject.Position or targetObject:GetPrimaryPartCFrame().Position
                            local shortestDist = math.huge
                            for idx, cf in ipairs(activeRoute) do
                                local dist = (cf.Position - objPos).Magnitude
                                if dist < shortestDist then shortestDist = dist; closestIndex = idx end
                            end
                            break
                        end
                        task.wait(1)
                    end
                end)
                
                local lastCheckPos = hrp.Position
                local lifeMonitor = task.spawn(function()
                    while routeRunning and hum.Health > 0 do
                        task.wait(2)
                        if hum.Health <= 0 then break end
                        
                        if autoSpecialKeysActive then
                            for _, obj in pairs(Workspace:GetDescendants()) do
                                if obj.Name:find("SpecialKey") then
                                    if (obj:IsA("BasePart") or (obj:IsA("Model") and obj.PrimaryPart)) then
                                        local alreadyQueued = false
                                        for _, qObj in ipairs(specialKeysQueue) do
                                            if qObj == obj then alreadyQueued = true; break; end
                                        end
                                        if not alreadyQueued then
                                            table.insert(specialKeysQueue, obj)
                                        end
                                    end
                                end
                            end
                        end
                        
                        lastCheckPos = hrp.Position
                    end
                end)
                
                local currentIndex = 2
                while currentIndex <= #activeRoute and routeRunning and hum.Health > 0 do
                    if currentIndex > closestIndex then break end
                    local targetPos = activeRoute[currentIndex].Position
                    local mustPlant = false
                    local reach = mustPlant and 0.15 or 1
                    while hrp and (hrp.Position - targetPos).Magnitude > reach and routeRunning and hum.Health > 0 do
                        local dist = (hrp.Position - targetPos).Magnitude
                        local spd = approachSpeed(dist, activeRoute[currentIndex + 1] and (activeRoute[currentIndex + 1].Position - targetPos).Magnitude)
                        if dist > 0.05 then
                            bv.Velocity = (targetPos - hrp.Position).Unit * spd
                        else
                            bv.Velocity = Vector3.new(0, 0, 0)
                        end
                        RunService.Stepped:Wait()
                    end
                                        currentIndex = currentIndex + 1
                end
                
                while not targetObject and routeRunning and hum.Health > 0 do
                    targetObject = Workspace:FindFirstChild(selectedRealName, true)
                    task.wait(0.5)
                end
                
                if targetObject and routeRunning and hum.Health > 0 then
                    local objPos = targetObject.Position or targetObject:GetPrimaryPartCFrame().Position
                    if (hrp.Position - objPos).Magnitude > 4 then
                        while hrp and (hrp.Position - objPos).Magnitude > 4 and routeRunning and hum.Health > 0 do
                            objPos = targetObject.Position or targetObject:GetPrimaryPartCFrame().Position
                            bv.Velocity = (objPos - hrp.Position).Unit * approachSpeed((objPos - hrp.Position).Magnitude)
                            RunService.Stepped:Wait()
                        end
                    end
                    if bv then bv.Velocity = Vector3.new(0, 0, 0) end

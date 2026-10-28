                end
                
                if bv then bv:Destroy() end
                pcall(function() task.cancel(lifeMonitor) end)
                
                if routeRunning and hum.Health > 0 then
                    -- Espera exacta de 0.67 segundos para dar tiempo al SpawnLocation del WinBlock
                    task.wait(0.67)
                    addRouteWins()
                    
                    hrp.CFrame = routeCFrames[1]
                    local holdTime = 1 + delayTime
                    local holdElapsed = 0
                    while routeRunning and hum.Health > 0 and holdElapsed < holdTime do
                        hrp.CFrame = routeCFrames[1]
                        task.wait(0.1)
                        holdElapsed = holdElapsed + 0.1
                    end
                end
            else
                if routeRunning then
                    PromptContainer.Visible = true
                    resetWinStreak()
                    local choice = nil
                    
                    local connYes, connNo
                    connYes = YesBtn.MouseButton1Click:Connect(function() choice = true; connYes:Disconnect(); connNo:Disconnect() end)
                    connNo = NoBtn.MouseButton1Click:Connect(function() choice = false; connYes:Disconnect(); connNo:Disconnect() end)
                    
                    while choice == nil and routeRunning do task.wait(0.2) end
                    PromptContainer.Visible = false
                    
                    if choice == true then
                        local char = player.Character
                        local humNow = char and char:FindFirstChildOfClass("Humanoid")
                        if not char or not humNow or humNow.Health <= 0 then
                            char = player.CharacterAdded:Wait()
                        end
                        task.wait(0.4)
                        local hrpNow = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        if hrpNow and routeCFrames[1] then
                            hrpNow.CFrame = routeCFrames[1]
                            hrpNow.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        end
                        -- reanuda el while routeRunning (sin keyword continue)
                    else
                        stopRecorridoGeneral()
                        break
                    end
                end
            end
            
            local goalStillGoing = goalEnabled and not infiniteRouteActive and goalProgress < goalAmount
            if finishAfterClaim or (not infiniteRouteActive and not goalStillGoing) then
                while #specialKeysQueue > 0 do
                    local keyObj = table.remove(specialKeysQueue, 1)
                    if keyObj and keyObj.Parent then processSpecialKey(keyObj, hrp) end
                end
                stopRecorridoGeneral()
                break
            end
            while #specialKeysQueue > 0 and routeRunning do
                local keyObj = table.remove(specialKeysQueue, 1)
                if keyObj and keyObj.Parent then processSpecialKey(keyObj, hrp) end
            end
        end
    end)
end)

-- Bucle independiente para SpecialKeys cuando NO hay recorrido activo
task.spawn(function()
    while true do
        task.wait(2)
        if autoSpecialKeysActive and not routeRunning then
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local foundKey = nil
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj.Name:find("SpecialKey") then
                        if (obj:IsA("BasePart") or (obj:IsA("Model") and obj.PrimaryPart)) then
                            foundKey = obj
                            break
                        end
                    end
                end
                if foundKey then
                    processSpecialKey(foundKey, hrp)
                end
            end
        end
    end
end)

-- ==========================================
-- NAVEGACIÃN Y STEPS GENERALES
-- ==========================================
local MainFrame = HW.MainFrame or MainFrame
local FloatingLogo = HW.FloatingLogo or FloatingLogo
local Sidebar = HW.Sidebar or Sidebar
local ScreenGui = HW.ScreenGui or ScreenGui
local MinimizeBtn = HW.MinimizeBtn or MinimizeBtn
local TabPlayerBtn = HW.TabPlayerBtn or TabPlayerBtn
local TabGameBtn = HW.TabGameBtn or TabGameBtn
local TabExtrasBtn = HW.TabExtrasBtn or TabExtrasBtn
local TabEventsBtn = HW.TabEventsBtn or TabEventsBtn
local PlayerPage = HW.PlayerPage or PlayerPage
local GamePage = HW.GamePage or GamePage
local ExtrasPage = HW.ExtrasPage or ExtrasPage
local EventsPage = HW.EventsPage or EventsPage
local SectionTitle = HW.SectionTitle or SectionTitle
local ContentArea = HW.ContentArea or ContentArea
local UIListSidebar = HW.UIListSidebar or UIListSidebar

local function setHubOpen(open)
    if MainFrame then MainFrame.Visible = open end
    if FloatingLogo then FloatingLogo.Visible = not open end
    if Sidebar then Sidebar.Visible = open end
    if ScreenGui then
        local panel = ScreenGui:FindFirstChild("WinPanel")
        if panel then panel.Visible = false end
    end
end
if MinimizeBtn then
    MinimizeBtn.MouseButton1Click:Connect(function() setHubOpen(false) end)
end
if FloatingLogo then
    FloatingLogo.MouseButton1Click:Connect(function() setHubOpen(true) end)
end

local function updateTabs(btn, page, title)
    if PlayerPage then PlayerPage.Visible = false end
    if GamePage then GamePage.Visible = false end
    if ExtrasPage then ExtrasPage.Visible = false end
    if EventsPage then EventsPage.Visible = false end
    if page then page.Visible = true end
    if SectionTitle and title then SectionTitle.Text = title end
    if btn then
        -- highlight simple
    end
end

if TabPlayerBtn then TabPlayerBtn.MouseButton1Click:Connect(function() updateTabs(TabPlayerBtn, PlayerPage, "Player") end) end
if TabGameBtn then TabGameBtn.MouseButton1Click:Connect(function() updateTabs(TabGameBtn, GamePage, "Game") end) end
if TabExtrasBtn then TabExtrasBtn.MouseButton1Click:Connect(function() updateTabs(TabExtrasBtn, ExtrasPage, "Extras") end) end
if TabEventsBtn then TabEventsBtn.MouseButton1Click:Connect(function() updateTabs(TabEventsBtn, EventsPage, "Events") end) end

RunService.Stepped:Connect(function()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        if speedEnabled then hum.WalkSpeed = customSpeed end
        if jumpEnabled then
            hum.UseJumpPower = true
            hum.JumpPower = customJump
        end
    end
    if noClipEnabled then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)


local eventChocolate = false
local eventCandy = false
local eventCoin = false
local eventXp = false
local eventQueue = {}
local eventSeen = {}

function hideKeycaps()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local ln = string.lower(obj.Name or "")
        if ln == "keycaps" or string.find(ln, "keycaps", 1, true) then
            if obj:IsA("BasePart") then
                obj.Transparency = 1
                obj.CanCollide = false
                obj.CanTouch = false
                obj.CanQuery = false
            end
            for _, d in ipairs(obj:GetDescendants()) do
                if d:IsA("BasePart") then
                    d.Transparency = 1
                    d.CanCollide = false
                    d.CanTouch = false
                    d.CanQuery = false
                end
            end
        end
    end
end

local function restoreKeycap(obj)
    local function fix(p)
        if p:IsA("BasePart") then
            p.Transparency = 0
            p.CanCollide = true
            p.CanTouch = true
            p.CanQuery = true
        end
    end
    if obj:IsA("BasePart") then fix(obj) end
    for _, d in ipairs(obj:GetDescendants()) do fix(d) end
    local parent = obj.Parent
    if parent then
        local pn = string.lower(parent.Name)
        if string.find(pn, "keycap", 1, true) then
            for _, d in ipairs(parent:GetDescendants()) do fix(d) end
        end
    end
end

local function objectPosition(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") then return obj.Position end
    local ok, pivot = pcall(function() return obj:GetPivot() end)
    if ok and pivot then return pivot.Position end
    local ok2, wp = pcall(function() return obj.WorldPivot end)
    if ok2 and wp then return wp.Position end
    if obj.PrimaryPart then return obj.PrimaryPart.Position end
    local part = obj:FindFirstChildWhichIsA("BasePart", true)
    if part then return part.Position end
    return nil
end

local function eventKind(name)
    local n = string.lower(name or "")
    if eventChocolate and (string.find(n, "chocolatehuntcollectible", 1, true) or (string.find(n, "chocolate", 1, true) and string.find(n, "collect", 1, true))) then
        return "chocolate"
    end
    -- Candy Corn: el contenedor se llama EventCoin (se resuelve en rememberEvent buscando Plane adentro)
    if eventCandy and string.find(n, "eventcoin", 1, true) then
        return "candy"
    end
    if eventCoin and string.find(n, "coinbattlecoin", 1, true) then
        return "coin"
    end
    if eventXp and string.find(n, "electrifiedkeycap", 1, true) then
        return "xp"
    end
    return nil
end

-- Auto Candy Corn: EventCoin -> dentro busca "Plane" y usa su CFrame/posicion
local function findCandyPlane(eventCoinObj)
    if not eventCoinObj then return nil end
    local plaine = eventCoinObj:FindFirstChild("Plane", true)
    if not plaine then
        for _, d in ipairs(eventCoinObj:GetDescendants()) do
            if string.lower(d.Name) == "plane" then
                plaine = d
                break
            end
        end
    end
    return plaine
end

local function rememberEvent(obj)
    if not obj or eventSeen[obj] then return nil end
    local kind = eventKind(obj.Name)
    if not kind then return nil end

    local targetObj = obj
    local pos = nil

    if kind == "candy" then
        local plaine = findCandyPlane(obj)
        if not plaine then
            return nil -- EventCoin sin Plane todavÃ­a
        end
        targetObj = plaine
        pos = objectPosition(plaine)
        if not pos then return nil end
        -- marcar vistos el EventCoin y el Plane para no repetir
        eventSeen[obj] = true
        eventSeen[plaine] = true
    else
        pos = objectPosition(obj)
        if not pos then return nil end
        eventSeen[obj] = true
    end

    if kind == "xp" then restoreKeycap(obj) end
    table.insert(eventQueue, {obj = targetObj, pos = pos, kind = kind})
    return pos
end


end

local function __hw_C()
local function eventButton(text, order)
    local b = Instance.new("TextButton")
    b.Parent = EventsPage
    b.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
    b.Size = UDim2.new(1, -10, 0, 32)
    b.Font = Enum.Font.GothamBold
    b.Text = text .. ": OFF"
    b.TextColor3 = Color3.fromRGB(255, 100, 100)
    b.TextSize = 12
    b.LayoutOrder = order
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    return b
end

local btnChocolate = eventButton("Auto Chocolate Hunt", 1)
local btnCandy = eventButton("Auto Candy Corn", 2)
local btnCoin = eventButton("Auto Battle Coin", 3)
local btnXp = eventButton("Auto XP Event Key", 4)

local function paintEvent(btn, on, label)
    btn.Text = label .. (on and ": ON" or ": OFF")
    btn.TextColor3 = on and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    btn.BackgroundColor3 = on and Color3.fromRGB(35, 60, 35) or Color3.fromRGB(26, 26, 34)
end

btnChocolate.MouseButton1Click:Connect(function()
    eventChocolate = not eventChocolate
    paintEvent(btnChocolate, eventChocolate, "Auto Chocolate Hunt")
end)
btnCandy.MouseButton1Click:Connect(function()
    eventCandy = not eventCandy
    paintEvent(btnCandy, eventCandy, "Auto Candy Corn")
end)
btnCoin.MouseButton1Click:Connect(function()
    eventCoin = not eventCoin
    paintEvent(btnCoin, eventCoin, "Auto Battle Coin")
end)
btnXp.MouseButton1Click:Connect(function()
    eventXp = not eventXp
    paintEvent(btnXp, eventXp, "Auto XP Event Key")
end)

task.spawn(function()
    local anchored = false
    local lastWide = 0
    local lastNear = 0
    while true do
        task.wait(0.1)
        local anyOn = eventChocolate or eventCandy or eventCoin or eventXp
        if not anyOn then
            anchored = false
            eventQueue = {}
            eventSeen = {}
        else
            local now = tick()
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                if not anchored and now - lastWide >= 1 then
                    lastWide = now
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if rememberEvent(obj) then break end
                    end
                    if #eventQueue > 0 then
                        local first = table.remove(eventQueue, 1)
                        local dest = first.pos + Vector3.new(0, 3, 0)
                        if eventCollectMode == "Tp" then
                            hrp.CFrame = CFrame.new(dest)
                            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        else
                            -- Tween con BodyVelocity hacia Plane / objetivo
                            local bv = Instance.new("BodyVelocity")
                            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                            bv.Parent = hrp
                            local t0 = tick()
                            while hrp and hrp.Parent and (hrp.Position - dest).Magnitude > 3 and tick() - t0 < 8 do
                                local d = (dest - hrp.Position)
                                if d.Magnitude > 0.05 then
                                    bv.Velocity = d.Unit * math.clamp(d.Magnitude * 8, 40, 250)
                                else
                                    bv.Velocity = Vector3.new()
                                end
                                RunService.Stepped:Wait()
                            end
                            if bv then bv:Destroy() end
                            if hrp then
                                hrp.CFrame = CFrame.new(dest)
                                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                            end
                        end
                        anchored = true
                    end
                elseif anchored and now - lastNear >= 0.3 then
                    lastNear = now
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        local pos = objectPosition(obj)
                        if pos and (pos - hrp.Position).Magnitude <= 100 then
                            rememberEvent(obj)
                        end
                    end
                    if #eventQueue > 0 then
                        local nextItem = eventQueue[1]
                        local pos = objectPosition(nextItem.obj) or nextItem.pos
                        if (hrp.Position - pos).Magnitude <= 4 then
                            table.remove(eventQueue, 1)
                        else
                            if eventCollectMode == "Tp" then
                                hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                                table.remove(eventQueue, 1)
                            else
                                local bv = hrp:FindFirstChild("DeltaEventBV")
                                if not bv then
                                    bv = Instance.new("BodyVelocity")
                                    bv.Name = "DeltaEventBV"
                                    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                    bv.Parent = hrp
                                end
                                local delta = pos - hrp.Position
                                if delta.Magnitude > 0.1 then
                                    local spd = math.clamp(gameSpeed or 250, 1, 500)
                                    bv.Velocity = delta.Unit * spd
                                end
                            end
                        end
                    else
                        local bv = hrp:FindFirstChild("DeltaEventBV")
                        if bv then bv:Destroy() end
                    end
                end
            end
        end
    end
end)


-- Helpers UI (fuera de buildHubUi para no saturar locals)
local function makeSwitch(parent, text, order)
    local row = Instance.new("Frame")
    row.Parent = parent
    row.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
    row.Size = UDim2.new(1, -8, 0, 36)
    row.LayoutOrder = order
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
    local label = Instance.new("TextLabel")
    label.Parent = row
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -58, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.Font = Enum.Font.GothamBold
    label.Text = text
    label.TextColor3 = Color3.fromRGB(240, 240, 245)
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    local hit = Instance.new("TextButton")
    hit.Parent = row
    hit.BackgroundColor3 = Color3.fromRGB(70, 70, 78)
    hit.Position = UDim2.new(1, -46, 0.5, -11)
    hit.Size = UDim2.new(0, 36, 0, 22)
    hit.Text = ""
    Instance.new("UICorner", hit).CornerRadius = UDim.new(1, 0)
    local knob = Instance.new("Frame")
    knob.Parent = hit
    knob.BackgroundColor3 = Color3.fromRGB(230, 230, 235)
    knob.Position = UDim2.new(0, 2, 0, 2)
    knob.Size = UDim2.new(0, 18, 0, 18)
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    local on = false
    local function paint()
        hit.BackgroundColor3 = on and Color3.fromRGB(70, 190, 90) or Color3.fromRGB(70, 70, 78)
        knob.Position = on and UDim2.new(1, -20, 0, 2) or UDim2.new(0, 2, 0, 2)
    end
    return row, function(state)
        on = state and true or false
        paint()
    end, function()
        return on
    end, hit
end

local function section(parent, title, order)
    local wrap = Instance.new("Frame")
    wrap.Parent = parent
    wrap.BackgroundTransparency = 1
    wrap.Size = UDim2.new(1, -8, 0, 34)
    wrap.AutomaticSize = Enum.AutomaticSize.Y
    wrap.LayoutOrder = order
    local head = Instance.new("TextButton")
    head.Parent = wrap
    head.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
    head.Size = UDim2.new(1, 0, 0, 32)
    head.Font = Enum.Font.GothamBold
    head.Text = "  >  " .. title
    head.TextColor3 = Color3.fromRGB(240, 240, 245)
    head.TextSize = 13
    head.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", head).CornerRadius = UDim.new(0, 6)
    local body = Instance.new("Frame")
    body.Parent = wrap
    body.BackgroundTransparency = 1
    body.Position = UDim2.new(0, 10, 0, 36)
    body.Size = UDim2.new(1, -10, 0, 0)
    body.AutomaticSize = Enum.AutomaticSize.Y
    body.Visible = false
    local layout = Instance.new("UIListLayout")
    layout.Parent = body
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    head.MouseButton1Click:Connect(function()
        body.Visible = not body.Visible
        head.Text = (body.Visible and "  v  " or "  >  ") .. title
    end)
    return body
end


local farmPage, playerNew, eventsNew, extrasPage

local function showPage(page, title)
    local farmPage = HW.farmPage or farmPage
    local playerNew = HW.playerNew or playerNew
    local eventsNew = HW.eventsNew or eventsNew
    local extrasPage = HW.extrasPage or extrasPage
    local SectionTitle = HW.SectionTitle or SectionTitle
    if farmPage then farmPage.Visible = false end
    if playerNew then playerNew.Visible = false end
    if eventsNew then eventsNew.Visible = false end
    if extrasPage then extrasPage.Visible = false end
    if page then page.Visible = true end
    if SectionTitle then
        SectionTitle.Visible = true
        SectionTitle.Text = title
    end
end

local function buildHubUi_Farm()
    local MainFrame = HW.MainFrame or MainFrame
    local ScreenGui = HW.ScreenGui or ScreenGui
    local ContentArea = HW.ContentArea or ContentArea
    local SectionTitle = HW.SectionTitle or SectionTitle
    local TabPlayerBtn = HW.TabPlayerBtn or TabPlayerBtn
    local TabGameBtn = HW.TabGameBtn or TabGameBtn
    local TabEventsBtn = HW.TabEventsBtn or TabEventsBtn
    local TabExtrasBtn = HW.TabExtrasBtn or TabExtrasBtn
    local Sidebar = HW.Sidebar or Sidebar
    local MinimizeBtn = HW.MinimizeBtn or MinimizeBtn
    HW._ui = HW._ui or {}
    if MainFrame then MainFrame.Visible = true end
    if ScreenGui then ScreenGui.Enabled = true end
    farmPage = createScrollingPage(ContentArea)
    HW.farmPage = farmPage
playerNew = createScrollingPage(ContentArea)
playerNew.Visible = false
eventsNew = createScrollingPage(ContentArea)
eventsNew.Visible = false
HW.playerNew = playerNew
HW.eventsNew = eventsNew



TabPlayerBtn.Text = "P"
TabGameBtn.Text = "F"
TabEventsBtn.Text = "E"
TabPlayerBtn.Visible = true
TabGameBtn.Visible = true
TabEventsBtn.Visible = true
Sidebar.Visible = true
TabExtrasBtn.Visible = false
if TabGameBtn then TabGameBtn.MouseButton1Click:Connect(function() showPage(farmPage, "Farm") end) end
if TabPlayerBtn then TabPlayerBtn.MouseButton1Click:Connect(function() showPage(playerNew, "Player") end) end
if TabEventsBtn then TabEventsBtn.MouseButton1Click:Connect(function() showPage(eventsNew, "Events") end) end
showPage(farmPage, "Farm")

local winsBody = section(farmPage, "Wins", 1)
if selectorMain then selectorMain.Visible = false selectorMain.Parent = nil end
local winHead = Instance.new("TextButton")
winHead.Name = "WinBlockSelector"
winHead.Parent = winsBody
winHead.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
winHead.Size = UDim2.new(1, -8, 0, 32)
winHead.Font = Enum.Font.GothamBold
winHead.Text = "  >  WinBlock: " .. selectedDisplayName
winHead.TextXAlignment = Enum.TextXAlignment.Left
winHead.TextColor3 = Color3.fromRGB(240, 240, 245)
winHead.TextSize = 13
winHead.LayoutOrder = 1
winHead.Active = true
winHead.AutoButtonColor = true
Instance.new("UICorner", winHead).CornerRadius = UDim.new(0, 6)
local winList = Instance.new("Frame")
winList.Name = "WinBlockList"
winList.Parent = winsBody
winList.BackgroundTransparency = 1
winList.Size = UDim2.new(1, -8, 0, 0)
winList.AutomaticSize = Enum.AutomaticSize.Y
winList.Visible = false
winList.LayoutOrder = 2
local winListLayout = Instance.new("UIListLayout")
winListLayout.Parent = winList
winListLayout.Padding = UDim.new(0, 4)
winListLayout.SortOrder = Enum.SortOrder.LayoutOrder
for _, info in ipairs(orderedWinBlocks) do
    local opt = Instance.new("TextButton")
    opt.Parent = winList
    opt.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
    opt.Size = UDim2.new(1, 0, 0, 28)
    opt.Font = Enum.Font.Gotham
    opt.Text = info.display
    opt.TextColor3 = Color3.fromRGB(240, 240, 245)
    opt.TextSize = 12
    opt.LayoutOrder = info.order
    opt.Active = true
    Instance.new("UICorner", opt).CornerRadius = UDim.new(0, 5)
    opt.MouseButton1Click:Connect(function()
        selectedRealName = info.real
        selectedDisplayName = info.display
        winHead.Text = "  >  WinBlock: " .. info.display
        winList.Visible = false
        showNotification("WinBlock: " .. info.display)
    end)
end
winHead.MouseButton1Click:Connect(function()
    winList.Visible = not winList.Visible
    winHead.Text = (winList.Visible and "  v  " or "  >  ") .. "WinBlock: " .. selectedDisplayName
    showNotification(winList.Visible and "Selector abierto" or "Selector cerrado")
end)
local _, setGoal, _, goalHit = makeSwitch(winsBody, "Meta de Wins", 8)
local goalBox = Instance.new("TextBox")
goalBox.Parent = winsBody
goalBox.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
goalBox.Size = UDim2.new(1, -8, 0, 30)
goalBox.Font = Enum.Font.Gotham
goalBox.PlaceholderText = "Wins a ganar (1 a 1000T)"
goalBox.Text = ""
goalBox.TextColor3 = Color3.fromRGB(255, 255, 255)
goalBox.TextSize = 12
goalBox.LayoutOrder = 9
Instance.new("UICorner", goalBox).CornerRadius = UDim.new(0, 6)
local goalInfo = Instance.new("TextLabel")
goalInfo.Parent = winsBody
goalInfo.BackgroundTransparency = 1
goalInfo.Size = UDim2.new(1, -8, 0, 18)
goalInfo.Font = Enum.Font.Gotham
goalInfo.Text = "Meta apagada"
goalInfo.TextColor3 = Color3.fromRGB(180, 180, 190)
goalInfo.TextSize = 11
goalInfo.TextXAlignment = Enum.TextXAlignment.Left
goalInfo.LayoutOrder = 10
goalBox.FocusLost:Connect(function()
    local raw = goalBox.Text:gsub(",", "")
    local value = parseWinAmount(raw)
    if value < 1 then value = 1 end
    if value > 1e15 then value = 1e15 end
    if goalSavedFor ~= value then
        goalProgress = 0
        goalSavedFor = value
    end
    goalAmount = value
    goalBox.Text = formatShort(value) .. " Wins"
    refreshGoal()
end)
goalHit.MouseButton1Click:Connect(function()
    goalEnabled = not goalEnabled
    setGoal(goalEnabled)
    if goalEnabled and goalAmount < 1 then
        goalAmount = 1
        goalSavedFor = 1
        goalBox.Text = "1 Wins"
    end
    refreshGoal()
end)
speedGameBox.Parent = winsBody
speedGameBox.LayoutOrder = 2
fastBtn.Parent = winsBody
fastBtn.LayoutOrder = 3
local modeInfo = Instance.new("TextLabel")
modeInfo.Parent = winsBody
modeInfo.BackgroundTransparency = 1
modeInfo.Size = UDim2.new(1, 0, 0, 48)
modeInfo.Font = Enum.Font.Gotham
modeInfo.Text = "Normal: slows to a stop. Fast: stays at 50. Super Fast: stays at 150."
modeInfo.TextColor3 = Color3.fromRGB(180, 180, 190)
modeInfo.TextSize = 11
modeInfo.TextWrapped = true
modeInfo.LayoutOrder = 4
startRouteBtn.Parent = winsBody
startRouteBtn.LayoutOrder = 5
startRouteBtn.Text = "Iniciar recorrido"
routeClickState = 0
startRouteBtn.MouseButton1Click:Connect(function()
    task.defer(function()
        if routeRunning and routeClickState == 0 then
            routeClickState = 1
            startRouteBtn.Text = "Terminar recorrido"
            startRouteBtn.TextColor3 = Color3.fromRGB(255, 220, 120)
            return
        end
        if routeClickState == 1 then
            finishAfterClaim = true
            routeClickState = 2
            startRouteBtn.Text = "Terminar ahora"
            showNotification("Sigue hasta el WinBlock y vuelve al spawn.")
        elseif routeClickState == 2 then
            stopRecorridoGeneral()
            routeClickState = 0
            startRouteBtn.Text = "Iniciar recorrido"
            startRouteBtn.TextColor3 = Color3.fromRGB(255, 120, 120)
        end
    end)
end)

local millBody = section(farmPage, "Autofunciones", 2)
local _, setMill, _, millHit = makeSwitch(millBody, "Auto Treadmill", 1)
local bestLabel = Instance.new("TextLabel")
bestLabel.Parent = millBody
bestLabel.BackgroundTransparency = 1
bestLabel.Size = UDim2.new(1, 0, 0, 22)
bestLabel.Font = Enum.Font.GothamBold
bestLabel.Text = "Best treadmill: --"
bestLabel.TextColor3 = Color3.fromRGB(255, 210, 80)
bestLabel.TextSize = 12
bestLabel.TextXAlignment = Enum.TextXAlignment.Left
bestLabel.Visible = false
bestLabel.LayoutOrder = 2
local autoMill = false
millHit.MouseButton1Click:Connect(function()
    autoMill = not autoMill
    setMill(autoMill)
    bestLabel.Visible = autoMill
    bestLabel.Text = treadmillLabel()
    if not autoMill then return end
    sendToBestTreadmill()
    task.spawn(function()
        local names = {Admin = "TreadmillAdmin", Candy = "TreadmillCandy", Diamond = "TreadmillDiamond", Gold = "TreadmillGold", Normal = "Treadmill"}
        while autoMill do
            local folder = treadmillFolder()
            local model = folder and folder:FindFirstChild(names[bestTreadmill] or "Treadmill")
            sendToBestTreadmill()
            task.wait(1)
        end
    end)
end)


local _, setMillWins, _, millWinsHit = makeSwitch(millBody, "Treadmill in wins", 3)
millWinsHit.MouseButton1Click:Connect(function()
    millWins = not millWins
    setMillWins(millWins)
    if not millWins then restoreConveyor() end
end)
local _, setRebirthEarly, _, rebirthHitEarly = makeSwitch(millBody, "Auto Rebirth", 4)
local rebirthOnEarly = false
rebirthHitEarly.MouseButton1Click:Connect(function()
    rebirthOnEarly = not rebirthOnEarly
    setRebirthEarly(rebirthOnEarly)
    if not rebirthOnEarly then return end
    task.spawn(function()
        while rebirthOnEarly do
            pcall(function()
                game:GetService("ReplicatedStorage").Remotes.Rebirth:FireServer()
            end)
            task.wait(1)
        end
    end)
end)
local millPick = Instance.new("TextButton")
millPick.Parent = millBody
millPick.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
millPick.Size = UDim2.new(1, -8, 0, 30)
millPick.Font = Enum.Font.GothamBold
millPick.Text = "  >  Treadmill: x1"
millPick.TextXAlignment = Enum.TextXAlignment.Left
millPick.TextColor3 = Color3.fromRGB(240, 240, 245)
millPick.TextSize = 12
millPick.LayoutOrder = 5
millPick.Active = true
Instance.new("UICorner", millPick).CornerRadius = UDim.new(0, 6)
local millList = Instance.new("Frame")
millList.Parent = millBody
millList.BackgroundTransparency = 1
millList.Size = UDim2.new(1, -8, 0, 0)
millList.AutomaticSize = Enum.AutomaticSize.Y
millList.Visible = false
millList.LayoutOrder = 6
local millLayout = Instance.new("UIListLayout")
millLayout.Parent = millList
millLayout.Padding = UDim.new(0, 4)
local millOptions = {
    {name = "Normal", label = "x1 Treadmill"},
    {name = "Gold", label = "x3 Gold"},
    {name = "Diamond", label = "x9 Diamond"},
    {name = "Candy", label = "x25 Candy"},
    {name = "Admin", label = "x100 Admin"},
}
for i, info in ipairs(millOptions) do
    local opt = Instance.new("TextButton")
    opt.Parent = millList
    opt.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
    opt.Size = UDim2.new(1, 0, 0, 26)
    opt.Font = Enum.Font.Gotham
    opt.Text = info.label
    opt.TextColor3 = Color3.fromRGB(240, 240, 245)
    opt.TextSize = 12
    opt.LayoutOrder = i
    Instance.new("UICorner", opt).CornerRadius = UDim.new(0, 5)
    opt.MouseButton1Click:Connect(function()
        bestTreadmill = info.name
        millPick.Text = "  >  Treadmill: " .. info.label
        millList.Visible = false
        bestLabel.Text = "Elegida: " .. info.label
        showNotification("Treadmill: " .. info.label)
    end)
end
millPick.MouseButton1Click:Connect(function()
    millList.Visible = not millList.Visible
    millPick.Text = (millList.Visible and "  v  " or "  >  ") .. millPick.Text:gsub("^%s*[v>]%s*", "")
end)


end

local function buildHubUi_PlayerEvents()
local moveBody = section(playerNew, "Movement", 1)
local function sliderRow(parent, title, order, minV, maxV, apply)
    local box = Instance.new("TextBox")
    box.Parent = parent
    box.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
    box.Size = UDim2.new(1, -8, 0, 28)
    box.Font = Enum.Font.Gotham
    box.Text = tostring(minV)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.TextSize = 12
    box.LayoutOrder = order
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
    local bar = Instance.new("TextButton")
    bar.Parent = parent
    bar.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
    bar.Size = UDim2.new(1, -8, 0, 18)
    bar.Text = title
    bar.Font = Enum.Font.Gotham
    bar.TextSize = 11
    bar.TextColor3 = Color3.fromRGB(220, 220, 225)
    bar.LayoutOrder = order + 1
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 6)
    local function setValue(v)
        v = math.clamp(tonumber(v) or minV, minV, maxV)
        box.Text = tostring(math.floor(v))
        apply(v)
    end
    box.FocusLost:Connect(function() setValue(box.Text) end)
    bar.MouseButton1Click:Connect(function()
        local x = game:GetService("UserInputService"):GetMouseLocation().X
        local rel = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
        setValue(minV + (maxV - minV) * rel)
    end)
end
local _, setSpeedOn, _, speedHit = makeSwitch(moveBody, "Speed", 1)
local speedValueBox = Instance.new("TextBox")
speedValueBox.Parent = moveBody
speedValueBox.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
speedValueBox.Size = UDim2.new(1, -8, 0, 28)
speedValueBox.Font = Enum.Font.Gotham
speedValueBox.Text = "16"
speedValueBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedValueBox.TextSize = 12
speedValueBox.LayoutOrder = 2
Instance.new("UICorner", speedValueBox).CornerRadius = UDim.new(0, 6)
speedValueBox.FocusLost:Connect(function()
    local v = tonumber(speedValueBox.Text)
    customSpeed = math.clamp(v or customSpeed or 16, 1, 1000)
    speedValueBox.Text = tostring(math.floor(customSpeed))
end)
speedHit.MouseButton1Click:Connect(function()
    local v = tonumber(speedValueBox.Text)
    customSpeed = math.clamp(v or customSpeed or 16, 1, 1000)
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if not speedEnabled then
        if hum then originalWalkSpeed = hum.WalkSpeed end
        speedEnabled = true
    else
        speedEnabled = false
        if hum and originalWalkSpeed then hum.WalkSpeed = originalWalkSpeed end
    end
    setSpeedOn(speedEnabled)
end)
local _, setJumpOn, _, jumpHit = makeSwitch(moveBody, "Jump", 3)
local jumpValueBox = Instance.new("TextBox")
jumpValueBox.Parent = moveBody
jumpValueBox.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
jumpValueBox.Size = UDim2.new(1, -8, 0, 28)
jumpValueBox.Font = Enum.Font.Gotham
jumpValueBox.Text = "50"
jumpValueBox.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpValueBox.TextSize = 12
jumpValueBox.LayoutOrder = 4
Instance.new("UICorner", jumpValueBox).CornerRadius = UDim.new(0, 6)
jumpValueBox.FocusLost:Connect(function()
    local v = tonumber(jumpValueBox.Text)
    customJump = math.clamp(v or customJump or 50, 1, 1000)
    jumpValueBox.Text = tostring(math.floor(customJump))
end)
jumpHit.MouseButton1Click:Connect(function()
    local v = tonumber(jumpValueBox.Text)
    customJump = math.clamp(v or customJump or 50, 1, 1000)
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if not jumpEnabled then
        if hum then originalUseJumpPower, originalJumpPower = hum.UseJumpPower, hum.JumpPower end
        jumpEnabled = true
    else
        jumpEnabled = false
        if hum then
            if originalUseJumpPower ~= nil then hum.UseJumpPower = originalUseJumpPower end
            if originalJumpPower ~= nil then hum.JumpPower = originalJumpPower end
        end
    end
    setJumpOn(jumpEnabled)
end)
local _, setJumpInf, _, infHit = makeSwitch(moveBody, "InfiniteJump", 5)
infHit.MouseButton1Click:Connect(function()
    infiniteJumpEnabled = not infiniteJumpEnabled
    setJumpInf(infiniteJumpEnabled)
    infJumpToggle.Text = infiniteJumpEnabled and "Infinitejump: ON" or "Infinitejump: OFF"
end)


local abuseBody = section(eventsNew, "Admin abuse", 1)
btnChocolate.Parent = abuseBody
btnCandy.Parent = abuseBody
btnCoin.Parent = abuseBody
btnXp.Parent = abuseBody
btnChocolate.LayoutOrder = 1
btnCandy.LayoutOrder = 2
btnCoin.LayoutOrder = 3
btnXp.LayoutOrder = 4

local dailyBody = section(eventsNew, "Daily", 2)
specialKeysToggle.Parent = dailyBody
specialKeysToggle.Size = UDim2.new(1, -8, 0, 32)
specialKeysToggle.Text = "Auto SpecialKeys: OFF"
specialKeysToggle.LayoutOrder = 1

local eventModePick = Instance.new("TextButton")
eventModePick.Parent = dailyBody
eventModePick.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
eventModePick.Size = UDim2.new(1, -8, 0, 30)
eventModePick.Font = Enum.Font.GothamBold
eventModePick.Text = "  >  Modo eventos: Tween"
eventModePick.TextXAlignment = Enum.TextXAlignment.Left
eventModePick.TextColor3 = Color3.fromRGB(240, 240, 245)
eventModePick.TextSize = 12
eventModePick.LayoutOrder = 2
eventModePick.Active = true
Instance.new("UICorner", eventModePick).CornerRadius = UDim.new(0, 6)

local eventModeList = Instance.new("Frame")
eventModeList.Parent = dailyBody
eventModeList.BackgroundTransparency = 1
eventModeList.Size = UDim2.new(1, -8, 0, 0)
eventModeList.AutomaticSize = Enum.AutomaticSize.Y
eventModeList.Visible = false
eventModeList.LayoutOrder = 3
local eventModeLayout = Instance.new("UIListLayout")
eventModeLayout.Parent = eventModeList
eventModeLayout.Padding = UDim.new(0, 4)

local eventModes = {"Tween", "Tp"}
for i, modeName in ipairs(eventModes) do
    local opt = Instance.new("TextButton")
    opt.Parent = eventModeList
    opt.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
    opt.Size = UDim2.new(1, 0, 0, 26)
    opt.Font = Enum.Font.Gotham
    opt.Text = modeName
    opt.TextColor3 = Color3.fromRGB(240, 240, 245)
    opt.TextSize = 12
    opt.LayoutOrder = i
    Instance.new("UICorner", opt).CornerRadius = UDim.new(0, 5)
    opt.MouseButton1Click:Connect(function()
        eventCollectMode = modeName
        eventModePick.Text = "  >  Modo eventos: " .. modeName
        eventModeList.Visible = false
        showNotification("Modo eventos: " .. modeName)
    end)
end
eventModePick.MouseButton1Click:Connect(function()
    eventModeList.Visible = not eventModeList.Visible
    eventModePick.Text = (eventModeList.Visible and "  v  " or "  >  ") .. "Modo eventos: " .. eventCollectMode
end)


MainFrame.BackgroundTransparency = 0.25
ContentArea.BackgroundTransparency = 1
dropdownList.Visible = false
skDropdown.Visible = false
dropdownList.Parent = winsBody
skDropdown.Parent = dailyBody
selectorBtn.MouseButton1Click:Connect(function()
    dropdownList.Visible = not dropdownList.Visible
end)


end

local function buildHubUi_Extras()
local MainFrame = HW.MainFrame or MainFrame
local ScreenGui = HW.ScreenGui or ScreenGui
local ContentArea = HW.ContentArea or ContentArea
local SectionTitle = HW.SectionTitle or SectionTitle
local TabPlayerBtn = HW.TabPlayerBtn or TabPlayerBtn
local TabGameBtn = HW.TabGameBtn or TabGameBtn
local TabEventsBtn = HW.TabEventsBtn or TabEventsBtn
local TabExtrasBtn = HW.TabExtrasBtn or TabExtrasBtn
local Sidebar = HW.Sidebar or Sidebar
local UIListSidebar = HW.UIListSidebar or UIListSidebar
local MinimizeBtn = HW.MinimizeBtn or MinimizeBtn
local farmPage = HW.farmPage or farmPage
local playerNew = HW.playerNew or playerNew
local eventsNew = HW.eventsNew or eventsNew
extrasPage = createScrollingPage(ContentArea)
extrasPage.Visible = false
HW.extrasPage = extrasPage
local configPage = createScrollingPage(ContentArea)
configPage.Visible = false
local tabNames = {
    {btn = TabGameBtn, name = "Farm", page = farmPage},
    {btn = TabPlayerBtn, name = "Player", page = playerNew},
    {btn = TabEventsBtn, name = "Events", page = eventsNew},
    {btn = TabExtrasBtn, name = "Extras", page = extrasPage},
}
if Sidebar and ScreenGui then Sidebar.Parent = ScreenGui end
local tabCount = #tabNames
local tabW, tabH, gap = 92, 42, 26
local stack = tabCount * tabH + (tabCount - 1) * gap
Sidebar.Size = UDim2.new(0, tabW, 0, stack)
Sidebar.Position = UDim2.new(0.5, -225 - tabW - 18, 0.5, -stack / 2)
UIListSidebar.Padding = UDim.new(0, gap)
for i, info in ipairs(tabNames) do
    info.btn.Parent = Sidebar
    info.btn.Size = UDim2.new(0, tabW, 0, tabH)
    info.btn.Text = info.name
    info.btn.Font = Enum.Font.GothamBold
    info.btn.TextSize = 14
    info.btn.BackgroundColor3 = Color3.fromRGB(170, 35, 35)
    info.btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    info.btn.LayoutOrder = i
    info.btn.Visible = true
    info.btn.MouseButton1Click:Connect(function()
        farmPage.Visible = false
        playerNew.Visible = false
        eventsNew.Visible = false
        extrasPage.Visible = false
        info.page.Visible = true
        SectionTitle.Text = info.name
    end)
end
TabExtrasBtn.Visible = true
if MinimizeBtn then
    MinimizeBtn.MouseButton1Click:Connect(function()
        if MainFrame then MainFrame.Visible = false end
        if Sidebar then Sidebar.Visible = false end
        if HW.FloatingLogo then HW.FloatingLogo.Visible = true end
        if ScreenGui then
            local panel = ScreenGui:FindFirstChild("WinPanel")
            if panel then panel.Visible = false end
        end
    end)
end

local antiBody = section(extrasPage, "Antilag", 1)
antilagToggle.Visible = false
local function deleteNamed(names)
    for _, obj in pairs(Workspace:GetDescendants()) do
        for _, name in ipairs(names) do
            if obj.Name == name then pcall(function() obj:Destroy() end) end
        end
    end
end

local antiDecoOn = false
local antiHallOn = false
local antiKeysOn = false

local _, setAntiDeco, _, antiDecoHit = makeSwitch(antiBody, "Anti Decorations", 1)
local _, setAntiHall, _, antiHallHit = makeSwitch(antiBody, "Anti Halloween", 2)
local _, setAntiKeys, _, antiKeysHit = makeSwitch(antiBody, "Anti KeyCaps", 3)

antiDecoHit.MouseButton1Click:Connect(function()
    antiDecoOn = not antiDecoOn
    setAntiDeco(antiDecoOn)
end)
antiHallHit.MouseButton1Click:Connect(function()
    antiHallOn = not antiHallOn
    setAntiHall(antiHallOn)
end)
antiKeysHit.MouseButton1Click:Connect(function()
    antiKeysOn = not antiKeysOn
    setAntiKeys(antiKeysOn)
end)

task.spawn(function()
    while true do
        task.wait(0.3)
        if antiDecoOn then
            deleteNamed({"Decorations", "Props"})
        end
        if antiHallOn then
            deleteNamed({"Halloween", "HallowenMeshes"})
        end
        if antiKeysOn then
            if hideKeycaps then hideKeycaps() end
        end
    end
end)

local screenBody = section(extrasPage, "Pantalla", 2)
local renderBody = screenBody
local _, setRender, _, renderHit = makeSwitch(renderBody, "No render", 1)
local colorRow = Instance.new("Frame")
colorRow.Parent = renderBody
colorRow.BackgroundTransparency = 1
colorRow.Size = UDim2.new(1, -8, 0, 28)
colorRow.Visible = false
colorRow.LayoutOrder = 2
local renderGui = Instance.new("ScreenGui")
renderGui.Name = "DeltaHubNoRender"
renderGui.Parent = playerGui
renderGui.ResetOnSpawn = false
renderGui.DisplayOrder = 1
renderGui.IgnoreGuiInset = true
local noRender = Instance.new("Frame")
noRender.Parent = renderGui
noRender.Size = UDim2.new(1, 0, 1, 0)
noRender.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
noRender.Visible = false
noRender.ZIndex = 1
noRender.Active = false
local renderOn = false
local renderWhite = true
local function paintRender()
    noRender.BackgroundColor3 = renderWhite and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0)
    noRender.Visible = renderOn
end
for _, name in ipairs({"Blanco", "Negro"}) do
    local b = Instance.new("TextButton")
    b.Parent = colorRow
    b.Size = UDim2.new(0, 70, 0, 24)
    b.Position = name == "Blanco" and UDim2.new(0, 0, 0, 0) or UDim2.new(0, 78, 0, 0)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 46)
    b.Font = Enum.Font.Gotham
    b.Text = name
    b.TextSize = 11
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.MouseButton1Click:Connect(function()
        renderWhite = name == "Blanco"
        paintRender()
    end)
end
renderHit.MouseButton1Click:Connect(function()
    renderOn = not renderOn
    setRender(renderOn)
    colorRow.Visible = renderOn
    paintRender()
end)

local _, setStats, _, statsHit = makeSwitch(screenBody, "Stats", 3)
local sessionStart = tick()
local function statCard(text, y)
    local f = Instance.new("TextLabel")
    f.Parent = ScreenGui
    f.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    f.BackgroundTransparency = 0.25
    f.Position = UDim2.new(0, 12, 0, y)
    f.Size = UDim2.new(0, 180, 0, 36)
    f.Font = Enum.Font.GothamBold
    f.Text = text
    f.TextColor3 = Color3.fromRGB(255, 255, 255)
    f.TextSize = 12
    f.Visible = false
    f.Active = true
    f.Draggable = true
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
    return f
end
local cardStats = statCard("Wins ruta: 0\nSesion: 0s\nSpecialKeys: 0 | Wins keys: 0", 80)
cardStats.Size = UDim2.new(0, 210, 0, 72)
cardStats.TextYAlignment = Enum.TextYAlignment.Top
local perfCard = Instance.new("TextLabel")
perfCard.Parent = ScreenGui
perfCard.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
perfCard.BackgroundTransparency = 0.2
perfCard.Position = UDim2.new(0, 8, 0, 8)
perfCard.Size = UDim2.new(0, 150, 0, 54)
perfCard.Font = Enum.Font.GothamBold
perfCard.Text = "FPS: --\nMS: --\nMB: --"
perfCard.TextColor3 = Color3.fromRGB(255, 255, 255)
perfCard.TextSize = 12
perfCard.TextYAlignment = Enum.TextYAlignment.Top
perfCard.Visible = false
perfCard.Active = true
perfCard.Draggable = true
Instance.new("UICorner", perfCard).CornerRadius = UDim.new(0, 6)
local statsGui = Instance.new("ScreenGui")
statsGui.Name = "DeltaHubStats"
statsGui.ResetOnSpawn = false
statsGui.DisplayOrder = 100000
statsGui.IgnoreGuiInset = true
pcall(function() statsGui.Parent = game:GetService("CoreGui") end)
if not statsGui.Parent then statsGui.Parent = playerGui end
cardStats.Parent = statsGui
perfCard.Parent = statsGui
local fpsFrames, fpsLast = 0, tick()
local statsOn = false
statsHit.MouseButton1Click:Connect(function()
    statsOn = not statsOn
    setStats(statsOn)
    cardStats.Visible = statsOn
    perfCard.Visible = statsOn
    if statsOn then
        for _, gui in ipairs(player:WaitForChild("PlayerGui"):GetChildren()) do
            if gui ~= ScreenGui and gui ~= renderGui and gui:IsA("ScreenGui") then gui.Enabled = false end
        end
    else
        for _, gui in ipairs(player:WaitForChild("PlayerGui"):GetChildren()) do
            if gui:IsA("ScreenGui") and gui ~= renderGui then gui.Enabled = true end
        end
    end
end)
task.spawn(function()
    while true do
        task.wait(1)
        if statsOn then
            cardStats.Text = "Wins ruta: " .. formatWins(routeWinsSession or 0)
                .. "\nSesion: " .. tostring(math.floor(tick() - sessionStart)) .. "s"
                .. "\nSpecialKeys: " .. tostring(specialKeyCount or 0)
                .. " | Wins keys: " .. formatWins(specialKeyWins or 0)
            fpsFrames = fpsFrames + 1
            local now = tick()
            if now - fpsLast >= 1 then
                local fps = math.floor(fpsFrames / (now - fpsLast))
                local ping = player:GetNetworkPing() * 1000
                local mb = 0
                pcall(function() mb = math.floor(stats().lua.mem / 1024) end)
                perfCard.Text = "FPS: " .. fps .. "\nMS: " .. math.floor(ping) .. "\nMB: " .. mb
                fpsFrames = 0
                fpsLast = now
            end
        end
    end
end)


local humNow = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
if humNow then
    customSpeed = humNow.WalkSpeed
    customJump = humNow.JumpPower
end


pcall(function()
    ScreenGui.Parent = playerGui
    ScreenGui.Enabled = true
    MainFrame.Visible = true
end)


local winPanel = Instance.new("Frame")
winPanel.Name = "WinPanel"
winPanel.Parent = ScreenGui
winPanel.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
winPanel.BackgroundTransparency = 0.08
winPanel.Position = UDim2.new(0.5, 235, 0.5, -150)
winPanel.Size = UDim2.new(0, 150, 0, 280)
winPanel.Visible = false
winPanel.ZIndex = 20
Instance.new("UICorner", winPanel).CornerRadius = UDim.new(0, 8)
local winTitle = Instance.new("TextLabel")
winTitle.Parent = winPanel
winTitle.BackgroundTransparency = 1
winTitle.Size = UDim2.new(1, 0, 0, 24)
winTitle.Font = Enum.Font.GothamBold
winTitle.Text = "WinBlocks"
winTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
winTitle.TextSize = 12
winTitle.ZIndex = 21
local winScroll = Instance.new("ScrollingFrame")
winScroll.Parent = winPanel
winScroll.BackgroundTransparency = 1
winScroll.Position = UDim2.new(0, 6, 0, 26)
winScroll.Size = UDim2.new(1, -12, 1, -32)
winScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
winScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
winScroll.ScrollBarThickness = 3
winScroll.ZIndex = 21
local winLayout = Instance.new("UIListLayout")
winLayout.Parent = winScroll
winLayout.Padding = UDim.new(0, 4)
winLayout.SortOrder = Enum.SortOrder.LayoutOrder
for _, info in ipairs(orderedWinBlocks) do
    local opt = Instance.new("TextButton")
    opt.Parent = winScroll
    opt.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
    opt.Size = UDim2.new(1, -4, 0, 24)
    opt.Font = Enum.Font.Gotham
    opt.Text = info.display
    opt.TextColor3 = Color3.fromRGB(240, 240, 245)
    opt.TextSize = 11
    opt.LayoutOrder = info.order
    opt.ZIndex = 22
    Instance.new("UICorner", opt).CornerRadius = UDim.new(0, 5)
    opt.MouseButton1Click:Connect(function()
        selectedRealName = info.real
        selectedDisplayName = info.display
        selectorBtn.Text = "Seleccionar Win: " .. info.display .. " â¾"
        if winChosenLabel then winChosenLabel.Text = "Win escogida: " .. info.display end
        winPanel.Visible = false
    end)
end
local function openWinPanel()
    dropdownList.Visible = false
    winPanel.Position = UDim2.new(MainFrame.Position.X.Scale, MainFrame.Position.X.Offset + MainFrame.Size.X.Offset + 12, MainFrame.Position.Y.Scale, MainFrame.Position.Y.Offset + 40)
    winPanel.Visible = not winPanel.Visible
end
selectorBtn.MouseButton1Click:Connect(openWinPanel)
selectorMain.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        openWinPanel()
    end
end)
MinimizeBtn.MouseButton1Click:Connect(function() winPanel.Visible = false end)

if boot then boot:Destroy() end
GamePage.Visible = false
PlayerPage.Visible = false
ExtrasPage.Visible = false
EventsPage.Visible = false
delayBox.Parent = winsBody
delayBox.LayoutOrder = 6
delayBox.PlaceholderText = "Retraso entre recorridos"
infRouteToggle.Parent = winsBody
infRouteToggle.LayoutOrder = 7
dropdownList.Parent = winsBody
dropdownList.LayoutOrder = 2
dropdownList.Visible = false
selectorBtn.MouseButton1Click:Connect(function()
    dropdownList.Visible = not dropdownList.Visible
end)
speedToggle.Visible = false
jumpToggle.Visible = false
noclipToggle.Visible = false
floatToggle.Visible = false
speedBox.Visible = false
jumpBox.Visible = false



local configTab = Instance.new("TextButton")
configTab.Parent = Sidebar
configTab.Size = UDim2.new(0, 92, 0, 42)
configTab.BackgroundColor3 = Color3.fromRGB(170, 35, 35)
configTab.Font = Enum.Font.GothamBold
configTab.Text = "Config"
configTab.TextColor3 = Color3.fromRGB(255, 255, 255)
configTab.TextSize = 14
configTab.LayoutOrder = 5
configTab.Visible = true
Instance.new("UICorner", configTab).CornerRadius = UDim.new(0, 6)
configTab.MouseButton1Click:Connect(function()
    farmPage.Visible = false
    playerNew.Visible = false
    eventsNew.Visible = false
    extrasPage.Visible = false
    configPage.Visible = true
    SectionTitle.Text = "Config"
end)
Sidebar.Size = UDim2.new(0, 92, 0, 5 * 42 + 4 * 26)
Sidebar.Position = UDim2.new(0.5, -225 - 92 - 18, 0.5, -(5 * 42 + 4 * 26) / 2)
configNameBox.Parent = configPage
saveConfigBtn.Parent = configPage
loadConfigBtn.Parent = configPage
autoConfigBtn.Parent = configPage
autoLoadBtn.Parent = configPage
configSelector.Parent = configPage
configList.Parent = configPage

local function buildWinSelectorDisabled()
    if selectorMain then selectorMain:Destroy() end
    if dropdownList then dropdownList:Destroy() end
    local panel = ScreenGui:FindFirstChild("WinPanel")
    if panel then panel:Destroy() end
    local wrap = Instance.new("Frame")
    wrap.Name = "WinSelectWrap"
    wrap.Parent = winsBody
    wrap.BackgroundTransparency = 1
    wrap.Size = UDim2.new(1, -8, 0, 32)
    wrap.AutomaticSize = Enum.AutomaticSize.Y
    wrap.LayoutOrder = 1
    local head = Instance.new("TextButton")
    head.Name = "WinSelectButton"
    head.Parent = wrap
    head.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
    head.Size = UDim2.new(1, 0, 0, 32)
    head.Font = Enum.Font.GothamBold
    head.Text = "  >  WinBlock: " .. selectedDisplayName
    head.TextXAlignment = Enum.TextXAlignment.Left
    head.TextColor3 = Color3.fromRGB(240, 240, 245)
    head.TextSize = 13
    head.Active = true
    head.AutoButtonColor = true
    Instance.new("UICorner", head).CornerRadius = UDim.new(0, 6)
    local list = Instance.new("Frame")
    list.Name = "WinSelectList"
    list.Parent = wrap
    list.BackgroundTransparency = 1
    list.Position = UDim2.new(0, 8, 0, 36)
    list.Size = UDim2.new(1, -8, 0, 0)
    list.AutomaticSize = Enum.AutomaticSize.Y
    list.Visible = false
    local layout = Instance.new("UIListLayout")
    layout.Parent = list
    layout.Padding = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    if speedGameBox then speedGameBox.LayoutOrder = 3 end
    if fastBtn then fastBtn.LayoutOrder = 4 end
    for _, info in ipairs(orderedWinBlocks) do
        local opt = Instance.new("TextButton")
        opt.Parent = list
        opt.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
        opt.Size = UDim2.new(1, 0, 0, 28)
        opt.Font = Enum.Font.Gotham
        opt.Text = info.display
        opt.TextColor3 = Color3.fromRGB(240, 240, 245)
        opt.TextSize = 12
        opt.LayoutOrder = info.order
        opt.Active = true
        opt.ZIndex = 6
        Instance.new("UICorner", opt).CornerRadius = UDim.new(0, 4)
        opt.MouseButton1Click:Connect(function()
            selectedRealName = info.real
            selectedDisplayName = info.display
            head.Text = "  >  WinBlock: " .. info.display
            list.Visible = false
            showNotification("Win: " .. info.display)
        end)
    end
    head.MouseButton1Click:Connect(function()
        list.Visible = not list.Visible
        head.Text = (list.Visible and "  v  " or "  >  ") .. "WinBlock: " .. selectedDisplayName
        showNotification(list.Visible and "Selector abierto" or "Selector cerrado")
    end)
end


    print("Delta Hub visible en PlayerGui")
end

local function buildHubUi()
    buildHubUi_Farm()
    buildHubUi_PlayerEvents()
    buildHubUi_Extras()
end
HW.buildHubUi = buildHubUi


task.defer(function()
    if boot then boot:Destroy() end
end)

end

local function __hw_run()
    local okA, errA = pcall(__hw_A)
    if not okA then warn("[HW] A: " .. tostring(errA)) error(errA) end
    local okB, errB = pcall(__hw_B)
    if not okB then warn("[HW] B: " .. tostring(errB)) error(errB) end
    local okC, errC = pcall(__hw_C)
    if not okC then warn("[HW] C: " .. tostring(errC)) error(errC) end
end
__hw_run()

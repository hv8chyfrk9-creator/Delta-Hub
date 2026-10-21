-- ==========================================
-- DELTA HUB - HALLOWEN WORLD
-- ==========================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
print("Delta Hub Hallowen world empezando")

local oldGui = playerGui:FindFirstChild("DeltaHubMinimal")
if oldGui then oldGui:Destroy() end
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaHubMinimal"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Enabled = true
ScreenGui.Parent = playerGui

local boot = Instance.new("TextLabel")
boot.Parent = ScreenGui
boot.Size = UDim2.new(0, 220, 0, 36)
boot.Position = UDim2.new(0.5, -110, 0, 40)
boot.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
boot.Text = "Hallowen world cargando"
boot.TextColor3 = Color3.fromRGB(255, 255, 255)
boot.Font = Enum.Font.GothamBold
boot.TextSize = 14
boot.ZIndex = 20

local function waitAliveHrp(returnCf)
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp and hum and hum.Health > 0 then
        return hrp
    end
    char = player.CharacterAdded:Wait()
    hrp = char:WaitForChild("HumanoidRootPart", 8)
    local newHum = char:WaitForChild("Humanoid", 8)
    task.wait(0.35)
    if hrp and returnCf then
        hrp.CFrame = returnCf
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end
    if newHum and newHum.Health <= 0 then
        return waitAliveHrp(returnCf)
    end
    return hrp
end

-- ==========================================
-- LIMPIEZA: nombres exactos + todo lo que empiece por "Pair"
-- ==========================================
local targetNamesToDestroy = {
    "ReversePad", "MeteorArea", "EyesLaser", "JumpWall", "Tsunami", "Tsunami1",
    "LavaTower", "Hitbox", "NPC20", "Laser", "NPC20_AttackZone",
    "TarantulaS13", "WindZonesS14"
}

local function runCleanupPass()
    for _, obj in pairs(Workspace:GetDescendants()) do
        local name = obj.Name
        for _, n in ipairs(targetNamesToDestroy) do
            if name == n then
                pcall(function() obj:Destroy() end)
            end
        end
        -- cualquier cosa que empiece por "Pair"
        if string.sub(name, 1, 4) == "Pair" then
            pcall(function() obj:Destroy() end)
        end
        local lowerName = string.lower(name)
        if lowerName == "lava" then
            pcall(function()
                for _, child in pairs(obj:GetChildren()) do
                    if child.ClassName == "TouchInterest" then child:Destroy() end
                end
                if obj:IsA("BasePart") then obj.CanTouch = false end
            end)
        end
    end
    pcall(function()
        local lavaStage = Workspace:FindFirstChild("Lava_Stage15", true)
        if lavaStage then
            local lc = lavaStage:FindFirstChild("LavaCollide", true)
            if lc then lc:Destroy() end
        end
    end)
end

runCleanupPass()

-- ==========================================
-- PANTALLA DE CARGA
-- ==========================================
local LoadingScreen = Instance.new("Frame")
LoadingScreen.Name = "LoadingScreen"
LoadingScreen.Parent = ScreenGui
LoadingScreen.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LoadingScreen.Position = UDim2.new(0, 0, 0, 0)
LoadingScreen.Size = UDim2.new(1, 0, 1, 0)
LoadingScreen.ZIndex = 10000

local LoadingText = Instance.new("TextLabel")
LoadingText.Parent = LoadingScreen
LoadingText.BackgroundTransparency = 1
LoadingText.Position = UDim2.new(0, 20, 0.35, 0)
LoadingText.Size = UDim2.new(1, -40, 0, 40)
LoadingText.Font = Enum.Font.GothamBold
LoadingText.Text = "Cargando activos..."
LoadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadingText.TextSize = 22
LoadingText.ZIndex = 10001

-- Selector de búsqueda de carga (2 / 3 / 5) — visible durante la carga
local loadSearchMode = "normal" -- normal=2, fast=3, ultra=5

local LoadModeFrame = Instance.new("Frame")
LoadModeFrame.Parent = LoadingScreen
LoadModeFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
LoadModeFrame.Position = UDim2.new(0.5, -140, 0.5, 10)
LoadModeFrame.Size = UDim2.new(0, 280, 0, 120)
LoadModeFrame.ZIndex = 10002
Instance.new("UICorner", LoadModeFrame).CornerRadius = UDim.new(0, 8)

local LoadModeTitle = Instance.new("TextLabel")
LoadModeTitle.Parent = LoadModeFrame
LoadModeTitle.BackgroundTransparency = 1
LoadModeTitle.Size = UDim2.new(1, 0, 0, 28)
LoadModeTitle.Font = Enum.Font.GothamBold
LoadModeTitle.Text = "Busqueda de limpieza"
LoadModeTitle.TextColor3 = Color3.fromRGB(240, 240, 245)
LoadModeTitle.TextSize = 13
LoadModeTitle.ZIndex = 10003

local function makeLoadBtn(text, mode, x)
    local b = Instance.new("TextButton")
    b.Parent = LoadModeFrame
    b.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
    b.Position = UDim2.new(0, x, 0, 40)
    b.Size = UDim2.new(0, 80, 0, 32)
    b.Font = Enum.Font.GothamBold
    b.Text = text
    b.TextColor3 = Color3.fromRGB(220, 220, 230)
    b.TextSize = 11
    b.ZIndex = 10003
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(function()
        loadSearchMode = mode
        for _, c in ipairs(LoadModeFrame:GetChildren()) do
            if c:IsA("TextButton") then
                c.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
            end
        end
        b.BackgroundColor3 = Color3.fromRGB(40, 100, 50)
    end)
    if mode == "normal" then b.BackgroundColor3 = Color3.fromRGB(40, 100, 50) end
    return b
end
makeLoadBtn("Normal 2", "normal", 12)
makeLoadBtn("Rapido 3", "fast", 100)
makeLoadBtn("Super 5", "ultra", 188)

local LoadHint = Instance.new("TextLabel")
LoadHint.Parent = LoadModeFrame
LoadHint.BackgroundTransparency = 1
LoadHint.Position = UDim2.new(0, 8, 0, 80)
LoadHint.Size = UDim2.new(1, -16, 0, 32)
LoadHint.Font = Enum.Font.Gotham
LoadHint.Text = "TP entre CFrames mientras limpia el mapa"
LoadHint.TextColor3 = Color3.fromRGB(160, 160, 175)
LoadHint.TextSize = 11
LoadHint.TextWrapped = true
LoadHint.ZIndex = 10003

local function loadStep()
    if loadSearchMode == "fast" then return 3 end
    if loadSearchMode == "ultra" then return 5 end
    return 2
end

local function showNotification(text)
    pcall(function()
        if ScreenGui:FindFirstChild("DeltaNotification") then
            ScreenGui.DeltaNotification:Destroy()
        end
        local notif = Instance.new("TextLabel")
        notif.Name = "DeltaNotification"
        notif.Parent = ScreenGui
        notif.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
        notif.Position = UDim2.new(0.5, -150, 0, 50)
        notif.Size = UDim2.new(0, 300, 0, 35)
        notif.Font = Enum.Font.GothamBold
        notif.Text = text
        notif.TextColor3 = Color3.fromRGB(100, 255, 100)
        notif.TextSize = 12
        Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 6)
        task.delay(3, function()
            if notif and notif.Parent then notif:Destroy() end
        end)
    end)
end

local FloatingLogo = Instance.new("TextButton")
FloatingLogo.Name = "FloatingLogo"
FloatingLogo.Parent = ScreenGui
FloatingLogo.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
FloatingLogo.Position = UDim2.new(0, 30, 0, 30)
FloatingLogo.Size = UDim2.new(0, 45, 0, 45)
FloatingLogo.Font = Enum.Font.GothamBold
FloatingLogo.Text = "HW"
FloatingLogo.TextColor3 = Color3.fromRGB(240, 240, 245)
FloatingLogo.TextSize = 15
FloatingLogo.Visible = false
FloatingLogo.Active = true
FloatingLogo.Draggable = true
Instance.new("UICorner", FloatingLogo).CornerRadius = UDim.new(1, 0)
local LogoStroke = Instance.new("UIStroke")
LogoStroke.Color = Color3.fromRGB(45, 45, 60)
LogoStroke.Thickness = 1
LogoStroke.Parent = FloatingLogo

local StopRouteContainer = Instance.new("Frame")
StopRouteContainer.Name = "StopRouteContainer"
StopRouteContainer.Parent = ScreenGui
StopRouteContainer.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
StopRouteContainer.Position = UDim2.new(1, -170, 0, 15)
StopRouteContainer.Size = UDim2.new(0, 155, 0, 35)
StopRouteContainer.Visible = false
Instance.new("UICorner", StopRouteContainer).CornerRadius = UDim.new(0, 6)

local StopRouteFloatingBtn = Instance.new("TextButton")
StopRouteFloatingBtn.Parent = StopRouteContainer
StopRouteFloatingBtn.BackgroundTransparency = 1
StopRouteFloatingBtn.Size = UDim2.new(1, -30, 1, 0)
StopRouteFloatingBtn.Font = Enum.Font.GothamBold
StopRouteFloatingBtn.Text = "Terminar Recorrido"
StopRouteFloatingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StopRouteFloatingBtn.TextSize = 11

local MinimizeRouteBtn = Instance.new("TextButton")
MinimizeRouteBtn.Parent = StopRouteContainer
MinimizeRouteBtn.BackgroundTransparency = 1
MinimizeRouteBtn.Position = UDim2.new(1, -30, 0, 0)
MinimizeRouteBtn.Size = UDim2.new(0, 30, 1, 0)
MinimizeRouteBtn.Font = Enum.Font.GothamBold
MinimizeRouteBtn.Text = "_"
MinimizeRouteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeRouteBtn.TextSize = 12

local routeMinimized = false
MinimizeRouteBtn.MouseButton1Click:Connect(function()
    routeMinimized = not routeMinimized
    if routeMinimized then
        StopRouteContainer.Size = UDim2.new(0, 155, 0, 20)
        StopRouteFloatingBtn.Visible = false
        MinimizeRouteBtn.Text = "+"
    else
        StopRouteContainer.Size = UDim2.new(0, 155, 0, 35)
        StopRouteFloatingBtn.Visible = true
        MinimizeRouteBtn.Text = "_"
    end
end)

local PromptContainer = Instance.new("Frame")
PromptContainer.Name = "PromptContainer"
PromptContainer.Parent = ScreenGui
PromptContainer.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
PromptContainer.Position = UDim2.new(0.5, -140, 0.4, -50)
PromptContainer.Size = UDim2.new(0, 280, 0, 95)
PromptContainer.Visible = false
Instance.new("UICorner", PromptContainer).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", PromptContainer).Color = Color3.fromRGB(60, 60, 80)

local PromptText = Instance.new("TextLabel")
PromptText.Parent = PromptContainer
PromptText.BackgroundTransparency = 1
PromptText.Position = UDim2.new(0, 10, 0, 10)
PromptText.Size = UDim2.new(1, -20, 0, 40)
PromptText.Font = Enum.Font.GothamBold
PromptText.Text = "¿Quieres retomar el recorrido?"
PromptText.TextColor3 = Color3.fromRGB(240, 240, 245)
PromptText.TextSize = 13
PromptText.TextWrapped = true

local YesBtn = Instance.new("TextButton")
YesBtn.Parent = PromptContainer
YesBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 60)
YesBtn.Position = UDim2.new(0.1, 0, 0.65, 0)
YesBtn.Size = UDim2.new(0, 100, 0, 28)
YesBtn.Font = Enum.Font.GothamBold
YesBtn.Text = "Sí"
YesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
YesBtn.TextSize = 12
Instance.new("UICorner", YesBtn).CornerRadius = UDim.new(0, 6)

local NoBtn = Instance.new("TextButton")
NoBtn.Parent = PromptContainer
NoBtn.BackgroundColor3 = Color3.fromRGB(140, 40, 40)
NoBtn.Position = UDim2.new(0.55, 0, 0.65, 0)
NoBtn.Size = UDim2.new(0, 100, 0, 28)
NoBtn.Font = Enum.Font.GothamBold
NoBtn.Text = "No"
NoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
NoBtn.TextSize = 12
Instance.new("UICorner", NoBtn).CornerRadius = UDim.new(0, 6)

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -175)
MainFrame.Size = UDim2.new(0, 450, 0, 350)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(35, 35, 48)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
TopBar.Size = UDim2.new(1, 0, 0, 35)
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)
local TopBarFix = Instance.new("Frame")
TopBarFix.Parent = TopBar
TopBarFix.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
TopBarFix.BorderSizePixel = 0
TopBarFix.Position = UDim2.new(0, 0, 1, -5)
TopBarFix.Size = UDim2.new(1, 0, 0, 5)

local Title = Instance.new("TextLabel")
Title.Parent = TopBar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Size = UDim2.new(0, 220, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "Hallowen world"
Title.TextColor3 = Color3.fromRGB(240, 240, 245)
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Parent = TopBar
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Position = UDim2.new(1, -35, 0, 0)
MinimizeBtn.Size = UDim2.new(0, 35, 1, 0)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(160, 160, 175)
MinimizeBtn.TextSize = 16

local Sidebar = Instance.new("Frame")
Sidebar.Parent = MainFrame
Sidebar.BackgroundTransparency = 1
Sidebar.Position = UDim2.new(0, 10, 0, 45)
Sidebar.Size = UDim2.new(0, 50, 1, -55)
local UIListSidebar = Instance.new("UIListLayout")
UIListSidebar.Parent = Sidebar
UIListSidebar.SortOrder = Enum.SortOrder.LayoutOrder
UIListSidebar.Padding = UDim.new(0, 8)
UIListSidebar.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function createLogoTab(name, symbol, order)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Parent = Sidebar
    btn.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
    btn.Size = UDim2.new(0, 38, 0, 38)
    btn.LayoutOrder = order
    btn.Text = symbol
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Color3.fromRGB(160, 160, 175)
    btn.TextSize = 16
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

local TabPlayerBtn = createLogoTab("TabPlayerBtn", "⚙", 1)
local TabGameBtn = createLogoTab("TabGameBtn", "⚡", 2)
local TabExtrasBtn = createLogoTab("TabExtrasBtn", "Ex", 3)
local TabEventsBtn = createLogoTab("TabEventsBtn", "E", 4)
TabPlayerBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
TabPlayerBtn.TextColor3 = Color3.fromRGB(240, 240, 245)

local ContentArea = Instance.new("Frame")
ContentArea.Parent = MainFrame
ContentArea.BackgroundTransparency = 1
ContentArea.Position = UDim2.new(0, 70, 0, 45)
ContentArea.Size = UDim2.new(1, -80, 1, -55)

local SectionTitle = Instance.new("TextLabel")
SectionTitle.Parent = ContentArea
SectionTitle.BackgroundTransparency = 1
SectionTitle.Size = UDim2.new(1, 0, 0, 25)
SectionTitle.Font = Enum.Font.GothamBold
SectionTitle.Text = "Player"
SectionTitle.TextColor3 = Color3.fromRGB(240, 240, 245)
SectionTitle.TextSize = 14
SectionTitle.TextXAlignment = Enum.TextXAlignment.Left

local function createScrollingPage(parent)
    local sf = Instance.new("ScrollingFrame")
    sf.Parent = parent
    sf.BackgroundTransparency = 1
    sf.Position = UDim2.new(0, 0, 0, 30)
    sf.Size = UDim2.new(1, 0, 1, -30)
    sf.CanvasSize = UDim2.new(0, 0, 0, 0)
    sf.ScrollBarThickness = 3
    sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local layout = Instance.new("UIListLayout")
    layout.Parent = sf
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    return sf
end

local PlayerPage = createScrollingPage(ContentArea)
local GamePage = createScrollingPage(ContentArea)
GamePage.Visible = false
local ExtrasPage = createScrollingPage(ContentArea)
ExtrasPage.Visible = false
local EventsPage = createScrollingPage(ContentArea)
EventsPage.Visible = false

-- PLAYER
local speedEnabled, customSpeed = false, 16
local originalWalkSpeed = nil
local jumpEnabled, customJump = false, 50
local originalJumpPower, originalUseJumpPower = nil, nil
local infiniteJumpEnabled, noClipEnabled = false, false

local speedBox = Instance.new("TextBox")
speedBox.Parent = PlayerPage
speedBox.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
speedBox.Size = UDim2.new(1, -10, 0, 32)
speedBox.Font = Enum.Font.Gotham
speedBox.PlaceholderText = "WalkSpeed"
speedBox.Text = "16"
speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBox.TextSize = 13
speedBox.LayoutOrder = 1
Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 6)
speedBox.FocusLost:Connect(function() local v = tonumber(speedBox.Text) if v then customSpeed = v end end)

local speedToggle = Instance.new("TextButton")
speedToggle.Parent = PlayerPage
speedToggle.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
speedToggle.Size = UDim2.new(1, -10, 0, 32)
speedToggle.Font = Enum.Font.GothamBold
speedToggle.Text = "WalkSpeed: OFF"
speedToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
speedToggle.TextSize = 12
speedToggle.LayoutOrder = 2
Instance.new("UICorner", speedToggle).CornerRadius = UDim.new(0, 6)
speedToggle.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if speedEnabled then
        if hum then originalWalkSpeed = hum.WalkSpeed end
        speedToggle.Text = "WalkSpeed: ON"
        speedToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
        speedToggle.BackgroundColor3 = Color3.fromRGB(35, 60, 35)
    else
        if hum and originalWalkSpeed then hum.WalkSpeed = originalWalkSpeed end
        speedToggle.Text = "WalkSpeed: OFF"
        speedToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
        speedToggle.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
    end
end)

local jumpBox = Instance.new("TextBox")
jumpBox.Parent = PlayerPage
jumpBox.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
jumpBox.Size = UDim2.new(1, -10, 0, 32)
jumpBox.Font = Enum.Font.Gotham
jumpBox.PlaceholderText = "JumpPower"
jumpBox.Text = "50"
jumpBox.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpBox.TextSize = 13
jumpBox.LayoutOrder = 3
Instance.new("UICorner", jumpBox).CornerRadius = UDim.new(0, 6)
jumpBox.FocusLost:Connect(function() local v = tonumber(jumpBox.Text) if v then customJump = v end end)

local jumpToggle = Instance.new("TextButton")
jumpToggle.Parent = PlayerPage
jumpToggle.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
jumpToggle.Size = UDim2.new(1, -10, 0, 32)
jumpToggle.Font = Enum.Font.GothamBold
jumpToggle.Text = "Salto: OFF"
jumpToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
jumpToggle.TextSize = 12
jumpToggle.LayoutOrder = 4
Instance.new("UICorner", jumpToggle).CornerRadius = UDim.new(0, 6)
jumpToggle.MouseButton1Click:Connect(function()
    jumpEnabled = not jumpEnabled
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if jumpEnabled then
        if hum then originalUseJumpPower, originalJumpPower = hum.UseJumpPower, hum.JumpPower end
        jumpToggle.Text = "Salto: ON"
        jumpToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
        jumpToggle.BackgroundColor3 = Color3.fromRGB(35, 60, 35)
    else
        if hum then
            if originalUseJumpPower ~= nil then hum.UseJumpPower = originalUseJumpPower end
            if originalJumpPower ~= nil then hum.JumpPower = originalJumpPower end
        end
        jumpToggle.Text = "Salto: OFF"
        jumpToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
        jumpToggle.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
    end
end)

local noclipToggle = Instance.new("TextButton")
noclipToggle.Parent = PlayerPage
noclipToggle.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
noclipToggle.Size = UDim2.new(1, -10, 0, 32)
noclipToggle.Font = Enum.Font.GothamBold
noclipToggle.Text = "Noclip: OFF"
noclipToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
noclipToggle.TextSize = 12
noclipToggle.LayoutOrder = 5
Instance.new("UICorner", noclipToggle).CornerRadius = UDim.new(0, 6)
noclipToggle.MouseButton1Click:Connect(function()
    noClipEnabled = not noClipEnabled
    noclipToggle.Text = noClipEnabled and "Noclip: ON" or "Noclip: OFF"
    noclipToggle.TextColor3 = noClipEnabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    noclipToggle.BackgroundColor3 = noClipEnabled and Color3.fromRGB(35, 60, 35) or Color3.fromRGB(26, 26, 34)
end)

local infJumpToggle = Instance.new("TextButton")
infJumpToggle.Parent = PlayerPage
infJumpToggle.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
infJumpToggle.Size = UDim2.new(1, -10, 0, 32)
infJumpToggle.Font = Enum.Font.GothamBold
infJumpToggle.Text = "Infinitejump: OFF"
infJumpToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
infJumpToggle.TextSize = 12
infJumpToggle.LayoutOrder = 6
Instance.new("UICorner", infJumpToggle).CornerRadius = UDim.new(0, 6)
infJumpToggle.MouseButton1Click:Connect(function()
    infiniteJumpEnabled = not infiniteJumpEnabled
    infJumpToggle.Text = infiniteJumpEnabled and "Infinitejump: ON" or "Infinitejump: OFF"
    infJumpToggle.TextColor3 = infiniteJumpEnabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    infJumpToggle.BackgroundColor3 = infiniteJumpEnabled and Color3.fromRGB(35, 60, 35) or Color3.fromRGB(26, 26, 34)
end)

UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled then
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- ==========================================
-- RUTA + WINBLOCKS
-- ==========================================
local routeCFrames = {
	CFrame.new(1.623040, 10.398061, -13.920989, -0.934023, -0.000000, -0.357212, -0.000000, 1.000000, -0.000000, 0.357212, -0.000000, -0.934023),
	CFrame.new(1.328639, 8.788770, 416.416351, 0.999983, 0.000000, 0.005818, 0.000000, 1.000000, 0.000000, -0.005818, 0.000000, 0.999983),
	CFrame.new(1.334663, 34.045326, 416.418365, 0.999391, -0.000000, 0.034901, 0.000000, 1.000000, -0.000000, -0.034901, 0.000000, 0.999391),
	CFrame.new(4.921404, 42.603218, 445.724701, 0.046265, -0.000000, -0.998929, -0.000000, 1.000000, -0.000000, 0.998929, 0.000000, 0.046265),
	CFrame.new(1.518666, 61.743050, 543.303711, -0.968935, -0.000000, -0.247317, -0.000000, 1.000000, 0.000000, 0.247317, 0.000000, -0.968935),
	CFrame.new(0.508362, 41.586567, 650.449402, -0.999735, 0.000565, -0.023007, 0.000000, 0.999698, 0.024563, 0.023014, 0.024556, -0.999434),
	CFrame.new(3.190791, 8.788770, 667.263855, -0.998473, -0.000000, -0.055242, -0.000000, 1.000000, 0.000000, 0.055242, 0.000000, -0.998473),
	CFrame.new(3.251352, 8.788770, 1014.258606, -0.355652, -0.000000, 0.934618, 0.000000, 1.000000, 0.000000, -0.934618, 0.000000, -0.355652),
	CFrame.new(3.183271, 8.788770, 1030.791382, -0.999894, -0.000000, 0.014541, 0.000000, 1.000000, 0.000000, -0.014541, 0.000000, -0.999894),
	CFrame.new(7.991629, 71.522957, 1033.016113, 0.020386, -0.000000, -0.999792, -0.000000, 1.000000, -0.000000, 0.999792, 0.000000, 0.020386),
	CFrame.new(18.879166, 76.514763, 1085.120117, 0.026123, -0.000000, -0.999659, -0.000000, 1.000000, -0.000000, 0.999659, 0.000000, 0.026123),
	CFrame.new(-454.361847, 60.137856, 1079.599487, -0.999793, -0.000000, -0.020356, -0.000000, 1.000000, -0.000000, 0.020356, -0.000000, -0.999793),
	CFrame.new(-468.674164, 8.788770, 1084.140503, -0.008667, -0.000000, 0.999962, -0.000000, 1.000000, 0.000000, -0.999962, -0.000000, -0.008667),
	CFrame.new(-815.567200, 8.788770, 1083.154663, -0.008667, -0.000000, 0.999962, -0.000000, 1.000000, 0.000000, -0.999962, -0.000000, -0.008667),
	CFrame.new(-1056.829712, 8.788770, 1084.603394, -0.037721, -0.000000, 0.999288, -0.000000, 1.000000, 0.000000, -0.999288, -0.000000, -0.037721),
	CFrame.new(-1402.226929, 8.788770, 1084.065796, -0.037721, -0.000000, 0.999288, -0.000000, 1.000000, 0.000000, -0.999288, -0.000000, -0.037721),
	CFrame.new(-2161.080322, 8.788774, 733.081970, 0.188105, -0.000000, -0.982149, 0.000000, 1.000000, -0.000000, 0.982149, -0.000000, 0.188105),
	CFrame.new(-2156.534180, -68.211243, 721.625671, 0.999961, -0.000000, 0.008789, 0.000000, 1.000000, 0.000000, -0.008789, -0.000000, 0.999961),
	CFrame.new(-2156.600098, -58.543758, 633.953918, 0.997350, -0.000000, 0.072752, 0.000000, 1.000000, 0.000000, -0.072752, -0.000000, 0.997350),
	CFrame.new(-2156.865479, -68.327751, 70.296646, 0.999311, -0.000000, 0.037110, 0.000000, 1.000000, 0.000000, -0.037110, -0.000000, 0.999311),
	CFrame.new(-2156.095459, -68.327744, -391.930389, 0.999968, -0.000000, 0.008057, 0.000000, 1.000000, 0.000000, -0.008057, -0.000000, 0.999968),
	CFrame.new(-2156.441650, -68.327744, -1504.536987, 0.999012, -0.000000, 0.044433, 0.000000, 1.000000, 0.000000, -0.044433, -0.000000, 0.999012),
	CFrame.new(-2156.089844, -68.327744, -3074.508789, 1.000000, -0.000000, 0.000244, 0.000000, 1.000000, 0.000000, -0.000244, -0.000000, 1.000000),
	CFrame.new(-2156.245117, -68.177750, -3093.002441, 0.998935, 0.000000, -0.046138, -0.000000, 1.000000, 0.000000, 0.046138, -0.000000, 0.998935),
	CFrame.new(-2155.937012, -109.038826, -3208.316406, 0.998608, 0.000000, 0.052738, -0.000000, 1.000000, 0.000000, -0.052738, -0.000000, 0.998608),
	CFrame.new(-2156.312744, -109.036713, -4646.407715, 1.000000, 0.000000, 0.000488, -0.000000, 1.000000, 0.000000, -0.000488, -0.000000, 1.000000),
	CFrame.new(-2155.341064, -109.036713, -5836.088379, 0.999828, 0.000000, 0.018551, -0.000000, 1.000000, 0.000000, -0.018551, -0.000000, 0.999828),
	CFrame.new(-2157.275635, 154.302475, -6171.383301, 0.999619, 0.000000, 0.027591, -0.000000, 1.000000, 0.000000, -0.027591, -0.000000, 0.999619)
}

local orderedWinBlocks = {
    {real = "WinBlock1", display = "+1 Win", order = 1},
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
    {real = "WinBlock12", display = "+10K Wins", order = 12},
    {real = "WinBlock13", display = "+25K Wins", order = 13},
    {real = "WinBlock14", display = "+50K Wins", order = 14},
    {real = "WinBlock15", display = "+150K Wins", order = 15},
}

local selectedRealName = "WinBlock1"
local selectedDisplayName = "+1 Win"
local gameSpeed = 250
-- Modo de RECORRIDO (velocidad mínima al llegar al CFrame): normal=0, fast=50, ultra=150
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
local finishAfterClaim = false
local routeWinsSession = 0
local winStreakBonus = 0
local goalEnabled = false
local goalAmount = 0
local goalProgress = 0
local specialKeysQueue = {}
local antilagActive = false
local autoSpecialKeysActive = false
local eventCollectMode = "Tween"

-- GAME UI
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
selectorBtn.Text = "Seleccionar Win: +1 Win ▾"
selectorBtn.TextColor3 = Color3.fromRGB(240, 240, 245)
selectorBtn.TextSize = 12

local dropdownList = Instance.new("ScrollingFrame")
dropdownList.Parent = GamePage
dropdownList.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
dropdownList.Size = UDim2.new(1, -10, 0, 140)
dropdownList.Visible = false
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
        selectorBtn.Text = "Seleccionar Win: " .. info.display .. " ▾"
        dropdownList.Visible = false
    end)
end
selectorBtn.MouseButton1Click:Connect(function()
    dropdownList.Visible = not dropdownList.Visible
end)

local startRouteBtn = Instance.new("TextButton")
startRouteBtn.Parent = GamePage
startRouteBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
startRouteBtn.Size = UDim2.new(1, -10, 0, 32)
startRouteBtn.Font = Enum.Font.GothamBold
startRouteBtn.Text = "Iniciar Recorrido"
startRouteBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
startRouteBtn.TextSize = 12
startRouteBtn.LayoutOrder = 3
Instance.new("UICorner", startRouteBtn).CornerRadius = UDim.new(0, 6)

local speedGameBox = Instance.new("TextBox")
speedGameBox.Parent = GamePage
speedGameBox.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
speedGameBox.Size = UDim2.new(1, -10, 0, 32)
speedGameBox.Font = Enum.Font.Gotham
speedGameBox.PlaceholderText = "Velocidad max (1-500)"
speedGameBox.Text = "250"
speedGameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedGameBox.TextSize = 13
speedGameBox.LayoutOrder = 4
Instance.new("UICorner", speedGameBox).CornerRadius = UDim.new(0, 6)
speedGameBox.FocusLost:Connect(function()
    gameSpeed = math.clamp(tonumber(speedGameBox.Text) or 250, 1, 500)
    speedGameBox.Text = tostring(gameSpeed)
end)

local delayBox = Instance.new("TextBox")
delayBox.Parent = GamePage
delayBox.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
delayBox.Size = UDim2.new(1, -10, 0, 32)
delayBox.Font = Enum.Font.Gotham
delayBox.PlaceholderText = "Delay entre recorridos"
delayBox.Text = "0"
delayBox.TextColor3 = Color3.fromRGB(255, 255, 255)
delayBox.TextSize = 13
delayBox.LayoutOrder = 5
Instance.new("UICorner", delayBox).CornerRadius = UDim.new(0, 6)
delayBox.FocusLost:Connect(function()
    delayTime = math.clamp(tonumber(delayBox.Text) or 0, 0, 10)
end)

local infRouteToggle = Instance.new("TextButton")
infRouteToggle.Parent = GamePage
infRouteToggle.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
infRouteToggle.Size = UDim2.new(1, -10, 0, 32)
infRouteToggle.Font = Enum.Font.GothamBold
infRouteToggle.Text = "Recorrido Infinito: OFF"
infRouteToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
infRouteToggle.TextSize = 12
infRouteToggle.LayoutOrder = 6
Instance.new("UICorner", infRouteToggle).CornerRadius = UDim.new(0, 6)
infRouteToggle.MouseButton1Click:Connect(function()
    infiniteRouteActive = not infiniteRouteActive
    infRouteToggle.Text = infiniteRouteActive and "Recorrido Infinito: ON" or "Recorrido Infinito: OFF"
    infRouteToggle.TextColor3 = infiniteRouteActive and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    infRouteToggle.BackgroundColor3 = infiniteRouteActive and Color3.fromRGB(35, 60, 35) or Color3.fromRGB(26, 26, 34)
end)

-- Modo RECORRIDO: mínimo de velocidad al llegar (0 / 50 / 150)
local fastBtn = Instance.new("TextButton")
fastBtn.Parent = GamePage
fastBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
fastBtn.Size = UDim2.new(1, -10, 0, 32)
fastBtn.Font = Enum.Font.GothamBold
fastBtn.Text = "Modo: Normal (min 0)"
fastBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
fastBtn.TextSize = 12
fastBtn.LayoutOrder = 7
Instance.new("UICorner", fastBtn).CornerRadius = UDim.new(0, 6)

local modeInfo = Instance.new("TextLabel")
modeInfo.Parent = GamePage
modeInfo.BackgroundTransparency = 1
modeInfo.Size = UDim2.new(1, -10, 0, 40)
modeInfo.Font = Enum.Font.Gotham
modeInfo.Text = "Normal: frena a 0. Rapido: min 50. Super: min 150. Siempre pasa por cada CFrame."
modeInfo.TextColor3 = Color3.fromRGB(160, 160, 175)
modeInfo.TextSize = 11
modeInfo.TextWrapped = true
modeInfo.LayoutOrder = 8

local function paintRouteMode()
    if routeMode == "fast" then
        fastBtn.Text = "Modo: Rapido (min 50)"
    elseif routeMode == "ultra" then
        fastBtn.Text = "Modo: Super rapido (min 150)"
    else
        fastBtn.Text = "Modo: Normal (min 0)"
    end
end
fastBtn.MouseButton1Click:Connect(function()
    if routeMode == "normal" then routeMode = "fast"
    elseif routeMode == "fast" then routeMode = "ultra"
    else routeMode = "normal" end
    paintRouteMode()
end)

local function formatWins(n)
    n = tonumber(n) or 0
    local units = {{1e12, "T"}, {1e9, "B"}, {1e6, "M"}, {1e3, "K"}}
    for _, u in ipairs(units) do
        if n >= u[1] then return string.format("%.2f%s", n / u[1], u[2]) end
    end
    return tostring(math.floor(n))
end

local function parseWinAmount(text)
    local n, suf = string.match(string.lower(text or ""), "([%d%.]+)%s*([kmbqt]?)")
    local value = tonumber(n) or 0
    local mult = {k = 1e3, m = 1e6, b = 1e9, t = 1e12, q = 1e15}
    if suf and mult[suf] then value = value * mult[suf] end
    return value
end

local WinsCounter = Instance.new("TextLabel")
WinsCounter.Parent = ScreenGui
WinsCounter.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
WinsCounter.Position = UDim2.new(1, -210, 0, 90)
WinsCounter.Size = UDim2.new(0, 195, 0, 36)
WinsCounter.Font = Enum.Font.GothamBold
WinsCounter.Text = "Wins ruta: 0"
WinsCounter.TextColor3 = Color3.fromRGB(255, 220, 80)
WinsCounter.TextSize = 11
WinsCounter.Visible = false
Instance.new("UICorner", WinsCounter).CornerRadius = UDim.new(0, 6)

local streakBlock = nil
local function addRouteWins()
    if streakBlock ~= selectedRealName then
        winStreakBonus = 0
        streakBlock = selectedRealName
    end
    local infoText = selectedDisplayName
    local base = parseWinAmount(infoText)
    local gain = base * (1 + winStreakBonus)
    routeWinsSession = routeWinsSession + gain
    if goalEnabled then goalProgress = goalProgress + gain end
    WinsCounter.Visible = true
    WinsCounter.Text = "Wins ruta: " .. formatWins(routeWinsSession) .. " | +" .. tostring(math.floor(winStreakBonus * 100)) .. "%"
    showNotification("+" .. formatWins(gain) .. " Wins")
    winStreakBonus = math.min(1, winStreakBonus + 0.1)
end

local function resetWinStreak()
    winStreakBonus = 0
    streakBlock = nil
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
    startRouteBtn.Text = "Iniciar Recorrido"
    startRouteBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
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
    showNotification("Sigue hasta el WinBlock")
end)
StopNowBtn.MouseButton1Click:Connect(function()
    stopRecorridoGeneral()
    showNotification("Recorrido detenido")
end)

-- EXTRAS: Antilag
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

function hideKeycaps()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if string.lower(obj.Name) == "keycaps" then
            for _, d in ipairs(obj:GetDescendants()) do
                if d:IsA("BasePart") then
                    pcall(function()
                        d.Transparency = 1
                        d.CanCollide = false
                        d.CanTouch = false
                        d.CanQuery = false
                    end)
                end
            end
        end
    end
end

antilagToggle.MouseButton1Click:Connect(function()
    antilagActive = not antilagActive
    if antilagActive then
        antilagToggle.Text = "Antilag: ON"
        antilagToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
        antilagToggle.BackgroundColor3 = Color3.fromRGB(35, 60, 35)
        pcall(function() Lighting.GlobalShadows = false; Lighting.Brightness = 2 end)
        hideKeycaps()
        for _, obj in pairs(Workspace:GetDescendants()) do
            for _, name in ipairs({"Decorations", "Props", "Halloween", "HallowenMeshes"}) do
                if obj.Name == name then pcall(function() obj:Destroy() end) end
            end
        end
    else
        antilagToggle.Text = "Antilag: OFF"
        antilagToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
        antilagToggle.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
    end
end)

task.spawn(function()
    while true do
        task.wait(0.3)
        if antilagActive then hideKeycaps() end
    end
end)

local function processSpecialKey(keyObj, hrp)
    if not keyObj or not keyObj.Parent or not hrp then return end
    local pos
    if keyObj:IsA("BasePart") then pos = keyObj.Position
    elseif keyObj:IsA("Model") and keyObj.PrimaryPart then pos = keyObj.PrimaryPart.Position
    else return end
    local origin = hrp.CFrame
    if eventCollectMode == "Tp" then
        hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
        task.wait(0.35)
        hrp.CFrame = origin
    else
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bv.Parent = hrp
        local t0 = tick()
        while (hrp.Position - pos).Magnitude > 3 and tick() - t0 < 6 do
            bv.Velocity = (pos - hrp.Position).Unit * 120
            RunService.Stepped:Wait()
        end
        bv:Destroy()
        task.wait(0.2)
        hrp.CFrame = origin
    end
end

-- ==========================================
-- FARM: siempre 1 CFrame en 1 (min speed por routeMode)
-- ==========================================
startRouteBtn.MouseButton1Click:Connect(function()
    if routeRunning then
        finishAfterClaim = true
        StopNowBtn.Visible = true
        StopRouteFloatingBtn.Text = "Terminara al WinBlock"
        return
    end
    gameSpeed = math.clamp(tonumber(speedGameBox.Text) or 250, 1, 500)
    routeRunning = true
    finishAfterClaim = false
    startRouteBtn.Text = "Terminar recorrido"
    startRouteBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
    startRouteBtn.BackgroundColor3 = Color3.fromRGB(35, 60, 35)
    StopRouteContainer.Visible = true
    noClipEnabled = true
    noclipToggle.Text = "Noclip: ON"
    noclipToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
    noclipToggle.BackgroundColor3 = Color3.fromRGB(35, 60, 35)

    task.spawn(function()
        while routeRunning do
            local char = player.Character or player.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart", 5)
            local hum = char:WaitForChild("Humanoid", 5)

            if hrp and hum and hum.Health > 0 then
                local oldBv = hrp:FindFirstChildOfClass("BodyVelocity")
                if oldBv then oldBv:Destroy() end
                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Velocity = Vector3.new()
                bv.Parent = hrp

                hrp.CFrame = routeCFrames[1]
                hrp.AssemblyLinearVelocity = Vector3.new()

                local targetObject = nil
                local closestIndex = #routeCFrames
                task.spawn(function()
                    while routeRunning and hum.Health > 0 and not targetObject do
                        targetObject = Workspace:FindFirstChild(selectedRealName, true)
                        if targetObject and (targetObject:IsA("BasePart") or (targetObject:IsA("Model") and targetObject.PrimaryPart)) then
                            local objPos = targetObject.Position or targetObject:GetPrimaryPartCFrame().Position
                            local best = math.huge
                            for idx, cf in ipairs(routeCFrames) do
                                local d = (cf.Position - objPos).Magnitude
                                if d < best then best = d; closestIndex = idx end
                            end
                            break
                        end
                        task.wait(1)
                    end
                end)

                local currentIndex = 2
                while currentIndex <= #routeCFrames and routeRunning and hum.Health > 0 do
                    if currentIndex > closestIndex then break end
                    local targetPos = routeCFrames[currentIndex].Position
                    while hrp and (hrp.Position - targetPos).Magnitude > 1 and routeRunning and hum.Health > 0 do
                        local dist = (hrp.Position - targetPos).Magnitude
                        local nextCf = routeCFrames[currentIndex + 1]
                        local spd = approachSpeed(dist, nextCf and (nextCf.Position - targetPos).Magnitude)
                        if dist > 0.05 then
                            bv.Velocity = (targetPos - hrp.Position).Unit * spd
                        else
                            bv.Velocity = Vector3.new()
                        end
                        RunService.Stepped:Wait()
                    end
                    if hrp and routeRunning then
                        bv.Velocity = Vector3.new()
                        hrp.CFrame = routeCFrames[currentIndex]
                        hrp.AssemblyLinearVelocity = Vector3.new()
                    end
                    currentIndex = currentIndex + 1
                end

                while not targetObject and routeRunning and hum.Health > 0 do
                    targetObject = Workspace:FindFirstChild(selectedRealName, true)
                    task.wait(0.5)
                end

                if targetObject and routeRunning and hum.Health > 0 then
                    local objPos = targetObject.Position or targetObject:GetPrimaryPartCFrame().Position
                    while hrp and (hrp.Position - objPos).Magnitude > 4 and routeRunning and hum.Health > 0 do
                        objPos = targetObject.Position or targetObject:GetPrimaryPartCFrame().Position
                        bv.Velocity = (objPos - hrp.Position).Unit * approachSpeed((objPos - hrp.Position).Magnitude)
                        RunService.Stepped:Wait()
                    end
                    bv.Velocity = Vector3.new()
                end

                if bv then bv:Destroy() end

                if routeRunning and hum.Health > 0 then
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
                    connYes = YesBtn.MouseButton1Click:Connect(function()
                        choice = true; connYes:Disconnect(); connNo:Disconnect()
                    end)
                    connNo = NoBtn.MouseButton1Click:Connect(function()
                        choice = false; connYes:Disconnect(); connNo:Disconnect()
                    end)
                    while choice == nil and routeRunning do task.wait(0.2) end
                    PromptContainer.Visible = false
                    if choice == true then
                        local c = player.Character or player.CharacterAdded:Wait()
                        task.wait(0.4)
                        local hrpNow = c and c:FindFirstChild("HumanoidRootPart")
                        if hrpNow then
                            hrpNow.CFrame = routeCFrames[1]
                            hrpNow.AssemblyLinearVelocity = Vector3.new()
                        end
                    else
                        stopRecorridoGeneral()
                        break
                    end
                end
            end

            local goalStill = goalEnabled and not infiniteRouteActive and goalProgress < goalAmount
            if finishAfterClaim or (not infiniteRouteActive and not goalStill) then
                stopRecorridoGeneral()
                break
            end
        end
    end)
end)

-- Events
local eventChocolate, eventCandy, eventCoin, eventXp = false, false, false, false

local function eventToggle(parent, text, order, get, set)
    local b = Instance.new("TextButton")
    b.Parent = parent
    b.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
    b.Size = UDim2.new(1, -10, 0, 32)
    b.Font = Enum.Font.GothamBold
    b.Text = text .. ": OFF"
    b.TextColor3 = Color3.fromRGB(255, 100, 100)
    b.TextSize = 12
    b.LayoutOrder = order
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(function()
        local on = not get()
        set(on)
        b.Text = text .. (on and ": ON" or ": OFF")
        b.TextColor3 = on and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
        b.BackgroundColor3 = on and Color3.fromRGB(35, 60, 35) or Color3.fromRGB(26, 26, 34)
    end)
end

eventToggle(EventsPage, "Auto Chocolate", 1, function() return eventChocolate end, function(v) eventChocolate = v end)
eventToggle(EventsPage, "Auto Candy Corn", 2, function() return eventCandy end, function(v) eventCandy = v end)
eventToggle(EventsPage, "Auto BattleCoin", 3, function() return eventCoin end, function(v) eventCoin = v end)
eventToggle(EventsPage, "Auto XP Key", 4, function() return eventXp end, function(v) eventXp = v end)

local skToggle = Instance.new("TextButton")
skToggle.Parent = EventsPage
skToggle.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
skToggle.Size = UDim2.new(1, -10, 0, 32)
skToggle.Font = Enum.Font.GothamBold
skToggle.Text = "Auto SpecialKeys: OFF"
skToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
skToggle.TextSize = 12
skToggle.LayoutOrder = 5
Instance.new("UICorner", skToggle).CornerRadius = UDim.new(0, 6)
skToggle.MouseButton1Click:Connect(function()
    autoSpecialKeysActive = not autoSpecialKeysActive
    skToggle.Text = autoSpecialKeysActive and "Auto SpecialKeys: ON" or "Auto SpecialKeys: OFF"
    skToggle.TextColor3 = autoSpecialKeysActive and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    skToggle.BackgroundColor3 = autoSpecialKeysActive and Color3.fromRGB(35, 60, 35) or Color3.fromRGB(26, 26, 34)
end)

task.spawn(function()
    while true do
        task.wait(1)
        if not (eventChocolate or eventCandy or eventCoin or eventXp or autoSpecialKeysActive) then continue end
        if routeRunning then continue end
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        for _, obj in pairs(Workspace:GetDescendants()) do
            local n = string.lower(obj.Name)
            local hit = false
            if eventChocolate and n:find("chocolatehunt") then hit = true end
            if eventCoin and n:find("coinbattlecoin") then hit = true end
            if eventXp and n:find("electrifiedkeycap") then hit = true end
            if eventCandy and n:find("eventcoin") and obj.Parent and obj.Parent.Name == "EventCoinsLocal" then hit = true end
            if autoSpecialKeysActive and obj.Name:find("SpecialKey") then hit = true end
            if hit and (obj:IsA("BasePart") or (obj:IsA("Model") and obj.PrimaryPart)) then
                processSpecialKey(obj, hrp)
                break
            end
        end
    end
end)

-- Navegación
local function setHubOpen(open)
    MainFrame.Visible = open
    FloatingLogo.Visible = not open
end
MinimizeBtn.MouseButton1Click:Connect(function() setHubOpen(false) end)
FloatingLogo.MouseButton1Click:Connect(function() setHubOpen(true) end)

local function showPage(page, title)
    PlayerPage.Visible = false
    GamePage.Visible = false
    ExtrasPage.Visible = false
    EventsPage.Visible = false
    page.Visible = true
    SectionTitle.Text = title
end
TabPlayerBtn.MouseButton1Click:Connect(function() showPage(PlayerPage, "Player") end)
TabGameBtn.MouseButton1Click:Connect(function() showPage(GamePage, "Farm") end)
TabExtrasBtn.MouseButton1Click:Connect(function() showPage(ExtrasPage, "Extras") end)
TabEventsBtn.MouseButton1Click:Connect(function() showPage(EventsPage, "Events") end)

RunService.Stepped:Connect(function()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        if speedEnabled then hum.WalkSpeed = customSpeed end
        if jumpEnabled then hum.UseJumpPower = true; hum.JumpPower = customJump end
    end
    if noClipEnabled then
        for _, p in pairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

-- ==========================================
-- CARGA: TP 2/3/5 + limpieza (Pair*, etc.)
-- ==========================================
task.spawn(function()
    if getgenv and getgenv().DeltaHubSkipAssets then
        if LoadingScreen then LoadingScreen:Destroy() end
        if boot then boot:Destroy() end
        MainFrame.Visible = true
        return
    end

    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart", 10)
    if not hrp then
        if LoadingScreen then LoadingScreen:Destroy() end
        if boot then boot:Destroy() end
        MainFrame.Visible = true
        return
    end

    -- da tiempo a elegir Normal 2 / Rapido 3 / Super 5
    task.wait(1.2)
    local step = loadStep()
    local i = 1
    while i <= #routeCFrames do
        pcall(function()
            hrp.CFrame = routeCFrames[i]
            hrp.AssemblyLinearVelocity = Vector3.new()
        end)
        runCleanupPass()
        if LoadingText then
            LoadingText.Text = "Limpieza " .. tostring(i) .. "/" .. tostring(#routeCFrames) .. " (paso " .. tostring(step) .. ")"
        end
        task.wait(0.12)
        step = loadStep() -- por si el jugador cambió el modo a mitad
        i = i + step
    end

    pcall(function()
        hrp.CFrame = routeCFrames[1]
        hrp.AssemblyLinearVelocity = Vector3.new()
    end)
    if LoadingText then LoadingText.Text = "Listo" end
    task.wait(0.35)
    if LoadingScreen and LoadingScreen.Parent then LoadingScreen:Destroy() end
    if boot then boot:Destroy() end
    MainFrame.Visible = true
    print("Hallowen world listo")
end)
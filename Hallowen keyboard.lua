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

-- Solo este PlaceId (Hallowen), salvo force
local HALLOWEEN_PLACE_ID = 128614435234859
if game.PlaceId ~= HALLOWEEN_PLACE_ID and not (getgenv and getgenv().DeltaHubForceLoad) then
    warn("[Delta Hub] Hallowen world: PlaceId incorrecto (" .. tostring(game.PlaceId) .. "). Esperado 128614435234859. Usa getgenv().DeltaHubForceLoad = true para forzar.")
    return
end

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
-- 0. DATOS DE LIMPIEZA (se ejecuta en fase 3 de carga)
-- ==========================================
local targetNamesToDestroy = {
    "TarantulaS13", "WindZonesS14", "Lava_Stage15",
    "MovingWallsS6", "EyeLaserStage10", "Zone", "TwompsS7"
}

local function runExactCleanup()
    for _, obj in pairs(Workspace:GetDescendants()) do
        local name = obj.Name
        for _, n in ipairs(targetNamesToDestroy) do
            if name == n then
                pcall(function() obj:Destroy() end)
            end
        end
    end
end



-- ==========================================
-- PANTALLA DE CARGA 0-100% (bloquea UI hasta el final)
-- ==========================================
local scriptReady = false
local LoadingScreen = Instance.new("Frame")
LoadingScreen.Name = "LoadingScreen"
LoadingScreen.Parent = ScreenGui
LoadingScreen.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LoadingScreen.Position = UDim2.new(0, 0, 0, 0)
LoadingScreen.Size = UDim2.new(1, 0, 1, 0)
LoadingScreen.ZIndex = 10000
LoadingScreen.Active = true -- bloquea clicks debajo

local LoadingText = Instance.new("TextLabel")
LoadingText.Parent = LoadingScreen
LoadingText.BackgroundTransparency = 1
LoadingText.Position = UDim2.new(0.1, 0, 0.38, 0)
LoadingText.Size = UDim2.new(0.8, 0, 0, 28)
LoadingText.Font = Enum.Font.GothamBold
LoadingText.Text = "Hallowen world cargando..."
LoadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadingText.TextSize = 20
LoadingText.ZIndex = 10001

local LoadingSub = Instance.new("TextLabel")
LoadingSub.Parent = LoadingScreen
LoadingSub.BackgroundTransparency = 1
LoadingSub.Position = UDim2.new(0.1, 0, 0.44, 0)
LoadingSub.Size = UDim2.new(0.8, 0, 0, 22)
LoadingSub.Font = Enum.Font.Gotham
LoadingSub.Text = "Fase 1/3"
LoadingSub.TextColor3 = Color3.fromRGB(180, 180, 190)
LoadingSub.TextSize = 14
LoadingSub.ZIndex = 10001

local BarBg = Instance.new("Frame")
BarBg.Parent = LoadingScreen
BarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
BarBg.Position = UDim2.new(0.15, 0, 0.52, 0)
BarBg.Size = UDim2.new(0.7, 0, 0, 18)
BarBg.ZIndex = 10001
Instance.new("UICorner", BarBg).CornerRadius = UDim.new(0, 8)

local BarFill = Instance.new("Frame")
BarFill.Parent = BarBg
BarFill.BackgroundColor3 = Color3.fromRGB(80, 160, 255)
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.ZIndex = 10002
Instance.new("UICorner", BarFill).CornerRadius = UDim.new(0, 8)

local PctLabel = Instance.new("TextLabel")
PctLabel.Parent = LoadingScreen
PctLabel.BackgroundTransparency = 1
PctLabel.Position = UDim2.new(0.15, 0, 0.56, 0)
PctLabel.Size = UDim2.new(0.7, 0, 0, 20)
PctLabel.Font = Enum.Font.GothamBold
PctLabel.Text = "0%"
PctLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
PctLabel.TextSize = 14
PctLabel.ZIndex = 10001

local CleanChoiceFrame = Instance.new("Frame")
CleanChoiceFrame.Parent = LoadingScreen
CleanChoiceFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
CleanChoiceFrame.Position = UDim2.new(0.15, 0, 0.62, 0)
CleanChoiceFrame.Size = UDim2.new(0.7, 0, 0, 120)
CleanChoiceFrame.Visible = false
CleanChoiceFrame.ZIndex = 10001
Instance.new("UICorner", CleanChoiceFrame).CornerRadius = UDim.new(0, 10)

local CleanTitle = Instance.new("TextLabel")
CleanTitle.Parent = CleanChoiceFrame
CleanTitle.BackgroundTransparency = 1
CleanTitle.Size = UDim2.new(1, 0, 0, 28)
CleanTitle.Font = Enum.Font.GothamBold
CleanTitle.Text = "Tipo de limpieza inicial"
CleanTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
CleanTitle.TextSize = 14
CleanTitle.ZIndex = 10002

local function makeCleanBtn(text, order, color)
    local b = Instance.new("TextButton")
    b.Parent = CleanChoiceFrame
    b.BackgroundColor3 = color
    b.Position = UDim2.new(0.05, 0, 0, 28 + (order - 1) * 30)
    b.Size = UDim2.new(0.9, 0, 0, 26)
    b.Font = Enum.Font.GothamBold
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextSize = 12
    b.ZIndex = 10002
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    return b
end
local btnCleanNormal = makeCleanBtn("Limpieza Normal (ruta Normal)", 1, Color3.fromRGB(40, 100, 55))
local btnCleanFast = makeCleanBtn("Limpieza Rapida (ruta Fast)", 2, Color3.fromRGB(40, 80, 140))
local btnCleanSuper = makeCleanBtn("Limpieza Super rapida (ruta Super)", 3, Color3.fromRGB(120, 60, 140))

local loadProgress = 0
local function setProgress(p, title, sub)
    loadProgress = math.clamp(p, 0, 100)
    BarFill.Size = UDim2.new(loadProgress / 100, 0, 1, 0)
    PctLabel.Text = string.format("%d%%", math.floor(loadProgress + 0.5))
    if title then LoadingText.Text = title end
    if sub then LoadingSub.Text = sub end
end

local function fadeAndDestroyLoading()
    setProgress(100, "Listo", "Iniciando...")
    local t0 = tick()
    while tick() - t0 < 1 do
        local a = (tick() - t0) / 1
        LoadingScreen.BackgroundTransparency = a
        LoadingText.TextTransparency = a
        LoadingSub.TextTransparency = a
        PctLabel.TextTransparency = a
        BarBg.BackgroundTransparency = a
        BarFill.BackgroundTransparency = a
        task.wait()
    end
    if LoadingScreen and LoadingScreen.Parent then LoadingScreen:Destroy() end
    scriptReady = true
end



-- ==========================================
-- SISTEMA DE NOTIFICACIONES INTERNAS
-- ==========================================
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

-- ==========================================
-- LOGO FLOTANTE MINIMALISTA (MOVIBLE)
-- ==========================================
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

local LogoCorner = Instance.new("UICorner")
LogoCorner.CornerRadius = UDim.new(1, 0)
LogoCorner.Parent = FloatingLogo

local LogoStroke = Instance.new("UIStroke")
LogoStroke.Color = Color3.fromRGB(45, 45, 60)
LogoStroke.Thickness = 1
LogoStroke.Parent = FloatingLogo

-- ==========================================
-- PANEL FLOTANTE SUPERIOR DERECHA: TERMINAR RECORRIDO (CON MINIMIZAR)
-- ==========================================
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

-- ==========================================
-- VENTANA DE PREGUNTA AL MORIR (SÃ / NO)
-- ==========================================
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
PromptText.Text = "Â¿Quieres retomar el recorrido?"
PromptText.TextColor3 = Color3.fromRGB(240, 240, 245)
PromptText.TextSize = 13
PromptText.TextWrapped = true

local YesBtn = Instance.new("TextButton")
YesBtn.Parent = PromptContainer
YesBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 60)
YesBtn.Position = UDim2.new(0.1, 0, 0.65, 0)
YesBtn.Size = UDim2.new(0, 100, 0, 28)
YesBtn.Font = Enum.Font.GothamBold
YesBtn.Text = "SÃ­"
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

-- ==========================================
-- VENTANA PRINCIPAL
-- ==========================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -175)
MainFrame.Size = UDim2.new(0, 450, 0, 350)
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(35, 35, 48)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- ==========================================
-- BARRA SUPERIOR
-- ==========================================
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
TopBar.Size = UDim2.new(1, 0, 0, 35)

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 8)
TopBarCorner.Parent = TopBar

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
Title.Size = UDim2.new(0, 200, 1, 0)
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

-- ==========================================
-- BARRA LATERAL
-- ==========================================
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
UIListSidebar.VerticalAlignment = Enum.VerticalAlignment.Top

local function createLogoTab(name, symbol, order, isImage)
    local btn
    if isImage then
        btn = Instance.new("ImageButton")
        local success, thumb = pcall(function()
            return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size42x42)
        end)
        if success then btn.Image = thumb else btn.Image = "rbxassetid://0" end
    else
        btn = Instance.new("TextButton")
        btn.Text = symbol
        btn.Font = Enum.Font.GothamBold
        btn.TextColor3 = Color3.fromRGB(160, 160, 175)
        btn.TextSize = 16
    end
    
    btn.Name = name
    btn.Parent = Sidebar
    btn.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
    btn.Size = UDim2.new(0, 38, 0, 38)
    btn.LayoutOrder = order
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

local TabPlayerBtn = createLogoTab("TabPlayerBtn", "â", 1, false)
local TabGameBtn = createLogoTab("TabGameBtn", "â¡", 2, false)
local TabExtrasBtn = createLogoTab("TabExtrasBtn", "Extras", 3, false)
local TabEventsBtn = createLogoTab("TabEventsBtn", "E", 4, false)

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
SectionTitle.Position = UDim2.new(0, 0, 0, 0)
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

-- ==========================================
-- PÃGINA "PLAYER"
-- ==========================================
local speedEnabled, customSpeed = false, 16
local originalWalkSpeed = nil
local jumpEnabled, customJump = false, 50
local originalJumpPower, originalUseJumpPower = nil, nil
local infiniteJumpEnabled, noClipEnabled, floatEnabled = false, false, false

local speedBox = Instance.new("TextBox")
speedBox.Parent = PlayerPage
speedBox.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
speedBox.Size = UDim2.new(1, -10, 0, 32)
speedBox.Font = Enum.Font.Gotham
speedBox.PlaceholderText = "WalkSpeed (Ej. 16)"
speedBox.Text = "16"
speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBox.PlaceholderColor3 = Color3.fromRGB(110, 110, 125)
speedBox.TextSize = 13
speedBox.LayoutOrder = 1
Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 6)
speedBox.FocusLost:Connect(function() local v = tonumber(speedBox.Text) if v then customSpeed = v end end)

local speedToggle = Instance.new("TextButton")
speedToggle.Parent = PlayerPage
speedToggle.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
speedToggle.Size = UDim2.new(1, -10, 0, 32)
speedToggle.Font = Enum.Font.GothamBold
speedToggle.Text = "Activar WalkSpeed: OFF"
speedToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
speedToggle.TextSize = 12
speedToggle.LayoutOrder = 2
Instance.new("UICorner", speedToggle).CornerRadius = UDim.new(0, 6)

speedToggle.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if speedEnabled then
        if hum then originalWalkSpeed = hum.WalkSpeed end
        speedToggle.Text = "Activar WalkSpeed: ON"
        speedToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
        speedToggle.BackgroundColor3 = Color3.fromRGB(35, 60, 35)
    else
        if hum and originalWalkSpeed then hum.WalkSpeed = originalWalkSpeed end
        speedToggle.Text = "Activar WalkSpeed: OFF"
        speedToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
        speedToggle.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
    end
end)

local jumpBox = Instance.new("TextBox")
jumpBox.Parent = PlayerPage
jumpBox.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
jumpBox.Size = UDim2.new(1, -10, 0, 32)
jumpBox.Font = Enum.Font.Gotham
jumpBox.PlaceholderText = "JumpPower (Ej. 50)"
jumpBox.Text = "50"
jumpBox.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpBox.PlaceholderColor3 = Color3.fromRGB(110, 110, 125)
jumpBox.TextSize = 13
jumpBox.LayoutOrder = 3
Instance.new("UICorner", jumpBox).CornerRadius = UDim.new(0, 6)
jumpBox.FocusLost:Connect(function() local v = tonumber(jumpBox.Text) if v then customJump = v end end)

local jumpToggle = Instance.new("TextButton")
jumpToggle.Parent = PlayerPage
jumpToggle.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
jumpToggle.Size = UDim2.new(1, -10, 0, 32)
jumpToggle.Font = Enum.Font.GothamBold
jumpToggle.Text = "Activar Salto: OFF"
jumpToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
jumpToggle.TextSize = 12
jumpToggle.LayoutOrder = 4
Instance.new("UICorner", jumpToggle).CornerRadius = UDim.new(0, 6)

jumpToggle.MouseButton1Click:Connect(function()
    jumpEnabled = not jumpEnabled
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if jumpEnabled then
        if hum then originalUseJumpPower, originalJumpPower = hum.UseJumpPower, hum.JumpPower end
        jumpToggle.Text = "Activar Salto: ON"
        jumpToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
        jumpToggle.BackgroundColor3 = Color3.fromRGB(35, 60, 35)
    else
        if hum then
            if originalUseJumpPower ~= nil then hum.UseJumpPower = originalUseJumpPower end
            if originalJumpPower ~= nil then hum.JumpPower = originalJumpPower end
        end
        jumpToggle.Text = "Activar Salto: OFF"
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
    if noClipEnabled then
        noclipToggle.Text = "Noclip: ON"
        noclipToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
        noclipToggle.BackgroundColor3 = Color3.fromRGB(35, 60, 35)
    else
        noclipToggle.Text = "Noclip: OFF"
        noclipToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
        noclipToggle.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
    end
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
    if infiniteJumpEnabled then
        infJumpToggle.Text = "Infinitejump: ON"
        infJumpToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
        infJumpToggle.BackgroundColor3 = Color3.fromRGB(35, 60, 35)
    else
        infJumpToggle.Text = "Infinitejump: OFF"
        infJumpToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
        infJumpToggle.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
    end
end)

UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled then
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end
end)

-- ==========================================
-- PÃGINA "GAME" (RECORRIDOS Y WINBLOCKS)
-- ==========================================
local routeCFrames = {
	CFrame.new(1.723794, 10.398061, -14.657170, -0.981345, 0.000000, -0.192254, 0.000000, 1.000000, 0.000000, 0.192254, 0.000000, -0.981345), -- CFrame 1 modes:NFS
	CFrame.new(2.498288, 8.788522, 155.956909, 0.841975, 0.000000, -0.539517, 0.000000, 1.000000, 0.000000, 0.539517, -0.000000, 0.841975), -- CFrame 2 modes:N
	CFrame.new(2.472235, 8.788770, 414.924713, -0.993998, -0.000000, -0.109399, -0.000000, 1.000000, 0.000000, 0.109399, 0.000000, -0.993998), -- CFrame 3 modes:NFS
	CFrame.new(2.472236, 48.788769, 414.924713, -0.993998, 0.000000, -0.109399, 0.000000, 1.000000, -0.000000, 0.109399, -0.000000, -0.993998), -- CFrame 4 modes:N
	CFrame.new(2.210491, 48.788769, 459.923950, -0.999983, -0.000000, 0.005817, -0.000000, 1.000000, 0.000000, -0.005817, 0.000000, -0.999983), -- CFrame 5 modes:NF
	CFrame.new(2.065077, 48.788765, 484.923523, -0.999983, -0.000000, 0.005817, -0.000000, 1.000000, 0.000000, -0.005817, 0.000000, -0.999983), -- CFrame 6 modes:NFS
	CFrame.new(1.979693, 48.788769, 666.727295, -0.987106, 0.000000, -0.160066, -0.000000, 1.000000, 0.000000, 0.160066, 0.000000, -0.987106), -- CFrame 7 modes:NFS
	CFrame.new(1.979693, 8.788770, 666.727295, -0.987106, -0.000000, -0.160066, 0.000000, 1.000000, -0.000000, 0.160066, -0.000000, -0.987106), -- CFrame 8 modes:NFS
	CFrame.new(2.401369, 8.788770, 1015.547424, -0.998025, -0.000000, -0.062823, -0.000000, 1.000000, 0.000000, 0.062823, 0.000000, -0.998025), -- CFrame 9 modes:NFS
	CFrame.new(2.401369, 48.788769, 1015.547424, -0.998025, -0.000000, -0.062823, -0.000000, 1.000000, 0.000000, 0.062823, 0.000000, -0.998025), -- CFrame 10 modes:S
	CFrame.new(1.888022, 8.788770, 1029.942749, -0.999990, -0.000000, -0.004500, -0.000000, 1.000000, -0.000000, 0.004500, -0.000000, -0.999990), -- CFrame 11 modes:N
	CFrame.new(1.888025, 48.788769, 1029.942749, -0.999990, 0.000000, -0.004500, 0.000000, 1.000000, 0.000000, 0.004500, 0.000000, -0.999990), -- CFrame 12 modes:NF
	CFrame.new(4.778526, 78.788330, 1084.120239, -0.999998, -0.000000, 0.001943, -0.000000, 1.000000, -0.000000, -0.001943, -0.000000, -0.999998), -- CFrame 13 modes:NFS
	CFrame.new(-469.233154, 78.788773, 1084.786377, 0.287080, 0.000000, 0.957907, 0.000000, 1.000000, -0.000000, -0.957907, 0.000000, 0.287080), -- CFrame 14 modes:NFS
	CFrame.new(-469.233154, 8.788770, 1084.786377, 0.287080, -0.000000, 0.957907, -0.000000, 1.000000, 0.000000, -0.957907, -0.000000, 0.287080), -- CFrame 15 modes:NFS
	CFrame.new(-815.334290, 8.788770, 1085.548462, -0.021215, 0.000000, 0.999775, -0.000000, 1.000000, -0.000000, -0.999775, -0.000000, -0.021215), -- CFrame 16 modes:NFS
	CFrame.new(-1055.344360, 8.788770, 1084.210571, -0.353525, -0.000000, 0.935425, 0.000000, 1.000000, 0.000000, -0.935425, 0.000000, -0.353525), -- CFrame 17 modes:NFS
	CFrame.new(-1404.096191, 8.788770, 1085.305298, -0.204193, 0.000000, 0.978931, -0.000000, 1.000000, -0.000000, -0.978931, -0.000000, -0.204193), -- CFrame 18 modes:NFS
	CFrame.new(-1560.739136, 8.788774, 1089.958130, 0.595433, -0.000000, 0.803405, 0.000000, 1.000000, 0.000000, -0.803405, 0.000000, 0.595433), -- CFrame 19 modes:N
	CFrame.new(-1530.167114, 8.788774, 1127.149658, -0.769944, 0.000000, -0.638111, 0.000000, 1.000000, -0.000000, 0.638111, -0.000000, -0.769944), -- CFrame 20 modes:F
	CFrame.new(-1559.823120, 8.788774, 1307.095825, -0.986730, -0.000000, 0.162370, -0.000000, 1.000000, 0.000000, -0.162370, 0.000000, -0.986730), -- CFrame 21 modes:N
	CFrame.new(-1515.464722, 8.788774, 1322.853882, -0.225007, 0.000000, -0.974357, -0.000000, 1.000000, 0.000000, 0.974357, 0.000000, -0.225007), -- CFrame 22 modes:F
	CFrame.new(-1478.150757, 8.788774, 1314.697632, 0.920410, -0.000000, -0.390954, 0.000000, 1.000000, -0.000000, 0.390954, 0.000000, 0.920410), -- CFrame 23 modes:N
	CFrame.new(-1482.656128, 8.788774, 1407.314697, -0.994967, -0.000000, 0.100207, -0.000000, 1.000000, 0.000000, -0.100207, 0.000000, -0.994967), -- CFrame 24 modes:N
	CFrame.new(-1542.863525, 8.788774, 1412.845825, -0.072391, -0.000000, 0.997376, 0.000000, 1.000000, 0.000000, -0.997376, 0.000000, -0.072391), -- CFrame 25 modes:F
	CFrame.new(-1673.566528, 8.788774, 1414.027222, 0.066663, 0.000000, -0.997776, 0.000000, 1.000000, 0.000000, 0.997776, -0.000000, 0.066663), -- CFrame 26 modes:N
	CFrame.new(-1867.711548, 8.788774, 1409.603027, -0.044628, 0.000000, 0.999004, -0.000000, 1.000000, -0.000000, -0.999004, -0.000000, -0.044628), -- CFrame 27 modes:N
	CFrame.new(-1817.476562, 8.788771, 1359.951660, 0.832316, -0.000000, -0.554302, -0.000000, 1.000000, -0.000000, 0.554302, 0.000000, 0.832316), -- CFrame 28 modes:F
	CFrame.new(-2004.102295, 8.788774, 1157.550293, 0.998348, -0.000000, 0.057460, 0.000000, 1.000000, 0.000000, -0.057460, -0.000000, 0.998348), -- CFrame 29 modes:F
	CFrame.new(-1865.652588, 8.788774, 1214.202271, -0.933495, 0.000000, 0.358591, 0.000000, 1.000000, -0.000000, -0.358591, -0.000000, -0.933495), -- CFrame 30 modes:N
	CFrame.new(-2067.085693, 8.788774, 1214.307495, -0.032194, 0.000000, 0.999482, 0.000000, 1.000000, -0.000000, -0.999482, -0.000000, -0.032194), -- CFrame 31 modes:N
	CFrame.new(-2067.824951, 8.788650, 987.487427, -0.892555, 0.000000, -0.450938, 0.000000, 1.000000, 0.000000, 0.450938, 0.000000, -0.892555), -- CFrame 32 modes:N
	CFrame.new(-2150.184814, 8.788774, 979.491028, 0.119159, -0.000000, 0.992875, 0.000000, 1.000000, 0.000000, -0.992875, 0.000000, 0.119159), -- CFrame 33 modes:N
	CFrame.new(-2122.424805, 8.788774, 890.425781, 0.683254, 0.000000, -0.730180, -0.000000, 1.000000, 0.000000, 0.730180, 0.000000, 0.683254), -- CFrame 34 modes:F
	CFrame.new(-2158.113037, 7.570764, 731.783325, -0.287473, 0.000000, -0.957789, 0.000000, 1.000000, 0.000000, 0.957789, -0.000000, -0.287473), -- CFrame 35 modes:NFS
	CFrame.new(-2158.113037, -68.211243, 731.783325, -0.287473, 0.000000, -0.957789, 0.000000, 1.000000, 0.000000, 0.957789, -0.000000, -0.287473), -- CFrame 36 modes:N
	CFrame.new(-2158.284424, -68.211243, 720.066956, -0.790156, 0.000000, -0.612906, 0.000000, 1.000000, 0.000000, 0.612906, -0.000000, -0.790156), -- CFrame 37 modes:FS
	CFrame.new(-2158.700439, -67.264351, 666.636414, 0.993354, -0.000000, -0.115099, 0.000000, 1.000000, -0.000000, 0.115099, 0.000000, 0.993354), -- CFrame 38 modes:N
	CFrame.new(-2158.542236, -58.538563, 633.734497, 0.999120, -0.000000, -0.041954, -0.000000, 1.000000, -0.000000, 0.041954, 0.000000, 0.999120), -- CFrame 39 modes:NF
	CFrame.new(-2176.256104, -68.337509, 537.865112, 0.993793, -0.000000, 0.111241, 0.000000, 1.000000, -0.000000, -0.111241, 0.000000, 0.993793), -- CFrame 40 modes:N
	CFrame.new(-2177.282715, -68.305290, 508.678406, -0.976854, -0.000000, -0.213906, -0.000000, 1.000000, -0.000000, 0.213906, -0.000000, -0.976854), -- CFrame 41 modes:N
	CFrame.new(-2177.771973, -58.615578, 472.419128, 0.564029, 0.000000, -0.825755, -0.000000, 1.000000, 0.000000, 0.825755, 0.000000, 0.564029), -- CFrame 42 modes:NF
	CFrame.new(-2158.132812, -58.837502, 412.536774, 0.986553, -0.000000, 0.163440, 0.000000, 1.000000, 0.000000, -0.163440, -0.000000, 0.986553), -- CFrame 43 modes:NF
	CFrame.new(-2156.780029, -58.837502, 350.491425, 0.999445, -0.000000, 0.033318, 0.000000, 1.000000, -0.000000, -0.033318, 0.000000, 0.999445), -- CFrame 44 modes:N
	CFrame.new(-2156.677734, -58.837502, 280.591919, -0.527067, -0.000000, -0.849824, -0.000000, 1.000000, 0.000000, 0.849824, 0.000000, -0.527067), -- CFrame 45 modes:N
	CFrame.new(-2157.453613, -58.837502, 215.610672, 0.968502, 0.000000, 0.249008, -0.000000, 1.000000, 0.000000, -0.249008, -0.000000, 0.968502), -- CFrame 46 modes:NF
	CFrame.new(-2178.700195, -68.337509, 154.869110, 0.992454, 0.000000, -0.122616, -0.000000, 1.000000, -0.000000, 0.122616, 0.000000, 0.992454), -- CFrame 47 modes:NF
	CFrame.new(-2176.458496, -68.337509, 87.430786, 0.999897, -0.000000, 0.014348, 0.000000, 1.000000, -0.000000, -0.014348, 0.000000, 0.999897), -- CFrame 48 modes:N
	CFrame.new(-2157.995605, -68.327744, 67.934364, -0.759770, 0.000000, 0.650192, 0.000000, 1.000000, -0.000000, -0.650192, -0.000000, -0.759770), -- CFrame 49 modes:NFS
	CFrame.new(-2153.648926, -68.329048, 5.905844, -0.147685, -0.000000, -0.989034, -0.000000, 1.000000, -0.000000, 0.989034, 0.000000, -0.147685), -- CFrame 50 modes:N
	CFrame.new(-2177.284912, -68.329048, -36.404144, -0.316363, 0.000000, 0.948638, 0.000000, 1.000000, 0.000000, -0.948638, 0.000000, -0.316363), -- CFrame 51 modes:NF
	CFrame.new(-2192.481689, -68.329048, -222.030853, 0.298791, 0.000000, 0.954319, -0.000000, 1.000000, -0.000000, -0.954319, -0.000000, 0.298791), -- CFrame 52 modes:NF
	CFrame.new(-2173.635742, -68.329048, -252.867462, 0.997163, 0.000000, 0.075272, -0.000000, 1.000000, 0.000000, -0.075272, -0.000000, 0.997163), -- CFrame 53 modes:N
	CFrame.new(-2159.074707, -68.327744, -394.848175, 0.977728, -0.000000, -0.209878, 0.000000, 1.000000, -0.000000, 0.209878, 0.000000, 0.977728), -- CFrame 54 modes:NFS
	CFrame.new(-2157.513672, -68.299034, -719.824585, 0.265701, -0.000000, -0.964055, -0.000000, 1.000000, -0.000000, 0.964055, 0.000000, 0.265701), -- CFrame 55 modes:N
	CFrame.new(-2155.650635, -68.327232, -1026.460449, -0.140630, -0.000000, -0.990062, -0.000000, 1.000000, -0.000000, 0.990062, 0.000000, -0.140630), -- CFrame 56 modes:NF
	CFrame.new(-2154.859375, -68.299034, -1332.979004, 0.999855, -0.000000, -0.017036, 0.000000, 1.000000, -0.000000, 0.017036, 0.000000, 0.999855), -- CFrame 57 modes:N
	CFrame.new(-2158.319092, -68.327744, -1504.355469, 0.992763, 0.000000, 0.120094, -0.000000, 1.000000, -0.000000, -0.120094, 0.000000, 0.992763), -- CFrame 58 modes:NFS
	CFrame.new(-2169.666260, -68.332741, -1634.468384, 0.931206, -0.000000, 0.364494, 0.000000, 1.000000, 0.000000, -0.364494, -0.000000, 0.931206), -- CFrame 59 modes:N
	CFrame.new(-2197.297607, -47.667351, -1700.590454, 0.970139, 0.000000, 0.242551, 0.000000, 1.000000, -0.000000, -0.242551, 0.000000, 0.970139), -- CFrame 60 modes:N
	CFrame.new(-2197.297607, -47.667351, -1700.590454, 0.970139, 0.000000, 0.242551, -0.000000, 1.000000, -0.000000, -0.242551, 0.000000, 0.970139), -- CFrame 61 modes:NF
	CFrame.new(-2197.310547, -47.541206, -1763.638916, 0.997211, 0.000000, -0.074632, -0.000000, 1.000000, 0.000000, 0.074632, -0.000000, 0.997211), -- CFrame 62 modes:NF
	CFrame.new(-2197.867188, -70.453674, -1931.262207, -0.997369, -0.000000, -0.072497, -0.000000, 1.000000, -0.000000, 0.072497, 0.000000, -0.997369), -- CFrame 63 modes:N
	CFrame.new(-2197.487061, -70.437897, -1993.377930, 0.805633, -0.000000, 0.592414, 0.000000, 1.000000, 0.000000, -0.592414, -0.000000, 0.805633), -- CFrame 64 modes:N
	CFrame.new(-2197.502441, -58.354435, -2030.619507, 0.996522, 0.000000, 0.083334, -0.000000, 1.000000, -0.000000, -0.083334, 0.000000, 0.996522), -- CFrame 65 modes:NF
	CFrame.new(-2158.854248, -68.332741, -2199.634521, -0.999959, -0.000000, 0.009075, -0.000000, 1.000000, -0.000000, -0.009075, -0.000000, -0.999959), -- CFrame 66 modes:N
	CFrame.new(-2157.820312, -68.332741, -2262.027588, 0.738523, 0.000000, 0.674228, 0.000000, 1.000000, -0.000000, -0.674228, 0.000000, 0.738523), -- CFrame 67 modes:N
	CFrame.new(-2156.573486, -56.146812, -2301.862793, 0.969763, 0.000000, 0.244050, -0.000000, 1.000000, 0.000000, -0.244050, -0.000000, 0.969763), -- CFrame 68 modes:NF
	CFrame.new(-2157.894531, -68.332817, -2462.182373, -0.998098, -0.000000, -0.061645, -0.000000, 1.000000, -0.000000, 0.061645, -0.000000, -0.998098), -- CFrame 69 modes:N
	CFrame.new(-2158.653809, -68.332817, -2524.041016, 0.321548, 0.000000, -0.946893, 0.000000, 1.000000, 0.000000, 0.946893, -0.000000, 0.321548), -- CFrame 70 modes:N
	CFrame.new(-2157.582275, -56.471050, -2562.268555, 0.995030, -0.000000, 0.099577, 0.000000, 1.000000, -0.000000, -0.099577, 0.000000, 0.995030), -- CFrame 71 modes:NF
	CFrame.new(-2157.990723, -68.332886, -2737.116699, -0.998777, -0.000000, -0.049439, -0.000000, 1.000000, 0.000000, 0.049439, 0.000000, -0.998777), -- CFrame 72 modes:N
	CFrame.new(-2158.024414, -68.307816, -2801.284424, 0.996086, -0.000000, 0.088387, 0.000000, 1.000000, -0.000000, -0.088387, 0.000000, 0.996086), -- CFrame 73 modes:N
	CFrame.new(-2158.176758, -56.394001, -2838.208008, 0.984669, -0.000000, 0.174435, -0.000000, 1.000000, 0.000000, -0.174435, -0.000000, 0.984669), -- CFrame 74 modes:NF
	CFrame.new(-2157.363037, -68.332909, -2956.279053, 0.998846, -0.000000, 0.048024, 0.000000, 1.000000, -0.000000, -0.048024, 0.000000, 0.998846), -- CFrame 75 modes:NF
	CFrame.new(-2158.196777, -68.330841, -3058.660645, 0.921797, -0.000000, -0.387673, 0.000000, 1.000000, 0.000000, 0.387673, -0.000000, 0.921797), -- CFrame 76 modes:N
	CFrame.new(-2158.274658, -68.327744, -3077.696289, 0.990696, 0.000000, -0.136094, -0.000000, 1.000000, -0.000000, 0.136094, 0.000000, 0.990696), -- CFrame 77 modes:NFS
	CFrame.new(-2157.677734, -68.177742, -3093.096436, 0.450028, -0.000000, -0.893014, 0.000000, 1.000000, 0.000000, 0.893014, -0.000000, 0.450028), -- CFrame 78 modes:NFS
	CFrame.new(-2158.995850, -109.038826, -3165.531250, 0.937907, -0.000000, 0.346886, 0.000000, 1.000000, -0.000000, -0.346886, 0.000000, 0.937907), -- CFrame 79 modes:NFS
	CFrame.new(-2158.782227, -109.038818, -3340.531250, 0.999999, -0.000000, -0.001221, 0.000000, 1.000000, -0.000000, 0.001221, 0.000000, 0.999999), -- CFrame 80 modes:N
	CFrame.new(-2158.568604, -109.038857, -3515.531006, 0.999999, 0.000000, -0.001221, -0.000000, 1.000000, 0.000000, 0.001221, -0.000000, 0.999999), -- CFrame 81 modes:NF
	CFrame.new(-2158.354980, -109.038818, -3690.530762, 0.999999, 0.000000, -0.001221, -0.000000, 1.000000, -0.000000, 0.001221, 0.000000, 0.999999), -- CFrame 82 modes:N
	CFrame.new(-2158.141357, -109.038826, -3865.530762, 0.999999, -0.000000, -0.001221, 0.000000, 1.000000, 0.000000, 0.001221, -0.000000, 0.999999), -- CFrame 83 modes:NF
	CFrame.new(-2157.927734, -109.038811, -4040.530762, 0.999999, 0.000000, -0.001221, -0.000000, 1.000000, -0.000000, 0.001221, 0.000000, 0.999999), -- CFrame 84 modes:N
	CFrame.new(-2157.714111, -109.038834, -4215.530273, 0.999999, -0.000000, -0.001221, 0.000000, 1.000000, 0.000000, 0.001221, -0.000000, 0.999999), -- CFrame 85 modes:NF
	CFrame.new(-2157.500488, -109.038849, -4390.530273, 0.999999, -0.000000, -0.001221, 0.000000, 1.000000, 0.000000, 0.001221, -0.000000, 0.999999), -- CFrame 86 modes:N
	CFrame.new(-2157.286865, -109.038834, -4565.530273, 0.999999, -0.000000, -0.001221, 0.000000, 1.000000, 0.000000, 0.001221, -0.000000, 0.999999), -- CFrame 87 modes:NF
	CFrame.new(-2157.679443, -109.036713, -4647.820801, 0.766852, 0.000000, 0.641824, 0.000000, 1.000000, -0.000000, -0.641824, 0.000000, 0.766852), -- CFrame 88 modes:NFS
	CFrame.new(-2181.696533, -109.038483, -4802.574707, 0.681549, 0.000000, -0.731772, -0.000000, 1.000000, 0.000000, 0.731772, 0.000000, 0.681549), -- CFrame 89 modes:N
	CFrame.new(-2133.482666, -109.038483, -4928.677734, 0.249246, -0.000000, 0.968440, 0.000000, 1.000000, 0.000000, -0.968440, -0.000000, 0.249246), -- CFrame 90 modes:N
	CFrame.new(-2182.430664, -109.038483, -5057.438477, 0.912545, -0.000000, 0.408976, -0.000000, 1.000000, 0.000000, -0.408976, -0.000000, 0.912545), -- CFrame 91 modes:N
	CFrame.new(-2128.923828, -109.038483, -5187.791016, 0.286787, 0.000000, -0.957994, 0.000000, 1.000000, 0.000000, 0.957994, -0.000000, 0.286787), -- CFrame 92 modes:NF
	CFrame.new(-2183.152832, -109.038483, -5303.347656, 0.985065, 0.000000, -0.172184, -0.000000, 1.000000, 0.000000, 0.172184, -0.000000, 0.985065), -- CFrame 93 modes:N
	CFrame.new(-2133.355225, -109.038483, -5425.147949, 0.482307, -0.000000, -0.876002, 0.000000, 1.000000, -0.000000, 0.876002, -0.000000, 0.482307), -- CFrame 94 modes:N
	CFrame.new(-2182.405762, -109.038483, -5557.606934, 0.240303, 0.000000, -0.970698, 0.000000, 1.000000, 0.000000, 0.970698, -0.000000, 0.240303), -- CFrame 95 modes:N
	CFrame.new(-2130.674316, -109.038483, -5691.516602, 0.652771, 0.000000, 0.757555, 0.000000, 1.000000, -0.000000, -0.757555, 0.000000, 0.652771), -- CFrame 96 modes:NF
	CFrame.new(-2158.924805, -109.036713, -5838.735840, 0.999708, -0.000000, 0.024151, 0.000000, 1.000000, -0.000000, -0.024151, 0.000000, 0.999708), -- CFrame 97 modes:NFS
	CFrame.new(-2157.822754, -109.039032, -5890.735840, 0.537583, -0.000000, 0.843211, 0.000000, 1.000000, 0.000000, -0.843211, 0.000000, 0.537583), -- CFrame 98 modes:NF
	CFrame.new(-2043.721924, -109.039032, -5899.330078, 0.999073, 0.000000, -0.043046, -0.000000, 1.000000, -0.000000, 0.043046, 0.000000, 0.999073), -- CFrame 99 modes:N
	CFrame.new(-2046.213379, -108.921761, -5949.420410, -0.794346, -0.000000, -0.607466, -0.000000, 1.000000, -0.000000, 0.607466, -0.000000, -0.794346), -- CFrame 100 modes:N
	CFrame.new(-2046.191895, -76.067596, -6078.995605, -0.142012, -0.000000, -0.989865, 0.000000, 1.000000, -0.000000, 0.989865, -0.000000, -0.142012), -- CFrame 101 modes:N
	CFrame.new(-2045.687134, -76.060432, -6114.630371, -0.343429, 0.000000, 0.939179, 0.000000, 1.000000, -0.000000, -0.939179, 0.000000, -0.343429), -- CFrame 102 modes:N
	CFrame.new(-2171.921875, -55.940319, -6079.653320, -0.999532, -0.000000, -0.030590, -0.000000, 1.000000, 0.000000, 0.030590, 0.000000, -0.999532), -- CFrame 103 modes:F
	CFrame.new(-2223.168945, -43.089211, -6124.910645, -0.591045, 0.000000, 0.806638, -0.000000, 1.000000, -0.000000, -0.806638, -0.000000, -0.591045), -- CFrame 104 modes:N
	CFrame.new(-2266.797119, -43.085396, -6123.513672, 0.382354, -0.000000, 0.924016, 0.000000, 1.000000, 0.000000, -0.924016, 0.000000, 0.382354), -- CFrame 105 modes:N
	CFrame.new(-2266.984619, -43.085396, -6080.699219, 0.548471, -0.000000, 0.836170, -0.000000, 1.000000, 0.000000, -0.836170, -0.000000, 0.548471), -- CFrame 106 modes:N
	CFrame.new(-2267.391113, -10.287116, -5949.721191, -0.365208, 0.000000, -0.930926, 0.000000, 1.000000, 0.000000, 0.930926, -0.000000, -0.365208), -- CFrame 107 modes:N
	CFrame.new(-2268.511963, -10.129237, -5911.355469, -0.998559, -0.000000, 0.053661, -0.000000, 1.000000, -0.000000, -0.053661, -0.000000, -0.998559), -- CFrame 108 modes:N
	CFrame.new(-2223.602783, -10.129237, -5911.150879, -0.172702, -0.000000, -0.984974, 0.000000, 1.000000, -0.000000, 0.984974, -0.000000, -0.172702), -- CFrame 109 modes:N
	CFrame.new(-2162.547852, 5.101793, -5948.480957, 0.702743, 0.000000, -0.711444, 0.000000, 1.000000, 0.000000, 0.711444, -0.000000, 0.702743), -- CFrame 110 modes:F
	CFrame.new(-2091.559326, 22.845793, -5907.810547, -0.647408, -0.000000, -0.762143, -0.000000, 1.000000, -0.000000, 0.762143, -0.000000, -0.647408), -- CFrame 111 modes:N
	CFrame.new(-2049.938965, 22.845793, -5908.574707, -0.075823, -0.000000, -0.997121, -0.000000, 1.000000, -0.000000, 0.997121, 0.000000, -0.075823), -- CFrame 112 modes:N
	CFrame.new(-2049.121338, 22.845793, -5946.925781, 0.991554, -0.000000, -0.129696, 0.000000, 1.000000, -0.000000, 0.129696, 0.000000, 0.991554), -- CFrame 113 modes:N
	CFrame.new(-2047.412476, 55.801739, -6079.977051, 0.361305, -0.000000, 0.932448, -0.000000, 1.000000, 0.000000, -0.932448, -0.000000, 0.361305), -- CFrame 114 modes:N
	CFrame.new(-2047.680298, 55.801739, -6112.555176, 0.979468, -0.000000, 0.201602, 0.000000, 1.000000, 0.000000, -0.201602, -0.000000, 0.979468), -- CFrame 115 modes:N
	CFrame.new(-2092.197510, 55.818737, -6112.405273, -0.316484, -0.000000, 0.948598, -0.000000, 1.000000, -0.000000, -0.948598, -0.000000, -0.316484), -- CFrame 116 modes:N
	CFrame.new(-2142.987061, 68.541687, -6079.058594, -0.927693, -0.000000, 0.373343, -0.000000, 1.000000, 0.000000, -0.373343, 0.000000, -0.927693), -- CFrame 117 modes:F
	CFrame.new(-2222.015381, 88.617874, -6123.796387, -0.071223, -0.000000, 0.997460, -0.000000, 1.000000, 0.000000, -0.997460, -0.000000, -0.071223), -- CFrame 118 modes:N
	CFrame.new(-2258.933594, 88.776756, -6124.555664, 0.026878, -0.000000, 0.999639, -0.000000, 1.000000, 0.000000, -0.999639, -0.000000, 0.026878), -- CFrame 119 modes:N
	CFrame.new(-2261.036865, 88.787743, -6079.577637, -0.999042, -0.000000, -0.043771, -0.000000, 1.000000, 0.000000, 0.043771, 0.000000, -0.999042), -- CFrame 120 modes:N
	CFrame.new(-2260.954834, 121.732918, -5948.331543, -0.864683, -0.000000, 0.502318, -0.000000, 1.000000, -0.000000, -0.502318, -0.000000, -0.864683), -- CFrame 121 modes:N
	CFrame.new(-2261.293701, 121.732918, -5912.591309, -0.998810, -0.000000, -0.048762, -0.000000, 1.000000, 0.000000, 0.048762, 0.000000, -0.998810), -- CFrame 122 modes:N
	CFrame.new(-2222.482178, 121.809174, -5911.831543, -0.023209, -0.000000, -0.999731, -0.000000, 1.000000, -0.000000, 0.999731, 0.000000, -0.023209), -- CFrame 123 modes:N
	CFrame.new(-2150.757080, 139.955276, -5948.726562, 0.410006, 0.000000, -0.912083, -0.000000, 1.000000, 0.000000, 0.912083, -0.000000, 0.410006), -- CFrame 124 modes:F
	CFrame.new(-2091.486328, 154.707962, -5905.091797, -0.989906, -0.000000, -0.141724, -0.000000, 1.000000, 0.000000, 0.141724, 0.000000, -0.989906), -- CFrame 125 modes:N
	CFrame.new(-2050.897217, 154.707962, -5905.969727, -0.167784, -0.000000, -0.985824, 0.000000, 1.000000, -0.000000, 0.985824, -0.000000, -0.167784), -- CFrame 126 modes:N
	CFrame.new(-2051.775391, 154.707962, -6117.379395, 0.999643, -0.000000, -0.026712, 0.000000, 1.000000, 0.000000, 0.026712, -0.000000, 0.999643), -- CFrame 127 modes:N
	CFrame.new(-2157.757324, 154.705612, -6124.634766, -0.465964, 0.000000, 0.884804, -0.000000, 1.000000, -0.000000, -0.884804, -0.000000, -0.465964), -- CFrame 128 modes:N
	CFrame.new(-2159.168457, 154.906082, -6079.477051, -0.906686, -0.000000, -0.421806, -0.000000, 1.000000, 0.000000, 0.421806, 0.000000, -0.906686), -- CFrame 129 modes:F
	CFrame.new(-2157.790527, 154.458725, -6169.575195, 0.999800, 0.000000, -0.019995, -0.000000, 1.000000, 0.000000, 0.019995, -0.000000, 0.999800) -- CFrame 130 modes:NFS
}

local routeModes = {
	[1] = { normal = true, fast = true, super = true }, -- CF 1
	[2] = { normal = true, fast = false, super = false }, -- CF 2
	[3] = { normal = true, fast = true, super = true }, -- CF 3
	[4] = { normal = true, fast = false, super = false }, -- CF 4
	[5] = { normal = true, fast = true, super = false }, -- CF 5
	[6] = { normal = true, fast = true, super = true }, -- CF 6
	[7] = { normal = true, fast = true, super = true }, -- CF 7
	[8] = { normal = true, fast = true, super = true }, -- CF 8
	[9] = { normal = true, fast = true, super = true }, -- CF 9
	[10] = { normal = false, fast = false, super = true }, -- CF 10
	[11] = { normal = true, fast = false, super = false }, -- CF 11
	[12] = { normal = true, fast = true, super = false }, -- CF 12
	[13] = { normal = true, fast = true, super = true }, -- CF 13
	[14] = { normal = true, fast = true, super = true }, -- CF 14
	[15] = { normal = true, fast = true, super = true }, -- CF 15
	[16] = { normal = true, fast = true, super = true }, -- CF 16
	[17] = { normal = true, fast = true, super = true }, -- CF 17
	[18] = { normal = true, fast = true, super = true }, -- CF 18
	[19] = { normal = true, fast = false, super = false }, -- CF 19
	[20] = { normal = false, fast = true, super = false }, -- CF 20
	[21] = { normal = true, fast = false, super = false }, -- CF 21
	[22] = { normal = false, fast = true, super = false }, -- CF 22
	[23] = { normal = true, fast = false, super = false }, -- CF 23
	[24] = { normal = true, fast = false, super = false }, -- CF 24
	[25] = { normal = false, fast = true, super = false }, -- CF 25
	[26] = { normal = true, fast = false, super = false }, -- CF 26
	[27] = { normal = true, fast = false, super = false }, -- CF 27
	[28] = { normal = false, fast = true, super = false }, -- CF 28
	[29] = { normal = false, fast = true, super = false }, -- CF 29
	[30] = { normal = true, fast = false, super = false }, -- CF 30
	[31] = { normal = true, fast = false, super = false }, -- CF 31
	[32] = { normal = true, fast = false, super = false }, -- CF 32
	[33] = { normal = true, fast = false, super = false }, -- CF 33
	[34] = { normal = false, fast = true, super = false }, -- CF 34
	[35] = { normal = true, fast = true, super = true }, -- CF 35
	[36] = { normal = true, fast = false, super = false }, -- CF 36
	[37] = { normal = false, fast = true, super = true }, -- CF 37
	[38] = { normal = true, fast = false, super = false }, -- CF 38
	[39] = { normal = true, fast = true, super = false }, -- CF 39
	[40] = { normal = true, fast = false, super = false }, -- CF 40
	[41] = { normal = true, fast = false, super = false }, -- CF 41
	[42] = { normal = true, fast = true, super = false }, -- CF 42
	[43] = { normal = true, fast = true, super = false }, -- CF 43
	[44] = { normal = true, fast = false, super = false }, -- CF 44
	[45] = { normal = true, fast = false, super = false }, -- CF 45
	[46] = { normal = true, fast = true, super = false }, -- CF 46
	[47] = { normal = true, fast = true, super = false }, -- CF 47
	[48] = { normal = true, fast = false, super = false }, -- CF 48
	[49] = { normal = true, fast = true, super = true }, -- CF 49
	[50] = { normal = true, fast = false, super = false }, -- CF 50
	[51] = { normal = true, fast = true, super = false }, -- CF 51
	[52] = { normal = true, fast = true, super = false }, -- CF 52
	[53] = { normal = true, fast = false, super = false }, -- CF 53
	[54] = { normal = true, fast = true, super = true }, -- CF 54
	[55] = { normal = true, fast = false, super = false }, -- CF 55
	[56] = { normal = true, fast = true, super = false }, -- CF 56
	[57] = { normal = true, fast = false, super = false }, -- CF 57
	[58] = { normal = true, fast = true, super = true }, -- CF 58
	[59] = { normal = true, fast = false, super = false }, -- CF 59
	[60] = { normal = true, fast = false, super = false }, -- CF 60
	[61] = { normal = true, fast = true, super = false }, -- CF 61
	[62] = { normal = true, fast = true, super = false }, -- CF 62
	[63] = { normal = true, fast = false, super = false }, -- CF 63
	[64] = { normal = true, fast = false, super = false }, -- CF 64
	[65] = { normal = true, fast = true, super = false }, -- CF 65
	[66] = { normal = true, fast = false, super = false }, -- CF 66
	[67] = { normal = true, fast = false, super = false }, -- CF 67
	[68] = { normal = true, fast = true, super = false }, -- CF 68
	[69] = { normal = true, fast = false, super = false }, -- CF 69
	[70] = { normal = true, fast = false, super = false }, -- CF 70
	[71] = { normal = true, fast = true, super = false }, -- CF 71
	[72] = { normal = true, fast = false, super = false }, -- CF 72
	[73] = { normal = true, fast = false, super = false }, -- CF 73
	[74] = { normal = true, fast = true, super = false }, -- CF 74
	[75] = { normal = true, fast = true, super = false }, -- CF 75
	[76] = { normal = true, fast = false, super = false }, -- CF 76
	[77] = { normal = true, fast = true, super = true }, -- CF 77
	[78] = { normal = true, fast = true, super = true }, -- CF 78
	[79] = { normal = true, fast = true, super = true }, -- CF 79
	[80] = { normal = true, fast = false, super = false }, -- CF 80
	[81] = { normal = true, fast = true, super = false }, -- CF 81
	[82] = { normal = true, fast = false, super = false }, -- CF 82
	[83] = { normal = true, fast = true, super = false }, -- CF 83
	[84] = { normal = true, fast = false, super = false }, -- CF 84
	[85] = { normal = true, fast = true, super = false }, -- CF 85
	[86] = { normal = true, fast = false, super = false }, -- CF 86
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
-- PÃGINA "EXTRAS" (ANTILAG, AUTO SPECIALKEYS, NPC MODE)
-- ==========================================
local antilagActive = false
local autoSpecialKeysActive = false
local eventCollectMode = "Tween"
local npcModeActive = false
local originalPosBeforeNpc = nil
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

local npcToggle = Instance.new("TextButton")
npcToggle.Parent = ExtrasPage
npcToggle.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
npcToggle.Size = UDim2.new(1, -10, 0, 32)
npcToggle.Font = Enum.Font.GothamBold
npcToggle.Text = "Convertirse en Npc: OFF"
npcToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
npcToggle.TextSize = 12
npcToggle.LayoutOrder = 5
Instance.new("UICorner", npcToggle).CornerRadius = UDim.new(0, 6)

npcToggle.MouseButton1Click:Connect(function()
    npcModeActive = not npcModeActive
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if npcModeActive then
        if hrp then
            originalPosBeforeNpc = hrp.CFrame
            local npc = Workspace:FindFirstChild("G2W1_NPC1", true)
            local npcHrp = npc and npc:FindFirstChild("HumanoidRootPart")
            if npcHrp then hrp.CFrame = npcHrp.CFrame end
        end
        npcToggle.Text = "Convertirse en Npc: ON"
        npcToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
        npcToggle.BackgroundColor3 = Color3.fromRGB(35, 60, 35)
        if char then for _, p in pairs(char:GetDescendants()) do if p:IsA("BasePart") or p:IsA("Decal") then p.Transparency = 1 end end end
    else
        npcToggle.Text = "Convertirse en Npc: OFF"
        npcToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
        npcToggle.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
        if char then
            for _, p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = 0
                elseif p:IsA("Decal") then p.Transparency = 0 end
            end
            if hrp and originalPosBeforeNpc then hrp.CFrame = originalPosBeforeNpc end
        end
    end
end)


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
-- CARGA EN 3 FASES (0-30 / 30-60 / 60-100)
-- ==========================================
-- Ocultar UI interactiva hasta scriptReady
pcall(function()
    if MainFrame then MainFrame.Visible = false end
    if FloatingLogo then FloatingLogo.Visible = false end
    if StopRouteContainer then StopRouteContainer.Visible = false end
end)

task.spawn(function()
    if getgenv and getgenv().DeltaHubSkipAssets then
        if LoadingScreen and LoadingScreen.Parent then LoadingScreen:Destroy() end
        scriptReady = true
        if MainFrame then MainFrame.Visible = true end
        return
    end

    -- ===== FASE 1: CFrames + routeModes (0 â 30%), max 10s =====
    setProgress(0, "Fase 1/3  CFrames", "Cargando ruta y modos...")
    local t1 = tick()
    local totalCf = #routeCFrames
    for i = 1, totalCf do
        -- "checar" entrada (fuerza parseo / acceso)
        local _ = routeCFrames[i]
        local __ = routeModes[i]
        if i % 8 == 0 then
            local p = (i / totalCf) * 30
            setProgress(p, "Fase 1/3  CFrames", string.format("CFrame %d / %d", i, totalCf))
            task.wait()
        end
    end
    -- si termina antes de 10s, salta a 30%
    setProgress(30, "Fase 1/3  Lista", "Ruta lista")
    local left1 = 10 - (tick() - t1)
    if left1 > 0.05 then
        -- no forzar espera completa: el usuario pidiÃ³ saltar si se completa antes
    end
    task.wait(0.15)

    -- ===== FASE 2: UI pestaÃ±as / apartados (30 â 60%), max 10s =====
    setProgress(30, "Fase 2/3  Interfaz", "Preparando pestaÃ±as...")
    local t2 = tick()
    -- asegurar pÃ¡ginas creadas (ya existen; solo "calentar" referencias)
    local pagesWarm = { GamePage, PlayerPage, EventsPage, ExtrasPage, MainFrame, Sidebar, ContentArea }
    for i, obj in ipairs(pagesWarm) do
        if obj then
            local _ = obj.Name
        end
        setProgress(30 + (i / #pagesWarm) * 30, "Fase 2/3  Interfaz", "UI " .. tostring(i) .. "/" .. tostring(#pagesWarm))
        task.wait(0.05)
    end
    setProgress(60, "Fase 2/3  Lista", "Interfaz lista")
    task.wait(0.15)

    -- ===== FASE 3: Limpieza con elecciÃ³n de ruta (60 â 100%), max 30s =====
    setProgress(60, "Fase 3/3  Limpieza", "Elige tipo de limpieza")
    CleanChoiceFrame.Visible = true
    local chosenMode = nil -- "normal" | "fast" | "super"
    local bindN = btnCleanNormal.MouseButton1Click:Connect(function() chosenMode = "normal" end)
    local bindF = btnCleanFast.MouseButton1Click:Connect(function() chosenMode = "fast" end)
    local bindS = btnCleanSuper.MouseButton1Click:Connect(function() chosenMode = "super" end)
    local waitStart = tick()
    while not chosenMode and tick() - waitStart < 60 do
        task.wait(0.1)
    end
    if not chosenMode then chosenMode = "normal" end
    pcall(function() bindN:Disconnect() bindF:Disconnect() bindS:Disconnect() end)
    CleanChoiceFrame.Visible = false

    setProgress(62, "Fase 3/3  Limpieza", "Limpiando (" .. chosenMode .. ")...")
    local routeList = select(1, getRouteCFramesForMode(chosenMode == "super" and "super" or chosenMode))
    local t3 = tick()
    local hrp = waitAliveHrp(routeList[1] or routeCFrames[1])
    local nRoute = math.max(1, #routeList)
    for i, spot in ipairs(routeList) do
        if tick() - t3 > 30 then break end
        hrp = waitAliveHrp(spot)
        if not hrp then break end
        hrp.CFrame = spot
        hrp.AssemblyLinearVelocity = Vector3.new()
        runExactCleanup()
        local p = 60 + (i / nRoute) * 40
        setProgress(p, "Fase 3/3  Limpieza", string.format("%s  %d/%d", chosenMode, i, nRoute))
        task.wait(0.08)
    end
    -- cleanup final por si quedÃ³ algo
    runExactCleanup()
    setProgress(100, "Fase 3/3  Lista", "100%")
    if hrp and routeCFrames[1] then
        hrp.CFrame = routeCFrames[1]
    end

    fadeAndDestroyLoading()
    if MainFrame then MainFrame.Visible = true end
    showNotification("Hallowen world listo")
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
local function setHubOpen(open)
    MainFrame.Visible = open
    FloatingLogo.Visible = not open
    if Sidebar then Sidebar.Visible = open end
    local panel = ScreenGui:FindFirstChild("WinPanel")
    if panel then panel.Visible = false end
end
MinimizeBtn.MouseButton1Click:Connect(function() setHubOpen(false) end)
FloatingLogo.MouseButton1Click:Connect(function() setHubOpen(true) end)

local function updateTabs(btn, page, title)
    PlayerPage.Visible = false
    GamePage.Visible = false
    ExtrasPage.Visible = false
    if EventsPage then EventsPage.Visible = false end
end

TabPlayerBtn.MouseButton1Click:Connect(function() updateTabs(TabPlayerBtn, PlayerPage, "Player") end)
TabGameBtn.MouseButton1Click:Connect(function() updateTabs(TabGameBtn, GamePage, "Game") end)
TabExtrasBtn.MouseButton1Click:Connect(function() updateTabs(TabExtrasBtn, ExtrasPage, "Extras") end)
TabEventsBtn.MouseButton1Click:Connect(function() updateTabs(TabEventsBtn, EventsPage, "Events") end)

RunService.Stepped:Connect(function()
    local char = player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hum then
            if speedEnabled then hum.WalkSpeed = customSpeed end
            if jumpEnabled then hum.UseJumpPower = true; hum.JumpPower = customJump end
        end
        if noClipEnabled or npcModeActive then
            for _, p in pairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
        end
        if npcModeActive and hrp then
            pcall(function()
                local npc = Workspace:FindFirstChild("G2W1_NPC1", true)
                local npcHrp = npc and npc:FindFirstChild("HumanoidRootPart")
                if npcHrp then
                    local cp = hrp.Position
                    local np = npcHrp.Position
                    hrp.CFrame = CFrame.new(cp.X, np.Y, cp.Z) * (hrp.CFrame - hrp.Position)
                end
            end)
            pcall(function()
                local cam = Workspace.CurrentCamera
                if cam then
                    cam.CFrame = CFrame.new(cam.CFrame.Position) * (cam.CFrame - cam.CFrame.Position)
                    for _, p in pairs(Workspace:GetPartsInPart(cam)) do
                        if p:IsA("BasePart") and not p.IsDescendantOf(char) then p.CanCollide = false end
                    end
                end
            end)
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


local function buildHubUi()
MainFrame.Visible = true
ScreenGui.Enabled = true

local function treadmillLabel()
    local best = bestTreadmill or "Normal"
    local mult = {Admin = "x100", Candy = "x25", Diamond = "x9", Gold = "x3", Normal = "x1"}
    return "Best treadmill: " .. (mult[best] or "x1") .. " Treadmill"
end

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

local farmPage = createScrollingPage(ContentArea)
local playerNew = createScrollingPage(ContentArea)
playerNew.Visible = false
local eventsNew = createScrollingPage(ContentArea)
eventsNew.Visible = false

local function showPage(page, title)
    farmPage.Visible = false
    playerNew.Visible = false
    eventsNew.Visible = false
    page.Visible = true
    SectionTitle.Visible = true
    SectionTitle.Text = title
end

TabPlayerBtn.Text = "P"
TabGameBtn.Text = "F"
TabEventsBtn.Text = "E"
TabPlayerBtn.Visible = true
TabGameBtn.Visible = true
TabEventsBtn.Visible = true
Sidebar.Visible = true
TabExtrasBtn.Visible = false
TabGameBtn.MouseButton1Click:Connect(function() showPage(farmPage, "Farm") end)
TabPlayerBtn.MouseButton1Click:Connect(function() showPage(playerNew, "Player") end)
TabEventsBtn.MouseButton1Click:Connect(function() showPage(eventsNew, "Events") end)
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

local npcBody = section(playerNew, "NPC", 2)
npcToggle.Parent = npcBody
npcToggle.Size = UDim2.new(1, -8, 0, 32)
npcToggle.LayoutOrder = 1

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

local extrasPage = createScrollingPage(ContentArea)
extrasPage.Visible = false
local configPage = createScrollingPage(ContentArea)
configPage.Visible = false
local tabNames = {
    {btn = TabGameBtn, name = "Farm", page = farmPage},
    {btn = TabPlayerBtn, name = "Player", page = playerNew},
    {btn = TabEventsBtn, name = "Events", page = eventsNew},
    {btn = TabExtrasBtn, name = "Extras", page = extrasPage},
}
Sidebar.Parent = ScreenGui
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
MinimizeBtn.MouseButton1Click:Connect(function()
    Sidebar.Visible = false
    local panel = ScreenGui:FindFirstChild("WinPanel")
    if panel then panel.Visible = false end
end)

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

-- buildHubUi se llama al final de la carga 3 fases (scriptReady)
-- No destruir LoadingScreen aqui (conflicto con la carga nueva)

task.defer(function()
    if boot then boot:Destroy() end
end)

-- Cuando la carga termine, mostrar UI base
task.spawn(function()
    while not scriptReady do
        task.wait(0.2)
    end
    pcall(function()
        buildHubUi()
    end)
    pcall(function()
        if GamePage then GamePage.Visible = false end
        if PlayerPage then PlayerPage.Visible = false end
        if ExtrasPage then ExtrasPage.Visible = false end
        if EventsPage then EventsPage.Visible = false end
        if Sidebar then Sidebar.Size = UDim2.new(0, 78, 0, 250) end
    end)
    if MainFrame then MainFrame.Visible = true end
    print("Delta Hub Hallowen UI lista")
end)

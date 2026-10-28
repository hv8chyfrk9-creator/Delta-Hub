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
local playerGui = player:WaitForChild("PlayerGui", 10)
if not playerGui then
    warn("[Delta Hub] No hay PlayerGui")
    return
end

-- Aviso visible YA (antes de PlaceId / resto del script)
do
    local oldMsg = playerGui:FindFirstChild("DeltaHubBootMsg")
    if oldMsg then oldMsg:Destroy() end
    local msgSg = Instance.new("ScreenGui")
    msgSg.Name = "DeltaHubBootMsg"
    msgSg.ResetOnSpawn = false
    msgSg.IgnoreGuiInset = true
    msgSg.DisplayOrder = 100000
    msgSg.Parent = playerGui
    local msg = Instance.new("TextLabel")
    msg.Name = "Label"
    msg.Parent = msgSg
    msg.Size = UDim2.new(0, 320, 0, 70)
    msg.Position = UDim2.new(0.5, -160, 0.08, 0)
    msg.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    msg.TextColor3 = Color3.fromRGB(120, 255, 140)
    msg.Font = Enum.Font.GothamBold
    msg.TextSize = 13
    msg.TextWrapped = true
    msg.Text = "Delta Hub Hallowen: script iniciado\nPlaceId: " .. tostring(game.PlaceId)
    Instance.new("UICorner", msg).CornerRadius = UDim.new(0, 8)
    getgenv().DeltaHubBootMsg = msgSg
end

print("Delta Hub Hallowen world empezando PlaceId=", game.PlaceId)

-- Solo este PlaceId (Hallowen), salvo force
local HALLOWEEN_PLACE_ID = 128614435234859
if game.PlaceId ~= HALLOWEEN_PLACE_ID and not (getgenv and getgenv().DeltaHubForceLoad) then
    local msgSg = getgenv().DeltaHubBootMsg
    if msgSg and msgSg:FindFirstChild("Label") then
        msgSg.Label.TextColor3 = Color3.fromRGB(255, 120, 120)
        msgSg.Label.Text = "PlaceId incorrecto: " .. tostring(game.PlaceId) .. "\nEsperado: 128614435234859\nPon: getgenv().DeltaHubForceLoad = true"
    end
    warn("[Delta Hub] Hallowen PlaceId incorrecto: " .. tostring(game.PlaceId))
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
boot.Size = UDim2.new(0, 260, 0, 40)
boot.Position = UDim2.new(0.5, -130, 0, 50)
boot.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
boot.Text = "Hallowen world cargando..."
boot.TextColor3 = Color3.fromRGB(255, 255, 255)
boot.Font = Enum.Font.GothamBold
boot.TextSize = 14
boot.ZIndex = 20
Instance.new("UICorner", boot).CornerRadius = UDim.new(0, 6)

if getgenv().DeltaHubBootMsg and getgenv().DeltaHubBootMsg:FindFirstChild("Label") then
    getgenv().DeltaHubBootMsg.Label.Text = "PlaceId OK. Cargando UI..."
end
-- Quitar aviso de boot para que se vea la pantalla de carga
task.delay(1.5, function()
    pcall(function()
        if getgenv().DeltaHubBootMsg then
            getgenv().DeltaHubBootMsg:Destroy()
            getgenv().DeltaHubBootMsg = nil
        end
    end)
end)

-- Shared table para no saturar el limite de 200 locals del chunk
local HW = getgenv().DeltaHubHW or {}
getgenv().DeltaHubHW = HW


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
local LoadingGui = Instance.new("ScreenGui")
LoadingGui.Name = "DeltaHubLoadingGui"
LoadingGui.ResetOnSpawn = false
LoadingGui.IgnoreGuiInset = true
LoadingGui.DisplayOrder = 200000
LoadingGui.Parent = playerGui
local LoadingScreen = Instance.new("Frame")
LoadingScreen.Name = "LoadingScreen"
LoadingScreen.Parent = LoadingGui
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
HW.btnCleanNormal = btnCleanNormal
HW.btnCleanFast = btnCleanFast
HW.btnCleanSuper = btnCleanSuper
HW.CleanChoiceFrame = CleanChoiceFrame
HW.LoadingScreen = LoadingScreen
HW.LoadingGui = LoadingGui
HW.LoadingText = LoadingText
HW.LoadingSub = LoadingSub
HW.PctLabel = PctLabel
HW.ScreenGui = ScreenGui
HW.setProgress = setProgress
HW.fadeAndDestroyLoading = fadeAndDestroyLoading
HW.runExactCleanup = runExactCleanup
HW.waitAliveHrp = waitAliveHrp

local loadProgress = 0
local function setProgress(p, title, sub)
    loadProgress = math.clamp(p, 0, 100)
    BarFill.Size = UDim2.new(loadProgress / 100, 0, 1, 0)
    -- un solo decimal: 14.6%
    PctLabel.Text = string.format("%.1f%%", loadProgress)
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
    if LoadingGui and LoadingGui.Parent then LoadingGui:Destroy()
    elseif LoadingScreen and LoadingScreen.Parent then LoadingScreen:Destroy() end
    scriptReady = true
end





local function __hw_A()
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
HW.MainFrame = MainFrame

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

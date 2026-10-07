-- ==========================================
-- DELTA HUB - NUEVO MUNDO (NPC + ATTACKZONE GIGANTE EN 3D + KEYCAPS)
-- ==========================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

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

if playerGui:FindFirstChild("DeltaHubMinimal") then
    playerGui.DeltaHubMinimal:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaHubMinimal"
ScreenGui.Parent = playerGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999

-- ==========================================
-- PANTALLA NEGRA DE CARGA QUE ABARCA TODA LA PANTALLA
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
LoadingText.Size = UDim2.new(1, 0, 1, 0)
LoadingText.Font = Enum.Font.GothamBold
LoadingText.Text = "Cargando activos..."
LoadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadingText.TextSize = 24
LoadingText.ZIndex = 10000

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
FloatingLogo.Text = "DH"
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
-- VENTANA DE PREGUNTA AL MORIR (SÍ / NO)
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
Title.Text = "Delta Hub"
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

local TabPlayerBtn = createLogoTab("TabPlayerBtn", "⚙", 1, false)
local TabGameBtn = createLogoTab("TabGameBtn", "⚡", 2, false)
local TabExtrasBtn = createLogoTab("TabExtrasBtn", "", 3, true)
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
-- PÁGINA "PLAYER"
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
-- PÁGINA "GAME" (RECORRIDOS Y WINBLOCKS)
-- ==========================================
local routeCFrames = {
	CFrame.new(-1455.067, -159.041, -1000.098),
	CFrame.new(-1455.067, -159.041, -865.672),
	CFrame.new(-1431.380, -159.041, -865.672),
	CFrame.new(-1431.380, -159.041, -843.140),
	CFrame.new(-1428.823, -69.414, -541.792),
	CFrame.new(-1454.808, -69.414, -515.883),
	CFrame.new(-1454.808, -69.414, -440.332),
	CFrame.new(-1454.753, -58.471, -394.175),
	CFrame.new(-1454.804, -58.471, -347.091),
	CFrame.new(-1454.804, -58.471, -15.258),
	CFrame.new(-1454.804, -58.471, 84.460),
	CFrame.new(-1454.804, 228.104, 84.500),
	CFrame.new(-1454.804, 222.354, 233.264),
	CFrame.new(-1454.804, 215.782, 258.120),
	CFrame.new(-1454.804, 215.782, 330.898),
	CFrame.new(-1454.804, 215.782, 626.709),
	CFrame.new(-1454.804, 481.541, 626.709),
	CFrame.new(-1410.213, 492.710, 720.485),
	CFrame.new(-1410.187, 697.269, 720.485),
	CFrame.new(-1404.402, 532.725, 757.720),
	CFrame.new(-1404.402, 532.724, 1329.665),
	CFrame.new(-1404.402, 532.722, 1444.335),
	CFrame.new(-1441.623, 532.722, 1444.335),
	CFrame.new(-1444.373, 508.722, 1444.335),
	CFrame.new(-2034.741, 508.722, 1444.335),
	CFrame.new(-2062.319, 442.722, 1486.236),
	CFrame.new(-2137.296, 442.722, 1486.312),
	CFrame.new(-2170.049, 451.490, 1486.312),
	CFrame.new(-2263.484, 438.722, 1486.312),
	CFrame.new(-2310.261, 438.722, 1486.312),
	CFrame.new(-2343.476, 447.722, 1486.298),
	CFrame.new(-2380.390, 447.669, 1486.298),
	CFrame.new(-2415.859, 438.722, 1486.298),
	CFrame.new(-2456.827, 438.722, 1486.298),
	CFrame.new(-2499.995, 447.239, 1486.298),
	CFrame.new(-2550.813, 465.735, 1486.298),
	CFrame.new(-2655.013, 442.722, 1486.298),
	CFrame.new(-2699.919, 442.722, 1486.298),
	CFrame.new(-2732.480, 451.549, 1486.298),
	CFrame.new(-2832.842, 446.891, 1486.298),
	CFrame.new(-2832.844, 524.901, 1486.298),
	CFrame.new(-2910.317, 524.901, 1486.298),
	CFrame.new(-2910.317, 603.702, 1486.298),
	CFrame.new(-2981.481, 596.514, 1486.298),
	CFrame.new(-2981.543, 675.454, 1486.298),
	CFrame.new(-3053.735, 672.236, 1486.298),
	CFrame.new(-3215.901, 672.234, 1486.298),
	CFrame.new(-3244.502, 672.234, 1486.298),
	CFrame.new(-3633.041, 616.845, 1486.201),
	CFrame.new(-3658.373, 616.845, 1486.201),
	CFrame.new(-4129.089, 616.845, 1486.201),
	CFrame.new(-4175.052, 616.845, 1486.201),
	CFrame.new(-4376.956, 616.845, 1550.646),
	CFrame.new(-4612.793, 616.845, 1443.277),
	CFrame.new(-4822.641, 616.845, 1552.900),
	CFrame.new(-4931.930, 616.845, 1485.256),
	CFrame.new(-4966.471, 616.845, 1485.256),
	CFrame.new(-5042.986, 616.882, 1485.256),
	CFrame.new(-5075.064, 625.364, 1485.256),
	CFrame.new(-5170.879, 619.117, 1485.256),
	CFrame.new(-5173.418, 768.734, 1485.256),
	CFrame.new(-5351.491, 711.272, 1485.256),
	CFrame.new(-5351.491, 845.947, 1485.256),
	CFrame.new(-5531.767, 778.740, 1485.256),
	CFrame.new(-5531.767, 900.784, 1485.256),
	CFrame.new(-5711.660, 833.062, 1485.256),
	CFrame.new(-5711.660, 852.378, 1485.256),
	CFrame.new(-5740.584, 852.378, 1485.256),
	CFrame.new(-5864.127, 852.378, 1485.256),
	CFrame.new(-5964.662, 852.378, 1381.786),
	CFrame.new(-6192.698, 852.378, 1603.383),
	CFrame.new(-6423.904, 852.378, 1374.484),
	CFrame.new(-6538.485, 852.378, 1485.245),
	CFrame.new(-6660.707, 852.378, 1485.245),
	CFrame.new(-7312.893, 852.378, 1485.245),
	CFrame.new(-7526.252, 852.378, 1709.996),
	CFrame.new(-8048.232, 852.378, 1719.897),
	CFrame.new(-8270.788, 852.378, 1485.197),
	CFrame.new(-9512.411, 852.378, 1485.197),
	CFrame.new(-9589.005, 852.378, 1485.197),
	CFrame.new(-9622.849, 860.651, 1485.197),
	CFrame.new(-9736.655, 851.603, 1485.197),
	CFrame.new(-9816.223, 860.391, 1485.197),
	CFrame.new(-9901.173, 851.603, 1485.197),
	CFrame.new(-9979.802, 851.603, 1485.197),
	CFrame.new(-10131.783, 851.603, 1485.197),
	CFrame.new(-10178.276, 851.603, 1485.197),
	CFrame.new(-10209.922, 860.371, 1485.197),
	CFrame.new(-10324.558, 851.603, 1485.144),
	CFrame.new(-10369.938, 851.603, 1485.144),
	CFrame.new(-10402.345, 860.502, 1485.144),
	CFrame.new(-10471.802, 851.603, 1482.289),
	CFrame.new(-10549.584, 851.603, 1482.273),
	CFrame.new(-10629.244, 851.603, 1486.232),
	CFrame.new(-10675.295, 851.603, 1486.184),
	CFrame.new(-10706.976, 860.624, 1486.184),
	CFrame.new(-10806.283, 851.600, 1486.184),
	CFrame.new(-11546.611, 851.600, 1486.184),
	CFrame.new(-12521.399, 851.600, 1483.636),
	CFrame.new(-12570.752, 851.600, 1486.365),
	CFrame.new(-12576.339, 851.600, 1461.276),
	CFrame.new(-12609.233, 851.600, 1461.276),
	CFrame.new(-12840.677, 890.176, 1461.276),
	CFrame.new(-13343.156, 980.512, 1457.655),
	CFrame.new(-13394.042, 989.372, 1457.655),
	CFrame.new(-13601.614, 1026.290, 1457.655),
	CFrame.new(-13651.566, 1026.290, 1485.752),
	CFrame.new(-14436.752, 1026.290, 1485.690),
	CFrame.new(-14518.397, 1041.995, 1485.690),
	CFrame.new(-14686.220, 1028.308, 1510.621),
	CFrame.new(-14806.466, 1028.308, 1510.621),
	CFrame.new(-14885.395, 1042.184, 1510.652),
	CFrame.new(-15051.140, 1028.308, 1487.367),
	CFrame.new(-15172.444, 1028.308, 1484.592),
	CFrame.new(-15251.663, 1042.318, 1484.530),
	CFrame.new(-15382.346, 1028.306, 1484.530),
	CFrame.new(-15418.880, 1028.306, 1484.530),
	CFrame.new(-15502.269, 1014.293, 1484.530),
	CFrame.new(-17182.863, 1014.288, 1500.160),
	CFrame.new(-17412.496, 1014.281, 1732.716),
	CFrame.new(-17865.455, 1014.281, 1270.503),
	CFrame.new(-18330.396, 1014.281, 1732.626),
	CFrame.new(-18785.594, 1014.281, 1273.318),
	CFrame.new(-19030.672, 1014.299, 1514.662),
	CFrame.new(-19216.285, 1014.299, 1518.756),
	CFrame.new(-19420.988, 952.388, 1579.133),
	CFrame.new(-19558.553, 952.388, 1600.643),
	CFrame.new(-20025.061, 843.654, 1600.643),
	CFrame.new(-20216.875, 843.654, 1600.643),
	CFrame.new(-20766.449, 720.775, 1519.487),
	CFrame.new(-20883.184, 720.775, 1519.487),
	CFrame.new(-20965.094, 734.802, 1516.125),
	CFrame.new(-21149.236, 720.775, 1516.125),
	CFrame.new(-21267.373, 720.775, 1516.125),
	CFrame.new(-21351.812, 734.288, 1516.125),
	CFrame.new(-21428.020, 720.775, 1516.125),
	CFrame.new(-21548.639, 720.775, 1516.125),
	CFrame.new(-21709.314, 700.705, 1516.125),
	CFrame.new(-21907.512, 671.094, 1518.855),
	CFrame.new(-22101.980, 671.094, 1515.310),
	CFrame.new(-23260.682, 671.094, 1515.310),
}

local orderedWinBlocks = {
    {real = "WinBlock32", display = "+300M Wins", order = 1},
    {real = "WinBlock33", display = "+500M Wins", order = 2},
    {real = "WinBlock34", display = "+800M Wins", order = 3},
    {real = "WinBlock35", display = "+1.25B Wins", order = 4},
    {real = "WinBlock36", display = "+2B Wins", order = 5},
    {real = "WinBlock37", display = "+3.5B Wins", order = 6},
    {real = "WinBlock38", display = "+5.5B Wins", order = 7},
    {real = "WinBlock39", display = "+8.5B Wins", order = 8},
    {real = "WinBlock40", display = "+16B Wins", order = 9},
    {real = "WinBlock41", display = "+25B Wins", order = 10},
    {real = "WinBlock42", display = "+40B Wins", order = 11},
    {real = "WinBlock43", display = "+65B Wins", order = 12},
    {real = "WinBlock44", display = "+100B Wins", order = 13},
    {real = "WinBlock45", display = "+200B Wins", order = 14},
    {real = "WinBlock46", display = "+1T Wins", order = 15},
}

local selectedRealName = "WinBlock32"
local selectedDisplayName = "+300M Wins"
local gameSpeed = 250
local routeMode = "normal"
local function approachSpeed(distance, nextDistance)
    local maxSpeed = math.clamp(gameSpeed or 250, 1, 500)
    if nextDistance and nextDistance < 5 then
        return maxSpeed
    end
    local brake = 18
    local floorSpeed = 12
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
selectorBtn.Text = "Seleccionar Win: +300M Wins ▾"
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
        selectorBtn.Text = "Seleccionar Win: " .. info.display .. " ▾"
        dropdownList.Visible = false
    end)
end
selectorBtn.MouseButton1Click:Connect(function() dropdownList.Visible = not dropdownList.Visible end)

local winChosenLabel = Instance.new("TextLabel")
winChosenLabel.Parent = GamePage
winChosenLabel.BackgroundTransparency = 1
winChosenLabel.Size = UDim2.new(1, -10, 0, 22)
winChosenLabel.Font = Enum.Font.GothamSemibold
winChosenLabel.Text = "Win escogida: +300M Wins"
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
speedGameBox.FocusLost:Connect(function() local v = tonumber(speedGameBox.Text) if v then gameSpeed = math.clamp(v, 1, 500) end end)

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
    startRouteBtn.Text = "Iniciar Recorrido: OFF"
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
    showNotification("Sigue hasta tocar el WinBlock y volver al spawn.")
end)

StopNowBtn.MouseButton1Click:Connect(function()
    stopRecorridoGeneral()
    showNotification("Recorrido detenido ahora.")
end)

-- ==========================================
-- PÁGINA "EXTRAS" (ANTILAG, AUTO SPECIALKEYS, NPC MODE)
-- ==========================================
local antilagActive = false
local autoSpecialKeysActive = false
local specialKeysMode = "Tween"
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
        local antilagTargets = {"FloatFolder", "Decorations", "Props", "Halloween", "HallowenMeshes"}
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
saveConfigBtn.MouseButton1Click:Connect(function()
    local name = configNameBox.Text
    if name == "" or name == "default" then
        showNotification("Escribe un nombre. default no se reemplaza.")
        return
    end
    if configs[name] and not rememberOverwrite then
        showNotification("Ya existe. Se reemplaza si guardas otra vez y marcas recordar.")
        rememberOverwrite = true
        writeConfigs()
        return
    end
    if configs[name] and not rememberOverwrite then return end
    doSave(name)
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
        task.wait(0.5)
        if antilagActive and hideKeycaps then
            hideKeycaps()
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
skSelectorBtn.Text = "Modo SpecialKey: Tween ▾"
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
        specialKeysMode = text
        skSelectorBtn.Text = "Modo SpecialKey: " .. text .. " ▾"
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
            
            -- Traer el NPC_LolMonster a tu posición
            local npc = Workspace:FindFirstChild("NPC_LolMonster", true)
            local npcHrp = npc and npc:FindFirstChild("HumanoidRootPart")
            if npcHrp then
                npcHrp.CFrame = hrp.CFrame
            end
            
            -- Traer NPC5_AttackZone a tu posición y hacerlo el doble de grande
            local attackZone = Workspace:FindFirstChild("NPC5_AttackZone", true)
            if attackZone then
                if attackZone:IsA("BasePart") then
                    attackZone.CFrame = hrp.CFrame
                    attackZone.Size = attackZone.Size * 2
                elseif attackZone:IsA("Model") then
                    if attackZone.PrimaryPart then
                        attackZone:SetPrimaryPartCFrame(hrp.CFrame)
                    end
                    for _, part in pairs(attackZone:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Size = part.Size * 2
                        end
                    end
                end
            end
        end
        npcToggle.Text = "Convertirse en Npc: ON"
        npcToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
        npcToggle.BackgroundColor3 = Color3.fromRGB(35, 60, 35)
        
        -- Hacerte invisible
        if char then 
            for _, p in pairs(char:GetDescendants()) do 
                if p:IsA("BasePart") or p:IsA("Decal") then 
                    p.Transparency = 1 
                end 
            end 
        end
    else
        npcToggle.Text = "Convertirse en Npc: OFF"
        npcToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
        npcToggle.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
        
        -- Restaurar tamaño original de NPC5_AttackZone al desactivar (dividiendo entre 2)
        local attackZone = Workspace:FindFirstChild("NPC5_AttackZone", true)
        if attackZone then
            if attackZone:IsA("BasePart") then
                attackZone.Size = attackZone.Size / 2
            elseif attackZone:IsA("Model") then
                for _, part in pairs(attackZone:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Size = part.Size / 2
                    end
                end
            end
        end
        
        if char then
            for _, p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = 0
                elseif p:IsA("Decal") then p.Transparency = 0 end
            end
            if hrp and originalPosBeforeNpc then hrp.CFrame = originalPosBeforeNpc end
        end
    end
end)

-- ==========================================
-- RUTINA DE CARGA INICIAL: ESCANEO Y LIMPIEZA ACTIVA CADA 3 CFRAMES
-- ==========================================
task.spawn(function()
    local targetNamesToDestroy = {"Hitbox", "MovingWalls", "Arrows", "FanEffects", "Trap_Stage13", "VoidWall_Stage15", "Tsunami", "Twomp"}
    if getgenv and getgenv().DeltaHubSkipAssets then
        if LoadingScreen and LoadingScreen.Parent then LoadingScreen:Destroy() end
        if getgenv().DeltaHubAntilagWasOn then antilagActive = true end
        return
    end
    local hrp = waitAliveHrp(routeCFrames[1])
    if hrp and #routeCFrames > 0 then
        local i = 1
        while i <= #routeCFrames do
            local spot = routeCFrames[i]
            hrp = waitAliveHrp(spot)
            if not hrp then break end
            hrp.CFrame = spot
            local floatBp = Instance.new("BodyPosition")
            floatBp.MaxForce = Vector3.new(400000, 400000, 400000)
            floatBp.Position = hrp.Position
            floatBp.Parent = hrp
            task.wait(0.15)
            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if not hrp.Parent or not hum or hum.Health <= 0 then
                if floatBp then floatBp:Destroy() end
                hrp = waitAliveHrp(spot)
            else
                for _, obj in pairs(Workspace:GetDescendants()) do
                    for _, name in ipairs(targetNamesToDestroy) do
                        if obj.Name == name then pcall(function() obj:Destroy() end) end
                    end
                    if obj.Name == "LavaCollide" then pcall(function() obj:Destroy() end) end
                    if obj.Name == "LavaPart" then
                        pcall(function()
                            for _, child in pairs(obj:GetChildren()) do
                                if child.ClassName == "TouchInterest" then child:Destroy() end
                            end
                            if obj:IsA("BasePart") then obj.CanTouch = false end
                        end)
                    end
                end
                if floatBp then floatBp:Destroy() end
                i = i + 3
            end
        end
        hrp = waitAliveHrp(routeCFrames[1])
        if hrp then hrp.CFrame = routeCFrames[1] end
    end
    if LoadingScreen and LoadingScreen.Parent then LoadingScreen:Destroy() end
    showNotification("¡Activos cargados correctamente!")
end)


-- ==========================================
-- LÓGICA DE RECOGIDA DE SPECIALKEY CON RETORNO A POSICIÓN ORIGINAL
-- ==========================================
local function processSpecialKey(obj, hrp)
    local itemPos = obj.Position or obj:GetPrimaryPartCFrame().Position
    local originalPos = hrp.CFrame
    
    if specialKeysMode == "Tp" then
        showNotification("SpecialKey encontrada haciendo tp a ella")
        hrp.CFrame = CFrame.new(itemPos + Vector3.new(0, 3, 0))
    elseif specialKeysMode == "Tween" then
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
        while hrp and (hrp.Position - itemPos).Magnitude > 4 and autoSpecialKeysActive do
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
    if routeRunning then return end
    routeRunning = true
    StopRouteContainer.Visible = true
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
                
                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Parent = hrp
                
                hrp.CFrame = routeCFrames[1]
                
                local targetObject = nil
                local targetFound = false
                local closestIndex = #routeCFrames
                
                task.spawn(function()
                    while not targetFound and routeRunning and hum.Health > 0 do
                        targetObject = Workspace:FindFirstChild(selectedRealName, true)
                        if targetObject and (targetObject:IsA("BasePart") or (targetObject:IsA("Model") and targetObject.PrimaryPart)) then
                            targetFound = true
                            local objPos = targetObject.Position or targetObject:GetPrimaryPartCFrame().Position
                            local shortestDist = math.huge
                            for idx, cf in ipairs(routeCFrames) do
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
                while currentIndex <= #routeCFrames and routeRunning and hum.Health > 0 do
                    if currentIndex > closestIndex then break end
                    local targetPos = routeCFrames[currentIndex].Position
                    while hrp and (hrp.Position - targetPos).Magnitude > 1 and routeRunning and hum.Health > 0 do
                        bv.Velocity = (targetPos - hrp.Position).Unit * approachSpeed((targetPos - hrp.Position).Magnitude, routeCFrames[i + 1] and (routeCFrames[i + 1].Position - targetPos).Magnitude)
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
                    
                    if #specialKeysQueue > 0 then
                        local keyObj = table.remove(specialKeysQueue, 1)
                        if keyObj and keyObj.Parent then
                            processSpecialKey(keyObj, hrp)
                        end
                    end
                    
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
                        continue
                    else
                        stopRecorridoGeneral()
                        break
                    end
                end
            end
            
            if finishAfterClaim or not infiniteRouteActive then
                stopRecorridoGeneral()
                break
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
-- NAVEGACIÓN Y STEPS GENERALES
-- ==========================================
MinimizeBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; FloatingLogo.Visible = true end)
FloatingLogo.MouseButton1Click:Connect(function() MainFrame.Visible = true; FloatingLogo.Visible = false end)

local function updateTabs(btn, page, title)
    PlayerPage.Visible = false; GamePage.Visible = false; ExtrasPage.Visible = false
    if EventsPage then EventsPage.Visible = false end
    TabPlayerBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 34); TabPlayerBtn.TextColor3 = Color3.fromRGB(160, 160, 175)
    TabGameBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 34); TabGameBtn.TextColor3 = Color3.fromRGB(160, 160, 175)
    TabExtrasBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
    if TabEventsBtn then TabEventsBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 34); TabEventsBtn.TextColor3 = Color3.fromRGB(160, 160, 175) end
    page.Visible = true; SectionTitle.Text = title
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
    if btn ~= TabExtrasBtn then btn.TextColor3 = Color3.fromRGB(240, 240, 245) end
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
        
        -- MODO NPC: Te bloquea arriba de la cabeza, y mueve al NPC y a NPC5_AttackZone contigo en todas direcciones (incluyendo Y)
        if npcModeActive and hrp then
            pcall(function()
                local npc = Workspace:FindFirstChild("NPC_LolMonster", true)
                local npcHrp = npc and npc:FindFirstChild("HumanoidRootPart")
                local head = npc and npc:FindFirstChild("Head")
                
                if npcHrp and head then
                    -- El NPC te sigue en todas direcciones (incluyendo altura Y)
                    npcHrp.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y - 3, hrp.Position.Z) * (npcHrp.CFrame - npcHrp.Position)
                    
                    -- NPC5_AttackZone te sigue exactamente en todas direcciones (eje X, Y, Z)
                    local attackZone = Workspace:FindFirstChild("NPC5_AttackZone", true)
                    if attackZone then
                        if attackZone:IsA("BasePart") then
                            attackZone.CFrame = CFrame.new(hrp.Position) * (attackZone.CFrame - attackZone.Position)
                        elseif attackZone:IsA("Model") and attackZone.PrimaryPart then
                            attackZone:SetPrimaryPartCFrame(CFrame.new(hrp.Position) * (attackZone.PrimaryPart.CFrame - attackZone.PrimaryPart.Position))
                        end
                    end
                    
                    -- Te bloquea y posiciona exactamente arriba de la cabeza del NPC
                    hrp.CFrame = head.CFrame + Vector3.new(0, 3, 0)
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
local eventCoin = false
local eventXp = false
local eventQueue = {}
local eventSeen = {}

function hideKeycaps()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if string.lower(obj.Name) == "keycaps" then
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
    if eventCoin and string.find(n, "coinbattlecoin", 1, true) then
        return "coin"
    end
    if eventXp and string.find(n, "electrifiedkeycap", 1, true) then
        return "xp"
    end
    return nil
end

local function rememberEvent(obj)
    if not obj or eventSeen[obj] then return nil end
    local kind = eventKind(obj.Name)
    if not kind then return nil end
    local pos = objectPosition(obj)
    if not pos then return nil end
    eventSeen[obj] = true
    if kind == "xp" then restoreKeycap(obj) end
    table.insert(eventQueue, {obj = obj, pos = pos, kind = kind})
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
local btnCoin = eventButton("Auto Battle Coin", 2)
local btnXp = eventButton("Auto XP Event Key", 3)

local function paintEvent(btn, on, label)
    btn.Text = label .. (on and ": ON" or ": OFF")
    btn.TextColor3 = on and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    btn.BackgroundColor3 = on and Color3.fromRGB(35, 60, 35) or Color3.fromRGB(26, 26, 34)
end

btnChocolate.MouseButton1Click:Connect(function()
    eventChocolate = not eventChocolate
    paintEvent(btnChocolate, eventChocolate, "Auto Chocolate Hunt")
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
        local anyOn = eventChocolate or eventCoin or eventXp
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
                        hrp.CFrame = CFrame.new(first.pos + Vector3.new(0, 3, 0))
                        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
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
                    else
                        local bv = hrp:FindFirstChild("DeltaEventBV")
                        if bv then bv:Destroy() end
                    end
                end
            end
        end
    end
end)

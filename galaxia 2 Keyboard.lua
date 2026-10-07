-- ==========================================
-- DELTA HUB - SCRIPT FINAL CORREGIDO (PLAYERGUI)
-- ==========================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ==========================================
-- 0. LIMPIEZA INICIAL DE OBJETOS Y LAVA (DE FÁBRICA)
-- ==========================================
local targetNamesToDestroy = {"ReversePad", "MeteorArea", "EyesLaser", "JumpWall", "Tsunami", "Tsunami1", "LavaTower", "Hitbox", "NPC20", "Laser", "NPC20_AttackZone"}
for _, obj in pairs(Workspace:GetDescendants()) do
    for _, name in ipairs(targetNamesToDestroy) do
        if obj.Name == name then
            pcall(function() obj:Destroy() end)
        end
    end
end

-- Borrar TouchInterests y desactivar CanTouch en objetos Lava / lava
for _, obj in pairs(Workspace:GetDescendants()) do
    local lowerName = string.lower(obj.Name)
    if lowerName == "lava" then
        pcall(function()
            for _, child in pairs(obj:GetChildren()) do
                if child.ClassName == "TouchInterest" then
                    child:Destroy()
                end
            end
            if obj:IsA("BasePart") then
                obj.CanTouch = false
            end
        end)
    end
end

if playerGui:FindFirstChild("DeltaHubMinimal") then
    playerGui.DeltaHubMinimal:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaHubMinimal"
ScreenGui.Parent = playerGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

-- ==========================================
-- PANTALLA NEGRA DE CARGA QUE ABARCA TODA LA PANTALLA
-- ==========================================
local LoadingScreen = Instance.new("Frame")
LoadingScreen.Name = "LoadingScreen"
LoadingScreen.Parent = ScreenGui
LoadingScreen.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LoadingScreen.Position = UDim2.new(0, 0, 0, 0)
LoadingScreen.Size = UDim2.new(1, 0, 1, 0)
LoadingScreen.ZIndex = 9999

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
    CFrame.new(-440.38330078125, 361.92694091796875, -759.8446044921875),
    CFrame.new(-130.13021850585938, 361.3833923339844, -760.8226318359375),
    CFrame.new(102.61224365234375, 361.39892578125, -760.7482299804688),
    CFrame.new(463.5228576660156, 361.3988952636719, -760.4751586914062),
    CFrame.new(781.8070068359375, 361.39837646484375, -759.7503051757812),
    CFrame.new(1141.7806396484375, 361.39764404296875, -759.6134033203125),
    CFrame.new(1277.7493896484375, 361.4492492675781, -756.4906616210938),
    CFrame.new(1297.6243896484375, 361.015625, -713.5008544921875),
    CFrame.new(1403.256103515625, 361.3271484375, -724.1265258789062),
    CFrame.new(1559.3822021484375, 361.9882507324219, -759.294677734375),
    CFrame.new(1628.4879150390625, 361.0229797363281, -774.3330688476562),
    CFrame.new(1739.0810546875, 365.5611572265625, -815.9473266601562),
    CFrame.new(2004.09716796875, 364.81549072265625, -816.4194946289062),
    CFrame.new(2079.80126953125, 361.04034423828125, -783.0150146484375),
    CFrame.new(2137.33154296875, 364.9627990722656, -810.2340087890625),
    CFrame.new(2394.031982421875, 366.2619934082031, -810.7460327148438),
    CFrame.new(2456.599853515625, 361.78863525390625, -760.1548461914062),
    CFrame.new(2565.0771484375, 361.78863525390625, -759.7837524414062),
    CFrame.new(2776.43408203125, 837.8399047851562, -759.7169189453125),
    CFrame.new(2828.546142578125, 837.8399047851562, -759.8732299804688),
    CFrame.new(3705.980224609375, 844.3345336914062, -761.0584716796875),
    CFrame.new(3705.980224609375, 729.8399047851562, -761.0584716796875),
    CFrame.new(3726.34375, 729.8399047851562, -759.70849609375),
    CFrame.new(4511.1708984375, 729.13134765625, -759.2071533203125),
    CFrame.new(4872.0771484375, 729.13134765625, -760.1740112304688),
    CFrame.new(6050.4501953125, 719.1561889648438, -759.3504638671875),
    CFrame.new(7054.529296875, 719.1592407226562, -759.0474243164062),
    CFrame.new(7072.26123046875, 719.1592407226562, -759.3761596679688),
    CFrame.new(7281.005859375, 663.6329956054688, -760.5911254882812),
    CFrame.new(8216.5498046875, 663.6351318359375, -759.349609375),
    CFrame.new(8379.78515625, 663.6180419921875, -760.164306640625),
    CFrame.new(8459.8525390625, 679.3387451171875, -760.4544677734375),
    CFrame.new(8541.248046875, 663.6180419921875, -759.7352905273438),
    CFrame.new(8983.1181640625, 663.6180419921875, -759.728271484375),
    CFrame.new(9056.5302734375, 678.7879638671875, -760.2889404296875),
    CFrame.new(9143.6484375, 663.6180419921875, -759.6319580078125),
    CFrame.new(9262.5146484375, 663.6226806640625, -759.2718505859375),
    CFrame.new(10566.734375, 663.0563354492188, -760.960693359375),
    CFrame.new(11202.3046875, 638.2919921875, -760.2417602539062),
    CFrame.new(11315.927734375, 638.2919921875, -759.7529907226562),
    CFrame.new(11414.8388671875, 608.3887329101562, -761.3040161132812),
    CFrame.new(11541.4169921875, 608.3922729492188, -759.5479125976562),
    CFrame.new(11566.38671875, 609.4844360351562, -759.0453491210938),
    CFrame.new(11684.69921875, 609.4865112304688, -761.5023803710938),
    CFrame.new(11716.7880859375, 611.7996215820312, -761.750244140625),
    CFrame.new(11741.4384765625, 621.2305908203125, -761.7488403320312),
    CFrame.new(11765.333984375, 637.152099609375, -761.5225219726562),
    CFrame.new(11792.8662109375, 652.941162109375, -761.662353515625),
    CFrame.new(11822.3154296875, 665.982421875, -762.25146484375),
    CFrame.new(11865.81640625, 679.0281982421875, -762.2486572265625),
    CFrame.new(11909.8955078125, 685.5263671875, -762.2811889648438),
    CFrame.new(11971.763671875, 686.2445068359375, -762.1334838867188),
    CFrame.new(12221.97265625, 585.2445068359375, -760.0919799804688),
    CFrame.new(14179.33984375, 585.5997314453125, -760.1315307617188),
    CFrame.new(14788.927734375, 576.699951171875, -761.97900390625),
    CFrame.new(15097.1396484375, 610.1297607421875, -760.3917846679688),
    CFrame.new(15116.7431640625, 610.49658203125, -760.1701049804688),
    CFrame.new(15189.39453125, 610.4378051757812, -760.591552734375),
    CFrame.new(15216.447265625, 613.7432861328125, -761.0140380859375),
    CFrame.new(15240.0517578125, 628.7255859375, -761.2734985351562),
    CFrame.new(15252.8349609375, 648.4100952148438, -761.8596801757812),
    CFrame.new(15257.01953125, 671.851318359375, -762.2672729492188),
    CFrame.new(15257.0205078125, 2699.50341796875, -761.6668701171875),
    CFrame.new(15287.9189453125, 2760.457275390625, -759.0579223632812),
    CFrame.new(15287.412109375, 2705.197021484375, -759.059326171875),
    CFrame.new(15396.9208984375, 2705.218505859375, -761.7806396484375),
    CFrame.new(16470.859375, 2704.299072265625, -760.9381103515625),
    CFrame.new(16541.8046875, 2712.464111328125, -761.35888671875),
    CFrame.new(16876.66796875, 2704.299072265625, -759.4518432617188),
    CFrame.new(16985.974609375, 2812.8984375, -760.7992553710938),
    CFrame.new(17240.263671875, 2812.895263671875, -759.5662231445312),
    CFrame.new(18024.396484375, 2812.886474609375, -223.57559204101562),
    CFrame.new(18023.5234375, 2812.886474609375, 1761.0914306640625)
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
    {real = "WinBlock16", display = "+350K Wins", order = 16},
    {real = "WinBlock17", display = "+1M Wins", order = 17},
    {real = "WinBlock18", display = "+2.5M Wins", order = 18},
    {real = "WinBlock19", display = "+6.5M Wins", order = 19},
    {real = "WinBlock20", display = "+15M Wins", order = 20},
}

local selectedRealName = "WinBlock1"
local selectedDisplayName = "+1 Win"
local gameSpeed = 250
local function approachSpeed(distance)
    local maxSpeed = math.clamp(gameSpeed or 250, 1, 500)
    if distance >= 18 then
        return maxSpeed
    end
    local t = math.clamp(distance / 18, 0, 1)
    return math.max(maxSpeed * t * t, 12)
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
selectorBtn.Text = "Seleccionar Win: +1 Win ▾"
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

local function stopRecorridoGeneral()
    routeRunning = false
    StopRouteContainer.Visible = false
    noClipEnabled = false
    noclipToggle.Text = "Noclip: OFF"
    noclipToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
    noclipToggle.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
    startRouteBtn.Text = "Iniciar Recorrido: OFF"
    startRouteBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    startRouteBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
end

StopRouteFloatingBtn.MouseButton1Click:Connect(function()
    stopRecorridoGeneral()
    showNotification("Recorrido terminado. Completará la vuelta actual.")
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
    if antilagActive then
        antilagToggle.Text = "Antilag: ON"
        antilagToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
        antilagToggle.BackgroundColor3 = Color3.fromRGB(35, 60, 35)
        pcall(function() Lighting.GlobalShadows = false; Lighting.Brightness = 2 end)
        local antilagTargets = {"Decorations", "Props", "Halloween", "HallowenMeshes", "ReversePad", "MeteorArea", "EyesLaser", "JumpWall", "Tsunami", "Tsunami1", "LavaTower", "Hitbox", "NPC20", "Laser", "NPC20_AttackZone"}
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

-- ==========================================
-- RUTINA DE CARGA INICIAL: RECORRIDO DE 3 EN 3 CFRAMES PARA LIMPIAR LAVA
-- ==========================================
task.spawn(function()
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    
    if hrp and #routeCFrames > 0 then
        for i = 1, #routeCFrames, 3 do
            hrp.CFrame = routeCFrames[i]
            
            local floatBp = Instance.new("BodyPosition")
            floatBp.MaxForce = Vector3.new(400000, 400000, 400000)
            floatBp.Position = hrp.Position
            floatBp.Parent = hrp
            
            task.wait(0.15)
            
            for _, obj in pairs(Workspace:GetDescendants()) do
                local lowerName = string.lower(obj.Name)
                if lowerName == "lava" then
                    pcall(function()
                        for _, child in pairs(obj:GetChildren()) do
                            if child.ClassName == "TouchInterest" then
                                child:Destroy()
                            end
                        end
                        if obj:IsA("BasePart") then
                            obj.CanTouch = false
                        end
                    end)
                end
            end
            
            if floatBp then floatBp:Destroy() end
        end
        
        hrp.CFrame = routeCFrames[1]
    end
    
    if LoadingScreen and LoadingScreen.Parent then
        LoadingScreen:Destroy()
    end
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
                bv.Velocity = (targetPos - hrp.Position).Unit * approachSpeed((targetPos - hrp.Position).Magnitude)
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
                        bv.Velocity = (targetPos - hrp.Position).Unit * approachSpeed((targetPos - hrp.Position).Magnitude)
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
                    while hrp and (hrp.Position - objPos).Magnitude > 3 and routeRunning and hum.Health > 0 do
                        bv.Velocity = (objPos - hrp.Position).Unit * approachSpeed((objPos - hrp.Position).Magnitude)
                        RunService.Stepped:Wait()
                    end
                end
                
                if bv then bv:Destroy() end
                pcall(function() task.cancel(lifeMonitor) end)
                
                if routeRunning and hum.Health > 0 then
                    -- Espera exacta de 0.67 segundos para dar tiempo al SpawnLocation del WinBlock
                    task.wait(0.67)
                    
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
                    local choice = nil
                    
                    local connYes, connNo
                    connYes = YesBtn.MouseButton1Click:Connect(function() choice = true; connYes:Disconnect(); connNo:Disconnect() end)
                    connNo = NoBtn.MouseButton1Click:Connect(function() choice = false; connYes:Disconnect(); connNo:Disconnect() end)
                    
                    while choice == nil and routeRunning do task.wait(0.2) end
                    PromptContainer.Visible = false
                    
                    if choice == true then
                        player.CharacterAdded:Wait()
                        task.wait(0.5)
                        continue
                    else
                        stopRecorridoGeneral()
                        break
                    end
                end
            end
            
            if not infiniteRouteActive then
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

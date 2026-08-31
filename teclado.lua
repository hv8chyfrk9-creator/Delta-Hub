-- Servicios necesarios
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer

-- Limpiar interfaz anterior si existe
if CoreGui:FindFirstChild("DeltaHubCustom") then
    CoreGui.DeltaHubCustom:Destroy()
end

----------------------------------------------------
-- 2. ANTI-DAÑO AUTOMÁTICO, LAVA Y MOVING WALLS
----------------------------------------------------
local function cleanObject(obj)
    pcall(function()
        local nameLower = string.lower(obj.Name)
        if string.find(nameLower, "lava") or string.find(nameLower, "movingwall") then
            obj:Destroy()
            return
        end
        if nameLower == "hitbox" then
            local parent = obj.Parent
            if parent and string.lower(parent.Name):find("npc") then
                obj:Destroy()
            end
        end
    end)
end

-- Limpieza inicial única
pcall(function()
    for _, obj in pairs(Workspace:GetDescendants()) do
        cleanObject(obj)
    end
end)

-- Conexión dinámica en lugar de bucle while true pesado
Workspace.DescendantAdded:Connect(function(obj)
    cleanObject(obj)
end)

-- Creación de la Interfaz Principal (ScreenGui)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaHubCustom"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MaximizeBtn = Instance.new("TextButton")
MaximizeBtn.Name = "MaximizeBtn"
MaximizeBtn.Parent = ScreenGui
MaximizeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
MaximizeBtn.Position = UDim2.new(0.5, -20, 0, 10)
MaximizeBtn.Size = UDim2.new(0, 40, 0, 40)
MaximizeBtn.Font = Enum.Font.GothamBold
MaximizeBtn.Text = "+"
MaximizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MaximizeBtn.TextSize = 20
MaximizeBtn.Visible = false
Instance.new("UICorner", MaximizeBtn).CornerRadius = UDim.new(1, 0)

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -175)
MainFrame.Size = UDim2.new(0, 480, 0, 350)
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
TopBar.BorderSizePixel = 0
TopBar.Size = UDim2.new(1, 0, 0, 35)
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)

local TopBarFix = Instance.new("Frame")
TopBarFix.Parent = TopBar
TopBarFix.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
TopBarFix.BorderSizePixel = 0
TopBarFix.Position = UDim2.new(0, 0, 1, -5)
TopBarFix.Size = UDim2.new(1, 0, 0, 5)

local Title = Instance.new("TextLabel")
Title.Parent = TopBar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Size = UDim2.new(0, 250, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "Delta Hub | Escapa del Teclado"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Parent = TopBar
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
MinimizeBtn.Position = UDim2.new(1, -30, 0, 6)
MinimizeBtn.Size = UDim2.new(0, 24, 0, 24)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 14
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 4)

MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    MaximizeBtn.Visible = true
end)

MaximizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    MaximizeBtn.Visible = false
end)

local Container = Instance.new("Frame")
Container.Name = "Container"
Container.Parent = MainFrame
Container.BackgroundTransparency = 1
Container.Position = UDim2.new(0, 0, 0, 35)
Container.Size = UDim2.new(1, 0, 1, -35)

local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Parent = Container
Sidebar.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
Sidebar.BorderSizePixel = 0
Sidebar.Size = UDim2.new(0, 130, 1, 0)

local UIListSidebar = Instance.new("UIListLayout")
UIListSidebar.Parent = Sidebar
UIListSidebar.SortOrder = Enum.SortOrder.LayoutOrder
UIListSidebar.Padding = UDim.new(0, 10)
UIListSidebar.HorizontalAlignment = Enum.HorizontalAlignment.Center

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.Parent = Sidebar
SidebarPadding.PaddingTop = UDim.new(0, 10)

local Tab1Btn = Instance.new("TextButton")
Tab1Btn.Parent = Sidebar
Tab1Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
Tab1Btn.Size = UDim2.new(1, -16, 0, 35)
Tab1Btn.Font = Enum.Font.GothamBold
Tab1Btn.Text = "Configuración"
Tab1Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
Tab1Btn.TextSize = 12
Instance.new("UICorner", Tab1Btn).CornerRadius = UDim.new(0, 4)

local Tab2Btn = Instance.new("TextButton")
Tab2Btn.Parent = Sidebar
Tab2Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Tab2Btn.Size = UDim2.new(1, -16, 0, 35)
Tab2Btn.Font = Enum.Font.GothamBold
Tab2Btn.Text = "Grabador"
Tab2Btn.TextColor3 = Color3.fromRGB(170, 170, 170)
Tab2Btn.TextSize = 12
Instance.new("UICorner", Tab2Btn).CornerRadius = UDim.new(0, 4)

local PagesFrame = Instance.new("Frame")
PagesFrame.Name = "PagesFrame"
PagesFrame.Parent = Container
PagesFrame.BackgroundTransparency = 1
PagesFrame.Position = UDim2.new(0, 130, 0, 0)
PagesFrame.Size = UDim2.new(1, -130, 1, 0)

local ConfigPage = Instance.new("ScrollingFrame")
ConfigPage.Name = "ConfigPage"
ConfigPage.Parent = PagesFrame
ConfigPage.BackgroundTransparency = 1
ConfigPage.Position = UDim2.new(0, 10, 0, 10)
ConfigPage.Size = UDim2.new(1, -20, 1, -20)
ConfigPage.CanvasSize = UDim2.new(0, 0, 0, 550)
ConfigPage.ScrollBarThickness = 4

local UIListConfig = Instance.new("UIListLayout")
UIListConfig.Parent = ConfigPage
UIListConfig.SortOrder = Enum.SortOrder.LayoutOrder
UIListConfig.Padding = UDim.new(0, 10)

local GamePage = Instance.new("ScrollingFrame")
GamePage.Name = "GamePage"
GamePage.Parent = PagesFrame
GamePage.BackgroundTransparency = 1
GamePage.Position = UDim2.new(0, 10, 0, 10)
GamePage.Size = UDim2.new(1, -20, 1, -20)
GamePage.CanvasSize = UDim2.new(0, 0, 0, 1350)
GamePage.ScrollBarThickness = 4
GamePage.Visible = false

local UIListGame = Instance.new("UIListLayout")
UIListGame.Parent = GamePage
UIListGame.SortOrder = Enum.SortOrder.LayoutOrder
UIListGame.Padding = UDim.new(0, 10)

Tab1Btn.MouseButton1Click:Connect(function()
    ConfigPage.Visible = true
    GamePage.Visible = false
    Tab1Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    Tab1Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Tab2Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    Tab2Btn.TextColor3 = Color3.fromRGB(170, 170, 170)
end)

Tab2Btn.MouseButton1Click:Connect(function()
    ConfigPage.Visible = false
    GamePage.Visible = true
    Tab2Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    Tab2Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Tab1Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    Tab1Btn.TextColor3 = Color3.fromRGB(170, 170, 170)
end)

----------------------------------------------------
-- CONFIGURACIÓN
----------------------------------------------------
local speedEnabled = false
local currentSpeed = 16
local originalWalkSpeed = nil

local jumpEnabled = false
local currentJump = 50
local originalUseJumpPower = nil
local originalJumpPower = nil

local noClipEnabled = false
local infiniteJumpEnabled = false
local antiLagEnabled = false

local function createLabel(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Parent = parent
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    return lbl
end

createLabel(ConfigPage, "Velocidad Normal:")
local speedBox = Instance.new("TextBox")
speedBox.Parent = ConfigPage
speedBox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
speedBox.Size = UDim2.new(1, 0, 0, 30)
speedBox.Font = Enum.Font.Gotham
speedBox.PlaceholderText = "Ej. 16"
speedBox.Text = ""
speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBox.TextSize = 12
Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 4)

speedBox.FocusLost:Connect(function()
    local val = tonumber(speedBox.Text)
    if val then
        currentSpeed = math.clamp(val, 1, 500)
        speedBox.Text = tostring(currentSpeed)
    end
end)

local speedToggle = Instance.new("TextButton")
speedToggle.Parent = ConfigPage
speedToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
speedToggle.Size = UDim2.new(1, 0, 0, 30)
speedToggle.Font = Enum.Font.GothamBold
speedToggle.Text = "Activar Velocidad: OFF"
speedToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
speedToggle.TextSize = 12
Instance.new("UICorner", speedToggle).CornerRadius = UDim.new(0, 4)

speedToggle.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if speedEnabled then
        if hum then
            originalWalkSpeed = hum.WalkSpeed
        end
        speedToggle.Text = "Activar Velocidad: ON"
        speedToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
        speedToggle.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
    else
        if hum and originalWalkSpeed then
            hum.WalkSpeed = originalWalkSpeed
        end
        speedToggle.Text = "Activar Velocidad: OFF"
        speedToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
        speedToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    end
end)

createLabel(ConfigPage, "Potencia de Salto (1 - 500):")
local jumpBox = Instance.new("TextBox")
jumpBox.Parent = ConfigPage
jumpBox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
jumpBox.Size = UDim2.new(1, 0, 0, 30)
jumpBox.Font = Enum.Font.Gotham
jumpBox.PlaceholderText = "Ej. 50"
jumpBox.Text = ""
jumpBox.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpBox.TextSize = 12
Instance.new("UICorner", jumpBox).CornerRadius = UDim.new(0, 4)

jumpBox.FocusLost:Connect(function()
    local val = tonumber(jumpBox.Text)
    if val then
        currentJump = math.clamp(val, 1, 500)
        jumpBox.Text = tostring(currentJump)
    end
end)

local jumpToggle = Instance.new("TextButton")
jumpToggle.Parent = ConfigPage
jumpToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
jumpToggle.Size = UDim2.new(1, 0, 0, 30)
jumpToggle.Font = Enum.Font.GothamBold
jumpToggle.Text = "Activar Salto: OFF"
jumpToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
jumpToggle.TextSize = 12
Instance.new("UICorner", jumpToggle).CornerRadius = UDim.new(0, 4)

jumpToggle.MouseButton1Click:Connect(function()
    jumpEnabled = not jumpEnabled
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if jumpEnabled then
        if hum then
            originalUseJumpPower = hum.UseJumpPower
            originalJumpPower = hum.JumpPower
        end
        jumpToggle.Text = "Activar Salto: ON"
        jumpToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
        jumpToggle.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
    else
        if hum then
            if originalUseJumpPower ~= nil then hum.UseJumpPower = originalUseJumpPower end
            if originalJumpPower ~= nil then hum.JumpPower = originalJumpPower end
        end
        jumpToggle.Text = "Activar Salto: OFF"
        jumpToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
        jumpToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    end
end)

local infJumpToggle = Instance.new("TextButton")
infJumpToggle.Parent = ConfigPage
infJumpToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
infJumpToggle.Size = UDim2.new(1, 0, 0, 30)
infJumpToggle.Font = Enum.Font.GothamBold
infJumpToggle.Text = "Salto Infinito: OFF"
infJumpToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
infJumpToggle.TextSize = 12
Instance.new("UICorner", infJumpToggle).CornerRadius = UDim.new(0, 4)

infJumpToggle.MouseButton1Click:Connect(function()
    infiniteJumpEnabled = not infiniteJumpEnabled
    if infiniteJumpEnabled then
        infJumpToggle.Text = "Salto Infinito: ON"
        infJumpToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
        infJumpToggle.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
    else
        infJumpToggle.Text = "Salto Infinito: OFF"
        infJumpToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
        infJumpToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    end
end)

UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled then
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

local noclipBtn = Instance.new("TextButton")
noclipBtn.Parent = ConfigPage
noclipBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
noclipBtn.Size = UDim2.new(1, 0, 0, 30)
noclipBtn.Font = Enum.Font.GothamBold
noclipBtn.Text = "NoClip Global: OFF"
noclipBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
noclipBtn.TextSize = 12
Instance.new("UICorner", noclipBtn).CornerRadius = UDim.new(0, 4)

noclipBtn.MouseButton1Click:Connect(function()
    noClipEnabled = not noClipEnabled
    if noClipEnabled then
        noclipBtn.Text = "NoClip Global: ON"
        noclipBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        noclipBtn.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
    else
        noclipBtn.Text = "NoClip Global: OFF"
        noclipBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        noclipBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    end
end)

local antiLagToggle = Instance.new("TextButton")
antiLagToggle.Parent = ConfigPage
antiLagToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
antiLagToggle.Size = UDim2.new(1, 0, 0, 30)
antiLagToggle.Font = Enum.Font.GothamBold
antiLagToggle.Text = "Anti-Lag Extremo & Key Caps: OFF"
antiLagToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
antiLagToggle.TextSize = 11
Instance.new("UICorner", antiLagToggle).CornerRadius = UDim.new(0, 4)

local originalMaterials = {}

antiLagToggle.MouseButton1Click:Connect(function()
    antiLagEnabled = not antiLagEnabled
    if antiLagEnabled then
        antiLagToggle.Text = "Anti-Lag Extremo & Key Caps: ON"
        antiLagToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
        antiLagToggle.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
        
        task.spawn(function()
            for _, obj in pairs(Workspace:GetDescendants()) do
                local nameLower = string.lower(obj.Name)
                if nameLower == "floatfolder" or string.find(obj.Name, "Keycap", 1, true) then
                    obj:Destroy()
                else
                    if obj:IsA("BasePart") then
                        if not originalMaterials[obj] then
                            originalMaterials[obj] = obj.Material
                        end
                        obj.Material = Enum.Material.SmoothPlastic
                    end
                end
            end
        end)
    else
        antiLagToggle.Text = "Anti-Lag Extremo & Key Caps: OFF"
        antiLagToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
        antiLagToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        
        task.spawn(function()
            for obj, mat in pairs(originalMaterials) do
                if obj and obj.Parent then
                    obj.Material = mat
                end
            end
        end)
    end
end)

RunService.Stepped:Connect(function()
    local char = player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            if speedEnabled then hum.WalkSpeed = currentSpeed end
            if jumpEnabled then 
                hum.UseJumpPower = true
                hum.JumpPower = currentJump 
            end
        end
        if noClipEnabled then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

----------------------------------------------------
-- GAMEPLAY & REPRODUCTOR DE WINS (NUEVOS RECORRIDOS ACUMULATIVOS)
----------------------------------------------------
local mundoCoordinates = {
    ["Check 1"] = {CFrame = CFrame.new(-1457.01, -159.04, -995.58), Name = "Check 1", Index = 1},
    ["Check 2"] = {CFrame = CFrame.new(-1454.13, -160.68, -866.26), Name = "Check 2", Index = 2},
    ["Check 3"] = {CFrame = CFrame.new(-1429.06, -161.35, -859.59), Name = "Check 3", Index = 3},
    ["WinBlock32"] = {CFrame = CFrame.new(-1424.62, -69.54, -535.65), Name = "WinBlock32", Index = 4},
    ["WinBlock33"] = {CFrame = CFrame.new(-1452.24, -57.30, -13.76), Name = "WinBlock33", Index = 5},
    ["Check 6"] = {CFrame = CFrame.new(-1446.47, 214.96, 102.78), Name = "Check 6", Index = 6},
    ["WinBlock34"] = {CFrame = CFrame.new(-1452.94, 214.71, 331.86), Name = "WinBlock34", Index = 7},
    ["Check 8"] = {CFrame = CFrame.new(-1452.77, 214.71, 627.39), Name = "Check 8", Index = 8},
    ["Check 9"] = {CFrame = CFrame.new(-1452.84, 375.07, 627.82), Name = "Check 9", Index = 9},
    ["Check 10"] = {CFrame = CFrame.new(-1406.34, 373.75, 724.71), Name = "Check 10", Index = 10},
    ["Check 11"] = {CFrame = CFrame.new(-1406.21, 542.43, 724.63), Name = "Check 11", Index = 11},
    ["WinBlock35"] = {CFrame = CFrame.new(-1403.21, 532.72, 764.47), Name = "WinBlock35", Index = 12},
    ["Check 13"] = {CFrame = CFrame.new(-1403.59, 572.57, 840.81), Name = "Check 13", Index = 13},
    ["Check 14"] = {CFrame = CFrame.new(-1401.34, 568.12, 1279.96), Name = "Check 14", Index = 14},
    ["Check 15"] = {CFrame = CFrame.new(-1404.94, 532.72, 1336.26), Name = "Check 15", Index = 15},
    ["WinBlock36"] = {CFrame = CFrame.new(-1415.26, 532.72, 1328.72), Name = "WinBlock36", Index = 16},
    ["Check 17"] = {CFrame = CFrame.new(-1418.55, 532.72, 1444.72), Name = "Check 17", Index = 17},
    ["Check 18"] = {CFrame = CFrame.new(-1464.45, 508.72, 1445.54), Name = "Check 18", Index = 18},
    ["Check 19"] = {CFrame = CFrame.new(-2060.08, 507.48, 1446.34), Name = "Check 19", Index = 19},
    ["WinBlock37"] = {CFrame = CFrame.new(-2066.29, 442.72, 1483.72), Name = "WinBlock37", Index = 20},
    ["Check 21"] = {CFrame = CFrame.new(-2170.62, 451.59, 1486.40), Name = "Check 21", Index = 21},
    ["Check 22"] = {CFrame = CFrame.new(-2361.55, 447.72, 1483.10), Name = "Check 22", Index = 22},
    ["Check 23"] = {CFrame = CFrame.new(-2549.23, 465.28, 1482.54), Name = "Check 23", Index = 23},
    ["Check 24"] = {CFrame = CFrame.new(-2865.76, 499.08, 1486.15), Name = "Check 24", Index = 24},
    ["Check 25"] = {CFrame = CFrame.new(-2895.08, 524.15, 1488.26), Name = "Check 25", Index = 25},
    ["Check 26"] = {CFrame = CFrame.new(-2920.23, 520.90, 1482.62), Name = "Check 26", Index = 26},
    ["Check 27"] = {CFrame = CFrame.new(-2971.24, 598.60, 1479.33), Name = "Check 27", Index = 27},
    ["Check 28"] = {CFrame = CFrame.new(-3007.71, 598.27, 1486.84), Name = "Check 28", Index = 28},
    ["Check 29"] = {CFrame = CFrame.new(-3051.79, 678.35, 1483.46), Name = "Check 29", Index = 29},
    ["WinBlock38"] = {CFrame = CFrame.new(-3214.58, 672.23, 1485.70), Name = "WinBlock38", Index = 30},
    ["Check 31"] = {CFrame = CFrame.new(-3242.50, 672.23, 1485.28), Name = "Check 31", Index = 31},
    ["WinBlock39"] = {CFrame = CFrame.new(-3635.40, 616.57, 1487.51), Name = "WinBlock39", Index = 32},
    ["DeleteMovingWalls"] = {CFrame = CFrame.new(-3678.52, 616.57, 1484.52), Name = "DeleteMovingWalls", Index = 33},
    ["WinBlock40"] = {CFrame = CFrame.new(-4129.89, 616.57, 1485.00), Name = "WinBlock40", Index = 34},
    ["Check 35"] = {CFrame = CFrame.new(-4179.17, 615.42, 1485.02), Name = "Check 35", Index = 35},
    ["WinBlock41"] = {CFrame = CFrame.new(-4963.60, 616.58, 1484.45), Name = "WinBlock41", Index = 36},
    ["Check 37"] = {CFrame = CFrame.new(-5075.15, 625.33, 1487.43), Name = "Check 37", Index = 37},
    ["Check 38"] = {CFrame = CFrame.new(-5174.70, 676.08, 1478.71), Name = "Check 38", Index = 38},
    ["Check 39"] = {CFrame = CFrame.new(-5254.81, 684.30, 1485.26), Name = "Check 39", Index = 39},
    ["Check 40"] = {CFrame = CFrame.new(-5350.31, 685.81, 1498.25), Name = "Check 40", Index = 40},
    ["Check 41"] = {CFrame = CFrame.new(-5351.64, 732.28, 1497.75), Name = "Check 41", Index = 41},
    ["Check 42"] = {CFrame = CFrame.new(-5434.03, 743.12, 1490.36), Name = "Check 42", Index = 42},
    ["Check 43"] = {CFrame = CFrame.new(-5529.95, 743.16, 1487.80), Name = "Check 43", Index = 43},
    ["Check 44"] = {CFrame = CFrame.new(-5531.66, 802.47, 1487.38), Name = "Check 44", Index = 44},
    ["Check 45"] = {CFrame = CFrame.new(-5618.35, 802.01, 1484.20), Name = "Check 45", Index = 45},
    ["Check 46"] = {CFrame = CFrame.new(-5710.37, 801.54, 1485.99), Name = "Check 46", Index = 46},
    ["Check 47"] = {CFrame = CFrame.new(-5711.84, 861.79, 1485.97), Name = "Check 47", Index = 47},
    ["WinBlock42"] = {CFrame = CFrame.new(-5738.87, 851.59, 1485.31), Name = "WinBlock42", Index = 48},
    ["Check 49"] = {CFrame = CFrame.new(-5763.28, 851.59, 1483.11), Name = "Check 49", Index = 49},
    ["Check 50"] = {CFrame = CFrame.new(-5856.32, 850.32, 1480.37), Name = "Check 50", Index = 50},
    ["Check 51"] = {CFrame = CFrame.new(-5969.47, 850.32, 1365.51), Name = "Check 51", Index = 51},
    ["Check 52"] = {CFrame = CFrame.new(-6203.47, 850.32, 1600.17), Name = "Check 52", Index = 52},
    ["Check 53"] = {CFrame = CFrame.new(-6424.06, 850.32, 1371.28), Name = "Check 53", Index = 53},
    ["Check 54"] = {CFrame = CFrame.new(-6545.06, 850.32, 1483.27), Name = "Check 54", Index = 54},
    ["WinBlock43"] = {CFrame = CFrame.new(-6656.58, 851.60, 1481.67), Name = "WinBlock43", Index = 55},
    ["WinBlock44"] = {CFrame = CFrame.new(-9514.86, 851.60, 1485.95), Name = "WinBlock44", Index = 56},
    ["Check 57"] = {CFrame = CFrame.new(-9621.40, 860.35, 1487.07), Name = "Check 57", Index = 57},
    ["Check 58"] = {CFrame = CFrame.new(-9815.77, 860.41, 1483.23), Name = "Check 58", Index = 58},
    ["Check 59"] = {CFrame = CFrame.new(-10209.31, 860.24, 1482.81), Name = "Check 59", Index = 59},
    ["Check 60"] = {CFrame = CFrame.new(-10403.26, 860.58, 1482.43), Name = "Check 60", Index = 60},
    ["Check 61"] = {CFrame = CFrame.new(-10708.00, 857.29, 1483.09), Name = "Check 61", Index = 61},
    ["WinBlock45"] = {CFrame = CFrame.new(-10809.08, 851.60, 1483.35), Name = "WinBlock45", Index = 62},
}

-- Organizar puntos ordenados por Index para construcción acumulativa
local orderedPoints = {}
for _, data in pairs(mundoCoordinates) do
    orderedPoints[data.Index] = data.CFrame.Position
end

local function getRangePositions(maxIndex)
    local list = {}
    for i = 1, maxIndex do
        if orderedPoints[i] then
            table.insert(list, orderedPoints[i])
        end
    end
    return list
end

_G.RecordedPaths = {
    ["WinBlock32"] = getRangePositions(4),
    ["WinBlock33"] = getRangePositions(5),
    ["WinBlock34"] = getRangePositions(7),
    ["WinBlock35"] = getRangePositions(12),
    ["WinBlock36"] = getRangePositions(16),
    ["WinBlock37"] = getRangePositions(20),
    ["WinBlock38"] = getRangePositions(30),
    ["WinBlock39"] = getRangePositions(32),
    ["WinBlock40"] = getRangePositions(34),
    ["WinBlock41"] = getRangePositions(36),
    ["WinBlock42"] = getRangePositions(48),
    ["WinBlock43"] = getRangePositions(55),
    ["WinBlock44"] = getRangePositions(56),
    ["WinBlock45"] = getRangePositions(62),
}

local winsContainer = Instance.new("Frame")
winsContainer.Parent = GamePage
winsContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
winsContainer.Size = UDim2.new(1, 0, 0, 35)
winsContainer.BorderSizePixel = 0
Instance.new("UICorner", winsContainer).CornerRadius = UDim.new(0, 4)

local winsText = Instance.new("TextLabel")
winsText.Parent = winsContainer
winsText.BackgroundTransparency = 1
winsText.Position = UDim2.new(0, 10, 0, 0)
winsText.Size = UDim2.new(1, -40, 1, 0)
winsText.Font = Enum.Font.GothamBold
winsText.Text = "Wins"
winsText.TextColor3 = Color3.fromRGB(255, 255, 255)
winsText.TextSize = 12
winsText.TextXAlignment = Enum.TextXAlignment.Left

local winsArrowBtn = Instance.new("TextButton")
winsArrowBtn.Parent = winsContainer
winsArrowBtn.BackgroundTransparency = 1
winsArrowBtn.Position = UDim2.new(1, -30, 0, 0)
winsArrowBtn.Size = UDim2.new(0, 30, 1, 0)
winsArrowBtn.Font = Enum.Font.GothamBold
winsArrowBtn.Text = ">"
winsArrowBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
winsArrowBtn.TextSize = 14

local winsSidebar = Instance.new("ScrollingFrame")
winsSidebar.Parent = GamePage
winsSidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
winsSidebar.Size = UDim2.new(1, 0, 0, 0)
winsSidebar.Visible = false
winsSidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
winsSidebar.ScrollBarThickness = 4
Instance.new("UICorner", winsSidebar).CornerRadius = UDim.new(0, 4)

local UIListWinsSidebar = Instance.new("UIListLayout")
UIListWinsSidebar.Parent = winsSidebar
UIListWinsSidebar.SortOrder = Enum.SortOrder.LayoutOrder
UIListWinsSidebar.Padding = UDim.new(0, 5)

local currentSelectedRecording = nil

local chosenRecLabel = Instance.new("TextLabel")
chosenRecLabel.Parent = GamePage
chosenRecLabel.BackgroundTransparency = 1
chosenRecLabel.Size = UDim2.new(1, 0, 0, 20)
chosenRecLabel.Font = Enum.Font.GothamSemibold
chosenRecLabel.Text = "recorrido escogido: Ninguno"
chosenRecLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
chosenRecLabel.TextSize = 12
chosenRecLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Orden fijo de los 14 recorridos exactos
local sortedWinNames = {
    "WinBlock32",
    "WinBlock33",
    "WinBlock34",
    "WinBlock35",
    "WinBlock36",
    "WinBlock37",
    "WinBlock38",
    "WinBlock39",
    "WinBlock40",
    "WinBlock41",
    "WinBlock42",
    "WinBlock43",
    "WinBlock44",
    "WinBlock45"
}

local function updateWinsSidebarUI()
    for _, child in pairs(winsSidebar:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    for _, recName in ipairs(sortedWinNames) do
        if _G.RecordedPaths[recName] then
            local btn = Instance.new("TextButton")
            btn.Parent = winsSidebar
            btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            btn.Size = UDim2.new(1, -10, 0, 25)
            btn.Font = Enum.Font.Gotham
            btn.Text = recName
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextSize = 11
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            
            btn.MouseButton1Click:Connect(function()
                currentSelectedRecording = recName
                chosenRecLabel.Text = "recorrido escogido: " .. recName
                winsSidebar.Visible = false
                winsSidebar.Size = UDim2.new(1, 0, 0, 0)
                winsArrowBtn.Text = ">"
            end)
        end
    end
    winsSidebar.CanvasSize = UDim2.new(0, 0, 0, #sortedWinNames * 30)
end

winsArrowBtn.MouseButton1Click:Connect(function()
    local isOpen = winsSidebar.Visible
    if not isOpen then
        updateWinsSidebarUI()
        winsSidebar.Visible = true
        winsSidebar.Size = UDim2.new(1, 0, 0, 160)
        winsArrowBtn.Text = "v"
    else
        winsSidebar.Visible = false
        winsSidebar.Size = UDim2.new(1, 0, 0, 0)
        winsArrowBtn.Text = ">"
    end
end)

local playbackSpeedLimit = 200

local playbackSpeedLabel = createLabel(GamePage, "Velocidad del recorrido (Max: 200):")
local playbackSpeedBox = Instance.new("TextBox")
playbackSpeedBox.Parent = GamePage
playbackSpeedBox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
playbackSpeedBox.Size = UDim2.new(1, 0, 0, 30)
playbackSpeedBox.Font = Enum.Font.Gotham
playbackSpeedBox.Text = "100"
playbackSpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
playbackSpeedBox.TextSize = 12
Instance.new("UICorner", playbackSpeedBox).CornerRadius = UDim.new(0, 4)

local playbackSpeedValue = 100
playbackSpeedBox.FocusLost:Connect(function()
    local val = tonumber(playbackSpeedBox.Text)
    if val then
        playbackSpeedValue = math.clamp(val, 1, playbackSpeedLimit)
        playbackSpeedBox.Text = tostring(playbackSpeedValue)
    else
        playbackSpeedBox.Text = tostring(playbackSpeedValue)
    end
end)

local safeSpeedToggle = Instance.new("TextButton")
safeSpeedToggle.Parent = GamePage
safeSpeedToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
safeSpeedToggle.Size = UDim2.new(1, 0, 0, 30)
safeSpeedToggle.Font = Enum.Font.GothamBold
safeSpeedToggle.Text = "Modo Extremo Recorrido (Max 400): OFF"
safeSpeedToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
safeSpeedToggle.TextSize = 11
Instance.new("UICorner", safeSpeedToggle).CornerRadius = UDim.new(0, 4)

safeSpeedToggle.MouseButton1Click:Connect(function()
    if playbackSpeedLimit == 200 then
        playbackSpeedLimit = 400
        safeSpeedToggle.Text = "Modo Extremo Recorrido (Max 400): ON"
        safeSpeedToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
        safeSpeedToggle.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
        playbackSpeedLabel.Text = "Velocidad del recorrido (Max: 400):"
    else
        playbackSpeedLimit = 200
        safeSpeedToggle.Text = "Modo Extremo Recorrido (Max 400): OFF"
        safeSpeedToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
        safeSpeedToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        playbackSpeedLabel.Text = "Velocidad del recorrido (Max: 200):"
        if playbackSpeedValue > 200 then
            playbackSpeedValue = 200
            playbackSpeedBox.Text = "200"
        end
    end
end)

createLabel(GamePage, "Delay entre recorridos (0 - 10 seg):")
local delayBox = Instance.new("TextBox")
delayBox.Parent = GamePage
delayBox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
delayBox.Size = UDim2.new(1, 0, 0, 30)
delayBox.Font = Enum.Font.Gotham
delayBox.Text = "2"
delayBox.TextColor3 = Color3.fromRGB(255, 255, 255)
delayBox.TextSize = 12
Instance.new("UICorner", delayBox).CornerRadius = UDim.new(0, 4)

local delayValue = 2
delayBox.FocusLost:Connect(function()
    local val = tonumber(delayBox.Text)
    if val then
        delayValue = math.clamp(val, 0, 10)
        delayBox.Text = tostring(delayValue)
    else
        delayBox.Text = tostring(delayValue)
    end
end)

local loopToggle = Instance.new("TextButton")
loopToggle.Parent = GamePage
loopToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
loopToggle.Size = UDim2.new(1, 0, 0, 30)
loopToggle.Font = Enum.Font.GothamBold
loopToggle.Text = "Correr Indefinidamente: OFF"
loopToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
loopToggle.TextSize = 12
Instance.new("UICorner", loopToggle).CornerRadius = UDim.new(0, 4)

local loopEnabled = false
loopToggle.MouseButton1Click:Connect(function()
    loopEnabled = not loopEnabled
    if loopEnabled then
        loopToggle.Text = "Correr Indefinidamente: ON"
        loopToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
        loopToggle.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
    else
        loopToggle.Text = "Correr Indefinidamente: OFF"
        loopToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
        loopToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    end
end)

local autoCoinsSelected = false
local autoKeysSelected = false

local autoItemsContainer = Instance.new("Frame")
autoItemsContainer.Parent = GamePage
autoItemsContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
autoItemsContainer.Size = UDim2.new(1, 0, 0, 35)
autoItemsContainer.BorderSizePixel = 0
Instance.new("UICorner", autoItemsContainer).CornerRadius = UDim.new(0, 4)

local autoItemsText = Instance.new("TextLabel")
autoItemsText.Parent = autoItemsContainer
autoItemsText.BackgroundTransparency = 1
autoItemsText.Position = UDim2.new(0, 10, 0, 0)
autoItemsText.Size = UDim2.new(1, -40, 1, 0)
autoItemsText.Font = Enum.Font.GothamBold
autoItemsText.Text = "Auto Items (Seleccionar)"
autoItemsText.TextColor3 = Color3.fromRGB(255, 255, 255)
autoItemsText.TextSize = 12
autoItemsText.TextXAlignment = Enum.TextXAlignment.Left

local autoItemsArrowBtn = Instance.new("TextButton")
autoItemsArrowBtn.Parent = autoItemsContainer
autoItemsArrowBtn.BackgroundTransparency = 1
autoItemsArrowBtn.Position = UDim2.new(1, -30, 0, 0)
autoItemsArrowBtn.Size = UDim2.new(0, 30, 1, 0)
autoItemsArrowBtn.Font = Enum.Font.GothamBold
autoItemsArrowBtn.Text = ">"
autoItemsArrowBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoItemsArrowBtn.TextSize = 14

local autoItemsSidebar = Instance.new("ScrollingFrame")
autoItemsSidebar.Parent = GamePage
autoItemsSidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
autoItemsSidebar.Size = UDim2.new(1, 0, 0, 0)
autoItemsSidebar.Visible = false
autoItemsSidebar.CanvasSize = UDim2.new(0, 0, 0, 70)
autoItemsSidebar.ScrollBarThickness = 4
Instance.new("UICorner", autoItemsSidebar).CornerRadius = UDim.new(0, 4)

local UIListAutoItems = Instance.new("UIListLayout")
UIListAutoItems.Parent = autoItemsSidebar
UIListAutoItems.SortOrder = Enum.SortOrder.LayoutOrder
UIListAutoItems.Padding = UDim.new(0, 5)

local btnCoins = Instance.new("TextButton")
btnCoins.Parent = autoItemsSidebar
btnCoins.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
btnCoins.Size = UDim2.new(1, -10, 0, 25)
btnCoins.Font = Enum.Font.Gotham
btnCoins.Text = "Auto Summer Coins"
btnCoins.TextColor3 = Color3.fromRGB(255, 255, 255)
btnCoins.TextSize = 11
Instance.new("UICorner", btnCoins).CornerRadius = UDim.new(0, 4)

local btnKeys = Instance.new("TextButton")
btnKeys.Parent = autoItemsSidebar
btnKeys.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
btnKeys.Size = UDim2.new(1, -10, 0, 25)
btnKeys.Font = Enum.Font.Gotham
btnKeys.Text = "Auto Special Keys"
btnKeys.TextColor3 = Color3.fromRGB(255, 255, 255)
btnKeys.TextSize = 11
Instance.new("UICorner", btnKeys).CornerRadius = UDim.new(0, 4)

btnCoins.MouseButton1Click:Connect(function()
    autoCoinsSelected = not autoCoinsSelected
    if autoCoinsSelected then
        btnCoins.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    else
        btnCoins.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    end
end)

btnKeys.MouseButton1Click:Connect(function()
    autoKeysSelected = not autoKeysSelected
    if autoKeysSelected then
        btnKeys.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    else
        btnKeys.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    end
end)

autoItemsArrowBtn.MouseButton1Click:Connect(function()
    local isOpen = autoItemsSidebar.Visible
    if not isOpen then
        autoItemsSidebar.Visible = true
        autoItemsSidebar.Size = UDim2.new(1, 0, 0, 70)
        autoItemsArrowBtn.Text = "v"
    else
        autoItemsSidebar.Visible = false
        autoItemsSidebar.Size = UDim2.new(1, 0, 0, 0)
        autoItemsArrowBtn.Text = ">"
    end
end)

local autoGlobalToggle = Instance.new("TextButton")
autoGlobalToggle.Parent = GamePage
autoGlobalToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
autoGlobalToggle.Size = UDim2.new(1, 0, 0, 30)
autoGlobalToggle.Font = Enum.Font.GothamBold
autoGlobalToggle.Text = "Auto: OFF"
autoGlobalToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
autoGlobalToggle.TextSize = 12
Instance.new("UICorner", autoGlobalToggle).CornerRadius = UDim.new(0, 4)

local autoGlobalEnabled = false
autoGlobalToggle.MouseButton1Click:Connect(function()
    autoGlobalEnabled = not autoGlobalEnabled
    if autoGlobalEnabled then
        autoGlobalToggle.Text = "Auto: ON"
        autoGlobalToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
        autoGlobalToggle.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
    else
        autoGlobalToggle.Text = "Auto: OFF"
        autoGlobalToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
        autoGlobalToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    end
end)

local collectedCoinsPositions = {}
local collectedKeysPositions = {}
local isCollectingItemsNow = false

task.spawn(function()
    while true do
        if not autoGlobalEnabled then
            task.wait(0.5)
        else
            local hasTargets = (#collectedCoinsPositions > 0 and autoCoinsSelected) or (#collectedKeysPositions > 0 and autoKeysSelected)
            if hasTargets then
                task.wait(0.2)
            else
                task.wait(10)
            end
            
            if autoGlobalEnabled then
                local char = player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                
                if hrp then
                    if autoCoinsSelected then
                        for _, obj in pairs(Workspace:GetDescendants()) do
                            if obj.Name == "SummerCoin" then
                                local targetPart = nil
                                if obj:IsA("BasePart") then
                                    targetPart = obj
                                elseif obj:IsA("Model") and obj.PrimaryPart then
                                    targetPart = obj.PrimaryPart
                                else
                                    targetPart = obj:FindFirstChildOfClass("BasePart")
                                end

                                if targetPart then
                                    local pos = targetPart.Position
                                    if (hrp.Position - pos).Magnitude <= 100 then
                                        local alreadySaved = false
                                        for _, savedPos in ipairs(collectedCoinsPositions) do
                                            if (savedPos - pos).Magnitude < 5 then
                                                alreadySaved = true
                                                break
                                            end
                                        end
                                        if not alreadySaved then
                                            table.insert(collectedCoinsPositions, pos)
                                        end
                                    end
                                end
                            end
                        end
                    end

                    if autoKeysSelected then
                        for _, obj in pairs(Workspace:GetDescendants()) do
                            if obj.Name == "SpecialKeys" or string.lower(obj.Name) == "specialkeys" then
                                for _, item in pairs(obj:GetDescendants()) do
                                    local targetPart = nil
                                    if item:IsA("BasePart") then
                                        targetPart = item
                                    elseif item:IsA("Model") and item.PrimaryPart then
                                        targetPart = item.PrimaryPart
                                    else
                                        targetPart = item:FindFirstChildOfClass("BasePart")
                                    end

                                    if targetPart then
                                        local pos = targetPart.Position
                                        if (hrp.Position - pos).Magnitude <= 150 then
                                            local alreadySaved = false
                                            for _, savedPos in ipairs(collectedKeysPositions) do
                                                if (savedPos - pos).Magnitude < 5 then
                                                    alreadySaved = true
                                                    break
                                                end
                                            end
                                            if not alreadySaved then
                                                table.insert(collectedKeysPositions, pos)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

local function getSpawnPosition()
    local spawnPos = Vector3.new(-1457.01, -159.04, -995.58)
    if currentSelectedRecording and _G.RecordedPaths[currentSelectedRecording] then
        local firstPt = _G.RecordedPaths[currentSelectedRecording][1]
        spawnPos = (typeof(firstPt) == "Vector3") and firstPt or firstPt.Position
    end
    return spawnPos
end

local function processQueue(positionsList)
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local spawnPos = getSpawnPosition()

    for i = #positionsList, 1, -1 do
        if not autoGlobalEnabled then break end
        local itemPos = positionsList[i]
        
        if hrp and itemPos then
            hrp.CFrame = CFrame.new(spawnPos)
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            task.wait(0.2)

            hrp.CFrame = CFrame.new(itemPos + Vector3.new(0, 3, 0))
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            task.wait(0.35)
            
            table.remove(positionsList, i)
        end
    end

    if hrp then
        hrp.CFrame = CFrame.new(spawnPos)
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end
    task.wait(0.3)
end

playbackStatus = "STOPPED"
local autoNoclipConnection
local customNoclipActive = true

local playBtn = Instance.new("TextButton")
playBtn.Parent = GamePage
playBtn.BackgroundColor3 = Color3.fromRGB(40, 90, 40)
playBtn.Size = UDim2.new(1, 0, 0, 35)
playBtn.Font = Enum.Font.GothamBold
playBtn.Text = "iniciar recorrido"
playBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
playBtn.TextSize = 12
Instance.new("UICorner", playBtn).CornerRadius = UDim.new(0, 4)

local stopRecBtn = Instance.new("TextButton")
stopRecBtn.Parent = GamePage
stopRecBtn.BackgroundColor3 = Color3.fromRGB(90, 40, 40)
stopRecBtn.Size = UDim2.new(1, 0, 0, 35)
stopRecBtn.Font = Enum.Font.GothamBold
stopRecBtn.Text = "terminar recorrido"
stopRecBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
stopRecBtn.TextSize = 12
Instance.new("UICorner", stopRecBtn).CornerRadius = UDim.new(0, 4)

local function stopPlaybackCleanup()
    playbackStatus = "STOPPED"
    customNoclipActive = true
    if autoNoclipConnection then
        autoNoclipConnection:Disconnect()
        autoNoclipConnection = nil
    end
    local char = player.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp and hrp:FindFirstChildOfClass("BodyVelocity") then
            hrp:FindFirstChildOfClass("BodyVelocity"):Destroy()
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end

local function executePlayback()
    if not currentSelectedRecording then return end
    if playbackStatus == "PLAYING" or playbackStatus == "PAUSED" then return end
    
    local pathData = _G.RecordedPaths[currentSelectedRecording]
    if not pathData or #pathData == 0 then return end

    playbackStatus = "PLAYING"
    customNoclipActive = true
    
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local hum = char:FindFirstChildOfClass("Humanoid")

    local firstPoint = pathData[1]
    if typeof(firstPoint) == "Vector3" then
        hrp.CFrame = CFrame.new(firstPoint)
    else
        hrp.CFrame = firstPoint
    end
    task.wait(0.05)

    autoNoclipConnection = RunService.Stepped:Connect(function()
        if (playbackStatus == "PLAYING" or playbackStatus == "PAUSED") and char and customNoclipActive then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)

    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = hrp

    if hum then hum.PlatformStand = true end

    task.spawn(function()
        local jitterCounter = 0
        local currentIndex = 1

        while playbackStatus == "PLAYING" or playbackStatus == "PAUSED" do
            if playbackStatus == "PAUSED" then
                task.wait(0.1)
                continue
            end

            jitterCounter = jitterCounter + 1
            local speedVariation = 0
            
            if playbackSpeedValue > 10 then
                local mod = jitterCounter % 5
                if mod == 1 then speedVariation = 0
                elseif mod == 2 then speedVariation = -10
                elseif mod == 3 then speedVariation = -5
                elseif mod == 4 then speedVariation = -3
                else speedVariation = -8 end
            end
            
            local activeSpeed = math.clamp(playbackSpeedValue + speedVariation, 1, playbackSpeedLimit)

            local reachedEndNormal = false
            while currentIndex <= #pathData and playbackStatus == "PLAYING" do
                local point = pathData[currentIndex]
                local targetPos = (typeof(point) == "Vector3") and point or point.Position
                
                local isLastPoint = (currentIndex == #pathData)
                if isLastPoint then
                    -- Buscar en el Workspace el objeto con el nombre del WinBlock seleccionado y hacer tween/teleport directo al CFrame exacto del objeto si existe
                    pcall(function()
                        local foundWinObj = Workspace:FindFirstChild(currentSelectedRecording, true)
                        if foundWinObj then
                            local targetPart = nil
                            if foundWinObj:IsA("BasePart") then
                                targetPart = foundWinObj
                            elseif foundWinObj:IsA("Model") and foundWinObj.PrimaryPart then
                                targetPart = foundWinObj.PrimaryPart
                            else
                                targetPart = foundWinObj:FindFirstChildOfClass("BasePart")
                            end
                            if targetPart then
                                targetPos = targetPart.Position + Vector3.new(0, 3, 0)
                            end
                        end
                    end)
                    targetPos = targetPos + Vector3.new(0, 10, 0)
                end
                
                local currentSpeedToUse = activeSpeed
                
                if hrp then
                    while playbackStatus == "PLAYING" do
                        local dt = RunService.RenderStepped:Wait()
                        local currentPos = hrp.Position
                        local distanceToTarget = (targetPos - currentPos).Magnitude
                        local stepDistance = currentSpeedToUse * dt
                        
                        if distanceToTarget <= stepDistance + 0.5 then
                            hrp.CFrame = CFrame.new(targetPos)
                            break
                        else
                            local direction = (targetPos - currentPos).Unit
                            bv.Velocity = direction * currentSpeedToUse
                            hrp.CFrame = CFrame.new(currentPos, targetPos)
                        end
                    end
                end
                
                currentIndex = currentIndex + 1
            end

            if currentIndex > #pathData then
                reachedEndNormal = true
            end

            if reachedEndNormal and playbackStatus == "PLAYING" then
                if bv and bv.Parent then bv:Destroy() end
                customNoclipActive = false
                if hum then hum.PlatformStand = false end

                if hrp then
                    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                end

                task.wait(0.5)
                
                if autoGlobalEnabled then
                    local hasCoins = (#collectedCoinsPositions > 0) and autoCoinsSelected
                    local hasKeys = (#collectedKeysPositions > 0) and autoKeysSelected
                    
                    if hasCoins or hasKeys then
                        isCollectingItemsNow = true
                        if hasCoins then processQueue(collectedCoinsPositions) end
                        if hasKeys then processQueue(collectedKeysPositions) end
                        isCollectingItemsNow = false
                    end
                end

                if playbackStatus == "PLAYING" and loopEnabled then
                    currentIndex = 1
                    bv = Instance.new("BodyVelocity")
                    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bv.Velocity = Vector3.new(0, 0, 0)
                    bv.Parent = hrp
                    if hum then hum.PlatformStand = true end
                end
            end

            if not loopEnabled or playbackStatus ~= "PLAYING" then
                break
            end

            if playbackStatus == "PLAYING" then
                if delayValue > 0 then
                    task.wait(delayValue)
                else
                    task.wait(0.2)
                end
                
                local nextFirstPoint = pathData[1]
                local nextStartPos = (typeof(nextFirstPoint) == "Vector3") and nextFirstPoint or nextFirstPoint.Position
                if hrp then
                    hrp.CFrame = CFrame.new(nextStartPos)
                    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                end
                task.wait(0.1)
            end
            
            customNoclipActive = true
        end
        if playbackStatus ~= "PAUSED" then
            stopPlaybackCleanup()
        end
    end)
end

task.spawn(function()
    while true do
        task.wait(1)
        if autoGlobalEnabled and not isCollectingItemsNow then
            local hasCoinsToCollect = (#collectedCoinsPositions > 0) and autoCoinsSelected
            local hasKeysToCollect = (#collectedKeysPositions > 0) and autoKeysSelected

            if hasCoinsToCollect or hasKeysToCollect then
                if playbackStatus == "PLAYING" then
                    if loopEnabled then
                        playbackStatus = "PAUSED"
                        local char = player.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if hrp and hrp:FindFirstChildOfClass("BodyVelocity") then
                            hrp:FindFirstChildOfClass("BodyVelocity"):Destroy()
                        end
                        local hum = char and char:FindFirstChildOfClass("Humanoid")
                        if hum then hum.PlatformStand = false end

                        isCollectingItemsNow = true
                        if hasCoinsToCollect then processQueue(collectedCoinsPositions) end
                        if hasKeysToCollect then processQueue(collectedKeysPositions) end
                        isCollectingItemsNow = false

                        playbackStatus = "PLAYING"
                        if hrp then
                            local bv = Instance.new("BodyVelocity")
                            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                            bv.Velocity = Vector3.new(0, 0, 0)
                            bv.Parent = hrp
                            if hum then hum.PlatformStand = true end
                        end
                    end
                elseif playbackStatus == "STOPPED" then
                    isCollectingItemsNow = true
                    if hasCoinsToCollect then processQueue(collectedCoinsPositions) end
                    if hasKeysToCollect then processQueue(collectedKeysPositions) end
                    isCollectingItemsNow = false
                end
            end
        end
    end
end)

playBtn.MouseButton1Click:Connect(function()
    if playbackStatus == "STOPPED" then
        executePlayback()
    end
end)

stopRecBtn.MouseButton1Click:Connect(function()
    stopPlaybackCleanup()
end)

updateWinsSidebarUI()

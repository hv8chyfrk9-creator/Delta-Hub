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
-- ANTI-DAÑO AUTOMÁTICO (Lava y NPCs con hitbox)
----------------------------------------------------
local function applyAntiDamage()
    pcall(function()
        for _, obj in pairs(Workspace:GetDescendants()) do
            local nameLower = string.lower(obj.Name)
            if string.find(nameLower, "lava") then
                obj:Destroy()
            end
        end
        
        local npcFolder = Workspace:FindFirstChild("NPC") or Workspace:FindFirstChild("Npcs")
        if npcFolder then
            for _, npc in pairs(npcFolder:GetDescendants()) do
                if string.lower(npc.Name) == "hitbox" then
                    npc:Destroy()
                end
            end
        end
        
        for _, obj in pairs(Workspace:GetChildren()) do
            if string.lower(obj.Name):find("npc") then
                local hitbox = obj:FindFirstChild("Hitbox", true)
                if hitbox then
                    hitbox:Destroy()
                end
            end
        end
    end)
end

applyAntiDamage()
task.spawn(function()
    while true do
        task.wait(1)
        applyAntiDamage()
    end
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
GamePage.CanvasSize = UDim2.new(0, 0, 0, 1250)
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
local jumpEnabled = false
local currentJump = 50
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
    if speedEnabled then
        speedToggle.Text = "Activar Velocidad: ON"
        speedToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
        speedToggle.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
    else
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
    if jumpEnabled then
        jumpToggle.Text = "Activar Salto: ON"
        jumpToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
        jumpToggle.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
    else
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
local originalReflectance = {}
local originalLighting = {
    GlobalShadows = Lighting.GlobalShadows,
    Brightness = Lighting.Brightness,
    FogEnd = Lighting.FogEnd
}

antiLagToggle.MouseButton1Click:Connect(function()
    antiLagEnabled = not antiLagEnabled
    if antiLagEnabled then
        antiLagToggle.Text = "Anti-Lag Extremo & Key Caps: ON"
        antiLagToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
        antiLagToggle.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
        
        pcall(function()
            Workspace.StreamingEnabled = false
            Workspace.LevelOfDetail = Enum.ModelLevelOfDetail.Disabled
            settings():GetService("RenderSettings").MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
        end)
        
        pcall(function()
            local floatFolder = Workspace:FindFirstChild("FloatFolder")
            if floatFolder then
                floatFolder:Destroy()
            end
        end)
        
        local keyCapsMatches = {}
        for _, obj in pairs(Workspace:GetDescendants()) do
            local nameLower = string.lower(obj.Name)
            if string.find(nameLower, "key") and string.find(nameLower, "cap") then
                table.insert(keyCapsMatches, obj)
            end
        end

        if #keyCapsMatches > 50 then
            for _, obj in ipairs(keyCapsMatches) do
                pcall(function()
                    obj:Destroy()
                end)
            end
        end

        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj and obj.Parent and obj:IsA("BasePart") then
                originalMaterials[obj] = obj.Material
                originalReflectance[obj] = obj.Reflectance
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
                obj.CastShadow = false
            elseif obj and obj.Parent and (obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles")) then
                obj.Enabled = false
            end
        end
        
        Lighting.GlobalShadows = false
        Lighting.Brightness = 2
        Lighting.FogEnd = 100000
    else
        antiLagToggle.Text = "Anti-Lag Extremo & Key Caps: OFF"
        antiLagToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
        antiLagToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        
        pcall(function()
            Workspace.StreamingEnabled = true
        end)
        
        for obj, mat in pairs(originalMaterials) do
            if obj and obj.Parent then
                obj.Material = mat
                obj.CastShadow = true
            end
        end
        for obj, ref in pairs(originalReflectance) do
            if obj and obj.Parent then
                obj.Reflectance = ref
            end
        end
        
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj and obj.Parent and (obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles")) then
                obj.Enabled = true
            end
        end
        
        Lighting.GlobalShadows = originalLighting.GlobalShadows
        Lighting.Brightness = originalLighting.Brightness
        Lighting.FogEnd = originalLighting.FogEnd
        
        originalMaterials = {}
        originalReflectance = {}
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
-- GAMEPLAY & REPRODUCTOR DE WINS
----------------------------------------------------
_G.RecordedPaths = _G.RecordedPaths or {
    ["Win-block-1"] = {
        Vector3.new(-1455.18, -159.04, -999.85),
        Vector3.new(-1452.75, -160.68, -864.21),
        Vector3.new(-1431.03, -160.43, -859.13),
        Vector3.new(-1430.00, -69.54, -539.32),
        Vector3.new(-1453.00, -69.54, -516.92),
        Vector3.new(-1480.72, -68.65, -516.64)
    },
    ["Win-block-2"] = {
        Vector3.new(-1454.95, -159.04, -1000.49),
        Vector3.new(-1455.35, -160.68, -863.53),
        Vector3.new(-1431.57, -160.43, -857.99),
        Vector3.new(-1429.59, -69.54, -538.64),
        Vector3.new(-1452.39, -69.54, -514.24),
        Vector3.new(-1452.81, -57.91, -391.94),
        Vector3.new(-1454.66, -57.30, -18.80),
        Vector3.new(-1479.18, -56.41, -15.81)
    },
    ["Win-block-3"] = {
        Vector3.new(-1456.28, -159.04, -999.09),
        Vector3.new(-1455.84, -160.68, -862.67),
        Vector3.new(-1429.39, -160.43, -858.34),
        Vector3.new(-1427.87, -69.54, -533.03),
        Vector3.new(-1454.57, -69.54, -491.11),
        Vector3.new(-1452.46, -58.13, -392.79),
        Vector3.new(-1453.40, -57.30, -15.98),
        Vector3.new(-1454.60, -57.30, 4.99),
        Vector3.new(-1455.46, 274.37, 4.74),
        Vector3.new(-1455.02, 256.95, 13.45),
        Vector3.new(-1455.75, 223.52, 179.85),
        Vector3.new(-1448.47, 223.77, 227.89),
        Vector3.new(-1479.51, 215.60, 332.05)
    },
    ["Win-block-4"] = {
        Vector3.new(-1455.07, -159.04, -999.51),
        Vector3.new(-1454.60, -160.68, -862.43),
        Vector3.new(-1429.65, -160.43, -861.47),
        Vector3.new(-1428.23, -69.54, -534.50),
        Vector3.new(-1453.44, -69.54, -490.71),
        Vector3.new(-1453.89, -57.98, -392.20),
        Vector3.new(-1452.69, -57.30, 5.25),
        Vector3.new(-1457.56, 256.95, 13.62),
        Vector3.new(-1453.49, 214.71, 332.51),
        Vector3.new(-1453.41, 214.71, 627.32),
        Vector3.new(-1453.43, 375.20, 627.74),
        Vector3.new(-1406.99, 392.23, 720.46),
        Vector3.new(-1406.99, 559.22, 720.46),
        Vector3.new(-1405.46, 532.72, 758.44),
        Vector3.new(-1410.59, 576.73, 808.45),
        Vector3.new(-1314.53, 590.19, 1005.70),
        Vector3.new(-1375.53, 591.62, 1236.85),
        Vector3.new(-1402.83, 532.72, 1329.88),
        Vector3.new(-1430.08, 533.61, 1329.89)
    },
    ["Win-block-5"] = {
        Vector3.new(-1452.65, -159.04, -996.46),
        Vector3.new(-1452.99, -160.68, -865.02),
        Vector3.new(-1433.13, -160.43, -858.72),
        Vector3.new(-1431.15, -69.54, -539.78),
        Vector3.new(-1454.68, -69.54, -496.74),
        Vector3.new(-1454.89, -58.65, -394.89),
        Vector3.new(-1453.12, -57.30, 3.29),
        Vector3.new(-1449.43, 257.62, 7.44),
        Vector3.new(-1447.02, 256.95, 13.27),
        Vector3.new(-1456.40, 223.35, 179.21),
        Vector3.new(-1455.03, 214.71, 333.16),
        Vector3.new(-1454.93, 214.67, 627.20),
        Vector3.new(-1454.93, 374.54, 627.20),
        Vector3.new(-1405.45, 373.74, 724.20),
        Vector3.new(-1405.45, 548.60, 724.20),
        Vector3.new(-1402.99, 532.72, 760.93),
        Vector3.new(-1408.86, 532.72, 798.73),
        Vector3.new(-1405.86, 543.58, 812.64),
        Vector3.new(-1295.28, 543.58, 1039.75),
        Vector3.new(-1402.41, 543.58, 1230.38),
        Vector3.new(-1403.06, 532.72, 1329.03),
        Vector3.new(-1430.21, 533.61, 1330.90)
    },
    ["Win-block-6"] = {
        Vector3.new(-1455.11, -159.04, -999.51),
        Vector3.new(-1456.32, -160.68, -861.32),
        Vector3.new(-1432.18, -160.43, -858.86),
        Vector3.new(-1429.89, -69.54, -534.43),
        Vector3.new(-1455.58, -69.54, -491.34),
        Vector3.new(-1454.55, -58.05, -392.49),
        Vector3.new(-1452.54, -57.30, 3.35),
        Vector3.new(-1454.01, 256.59, 3.56),
        Vector3.new(-1455.28, 256.95, 12.89),
        Vector3.new(-1451.72, 214.96, 284.90),
        Vector3.new(-1452.50, 214.71, 329.67),
        Vector3.new(-1454.62, 214.72, 627.69),
        Vector3.new(-1454.62, 374.87, 627.69),
        Vector3.new(-1406.85, 374.85, 724.68),
        Vector3.new(-1406.85, 544.93, 724.68),
        Vector3.new(-1404.91, 532.72, 759.85),
        Vector3.new(-1404.93, 532.72, 795.47),
        Vector3.new(-1404.33, 543.58, 811.87),
        Vector3.new(-1295.36, 543.58, 1045.52),
        Vector3.new(-1402.53, 543.58, 1231.56),
        Vector3.new(-1402.50, 532.72, 1278.69),
        Vector3.new(-1403.84, 532.72, 1423.62),
        Vector3.new(-1440.64, 532.72, 1439.15),
        Vector3.new(-1661.71, 508.72, 1446.75),
        Vector3.new(-2006.55, 508.72, 1446.38),
        Vector3.new(-2059.75, 442.72, 1485.68),
        Vector3.new(-2062.52, 443.61, 1461.34)
    }
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

local function updateWinsSidebarUI()
    for _, child in pairs(winsSidebar:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local count = 0
    for recName, _ in pairs(_G.RecordedPaths) do
        count = count + 1
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
            chosenRecLabel.Text = "recorrido escogido: " + recName -- (Mantenido abajo con ..)
            chosenRecLabel.Text = "recorrido escogido: " .. recName
            winsSidebar.Visible = false
            winsSidebar.Size = UDim2.new(1, 0, 0, 0)
            winsArrowBtn.Text = ">"
        end)
    end
    winsSidebar.CanvasSize = UDim2.new(0, 0, 0, count * 30)
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

----------------------------------------------------
-- SELECTOR DROPDOWN: AUTO ITEMS (Auto Summer Coins / Auto Special Keys)
----------------------------------------------------
local selectedAutoItemMode = "Ninguno" -- "Ninguno", "Auto Summer Coins", "Auto Special Keys", "Ambos"

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
autoItemsText.Text = "Modo Auto Items: Ninguno"
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
autoItemsSidebar.CanvasSize = UDim2.new(0, 0, 0, 140)
autoItemsSidebar.ScrollBarThickness = 4
Instance.new("UICorner", autoItemsSidebar).CornerRadius = UDim.new(0, 4)

local UIListAutoItems = Instance.new("UIListLayout")
UIListAutoItems.Parent = autoItemsSidebar
UIListAutoItems.SortOrder = Enum.SortOrder.LayoutOrder
UIListAutoItems.Padding = UDim.new(0, 5)

local optionsList = {"Ninguno", "Auto Summer Coins", "Auto Special Keys", "Ambos"}
for _, optName in ipairs(optionsList) do
    local optBtn = Instance.new("TextButton")
    optBtn.Parent = autoItemsSidebar
    optBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    optBtn.Size = UDim2.new(1, -10, 0, 25)
    optBtn.Font = Enum.Font.Gotham
    optBtn.Text = optName
    optBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    optBtn.TextSize = 11
    Instance.new("UICorner", optBtn).CornerRadius = UDim.new(0, 4)
    
    optBtn.MouseButton1Click:Connect(function()
        selectedAutoItemMode = optName
        autoItemsText.Text = "Modo Auto Items: " .. optName
        autoItemsSidebar.Visible = false
        autoItemsSidebar.Size = UDim2.new(1, 0, 0, 0)
        autoItemsArrowBtn.Text = ">"
    end)
end

autoItemsArrowBtn.MouseButton1Click:Connect(function()
    local isOpen = autoItemsSidebar.Visible
    if not isOpen then
        autoItemsSidebar.Visible = true
        autoItemsSidebar.Size = UDim2.new(1, 0, 0, 115)
        autoItemsArrowBtn.Text = "v"
    else
        autoItemsSidebar.Visible = false
        autoItemsSidebar.Size = UDim2.new(1, 0, 0, 0)
        autoItemsArrowBtn.Text = ">"
    end
end)

----------------------------------------------------
-- LÓGICA DE RECOLECCIÓN INTELIGENTE (COINS Y SPECIAL KEYS)
----------------------------------------------------
local collectedCoinsPositions = {}
local collectedKeysPositions = {}
local isCollectingItemsNow = false

-- Monitoreo y registro de Summer Coins en un radio de 100 studs
RunService.Heartbeat:Connect(function()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Detectar Summer Coins
    for _, obj in pairs(Workspace:GetDescendants()) do
        local nameLower = string.lower(obj.Name)
        if string.find(nameLower, "summer") and string.find(nameLower, "coin") then
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

    -- Detectar Special Keys (buscando la carpeta SpecialKeys o elementos que contengan specialkey)
    for _, obj in pairs(Workspace:GetDescendants()) do
        local nameLower = string.lower(obj.Name)
        if string.find(nameLower, "specialkey") or string.find(nameLower, "special_key") then
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
end)

local function getSpawnPosition()
    local spawnPos = Vector3.new(-1455.18, -159.04, -999.85)
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
        if selectedAutoItemMode == "Ninguno" then break end
        local itemPos = positionsList[i]
        
        if hrp and itemPos then
            -- TP al spawn primero antes de ir al item
            hrp.CFrame = CFrame.new(spawnPos)
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            task.wait(0.2)

            -- Volar / TP hacia el item
            hrp.CFrame = CFrame.new(itemPos + Vector3.new(0, 3, 0))
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            task.wait(0.35)
            
            table.remove(positionsList, i)
        end
    end

    -- Regresar al spawn al terminar
    if hrp then
        hrp.CFrame = CFrame.new(spawnPos)
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end
    task.wait(0.3)
end

-- Bucle principal gestor de Auto Items de forma pasiva / en esperas
task.spawn(function()
    while true do
        task.wait(1)
        if selectedAutoItemMode ~= "Ninguno" and not isCollectingItemsNow then
            -- Solo actúa si no hay recorrido activo o si el sistema está libre
            -- (La verificación de recorrido activo se maneja coordinando con el reproductor)
            local hasCoinsToCollect = (#collectedCoinsPositions > 0) and (selectedAutoItemMode == "Auto Summer Coins" or selectedAutoItemMode == "Ambos")
            local hasKeysToCollect = (#collectedKeysPositions > 0) and (selectedAutoItemMode == "Auto Special Keys" or selectedAutoItemMode == "Ambos")

            if (hasCoinsToCollect or hasKeysToCollect) and playbackStatus == "STOPPED" then
                isCollectingItemsNow = true
                if hasCoinsToCollect then
                    processQueue(collectedCoinsPositions)
                end
                if hasKeysToCollect then
                    processQueue(collectedKeysPositions)
                end
                isCollectingItemsNow = false
            end
        end
    end
end)

----------------------------------------------------
-- REPRODUCTOR DE RECORRIDOS (WINS)
----------------------------------------------------
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
        if playbackStatus == "PLAYING" and char and customNoclipActive then
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

        while playbackStatus == "PLAYING" do
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

            local i = 1
            while i <= #pathData and playbackStatus == "PLAYING" do
                local point = pathData[i]
                local targetPos = (typeof(point) == "Vector3") and point or point.Position
                
                local isLastPoint = (i == #pathData)
                if isLastPoint then
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
                i = i + 1
            end

            if playbackStatus == "PLAYING" then
                if bv and bv.Parent then bv:Destroy() end
                customNoclipActive = false
                if hum then hum.PlatformStand = false end

                if hrp then
                    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                end

                -- 0.5 segundos despues de acabar el recorrido
                task.wait(0.5)
                
                -- Si hay items pendientes y el modo auto está activo, pausamos el bucle de recorrido para recolectar
                if selectedAutoItemMode ~= "Ninguno" then
                    local hasCoins = (#collectedCoinsPositions > 0) and (selectedAutoItemMode == "Auto Summer Coins" or selectedAutoItemMode == "Ambos")
                    local hasKeys = (#collectedKeysPositions > 0) and (selectedAutoItemMode == "Auto Special Keys" or selectedAutoItemMode == "Ambos")
                    
                    if hasCoins or hasKeys then
                        isCollectingItemsNow = true
                        if hasCoins then processQueue(collectedCoinsPositions) end
                        if hasKeys then processQueue(collectedKeysPositions) end
                        isCollectingItemsNow = false
                    end
                end

                if playbackStatus == "PLAYING" and loopEnabled then
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
        stopPlaybackCleanup()
    end)
end

playBtn.MouseButton1Click:Connect(function()
    if playbackStatus == "STOPPED" then
        executePlayback()
    end
end)

stopRecBtn.MouseButton1Click:Connect(function()
    stopPlaybackCleanup()
end)

updateWinsSidebarUI()

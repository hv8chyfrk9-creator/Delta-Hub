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

-- Creación de la Interfaz Principal (ScreenGui)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaHubCustom"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Botón Flotante para Maximizar (Oculto por defecto)
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

-- Ventana Principal
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

-- Barra Superior (Header)
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
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "Delta Hub | Escapa del Mono"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Botón Minimizar (-)
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

-- Contenedor General
local Container = Instance.new("Frame")
Container.Name = "Container"
Container.Parent = MainFrame
Container.BackgroundTransparency = 1
Container.Position = UDim2.new(0, 0, 0, 35)
Container.Size = UDim2.new(1, 0, 1, -35)

-- Sidebar Izquierda
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

-- Botones de la Sidebar
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
Tab2Btn.Text = "Apartado TP"
Tab2Btn.TextColor3 = Color3.fromRGB(170, 170, 170)
Tab2Btn.TextSize = 12
Instance.new("UICorner", Tab2Btn).CornerRadius = UDim.new(0, 4)

-- Contenedor de Páginas (Derecha)
local PagesFrame = Instance.new("Frame")
PagesFrame.Name = "PagesFrame"
PagesFrame.Parent = Container
PagesFrame.BackgroundTransparency = 1
PagesFrame.Position = UDim2.new(0, 130, 0, 0)
PagesFrame.Size = UDim2.new(1, -130, 1, 0)

-- Apartado 1: Configuración
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

-- Apartado 2: Apartado TP
local GamePage = Instance.new("ScrollingFrame")
GamePage.Name = "GamePage"
GamePage.Parent = PagesFrame
GamePage.BackgroundTransparency = 1
GamePage.Position = UDim2.new(0, 10, 0, 10)
GamePage.Size = UDim2.new(1, -20, 1, -20)
GamePage.CanvasSize = UDim2.new(0, 0, 0, 1150)
GamePage.ScrollBarThickness = 4
GamePage.Visible = false

local UIListGame = Instance.new("UIListLayout")
UIListGame.Parent = GamePage
UIListGame.SortOrder = Enum.SortOrder.LayoutOrder
UIListGame.Padding = UDim.new(0, 10)

-- Sistema de Pestañas
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
-- FUNCIONES APARTADO 1: CONFIGURACIÓN
----------------------------------------------------
local speedEnabled = false
local currentSpeed = 16
local jumpEnabled = false
local currentJump = 50 -- Valor base del cajón (equivalente adaptado a JumpHeight)
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

-- Salto Infinito (Infinite Jump usando JumpHeight)
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
                hum.UseJumpPower = false
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

----------------------------------------------------
-- ANTI-LAG EXTREMO Y BORRADO DE KEY CAPS ( > 50 )
----------------------------------------------------
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
        
        -- Recolectar todos los "key caps" para contar si son más de 50
        local keyCapsMatches = {}
        for _, obj in pairs(Workspace:GetDescendants()) do
            local nameLower = string.lower(obj.Name)
            if string.find(nameLower, "key") and string.find(nameLower, "cap") then
                table.insert(keyCapsMatches, obj)
            end
        end

        -- Si hay más de 50, se borran (Delete)
        if #keyCapsMatches > 50 then
            for _, obj in ipairs(keyCapsMatches) do
                pcall(function()
                    obj:Destroy()
                end)
            end
        end

        -- Aplicar optimizaciones generales de Anti-Lag
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

----------------------------------------------------
-- LOOP PRINCIPAL (Velocidad, Salto con JumpHeight y Noclip)
----------------------------------------------------
RunService.Stepped:Connect(function()
    local char = player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            if speedEnabled then 
                hum.WalkSpeed = currentSpeed 
            end
            if jumpEnabled then
                hum.UseJumpPower = false
                -- Conversión matemática para que 100 de JumpPower se sienta igual usando JumpHeight
                hum.JumpHeight = (currentJump * currentJump) / 200
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
-- APARTADO TP (Estructura de Sidebar y contenedor preparados)
----------------------------------------------------
local tpContainer = Instance.new("Frame")
tpContainer.Parent = GamePage
tpContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
tpContainer.Size = UDim2.new(1, 0, 0, 35)
tpContainer.BorderSizePixel = 0
Instance.new("UICorner", tpContainer).CornerRadius = UDim.new(0, 4)

local tpText = Instance.new("TextLabel")
tpText.Parent = tpContainer
tpText.BackgroundTransparency = 1
tpText.Position = UDim2.new(0, 10, 0, 0)
tpText.Size = UDim2.new(1, -40, 1, 0)
tpText.Font = Enum.Font.GothamBold
tpText.Text = "Opciones de Teleport"
tpText.TextColor3 = Color3.fromRGB(255, 255, 255)
tpText.TextSize = 12
tpText.TextXAlignment = Enum.TextXAlignment.Left

local tpArrowBtn = Instance.new("TextButton")
tpArrowBtn.Parent = tpContainer
tpArrowBtn.BackgroundTransparency = 1
tpArrowBtn.Position = UDim2.new(1, -30, 0, 0)
tpArrowBtn.Size = UDim2.new(0, 30, 1, 0)
tpArrowBtn.Font = Enum.Font.GothamBold
tpArrowBtn.Text = ">"
tpArrowBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tpArrowBtn.TextSize = 14

local tpSidebar = Instance.new("ScrollingFrame")
tpSidebar.Parent = GamePage
tpSidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
tpSidebar.Size = UDim2.new(1, 0, 0, 0)
tpSidebar.Visible = false
tpSidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
tpSidebar.ScrollBarThickness = 4
Instance.new("UICorner", tpSidebar).CornerRadius = UDim.new(0, 4)

local UIListTpSidebar = Instance.new("UIListLayout")
UIListTpSidebar.Parent = tpSidebar
UIListTpSidebar.SortOrder = Enum.SortOrder.LayoutOrder
UIListTpSidebar.Padding = UDim.new(0, 5)

tpArrowBtn.MouseButton1Click:Connect(function()
    local isOpen = tpSidebar.Visible
    if not isOpen then
        tpSidebar.Visible = true
        tpSidebar.Size = UDim2.new(1, 0, 0, 160)
        tpArrowBtn.Text = "v"
    else
        tpSidebar.Visible = false
        tpSidebar.Size = UDim2.new(1, 0, 0, 0)
        tpArrowBtn.Text = ">"
    end
end)

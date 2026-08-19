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

-- Salto Infinito
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
-- ANTI-LAG
----------------------------------------------------
local antiLagToggle = Instance.new("TextButton")
antiLagToggle.Parent = ConfigPage
antiLagToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
antiLagToggle.Size = UDim2.new(1, 0, 0, 30)
antiLagToggle.Font = Enum.Font.GothamBold
antiLagToggle.Text = "Anti-Lag: OFF"
antiLagToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
antiLagToggle.TextSize = 12
Instance.new("UICorner", antiLagToggle).CornerRadius = UDim.new(0, 4)

local originalMaterials = {}

antiLagToggle.MouseButton1Click:Connect(function()
    antiLagEnabled = not antiLagEnabled
    if antiLagEnabled then
        antiLagToggle.Text = "Anti-Lag: ON"
        antiLagToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
        antiLagToggle.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
        
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj and obj.Parent and obj:IsA("BasePart") then
                originalMaterials[obj] = obj.Material
                obj.Material = Enum.Material.SmoothPlastic
            end
        end
    else
        antiLagToggle.Text = "Anti-Lag: OFF"
        antiLagToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
        antiLagToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        
        for obj, mat in pairs(originalMaterials) do
            if obj and obj.Parent then
                obj.Material = mat
            end
        end
        
        originalMaterials = {}
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
-- APARTADO TP (Integrado con Mundos y Sidebar)
----------------------------------------------------
createLabel(GamePage, "Selecciona el Mundo (Win TP por Coordenadas):")

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
winsText.Text = "Mundos (1 - 5)"
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

local chosenWorldLabel = Instance.new("TextLabel")
chosenWorldLabel.Parent = GamePage
chosenWorldLabel.BackgroundTransparency = 1
chosenWorldLabel.Size = UDim2.new(1, 0, 0, 20)
chosenWorldLabel.Font = Enum.Font.GothamSemibold
chosenWorldLabel.Text = "Mundo seleccionado: Ninguno"
chosenWorldLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
chosenWorldLabel.TextSize = 12
chosenWorldLabel.TextXAlignment = Enum.TextXAlignment.Left

local mundoCoordinates = {
    ["Mundo 1"] = CFrame.new(-9459.66, 386.04, -254.67),
    ["Mundo 2"] = CFrame.new(-3605.38, 151.34, -9378.49),
    ["Mundo 3"] = CFrame.new(-8077.63, 278.54, 2740.95),
    ["Mundo 4"] = CFrame.new(-7760.11, 17.50, 5740.95),
    ["Mundo 5"] = CFrame.new(-1333.16, 22.54, 7561.95)
}

local selectedCFrame = nil

local function updateWinsSidebarUI()
    for _, child in pairs(winsSidebar:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local count = 0
    for mundoName, _ in pairs(mundoCoordinates) do
        count = count + 1
        local btn = Instance.new("TextButton")
        btn.Parent = winsSidebar
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        btn.Size = UDim2.new(1, -10, 0, 25)
        btn.Font = Enum.Font.Gotham
        btn.Text = mundoName
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 11
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        
        btn.MouseButton1Click:Connect(function()
            selectedCFrame = mundoCoordinates[mundoName]
            chosenWorldLabel.Text = "Mundo seleccionado: " .. mundoName
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
        winsSidebar.Size = UDim2.new(1, 0, 0, 130)
        winsArrowBtn.Text = "v"
    else
        winsSidebar.Visible = false
        winsSidebar.Size = UDim2.new(1, 0, 0, 0)
        winsArrowBtn.Text = ">"
    end
end)

local tpWinBtn = Instance.new("TextButton")
tpWinBtn.Parent = GamePage
tpWinBtn.BackgroundColor3 = Color3.fromRGB(40, 90, 40)
tpWinBtn.Size = UDim2.new(1, 0, 0, 40)
tpWinBtn.Font = Enum.Font.GothamBold
tpWinBtn.Text = "Hacer TP al Mundo"
tpWinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tpWinBtn.TextSize = 13
Instance.new("UICorner", tpWinBtn).CornerRadius = UDim.new(0, 4)

tpWinBtn.MouseButton1Click:Connect(function()
    if not selectedCFrame then return end
    
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        hrp.CFrame = selectedCFrame + Vector3.new(0, 5, 0)
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end
end)

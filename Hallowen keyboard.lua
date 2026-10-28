-- Delta Hub Hallowen
-- El archivo completo es muy grande para multipart incompleto.
-- Ejecuta el script completo LOCAL en Delta (no este bootstrap).
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")
local sg = Instance.new("ScreenGui")
sg.Name = "DeltaHubHallowenMsg"
sg.ResetOnSpawn = false
sg.Parent = pg
local t = Instance.new("TextLabel")
t.Parent = sg
t.Size = UDim2.new(0, 340, 0, 90)
t.Position = UDim2.new(0.5, -170, 0.2, 0)
t.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
t.TextColor3 = Color3.fromRGB(255, 180, 100)
t.Font = Enum.Font.GothamBold
t.TextSize = 13
t.TextWrapped = true
t.Text = "Hallowen: el loader aun no tiene el script completo en GitHub.\nEjecuta el archivo completo en Delta (el de ~157KB).\nPlaceId 128614435234859"
Instance.new("UICorner", t).CornerRadius = UDim.new(0, 8)
warn("[Delta Hub] Hallowen: ejecuta el script completo local, no el bootstrap de GitHub")

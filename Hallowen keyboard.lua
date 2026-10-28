-- Delta Hub Hallowen loader (3 partes -> un solo loadstring)
local base = "https://raw.githubusercontent.com/hv8chyfrk9-creator/Delta-Hub/refs/heads/main/"
local N = 3
local function get(path)
    local url = base .. path .. "?t=" .. tostring(math.floor(tick()))
    local ok, body = pcall(function()
        return game:HttpGet(url)
    end)
    if not ok or type(body) ~= "string" or #body < 20 then
        error("No se pudo bajar " .. tostring(path) .. " (" .. tostring(body) .. ")")
    end
    if body:sub(1, 9) == "<!DOCTYPE" or body:sub(1, 6) == "<html>" then
        error("GitHub devolvio HTML en " .. path .. " - sube el archivo al repo")
    end
    return body
end

local Players = game:GetService("Players")
local pg = Players.LocalPlayer:WaitForChild("PlayerGui")
local sg = Instance.new("ScreenGui")
sg.Name = "DeltaHubHWLoad"
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true
sg.DisplayOrder = 250000
sg.Parent = pg
local lbl = Instance.new("TextLabel")
lbl.Parent = sg
lbl.Size = UDim2.new(0, 300, 0, 60)
lbl.Position = UDim2.new(0.5, -150, 0.12, 0)
lbl.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
lbl.TextColor3 = Color3.fromRGB(120, 255, 140)
lbl.Font = Enum.Font.GothamBold
lbl.TextSize = 13
lbl.TextWrapped = true
lbl.Text = "Hallowen: bajando 1/" .. N .. "..."
Instance.new("UICorner", lbl).CornerRadius = UDim.new(0, 8)

local ok, err = pcall(function()
    local chunks = {}
    for i = 1, N do
        lbl.Text = "Hallowen: bajando " .. i .. "/" .. N .. "..."
        table.insert(chunks, get("HW_p" .. i .. ".lua"))
        task.wait(0.03)
    end
    lbl.Text = "Hallowen: uniendo y ejecutando..."
    local src = table.concat(chunks, "\n")
    local fn, e = loadstring(src)
    if not fn then
        error("loadstring: " .. tostring(e))
    end
    fn()
end)

if ok then
    lbl.Text = "Hallowen: cargado"
    lbl.TextColor3 = Color3.fromRGB(100, 255, 100)
    task.delay(2.5, function()
        if sg then sg:Destroy() end
    end)
else
    lbl.Text = "ERROR: " .. tostring(err)
    lbl.TextColor3 = Color3.fromRGB(255, 120, 120)
    warn("[Delta Hub] " .. tostring(err))
end

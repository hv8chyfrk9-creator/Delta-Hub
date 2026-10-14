# Parches minimos - galaxia 2 Keyboard.lua

Aplica SOLO estos cambios. No reescribas el script.

## 1) Ultimos 2 CFrames

Buscar:
```
    CFrame.new(18024.396484375, 2812.886474609375, -223.57559204101562),
    CFrame.new(18023.5234375, 2812.886474609375, 1761.0914306640625)
}
```

Reemplazar por:
```
    CFrame.new(18100.056641, 2812.886475, -224.773972),
    CFrame.new(18092.367188, 2812.862793, 4993.903320)
}
```

## 2) CFrame 64 (mustPlant)

Buscar el bloque completo de mustPlant que baja a velocidad 0 y hace task.wait(0.25).

Reemplazar por:
```lua
                    local mustPlant = currentIndex == 64
                    local reach = mustPlant and 0.8 or 1
                    while hrp and (hrp.Position - targetPos).Magnitude > reach and routeRunning and hum.Health > 0 do
                        local dist = (hrp.Position - targetPos).Magnitude
                        local spd = approachSpeed(dist, routeCFrames[currentIndex + 1] and (routeCFrames[currentIndex + 1].Position - targetPos).Magnitude)
                        if dist > 0.05 then
                            bv.Velocity = (targetPos - hrp.Position).Unit * spd
                        else
                            bv.Velocity = Vector3.new(0, 0, 0)
                        end
                        RunService.Stepped:Wait()
                    end
                    if mustPlant and hrp then
                        hrp.CFrame = routeCFrames[64] * CFrame.new(0, 0, -1.2)
                        task.wait(0.05)
                    end
```

## 3) Candy Corn

Agregar flag:
```lua
local eventCandy = false
```

En eventKind, antes de return nil:
```lua
    if eventCandy and string.find(n, "eventcoin", 1, true) then
        return "candy"
    end
```

Boton:
```lua
local btnCandy = eventButton("Auto Candy Corn", 3)
local btnXp = eventButton("Auto XP Event Key", 4)

btnCandy.MouseButton1Click:Connect(function()
    eventCandy = not eventCandy
    paintEvent(btnCandy, eventCandy, "Auto Candy Corn")
end)
```

anyOn:
```lua
local anyOn = eventChocolate or eventCoin or eventXp or eventCandy
```

abuseBody:
```lua
btnChocolate.Parent = abuseBody
btnCoin.Parent = abuseBody
btnCandy.Parent = abuseBody
btnXp.Parent = abuseBody
btnChocolate.LayoutOrder = 1
btnCoin.LayoutOrder = 2
btnCandy.LayoutOrder = 3
btnXp.LayoutOrder = 4
```

## 4) Antilag cada 0.3s

Flags cerca de antilagActive:
```lua
local antiDecoOn = false
local antiHallOn = false
local antiKeysOn = false
```

Loop:
```lua
task.spawn(function()
    while true do
        task.wait(0.3)
        if antiDecoOn then
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj.Name == "Decorations" or obj.Name == "Props" then
                    pcall(function() obj:Destroy() end)
                end
            end
        end
        if antiHallOn then
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj.Name == "Halloween" or obj.Name == "HallowenMeshes" then
                    pcall(function() obj:Destroy() end)
                end
            end
        end
        if (antiKeysOn or antilagActive) and hideKeycaps then
            hideKeycaps()
        end
    end
end)
```

Botones:
```lua
antiButton("Decorations", 1, function()
    antiDecoOn = true
    antilagActive = true
    deleteNamed({"Decorations", "Props"})
end)
antiButton("Halloween", 2, function()
    antiHallOn = true
    antilagActive = true
    deleteNamed({"Halloween", "HallowenMeshes"})
end)
antiButton("KeyCaps", 3, function()
    antiKeysOn = true
    antilagActive = true
    if hideKeycaps then hideKeycaps() end
end)
```

## 5) Selector Tween/Tp unificado (Daily)

Agregar:
```lua
local eventCollectMode = "Tween"
```

Quitar skRow con botones chicos Tween/Tp.

Poner en dailyBody debajo de specialKeysToggle:
```lua
local modeHead = Instance.new("TextButton")
modeHead.Parent = dailyBody
modeHead.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
modeHead.Size = UDim2.new(1, -8, 0, 32)
modeHead.Font = Enum.Font.GothamBold
modeHead.Text = "  >  Modo eventos: Tween"
modeHead.TextXAlignment = Enum.TextXAlignment.Left
modeHead.TextColor3 = Color3.fromRGB(240, 240, 245)
modeHead.TextSize = 12
modeHead.LayoutOrder = 2
Instance.new("UICorner", modeHead).CornerRadius = UDim.new(0, 6)

local modeList = Instance.new("Frame")
modeList.Parent = dailyBody
modeList.BackgroundTransparency = 1
modeList.Size = UDim2.new(1, -8, 0, 0)
modeList.AutomaticSize = Enum.AutomaticSize.Y
modeList.Visible = false
modeList.LayoutOrder = 3
local modeLayout = Instance.new("UIListLayout")
modeLayout.Parent = modeList
modeLayout.Padding = UDim.new(0, 4)

for i, modeName in ipairs({"Tween", "Tp"}) do
    local opt = Instance.new("TextButton")
    opt.Parent = modeList
    opt.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
    opt.Size = UDim2.new(1, 0, 0, 28)
    opt.Font = Enum.Font.Gotham
    opt.Text = modeName
    opt.TextColor3 = Color3.fromRGB(240, 240, 245)
    opt.TextSize = 12
    opt.LayoutOrder = i
    Instance.new("UICorner", opt).CornerRadius = UDim.new(0, 5)
    opt.MouseButton1Click:Connect(function()
        eventCollectMode = modeName
        specialKeysMode = modeName
        modeHead.Text = "  >  Modo eventos: " .. modeName
        modeList.Visible = false
        showNotification("Modo eventos: " .. modeName)
    end)
end

modeHead.MouseButton1Click:Connect(function()
    modeList.Visible = not modeList.Visible
    modeHead.Text = (modeList.Visible and "  v  " or "  >  ") .. "Modo eventos: " .. (eventCollectMode or "Tween")
end)
```

En processSpecialKey usar:
```lua
local modeNow = eventCollectMode or specialKeysMode or "Tween"
```
en vez de specialKeysMode solo.

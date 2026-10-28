-- Delta Hub Hallowen (multipart bootstrap)
local base = "https://raw.githubusercontent.com/hv8chyfrk9-creator/Delta-Hub/refs/heads/main/"
local function get(path)
    local ok, body = pcall(function() return game:HttpGet(base .. path .. "?t=" .. tostring(tick())) end)
    if not ok or type(body) ~= "string" or #body < 10 then error("No se pudo bajar " .. tostring(path)) end
    return body
end
local chunks = {}
table.insert(chunks, get("HW_p1.lua"))
table.insert(chunks, get("HW_p2.lua"))
table.insert(chunks, get("HW_p3.lua"))
table.insert(chunks, get("HW_p4.lua"))
table.insert(chunks, get("HW_p5.lua"))
table.insert(chunks, get("HW_p6.lua"))
table.insert(chunks, get("HW_p7.lua"))
table.insert(chunks, get("HW_p8.lua"))
local src = table.concat(chunks, "\n")
local fn, err = loadstring(src)
if not fn then error("Hallowen loadstring: " .. tostring(err)) end
fn()

-- Delta Hub Hallowen bootstrap
local base = "https://raw.githubusercontent.com/hv8chyfrk9-creator/Delta-Hub/refs/heads/main/"
local function get(path)
    local ok, body = pcall(function() return game:HttpGet(base .. path) end)
    if not ok or type(body) ~= "string" then error("No se pudo bajar " .. tostring(path)) end
    return body
end
local chunks = {}
table.insert(chunks, get("Hallowen_part1.lua"))
table.insert(chunks, get("Hallowen_part2.lua"))
table.insert(chunks, get("Hallowen_part3.lua"))
table.insert(chunks, get("Hallowen_part4.lua"))
table.insert(chunks, get("Hallowen_part5.lua"))
table.insert(chunks, get("Hallowen_part6.lua"))
local src = table.concat(chunks, "\n")
local fn, err = loadstring(src)
if not fn then error("Hallowen loadstring: " .. tostring(err)) end
fn()

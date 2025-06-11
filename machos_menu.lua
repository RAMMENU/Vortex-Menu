-- Machos Menu for MachoCheats
local playerPed = GetPlayerPed(-1)
local menuActive = false
local function Wait(ms)
    local start = GetGameTimer()
    while GetGameTimer() - start < ms do end
end
local KEY_F6 = 167
local KEY_F7 = 168
local KEY_F8 = 169
local KEY_F9 = 170
function ToggleMenu()
    menuActive = not menuActive
    print("Machos Menu: " .. (menuActive and "Opened (F7: Teleport, F8: Spawn Adder, F9: God Mode)" or "Closed"))
end
function Teleport()
    SetEntityCoords(playerPed, -1037.0, -2737.0, 13.8, false, false, false, true)
    print("Machos Menu: Teleported to Airport!")
end
function SpawnVehicle()
    local model = GetHashKey("adder")
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(100) end
    local coords = GetEntityCoords(playerPed)
    local vehicle = CreateVehicle(model, coords[1], coords[2], coords[3], GetEntityHeading(playerPed), true, false)
    SetPedIntoVehicle(playerPed, vehicle, -1)
    print("Machos Menu: Spawned Adder!")
end
function ToggleGodMode()
    local isInvincible = GetEntityInvincible(playerPed)
    SetEntityInvincible(playerPed, not isInvincible)
    print("Machos Menu: God Mode " .. (not isInvincible and "On" or "Off"))
end
while true do
    if IsControlJustPressed(0, KEY_F6) then
        ToggleMenu()
    elseif menuActive then
        if IsControlJustPressed(0, KEY_F7) then
            Teleport()
        elseif IsControlJustPressed(0, KEY_F8) then
            SpawnVehicle()
        elseif IsControlJustPressed(0, KEY_F9) then
            ToggleGodMode()
        end
    end
    Wait(0)
end

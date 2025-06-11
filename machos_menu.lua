-- Machos Menu for MachoCheats
local playerPed = GetPlayerPed(-1) -- Get local player
local menuActive = false

-- GTA V native helpers (MachoCheats likely supports these)
local function Wait(ms) -- Simulate Wait for non-FiveM
    local start = GetGameTimer()
    while GetGameTimer() - start < ms do end
end

local function IsControlJustPressed(inputGroup, control) -- Wrapper for native
    return IsControlJustPressed(inputGroup, control) or false
end

-- Key codes (based on GTA V control indices)
local KEY_F6 = 167 -- Toggle menu
local KEY_F7 = 168 -- Teleport
local KEY_F8 = 169 -- Spawn vehicle
local KEY_F9 = 170 -- God mode

-- Toggle menu
function ToggleMenu()
    menuActive = not menuActive
    print("Machos Menu: " .. (menuActive and "Opened (F7: Teleport, F8: Spawn Adder, F9: God Mode)" or "Closed"))
end

-- Teleport to Los Santos Airport
function Teleport()
    local coords = {-1037.0, -2737.0, 13.8}
    SetEntityCoords(playerPed, coords[1], coords[2], coords[3], false, false, false, true)
    print("Machos Menu: Teleported to Airport!")
end

-- Spawn Adder vehicle
function SpawnVehicle()
    local model = GetHashKey("adder")
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(100) end
    local coords = GetEntityCoords(playerPed)
    local vehicle = CreateVehicle(model, coords[1], coords[2], coords[3], GetEntityHeading(playerPed), true, false)
    SetPedIntoVehicle(playerPed, vehicle, -1)
    print("Machos Menu: Spawned Adder!")
end

-- Toggle God Mode
function ToggleGodMode()
    local isInvincible = GetEntityInvincible(playerPed)
    SetEntityInvincible(playerPed, not isInvincible)
    print("Machos Menu: God Mode " .. (not isInvincible and "On" or "Off"))
end

-- Main loop
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
    Wait(0) -- Prevent CPU overload
end

local menuOpen = false
local freeCamera = false
local godmode = false
local invisibility = false
local noRagdoll = false
local infiniteStamina = false
local noClip = false
local superPunch = false
local superStrength = false
local throwPeople = false
local friendlyFire = false
local crosshair = false
local healthAmount = 0
local armorAmount = 0
local model = nil

-- GUI rendering functions
function drawMenu()
    if not menuOpen then return end

    -- Background and title
    DrawRect(0.5, 0.5, 0.3, 0.8, 0, 0, 0, 200)
    DrawText("Freako", 0.5, 0.1, 1, 1, 0, 255, 7, 0.5)

    -- Sidebar
    DrawRect(0.15, 0.5, 0.05, 0.8, 0, 0, 0, 200)
    local sections = {"Player", "Server", "Teleport", "Weapon", "Vehicle", "Emotes", "Events", "Settings"}
    for i, section in ipairs(sections) do
        local y = 0.15 + i * 0.08
        DrawText(section, 0.1, y, 1, 1, 0, 255, 7, 0.3)
        if IsMouseInBounds(0.1, y - 0.03, 0.05, 0.06) and IsMouseJustPressed() then
            -- Handle section selection if needed
        end
    end

    -- Player Options
    if IsMouseInBounds(0.2, 0.2, 0.15, 0.6) then
        DrawRect(0.275, 0.4, 0.15, 0.5, 0, 0, 0, 200)
        DrawText("Player Options", 0.35, 0.2, 1, 1, 0, 255, 7, 0.3)
        toggleOption("Godmode", 0.35, 0.25, godmode)
        toggleOption("Invisibility", 0.35, 0.3, invisibility)
        toggleOption("No Ragdoll", 0.35, 0.35, noRagdoll)
        toggleOption("Infinite Stamina", 0.35, 0.4, infiniteStamina)
        toggleOption("Free Camera", 0.35, 0.45, freeCamera)
        toggleOption("No Clip", 0.35, 0.5, noClip)
        toggleOption("Super Punch", 0.35, 0.55, superPunch)
        toggleOption("Super Strength", 0.35, 0.6, superStrength)
        toggleOption("Throw People From Vehicle", 0.35, 0.65, throwPeople)
        toggleOption("Friendly Fire", 0.35, 0.7, friendlyFire)
        toggleOption("Crosshair", 0.35, 0.75, crosshair)
    end

    -- Misc Options
    if IsMouseInBounds(0.4, 0.2, 0.15, 0.6) then
        DrawRect(0.475, 0.4, 0.15, 0.5, 0, 0, 0, 200)
        DrawText("Misc", 0.55, 0.2, 1, 1, 0, 255, 7, 0.3)
        healthAmount = sliderOption("Health Amount", 0.55, 0.25, healthAmount, 0, 100)
        armorAmount = sliderOption("Armor Amount", 0.55, 0.3, armorAmount, 0, 100)
        model = dropdownOption("Model Changer", 0.55, 0.35, {"Heal", "Armor", "Revive", "Suicide", "Clear Task", "Reset Vision"}, model)
    end
end

function toggleOption(label, x, y, state)
    DrawText(label, x, y, 1, 1, 1, 255, 7, 0.3)
    DrawRect(x + 0.1, y, 0.02, 0.02, 1, 1, 0, state and 255 or 100)
    if IsMouseInBounds(x + 0.1, y - 0.01, 0.02, 0.02) and IsMouseJustPressed() then
        state = not state
    end
end

function sliderOption(label, x, y, value, min, max)
    DrawText(label, x, y, 1, 1, 1, 255, 7, 0.3)
    DrawRect(x + 0.1, y, 0.08, 0.02, 1, 1, 0, 200)
    local newValue = value
    if IsMouseInBounds(x + 0.1, y - 0.01, 0.08, 0.02) and IsMouseDown() then
        local mx = GetMouseX()
        newValue = (mx - (x + 0.1)) / 0.08 * (max - min)
        newValue = math.max(min, math.min(max, newValue))
    end
    DrawRect(x + 0.1 + (newValue / (max - min)) * 0.08, y, 0.002, 0.02, 1, 1, 0, 255)
    return newValue
end

function dropdownOption(label, x, y, options, selected)
    DrawText(label, x, y, 1, 1, 1, 255, 7, 0.3)
    DrawRect(x + 0.1, y, 0.08, 0.02, 1, 1, 0, 200)
    DrawText(selected or "...", x + 0.14, y, 1, 1, 1, 255, 7, 0.2)
    if IsMouseInBounds(x + 0.1, y - 0.01, 0.08, 0.02) and IsMouseJustPressed() then
        -- Simulate dropdown toggle (simplified)
        selected = selected or options[1]
    end
    return selected
end

function IsMouseInBounds(x, y, w, h)
    local mx, my = GetMousePosition()
    return mx >= x and mx <= x + w and my >= y and my <= y + h
end

function IsMouseJustPressed()
    return IsControlJustPressed(0, 24) -- Mouse left click
end

function IsMouseDown()
    return IsControlPressed(0, 24)
end

function GetMousePosition()
    local x, y = GetNuiCursorPosition()
    return x / 1920, y / 1080 -- Normalize to 0-1 scale
end

-- Free Camera Logic
function handleFreeCamera()
    if freeCamera then
        local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        AttachCamToEntity(cam, GetPlayerPed(-1), 0.0, 0.0, 0.0)
        SetCamActive(cam, true)
        RenderScriptCams(true, true, 0, true, false)
        -- Add camera movement controls if desired
    else
        RenderScriptCams(false, false, 0, true, false)
        DestroyAllCams(true)
    end
end

-- Apply states
function applyStates()
    local ped = GetPlayerPed(-1)
    SetEntityInvincible(ped, godmode)
    SetEntityVisible(ped, not invisibility, false)
    SetPedCanRagdoll(ped, not noRagdoll)
    -- Add more state applications as needed
    SetEntityHealth(ped, healthAmount + 100) -- Base health + slider
    SetPedArmour(ped, armorAmount)
end

-- Main loop
while true do
    if IsKeyJustPressed(0x74) then -- F5 key
        menuOpen = not menuOpen
        ShowCursor(menuOpen)
    end

    if menuOpen then
        drawMenu()
        handleFreeCamera()
        applyStates()
    end

    Citizen.Wait(0)
end

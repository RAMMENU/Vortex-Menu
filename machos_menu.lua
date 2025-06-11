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
local lastToggle = 0 -- For debounce

-- GUI rendering functions
function drawText(text, x, y, scale, r, g, b, a)
    pcall(function() DrawText(text, x, y, scale, r, g, b, a) end) -- Error handling
end

function drawRect(x, y, width, height, r, g, b, a)
    pcall(function() DrawRect(x, y, width, height, r, g, b, a) end) -- Error handling
end

function isMouseInBounds(x, y, w, h)
    local mx, my = GetMousePosition() or {0, 0} -- Fallback if nil
    return mx >= x and mx <= x + w and my >= y and my <= y + h
end

function isMouseClicked()
    return IsControlJustPressed(0, 24) -- Mouse left click
end

function toggleOption(label, x, y, state)
    drawText(label, x, y, 0.3, 255, 255, 255, 255)
    drawRect(x + 0.1, y, 0.02, 0.02, 255, 255, 0, state and 255 or 100)
    if isMouseInBounds(x + 0.1, y - 0.01, 0.02, 0.02) and isMouseClicked() then
        state = not state
    end
end

function sliderOption(label, x, y, value, min, max)
    drawText(label, x, y, 0.3, 255, 255, 255, 255)
    drawRect(x + 0.1, y, 0.08, 0.02, 255, 255, 0, 200)
    local newValue = value
    if isMouseInBounds(x + 0.1, y - 0.01, 0.08, 0.02) and IsControlPressed(0, 24) then
        local mx = (GetMousePosition() or {x = 0})[1] / 1920
        newValue = (mx - (x + 0.1)) / 0.08 * (max - min)
        newValue = math.max(min, math.min(max, newValue))
    end
    drawRect(x + 0.1 + (newValue / (max - min)) * 0.08, y, 0.002, 0.02, 255, 255, 0, 255)
    return newValue
end

function dropdownOption(label, x, y, options, selected)
    drawText(label, x, y, 0.3, 255, 255, 255, 255)
    drawRect(x + 0.1, y, 0.08, 0.02, 255, 255, 0, 200)
    drawText(selected or "...", x + 0.14, y, 0.2, 255, 255, 255, 255)
    if isMouseInBounds(x + 0.1, y - 0.01, 0.08, 0.02) and isMouseClicked() then
        selected = selected or options[1]
    end
    return selected
end

-- Free Camera Logic
function handleFreeCamera()
    local playerPed = GetPlayerPed(-1)
    if freeCamera then
        local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        AttachCamToEntity(cam, playerPed, 0.0, 0.0, 0.0)
        SetCamActive(cam, true)
        RenderScriptCams(true, true, 0, true, false)
    else
        RenderScriptCams(false, false, 0, true, false)
        DestroyAllCams(true)
    end
end

-- Apply states
function applyStates()
    local playerPed = GetPlayerPed(-1)
    SetEntityInvincible(playerPed, godmode)
    SetEntityVisible(playerPed, not invisibility, false)
    SetPedCanRagdoll(playerPed, not noRagdoll)
    SetEntityHealth(playerPed, healthAmount + 100)
    SetPedArmour(playerPed, armorAmount)
end

-- Main loop
while true do
    local currentTime = GetGameTimer()
    if IsControlJustPressed(0, 166) and (currentTime - lastToggle) > 300 then -- F5 key with 300ms debounce
        menuOpen = not menuOpen
        lastToggle = currentTime
    end

    if menuOpen then
        drawRect(0.5, 0.5, 0.3, 0.8, 0, 0, 0, 200)
        drawText("Freako", 0.5, 0.1, 0.5, 255, 255, 0, 255)

        drawRect(0.15, 0.5, 0.05, 0.8, 0, 0, 0, 200)
        local sections = {"Player", "Server", "Teleport", "Weapon", "Vehicle", "Emotes", "Events", "Settings"}
        for i, section in ipairs(sections) do
            drawText(section, 0.1, 0.15 + i * 0.08, 0.3, 255, 255, 0, 255)
        end

        if isMouseInBounds(0.2, 0.2, 0.15, 0.6) then
            drawRect(0.275, 0.4, 0.15, 0.5, 0, 0, 0, 200)
            drawText("Player Options", 0.35, 0.2, 0.3, 255, 255, 0, 255)
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

        if isMouseInBounds(0.4, 0.2, 0.15, 0.6) then
            drawRect(0.475, 0.4, 0.15, 0.5, 0, 0, 0, 200)
            drawText("Misc", 0.55, 0.2, 0.3, 255, 255, 0, 255)
            healthAmount = sliderOption("Health Amount", 0.55, 0.25, healthAmount, 0, 100)
            armorAmount = sliderOption("Armor Amount", 0.55, 0.3, armorAmount, 0, 100)
            model = dropdownOption("Model Changer", 0.55, 0.35, {"Heal", "Armor", "Revive", "Suicide", "Clear Task", "Reset Vision"}, model)
        end

        handleFreeCamera()
        applyStates()
    end

    Wait(0)
end

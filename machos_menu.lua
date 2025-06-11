local menuActive = false
local currentSection = 1
local currentOption = 1
local freeCamActive = false
local cam = nil
local camSpeed = 0.5
local teleportEnabled = true

-- Menu Sections
local menuSections = {
    "Player", "Server", "Teleport", "Weapon", "Vehicle", "Emotes", "Events", "Settings"
}

-- Player Options
local playerOptions = {
    {name = "Godmode", state = false, func = function(state) SetEntityInvincible(PlayerPedId(), state) if state then SetEntityHealth(PlayerPedId(), 200) end end},
    {name = "Invisibility", state = false, func = function(state) SetEntityVisible(PlayerPedId(), not state, 0) end},
    {name = "No Ragdoll", state = false, func = function(state) SetPedCanRagdoll(PlayerPedId(), not state) end},
    {name = "Infinite Stamina", state = false, func = function(state) SetPedInfiniteStamina(PlayerPedId(), state) end},
    {name = "Free Camera", state = false, func = function(state) ToggleFreeCam(state) end},
    {name = "No Clip", state = false, func = function(state) ToggleNoClip(state) end},
    {name = "Super Punch", state = false, func = function(state) ToggleSuperPunch(state) end},
    {name = "Super Strength", state = false, func = function(state) ToggleSuperStrength(state) end},
    {name = "Throw People From Vehicle", state = false, func = function(state) ToggleThrowFromVehicle(state) end},
    {name = "Friendly Fire", state = false, func = function(state) -- Placeholder, not fully supported in single-player end},
    {name = "Crosshair", state = false, func = function(state) ShowHudComponentThisFrame(14, state) end}
}

-- Misc Options
local miscOptions = {
    {name = "Health Amount", value = 200, min = 0, max = 200, func = function(value) SetEntityHealth(PlayerPedId(), value) end},
    {name = "Armor Amount", value = 0, min = 0, max = 100, func = function(value) SetPedArmour(PlayerPedId(), value) end},
    {name = "Model Changer", value = "a_m_m_hillbilly_01", func = function(value) ChangeModel(value) end},
    {name = "Heal", func = function() SetEntityHealth(PlayerPedId(), 200) end},
    {name = "Armor", func = function() SetPedArmour(PlayerPedId(), 100) end},
    {name = "Revive", func = function() -- Placeholder, single-player doesn't need revive end},
    {name = "Suicide", func = function() SetEntityHealth(PlayerPedId(), 0) end},
    {name = "Clear Task", func = function() ClearPedTasksImmediately(PlayerPedId()) end},
    {name = "Reset Vision", func = function() ResetPedVisibleDamage(PlayerPedId()) ClearPedBloodDamage(PlayerPedId()) end}
}

-- Utility Functions
local function RotationToDirection(rot)
    local z = math.rad(rot.z)
    local x = math.rad(rot.x)
    local num = math.abs(math.cos(x))
    return vector3(-math.sin(z) * num, math.cos(z) * num, math.sin(x))
end

local function GetCamHitCoord()
    local camCoords = GetCamCoord(cam)
    local camRot = GetCamRot(cam, 2)
    local direction = RotationToDirection(camRot)
    local target = camCoords + direction * 1000.0
    local ray = StartShapeTestRay(camCoords.x, camCoords.y, camCoords.z, target.x, target.y, target.z, -1, PlayerPedId(), 0)
    local _, hit, hitCoords = GetShapeTestResult(ray)
    return (hit == 1) and hitCoords or nil
end

local function TeleportPedToCoord(coord)
    local ped = PlayerPedId()
    local success, groundZ = GetGroundZFor_3dCoord(coord.x, coord.y, coord.z + 10.0, 0)
    local finalZ = success and (groundZ + 1.0) or (coord.z + 1.0)
    SetEntityCoords(ped, coord.x, coord.y, finalZ, false, false, false, true)
    SetEntityHeading(ped, GetCamRot(cam, 2).z)
end

-- Toggle Functions
local function ToggleFreeCam(state)
    freeCamActive = state
    local ped = PlayerPedId()
    if state then
        local coords = GetEntityCoords(ped)
        cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        SetCamCoord(cam, coords.x, coords.y, coords.z + 1.0)
        SetCamRot(cam, 0.0, 0.0, GetEntityHeading(ped))
        RenderScriptCams(true, true, 0, true, true)
        FreezeEntityPosition(ped, true)
        SetEntityCollision(ped, false, false)
    else
        RenderScriptCams(false, true, 0, true, true)
        DestroyCam(cam, false)
        cam = nil
        FreezeEntityPosition(ped, false)
        SetEntityCollision(ped, true, true)
    end
end

local function ToggleNoClip(state)
    local ped = PlayerPedId()
    SetEntityCollision(ped, not state, not state)
    SetEntityAlpha(ped, state and 150 or 255, false)
end

local function ToggleSuperPunch(state)
    local ped = PlayerPedId()
    if state then
        SetPedCombatAbility(ped, 2)
        SetPedCombatRange(ped, 2)
    else
        SetPedCombatAbility(ped, 0)
        SetPedCombatRange(ped, 0)
    end
end

local function ToggleSuperStrength(state)
    local ped = PlayerPedId()
    SetPedMoveRateOverride(ped, state and 1.1 or 1.0)
end

local function ToggleThrowFromVehicle(state)
    if state and IsPedInAnyVehicle(PlayerPedId(), false) then
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        for seat = -1, GetVehicleMaxNumberOfPassengers(vehicle) - 1 do
            local ped = GetPedInVehicleSeat(vehicle, seat)
            if ped ~= 0 and ped ~= PlayerPedId() then
                TaskLeaveVehicle(ped, vehicle, 0)
            end
        end
    end
end

local function ChangeModel(model)
    local ped = PlayerPedId()
    local hash = GetHashKey(model)
    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(0) end
    SetPlayerModel(PlayerId(), hash)
    SetModelAsNoLongerNeeded(hash)
end

-- Render Functions
local function DrawText(x, y, scale, text, r, g, b, a)
    SetTextFont(4)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextOutline()
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x, y)
end

local function DrawRect(x, y, width, height, r, g, b, a)
    DrawRect(x, y, width, height, r, g, b, a)
end

local function DrawMenu()
    if not menuActive then return end

    -- Background
    DrawRect(0.5, 0.5, 0.9, 0.9, 0, 0, 0, 200)

    -- Title
    DrawRect(0.15, 0.05, 0.3, 0.08, 255, 215, 0, 255)
    DrawText(0.3, 0.02, 0.4, "~w~Freako", 255, 255, 255, 255)

    -- Sidebar
    for i, section in ipairs(menuSections) do
        local y = 0.15 + (i - 1) * 0.05
        local color = (i == currentSection) and {255, 255, 0} or {255, 255, 255}
        DrawRect(0.15, y + 0.025, 0.3, 0.05, 0, 0, 0, 150)
        DrawText(0.03, y, 0.3, "~w~" .. section, table.unpack(color))
    end

    -- Vertical Divider
    DrawRect(0.45, 0.5, 0.005, 1.0, 255, 215, 0, 255)

    -- Options
    if menuSections[currentSection] == "Player" then
        DrawText(0.6, 0.12, 0.3, "~y~Player Options", 255, 255, 0, 255)
        for i, option in ipairs(playerOptions) do
            local y = 0.15 + (i - 1) * 0.05
            local color = (i == currentOption) and {255, 255, 255} or {200, 200, 200}
            DrawRect(0.7, y + 0.025, 0.4, 0.05, 0, 0, 0, 180)
            DrawText(0.5, y, 0.3, option.name .. " [" .. (option.state and "~g~ON" or "~r~OFF") .. "~w~]", table.unpack(color))
        end
    elseif menuSections[currentSection] == "Misc" then
        DrawText(0.6, 0.12, 0.3, "~y~Misc", 255, 255, 0, 255)
        local miscY = 0.15
        for i, option in ipairs(miscOptions) do
            local y = miscY + (i - 1) * 0.05
            local color = (i == currentOption - #playerOptions) and {255, 255, 255} or {200, 200, 200}
            if option.value ~= nil and option.min and option.max then
                DrawRect(0.7, y + 0.025, 0.4, 0.05, 0, 0, 0, 180)
                DrawText(0.5, y, 0.3, option.name .. " ~w~" .. option.value, table.unpack(color))
                DrawRect(0.85, y + 0.025, 0.15, 0.03, 255, 215, 0, 255)
                local sliderWidth = (option.value - option.min) / (option.max - option.min) * 0.15
                DrawRect(0.85, y + 0.025, sliderWidth, 0.03, 0, 255, 0, 255)
            else
                DrawRect(0.7, y + 0.025, 0.4, 0.05, 0, 0, 0, 180)
                DrawText(0.5, y, 0.3, option.name, table.unpack(color))
            end
        end
    end
end

-- Main Loop
CreateThread(function()
    while true do
        Wait(0)
        if IsControlJustPressed(0, 166) then -- F5
            menuActive = not menuActive
            if menuActive then currentOption = 1 end
        end

        if menuActive then
            DrawMenu()
            DisableAllControlActions(0)
            EnableControlAction(0, 172, true) -- Up
            EnableControlAction(0, 173, true) -- Down
            EnableControlAction(0, 174, true) -- Left
            EnableControlAction(0, 175, true) -- Right
            EnableControlAction(0, 176, true) -- Enter
            EnableControlAction(0, 177, true) -- Backspace

            if IsControlJustPressed(0, 172) then -- Up
                if menuSections[currentSection] == "Player" then
                    currentOption = currentOption > 1 and currentOption - 1 or #playerOptions
                elseif menuSections[currentSection] == "Misc" then
                    currentOption = currentOption > #playerOptions + 1 and currentOption - 1 or #playerOptions + #miscOptions
                end
            elseif IsControlJustPressed(0, 173) then -- Down
                if menuSections[currentSection] == "Player" then
                    currentOption = currentOption < #playerOptions and currentOption + 1 or 1
                elseif menuSections[currentSection] == "Misc" then
                    currentOption = currentOption < #playerOptions + #miscOptions and currentOption + 1 or #playerOptions + 1
                end
            elseif IsControlJustPressed(0, 174) then -- Left (decrease slider)
                if menuSections[currentSection] == "Misc" then
                    local opt = miscOptions[currentOption - #playerOptions]
                    if opt.value ~= nil and opt.min and opt.max then
                        opt.value = math.max(opt.value - 1, opt.min)
                        opt.func(opt.value)
                    end
                end
            elseif IsControlJustPressed(0, 175) then -- Right (increase slider)
                if menuSections[currentSection] == "Misc" then
                    local opt = miscOptions[currentOption - #playerOptions]
                    if opt.value ~= nil and opt.min and opt.max then
                        opt.value = math.min(opt.value + 1, opt.max)
                        opt.func(opt.value)
                    end
                end
            elseif IsControlJustPressed(0, 176) then -- Enter
                if menuSections[currentSection] == "Player" then
                    local opt = playerOptions[currentOption]
                    opt.func(opt.state)
                elseif menuSections[currentSection] == "Misc" then
                    local opt = miscOptions[currentOption - #playerOptions]
                    opt.func(opt.value or nil)
                end
            elseif IsControlJustPressed(0, 177) then -- Backspace
                menuActive = false
            end
        end

        -- Free Camera Controls
        if freeCamActive and cam then
            DisableAllControlActions(0)
            EnableControlAction(0, 24, true) -- Left click
            EnableControlAction(0, 14, true) -- Scroll up
            EnableControlAction(0, 15, true) -- Scroll down
            EnableControlAction(0, 220, true) -- Mouse X
            EnableControlAction(0, 221, true) -- Mouse Y

            local x, y, z = table.unpack(GetCamCoord(cam))
            local rotX, rotY, rotZ = table.unpack(GetCamRot(cam, 2))
            local forward = GetCamForwardVector(cam)
            local right = vector3(-forward.y, forward.x, 0.0)

            if IsDisabledControlPressed(0, 32) then x = x + forward.x * camSpeed y = y + forward.y * camSpeed z = z + forward.z * camSpeed end
            if IsDisabledControlPressed(0, 33) then x = x - forward.x * camSpeed y = y - forward.y * camSpeed z = z - forward.z * camSpeed end
            if IsDisabledControlPressed(0, 34) then x = x - right.x * camSpeed y = y - right.y * camSpeed end
            if IsDisabledControlPressed(0, 35) then x = x + right.x * camSpeed y = y + right.y * camSpeed end
            if IsDisabledControlPressed(0, 44) then z = z + camSpeed end
            if IsDisabledControlPressed(0, 36) then z = z - camSpeed end

            local rightAxisX = GetDisabledControlNormal(0, 220)
            local rightAxisY = GetDisabledControlNormal(0, 221)
            rotZ = rotZ + rightAxisX * -5.0
            rotX = rotX + rightAxisY * -5.0
            if rotX > 89.0 then rotX = 89.0 end
            if rotX < -89.0 then rotX = -89.0 end

            if IsDisabledControlJustPressed(0, 14) then camSpeed = math.min(camSpeed + 0.1, 2.0)
            elseif IsDisabledControlJustPressed(0, 15) then camSpeed = math.max(camSpeed - 0.1, 0.1) end

            SetCamCoord(cam, x, y, z)
            SetCamRot(cam, rotX, rotY, rotZ, 2)
            SetAudioListenerEntity(PlayerPedId())

            if teleportEnabled and IsDisabledControlJustPressed(0, 24) then
                local coord = GetCamHitCoord()
                if coord then
                    TeleportPedToCoord(coord)
                    ToggleFreeCam(false)
                end
            end
        end
    end
end)

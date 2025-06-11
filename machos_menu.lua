local freeCamActive = false
local cam = nil
local camSpeed = 0.5
local teleportEnabled = true
local menuActive = false
local currentOption = 1

-- Player Option Toggles
local playerOptions = {
    { label = "Godmode", action = "toggle_godmode", state = false },
    { label = "Invisibility", action = "toggle_invis", state = false },
    { label = "No Ragdoll", action = "toggle_noragdoll", state = false },
    { label = "Infinite Stamina", action = "toggle_stamina", state = false },
    { label = "Free Camera", action = "toggle_free_cam", state = false },
    { label = "No Clip", action = "toggle_noclip", state = false },
    { label = "Super Punch", action = "toggle_punch", state = false },
    { label = "Super Strength", action = "toggle_strength", state = false },
    { label = "Throw People From Vehicle", action = "toggle_throw", state = false },
    { label = "Crosshair", action = "toggle_crosshair", state = false }
}

-- Misc Options
local miscOptions = {
    { label = "Health Amount", action = "set_health", value = 200, min = 0, max = 200 },
    { label = "Armor Amount", action = "set_armor", value = 100, min = 0, max = 100 },
    { label = "Change Model", action = "change_model", value = "a_m_m_hillbilly_01" },
    { label = "Heal", action = "heal", value = nil },
    { label = "Armor", action = "armor", value = nil },
    { label = "Suicide", action = "suicide", value = nil },
    { label = "Clear Task", action = "clear_task", value = nil },
    { label = "Reset Vision", action = "reset_vision", value = nil }
}

-- Utility functions
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

-- Toggle functions
local function ToggleGodmode(state)
    local ped = PlayerPedId()
    SetEntityInvincible(ped, state)
    if state then SetEntityHealth(ped, GetEntityMaxHealth(ped)) end
end

local function ToggleInvisibility(state)
    local ped = PlayerPedId()
    SetEntityVisible(ped, not state, 0)
end

local function ToggleNoRagdoll(state)
    local ped = PlayerPedId()
    SetPedCanRagdoll(ped, not state)
end

local function ToggleStamina(state)
    local ped = PlayerPedId()
    SetPedInfiniteStamina(ped, state)
end

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

local function TogglePunch(state)
    local ped = PlayerPedId()
    if state then
        SetPedCombatAbility(ped, 2)
        SetPedCombatRange(ped, 2)
    else
        SetPedCombatAbility(ped, 0)
        SetPedCombatRange(ped, 0)
    end
end

local function ToggleStrength(state)
    local ped = PlayerPedId()
    SetPedMoveRateOverride(ped, state and 1.1 or 1.0)
end

local function ToggleThrow(state)
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

local function ToggleCrosshair(state)
    ShowHudComponentThisFrame(14, state)
end

-- Misc functions
local function SetHealth(value)
    local ped = PlayerPedId()
    SetEntityHealth(ped, value)
end

local function SetArmor(value)
    local ped = PlayerPedId()
    SetPedArmour(ped, value)
end

local function ChangeModel(value)
    local ped = PlayerPedId()
    local model = GetHashKey(value)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end
    SetPlayerModel(PlayerId(), model)
    SetModelAsNoLongerNeeded(model)
end

local function Heal()
    local ped = PlayerPedId()
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
end

local function Armor()
    local ped = PlayerPedId()
    SetPedArmour(ped, 100)
end

local function Suicide()
    local ped = PlayerPedId()
    SetEntityHealth(ped, 0)
end

local function ClearTask()
    local ped = PlayerPedId()
    ClearPedTasksImmediately(ped)
end

local function ResetVision()
    local ped = PlayerPedId()
    ResetPedVisibleDamage(ped)
    ClearPedBloodDamage(ped)
end

-- Action mapping
local actions = {
    toggle_godmode = ToggleGodmode,
    toggle_invis = ToggleInvisibility,
    toggle_noragdoll = ToggleNoRagdoll,
    toggle_stamina = ToggleStamina,
    toggle_free_cam = ToggleFreeCam,
    toggle_noclip = ToggleNoClip,
    toggle_punch = TogglePunch,
    toggle_strength = ToggleStrength,
    toggle_throw = ToggleThrow,
    toggle_crosshair = ToggleCrosshair,
    set_health = SetHealth,
    set_armor = SetArmor,
    change_model = ChangeModel,
    heal = Heal,
    armor = Armor,
    suicide = Suicide,
    clear_task = ClearTask,
    reset_vision = ResetVision
}

-- Draw text on screen
local function DrawText2D(x, y, text, scale, r, g, b, a)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow()
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextOutline()
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x, y)
end

-- Draw menu
local function DrawMenu()
    DrawRect(0.5, 0.5, 0.4, 0.9, 0, 0, 0, 220)
    DrawRect(0.5, 0.1, 0.4, 0.1, 255, 215, 0, 255) -- Yellow header
    DrawText2D(0.3, 0.05, "~y~Freako", 0.6, 255, 255, 255, 255)

    DrawText2D(0.15, 0.15, "~y~Player", 0.4, 255, 255, 0, 255)
    local y = 0.2
    for i, option in ipairs(playerOptions) do
        local color = (i == currentOption and currentOption <= #playerOptions) and { 255, 255, 0, 255 } or { 255, 255, 255, 255 }
        local toggle = option.state and "~g~ON" or "~r~OFF"
        DrawText2D(0.15, y, option.label .. " [" .. toggle .. "]", 0.3, color[1], color[2], color[3], color[4])
        y = y + 0.05
    end

    DrawText2D(0.65, 0.15, "~y~Misc", 0.4, 255, 255, 0, 255)
    y = 0.2
    for i, option in ipairs(miscOptions) do
        local idx = i + #playerOptions
        local color = (currentOption == idx) and { 255, 255, 0, 255 } or { 255, 255, 255, 255 }
        if option.action:find("set_") then
            DrawText2D(0.65, y, option.label .. ": " .. option.value, 0.3, color[1], color[2], color[3], color[4])
            DrawRect(0.75, y + 0.015, 0.15, 0.03, 255, 215, 0, 255) -- Slider background
            local sliderWidth = (option.value - option.min) / (option.max - option.min) * 0.15
            DrawRect(0.75, y + 0.015, sliderWidth, 0.03, 0, 255, 0, 255) -- Slider fill
        else
            DrawText2D(0.65, y, option.label, 0.3, color[1], color[2], color[3], color[4])
        end
        y = y + 0.05
    end
end

-- Main menu loop
CreateThread(function()
    while true do
        Wait(0)
        if IsControlJustPressed(0, 166) then -- F5
            menuActive = not menuActive
            if menuActive then
                currentOption = 1
            end
        end

        if menuActive then
            local ped = PlayerPedId()
            if not DoesEntityExist(ped) then
                menuActive = false
                return
            end

            DrawMenu()
            DisableAllControlActions(0)
            EnableControlAction(0, 172, true) -- Up
            EnableControlAction(0, 173, true) -- Down
            EnableControlAction(0, 174, true) -- Left
            EnableControlAction(0, 175, true) -- Right
            EnableControlAction(0, 176, true) -- Enter
            EnableControlAction(0, 177, true) -- Backspace

            if IsControlJustPressed(0, 172) then
                currentOption = currentOption - 1
                if currentOption < 1 then currentOption = #playerOptions + #miscOptions end
            elseif IsControlJustPressed(0, 173) then
                currentOption = currentOption + 1
                if currentOption > #playerOptions + #miscOptions then currentOption = 1 end
            elseif IsControlJustPressed(0, 174) and miscOptions[currentOption - #playerOptions] and miscOptions[currentOption - #playerOptions].action:find("set_") then
                local opt = miscOptions[currentOption - #playerOptions]
                opt.value = math.max(opt.value - 1, opt.min)
                actions[opt.action](opt.value)
            elseif IsControlJustPressed(0, 175) and miscOptions[currentOption - #playerOptions] and miscOptions[currentOption - #playerOptions].action:find("set_") then
                local opt = miscOptions[currentOption - #playerOptions]
                opt.value = math.min(opt.value + 1, opt.max)
                actions[opt.action](opt.value)
            elseif IsControlJustPressed(0, 176) then
                if currentOption <= #playerOptions then
                    local opt = playerOptions[currentOption]
                    opt.state = not opt.state
                    actions[opt.action](opt.state)
                else
                    local opt = miscOptions[currentOption - #playerOptions]
                    actions[opt.action](opt.value)
                end
            elseif IsControlJustPressed(0, 177) then
                menuActive = false
            end
        end
    end
end)

-- Free Cam Controls
CreateThread(function()
    while true do
        Wait(0)
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

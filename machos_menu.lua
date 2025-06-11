--[[
  FULL FREE CAMERA LUA MENU SCRIPT UPDATED TO MATCH THE TOGGLE UI STYLE SEEN IN "FREAKO"
--]]

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
    { label = "Friendly Fire", action = "toggle_friendly", state = false },
    { label = "Crosshair", action = "toggle_crosshair", state = false }
}

-- Convert rotation to direction vector
local function RotationToDirection(rot)
    local z = math.rad(rot.z)
    local x = math.rad(rot.x)
    local num = math.abs(math.cos(x))
    return vector3(-math.sin(z) * num, math.cos(z) * num, math.sin(x))
end

-- Raycast from cam to get hit position
local function GetCamHitCoord()
    local camCoords = GetCamCoord(cam)
    local camRot = GetCamRot(cam, 2)
    local direction = RotationToDirection(camRot)
    local target = camCoords + direction * 1000.0
    local ray = StartShapeTestRay(camCoords.x, camCoords.y, camCoords.z, target.x, target.y, target.z, 1, -1, 0)
    local _, hit, hitCoords = GetShapeTestResult(ray)
    return (hit == 1) and hitCoords or nil
end

-- Teleport player to the hit location
local function TeleportPedToCoord(coord)
    local ped = PlayerPedId()
    local success, groundZ = GetGroundZFor_3dCoord(coord.x, coord.y, coord.z + 10.0, 0)
    local finalZ = success and (groundZ + 1.0) or (coord.z + 1.0)
    SetEntityCoords(ped, coord.x, coord.y, finalZ, false, false, false, true)
end

-- Enable/disable free cam
function ToggleFreeCam()
    freeCamActive = not freeCamActive
    local ped = PlayerPedId()
    if freeCamActive then
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

-- Draw text on screen
function DrawText2D(x, y, text, scale, r, g, b, a)
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

-- Draw menu with toggles
function DrawMenu()
    DrawRect(0.15, 0.4, 0.3, 0.6, 0, 0, 0, 220)
    DrawRect(0.15, 0.15, 0.3, 0.05, 255, 200, 0, 255)
    DrawText2D(0.08, 0.14, "~y~Freako - Player Options", 0.5, 255, 255, 255, 255)

    local y = 0.2
    for i, option in ipairs(playerOptions) do
        local color = (i == currentOption) and { 255, 255, 0, 255 } or { 200, 200, 200, 255 }
        local toggle = option.state and "~g~ON" or "~r~OFF"
        local labelText = string.format("%s [%s]", option.label, toggle)
        DrawText2D(0.08, y, labelText, 0.4, color[1], color[2], color[3], color[4])
        y = y + 0.045
    end
end

-- Main menu loop
CreateThread(function()
    while true do
        Wait(0)
        if IsControlJustPressed(0, 166) then -- F5
            menuActive = not menuActive
        end

        if menuActive then
            DrawMenu()
            DisableAllControlActions(0)
            EnableControlAction(0, 172, true) -- Up
            EnableControlAction(0, 173, true) -- Down
            EnableControlAction(0, 176, true) -- Enter

            if IsControlJustPressed(0, 172) then
                currentOption = currentOption - 1
                if currentOption < 1 then currentOption = #playerOptions end
            elseif IsControlJustPressed(0, 173) then
                currentOption = currentOption + 1
                if currentOption > #playerOptions then currentOption = 1 end
            elseif IsControlJustPressed(0, 176) then
                local opt = playerOptions[currentOption]
                opt.state = not opt.state
                if opt.action == "toggle_free_cam" then
                    ToggleFreeCam()
                end
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

            if IsDisabledControlJustPressed(0, 14) then
                camSpeed = math.min(camSpeed + 0.1, 2.0)
            elseif IsDisabledControlJustPressed(0, 15) then
                camSpeed = math.max(camSpeed - 0.1, 0.1)
            end

            SetCamCoord(cam, x, y, z)
            SetCamRot(cam, rotX, rotY, rotZ, 2)
            SetAudioListenerEntity(PlayerPedId())

            if teleportEnabled and IsDisabledControlJustPressed(0, 24) then
                local coord = GetCamHitCoord()
                if coord then
                    TeleportPedToCoord(coord)
                    ToggleFreeCam()
                end
            end
        end
    end
end)

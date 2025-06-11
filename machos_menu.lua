local freeCamActive = false
local cam = nil
local camSpeed = 0.5
local toggleKey = 74 -- H key

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

    if hit == 1 then
        return hitCoords
    else
        return nil
    end
end

-- Teleport player to the hit location
local function TeleportPedToCoord(coord)
    local ped = PlayerPedId()
    local success, groundZ = GetGroundZFor_3dCoord(coord.x, coord.y, coord.z + 10.0, 0)
    local finalZ = success and (groundZ + 1.0) or (coord.z + 1.0)
    SetEntityCoords(ped, coord.x, coord.y, finalZ, false, false, false, true)
end

-- Enable/disable free cam
local function ToggleFreeCam()
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

-- Bind H to toggle free cam
CreateThread(function()
    while true do
        Wait(0)
        if IsControlJustPressed(0, toggleKey) then
            ToggleFreeCam()
        end
    end
end)

-- Main Free Cam loop with teleport & exit
CreateThread(function()
    while true do
        Wait(0)
        if freeCamActive and cam then
            DisableAllControlActions(0)

            local x, y, z = table.unpack(GetCamCoord(cam))
            local rotX, rotY, rotZ = table.unpack(GetCamRot(cam, 2))
            local forward = GetCamForwardVector(cam)
            local right = vector3(-forward.y, forward.x, 0.0)

            -- Movement
            if IsDisabledControlPressed(0, 32) then x = x + forward.x * camSpeed y = y + forward.y * camSpeed z = z + forward.z * camSpeed end
            if IsDisabledControlPressed(0, 33) then x = x - forward.x * camSpeed y = y - forward.y * camSpeed z = z - forward.z * camSpeed end
[9:26 PM]
if IsDisabledControlPressed(0, 34) then x = x - right.x * camSpeed y = y - right.y * camSpeed end
            if IsDisabledControlPressed(0, 35) then x = x + right.x * camSpeed y = y + right.y * camSpeed end
            if IsDisabledControlPressed(0, 44) then z = z + camSpeed end
            if IsDisabledControlPressed(0, 36) then z = z - camSpeed end

            -- Mouse look
            local rightAxisX = GetDisabledControlNormal(0, 220)
            local rightAxisY = GetDisabledControlNormal(0, 221)
            rotZ = rotZ + rightAxisX * -5.0
            rotX = rotX + rightAxisY * -5.0
            if rotX > 89.0 then rotX = 89.0 end
            if rotX < -89.0 then rotX = -89.0 end

            SetCamCoord(cam, x, y, z)
            SetCamRot(cam, rotX, rotY, rotZ, 2)

            -- Audio remains at ped
            SetAudioListenerEntity(PlayerPedId())

            -- Teleport on left click
            if IsDisabledControlJustPressed(0, 24) then
                local coord = GetCamHitCoord()
                if coord then
                    TeleportPedToCoord(coord)
                    ToggleFreeCam() -- Auto-exit free cam
                end
            end
        end
    end
end)

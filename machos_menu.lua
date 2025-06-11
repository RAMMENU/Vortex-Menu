local freeCamActive = false
local cam = nil
local camSpeed = 0.5
local teleportEnabled = true
local menuActive = false
local currentSection = 1
local currentOption = 1
local inSubmenu = false

-- Menu structure with sections
local menuOptions = {
    {
        label = "Free Cam Controls",
        options = {
            { label = "Toggle Free Cam (OFF)", action = "toggle_free_cam" },
            { label = "Camera Speed: 0.5", action = "adjust_speed", value = 0.5 },
            { label = "Teleport on Click: ON", action = "toggle_teleport" }
        }
    },
    {
        label = "Actions",
        options = {
            { label = "Trigger Explosion", action = "explode" }
        }
    }
    -- Add more sections here, e.g., { label = "New Section", options = { ... } }
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

-- Trigger explosion at coord
local function TriggerExplosion(coord)
    if coord then
        AddExplosion(coord.x, coord.y, coord.z, 2, 100.0, true, false, 1.0) -- Explosion type 2 (grenade)
    end
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
        SetMouseCursorActiveThisFrame() -- Enable mouse cursor
    else
        RenderScriptCams(false, true, 0, true, true)
        DestroyCam(cam, false)
        cam = nil
        FreezeEntityPosition(ped, false)
        SetEntityCollision(ped, true, true)
    end
    menuOptions[1].options[1].label = "Toggle Free Cam (" .. (freeCamActive and "ON" or "OFF") .. ")"
end

-- Draw text on screen
local function DrawText2D(x, y, text, scale, r, g, b, a)
    SetTextFont(4) -- Modern font
    SetTextProportional(1)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x, y)
end

-- Draw fancy menu
local function DrawMenu()
    -- Gradient background
    DrawRect(0.15, 0.35, 0.25, 0.5, 0, 0, 0, 220) -- Base
    DrawRect(0.15, 0.35, 0.25, 0.5, 0, 150, 255, 100) -- Gradient overlay
    DrawRect(0.15, 0.15, 0.25, 0.05, 0, 100, 200, 255) -- Title bar
    DrawText2D(0.08, 0.14, "~b~VORTEX MENU", 0.5, 255, 255, 255, 255)

    local y = 0.2
    if not inSubmenu then
        -- Display sections
        for i, section in ipairs(menuOptions) do
            local color = (i == currentSection) and { 255, 255, 0, 255 } or { 200, 200, 200, 255 }
            local prefix = (i == currentSection) and "~y~> " or "  "
            DrawText2D(0.08, y, prefix .. section.label, 0.4, color[1], color[2], color[3], color[4])
            y = y + 0.05
        end
    else
        -- Display options in current section
        local section = menuOptions[currentSection]
        DrawText2D(0.08, y, "~b~" .. section.label, 0.45, 255, 255, 255, 255)
        y = y + 0.05
        for i, option in ipairs(section.options) do
            local color = (i == currentOption) and { 255, 255, 0, 255 } or { 200, 200, 200, 255 }
            local prefix = (i == currentOption) and "~y~> " or "  "
            DrawText2D(0.08, y, prefix .. option.label, 0.4, color[1], color[2], color[3], color[4])
            y = y + 0.05
        end
    end
end

-- Menu input handling
CreateThread(function()
    while true do
        Wait(0)
        if IsControlJustPressed(0, 166) then -- F5 to toggle menu
            menuActive = not menuActive
            if not menuActive then inSubmenu = false end -- Reset submenu on close
        end

        if menuActive then
            DrawMenu()
            DisableAllControlActions(0)
            EnableControlAction(0, 172, true) -- Up
            EnableControlAction(0, 173, true) -- Down
            EnableControlAction(0, 176, true) -- Enter
            EnableControlAction(0, 175, true) -- Right (enter submenu)
            EnableControlAction(0, 174, true) -- Left (exit submenu)
            EnableControlAction(0, 166, true) -- F5

            if not inSubmenu then
                -- Navigate sections
                if IsControlJustPressed(0, 172) then -- Up
                    currentSection = currentSection - 1
                    if currentSection < 1 then currentSection = #menuOptions end
                elseif IsControlJustPressed(0, 173) then -- Down
                    currentSection = currentSection + 1
                    if currentSection > #menuOptions then currentSection = 1 end
               率先
                elseif IsControlJustPressed(0, 175) then -- Right (enter submenu)
                    if #menuOptions[currentSection].options > 0 then
                        inSubmenu = true
                        currentOption = 1
                    end
                end
            else
                -- Navigate options
                if IsControlJustPressed(0, 172) then -- Up
                    currentOption = currentOption - 1
                    if currentOption < 1 then currentOption = #menuOptions[currentSection].options end
                elseif IsControlJustPressed(0, 173) then -- Down
                    currentOption = currentOption + 1
                    if currentOption > #menuOptions[currentSection].options then currentOption = 1 end
                elseif IsControlJustPressed(0, 176) then -- Enter
                    local option = menuOptions[currentSection].options[currentOption]
                    if option.action == "toggle_free_cam" then
                        ToggleFreeCam()
                    elseif option.action == "adjust_speed" then
                        camSpeed = camSpeed + 0.1
                        if camSpeed > 2.0 then camSpeed = 0.1 end
                        option.value = camSpeed
                        option.label = string.format("Camera Speed: %.1f", camSpeed)
                    elseif option.action == "toggle_teleport" then
                        teleportEnabled = not teleportEnabled
                        option.label = "Teleport on Click: " .. (teleportEnabled and "ON" or "OFF")
                    elseif option.action == "explode" then
                        local coord = GetCamHitCoord()
                        if coord then
                            TriggerExplosion(coord)
                        end
                    end
                elseif IsControlJustPressed(0, 174) then -- Left (exit submenu)
                    inSubmenu = false
                end
            end
        end
    end
end)

-- Main Free Cam loop with teleport, explosion, and scroll wheel
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
            SetMouseCursorActiveThisFrame() -- Ensure mouse is active

            local x, y, z = table.unpack(GetCamCoord(cam))
            local rotX, rotY, rotZ = table.unpack(GetCamRot(cam, 2))
            local forward = GetCamForwardVector(cam)
            local right = vector3(-forward.y, forward.x, 0.0)

            -- Movement
            if IsDisabledControlPressed(0, 32) then x = x + forward.x * camSpeed y = y + forward.y * camSpeed z = z + forward.z * camSpeed end
            if IsDisabledControlPressed(0, 33) then x = x - forward.x * camSpeed y = y - forward.y * camSpeed z = z - forward.z * camSpeed end
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

            -- Scroll wheel for speed adjustment
            if IsDisabledControlJustPressed(0, 14) then -- Scroll up
                camSpeed = camSpeed + 0.1
                if camSpeed > 2.0 then camSpeed = 2.0 end
                menuOptions[1].options[2].value = camSpeed
                menuOptions[1].options[2].label = string.format("Camera Speed: %.1f", camSpeed)
            elseif IsDisabledControlJustPressed(0, 15) then -- Scroll down
                camSpeed = camSpeed - 0.1
                if camSpeed < 0.1 then camSpeed = 0.1 end
                menuOptions[1].options[2].value = camSpeed
                menuOptions[1].options[2].label = string.format("Camera Speed: %.1f", camSpeed)
            end

            SetCamCoord(cam, x, y, z)
            SetCamRot(cam, rotX, rotY, rotZ, 2)

            -- Audio remains at ped
            SetAudioListenerEntity(PlayerPedId())

            -- Teleport on left click (if enabled)
            if teleportEnabled and IsDisabledControlJustPressed(0, 24) then
                local coord = GetCamHitCoord()
                if coord then
                    TeleportPedToCoord(coord)
                    ToggleFreeCam() -- Auto-exit free cam
                end
            end
        end
    end
end)

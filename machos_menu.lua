local freeCamActive = false
local cam = nil
local camSpeed = 0.5
local teleportEnabled = true
local menuActive = false
local currentOption = 1

-- Player options
local playerOptions = {
    { label = "Godmode",       action="toggle_godmode",      state=false },
    { label = "Invisibility",  action="toggle_invis",        state=false },
    { label = "No Ragdoll",    action="toggle_noragdoll",    state=false },
    { label = "Infinite Stamina", action="toggle_stamina",   state=false },
    { label = "Free Camera",   action="toggle_free_cam",     state=false },
    { label = "No Clip",       action="toggle_noclip",       state=false },
    { label = "Super Punch",   action="toggle_punch",        state=false },
    { label = "Super Strength",action="toggle_strength",     state=false },
    { label = "Throw From Veh", action="toggle_throw",       state=false },
    { label = "Crosshair",     action="toggle_crosshair",    state=false }
}

-- Misc options
local miscOptions = {
    { label="Health Amount", action="set_health", value=200, min=0, max=200 },
    { label="Armor Amount",  action="set_armor",  value=100, min=0, max=100 },
    { label="Change Model",  action="change_model",value="a_m_m_hillbilly_01" },
    { label="Heal",          action="heal" },
    { label="Armor",         action="armor" },
    { label="Suicide",       action="suicide" },
    { label="Clear Task",    action="clear_task" },
    { label="Reset Vision",  action="reset_vision" }
}

-- Utility & toggle functions unchanged...

-- Draw helper:
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

-- Menu rendering function:
local function DrawMenu()
    DrawRect(0.5,0.5,0.4,0.9,0,0,0,220)
    DrawRect(0.5,0.1,0.4,0.1,255,215,0,255)
    DrawText2D(0.32,0.05, "~y~Freako Menu", 0.6,255,255,255,255)
    
    DrawText2D(0.15,0.15, "~y~Player", 0.4,255,255,0,255)
    for i,opt in ipairs(playerOptions) do
        local selected = (currentOption==i)
        local clr = selected and {255,255,0,255} or {255,255,255,255}
        local tog = opt.state and "~g~ON" or "~r~OFF"
        DrawText2D(0.15, 0.15 + i*0.05, opt.label.." ["..tog.."]", 0.3, clr[1],clr[2],clr[3],clr[4])
    end

    DrawText2D(0.65,0.15, "~y~Misc", 0.4,255,255,0,255)
    for i,opt in ipairs(miscOptions) do
        local idx = #playerOptions + i
        local selected = currentOption==idx
        local clr = selected and {255,255,0,255} or {255,255,255,255}
        local y = 0.15 + (i)*0.05
        if opt.min and opt.max then
            DrawText2D(0.65,y,opt.label..": "..opt.value,0.3,clr[1],clr[2],clr[3],clr[4])
            DrawRect(0.75, y+0.015, 0.15, 0.03, 255,215,0,255)
            local lw = ((opt.value - opt.min)/(opt.max - opt.min))*0.15
            DrawRect(0.75, y+0.015, lw, 0.03, 0,255,0,255)
        else
            DrawText2D(0.65,y,opt.label,0.3,clr[1],clr[2],clr[3],clr[4])
        end
    end
end

-- Main loop:
CreateThread(function()
    while true do
        Wait(0)
        
        -- Toggle menu:
        if IsControlJustReleased(0, 166) then -- F5
            menuActive = not menuActive
            if menuActive then currentOption = 1 end
            Wait(150) -- prevent instant undo
        end
        
        if menuActive then
            DrawMenu()
            DisableAllControlActions(0)
            EnableControlAction(0,172,true); -- up
            EnableControlAction(0,173,true); -- down
            EnableControlAction(0,174,true); -- left
            EnableControlAction(0,175,true); -- right
            EnableControlAction(0,176,true); -- enter
            EnableControlAction(0,177,true); -- backspace
            
            if IsControlJustPressed(0,172) then currentOption = (currentOption - 2) % (#playerOptions + #miscOptions) + 1
            elseif IsControlJustPressed(0,173) then currentOption = (currentOption) % (#playerOptions + #miscOptions) + 1
            elseif IsControlJustPressed(0,174) or IsControlJustPressed(0,175) then
                local idx = currentOption - #playerOptions
                if idx>=1 and miscOptions[idx].min then
                    local opt = miscOptions[idx]
                    opt.value = math.min(opt.max, math.max(opt.min, opt.value + (IsControlJustPressed(0,175) and 1 or -1)))
                    actions[opt.action](opt.value)
                end
            elseif IsControlJustPressed(0,176) then
                if currentOption <= #playerOptions then
                    local opt = playerOptions[currentOption]
                    opt.state = not opt.state
                    actions[opt.action](opt.state)
                else
                    local opt = miscOptions[currentOption - #playerOptions]
                    actions[opt.action](opt.value)
                end
            elseif IsControlJustPressed(0,177) then
                menuActive = false
                Wait(150)
            end
        end

        -- Freecam thread:
        if freeCamActive and cam then
            Wait(0)
            DisableAllControlActions(0)
            EnableControlAction(0,24,true)  -- left mouse
            EnableControlAction(0,14,true)  -- scroll up
            EnableControlAction(0,15,true)  -- scroll down
            EnableControlAction(0,220,true) -- dx
            EnableControlAction(0,221,true) -- dy

            local x,y,z = table.unpack(GetCamCoord(cam))
            local rotX,rotY,rotZ = table.unpack(GetCamRot(cam,2))
            local forward = GetCamForwardVector(cam)
            local right = vector3(-forward.y,forward.x,0)

            if IsDisabledControlPressed(0,32) then x,y,z = x+forward.x*camSpeed, y+forward.y*camSpeed, z+forward.z*camSpeed end
            if IsDisabledControlPressed(0,33) then x,y,z = x-forward.x*camSpeed, y-forward.y*camSpeed, z-forward.z*camSpeed end
            if IsDisabledControlPressed(0,34) then x,y = x-right.x*camSpeed, y-right.y*camSpeed end
            if IsDisabledControlPressed(0,35) then x,y = x+right.x*camSpeed, y+right.y*camSpeed end
            if IsDisabledControlPressed(0,44) then z = z+camSpeed end
            if IsDisabledControlPressed(0,36) then z = z-camSpeed end

            local dx,dy = GetDisabledControlNormal(0,220), GetDisabledControlNormal(0,221)
            rotZ = rotZ + dx * -5.0
            rotX = math.max(-89, math.min(89, rotX + dy * -5.0))

            if IsDisabledControlJustPressed(0,14) then camSpeed = math.min(2.0, camSpeed+0.1)
            elseif IsDisabledControlJustPressed(0,15) then camSpeed = math.max(0.1, camSpeed-0.1) end

            SetCamCoord(cam, x, y, z)
            SetCamRot(cam, rotX, rotY, rotZ, 2)
            SetAudioListenerEntity(PlayerPedId())

            if teleportEnabled and IsDisabledControlJustPressed(0,24) then
                local hit = GetCamHitCoord()
                if hit then TeleportPedToCoord(hit); actions["toggle_free_cam"](false) end
            end
        end
    end
end)

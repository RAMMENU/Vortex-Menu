local menuOpen = false
local lastToggle = 0

function drawText(text, x, y, scale, r, g, b, a)
    SetTextFont(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextOutline()
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x, y)
end

function drawRect(x, y, width, height, r, g, b, a)
    DrawRect(x, y, width, height, r, g, b, a)
end

-- Main loop
while true do
    if IsControlJustPressed(0, 166) and (GetGameTimer() - lastToggle > 300) then
        menuOpen = not menuOpen
        lastToggle = GetGameTimer()
        print("Toggled menu. Now: " .. tostring(menuOpen))
    end

    if menuOpen then
        -- Simple menu frame
        drawRect(0.5, 0.5, 0.4, 0.6, 0, 0, 0, 200)
        drawText("VORTEX MENU", 0.4, 0.25, 0.5, 255, 255, 0, 255)
        drawText("Godmode [OFF]", 0.4, 0.35, 0.3, 255, 255, 255, 255)
        drawText("Invisibility [OFF]", 0.4, 0.40, 0.3, 255, 255, 255, 255)
    end

    Wait(0)
end


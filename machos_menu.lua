-- VORTEX MENU - GTA V LUA MENU
-- Matching the visual style of Freako menu

local freeCamActive = false
local cam = nil
local camSpeed = 0.5
local teleportEnabled = true
local menuActive = false
local currentSection = 1
local currentOption = 1
local inSubmenu = false

local sections = {
    { name = "Player", options = {
        { name = "Godmode", state = false },
        { name = "Invisibility", state = false },
        { name = "No Ragdoll", state = false },
        { name = "Infinite Stamina", state = false },
        { name = "Free Camera", state = false },
        { name = "No Clip", state = false },
        { name = "Super Punch", state = false },
        { name = "Super Strength", state = false },
        { name = "Throw People From Vehicle", state = false },
        { name = "Friendly Fire", state = false },
        { name = "Crosshair", state = false },
    }},
    { name = "Server" },
    { name = "Teleport" },
    { name = "Weapon" },
    { name = "Vehicle" },
    { name = "Emotes" },
    { name = "Events" },
    { name = "Settings" },
}

function drawMenu()
    local x = 0.1
    local y = 0.1
    local width = 0.25
    local height = 0.05
    local padding = 0.005

    -- Draw Title
    DrawRect(x + width / 2, y - 0.05, width, 0.05, 10, 10, 10, 255)
    DrawText3D("VORTEX MENU", x + 0.01, y - 0.055, 0.5, 255, 255, 255, 255)

    -- Left Menu
    for i, section in ipairs(sections) do
        local isSelected = (i == currentSection)
        DrawRect(x + width / 2, y + (i - 1) * (height + padding), width, height,
            isSelected and 30 or 15,
            isSelected and 30 or 15,
            isSelected and 30 or 15, 200)
        DrawText3D("\u{2699} " .. section.name, x + 0.01, y + (i - 1) * (height + padding) + 0.01, 0.35,
            255, 255, 0, 255)
    end

    -- Right Panel (if options exist)
    if sections[currentSection].options then
        for i, option in ipairs(sections[currentSection].options) do
            local isSelected = (i == currentOption)
            local toggle = option.state and "ON" or "OFF"
            DrawRect(x + width + 0.15, y + (i - 1) * (height + padding), width, height,
                isSelected and 30 or 20, isSelected and 30 or 20, isSelected and 30 or 20, 200)
            DrawText3D(option.name .. " [" .. toggle .. "]",
                x + width + 0.16, y + (i - 1) * (height + padding) + 0.01, 0.35,
                255, 255, 255, 255)
        end
    end
end

function DrawText3D(text, x, y, scale, r, g, b, a)
    SetTextFont(4)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextOutline()
    SetTextCentre(false)
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x, y)
end

function toggleOption()
    local option = sections[currentSection].options[currentOption]
    option.state = not option.state
    -- Execute specific features
    if option.name == "Free Camera" then
        freeCamActive = option.state
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if IsControlJustPressed(0, 166) then -- F5
            menuActive = not menuActive
        end

        if menuActive then
            drawMenu()

            if IsControlJustPressed(0, 172) then -- UP
                currentOption = currentOption - 1
                if currentOption < 1 then
                    currentOption = #sections[currentSection].options
                end
            elseif IsControlJustPressed(0, 173) then -- DOWN
                currentOption = currentOption + 1
                if currentOption > #sections[currentSection].options then
                    currentOption = 1
                end
            elseif IsControlJustPressed(0, 174) then -- LEFT
                currentSection = currentSection - 1
                if currentSection < 1 then currentSection = #sections end
                currentOption = 1
            elseif IsControlJustPressed(0, 175) then -- RIGHT
                currentSection = currentSection + 1
                if currentSection > #sections then currentSection = 1 end
                currentOption = 1
            elseif IsControlJustPressed(0, 191) then -- ENTER
                if sections[currentSection].options then
                    toggleOption()
                end
            end
        end
    end
end)

-- Add basic free cam logic placeholder (extend as needed)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if freeCamActive then
            -- Free camera logic here
        end
    end
end)

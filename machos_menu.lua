-- VORTEX MENU - Freako Style UI with DirectX Rendering
-- GTA V Singleplayer - Macho Lua Executor Compatible

local menuActive = false
local currentSection = 1
local currentOption = 1
local freeCamActive = false
local cam = nil
local camSpeed = 0.5
local teleportEnabled = true

local menuSections = {
    "Player", "Server", "Teleport", "Weapon", "Vehicle", "Emotes", "Events", "Settings"
}

local playerOptions = {
    {name = "Godmode", state = false},
    {name = "Invisibility", state = false},
    {name = "No Ragdoll", state = false},
    {name = "Infinite Stamina", state = false},
    {name = "Free Camera", state = false},
    {name = "No Clip", state = false},
    {name = "Super Punch", state = false},
    {name = "Super Strength", state = false},
    {name = "Throw People From Vehicle", state = false},
    {name = "Friendly Fire", state = false},
    {name = "Crosshair", state = false},
}

-- Menu Controls
function ToggleMenu()
    menuActive = not menuActive
end

function ToggleFreeCam()
    freeCamActive = not freeCamActive
    -- Add logic for enabling/disabling free camera here
end

-- Toggle feature
function ToggleFeature(option)
    option.state = not option.state
    if option.name == "Free Camera" then
        ToggleFreeCam()
    end
end

-- Render Menu with DirectX
function DrawTextLabel(text, x, y, scale, r, g, b, a, center)
    SetTextFont(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextCentre(center or false)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextOutline()
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x, y)
end

function DrawRectBG(x, y, width, height, r, g, b, a)
    DrawRect(x, y, width, height, r, g, b, a)
end

function DrawMenu()
    if not menuActive then return end

    -- Draw Title
    DrawRectBG(0.15, 0.08, 0.3, 0.08, 0, 0, 0, 200)
    DrawTextLabel("~w~VORTEX MENU", 0.025, 0.045, 1.0, 255, 255, 255, 255, false)

    -- Draw Sidebar
    for i, section in ipairs(menuSections) do
        local y = 0.15 + (i - 1) * 0.045
        local color = (i == currentSection) and {255, 255, 0} or {255, 255, 255}
        DrawRectBG(0.15, y + 0.01, 0.3, 0.035, 0, 0, 0, 150)
        DrawTextLabel("~w~" .. section, 0.025, y, 0.35, table.unpack(color))
    end

    -- Vertical Divider
    DrawRectBG(0.3, 0.5, 0.005, 1.0, 255, 255, 0, 150)

    -- Options (example for Player section)
    if menuSections[currentSection] == "Player" then
        for i, option in ipairs(playerOptions) do
            local y = 0.15 + (i - 1) * 0.035
            local color = (i == currentOption) and {255, 255, 255} or {200, 200, 200}
            DrawRectBG(0.6, y + 0.01, 0.4, 0.03, 0, 0, 0, 180)
            DrawTextLabel(option.name .. " [" .. (option.state and "ON" or "OFF") .. "]", 0.42, y, 0.35, table.unpack(color))
        end
    end
end

-- Menu navigation (F5 toggles menu)
Citizen.CreateThread(function()
    while true do
        Wait(0)

        if IsControlJustPressed(0, 166) then -- F5
            ToggleMenu()
        end

        if menuActive then
            DrawMenu()

            if IsControlJustPressed(0, 172) then -- UP
                currentOption = currentOption > 1 and currentOption - 1 or #playerOptions
            elseif IsControlJustPressed(0, 173) then -- DOWN
                currentOption = currentOption < #playerOptions and currentOption + 1 or 1
            elseif IsControlJustPressed(0, 174) then -- LEFT (prev section)
                currentSection = currentSection > 1 and currentSection - 1 or #menuSections
                currentOption = 1
            elseif IsControlJustPressed(0, 175) then -- RIGHT (next section)
                currentSection = currentSection < #menuSections and currentSection + 1 or 1
                currentOption = 1
            elseif IsControlJustPressed(0, 191) then -- Enter
                if menuSections[currentSection] == "Player" then
                    ToggleFeature(playerOptions[currentOption])
                end
            end
        end
    end
end)

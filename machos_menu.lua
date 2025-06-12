-- VORTEX MENU - DirectX Style Freako Clone for Macho Executor
-- Features: High-fidelity UI, DirectX, toggles, Free Cam, persistent menu

local menuVisible = true
local currentSection = 1
local currentOption = 1
local freeCamEnabled = false

local menuSections = {
    { name = "Player", icon = "⚙", options = {
        { name = "Godmode", toggle = false },
        { name = "Invisibility", toggle = false },
        { name = "No Ragdoll", toggle = false },
        { name = "Infinite Stamina", toggle = false },
        { name = "Free Camera", toggle = false },
        { name = "No Clip", toggle = false },
        { name = "Super Punch", toggle = false },
        { name = "Super Strength", toggle = false },
        { name = "Throw People From Vehicle", toggle = false },
        { name = "Friendly Fire", toggle = false },
        { name = "Crosshair", toggle = false },
    }},
    { name = "Server", icon = "⚙", options = {}},
    { name = "Teleport", icon = "⚙", options = {}},
    { name = "Weapon", icon = "⚙", options = {}},
    { name = "Vehicle", icon = "⚙", options = {}},
    { name = "Emotes", icon = "⚙", options = {}},
    { name = "Events", icon = "⚙", options = {}},
    { name = "Settings", icon = "⚙", options = {}},
}

function toggleFreeCam()
    freeCamEnabled = not freeCamEnabled
    -- Add your actual free cam logic here
end

function drawMenu()
    if not menuVisible then return end

    -- Title bar
    directx.draw_rect(0.05, 0.05, 0.9, 0.06, {0, 0, 0, 200})
    directx.draw_text(0.06, 0.06, "VORTEX MENU", 1.0, {1, 1, 1, 1}, false)

    -- Sidebar
    for i, section in ipairs(menuSections) do
        local y = 0.12 + (i - 1) * 0.04
        local color = i == currentSection and {1, 1, 0, 1} or {1, 1, 1, 0.9}
        directx.draw_text(0.06, y, section.icon .. " " .. section.name, 0.7, color, false)
        directx.draw_rect(0.05, y + 0.03, 0.15, 0.002, {1, 1, 0, 1})
    end

    -- Divider
    directx.draw_rect(0.22, 0.12, 0.002, 0.75, {1, 1, 0, 1})

    -- Options in selected section
    local section = menuSections[currentSection]
    if #section.options > 0 then
        for i, option in ipairs(section.options) do
            local y = 0.12 + (i - 1) * 0.035
            local color = i == currentOption and {1, 1, 1, 1} or {1, 1, 1, 0.85}
            local text = option.name .. " [" .. (option.toggle and "ON" or "OFF") .. "]"
            directx.draw_text(0.24, y, text, 0.65, color, false)
            directx.draw_rect(0.23, y + 0.025, 0.45, 0.001, {1, 1, 0, 0.5})
        end
    end
end

function handleInput()
    if isKeyJustPressed(Keys.F5) then
        menuVisible = not menuVisible
    end
    if not menuVisible then return end

    if isKeyJustPressed(Keys.Up) then
        currentOption = math.max(1, currentOption - 1)
    elseif isKeyJustPressed(Keys.Down) then
        currentOption = math.min(#menuSections[currentSection].options, currentOption + 1)
    elseif isKeyJustPressed(Keys.Left) then
        currentSection = currentSection == 1 and #menuSections or currentSection - 1
        currentOption = 1
    elseif isKeyJustPressed(Keys.Right) then
        currentSection = currentSection == #menuSections and 1 or currentSection + 1
        currentOption = 1
    elseif isKeyJustPressed(Keys.Enter) then
        local option = menuSections[currentSection].options[currentOption]
        if option then
            option.toggle = not option.toggle
            if option.name == "Free Camera" then
                toggleFreeCam()
            end
        end
    end
end

-- MAIN TICK
function OnFrame()
    handleInput()
    drawMenu()
end

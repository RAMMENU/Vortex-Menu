-- Freako-style Menu for Macho Executor
local menuVisible = true
local currentSection = 1
local currentOption = 1

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

-- Helper for drawing toggle switches (simulate with circles or rectangles)
function draw_toggle(x, y, on)
    -- Outer (toggle background)
    directx.draw_rect(x, y, 0.030, 0.016, {0.16, 0.16, 0.16, 1})
    -- Inner circle or rectangle (switch position)
    if on then
        directx.draw_rect(x + 0.016, y + 0.002, 0.012, 0.012, {1, 0.8, 0, 1})
    else
        directx.draw_rect(x + 0.002, y + 0.002, 0.012, 0.012, {0.32, 0.32, 0.32, 1})
    end
end

function drawMenu()
    if not menuVisible then return end

    -- Sidebar
    directx.draw_rect(0.04, 0.04, 0.16, 0.82, {0.08, 0.08, 0.08, 0.99})
    directx.draw_text(0.07, 0.08, "Freako", 1.3, {1, 1, 1, 1}, false)
    for i, section in ipairs(menuSections) do
        local y = 0.14 + (i - 1) * 0.07
        local isSel = (i == currentSection)
        local color = isSel and {1, 0.8, 0, 1} or {1, 1, 1, 0.8}
        if isSel then
            directx.draw_rect(0.045, y-0.014, 0.15, 0.05, {0.14, 0.14, 0.14, 1})
            directx.draw_rect(0.04, y-0.014, 0.008, 0.05, {1, 0.8, 0, 1})
        end
        directx.draw_text(0.065, y, section.icon .. "  " .. section.name, 0.8, color, false)
    end

    -- Main panel
    directx.draw_rect(0.21, 0.08, 0.34, 0.74, {0.13, 0.13, 0.13, 1})
    directx.draw_rect(0.21+0.34-0.012, 0.08, 0.008, 0.74, {1, 0.8, 0, 1})
    directx.draw_text(0.23, 0.10, "Player Options", 0.95, {1, 1, 1, 1}, false)
    directx.draw_rect(0.23, 0.13, 0.29, 0.002, {0.2, 0.2, 0.2, 1})

    -- Options
    local section = menuSections[currentSection]
    if #section.options > 0 then
        for i, option in ipairs(section.options) do
            local y = 0.15 + (i - 1) * 0.054
            local col = i == currentOption and {1, 1, 1, 1} or {1, 1, 1, 0.8}
            directx.draw_text(0.26, y, option.name, 0.85, col, false)
            draw_toggle(0.50, y-0.004, option.toggle)
        end
    end
end

function handleInput()
    if isKeyJustPressed(Keys.F5) then
        menuVisible = not menuVisible
    end
    if not menuVisible then return end
    local section = menuSections[currentSection]
    if isKeyJustPressed(Keys.Up) then
        currentOption = math.max(1, currentOption - 1)
    elseif isKeyJustPressed(Keys.Down) then
        currentOption = math.min(#section.options, currentOption + 1)
    elseif isKeyJustPressed(Keys.Left) then
        currentSection = currentSection == 1 and #menuSections or currentSection - 1
        currentOption = 1
    elseif isKeyJustPressed(Keys.Right) then
        currentSection = currentSection == #menuSections and 1 or currentSection + 1
        currentOption = 1
    elseif isKeyJustPressed(Keys.Enter) then
        local option = section.options[currentOption]
        if option then
            option.toggle = not option.toggle
        end
    end
end

function OnFrame()
    handleInput()
    drawMenu()
end

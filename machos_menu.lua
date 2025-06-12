-- VORTEX Menu using ImGui
local imgui = require("imgui") -- or your environment's way to access ImGui

-- Menu state
local menuVisible = false
local currentSection = 1
local currentOption = 1
local healthAmount = 0
local armorAmount = 0
local modelChanger = "..."
local optionToggles = {}

local menuSections = {
    { name = "Player", options = {
        "Godmode", "Invisibility", "No Ragdoll", "Infinite Stamina",
        "Free Camera", "No Clip", "Super Punch", "Super Strength",
        "Throw People From Vehicle", "Friendly Fire", "Crosshair"
    }},
    { name = "Server", options = {}},
    { name = "Teleport", options = {}},
    { name = "Weapon", options = {}},
    { name = "Vehicle", options = {}},
    { name = "Emotes", options = {}},
    { name = "Events", options = {}},
    { name = "Settings", options = {}},
}

-- Initialize toggle states
for i, section in ipairs(menuSections) do
    optionToggles[i] = {}
    for j, _ in ipairs(section.options) do
        optionToggles[i][j] = false
    end
end

-- Helper: Check if CapsLock was pressed (this implementation may vary based on environment)
local wasCapsLockDown = false
function handleMenuToggle()
    local isCapsLockDown = imgui.IsKeyReleased(imgui.Key_CapsLock)
    if isCapsLockDown and not wasCapsLockDown then
        menuVisible = not menuVisible
    end
    wasCapsLockDown = isCapsLockDown
end

function drawSidebar()
    imgui.BeginChild("Sidebar", imgui.ImVec2(180, 0), true)
    imgui.PushFont(boldFont or imgui.GetFont())
    imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), "VORTEX")
    imgui.PopFont()
    imgui.Spacing()
    for i, section in ipairs(menuSections) do
        if imgui.Selectable(section.name, i == currentSection, 0, imgui.ImVec2(160, 0)) then
            currentSection = i
            currentOption = 1
        end
        if i == currentSection then
            -- Draw yellow bar accent
            local cursorPos = imgui.GetCursorScreenPos()
            imgui.GetWindowDrawList():AddRectFilled(
                imgui.ImVec2(cursorPos.x - 10, cursorPos.y - 32),
                imgui.ImVec2(cursorPos.x - 4, cursorPos.y - 8),
                imgui.ColorConvertFloat4ToU32(imgui.ImVec4(1, 0.8, 0, 1))
            )
        end
    end
    imgui.EndChild()
end

function drawPlayerOptions()
    imgui.BeginChild("PlayerOptions", imgui.ImVec2(320, 0), true)
    -- Header
    imgui.TextColored(imgui.ImVec4(1, 1, 1, 1), "Player Options")
    imgui.SameLine()
    imgui.PushStyleColor(imgui.Col_Separator, imgui.ImVec4(1, 0.8, 0, 1))
    imgui.Separator()
    imgui.PopStyleColor()
    -- Options
    local section = menuSections[currentSection]
    if #section.options > 0 then
        for i, option in ipairs(section.options) do
            imgui.PushID(i)
            local changed, val = imgui.Checkbox(option, optionToggles[currentSection][i])
            if changed then
                optionToggles[currentSection][i] = val
                -- Implement option logic here
            end
            imgui.PopID()
        end
    else
        imgui.TextColored(imgui.ImVec4(0.7, 0.7, 0.7, 1), "No options in this section.")
    end
    imgui.EndChild()
end

function drawMiscPanel()
    imgui.BeginChild("MiscPanel", imgui.ImVec2(260, 0), true)
    imgui.Text("Misc")
    imgui.SameLine()
    imgui.PushStyleColor(imgui.Col_Separator, imgui.ImVec4(1, 0.8, 0, 1))
    imgui.Separator()
    imgui.PopStyleColor()

    -- Health slider
    imgui.Text("Health Amount")
    imgui.SameLine(170)
    imgui.PushStyleColor(imgui.Col_SliderGrab, imgui.ImVec4(1, 0.8, 0, 1))
    local changed1, v1 = imgui.SliderInt("##health", healthAmount, 0, 100)
    if changed1 then healthAmount = v1 end
    imgui.PopStyleColor()

    -- Armor slider
    imgui.Text("Armor Amount")
    imgui.SameLine(170)
    imgui.PushStyleColor(imgui.Col_SliderGrab, imgui.ImVec4(1, 0.8, 0, 1))
    local changed2, v2 = imgui.SliderInt("##armor", armorAmount, 0, 100)
    if changed2 then armorAmount = v2 end
    imgui.PopStyleColor()

    -- Model changer
    imgui.Text("Model Changer")
    imgui.InputText("##model", modelChanger, 32)
    if imgui.Button("Change Model", imgui.ImVec2(220, 0)) then
        -- Change model logic here
    end
    if imgui.Button("Heal", imgui.ImVec2(220, 0)) then
        -- Heal logic here
    end
    if imgui.Button("Armor", imgui.ImVec2(220, 0)) then
        -- Armor logic here
    end
    if imgui.Button("Revive", imgui.ImVec2(220, 0)) then
        -- Revive logic here
    end
    if imgui.Button("Suicide", imgui.ImVec2(220, 0)) then
        -- Suicide logic here
    end
    if imgui.Button("Clear Task", imgui.ImVec2(220, 0)) then
        -- Clear task logic here
    end
    if imgui.Button("Reset Vision", imgui.ImVec2(220, 0)) then
        -- Reset vision logic here
    end

    imgui.EndChild()
end

function drawVortexMenu()
    handleMenuToggle()
    if not menuVisible then return end

    -- Main window
    imgui.SetNextWindowSize(imgui.ImVec2(800, 510), imgui.Cond_Always)
    imgui.PushStyleColor(imgui.Col_WindowBg, imgui.ImVec4(0.09, 0.09, 0.09, 0.99))
    imgui.PushStyleColor(imgui.Col_Border, imgui.ImVec4(1, 0.8, 0, 1))
    imgui.Begin("VORTEX", nil, imgui.WindowFlags_NoResize + imgui.WindowFlags_NoCollapse + imgui.WindowFlags_NoScrollbar)
    imgui.PopStyleColor(2)

    imgui.Columns(3, nil, false)
    drawSidebar()
    imgui.NextColumn()
    drawPlayerOptions()
    imgui.NextColumn()
    drawMiscPanel()
    imgui.Columns(1)

    imgui.End()
end

-- In your render loop, call drawVortexMenu()

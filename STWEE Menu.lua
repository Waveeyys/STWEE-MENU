-- Get screen resolution and calculate scale factor dynamically
local screenX, screenY = GetActualScreenResolution()
local baseResolutionY = screenY  -- Use the current screen height as the base
local scaleFactor = screenY / baseResolutionY
local GFX_ORDER = {
    lowlow = 0,
    BEFORE_HUD = 1,
    BEFORE_HUD_HIGH = 2,
    AFTER_HUD_LOW = 3,
    AFTER_HUD = 4,
    AFTER_HUD_HIGH = 5,
}
local option = {
    invis = false,
}
-- Menu Setup XorMenu.notifications.off
local XorMenu = { 
    esp = false, 
    openkey = 57,
    Nocollision = false,
    Controller = true,
    -- Config table to control individual effects
    espconfig = {
        tracers = false,  
        boxes = false,    
        player = false,    
        data = false,
        npcs = false,  
        skeletons = false,
        health = false,
        armour = false,
        datacfg = {
            distance = false,
            weapon = false,
            health = false,
            name = false,
            IDs = false,
            status = false,
            main = false,
        }
    },
    Functions = {},
    menus = {},
    UI = {
        MenuX = 0.75,
        MenuY = 0.08,
        NotificationX = 0.011,
		NotificationY = 0.3025,
        header = 1,
        bindsX = 0.578,
		bindsY = 0.066,
        spectatorY = 0.066,
        spectatorX = 0.01,
        ItemSpacing = 0.009 * scaleFactor,  -- Scales based on screen height
        MaximumOptionCount = 14, 
    },
    ScreenWidth, ScreenHeight = Citizen.InvokeNative(0x873C9F3104101DD3, Citizen.PointerValueInt(), Citizen.PointerValueInt()),
    rgb = { r = 150, g = 35, b = 150, a = 255 },
    background = { r = 0, g = 0, b = 0, a = 85 },
    selector = { r = 85, g = 15, b = 85, a = 120 },
    notifications = { off = true },
    optionCount = 0,
    currentMenu = nil,
    rgbShiftActive = false,
    rgbShiftBackground = false,
    RGBShiftSelector = false,
    godmodeActive = false,
    godmodeforbros = {},
    invisdisabler = false,
    isNukeActive = false,
    OnePunchMan = false,
    Noclip = false,
    Noclipspeed = 1.0,
    ToggleSpectate = {},
    Bindindicator = false,
    SpectatorIndicator = false,
    Safe = false,
    Uninjected = false,
    ForceEmote = false,
    ForceEmote1 = false,
    ForceEmote2 = false,
    ForceEmote3 = false,
    ForceEmote4 = false,
    ForceEmote5 = false,
    ForceEmote6 = false,
    ForceEmote7 = false,
    ForceEmote8 = false,
    ForceEmote9 = false,
    ForceEmote10 = false,
    ForceEmote11 = false,
    ForceEmoteCustom = false,
    vehicleRepairActive = false,
    TpDisabled = false,
    InvActive = false,
    freecamActive = false,
    camspeed = 1.0,
    DriftOthers = {},
    invis = false,
    Boost = false,
    Boostspeed = 175,
    BoostOthers = {},
    Driftmode = false,
    Driftmode2 = false,
    goatedhandling = false,
    throwing = false,

    -- XOR Configuration
    xorEnabled = false,
    xorKey = "428910",  -- Use this key for all XOR operations
    xorStrength = 0.1,  
    xorSpeed = 1.0,     
}

-- color picker logic
local functions = {}
local draggingBar = nil

-- Screen resolution and safezone cache
functions.screenWidth = 2560
functions.screenHeight = 1440
functions.safeZoneX = 0.0
functions.safeZoneY = 0.0

functions.RefreshScreenData = function()
    functions.screenWidth, functions.screenHeight = GetActiveScreenResolution()
    local safezone = GetSafeZoneSize()
    functions.safeZoneX = (1.0 - safezone) * 0.5
    functions.safeZoneY = (1.0 - safezone) * 0.5
end

-- Pixel → normalized coords (with safezone)
functions.toNormalized = function(xPx, yPx)
    local x = xPx / functions.screenWidth
    local y = yPx / functions.screenHeight
    x = x * (1 - functions.safeZoneX * 2) + functions.safeZoneX
    y = y * (1 - functions.safeZoneY * 2) + functions.safeZoneY
    return x, y
end

-- Pixel size → normalized size
functions.sizeToNormalized = function(wPx, hPx)
    return wPx / functions.screenWidth, hPx / functions.screenHeight
end

functions.DrawTextEx = function(xPx, yPx, text, size, color)
    local f = functions
    local xN, yN = f.toNormalized(xPx, yPx)
    local textSize = size or 0.24

    SetTextFont(0)
    SetTextScale(textSize, textSize)
    SetTextColour(color.r, color.g, color.b, color.a)
    SetTextCentre(false)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextOutline()

    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(xN, yN)
end


-- Draw a rectangle (with optional border)
functions.DrawRectEx = function(xPx, yPx, widthPx, heightPx, color, borderPx, borderColor)
    local xN, yN = functions.toNormalized(xPx, yPx)
    local wN, hN = functions.sizeToNormalized(widthPx, heightPx)
    DrawRect(xN, yN, wN, hN, color.r, color.g, color.b, color.a)
    if borderPx and borderColor then
        local bw = borderPx / functions.screenWidth
        local bh = borderPx / functions.screenHeight
        local halfW, halfH = wN * 0.5, hN * 0.5
        -- top
        DrawRect(xN, yN - halfH + bh * 0.5, wN, bh, borderColor.r, borderColor.g, borderColor.b, borderColor.a)
        -- bottom
        DrawRect(xN, yN + halfH - bh * 0.5, wN, bh, borderColor.r, borderColor.g, borderColor.b, borderColor.a)
        -- left
        DrawRect(xN - halfW + bw * 0.5, yN, bw, hN, borderColor.r, borderColor.g, borderColor.b, borderColor.a)
        -- right
        DrawRect(xN + halfW - bw * 0.5, yN, bw, hN, borderColor.r, borderColor.g, borderColor.b, borderColor.a)
    end
end

----------------------------------
-- Mouse-based UI + Color Picker
----------------------------------
local mouseUi = {
    currentTarget = "selector",
    colorPicker = {
        active = false,
        xOffset = 0, -- base X (can move it)
        yOffset = 0, -- base Y (can move it)
        width = 300,
        barH = 24,
        gap = 10,
        bars = {
            { name = "r", label = "R" },
            { name = "g", label = "G" },
            { name = "b", label = "B" },
            { name = "a", label = "A" },  -- Alpha channel
        },
        selected = { r = 50, g = 150, b = 250, a = 150 },
    },
    active = false,
}

mouseUi.boxes = {
    {
        name = "Main Menu",
        x    = functions.screenWidth * XorMenu.UI.MenuX,
        y    = functions.screenHeight * XorMenu.UI.MenuY,
        w    = 660,
        h    = 600,
    }
}

-- Add Color Picker box
table.insert(mouseUi.boxes, {
    name = "Color Picker",
    x    = (functions.screenWidth * 0.5) - (mouseUi.colorPicker.width * 0.5),
    y    = functions.screenHeight - 300,
    w    = 300,
    h    = 300,
})

table.insert(mouseUi.boxes, {
    name = "Binds",
    x    = functions.screenWidth * XorMenu.UI.bindsX,
    y    = functions.screenHeight * XorMenu.UI.bindsY,
    w    = 300,
    h    = 300,
})

table.insert(mouseUi.boxes, {
    name = "Spectators",
    x    = functions.screenWidth * XorMenu.UI.spectatorX,
    y    = functions.screenHeight * XorMenu.UI.spectatorY,
    w    = 300,
    h    = 300,
})

table.insert(mouseUi.boxes, {
    name = "Notis",
    x    = functions.screenWidth * XorMenu.UI.NotificationX,
    y    = functions.screenHeight * XorMenu.UI.NotificationX,
    w    = 300,
    h    = 300,
})

local draggingBox = { box = nil, offsetX = 0, offsetY = 0 }

function mouseUi.open()
    SetNuiFocus(false, true)
    SetMouseCursorVisible(true)
    mouseUi.active = true
end

function mouseUi.picker()
    mouseUi.open()
    mouseUi.colorPicker.active = true
end

function mouseUi.close()
    SetNuiFocus(false, false)
    SetMouseCursorVisible(false)
    mouseUi.active = false
    mouseUi.colorPicker.active = false
end

function mouseUi.isMouseInRect(mx, my, rect)
    if not (rect and rect.x and rect.y and rect.w and rect.h) then return false end
    return mx >= rect.x and mx <= rect.x + rect.w
       and my >= rect.y and my <= rect.y + rect.h
end

CreateThread(function()
    functions.RefreshScreenData()

    local cp = mouseUi.colorPicker
    cp.xOffset = (functions.screenWidth * 0.5) - (cp.width * 0.5)
    cp.yOffset = functions.screenHeight - 300

    while true do
        if mouseUi.active then
            local mx, my = GetNuiCursorPosition()
            local VISUAL_OFFSET_X = -90
            local VISUAL_OFFSET_Y = -130

            for _, box in ipairs(mouseUi.boxes) do
                Citizen.InvokeNative(0x61BB1D9B3A95D802, GFX_ORDER.lowlow)

                -- No offset when calculating hitboxes or dragging
                local hitbox = {
                    x = box.x + VISUAL_OFFSET_X - 25,
                    y = box.y + VISUAL_OFFSET_Y - 2,
                    w = box.w + 4,
                    h = box.h + 4
                }

                -- Start dragging
                if IsControlJustPressed(0, 24) and mouseUi.isMouseInRect(mx, my, hitbox) then
                    draggingBox.box     = box
                    draggingBox.offsetX = mx - box.x
                    draggingBox.offsetY = my - box.y
                end

                -- Dragging
                if draggingBox.box == box and IsControlPressed(0, 24) then
                    box.x = mx - draggingBox.offsetX
                    box.y = my - draggingBox.offsetY

                    if box.name == "Main Menu" then
                        XorMenu.UI.MenuX = box.x / functions.screenWidth
                        XorMenu.UI.MenuY = box.y / functions.screenHeight
                    end

                    if box.name == "Color Picker" then
                        mouseUi.colorPicker.xOffset = box.x
                        mouseUi.colorPicker.yOffset = box.y + box.h + 10
                    end

                    if box.name == "Binds" then
                        XorMenu.UI.bindsX = box.x / functions.screenWidth
                        XorMenu.UI.bindsY = box.y / functions.screenHeight
                    end

                    if box.name == "Spectators" then
                        XorMenu.UI.spectatorX = box.x / functions.screenWidth
                        XorMenu.UI.spectatorY = box.y / functions.screenHeight
                    end

                    if box.name == "Notis" then
                        XorMenu.UI.NotificationX = box.x / functions.screenWidth
                        XorMenu.UI.NotificationY = box.y / functions.screenHeight
                    end
                end

                -- Stop dragging
                if draggingBox.box == box and IsControlJustReleased(0, 24) then
                    draggingBox.box = nil
                end

                -- Only the drawing uses visual offset
                local drawX = box.x + VISUAL_OFFSET_X
                local drawY = box.y + VISUAL_OFFSET_Y

                functions.DrawRectEx(
                    drawX + (box.w * 0.5), drawY + (box.h * 0.5),
                    box.w, box.h,
                    { r = 30, g = 30, b = 30, a = 200 },
                    1, { r = 255, g = 255, b = 255, a = 100 }
                )

                functions.DrawTextEx(
                    drawX + 15, drawY - 5,
                    box.name,
                    0.35,
                    { r = 255, g = 255, b = 255, a = 255 }
                )
            end
            -- Only check hover once, optimize this part
            local hovered = mouseUi.isMouseInRect(mx, my, mouseUi.colorPicker)
            local col = hovered and { r = 100, g = 200, b = 255, a = 220 } or { r = 0, g = 0, b = 0, a = 0 }

            if hovered and IsControlJustReleased(0, 24) then
                mouseUi.colorPicker.active = not mouseUi.colorPicker.active
            end

            if mouseUi.colorPicker.active then
                local sliderW  = cp.width
                local sliderH  = cp.barH
                local sliderX  = cp.xOffset
                local sliderY0 = cp.yOffset

                for i, bar in ipairs(cp.bars) do
                    local bx = sliderX
                    local by = sliderY0 + (i - 1) * (sliderH + cp.gap)

                    -- background
                    functions.DrawRectEx(
                        bx + 6 + sliderW * 0.5 - 20, by,
                        sliderW - 40, sliderH,
                        { r = 30, g = 30, b = 30, a = 0 },
                        1, { r = 220, g = 220, b = 220, a = 220 }
                    )

                    -- gradient for RGB channels
                    if bar.name ~= "a" then
                        local step = 4
                        for j = 0, sliderW - 20, step do
                            local v = math.floor((j / (sliderW - 20)) * 255)
                            local grad = { r = 0, g = 0, b = 0, a = 255 }
                            grad[bar.name] = v
                            functions.DrawRectEx(
                                bx + 6 + j + step * 0.5 - 4,
                                by,
                                step,
                                sliderH,
                                grad
                            )
                        end
                    else
                        -- gradient for alpha channel
                        local step = 4
                        for j = 0, sliderW - 24, step do
                            local v = math.floor((j / (sliderW - 20)) * 255)
                            local grad = { r = v, g = v, b = v, a = v }
                            functions.DrawRectEx(
                                bx + 6 + j + step * 0.5,
                                by,
                                step,
                                sliderH,
                                grad
                            )
                        end
                    end

                    -- notch (fixed now)
                    local cur = cp.selected[bar.name]
                    local px = bx + 6 + (cur / 255) * (sliderW - 20)

                    functions.DrawRectEx(
                        px, by,
                        8, sliderH + 10,
                        { r = 255, g = 255, b = 255, a = 255 },
                        1, { r = 0, g = 0, b = 0, a = 255 }
                    )

                    -- dragging
                    if IsControlJustPressed(0, 24) then
                        if mx >= bx and mx <= bx + sliderW and my >= by - sliderH * 1.2 and my <= by + sliderH / 64 then
                            draggingBar = bar
                        end
                    end

                    -- Direct mouse drag handling (optimizing update frequency)
                    if draggingBar and IsControlPressed(0, 24) then
                        local curX = mx - bx - 6 -- minus 6 to match the gradient starting point
                        local newv = math.floor((curX / (sliderW - 20)) * 255)
                        newv = math.min(math.max(newv, 0), 255)
                        cp.selected[draggingBar.name] = newv
                        mouseUi.colorPicker.selected[draggingBar.name] = newv
                    end

                    if IsControlJustReleased(0, 24) then
                        draggingBar = nil
                    end
                end

                -- color preview
                functions.DrawRectEx(
                    sliderX + sliderW + 48,
                    sliderY0 + (64 * 0.5),
                    64, 64,
                    { r = cp.selected.r, g = cp.selected.g, b = cp.selected.b, a = cp.selected.a },
                    2, { r = 255, g = 255, b = 255, a = 255 }
                )
            end
        end

        Wait(0)  -- Keep it responsive by keeping the loop minimal
    end
end)

function ApplyColor(tableName)
    local cp = mouseUi.colorPicker.selected
    local dest = XorMenu[tableName]

    if dest and type(dest) == "table" then
        -- overwrite r,g,b,a in the target table
        dest.r = cp.r
        dest.g = cp.g
        dest.b = cp.b
        dest.a = cp.a

        print(("[XorMenu] Applied color to '%s': R=%d G=%d B=%d A=%d")
            :format(tableName, cp.r, cp.g, cp.b, cp.a))
    else
        print(("[XorMenu] ERROR: '%s' is not a valid color table!"):format(tableName))
    end
end


local XorVariables = {
    Notifications = {},
    NotificationIDs = {},
    ScriptOptions = {
        blocktakehostage = false,
    },
}

-- Reserved strings that should never be scrambled
local reservedStrings = {
    ["a_c_seagull"] = true,
    ["creatures@gull@move"] = true,
    ["flapping"] = true,
    ["-699955605"] = true,
    ["-1585415771"] = true,
    ["1124049486"] = true,
    ["1125864094"] = true,
    ["sultan"] = true,
    ["DEFAULT_SCRIPTED_CAMERA"] = true,
}

-- Generate a random key string based solely on xorStrength.
local function generateRandomKey()
    -- Reduce the impact of xorStrength by using a smaller multiplier (e.g., 2 instead of 5).
    local len = math.max(1, math.floor(XorMenu.xorStrength * 10))  -- Reduced multiplier
    local key = ""
    for i = 1, len do
        key = key .. string.char(math.random(33, 126))  -- XorVariables.Pushable ASCII range.
    end
    return key
end

-- Updated XOR function using the generated string key.
local function XORString(str)
    -- Only preserve reserved strings in cleartext when the menu is drawing.
    if XorMenu.menuDrawing then
        if str == "STRING" or str == "commonmenu" or str == "shop_box_tick" or str == "shop_box_blank" or str == ">>>" then
            return str
        end
    end -- If the string is reserved, return it unchanged
    if reservedStrings[str] then
        return str
    end
    if not XorMenu.xorEnabled then 
        return str 
    end
    local key = XorMenu.xorKey
    local keyLen = #key
    local res = ""
    for i = 1, #str do
        local char = str:sub(i, i)
        if math.random() < XorMenu.xorStrength then
            local keyChar = key:sub(((i - 1) % keyLen) + 1, ((i - 1) % keyLen) + 1)
            res = res .. string.char(string.byte(char) ~ string.byte(keyChar))
        else
            res = res .. char
        end
    end
    return res
end

-- Using XORString to display the current state of XOR

-- Periodically update the xorKey using the current xorSpeed value.
Citizen.CreateThread(function()
    while true do
        -- Ensure xorSpeed is at least 1 to prevent the key from updating too frequently.
        Citizen.Wait(math.max(1, XorMenu.xorSpeed) * 50)  -- Update interval scales with xorSpeed.
        XorMenu.xorKey = generateRandomKey()
    end
end)

-- Define multiple prebuilt configurations
local configs = {
    STWEEMenu = {
        esp = false,
        openkey = 137,
        espconfig = {
            tracers = false,
            boxes = false,
            player = false,
            data = false,
            npcs = false,
            skeletons = false,
            health = false,
            armour = false,
            datacfg = {
                distance = false,
                weapon = false,
                health = false,
                name = false,
                IDs = false,
                status = false,
                main = false,
            }
        },
        UI = {
            MenuX = 0.75,
            MenuY = 0.08,
            NotificationX = 0.011,
            NotificationY = 0.3025,
            header = 1,
            bindsX = 0.578,
            bindsY = 0.066,
            spectatorY = 0.066,
            spectatorX = 0.01,
            ItemSpacing = 0.009 * scaleFactor,  -- Scales based on screen height
            MaximumOptionCount = 14, 
        },
        rgb = { r = 150, g = 35, b = 150, a = 255 },
        background = { r = 0, g = 0, b = 0, a = 85 },
        selector = { r = 85, g = 15, b = 85, a = 120 },
        Boostspeed = 5,
        xorEnabled = false,
        xorKey = "428910",
        xorStrength = 0.1,
        xorSpeed = 1.0,
    },
    Eleven5m = {
        esp = false,
        openkey = 137,
        espconfig = {
            tracers = false,
            boxes = false,
            player = false,
            data = false,
            npcs = false,
            skeletons = false,
            health = false,
            armour = false,
            datacfg = {
                distance = false,
                weapon = false,
                health = false,
                name = false,
                IDs = false,
                status = false,
                main = false,
            }
        },
        UI = {
            MenuX = 0.75,
            MenuY = 0.08,
            NotificationX = 0.011,
            NotificationY = 0.3025,
            header = 4,
            bindsX = 0.578,
            bindsY = 0.066,
            spectatorY = 0.066,
            spectatorX = 0.01,
            ItemSpacing = 0.009 * scaleFactor,  -- Scales based on screen height
            MaximumOptionCount = 14, 
        },
        rgb = { r = 255, g = 0, b = 0, a = 255 },
        background = { r = 0, g = 0, b = 0, a = 255 },
        selector = { r = 255, g = 15, b = 15, a = 135 },
        Boostspeed = 5,
        xorEnabled = false,
        xorKey = "428910",
        xorStrength = 0.1,
        xorSpeed = 1.0,
    },
    Picho = {
        esp = false,
        openkey = 178,
        espconfig = {
            tracers = false,
            boxes = false,
            player = false,
            data = false,
            npcs = false,
            skeletons = false,
            health = false,
            armour = false,
            datacfg = {
                distance = false,
                weapon = false,
                health = false,
                name = false,
                IDs = false,
                status = false,
                main = false,
            }
        },
        UI = {
            MenuX = 0.75,
            MenuY = 0.08,
            NotificationX = 0.011,
            NotificationY = 0.3025,
            header = 3,
            bindsX = 0.578,
            bindsY = 0.066,
            spectatorY = 0.066,
            spectatorX = 0.01,
            ItemSpacing = 0.009 * scaleFactor,  -- Scales based on screen height
            MaximumOptionCount = 14, 
        },
        rgb = { r = 80, g = 40, b = 150, a = 255 },
        background = { r = 15, g = 0, b = 15, a = 255 },
        selector = { r = 115, g = 90, b = 120, a = 160 },
        Boostspeed = 5,
        xorEnabled = false,
        xorKey = "428910",
        xorStrength = 0.1,
        xorSpeed = 1.0,
    },
    Wavey = {
        esp = false,
        openkey = 83,
        espconfig = {
            tracers = false,
            boxes = false,
            player = false,
            data = false,
            npcs = false,
            skeletons = false,
            health = false,
            armour = false,
            datacfg = {
                distance = false,
                weapon = false,
                health = false,
                name = false,
                IDs = false,
                status = false,
                main = false,
            }
        },
        UI = {
            MenuX = 0.75,
            MenuY = 0.08,
            NotificationX = 0.011,
            NotificationY = 0.3025,
            header = 5,
            bindsX = 0.578,
            bindsY = 0.066,
            spectatorY = 0.066,
            spectatorX = 0.01,
            ItemSpacing = 0.009 * scaleFactor,  -- Scales based on screen height
            MaximumOptionCount = 14, 
        },
        rgb = { r = 80, g = 40, b = 150, a = 255 },
        background = { r = 15, g = 0, b = 15, a = 255 },
        selector = { r = 115, g = 90, b = 120, a = 160 },
        Boostspeed = 5,
        xorEnabled = false,
        xorKey = "428910",
        xorStrength = 0.1,
        xorSpeed = 1.0,
    },
}

-- Function to apply the selected config
function ApplyConfig(configName)
    local config = configs[configName]
    if config then
        -- Apply values to XorMenu
        XorMenu.esp = config.esp
        XorMenu.openkey = config.openkey
        XorMenu.espconfig = config.espconfig
        XorMenu.UI = config.UI
        XorMenu.rgb = config.rgb
        XorMenu.background = config.background
        XorMenu.selector = config.selector
        XorMenu.Boostspeed = config.Boostspeed
        XorMenu.xorEnabled = config.xorEnabled
        XorMenu.xorKey = config.xorKey
        XorMenu.xorStrength = config.xorStrength
        XorMenu.xorSpeed = config.xorSpeed
    end
end

-- Function to smoothly cycle RGB colors for the menu
function XorMenu.RGBShift()
    Citizen.CreateThread(function()
        local hue = 0
        while XorMenu.rgbShiftActive do
            Citizen.Wait(50) -- smoother transition
            hue = (hue + 2) % 360 -- cycle hues
            local r, g, b = HSLToRGB(hue / 360, 1, 0.5)
            XorMenu.rgb.r = r
            XorMenu.rgb.g = g
            XorMenu.rgb.b = b
        end        
    end)
end

-- Function to smoothly cycle RGB colors for the background
function XorMenu.RGBShiftBackground()
    Citizen.CreateThread(function()
        local hue = 0
        while XorMenu.rgbShiftBackground do
            Citizen.Wait(50) -- smoother transition
            hue = (hue + 2) % 360 -- cycle hues
            local r, g, b = HSLToRGB(hue / 360, 1, 0.5)
            XorMenu.background.r = r  -- Fixed typo: XorMenu.Background should be XorMenu.background
            XorMenu.background.g = g
            XorMenu.background.b = b
        end        
    end)
end

-- Function to smoothly cycle RGB colors for the background
function XorMenu.RGBShiftSelector()
    Citizen.CreateThread(function()
        local hue = 0
        while XorMenu.rgbShiftSelector do
            Citizen.Wait(50) -- smoother transition
            hue = (hue + 2) % 360 -- cycle hues
            local r, g, b = HSLToRGB(hue / 360, 1, 0.5)
            XorMenu.selector.r = r  -- Fixed typo: XorMenu.Background should be XorMenu.background
            XorMenu.selector.g = g
            XorMenu.selector.b = b
        end        
    end)
end

function HSLToRGB(h, s, l)
    local function f(p, q, t)
        if t < 0 then t = t + 1 end
        if t > 1 then t = t - 1 end
        if t < 1/6 then return p + (q - p) * 6 * t end
        if t < 1/2 then return q end
        if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
        return p
    end

    local q = l < 0.5 and l * (1 + s) or l + s - l * s
    local p = 2 * l - q

    local r = math.floor(f(p, q, h + 1/3) * 255)
    local g = math.floor(f(p, q, h) * 255)
    local b = math.floor(f(p, q, h - 1/3) * 255)

    return r, g, b
end

-- Function to Create a Menu (ID remains plain)
function XorMenu.CreateMenu(id, title, subtitle)
    XorMenu.menus[id] = {
        title = XORString(title),
        subTitle = XORString(subtitle),
        visible = false,
        previousMenu = nil,
        selectedIndex = 1,
        items = {},
    }
end

-- Function to Create a SubMenu
function XorMenu.CreateSubMenu(id, parentId, subTitle)
    if not parentId then
        XorVariables.Push("Error: Parent menu ID is nil.")
        return
    end

    if XorMenu.menus[parentId] then
        -- Create the menu under the parent menu and assign previousMenu
        XorMenu.CreateMenu(id, XorMenu.menus[parentId].title, XORString(subTitle))
        XorMenu.menus[id].previousMenu = parentId
    else
        XorVariables.Push(("Error: Parent menu not found: ") .. parentId)
    end
end

-- Add items to a Menu
function XorMenu.AddMenuItem(menuId, item, submenuName)
    if XorMenu.menus[menuId] then
        table.insert(XorMenu.menus[menuId].items, { item = XORString(item), submenuName = submenuName, action = nil })
    else
        XorVariables.Push(("Error: Menu not found: ") .. menuId)
    end
end

-- Add a Button to a Menu
function XorMenu.AddMenuButton(menuId, item, action)
    if XorMenu.menus[menuId] then
        table.insert(XorMenu.menus[menuId].items, { item = XORString(item), submenuName = nil, action = action })
    else
        XorVariables.Push(("Error: Menu not found: ") .. menuId)
    end
end

-- Function to Add a Checkbox
function XorMenu.AddMenuCheckbox(menuId, item, isChecked, action)
    if XorMenu.menus[menuId] then
        -- Add the checkbox item with an index assigned based on the order
        local itemIndex = #XorMenu.menus[menuId].items + 1  -- Get the next available index
        table.insert(XorMenu.menus[menuId].items, {
            item = XORString(item),
            checked = isChecked,
            action = action,
            isCheckbox = true,
            index = itemIndex  -- Assign index for proper positioning
        })
    else
        XorVariables.Push(("Error: Menu not found: ") .. menuId)
    end
end

-- Function to Add a Slider to a Menu
function XorMenu.AddMenuSlider(menuId, item, minValue, maxValue, defaultValue, onChange, stepSize)
    if XorMenu.menus[menuId] then
        local itemIndex = #XorMenu.menus[menuId].items + 1
        table.insert(XorMenu.menus[menuId].items, {
            item = XORString(item),
            minValue = minValue,
            maxValue = maxValue,
            currentValue = defaultValue,
            stepSize = stepSize or 1, -- Default small step size
            isSlider = true,
            index = itemIndex,
            onChange = onChange
        })
    else
        XorVariables.Push(XORString(("Error: Menu not found: ")) .. menuId, 240)
    end
end

function XorMenu.AddMenuStringSelector(menuId, item, stringList, defaultValue, onChange)
    if XorMenu.menus[menuId] then
        local itemIndex = #XorMenu.menus[menuId].items + 1
        table.insert(XorMenu.menus[menuId].items, {
            item = XORString(item),
            stringList = stringList,          -- List of strings to display
            currentValue = defaultValue,      -- Default selected string (index in stringList)
            isStringSelector = true,          -- Flag to distinguish from sliders
            index = itemIndex,
            onChange = function(value)
                onChange(stringList[value]) -- Pass the selected string to the callback
            end
        })
    else
        XorVariables.Push(XORString(("Error: Menu not found: ")) .. menuId, 240)
    end
end


-- Function to Handle Input for the Slider (Arrow Keys)
local sliderHoldStart = nil
local sliderSpeedMultiplier = 1.0

function XorMenu.HandleSliderInput(menuId)
    local menu = XorMenu.menus[menuId]
    local selectedItem = menu.items[menu.selectedIndex]

    if selectedItem and selectedItem.isSlider then
        local previousValue = selectedItem.currentValue
        local stepSize = selectedItem.stepSize or 1 -- Default small step size if not set

        local isAccelerating = IsControlPressed(0, 21) -- Shift key for acceleration
        local isFineControl = IsControlPressed(0, 25)  -- Rmb key for fine control

        local leftHeld = IsControlPressed(0, 174)
        local rightHeld = IsControlPressed(0, 175)

        -- Start hold timer if pressing left or right
        if leftHeld or rightHeld then
            if not sliderHoldStart then
                sliderHoldStart = GetGameTimer()
            end

            -- Calculate how long we've been holding
            local holdDuration = (GetGameTimer() - sliderHoldStart) / 1000.0 -- convert ms to seconds

            -- Smooth acceleration curve (tweak values here)
            sliderSpeedMultiplier = math.min(1.0 + holdDuration * 3.0, 6.0) -- Max 6x faster after ~1.5 seconds hold
        else
            -- Reset when no longer holding
            sliderHoldStart = nil
            sliderSpeedMultiplier = 1.0
        end

        -- Adjust step size dynamically based on fine/fast control
        local actualStep = stepSize

        if isFineControl then
            actualStep = stepSize / 10  -- Fine adjustment
        elseif isAccelerating then
            actualStep = stepSize * 5   -- Shift boosting
        end

        -- Apply smooth multiplier (based on hold time)
        actualStep = actualStep * sliderSpeedMultiplier

        -- Decrease slider value
        if leftHeld and selectedItem.currentValue > selectedItem.minValue then
            selectedItem.currentValue = math.max(selectedItem.minValue, selectedItem.currentValue - actualStep)
        end

        -- Increase slider value
        if rightHeld and selectedItem.currentValue < selectedItem.maxValue then
            selectedItem.currentValue = math.min(selectedItem.maxValue, selectedItem.currentValue + actualStep)
        end

        -- Always round to 2 decimal places
        selectedItem.currentValue = math.floor(selectedItem.currentValue * 100 + 0.5) / 100

        -- Apply value change callback if needed
        if selectedItem.currentValue ~= previousValue and selectedItem.onChange then
            selectedItem.onChange(selectedItem.currentValue)
        end
    end
end

function XorMenu.HandleStringSelectorInput(menuId)
    local menu = XorMenu.menus[menuId]
    local selectedItem = menu.items[menu.selectedIndex]

    if selectedItem and selectedItem.isStringSelector then
        local totalOptions = #selectedItem.stringList

        -- initialize committedValue once
        if selectedItem.committedValue == nil then
            selectedItem.committedValue = selectedItem.currentValue
        end

        -- Left arrow: move selection but don't call onChange yet
        if IsControlJustPressed(0, 174) and selectedItem.currentValue > 1 then
            selectedItem.currentValue = selectedItem.currentValue - 1
        end

        -- Right arrow: move selection but don't call onChange yet
        if IsControlJustPressed(0, 175) and selectedItem.currentValue < totalOptions then
            selectedItem.currentValue = selectedItem.currentValue + 1
        end

        -- Enter key: commit and call onChange if it actually changed
        if IsControlJustPressed(0, 201) then
            if selectedItem.currentValue ~= selectedItem.committedValue then
                selectedItem.committedValue = selectedItem.currentValue
                if selectedItem.onChange then
                    selectedItem.onChange(selectedItem.currentValue)
                end
            end
        end
    end
end

-- Function to Load Texture Dictionary
function LoadTextureDict(dict)
    RequestStreamedTextureDict(dict, true)
    while not HasStreamedTextureDictLoaded(dict) do
        Citizen.Wait(0)
    end
end

local RuntimeTXD = CreateRuntimeTxd('STWEEMenu')
local HeaderObject = CreateDui("https://i.ibb.co/Hf9jzqN5/STWEE-menu-banner2.png", 680, 240)  -- Load the Dui image
_G.HeaderObject = HeaderObject
local TextureThing = GetDuiHandle(HeaderObject)
local Texture = CreateRuntimeTextureFromDuiHandle(RuntimeTXD, 'STWEEMenu2Header', TextureThing)
local RuntimeTXD2 = CreateRuntimeTxd('STWEEMenu2')
local HeaderObject2 = CreateDui("https://i.ibb.co/Hf9jzqN5/STWEE-menu-banner2.png", 2048, 730)  -- Load the Dui image
_G.HeaderObject2 = HeaderObject2
local TextureThing2 = GetDuiHandle(HeaderObject2)
local Texture2 = CreateRuntimeTextureFromDuiHandle(RuntimeTXD2, 'Eleven5mHeader2', TextureThing2)
local RuntimeTXD3 = CreateRuntimeTxd('Eleven5m')
local HeaderObject3 = CreateDui("https://i.ibb.co/y70WRmz/STWEE-menu-banner.png", 680, 240)  -- Load the Dui image
_G.HeaderObject3 = HeaderObject3
local TextureThing3 = GetDuiHandle(HeaderObject3)
local Texture3 = CreateRuntimeTextureFromDuiHandle(RuntimeTXD3, 'PichoHeader3', TextureThing3)
local RuntimeTXD4 = CreateRuntimeTxd('Picho')
local HeaderObject4 = CreateDui("https://i.ibb.co/Hf9jzqN5/STWEE-menu-banner2.png", 680, 240)  -- Load the Dui image
_G.HeaderObject4 = HeaderObject4
local TextureThing4 = GetDuiHandle(HeaderObject4)
local Texture4 = CreateRuntimeTextureFromDuiHandle(RuntimeTXD4, 'TeddyDooHeader', TextureThing4)
local RuntimeTXD5 = CreateRuntimeTxd('hentai')
local HeaderObject5 = CreateDui("https://i.ibb.co/y70WRmz/STWEE-menu-banner.png", 300, 120)  -- Load the Dui image
_G.HeaderObject5 = HeaderObject5
local TextureThing5 = GetDuiHandle(HeaderObject5)
local Texture5 = CreateRuntimeTextureFromDuiHandle(RuntimeTXD5, 'hentaiHeader', TextureThing5)
-- Create a runtime texture dictionary for the scroll indicator background (rounded rectangle)
local roundedRectTXD_bg = CreateRuntimeTxd("scrollindicator_bg")
local roundedRectDui_bg = CreateDui("https://swagi-redacted.github.io/XorScroll/scroll_bgV1.html", 200, 2160)
local roundedRectHandle_bg = GetDuiHandle(roundedRectDui_bg)
local roundedRectTexture_bg = CreateRuntimeTextureFromDuiHandle(roundedRectTXD_bg, "background", roundedRectHandle_bg)

-- Create a runtime texture dictionary for the scroll handle (rounded rectangle)
local roundedRectTXD_handle = CreateRuntimeTxd("scrollindicator_handle")
local roundedRectDui_handle = CreateDui("https://swagi-redacted.github.io/XorScroll/Scroll_handleV1.html", 200, 308)
local roundedRectHandle_handle = GetDuiHandle(roundedRectDui_handle)
local roundedRectTexture_handle = CreateRuntimeTextureFromDuiHandle(roundedRectTXD_handle, "indicator", roundedRectHandle_handle)

function XorMenu.Drawscrollindicator(displayedItems, totalItems, menu)
    if totalItems < 14 then return end

    local scrollBarX = XorMenu.UI.MenuX - 0.018 * scaleFactor
    local scrollBarY = XorMenu.UI.MenuY + 0.045 * scaleFactor

    local itemHeight           = 0.01995 * scaleFactor
    local naturalScrollBarHeight = itemHeight * displayedItems
    local maxScrollBarHeight   = 0.265 * scaleFactor
    local scrollBarHeight      = math.min(naturalScrollBarHeight, maxScrollBarHeight)

    local scrollBarWidth       = 0.0080 * scaleFactor

    -- handle sizing
    local handleHeight = (scrollBarHeight * (XorMenu.UI.MaximumOptionCount / totalItems)) * 0.20
    handleHeight = math.max(handleHeight, 0.01)
    handleHeight = math.min(handleHeight, scrollBarHeight)

    -- raw target position
    local handlePosition = scrollBarY
    if totalItems > 1 then
        handlePosition = scrollBarY +
            ((menu.selectedIndex - 1) / (totalItems - 1)) *
            (scrollBarHeight - handleHeight)
    end

    -- clamp the raw target so it never leaves the scroll‐area
    local minPos = scrollBarY
    local maxPos = scrollBarY + scrollBarHeight - handleHeight
    handlePosition = math.max(minPos, math.min(maxPos, handlePosition))

    -- interpolate smoothly toward the clamped target
    local prev = XorMenu.scrollIndicatorPrevPos or handlePosition
    local smoothSpeed = 10.0
    local interp = prev + (handlePosition - prev) / smoothSpeed

    -- clamp the interpolated value as well
    local currentHandlePosition = math.max(minPos, math.min(maxPos, interp))
    XorMenu.scrollIndicatorPrevPos = currentHandlePosition

    -- draw background & handle
    Citizen.InvokeNative(0x61BB1D9B3A95D802, GFX_ORDER.AFTER_HUD)
    DrawSprite(
        "scrollindicator_bg", "background",
        scrollBarX, scrollBarY + scrollBarHeight / 2,
        scrollBarWidth, scrollBarHeight,
        0.0,
        XorMenu.background.r,
        XorMenu.background.g,
        XorMenu.background.b,
        XorMenu.background.a
    )

    DrawSprite(
        "scrollindicator_handle", "indicator",
        scrollBarX, currentHandlePosition + handleHeight / 2,
        scrollBarWidth, handleHeight,
        0.0,
        XorMenu.rgb.r,
        XorMenu.rgb.g,
        XorMenu.rgb.b,
        175
    )
end


-- Function to Draw Header
function XorMenu.DrawHeader()
    -- Set position for the header (menu's starting point)
    local headerX = XorMenu.UI.MenuX + 0.099
    local headerY = XorMenu.UI.MenuY - 0.005  -- Adjust to be just above the first menu item
    local headerWidth = 0.22
    local headerHeight = 0.10  -- Height of the header (adjust as needed)

    -- Determine which header to draw based on the UI setting
    local textureroot = "XorMenu"
    local headerStyle = "XorMenuHeader"
    if XorMenu.UI.header == 2 then
        textureroot = "XorMenu1"
        headerStyle = "XorMenuHeader2"
    elseif XorMenu.UI.header == 3 then
        textureroot = "XorMenu2"
        headerStyle = "XorMenuHeader3"
    elseif XorMenu.UI.header == 4 then
        textureroot = "TeddyDoo"
        headerStyle = "TeddyDooHeader"
    elseif XorMenu.UI.header == 5 then
        textureroot = "hentai"
        headerStyle = "hentaiHeader"
    end

    Citizen.InvokeNative(0x61BB1D9B3A95D802, GFX_ORDER.AFTER_HUD_LOW)
    DrawSprite(textureroot, headerStyle, headerX, headerY, headerWidth, headerHeight, 0.0, 255, 255, 255, 255)
end

local roundedRectTXD_menu = CreateRuntimeTxd("XorMenuBg")
local roundedRectDui_menu = CreateDui("https://swagi-redacted.github.io/XorScroll/MenuBg.html", 563, 450)
local roundedRectHandle_menu = GetDuiHandle(roundedRectDui_menu)
local roundedRectTexture_menu = CreateRuntimeTextureFromDuiHandle(roundedRectTXD_menu, "Background", roundedRectHandle_menu)
-- fix this later or smth
local roundedRectTXD_outline = CreateRuntimeTxd("XorMenuoutline")
local roundedRectDui_outline = CreateDui("https://swagi-redacted.github.io/XorScroll/menuoutline.html", 563, 850)
local roundedRectHandle_outline = GetDuiHandle(roundedRectDui_outline)
local roundedRectTexture_outline = CreateRuntimeTextureFromDuiHandle(roundedRectTXD_outline, "Outline", roundedRectHandle_outline)
--------------     DrawSprite("XorMenuoutline", "Outline", backgroundX, backgroundY, manualWidth, backgroundHeight, 0.0, XorMenu.rgb.r, XorMenu.rgb.g, XorMenu.rgb.b, XorMenu.rgb.a)

-- Function to Draw Background
function XorMenu.DrawBackground(displayedItemCount)
    local itemHeight = 0.02 * scaleFactor  -- Height per item (scaled)
    local naturalHeight = itemHeight * displayedItemCount * 1.005  -- Natural height based on items
    local maxHeight = 0.27 * scaleFactor  -- Maximum allowed height
    local backgroundHeight = math.min(naturalHeight, maxHeight)  -- Clamp to max height
    
    local manualYOffset = 0.045 * scaleFactor  -- Y offset adjustment
    local manualXOffset = 0.099 * scaleFactor  -- X offset adjustment
    local manualWidth = 0.22 * scaleFactor     -- Background width
    local backgroundY = XorMenu.UI.MenuY + (backgroundHeight / 2) + manualYOffset
    local backgroundX = XorMenu.UI.MenuX + manualXOffset

    Citizen.InvokeNative(0x61BB1D9B3A95D802, GFX_ORDER.BEFORE_HUD)
    DrawSprite("XorMenuBg", "Background", backgroundX, backgroundY, manualWidth, backgroundHeight, 0.0, XorMenu.background.r, XorMenu.background.g, XorMenu.background.b, XorMenu.background.a)
end

local roundedRectTXD_notis = CreateRuntimeTxd("drawxornotis")
local roundedRectDui_notis = CreateDui("https://swagi-redacted.github.io/XorScroll/DrawNotis/drawnotifications.html", 1000, 60)
local roundedRectHandle_notis = GetDuiHandle(roundedRectDui_notis)
local roundedRectTexture_notis = CreateRuntimeTextureFromDuiHandle(roundedRectTXD_notis, "notismenu", roundedRectHandle_notis)
--placeholder not right yet
local roundedRectTXD_notis2 = CreateRuntimeTxd("drawxornotis2")
local roundedRectDui_notis2 = CreateDui("https://swagi-redacted.github.io/XorScroll/DrawNotis/drawnotisbackground.html", 1000, 50)
local roundedRectHandle_notis2 = GetDuiHandle(roundedRectDui_notis2)
local roundedRectTexture_notis2 = CreateRuntimeTextureFromDuiHandle(roundedRectTXD_notis2, "notismenu2", roundedRectHandle_notis2)
-- for now its just a square for the actual notis

Citizen.CreateThread(function()
    while true do
        if XorMenu.notifications.off then
            Wait(1) -- **Pause loop while notifications are disabled**
        else
            if XorMenu.menus[XorMenu.currentMenu] and XorMenu.menus[XorMenu.currentMenu].visible and #XorVariables.Notifications > 0 then
                local hasActiveNotifications = false
                local notificationCount = #XorVariables.Notifications

                -- Clean up expired notifications
                for i = notificationCount, 1, -1 do
                    local notification = XorVariables.Notifications[i]
                    if notification.duration == nil then 
                        notification.duration = 2 
                    end

                    if notification.duration <= 0 then
                        XorVariables.NotificationIDs[notification.id] = nil
                        table.remove(XorVariables.Notifications, i)
                    else
                        notification.duration = notification.duration - 1
                        hasActiveNotifications = true
                    end
                end

                if hasActiveNotifications then
                    local baseY = XorMenu.UI.NotificationY
                    local notificationHeight = 0.04 -- Height for each notification
                    local totalHeight = notificationHeight * notificationCount -- Total height for all notifications

                    Citizen.InvokeNative(0x61BB1D9B3A95D802, GFX_ORDER.AFTER_HUD_HIGH)

                    -- **Draw Notification Header**
                    DrawNotificationText("[STWEE Menu] ~w~Notifications", XorMenu.UI.NotificationX + 0.0025, baseY + 0.0025, XorMenu.rgb.r, XorMenu.rgb.g, XorMenu.rgb.b, 255, 0.45, 4)
                    DrawSprite("drawxornotis", "notismenu", XorMenu.UI.NotificationX + 0.15, baseY + 0.0175, 0.30, 0.040, 0.0, 150, 35, 150, 255)
                    DrawSprite("drawxornotis", "notismenu", XorMenu.UI.NotificationX + 0.15, baseY + 0.0345, 0.30, 0.001, 0.0, XorMenu.rgb.r, XorMenu.rgb.g, XorMenu.rgb.b, 255)

                    -- **Draw Notifications and Move Them Down**
                    for i, notification in ipairs(XorVariables.Notifications) do
                        local updatedMessage = XORString(notification.message)
                        DrawRect(XorMenu.UI.NotificationX + 0.15, XorMenu.UI.NotificationY + 0.0175 + 0.035 * i, 0.30, 0.035, 10, 10, 10, 220)
                        DrawNotificationText("[SM] ~w~" .. updatedMessage, XorMenu.UI.NotificationX, XorMenu.UI.NotificationY + 0.035 * i, XorMenu.rgb.r, XorMenu.rgb.g, XorMenu.rgb.b, 255, 0.45, 4)
                    end
                end
            end
            Wait(1)
        end
    end
end)

-- Function to push a notification with ID check
function XorVariables.Push(Message, Duration)
    local id = tostring(Message) -- Unique identifier based on the message content

    -- Prevent duplicate notifications
    if not XorVariables.NotificationIDs[id] then
        XorVariables.NotificationIDs[id] = true
        table.insert(XorVariables.Notifications, {id = id, message = Message, duration = Duration})
    end
end

-- Safe Mode Notification Example
function SafeModeNotification()
    XorVariables.Push(XORString("Safe Mode is ~g~Active ~s~Function Blocked", 600))
end

-- Draw Text Function
function DrawNotificationText(text, x, y, r, g, b, a, scale, font)
    Citizen.InvokeNative(0x61BB1D9B3A95D802, GFX_ORDER.AFTER_HUD_HIGH)
    SetTextFont(font)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextOutline()
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x, y)
end

local roundedRectTXD_Selector = CreateRuntimeTxd("DrawXorSelector")
local roundedRectDui_Selector = CreateDui("https://swagi-redacted.github.io/XorScroll/Selector.html", 563, 22)
local roundedRectHandle_Selector = GetDuiHandle(roundedRectDui_Selector)
local roundedRectTexture_Selector = CreateRuntimeTextureFromDuiHandle(roundedRectTXD_Selector, "Selector", roundedRectHandle_Selector)

local previousSelectorY = nil
-- update screen resolution & safezone 
local function RefreshScreenData()
    local sw, sh = GetActiveScreenResolution()
    functions.screenWidth  = sw
    functions.screenHeight = sh

    local safezone = GetSafeZoneSize()
    functions.safeZoneX = (1.0 - safezone) * 0.5
    functions.safeZoneY = (1.0 - safezone) * 0.5
end

local function toNormalized(xPx, yPx)
    local f = functions
    local x = xPx and (xPx / f.screenWidth) or nil
    local y = yPx and (yPx / f.screenHeight) or nil

    if x then
        x = x * (1 - f.safeZoneX * 2) + f.safeZoneX
    end
    if y then
        y = y * (1 - f.safeZoneY * 2) + f.safeZoneY
    end

    return x, y
end
local function sizeToNormalized(wPx, hPx)
    return wPx / functions.screenWidth, hPx / functions.screenHeight
end

-- draw text at pixel coords
local function DrawTextEx(xPx, yPx, text, size, color)
    local xN, yN = toNormalized(xPx, yPx)
    local textSize = size or 0.35
    SetTextFont(0)
    SetTextScale(textSize, textSize)
    SetTextColour(color.r, color.g, color.b, color.a)
    SetTextCentre(false)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextOutline()
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(xN, yN)
end

-- draw rectangle with border
local function DrawRectEx(xPx, yPx, widthPx, heightPx, color, borderPx, borderColor)
    local xN, yN = toNormalized(xPx, yPx)
    local wN, hN = sizeToNormalized(widthPx, heightPx)
    DrawRect(xN, yN, wN, hN, color.r, color.g, color.b, color.a)
    if borderPx and borderColor then
        local borders = {
            top    = borderPx,
            bottom = borderPx,
            left   = borderPx,
            right  = borderPx,
        }
        local bh = borders.top / functions.screenHeight
        local c  = borderColor
        -- top
        DrawRect(xN, yN - hN/2 + bh/2, wN, bh, c.r, c.g, c.b, c.a)
        -- bottom
        DrawRect(xN, yN + hN/2 - bh/2, wN, bh, c.r, c.g, c.b, c.a)
        -- left
        local bw = borders.left / functions.screenWidth
        DrawRect(xN - wN/2 + bw/2, yN, bw, hN, c.r, c.g, c.b, c.a)
        -- right
        DrawRect(xN + wN/2 - bw/2, yN, bw, hN, c.r, c.g, c.b, c.a)
    end
end

function XorMenu.DrawMenu(menuId)
    local menu = XorMenu.menus[menuId]
    if menu.visible then
        XorMenu.menuDrawing = true  -- Set flag: menu is drawing
    
    -- 1) initialize some vars
    local totalItems = #menu.items
    local maxCount   = XorMenu.UI.MaximumOptionCount

    -- 2) maintain a persistent scrollOffset on the menu
    menu.scrollOffset = menu.scrollOffset or 1
    local startIdx   = menu.scrollOffset
    local endIdx     = startIdx + maxCount - 1

    -- 3) if selection moves below visible window, scroll down
    if menu.selectedIndex > endIdx then
        startIdx = menu.selectedIndex - maxCount + 1

    -- 4) if selection moves above visible window, scroll up
    elseif menu.selectedIndex < startIdx then
        startIdx = menu.selectedIndex
    end

    -- 5) clamp to [1 .. totalItems–maxCount+1]
    startIdx = math.max(1, math.min(startIdx, totalItems - maxCount + 1))
    endIdx   = math.min(startIdx + maxCount - 1, totalItems)

    -- 6) store it back for next frame
    menu.scrollOffset = startIdx

    -- 7) now draw from startIdx to endIdx as before:
    local yOffset = 0.05 * scaleFactor
        -- Draw header before items
        XorMenu.DrawHeader()

        local displayedItems = endIdx - startIdx + 1
        XorMenu.DrawBackground(displayedItems)
        XorMenu.Drawscrollindicator(displayedItems, totalItems, menu)

        for i = startIdx, endIdx do
            local item = menu.items[i]
            local menuXPos = XorMenu.UI.MenuX
            local menuYPos = XorMenu.UI.MenuY + yOffset
            yOffset = yOffset + XorMenu.UI.ItemSpacing


            -- Draw selection highlight rectangle
            if i == menu.selectedIndex then
                local rectWidth = 0.22  -- Adjust width if needed
                local itemHeight = 0.02 * scaleFactor  -- Height per item (scaled)
                local naturalHeight = itemHeight * 1.005  -- Natural height based on items
                local rectHeight = naturalHeight  -- Clamp to max height
                local rectX = menuXPos + 0.10
                local targetRectY = menuYPos + rectHeight / 2
            
                -- Initialize previous position if needed
                if not previousSelectorY then
                    previousSelectorY = targetRectY
                end
            
                -- Smooth the Y position
                local frameTime = GetFrameTime()
                local smoothSpeed = 15.0
                previousSelectorY = previousSelectorY + (targetRectY - previousSelectorY) * math.min(frameTime * smoothSpeed, 1.0)
            
                -- Draw under HUD
                Citizen.InvokeNative(0x61BB1D9B3A95D802, GFX_ORDER.BEFORE_HUD_HIGH)
            
                -- Draw highlighted rectangle behind selected item
                DrawSprite("DrawXorSelector", "Selector", rectX - 0.0011, previousSelectorY - 0.0008, rectWidth - 0.0116, rectHeight, 0.0, XorMenu.selector.r, XorMenu.selector.g, XorMenu.selector.b, XorMenu.selector.a) -- Semi-transparent
            
                -- Change text color for selected item
                SetTextColour(XorMenu.rgb.r, XorMenu.rgb.g, XorMenu.rgb.b, XorMenu.rgb.a)
            else
                SetTextColour(255, 255, 255, 255)
            end

            SetTextFont(0)
            SetTextScale(0.24, 0.24)
            BeginTextCommandDisplayText("STRING")
            AddTextComponentSubstringPlayerName(XORString(item.item))
            EndTextCommandDisplayText(menuXPos, menuYPos)

            if item.isSlider then
                local sliderWidth = 0.05 * scaleFactor
                local sliderHeight = 0.008 * scaleFactor                
                local sliderX = XorMenu.UI.MenuX + 0.175
                local sliderY = menuYPos + 0.01
                local minValue = item.minValue
                local maxValue = item.maxValue
                local currentValue = item.currentValue
                local sliderLength = (currentValue - minValue) / (maxValue - minValue) * sliderWidth

                DrawRect(sliderX, sliderY, sliderWidth, sliderHeight, 100, 100, 100, 255)
                DrawRect(sliderX - sliderWidth / 2 + sliderLength / 2, sliderY, sliderLength, sliderHeight, XorMenu.rgb.r, XorMenu.rgb.g, XorMenu.rgb.b, XorMenu.rgb.a)

                local valueTextX = sliderX - sliderWidth / 2 - 0.018
                local valueTextY = sliderY - 0.0110
                SetTextFont(0)
                SetTextScale(0.26, 0.26)
                SetTextColour(255, 255, 255, 255)
                BeginTextCommandDisplayText("STRING")
                AddTextComponentSubstringPlayerName(XORString(tostring(currentValue)))
                EndTextCommandDisplayText(valueTextX - 0.025, valueTextY)
            end

            -- Inside your menu draw loop
            if item.isStringSelector then
                local selectorWidth = 0.05 * scaleFactor
                local selectorHeight = 0.008 * scaleFactor
                local selectorX = XorMenu.UI.MenuX + 0.175
                local selectorY = menuYPos + 0.01

                local totalOptions = #item.stringList
                local index = item.currentValue
                local fillWidth = (index - 1) / (totalOptions - 1) * selectorWidth

                -- Draw background bar
                DrawRect(selectorX, selectorY, selectorWidth, selectorHeight, 100, 100, 100, 255)

                -- Fill progress based on selection
                if totalOptions > 1 then
                    DrawRect(selectorX - selectorWidth / 2 + fillWidth / 2, selectorY, fillWidth, selectorHeight, XorMenu.rgb.r, XorMenu.rgb.g, XorMenu.rgb.b, XorMenu.rgb.a)
                end

                -- Draw selected string text
                local currentString = item.stringList[index]
                local textX = selectorX - selectorWidth / 2 - 0.02
                local textY = selectorY - 0.0110
                SetTextFont(0)
                SetTextScale(0.26, 0.26)
                SetTextColour(255, 255, 255, 255)
                BeginTextCommandDisplayText("STRING")
                AddTextComponentSubstringPlayerName(XORString(tostring(currentString)))
                EndTextCommandDisplayText(textX - 0.025, textY)
            end      

            if item.isCheckbox then
                -- normalized vals (0.0–1.0)
                local normW, normH    = 0.02, 0.01
                local normPad, normOff = 0.008, 0.01
            
                -- screen size in pixels
                local screenW, screenH = GetActualScreenResolution()
            
                -- convert normalized → absolute
                local toggleW  = normW * screenW
                local toggleH  = normH * screenH
                local pad      = normPad * screenH
                local offsetY  = normOff * screenH
            
                -- menu base in pixels
                local baseX = XorMenu.UI.MenuX * screenW
                local baseY = XorMenu.UI.MenuY * screenH
            
                -- now define toggleX/Y in pixels
                local toggleX = baseX + 400
                local toggleY = baseY + 63 + (item.index - startIdx) * (toggleH + pad)
            
                -- helper to normalize pixel → 0.0–1.0
                local function N(x, y) return x/screenW, y/screenH end
            
                -- 1) background
                do
                    local cx = toggleX + toggleW/2
                    local cy = toggleY + toggleH/2 + offsetY
                    local w  = toggleW
                    local h  = toggleH
                    local nx, ny = N(cx, cy)
                    DrawRect(nx, ny, w/screenW, h/screenH, 100,100,100,200)
                end
            
                -- init smooth
                if item.smoothValue==nil then
                    item.smoothValue = item.checked and 1 or 0
                end
            
                -- interpolate
                local target = item.checked and 1 or 0
                item.smoothValue = item.smoothValue + (target - item.smoothValue)*0.15
            
                -- circle handle in pixels
                local circleSize = toggleH - 4
                local minO, maxO = 2, toggleW - circleSize - 2
                local circX = toggleX + (minO + (maxO-minO)*item.smoothValue) + circleSize/2
                local circY = toggleY + toggleH/2 + offsetY
            
                -- 2) fill
                local fillW = toggleW * item.smoothValue
                if fillW > 0 then
                    local fx = toggleX + fillW/2
                    local fy = toggleY + toggleH/2 + offsetY
                    local nx, ny = N(fx, fy)
                    DrawRect(nx, ny, fillW/screenW, toggleH/screenH,
                             XorMenu.rgb.r, XorMenu.rgb.g, XorMenu.rgb.b, XorMenu.rgb.a)
                end
            
                -- 3) handle
                do
                    local nx, ny = N(circX, circY)
                    DrawRect(nx, ny, circleSize/screenW, circleSize/screenH, 255,255,255,255)
                end
            end                                  
            
            if item.submenuName then
                SetTextFont(0)
                SetTextScale(0.34, 0.34)
                SetTextColour(255, 255, 255, 255)
                BeginTextCommandDisplayText("STRING")
                AddTextComponentSubstringPlayerName(XORString(">>>"))
                EndTextCommandDisplayText(XorMenu.UI.MenuX + 0.175, menuYPos - 0.0035)
            end

            yOffset = yOffset + XorMenu.UI.ItemSpacing
        end
        XorMenu.menuDrawing = false  -- Unset flag after drawing
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        Citizen.InvokeNative(0xA5FFE9B05F199DE7, 0)
        Citizen.InvokeNative(0xA5FFE9B05F199DE7, 1)
        Citizen.InvokeNative(0xA5FFE9B05F199DE7, 2)
        -- Check if menu was uninjected and kill the thread
        if XorMenu.uninjected then break end


        local openkey = XorMenu.openkey
        local playerPed = PlayerPedId()
        local currentMenu = XorMenu.menus[XorMenu.currentMenu]

        -- Force-enable controls if player is dead
        Citizen.InvokeNative(0x61BB1D9B3A95D802, GFX_ORDER.lowlow)
        Citizen.InvokeNative(0xC6372ECD45D73BCD, true)

        -- Toggle menu visibility
        if IsControlJustPressed(0, openkey) then
            currentMenu.visible = not currentMenu.visible
        end

        if XorMenu.Controller and IsControlJustPressed(0, 206) and IsControlJustPressed(0, 203) then
            currentMenu.visible = not currentMenu.visible
        end

        -- Skip if no current menu or not visible
        if not XorMenu.currentMenu or not currentMenu.visible then
            goto continue
        end

        -- Handle Slider Input
        XorMenu.HandleSliderInput(XorMenu.currentMenu)
        XorMenu.HandleStringSelectorInput(XorMenu.currentMenu)

        -- Up Arrow
        if IsControlJustPressed(0, 172) then
            if currentMenu.selectedIndex > 1 then
                currentMenu.selectedIndex = currentMenu.selectedIndex - 1
            else
                currentMenu.selectedIndex = #currentMenu.items
            end
        end

        -- Down Arrow
        if IsControlJustPressed(0, 173) then
            if currentMenu.selectedIndex < #currentMenu.items then
                currentMenu.selectedIndex = currentMenu.selectedIndex + 1
            else
                currentMenu.selectedIndex = 1
            end
        end

        -- Enter Key
        if IsControlJustPressed(0, 201) then
            local selectedItem = currentMenu.items[currentMenu.selectedIndex]
            XorVariables.Push(XORString("Selected: " .. selectedItem.item), 240)

            if selectedItem.isCheckbox then
                selectedItem.checked = not selectedItem.checked
                if selectedItem.action then
                    selectedItem.action(selectedItem.checked)
                end
            elseif selectedItem.submenuName then
                if XorMenu.menus[selectedItem.submenuName] then
                    XorMenu.currentMenu = selectedItem.submenuName
                    XorMenu.menus[XorMenu.currentMenu].visible = true
                    XorMenu.menus[XorMenu.currentMenu].selectedIndex = 1
                else
                    XorVariables.Push(XORString("Error: Submenu not found: " .. selectedItem.submenuName), 240)
                end
            elseif selectedItem.action then
                selectedItem.action()
            end
        end

        if IsControlJustPressed(0, 25) then goto skipback end
        if IsControlJustPressed(0, 202) then
            if currentMenu.previousMenu then
                XorMenu.currentMenu = currentMenu.previousMenu
                XorMenu.menus[XorMenu.currentMenu].visible = true
                XorMenu.menus[XorMenu.currentMenu].selectedIndex = 1
            else
                currentMenu.visible = false
            end
        end
        ::skipback::
        -- Safety check: hide menu if uninjected
        if XorMenu.uninjected and IsControlJustPressed(0, openkey) then
            if XorMenu.currentMenu and currentMenu then
                currentMenu.visible = false
            end
        end

        -- Draw the menu
        XorMenu.DrawMenu(XorMenu.currentMenu)

        ::continue::
    end
end)


-- Sample Menu Creation works like 1st string menu to draw in second string name third string logic
XorMenu.CreateMenu(XORString("MainMenu"), XORString("Main Menu"), XORString("Select an option"))
XorMenu.AddMenuItem(XORString("MainMenu"), XORString("Self"), XORString("self"))
XorMenu.AddMenuItem(XORString("MainMenu"), XORString("Weapon"), XORString("Weapon"))
XorMenu.AddMenuItem(XORString("MainMenu"), XORString("Vehicle"), XORString("Vehicle"))
XorMenu.AddMenuItem(XORString("MainMenu"), XORString("Esp"), XORString("Esp"))
XorMenu.AddMenuItem(XORString("MainMenu"), XORString("Destroyer"), XORString("Destroyer"))
XorMenu.AddMenuItem(XORString("MainMenu"), XORString("Players"), XORString("onlinePlayersSubMenu"))
XorMenu.AddMenuItem(XORString("MainMenu"), XORString("Scripts(Load doesnt work yet)"), XORString("Scripts"))
XorMenu.AddMenuItem(XORString("MainMenu"), XORString("Settings"), XORString("Settings"))
XorMenu.AddMenuItem(XORString("MainMenu"), XORString("Misc"), XORString("Misc"))

--initialize menu
XorMenu.currentMenu = XORString("MainMenu")
XorMenu.menus[XORString("MainMenu")].visible = true

XorMenu.CreateSubMenu(XORString("self"), XORString("MainMenu"), XORString("self"))
XorMenu.AddMenuCheckbox(XORString("self"), XORString("Enable Godmode"), false, function(state) XorMenu.godmodeActive = state end)
XorMenu.AddMenuButton(XORString("self"), XORString("Full HP"), function() SetEntityFullHealth() end)
XorMenu.AddMenuButton(XORString("self"), XORString("Full Armor"), function() SetArmorToFull() end)
XorMenu.AddMenuButton(XORString("self"), XORString("TP To Waypoint"), function() TeleportToWaypoint() end)
XorMenu.AddMenuCheckbox(XORString("self"), XORString("Super punch"), false, function(state)
    if XorMenu.Safe then
        XorVariables.Push(XORString("~r~Safe Mode Is On - Punch Blocked"), 240)
        -- Disable the checkbox if Safe Mode is enabled (keeps the state as is)
        return
    end
    
    if state then
        XorMenu.OnePunchMan = true
        XorVariables.Push(XORString("~g~Punch enabled"), 240)
    else
        XorMenu.OnePunchMan = false
        XorVariables.Push(XORString("~r~Punch disabled"), 240)
    end
end)
XorMenu.AddMenuCheckbox(XORString("self"), XORString("noclip"), false, function(state)
    if XorMenu.Safe then
        XorVariables.Push(XORString("~r~Safe Mode Is On - NoClip Blocked"), 240)
        -- Disable the checkbox if Safe Mode is enabled (keeps the state as is)
        return
    end
    
    if state then
        XorMenu.Noclip = true
        XorVariables.Push(XORString("~g~No-clip enabled"), 240)
    else
        XorMenu.Noclip = false
        XorVariables.Push(XORString("~r~No-clip disabled"), 240)
    end
end)
XorMenu.AddMenuSlider(XORString("self"), XORString("noclip speed"), 0.1, 100, XorMenu.Noclipspeed, function(value) XorMenu.Noclipspeed = value end)
XorMenu.AddMenuCheckbox(XORString("self"), XORString("Freecam"), false, function(state)
    if XorMenu.Safe then
        XorVariables.Push(XORString("~r~Safe Mode Is On - Freecam Blocked"), 240)
        -- Disable the checkbox if Safe Mode is enabled (keeps the state as is)
        return
    end
    
    if state then
        XorMenu.freecamActive = true
        XorVariables.Push(XORString("~g~Freecam enabled"), 240)
    else
        XorMenu.freecamActive = false
        XorVariables.Push(XORString("~r~Freecam disabled"), 240)
    end
end)
XorMenu.AddMenuSlider(XORString("self"), XORString("Freecam Speed"), 0.1, 100, XorMenu.camspeed, function(value) XorMenu.camspeed = value end)
XorMenu.AddMenuCheckbox(XORString("self"), XORString("invis"), false, function(state)
    if XorMenu.Safe then
        XorVariables.Push(XORString("~r~Safe Mode Is On - NoClip Blocked"), 240)
        -- Disable the checkbox if Safe Mode is enabled (keeps the state as is)
        return
    end
    
    if state then
        option.invis = true
        XorVariables.Push(XORString("~g~No-clip enabled"), 240)
    else
        option.invis = false
        XorVariables.Push(XORString("~r~No-clip disabled"), 240)
    end
end)
XorMenu.AddMenuButton(XORString("self"), XORString("RandomizeClothing"), function() RandomizeClothing() end)

XorMenu.CreateSubMenu(XORString("Weapon"), XORString("MainMenu"), XORString("Weapon"))
XorMenu.AddMenuButton(XORString("Weapon"), XORString("Spawn Weapon From Hash"), function() SpawnWeaponFromInput() end)
XorMenu.AddMenuButton(XORString("Weapon"), XORString("Spoof Weapon From Hash"), function() SpoofWeaponInHand() end)

XorMenu.CreateSubMenu(XORString("Vehicle"), XORString("MainMenu"), XORString("Vehicle"))
XorMenu.AddMenuButton(XORString("Vehicle"), XORString("Spawn Weapon From Hash"), function() SpawnVehicleFromInput() end)
XorMenu.AddMenuButton(XORString("Vehicle"), XORString("Tp Into Nearest Whip"), function() TeleportPlayerIntoNearestVehicle() end)
XorMenu.AddMenuButton(XORString("Vehicle"), XORString("Unlock Nearest Whip"), function() UnlockNearestVehicle() end)
XorMenu.AddMenuCheckbox(XORString("Vehicle"), XORString("Enable Vehicle Godmode"), false, function(state) XorMenu.vehicleGodmodeActive = state end)
XorMenu.AddMenuCheckbox(XORString("Vehicle"), XORString("Boost"), false, function(state)
    if XorMenu.Safe then
        XorVariables.Push(XORString("~r~Safe Mode Is On - Boost Blocked"), 240)
        -- Disable the checkbox if Safe Mode is enabled (keeps the state as is)
        return 
    end
    
    if state then
        XorMenu.Boost = true
        XorVariables.Push(XORString("~g~Boost Enabled Press Left Shift while Driving to Boost Left ctrl to quick stop"), 240)
    else
        XorMenu.Boost = false
        XorVariables.Push(XORString("~r~Boost Disabled"), 240)
    end
end)
XorMenu.AddMenuSlider(XORString("Vehicle"), XORString("Boost speed"), 0.1, 200, XorMenu.Boostspeed, function(value) XorMenu.Boostspeed = value end)
XorMenu.AddMenuButton(XORString("Vehicle"), XORString("Repair Vehicle"), function() RepairVehicle() end)
XorMenu.AddMenuCheckbox(XORString("Vehicle"), XORString("Auto-Repair"), false, function(state)
    if XorMenu.Safe then
        XorVariables.Push(XORString("~r~Safe Mode Is On - Auto Blocked Please Use Regular"), 240)
        -- Disable the checkbox if Safe Mode is enabled (keeps the state as is)
        return 
    end
    
    if state then
        XorMenu.vehicleRepairActive = true
        XorVariables.Push(XORString("~g~Repairing Enabled"), 240)
    else
        XorMenu.vehicleRepairActive = false
        XorVariables.Push(XORString("~r~Repairing Disabled"), 240)
    end
end)
XorMenu.AddMenuCheckbox(XORString("Vehicle"), XORString("Enable Vehicle Drift"), false, function(state) XorMenu.Driftmode = state
    if state then
        XorMenu.Driftmode = true
        XorVariables.Push(XORString("~g~Drift Enabled Press Left Shift while Driving to Drift"), 240)
    else
        XorMenu.Driftmode = false
        XorVariables.Push(XORString("~r~Drift Disabled"), 240)
    end
end)
XorMenu.AddMenuCheckbox(XORString("Vehicle"), XORString("Enable Vehicle Controlled Drift"), false, function(state) XorMenu.Driftmode2 = state
    if state then
        XorMenu.Driftmode2 = true
        XorVariables.Push(XORString("~g~Drift Enabled Press Left Shift while Driving to Drift Like a Pro"), 240)
    else
        XorMenu.Driftmode2 = false
        XorVariables.Push(XORString("~r~Drift Disabled"), 240)
    end
end)
XorMenu.AddMenuCheckbox(XORString("Vehicle"), XORString("Enable Vehicle handling"), false, function(state) XorMenu.goatedhandling = state
    if state then
        XorMenu.goatedhandling = true
        XorVariables.Push(XORString("~g~Drift Enabled Press Left Shift while Driving to tighten turning"), 240)
    else
        XorMenu.goatedhandling = false
        XorVariables.Push(XORString("~r~Drift Disabled"), 240)
    end
end)

XorMenu.CreateSubMenu(XORString("Esp"), XORString("MainMenu"), XORString("Esp"))
XorMenu.AddMenuCheckbox(XORString("Esp"), XORString("Enable Esp"), false, function(state) XorMenu.esp = state end)
XorMenu.AddMenuCheckbox(XORString("Esp"), XORString("Enable Boxes"), false, function(state) XorMenu.espconfig.boxes = state end)
XorMenu.AddMenuCheckbox(XORString("Esp"), XORString("Enable Skeletons"), false, function(state) XorMenu.espconfig.skeletons = state end)
XorMenu.AddMenuCheckbox(XORString("Esp"), XORString("Enable health"), false, function(state) XorMenu.espconfig.health = state end)
XorMenu.AddMenuCheckbox(XORString("Esp"), XORString("Enable armour"), false, function(state) XorMenu.espconfig.armour = state end)
XorMenu.AddMenuCheckbox(XORString("Esp"), XORString("Enable Tracers"), false, function(state) XorMenu.espconfig.tracers = state end)
XorMenu.AddMenuCheckbox(XORString("Esp"), XORString("Enable self"), false, function(state) XorMenu.espconfig.player = state end)
XorMenu.AddMenuCheckbox(XORString("Esp"), XORString("Enable npcs"), false, function(state) XorMenu.espconfig.npcs = state end)
XorMenu.AddMenuCheckbox(XORString("Esp"), XORString("Enable Data"), false, function(state) XorMenu.espconfig.data = state end)
XorMenu.AddMenuCheckbox(XORString("Esp"), XORString("Enable weapon"), false, function(state) XorMenu.espconfig.datacfg.weapon = state end)
XorMenu.AddMenuCheckbox(XORString("Esp"), XORString("Enable Name"), false, function(state) XorMenu.espconfig.datacfg.name = state end)
XorMenu.AddMenuCheckbox(XORString("Esp"), XORString("Enable Ids"), false, function(state) XorMenu.espconfig.datacfg.IDs = state end)
XorMenu.AddMenuCheckbox(XORString("Esp"), XORString("Enable distance Data"), false, function(state) XorMenu.espconfig.datacfg.distance = state end)
XorMenu.AddMenuCheckbox(XORString("Esp"), XORString("Enable health Data"), false, function(state) XorMenu.espconfig.datacfg.health = state end)
XorMenu.AddMenuCheckbox(XORString("Esp"), XORString("Enable Alive Status"), false, function(state) XorMenu.espconfig.datacfg.status = state end)
XorMenu.AddMenuCheckbox(XORString("Esp"), XORString("Enable full Data"), false, function(state) XorMenu.espconfig.datacfg.main = state end)

XorMenu.CreateSubMenu(XORString("Destroyer"), XORString("MainMenu"), XORString("Destroyer"))
XorMenu.AddMenuCheckbox(XORString("Destroyer"), XORString("Nuke"), false, function(state)
    if XorMenu.Safe then
        XorVariables.Push(XORString("~r~Safe Mode Is On - Nuke Blocked"), 240)
        -- Disable the checkbox if Safe Mode is enabled (keeps the state as is)
        return
    end
    
    if state then
        XorMenu.isNukeActive = true
        XorVariables.Push(XORString("~g~Nuke Enabled"), 240)
    else
        XorMenu.isNukeActive = false
        XorVariables.Push(XORString("~r~Nuke Disabled"), 240)
    end
end)
XorMenu.AddMenuButton(XORString("Destroyer"), XORString("rape server"), function() RapeServer()
    if XorMenu.Safe then
        XorVariables.Push(XORString("~r~Safe Mode Is On - Raper Blocked"), 240)
        return
    end
end)


XorMenu.CreateSubMenu(XORString("Scripts"), XORString("MainMenu"), XORString("Scripts"))

-- add script integrator

XorMenu.CreateSubMenu(XORString("Built-in"), XORString("Scripts"), XORString("Built-in"))
XorMenu.AddMenuItem(XORString("Scripts"), XORString("Built-in"), XORString("Built-in"))
XorMenu.AddMenuCheckbox(XORString("Built-in"), XORString("Steal Inventories"), false, function(state)
    if XorMenu.Safe then
        XorVariables.Push(XORString("~r~Safe Mode Is On - Cannot Steal Inventories"), 240)
         return
    end
        
    if state then
        XorMenu.InvActive = true
        XorVariables.Push(XORString("~g~Steal Inventory ready press F6 nearby players"), 240)
    else
        XorMenu.InvActive = false
        XorVariables.Push(XORString("~r~Steal Inventory disabled you can safely press F6"), 240)
    end
end)
XorMenu.AddMenuCheckbox(XORString("Built-in"), XORString("Anti Tp"), false, function(state)
    if XorMenu.Safe then
        XorVariables.Push(XORString("~r~Safe Mode Is On - Anti Tp Blocked"), 240)
        return
    end
    XorMenu.TpDisabled = state
end)
XorMenu.AddMenuCheckbox(XORString("Built-in"), XORString("throw shit"), false, function(state)
    if XorMenu.Safe then
        XorVariables.Push(XORString("~r~Safe Mode Is On - cant use built in scripts"), 240)
        return
    end
    XorMenu.throwing = state
end)
XorMenu.AddMenuButton(XORString("Built-in"), XORString("endcashflowcoms"), function() FinishComserv(false)
    if XorMenu.Safe then
        XorVariables.Push(XORString("~r~Safe Mode Is On - cant use built in scripts"), 240)
        return
    end
end)
XorMenu.AddMenuButton(XORString("Built-in"), XORString("Cheef Menu"), function() _XO849()
    if XorMenu.Safe then
        XorVariables.Push(XORString("~r~Safe Mode Is On - cant use built in scripts"), 240)
        return
    end
end)
XorMenu.AddMenuButton(XORString("Built-in"), XORString("Money Vip/Mc9"), function() robsafe()
    if XorMenu.Safe then
        XorVariables.Push(XORString("~r~Safe Mode Is On - cant use built in scripts"), 240)
        return
    end
end)
XorMenu.AddMenuButton(XORString("Built-in"), XORString("Goop Vip/Mc9"), function() SpawnGoop()
    if XorMenu.Safe then
        XorVariables.Push(XORString("~r~Safe Mode Is On - cant use built in scripts"), 240)
        return
    end
end)
XorMenu.AddMenuButton(XORString("Built-in"), XORString("Goopcs Vip/Mc9"), function() ClientGoop()
    if XorMenu.Safe then
        XorVariables.Push(XORString("~r~Safe Mode Is On - cant use built in scripts"), 240)
        return
    end
end)

XorMenu.CreateSubMenu(XORString("ForceEmote"), XORString("Scripts"), XORString("ForceEmote"))
XorMenu.AddMenuItem(XORString("Scripts"), XORString("Force Emote"), XORString("ForceEmote"))
XorMenu.AddMenuButton(XORString("ForceEmote"), XORString("custom forced emote"), function()
    if XorMenu.Safe then
        XorVariables.Push(XORString("~r~Safe Mode Is On - cant use built in scripts"), 240)
        return
    end
    customemote()
end)

XorMenu.AddMenuCheckbox(XORString("ForceEmote"), XORString("Enable Custom Force Emote"), false, function(state)
    if XorMenu.Safe then
        XorVariables.Push(XORString("~r~Safe Mode Is On - Emote Blocked"), 240)
        return
    end
    XorMenu.ForceEmoteCustom = state
end)

XorMenu.AddMenuCheckbox(XORString("ForceEmote"), XORString("Enable Slap Force Emote"), false, function(state)
    if XorMenu.Safe then
        XorVariables.Push(XORString("~r~Safe Mode Is On - Emote Blocked"), 240)
        return
    end
    XorMenu.ForceEmote = state
end)

XorMenu.AddMenuCheckbox(XORString("ForceEmote"), XORString("Force Emote (Slapped) Press Y"), false, function(state)
    if XorMenu.Safe then return XorVariables.Push(XORString("~r~Safe Mode Is On - Emote Blocked"), 240) end
    XorMenu.ForceEmote = state
end)

XorMenu.AddMenuCheckbox(XORString("ForceEmote"), XORString("Force Emote (Slapped2) Press Y"), false, function(state)
    if XorMenu.Safe then return XorVariables.Push(XORString("~r~Safe Mode Is On - Emote Blocked"), 240) end
    XorMenu.ForceEmote1 = state
end)

XorMenu.AddMenuCheckbox(XORString("ForceEmote"), XORString("Force Emote (Cuddleet5) Press Y"), false, function(state)
    if XorMenu.Safe then return XorVariables.Push(XORString("~r~Safe Mode Is On - Emote Blocked"), 240) end
    XorMenu.ForceEmote2 = state
end)

XorMenu.AddMenuCheckbox(XORString("ForceEmote"), XORString("Force Emote (headbutted) Press Y"), false, function(state)
    if XorMenu.Safe then return XorVariables.Push(XORString("~r~Safe Mode Is On - Emote Blocked"), 240) end
    XorMenu.ForceEmote3 = state
end)

XorMenu.AddMenuCheckbox(XORString("ForceEmote"), XORString("Force Emote (Kiss) Press Y"), false, function(state)
    if XorMenu.Safe then return XorVariables.Push(XORString("~r~Safe Mode Is On - Emote Blocked"), 240) end
    XorMenu.ForceEmote4 = state
end)

XorMenu.AddMenuCheckbox(XORString("ForceEmote"), XORString("Force Emote (punched) Press Y"), false, function(state)
    if XorMenu.Safe then return XorVariables.Push(XORString("~r~Safe Mode Is On - Emote Blocked"), 240) end
    XorMenu.ForceEmote5 = state
end)

XorMenu.AddMenuCheckbox(XORString("ForceEmote"), XORString("Force Emote (slap2) Press Y"), false, function(state)
    if XorMenu.Safe then return XorVariables.Push(XORString("~r~Safe Mode Is On - Emote Blocked"), 240) end
    XorMenu.ForceEmote6 = state
end)

XorMenu.AddMenuCheckbox(XORString("ForceEmote"), XORString("Force Emote (slap2) Press Y"), false, function(state)
    if XorMenu.Safe then return XorVariables.Push(XORString("~r~Safe Mode Is On - Emote Blocked"), 240) end
    XorMenu.ForceEmote7 = state
end)

XorMenu.AddMenuCheckbox(XORString("ForceEmote"), XORString("Force Emote (carrycmg2) Press Y"), false, function(state)
    if XorMenu.Safe then return XorVariables.Push(XORString("~r~Safe Mode Is On - Emote Blocked"), 240) end
    XorMenu.ForceEmote8 = state
end)

XorMenu.AddMenuCheckbox(XORString("ForceEmote"), XORString("Force Emote (kiss6) Press Y"), false, function(state)
    if XorMenu.Safe then return XorVariables.Push(XORString("~r~Safe Mode Is On - Emote Blocked"), 240) end
    XorMenu.ForceEmote9 = state
end)

XorMenu.AddMenuCheckbox(XORString("ForceEmote"), XORString("Force Emote (kiss6) Press Y"), false, function(state)
    if XorMenu.Safe then return XorVariables.Push(XORString("~r~Safe Mode Is On - Emote Blocked"), 240) end
    XorMenu.ForceEmote10 = state
end)

XorMenu.AddMenuCheckbox(XORString("ForceEmote"), XORString("Force Emote (Kiss7) Press Y"), false, function(state)
    if XorMenu.Safe then return XorVariables.Push(XORString("~r~Safe Mode Is On - Emote Blocked"), 240) end
    XorMenu.ForceEmote11 = state
end)

XorMenu.AddMenuCheckbox(XORString("Built-in"), XORString("Block Hostage(potentially)"), false, function(state)
    if XorMenu.Safe then
        XorVariables.Push(XORString("~r~Safe Mode Is On - Block hostage Blocked"), 240)
        -- Disable the checkbox if Safe Mode is enabled (keeps the state as is)
        return
    end
    
    if state then
        XorVariables.ScriptOptions.blocktakehostage = true
        XorVariables.Push(XORString("~g~getting taken hostage MAY be blocked"), 240)
    else
        XorVariables.ScriptOptions.blocktakehostage = false
        XorVariables.Push(XORString("~r~getting taken hostage is unblocked"), 240)
    end
end)



XorMenu.CreateSubMenu(XORString("Settings"), XORString("MainMenu"), XORString("Settings"))
-- Toggle XOR scrambling
XorMenu.AddMenuCheckbox(XORString("Settings"), XORString("Enable XOR Scramble"), false, function(state) XorMenu.xorEnabled = state end)
XorMenu.AddMenuCheckbox(XORString("Settings"), XORString("Enable Safe Mode"), false, function(state) XorMenu.Safe = state end)

-- Helper function to recursively remove non-serializable values (e.g., functions)
local function sanitizeTable(tbl)
    local sanitized = {}
    for k, v in pairs(tbl) do
        local vType = type(v)
        if vType == "table" then
            sanitized[k] = sanitizeTable(v)
        elseif vType == "number" or vType == "string" or vType == "boolean" then
            sanitized[k] = v
        end
         -- Skip functions, userdata, threads, etc.
    end
    return sanitized
end
    
local function sanitizeTable(tbl)
    local sanitized = {}

    for k, v in pairs(tbl) do
        if type(v) == "table" then
            sanitized[k] = sanitizeTable(v)
        elseif type(v) ~= "function" then
            sanitized[k] = v
        end
    end

    return sanitized
end

local function saveConfig()
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", "", "", "", "", 20)
    while UpdateOnscreenKeyboard() == 0 do Citizen.Wait(0) end

    local filename = GetOnscreenKeyboardResult()
    if filename == "" then print("No filename entered.") return end

    local configData = {
        esp                = XorMenu.esp,
        openkey            = XorMenu.openkey,
        espconfig          = sanitizeTable(XorMenu.espconfig),
        menus              = sanitizeTable(XorMenu.menus),
        UI                 = sanitizeTable(XorMenu.UI),
        rgb                = sanitizeTable(XorMenu.rgb),
        background         = sanitizeTable(XorMenu.background),
        selector           = sanitizeTable(XorMenu.selector),
        notifications      = sanitizeTable(XorMenu.notifications),
        optionCount        = XorMenu.optionCount,
        currentMenu        = XorMenu.currentMenu,
        rgbShiftActive     = XorMenu.rgbShiftActive,
        rgbShiftBackground = XorMenu.rgbShiftBackground,
        RGBShiftSelector   = XorMenu.RGBShiftSelector,
        godmodeActive      = XorMenu.godmodeActive,
        godmodeforbros     = XorMenu.godmodeforbros,
        invisdisabler      = XorMenu.invisdisabler,
        isNukeActive       = XorMenu.isNukeActive,
        OnePunchMan        = XorMenu.OnePunchMan,
        Noclip             = XorMenu.Noclip,
        Noclipspeed        = XorMenu.Noclipspeed,
        ToggleSpectate     = XorMenu.ToggleSpectate,
        Bindindicator      = XorMenu.Bindindicator,
        SpectatorIndicator = XorMenu.SpectatorIndicator,
        Safe               = XorMenu.Safe,
        Uninjected         = XorMenu.Uninjected,
        vehicleRepairActive= XorMenu.vehicleRepairActive,
        TpDisabled         = XorMenu.TpDisabled,
        InvActive          = XorMenu.InvActive,
        freecamActive      = XorMenu.freecamActive,
        camspeed           = XorMenu.camspeed,
        DriftOthers        = XorMenu.DriftOthers,
        invis              = XorMenu.invis,
        Boost              = XorMenu.Boost,
        Boostspeed         = XorMenu.Boostspeed,
        BoostOthers        = XorMenu.BoostOthers,
        Driftmode          = XorMenu.Driftmode,
        Driftmode2         = XorMenu.Driftmode2,
        goatedhandling     = XorMenu.goatedhandling,
        throwing           = XorMenu.throwing,
        xorEnabled         = XorMenu.xorEnabled,
        xorKey             = XorMenu.xorKey,
        xorStrength        = XorMenu.xorStrength,
        xorSpeed           = XorMenu.xorSpeed
    }

    local jsonData = json.encode(configData)
    SaveResourceFile(GetCurrentResourceName(), "config/" .. filename .. ".json", jsonData, -1)
    print("Configuration saved as " .. filename .. ".json")
end

local function loadConfig()
    -- Display on-screen keyboard to input filename
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", "", "", "", "", 20)
    
    -- Wait for the user to finish input
    while UpdateOnscreenKeyboard() == 0 do
        Citizen.Wait(0)
    end
    
    -- Get the entered filename
    local filenameInput = GetOnscreenKeyboardResult()
    if filenameInput == "" then
        print("No filename entered.")
        return
    end
    
    -- Append ".json" to the filename input
    local fullFileName = filenameInput .. ".json"
    
    -- Attempt to load the resource file
    local configData = LoadResourceFile(GetCurrentResourceName(), "config/" .. fullFileName)
    
    -- Check if the file was loaded successfully
    if not configData or configData == "" then
        print("Failed to load config: " .. fullFileName)
        return
    end
    
    -- Attempt to decode the JSON data
    local parsedData = json.decode(configData)
    
    -- Check if parsing was successful
    if not parsedData then
        print("Failed to parse configuration data.")
        return
    end
    
    -- Apply the loaded configuration to XorMenu (or any other table you want to modify)
    for k, v in pairs(parsedData) do
        XorMenu[k] = v
    end
    
    print("Configuration loaded successfully from " .. fullFileName)
end

-- Sliders for settings
XorMenu.AddMenuSlider(XORString("Settings"), XORString("XOR Strength"), 0.1, 100, XorMenu.xorStrength, function(value) XorMenu.xorStrength = value end)
XorMenu.AddMenuSlider(XORString("Settings"), XORString("XOR Speed"), 0.1, 240, XorMenu.xorSpeed, function(value) XorMenu.xorSpeed = value end)
XorMenu.AddMenuStringSelector(XORString("Settings"), XORString("Select Config"), 
    {"STWEE Menu", "Eleven5m", "Picho", "Wavey"}, 1, function(selectedConfig)
        ApplyConfig(selectedConfig)  -- selectedConfig will be one of the strings: "Default", "Teddydoo", etc.
    end)
XorMenu.AddMenuCheckbox(XORString("Settings"), XORString("Disable notifications"), false, function(state) XorMenu.notifications.off = state end)
XorMenu.AddMenuCheckbox(XORString("Settings"), XORString("Draw Binds"), false, function(state) XorMenu.Bindindicator = state end)
XorMenu.AddMenuCheckbox(XORString("Settings"), XORString("RGB Menu"), false, function(state) XorMenu.rgbShiftActive = state if state then XorMenu.RGBShift() end end)
XorMenu.AddMenuCheckbox(XORString("Settings"), XORString("RGB Background"), false, function(state) XorMenu.rgbShiftBackground = state if state then XorMenu.RGBShiftBackground() end end)
XorMenu.AddMenuCheckbox(XORString("Settings"), XORString("RGB Selector"), false, function(state) XorMenu.rgbShiftSelector = state if state then XorMenu.RGBShiftSelector() end end)
XorMenu.AddMenuButton(XORString("Settings"), XORString("mouseUi open"), function() mouseUi.open() end)
XorMenu.AddMenuButton(XORString("Settings"), XORString("color picker"), function() mouseUi.picker() end)
XorMenu.AddMenuButton(XORString("Settings"), XORString("mouseUi close"), function() mouseUi.close() end)
XorMenu.AddMenuStringSelector(
    XORString("Settings"),
    XORString("Apply Color To"),
    { "selector", "background", "rgb" },
    1,
    function(selectedTable)
        ApplyColor(selectedTable)
    end
)
XorMenu.AddMenuSlider(XORString("Settings"), XORString("Binds X"), 0.001, 0.849, XorMenu.UI.bindsX, function(value) XorMenu.UI.bindsX = value end, 0.01)
XorMenu.AddMenuSlider(XORString("Settings"), XORString("Binds Y"), 0.011, 0.81, XorMenu.UI.bindsY, function(value) XorMenu.UI.bindsY = value end, 0.01)
XorMenu.AddMenuButton(XORString("Settings"), XORString("Change open key"), function() changeOpenKey() end)
XorMenu.AddMenuButton(XORString("Settings"), XORString("Unbind All Keybinds"), function() UnbindAllKeys() end)
XorMenu.AddMenuButton(XORString("Settings"), XORString("save config"), function() saveConfig() end)
XorMenu.AddMenuButton(XORString("Settings"), XORString("load config"), function() loadConfig() end)
XorMenu.AddMenuButton(XORString("Settings"), XORString("Panic Button"), function() Uninject() end)

XorMenu.CreateSubMenu(XORString("Misc"), XORString("MainMenu"), XORString("Misc"))
XorMenu.AddMenuCheckbox(XORString("Misc"), XORString("Reveal Invis Players"), false, function(state) XorMenu.invisdisabler = state end)
XorMenu.AddMenuCheckbox(XORString("Misc"), XORString("Spectator list"), false, function(state) XorMenu.SpectatorIndicator = state end)
XorMenu.AddMenuSlider(XORString("Misc"), XORString("Spectator X"), 0.001, 0.849, XorMenu.UI.spectatorX, function(value) XorMenu.UI.spectatorX = value end, 0.01)
XorMenu.AddMenuSlider(XORString("Misc"), XORString("Spectator Y"), 0.011, 0.81, XorMenu.UI.spectatorY, function(value) XorMenu.UI.spectatorY = value end, 0.01)
XorMenu.AddMenuCheckbox(XORString("Misc"), XORString("No Collision"), false, function(state) XorMenu.Nocollision = state end)


---------------------------------------------
-- freecam
---------------------------------------------

---------------------------------------------------------------------
-- Freecam Option Selector / Action Trigger with Center Crosshair --
---------------------------------------------------------------------

local selectedIndex = 1  -- Default option index
local options = {"Teleport", "Explode", "Explode 2", "Action 4", "Action 5"}
local scrollSpeed = 1.0  -- (unused in this sample but can be customized)

-- Function to draw text on screen at (x, y) with given alpha
local function DrawTextOnScreen(x, y, text, alpha)
    SetTextScale(0.35, 0.35)
    SetTextFont(1)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, alpha)
    SetTextCentre(true)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

-- Function to display the options list (3 at a time) centered horizontally
local function displayOptions()
    local startY = 0.25   -- Top Y for options (screen-space)
    local spacing = 0.05  -- Vertical spacing between options
    local alphaValues = {255, 180, 100}  -- Fading alpha for non-selected options
    local optionY = startY

    local maxDisplayOptions = 3
    local lowerBound = math.max(selectedIndex - math.floor(maxDisplayOptions/2), 1)
    local upperBound = math.min(lowerBound + maxDisplayOptions - 1, #options)
    
    if selectedIndex - lowerBound < math.floor(maxDisplayOptions/2) then
        lowerBound = math.max(upperBound - maxDisplayOptions + 1, 1)
    end

    for i = lowerBound, upperBound do
        local optionText = options[i]
        local alpha = alphaValues[i - lowerBound + 2] or 100

        if i == selectedIndex then
            DrawTextOnScreen(0.5, optionY, " " .. optionText, 255)
        else
            DrawTextOnScreen(0.5, optionY, optionText, alpha)
        end

        optionY = optionY - spacing
    end
end

-- Function to update the selected index given a delta (positive for up, negative for down)
local function updateSelectedIndex(delta)
    if delta > 0 then
        selectedIndex = math.max(selectedIndex - 1, 1)
    elseif delta < 0 then
        selectedIndex = math.min(selectedIndex + 1, #options)
    end
end

-- Example freecam action functions for each option
local freecamActions = {
    function() teleportToFreecamTarget() end,
    function() XorMenu.ExplodeFreecamTarget() end,
    function() XorMenu.Explode2() end,
    function() print("Action 4 executed") end,
    function() print("Action 5 executed") end,
}

-- Function to get the target hit position in front of the camera
local function getFreecamTarget()
    local camCoords = GetGameplayCamCoord()
    local camRot = GetGameplayCamRot(2)
    local dir = RoFoCro(camRot)

    -- Cast a ray ahead of the camera to get the hit coordinates
    local dest = camCoords + dir * 10000.0 -- Ensure the ray is long enough for precision
    local rayHandle = StartShapeTestRay(
        camCoords.x, camCoords.y, camCoords.z,
        dest.x, dest.y, dest.z,
        -1, PlayerPedId(), 0
    )

    local result, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)
    if hit and endCoords and endCoords.x ~= 0 and endCoords.y ~= 0 and endCoords.z ~= 0 then
        return endCoords, entityHit
    else
        return nil, 0 -- Return nil if no valid target found
    end
end

function XorMenu.Explode2()
    -- Retrieve the freecam target entity and its coordinates.
    local coords, entityHit = getFreecamTarget()

    -- Check if a valid entity was found
    if not entityHit or not DoesEntityExist(entityHit) then
        XorVariables.Push(XORString("No valid target found."), 240)
        return
    end

    -- Verify that the target is a vehicle before proceeding
    if not IsEntityAVehicle(entityHit) then
        XorVariables.Push(XORString("Target is not a vehicle."), 240)
        return
    end

    -- Explode the vehicle using the native call
    Citizen.InvokeNative(0x301A42153C9AD707, entityHit, true, false, false)
    XorVariables.Push(XORString("Vehicle exploded."), 240)
end


function XorMenu.ExplodeFreecamTarget()
    local coords, entityHit = getFreecamTarget()  -- Retrieve freecam target coordinates

    -- Check if valid coordinates were found
    if not coords then
        XorVariables.Push(XORString("No valid freecam target found."), 240)
        return
    end

    if XorMenu.Safe then
        XorVariables.Push(XORString("~r~Safe Mode Is On - Explosion Blocked"), 240)
        return
    end

    local modelHash = GetHashKey(XORString("sultan")) -- Change this to any vehicle model you prefer

    -- Request the vehicle model
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(0)
    end

    -- Create the vehicle at the freecam target coordinates
    local vehicle = Citizen.InvokeNative(0xAF35D0D2583051B0, modelHash, coords.x, coords.y, coords.z, 0.0, true, false)

    -- Ensure the vehicle exists before proceeding
    if DoesEntityExist(vehicle) then
        -- Make the vehicle explode
        Citizen.InvokeNative(0x301A42153C9AD707, vehicle, true, false, false)
    end

    -- Clean up the model from memory
    SetModelAsNoLongerNeeded(modelHash)
end


function teleportToFreecamTarget()
    local ped = PlayerPedId()
    local coords, entityHit = getFreecamTarget()  -- Get coordinates from freecam

    if coords then
        -- Compute the target coordinates (adjusting Z as needed)
        local targetX = coords.x
        local targetY = coords.y
        local targetZ = coords.z + 1.0  -- Adjust Z to ensure the player is above ground

        -- Verify the player's ped exists before teleporting
        if DoesEntityExist(ped) then
            -- Teleport the local player's ped to the freecam target coordinates
            Citizen.InvokeNative(0x239A3351AC1DA385, ped, targetX, targetY, targetZ, true, true, true)

            -- Optionally, set the player's heading to match the camera's direction after teleporting
            local camRot = GetGameplayCamRot(2)
            SetEntityHeading(ped, camRot.z)

            print("[Freecam TP] Teleported to target at: ", targetX, targetY, targetZ)
            XorVariables.Push(XORString("Teleported to Freecam Target"), 240)
        else
            XorVariables.Push(XORString("Invalid player."), 240)
        end
    else
        XorVariables.Push(XORString("No valid freecam target found."), 240)
    end
end

-- Function to convert rotation to direction
function RoFoCro(rot)
    local radZ = math.rad(rot.z)
    local radX = math.rad(rot.x)
    local num = math.abs(math.cos(radX))
    return vector3(-math.sin(radZ) * num, math.cos(radZ) * num, math.sin(radX))
end

-- Function to draw a box around the crosshair position
local function DrawBoxLines2D(screenCoords, boxSize, r, g, b, a)
    local x = screenCoords.x
    local y = screenCoords.y

    local innerWidth = boxSize * 0.85
    local innerHeight = boxSize * 1.0
    local outerWidth = boxSize * 1.4
    local outerHeight = boxSize * 1.6

    local thickness = 0.00025

    -- Draw the inner and outer boxes
    local ix1 = x - innerWidth / 2
    local ix2 = x + innerWidth / 2
    local iy1 = y - innerHeight / 2
    local iy2 = y + innerHeight / 2

    local ox1 = x - outerWidth / 2
    local ox2 = x + outerWidth / 2
    local oy1 = y - outerHeight / 2
    local oy2 = y + outerHeight / 2

    -- Inner box
    DrawLine_2d(ix1, iy1, ix2, iy1, thickness, r, g, b, a)
    DrawLine_2d(ix1, iy2, ix2, iy2, thickness, r, g, b, a)
    DrawLine_2d(ix1, iy1, ix1, iy2, thickness, r, g, b, a)
    DrawLine_2d(ix2, iy1, ix2, iy2, thickness, r, g, b, a)

    -- Outer box
    DrawLine_2d(ox1, oy1, ox2, oy1, thickness, r, g, b, a)
    DrawLine_2d(ox1, oy2, ox2, oy2, thickness, r, g, b, a)
    DrawLine_2d(ox1, oy1, ox1, oy2, thickness, r, g, b, a)
    DrawLine_2d(ox2, oy1, ox2, oy2, thickness, r, g, b, a)

    -- Connector lines (for corners)
    DrawLine_2d(ix1, iy1, ox1, oy1, thickness, r, g, b, a)
    DrawLine_2d(ix2, iy1, ox2, oy1, thickness, r, g, b, a)
    DrawLine_2d(ix1, iy2, ox1, oy2, thickness, r, g, b, a)
    DrawLine_2d(ix2, iy2, ox2, oy2, thickness, r, g, b, a)
end

-- Function to draw the dynamic crosshair
local function DrawDynamicCrosshair()
    local camCoords = GetGameplayCamCoord()
    local hitCoords, _ = getFreecamTarget()

    if not hitCoords then return end

    -- Calculate distance from the camera to the hit position
    local dist = #(camCoords - hitCoords)

    -- Smoother scaling logic for the crosshair based on distance
    local scale = math.max(0.001, 0.10 / (dist ^ 0.50)) -- Gradual scale change

    -- Directly get the screen coordinates for the hit position
    local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(hitCoords.x, hitCoords.y, hitCoords.z)
    if onScreen then
        -- Draw the box at the screen coordinates with the calculated scale
        DrawBoxLines2D({x = screenX, y = screenY}, scale, XorMenu.rgb.r, XorMenu.rgb.g, XorMenu.rgb.b, 220)
    end
end



---------------------------------------------------------------------
-- Continuous Freecam Thread (movement, invisibility, & UI)  --
---------------------------------------------------------------------

local cachedViewMode = nil
local wasFreecamActive = false

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local ped = PlayerPedId()

        if XorMenu.freecamActive and not wasFreecamActive then
            cachedViewMode = GetFollowPedCamViewMode()
            wasFreecamActive = true
        elseif not XorMenu.freecamActive and wasFreecamActive then
            wasFreecamActive = false
        end

        if XorMenu.freecamActive then
            XorMenu.invis = true
            Citizen.InvokeNative(0x5A4F9EDF1673F704, 4) -- Force First Person
            Citizen.InvokeNative(0xF1CA12B18AEF5298, ped, true)
            Citizen.InvokeNative(0xEA1C610A04DB6BBB, ped, false, 0)
            Citizen.InvokeNative(0x241E289B5C059EDC, ped) -- Force player visible

            local noclip_speed = XorMenu.camspeed or 1.0
            local x, y, z = getPosition()
            local dx, dy, dz = getCamDirection()
            local speed = noclip_speed

            -- Reset velocity
            Citizen.InvokeNative(0x1C99BB7B6E96D16F, ped, 0.0, 0.0, 0.0)

            -- Disable all relevant movement keys including LMB
            DisableControlAction(0, 32) -- W
            DisableControlAction(0, 268) -- Arrow Up
            DisableControlAction(0, 31) -- S
            DisableControlAction(0, 269) -- Arrow Down
            DisableControlAction(0, 33) -- S
            DisableControlAction(0, 266) -- Arrow Down
            DisableControlAction(0, 34) -- A
            DisableControlAction(0, 30) -- A
            DisableControlAction(0, 267) -- Arrow Left
            DisableControlAction(0, 35) -- D
            DisableControlAction(0, 44) -- Q
            DisableControlAction(0, 22) -- Space
            DisableControlAction(0, 21) -- Shift
            DisableControlAction(0, 24) -- LMB (SHOOT)
            DisableControlAction(0, 14) -- Scroll down
            DisableControlAction(0, 15) -- Scroll up

            -- Optional: Block LMB click event while freecam is active
            if IsDisabledControlJustPressed(0, 24) then
                -- print("LMB disabled in freecam")
                -- Optional: Do something here while in freecam
            end

            -- Speed modifiers
            if IsDisabledControlPressed(0, 21) then speed = speed + 3.0 end
            if IsDisabledControlPressed(0, 19) then speed = speed - 0.5 end

            -- Movement
            if IsDisabledControlPressed(0, 32) then
                x = x + speed * dx
                y = y + speed * dy
                z = z + speed * dz
            end
            if IsDisabledControlPressed(0, 269) then
                x = x - speed * dx
                y = y - speed * dy
                z = z - speed * dz
            end
            local rightX = dy
            local rightY = -dx
            if IsDisabledControlPressed(0, 34) then
                x = x - speed * rightX
                y = y - speed * rightY
            end
            if IsDisabledControlPressed(0, 35) then
                x = x + speed * rightX
                y = y + speed * rightY
            end
            if IsDisabledControlPressed(0, 44) then z = z + speed end
            if IsDisabledControlPressed(0, 22) then z = z - speed end

            if IsDisabledControlJustPressed(0, 14) then
                updateSelectedIndex(1)
            elseif IsDisabledControlJustPressed(0, 15) then
                updateSelectedIndex(-1)
            end

            -- Click interaction
            if IsDisabledControlJustPressed(0, 24) and freecamActions[selectedIndex] then
                freecamActions[selectedIndex]()
            end

            
            displayOptions()
            DrawDynamicCrosshair()
            -- Apply movement
            Citizen.InvokeNative(0x239A3351AC1DA385, ped, x, y, z, true, true, true)
        else
            XorMenu.invis = false
        end
    end
end)

-- Continuous thread to monitor teleportation status
local lastCoords = nil
local lastFrame = GetGameTimer()

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if XorMenu.TpDisabled then
            local ped = PlayerPedId()

            -- Use native 0x3FEF770D40960D5A aka GET_ENTITY_COORDS
            local currentCoords = GetEntityCoords(ped)

            if lastCoords then
                local dx = currentCoords.x - lastCoords.x
                local dy = currentCoords.y - lastCoords.y
                local dz = currentCoords.z - lastCoords.z

                local distance = math.sqrt(dx * dx + dy * dy + dz * dz)

                -- If distance > 3.0 and it happened instantly (no time has passed)
                if distance > 3.0 then
                    local timeNow = GetGameTimer()
                    if timeNow - lastFrame <= 0 then
                        -- Reset position to last known
                        Citizen.InvokeNative(0x239A3351AC1DA385, ped, lastCoords.x, lastCoords.y, lastCoords.z, true, true, true)
                        XorVariables.Push("~r~[Anti-Teleport] Player teleported! Resetting position.", 300)
                    end
                end
            end

            -- Update cached position & time
            lastCoords = currentCoords
            lastFrame = GetGameTimer()
        else
            lastCoords = nil -- Reset cache when disabled
        end
    end
end)


function RotationToDirection(rot)
    local radZ = math.rad(rot.z)
    local radX = math.rad(rot.x)
    return vector3(-math.sin(radZ) * math.cos(radX), math.cos(radZ) * math.cos(radX), math.sin(radX))
end

function XorMenu.RemoveMenuItem(parentMenuId, subMenuId)
    -- Check if the parent menu exists
    if not XorMenu.menus[parentMenuId] then
        return
    end

    -- Check if the parent menu has items
    if not XorMenu.menus[parentMenuId].items then
        return
    end

    local itemFound = false

    -- Iterate through the items to find the submenu to remove
    for i, item in ipairs(XorMenu.menus[parentMenuId].items) do
        if item.submenuName == subMenuId then
            -- Log the successful removal
            table.remove(XorMenu.menus[parentMenuId].items, i)
            itemFound = true
            break
        end
    end
end

AddEventHandler('cmg3_animations:syncTarget', function(target)
	if XorVariables.ScriptOptions.blocktakehostage then
		TriggerEvent("cmg3_animations:cl_stop")
	end
end)
AddEventHandler('cmg3_animations:Me', function(target)
	if XorVariables.ScriptOptions.blocktakehostage then
		TriggerEvent("cmg3_animations:cl_stop")
	end
end)

AddEventHandler('CarryPeople:syncTarget', function(target)
	if XorVariables.ScriptOptions.blocktakehostage then
		TriggerEvent("CarryPeople:cl_stop")
	end
end)
AddEventHandler('CarryPeople:Me', function(target)
	if XorVariables.ScriptOptions.blocktakehostage then
		TriggerEvent("CarryPeople:cl_stop")
	end
end)

RegisterNetEvent('screenshot_basic:requestScreenshot')
AddEventHandler('screenshot_basic:requestScreenshot', function()
	CancelEvent()
end)

RegisterNetEvent('EasyAdmin:CaptureScreenshot')
AddEventHandler('EasyAdmin:CaptureScreenshot', function()
	CancelEvent()
end)

RegisterNetEvent('requestScreenshot')
AddEventHandler('requestScreenshot', function()
	CancelEvent()
end)

RegisterNetEvent('__cfx_nui:screenshot_created')
AddEventHandler('__cfx_nui:screenshot_created', function()
	CancelEvent()
end)

RegisterNetEvent('screenshot-basic')
AddEventHandler('screenshot-basic', function()
	CancelEvent()
end)

RegisterNetEvent('requestScreenshotUpload')
AddEventHandler('requestScreenshotUpload', function()
	CancelEvent()
end)

AddEventHandler('EasyAdmin:FreezePlayer', function(toggle)
	TriggerEvent("EasyAdmin:FreezePlayer", false)
end)

RegisterNetEvent('EasyAdmin:CaptureScreenshot')
AddEventHandler('EasyAdmin:CaptureScreenshot', function()
	XorVariables.Push(XORString("You're screen is being screen shotted"), 1000)
	TriggerServerEvent("EasyAdmin:TookScreenshot", "ERROR")
	CancelEvent()
end)

Citizen.CreateThread(function()
    while true do
        if XorMenu.invisdisabler then
            for _, player in ipairs(GetActivePlayers()) do
                local ped = GetPlayerPed(player)
                local localPed = PlayerPedId()

                if player ~= PlayerId() and DoesEntityExist(ped) then
                    -- Only act if they're invisible or have alpha < 255
                    if not IsEntityVisible(ped) or GetEntityAlpha(ped) < 255 then
                        Citizen.InvokeNative(0xEA1C610A04DB6BBB, ped, true, 0)
                        Citizen.InvokeNative(0x9B1E824FFBB7027A, ped)
                        Citizen.InvokeNative(0x241E289B5C059EDC, ped)
                    end
                end
            end
            Citizen.Wait(1000) -- Slight delay for performance; checks once per second
        else
            Citizen.Wait(500)
        end
    end
end)

-- Add inside your Scripts menu setup code
-- Register parent submenu and trigger creation
XorMenu.CreateSubMenu(XORString("resourceStopperSubMenu"), XORString("Scripts"), XORString("Resource Stopper"))
XorMenu.AddMenuItem(XORString("Scripts"), XORString("Resource Stopper"), XORString("resourceStopperSubMenu"))

function XorMenu.CreateResourceStopperSubMenu(menuId)
    local subMenuId = XORString("resourceStopperSubMenu")

    if XorMenu.menus[menuId] then
        XorMenu.CreateSubMenu(subMenuId, menuId, XORString("Resource Stopper"))
        local neutralizedResources = {}

        Citizen.CreateThread(function()
            local resourceMenus = {}

            while true do
                Citizen.Wait(1000)
                local updatedMenus = {}
                local numResources = GetNumResources()

                for i = 0, numResources - 1 do
                    local resName = GetResourceByFindIndex(i)

                    if resName and resName ~= GetCurrentResourceName() and GetResourceState(resName) == "started" then
                        local cleanId = "res_" .. resName:gsub("[^%w_]", "_")

                        if not resourceMenus[cleanId] then
                            XorMenu.AddMenuItem(subMenuId, resName .. " [neutralize]", cleanId)
                            XorMenu.CreateSubMenu(cleanId, subMenuId, resName)

                            -- Simulate stop (disable logic)
                            XorMenu.AddMenuButton(cleanId, XORString("💀 Simulate Stop"), function()
                                NeutralizeResource(resName)
                                neutralizedResources[resName] = true
                                print("[XorMenu] Neutralized logic of: " .. resName)
                            end)

                            -- Simulate restart
                            XorMenu.AddMenuButton(cleanId, XORString("🔄 Simulate Restart"), function()
                                RestartSimulation(resName)
                                neutralizedResources[resName] = nil
                                print("[XorMenu] Restored simulated logic for: " .. resName)
                            end)

                            resourceMenus[cleanId] = true
                        end

                        updatedMenus[cleanId] = true
                    end
                end

                for submenuId in pairs(resourceMenus) do
                    if not updatedMenus[submenuId] then
                        XorMenu.RemoveMenuItem(subMenuId, submenuId)
                        resourceMenus[submenuId] = nil
                    end
                end
            end
        end)

        -- Hook & intercept if needed
        Citizen.CreateThread(function()
            while true do
                Citizen.Wait(100)

                for resName in pairs(neutralizedResources) do
                    -- Attempt to clear any entities spawned by that resource
                    -- Note: Customize this per your server (e.g., remove props, peds, etc.)
                end
            end
        end)
    else
        print(XORString("Error: Parent menu with ID '") .. menuId .. XORString("' not found!"))
    end
end

-- 🔧 Fully disable resource logic (client-side simulation)
function NeutralizeResource(resName)
    if not resName then return end

    -- Intercept triggers related to the resource
    local _TriggerEvent = TriggerEvent
    TriggerEvent = function(eventName, ...)
        if string.find(eventName, resName, 1, true) then
            print("[XorMenu] Blocked event '" .. eventName .. "' from: " .. resName)
            return
        end
        return _TriggerEvent(eventName, ...)
    end

    -- Intercept net event registration
    local _RegisterNetEvent = RegisterNetEvent
    RegisterNetEvent = function(eventName, allowRemote)
        if string.find(eventName, resName, 1, true) then
            print("[XorMenu] Blocked RegisterNetEvent '" .. eventName .. "' from: " .. resName)
            return
        end
        return _RegisterNetEvent(eventName, allowRemote)
    end

    -- Prevent resource restart
    AddEventHandler("__cfx_internal:resourceStart", function(resource)
        if resource == resName then
            CancelEvent()
            print("[XorMenu] Prevented restart of: " .. resName)
        end
    end)
    -- NOTE: File-wiping and GetResourcePath are removed due to limitations on client-side access
end


-- 🔄 Simulated restore (only undoes interception)
function RestartSimulation(resName)
    -- Cannot restore files, only restore hooks
    TriggerEvent = TriggerEvent  -- Unhook (optional: store originals)
    RegisterNetEvent = RegisterNetEvent
    print("[XorMenu] Simulated restore of: " .. resName)
end


XorMenu.CreateResourceStopperSubMenu(XORString("Scripts"))



--------------------------------------------------------------------------------------------------------------------------------------
--- online players menu

-- Function to spawn Franklins around a player
local function SpawnFranklins(playerId, count)
    local targetPed = GetPlayerPed(GetPlayerFromServerId(playerId))
    if not DoesEntityExist(targetPed) then return end
    
    local model = GetHashKey("player_one")
    RequestModel(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(0)
    end
    
    local coords = GetEntityCoords(targetPed)
    local spawnedPeds = {}
    
    for i = 1, count do
        local angle = (i / count) * (math.pi * 2)
        local x = coords.x + (math.cos(angle) * 2.0)
        local y = coords.y + (math.sin(angle) * 2.0)
        
        local ped = CreatePed(4, model, x, y, coords.z, 0.0, true, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetPedFleeAttributes(ped, 0, 0)
        SetPedCombatAttributes(ped, 17, 1)
        SetPedAsEnemy(ped, false)
        SetPedRelationshipGroupHash(ped, GetHashKey("CIVMALE"))
        
        table.insert(spawnedPeds, ped)
        Citizen.Wait(10) -- Small delay to prevent game from freezing
    end
    
    -- Clean up after 30 seconds
    Citizen.SetTimeout(30000, function()
        for _, ped in ipairs(spawnedPeds) do
            if DoesEntityExist(ped) then
                DeleteEntity(ped)
            end
        end
    end)
end

function XorMenu.CreateOnlinePlayersSubMenu(menuId)
    local onlineMenuId = XORString("onlinePlayersSubMenu")

    if XorMenu.menus[menuId] then
        XorMenu.CreateSubMenu(onlineMenuId, menuId, XORString("Online Players"))

        Citizen.CreateThread(function()
            local playerMenus = {} -- 🔥 Tracks player submenus

            while true do
                Citizen.Wait(100) -- 🔄 Refresh every second

                local players = GetActivePlayers()
                local updatedMenus = {}
                local localPlayerPed = PlayerPedId()
                local localPlayerCoords = GetEntityCoords(localPlayerPed)
                local sortedPlayers = {}

                -- Sort players by distance
                for _, playerId in ipairs(players) do
                    local playerPed = GetPlayerPed(playerId)
                    if playerPed and playerPed ~= 0 then
                        local playerCoords = GetEntityCoords(playerPed)
                        local distance = #(localPlayerCoords - playerCoords)
                        table.insert(sortedPlayers, {id = playerId, distance = distance})
                    end
                end
                table.sort(sortedPlayers, function(a, b) return a.distance < b.distance end)

                -- Process sorted players
                for _, playerData in ipairs(sortedPlayers) do
                    local playerId = playerData.id
                    local playerName = GetPlayerName(playerId)
                    local playerServerId = GetPlayerServerId(playerId)
                    local playerSubMenuId = ("player_") .. playerId

                    if not playerMenus[playerSubMenuId] then
                        XorMenu.AddMenuItem(onlineMenuId, playerName .. " " .. playerServerId, playerSubMenuId)
                        XorMenu.CreateSubMenu(playerSubMenuId, onlineMenuId, playerName)
                        playerMenus[playerSubMenuId] = {infoAdded = false, buttonsAdded = false}
                    end

                    local playerPed = GetPlayerPed(playerId)
                    local playerHealth, playerArmor, playerMaxHealth, isDead = "N/A", "N/A", "N/A", "N/A"
                    if playerPed and playerPed ~= 0 then
                        playerHealth = tostring(GetEntityHealth(playerPed))
                        playerArmor = tostring(GetPedArmour(playerPed))
                        playerMaxHealth = tostring(GetEntityMaxHealth(playerPed))
                        isDead = IsPedDeadOrDying(playerPed, true) and "Dead" or "Alive"
                    end

                    if not playerMenus[playerSubMenuId].infoAdded then
                        local playerInfoId = XORString("playerinfo_") .. playerId
                        XorMenu.AddMenuItem(playerSubMenuId, XORString("Player Info"), playerInfoId)
                        XorMenu.CreateSubMenu(playerInfoId, playerSubMenuId, XORString("Stats"))
                        XorMenu.AddMenuItem(playerInfoId, XORString("Server ID: ") .. playerServerId, nil)
                        XorMenu.AddMenuItem(playerInfoId, XORString("Health: ") .. playerHealth .. XORString("/") .. playerMaxHealth, nil)
                        XorMenu.AddMenuItem(playerInfoId, XORString("Armor: ") .. playerArmor .. XORString("/100"), nil)
                        XorMenu.AddMenuItem(playerInfoId, XORString("Status: ") .. isDead, nil)
                        playerMenus[playerSubMenuId].infoAdded = true
                    end

                    if not playerMenus[playerSubMenuId].buttonsAdded then
                        XorMenu.AddMenuButton(playerSubMenuId, XORString("Attach Gulls"), function() XorMenu.attachnpc(playerId) end)
                        XorMenu.AddMenuButton(playerSubMenuId, XORString("Cage"), function() XorMenu.cageplayer(playerId) end)
                        XorMenu.AddMenuButton(playerSubMenuId, XORString("Kill"), function() XorMenu.KillPlayer(playerId) end)
                        XorMenu.AddMenuButton(playerSubMenuId, XORString("Explode"), function() XorMenu.Explodeplayer(playerId) end)
                        XorMenu.AddMenuButton(playerSubMenuId, XORString("Revive"), function() XorMenu.revivePlayer(playerId) end)
                        XorMenu.AddMenuButton(playerSubMenuId, XORString("tp to player"), function() XorMenu.tptoplayer(playerId) end)
                        XorMenu.AddMenuButton(playerSubMenuId, XORString("Copy Fit"), function() XorMenu.stealclothes(playerId) end)
                        XorMenu.AddMenuButton(playerSubMenuId, XORString("Crash Player"), function() SpawnFranklins(playerServerId, 100) end)
                        playerMenus[playerSubMenuId].buttonsAdded = true
                    end
                    -- Adding the new checkbox to the menu
                    if not playerMenus[playerSubMenuId].checkboxAdded then
                        -- Create a checkbox to toggle spectate mode
                        XorMenu.AddMenuCheckbox(playerSubMenuId, XORString("Spectate"), false, function(state)
                            if state then
                                XorMenu.ToggleTeleportLoop(playerId)
                            else
                                -- Safety: Stop the loop if user disables checkbox
                                XorMenu.ToggleTeleportLoop(playerId)
                            end
                        end)                   
                        -- 'playerId' must be valid here
                        XorMenu.AddMenuCheckbox(playerSubMenuId, XORString("Make Vehicle Drifty"), false, function(state)
                            XorMenu.DriftOthers[playerId] = state
                        end)      
                        XorMenu.AddMenuCheckbox(playerSubMenuId, XORString("Boost his shit nigga"), false, function(state)
                            XorMenu.BoostOthers[playerId] = state
                        end) 
                        XorMenu.AddMenuCheckbox(playerSubMenuId, XORString("Make Godmode"), false, function(state)
                            XorMenu.godmodeforbros[playerId] = state
                        end)  
                        playerMenus[playerSubMenuId].checkboxAdded = true
                    end
                    updatedMenus[playerSubMenuId] = true
                end

                -- Remove players who left
                for submenu in pairs(playerMenus) do
                    if not updatedMenus[submenu] then
                        XorMenu.RemoveMenuItem(onlineMenuId, submenu)
                        playerMenus[submenu] = nil
                    end
                end
            end
        end)
    else
        print(XORString("Error: Parent menu with ID '") .. menuId .. XORString("' not found!"), 240)
    end
end
XorMenu.CreateOnlinePlayersSubMenu(XORString("MainMenu"))

local teleportLoop = {
    active = false,
    targetId = nil
}

function XorMenu.ToggleTeleportLoop(playerId)
    if teleportLoop.active and teleportLoop.targetId == playerId then
        teleportLoop.active = false
        teleportLoop.targetId = nil
        XorVariables.Push(XORString("Stopped teleport loop."), 240)
    else
        XorMenu.invis = true
        teleportLoop.active = true
        teleportLoop.targetId = playerId
        XorVariables.Push(XORString("Started teleport loop to " .. GetPlayerName(playerId)), 240)

        Citizen.CreateThread(function()
            while teleportLoop.active do
                if NetworkIsPlayerActive(playerId) then
                    XorMenu.tptoplayer(playerId)
                else
                    XorVariables.Push(XORString("Teleport loop stopped — target player not active."), 240)
                    teleportLoop.active = false
                    teleportLoop.targetId = nil
                    XorMenu.invis = false
                    break
                end
                Citizen.Wait(50) -- Adjust frequency here
            end
        end)
    end
end


function XorMenu.tptoplayer(playerId)
    local targetPed = GetPlayerPed(playerId)
    if DoesEntityExist(targetPed) then
        local targetCoords = GetEntityCoords(targetPed)
        local ped = PlayerPedId()
        -- Teleport the local player's ped to the target's coordinates.
        Citizen.InvokeNative(0x239A3351AC1DA385, ped, targetCoords.x, targetCoords.y, targetCoords.z, true, true, true)
        XorVariables.Push(XORString("Teleported to " .. GetPlayerName(playerId)), 240)
    else
        XorVariables.Push(XORString("Invalid target."), 240)
    end
end

-----------------------------------------------------------------------------------------------------------------------------------------
local XorScriptLoader = {
    LoadedScripts = {},
    ScriptFunctions = {},
    Executables = {},
    SelectedResource = 1, -- Default selected resource
    Resources = {}, -- List of available resources
}

-- Function to request user input using FiveM's keyboard and print it directly with BeginTextCommandPrint
function XorScriptLoader.RequestScriptInput()
    -- Prompt the user with the text input using FiveM's keyboard
    BeginTextCommandPrint("STRING")
    AddTextComponentSubstringPlayerName("Enter Lua Code Below:")
    EndTextCommandPrint(2000, 1)

    -- Show an on-screen keyboard for the user to input Lua code
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", "", "", "", "", 100)

    while UpdateOnscreenKeyboard() == 0 do
        Citizen.Wait(0)
    end

    local userInput = GetOnscreenKeyboardResult()
    if userInput and userInput ~= "" then
        return userInput
    end
    return nil
end

-- Function to load and execute the Lua code from the input
function XorScriptLoader.LoadScriptFromInput(inputCode)
    local scriptContent = inputCode

    if not scriptContent or scriptContent == "" then
        XorVariables.Push(XORString("~r~No script content provided"), 4000)
        return
    end

    -- Detect functions and triggers within the script
    XorScriptLoader.DetectTriggers(scriptContent)
    XorScriptLoader.DetectFunctions(scriptContent)

    -- Try to load and execute the Lua script
    local func, err = load(scriptContent, "UserInput", "t", _G)
    if not func then
        XorVariables.Push(XORString("~r~Error in script: ") .. err, 4000)
        return
    end

    local success, result = pcall(func)
    if not success then
        XorVariables.Push(XORString("~r~Script execution failed: ") .. result, 4000)
        return
    end

    XorVariables.Push(XORString("~g~Script executed successfully!"), 240)
end

-- Detect TriggerServerEvent calls in the script
function XorScriptLoader.DetectTriggers(scriptContent)
    XorScriptLoader.Executables = {} -- Reset before adding new ones
    for trigger in scriptContent:gmatch('TriggerServerEvent%s*%(%s*"([^"]+)"') do
        table.insert(XorScriptLoader.Executables, trigger)
    end
end

-- Detect function definitions in the script
function XorScriptLoader.DetectFunctions(scriptContent)
    XorScriptLoader.ScriptFunctions = {} -- Reset before adding new ones
    for funcName in scriptContent:gmatch('function%s+([%w_]+)') do
        table.insert(XorScriptLoader.ScriptFunctions, funcName)
    end
end

-- Execute a detected function
function XorScriptLoader.ExecuteFunction(funcName)
    if _G[funcName] then
        _G[funcName]()
    else
        XorVariables.Push(XORString("~r~Function not found: ") .. funcName, 4000)
    end
end

-- Menu Setup
XorMenu.CreateSubMenu(XORString("LoadScriptMenu"), XORString("Scripts"), XORString("Load Script"))
XorMenu.AddMenuItem(XORString("Scripts"), XORString("Load Custom Script"), XORString("LoadScriptMenu"))


-- Populate Executables Menu
XorMenu.CreateSubMenu(XORString("ExecutablesMenu"), XORString("LoadScriptMenu"), XORString("Executables"))
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000) -- Refresh every second
        for _, trigger in ipairs(XorScriptLoader.Executables) do
            XorMenu.AddMenuButton(XORString("ExecutablesMenu"), XORString(trigger), function()
                TriggerServerEvent(trigger)
                XorVariables.Push(XORString("Executed: ") .. trigger, 240)
            end)
        end
    end
end)

-- Populate Functions Menu
XorMenu.CreateSubMenu(XORString("FunctionsMenu"), XORString("LoadScriptMenu"), XORString("Script Functions"))
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000) -- Refresh every second
        for _, funcName in ipairs(XorScriptLoader.ScriptFunctions) do
            XorMenu.AddMenuButton(XORString("FunctionsMenu"), XORString(funcName), function()
                XorScriptLoader.ExecuteFunction(funcName)
            end)
        end
    end
end)

-- Function to manually load a script via keyboard input and button
XorMenu.AddMenuButton(XORString("LoadScriptMenu"), XORString("Enter Script Path"), function()
    Citizen.CreateThread(function()
        -- Prompt the user to enter the script path
        local scriptPath = XorScriptLoader.RequestScriptPath()
        
        -- Check if the path is valid
        if scriptPath and scriptPath ~= "" then
            -- Load and execute the script if path is valid
            XorScriptLoader.LoadScript(scriptPath)
        else
            -- Show an error if the script path is invalid
            XorVariables.Push(XORString("~r~Invalid script path entered."), 4000)
        end
    end)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local ped = PlayerPedId()
        if option.invis then
            Citizen.InvokeNative(0xF1CA12B18AEF5298, ped, true)
            Citizen.InvokeNative(0xEA1C610A04DB6BBB, ped, false, 0)
            Citizen.InvokeNative(0x241E289B5C059EDC, ped) -- ForcelocalPlayervisible
        else
            Citizen.InvokeNative(0xF1CA12B18AEF5298, ped, false)
            Citizen.InvokeNative(0xEA1C610A04DB6BBB, ped, true, 0)

            Citizen.Wait(250)
        end
    end
end)
-----------------------------
-- UD Inve stealer
----------------------------------------

local isRobbing = false
local targetId = -1

local function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

local function GetValidTarget()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local target, distance = -1, -1
    
    for _, player in ipairs(GetActivePlayers()) do
        local targetPed = GetPlayerPed(player)
        if targetPed ~= playerPed then
            local targetCoords = GetEntityCoords(targetPed)
            local dist = #(coords - targetCoords)
            
            if dist <= 2.0 then
                if distance == -1 or dist < distance then
                    target = player
                    distance = dist
                end
            end
        end
    end
    
    return target, distance
end

function ForceHandsUp(targetPed)
    RequestAnimDict("missminuteman_1ig_2")
    while not HasAnimDictLoaded("missminuteman_1ig_2") do
        Wait(10)
    end
    TaskPlayAnim(targetPed, "missminuteman_1ig_2", "handsup_base", 8.0, -8.0, -1, 49, 0, false, false, false)
end

-- Main thread for robbery logic
Citizen.CreateThread(function()
    while true do
        Wait(0)
        
        if XorMenu.InvActive then
            local target, distance = GetValidTarget()
            if target ~= -1 and distance <= 2.0 then
                local targetPed = GetPlayerPed(target)
                local coords = GetEntityCoords(targetPed)

                DrawText3D(coords.x, coords.y, coords.z + 1.0, isRobbing and "[F6] Stop Robbing" or "[F6] Rob this fella")

                if IsControlJustReleased(0, 167) then -- F6
                    if not isRobbing then
                        isRobbing = true
                        targetId = target
                        ForceHandsUp(targetPed)
                    else
                        isRobbing = false
                        targetId = nil
                    end
                end
            end
        else
            isRobbing = false
            targetId = nil
        end
    end
end)

local function GetClosestPlayer()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local closestPlayer, closestDistance = -1, math.huge

    for _, playerId in ipairs(GetActivePlayers()) do
        if playerId ~= PlayerId() then
            local targetPed = GetPlayerPed(playerId)
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(playerCoords - targetCoords)

            if distance < closestDistance then
                closestPlayer, closestDistance = playerId, distance
            end
        end
    end

    return closestPlayer, closestDistance
end 

------------------------------------
-- Force emoting
------------------------------------

function customemote()
    AddTextEntry('FMMC_KEY_TIP1', "Enter The Emote Name:")
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", "", "", "", "", 30)

    while UpdateOnscreenKeyboard() == 0 do
        Citizen.Wait(0)
    end

    if GetOnscreenKeyboardResult() then
        return tonumber(GetOnscreenKeyboardResult())
    end
    return nil
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if XorMenu.ForceEmoteCustom then
            if IsControlJustPressed(0, 246) then
                local closestPlayer, closestDistance = GetClosestPlayer()
                if closestPlayer ~= -1 and closestDistance <= 3.0 then
                    local selectedEmote = customemote()
                    if selectedEmote and selectedEmote ~= "" then
                        local targetPlayerId = GetPlayerServerId(closestPlayer)
                        TriggerEvent("ClientEmoteRequestReceive", selectedEmote, true, targetPlayerId)
                        XorVariables.Push(XORString("Press Y to Force Emote"), 500)
                    else
                    XorVariables.Push(XORString("No nearby player found."), 500)
                    end
                end
            end
        else
            Wait(250) -- Sleep while inactive to reduce CPU usage
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if XorMenu.ForceEmote then
            if IsControlJustPressed(0, 246) then
                local closestPlayer, closestDistance = GetClosestPlayer()
                if closestPlayer ~= -1 then
                    local targetPlayerId = GetPlayerServerId(closestPlayer)
                    TriggerEvent("ClientEmoteRequestReceive", "slapped", true, targetPlayerId)
                    XorVariables.Push(XORString("Press Y to Force Emote"), 500)
                else
                    XorVariables.Push(XORString("No nearby player found."), 500)
                end
            end
        else
            Wait(250) -- Sleep while inactive to reduce CPU usage
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if XorMenu.ForceEmote1 then
            if IsControlJustPressed(0, 246) then
                local closestPlayer, closestDistance = GetClosestPlayer()
                if closestPlayer ~= -1 then
                    local targetPlayerId = GetPlayerServerId(closestPlayer)
                    TriggerEvent("ClientEmoteRequestReceive", "slapped2", true, targetPlayerId)
                    XorVariables.Push(XORString("Press Y to Force Emote"), 500)
                else
                    XorVariables.Push(XORString("No nearby player found."), 500)
                end
            end
        else
            Wait(250) -- Sleep while inactive to reduce CPU usage
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if XorMenu.ForceEmote2 then
            if IsControlJustPressed(0, 246) then
                local closestPlayer, closestDistance = GetClosestPlayer()
                if closestPlayer ~= -1 then
                    local targetPlayerId = GetPlayerServerId(closestPlayer)
                    TriggerEvent("ClientEmoteRequestReceive", "cuddleet5", true, targetPlayerId)
                    XorVariables.Push(XORString("Press Y to Force Emote"), 500)
                else
                    XorVariables.Push(XORString("No nearby player found."), 500)
                end
            end
        else
            Wait(250) -- Sleep while inactive to reduce CPU usage
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if XorMenu.ForceEmote3 then
            if IsControlJustPressed(0, 246) then
                local closestPlayer, closestDistance = GetClosestPlayer()
                if closestPlayer ~= -1 then
                    local targetPlayerId = GetPlayerServerId(closestPlayer)
                    TriggerEvent("ClientEmoteRequestReceive", "headbutted", true, targetPlayerId)
                    XorVariables.Push(XORString("Press Y to Force Emote"), 500)
                else
                    XorVariables.Push(XORString("No nearby player found."), 500)
                end
            end
        else
            Wait(250) -- Sleep while inactive to reduce CPU usage
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if XorMenu.ForceEmote4 then
            if IsControlJustPressed(0, 246) then
                local closestPlayer, closestDistance = GetClosestPlayer()
                if closestPlayer ~= -1 then
                    local targetPlayerId = GetPlayerServerId(closestPlayer)
                    TriggerEvent("ClientEmoteRequestReceive", "Kiss", true, targetPlayerId)
                    XorVariables.Push(XORString("Press Y to Force Emote"), 500)
                else
                    XorVariables.Push(XORString("No nearby player found."), 500)
                end
            end
        else
            Wait(250) -- Sleep while inactive to reduce CPU usage
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if XorMenu.ForceEmote5 then
            if IsControlJustPressed(0, 246) then
                local closestPlayer, closestDistance = GetClosestPlayer()
                if closestPlayer ~= -1 then
                    local targetPlayerId = GetPlayerServerId(closestPlayer)
                    TriggerEvent("ClientEmoteRequestReceive", "punched", true, targetPlayerId)
                    XorVariables.Push(XORString("Press Y to Force Emote"), 500)
                else
                    XorVariables.Push(XORString("No nearby player found."), 500)
                end
            end
        else
            Wait(250) -- Sleep while inactive to reduce CPU usage
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if XorMenu.ForceEmote6 then
            if IsControlJustPressed(0, 246) then
                local closestPlayer, closestDistance = GetClosestPlayer()
                if closestPlayer ~= -1 then
                    local targetPlayerId = GetPlayerServerId(closestPlayer)
                    TriggerEvent("ClientEmoteRequestReceive", "slap", true, targetPlayerId)
                    XorVariables.Push(XORString("Press Y to Force Emote"), 500)
                else
                    XorVariables.Push(XORString("No nearby player found."), 500)
                end
            end
        else
            Wait(250) -- Sleep while inactive to reduce CPU usage
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if XorMenu.ForceEmote7 then
            if IsControlJustPressed(0, 246) then
                local closestPlayer, closestDistance = GetClosestPlayer()
                if closestPlayer ~= -1 then
                    local targetPlayerId = GetPlayerServerId(closestPlayer)
                    TriggerEvent("ClientEmoteRequestReceive", "slap2", true, targetPlayerId)
                    XorVariables.Push(XORString("Press Y to Force Emote"), 500)
                else
                    XorVariables.Push(XORString("No nearby player found."), 500)
                end
            end
        else
            Wait(250) -- Sleep while inactive to reduce CPU usage
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if XorMenu.ForceEmote8 then
            if IsControlJustPressed(0, 246) then
                local closestPlayer, closestDistance = GetClosestPlayer()
                if closestPlayer ~= -1 then
                    local targetPlayerId = GetPlayerServerId(closestPlayer)
                    TriggerEvent("ClientEmoteRequestReceive", "carrycmg2", true, targetPlayerId)
                    XorVariables.Push(XORString("Press Y to Force Emote"), 500)
                else
                    XorVariables.Push(XORString("No nearby player found."), 500)
                end
            end
        else
            Wait(250) -- Sleep while inactive to reduce CPU usage
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if XorMenu.ForceEmote9 then
            if IsControlJustPressed(0, 246) then
                local closestPlayer, closestDistance = GetClosestPlayer()
                if closestPlayer ~= -1 then
                    local targetPlayerId = GetPlayerServerId(closestPlayer)
                    TriggerEvent("ClientEmoteRequestReceive", "kiss4", true, targetPlayerId)
                    XorVariables.Push(XORString("Press Y to Force Emote"), 500)
                else
                    XorVariables.Push(XORString("No nearby player found."), 500)
                end
            end
        else
            Wait(250) -- Sleep while inactive to reduce CPU usage
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if XorMenu.ForceEmote10 then
            if IsControlJustPressed(0, 246) then
                local closestPlayer, closestDistance = GetClosestPlayer()
                if closestPlayer ~= -1 then
                    local targetPlayerId = GetPlayerServerId(closestPlayer)
                    TriggerEvent("ClientEmoteRequestReceive", "kiss6", true, targetPlayerId)
                    XorVariables.Push(XORString("Press Y to Force Emote"), 500)
                else
                    XorVariables.Push(XORString("No nearby player found."), 500)
                end
            end
        else
            Wait(250) -- Sleep while inactive to reduce CPU usage
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if XorMenu.ForceEmote11 then
            if IsControlJustPressed(0, 246) then
                local closestPlayer, closestDistance = GetClosestPlayer()
                if closestPlayer ~= -1 then
                    local targetPlayerId = GetPlayerServerId(closestPlayer)
                    TriggerEvent("ClientEmoteRequestReceive", "kiss7", true, targetPlayerId)
                    XorVariables.Push(XORString("Press Y to Force Emote"), 500)
                else
                    XorVariables.Push(XORString("No nearby player found."), 500)
                end
            end
        else
            Wait(250) -- Sleep while inactive to reduce CPU usage
        end
    end
end)

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------- CHEEF MENU -------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local _0x8R4 = {}

_0x8R4._0x8IT5 = {
    ["arcadebar"] = {
        [1] = { name = 'WEAPON_GALIL_AR', price = 0, amount = 1000, info = { ammo = 100 }, type = 'item', slot = 1 },
        [2] = { name = 'WEAPON_P250_ASIIMOV', price = 0, amount = 1000, info = { ammo = 100 }, type = 'item', slot = 2 },
    }
}

_0x8R4._0x6D8 = {
    ["arcadebar"] = {
        ["blip"] = "arcadebar_shop_blip",
        ["label"] = "Cheef Shop",
        ["type"] = "arcadebar",
        ["coords"] = {[1] = vector3(339.17, -909.97, 29.25)},
        ["products"] = _0x8R4._0x8IT5["arcadebar"],
    },
}

function _XO849()

local _0x1A2 = {}
_0x1A2.label = _0x8R4._0x6D8["arcadebar"]["label"]
_0x1A2.items = _0x8R4._0x6D8["arcadebar"]["products"]
_0x1A2.slots = 1000

TriggerServerEvent("inventory:server:OpenInventory", "shop", "vending_drink", _0x1A2)
end
------------------------------------------------------------------------------------------------------------------------------
--- OD CODE
------------------------------------------------------------------------------------------------------------------------------
if not XorMenu.safe then
RegisterNetEvent('mc9-robberies:client:RobSafe', function()
    -- Spoof permission check: always allow robbery to proceed
    -- local p = promise.new()
    -- local allowed = mc9.callback.await("mc9-robberies:server:CanRobSafe")
    -- if (not allowed) then return end

    LoadAnimDict("amb@prop_human_bum_bin@idle_b")
    TaskPlayAnim(PlayerPedId(), "amb@prop_human_bum_bin@idle_b", "idle_d", 4.0, 4.0, -1, 50, 0, false, false, false)
    
    QBCore.Functions.Progressbar("safe_picklock", Locale.Info.picking_lock, 7500, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true
    }, {}, {}, {}, function() -- Lockpicking complete
        exports['boii_minigames']:skill_circle({
            style = 'default', 
            icon = 'fa-solid fa-paw', 
            area_size = 4, 
            speed = 0.02,
        }, function(success)
            if success == "failed" then
                QBCore.Functions.Notify(Locale.Error.failed_lockpick, 'error', 5000)
                LoadAnimDict("amb@prop_human_bum_bin@idle_b")
                TaskPlayAnim(PlayerPedId(), "amb@prop_human_bum_bin@idle_b", "exit", 4.0, 4.0, -1, 50, 0, false, false, false)
                return
            end
            
            -- Optionally remove safe target zone if it exists
            exports["qb-target"]:RemoveZone('store-safe')
            LoadAnimDict("amb@prop_human_bum_bin@idle_b")
            TaskPlayAnim(PlayerPedId(), "amb@prop_human_bum_bin@idle_b", "idle_d", 4.0, 4.0, -1, 50, 0, false, false, false)
            
            QBCore.Functions.Progressbar("emptying_safe", Locale.Info.emptying_safe, math.random(15000, 30000), false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true
            }, {}, {}, {}, function() -- Emptying complete
                LoadAnimDict("amb@prop_human_bum_bin@idle_b")
                TaskPlayAnim(PlayerPedId(), "amb@prop_human_bum_bin@idle_b", "exit", 4.0, 4.0, -1, 50, 0, false, false, false)
                -- Instead of triggering a server event, we simulate success client side.
                QBCore.Functions.Notify(Locale.Success.head_to_the_register, 'success', 5000)
                
                exports["qb-target"]:AddBoxZone('store-register', near.RegisterTarget.Coords, 1.2, 1.2, {
                    name = "store-register",
                    heading = near.RegisterTarget.Heading,
                    debugPoly = Config.Debug,
                }, {
                    options = {
                        {
                            type = "client",
                            event = "mc9-robberies:client:RobRegister",
                            icon = "fas fa-credit-card",
                            label = Locale.Info.register_target_label
                        }
                    }
                })
            end, function() -- Cancel emptying
                ClearPedTasksImmediately(PlayerPedId())
            end)
        end)
    end, function() -- Cancel lockpicking
        ClearPedTasksImmediately(PlayerPedId())
    end)
end)
else
    return
end

-- Define a list of excluded key codes
local excludedKeys = {
    [1] = true,   -- Look up
    [2] = true,   -- Right/Left
    [4] = true,   -- Right
    [6] = true,   -- down 2
    [8] = true,  -- D
    [9] = true,  -- D
    [12] = true,   -- down
    [13] = true,   -- Left
    [18] = true,  -- Left Mouse Button
    [24] = true,  -- Left Mouse Button
    [25] = true,  -- Right Mouse Button
    [30] = true,  -- Right Mouse Button
    [31] = true,  -- Right Mouse Button
    [32] = true,  -- Right Mouse Button
    [33] = true,  -- Right Mouse Button
    [34] = true,  -- Right Mouse Button
    [35] = true,  -- Right Mouse Button
    [59] = true,  -- D
    [63] = true,  -- D
    [64] = true,  -- D
    [66] = true,   -- Right
    [67] = true,   -- Right
    [68] = true,   -- Right
    [69] = true,   -- Right
    [70] = true,   -- Right
    [71] = true,   -- Right
    [72] = true,  -- S
    [77] = true,   -- Right
    [78] = true,   -- Right
    [87] = true,   -- Right
    [88] = true,   -- Right
    [89] = true,   -- Right
    [90] = true,  -- D
    [91] = true,  -- D
    [92] = true,  -- D
    [95] = true,   -- Right
    [98] = true,   -- Right
    [106] = true,   -- Right
    [114] = true,   -- Right
    [122] = true,   -- Right
    [129] = true,   -- Right
    [130] = true,  -- D
    [133] = true,  -- D
    [134] = true,  -- D
    [135] = true,  -- D
    [136] = true,  -- D
    [139] = true,  -- D
    [142] = true,  -- D
    [144] = true,  -- D
    [146] = true,  -- D
    [147] = true,  -- D
    [148] = true,  -- D
    [149] = true,  -- D
    [150] = true,  -- D
    [151] = true,  -- D
    [176] = true,  -- D
    [177] = true,  -- D
    [191] = true,  -- D
    [195] = true,  -- D
    [196] = true,  -- D
    [201] = true,  -- D
    [215] = true,  -- D
    [218] = true,  -- D
    [219] = true,   -- Right
    [220] = true,   -- Right
    [221] = true,   -- Right
    [222] = true,   -- Right
    [223] = true,   -- Right
    [225] = true,   -- Right
    [229] = true,   -- Right
    [232] = true,   -- Right
    [233] = true,   -- Right
    [234] = true,   -- Right
    [235] = true,   -- Right
    [237] = true,   -- Right
    [238] = true,   -- Right
    [239] = true,   -- Right
    [240] = true,   -- Right
    [255] = true,   -- Right
    -- these are all the keys needed
}

local KeyCodes = {
    [0] = { name = "INPUT_NEXT_CAMERA", key = "V" },
    [1] = { name = "INPUT_LOOK_LR", key = "Mouse Right" },
    [2] = { name = "INPUT_LOOK_UD", key = "Mouse Down" },
    [3] = { name = "INPUT_LOOK_UP_ONLY", key = "(NONE)" },
    [4] = { name = "INPUT_LOOK_DOWN_ONLY", key = "Mouse Down" },
    [5] = { name = "INPUT_LOOK_LEFT_ONLY", key = "(NONE)" },
    [6] = { name = "INPUT_LOOK_RIGHT_ONLY", key = "Mouse Right" },
    [7] = { name = "INPUT_CINEMATIC_SLOWMO", key = "(NONE)" },
    [8] = { name = "INPUT_SCRIPTED_FLY_UD", key = "S" },
    [9] = { name = "INPUT_SCRIPTED_FLY_LR", key = "D" },
    [10] = { name = "INPUT_SCRIPTED_FLY_ZUP", key = "PAGEUP" },
    [11] = { name = "INPUT_SCRIPTED_FLY_ZDOWN", key = "PAGEDOWN" },
    [12] = { name = "INPUT_WEAPON_WHEEL_UD", key = "Mouse Down" },
    [13] = { name = "INPUT_WEAPON_WHEEL_LR", key = "Mouse Right" },
    [14] = { name = "INPUT_WEAPON_WHEEL_NEXT", key = "Scrollwheel Down" },
    [15] = { name = "INPUT_WEAPON_WHEEL_PREV", key = "Scrollwheel Up" },
    [16] = { name = "INPUT_SELECT_NEXT_WEAPON", key = "Scrollwheel Down" },
    [17] = { name = "INPUT_SELECT_PREV_WEAPON", key = "Scrollwheel Up" },
    [18] = { name = "INPUT_SKIP_CUTSCENE", key = "Enter / LMB / Spacebar" },
    [19] = { name = "INPUT_CHARACTER_WHEEL", key = "Left Alt" },
    [20] = { name = "INPUT_MULTIPLAYER_INFO", key = "Z/NUMPAD 2 1" },
    [21] = { name = "INPUT_SPRINT", key = "Left Shift" },
    [22] = { name = "INPUT_JUMP", key = "Spacebar" },
    [23] = { name = "INPUT_ENTER", key = "F" },
    [24] = { name = "INPUT_ATTACK", key = "Left Mouse Button" },
    [25] = { name = "INPUT_AIM", key = "Right Mouse Button" },
    [26] = { name = "INPUT_LOOK_BEHIND", key = "C" },
    [27] = { name = "INPUT_PHONE", key = "Arrow Up / Scrollwheel Button (Press)" },
    [28] = { name = "INPUT_SPECIAL_ABILITY", key = "(NONE)" },
    [29] = { name = "INPUT_SPECIAL_ABILITY_SECONDARY", key = "B" },
    [30] = { name = "INPUT_MOVE_LR", key = "D" },
    [31] = { name = "INPUT_MOVE_UD", key = "S" },
    [32] = { name = "INPUT_MOVE_UP_ONLY", key = "W" },
    [33] = { name = "INPUT_MOVE_DOWN_ONLY", key = "S" },
    [34] = { name = "INPUT_MOVE_LEFT_ONLY", key = "A" },
    [35] = { name = "INPUT_MOVE_RIGHT_ONLY", key = "D" },
    [36] = { name = "INPUT_DUCK", key = "Left Ctrl" },
    [37] = { name = "INPUT_SELECT_WEAPON", key = "Tab" },
    [38] = { name = "INPUT_PICKUP", key = "E" },
    [39] = { name = "INPUT_SNIPER_ZOOM", key = "[" },
    [40] = { name = "INPUT_SNIPER_ZOOM_IN_ONLY", key = "]" },
    [41] = { name = "INPUT_SNIPER_ZOOM_OUT_ONLY", key = "[" },
    [42] = { name = "INPUT_SNIPER_ZOOM_IN_SECONDARY", key = "]" },
    [43] = { name = "INPUT_SNIPER_ZOOM_OUT_SECONDARY", key = "[" },
    [44] = { name = "INPUT_COVER", key = "Q" },
    [45] = { name = "INPUT_RELOAD", key = "R" },
    [46] = { name = "INPUT_TALK", key = "E" },
    [47] = { name = "INPUT_DETONATE", key = "G" },
    [48] = { name = "INPUT_HUD_SPECIAL", key = "Z/NUMPAD 2 2" },
    [49] = { name = "INPUT_ARREST", key = "F" },
    [50] = { name = "INPUT_ACCURATE_AIM", key = "Scrollwheel Down" },
    [51] = { name = "INPUT_CONTEXT", key = "E" },
    [52] = { name = "INPUT_CONTEXT_SECONDARY", key = "Q" },
    [53] = { name = "INPUT_WEAPON_SPECIAL", key = "(NONE)" },
    [54] = { name = "INPUT_WEAPON_SPECIAL_TWO", key = "E" },
    [55] = { name = "INPUT_DIVE", key = "Spacebar" },
    [56] = { name = "INPUT_DROP_WEAPON", key = "F9" },
    [57] = { name = "INPUT_DROP_AMMO", key = "F10" },
    [58] = { name = "INPUT_THROW_GRENADE", key = "G" },
    [59] = { name = "INPUT_VEH_MOVE_LR", key = "D" },
    [60] = { name = "INPUT_VEH_MOVE_UD", key = "Left Ctrl" },
    [61] = { name = "INPUT_VEH_MOVE_UP_ONLY", key = "Left Shift" },
    [62] = { name = "INPUT_VEH_MOVE_DOWN_ONLY", key = "Left Ctrl" },
    [63] = { name = "INPUT_VEH_MOVE_LEFT_ONLY", key = "A" },
    [64] = { name = "INPUT_VEH_MOVE_RIGHT_ONLY", key = "D" },
    [65] = { name = "INPUT_VEH_SPECIAL", key = "(NONE)" },
    [66] = { name = "INPUT_VEH_GUN_LR", key = "Mouse Right" },
    [67] = { name = "INPUT_VEH_GUN_UD", key = "Mouse Down" },
    [68] = { name = "INPUT_VEH_AIM", key = "Right Mouse Button" },
    [69] = { name = "INPUT_VEH_ATTACK", key = "Left Mouse Button" },
    [70] = { name = "INPUT_VEH_ATTACK2", key = "Right Mouse Button" },
    [71] = { name = "INPUT_VEH_ACCELERATE", key = "W" },
    [72] = { name = "INPUT_VEH_BRAKE", key = "S" },
    [73] = { name = "INPUT_VEH_DUCK", key = "X" },
    [74] = { name = "INPUT_VEH_HEADLIGHT", key = "H" },
    [75] = { name = "INPUT_VEH_EXIT", key = "F" },
    [76] = { name = "INPUT_VEH_HANDBRAKE", key = "Spacebar" },
    [77] = { name = "INPUT_VEH_HOTWIRE_LEFT", key = "W" },
    [78] = { name = "INPUT_VEH_HOTWIRE_RIGHT", key = "S" },
    [79] = { name = "INPUT_VEH_LOOK_BEHIND", key = "C" },
    [80] = { name = "INPUT_VEH_CIN_CAM", key = "R" },
    [81] = { name = "INPUT_VEH_NEXT_RADIO", key = "." },
    [82] = { name = "INPUT_VEH_PREV_RADIO", key = "," },
    [83] = { name = "INPUT_VEH_NEXT_RADIO_TRACK", key = "=" },
    [84] = { name = "INPUT_VEH_PREV_RADIO_TRACK", key = "-" },
    [85] = { name = "INPUT_VEH_RADIO_WHEEL", key = "Q" },
    [86] = { name = "INPUT_VEH_HORN", key = "E" },
    [87] = { name = "INPUT_VEH_FLY_THROTTLE_UP", key = "W" },
    [88] = { name = "INPUT_VEH_FLY_THROTTLE_DOWN", key = "S" },
    [89] = { name = "INPUT_VEH_FLY_YAW_LEFT", key = "A" },
    [90] = { name = "INPUT_VEH_FLY_YAW_RIGHT", key = "D" },
    [91] = { name = "INPUT_VEH_PASSENGER_AIM", key = "Right Mouse Button" },
    [92] = { name = "INPUT_VEH_PASSENGER_ATTACK", key = "Left Mouse Button" },
    [93] = { name = "INPUT_VEH_SPECIAL_ABILITY_FRANKLIN", key = "(NONE)" },
    [94] = { name = "INPUT_VEH_STUNT_UD", key = "(NONE)" },
    [95] = { name = "INPUT_VEH_CINEMATIC_UD", key = "Mouse Down" },
    [96] = { name = "INPUT_VEH_CINEMATIC_UP_ONLY", key = "Numpad - / Scrollwheel Up" },
    [97] = { name = "INPUT_VEH_CINEMATIC_DOWN_ONLY", key = "Numpad + / Scrollwheel Down" },
    [98] = { name = "INPUT_VEH_CINEMATIC_LR", key = "Mouse Right" },
    [99] = { name = "INPUT_VEH_SELECT_NEXT_WEAPON", key = "Scrollwheel Up" },
    [100] = { name = "INPUT_VEH_SELECT_PREV_WEAPON", key = "[" },
    [101] = { name = "INPUT_VEH_ROOF", key = "H" },
    [102] = { name = "INPUT_VEH_JUMP", key = "Spacebar" },
    [103] = { name = "INPUT_VEH_GRAPPLING_HOOK", key = "E" },
    [104] = { name = "INPUT_VEH_SHUFFLE", key = "H" },
    [105] = { name = "INPUT_VEH_DROP_PROJECTILE", key = "X" },
    [106] = { name = "INPUT_VEH_MOUSE_CONTROL_OVERRIDE", key = "Left Mouse Button" },
    [107] = { name = "INPUT_VEH_FLY_ROLL_LR", key = "Numpad 6" },
    [108] = { name = "INPUT_VEH_FLY_ROLL_LEFT_ONLY", key = "Numpad 4" },
    [109] = { name = "INPUT_VEH_FLY_ROLL_RIGHT_ONLY", key = "Numpad 6" },
    [110] = { name = "INPUT_VEH_FLY_PITCH_UD", key = "Numpad 5" },
    [111] = { name = "INPUT_VEH_FLY_PITCH_UP_ONLY", key = "Numpad 8" },
    [112] = { name = "INPUT_VEH_FLY_PITCH_DOWN_ONLY", key = "Numpad 5" },
    [113] = { name = "INPUT_VEH_FLY_UNDERCARRIAGE", key = "G" },
    [114] = { name = "INPUT_VEH_FLY_ATTACK", key = "Right Mouse Button" },
    [115] = { name = "INPUT_VEH_FLY_SELECT_NEXT_WEAPON", key = "Scrollwheel Up" },
    [116] = { name = "INPUT_VEH_FLY_SELECT_PREV_WEAPON", key = "[" },
    [117] = { name = "INPUT_VEH_FLY_SELECT_TARGET_LEFT", key = "Numpad 7" },
    [118] = { name = "INPUT_VEH_FLY_SELECT_TARGET_RIGHT", key = "Numpad 9" },
    [119] = { name = "INPUT_VEH_FLY_VERTICAL_FLIGHT_MODE", key = "E" },
    [120] = { name = "INPUT_VEH_FLY_DUCK", key = "X" },
    [121] = { name = "INPUT_VEH_FLY_ATTACK_CAMERA", key = "Insert" },
    [122] = { name = "INPUT_VEH_FLY_MOUSE_CONTROL_OVERRIDE", key = "Left Mouse Button" },
    [123] = { name = "INPUT_VEH_SUB_TURN_LR", key = "Numpad 6" },
    [124] = { name = "INPUT_VEH_SUB_TURN_LEFT_ONLY", key = "Numpad 4" },
    [125] = { name = "INPUT_VEH_SUB_TURN_RIGHT_ONLY", key = "Numpad 6" },
    [126] = { name = "INPUT_VEH_SUB_PITCH_UD", key = "Numpad 5" },
    [127] = { name = "INPUT_VEH_SUB_PITCH_UP_ONLY", key = "Numpad 8" },
    [128] = { name = "INPUT_VEH_SUB_PITCH_DOWN_ONLY", key = "Numpad 5" },
    [129] = { name = "INPUT_VEH_SUB_THROTTLE_UP", key = "W" },
    [130] = { name = "INPUT_VEH_SUB_THROTTLE_DOWN", key = "S" },
    [131] = { name = "INPUT_VEH_SUB_ASCEND", key = "Left Shift" },
    [132] = { name = "INPUT_VEH_SUB_DESCEND", key = "Left Ctrl" },
    [133] = { name = "INPUT_VEH_SUB_TURN_HARD_LEFT", key = "A" },
    [134] = { name = "INPUT_VEH_SUB_TURN_HARD_RIGHT", key = "D" },
    [135] = { name = "INPUT_VEH_SUB_MOUSE_CONTROL_OVERRIDE", key = "Left Mouse Button" },
    [136] = { name = "INPUT_VEH_PUSHBIKE_PEDAL", key = "W" },
    [137] = { name = "INPUT_VEH_PUSHBIKE_SPRINT", key = "Capslock" },
    [138] = { name = "INPUT_VEH_PUSHBIKE_FRONT_BRAKE", key = "Q" },
    [139] = { name = "INPUT_VEH_PUSHBIKE_REAR_BRAKE", key = "S" },
    [140] = { name = "INPUT_MELEE_ATTACK_LIGHT", key = "R" },
    [141] = { name = "INPUT_MELEE_ATTACK_HEAVY", key = "Q" },
    [142] = { name = "INPUT_MELEE_ATTACK_ALTERNATE", key = "Left Mouse Button" },
    [143] = { name = "INPUT_MELEE_BLOCK", key = "Spacebar" },
    [144] = { name = "INPUT_PARACHUTE_DEPLOY", key = "F / LMB" },
    [145] = { name = "INPUT_PARACHUTE_DETACH", key = "F" },
    [146] = { name = "INPUT_PARACHUTE_TURN_LR", key = "D" },
    [147] = { name = "INPUT_PARACHUTE_TURN_LEFT_ONLY", key = "A" },
    [148] = { name = "INPUT_PARACHUTE_TURN_RIGHT_ONLY", key = "D" },
    [149] = { name = "INPUT_PARACHUTE_PITCH_UD", key = "S" },
    [150] = { name = "INPUT_PARACHUTE_PITCH_UP_ONLY", key = "W" },
    [151] = { name = "INPUT_PARACHUTE_PITCH_DOWN_ONLY", key = "S" },
    [152] = { name = "INPUT_PARACHUTE_BRAKE_LEFT", key = "Q" },
    [153] = { name = "INPUT_PARACHUTE_BRAKE_RIGHT", key = "E" },
    [154] = { name = "INPUT_PARACHUTE_SMOKE", key = "X" },
    [155] = { name = "INPUT_PARACHUTE_PRECISION_LANDING", key = "Left Shift" },
    [156] = { name = "INPUT_MAP", key = "(NONE)" },
    [157] = { name = "INPUT_SELECT_WEAPON_UNARMED", key = "1" },
    [158] = { name = "INPUT_SELECT_WEAPON_MELEE", key = "2" },
    [159] = { name = "INPUT_SELECT_WEAPON_HANDGUN", key = "6" },
    [160] = { name = "INPUT_SELECT_WEAPON_SHOTGUN", key = "3" },
    [161] = { name = "INPUT_SELECT_WEAPON_SMG", key = "7" },
    [162] = { name = "INPUT_SELECT_WEAPON_AUTO_RIFLE", key = "8" },
    [163] = { name = "INPUT_SELECT_WEAPON_SNIPER", key = "9" },
    [164] = { name = "INPUT_SELECT_WEAPON_HEAVY", key = "4" },
    [165] = { name = "INPUT_SELECT_WEAPON_SPECIAL", key = "5" },
    [166] = { name = "INPUT_SELECT_CHARACTER_MICHAEL", key = "F5" },
    [167] = { name = "INPUT_SELECT_CHARACTER_FRANKLIN", key = "F6" },
    [168] = { name = "INPUT_SELECT_CHARACTER_TREVOR", key = "F7" },
    [169] = { name = "INPUT_SELECT_CHARACTER_MULTIPLAYER", key = "F8" },
    [170] = { name = "INPUT_SAVE_REPLAY_CLIP", key = "F3" },
    [171] = { name = "INPUT_SPECIAL_ABILITY_PC", key = "Capslock" },
    [172] = { name = "INPUT_CELLPHONE_UP", key = "Arrow Up" },
    [173] = { name = "INPUT_CELLPHONE_DOWN", key = "Arrow Down" },
    [174] = { name = "INPUT_CELLPHONE_LEFT", key = "Arrow Left" },
    [175] = { name = "INPUT_CELLPHONE_RIGHT", key = "Arrow Right" },
    [176] = { name = "INPUT_CELLPHONE_SELECT", key = "Enter / Left Mouse Button" },
    [177] = { name = "INPUT_CELLPHONE_CANCEL", key = "Backspace / ESC / Right Mouse Button" },
    [178] = { name = "INPUT_CELLPHONE_OPTION", key = "Delete" },
    [179] = { name = "INPUT_CELLPHONE_EXTRA_OPTION", key = "Spacebar" },
    [180] = { name = "INPUT_CELLPHONE_SCROLL_FORWARD", key = "Scrollwheel Down" },
    [181] = { name = "INPUT_CELLPHONE_SCROLL_BACKWARD", key = "Scrollwheel Up" },
    [182] = { name = "INPUT_CELLPHONE_CAMERA_FOCUS_LOCK", key = "L" },
    [183] = { name = "INPUT_CELLPHONE_CAMERA_GRID", key = "G" },
    [184] = { name = "INPUT_CELLPHONE_CAMERA_SELFIE", key = "E" },
    [185] = { name = "INPUT_CELLPHONE_CAMERA_DOF", key = "F" },
    [186] = { name = "INPUT_CELLPHONE_CAMERA_EXPRESSION", key = "X" },
    [187] = { name = "INPUT_FRONTEND_DOWN", key = "Arrow Down" },
    [188] = { name = "INPUT_FRONTEND_UP", key = "Arrow Up" },
    [189] = { name = "INPUT_FRONTEND_LEFT", key = "Arrow Left" },
    [190] = { name = "INPUT_FRONTEND_RIGHT", key = "Arrow Right" },
    [191] = { name = "INPUT_FRONTEND_RDOWN", key = "Enter" },
    [192] = { name = "INPUT_FRONTEND_RUP", key = "Tab" },
    [193] = { name = "INPUT_FRONTEND_RLEFT", key = "(NONE)" },
    [194] = { name = "INPUT_FRONTEND_RRIGHT", key = "Backspace" },
    [195] = { name = "INPUT_FRONTEND_AXIS_X", key = "D" },
    [196] = { name = "INPUT_FRONTEND_AXIS_Y", key = "S" },
    [197] = { name = "INPUT_FRONTEND_RIGHT_AXIS_X", key = "]" },
    [198] = { name = "INPUT_FRONTEND_RIGHT_AXIS_Y", key = "Scrollwheel Down" },
    [199] = { name = "INPUT_FRONTEND_PAUSE", key = "P" },
    [200] = { name = "INPUT_FRONTEND_PAUSE_ALTERNATE", key = "ESC" },
    [201] = { name = "INPUT_FRONTEND_ACCEPT", key = "Enter / Numpad Enter" },
    [202] = { name = "INPUT_FRONTEND_CANCEL", key = "Backspace / ESC" },
    [203] = { name = "INPUT_FRONTEND_X", key = "Spacebar" },
    [204] = { name = "INPUT_FRONTEND_Y", key = "Tab" },
    [205] = { name = "INPUT_FRONTEND_LB", key = "Q" },
    [206] = { name = "INPUT_FRONTEND_RB", key = "E" },
    [207] = { name = "INPUT_FRONTEND_LT", key = "Page Down" },
    [208] = { name = "INPUT_FRONTEND_RT", key = "Page Up" },
    [209] = { name = "INPUT_FRONTEND_LS", key = "Left Shift" },
    [210] = { name = "INPUT_FRONTEND_RS", key = "Left Control" },
    [211] = { name = "INPUT_FRONTEND_LEADERBOARD", key = "Tab" },
    [212] = { name = "INPUT_FRONTEND_SOCIAL_CLUB", key = "Home" },
    [213] = { name = "INPUT_FRONTEND_SOCIAL_CLUB_SECONDARY", key = "Home" },
    [214] = { name = "INPUT_FRONTEND_DELETE", key = "Delete" },
    [215] = { name = "INPUT_FRONTEND_ENDSCREEN_ACCEPT", key = "Enter" },
    [216] = { name = "INPUT_FRONTEND_ENDSCREEN_EXPAND", key = "Spacebar" },
    [217] = { name = "INPUT_FRONTEND_SELECT", key = "Capslock" },
    [218] = { name = "INPUT_SCRIPT_LEFT_AXIS_X", key = "D" },
    [219] = { name = "INPUT_SCRIPT_LEFT_AXIS_Y", key = "S" },
    [220] = { name = "INPUT_SCRIPT_RIGHT_AXIS_X", key = "Mouse Right" },
    [221] = { name = "INPUT_SCRIPT_RIGHT_AXIS_Y", key = "Mouse Down" },
    [222] = { name = "INPUT_SCRIPT_RUP", key = "Right Mouse Button" },
    [223] = { name = "INPUT_SCRIPT_RDOWN", key = "Left Mouse Button" },
    [224] = { name = "INPUT_SCRIPT_RLEFT", key = "Left Ctrl" },
    [225] = { name = "INPUT_SCRIPT_RRIGHT", key = "Right Mouse Button" },
    [226] = { name = "INPUT_SCRIPT_LB", key = "(NONE)" },
    [227] = { name = "INPUT_SCRIPT_RB", key = "(NONE)" },
    [228] = { name = "INPUT_SCRIPT_LT", key = "(NONE)" },
    [229] = { name = "INPUT_SCRIPT_RT", key = "Left Mouse Button" },
    [230] = { name = "INPUT_SCRIPT_LS", key = "(NONE)" },
    [231] = { name = "INPUT_SCRIPT_RS", key = "(NONE)" },
    [232] = { name = "INPUT_SCRIPT_PAD_UP", key = "W" },
    [233] = { name = "INPUT_SCRIPT_PAD_DOWN", key = "S" },
    [234] = { name = "INPUT_SCRIPT_PAD_LEFT", key = "A" },
    [235] = { name = "INPUT_SCRIPT_PAD_RIGHT", key = "D" },
    [236] = { name = "INPUT_SCRIPT_SELECT", key = "V" },
    [237] = { name = "INPUT_CURSOR_ACCEPT", key = "Left Mouse Button" },
    [238] = { name = "INPUT_CURSOR_CANCEL", key = "Right Mouse Button" },
    [239] = { name = "INPUT_CURSOR_X", key = "(NONE)" },
    [240] = { name = "INPUT_CURSOR_Y", key = "(NONE)" },
    [241] = { name = "INPUT_CURSOR_SCROLL_UP", key = "Scrollwheel Up" },
    [242] = { name = "INPUT_CURSOR_SCROLL_DOWN", key = "Scrollwheel Down" },
    [243] = { name = "INPUT_ENTER_CHEAT_CODE", key = "~ / `" },
    [244] = { name = "INPUT_INTERACTION_MENU", key = "M" },
    [245] = { name = "INPUT_MP_TEXT_CHAT_ALL", key = "T" },
    [246] = { name = "INPUT_MP_TEXT_CHAT_TEAM", key = "Y" },
    [247] = { name = "INPUT_MP_TEXT_CHAT_FRIENDS", key = "(NONE)" },
    [248] = { name = "INPUT_MP_TEXT_CHAT_CREW", key = "(NONE)" },
    [249] = { name = "INPUT_PUSH_TO_TALK", key = "N" },
    [250] = { name = "INPUT_CREATOR_LS", key = "R" },
    [251] = { name = "INPUT_CREATOR_RS", key = "F" },
    [252] = { name = "INPUT_CREATOR_LT", key = "X" },
    [253] = { name = "INPUT_CREATOR_RT", key = "C" },
    [254] = { name = "INPUT_CREATOR_MENU_TOGGLE", key = "Left Shift" },
    [255] = { name = "INPUT_CREATOR_ACCEPT", key = "Spacebar" },
    [256] = { name = "INPUT_CREATOR_DELETE", key = "Delete" },
    [257] = { name = "INPUT_ATTACK2", key = "Left Mouse Button" },
    [258] = { name = "INPUT_RAPPEL_JUMP", key = "(NONE)" },
    [259] = { name = "INPUT_RAPPEL_LONG_JUMP", key = "(NONE)" },
    [260] = { name = "INPUT_RAPPEL_SMASH_WINDOW", key = "(NONE)" },
    [261] = { name = "INPUT_PREV_WEAPON", key = "Scrollwheel Up" },
    [262] = { name = "INPUT_NEXT_WEAPON", key = "Scrollwheel Down" },
    [263] = { name = "INPUT_MELEE_ATTACK1", key = "R" },
    [264] = { name = "INPUT_MELEE_ATTACK2", key = "Q" },
    [265] = { name = "INPUT_WHISTLE", key = "(NONE)" },
    [266] = { name = "INPUT_MOVE_LEFT", key = "D" },
    [267] = { name = "INPUT_MOVE_RIGHT", key = "D" },
    [268] = { name = "INPUT_MOVE_UP", key = "S" },
    [269] = { name = "INPUT_MOVE_DOWN", key = "S" },
    [270] = { name = "INPUT_LOOK_LEFT", key = "Mouse Right" },
    [271] = { name = "INPUT_LOOK_RIGHT", key = "Mouse Right" },
    [272] = { name = "INPUT_LOOK_UP", key = "Mouse Down" },
    [273] = { name = "INPUT_LOOK_DOWN", key = "Mouse Down" },
    [274] = { name = "INPUT_SNIPER_ZOOM_IN", key = "[" },
    [275] = { name = "INPUT_SNIPER_ZOOM_OUT", key = "[" },
    [276] = { name = "INPUT_SNIPER_ZOOM_IN_ALTERNATE", key = "[" },
    [277] = { name = "INPUT_SNIPER_ZOOM_OUT_ALTERNATE", key = "[" },
    [278] = { name = "INPUT_VEH_MOVE_LEFT", key = "D" },
    [279] = { name = "INPUT_VEH_MOVE_RIGHT", key = "D" },
    [280] = { name = "INPUT_VEH_MOVE_UP", key = "Left Ctrl" },
    [281] = { name = "INPUT_VEH_MOVE_DOWN", key = "Left Ctrl" },
    [282] = { name = "INPUT_VEH_GUN_LEFT", key = "Mouse Right" },
    [283] = { name = "INPUT_VEH_GUN_RIGHT", key = "Mouse Right" },
    [284] = { name = "INPUT_VEH_GUN_UP", key = "Mouse Right" },
    [285] = { name = "INPUT_VEH_GUN_DOWN", key = "Mouse Right" },
    [286] = { name = "INPUT_VEH_LOOK_LEFT", key = "Mouse Right" },
    [287] = { name = "INPUT_VEH_LOOK_RIGHT", key = "Mouse Right" },
    [288] = { name = "INPUT_REPLAY_START_STOP_RECORDING", key = "F1" },
    [289] = { name = "INPUT_REPLAY_START_STOP_RECORDING_SECONDARY", key = "F2" },
    [290] = { name = "INPUT_SCALED_LOOK_LR", key = "Mouse Right" },
    [291] = { name = "INPUT_SCALED_LOOK_UD", key = "Mouse Down" },
    [292] = { name = "INPUT_SCALED_LOOK_UP_ONLY", key = "(NONE)" },
    [293] = { name = "INPUT_SCALED_LOOK_DOWN_ONLY", key = "(NONE)" },
    [294] = { name = "INPUT_SCALED_LOOK_LEFT_ONLY", key = "(NONE)" },
    [295] = { name = "INPUT_SCALED_LOOK_RIGHT_ONLY", key = "(NONE)" },
    [296] = { name = "INPUT_REPLAY_MARKER_DELETE", key = "Delete" },
    [297] = { name = "INPUT_REPLAY_CLIP_DELETE", key = "Delete" },
    [298] = { name = "INPUT_REPLAY_PAUSE", key = "Spacebar" },
    [299] = { name = "INPUT_REPLAY_REWIND", key = "Arrow Down" },
    [300] = { name = "INPUT_REPLAY_FFWD", key = "Arrow Up" },
    [301] = { name = "INPUT_REPLAY_NEWMARKER", key = "M" },
    [302] = { name = "INPUT_REPLAY_RECORD", key = "S" },
    [303] = { name = "INPUT_REPLAY_SCREENSHOT", key = "U" },
    [304] = { name = "INPUT_REPLAY_HIDEHUD", key = "H" },
    [305] = { name = "INPUT_REPLAY_STARTPOINT", key = "B" },
    [306] = { name = "INPUT_REPLAY_ENDPOINT", key = "N" },
    [307] = { name = "INPUT_REPLAY_ADVANCE", key = "Arrow Right" },
    [308] = { name = "INPUT_REPLAY_BACK", key = "Arrow Left" },
    [309] = { name = "INPUT_REPLAY_TOOLS", key = "T" },
    [310] = { name = "INPUT_REPLAY_RESTART", key = "R" },
    [311] = { name = "INPUT_REPLAY_TOGGLE_TIMELINE", key = "Y" },
    [312] = { name = "INPUT_REPLAY_TOGGLE_RECORDING", key = "F1" },
    [313] = { name = "INPUT_REPLAY_TOGGLE_PLAYBACK", key = "F2" },
    [314] = { name = "INPUT_REPLAY_TOGGLE_SLOWMO", key = "F3" },
    [315] = { name = "INPUT_REPLAY_TOGGLE_FPS", key = "F4" },
    [316] = { name = "INPUT_REPLAY_TOGGLE_CAMERA", key = "F5" },
    [317] = { name = "INPUT_REPLAY_TOGGLE_MUSIC", key = "F6" },
    [318] = { name = "INPUT_REPLAY_TOGGLE_SFX", key = "F7" },
    [319] = { name = "INPUT_REPLAY_TOGGLE_VOICE", key = "F8" },
    [320] = { name = "INPUT_REPLAY_TOGGLE_VOICE_CHAT", key = "F9" },
    [321] = { name = "INPUT_REPLAY_TOGGLE_CHAT", key = "F10" },
    [322] = { name = "INPUT_REPLAY_TOGGLE_FPS_DISPLAY", key = "F11" },
    [323] = { name = "INPUT_REPLAY_TOGGLE_HUD", key = "F12" },
    [324] = { name = "INPUT_REPLAY_TOGGLE_CINEMATIC", key = "F13" },
    [325] = { name = "INPUT_REPLAY_TOGGLE_CINEMATIC_MODE", key = "F14" },
    [326] = { name = "INPUT_REPLAY_TOGGLE_CINEMATIC_CAMERA", key = "F15" },
    [327] = { name = "INPUT_REPLAY_TOGGLE_CINEMATIC_FPS", key = "F16" },
    [328] = { name = "INPUT_REPLAY_TOGGLE_CINEMATIC_SLOWMO", key = "F17" },
    [329] = { name = "INPUT_REPLAY_TOGGLE_CINEMATIC_MUSIC", key = "F18" },
    [330] = { name = "INPUT_REPLAY_TOGGLE_CINEMATIC_SFX", key = "F19" },
    [331] = { name = "INPUT_REPLAY_TOGGLE_CINEMATIC_VOICE", key = "F20" },
    [332] = { name = "INPUT_REPLAY_TOGGLE_CINEMATIC_VOICE_CHAT", key = "F21" },
    [333] = { name = "INPUT_REPLAY_TOGGLE_CINEMATIC_CHAT", key = "F22" },
    [334] = { name = "INPUT_REPLAY_TOGGLE_CINEMATIC_FPS_DISPLAY", key = "F23" },
    [335] = { name = "INPUT_REPLAY_TOGGLE_CINEMATIC_HUD", key = "F24" },
    [336] = { name = "INPUT_REPLAY_TOGGLE_CINEMATIC_MODE", key = "F25" },
    [337] = { name = "INPUT_REPLAY_TOGGLE_CINEMATIC_CAMERA", key = "F26" },
    [338] = { name = "INPUT_REPLAY_TOGGLE_CINEMATIC_FPS", key = "F27" },
    [339] = { name = "INPUT_REPLAY_TOGGLE_CINEMATIC_SLOWMO", key = "F28" },
    [340] = { name = "INPUT_REPLAY_TOGGLE_CINEMATIC_MUSIC", key = "F29" },
    [341] = { name = "INPUT_REPLAY_TOGGLE_CINEMATIC_SFX", key = "F30" },
    [342] = { name = "INPUT_REPLAY_TOGGLE_CINEMATIC_VOICE", key = "F31" },
    [343] = { name = "INPUT_REPLAY_TOGGLE_CINEMATIC_VOICE_CHAT", key = "F32" },
    [344] = { name = "INPUT_REPLAY_TOGGLE_CINEMATIC_CHAT", key = "F33" },
    [345] = { name = "INPUT_REPLAY_TOGGLE_CINEMATIC_FPS_DISPLAY", key = "F34" },
    [346] = { name = "INPUT_REPLAY_TOGGLE_CINEMATIC_HUD", key = "F35" },
    [347] = { name = "INPUT_REPLAY_TOGGLE_CINEMATIC_MODE", key = "F36" },
    [348] = { name = "INPUT_REPLAY_TOGGLE_CINEMATIC_CAMERA", key = "F37" },
    [349] = { name = "INPUT_REPLAY_TOGGLE_CINEMATIC_FPS", key = "F38" },
    [350] = { name = "INPUT_REPLAY_TOGGLE_CINEMATIC_SLOWMO", key = "F39" },
    [351] = { name = "INPUT_REPLAY_TOGGLE_CINEMATIC_MUSIC", key = "F40" },
    [352] = { name = "INPUT_REPLAY_TOGGLE_CINEMATIC_SFX", key = "F41" },
    [353] = { name = "INPUT_REPLAY_TOGGLE_CINEMATIC_VOICE", key = "F42" },
    [354] = { name = "INPUT_REPLAY_TOGGLE_CINEMATIC_VOICE_CHAT", key = "F43" },
    [355] = { name = "INPUT_REPLAY_TOGGLE_CINEMATIC_CHAT", key = "F44" },
    [356] = { name = "INPUT_REPLAY_TOGGLE_CINEMATIC_FPS_DISPLAY", key = "F45" },
    [357] = { name = "INPUT_REPLAY_TOGGLE_CINEMATIC_HUD", key = "F46" },
    [358] = { name = "INPUT_REPLAY_TOGGLE_CINEMATIC_MODE", key = "F47" },
    [359] = { name = "INPUT_REPLAY_TOGGLE_CINEMATIC_CAMERA", key = "F48" },
    [360] = { name = "INPUT_REPLAY_TOGGLE_CINEMATIC_FPS", key = "F49" },
}
local function GetKeyName(key)
    if KeyCodes[key] then
        return KeyCodes[key].key
    else
        return tostring(key)
    end
end
-------------------------------
-- 1. Keybind Update Mode --
-------------------------------
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustPressed(0, 56) and XorMenu.menus[XorMenu.currentMenu].visible then
            -- Hide the current menu if it exists
            if XorMenu.menus[XorMenu.currentMenu] then
                XorMenu.menus[XorMenu.currentMenu].visible = false
            end

            Citizen.CreateThread(function()
                local rectWidth, rectHeight = 0.2, 0.05  -- Adjust for visibility
                local rectX = 0.5
                local rectY = 0.468
                local textX = 0.5
                local textY = 0.5         
                local keySelected = false

                -- Get the currently selected menu item (if any)
                local currentMenu = XorMenu.menus[XorMenu.currentMenu]
                if not currentMenu then
                    return
                end
                local selectedIdx = currentMenu.selectedIndex or 1
                local currentItem = currentMenu.items[selectedIdx]
                if not currentItem then
                    return
                end

                -- Only allow binding for checkboxes and items with an action
                if currentItem.submenuName or (not currentItem.isCheckbox and not currentItem.action) then
                    XorVariables.Push(XORString("Cannot bind submenu items."), 240)
                    if XorMenu.menus[XorMenu.currentMenu] then
                        XorMenu.menus[XorMenu.currentMenu].visible = true
                    end
                    return
                end

                while not keySelected do
                    Citizen.Wait(0)

                    -- Draw a black rectangle as background for instruction
                    DrawRect(rectX, rectY, rectWidth, rectHeight, 0, 0, 0, 200)

                    -- Draw instruction text
                    SetTextFont(4)
                    SetTextScale(0.5, 0.5)
                    SetTextColour(255, 255, 255, 255)
                    SetTextCentre(true)
                    SetTextEntry(XORString("STRING"))
                    AddTextComponentString(XORString("Press any key to bind this menu item"))
                    DrawText(textX, textY - 0.05)

                    -- Capture key press (ignoring excluded keys)
                    for key = 1, 255 do
                        if IsControlJustPressed(0, key) and not excludedKeys[key] then
                            currentItem.keybind = key
                            keySelected = true
                            XorVariables.Push(XORString("Bound key = ") .. GetKeyName(key) .. XORString(" to item: ") .. XORString(currentItem.item), 240)
                            break
                        end
                    end
                end

                -- Show the menu again if it exists
                if XorMenu.menus[XorMenu.currentMenu] then
                    XorMenu.menus[XorMenu.currentMenu].visible = true
                end
            end)
        end
    end
end)

----------------------------------
-- 2. Global Keybind Activation --
----------------------------------
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        -- Loop through all menus and their items to detect keybind activation
        for menuId, menu in pairs(XorMenu.menus) do
            for index, item in ipairs(menu.items) do
                if item.keybind and not item.submenuName then
                    if IsControlJustPressed(0, item.keybind) then
                        XorVariables.Push(XORString("Selected: " .. item.item), 240)
                        -- Mimic Enter key activation logic:
                        if item.isCheckbox then
                            item.checked = not item.checked
                            if item.action then
                                item.action(item.checked)
                            end
                        elseif item.action then
                            item.action()
                        end
                    end
                end
            end
        end
    end
end)

------------------------------
-- 3. Constant Keybind Display --
------------------------------
local roundedRectTXD_bind = CreateRuntimeTxd("drawbind")
local roundedRectDui_bind = CreateDui("https://swagi-redacted.github.io/XorScroll/drawbinds.html", 400, 20)
local roundedRectHandle_bind = GetDuiHandle(roundedRectDui_bind)
local roundedRectTexture_bind = CreateRuntimeTextureFromDuiHandle(roundedRectTXD_bind, "bindheader", roundedRectHandle_bind)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if XorMenu.Bindindicator then
            local displayWidth = 0.15          -- 20% of screen width
            local lineHeight = 0.025          -- Height per keybind line
            local baseX = XorMenu.UI.bindsX
            local baseY = XorMenu.UI.bindsY

            local hasAnyKeybind = false

            -- First pass: check if any keybinds exist
            for _, menu in pairs(XorMenu.menus) do
                for _, item in ipairs(menu.items) do
                    if item.keybind then
                        hasAnyKeybind = true
                        break
                    end
                end
                if hasAnyKeybind then break end
            end

            if hasAnyKeybind then
                -- Only draw the header if we found at least one keybind
                local posY = baseY + (0.01 * lineHeight)
                DrawSprite("drawbind", "bindheader", baseX + displayWidth / 2, posY - lineHeight / 4 + 0.001, displayWidth, 0.01, 0.0, 150, 35, 150, 255)

                -- Now draw the keybind lines
                local line = 0
                for _, menu in pairs(XorMenu.menus) do
                    for _, item in ipairs(menu.items) do
                        if item.keybind then
                            local posY = baseY + (line * lineHeight)

                            -- Background
                            DrawRect(baseX + displayWidth / 2, posY + lineHeight / 2, displayWidth, lineHeight, 0, 0, 0, 150)

                            -- Line highlight
                            DrawRect(baseX + displayWidth / 2, posY - lineHeight / 20 + 0.001, displayWidth, 0.001, XorMenu.rgb.r, XorMenu.rgb.g, XorMenu.rgb.b, 255)

                            -- Text
                            SetTextFont(0)
                            SetTextScale(0.35, 0.35)
                            SetTextColour(255, 255, 255, 255)
                            SetTextCentre(true)
                            SetTextEntry("STRING")
                            AddTextComponentString(XORString(item.item) .. ": key = " .. GetKeyName(item.keybind))
                            DrawText(baseX + displayWidth / 2, posY + lineHeight / 2 - 0.015)

                            line = line + 1
                        end
                    end
                end
            end
        else
            Citizen.Wait(200)
        end
    end
end)

------------------------------
-- Spectator List Display --
------------------------------

local checkDistance = 60.0
local displayWidth = 0.15
local lineHeight = 0.025

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if XorMenu.SpectatorIndicator then
            local baseX = XorMenu.UI.spectatorX
            local baseY = XorMenu.UI.spectatorY

            local playerPed = PlayerPedId()
            local myCoords = GetEntityCoords(playerPed)
            local myPlayerId = PlayerId()
            local spectatingList = {}

            for _, playerId in ipairs(GetActivePlayers()) do
                if playerId ~= myPlayerId then
                    local targetPed = GetPlayerPed(playerId)
                    if targetPed and not IsEntityDead(targetPed) and NetworkIsPlayerActive(playerId) then
                        local targetCoords = GetEntityCoords(targetPed)
                        local camCoords = GetFinalRenderedCamCoord()
                        local distance = #(myCoords - targetCoords)
                        local isVisible = IsEntityVisible(targetPed)

                        -- Try detect spectating by comparing cam coord to your coords
                        local camOnYou = #(camCoords - myCoords) < 2.0

                        if camOnYou or (not isVisible and distance <= checkDistance) then
                            table.insert(spectatingList, {
                                name = GetPlayerName(playerId),
                                serverId = GetPlayerServerId(playerId)
                            })
                        end
                    end
                end
            end

            if #spectatingList > 0 then
                local posY = baseY + (0.01 * lineHeight)
                DrawSprite("drawbind", "bindheader", baseX + displayWidth / 2, posY - lineHeight / 4 + 0.001, displayWidth, 0.01, 0.0, 150, 35, 150, 255)

                local line = 0
                for _, spec in ipairs(spectatingList) do
                    local posY = baseY + (line * lineHeight)

                    DrawRect(baseX + displayWidth / 2, posY + lineHeight / 2, displayWidth, lineHeight, 0, 0, 0, 150)
                    DrawRect(baseX + displayWidth / 2, posY - lineHeight / 20 + 0.001, displayWidth, 0.001, XorMenu.rgb.r, XorMenu.rgb.g, XorMenu.rgb.b, 255)

                    SetTextFont(0)
                    SetTextScale(0.35, 0.35)
                    SetTextColour(255, 255, 255, 255)
                    SetTextCentre(true)
                    SetTextEntry("STRING")
                    AddTextComponentString(XORString(spec.name) .. " [ID: " .. spec.serverId .. "]")
                    DrawText(baseX + displayWidth / 2, posY + lineHeight / 2 - 0.015)

                    line = line + 1
                end
            end
        else
            Citizen.Wait(200)
        end
    end
end)

-------------------------------------------------------------------------------

function UnbindAllKeys()
    for _, menu in pairs(XorMenu.menus) do
        for _, item in ipairs(menu.items) do
            item.keybind = nil
        end
    end
    XorVariables.Push(XORString("All keybinds cleared."), 240)
end

-- Function to capture key press while respecting the excluded list
function captureKeyPress()
    local keyPressed = nil

    Citizen.CreateThread(function()
        while keyPressed == nil do
            Citizen.Wait(0)
            for key = 1, 255 do
                if IsControlJustPressed(0, key) and not excludedKeys[key] then  
                    keyPressed = key
                    XorVariables.Push(XORString(("Selected key code: ")) .. GetKeyName(keyPressed), 240) -- Always XorVariables.Push the keycode
                    break
                end
            end
        end
    end)

    while keyPressed == nil do
        Citizen.Wait(0)
    end

    return keyPressed
end

Citizen.SetTimeout(1, function()
    changeOpenKey()
end)

-- Function to change the open key
function changeOpenKey()
    -- Hide the current menu
    XorMenu.menus[XorMenu.currentMenu].visible = false

    Citizen.CreateThread(function()
        local rectWidth, rectHeight = 0.25, 0.05  -- Adjusted for better visibility
        local rectX, rectY = 0.5, 0.468  -- Center of screen
        local textX, textY = 0.5, 0.5  -- Center of screen
        local keySelected = false

        while not keySelected do
            Citizen.Wait(0)

            Citizen.InvokeNative(0x61BB1D9B3A95D802, GFX_ORDER.AFTER_HUD)
            -- Draw a black rectangle in the middle of the screen
            DrawRect(rectX, rectY, rectWidth, rectHeight, 0, 0, 0, 200) 

            Citizen.InvokeNative(0x61BB1D9B3A95D802, GFX_ORDER.AFTER_HUD_HIGH)
            -- Draw instruction text
            SetTextFont(4)
            SetTextScale(0.5, 0.5)
            SetTextColour(255, 255, 255, 255)
            SetTextCentre(true)
            SetTextEntry(XORString("STRING"))
            AddTextComponentString(XORString("Press any key to update open key: Made by Blupillcosby"))
            DrawText(textX, textY - 0.05)

            -- Capture the key press within the loop
            for key = 1, 255 do
                if IsControlJustPressed(0, key) and not excludedKeys[key] then
                    XorMenu.openkey = key
                    keySelected = true
                    XorVariables.Push(XORString(("Selected key code: ")) .. GetKeyName(key), 240)
                    break
                end
            end
        end

        -- Show the menu again after selecting a key
        XorMenu.menus[XorMenu.currentMenu].visible = true
    end)
end
-----------------------------------
-- past the nonsense
-----------------------------------

local holdingEntity = false
local holdingCarEntity = false
local holdingPed = false
local heldEntity = nil
local entityType = nil

local function ROtoThrow(rotation)
    local adjustedRotation = vec3((math.pi / 180) * rotation.x, (math.pi / 180) * rotation.y, (math.pi / 180) * rotation.z)
    local direction = vec3(-math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), math.sin(adjustedRotation.x))
    return direction
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if holdingEntity and heldEntity then
            local playerPed = PlayerPedId()
            local headPos = GetPedBoneCoords(playerPed, 0x796e, 0.0, 0.0, 0.0)
            if holdingCarEntity and not IsEntityPlayingAnim(playerPed, 'anim@mp_rollarcoaster', 'hands_up_idle_a_player_one', 3) then
                RequestAnimDict('anim@mp_rollarcoaster')
                while not HasAnimDictLoaded('anim@mp_rollarcoaster') do
                    Citizen.Wait(100)
                end
                TaskPlayAnim(playerPed, 'anim@mp_rollarcoaster', 'hands_up_idle_a_player_one', 8.0, -8.0, -1, 50, 0, false, false, false)
            elseif (holdingPed or not holdingCarEntity) and not IsEntityPlayingAnim(playerPed, 'anim@heists@box_carry@', 'idle', 3) then
                RequestAnimDict('anim@heists@box_carry@')
                while not HasAnimDictLoaded('anim@heists@box_carry@') do
                    Citizen.Wait(100)
                end
                TaskPlayAnim(playerPed, 'anim@heists@box_carry@', 'idle', 8.0, -8.0, -1, 50, 0, false, false, false)
            end

            if not IsEntityAttached(heldEntity) then
                holdingEntity = false
                holdingCarEntity = false
                holdingPed = false
                heldEntity = nil
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if XorMenu.throwing then
            local playerPed = PlayerPedId()
            local camPos = GetGameplayCamCoord()
            local camRot = GetGameplayCamRot(2)
            local direction = ROtoThrow(camRot)
            local dest = vec3(camPos.x + direction.x * 10.0, camPos.y + direction.y * 10.0, camPos.z + direction.z * 10.0)

            local rayHandle = StartShapeTestRay(camPos.x, camPos.y, camPos.z, dest.x, dest.y, dest.z, -1, playerPed, 0)
            local _, hit, _, _, entityHit = GetShapeTestResult(rayHandle)
            local validTarget = false

            if hit == 1 then
                entityType = GetEntityType(entityHit)
                if entityType == 3 or entityType == 2 or entityType == 1 then
                    validTarget = true
                    if entityType == 2 then
                        if NetworkHasControlOfEntity(entityHit) then
                        else
                            NetworkRequestControlOfEntity(entityHit)
                        end
                    end
                end
            end

            DisableControlAction(0, 24)
            if IsDisabledControlJustPressed(0, 24) then  -- Lmb key
                if validTarget then
                    if not holdingEntity and entityHit and (entityType == 3 or entityType == 2 or entityType == 1) then
                        if entityType == 3 then
                            local entityModel = GetEntityModel(entityHit)
                            DeleteEntity(entityHit)
                            RequestModel(entityModel)
                            while not HasModelLoaded(entityModel) do
                                Citizen.Wait(100)
                            end

                            local clonedEntity = CreateObject(entityModel, camPos.x, camPos.y, camPos.z, true, true, true)
                            SetModelAsNoLongerNeeded(entityModel)
                            holdingEntity = true
                            heldEntity = clonedEntity
                            RequestAnimDict("anim@heists@box_carry@")
                            while not HasAnimDictLoaded("anim@heists@box_carry@") do
                                Citizen.Wait(100)
                            end
                            TaskPlayAnim(playerPed, "anim@heists@box_carry@", "idle", 8.0, -8.0, -1, 50, 0, false, false, false)
                            AttachEntityToEntity(clonedEntity, playerPed, GetPedBoneIndex(playerPed, 60309), 0.0, 0.2, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
                        elseif entityType == 2 then
                            holdingEntity = true
                            holdingCarEntity = true
                            heldEntity = entityHit
                            RequestAnimDict('anim@mp_rollarcoaster')
                            while not HasAnimDictLoaded('anim@mp_rollarcoaster') do
                                Citizen.Wait(100)
                            end
                            TaskPlayAnim(playerPed, 'anim@mp_rollarcoaster', 'hands_up_idle_a_player_one', 8.0, -8.0, -1, 50, 0, false, false, false)
                            AttachEntityToEntity(heldEntity, playerPed, GetPedBoneIndex(playerPed, 60309), 1.0, 0.5, 0.0, 0.0, 0.0, 0.0, true, true, false, false, 1, true)
                        elseif entityType == 1 then
                            holdingEntity = true
                            holdingPed = true
                            heldEntity = entityHit
                            RequestAnimDict('anim@heists@box_carry@')
                            while not HasAnimDictLoaded('anim@heists@box_carry@') do
                                Citizen.Wait(100)
                            end
                            TaskPlayAnim(playerPed, 'anim@heists@box_carry@', 'idle', 8.0, -8.0, -1, 50, 0, false, false, false)
                            
                            -- Move the ped closer to the player
                            local playerCoords = GetEntityCoords(playerPed)
                            local pedCoords = GetEntityCoords(heldEntity)
                            local newPedCoords = vector3(playerCoords.x, playerCoords.y, playerCoords.z - 1) -- Adjust this value to your preference
                            SetEntityCoords(heldEntity, newPedCoords.x, newPedCoords.y, newPedCoords.z, false, false, false, false)

                            -- Clear the ped's tasks
                            ClearPedTasksImmediately(heldEntity)

                            -- Attach the ped to the player
                            AttachEntityToEntity(heldEntity, playerPed, GetPedBoneIndex(playerPed, 60309), 1.0, 0.5, 0.0, 0.0, 0.0, 0.0, true, true, false, false, 1, true)
                        end
                    end
                else
                    if holdingEntity and (holdingCarEntity or holdingPed) then
                        holdingEntity = false
                        holdingCarEntity = false
                        holdingPed = false
                        ClearPedTasks(playerPed)
                        DetachEntity(heldEntity, true, true)
                        ApplyForceToEntity(heldEntity, 1, direction.x * 800, direction.y * 800, direction.z * 800, 0.0, 0.0, 0.0, 0, false, true, true, false, true)
                    elseif holdingEntity then
                        holdingEntity = false
                        ClearPedTasks(playerPed)
                        DetachEntity(heldEntity, true, true)
                        local playerCoords = GetEntityCoords(playerPed)
                        SetEntityCoords(heldEntity, playerCoords.x, playerCoords.y, playerCoords.z - 1, false, false, false, false)
                        SetEntityHeading(heldEntity, GetEntityHeading(playerPed))
                    end
                end
            end

            -- Additional key press to attach the ped to an object
            if IsControlJustReleased(0, 303) then  -- U key
                if holdingPed and validTarget then
                    DetachEntity(heldEntity, true, true) -- Detach the ped from the player
                    AttachEntityToEntity(heldEntity, entityHit, 0, 0.0, 0.0, 1.5, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
                    FreezeEntityPosition(heldEntity, true) -- Freeze the ped's position
                    TaskStartScenarioInPlace(heldEntity, "WORLD_HUMAN_PARTYING", 0, true) -- Make the ped dance
                    holdingPed = false  -- Reset holdingPed flag
                    heldEntity = nil    -- Clear heldEntity
                end
            end
        end
    end
end)

function UnloadTextureDict(textureDict)
    -- Ensure the texture dictionary is loaded before unloading
    if HasStreamedTextureDictLoaded(textureDict) then
        SetStreamedTextureDictAsNoLongerNeeded(textureDict)
        XorVariables.Push(XORString(("Texture dictionary '")) .. textureDict .. (XORString"' unloaded successfully."), 240)
    else
        XorVariables.Push(XORString(("Texture dictionary '")) .. textureDict .. (XORString"' is not loaded."), 240)
    end
end

function Uninject()
    -- Unload the textures associated with the XorMenu header
    if _G.HeaderObject then
        local headerTextureDict = XORString("XorMenu")
        UnloadTextureDict(headerTextureDict)  -- Unloads the header texture dictionary
        _G.HeaderObject = nil  -- Clean up the HeaderObject
    end
    
    -- Unload the scroll indicator background texture
    local scrollIndicatorBgDict = XORString("scrollindicator_bg")
    UnloadTextureDict(scrollIndicatorBgDict)  -- Unloads the scroll indicator background texture dictionary
    
    -- Unload the scroll indicator handle texture
    local scrollIndicatorHandleDict = XORString("scrollindicator_handle")
    UnloadTextureDict(scrollIndicatorHandleDict)  -- Unloads the scroll indicator handle texture dictionary
    XorMenu.menus[XorMenu.currentMenu].visible = false

    -- Clean up runtime textures
    if RuntimeTXD then
        SetStreamedTextureDictAsNoLongerNeeded(XORString("XorMenu"))
        SetStreamedTextureDictAsNoLongerNeeded(XORString("scrollindicator_bg"))
        SetStreamedTextureDictAsNoLongerNeeded(XORString("scrollindicator_handle"))
        SetStreamedTextureDictAsNoLongerNeeded(XORString("XorMenuHeader"))
        SetStreamedTextureDictAsNoLongerNeeded(XORString("background"))
        SetStreamedTextureDictAsNoLongerNeeded(XORString("indicator"))
        DestroyDui(GetDuiHandle(roundedRectDui_menu))
        DestroyDui(GetDuiHandle(roundedRectDui_notis))
        DestroyDui(GetDuiHandle(roundedRectDui_notis2))
        DestroyDui(GetDuiHandle(roundedRectDui_handle))
        DestroyDui(GetDuiHandle(roundedRectDui_bg))
        DestroyDui(GetDuiHandle(HeaderObject))
        RuntimeTXD = nil
    end
    
    -- Stop all active threads (if any) associated with the menu
    for _, thread in pairs(_G.menuThreads or {}) do
        if thread and Citizen.IsThreadRunning(thread) then
            Citizen.KillThread(thread)
        end
    end
    
    _G.XorMenu.Uninjected = true
    -- Clear any menu-specific globals or resources
    _G.menuThreads = nil
    _G.scrollIndicator = nil  -- Clean up any scroll indicator variable (if used)

    -- Clean up any other menu resources or variables if necessary
    -- Example: if you have a custom function or object associated with XorMenu, make sure to clear them here

    XorVariables.Push(XORString(("All texture dictionaries unloaded, XorMenu un-injected, and Lua code cleaned up successfully.")), 240)
end

--------------------------
-- Self Thread
--------------------------

-- Utility function to get the player's current position.
function getPosition()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    return coords.x, coords.y, coords.z
end

-- Utility function to get the camera direction.
function getCamDirection()
    local camRot = GetGameplayCamRot(2)
    local rotZ = math.rad(camRot.z)
    local rotX = math.rad(camRot.x)
    local dx = -math.sin(rotZ) * math.abs(math.cos(rotX))
    local dy = math.cos(rotZ) * math.abs(math.cos(rotX))
    local dz = math.sin(rotX)
    return dx, dy, dz
end

function SetArmorToFull(ped)
    local ped = PlayerPedId()
    Citizen.InvokeNative(0xCEA04D83135264CC, ped, 100)
end

function SetEntityFullHealth(ped)
local ped = PlayerPedId()
local maxHealth = Citizen.InvokeNative(0x4700A416E8324EF3, ped)
    Citizen.InvokeNative(0x6B76DC1F3AE6E6A3, ped, maxHealth)
end

local UNARMED_HASH = -1569615261
local ONE_PUNCH_FORCE = 60.0
local damageBoosted = false

Citizen.CreateThread(function()
    while true do
        if XorMenu.OnePunchMan then
            -- Apply damage boost once
            if not damageBoosted then
                Citizen.InvokeNative(0x4757F00BC6323CFE, UNARMED_HASH, 9999.0)
                damageBoosted = true
            end

            local playerPed = PlayerPedId()
            local weapon = GetSelectedPedWeapon(playerPed)
        else
            if damageBoosted then
                -- Reset damage when feature is disabled
                Citizen.InvokeNative(0x4757F00BC6323CFE, UNARMED_HASH, 1.0)
                damageBoosted = false
            end
        end

        Citizen.Wait(0)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local ped = PlayerPedId()

        if XorMenu.Noclip then

            Citizen.InvokeNative(0xF1CA12B18AEF5298, ped, true)
            Citizen.InvokeNative(0xEA1C610A04DB6BBB, ped, false, 0)
            Citizen.InvokeNative(0x241E289B5C059EDC, ped) -- ForcelocalPlayervisible
            local noclip_speed = XorMenu.Noclipspeed or 1.0
            local x, y, z = getPosition()
            local dx, dy, dz = getCamDirection()
            local speed = noclip_speed

            -- Reset velocity
            Citizen.InvokeNative(0x1C99BB7B6E96D16F, ped, 0.0, 0.0, 0.0)

            -- Disable all relevant movement keys including LMB
            DisableControlAction(0, 32) -- W
            DisableControlAction(0, 268) -- Arrow Up
            DisableControlAction(0, 31) -- S
            DisableControlAction(0, 269) -- Arrow Down
            DisableControlAction(0, 33) -- S
            DisableControlAction(0, 266) -- Arrow Down
            DisableControlAction(0, 34) -- A
            DisableControlAction(0, 30) -- A
            DisableControlAction(0, 267) -- Arrow Left
            DisableControlAction(0, 35) -- D
            DisableControlAction(0, 44) -- Q
            DisableControlAction(0, 22) -- Space
            DisableControlAction(0, 21) -- Shift
            DisableControlAction(0, 24) -- LMB (SHOOT)

            -- Optional: Block LMB click event while freecam is active
            if IsDisabledControlJustPressed(0, 24) then
                -- print("LMB disabled in freecam")
                -- Optional: Do something here while in freecam
            end

            -- Speed modifiers
            if IsDisabledControlPressed(0, 21) then speed = speed + 3.0 end
            if IsDisabledControlPressed(0, 19) then speed = speed - 0.5 end

            -- Movement
            if IsDisabledControlPressed(0, 32) then
                x = x + speed * dx
                y = y + speed * dy
                z = z + speed * dz
            end
            if IsDisabledControlPressed(0, 269) then
                x = x - speed * dx
                y = y - speed * dy
                z = z - speed * dz
            end
            local rightX = dy
            local rightY = -dx
            if IsDisabledControlPressed(0, 34) then
                x = x - speed * rightX
                y = y - speed * rightY
            end
            if IsDisabledControlPressed(0, 35) then
                x = x + speed * rightX
                y = y + speed * rightY
            end
            if IsDisabledControlPressed(0, 44) then z = z + speed end
            if IsDisabledControlPressed(0, 22) then z = z - speed end

            -- Apply movement
            Citizen.InvokeNative(0x239A3351AC1DA385, ped, x, y, z, true, true, true)
        else
            Citizen.InvokeNative(0xF1CA12B18AEF5298, ped, false)
            Citizen.InvokeNative(0xEA1C610A04DB6BBB, ped, true, 0)
        end
    end
end)

local function DisableCollisionForNearbyEntities()
    local localPlayerPed = PlayerPedId() 
    local localPlayerCoords = GetEntityCoords(localPlayerPed)
    local players = GetActivePlayers()

    -- Process other players
    for _, playerId in ipairs(players) do
        if playerId ~= PlayerId() then
            local otherPed = GetPlayerPed(playerId)
            local otherCoords = GetEntityCoords(otherPed)
            if Vdist(localPlayerCoords, otherCoords) <= 10.0 then
                if IsPedInAnyVehicle(otherPed, false) then
                    -- Other player is in a vehicle. Get the vehicle.
                    local otherVeh = GetVehiclePedIsIn(otherPed, false)
                    if otherVeh and otherVeh ~= 0 then
                        -- If the local player is in a vehicle, disable collision between vehicles;
                        -- otherwise, disable collision between the local player and the vehicle.
                        if IsPedInAnyVehicle(localPlayerPed, false) then
                            local localVeh = GetVehiclePedIsIn(localPlayerPed, false)
                            if localVeh and localVeh ~= 0 then
                                Citizen.InvokeNative(0xA53ED5520C07654A, localVeh, otherVeh, false)
                            end
                        else
                            Citizen.InvokeNative(0xA53ED5520C07654A, localPlayerPed, otherVeh, false)
                        end
                    end
                else
                    -- Other player is on foot. Disable collision between peds.
                    Citizen.InvokeNative(0xA53ED5520C07654A, localPlayerPed, otherPed, false)
                end
            end
        end
    end

    -- Additionally, if the local player is in a vehicle, handle vehicles nearby separately
    if IsPedInAnyVehicle(localPlayerPed, false) then
        local localVeh = GetVehiclePedIsIn(localPlayerPed, false)
        if localVeh and localVeh ~= 0 then
            for _, playerId in ipairs(players) do
                if playerId ~= PlayerId() then
                    local otherPed = GetPlayerPed(playerId)
                    if IsPedInAnyVehicle(otherPed, false) then
                        local otherVeh = GetVehiclePedIsIn(otherPed, false)
                        if otherVeh and otherVeh ~= 0 then
                            local vehCoords = GetEntityCoords(otherVeh)
                            if Vdist(GetEntityCoords(localVeh), vehCoords) <= 10.0 then
                                Citizen.InvokeNative(0xA53ED5520C07654A, localVeh, otherVeh, false)
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Example usage: Run continuously in a thread if XorMenu.Nocollision is active
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if XorMenu.Nocollision then
            DisableCollisionForNearbyEntities()
        end
    end
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        if XorMenu.godmodeActive then
            
            -- Core invincibility
            Citizen.InvokeNative(0x239528EACDC3E7DE, playerPed, true)  -- SET_PLAYER_INVINCIBLE
            Citizen.InvokeNative(0x3882114BDE571AD4, playerPed, true)  -- SET_ENTITY_INVINCIBLE
            Citizen.InvokeNative(0x1760FFA8AB074D66, playerPed, false)  -- SET_ENTITY_CAN_BE_DAMAGED
            
            -- Additional protections
            Citizen.InvokeNative(0xFAEE099C6F890BB8, playerPed, true, true, true, true, true, true, true, 0, true)  -- SET_ENTITY_PROOFS
            Citizen.InvokeNative(0x733C87D4CE22BEA2, playerPed)  -- SET_PED_RESET_FLAG
            Citizen.InvokeNative(0x8FE22675A5A45817, playerPed)  -- CLEAR_PED_BLOOD_DAMAGE
            
            -- Prevent ragdoll and other effects
            Citizen.InvokeNative(0xB128377056A54E2A, playerPed, false)  -- SET_PED_CAN_RAGDOLL
            Citizen.InvokeNative(0x7A6535691B477C48, playerPed, false)  -- SET_PED_CAN_BE_KNOCKED_OFF_VEHICLE
            
            -- Health management

        else
            
            -- Disable all protections
            Citizen.InvokeNative(0x239528EACDC3E7DE, playerPed, false)
            Citizen.InvokeNative(0x3882114BDE571AD4, playerPed, false)
            Citizen.InvokeNative(0x1760FFA8AB074D66, playerPed, true)
            Citizen.InvokeNative(0xFAEE099C6F890BB8, playerPed, false, false, false, false, false, false, false, 0, false)
            Citizen.InvokeNative(0x8FE22675A5A45817, playerPed)  -- CLEAR_PED_LAST_DAMAGE_BONE
            
            -- Reset states
            Citizen.InvokeNative(0xB128377056A54E2A, playerPed, true)
            Citizen.InvokeNative(0x7A6535691B477C48, playerPed, true)
            Citizen.InvokeNative(0x6B7A646C242A7059, playerPed, true)
        end
    end
end)

function RandomizeClothing()
    local playerPed = PlayerPedId() -- Get local player ped

    if DoesEntityExist(playerPed) then
        -- Randomize main clothing components (0-11)
        for component = 0, 11 do
            local maxDrawable = Citizen.InvokeNative(0x27561561732A7842, playerPed, component, Citizen.ResultAsInteger())
            if maxDrawable and maxDrawable > 0 then
                local drawable = math.random(0, maxDrawable - 1)
                local maxTexture = Citizen.InvokeNative(0x8F7156A3142A6BAD, playerPed, component, drawable, Citizen.ResultAsInteger())
                local texture = (maxTexture and maxTexture > 0) and math.random(0, maxTexture - 1) or 0
                Citizen.InvokeNative(0x262B14F48D29DE80, playerPed, component, drawable, texture, 0)
            end
        end

        -- Randomize accessories (hats, glasses, watches, etc.)
        for prop = 0, 7 do
            local maxPropDrawable = Citizen.InvokeNative(0x5FAF9754E789FB47, playerPed, prop, Citizen.ResultAsInteger())
            if maxPropDrawable and maxPropDrawable > 0 then
                local propDrawable = math.random(0, maxPropDrawable - 1)
                local maxPropTexture = Citizen.InvokeNative(0xA6E7F1CEB523E171, playerPed, prop, propDrawable, Citizen.ResultAsInteger())
                local propTexture = (maxPropTexture and maxPropTexture > 0) and math.random(0, maxPropTexture - 1) or 0
                Citizen.InvokeNative(0x93376B65A266EB5F, playerPed, prop, propDrawable, propTexture, true)
            else
                Citizen.InvokeNative(0x0943E5B8E078E76E, playerPed, prop) -- Remove prop if there's no variation
            end
        end
    end
end

--------------------------
-- Weapon Thread
--------------------------

function SpawnWeaponFromInput()
    -- Display input box
    AddTextEntry(XORString("FMMC_KEY_TIP1"), XORString("Enter The Weapon Hash:"))
    DisplayOnscreenKeyboard(1, XORString("FMMC_KEY_TIP1"), "", "", "", "", "", 240)

    -- Wait for user input
    while UpdateOnscreenKeyboard() == 0 do
        Citizen.Wait(0)
    end

    -- Get the entered text
    local result = GetOnscreenKeyboardResult()
    if result then
        local playerPed = PlayerPedId()
        local weaponHash = GetHashKey(result)

        -- Check if the weapon hash is valid
        if weaponHash ~= 0 then
            -- Give the weapon to the player
            local success = Citizen.InvokeNative(0xBF0FD6E56C964FCB, playerPed, weaponHash, 9999, false, true)

            if success then
                XorVariables.Push(XORString(("~g~ Weapon Spawned: ")) .. result, 240)
            else
                XorVariables.Push(XORString(("~r~ Failed to Spawn Weapon: ")) .. result, 240)
            end
        else
            XorVariables.Push(XORString(("~r~ Invalid Weapon Hash Entered")), 240)
        end
    else
        XorVariables.Push(XORString(("~r~ No Weapon Entered Or Failed To Spawn")), 240)
    end
end

function SpoofWeaponInHand()
    AddTextEntry(XORString("FMMC_KEY_TIP1"), XORString("Enter The Weapon Hash:"))
    DisplayOnscreenKeyboard(1, XORString("FMMC_KEY_TIP1"), "", "", "", "", "", 240)

    while UpdateOnscreenKeyboard() == 0 do
        Citizen.Wait(0)
    end

    local result = GetOnscreenKeyboardResult()
    if result and result ~= "" then
        local playerPed = PlayerPedId()
        local weaponHash = GetHashKey(result)

        Citizen.CreateThread(function()
            -- Remove all currently held weapons to clear logs
            RemoveAllPedWeapons(playerPed, true)

            -- Wait to prevent instant detection
            Citizen.Wait(math.random(250, 600))

            -- Apply the weapon model as if it's being held
            SetCurrentPedWeapon(playerPed, weaponHash, true)

            XorVariables.Push(XORString(("Weapon Spoofed in Hand: ")) .. result, 240)
        end)
    end
end

--------------------------
-- Destroyer Thread
--------------------------


function RapeServer()
    local players = GetActivePlayers()
    local exclude = PlayerPedId() -- Exclude self from effects

    if XorMenu.Safe then
        XorVariables.Push(XORString("~r~Safe Mode Is On - Rape Blocked"), 240)
        return
    end

    for _, player in ipairs(players) and not XorMenu.Safe do
        local playerPed = GetPlayerPed(player)
        if playerPed ~= exclude then
            Citizen.InvokeNative(0x428CA6DBD1094446, playerPed, true)
            XorMenu.KillPlayer(playerPed)
        end
    end
end

-- Helper functions to retrieve each obfuscated prop hash.
local function GetPropHash1()
    -- The first prop hash is -1585415771 (or unsigned 2709551525)
    local encoded = XORString("-1585415771")
    return tonumber(encoded)
end

local function GetPropHash2()
    -- The second prop hash is 1124049486
    local encoded = XORString("1124049486")
    return tonumber(encoded)
end

local function GetPropHash3()
    -- The third prop hash is 1125864094
    local encoded = XORString("1125864094")
    return tonumber(encoded)
end

-- The nuke function: Spams the three props randomly across the map.
function startNuke()
    local playerPed = PlayerPedId()
    if not playerPed or playerPed == 0 then
        XorVariables.Push(XORString(("Error: Invalid player ped.")), 240)
        return
    end

    if XorMenu.Safe then
        XorVariables.Push(XORString("~r~Safe Mode Is On - Nuke Blocked"), 240)
        return
    end

    Citizen.CreateThread(function()
        while XorMenu.isNukeActive and not XorMenu.Safe do
            Citizen.Wait(1)  -- Small delay between spawns

            local playerCoords = GetEntityCoords(playerPed)
            -- Choose one of the three prop hashes at random.
            local propHashes = { GetPropHash1(), GetPropHash2(), GetPropHash3() }  -- Hardcoded prop hashes
            local randomPropHash = propHashes[math.random(1, #propHashes)]

            -- Request and load the model.
            RequestModel(randomPropHash)
            while not HasModelLoaded(randomPropHash) do
                Citizen.Wait(5)
            end

            -- Compute a random spawn offset with large values to cover the entire map.
            local spawnX = playerCoords.x + math.random(-5000, 5000)  -- Large random offset
            local spawnY = playerCoords.y + math.random(-5000, 5000)  -- Large random offset 
            local spawnZ = playerCoords.z + math.random(50, 200)  -- Higher altitude for a more dramatic effect
            local heading = math.random(0, 360)  -- Randomized heading for variation
            local isNetwork = true
            local netMissionEntity = false

            -- Create the object using the native 0x509D5878EB39E842 (CREATE_OBJECT)
            local spawnedProp = Citizen.InvokeNative(0x509D5878EB39E842, randomPropHash, spawnX, spawnY, spawnZ, heading, isNetwork, netMissionEntity, netMissionEntity, false)

            SetModelAsNoLongerNeeded(randomPropHash)
        end
    end)
end

--------------------------
-- Player Thread
--------------------------

function XorMenu.stealclothes(playerId)
    local targetPed = GetPlayerPed(playerId)
    local playerPed = PlayerPedId() -- Local player

    if DoesEntityExist(targetPed) then
        -- Copy main clothing components (0-11)
        for component = 0, 11 do
            local drawable = Citizen.InvokeNative(0x67F3780DD425D4FC, targetPed, component)
            local texture = Citizen.InvokeNative(0x04A355E041E004E6, targetPed, component)
            local palette = Citizen.InvokeNative(0xE3DD5F2A84B42281, targetPed, component)
            Citizen.InvokeNative(0x262B14F48D29DE80, playerPed, component, drawable, texture, palette)
        end

        -- Copy props (hats, glasses, etc.)
        for prop = 0, 7 do
            local propIndex = Citizen.InvokeNative(0x898CC20EA75BACD8, targetPed, prop)
            local propTexture = Citizen.InvokeNative(0xE131A28626F81AB2, targetPed, prop)

            if propIndex ~= -1 then
                Citizen.InvokeNative(0x93376B65A266EB5F, playerPed, prop, propIndex, propTexture, true)
            else
                Citizen.InvokeNative(0x0943E5B8E078E76E, playerPed, prop) -- Remove prop if target has none
            end
        end
    else
        XorVariables.Push(XORString("Invalid player ID or player not found."), 240)
    end
end

function XorMenu.revivePlayer(playerId)
    local targetPed = GetPlayerPed(playerId)

    if not DoesEntityExist(targetPed) then
        XorVariables.Push(XORString("Invalid player."), 240)
        return
    end

    -- Health check
    local health = GetEntityHealth(targetPed)
    local maxhealth = GetEntityMaxHealth(playerId)

    -- Local player logic (can fully resurrect with network native)
    if playerId == PlayerId() then
        if IsEntityDead(targetPed) or health <= 0 then
            local coords = GetEntityCoords(targetPed)
            local heading = GetEntityHeading(targetPed)
            Citizen.InvokeNative(0x239528EACDC3E7DE, coords.x, coords.y, coords.z, heading, true, false)
            Citizen.InvokeNative(0x239528EACDC3E7DE, PlayerId(), false)
            ClearPedTasksImmediately(targetPed)
            XorVariables.Push(XORString("You have been revived."), 160)
        elseif health < 100 then
            -- Injured but not dead, try healing
            Citizen.InvokeNative(0x8D8ACD8388CD99CE, targetPed) -- ReviveInjuredPed
            Citizen.InvokeNative(0x6B76DC1F3AE6E6A3, targetPed, maxhealth)
            ClearPedTasksImmediately(targetPed)
            XorVariables.Push(XORString("You were healed from injured state."), 160)
        else
            XorVariables.Push(XORString("Already alive and healthy."), 160)
        end
    else
        -- Remote player logic (limited to ReviveInjuredPed only)
        if not IsEntityDead(targetPed) and health < 100 then
            Citizen.InvokeNative(0x8D8ACD8388CD99CE, targetPed) -- ReviveInjuredPed
            Citizen.InvokeNative(0x6B76DC1F3AE6E6A3, targetPed, maxhealth)
            ClearPedTasksImmediately(targetPed)
            XorVariables.Push(XORString("Target was healed from injured state."), 160)
        else
            XorVariables.Push(XORString("Cannot revive dead remote players."), 240)
        end
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        for _, playerId in ipairs(GetActivePlayers()) do
            local ped = GetPlayerPed(playerId)
            if XorMenu.godmodeforbros[playerId] then
                -- Activate Godmode (Health only)
                Citizen.InvokeNative(0x239528EACDC3E7DE, ped, true)  -- Makes player invincible

                -- Disable all types of damage
                Citizen.InvokeNative(0xFAEE099C6F890BB8, ped, true, true, true, true, true, true, true, true)

            else
                -- Deactivate Godmode
                Citizen.InvokeNative(0x239528EACDC3E7DE, ped, false)  -- Allow damage again
                Citizen.InvokeNative(0xFAEE099C6F890BB8, ped, false, false, false, false, false, false, false, false)
            end
        end
    end
end)

local cachedHandlingValues = {}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        for _, playerId in ipairs(GetActivePlayers()) do
            if XorMenu.DriftOthers[playerId] then
                local ped = GetPlayerPed(playerId)
                if DoesEntityExist(ped) and IsPedInAnyVehicle(ped, false) then
                    local veh = GetVehiclePedIsIn(ped, false)

                    if not cachedHandlingValues[veh] then
                        cachedHandlingValues[veh] = {
                            fTractionCurveMin = GetVehicleHandlingFloat(veh, "CHandlingData", "fTractionCurveMin"),
                            fTractionCurveMax = GetVehicleHandlingFloat(veh, "CHandlingData", "fTractionCurveMax")
                        }
                    end

                    local original = cachedHandlingValues[veh]

                    if IsControlPressed(0, 21) then
                        -- This native sometimes doesn't apply — fallback method below
                        Citizen.InvokeNative(0x90D3A0D9, veh, true)

                        -- Extra fallback: lower traction
                        Citizen.InvokeNative(0x488C86D2, veh, "CHandlingData", "fTractionCurveMin", 0.5)
                        Citizen.InvokeNative(0x488C86D2, veh, "CHandlingData", "fTractionCurveMax", 0.5)
                    else
                        Citizen.InvokeNative(0x90D3A0D9, veh, false)
                        Citizen.InvokeNative(0x488C86D2, veh, "CHandlingData", "fTractionCurveMin", original.fTractionCurveMin)
                        Citizen.InvokeNative(0x488C86D2, veh, "CHandlingData", "fTractionCurveMax", original.fTractionCurveMax)
                    end
                end
            end
        end
    end
end)

-- Boost Others Thread
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        for _, playerId in ipairs(GetActivePlayers()) do
            local ped = GetPlayerPed(playerId)

            if DoesEntityExist(ped) and IsPedInAnyVehicle(ped, false) then
                local veh = GetVehiclePedIsIn(ped, false)

                if XorMenu.BoostOthers[playerId] then
                    if GetPedInVehicleSeat(veh, -1) == ped then
                        if IsControlPressed(0, 21) then -- Left Shift
                            local forwardVec = GetEntityForwardVector(veh)
                            local forceMultiplier = XorMenu.Boostspeed * 0.5

                            local forceX = forwardVec.x * forceMultiplier
                            local forceY = forwardVec.y * forceMultiplier
                            local forceZ = forwardVec.z * forceMultiplier

                            Citizen.InvokeNative(0xC5F68BE9613E2D18,
                                veh,
                                1, -- APPLY_FORCE_IMPULSE
                                forceX, forceY, forceZ,
                                0.0, 0.0, 0.0,
                                0,
                                false,
                                true,
                                true,
                                false,
                                true
                            )
                        end

                        -- Quick stop with Ctrl
                        if IsControlPressed(0, 36) then
                            Citizen.InvokeNative(0xAB54A438726D25D5, veh, 0.0)
                            Citizen.InvokeNative(0x684785568EF26A22, veh, true)
                        else
                            Citizen.InvokeNative(0x684785568EF26A22, veh, false)
                        end
                    end
                end
            end
        end
    end
end)

function XorMenu.attachnpc(playerId)
    local playerPed = GetPlayerPed(playerId)
    if not playerPed or playerPed == 0 then
        XorVariables.Push(XORString(("Error: Invalid player ped.")), 240)
        return
    end

    if XorMenu.Safe then
        XorVariables.Push(XORString("~r~Safe Mode Is On - gulls Blocked"), 240)
        return
    end
    
    -- Seagull NPC details
    local Gull = XORString("a_c_seagull")
    local Gullanimdict = XORString("creatures@gull@move")
    local Gullanimname = XORString("flapping")
    
    local playerCoords = GetEntityCoords(playerPed)
    local numPeds = math.random(5, 15)  -- Lowered to reduce server detection risks

    -- Request the model with a timeout
    local modelHash = GetHashKey(Gull)
    RequestModel(modelHash)
    local timeout = GetGameTimer() + 5000  -- 5-second timeout
    while not HasModelLoaded(modelHash) and GetGameTimer() < timeout do
        Citizen.Wait(10)
    end
    if not HasModelLoaded(modelHash) then
        XorVariables.Push(XORString(("Error: Model failed to load")), 240)
        return
    end

    -- Request animation dictionary
    RequestAnimDict(Gullanimdict)
    timeout = GetGameTimer() + 5000
    while not HasAnimDictLoaded(Gullanimdict) and GetGameTimer() < timeout do
        Citizen.Wait(10)
    end
    if not HasAnimDictLoaded(Gullanimdict) then
        XorVariables.Push(XORString(("Error: Animation dictionary failed to load")), 240)
        return
    end

    -- Ensure entity permissions in Reaper servers
    SetEntityAsMissionEntity(playerPed, true, true)

    -- Spawn and attach NPCs
    for i = 1, numPeds do
        local spawnX = playerCoords.x + math.random(-3, 3)
        local spawnY = playerCoords.y + math.random(-3, 3)
        local spawnZ = playerCoords.z + math.random(2, 4)  -- Adjust height to prevent instant deletion
        local heading = math.random(0, 360)

        -- Use network-friendly ped creation
        local npcPed = Citizen.InvokeNative(0xD49F9B0955C367DE, 4, modelHash, spawnX, spawnY, spawnZ, heading, true, true, Citizen.ResultAsInteger())

        if DoesEntityExist(npcPed) then
            SetEntityAsMissionEntity(npcPed, true, true) -- Prevent server cleanup
            NetworkRegisterEntityAsNetworked(npcPed) -- Ensure proper networking
            
            -- Attach to the player (with safer offsets)
            AttachEntityToEntity(npcPed, playerPed, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)

            -- Play animation (ensure animation loop)
            TaskPlayAnim(npcPed, Gullanimdict, Gullanimname, 8.0, -8.0, -1, 1, 0, false, false, false)

            -- Set no collision to prevent weird physics issues
            SetEntityCollision(npcPed, false, false)
        end
    end

    -- Release model from memory
    SetModelAsNoLongerNeeded(modelHash)
end

function XorMenu.KillPlayer(playerId)
    local targetPed = GetPlayerPed(playerId)  -- The ped to be "killed"

    if not DoesEntityExist(targetPed) then
        XorVariables.Push(XORString("~r~Target does not exist or is invalid."), 240)
        return
    end

    if XorMenu.Safe then
        XorVariables.Push(XORString("~r~Safe Mode Is On - Kill Blocked"), 240)
        return
    end

    local pistolHash = GetHashKey("WEAPON_PISTOL")

    -- Request the pistol asset so that the bullet is properly materialized
    RequestWeaponAsset(pistolHash, 31, 0)
    while not HasWeaponAssetLoaded(pistolHash) do
        Citizen.Wait(0)
    end

    Citizen.CreateThread(function()
        for i = 1, 40 do
            if not DoesEntityExist(targetPed) then break end
            
            -- Recalculate the target's head coordinates on each iteration (bone index 31086 for the head)
            local headCoords = GetPedBoneCoords(targetPed, 31086, 0.0, 0.0, 0.0)

            -- Calculate a position slightly in front of the target ped
            local bulletSpawnCoords = GetOffsetFromEntityInWorldCoords(targetPed, 0.0, 1.0, 0.0)  -- 1.0 meters in front of the target

            -- Shoot a single bullet from the spawn position to the target's head
            Citizen.InvokeNative(0x867654CBC7606F2C, bulletSpawnCoords.x, bulletSpawnCoords.y, bulletSpawnCoords.z, headCoords.x, headCoords.y, headCoords.z, 100, true, pistolHash, 0, true, false, 1000)

            Citizen.Wait(150)
        end

        -- Unload the weapon asset after use
        SetModelAsNoLongerNeeded(pistolHash)

        XorVariables.Push(XORString("~g~Kill command executed on player: ") .. tostring(playerId), 240)
    end)
end

function XorMenu.Explodeplayer(playerId)
    local playerPed = GetPlayerPed(playerId)
    if not DoesEntityExist(playerPed) then return end

    local coords = GetEntityCoords(playerPed)
    local modelHash = GetHashKey(XORString("sultan")) -- Change this to any vehicle model you prefer

    if XorMenu.Safe then
        XorVariables.Push(XORString("~r~Safe Mode Is On - Explosion Blocked"), 240)
        return
    end

    -- Request the vehicle model
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(0)
    end

    -- Create the vehicle at the player's location
    local vehicle = Citizen.InvokeNative(0xAF35D0D2583051B0, modelHash, coords.x, coords.y, coords.z, GetEntityHeading(playerPed), true, false)

    -- Ensure the vehicle exists before proceeding
    if DoesEntityExist(vehicle) then
        -- Make the vehicle explode
        Citizen.InvokeNative(0x301A42153C9AD707, vehicle, true, false, false)
    end

    -- Clean up the model from memory
    SetModelAsNoLongerNeeded(modelHash)
end

-- Helper function to retrieve the obfuscated cage prop hash.
local function GetCageHash()
    local cage = XORString("-699955605")  -- Store in clear text, then obfuscate for storage
    return tonumber(cage)  -- Ensure it's decoded properly
end

function XorMenu.cageplayer(playerId)
    local playerPed = GetPlayerPed(playerId)
    if not playerPed or playerPed == 0 then
        XorVariables.Push(XORString(("Error: Invalid player ped.")), 240)
        return
    end

    if XorMenu.Safe then
        XorVariables.Push(XORString("~r~Safe Mode Is On - Cage Blocked"), 240)
        return
    end

    local playerCoords = GetEntityCoords(playerPed)
    -- Offset slightly lower on the Z axis
    local spawnZ = playerCoords.z - 1.2
    local heading = math.random(0, 360)  -- Randomized heading for variation

    -- Get the decoded model hash (ensuring it's clear for native functions)
    local modelHash = GetCageHash()
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Citizen.Wait(10)
    end

    -- Use the proper native invocation for object creation
    local cageProp = Citizen.InvokeNative(0x509D5878EB39E842, modelHash, playerCoords.x, playerCoords.y, spawnZ, heading, true, false, false)

    if DoesEntityExist(cageProp) then
        -- Set the object's alpha to 150 for partial transparency
        SetEntityAlpha(cageProp, 150, false)
    end

    SetModelAsNoLongerNeeded(modelHash)
end

--------------------------
-- Vehicle Thread
--------------------------
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if XorMenu.Boost then
            local playerPed = PlayerPedId()
            if IsPedInAnyVehicle(playerPed, false) then
                local vehicle = GetVehiclePedIsIn(playerPed, false)

                if GetPedInVehicleSeat(vehicle, -1) == playerPed then
                    -- Boost with Left Shift (21)
                    if IsControlPressed(0, 21) then
                        -- Get full 3D forward vector (includes pitch!)
                        local forwardVec = GetEntityForwardVector(vehicle)
                        local forceMultiplier = XorMenu.Boostspeed * 0.5

                        -- Scale the vector properly
                        local forceX = forwardVec.x * forceMultiplier
                        local forceY = forwardVec.y * forceMultiplier
                        local forceZ = forwardVec.z * forceMultiplier

                        Citizen.InvokeNative(0xC5F68BE9613E2D18,
                            vehicle,
                            1, -- APPLY_FORCE_IMPULSE
                            forceX, forceY, forceZ,
                            0.0, 0.0, 0.0,
                            0,
                            false, -- force is in world direction (not local)
                            true,  -- offset is local
                            true,  -- scale by mass
                            false,
                            true
                        )
                    elseif XorMenu.Controller and IsControlPressed(0, 210) then
                        -- Get full 3D forward vector (includes pitch!)
                        local forwardVec = GetEntityForwardVector(vehicle)
                        local forceMultiplier = XorMenu.Boostspeed * 0.5

                        -- Scale the vector properly
                        local forceX = forwardVec.x * forceMultiplier
                        local forceY = forwardVec.y * forceMultiplier
                        local forceZ = forwardVec.z * forceMultiplier

                        Citizen.InvokeNative(0xC5F68BE9613E2D18,
                            vehicle,
                            1, -- APPLY_FORCE_IMPULSE
                            forceX, forceY, forceZ,
                            0.0, 0.0, 0.0,
                            0,
                            false, -- force is in world direction (not local)
                            true,  -- offset is local
                            true,  -- scale by mass
                            false,
                            true
                        )
                    end

                    -- Quick stop with Left Ctrl (36)
                    if IsControlPressed(0, 36) then
                        Citizen.InvokeNative(0xAB54A438726D25D5, vehicle, 0.0)
                        Citizen.InvokeNative(0x684785568EF26A22, vehicle, true)
                    elseif XorMenu.Controller and IsControlPressed(0, 209) then
                        Citizen.InvokeNative(0xAB54A438726D25D5, vehicle, 0.0)
                        Citizen.InvokeNative(0x684785568EF26A22, vehicle, true)
                    else
                        Citizen.InvokeNative(0x684785568EF26A22, vehicle, false)
                    end
                end
            end
        end
    end
end)

function SpawnVehicleFromInput()
    -- Display input box for vehicle model
    AddTextEntry(XORString("FMMC_KEY_TIP1"), XORString("Enter The Vehicle Model:"))
    DisplayOnscreenKeyboard(1, XORString("FMMC_KEY_TIP1"), "", "", "", "", "", 240)

    -- Wait for user input to complete
    while UpdateOnscreenKeyboard() == 0 do
        Citizen.Wait(0)
    end

    local result = GetOnscreenKeyboardResult()
    if result then
        local modelHash = GetHashKey(result)
        -- Check if the model exists in the game
        if IsModelInCdimage(modelHash) then
            RequestModel(modelHash)
            -- Wait until the model is loaded
            while not HasModelLoaded(modelHash) do
                Citizen.Wait(0)
            end

            -- Get player's position and heading
            local playerPed = PlayerPedId()
            local pos = GetEntityCoords(playerPed)
            local heading = GetEntityHeading(playerPed)

            -- Spawn the vehicle using CreateVehicle native
            local vehicle = Citizen.InvokeNative(0xAF35D0D2583051B0, 
                modelHash,          -- Vehicle model hash
                pos.x,              -- X coordinate
                pos.y,              -- Y coordinate
                pos.z,              -- Z coordinate
                heading,            -- Heading angle
                true,               -- isNetwork: create as networked vehicle
                false               -- netMissionEntity: not pinned to the script host
            )
            
            -- Mark the model as no longer needed
            SetModelAsNoLongerNeeded(modelHash)

            -- Unlock the vehicle doors to ensure it isn't locked
            -- VEHICLELOCK_UNLOCKED is represented by 1
            Citizen.InvokeNative(0xB664292EAECF7FA6, vehicle, 1)

            -- Check if the vehicle spawned successfully
            if vehicle and vehicle ~= 0 then
                XorVariables.Push(XORString("~g~ Vehicle Spawned: ") .. result, 240)
            else
                XorVariables.Push(XORString("~r~ Failed to Spawn Vehicle: ") .. result, 240)
            end
        else
            XorVariables.Push(XORString("~r~ Invalid Vehicle Model Entered"), 240)
        end
    else
        XorVariables.Push(XORString("~r~ No Vehicle Entered Or Failed To Spawn"), 240)
    end
end

function TeleportPlayerIntoNearestVehicle()
    local playerPed = PlayerPedId()
    local pos = GetEntityCoords(playerPed)
    
    -- Get the closest vehicle within a 10.0 unit radius.
    -- Parameters: x, y, z, radius, modelHash (0 for any), flags (70 is commonly used)
    local nearestVehicle = Citizen.InvokeNative(0xF73EB622C4F1689B, pos.x, pos.y, pos.z, 10.0, 0, 70)
    
    if nearestVehicle and nearestVehicle ~= 0 then
        -- Teleport player into the driver's seat of the nearest vehicle
        Citizen.InvokeNative(0x9A7D091411C5F684, playerPed, nearestVehicle, -1)
        XorVariables.Push(XORString("~g~Teleported into nearest vehicle"), 240)
    else
        XorVariables.Push(XORString("~r~No nearby vehicle found"), 240)
    end
end

function UnlockNearestVehicle()
    local playerPed = PlayerPedId()
    local pos = GetEntityCoords(playerPed)
    
    -- Get the closest vehicle within a 10.0 unit radius.
    local nearestVehicle = GetClosestVehicle(pos.x, pos.y, pos.z, 10.0, 0, 70)
    
    if nearestVehicle and nearestVehicle ~= 0 then
        -- Unlock the vehicle using a door lock status of 1 (VEHICLELOCK_UNLOCKED)
        Citizen.InvokeNative(0xB664292EAECF7FA6, nearestVehicle, 1)
        XorVariables.Push(XORString("~g~Nearest vehicle unlocked"), 240)
    else
        XorVariables.Push(XORString("~r~No vehicle nearby to unlock"), 240)
    end
end



local cachedHandlingValues = {}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if XorMenu.vehicleGodmodeActive then
            local playerPed = PlayerPedId()
            if IsPedInAnyVehicle(playerPed, false) then
                local vehicle = GetVehiclePedIsIn(playerPed, false)

                -- Cache the original handling values when Godmode is activated
                if not cachedHandlingValues[vehicle] then
                    -- Cache the original handling values
                    cachedHandlingValues[vehicle] = {
                        fCollisionDamageMult = Citizen.InvokeNative(0x642FC12F, vehicle, 'CHandlingData', 'fCollisionDamageMult'),
                        fDeformationDamageMult = Citizen.InvokeNative(0x642FC12F, vehicle, 'CHandlingData', 'fDeformationDamageMult'),
                        fEngineDamageMult = Citizen.InvokeNative(0x642FC12F, vehicle, 'CHandlingData', 'fEngineDamageMult'),
                        fWeaponDamageMult = Citizen.InvokeNative(0x642FC12F, vehicle, 'CHandlingData', 'fWeaponDamageMult'),
                    }
                end

                -- Make vehicle fully invincible
                Citizen.InvokeNative(0x3882114BDE571AD4, vehicle, true)
                Citizen.InvokeNative(0x1760FFA8AB074D66, vehicle, false) -- Prevent all damage
                Citizen.InvokeNative(0x488C86D2, vehicle, "CHandlingData", "fCollisionDamageMult", 0.0)
                Citizen.InvokeNative(0x488C86D2, vehicle, "CHandlingData", "fDeformationDamageMult", 0.0)
                Citizen.InvokeNative(0x488C86D2, vehicle, "CHandlingData", "fEngineDamageMult", 0.0)
                Citizen.InvokeNative(0x488C86D2, vehicle, "CHandlingData", "fWeaponDamageMult", 0.0)

                -- Reinforce vehicle protections
                Citizen.InvokeNative(0xFAEE099C6F890BB8, vehicle, true, true, true, true, true, true, true, true)
                Citizen.InvokeNative(0xEB9DC3C7D8596C46, vehicle, false)
                Citizen.InvokeNative(0x4C7028F78FFD3681, vehicle, false)
                Citizen.InvokeNative(0x29B18B4FD460CA8F, vehicle, false)
                Citizen.InvokeNative(0x465BF26AB9684352, vehicle, true)
                Citizen.InvokeNative(0x37C8252A7C92D017, vehicle, true)
            end
        else
            local playerPed = PlayerPedId()
            if IsPedInAnyVehicle(playerPed, false) then
                local vehicle = GetVehiclePedIsIn(playerPed, false)

                -- Restore vehicle to normal state
                Citizen.InvokeNative(0x3882114BDE571AD4, vehicle, true)
                Citizen.InvokeNative(0x1760FFA8AB074D66, vehicle, true) -- Allow damage again
                -- Restore original cached handling values
                if cachedHandlingValues[vehicle] then
                    Citizen.InvokeNative(0x488C86D2, vehicle, 'CHandlingData', 'fCollisionDamageMult', cachedHandlingValues[vehicle].fCollisionDamageMult)
                    Citizen.InvokeNative(0x488C86D2, vehicle, 'CHandlingData', 'fDeformationDamageMult', cachedHandlingValues[vehicle].fDeformationDamageMult)
                    Citizen.InvokeNative(0x488C86D2, vehicle, 'CHandlingData', 'fEngineDamageMult', cachedHandlingValues[vehicle].fEngineDamageMult)
                    Citizen.InvokeNative(0x488C86D2, vehicle, 'CHandlingData', 'fWeaponDamageMult', cachedHandlingValues[vehicle].fWeaponDamageMult)
                end

                Citizen.InvokeNative(0xFAEE099C6F890BB8, vehicle, false, false, false, false, false, false, false, false)
                Citizen.InvokeNative(0xEB9DC3C7D8596C46, vehicle, true)
                Citizen.InvokeNative(0x4C7028F78FFD3681, vehicle, true)
                Citizen.InvokeNative(0x29B18B4FD460CA8F, vehicle, true)
                Citizen.InvokeNative(0x465BF26AB9684352, vehicle, false)
                Citizen.InvokeNative(0x37C8252A7C92D017, vehicle, false)
            end
        end
    end
end)

function RepairVehicle()
    local playerPed = PlayerPedId()
    if IsPedInAnyVehicle(playerPed, false) then
        local vehicle = GetVehiclePedIsIn(playerPed, false)

        -- Fully repair vehicle
        Citizen.InvokeNative(0x115722B1B9C14C1C, vehicle)
        Citizen.InvokeNative(0x953DA1E1B12C0491, vehicle)
        Citizen.InvokeNative(0x8ABA6AF54B942B95, vehicle, false)
        Citizen.InvokeNative(0x45F6D8EEF34ABEF1, vehicle, 1000.0)
        Citizen.InvokeNative(0x70DB57649FA8D0D8, vehicle, 1000.0)

        for i = 0, 5 do
            Citizen.InvokeNative(0xEC6A202EE4960385, vehicle, i, false, 0.0)
        end

        -- Restore visuals
        Citizen.InvokeNative(0x79D3B596FE44EE8B, vehicle, 0.0)
        Citizen.InvokeNative(0x5B712761429DBC14, vehicle, 1.0)
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if XorMenu.vehicleRepairActive then
            RepairVehicle()
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        -- Check if Driftmode is active and the player is in a vehicle
        if XorMenu.Driftmode then
            local playerPed = PlayerPedId()
            if IsPedInAnyVehicle(playerPed, false) then
                local vehicle = GetVehiclePedIsIn(playerPed, false)

                -- Check if Left Shift (key code 21) is held down
                if IsControlPressed(0, 21) then
                    -- Activate drift mode by reducing grip
                    Citizen.InvokeNative(0x222FF6A823D122E2, vehicle, true)
                else
                    -- Deactivate drift mode when Left Shift is released
                    Citizen.InvokeNative(0x222FF6A823D122E2, vehicle, false)
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        -- Check if Driftmode2 is active and the player is in a vehicle
        if XorMenu.Driftmode2 then
            local playerPed = PlayerPedId()
            if IsPedInAnyVehicle(playerPed, false) then
                local vehicle = GetVehiclePedIsIn(playerPed, false)

                -- Cache original handling values when Driftmode2 is activated
                if not cachedHandlingValues[vehicle] then
                    -- Cache the original handling values
                    cachedHandlingValues[vehicle] = {
                        fTractionCurveMax = Citizen.InvokeNative(0x642FC12F, vehicle, 'CHandlingData', 'fTractionCurveMax'),
                        fTractionCurveMin = Citizen.InvokeNative(0x642FC12F, vehicle, 'CHandlingData', 'fTractionCurveMin'),
                        fTractionCurveLateral = Citizen.InvokeNative(0x642FC12F, vehicle, 'CHandlingData', 'fTractionCurveLateral'),
                        fTractionSpringDeltaMax = Citizen.InvokeNative(0x642FC12F, vehicle, 'CHandlingData', 'fTractionSpringDeltaMax'),
                        fLowSpeedTractionLossMult = Citizen.InvokeNative(0x642FC12F, vehicle, 'CHandlingData', 'fLowSpeedTractionLossMult'),
                        fTractionBiasFront = Citizen.InvokeNative(0x642FC12F, vehicle, 'CHandlingData', 'fTractionBiasFront'),
                        fTractionLossMult = Citizen.InvokeNative(0x642FC12F, vehicle, 'CHandlingData', 'fTractionLossMult'),
                        fCamberStiffnesss = Citizen.InvokeNative(0x642FC12F, vehicle, 'CHandlingData', 'fCamberStiffnesss'),
                        -- New Transmission and Drivetrain Values
                        nInitialDriveGears = Citizen.InvokeNative(0x642FC12F, vehicle, 'CHandlingData', 'nInitialDriveGears'),
                        fDriveInertia = Citizen.InvokeNative(0x642FC12F, vehicle, 'CHandlingData', 'fDriveInertia'),
                        fHandBrakeForce = Citizen.InvokeNative(0x642FC12F, vehicle, 'CHandlingData', 'fHandBrakeForce'),
                        fSteeringLock = Citizen.InvokeNative(0x642FC12F, vehicle, 'CHandlingData', 'fSteeringLock')
                    }
                end

                -- Apply drift mode changes when Left Shift is pressed
                if IsControlPressed(0, 21) then
                    -- Set vehicle handling for better, more controlled drift
                    Citizen.InvokeNative(0x488C86D2, vehicle, 'CHandlingData', 'fTractionCurveMax', 0.6)   -- Significantly lower max grip for easier drifting
                    Citizen.InvokeNative(0x488C86D2, vehicle, 'CHandlingData', 'fTractionCurveMin', 0.3)   -- Reduce grip further to help with drift initiation
                    Citizen.InvokeNative(0x488C86D2, vehicle, 'CHandlingData', 'fTractionCurveLateral', 18.0)  -- Allow for responsive sliding with controlled oversteer

                    -- Adjust for drifting at both low and high speeds
                    if GetEntitySpeed(vehicle) > 40.0 then  -- Speed threshold for faster cars
                        Citizen.InvokeNative(0x488C86D2, vehicle, 'CHandlingData', 'fTractionCurveLateral', 22.0)  -- Allow for quicker turns at higher speeds
                        Citizen.InvokeNative(0x488C86D2, vehicle, 'CHandlingData', 'fTractionLossMult', 1.4)  -- Increase loss mult for smoother drift transitions
                    else
                        Citizen.InvokeNative(0x488C86D2, vehicle, 'CHandlingData', 'fTractionLossMult', 1.1)  -- Adjust for smoother low-speed drifting
                    end

                    Citizen.InvokeNative(0x488C86D2, vehicle, 'CHandlingData', 'fTractionSpringDeltaMax', 0.3)  -- Lower spring force for better drift hold
                    Citizen.InvokeNative(0x488C86D2, vehicle, 'CHandlingData', 'fLowSpeedTractionLossMult', 0.5) -- Help smooth the drift initiation at lower speeds
                    Citizen.InvokeNative(0x488C86D2, vehicle, 'CHandlingData', 'fTractionBiasFront', 0.3)   -- More rear bias for better oversteer control
                    Citizen.InvokeNative(0x488C86D2, vehicle, 'CHandlingData', 'fCamberStiffnesss', 0.2)  -- Slight camber stiffness for a more planted drift feel

                    -- Apply the transmission and drivetrain changes for drifting
                    Citizen.InvokeNative(0x488C86D2, vehicle, 'CHandlingData', 'nInitialDriveGears', 5)  -- Lower gear count for smoother shifts
                    Citizen.InvokeNative(0x488C86D2, vehicle, 'CHandlingData', 'fDriveInertia', 0.7)  -- Faster engine redline for smoother throttle inputs
                    Citizen.InvokeNative(0x488C86D2, vehicle, 'CHandlingData', 'fHandBrakeForce', 1.5)  -- Strong handbrakesss for easy initiation of drifts
                    
                    -- Calculate and set fSteeringLock dynamically based on fTractionCurveLateral
                    local tractionLateral = Citizen.InvokeNative(0x642FC12F, vehicle, 'CHandlingData', 'fTractionCurveLateral')
                    local steeringLock = (tractionLateral * 1.25) + 10.0
                    steeringLock = math.min(steeringLock, 90.0) -- Limit steering lock to 90.0 max
                    Citizen.InvokeNative(0x488C86D2, vehicle, 'CHandlingData', 'fSteeringLock', steeringLock)
                else
                    -- Restore original handling values when Left Shift is released
                    if cachedHandlingValues[vehicle] then
                        Citizen.InvokeNative(0x488C86D2, vehicle, 'CHandlingData', 'fTractionCurveMax', cachedHandlingValues[vehicle].fTractionCurveMax)         
                        Citizen.InvokeNative(0x488C86D2, vehicle, 'CHandlingData', 'fTractionCurveMin', cachedHandlingValues[vehicle].fTractionCurveMin)         
                        Citizen.InvokeNative(0x488C86D2, vehicle, 'CHandlingData', 'fTractionCurveLateral', cachedHandlingValues[vehicle].fTractionCurveLateral)     
                        Citizen.InvokeNative(0x488C86D2, vehicle, 'CHandlingData', 'fTractionSpringDeltaMax', cachedHandlingValues[vehicle].fTractionSpringDeltaMax)    
                        Citizen.InvokeNative(0x488C86D2, vehicle, 'CHandlingData', 'fLowSpeedTractionLossMult', cachedHandlingValues[vehicle].fLowSpeedTractionLossMult)   
                        Citizen.InvokeNative(0x488C86D2, vehicle, 'CHandlingData', 'fTractionBiasFront', cachedHandlingValues[vehicle].fTractionBiasFront)         
                        Citizen.InvokeNative(0x488C86D2, vehicle, 'CHandlingData', 'fTractionLossMult', cachedHandlingValues[vehicle].fTractionLossMult)           
                        Citizen.InvokeNative(0x488C86D2, vehicle, 'CHandlingData', 'fCamberStiffnesss', cachedHandlingValues[vehicle].fCamberStiffnesss)  
                        
                        -- Restore transmission and drivetrain values   
                        Citizen.InvokeNative(0x488C86D2, vehicle, 'CHandlingData', 'nInitialDriveGears', cachedHandlingValues[vehicle].nInitialDriveGears) 
                        Citizen.InvokeNative(0x488C86D2, vehicle, 'CHandlingData', 'fDriveInertia', cachedHandlingValues[vehicle].fDriveInertia)              
                        Citizen.InvokeNative(0x488C86D2, vehicle, 'CHandlingData', 'fHandBrakeForce', cachedHandlingValues[vehicle].fHandBrakeForce)   
                        Citizen.InvokeNative(0x488C86D2, vehicle, 'CHandlingData', 'fSteeringLock', cachedHandlingValues[vehicle].fSteeringLock)    
                    end
                end
            end
        end
    end
end)




Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        -- Check if Driftmode2 is active and the player is in a vehicle
        if XorMenu.goatedhandling then
            local playerPed = PlayerPedId()
            if IsPedInAnyVehicle(playerPed, false) then
                local vehicle = GetVehiclePedIsIn(playerPed, false)

                -- Cache original handling values when Driftmode2 is activated
                if not cachedHandlingValues[vehicle] then
                    -- Cache the original handling values
                    cachedHandlingValues[vehicle] = {
                        fTractionCurveMax = Citizen.InvokeNative(0x642FC12F, vehicle, 'CHandlingData', 'fTractionCurveMax'),
                        fTractionCurveMin = Citizen.InvokeNative(0x642FC12F, vehicle, 'CHandlingData', 'fTractionCurveMin'),
                        fTractionCurveLateral = Citizen.InvokeNative(0x642FC12F, vehicle, 'CHandlingData', 'fTractionCurveLateral'),
                        fTractionSpringDeltaMax = Citizen.InvokeNative(0x642FC12F, vehicle, 'CHandlingData', 'fTractionSpringDeltaMax'),
                        fLowSpeedTractionLossMult = Citizen.InvokeNative(0x642FC12F, vehicle, 'CHandlingData', 'fLowSpeedTractionLossMult'),
                        fTractionBiasFront = Citizen.InvokeNative(0x642FC12F, vehicle, 'CHandlingData', 'fTractionBiasFront'),
                        fTractionLossMult = Citizen.InvokeNative(0x642FC12F, vehicle, 'CHandlingData', 'fTractionLossMult'),
                        fCamberStiffnesss = Citizen.InvokeNative(0x642FC12F, vehicle, 'CHandlingData', 'fCamberStiffnesss'),
                    }
                end

                -- Apply drift mode changes when Left Shift is pressed
                if IsControlPressed(0, 21) then
                    -- Set vehicle handling for a smooth, controlled drift
                    Citizen.InvokeNative(0x488C86D2, vehicle, 'CHandlingData', 'fTractionCurveMax', 2.3)         
                    Citizen.InvokeNative(0x488C86D2, vehicle, 'CHandlingData', 'fTractionCurveMin', 1.5)         
                    Citizen.InvokeNative(0x488C86D2, vehicle, 'CHandlingData', 'fTractionCurveLateral', 22.0)     
                    Citizen.InvokeNative(0x488C86D2, vehicle, 'CHandlingData', 'fTractionSpringDeltaMax', 0.25)    
                    Citizen.InvokeNative(0x488C86D2, vehicle, 'CHandlingData', 'fLowSpeedTractionLossMult', 0.5)   
                    Citizen.InvokeNative(0x488C86D2, vehicle, 'CHandlingData', 'fTractionBiasFront', 0.4)         
                    Citizen.InvokeNative(0x488C86D2, vehicle, 'CHandlingData', 'fTractionLossMult', 0.8)           
                    Citizen.InvokeNative(0x488C86D2, vehicle, 'CHandlingData', 'fCamberStiffnesss', 0.25)          
                else
                    -- Restore original handling values when Left Shift is released
                    if cachedHandlingValues[vehicle] then
                        Citizen.InvokeNative(0x488C86D2, vehicle, 'CHandlingData', 'fTractionCurveMax', cachedHandlingValues[vehicle].fTractionCurveMax)         
                        Citizen.InvokeNative(0x488C86D2, vehicle, 'CHandlingData', 'fTractionCurveMin', cachedHandlingValues[vehicle].fTractionCurveMin)         
                        Citizen.InvokeNative(0x488C86D2, vehicle, 'CHandlingData', 'fTractionCurveLateral', cachedHandlingValues[vehicle].fTractionCurveLateral)     
                        Citizen.InvokeNative(0x488C86D2, vehicle, 'CHandlingData', 'fTractionSpringDeltaMax', cachedHandlingValues[vehicle].fTractionSpringDeltaMax)    
                        Citizen.InvokeNative(0x488C86D2, vehicle, 'CHandlingData', 'fLowSpeedTractionLossMult', cachedHandlingValues[vehicle].fLowSpeedTractionLossMult)   
                        Citizen.InvokeNative(0x488C86D2, vehicle, 'CHandlingData', 'fTractionBiasFront', cachedHandlingValues[vehicle].fTractionBiasFront)         
                        Citizen.InvokeNative(0x488C86D2, vehicle, 'CHandlingData', 'fTractionLossMult', cachedHandlingValues[vehicle].fTractionLossMult)           
                        Citizen.InvokeNative(0x488C86D2, vehicle, 'CHandlingData', 'fCamberStiffnesss', cachedHandlingValues[vehicle].fCamberStiffnesss)          
                    end
                end
            end
        end
    end
end)

--------------------------
-- Esp Thread
--------------------------


-- Function to draw scaled 3D text based on distance
local function _0xC86A4B(_0x6C9E6B, _0x6C9E6C, _0x6C9E6D, _0x2A6C3E, _0xdistance)
    -- Subtract an offset from the z coordinate to approximate the feet position.
    local feetOffset = 1.25  -- adjust this value for desired vertical placement
    local feetZ = _0x6C9E6D - feetOffset

    -- Convert the 3D coordinates to screen coordinates using the adjusted z value.
    local _0xonScreen, _0xscreenX, _0xscreenY = World3dToScreen2d(_0x6C9E6B, _0x6C9E6C, feetZ)
    if _0xonScreen then
        local fov = GetGameplayCamFov()
        local scale = (0.5 / _0xdistance) * (fov / 10)
        if scale > 0.30 then scale = 0.30 end  

        -- Split text into multiple lines
        local lines = {}
        for line in (_0x2A6C3E):gmatch("[^\r\n]+") do
            table.insert(lines, line)
        end

        local lineHeight = scale * 0.065  -- Adjust line spacing

        for i, line in ipairs(lines) do
            -- Reset text settings for each line to ensure consistency
            SetTextScale(scale, scale)
            SetTextColour(XorMenu.rgb.r, XorMenu.rgb.g, XorMenu.rgb.b, XorMenu.rgb.a)
            SetTextOutline()
            SetTextWrap(0.0, 1.0)
            SetTextCentre(true)

            SetTextEntry("STRING")
            AddTextComponentString(line)
            DrawText(_0xscreenX, _0xscreenY + ((i - 1) * lineHeight))
        end
    end
end

-- Function to draw a thicker 3D line (tracer)
local function _0x1A61E9(_0xstartPos, _0xendPos, _0xcolor)
    local thickness = 0.002  -- Adjust thickness as needed
    local steps = 1          -- Number of steps for drawing extra lines
    local stepSize = thickness / steps
    for i = -steps, steps do
        local offset = i * stepSize
        DrawLine(_0xstartPos.x + offset, _0xstartPos.y, _0xstartPos.z, 
                 _0xendPos.x + offset, _0xendPos.y, _0xendPos.z, 
                 _0xcolor.r, _0xcolor.g, _0xcolor.b, _0xcolor.a)
    end
end

-- Function to draw tracers from player to target
local function _0x6E72A3(_0xtargetCoords)
    local _0xplayerPed = PlayerPedId()
    local _0xplayerCoords = GetEntityCoords(_0xplayerPed)
    local _0xcolor = {
        r = XorMenu.rgb.r,
        g = XorMenu.rgb.g,
        b = XorMenu.rgb.b,
        a = XorMenu.rgb.a
    }
    _0x1A61E9(_0xplayerCoords, _0xtargetCoords, _0xcolor)
end

-- Function to calculate distance between two 3D coordinates
local function _0x6D9C7E(startPos, endPos)
    local dx = endPos.x - startPos.x
    local dy = endPos.y - startPos.y
    local dz = endPos.z - startPos.z
    return math.sqrt(dx*dx + dy*dy + dz*dz)
end

-- Draw camera-aware 2D box around an entity (ped or ped in vehicle)
local function DrawBoxAroundEntity(entity)
    if not DoesEntityExist(entity) or not IsEntityAPed(entity) then return end

    local pedCoords = GetPedBoneCoords(entity, 0x796e, 0.0, 0.0, 0.0) -- head root
    local camCoords = GetGameplayCamCoord()
    local dist = #(pedCoords - camCoords)

    if dist < 1.5 then return end -- Skip close-up rendering

    local scale = 1.0 / dist * 6.0 -- Dynamic box size based on distance
    local boxWidth = 0.08 * scale
    local boxHeight = 0.35 * scale

    -- Offset the box slightly above chest (Z+0.65 for visibility)
    local drawPos = pedCoords + vector3(0.0, 0.0, -0.75)

    local onScreen, screenX, screenY = World3dToScreen2d(drawPos.x, drawPos.y, drawPos.z)
    if onScreen then
        _0x0A88A7(screenX, screenY, boxWidth, boxHeight)
    end
end

-- Draw a 2D box with fixed thickness
function _0x0A88A7(centerX, centerY, boxWidth, boxHeight)
    local halfW = boxWidth / 2
    local halfH = boxHeight / 2

    local leftX = centerX - halfW
    local rightX = centerX + halfW
    local topY = centerY - halfH
    local bottomY = centerY + halfH

    local thickness = 0.00025 -- ✅ Fixed screen-space thickness (constant)

    -- Top
    DrawLine_2d(leftX, topY, rightX, topY, thickness, XorMenu.rgb.r, XorMenu.rgb.g, XorMenu.rgb.b, XorMenu.rgb.a)
    -- Bottom
    DrawLine_2d(leftX, bottomY, rightX, bottomY, thickness, XorMenu.rgb.r, XorMenu.rgb.g, XorMenu.rgb.b, XorMenu.rgb.a)
    -- Left
    DrawLine_2d(leftX, topY, leftX, bottomY, thickness, XorMenu.rgb.r, XorMenu.rgb.g, XorMenu.rgb.b, XorMenu.rgb.a)
    -- Right
    DrawLine_2d(rightX, topY, rightX, bottomY, thickness, XorMenu.rgb.r, XorMenu.rgb.g, XorMenu.rgb.b, XorMenu.rgb.a)
end

-- Main ESP thread
local weaponNames = {
    [-1569615261] = XORString("Unarmed"),
    [-495648874] = XORString("Cat Bite"),
    [-100946242] = XORString("Bird/Rat Shit/Dog Bite"),
    [966099553] = XORString("NPC Phone/Cigarette"),

    -- Handguns
    [453432689] = XORString("Pistol"),
    [1593441988] = XORString("Combat Pistol"),
    [-1716589765] = XORString("Pistol .50"),
    [-1076751822] = XORString("SNS Pistol"),
    [-771403250] = XORString("SNS Pistol Mk II"),
    [584646201] = XORString("APP Pistol"),
    [-1045183535] = XORString("Heavy Revolver"),
    [-879347409] = XORString("Heavy Revolver Mk II"),
    [911657153] = XORString("Stun Gun"),
    [1198879012] = XORString("Flare Gun"),
    [-598887786] = XORString("Marksman Pistol"),
    [-2009644972] = XORString("Vintage Pistol"),
    [137902532] = XORString("Ceramic Pistol"),
    [-1746263880] = XORString("Navy Revolver"),
    [-1853920116] = XORString("Perico Pistol"),
    
    -- Submachine Guns
    [324215364] = XORString("Micro SMG"),
    [736523883] = XORString("SMG"),
    [2024373456] = XORString("SMG Mk II"),
    [-270015777] = XORString("Assault SMG"),
    [171789620] = XORString("Combat PDW"),
    [-619010992] = XORString("Machine Pistol"),
    [-1121678507] = XORString("Mini SMG"),
    
    -- Assault Rifles
    [-1074790547] = XORString("Assault Rifle"),
    [961495388] = XORString("Assault Rifle Mk II"),
    [-2084633992] = XORString("Carbine Rifle"),
    [-86904375] = XORString("Carbine Rifle Mk II"),
    [-1357824103] = XORString("Advanced Rifle"),
    [-1063057011] = XORString("Special Carbine"),
    [-1768145561] = XORString("Special Carbine Mk II"),
    [-2066285827] = XORString("Bullpup Rifle"),
    [1785463520] = XORString("Bullpup Rifle Mk II"),
    [-1658906650] = XORString("Military Rifle"),
    [2132975508] = XORString("Service Carbine"),
    
    -- Light Machine Guns
    [-1660422300] = XORString("MG"),
    [2144741730] = XORString("Combat MG"),
    [-608341376] = XORString("Combat MG Mk II"),
    [-1355376991] = XORString("Gusenberg Sweeper"),
    
    -- Shotguns
    [487013001] = XORString("Pump Shotgun"),
    [1432025498] = XORString("Pump Shotgun Mk II"),
    [2017895192] = XORString("Sawed-Off Shotgun"),
    [-1654528753] = XORString("Bullpup Shotgun"),
    [-494615257] = XORString("Assault Shotgun"),
    [-1466123874] = XORString("Double Barrel Shotgun"),
    [984333226] = XORString("Heavy Shotgun"),
    [-275439685] = XORString("Musket"),
    [-538741184] = XORString("Sweeper Shotgun"),
    
    -- Sniper Rifles
    [100416529] = XORString("Sniper Rifle"),
    [205991906] = XORString("Heavy Sniper"),
    [177293209] = XORString("Heavy Sniper Mk II"),
    [-952879014] = XORString("Marksman Rifle"),
    [1785463520] = XORString("Marksman Rifle Mk II"),
    
    -- Heavy Weapons
    [-1813897027] = XORString("Grenade Launcher"),
    [1305664598] = XORString("Compact Grenade Launcher"),
    [-1312131151] = XORString("RPG"),
    [-1238556825] = XORString("Firework Launcher"),
    [2138347493] = XORString("Railgun"),
    [1119849093] = XORString("Minigun"),
    [-1465727896] = XORString("Homing Launcher"),
    [1834241177] = XORString("Widowmaker"),
    [-275439685] = XORString("Compact EMP Launcher"),
    
    -- Melee Weapons
    [-102323637] = XORString("Knife"),
    [1737195953] = XORString("Nightstick"),
    [1317494643] = XORString("Hammer"),
    [-1786099057] = XORString("Bat"),
    [-2067956739] = XORString("Crowbar"),
    [1141786504] = XORString("Golf Club"),
    [-102973651] = XORString("Bottle"),
    [-656458692] = XORString("Dagger"),
    [-581044007] = XORString("Hatchet"),
    [-1951375401] = XORString("Machete"),
    [-538741184] = XORString("Flashlight"),
    [910830060] = XORString("Switchblade"),
    [-853065399] = XORString("Battle Axe"),
    [-1810795771] = XORString("Pool Cue"),
    [940833800] = XORString("Wrench"),
    [-209319155] = XORString("Stone Hatchet"),
    
    -- Throwables
    [615608432] = XORString("Molotov"),
    [101631238] = XORString("Grenade"),
    [883325847] = XORString("Flare Gun"),
    [-72657034] = XORString("Pipe Bomb"),
    [-1169823560] = XORString("Sticky Bomb"),
    [-37975472] = XORString("Smoke Grenade"),
    [600439132] = XORString("Ball"),
    [1233104067] = XORString("Snowball"),
    [-1420407917] = XORString("Proximity Mine"),
    
    -- Special
    [-1600701090] = XORString("Rocket Launcher"),
    [1198256469] = XORString("Compact Launcher")
}

local function _02C5SS3T(_0xped)
    if not DoesEntityExist(_0xped) or IsEntityDead(_0xped) then return end

    -- Cache bone screen positions per ped
    local boneCache = {}

    local function GetBoneScreenPos(boneId)
        if boneCache[boneId] then return table.unpack(boneCache[boneId]) end

        local boneIndex = GetPedBoneIndex(_0xped, boneId)
        if boneIndex == -1 then return nil, nil end

        local pos = GetWorldPositionOfEntityBone(_0xped, boneIndex)
        if not pos then return nil, nil end

        local onScreen, sx, sy = World3dToScreen2d(pos.x, pos.y, pos.z)
        if onScreen then
            boneCache[boneId] = {sx, sy}
            return sx, sy
        end

        return nil, nil
    end

    local bones = {
        {0x796E, 0x9995}, -- Head → neck
        {0x9995, 0x5C01}, -- neck → Chest
        {0x5C01, 0xE39F}, -- Chest → Left Thigh
        {0x5C01, 0xCA72}, -- Chest → Right Thigh
        {0xE39F, 0xB3FE}, -- Left Thigh → Left knee
        {0xCA72, 0x3FCF}, -- Right Thigh → Right knee
        {0xB3FE, 0x3779}, -- Left knee → Left Foot
        {0x3FCF, 0xCC4D}, -- Right knee → Right Foot
        {0x9995, 0xFCD9}, -- neck → Left Clavicle
        {0x9995, 0x29D2}, -- neck → Right Clavicle
        {0xFCD9, 0xB1C5}, -- Left Clavicle → Left Upper Arm
        {0x29D2, 0x9D4D}, -- Right Clavicle → Right Upper Arm
        {0xB1C5, 0xEEEB}, -- Left Upper Arm → Left Forearm
        {0x9D4D, 0x6E5C}, -- Right Upper Arm → Right Forearm
        {0xEEEB, 0x49D9}, -- Left Forearm → Left Hand
        {0x6E5C, 0xDEAD}, -- Right Forearm → Right Hand
    }

    for _, pair in ipairs(bones) do
        local sx1, sy1 = GetBoneScreenPos(pair[1])
        local sx2, sy2 = GetBoneScreenPos(pair[2])

        if sx1 and sy1 and sx2 and sy2 then
            DrawLine_2d(sx1, sy1, sx2, sy2, 0.0006, XorMenu.rgb.r, XorMenu.rgb.g, XorMenu.rgb.b, XorMenu.rgb.a)
        end
    end
end

-- Function to draw a health ESP bar for a given ped at screen coordinates.

-- Function to draw a health ESP bar for a given ped at screen coordinates.
-- _0xposX and _0xposY represent the center position where the bar is drawn,
local function _0x4D2F7E(_0xped, _0xposX, _0xposY, _0xwidth, _0xheight)
    local pedCoords = GetEntityCoords(_0xped)
    local camCoords = GetGameplayCamCoord()
    local dist = #(pedCoords - camCoords)
    if dist < 1.5 then return end

    local scale = (1.0 / dist * 5.0) + 0.125
    local scaledWidth = _0xwidth * scale
    local scaledHeight = _0xheight * scale

    -- Use a fixed, non-scaling X offset
    local offsetX = -0.035
    local baseX = _0xposX + offsetX
    local centerY = _0xposY  -- This is the center of the background

    local _0xhealth = GetEntityHealth(_0xped)
    local _0xmaxHealth = 200.0
    local _0xhealthRatio = math.max(_0xhealth, 0) / _0xmaxHealth

    -- Colors for the health fill
    local _0xhealthR = math.floor((1 - _0xhealthRatio) * 255)
    local _0xhealthG = math.floor(_0xhealthRatio * 255)
    local _0xhealthB = 0
    local _0xhealthA = 200

    -- Background color (if no health, show red)
    local bgHealthR, bgHealthG, bgHealthB = 0, 0, 0
    if _0xhealthRatio <= 0 then
        bgHealthR, bgHealthG, bgHealthB = 255, 0, 0
    end

    -- Draw the background (full bar)
    DrawRect(baseX + scaledWidth / 2, centerY  + 0.005, scaledWidth, scaledHeight, bgHealthR, bgHealthG, bgHealthB, 200)

    -- Now scale the filled portion vertically.
    local healthBarHeight = scaledHeight * _0xhealthRatio
    -- Anchor the bar at the bottom of the background:
    local backgroundBottom = centerY + (scaledHeight / 2)
    local healthBarCenterY = backgroundBottom - (healthBarHeight / 2)

    DrawRect(baseX + scaledWidth / 2, healthBarCenterY  + 0.005, scaledWidth, healthBarHeight, _0xhealthR, _0xhealthG, _0xhealthB, _0xhealthA)
end

local function _0x4D2F7C(_0xped, _0xposX, _0xposY, _0xwidth, _0xheight)
    local pedCoords = GetEntityCoords(_0xped)
    local camCoords = GetGameplayCamCoord()
    local dist = #(pedCoords - camCoords)
    if dist < 1.5 then return end

    local scale = (1.0 / dist * 5.0) + 0.125
    local scaledWidth = _0xwidth * scale
    local scaledHeight = _0xheight * scale

    local offsetX = -0.035
    local baseX = _0xposX + offsetX
    -- Position the armor bar directly below the health bar:
    local centerY = _0xposY + scaledHeight + (0.0025 * scale)

    local _0xarmor = GetPedArmour(_0xped)
    local _0xmaxArmor = 100.0
    local _0xarmorRatio = math.max(_0xarmor, 0) / _0xmaxArmor

    local _0xarmorR = math.floor((1 - _0xarmorRatio) * 255)
    local _0xarmorG = 0
    local _0xarmorB = math.floor(_0xarmorRatio * 255)
    local _0xarmorA = 200

    local bgArmorR, bgArmorG, bgArmorB = 0, 0, 0
    if _0xarmorRatio <= 0 then
        bgArmorR, bgArmorG, bgArmorB = 0, 0, 0
    end

    -- Draw the full armor background:
    DrawRect(baseX + scaledWidth / 2, centerY + 0.0025, scaledWidth, scaledHeight, bgArmorR, bgArmorG, bgArmorB, 200)

    local armorBarHeight = scaledHeight * _0xarmorRatio
    local armorBarCenterY = centerY + (scaledHeight / 2) - (armorBarHeight / 2)

    DrawRect(baseX + scaledWidth / 2, armorBarCenterY + 0.0025, scaledWidth, armorBarHeight, XorMenu.rgb.r, XorMenu.rgb.g, XorMenu.rgb.b, _0xarmorA)
end


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if XorMenu.esp then
            -- Process all active players
            for _, _0xplayer in ipairs(GetActivePlayers()) do
                local _0xped = GetPlayerPed(_0xplayer)
                local isSelf = (_0xped == PlayerPedId())
                if (isSelf and XorMenu.espconfig.player) or (not isSelf) then
                    if XorMenu.espconfig.skeletons then
                        _02C5SS3T(_0xped)
                    end

                    local _0xhealth = GetEntityHealth(_0xped)
                    local _0xcoords = GetEntityCoords(_0xped)
                    
                    -- Build the ESP data string
                    local _0xdata = ""
                    local _0xweaponHash = GetSelectedPedWeapon(_0xped)
                    local _0xweaponName = weaponNames[_0xweaponHash] or XORString("Unknown Weapon (") .. tostring(_0xweaponHash) .. XORString(")")
                    if XorMenu.espconfig.datacfg.main then
                        _0xdata = XORString("Player Name: ") .. XORString(GetPlayerName(_0xplayer)) .. "\n" ..
                                 XORString("Player Id: ") .. _0xplayer .. "\n" ..
                                 XORString("Server Id: ") .. GetPlayerServerId(_0xplayer) .. "\n" ..
                                 XORString("Alive status: ") .. (_0xhealth > 0 and XORString("Alive") or XORString("Dead")) .. "\n" ..
                                 XORString("Weapon: ") .. XORString(_0xweaponName) .. "\n"
                    end

                    if XorMenu.espconfig.datacfg.name then
                        _0xdata = _0xdata .. XORString("Player Name: ") .. XORString(GetPlayerName(_0xplayer)) .. "\n"
                    end
                    
                    if XorMenu.espconfig.datacfg.IDs then
                        _0xdata = _0xdata .. XORString("Player Id: ") .. _0xplayer .. "\n" ..
                                            XORString("Server Id: ") .. GetPlayerServerId(_0xplayer) .. "\n"
                    end
                    
                    if XorMenu.espconfig.datacfg.status then
                        _0xdata = _0xdata .. XORString("Alive status: ") .. 
                                            ((_0xhealth > 0 and XORString("Alive")) or XORString("Dead")) .. "\n"
                    end
                    -- Append weapon information if enabled
                    if XorMenu.espconfig.datacfg.weapon then
                        _0xdata = _0xdata .. "\n" .. XORString("Weapon: ") .. XORString(_0xweaponName)
                    end

                    -- Append vehicle information if the player is in a vehicle
                    if IsPedInAnyVehicle(_0xped, false) then
                        local _0xveh = GetVehiclePedIsIn(_0xped, false)
                        local _0xvehModel = GetEntityModel(_0xveh)
                        local _0xvehName = GetDisplayNameFromVehicleModel(_0xvehModel)
                        _0xdata = _0xdata .. "\n" .. XORString("Vehicle: ") .. _0xvehName
                    end

                    local _0xplayerPos = GetEntityCoords(PlayerPedId())
                    local _0xdistance = _0x6D9C7E(_0xplayerPos, _0xcoords)
                    
                    if XorMenu.espconfig.datacfg.distance then
                        _0xdata = _0xdata .. "\n" .. XORString("Distance: ") .. string.format("%.2f", _0xdistance) .. XORString(" meters")
                    end

                    if XorMenu.espconfig.datacfg.health then
                        _0xdata = _0xdata .. "\n" .. XORString("Health: ") .. tostring(_0xhealth)
                    end

                    if XorMenu.espconfig.data then
                        _0xC86A4B(_0xcoords.x, _0xcoords.y, _0xcoords.z + 1.0, _0xdata, _0xdistance)
                    end

                    if XorMenu.espconfig.tracers then
                        _0x6E72A3(_0xcoords)
                    end

                    -- Draw the outline box and health bar if the player is on screen
                    local _0xonScreen, _0xscreenX, _0xscreenY = World3dToScreen2d(_0xcoords.x, _0xcoords.y, _0xcoords.z)
                    if _0xonScreen then
                        local _0xboxWidth = 0.05
                        local _0xboxHeight = _0xboxWidth * 4
                        if XorMenu.espconfig.boxes then
                            DrawBoxAroundEntity(_0xped)
                        end
                        -- Draw the health bar to the right of the outline box
                        if XorMenu.espconfig.health then
                            local _0xmargin = 0.02
                            local _0xhealthPosX = _0xscreenX + _0xboxWidth / 2 + _0xmargin
                            local _0xhealthPosY = _0xscreenY  -- align vertically with the box center
                            _0x4D2F7E(_0xped, _0xhealthPosX, _0xhealthPosY, 0.005, 0.1)
                        end
                        if XorMenu.espconfig.armour then
                            local _0xmargin = 0.02
                            local _0xarmourPosX = _0xscreenX + _0xboxWidth / 2 + _0xmargin
                            local _0xarmourPosY = _0xscreenY  -- align vertically with the box center
                            _0x4D2F7C(_0xped, _0xarmourPosX, _0xarmourPosY, 0.005, 0.1)
                        end
                    end
                end
            end

            -- Process NPCs if NPC ESP is enabled
            if XorMenu.espconfig.npcs then
                local _0xplayerPos = GetEntityCoords(PlayerPedId())
                for _, _0xNPC in ipairs(GetGamePool('CPed')) do
                    if not IsPedAPlayer(_0xNPC) then
                        local _0xhealth = GetEntityHealth(_0xNPC)
                        local _0xcoords = GetEntityCoords(_0xNPC)
                        local _0xdistance = _0x6D9C7E(_0xplayerPos, _0xcoords)
                        
                        local _0xdata = XORString("NPC") .. "\n" ..
                                       XORString("HP: ") .. _0xhealth .. "\n" ..
                                       XORString("Distance: ") .. string.format("%.2f", _0xdistance) .. XORString(" meters")
                        
                        local _0xnpcWeaponHash = GetSelectedPedWeapon(_0xNPC)
                        local _0xnpcWeaponName = weaponNames[_0xnpcWeaponHash] or XORString("Unknown Weapon (") .. tostring(_0xnpcWeaponHash) .. XORString(")")
                        if XorMenu.espconfig.datacfg.weapon then
                            _0xdata = _0xdata .. "\n" .. XORString("Weapon: ") .. XORString(_0xnpcWeaponName)
                        end

                        if XorMenu.espconfig.skeletons then
                            _02C5SS3T(_0xNPC)
                        end

                        if IsPedInAnyVehicle(_0xNPC, false) then
                            local _0xveh = GetVehiclePedIsIn(_0xNPC, false)
                            local _0xvehModel = GetEntityModel(_0xveh)
                            local _0xvehName = GetDisplayNameFromVehicleModel(_0xvehModel)
                            _0xdata = _0xdata .. "\n" .. XORString("Vehicle: ") .. XORString(_0xvehName)
                        end

                        if XorMenu.espconfig.tracers then
                            _0x6E72A3(_0xcoords)
                        end

                        if XorMenu.espconfig.data then
                            _0xC86A4B(_0xcoords.x, _0xcoords.y, _0xcoords.z + 1.0, _0xdata, _0xdistance)
                        end

                        local _0xonScreen, _0xscreenX, _0xscreenY = World3dToScreen2d(_0xcoords.x, _0xcoords.y, _0xcoords.z)
                        if _0xonScreen then
                            local _0xboxWidth = 0.05
                            local _0xboxHeight = _0xboxWidth * 4
                            if XorMenu.espconfig.boxes then
                                DrawBoxAroundEntity(_0xNPC)
                            end
                            if XorMenu.espconfig.health then
                                local _0xmargin = 0.02
                                local _0xhealthPosX = _0xscreenX + _0xboxWidth / 2 + _0xmargin
                                local _0xhealthPosY = _0xscreenY  -- align vertically with the box center
                                _0x4D2F7E(_0xNPC, _0xhealthPosX, _0xhealthPosY, 0.005, 0.1)
                            end
                            if XorMenu.espconfig.armour then
                                local _0xmargin = 0.02
                                local _0xarmourPosX = _0xscreenX + _0xboxWidth / 2 + _0xmargin
                                local _0xarmourPosY = _0xscreenY  -- align vertically with the box center
                                _0x4D2F7C(_0xNPC, _0xarmourPosX, _0xarmourPosY, 0.005, 0.1)
                            end
                        end
                    end
                end
            end
        end
    end
end)

function TeleportToWaypoint()
    local ped = GetPlayerPed(-1)
    local blip = GetFirstBlipInfoId(8) -- 8 = Waypoint

    if DoesBlipExist(blip) then
        local x, y, _ = table.unpack(GetBlipInfoIdCoord(blip))
        local groundZ = nil

        -- Try to get ground height accurately
        for height = 1, 1000 do
            RequestCollisionAtCoord(x, y, height + 0.0)
            Wait(1)
            local success, zCheck = GetGroundZFor_3dCoord(x, y, height + 0.0, 0)
            if success and zCheck > 0.0 then
                groundZ = zCheck + 1.0
                break
            end
        end

        -- If still no ground, use shape test for accurate detection
        if not groundZ then
            local startCoords = vector3(x, y, 1000.0)
            local endCoords = vector3(x, y, 0.0)
            local rayHandle = StartShapeTestRay(startCoords, endCoords, 1, ped, 0)
            local _, hit, hitCoords = GetShapeTestResult(rayHandle)
            if hit then
                groundZ = hitCoords.z + 1.0
            else
                groundZ = 1000.0 -- absolute fallback
            end
        end

        -- Teleport using native
        Citizen.InvokeNative(0x239A3351AC1DA385, ped, x, y, groundZ, true, true, true)
        Citizen.InvokeNative(0x428CA6DBD1094446, ped, true)

        XorVariables.Push("~g~Teleported to waypoint.")
    else
        XorVariables.Push("~r~No waypoint set!")
    end
end

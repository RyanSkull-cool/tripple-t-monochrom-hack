

-- Scream And Run thing

-- LocalScript inside StarterPlayer > StarterPlayerScripts



local Players = game:GetService("Players")

local TweenService = game:GetService("TweenService")

local UserInputService = game:GetService("UserInputService")

local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")



local player = Players.LocalPlayer

local playerGui = player:WaitForChild("PlayerGui")



--==================================================

-- SETTINGS

--==================================================



local GUI_TITLE = "tripple t monochrom hack"



local MONSTER_NAME = "VER"
local TARGET_MODEL_NAME = "monochrome"
local ESCAPE_DOOR_NAME = "Cube.007"
local CODE_NOTE_NAME = "CodeNote"
local KEY_NAMES = { "HiddenKey1", "HiddenKey2", "HiddenKey3", "HiddenKey4" }
local HALLOWEEN_FOLDER_NAME = "HalloweenMedallions"
local HALLOWEEN_NAMES = { "Bat", "Cauldron", "Ghost", "Pumpkin", "Web" }



local METERS_PER_STUD = 0.28

local UPDATE_INTERVAL = 0.15



local COLORS = {
    Monster = Color3.fromRGB(255, 55, 55),
    ["Escape Door"] = Color3.fromRGB(40, 145, 255),
    Keys = Color3.fromRGB(0, 255, 90),
    Code = Color3.fromRGB(255, 225, 0),
    ["Halloween Quest"] = Color3.fromRGB(255, 140, 0),
    Closets = Color3.fromRGB(255, 80, 190),
    Players = Color3.fromRGB(255, 255, 255),
}


local BACKGROUND = Color3.fromRGB(20, 20, 25)

local PANEL_COLOR = Color3.fromRGB(29, 29, 36)

local ROW_COLOR = Color3.fromRGB(39, 39, 48)

local ACCENT_COLOR = Color3.fromRGB(255, 65, 65)

local TEXT_COLOR = Color3.fromRGB(245, 245, 250)

local MUTED_COLOR = Color3.fromRGB(155, 155, 170)

local OFF_COLOR = Color3.fromRGB(220, 55, 65)

local ON_COLOR = Color3.fromRGB(0, 205, 105)



--==================================================

-- STATE

--==================================================



local closed = false

local minimized = false

local updateAccumulator = 0



local espEnabled = {
    Monster = false,
    ["Escape Door"] = false,
    Keys = false,
    Code = false,
    ["Halloween Quest"] = false,
    Closets = false,
    Players = false,
}

local textEnabled = {
    Monster = true,
    ["Escape Door"] = true,
    Keys = true,
    Code = true,
    ["Halloween Quest"] = true,
    Closets = true,
    Players = true,
}

local monsterObjects = {}
local doorObjects = {}
local namedESPObjects = { Keys = {}, Code = {}, ["Halloween Quest"] = {}, Closets = {} }
local refreshNamedESP
local playerObjects = {}

local toggleButtons = {}
local textToggleButtons = {}
local tabButtons = {}
local tabPages = {}


--==================================================

-- REMOVE OLD GUI

--==================================================



local oldGui = playerGui:FindFirstChild("ScreamAndRunGui")



if oldGui then

    oldGui:Destroy()

end



--==================================================

-- GUI HELPERS

--==================================================



local screenGui = Instance.new("ScreenGui")

screenGui.Name = "ScreamAndRunGui"

screenGui.ResetOnSpawn = false

screenGui.IgnoreGuiInset = true

screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

screenGui.Parent = playerGui



local function create(className, properties, parent)

    local object = Instance.new(className)



    for property, value in pairs(properties) do

        object[property] = value

    end



    object.Parent = parent

    return object

end



local function addCorner(object, radius)

    create("UICorner", {

        CornerRadius = UDim.new(0, radius or 8),

    }, object)

end



local function addStroke(object, color, thickness, transparency)

    return create("UIStroke", {

        Color = color or ACCENT_COLOR,

        Thickness = thickness or 1,

        Transparency = transparency or 0,

    }, object)

end



local function tween(object, duration, properties, style, direction)

    local animation = TweenService:Create(

        object,

        TweenInfo.new(

            duration,

            style or Enum.EasingStyle.Quint,

            direction or Enum.EasingDirection.Out

        ),

        properties

    )



    animation:Play()

    return animation

end



--==================================================

-- MAIN WINDOW

--==================================================



local main = create("Frame", {

    Name = "MainWindow",

    AnchorPoint = Vector2.new(0.5, 0.5),

    Position = UDim2.new(0.5, 0, 0.5, 0),

    Size = UDim2.fromOffset(490, 400),

    BackgroundColor3 = BACKGROUND,

    BorderSizePixel = 0,

    ClipsDescendants = true,

}, screenGui)



addCorner(main, 12)

addStroke(main, Color3.fromRGB(70, 70, 85), 1, 0.15)



local originalSize = main.Size



--==================================================

-- HEADER

--==================================================



local header = create("Frame", {

    Name = "Header",

    Size = UDim2.new(1, 0, 0, 48),

    BackgroundColor3 = PANEL_COLOR,

    BorderSizePixel = 0,

}, main)



create("TextLabel", {

    Name = "Title",

    Position = UDim2.fromOffset(15, 0),

    Size = UDim2.new(1, -120, 1, 0),

    BackgroundTransparency = 1,

    Text = GUI_TITLE,

    TextColor3 = TEXT_COLOR,

    TextSize = 18,

    Font = Enum.Font.GothamBold,

    TextXAlignment = Enum.TextXAlignment.Left,

}, header)



local minimizeButton = create("TextButton", {

    Name = "Minimize",

    Position = UDim2.new(1, -77, 0, 8),

    Size = UDim2.fromOffset(30, 30),

    BackgroundColor3 = ROW_COLOR,

    BorderSizePixel = 0,

    Text = "—",

    TextColor3 = TEXT_COLOR,

    TextSize = 18,

    Font = Enum.Font.GothamBold,

    AutoButtonColor = false,

}, header)



addCorner(minimizeButton, 7)



local closeButton = create("TextButton", {

    Name = "Close",

    Position = UDim2.new(1, -39, 0, 8),

    Size = UDim2.fromOffset(30, 30),

    BackgroundColor3 = ACCENT_COLOR,

    BorderSizePixel = 0,

    Text = "X",

    TextColor3 = Color3.new(1, 1, 1),

    TextSize = 16,

    Font = Enum.Font.GothamBold,

    AutoButtonColor = false,

}, header)



addCorner(closeButton, 7)



closeButton.MouseEnter:Connect(function()

    if not closed then

        tween(closeButton, 0.12, {

            BackgroundColor3 = Color3.fromRGB(255, 105, 105),

        })

    end

end)



closeButton.MouseLeave:Connect(function()

    if not closed then

        tween(closeButton, 0.12, {

            BackgroundColor3 = ACCENT_COLOR,

        })

    end

end)



--==================================================

-- TABS

--==================================================



local tabBar = create("Frame", {

    Name = "TabBar",

    Position = UDim2.fromOffset(10, 57),

    Size = UDim2.new(1, -20, 0, 38),

    BackgroundTransparency = 1,

}, main)



create("UIListLayout", {

    FillDirection = Enum.FillDirection.Horizontal,

    HorizontalAlignment = Enum.HorizontalAlignment.Left,

    VerticalAlignment = Enum.VerticalAlignment.Center,

    Padding = UDim.new(0, 7),

    SortOrder = Enum.SortOrder.LayoutOrder,

}, tabBar)



local content = create("Frame", {

    Name = "Content",

    Position = UDim2.fromOffset(10, 103),

    Size = UDim2.new(1, -20, 1, -113),

    BackgroundTransparency = 1,

}, main)



local function createTab(name, label, order)

    local button = create("TextButton", {

        Name = name .. "Tab",

        Size = UDim2.new(1 / 3, -5, 1, 0),

        BackgroundColor3 = ROW_COLOR,

        BorderSizePixel = 0,

        Text = label,

        TextColor3 = MUTED_COLOR,

        TextSize = 13,

        Font = Enum.Font.GothamBold,

        AutoButtonColor = false,

        LayoutOrder = order,

    }, tabBar)



    addCorner(button, 7)



    local page = create("ScrollingFrame", {

        Name = name .. "Page",

        Size = UDim2.fromScale(1, 1),

        BackgroundTransparency = 1,

        BorderSizePixel = 0,

        ScrollBarThickness = 4,

        ScrollBarImageColor3 = ACCENT_COLOR,

        CanvasSize = UDim2.new(),

        AutomaticCanvasSize = Enum.AutomaticSize.Y,

        Visible = false,

    }, content)



    create("UIListLayout", {

        SortOrder = Enum.SortOrder.LayoutOrder,

        Padding = UDim.new(0, 6),

    }, page)



    create("UIPadding", {

        PaddingTop = UDim.new(0, 3),

        PaddingBottom = UDim.new(0, 6),

        PaddingRight = UDim.new(0, 5),

    }, page)



    tabButtons[name] = button

    tabPages[name] = page



    return button, page

end



local espTabButton, espPage = createTab("ESP", "👁️  ESP", 1)

local playerTabButton, playerPage = createTab("Player", "🏃  Player", 2)

local otherTabButton, otherPage = createTab("Other", "⚙️  Other", 3)



local function selectTab(name)

    if closed then

        return

    end



    for tabName, button in pairs(tabButtons) do

        local selected = tabName == name



        tween(button, 0.15, {

            BackgroundColor3 = selected and ACCENT_COLOR or ROW_COLOR,

            TextColor3 = selected and Color3.new(1, 1, 1) or MUTED_COLOR,

        })



        tabPages[tabName].Visible = selected

    end

end



espTabButton.Activated:Connect(function()

    selectTab("ESP")

end)



playerTabButton.Activated:Connect(function()

    selectTab("Player")

end)



otherTabButton.Activated:Connect(function()

    selectTab("Other")

end)



--==================================================

-- DISTANCE HELPERS

--==================================================



local function getCharacterRoot(character)

    if not character then

        return nil

    end



    return character:FindFirstChild("HumanoidRootPart")

        or character:FindFirstChildWhichIsA("BasePart")

end



local function getDistanceInMeters(part)

    local root = getCharacterRoot(player.Character)



    if not root or not part or not part.Parent then

        return nil

    end



    return (root.Position - part.Position).Magnitude * METERS_PER_STUD

end



--==================================================

-- ESP OBJECT CREATION

--==================================================



local function makeHighlight(model, color)

    local highlight = Instance.new("Highlight")

    highlight.Name = "ScreamRunESPHighlight"

    highlight.Adornee = model

    highlight.FillColor = color

    highlight.FillTransparency = 0.5

    highlight.OutlineColor = color

    highlight.OutlineTransparency = 1

    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

    highlight.Parent = screenGui



    return highlight

end



local function makeBillboard(part, labelText, color, showText)

    local billboard = Instance.new("BillboardGui")

    billboard.Name = "ScreamRunESPLabel"

    billboard.Adornee = part

    billboard.Size = UDim2.fromOffset(190, 42)

    billboard.StudsOffset = Vector3.new(0, 3, 0)

    billboard.AlwaysOnTop = true

    billboard.MaxDistance = 100000

    billboard.Enabled = showText

    billboard.Parent = screenGui



    local label = Instance.new("TextLabel")

    label.Name = "Label"

    label.Size = UDim2.fromScale(1, 1)

    label.BackgroundTransparency = 1

    label.Text = labelText

    label.TextColor3 = color

    label.TextStrokeColor3 = Color3.new(0, 0, 0)

    label.TextStrokeTransparency = 0.15

    label.TextSize = 14

    label.Font = Enum.Font.GothamBold

    label.TextWrapped = true

    label.Parent = billboard



    return billboard, label

end



local function updateDistanceLabel(label, part, labelText)

    if not label or not label.Parent then

        return

    end



    local distance = getDistanceInMeters(part)



    if distance then

        label.Text = string.format("%s\n%.1f meters", labelText, distance)

    else

        label.Text = labelText

    end

end



local function applyTextVisibility(objects, settingName)

    if not objects then

        return

    end



    local show = textEnabled[settingName] == true



    if objects.billboard then

        objects.billboard.Enabled = show

    end

end



--==================================================

-- MONSTER ESP

--==================================================



local function removeMonsterESP(model)

    local objects = monsterObjects[model]



    if not objects then

        return

    end



    if objects.highlight then

        objects.highlight:Destroy()

    end



    if objects.billboard then

        objects.billboard:Destroy()

    end



    monsterObjects[model] = nil

end



local function addMonsterESP(model)

    if closed or not espEnabled["Monster"] then

        return

    end



    if not model:IsA("Model") or model.Name ~= MONSTER_NAME then

        return

    end



    if not model:IsDescendantOf(workspace) or monsterObjects[model] then

        return

    end



    local part = model.PrimaryPart

        or model:FindFirstChild("HumanoidRootPart", true)

        or model:FindFirstChildWhichIsA("BasePart", true)



    if not part then

        return

    end



    local highlight = makeHighlight(model, COLORS.Monster)



    local billboard, label = makeBillboard(

        part,

        "Monster",

        COLORS.Monster,

        textEnabled["Monster"]

    )



    monsterObjects[model] = {

        highlight = highlight,

        billboard = billboard,

        label = label,

        part = part,

        labelText = "Monster",

    }



    updateDistanceLabel(label, part, "Monster")

end



local function refreshMonsterESP()

    if not espEnabled["Monster"] then

        for model in pairs(monsterObjects) do

            removeMonsterESP(model)

        end

        return

    end



    for _, object in ipairs(workspace:GetDescendants()) do

        if object:IsA("Model") and object.Name == MONSTER_NAME then

            addMonsterESP(object)

        end

    end

end



--==================================================
-- ESCAPE DOOR ESP
-- Highlights workspace.monochrome.Cube.007.
--==================================================

local function removeDoorESP(object)
    local objects = doorObjects[object]
    if not objects then return end
    if objects.highlight then objects.highlight:Destroy() end
    if objects.billboard then objects.billboard:Destroy() end
    doorObjects[object] = nil
end

local function addDoorESP(object)
    if closed or not espEnabled["Escape Door"] then return end
    local targetModel = workspace:FindFirstChild(TARGET_MODEL_NAME)
    if not targetModel or not object or object.Name ~= ESCAPE_DOOR_NAME
        or not object:IsA("BasePart") or not object:IsDescendantOf(targetModel) then return end
    if doorObjects[object] then return end
    local highlight = makeHighlight(object, COLORS["Escape Door"])
    local billboard, label = makeBillboard(object, "Escape Door", COLORS["Escape Door"], textEnabled["Escape Door"])
    doorObjects[object] = { highlight = highlight, billboard = billboard, label = label, part = object, labelText = "Escape Door" }
    updateDistanceLabel(label, object, "Escape Door")
end

local function refreshDoorESP()
    if not espEnabled["Escape Door"] then
        for object in pairs(doorObjects) do removeDoorESP(object) end
        return
    end
    for object in pairs(doorObjects) do
        if not object:IsDescendantOf(workspace) then removeDoorESP(object) end
    end
    local targetModel = workspace:FindFirstChild(TARGET_MODEL_NAME)
    local object = targetModel and targetModel:FindFirstChild(ESCAPE_DOOR_NAME, true)
    if object then addDoorESP(object) end
end

--==================================================
-- KEYS AND CODE ESP
--==================================================

local function removeNamedESP(kind, object)
    local set = namedESPObjects[kind]
    local objects = set and set[object]
    if not objects then return end
    if objects.highlight then objects.highlight:Destroy() end
    if objects.billboard then objects.billboard:Destroy() end
    set[object] = nil
end

local function addNamedESP(kind, object)
    local set = namedESPObjects[kind]
    if closed or not espEnabled[kind] or not set or not object then return end
    if kind == "Halloween Quest" then
        local folder = workspace:FindFirstChild(HALLOWEEN_FOLDER_NAME)
        if not folder or not object:IsDescendantOf(folder) then return end
        local valid = false
        for _, objectName in ipairs(HALLOWEEN_NAMES) do
            if object.Name == objectName and (object:IsA("Model") or object:IsA("BasePart")) then valid = true; break end
        end
        if not valid then return end
    else
        local targetModel = workspace:FindFirstChild(TARGET_MODEL_NAME)
        if not targetModel or not object:IsDescendantOf(targetModel) then return end
        if kind == "Closets" then
            if not (object:IsA("Model") or object:IsA("BasePart")) or not object:FindFirstChild("HidePromptPoint") then return end
        elseif kind == "Code" and (object.Name ~= CODE_NOTE_NAME or not object:IsA("BasePart")) then
            return
        elseif kind == "Keys" then
            local valid = false
            for _, keyName in ipairs(KEY_NAMES) do
                if object.Name == keyName and (object:IsA("Model") or object:IsA("BasePart")) then valid = true; break end
            end
            if not valid then return end
        end
    end
    if set[object] then return end
    local part = object:IsA("BasePart") and object or object.PrimaryPart or object:FindFirstChildWhichIsA("BasePart", true)
    if not part then return end
    local color = COLORS[kind]
    local highlight = makeHighlight(object, color)
    local billboard, label = makeBillboard(part, kind, color, textEnabled[kind])
    set[object] = { highlight = highlight, billboard = billboard, label = label, part = part, labelText = kind }
    updateDistanceLabel(label, part, kind)
end

refreshNamedESP = function(kind)
    local set = namedESPObjects[kind]
    if not set then return end
    if not espEnabled[kind] then
        for object in pairs(set) do removeNamedESP(kind, object) end
        return
    end
    if kind == "Halloween Quest" then
        local folder = workspace:FindFirstChild(HALLOWEEN_FOLDER_NAME)
        for object in pairs(set) do
            if not folder or not object:IsDescendantOf(folder) then removeNamedESP(kind, object) end
        end
        if not folder then return end
        for _, objectName in ipairs(HALLOWEEN_NAMES) do
            local object = folder:FindFirstChild(objectName)
            if object then addNamedESP(kind, object) end
        end
        return
    end
    local targetModel = workspace:FindFirstChild(TARGET_MODEL_NAME)
    for object in pairs(set) do
        if not targetModel or not object:IsDescendantOf(targetModel) then removeNamedESP(kind, object) end
    end
    if not targetModel then return end
    if kind == "Code" then
        local object = targetModel:FindFirstChild(CODE_NOTE_NAME, true)
        if object then addNamedESP(kind, object) end
    elseif kind == "Keys" then
        for _, keyName in ipairs(KEY_NAMES) do
            local object = targetModel:FindFirstChild(keyName, true)
            if object then addNamedESP(kind, object) end
        end
    elseif kind == "Closets" then
        for _, object in ipairs(targetModel:GetDescendants()) do
            if (object:IsA("Model") or object:IsA("BasePart")) and object:FindFirstChild("HidePromptPoint") then
                addNamedESP(kind, object)
            end
        end
    end
end

--==================================================

-- PLAYER ESP

-- White highlight, displays each player's name.

-- Never creates ESP for the local player.

--==================================================



local function removePlayerESP(targetPlayer)

    local objects = playerObjects[targetPlayer]



    if not objects then

        return

    end



    if objects.highlight then

        objects.highlight:Destroy()

    end



    if objects.billboard then

        objects.billboard:Destroy()

    end



    playerObjects[targetPlayer] = nil

end



local function addPlayerESP(targetPlayer)

    if closed or not espEnabled["Players"] then

        return

    end



    if targetPlayer == player then

        return

    end



    local character = targetPlayer.Character



    if not character then

        return

    end



    local part = getCharacterRoot(character)



    if not part then

        return

    end



    local existing = playerObjects[targetPlayer]



    if existing and existing.character == character then

        applyTextVisibility(existing, "Players")

        return

    elseif existing then

        removePlayerESP(targetPlayer)

    end



    local highlight = makeHighlight(character, COLORS.Players)



    local displayName = targetPlayer.DisplayName



    local billboard, label = makeBillboard(

        part,

        displayName,

        COLORS.Players,

        textEnabled["Players"]

    )



    playerObjects[targetPlayer] = {

        highlight = highlight,

        billboard = billboard,

        label = label,

        part = part,

        character = character,

        labelText = displayName,

    }



    updateDistanceLabel(label, part, displayName)

end



local function refreshPlayerESP()

    if not espEnabled["Players"] then

        for targetPlayer in pairs(playerObjects) do

            removePlayerESP(targetPlayer)

        end

        return

    end



    for _, targetPlayer in ipairs(Players:GetPlayers()) do

        if targetPlayer ~= player then

            addPlayerESP(targetPlayer)

        end

    end

end



--==================================================

-- REFRESH TEXT VISIBILITY

--==================================================



local function refreshTextForESP(name)
    local objectSets = {
        Monster = monsterObjects,
        ["Escape Door"] = doorObjects,
        Keys = namedESPObjects.Keys,
        Code = namedESPObjects.Code,
        ["Halloween Quest"] = namedESPObjects["Halloween Quest"],
        Closets = namedESPObjects.Closets,
        Players = playerObjects,
    }
    local set = objectSets[name]
    if set then
        for _, objects in pairs(set) do
            applyTextVisibility(objects, name)
        end
    end
end


--==================================================

-- SWITCH VISUALS

--==================================================



local function updateSwitch(button, enabled)

    if not button then

        return

    end



    local track = button:FindFirstChild("SwitchTrack")

    local knob = track and track:FindFirstChild("SwitchKnob")



    if not track or not knob then

        return

    end



    tween(track, 0.18, {

        BackgroundColor3 = enabled and ON_COLOR or OFF_COLOR,

    })



    tween(knob, 0.18, {

        Position = enabled

            and UDim2.new(1, -21, 0.5, 0)

            or UDim2.new(0, 3, 0.5, 0),

    })

end



local function updateAllSwitches()

    for name, button in pairs(toggleButtons) do

        updateSwitch(button, espEnabled[name])

    end



    for name, button in pairs(textToggleButtons) do

        updateSwitch(button, textEnabled[name])

    end

end



--==================================================

-- SET ESP TOGGLE

--==================================================



local function setToggle(name, enabled)

    if closed then

        return

    end



    espEnabled[name] = enabled



    -- Show Text options only appear when their ESP is enabled.

    if textToggleButtons[name] then

        textToggleButtons[name].Visible = enabled

    end



    updateAllSwitches()



    if name == "Monster" then

        refreshMonsterESP()



    elseif name == "Escape Door" then

        refreshDoorESP()



    elseif name == "Keys" or name == "Code" then
        refreshNamedESP(name)

    elseif name == "Players" then
        refreshPlayerESP()
    end

end



local function setTextToggle(name, enabled)

    if closed then

        return

    end



    textEnabled[name] = enabled



    updateAllSwitches()

    refreshTextForESP(name)

end



--==================================================

-- CREATE SLIDING SWITCH

--==================================================



local function createSwitch(parent)

    local track = create("Frame", {

        Name = "SwitchTrack",

        AnchorPoint = Vector2.new(0, 0.5),

        Position = UDim2.new(1, -61, 0.5, 0),

        Size = UDim2.fromOffset(48, 24),

        BackgroundColor3 = OFF_COLOR,

        BorderSizePixel = 0,

    }, parent)



    addCorner(track, 12)



    local knob = create("Frame", {

        Name = "SwitchKnob",

        AnchorPoint = Vector2.new(0, 0.5),

        Position = UDim2.new(0, 3, 0.5, 0),

        Size = UDim2.fromOffset(18, 18),

        BackgroundColor3 = Color3.new(1, 1, 1),

        BorderSizePixel = 0,

    }, track)



    addCorner(knob, 9)



    return track

end



--==================================================

-- CREATE ESP ROW + SHOW TEXT ROW

--==================================================



local function createToggleRow(parent, name, description, order)

    local row = create("TextButton", {

        Name = name:gsub("%s+", "") .. "Toggle",

        Size = UDim2.new(1, -2, 0, 57),

        BackgroundColor3 = ROW_COLOR,

        BorderSizePixel = 0,

        Text = "",

        AutoButtonColor = false,

        LayoutOrder = order * 2,

    }, parent)



    addCorner(row, 8)



    local rowStroke = addStroke(

        row,

        Color3.fromRGB(65, 65, 78),

        1,

        0.55

    )



    create("TextLabel", {

        Name = "Label",

        Position = UDim2.fromOffset(12, 7),

        Size = UDim2.new(1, -100, 0, 22),

        BackgroundTransparency = 1,

        Text = name,

        TextColor3 = TEXT_COLOR,

        TextSize = 14,

        Font = Enum.Font.GothamBold,

        TextXAlignment = Enum.TextXAlignment.Left,

    }, row)



    create("TextLabel", {

        Name = "Description",

        Position = UDim2.fromOffset(12, 29),

        Size = UDim2.new(1, -100, 0, 18),

        BackgroundTransparency = 1,

        Text = description,

        TextColor3 = MUTED_COLOR,

        TextSize = 10,

        Font = Enum.Font.Gotham,

        TextXAlignment = Enum.TextXAlignment.Left,

        TextTruncate = Enum.TextTruncate.AtEnd,

    }, row)



    createSwitch(row)



    toggleButtons[name] = row



    row.MouseEnter:Connect(function()

        if not closed then

            tween(row, 0.12, {

                BackgroundColor3 = Color3.fromRGB(48, 48, 59),

            })



            tween(rowStroke, 0.12, {

                Transparency = 0.15,

            })

        end

    end)



    row.MouseLeave:Connect(function()

        if not closed then

            tween(row, 0.12, {

                BackgroundColor3 = ROW_COLOR,

            })



            tween(rowStroke, 0.12, {

                Transparency = 0.55,

            })

        end

    end)



    row.Activated:Connect(function()

        setToggle(name, not espEnabled[name])

    end)



    -- Separate Show Text toggle, hidden until its ESP is enabled.

    local textRow = create("TextButton", {

        Name = name:gsub("%s+", "") .. "ShowTextToggle",

        Size = UDim2.new(1, -2, 0, 42),

        BackgroundColor3 = Color3.fromRGB(32, 32, 39),

        BorderSizePixel = 0,

        Text = "",

        AutoButtonColor = false,

        Visible = false,

        LayoutOrder = order * 2 + 1,

    }, parent)



    addCorner(textRow, 8)

    addStroke(textRow, Color3.fromRGB(65, 65, 78), 1, 0.65)



    create("TextLabel", {

        Name = "Label",

        Position = UDim2.fromOffset(12, 0),

        Size = UDim2.new(1, -100, 1, 0),

        BackgroundTransparency = 1,

        Text = "Show Text",

        TextColor3 = TEXT_COLOR,

        TextSize = 12,

        Font = Enum.Font.GothamMedium,

        TextXAlignment = Enum.TextXAlignment.Left,

    }, textRow)



    createSwitch(textRow)



    textToggleButtons[name] = textRow



    textRow.Activated:Connect(function()

        setTextToggle(name, not textEnabled[name])

    end)

end



--==================================================
-- ESP TAB
--==================================================

createToggleRow(espPage, "Monster", "Red ESP for VER", 1)
createToggleRow(espPage, "Escape Door", "Blue ESP for monochrome > Cube.007", 2)
createToggleRow(espPage, "Keys", "Green ESP for HiddenKey1–HiddenKey4", 3)
createToggleRow(espPage, "Code", "ESP for monochrome > CodeNote", 4)
createToggleRow(espPage, "Halloween Quest", "Orange ESP for HalloweenMedallions objects", 5)
createToggleRow(espPage, "Closets", "Pink ESP for objects with HidePromptPoint", 6)
createToggleRow(espPage, "Players", "White ESP with each player's name", 7)


-- PLAYER / OTHER TABS

--==================================================



--==================================================
-- TPWALK SPEEDHACK SLIDER
-- Uses small CFrame offsets; Humanoid.WalkSpeed is never changed.
-- The slider starts at the character's current WalkSpeed baseline.
--==================================================

local speedhackBaseline = 16
local speedhackTarget = 16
local speedhackDragging = false
local speedhackConnections = {}

local speedRow = create("Frame", {
    Name = "SpeedhackRow",
    Size = UDim2.new(1, -4, 0, 104),
    BackgroundColor3 = ROW_COLOR,
    BorderSizePixel = 0,
    LayoutOrder = 1,
}, playerPage)
addCorner(speedRow, 8)
addStroke(speedRow, Color3.fromRGB(65, 65, 78), 1, 0.45)

local speedTitle = create("TextLabel", {
    Name = "Title",
    Position = UDim2.fromOffset(12, 8),
    Size = UDim2.new(1, -24, 0, 22),
    BackgroundTransparency = 1,
    Text = "Speedhack",
    TextColor3 = TEXT_COLOR,
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, speedRow)

local speedValueLabel = create("TextLabel", {
    Name = "Value",
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -12, 0, 8),
    Size = UDim2.fromOffset(100, 22),
    BackgroundTransparency = 1,
    Text = "16.0 studs/s",
    TextColor3 = ACCENT_COLOR,
    TextSize = 12,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Right,
}, speedRow)

local speedTrack = create("Frame", {
    Name = "SliderTrack",
    Position = UDim2.new(0, 12, 0, 53),
    Size = UDim2.new(1, -24, 0, 8),
    BackgroundColor3 = Color3.fromRGB(65, 65, 78),
    BorderSizePixel = 0,
}, speedRow)
addCorner(speedTrack, 4)

local speedFill = create("Frame", {
    Name = "Fill",
    Size = UDim2.new(16 / 100, 0, 1, 0),
    BackgroundColor3 = ACCENT_COLOR,
    BorderSizePixel = 0,
}, speedTrack)
addCorner(speedFill, 4)

local speedKnob = create("Frame", {
    Name = "Knob",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(16 / 100, 0, 0.5, 0),
    Size = UDim2.fromOffset(16, 16),
    BackgroundColor3 = Color3.new(1, 1, 1),
    BorderSizePixel = 0,
    ZIndex = 2,
}, speedTrack)
addCorner(speedKnob, 8)

local speedHitbox = create("TextButton", {
    Name = "SliderHitbox",
    Position = UDim2.new(0, 8, 0, 38),
    Size = UDim2.new(1, -16, 0, 38),
    BackgroundTransparency = 1,
    Text = "",
    AutoButtonColor = false,
    ZIndex = 3,
}, speedRow)

create("TextLabel", {
    Name = "Range",
    Position = UDim2.new(0, 12, 0, 72),
    Size = UDim2.new(1, -24, 0, 18),
    BackgroundTransparency = 1,
    Text = "0  —  100 studs/s",
    TextColor3 = MUTED_COLOR,
    TextSize = 10,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
}, speedRow)

local SPEED_MIN = 0
local SPEED_MAX = 100

local function setSpeedhackValue(value)
    speedhackTarget = math.clamp(math.floor(value + 0.5), SPEED_MIN, SPEED_MAX)
    local alpha = (speedhackTarget - SPEED_MIN) / (SPEED_MAX - SPEED_MIN)
    speedFill.Size = UDim2.new(alpha, 0, 1, 0)
    speedKnob.Position = UDim2.new(alpha, 0, 0.5, 0)
    speedValueLabel.Text = string.format("%d studs/s", speedhackTarget)
end

local function setSpeedFromInput(input)
    local width = speedTrack.AbsoluteSize.X
    if width <= 0 then return end
    local alpha = math.clamp(
        (input.Position.X - speedTrack.AbsolutePosition.X) / width,
        0,
        1
    )
    setSpeedhackValue(SPEED_MIN + alpha * (SPEED_MAX - SPEED_MIN))
end

speedHitbox.InputBegan:Connect(function(input)
    if closed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        speedhackDragging = true
        setSpeedFromInput(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if speedhackDragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        setSpeedFromInput(input)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        speedhackDragging = false
    end
end)

local function updateSpeedhackBaseline()
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        speedhackBaseline = humanoid.WalkSpeed
        setSpeedhackValue(speedhackBaseline)
    end
end

player.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if humanoid then
        speedhackBaseline = humanoid.WalkSpeed
        setSpeedhackValue(speedhackBaseline)
    end
end)

updateSpeedhackBaseline()

-- TPWalk: add only the difference between the slider target and the
-- character's normal WalkSpeed. At the baseline value, no extra offset is added.
pcall(function()
    RunService:UnbindFromRenderStep("ScreamRunTPWalk")
end)

RunService:BindToRenderStep("ScreamRunTPWalk", Enum.RenderPriority.Character.Value + 1, function(deltaTime)
    if closed or speedhackTarget == speedhackBaseline then
        return
    end

    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")

    if not humanoid or not root or humanoid.Health <= 0 then
        return
    end

    local moveDirection = humanoid.MoveDirection
    if moveDirection.Magnitude < 0.01 then
        return
    end

    local extraSpeed = speedhackTarget - speedhackBaseline
    root.CFrame = root.CFrame + moveDirection * extraSpeed * deltaTime
end)



--==================================================
-- FEATURE TOGGLES: Noclip, Fullbright, No Fog, Instant Interact
--==================================================

local featureStates = { Noclip = false, Fullbright = false, ["No Fog"] = false, ["Instant Interact"] = false, ["Remove Screen Static"] = false }
local featureRows = {}
local noclipConnection
local originalCollisions = setmetatable({}, { __mode = "k" })
local lightingOriginals = nil
local fogOriginals = nil
local originalPromptDurations = setmetatable({}, { __mode = "k" })
local promptAddedConnection
local pixelStaticOriginals = setmetatable({}, { __mode = "k" })
local pixelStaticAddedConnection

local function makePromptInstant(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    if originalPromptDurations[prompt] == nil then
        originalPromptDurations[prompt] = prompt.HoldDuration
    end
    prompt.HoldDuration = 0
end

local function restorePromptDurations()
    for prompt, originalDuration in pairs(originalPromptDurations) do
        if prompt and prompt.Parent then
            prompt.HoldDuration = originalDuration
        end
        originalPromptDurations[prompt] = nil
    end
end

local function setPixelStaticEnabled(guiObject, enabled)
    if not guiObject or guiObject.Name ~= "PixelStatic" then return end
    if guiObject:IsA("LayerCollector") then
        if pixelStaticOriginals[guiObject] == nil then pixelStaticOriginals[guiObject] = guiObject.Enabled end
        guiObject.Enabled = enabled
    elseif guiObject:IsA("GuiObject") then
        if pixelStaticOriginals[guiObject] == nil then pixelStaticOriginals[guiObject] = guiObject.Visible end
        guiObject.Visible = enabled
    end
end

local function restorePixelStatic()
    for guiObject, originalValue in pairs(pixelStaticOriginals) do
        if guiObject and guiObject.Parent then
            pcall(function()
                if guiObject:IsA("LayerCollector") then guiObject.Enabled = originalValue
                elseif guiObject:IsA("GuiObject") then guiObject.Visible = originalValue end
            end)
        end
        pixelStaticOriginals[guiObject] = nil
    end
end

local function applyRemoveScreenStatic(enabled)
    if pixelStaticAddedConnection then pixelStaticAddedConnection:Disconnect(); pixelStaticAddedConnection = nil end
    if enabled then
        for _, descendant in ipairs(playerGui:GetDescendants()) do
            if descendant.Name == "PixelStatic" then setPixelStaticEnabled(descendant, false) end
        end
        pixelStaticAddedConnection = playerGui.DescendantAdded:Connect(function(descendant)
            if not closed and featureStates["Remove Screen Static"] and descendant.Name == "PixelStatic" then
                task.defer(function()
                    if descendant.Parent then setPixelStaticEnabled(descendant, false) end
                end)
            end
        end)
    else
        restorePixelStatic()
    end
end

local function makeFeatureToggle(parent, name, description, order)
    local row = create("TextButton", {
        Name = name:gsub("%s+", "") .. "Toggle", Size = UDim2.new(1, -4, 0, 57),
        BackgroundColor3 = ROW_COLOR, BorderSizePixel = 0, Text = "", AutoButtonColor = false,
        LayoutOrder = order,
    }, parent)
    addCorner(row, 8)
    local outline = addStroke(row, Color3.fromRGB(65, 65, 78), 1, 0.45)
    create("TextLabel", {
        Name = "Label", Position = UDim2.fromOffset(12, 7), Size = UDim2.new(1, -100, 0, 22),
        BackgroundTransparency = 1, Text = name, TextColor3 = TEXT_COLOR, TextSize = 14,
        Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left,
    }, row)
    create("TextLabel", {
        Name = "Description", Position = UDim2.fromOffset(12, 29), Size = UDim2.new(1, -100, 0, 18),
        BackgroundTransparency = 1, Text = description, TextColor3 = MUTED_COLOR, TextSize = 10,
        Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, row)
    local pill = create("Frame", {
        Name = "Switch", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.fromOffset(42, 23), BackgroundColor3 = OFF_COLOR, BorderSizePixel = 0,
    }, row)
    addCorner(pill, 12)
    local dot = create("Frame", {
        Name = "Dot", Position = UDim2.fromOffset(3, 3), Size = UDim2.fromOffset(17, 17),
        BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
    }, pill)
    addCorner(dot, 9)
    featureRows[name] = { row = row, pill = pill, dot = dot, outline = outline }
    row.Activated:Connect(function()
        if not closed then
            featureStates[name] = not featureStates[name]
            local enabled = featureStates[name]
            tween(pill, 0.12, { BackgroundColor3 = enabled and ON_COLOR or OFF_COLOR })
            tween(dot, 0.12, { Position = enabled and UDim2.fromOffset(22, 3) or UDim2.fromOffset(3, 3) })
            tween(outline, 0.12, { Transparency = enabled and 0.15 or 0.45 })
            if name == "Remove Screen Static" then
                applyRemoveScreenStatic(enabled)
            elseif name == "Noclip" then
                if enabled then
                    if noclipConnection then noclipConnection:Disconnect() end
                    noclipConnection = RunService.Stepped:Connect(function()
                        if closed or not featureStates.Noclip then return end
                        local character = player.Character
                        if not character then return end
                        for _, part in ipairs(character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                if originalCollisions[part] == nil then originalCollisions[part] = part.CanCollide end
                                part.CanCollide = false
                            end
                        end
                    end)
                else
                    if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
                    for part, wasCollidable in pairs(originalCollisions) do
                        if part and part.Parent then part.CanCollide = wasCollidable end
                        originalCollisions[part] = nil
                    end
                end
            elseif name == "Fullbright" then
                if enabled then
                    if not lightingOriginals then
                        lightingOriginals = {
                            Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime,
                            GlobalShadows = Lighting.GlobalShadows, Ambient = Lighting.Ambient,
                            OutdoorAmbient = Lighting.OutdoorAmbient, ExposureCompensation = Lighting.ExposureCompensation,
                        }
                    end
                    Lighting.Brightness = 3
                    Lighting.ClockTime = 14
                    Lighting.GlobalShadows = false
                    Lighting.Ambient = Color3.new(1, 1, 1)
                    Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
                    Lighting.ExposureCompensation = 0
                elseif lightingOriginals then
                    for property, value in pairs(lightingOriginals) do Lighting[property] = value end
                    lightingOriginals = nil
                end
            elseif name == "Instant Interact" then
                if enabled then
                    for _, descendant in ipairs(workspace:GetDescendants()) do
                        if descendant:IsA("ProximityPrompt") then
                            makePromptInstant(descendant)
                        end
                    end
                    if promptAddedConnection then promptAddedConnection:Disconnect() end
                    promptAddedConnection = workspace.DescendantAdded:Connect(function(descendant)
                        if not closed and featureStates["Instant Interact"] and descendant:IsA("ProximityPrompt") then
                            makePromptInstant(descendant)
                        end
                    end)
                else
                    if promptAddedConnection then promptAddedConnection:Disconnect(); promptAddedConnection = nil end
                    restorePromptDurations()
                end
            elseif name == "No Fog" then
                if enabled then
                    if not fogOriginals then fogOriginals = { FogStart = Lighting.FogStart, FogEnd = Lighting.FogEnd } end
                    Lighting.FogStart = 0
                    Lighting.FogEnd = 1000000
                    for _, effect in ipairs(Lighting:GetDescendants()) do
                        if effect:IsA("Atmosphere") then
                            effect:SetAttribute("ScreamRunOriginalDensity", effect.Density)
                            effect:SetAttribute("ScreamRunOriginalHaze", effect.Haze)
                            effect:SetAttribute("ScreamRunOriginalGlare", effect.Glare)
                            effect.Density = 0
                            effect.Haze = 0
                            effect.Glare = 0
                        end
                    end
                else
                    if fogOriginals then
                        Lighting.FogStart = fogOriginals.FogStart
                        Lighting.FogEnd = fogOriginals.FogEnd
                        fogOriginals = nil
                    end
                    for _, effect in ipairs(Lighting:GetDescendants()) do
                        if effect:IsA("Atmosphere") then
                            local density = effect:GetAttribute("ScreamRunOriginalDensity")
                            local haze = effect:GetAttribute("ScreamRunOriginalHaze")
                            local glare = effect:GetAttribute("ScreamRunOriginalGlare")
                            if density ~= nil then effect.Density = density; effect:SetAttribute("ScreamRunOriginalDensity", nil) end
                            if haze ~= nil then effect.Haze = haze; effect:SetAttribute("ScreamRunOriginalHaze", nil) end
                            if glare ~= nil then effect.Glare = glare; effect:SetAttribute("ScreamRunOriginalGlare", nil) end
                        end
                    end
                end
            end
        end
    end)
    row.MouseEnter:Connect(function()
        if not closed then tween(row, 0.12, { BackgroundColor3 = Color3.fromRGB(48, 48, 59) }) end
    end)
    row.MouseLeave:Connect(function()
        if not closed then tween(row, 0.12, { BackgroundColor3 = ROW_COLOR }) end
    end)
    return row
end

makeFeatureToggle(playerPage, "Noclip", "Walk through walls and objects", 3)
makeFeatureToggle(otherPage, "Fullbright", "Brighten the world", 1)
makeFeatureToggle(otherPage, "No Fog", "Disable fog and atmosphere haze", 2)
makeFeatureToggle(otherPage, "Instant Interact", "Make all proximity prompts instant", 3)
makeFeatureToggle(otherPage, "Remove Screen Static", "Hide PlayerGui > PixelStatic", 4)

-- One-shot button: reads monochrome.CodeNote.Printed.Digits and displays it bottom-right.
local readPaperButton = create("TextButton", {
    Name = "ReadPaperButton", Size = UDim2.new(1, -4, 0, 48),
    BackgroundColor3 = ROW_COLOR, BorderSizePixel = 0, Text = "Read Paper",
    TextColor3 = TEXT_COLOR, TextSize = 14, Font = Enum.Font.GothamBold,
    AutoButtonColor = false, LayoutOrder = 5,
}, otherPage)
addCorner(readPaperButton, 8)
addStroke(readPaperButton, Color3.fromRGB(65, 65, 78), 1, 0.45)

local function showCodeNotification(code)
    local old = playerGui:FindFirstChild("ScreamRunCodeNotification")
    if old then old:Destroy() end
    local notificationGui = create("ScreenGui", {
        Name = "ScreamRunCodeNotification", ResetOnSpawn = false,
        IgnoreGuiInset = true, DisplayOrder = 1000,
    }, playerGui)
    local notice = create("Frame", {
        Name = "Notice", AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -22, 1, -22), Size = UDim2.fromOffset(280, 76),
        BackgroundColor3 = PANEL_COLOR, BorderSizePixel = 0, ZIndex = 100,
    }, notificationGui)
    addCorner(notice, 10)
    addStroke(notice, ACCENT_COLOR, 1.5, 0.15)
    create("TextLabel", {
        Name = "Title", Position = UDim2.fromOffset(14, 8), Size = UDim2.new(1, -28, 0, 22),
        BackgroundTransparency = 1, Text = "Paper Code", TextColor3 = ACCENT_COLOR,
        TextSize = 13, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 101,
    }, notice)
    create("TextLabel", {
        Name = "Code", Position = UDim2.fromOffset(14, 32), Size = UDim2.new(1, -28, 0, 32),
        BackgroundTransparency = 1, Text = tostring(code), TextColor3 = TEXT_COLOR,
        TextSize = 20, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 101,
    }, notice)
    task.delay(5, function() if notificationGui and notificationGui.Parent then notificationGui:Destroy() end end)
end

readPaperButton.Activated:Connect(function()
    local targetModel = workspace:FindFirstChild(TARGET_MODEL_NAME)
    local note = targetModel and targetModel:FindFirstChild(CODE_NOTE_NAME, true)
    local printed = note and note:FindFirstChild("Printed")
    local digits = printed and printed:FindFirstChild("Digits", true)
    if not digits then
        showCodeNotification("Digits display not found")
        return
    end
    local value
    if digits:IsA("TextLabel") or digits:IsA("TextButton") or digits:IsA("TextBox") then
        value = digits.Text
    elseif digits:IsA("StringValue") or digits:IsA("IntValue") or digits:IsA("NumberValue") then
        value = digits.Value
    else
        value = digits:GetAttribute("Text") or digits:GetAttribute("Value") or digits.Name
    end
    showCodeNotification(value)
end)

--==================================================

-- SMOOTH DRAGGING

--==================================================



local dragging = false

local dragStart

local startPosition

local dragInput

local targetPosition = main.Position



header.Active = true



header.InputBegan:Connect(function(input)

    if closed then

        return

    end



    if input.UserInputType == Enum.UserInputType.MouseButton1

        or input.UserInputType == Enum.UserInputType.Touch then



        dragging = true

        dragStart = input.Position

        startPosition = targetPosition



        input.Changed:Connect(function()

            if input.UserInputState == Enum.UserInputState.End then

                dragging = false

                dragInput = nil

            end

        end)

    end

end)



UserInputService.InputChanged:Connect(function(input)

    if closed then

        return

    end



    if dragging and (

        input.UserInputType == Enum.UserInputType.MouseMovement

        or input.UserInputType == Enum.UserInputType.Touch

    ) then

        dragInput = input

    end

end)



RunService.RenderStepped:Connect(function(deltaTime)

    if closed then

        return

    end



    if dragging and dragInput and dragStart and startPosition then

        local delta = dragInput.Position - dragStart



        targetPosition = UDim2.new(

            startPosition.X.Scale,

            startPosition.X.Offset + delta.X,

            startPosition.Y.Scale,

            startPosition.Y.Offset + delta.Y

        )

    end



    main.Position = main.Position:Lerp(

        targetPosition,

        math.clamp(deltaTime * 22, 0, 1)

    )

end)



--==================================================

-- MINIMIZE

--==================================================



minimizeButton.Activated:Connect(function()

    if closed then

        return

    end



    minimized = not minimized



    if minimized then

        minimizeButton.Text = "+"

        tabBar.Visible = false

        content.Visible = false



        tween(main, 0.25, {

            Size = UDim2.fromOffset(490, 48),

        })

    else

        minimizeButton.Text = "—"



        tween(main, 0.25, {

            Size = originalSize,

        })



        task.delay(0.15, function()

            if closed or minimized then

                return

            end



            tabBar.Visible = true

            content.Visible = true

        end)

    end

end)



--==================================================

-- SMOOTH CLOSE

--==================================================



closeButton.Activated:Connect(function()

    if closed then

        return

    end



    closed = true
    dragging = false
    speedhackDragging = false
    pcall(function()
        RunService:UnbindFromRenderStep("ScreamRunTPWalk")
    end)
    if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
    if promptAddedConnection then promptAddedConnection:Disconnect(); promptAddedConnection = nil end
    if pixelStaticAddedConnection then pixelStaticAddedConnection:Disconnect(); pixelStaticAddedConnection = nil end
    restorePixelStatic()
    restorePromptDurations()
    for part, wasCollidable in pairs(originalCollisions) do
        if part and part.Parent then part.CanCollide = wasCollidable end
        originalCollisions[part] = nil
    end
    if lightingOriginals then
        for property, value in pairs(lightingOriginals) do Lighting[property] = value end
        lightingOriginals = nil
    end
    if fogOriginals then
        Lighting.FogStart = fogOriginals.FogStart
        Lighting.FogEnd = fogOriginals.FogEnd
        fogOriginals = nil
    end
    for _, effect in ipairs(Lighting:GetDescendants()) do
        if effect:IsA("Atmosphere") then
            local density = effect:GetAttribute("ScreamRunOriginalDensity")
            local haze = effect:GetAttribute("ScreamRunOriginalHaze")
            local glare = effect:GetAttribute("ScreamRunOriginalGlare")
            if density ~= nil then effect.Density = density; effect:SetAttribute("ScreamRunOriginalDensity", nil) end
            if haze ~= nil then effect.Haze = haze; effect:SetAttribute("ScreamRunOriginalHaze", nil) end
            if glare ~= nil then effect.Glare = glare; effect:SetAttribute("ScreamRunOriginalGlare", nil) end
        end
    end

    local animation = tween(main, 0.22, {

        Size = UDim2.fromOffset(0, 0),

        BackgroundTransparency = 1,

        Position = main.Position + UDim2.fromOffset(0, 15),

    }, Enum.EasingStyle.Back, Enum.EasingDirection.In)



    tween(closeButton, 0.12, {

        BackgroundTransparency = 1,

        TextTransparency = 1,

    })



    tween(minimizeButton, 0.12, {

        BackgroundTransparency = 1,

        TextTransparency = 1,

    })



    animation.Completed:Wait()



    for model in pairs(monsterObjects) do

        removeMonsterESP(model)

    end



    for model in pairs(doorObjects) do
        removeDoorESP(model)
    end

    for kind, set in pairs(namedESPObjects) do
        for object in pairs(set) do
            removeNamedESP(kind, object)
        end
    end

    for targetPlayer in pairs(playerObjects) do

        removePlayerESP(targetPlayer)

    end



    screenGui:Destroy()

end)



--==================================================

-- WORLD CHANGE LISTENERS

--==================================================



workspace.DescendantAdded:Connect(function(descendant)

    if closed then

        return

    end



    task.defer(function()

        if closed or not descendant.Parent then

            return

        end



        if descendant:IsA("Model") then

            if descendant.Name == MONSTER_NAME

                and espEnabled["Monster"] then

                addMonsterESP(descendant)

            end


        end



        if descendant:IsA("BasePart") or descendant:IsA("Model") then
            if descendant.Name == ESCAPE_DOOR_NAME and espEnabled["Escape Door"] then addDoorESP(descendant) end
            if espEnabled.Keys then addNamedESP("Keys", descendant) end
            if espEnabled.Code then addNamedESP("Code", descendant) end
            if espEnabled["Halloween Quest"] then addNamedESP("Halloween Quest", descendant) end
            if espEnabled.Closets then addNamedESP("Closets", descendant) end
        end
        refreshDoorESP()
        if espEnabled.Keys then refreshNamedESP("Keys") end
        if espEnabled.Code then refreshNamedESP("Code") end
        if espEnabled["Halloween Quest"] then refreshNamedESP("Halloween Quest") end
        if espEnabled.Closets then refreshNamedESP("Closets") end

    end)
end)


workspace.DescendantRemoving:Connect(function(descendant)
    if closed then return end
    removeMonsterESP(descendant)
    removeDoorESP(descendant)
    removeNamedESP("Keys", descendant)
    removeNamedESP("Code", descendant)
    removeNamedESP("Halloween Quest", descendant)
    removeNamedESP("Closets", descendant)
end)


--==================================================

-- PLAYER LISTENERS

--==================================================



local function connectPlayer(targetPlayer)

    targetPlayer.CharacterAdded:Connect(function()

        task.wait(0.25)



        if not closed and espEnabled["Players"] and targetPlayer ~= player then

            addPlayerESP(targetPlayer)

        end

    end)

end



for _, targetPlayer in ipairs(Players:GetPlayers()) do

    if targetPlayer ~= player then

        connectPlayer(targetPlayer)

    end

end



Players.PlayerAdded:Connect(function(targetPlayer)

    connectPlayer(targetPlayer)



    task.defer(function()

        if not closed and espEnabled["Players"] then

            addPlayerESP(targetPlayer)

        end

    end)

end)



Players.PlayerRemoving:Connect(function(targetPlayer)

    removePlayerESP(targetPlayer)

end)



--==================================================

-- DISTANCE / OBJECT UPDATES

--==================================================



RunService.Heartbeat:Connect(function(deltaTime)

    if closed then

        return

    end



    updateAccumulator += deltaTime



    if updateAccumulator < UPDATE_INTERVAL then

        return

    end



    updateAccumulator = 0



    -- Monster labels and missing parts.

    for model, objects in pairs(monsterObjects) do

        if not model:IsDescendantOf(workspace) then

            removeMonsterESP(model)

        else

            local part = objects.part



            if not part or not part.Parent then

                part = model.PrimaryPart

                    or model:FindFirstChild("HumanoidRootPart", true)

                    or model:FindFirstChildWhichIsA("BasePart", true)



                objects.part = part



                if part and objects.billboard then

                    objects.billboard.Adornee = part

                end

            end



            if part then

                updateDistanceLabel(objects.label, part, objects.labelText)

            end

        end

    end



    -- Escape door label updates.
    for object, objects in pairs(doorObjects) do
        if not object:IsDescendantOf(workspace) then
            removeDoorESP(object)
        else
            updateDistanceLabel(objects.label, object, objects.labelText)
        end
    end

    -- Key and code labels.
    for _, set in pairs(namedESPObjects) do
        for object, objects in pairs(set) do
            if not object:IsDescendantOf(workspace) then
                -- The set key identifies which ESP collection owns this object.
                for kind, candidateSet in pairs(namedESPObjects) do
                    if candidateSet == set then removeNamedESP(kind, object); break end
                end
            elseif objects.part and objects.part.Parent then
                updateDistanceLabel(objects.label, objects.part, objects.labelText)
            end
        end
    end



    -- Player labels. Never display ESP for the local player.

    for targetPlayer, objects in pairs(playerObjects) do

        if targetPlayer == player or targetPlayer.Parent ~= Players then

            removePlayerESP(targetPlayer)

        else

            local character = targetPlayer.Character



            if not character or not character:IsDescendantOf(workspace) then

                removePlayerESP(targetPlayer)

            else

                local part = getCharacterRoot(character)



                if part then

                    objects.part = part

                    objects.character = character

                    objects.labelText = targetPlayer.DisplayName



                    if objects.billboard then

                        objects.billboard.Adornee = part

                    end



                    updateDistanceLabel(

                        objects.label,

                        part,

                        targetPlayer.DisplayName

                    )

                end

            end

        end

    end

end)



--==================================================

-- INITIALIZE

--==================================================



selectTab("ESP")

updateAllSwitches()

--[[
    NEXUS BOOST V2
    Roblox-native client optimization panel.

    INSTALLATION:
      1. In Roblox Studio, open StarterPlayer > StarterPlayerScripts.
      2. Insert ONE LocalScript.
      3. Paste this entire file into that LocalScript.
      4. Press Play to test.

    This is a standalone LocalScript: no ModuleScript or second loader is needed.

    Notes:
      - This only changes supported visual properties on the local client.
      - It cannot switch off Roblox's entire 3D renderer or directly clear memory.
      - No exploit APIs, executor functions, or remote-code loading are used.
]]

local function startNexusBoost()
    local Players = game:GetService("Players")
    local Lighting = game:GetService("Lighting")
    local Workspace = game:GetService("Workspace")
    local RunService = game:GetService("RunService")
    local Stats = game:GetService("Stats")
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")

    local player = Players.LocalPlayer
    if not player then
        warn("NEXUS BOOST must be started by a LocalScript.")
        return
    end

    local playerGui = player:WaitForChild("PlayerGui")
    local restoreVisualSettings
    local oldGui = playerGui:FindFirstChild("NexusBoostV2")
    if oldGui then
        oldGui:Destroy()
    end

    --------------------------------------------------------------------
    -- State and safe visual-property handling
    --------------------------------------------------------------------

    local states = {
        LowGraphics = false,
        DisableShadows = false,
        DisableParticles = false,
        DisableLights = false,
        HideTextures = false,
        DisablePostFX = false,
    }

    -- Weak keys allow destroyed instances to be garbage-collected.
    local originalValues = setmetatable({}, { __mode = "k" })

    local particleClasses = {
        ParticleEmitter = true,
        Trail = true,
        Beam = true,
        Smoke = true,
        Fire = true,
        Sparkles = true,
    }

    local lightClasses = {
        PointLight = true,
        SpotLight = true,
        SurfaceLight = true,
    }

    local postEffectClasses = {
        BloomEffect = true,
        BlurEffect = true,
        ColorCorrectionEffect = true,
        DepthOfFieldEffect = true,
        SunRaysEffect = true,
    }

    local function getOriginal(instance, property)
        local values = originalValues[instance]
        if not values then
            values = {}
            originalValues[instance] = values
        end

        if values[property] == nil then
            local ok, value = pcall(function()
                return instance[property]
            end)
            if not ok then
                return nil
            end
            values[property] = value
        end
        return values[property]
    end

    local function setOrRestore(instance, property, shouldOverride, overrideValue)
        if not instance or not instance.Parent then
            return
        end

        if shouldOverride then
            local baseline = getOriginal(instance, property)
            if baseline == nil then
                return
            end
            pcall(function()
                instance[property] = overrideValue
            end)
        else
            local values = originalValues[instance]
            if values and values[property] ~= nil then
                local baseline = values[property]
                pcall(function()
                    instance[property] = baseline
                end)
                values[property] = nil
            end
        end
    end

    local function applyInstance(instance)
        if instance == Lighting then
            setOrRestore(Lighting, "GlobalShadows", states.DisableShadows, false)
            return
        end

        if instance:IsA("BasePart") then
            setOrRestore(instance, "Material", states.LowGraphics, Enum.Material.Plastic)
            setOrRestore(instance, "Reflectance", states.LowGraphics, 0)
            setOrRestore(instance, "CastShadow", states.DisableShadows, false)
        end

        if instance:IsA("Decal") or instance:IsA("Texture") then
            setOrRestore(instance, "Transparency", states.HideTextures, 1)
        end

        if particleClasses[instance.ClassName] then
            setOrRestore(instance, "Enabled", states.DisableParticles, false)
        end

        if lightClasses[instance.ClassName] then
            setOrRestore(instance, "Enabled", states.DisableLights, false)
        end

        if postEffectClasses[instance.ClassName] then
            setOrRestore(instance, "Enabled", states.DisablePostFX, false)
        end
    end

    local function applyAllInstances()
        applyInstance(Lighting)
        for _, instance in ipairs(Workspace:GetDescendants()) do
            applyInstance(instance)
        end
        for _, instance in ipairs(Lighting:GetDescendants()) do
            applyInstance(instance)
        end
    end

    -- Track global connections so closing the panel cleans them up.
    local externalConnections = {}
    local function trackConnection(connection)
        table.insert(externalConnections, connection)
        return connection
    end

    -- Apply current options to new objects that appear while playing.
    trackConnection(Workspace.DescendantAdded:Connect(function(instance)
        task.defer(applyInstance, instance)
    end))
    trackConnection(Lighting.DescendantAdded:Connect(function(instance)
        task.defer(applyInstance, instance)
    end))

    --------------------------------------------------------------------
    -- UI helpers and theme system
    --------------------------------------------------------------------

    local themes = {
        Midnight = {
            background = Color3.fromRGB(15, 18, 27),
            panel = Color3.fromRGB(22, 27, 40),
            card = Color3.fromRGB(29, 35, 51),
            accent = Color3.fromRGB(83, 145, 255),
            text = Color3.fromRGB(241, 244, 255),
            muted = Color3.fromRGB(145, 157, 181),
            stroke = Color3.fromRGB(61, 76, 105),
            green = Color3.fromRGB(74, 204, 145),
        },
        Violet = {
            background = Color3.fromRGB(20, 16, 29),
            panel = Color3.fromRGB(31, 24, 45),
            card = Color3.fromRGB(43, 34, 59),
            accent = Color3.fromRGB(170, 115, 255),
            text = Color3.fromRGB(247, 240, 255),
            muted = Color3.fromRGB(174, 157, 194),
            stroke = Color3.fromRGB(91, 68, 119),
            green = Color3.fromRGB(102, 215, 166),
        },
        Ocean = {
            background = Color3.fromRGB(12, 22, 29),
            panel = Color3.fromRGB(18, 34, 44),
            card = Color3.fromRGB(25, 47, 59),
            accent = Color3.fromRGB(47, 190, 210),
            text = Color3.fromRGB(235, 250, 252),
            muted = Color3.fromRGB(135, 171, 181),
            stroke = Color3.fromRGB(51, 101, 114),
            green = Color3.fromRGB(92, 215, 170),
        },
        Crimson = {
            background = Color3.fromRGB(25, 16, 21),
            panel = Color3.fromRGB(39, 24, 32),
            card = Color3.fromRGB(54, 33, 43),
            accent = Color3.fromRGB(244, 103, 133),
            text = Color3.fromRGB(255, 241, 245),
            muted = Color3.fromRGB(184, 150, 161),
            stroke = Color3.fromRGB(112, 65, 82),
            green = Color3.fromRGB(109, 213, 158),
        },
    }

    local currentThemeName = "Midnight"
    local themeTargets = {}

    local function themeColor(role)
        return themes[currentThemeName][role]
    end

    local function registerTheme(instance, property, role)
        table.insert(themeTargets, {
            instance = instance,
            property = property,
            role = role,
        })
        instance[property] = themeColor(role)
    end

    local function applyTheme(name)
        if not themes[name] then
            return
        end
        currentThemeName = name
        for _, target in ipairs(themeTargets) do
            if target.instance and target.instance.Parent then
                pcall(function()
                    target.instance[target.property] = themeColor(target.role)
                end)
            end
        end
    end

    local function create(className, properties, parent)
        local instance = Instance.new(className)
        for property, value in pairs(properties or {}) do
            instance[property] = value
        end
        instance.Parent = parent
        return instance
    end

    local function addCorner(instance, radius)
        create("UICorner", {
            CornerRadius = UDim.new(0, radius or 10),
        }, instance)
    end

    local function addStroke(instance, role, transparency)
        local stroke = create("UIStroke", {
            Thickness = 1,
            Transparency = transparency or 0.35,
        }, instance)
        registerTheme(stroke, "Color", role or "stroke")
        return stroke
    end

    local function makeLabel(parent, text, size, position, fontSize, bold, role)
        local label = create("TextLabel", {
            BackgroundTransparency = 1,
            Size = size,
            Position = position,
            Text = text,
            Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham,
            TextSize = fontSize or 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            TextWrapped = false,
        }, parent)
        registerTheme(label, "TextColor3", role or "text")
        return label
    end

    local function makeButton(parent, text, size, position, role, callback)
        local button = create("TextButton", {
            AutoButtonColor = false,
            Size = size,
            Position = position,
            BackgroundColor3 = themeColor(role or "card"),
            BorderSizePixel = 0,
            Text = text,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
        }, parent)
        registerTheme(button, "BackgroundColor3", role or "card")
        registerTheme(button, "TextColor3", "text")
        addCorner(button, 9)
        if callback then
            button.MouseButton1Click:Connect(callback)
        end
        return button
    end

    --------------------------------------------------------------------
    -- Screen and main window
    --------------------------------------------------------------------

    local screen = create("ScreenGui", {
        Name = "NexusBoostV2",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 50,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, playerGui)

    local window = create("Frame", {
        Name = "Window",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(0.86, 0, 0.78, 0),
        BackgroundColor3 = themeColor("background"),
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, screen)
    registerTheme(window, "BackgroundColor3", "background")
    addCorner(window, 16)
    addStroke(window, "stroke", 0.18)

    create("UISizeConstraint", {
        MinSize = Vector2.new(330, 360),
        MaxSize = Vector2.new(760, 520),
    }, window)

    TweenService:Create(
        window,
        TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        { Size = UDim2.new(0.9, 0, 0.82, 0) }
    ):Play()

    local topbar = create("Frame", {
        Name = "Topbar",
        Size = UDim2.new(1, 0, 0, 58),
        BackgroundColor3 = themeColor("panel"),
        BorderSizePixel = 0,
    }, window)
    registerTheme(topbar, "BackgroundColor3", "panel")

    local title = makeLabel(topbar, "NEXUS BOOST", UDim2.new(0, 210, 0, 25), UDim2.fromOffset(18, 7), 18, true, "accent")
    local subtitle = makeLabel(topbar, "CLIENT PERFORMANCE PANEL  /  V2", UDim2.new(0, 260, 0, 17), UDim2.fromOffset(19, 32), 9, false, "muted")

    local collapseButton = makeButton(topbar, "☰", UDim2.fromOffset(34, 32), UDim2.new(1, -84, 0, 13), "card")
    collapseButton.TextSize = 16
    local closeButton = makeButton(topbar, "×", UDim2.fromOffset(34, 32), UDim2.new(1, -44, 0, 13), "card", function()
        if restoreVisualSettings then
            restoreVisualSettings()
        end
        screen:Destroy()
    end)
    closeButton.TextSize = 19

    local sidebar = create("Frame", {
        Name = "Sidebar",
        Position = UDim2.fromOffset(0, 58),
        Size = UDim2.new(0, 150, 1, -58),
        BackgroundColor3 = themeColor("panel"),
        BorderSizePixel = 0,
    }, window)
    registerTheme(sidebar, "BackgroundColor3", "panel")

    makeLabel(sidebar, "WORKSPACE", UDim2.new(1, -24, 0, 22), UDim2.fromOffset(14, 12), 9, true, "muted")

    local content = create("Frame", {
        Name = "Content",
        Position = UDim2.fromOffset(164, 70),
        Size = UDim2.new(1, -178, 1, -84),
        BackgroundTransparency = 1,
    }, window)

    local pages = {}
    local navButtons = {}
    local function createPage(name)
        local page = create("Frame", {
            Name = name,
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Visible = false,
        }, content)
        pages[name] = page
        return page
    end

    local dashboardPage = createPage("Dashboard")
    local graphicsPage = createPage("Graphics")
    local settingsPage = createPage("Settings")

    local function showPage(name)
        for pageName, page in pairs(pages) do
            page.Visible = pageName == name
        end
        for buttonName, button in pairs(navButtons) do
            button.BackgroundColor3 = buttonName == name and themeColor("accent") or themeColor("card")
        end
    end

    local function addNav(name, icon, y)
        local button = makeButton(sidebar, icon .. "   " .. name, UDim2.new(1, -20, 0, 38), UDim2.fromOffset(10, y), "card", function()
            showPage(name)
        end)
        button.TextXAlignment = Enum.TextXAlignment.Left
        button.TextSize = 11
        local pad = create("UIPadding", { PaddingLeft = UDim.new(0, 12) }, button)
        navButtons[name] = button
        return button
    end

    addNav("Dashboard", "⌂", 43)
    addNav("Graphics", "◈", 88)
    addNav("Settings", "⚙", 133)

    local sidebarCollapsed = false
    collapseButton.MouseButton1Click:Connect(function()
        sidebarCollapsed = not sidebarCollapsed
        sidebar.Visible = not sidebarCollapsed
        if sidebarCollapsed then
            content.Position = UDim2.fromOffset(14, 70)
            content.Size = UDim2.new(1, -28, 1, -84)
        else
            content.Position = UDim2.fromOffset(164, 70)
            content.Size = UDim2.new(1, -178, 1, -84)
        end
    end)

    --------------------------------------------------------------------
    -- Dashboard page
    --------------------------------------------------------------------

    makeLabel(dashboardPage, "Performance overview", UDim2.new(1, 0, 0, 30), UDim2.fromOffset(2, 0), 20, true, "text")
    makeLabel(dashboardPage, "Quick controls and live client readings", UDim2.new(1, 0, 0, 20), UDim2.fromOffset(3, 29), 10, false, "muted")

    local statsHolder = create("Frame", {
        Position = UDim2.fromOffset(0, 68),
        Size = UDim2.new(1, 0, 0, 93),
        BackgroundTransparency = 1,
    }, dashboardPage)

    local statCards = {}
    local statSpecs = {
        { name = "FPS", value = "--", suffix = "frames / sec" },
        { name = "MEMORY", value = "--", suffix = "client usage" },
        { name = "ACTIVE MODE", value = "NORMAL", suffix = "visual profile" },
    }

    for index, spec in ipairs(statSpecs) do
        local card = create("Frame", {
            Position = UDim2.new((index - 1) / 3, 0, 0, 0),
            Size = UDim2.new(1 / 3, -9, 1, 0),
            BackgroundColor3 = themeColor("card"),
            BorderSizePixel = 0,
        }, statsHolder)
        registerTheme(card, "BackgroundColor3", "card")
        addCorner(card, 11)
        addStroke(card, "stroke", 0.55)
        makeLabel(card, spec.name, UDim2.new(1, -18, 0, 17), UDim2.fromOffset(10, 9), 9, true, "muted")
        local value = makeLabel(card, spec.value, UDim2.new(1, -18, 0, 28), UDim2.fromOffset(10, 29), index == 3 and 14 or 22, true, index == 3 and "green" or "text")
        makeLabel(card, spec.suffix, UDim2.new(1, -18, 0, 15), UDim2.fromOffset(10, 65), 8, false, "muted")
        statCards[spec.name] = value
    end

    local maxButton = makeButton(dashboardPage, "⚡   APPLY MAX OPTIMIZATION", UDim2.new(1, 0, 0, 47), UDim2.fromOffset(0, 180), "accent")
    maxButton.TextSize = 13

    local restoreButton = makeButton(dashboardPage, "RESTORE ORIGINAL VISUAL SETTINGS", UDim2.new(1, 0, 0, 39), UDim2.fromOffset(0, 237), "card")

    local statusLabel = makeLabel(dashboardPage, "Ready. No optimization settings are enabled.", UDim2.new(1, 0, 0, 38), UDim2.fromOffset(2, 290), 10, false, "muted")
    statusLabel.TextWrapped = true
    statusLabel.TextYAlignment = Enum.TextYAlignment.Top

    makeLabel(dashboardPage, "Note: FPS and memory readings are client-side estimates.", UDim2.new(1, 0, 0, 22), UDim2.fromOffset(2, 344), 9, false, "muted")

    --------------------------------------------------------------------
    -- Graphics page and toggle rows
    --------------------------------------------------------------------

    makeLabel(graphicsPage, "Graphics optimization", UDim2.new(1, 0, 0, 30), UDim2.fromOffset(2, 0), 20, true, "text")
    makeLabel(graphicsPage, "Each switch changes visuals locally on your client", UDim2.new(1, 0, 0, 20), UDim2.fromOffset(3, 29), 10, false, "muted")

    local toggleScroll = create("ScrollingFrame", {
        Position = UDim2.fromOffset(0, 61),
        Size = UDim2.new(1, 0, 1, -61),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageTransparency = 0.25,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, graphicsPage)
    local toggleLayout = create("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, toggleScroll)
    create("UIPadding", {
        PaddingBottom = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 4),
    }, toggleScroll)

    local toggleSetters = {}
    local toggleDefinitions = {
        { key = "LowGraphics", title = "Low graphics materials", desc = "Use simple materials and remove reflectance." },
        { key = "DisableShadows", title = "Disable shadows", desc = "Turn off global and part-cast shadows." },
        { key = "DisableParticles", title = "Disable particles and effects", desc = "Hide emitters, trails, beams, smoke and fire." },
        { key = "DisableLights", title = "Disable local lights", desc = "Turn off point, spot and surface lights." },
        { key = "HideTextures", title = "Hide decals and textures", desc = "Make Decal and Texture instances transparent." },
        { key = "DisablePostFX", title = "Disable post-processing", desc = "Turn off bloom, blur, depth-of-field and similar effects." },
    }

    local function updateModeLabel()
        local allOn = true
        local anyOn = false
        for _, value in pairs(states) do
            if value then anyOn = true else allOn = false end
        end
        if allOn then
            statCards["ACTIVE MODE"].Text = "MAX"
        elseif anyOn then
            statCards["ACTIVE MODE"].Text = "CUSTOM"
        else
            statCards["ACTIVE MODE"].Text = "NORMAL"
        end
    end

    local function setOptimization(key, enabled)
        if states[key] == nil then
            return
        end
        states[key] = enabled
        applyAllInstances()
        updateModeLabel()
    end

    local function makeToggleRow(definition)
        local row = create("Frame", {
            Size = UDim2.new(1, -6, 0, 59),
            BackgroundColor3 = themeColor("card"),
            BorderSizePixel = 0,
        }, toggleScroll)
        registerTheme(row, "BackgroundColor3", "card")
        addCorner(row, 10)

        makeLabel(row, definition.title, UDim2.new(1, -105, 0, 23), UDim2.fromOffset(12, 7), 11, true, "text")
        local description = makeLabel(row, definition.desc, UDim2.new(1, -105, 0, 18), UDim2.fromOffset(12, 30), 8, false, "muted")
        description.TextTruncate = Enum.TextTruncate.AtEnd

        local switch = create("TextButton", {
            Size = UDim2.fromOffset(52, 27),
            Position = UDim2.new(1, -66, 0.5, -13),
            BackgroundColor3 = themeColor("panel"),
            BorderSizePixel = 0,
            Text = "OFF",
            Font = Enum.Font.GothamBold,
            TextSize = 9,
            AutoButtonColor = false,
        }, row)
        registerTheme(switch, "TextColor3", "text")
        addCorner(switch, 20)

        local function refresh()
            local on = states[definition.key]
            switch.Text = on and "ON" or "OFF"
            switch.BackgroundColor3 = on and themeColor("accent") or themeColor("panel")
        end

        switch.MouseButton1Click:Connect(function()
            setOptimization(definition.key, not states[definition.key])
            refresh()
            statusLabel.Text = definition.title .. (states[definition.key] and " enabled." or " disabled.")
        end)

        toggleSetters[definition.key] = refresh
        refresh()
    end

    for _, definition in ipairs(toggleDefinitions) do
        makeToggleRow(definition)
    end

    --------------------------------------------------------------------
    -- Settings page and theme picker
    --------------------------------------------------------------------

    makeLabel(settingsPage, "Appearance & information", UDim2.new(1, 0, 0, 30), UDim2.fromOffset(2, 0), 20, true, "text")
    makeLabel(settingsPage, "Choose a color theme for the control panel", UDim2.new(1, 0, 0, 20), UDim2.fromOffset(3, 29), 10, false, "muted")

    local themeButtons = {}
    local themeNames = { "Midnight", "Violet", "Ocean", "Crimson" }
    for index, name in ipairs(themeNames) do
        local row = index <= 2 and 1 or 2
        local column = (index - 1) % 2
        local button = makeButton(settingsPage, name, UDim2.new(0.48, 0, 0, 42), UDim2.new(column * 0.52, 0, 0, 72 + (row - 1) * 53), "card", function()
            applyTheme(name)
            for themeName, themeButton in pairs(themeButtons) do
                themeButton.Text = themeName == name and ("✓  " .. themeName) or themeName
            end
        end)
        themeButtons[name] = button
    end
    themeButtons.Midnight.Text = "✓  Midnight"

    local infoPanel = create("Frame", {
        Position = UDim2.fromOffset(0, 190),
        Size = UDim2.new(1, 0, 0, 150),
        BackgroundColor3 = themeColor("card"),
        BorderSizePixel = 0,
    }, settingsPage)
    registerTheme(infoPanel, "BackgroundColor3", "card")
    addCorner(infoPanel, 11)
    makeLabel(infoPanel, "ABOUT NEXUS BOOST", UDim2.new(1, -24, 0, 23), UDim2.fromOffset(13, 10), 10, true, "accent")
    local about = makeLabel(infoPanel,
        "This tool adjusts supported local visual properties. It cannot disable the entire 3D renderer, force a specific FPS, or directly clear Roblox memory. World streaming and server-side settings must be configured by the experience developer.",
        UDim2.new(1, -26, 0, 102), UDim2.fromOffset(13, 37), 9, false, "muted")
    about.TextWrapped = true
    about.TextYAlignment = Enum.TextYAlignment.Top

    --------------------------------------------------------------------
    -- Presets and restore behavior
    --------------------------------------------------------------------

    local function refreshAllToggleButtons()
        for _, refresh in pairs(toggleSetters) do
            refresh()
        end
        updateModeLabel()
    end

    local function applyMaxOptimization()
        for key in pairs(states) do
            states[key] = true
        end
        applyAllInstances()
        refreshAllToggleButtons()
        statusLabel.Text = "MAX OPTIMIZATION applied. Some game visuals may look very simple or disappear."
    end

    restoreVisualSettings = function()
        for key in pairs(states) do
            states[key] = false
        end
        applyAllInstances()
        refreshAllToggleButtons()
        statusLabel.Text = "Original supported visual properties have been restored."
    end

    maxButton.MouseButton1Click:Connect(applyMaxOptimization)
    restoreButton.MouseButton1Click:Connect(restoreVisualSettings)

    --------------------------------------------------------------------
    -- Live performance readouts
    --------------------------------------------------------------------

    local frameCount = 0
    local fpsElapsed = 0
    local memoryElapsed = 0
    local currentFPS = 0
    local currentMemory = nil

    local function updateMemoryReadout()
        local ok, memory = pcall(function()
            return Stats:GetTotalMemoryUsageMb()
        end)
        if ok and type(memory) == "number" then
            currentMemory = memory
            statCards.MEMORY.Text = string.format("%.0f MB", memory)
        else
            statCards.MEMORY.Text = "N/A"
        end
    end

    local renderConnection
    renderConnection = RunService.RenderStepped:Connect(function(deltaTime)
        frameCount += 1
        fpsElapsed += deltaTime
        memoryElapsed += deltaTime

        if fpsElapsed >= 0.5 then
            currentFPS = math.floor(frameCount / math.max(fpsElapsed, 0.001) + 0.5)
            statCards.FPS.Text = tostring(currentFPS)
            frameCount = 0
            fpsElapsed = 0
        end

        if memoryElapsed >= 2 then
            updateMemoryReadout()
            memoryElapsed = 0
        end
    end)

    -- Disconnect the local sampling connection when this GUI is removed.
    screen.Destroying:Connect(function()
        if restoreVisualSettings then
            restoreVisualSettings()
        end
        if renderConnection then
            renderConnection:Disconnect()
            renderConnection = nil
        end
        for _, connection in ipairs(externalConnections) do
            connection:Disconnect()
        end
        table.clear(externalConnections)
    end)

    --------------------------------------------------------------------
    -- Window dragging (mouse and touch)
    --------------------------------------------------------------------

    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPosition = nil

    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragInput = input
            dragStart = input.Position
            startPosition = window.Position
        end
    end)

    trackConnection(UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            window.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end))

    trackConnection(UserInputService.InputEnded:Connect(function(input)
        if input == dragInput or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            dragInput = nil
        end
    end))

    --------------------------------------------------------------------
    -- Initial UI and visual state
    --------------------------------------------------------------------

    showPage("Dashboard")
    updateMemoryReadout()
    applyAllInstances()
    print("NEXUS BOOST V2 loaded. Open the Graphics tab to adjust local visual settings.")
end

startNexusBoost()

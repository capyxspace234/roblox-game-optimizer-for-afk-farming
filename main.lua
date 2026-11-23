-- ═══════════════════════════════════════════════
--  AFK Optimizer v2 — Liquid Glass UI
-- ═══════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer

-- ─── STATE ───────────────────────────────────
local state = {
    rendering = false,
    fpsCap = false,
    fpsValue = 15,
    shadows = false,
    lighting = false,
    fog = false,
    grass = false,
    particles = false,
    postFX = false,
    quality = false,
    terrain = false,
}

-- ─── CORE FUNCTIONS ──────────────────────────
local function toggleRendering(on)
    RunService:Set3dRenderingEnabled(not on)
end

local function setFps(on)
    if on then
        setfpscap(state.fpsValue)
    else
        setfpscap(0)
    end
end

local function toggleShadows(on)
    Lighting.GlobalShadows = not on
end

local function toggleLighting(on)
    Lighting.Technology = on and Enum.Technology.FixedFunction or Enum.Technology.Future
    if on then
        Lighting.ColorCorrection = nil
        Lighting:BakeAll()
    end
end

local function toggleFog(on)
    if on then
        Lighting.FogEnd = 50
        Lighting.FogStart = 1
    else
        Lighting.FogEnd = 1e9
        Lighting.FogStart = 0
    end
end

local function toggleGrass(on)
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        terrain.WaterWaveSize = on and 0 or 1
        terrain.WaterWaveSpeed = on and 0 or 1
        terrain.WaterReflectance = on and 0 or 0.5
    end
    -- Disable grass via fastflag if available
    if setfflag then
        setfflag("DFGrassEnable", on and false or true)
        setfflag("DFEnableGrass", on and false or true)
    end
end

local function toggleParticles(on)
    if on then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") then
                obj.Rate = 0
            end
        end
    end
end

local function togglePostFX(on)
    for _, obj in pairs(Lighting:GetChildren()) do
        if on and (obj:IsA("BloomEffect") or obj:IsA("ColorCorrectionEffect")
            or obj:IsA("DepthOfFieldEffect") or obj:IsA("SunRaysEffect")
            or obj:IsA("Atmosphere")) then
            obj.Enabled = false
        end
    end
end

local function toggleQuality(on)
    settings().Rendering.QualityLevel = on and 1 or 9
    if on then
        settings().Rendering.Shadows = false
        settings().Rendering.Lights = false
    else
        settings().Rendering.Shadows = true
        settings().Rendering.Lights = true
    end
end

-- ─── UNLOAD ──────────────────────────────────
local screenGui
local function unload()
    -- Restore everything
    RunService:Set3dRenderingEnabled(true)
    setfpscap(0)
    Lighting.GlobalShadows = true
    Lighting.Technology = Enum.Technology.Future
    Lighting.FogEnd = 1e9
    Lighting.FogStart = 0
    settings().Rendering.QualityLevel = 9
    settings().Rendering.Shadows = true
    settings().Rendering.Lights = true
    for _, obj in pairs(Lighting:GetChildren()) do
        if obj:IsA("BloomEffect") or obj:IsA("ColorCorrectionEffect")
            or obj:IsA("DepthOfFieldEffect") or obj:IsA("SunRaysEffect")
            or obj:IsA("Atmosphere") then
            obj.Enabled = true
        end
    end
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") then
            obj.Rate = 30
        end
    end
    if screenGui then screenGui:Destroy() end
end

-- ─── UI ──────────────────────────────────────
screenGui = Instance.new("ScreenGui")
screenGui.Name = "AFKOptimizerV2"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main container (liquid glass)
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 260, 0, 420)
main.Position = UDim2.new(1, -270, 0.5, -210)
main.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
main.BackgroundTransparency = 0.35
main.BorderSizePixel = 0
main.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 20)
mainCorner.Parent = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(255, 255, 255)
mainStroke.Transparency = 0.7
mainStroke.Thickness = 1
mainStroke.Parent = main

local mainBlur = Instance.new("UIGradient")
mainBlur.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 55)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 30)),
})
mainBlur.Rotation = 90
mainBlur.Parent = main

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "AFK Optimizer"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Position = UDim2.new(0, 20, 0, 10)
title.Parent = main

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, 0, 0, 16)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Liquid Glass Edition"
subtitle.TextColor3 = Color3.fromRGB(150, 150, 170)
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 11
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Position = UDim2.new(0, 20, 0, 32)
subtitle.Parent = main

-- Divider
local divider = Instance.new("Frame")
divider.Size = UDim2.new(1, -40, 0, 1)
divider.Position = UDim2.new(0, 20, 0, 52)
divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
divider.BackgroundTransparency = 0.8
divider.Parent = main

-- Scrollable content
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 1, -80)
scroll.Position = UDim2.new(0, 10, 0, 60)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = main

local scrollCorner = Instance.new("UICorner")
scrollCorner.Parent = scroll

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 6)
list.Parent = scroll

-- ─── TOGGLE BUILDER ─────────────────────────
local function makeToggle(label, key, onToggle, icon)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 40)
    container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    container.BackgroundTransparency = 0.92
    container.Parent = scroll

    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(0, 12)
    cCorner.Parent = container

    local cStroke = Instance.new("UIStroke")
    cStroke.Color = Color3.fromRGB(255, 255, 255)
    cStroke.Transparency = 0.85
    cStroke.Thickness = 0.5
    cStroke.Parent = container

    local labelFrame = Instance.new("TextLabel")
    labelFrame.Size = UDim2.new(1, -50, 1, 0)
    labelFrame.Position = UDim2.new(0, 14, 0, 0)
    labelFrame.BackgroundTransparency = 1
    labelFrame.Text = (icon and icon .. "  " or "") .. label
    labelFrame.TextColor3 = Color3.fromRGB(220, 220, 230)
    labelFrame.Font = Enum.Font.Gotham
    labelFrame.TextSize = 13
    labelFrame.TextXAlignment = Enum.TextXAlignment.Left
    labelFrame.Parent = container

    -- Toggle switch (pill shape)
    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(0, 40, 0, 22)
    toggle.Position = UDim2.new(1, -48, 0.5, -11)
    toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    toggle.BackgroundTransparency = 0.3
    toggle.Parent = container

    local tCorner = Instance.new("UICorner")
    tCorner.CornerRadius = UDim.new(1, 0)
    tCorner.Parent = toggle

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = UDim2.new(0, 2, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(200, 200, 210)
    knob.Parent = toggle

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local function updateToggle(on)
        toggle.BackgroundColor3 = on and Color3.fromRGB(48, 167, 107) or Color3.fromRGB(60, 60, 70)
        toggle.BackgroundTransparency = on and 0.1 or 0.3
        knob.Position = on and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        knob.BackgroundColor3 = on and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 210)
        labelFrame.TextColor3 = on and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(220, 220, 230)
    end

    updateToggle(state[key])

    local clickArea = Instance.new("TextButton")
    clickArea.Size = UDim2.new(1, 0, 1, 0)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""
    clickArea.AutoButtonColor = false
    clickArea.Parent = container

    clickArea.MouseButton1Click:Connect(function()
        state[key] = not state[key]
        onToggle(state[key])
        updateToggle(state[key])
    end)

    return container
end

-- ─── FPS SLIDER ──────────────────────────────
local fpsContainer = Instance.new("Frame")
fpsContainer.Size = UDim2.new(1, 0, 0, 56)
fpsContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
fpsContainer.BackgroundTransparency = 0.92
fpsContainer.Parent = scroll

local fcCorner = Instance.new("UICorner")
fcCorner.CornerRadius = UDim.new(0, 12)
fcCorner.Parent = fpsContainer

local fcStroke = Instance.new("UIStroke")
fcStroke.Color = Color3.fromRGB(255, 255, 255)
fcStroke.Transparency = 0.85
fcStroke.Thickness = 0.5
fcStroke.Parent = fpsContainer

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(1, -20, 0, 18)
fpsLabel.Position = UDim2.new(0, 14, 0, 6)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "🎮  FPS Cap"
fpsLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
fpsLabel.Font = Enum.Font.Gotham
fpsLabel.TextSize = 13
fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
fpsLabel.Parent = fpsContainer

local fpsValueLabel = Instance.new("TextLabel")
fpsValueLabel.Size = UDim2.new(0, 40, 0, 18)
fpsValueLabel.Position = UDim2.new(1, -50, 0, 6)
fpsValueLabel.BackgroundTransparency = 1
fpsValueLabel.Text = tostring(state.fpsValue) .. " fps"
fpsValueLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
fpsValueLabel.Font = Enum.Font.GothamMedium
fpsValueLabel.TextSize = 12
fpsValueLabel.TextXAlignment = Enum.TextXAlignment.Right
fpsValueLabel.Parent = fpsContainer

local slider = Instance.new("TextButton")
slider.Size = UDim2.new(1, -28, 0, 8)
slider.Position = UDim2.new(0, 14, 0, 32)
slider.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
slider.Text = ""
slider.AutoButtonColor = false
slider.Parent = fpsContainer

local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(1, 0)
sliderCorner.Parent = slider

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(0.25, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
sliderFill.BackgroundTransparency = 0.2
sliderFill.Parent = slider

local sliderFillCorner = Instance.new("UICorner")
sliderFillCorner.CornerRadius = UDim.new(1, 0)
sliderFillCorner.Parent = sliderFill

local dragging = false
local function updateSlider(pos)
    local rel = math.clamp((pos - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
    local val = math.floor(rel * 59) + 1 -- 1 to 60
    state.fpsValue = val
    fpsValueLabel.Text = val .. " fps"
    sliderFill.Size = UDim2.new(rel, 0, 1, 0)
    if state.fpsCap then setfpscap(val) end
end

slider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        updateSlider(input.Position.X)
    end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        updateSlider(input.Position.X)
    end
end)
game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

local fpsToggle = Instance.new("TextButton")
fpsToggle.Size = UDim2.new(0, 40, 0, 22)
fpsToggle.Position = UDim2.new(1, -52, 0, 6)
fpsToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
fpsToggle.Text = ""
fpsToggle.AutoButtonColor = true
fpsToggle.Parent = fpsContainer
local ftc = Instance.new("UICorner")
ftc.CornerRadius = UDim.new(1, 0)
ftc.Parent = fpsToggle

local fpsKnob = Instance.new("Frame")
fpsKnob.Size = UDim2.new(0, 18, 0, 18)
fpsKnob.Position = UDim2.new(0, 2, 0.5, -9)
fpsKnob.BackgroundColor3 = Color3.fromRGB(200, 200, 210)
fpsKnob.Parent = fpsToggle
local fkc = Instance.new("UICorner")
fkc.CornerRadius = UDim.new(1, 0)
fkc.Parent = fpsKnob

fpsToggle.MouseButton1Click:Connect(function()
    state.fpsCap = not state.fpsCap
    setFps(state.fpsCap)
    fpsToggle.BackgroundColor3 = state.fpsCap and Color3.fromRGB(48, 167, 107) or Color3.fromRGB(60, 60, 70)
    fpsKnob.Position = state.fpsCap and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
end)

-- ─── ADD TOGGLES ─────────────────────────────
makeToggle("3D Rendering", "rendering", toggleRendering, "🖥️")
makeToggle("Quality Level 1", "quality", toggleQuality, "⚡")
makeToggle("Shadows", "shadows", toggleShadows, "🌑")
makeToggle("Lighting (Fixed)", "lighting", toggleLighting, "💡")
makeToggle("Fog", "fog", toggleFog, "🌫️")
makeToggle("Grass & Water", "grass", toggleGrass, "🌿")
makeToggle("Particles", "particles", toggleParticles, "✨")
makeToggle("Post-Processing FX", "postFX", togglePostFX, "🎨")
makeToggle("Terrain Optimize", "terrain", function(on)
    local t = workspace:FindFirstChildOfClass("Terrain")
    if t then
        t.WaterWaveSize = on and 0 or 1
        t.WaterWaveSpeed = on and 0 or 1
        t.WaterReflectance = on and 0 or 0.5
        t.WaterTransparency = on and 1 or 0
    end
end, "🏔️")

-- ─── UNLOAD BUTTON ───────────────────────────
local unloadBtn = Instance.new("TextButton")
unloadBtn.Size = UDim2.new(1, -40, 0, 36)
unloadBtn.Position = UDim2.new(0, 20, 1, -46)
unloadBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
unloadBtn.BackgroundTransparency = 0.2
unloadBtn.Text = "  Unload & Restore All"
unloadBtn.TextColor3 = Color3.fromRGB(255, 220, 220)
unloadBtn.Font = Enum.Font.GothamMedium
unloadBtn.TextSize = 13
unloadBtn.Parent = main

local ubCorner = Instance.new("UICorner")
ubCorner.CornerRadius = UDim.new(0, 12)
ubCorner.Parent = unloadBtn

local ubStroke = Instance.new("UIStroke")
ubStroke.Color = Color3.fromRGB(255, 100, 100)
ubStroke.Transparency = 0.6
ubStroke.Thickness = 1
ubStroke.Parent = unloadBtn

unloadBtn.MouseButton1Click:Connect(unload)

-- ─── DRAG ────────────────────────────────────
local isDragging, dragStart, startPos
main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)
main.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
    end
end)
local dragInput
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)
RunService:RenderStepped:Connect(function()
    if isDragging and dragInput then
        local delta = dragInput.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

print("[AFK Optimizer v2] Loaded ✓")   
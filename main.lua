-- AFK Optimizer v3
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer

local state = {
    rendering=false, fpsCap=false, fpsValue=15,
    shadows=false, lighting=false, fog=false,
    grass=false, particles=false, postFX=false,
    quality=false, terrain=false
}

-- Safe wrappers
local function safe(fn)
    pcall(fn)
end

local function toggleRendering(on)
    safe(function() RunService:Set3dRenderingEnabled(not on) end)
end

local function setFps(on)
    safe(function() setfpscap(on and state.fpsValue or 0) end)
end

local function toggleShadows(on)
    safe(function() Lighting.GlobalShadows = not on end)
end

local function toggleLighting(on)
    safe(function()
        Lighting.Technology = on and Enum.Technology.FixedFunction or Enum.Technology.Future
    end)
end

local function toggleFog(on)
    safe(function()
        Lighting.FogEnd = on and 50 or 1e9
        Lighting.FogStart = on and 1 or 0
    end)
end

local function toggleGrass(on)
    safe(function()
        local t = workspace:FindFirstChildOfClass("Terrain")
        if t then
            t.WaterWaveSize = on and 0 or 1
            t.WaterWaveSpeed = on and 0 or 1
            t.WaterReflectance = on and 0 or 0.5
        end
        if setfflag then
            setfflag("DFGrassEnable", on and false or true)
            setfflag("DFEnableGrass", on and false or true)
        end
    end)
end

local function toggleParticles(on)
    safe(function()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") then
                obj.Rate = on and 0 or 30
            end
        end
    end)
end

local function togglePostFX(on)
    safe(function()
        for _, obj in pairs(Lighting:GetChildren()) do
            if on and (obj:IsA("BloomEffect") or obj:IsA("ColorCorrectionEffect")
                or obj:IsA("DepthOfFieldEffect") or obj:IsA("SunRaysEffect")
                or obj:IsA("Atmosphere")) then
                obj.Enabled = false
            end
        end
    end)
end

local function toggleQuality(on)
    safe(function()
        settings().Rendering.QualityLevel = on and 1 or 9
    end)
end

local function toggleTerrain(on)
    safe(function()
        local t = workspace:FindFirstChildOfClass("Terrain")
        if t then
            t.WaterWaveSize = on and 0 or 1
            t.WaterWaveSpeed = on and 0 or 1
            t.WaterReflectance = on and 0 or 0.5
            t.WaterTransparency = on and 1 or 0
        end
    end)
end

-- Unload
local screenGui
local function unload()
    safe(function() RunService:Set3dRenderingEnabled(true) end)
    safe(function() setfpscap(0) end)
    safe(function() Lighting.GlobalShadows = true end)
    safe(function() Lighting.Technology = Enum.Technology.Future end)
    safe(function()
        Lighting.FogEnd = 1e9
        Lighting.FogStart = 0
    end)
    safe(function() settings().Rendering.QualityLevel = 9 end)
    safe(function()
        for _, obj in pairs(Lighting:GetChildren()) do
            if obj:IsA("BloomEffect") or obj:IsA("ColorCorrectionEffect")
                or obj:IsA("DepthOfFieldEffect") or obj:IsA("SunRaysEffect")
                or obj:IsA("Atmosphere") then
                obj.Enabled = true
            end
        end
    end)
    safe(function()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") then obj.Rate = 30 end
        end
    end)
    if screenGui then screenGui:Destroy() end
end

-- UI
screenGui = Instance.new("ScreenGui")
screenGui.Name = "AFKOptimizerV3"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 260, 0, 440)
main.Position = UDim2.new(1, -270, 0.5, -220)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
main.BackgroundTransparency = 0.3
main.BorderSizePixel = 0
main.Parent = screenGui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 18)
local ms = Instance.new("UIStroke")
ms.Color = Color3.fromRGB(255,255,255)
ms.Transparency = 0.75
ms.Thickness = 1
ms.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,36)
title.Position = UDim2.new(0,0,0,10)
title.BackgroundTransparency = 1
title.Text = "AFK Optimizer"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.GothamBold
title.TextSize = 17
title.TextXAlignment = Enum.TextXAlignment.Left
title.Position = UDim2.new(0,20,0,12)
title.Parent = main

local sub = Instance.new("TextLabel")
sub.Size = UDim2.new(1,0,0,14)
sub.Position = UDim2.new(0,20,0,36)
sub.BackgroundTransparency = 1
sub.Text = "v3 - Liquid Glass"
sub.TextColor3 = Color3.fromRGB(140,140,160)
sub.Font = Enum.Font.Gotham
sub.TextSize = 11
sub.TextXAlignment = Enum.TextXAlignment.Left
sub.Parent = main

local div = Instance.new("Frame")
div.Size = UDim2.new(1,-40,0,1)
div.Position = UDim2.new(0,20,0,54)
div.BackgroundColor3 = Color3.fromRGB(255,255,255)
div.BackgroundTransparency = 0.8
div.Parent = main

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1,-20,1,-100)
scroll.Position = UDim2.new(0,10,0,62)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = Color3.fromRGB(255,255,255)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = main

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0,5)
list.Parent = scroll

-- Toggle builder (no emojis)
local function makeToggle(label, key, fn)
    local c = Instance.new("Frame")
    c.Size = UDim2.new(1,0,0,38)
    c.BackgroundColor3 = Color3.fromRGB(255,255,255)
    c.BackgroundTransparency = 0.93
    c.Parent = scroll
    Instance.new("UICorner", c).CornerRadius = UDim.new(0,10)
    local cs = Instance.new("UIStroke")
    cs.Color = Color3.fromRGB(255,255,255)
    cs.Transparency = 0.88
    cs.Thickness = 0.5
    cs.Parent = c

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-54,1,0)
    lbl.Position = UDim2.new(0,12,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(210,210,220)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = c

    local tog = Instance.new("Frame")
    tog.Size = UDim2.new(0,38,0,20)
    tog.Position = UDim2.new(1,-46,0.5,-10)
    tog.BackgroundColor3 = Color3.fromRGB(55,55,65)
    tog.BackgroundTransparency = 0.2
    tog.Parent = c
    Instance.new("UICorner", tog).CornerRadius = UDim.new(1,0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0,16,0,16)
    knob.Position = UDim2.new(0,2,0.5,-8)
    knob.BackgroundColor3 = Color3.fromRGB(190,190,200)
    knob.Parent = tog
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

    local function upd(on)
        tog.BackgroundColor3 = on and Color3.fromRGB(48,167,107) or Color3.fromRGB(55,55,65)
        knob.Position = on and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)
        knob.BackgroundColor3 = on and Color3.fromRGB(255,255,255) or Color3.fromRGB(190,190,200)
    end

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,1,0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = c

    btn.MouseButton1Click:Connect(function()
        state[key] = not state[key]
        fn(state[key])
        upd(state[key])
    end)
end

makeToggle("3D Rendering", "rendering", toggleRendering)
makeToggle("Quality Level 1", "quality", toggleQuality)
makeToggle("Shadows Off", "shadows", toggleShadows)
makeToggle("Fixed Function Lighting", "lighting", toggleLighting)
makeToggle("Fog Off", "fog", toggleFog)
makeToggle("Grass & Water Off", "grass", toggleGrass)
makeToggle("Particles Off", "particles", toggleParticles)
makeToggle("Post-FX Off", "postFX", togglePostFX)
makeToggle("Terrain Optimize", "terrain", toggleTerrain)

-- FPS slider
local fc = Instance.new("Frame")
fc.Size = UDim2.new(1,0,0,52)
fc.BackgroundColor3 = Color3.fromRGB(255,255,255)
fc.BackgroundTransparency = 0.93
fc.Parent = scroll
Instance.new("UICorner", fc).CornerRadius = UDim.new(0,10)
local fcs = Instance.new("UIStroke")
fcs.Color = Color3.fromRGB(255,255,255)
fcs.Transparency = 0.88
fcs.Thickness = 0.5
fcs.Parent = fc

local fl = Instance.new("TextLabel")
fl.Size = UDim2.new(1,-60,0,16)
fl.Position = UDim2.new(0,12,0,6)
fl.BackgroundTransparency = 1
fl.Text = "FPS Cap"
fl.TextColor3 = Color3.fromRGB(210,210,220)
fl.Font = Enum.Font.Gotham
fl.TextSize = 13
fl.TextXAlignment = Enum.TextXAlignment.Left
fl.Parent = fc

local fv = Instance.new("TextLabel")
fv.Size = UDim2.new(0,36,0,16)
fv.Position = UDim2.new(1,-44,0,6)
fv.BackgroundTransparency = 1
fv.Text = state.fpsValue .. " fps"
fv.TextColor3 = Color3.fromRGB(100,200,255)
fv.Font = Enum.Font.GothamMedium
fv.TextSize = 12
fv.TextXAlignment = Enum.TextXAlignment.Right
fv.Parent = fc

local sl = Instance.new("Frame")
sl.Size = UDim2.new(1,-24,0,6)
sl.Position = UDim2.new(0,12,0,30)
sl.BackgroundColor3 = Color3.fromRGB(50,50,60)
sl.Parent = fc
Instance.new("UICorner", sl).CornerRadius = UDim.new(1,0)

local sf = Instance.new("Frame")
sf.Size = UDim2.new(0.25,0,1,0)
sf.BackgroundColor3 = Color3.fromRGB(100,180,255)
sf.Parent = sl
Instance.new("UICorner", sf).CornerRadius = UDim.new(1,0)

local sdrag = false
local function updSlider(x)
    local r = math.clamp((x - sl.AbsolutePosition.X) / sl.AbsoluteSize.X, 0, 1)
    local v = math.floor(r * 59) + 1
    state.fpsValue = v
    fv.Text = v .. " fps"
    sf.Size = UDim2.new(r,0,1,0)
    if state.fpsCap then safe(function() setfpscap(v) end) end
end

sl.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then sdrag=true; updSlider(i.Position.X) end
end)
UIS.InputChanged:Connect(function(i)
    if sdrag and i.UserInputType == Enum.UserInputType.MouseMovement then updSlider(i.Position.X) end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then sdrag=false end
end)

-- FPS toggle
local ft = Instance.new("Frame")
ft.Size = UDim2.new(0,38,0,20)
ft.Position = UDim2.new(1,-50,0,4)
ft.BackgroundColor3 = Color3.fromRGB(55,55,65)
ft.BackgroundTransparency = 0.2
ft.Parent = fc
Instance.new("UICorner", ft).CornerRadius = UDim.new(1,0)
local fknob = Instance.new("Frame")
fknob.Size = UDim2.new(0,16,0,16)
fknob.Position = UDim2.new(0,2,0.5,-8)
fknob.BackgroundColor3 = Color3.fromRGB(190,190,200)
fknob.Parent = ft
Instance.new("UICorner", fknob).CornerRadius = UDim.new(1,0)

local fbtn = Instance.new("TextButton")
fbtn.Size = UDim2.new(1,0,1,0)
fbtn.BackgroundTransparency = 1
fbtn.Text = ""
fbtn.AutoButtonColor = false
fbtn.Parent = ft
fbtn.MouseButton1Click:Connect(function()
    state.fpsCap = not state.fpsCap
    setFps(state.fpsCap)
    ft.BackgroundColor3 = state.fpsCap and Color3.fromRGB(48,167,107) or Color3.fromRGB(55,55,65)
    fknob.Position = state.fpsCap and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)
end)

-- Unload button
local ub = Instance.new("TextButton")
ub.Size = UDim2.new(1,-40,0,34)
ub.Position = UDim2.new(0,20,1,-44)
ub.BackgroundColor3 = Color3.fromRGB(160,45,45)
ub.BackgroundTransparency = 0.15
ub.Text = "Unload & Restore All"
ub.TextColor3 = Color3.fromRGB(255,220,220)
ub.Font = Enum.Font.GothamMedium
ub.TextSize = 13
ub.Parent = main
Instance.new("UICorner", ub).CornerRadius = UDim.new(0,10)
local ubs = Instance.new("UIStroke")
ubs.Color = Color3.fromRGB(255,100,100)
ubs.Transparency = 0.6
ubs.Thickness = 1
ubs.Parent = ub
ub.MouseButton1Click:Connect(unload)

-- Drag
local dragging, ds, sp, di
main.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging=true; ds=i.Position; sp=main.Position
    end
end)
main.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging=false end
end)
UIS.InputChanged:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseMovement then di=i end
end)
RunService:RenderStepped:Connect(function()
    if dragging and di then
        local d = di.Position - ds
        main.Position = UDim2.new(sp.X.Scale, sp.X.Offset+d.X, sp.Y.Scale, sp.Y.Offset+d.Y)
    end
end)

print("[AFK Optimizer v3] Loaded")   
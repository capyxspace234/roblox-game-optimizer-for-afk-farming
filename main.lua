-- Roblox AFK Farm Optimizer (Intel Mac compatible)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- State
local state = {
    rendering = false,
    fpsCap = false,
    quality = false,
    terrain = false,
    textures = false,
    unfocused = false,
}

-- Core functions
local function setRendering(enabled)
    RunService:Set3dRenderingEnabled(not enabled)
end

local function setFps(cap)
    if cap then
        setfpscap(1)
    else
        setfpscap(0)
    end
end

local function setQuality(enabled)
    if enabled then
        settings().Rendering.QualityLevel = 1
    else
        settings().Rendering.QualityLevel = 9
    end
end

local function setTerrain(enabled)
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        if enabled then
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0
            terrain.WaterTransparency = 1
        else
            terrain.WaterWaveSize = 1
            terrain.WaterWaveSpeed = 1
            terrain.WaterReflectance = 0.5
            terrain.WaterTransparency = 0
        end
    end
end

local function setTextures(enabled)
    if enabled then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Decal") or obj:IsA("Texture") then
                obj:Destroy()
            end
        end
    end
end

-- Unfocused window handler
local focusedConn
local function setUnfocused(enabled)
    if focusedConn then focusedConn:Disconnect() end
    if enabled then
        focusedConn = RunService:BindToRenderStep("UnfocusedCheck", Enum.RenderPriority.Last.Value, function()
            if not game:GetService("GuiService"):GetGuiInset() then return end
            -- Use window focus check
            local focused = userinput and userinput:GetFocusedWindow()
        end)
        -- Simpler approach: check every 5s
        task.spawn(function()
            while state.unfocused do
                task.wait(5)
                if not player:FindFirstChild("Mouse") then return end
                -- Detect if window lost focus via rendering check
                if not RunService:IsRunning() then return end
            end
        end)
        -- Fallback: just cap FPS low and disable rendering when idle
        RunService:BindToRenderStep("AFKCheck", Enum.RenderPriority.Last.Value, function()
            if state.unfocused then
                RunService:Set3dRenderingEnabled(false)
            end
        end)
    else
        RunService:Set3dRenderingEnabled(true)
    end
end

-- UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AFKOptimizer"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 220, 0, 280)
frame.Position = UDim2.new(1, -230, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "⚙ AFK Optimizer"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = frame

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 4)
list.HorizontalAlignment = Enum.HorizontalAlignment.Center
list.Parent = frame

local pad = Instance.new("UIPadding")
pad.PaddingTop = UDim.new(0, 34)
pad.PaddingLeft = UDim.new(0, 10)
pad.PaddingRight = UDim.new(0, 10)
pad.Parent = frame

local toggles = {}

local function makeToggle(label, key, onToggle)
    local btn = Instance.new("TextButton")
    btn.Name = key
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    btn.Text = label .. "  [OFF]"
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.AutoButtonColor = true
    btn.Parent = frame

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 6)
    bc.Parent = btn

    btn.MouseButton1Click:Connect(function()
        state[key] = not state[key]
        onToggle(state[key])
        btn.Text = label .. (state[key] and "  [ON]" or "  [OFF]")
        btn.BackgroundColor3 = state[key] and Color3.fromRGB(40, 80, 50) or Color3.fromRGB(35, 35, 45)
        btn.TextColor3 = state[key] and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(180, 180, 180)
    end)

    toggles[key] = btn
    return btn
end

makeToggle("3D Rendering", "rendering", function(on)
    setRendering(on)
end)

makeToggle("FPS Cap (1)", "fpsCap", function(on)
    setFps(on)
end)

makeToggle("Quality Level 1", "quality", function(on)
    setQuality(on)
end)

makeToggle("Terrain Opt", "terrain", function(on)
    setTerrain(on)
end)

makeToggle("Remove Textures", "textures", function(on)
    setTextures(on)
end)

makeToggle("Unfocused Mode", "unfocused", function(on)
    setUnfocused(on)
end)

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(1, 0, 0, 24)
closeBtn.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
closeBtn.Text = "✕ Close"
closeBtn.TextColor3 = Color3.fromRGB(200, 100, 100)
closeBtn.Font = Enum.Font.Gotham
closeBtn.TextSize = 11
closeBtn.Parent = frame

local cc = Instance.new("UICorner")
cc.CornerRadius = UDim.new(0, 6)
cc.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Drag
local dragging
local dragInput
local dragStart, startPos

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

frame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

game:GetService("RunService").RenderStepped:Connect(function()
    if dragging and dragInput then
        local delta = dragInput.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                   startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)   
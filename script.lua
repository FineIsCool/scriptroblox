local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Fine's menu",
    Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
    LoadingTitle = "Fine is goat",
    LoadingSubtitle = "Made by Fine",
    Theme = "Ocean", -- Check https://docs.sirius.menu/rayfield/configuration/themes
 
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface
 
    ConfigurationSaving = {
       Enabled = true,
       FolderName = fine, -- Create a custom folder for your hub/game
       FileName = "fine script"
    },
 
    Discord = {
       Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
       Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
       RememberJoins = true -- Set this to false to make them join the discord every time they load it up
    },
 
    KeySystem = true, -- Set this to true to use our key system
    KeySettings = {
       Title = "Fine's key system",
       Subtitle = "Key system",
       Note = "Dm fine for key", -- Use this to tell the user how to get a key
       FileName = "fine script", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
       SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
       GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
       Key = {"skbidisigmafine", "negr", "heil_fine"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
    }
 })

 -- loadstrings

local TargetHud = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stratxgy/Lua-TargetHud/refs/heads/main/targethud.lua"))()
local speed = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stratxgy/Lua-Speed/refs/heads/main/speed.lua"))()


 
local ESPTab = Window:CreateTab("Visual", "users")



-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer


-- Variables for Luxury ESP
local espEnabled = false
local espHighlights = {}
local espLabels = {}
local showUsername = false
local showHealth = false
local showDistance = false

-- Variables for Box ESP
local boxEspEnabled = false
local boxEspBoxes = {}
local boxEspHealthBars = {}
local boxEspNameLabels = {}

-- Variables for Tracers
local tracerEnabled = false
local tracers = {}

-- Default colors
local luxuryEspColor = Color3.fromRGB(255, 215, 0) -- Gold
local boxEspColor = Color3.fromRGB(255, 215, 0) -- Gold
local tracerColor = Color3.fromRGB(255, 215, 0) -- Gold


-- Function to create or update Luxury ESP
local function createLuxuryESP(targetPlayer)
    if targetPlayer == player or not targetPlayer.Character then return end

    local character = targetPlayer.Character
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end

    local highlight = espHighlights[targetPlayer]
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "LuxuryESP"
        highlight.FillColor = luxuryEspColor
        highlight.OutlineColor = Color3.new(1, 1, 1)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Adornee = character
        highlight.Parent = character
        espHighlights[targetPlayer] = highlight
    end

    local billboard = espLabels[targetPlayer]
    if not billboard then
        billboard = Instance.new("BillboardGui")
        billboard.Name = "LuxuryESP_Label"
        billboard.Size = UDim2.new(0, 150, 0, 40)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Adornee = rootPart
        billboard.Parent = rootPart

        local frame = Instance.new("Frame", billboard)
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1

        local label = Instance.new("TextLabel", frame)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = luxuryEspColor
        label.TextStrokeTransparency = 0
        label.TextStrokeColor3 = Color3.new(1, 1, 1)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 12
        label.Text = "" -- Start with empty text

        espLabels[targetPlayer] = billboard
    end

    local label = billboard:FindFirstChildOfClass("Frame"):FindFirstChildOfClass("TextLabel")
    RunService.RenderStepped:Connect(function()
        if not espEnabled or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            if billboard then billboard:Destroy() end
            if highlight then highlight:Destroy() end
            espLabels[targetPlayer] = nil
            espHighlights[targetPlayer] = nil
            return
        end
        local distance = (player.Character and player.Character:FindFirstChild("HumanoidRootPart") and (player.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude) or 0
        -- Build the label text based on toggle states
        local textParts = {}
        if showUsername then
            table.insert(textParts, targetPlayer.Name)
        end
        if showHealth then
            table.insert(textParts, "Health: " .. math.floor(humanoid.Health))
        end
        if showDistance then
            table.insert(textParts, "Distance: " .. string.format("%.1f", distance))
        end
        label.Text = table.concat(textParts, "\n")
    end)
end

-- Function to create or update Box ESP
local function createBoxESP(targetPlayer)
    if targetPlayer == player or not targetPlayer.Character then return end

    local character = targetPlayer.Character
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end

    local box = boxEspBoxes[targetPlayer]
    if not box then
        box = Instance.new("SelectionBox")
        box.Name = "BoxESP"
        box.LineThickness = 0.05
        box.Color3 = boxEspColor
        box.SurfaceColor3 = boxEspColor
        box.SurfaceTransparency = 1
        box.Adornee = character
        box.Parent = character
        boxEspBoxes[targetPlayer] = box
    end

    local healthBar = boxEspHealthBars[targetPlayer]
    if not healthBar then
        healthBar = Instance.new("BillboardGui")
        healthBar.Name = "BoxESP_HealthBar"
        healthBar.Size = UDim2.new(0, 10, 0, 50)
        healthBar.StudsOffset = Vector3.new(3, 0, 0)
        healthBar.AlwaysOnTop = true
        healthBar.Adornee = rootPart
        healthBar.Parent = rootPart

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        frame.BorderSizePixel = 0
        frame.Parent = healthBar

        local healthFill = Instance.new("Frame")
        healthFill.Name = "HealthFill"
        healthFill.Size = UDim2.new(1, 0, 1, 0)
        healthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Default to green
        healthFill.BorderSizePixel = 0
        healthFill.Parent = frame

        boxEspHealthBars[targetPlayer] = healthBar
    end

    local nameLabel = boxEspNameLabels[targetPlayer]
    if not nameLabel then
        nameLabel = Instance.new("BillboardGui")
        nameLabel.Name = "BoxESP_NameLabel"
        nameLabel.Size = UDim2.new(0, 100, 0, 30)
        nameLabel.StudsOffset = Vector3.new(0, -4, 0)
        nameLabel.AlwaysOnTop = true
        nameLabel.Adornee = rootPart
        nameLabel.Parent = rootPart

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.Parent = nameLabel

        local nameText = Instance.new("TextLabel")
        nameText.Size = UDim2.new(1, 0, 0.6, 0)
        nameText.Position = UDim2.new(0, 0, 0, 0)
        nameText.BackgroundTransparency = 1
        nameText.TextColor3 = boxEspColor
        nameText.TextStrokeTransparency = 0
        nameText.TextStrokeColor3 = Color3.new(1, 1, 1)
        nameText.Font = Enum.Font.GothamBold
        nameText.TextSize = 12
        nameText.Text = targetPlayer.Name
        nameText.Parent = frame

        local distanceText = Instance.new("TextLabel")
        distanceText.Size = UDim2.new(1, 0, 0.4, 0)
        distanceText.Position = UDim2.new(0, 0, 0.6, 0)
        distanceText.BackgroundTransparency = 1
        distanceText.TextColor3 = boxEspColor
        distanceText.TextStrokeTransparency = 0
        distanceText.TextStrokeColor3 = Color3.new(1, 1, 1)
        distanceText.Font = Enum.Font.Gotham
        distanceText.TextSize = 10
        distanceText.Parent = frame

        boxEspNameLabels[targetPlayer] = nameLabel
    end

    local healthFrame = healthBar:FindFirstChildOfClass("Frame")
    if not healthFrame then return end
    local healthFill = healthFrame:FindFirstChild("HealthFill")
    local nameFrame = nameLabel:FindFirstChildOfClass("Frame")
    if not nameFrame then return end
    local distanceText = nameFrame:FindFirstChild("TextLabel", true)
    for _, child in pairs(nameFrame:GetChildren()) do
        if child:IsA("TextLabel") and child.Text ~= targetPlayer.Name then
            distanceText = child
            break
        end
    end
    RunService.RenderStepped:Connect(function()
        if not boxEspEnabled or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            if box then box:Destroy() end
            if healthBar then healthBar:Destroy() end
            if nameLabel then nameLabel:Destroy() end
            boxEspBoxes[targetPlayer] = nil
            boxEspHealthBars[targetPlayer] = nil
            boxEspNameLabels[targetPlayer] = nil
            return
        end
        local distance = (player.Character and player.Character:FindFirstChild("HumanoidRootPart") and (player.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude) or 0
        local scale = math.clamp(1 - (distance / 100), 0.3, 1)
        healthBar.Size = UDim2.new(0, 10 * scale, 0, 50 * scale)
        if healthFill then
            healthFill.Size = UDim2.new(1, 0, humanoid.Health / humanoid.MaxHealth, 0)
            if humanoid.Health > 51 then
                healthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Green
            else
                healthFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Red
            end
        end
        if distanceText then
            distanceText.Text = string.format("%.1f studs", distance)
        end
    end)
end

-- Function to create or update Tracer
local function createTracer(targetPlayer)
    if targetPlayer == player or not targetPlayer.Character or not player.Character then return end

    local myCharacter = player.Character
    local myChest = myCharacter:FindFirstChild("UpperTorso") or myCharacter:FindFirstChild("Torso")
    local targetCharacter = targetPlayer.Character
    local targetChest = targetCharacter:FindFirstChild("UpperTorso") or targetCharacter:FindFirstChild("Torso")
    if not myChest or not targetChest then return end

    local tracer = tracers[targetPlayer]
    if not tracer then
        tracer = {}
        local attachment0 = Instance.new("Attachment")
        attachment0.Position = Vector3.new(0, 0, 0)
        attachment0.Parent = myChest

        local attachment1 = Instance.new("Attachment")
        attachment1.Position = Vector3.new(0, 0, 0)
        attachment1.Parent = targetChest

        local beam = Instance.new("Beam")
        beam.Name = "TracerBeam"
        beam.Attachment0 = attachment0
        beam.Attachment1 = attachment1
        beam.Color = ColorSequence.new(tracerColor)
        beam.Width0 = 0.1
        beam.Width1 = 0.1
        beam.Transparency = NumberSequence.new(0)
        beam.Parent = myChest

        tracer.Attachment0 = attachment0
        tracer.Attachment1 = attachment1
        tracer.Beam = beam
        tracers[targetPlayer] = tracer
    end

    RunService.RenderStepped:Connect(function()
        if not tracerEnabled or not targetPlayer.Character or not player.Character or not targetPlayer.Character:FindFirstChild("UpperTorso") and not targetPlayer.Character:FindFirstChild("Torso") or not player.Character:FindFirstChild("UpperTorso") and not player.Character:FindFirstChild("Torso") then
            if tracer then
                if tracer.Attachment0 then tracer.Attachment0:Destroy() end
                if tracer.Attachment1 then tracer.Attachment1:Destroy() end
                if tracer.Beam then tracer.Beam:Destroy() end
                tracers[targetPlayer] = nil
            end
            return
        end
    end)
end

-- Function to toggle Luxury ESP
local function toggleLuxuryESP(value)
    espEnabled = value
    if not value then
        for _, highlight in pairs(espHighlights) do
            highlight:Destroy()
        end
        for _, label in pairs(espLabels) do
            label:Destroy()
        end
        espHighlights = {}
        espLabels = {}
    else
        for _, targetPlayer in pairs(Players:GetPlayers()) do
            createLuxuryESP(targetPlayer)
        end
    end
end

-- Function to toggle Box ESP
local function toggleBoxESP(value)
    boxEspEnabled = value
    if not value then
        for _, box in pairs(boxEspBoxes) do
            box:Destroy()
        end
        for _, healthBar in pairs(boxEspHealthBars) do
            healthBar:Destroy()
        end
        for _, nameLabel in pairs(boxEspNameLabels) do
            nameLabel:Destroy()
        end
        boxEspBoxes = {}
        boxEspHealthBars = {}
        boxEspNameLabels = {}
    else
        for _, targetPlayer in pairs(Players:GetPlayers()) do
            createBoxESP(targetPlayer)
        end
    end
end

-- Function to toggle Tracers
local function toggleTracers(value)
    tracerEnabled = value
    if not value then
        for _, tracer in pairs(tracers) do
            if tracer.Attachment0 then tracer.Attachment0:Destroy() end
            if tracer.Attachment1 then tracer.Attachment1:Destroy() end
            if tracer.Beam then tracer.Beam:Destroy() end
        end
        tracers = {}
    else
        for _, targetPlayer in pairs(Players:GetPlayers()) do
            createTracer(targetPlayer)
        end
    end
end

-- Toggle for Luxury ESP
local Toggle = ESPTab:CreateToggle({
    Name = "Enable Luxury ESP",
    CurrentValue = false,
    Flag = "ESPToggle",
    Callback = function(value)
        toggleLuxuryESP(value)
        Rayfield:Notify({
            Title = value and "Luxury ESP Enabled" or "Luxury ESP Disabled",
            Content = value and "Luxury ESP activated!" or "Luxury ESP deactivated.",
            Duration = 3
        })
    end
})


-- Toggle for Box ESP
local Toggle = ESPTab:CreateToggle({
    Name = "Enable Box ESP",
    CurrentValue = false,
    Flag = "BoxESPToggle",
    Callback = function(value)
        toggleBoxESP(value)
        Rayfield:Notify({
            Title = value and "Box ESP Enabled" or "Box ESP Disabled",
            Content = value and "Box ESP activated!" or "Box ESP deactivated.",
            Duration = 3
        })
    end
})

-- Toggle for Tracers
local Toggle = ESPTab:CreateToggle({
    Name = "Enable Tracers",
    CurrentValue = false,
    Flag = "TracerToggle",
    Callback = function(value)
        toggleTracers(value)
        Rayfield:Notify({
            Title = value and "Tracers Enabled" or "Tracers Disabled",
            Content = value and "Tracers activated!" or "Tracers deactivated.",
            Duration = 3
        })
    end
})

-- Handle player added with error handling
if Players then
    Players.PlayerAdded:Connect(function(targetPlayer)
        if espEnabled then
            createLuxuryESP(targetPlayer)
        end
        if boxEspEnabled then
            createBoxESP(targetPlayer)
        end
        if tracerEnabled then
            createTracer(targetPlayer)
        end
    end)
else
    warn("Players service is not available. PlayerAdded event will not be connected.")
end

-- Handle player removing
if Players then
    Players.PlayerRemoving:Connect(function(targetPlayer)
        if espHighlights[targetPlayer] then
            espHighlights[targetPlayer]:Destroy()
            espHighlights[targetPlayer] = nil
        end
        if espLabels[targetPlayer] then
            espLabels[targetPlayer]:Destroy()
            espLabels[targetPlayer] = nil
        end
        if boxEspBoxes[targetPlayer] then
            boxEspBoxes[targetPlayer]:Destroy()
            boxEspBoxes[targetPlayer] = nil
        end
        if boxEspHealthBars[targetPlayer] then
            boxEspHealthBars[targetPlayer]:Destroy()
            boxEspHealthBars[targetPlayer] = nil
        end
        if boxEspNameLabels[targetPlayer] then
            boxEspNameLabels[targetPlayer]:Destroy()
            boxEspNameLabels[targetPlayer] = nil
        end
        if tracers[targetPlayer] then
            local tracer = tracers[targetPlayer]
            if tracer.Attachment0 then tracer.Attachment0:Destroy() end
            if tracer.Attachment1 then tracer.Attachment1:Destroy() end
            if tracer.Beam then tracer.Beam:Destroy() end
            tracers[targetPlayer] = nil
        end
    end)
else
    warn("Players service is not available. PlayerRemoving event will not be connected.")
end

-- Handle local player character added
if player then
    player.CharacterAdded:Connect(function(character)
        if tracerEnabled then
            for _, targetPlayer in pairs(Players:GetPlayers()) do
                createTracer(targetPlayer)
            end
        end
    end)
else
    warn("Local player is not available. CharacterAdded event will not be connected.")
end

local Section = ESPTab:CreateSection("Luxury Settings")

-- Label for Usage Instructions
ESPTab:CreateLabel("Luxury ESP toggled to use.")

-- Toggle for Show Username
local Toggle = ESPTab:CreateToggle({
    Name = "Show Username",
    CurrentValue = false,
    Flag = "ShowUsernameToggle",
    Callback = function(value)
        showUsername = value
        Rayfield:Notify({
            Title = value and "Username Display Enabled" or "Username Display Disabled",
            Content = value and "Username display activated!" or "Username display deactivated.",
            Duration = 3
        })
    end
})

-- Toggle for Show Health
local Toggle = ESPTab:CreateToggle({
    Name = "Show Health",
    CurrentValue = false,
    Flag = "ShowHealthToggle",
    Callback = function(value)
        showHealth = value
        Rayfield:Notify({
            Title = value and "Health Display Enabled" or "Health Display Disabled",
            Content = value and "Health display activated!" or "Health display deactivated.",
            Duration = 3
        })
    end
})

-- Toggle for Show Distance
local Toggle = ESPTab:CreateToggle({
    Name = "Show Distance",
    CurrentValue = false,
    Flag = "ShowDistanceToggle",
    Callback = function(value)
        showDistance = value
        Rayfield:Notify({
            Title = value and "Distance Display Enabled" or "Distance Display Disabled",
            Content = value and "Distance display activated!" or "Distance display deactivated.",
            Duration = 3
        })
    end
})


local Section = ESPTab:CreateSection("Visual Settings")

-- Color Picker for Luxury ESP
local ColorPicker = ESPTab:CreateColorPicker({
    Name = "Luxury ESP Color",
    Color = luxuryEspColor,
    Flag = "LuxuryESPColorPicker",
    Callback = function(Value)
        luxuryEspColor = Value
        for _, highlight in pairs(espHighlights) do
            highlight.FillColor = luxuryEspColor
            highlight.OutlineColor = Color3.new(1, 1, 1)
        end
        for _, billboard in pairs(espLabels) do
            local label = billboard:FindFirstChildOfClass("Frame"):FindFirstChildOfClass("TextLabel")
            if label then
                label.TextColor3 = luxuryEspColor
                label.TextStrokeColor3 = Color3.new(1, 1, 1)
            end
        end
    end
})

-- Color Picker for Box ESP
local Slider = ESPTab:CreateColorPicker({
    Name = "Box ESP Color",
    Color = boxEspColor,
    Flag = "BoxESPColorPicker",
    Callback = function(Value)
        boxEspColor = Value
        for _, box in pairs(boxEspBoxes) do
            box.Color3 = boxEspColor
            box.SurfaceColor3 = boxEspColor
        end
        for _, nameLabel in pairs(boxEspNameLabels) do
            local nameFrame = nameLabel:FindFirstChildOfClass("Frame")
            if nameFrame then
                for _, child in pairs(nameFrame:GetChildren()) do
                    if child:IsA("TextLabel") then
                        child.TextColor3 = boxEspColor
                        child.TextStrokeColor3 = Color3.new(1, 1, 1)
                    end
                end
            end
        end
    end
})

-- Color Picker for Tracers
local Slider = ESPTab:CreateColorPicker({
    Name = "Tracer Color",
    Color = tracerColor,
    Flag = "TracerColorPicker",
    Callback = function(Value)
        tracerColor = Value
        for _, tracer in pairs(tracers) do
            tracer.Beam.Color = ColorSequence.new(tracerColor)
        end
    end
})


-- Notify script loaded
Rayfield:Notify({
    Title = "Luxury ESP",
    Content = "Luxury ESP script loaded!",
    Duration = 5,
    Image = "eye"
})

local Section = ESPTab:CreateSection("Brightness")

-- Services
local Lighting = game:GetService("Lighting")


-- Initialize variables
local isEnabled = false
local originalBrightness = Lighting.Brightness
local originalAmbient = Lighting.Ambient
local originalOutdoorAmbient = Lighting.OutdoorAmbient
local originalFogEnd = Lighting.FogEnd
local originalClockTime = Lighting.ClockTime
local originalGlobalShadows = Lighting.GlobalShadows

-- Function to enable Full Bright
local function enableFullBright()
    Lighting.Brightness = 2
    Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    Lighting.FogEnd = 100000
    Lighting.ClockTime = 14
    Lighting.GlobalShadows = false
end

-- Function to disable Full Bright (restore original settings)
local function disableFullBright()
    Lighting.Brightness = originalBrightness
    Lighting.Ambient = originalAmbient
    Lighting.OutdoorAmbient = originalOutdoorAmbient
    Lighting.FogEnd = originalFogEnd
    Lighting.ClockTime = originalClockTime
    Lighting.GlobalShadows = originalGlobalShadows
end

-- Toggle: Enable/Disable Full Bright
ESPTab:CreateToggle({
    Name = "Enable Full Bright",
    CurrentValue = false,
    Flag = "FullBrightToggle",
    Callback = function(value)
        isEnabled = value
        if isEnabled then
            enableFullBright()
            Rayfield:Notify({
                Title = "Full Bright",
                Content = "Full Bright enabled.",
                Duration = 3,
                Image = "user"
            })
        else
            disableFullBright()
            Rayfield:Notify({
                Title = "Full Bright",
                Content = "Full Bright disabled.",
                Duration = 3,
                Image = "user"
            })
        end
    end
})

-- Slider: Brightness Level
ESPTab:CreateSlider({
    Name = "Brightness Level",
    Range = {0, 5},
    Increment = 0.1,
    Suffix = "",
    CurrentValue = 2,
    Flag = "BrightnessSlider",
    Callback = function(value)
        if isEnabled then
            Lighting.Brightness = value
            Rayfield:Notify({
                Title = "Brightness Level",
                Content = "Brightness set to " .. value .. ".",
                Duration = 3,
                Image = "user"
            })
        end
    end
})

-- Notify script loaded
Rayfield:Notify({
    Title = "Script Loaded",
    Content = "Full Bright script loaded!",
    Duration = 5,
    Image = "user"
})



local PlayerTab = Window:CreateTab("Movement", "Globe")

local Section = PlayerTab:CreateSection("Fly")


-- Variables for flying
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local flying = false
local speed = 50 -- Default fly speed
local bodyVelocity = nil
local bodyGyro = nil
local camera = workspace.CurrentCamera
local inputService = game:GetService("UserInputService")

-- Function to start flying
local function startFlying()
    if not flying then
        flying = true
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.Parent = humanoidRootPart

        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.D = 500
        bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bodyGyro.P = 3000
        bodyGyro.Parent = humanoidRootPart

        humanoid.PlatformStand = true -- Prevents falling

        -- Flying logic with WASD, Shift, Control, and mouse steering
        game:GetService("RunService").RenderStepped:Connect(function()
            if flying then
                local direction = Vector3.new(0, 0, 0)
                local camLook = camera.CFrame.LookVector.Unit
                local camRight = camera.CFrame.RightVector.Unit

                -- Forward movement (W)
                if inputService:IsKeyDown(Enum.KeyCode.W) then
                    direction = direction + (camLook * speed)
                end

                -- Left movement (A)
                if inputService:IsKeyDown(Enum.KeyCode.A) then
                    direction = direction - (camRight * speed)
                end

                -- Right movement (D)
                if inputService:IsKeyDown(Enum.KeyCode.D) then
                    direction = direction + (camRight * speed)
                end

                -- Backward movement (S)
                if inputService:IsKeyDown(Enum.KeyCode.S) then
                    direction = direction - (camLook * speed)
                end

                -- Up movement (Shift)
                if inputService:IsKeyDown(Enum.KeyCode.LeftShift) or inputService:IsKeyDown(Enum.KeyCode.RightShift) then
                    direction = direction + Vector3.new(0, speed, 0)
                end

                -- Down movement (Control)
                if inputService:IsKeyDown(Enum.KeyCode.LeftControl) or inputService:IsKeyDown(Enum.KeyCode.RightControl) then
                    direction = direction - Vector3.new(0, speed, 0)
                end

                -- Vertical steering with right-click and mouse movement
                if inputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                    local mouseDelta = inputService:GetMouseDelta()
                    local verticalMove = -mouseDelta.Y * 0.5 -- Adjust sensitivity here
                    direction = direction + Vector3.new(0, verticalMove, 0)
                end

                bodyVelocity.Velocity = direction
                bodyGyro.CFrame = camera.CFrame -- Align with camera direction
            end
        end)

        Rayfield:Notify({
            Title = "Flying Enabled",
            Content = "WASD to move, Shift to go up, Control to go down, Right-click + mouse to steer pitch!",
            Duration = 5,
            Image = nil
        })
    end
end

-- Function to stop flying and land safely
local function stopFlying()
    if flying then
        flying = false
        
        -- Destroy flying components
        if bodyVelocity then 
            bodyVelocity.Velocity = Vector3.new(0, 0, 0) -- Clear velocity before destroying
            bodyVelocity:Destroy() 
            bodyVelocity = nil
        end
        if bodyGyro then 
            bodyGyro:Destroy() 
            bodyGyro = nil
        end

        -- Reset humanoid state
        humanoid.PlatformStand = false
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) -- Ensures proper transition to standing

        -- Safely place character on ground
        if humanoidRootPart then
            local rayOrigin = humanoidRootPart.Position
            local rayDirection = Vector3.new(0, -100, 0) -- Cast ray downward to find ground
            local raycastParams = RaycastParams.new()
            raycastParams.FilterDescendantsInstances = {character}
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

            local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
            if raycastResult then
                -- Position character just above the ground
                humanoidRootPart.CFrame = CFrame.new(raycastResult.Position + Vector3.new(0, 3, 0))
                humanoidRootPart.Velocity = Vector3.new(0, 0, 0) -- Clear any residual velocity
            else
                -- If no ground found, just clear velocity and let physics settle
                humanoidRootPart.Velocity = Vector3.new(0, 0, 0)
            end
        end

        Rayfield:Notify({
            Title = "Flying Disabled",
            Content = "You have landed safely.",
            Duration = 3,
            Image = nil
        })
    end
end

-- Toggle Fly Button with debug
local Toggle = PlayerTab:CreateToggle({
    Name = "Toggle Fly",
    CurrentValue = false,
    Flag = "ToggleFly", -- Add a flag to save toggle state
    Callback = function(value)
        -- Debug: Print the type and value of the argument
        print("Toggle Fly Callback - Value:", value, "Type:", typeof(value))
        
        -- Ensure value is a boolean
        if typeof(value) == "boolean" then
            if value then
                startFlying()
            else
                stopFlying()
            end
        else
            -- If value is not a boolean, log an error and do nothing
            warn("Toggle Fly Callback received invalid value type: " .. typeof(value))
        end
    end
})




-- Slider for adjusting fly speed
local Slider = PlayerTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 100},
    Increment = 5,
    Suffix = "Speed",
    CurrentValue = 50,
    Flag = "FlySpeed", -- Add a flag to save slider value
    Callback = function(value)
        -- Debug: Print the type and value of the argument
        print("Fly Speed Callback - Value:", value, "Type:", typeof(value))
        
        -- Ensure value is a number
        if typeof(value) == "number" then
            speed = value
            Rayfield:Notify({
                Title = "Speed Updated",
                Content = "Fly speed set to " .. value,
                Duration = 2,
                Image = nil
            })
        else
            warn("Fly Speed Callback received invalid value type: " .. typeof(value))
        end
    end
})

-- Handle character reset
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    if flying then
        startFlying()
    end
end)

-- Notify user that the fly controls are loaded
Rayfield:Notify({
    Title = "Fly Controls Loaded",
    Content = "Toggle flying and adjust speed below!",
    Duration = 5,
    Image = nil
})

local Section = PlayerTab:CreateSection("Gravity")

-- Services
local Workspace = game:GetService("Workspace")

-- Initialize variables
local isEnabled = false
local originalGravity = Workspace.Gravity or 196.2 -- Default Roblox gravity if not set
local currentGravity = originalGravity

-- Function to update gravity
local function updateGravity()
    if isEnabled then
        Workspace.Gravity = currentGravity
    else
        Workspace.Gravity = originalGravity
    end
end

-- Toggle: Enable/Disable Custom Gravity
PlayerTab:CreateToggle({
    Name = "Enable Custom Gravity",
    CurrentValue = false,
    Flag = "GravityToggle",
    Callback = function(value)
        isEnabled = value
        updateGravity()
        Rayfield:Notify({
            Title = "Gravity Control",
            Content = "Custom Gravity " .. (isEnabled and "enabled" or "disabled") .. ".",
            Duration = 3,
            Image = "user"
        })
    end
})

-- Slider: Gravity
PlayerTab:CreateSlider({
    Name = "Gravity",
    Range = {0, 500},
    Increment = 1,
    Suffix = "",
    CurrentValue = originalGravity,
    Flag = "GravitySlider",
    Callback = function(value)
        currentGravity = value
        updateGravity()
        Rayfield:Notify({
            Title = "Gravity Updated",
            Content = "Gravity set to " .. value .. ".",
            Duration = 3,
            Image = "user"
        })
    end
})

-- Notify script loaded
Rayfield:Notify({
    Title = "Script Loaded",
    Content = "Gravity Control script loaded!",
    Duration = 5,
    Image = "user"
})
 
 
 


local Section = PlayerTab:CreateSection("Speed")
 
local speedEnabled = false
local walkSpeed = 16

local Toggle = PlayerTab:CreateToggle({
    Name = "Enable Speed Boost",
    CurrentValue = false,
    Flag = "SpeedToggle",
    Callback = function(Value)
        speedEnabled = Value
        if speedEnabled then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = walkSpeed
        else
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16 -- Reset to default
        end
    end
})




local Slider = PlayerTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 500},
    Increment = 2,
    Suffix = "Speed",
    CurrentValue = 16,
    Flag = "SpeedSlider",
    Callback = function(Value)
        walkSpeed = Value
        if speedEnabled then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = walkSpeed
        end
    end
})

local Section = PlayerTab:CreateSection("Jump")



local jumpEnabled = false
local jumpPower = 50
 
local Toggle = PlayerTab:CreateToggle({
     Name = "Enable Jump Power",
     CurrentValue = false,
     Flag = "JumpToggle",
     Callback = function(Value)
         jumpEnabled = Value
         if jumpEnabled then
             game.Players.LocalPlayer.Character.Humanoid.UseJumpPower = true
             game.Players.LocalPlayer.Character.Humanoid.JumpPower = jumpPower
         else
             game.Players.LocalPlayer.Character.Humanoid.JumpPower = 50 -- Reset to default
         end
     end
 })
 
local Slider = PlayerTab:CreateSlider({
     Name = "Jump Power",
     Range = {50, 500},
     Increment = 10,
     Suffix = "Power",
     CurrentValue = 50,
     Flag = "JumpSlider",
     Callback = function(Value)
         jumpPower = Value
         if jumpEnabled then
             game.Players.LocalPlayer.Character.Humanoid.JumpPower = jumpPower
         end
     end
 })


 local SpillerTab = Window:CreateTab("Player", "user")
 local Section = SpillerTab:CreateSection("Player")


 
 -- Infinity jump
local Button = SpillerTab:CreateToggle({
    Name = "Infinite Jump",
    Callback = function()
 --Toggles the infinite jump between on or off on every script run
 _G.infinjump = not _G.infinjump
 
 if _G.infinJumpStarted == nil then
     --Ensures this only runs once to save resources
     _G.infinJumpStarted = true
     
     --Notifies readiness
     game.StarterGui:SetCore("SendNotification", {Title="Infinite Jump."; Text="Infinite jump activated..."; Duration=2;})
 
     --The actual infinite jump
     local plr = game:GetService('Players').LocalPlayer
     local m = plr:GetMouse()
     m.KeyDown:connect(function(k)
         if _G.infinjump then
             if k:byte() == 32 then
             humanoid = game:GetService'Players'.LocalPlayer.Character:FindFirstChildOfClass('Humanoid')
             humanoid:ChangeState('Jumping')
             wait()
             humanoid:ChangeState('Seated')
             end
         end
     end)
 end
    end,
})
-- noclip under
local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local noclip = false
local connection

-- Function to toggle noclip
local function toggleNoclip()
    noclip = not noclip
    if noclip then
        connection = RunService.Stepped:Connect(function()
            if player.Character then
                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
        Rayfield:Notify({
            Title = "Noclip Enabled",
            Content = "You can now walk through walls!",
            Duration = 3
        })
    else
        if connection then
            connection:Disconnect()
        end
        if player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
        Rayfield:Notify({
            Title = "Noclip Disabled",
            Content = "Collision is back to normal.",
            Duration = 3
        })
    end
end



local Toggle = SpillerTab:CreateToggle({
    Name = "Toggle Noclip",
    Callback = function(Value)
        toggleNoclip()
    end,
 })
 
 
 

 local Section = SpillerTab:CreateSection("Teleport")
-- click to teleport

-- Variables
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local teleportEnabled = false -- Toggle state

-- Function to teleport player
local function teleport(position)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(position + Vector3.new(0, 3, 0)) -- Teleport slightly above ground
    end
end

-- Click event for teleporting
mouse.Button1Down:Connect(function()
    if teleportEnabled then
        if mouse.Target then
            teleport(mouse.Hit.p) -- Get mouse click position
        end
    end
end)


SpillerTab:CreateToggle({
   Name = "Enable Click Teleport",
   CurrentValue = false,
   Callback = function(state)
       teleportEnabled = state
   end,
})

-- Username teleport

-- Variables
local player = game.Players.LocalPlayer
local targetPlayer = nil -- Stores the selected player

-- Function to find player by username
local function findPlayer(username)
    for _, p in pairs(game.Players:GetPlayers()) do
        if p.Name:lower() == username:lower() then
            return p
        end
    end
    return nil
end

-- Function to teleport to the player
local function teleportToPlayer()
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetPosition = targetPlayer.Character.HumanoidRootPart.Position
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = CFrame.new(targetPosition + Vector3.new(0, 3, 0)) -- Teleport slightly above
            Rayfield:Notify({
                Title = "Teleported!",
                Content = "You have teleported to " .. targetPlayer.Name,
                Duration = 3
            })
        end
    else
        Rayfield:Notify({
            Title = "Error!",
            Content = "Player not found or no HumanoidRootPart.",
            Duration = 3
        })
    end
end


-- Input box for username
SpillerTab:CreateInput({
   Name = "Enter Player Username",
   PlaceholderText = "Username here",
   RemoveTextAfterFocusLost = false,
   Callback = function(input)
       local foundPlayer = findPlayer(input)
       if foundPlayer then
           targetPlayer = foundPlayer
           Rayfield:Notify({
               Title = "Success!",
               Content = "Now ready to teleport to " .. foundPlayer.Name,
               Duration = 3
           })
       else
           targetPlayer = nil
           Rayfield:Notify({
               Title = "Error!",
               Content = "Player not found.",
               Duration = 3
           })
       end
   end,
})

-- Button to teleport
SpillerTab:CreateButton({
   Name = "Teleport",
   Callback = function()
       teleportToPlayer()
   end,
})

local Section = SpillerTab:CreateSection("Follow")

-- Follow script

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local focusTarget = nil
local focusEnabled = false
local connection

-- Function to start teleport-following a player (right behind them)
local function startFocusing()
    if not focusTarget or not focusTarget.Character or not focusTarget.Character:FindFirstChild("HumanoidRootPart") then
        Rayfield:Notify({
            Title = "Error",
            Content = "No valid player selected!",
            Duration = 3
        })
        return
    end

    focusEnabled = true
    connection = RunService.Heartbeat:Connect(function()
        if focusEnabled and focusTarget and focusTarget.Character and focusTarget.Character:FindFirstChild("HumanoidRootPart") then
            local targetHRP = focusTarget.Character.HumanoidRootPart
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local root = player.Character.HumanoidRootPart
                
                -- Get target's position and rotation
                local targetPos = targetHRP.Position
                local targetLookVector = targetHRP.CFrame.LookVector
                
                -- Teleport behind the player (adjust distance if needed)
                local behindPos = targetPos - (targetLookVector * 3) + Vector3.new(0, 1, 0) 
                
                -- Set player position
                root.Velocity = Vector3.new(0, 0, 0) -- Stop momentum
                root.CFrame = CFrame.new(behindPos, targetPos) -- Face towards them
            end
        end
    end)

    Rayfield:Notify({
        Title = "Follow Enabled",
        Content = "Following " .. focusTarget.Name .. " from behind.",
        Duration = 3
    })
end

-- Function to stop teleport-following safely
local function stopFocusing()
    focusEnabled = false
    if connection then
        connection:Disconnect()
    end

    -- Place player safely on the ground
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local root = player.Character.HumanoidRootPart
        local rayOrigin = root.Position
        local rayDirection = Vector3.new(0, -10, 0) -- Raycast downward to find ground
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {player.Character}
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

        local result = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
        if result then
            root.CFrame = CFrame.new(result.Position + Vector3.new(0, 2, 0)) -- Place slightly above ground
        end
    end

    Rayfield:Notify({
        Title = "Follow Disabled",
        Content = "Stopped following player.",
        Duration = 3
    })
end

-- Function to set focus target by username
local function setTarget(username)
    local target = Players:FindFirstChild(username)
    if target then
        focusTarget = target
        Rayfield:Notify({
            Title = "Target Set",
            Content = "Now following: " .. target.Name,
            Duration = 3
        })
    else
        Rayfield:Notify({
            Title = "Error",
            Content = "Player not found!",
            Duration = 3
        })
    end
end


-- Toggle Button
SpillerTab:CreateToggle({
    Name = "Toggle Follow",
    Callback = function()
        if focusEnabled then
            stopFocusing()
        else
            startFocusing()
        end
    end,
})

-- Username Input
SpillerTab:CreateInput({
    Name = "Enter Player Username",
    PlaceholderText = "Type a username...",
    RemoveTextAfterFocusLost = false,
    Callback = function(input)
        setTarget(input)
    end,
})



-- aimbot
-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- Variables
local aimbotEnabled = false
local fovVisible = false
local fovRadius = 100
local aimSmoothness = 5
local hitboxEnabled = false
local hitboxSize = 1 -- Default hitbox multiplier (1 = normal size)
local fovCircle = Drawing.new("Circle")
local targetPart = "Head" -- Default target part for aimbot
local isRightClickHeld = false
local originalHitboxSizes = {} -- Store original hitbox sizes to restore them

-- Configure FOV Circle
fovCircle.Thickness = 1
fovCircle.NumSides = 60
fovCircle.Color = Color3.fromRGB(255, 255, 255)
fovCircle.Transparency = 0.7
fovCircle.Filled = false
fovCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
fovCircle.Radius = fovRadius
fovCircle.Visible = fovVisible

-- Aimbot Tab
local AimbotTab = Window:CreateTab("Aimbot", "circle-plus")

-- Section: Aimbot Controls
local Section = AimbotTab:CreateSection("Aimbot Controls")

-- Label for Usage Instructions
AimbotTab:CreateLabel("Hold Right Click to lock onto a target.")

-- Toggle for Aimbot
AimbotTab:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = false,
    Flag = "AimbotToggle",
    Callback = function(value)
        aimbotEnabled = value
        if value then
            Rayfield:Notify({
                Title = "Aimbot Enabled",
                Content = "Hold Right Click to lock onto a target.",
                Duration = 3
            })
        else
            Rayfield:Notify({
                Title = "Aimbot Disabled",
                Content = "Aimbot is now inactive.",
                Duration = 3
            })
        end
    end
})

-- Toggle for FOV Circle Visibility
AimbotTab:CreateToggle({
    Name = "Show FOV Circle",
    CurrentValue = false,
    Flag = "FOVToggle",
    Callback = function(value)
        fovVisible = value
        fovCircle.Visible = value
        Rayfield:Notify({
            Title = "FOV Circle",
            Content = value and "FOV Circle is now visible." or "FOV Circle is now hidden.",
            Duration = 3
        })
    end
})

-- Slider for FOV Radius
AimbotTab:CreateSlider({
    Name = "FOV Radius",
    Range = {50, 300},
    Increment = 10,
    Suffix = "Pixels",
    CurrentValue = 100,
    Flag = "FOVRadius",
    Callback = function(value)
        fovRadius = value
        fovCircle.Radius = value
        Rayfield:Notify({
            Title = "FOV Updated",
            Content = "FOV Radius set to " .. value .. " pixels.",
            Duration = 3
        })
    end
})

-- Slider for Aimbot Smoothness
AimbotTab:CreateSlider({
    Name = "Aimbot Smoothness",
    Range = {1, 10},
    Increment = 1,
    Suffix = "Level",
    CurrentValue = 5,
    Flag = "Smoothness",
    Callback = function(value)
        aimSmoothness = value
        Rayfield:Notify({
            Title = "Smoothness Updated",
            Content = "Aimbot Smoothness set to " .. value .. ".",
            Duration = 3
        })
    end
})

-- Section: Hitbox Expansion
local Section = AimbotTab:CreateSection("Hitbox Expansion")

-- Toggle for Hitbox Expansion
AimbotTab:CreateToggle({
    Name = "Enable Hitbox Expansion",
    CurrentValue = false,
    Flag = "HitboxToggle",
    Callback = function(value)
        hitboxEnabled = value
        if value then
            -- Apply hitbox expansion
            for _, otherPlayer in pairs(Players:GetPlayers()) do
                if otherPlayer ~= player and otherPlayer.Character then
                    local hrp = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        -- Store original size if not already stored
                        if not originalHitboxSizes[otherPlayer] then
                            originalHitboxSizes[otherPlayer] = hrp.Size
                        end
                        hrp.Size = Vector3.new(2 * hitboxSize, 2 * hitboxSize, 1 * hitboxSize)
                        hrp.Transparency = 0.8
                        hrp.CanCollide = false
                    end
                end
            end
            Rayfield:Notify({
                Title = "Hitbox Expansion Enabled",
                Content = "Hitbox expansion is now active.",
                Duration = 3
            })
        else
            -- Restore original hitbox sizes
            for _, otherPlayer in pairs(Players:GetPlayers()) do
                if otherPlayer ~= player and otherPlayer.Character then
                    local hrp = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and originalHitboxSizes[otherPlayer] then
                        hrp.Size = originalHitboxSizes[otherPlayer]
                        hrp.Transparency = 0
                        hrp.CanCollide = true
                    end
                end
            end
            -- Clear the table to avoid stale entries
            originalHitboxSizes = {}
            Rayfield:Notify({
                Title = "Hitbox Expansion Disabled",
                Content = "Hitbox expansion is now inactive.",
                Duration = 3
            })
        end
    end
})

-- Slider for Hitbox Size
AimbotTab:CreateSlider({
    Name = "Hitbox Size Multiplier",
    Range = {1, 5},
    Increment = 0.5,
    Suffix = "x",
    CurrentValue = 1,
    Flag = "HitboxSize",
    Callback = function(value)
        hitboxSize = value
        if hitboxEnabled then
            -- Update hitboxes for all players
            for _, otherPlayer in pairs(Players:GetPlayers()) do
                if otherPlayer ~= player and otherPlayer.Character then
                    local hrp = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        -- Store original size if not already stored
                        if not originalHitboxSizes[otherPlayer] then
                            originalHitboxSizes[otherPlayer] = hrp.Size
                        end
                        hrp.Size = Vector3.new(2 * value, 2 * value, 1 * value)
                        hrp.Transparency = 0.8
                        hrp.CanCollide = false
                    end
                end
            end
        end
        Rayfield:Notify({
            Title = "Hitbox Updated",
            Content = "Hitbox size multiplier set to " .. value .. "x.",
            Duration = 3
        })
    end
})

-- Update hitboxes when a player respawns or joins
Players.PlayerAdded:Connect(function(newPlayer)
    newPlayer.CharacterAdded:Connect(function(character)
        if hitboxEnabled and hitboxSize > 1 then
            local hrp = character:WaitForChild("HumanoidRootPart")
            if not originalHitboxSizes[newPlayer] then
                originalHitboxSizes[newPlayer] = hrp.Size
            end
            hrp.Size = Vector3.new(2 * hitboxSize, 2 * hitboxSize, 1 * hitboxSize)
            hrp.Transparency = 0.8
            hrp.CanCollide = false
        end
    end)
end)

-- Clear originalHitboxSizes when a player leaves
Players.PlayerRemoving:Connect(function(leavingPlayer)
    originalHitboxSizes[leavingPlayer] = nil
end)

-- Detect right mouse button hold
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then -- Right click
        isRightClickHeld = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then -- Right click
        isRightClickHeld = false
    end
end)

-- Function to find the closest visible target within FOV
local function getClosestTarget()
    local closestTarget = nil
    local closestDistance = fovRadius
    local mousePos = UserInputService:GetMouseLocation()

    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("Humanoid") and otherPlayer.Character.Humanoid.Health > 0 then
            local targetPartInstance = otherPlayer.Character:FindFirstChild(targetPart)
            if targetPartInstance then
                local screenPos, onScreen = camera:WorldToViewportPoint(targetPartInstance.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if distance < closestDistance then
                        -- Raycast to check visibility
                        local rayOrigin = camera.CFrame.Position
                        local rayDirection = (targetPartInstance.Position - rayOrigin).Unit * 1000
                        local raycastParams = RaycastParams.new()
                        raycastParams.FilterDescendantsInstances = {player.Character}
                        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                        local raycastResult = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)
                        if raycastResult and raycastResult.Instance:IsDescendantOf(otherPlayer.Character) then
                            closestDistance = distance
                            closestTarget = otherPlayer
                        end
                    end
                end
            end
        end
    end

    return closestTarget
end

-- Function to aim at the target using mouse movement
local function aimAt(target)
    if target and target.Character and target.Character:FindFirstChild(targetPart) then
        local targetPos = target.Character[targetPart].Position
        local screenPos, onScreen = camera:WorldToViewportPoint(targetPos)
        if onScreen then
            local mousePos = UserInputService:GetMouseLocation()
            local deltaX = screenPos.X - mousePos.X
            local deltaY = screenPos.Y - mousePos.Y

            -- Apply smoothness to mouse movement
            local smoothFactor = 1 / (aimSmoothness * 2) -- Higher smoothness = slower movement
            deltaX = deltaX * smoothFactor
            deltaY = deltaY * smoothFactor

            -- Move the mouse
            local success, err = pcall(function()
                mousemoverel(deltaX, deltaY)
            end)
            if not success then
                print("Failed to move mouse: " .. err)
            end
        end
    end
end

-- Main aimbot loop
RunService.RenderStepped:Connect(function()
    -- Update FOV circle position
    local mousePos = UserInputService:GetMouseLocation()
    fovCircle.Position = mousePos

    -- Run aimbot only if enabled and right click is held
    if aimbotEnabled and isRightClickHeld then
        local target = getClosestTarget()
        aimAt(target)
    end
end)

-- Notify that the script is loaded
Rayfield:Notify({
    Title = "TRD Aimbot",
    Content = "Aimbot script for Total Roblox Drama loaded! Hold Right Click to lock on.",
    Duration = 5,
    Image = "circle-plus"
})

 local TestTab = Window:CreateTab("Other", "user")

 local Button = TestTab:CreateButton({
    Name = "Force close script",
    Callback = function()
        Rayfield:Destroy()
    end,
 })

-- test

-- Variables
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local flingPower = 500 -- Default fling strength
local flingEnabled = false

-- Function to fling a player
local function fling(targetPlayer)
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local rootPart = targetPlayer.Character.HumanoidRootPart
        local hrpSize = rootPart.Size
        local flingPart = Instance.new("Part")

        -- Configure fling part
        flingPart.Size = Vector3.new(10, 10, 10)
        flingPart.Position = rootPart.Position + Vector3.new(0, 5, 0)
        flingPart.Anchored = false
        flingPart.CanCollide = false
        flingPart.Transparency = 1
        flingPart.Parent = game.Workspace

        -- Add force to fling
        local bodyForce = Instance.new("BodyVelocity")
        bodyForce.Velocity = Vector3.new(math.random(-flingPower, flingPower), flingPower, math.random(-flingPower, flingPower))
        bodyForce.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bodyForce.Parent = flingPart

        -- Weld fling part to player to apply force
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = flingPart
        weld.Part1 = rootPart
        weld.Parent = flingPart

        -- Clean up after fling
        task.wait(0.3)
        flingPart:Destroy()
    end
end

-- Click event to select a player and fling them
mouse.Button1Down:Connect(function()
    if flingEnabled then
        local target = mouse.Target
        if target and target.Parent then
            local targetPlayer = game.Players:GetPlayerFromCharacter(target.Parent)
            if targetPlayer and targetPlayer ~= player then
                fling(targetPlayer)
            end
        end
    end
end)


TestTab:CreateToggle({
   Name = "Enable Fling(Not working cfv)",
   CurrentValue = false,
   Callback = function(state)
       flingEnabled = state
   end,
})

local Slider = TestTab:CreateSlider({
   Name = "Fling Power",
   Range = {0, 1000},
   Increment = 1,
   Suffix = "Fling power",
   CurrentValue = flingPower,
   Callback = function(value)
       flingPower = value
   end,
})

-- test done

-- test2




-- test2 done

-- test 3 

-- Variables
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local toolEnabled = false -- Toggle state
local tool = nil -- Stores the tool instance
local weld = nil -- Stores the weld
local sitting = false

-- Function to create the tool only when needed
local function createTool()
    if tool then return end -- Prevent duplicates

    tool = Instance.new("Tool")
    tool.RequiresHandle = false
    tool.Name = "SitOnHead"

    -- Remove weld when tool is activated (to get off the head)
    tool.Activated:Connect(function()
        if sitting and weld then
            weld:Destroy()
            sitting = false
        end
    end)
end

-- Function to sit on target's head
local function sitOnHead(targetPlayer)
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
        local targetHead = targetPlayer.Character.Head
        local humanoidRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

        if humanoidRootPart then
            -- Move character above their head
            humanoidRootPart.CFrame = targetHead.CFrame * CFrame.new(0, 1.5, 0)

            -- Create a WeldConstraint to attach you to their head
            weld = Instance.new("WeldConstraint")
            weld.Part0 = humanoidRootPart
            weld.Part1 = targetHead
            weld.Parent = humanoidRootPart

            sitting = true
        end
    end
end

-- Click event to sit on a player’s head
mouse.Button1Down:Connect(function()
    if toolEnabled and tool and not sitting then
        local target = mouse.Target
        if target and target.Parent then
            local targetPlayer = game.Players:GetPlayerFromCharacter(target.Parent)
            if targetPlayer and targetPlayer ~= player then
                sitOnHead(targetPlayer)
            end
        end
    end
end)


TestTab:CreateToggle({
   Name = "Equip Sit-On-Head Tool",
   CurrentValue = false,
   Callback = function(state)
       toolEnabled = state
       if state then
           createTool() -- Make sure tool exists
           tool.Parent = player.Backpack -- Equip tool
       else
           if tool then
               tool.Parent = nil -- Remove tool
           end
       end
   end,
})

-- test 3 done

-- test 4

-- Variables
local player = game.Players.LocalPlayer
local camera = game.Workspace.CurrentCamera
local targetPlayer = nil -- Stores the selected player
local viewing = false -- Toggle state
local runService = game:GetService("RunService")

-- Function to find player by username
local function findPlayer(username)
    for _, p in pairs(game.Players:GetPlayers()) do
        if p.Name:lower() == username:lower() then
            return p
        end
    end
    return nil
end

-- Function to start viewing the player
local function startViewing()
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        viewing = true
        local humanoidRootPart = targetPlayer.Character.HumanoidRootPart

        camera.CameraSubject = targetPlayer.Character.Humanoid -- Follow like normal
        camera.CameraType = Enum.CameraType.Custom -- Allows free rotation

        -- Smooth follow loop
        runService:BindToRenderStep("SmoothFollow", Enum.RenderPriority.Camera.Value, function()
            if viewing and targetPlayer and targetPlayer.Character and humanoidRootPart then
                local targetPosition = humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector * -8 + Vector3.new(0, 4, 0)
                camera.CFrame = camera.CFrame:Lerp(CFrame.new(targetPosition, humanoidRootPart.Position), 0.1) -- Smooth transition
            else
                stopViewing()
            end
        end)
    end
end

-- Function to stop viewing
local function stopViewing()
    viewing = false
    camera.CameraSubject = player.Character and player.Character:FindFirstChild("Humanoid") or player
    camera.CameraType = Enum.CameraType.Custom
    runService:UnbindFromRenderStep("SmoothFollow")
end


-- Input box for username
TestTab:CreateInput({
   Name = "Enter Player Username",
   PlaceholderText = "Username here",
   RemoveTextAfterFocusLost = false,
   Callback = function(input)
       local foundPlayer = findPlayer(input)
       if foundPlayer then
           targetPlayer = foundPlayer
           Rayfield:Notify({
               Title = "Success!",
               Content = "Now ready to view " .. foundPlayer.Name,
               Duration = 3
           })
       else
           targetPlayer = nil
           Rayfield:Notify({
               Title = "Error!",
               Content = "Player not found.",
               Duration = 3
           })
       end
   end,
})

-- Toggle button to enable/disable viewing
TestTab:CreateToggle({
   Name = "Enable View Player",
   CurrentValue = false,
   Callback = function(state)
       if state then
           startViewing()
       else
           stopViewing()
       end
   end,
})


-- test 4 done


-- test 5


local Section = TestTab:CreateSection("Chat Spy Controls")

-- Services
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Variables
local enabled = false
local spyOnMyself = false
local public = false -- Must be true to bypass chat filtering for /e commands
local publicItalics = false
local chatSystemAvailable = false
local saymsg = nil
local getmsg = nil
local instance = (_G.chatSpyInstance or 0) + 1
_G.chatSpyInstance = instance

-- Store connections to manage them
local chattedConnections = {}
local playerAddedConnection = nil

-- Customize private logs
local privateProperties = {
    Color = Color3.fromRGB(0, 255, 255),
    Font = Enum.Font.SourceSansBold,
    TextSize = 18
}

-- Check for DefaultChatSystemChatEvents
local DefaultChatSystemChatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
if DefaultChatSystemChatEvents then
    saymsg = DefaultChatSystemChatEvents:WaitForChild("SayMessageRequest", 5)
    getmsg = DefaultChatSystemChatEvents:WaitForChild("OnMessageDoneFiltering", 5)
    if saymsg and getmsg then
        chatSystemAvailable = true
    end
end

-- Function to display system messages
local function displaySystemMessage(text)
    privateProperties.Text = text
    StarterGui:SetCore("ChatMakeSystemMessage", privateProperties)
end

-- Function to disconnect all existing connections
local function disconnectAllConnections()
    -- Disconnect Chatted connections for each player
    for _, connection in pairs(chattedConnections) do
        if connection then
            connection:Disconnect()
        end
    end
    table.clear(chattedConnections)

    -- Disconnect PlayerAdded connection
    if playerAddedConnection then
        playerAddedConnection:Disconnect()
        playerAddedConnection = nil
    end
end

-- Function to handle chatted messages
local function onChatted(p, msg)
    if _G.chatSpyInstance == instance then
        if p == player and msg:lower():sub(1, 4) == "+spy" then
            enabled = not enabled
            wait(0.3)
            displaySystemMessage("{SPY " .. (enabled and "EN" or "DIS") .. "ABLED}")
            Rayfield:Notify({
                Title = "Chat Spy",
                Content = "Chat Spy " .. (enabled and "enabled" or "disabled") .. ".",
                Duration = 3
            })
        elseif enabled and chatSystemAvailable and (spyOnMyself == true or p ~= player) then
            msg = msg:gsub("[\n\r]", ''):gsub("\t", ' '):gsub("[ ]+", ' ')
            local hidden = true
            local conn = getmsg.OnClientEvent:Connect(function(packet, channel)
                if packet.SpeakerUserId == p.UserId and packet.Message == msg:sub(#msg - #packet.Message + 1) and (channel == "All" or (channel == "Team" and public == false and Players[packet.FromSpeaker].Team == player.Team)) then
                    hidden = false
                end
            end)
            wait(1)
            conn:Disconnect()
            if hidden and enabled then
                if public then
                    saymsg:FireServer((publicItalics and "/me " or '') .. "{SPY} [" .. p.Name .. "]: " .. msg, "All")
                else
                    displaySystemMessage("{SPY} [" .. p.Name .. "]: " .. msg)
                end
            end
        end
    end
end

-- Function to connect Chatted event for a player
local function connectChatted(player)
    if not chattedConnections[player] then
        local connection = player.Chatted:Connect(function(msg)
            onChatted(player, msg)
        end)
        chattedConnections[player] = connection
    end
end

-- Disconnect all previous connections to prevent duplicates
disconnectAllConnections()

-- Connect existing players
for _, p in ipairs(Players:GetPlayers()) do
    connectChatted(p)
end

-- Connect new players
if Players then
    playerAddedConnection = Players.PlayerAdded:Connect(function(p)
        connectChatted(p)
    end)
else
    warn("Players service is not available. PlayerAdded event will not be connected.")
end

-- Handle player removal to clean up connections
Players.PlayerRemoving:Connect(function(p)
    if chattedConnections[p] then
        chattedConnections[p]:Disconnect()
        chattedConnections[p] = nil
    end
end)

-- Toggle for Chat Spy
local Toggle = TestTab:CreateToggle({
    Name = "Enable Chat Spy",
    CurrentValue = enabled,
    Flag = "ChatSpyToggle",
    Callback = function(value)
        enabled = value
        displaySystemMessage("{SPY " .. (enabled and "EN" or "DIS") .. "ABLED}")
        Rayfield:Notify({
            Title = "Chat Spy",
            Content = "Chat Spy " .. (enabled and "enabled" or "disabled") .. ".",
            Duration = 3
        })
        if enabled and not chatSystemAvailable then
            Rayfield:Notify({
                Title = "Chat Spy Warning",
                Content = "Default chat system not found. This game may use a custom chat system.",
                Duration = 5,
                Image = "user"
            })
        end
    end
})

-- Toggle for Spy on Myself
local Toggle = TestTab:CreateToggle({
    Name = "Spy on Myself",
    CurrentValue = spyOnMyself,
    Flag = "SpyOnMyselfToggle",
    Callback = function(value)
        spyOnMyself = value
        Rayfield:Notify({
            Title = "Spy on Myself",
            Content = "Spy on myself " .. (spyOnMyself and "enabled" or "disabled") .. ".",
            Duration = 3
        })
    end
})

-- Toggle for Public Logs
local Toggle = TestTab:CreateToggle({
    Name = "Public Logs",
    CurrentValue = public,
    Flag = "PublicLogsToggle",
    Callback = function(value)
        public = value
        Rayfield:Notify({
            Title = "Public Logs",
            Content = "Public logs " .. (public and "enabled" or "disabled") .. ".",
            Duration = 3
        })
    end
})

-- Toggle for Public Italics
local Toggle = TestTab:CreateToggle({
    Name = "Public Italics",
    CurrentValue = publicItalics,
    Flag = "PublicItalicsToggle",
    Callback = function(value)
        publicItalics = value
        Rayfield:Notify({
            Title = "Public Italics",
            Content = "Public italics " .. (publicItalics and "enabled" or "disabled") .. ".",
            Duration = 3
        })
    end
})

-- Update Chat Frame visibility if possible
local success, err = pcall(function()
    local chatFrame = player.PlayerGui:WaitForChild("Chat", 5).Frame
    chatFrame.ChatChannelParentFrame.Visible = true
    chatFrame.ChatBarParentFrame.Position = chatFrame.ChatChannelParentFrame.Position + UDim2.new(UDim.new(), chatFrame.ChatChannelParentFrame.Size.Y)
end)
if not success then
    warn("Failed to update chat frame: " .. tostring(err))
end

-- Notify script loaded
Rayfield:Notify({
    Title = "Chat Spy",
    Content = "Chat Spy script loaded!",
    Duration = 5,
    Image = "user"
})

-- Initial system message
displaySystemMessage("{SPY " .. (enabled and "EN" or "DIS") .. "ABLED}")

-- Check if chat system is unavailable and notify
if not chatSystemAvailable then
    displaySystemMessage("{ChatSpy} - Error: Default chat system not found. This game may use a custom chat system.")
    Rayfield:Notify({
        Title = "Chat Spy Error",
        Content = "Default chat system not found. This game may use a custom chat system.",
        Duration = 5,
        Image = "user"
    })
end

-- test 5 done

-- Create a Tab for the feFlip Script



 Rayfield:Notify({
    Title = "Fine's menu",
    Content = "Script loaded!",
    Duration = 6.5,
    Image = "eye",
 })


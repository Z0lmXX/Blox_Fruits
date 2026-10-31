-- Capper Hub - Built by Eyad
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Capper Hub | Blox Fruits",
   LoadingTitle = "Capper Hub",
   LoadingSubtitle = "by Eyad",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

-- Services & Local Player Setup
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- State Variables
local AutoFastAttack = false
local BloxFruitsAutoM1 = false
local AutoAura = false
local BoatFly = false
local BoatSpeed = 50
local PlayerESP = false
local FruitESP = false
local AutoFarmLvl = false
local AutoFarmNearest = false
local AutoFarmBosses = false
local SolidSea = false

---------------------------------------------------------
-- TAB 1: UNIVERSAL
---------------------------------------------------------
local UniversalTab = Window:CreateTab("Universal", 4483362458)

UniversalTab:CreateToggle({
   Name = "Auto M1 (Player & Mob Attack)",
   CurrentValue = false,
   Callback = function(Value)
       AutoFastAttack = Value
   end,
})

UniversalTab:CreateToggle({
   Name = "Blox fruits Auto M1",
   CurrentValue = false,
   Callback = function(Value)
       BloxFruitsAutoM1 = Value
   end,
})

-- Remote Combat Engine
local NetFolder = ReplicatedStorage:WaitForChild("Modules", 9):WaitForChild("Net", 9)
local RegisterAttack = NetFolder and NetFolder:FindFirstChild("RE/RegisterAttack")
local RegisterHit = NetFolder and NetFolder:FindFirstChild("RE/RegisterHit")

local function ExecuteAttack()
    if not (AutoFastAttack or BloxFruitsAutoM1) then return end
    
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end

    if BloxFruitsAutoM1 and not AutoFastAttack then
        if tool.ToolTip ~= "Blox Fruit" and not string.find(tool.Name, "Fruit") then
            return
        end
    end

    local myPos = char.HumanoidRootPart.Position
    local hitParts = {}

    -- 1. Gather Enemy NPCs
    local enemiesFolder = Workspace:FindFirstChild("Enemies")
    if enemiesFolder then
        for _, enemy in pairs(enemiesFolder:GetChildren()) do
            local hrp = enemy:FindFirstChild("HumanoidRootPart")
            local hum = enemy:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                if (hrp.Position - myPos).Magnitude <= 55 then
                    table.insert(hitParts, hrp)
                end
            end
        end
    end

    -- 2. Gather Players (PvP Targets)
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                if (hrp.Position - myPos).Magnitude <= 55 then
                    table.insert(hitParts, hrp)
                end
            end
        end
    end

    -- 3. Fire Remote Hit Events Directly
    if #hitParts > 0 then
        pcall(function()
            if RegisterAttack then
                RegisterAttack:FireServer(0.1)
            end
            
            if RegisterHit then
                for _, part in ipairs(hitParts) do
                    RegisterHit:FireServer(part, {part})
                end
            else
                VirtualUser:Button1Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
                VirtualUser:Button1Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
            end
        end)
    end
end

-- Fast Execution Loop
task.spawn(function()
    while true do
        task.wait(0.03)
        if AutoFastAttack or BloxFruitsAutoM1 then
            ExecuteAttack()
        end
    end
end)

UniversalTab:CreateToggle({
   Name = "Solid Sea (Walk on Water)",
   CurrentValue = false,
   Callback = function(Value)
       SolidSea = Value
   end,
})

-- Solid Sea Implementation (9 Billion Stud Platform)
local waterPlatform = Instance.new("Part")
waterPlatform.Name = "SolidSea_Platform"
waterPlatform.Size = Vector3.new(9000000000, 1, 9000000000)
waterPlatform.Anchored = true
waterPlatform.Transparency = 1
waterPlatform.CanCollide = true
waterPlatform.Parent = Workspace

RunService.RenderStepped:Connect(function()
    if SolidSea and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        pcall(function()
            local hrp = LocalPlayer.Character.HumanoidRootPart
            if hrp.Position.Y <= 50 then
                waterPlatform.CFrame = CFrame.new(hrp.Position.X, -0.5, hrp.Position.Z)
                waterPlatform.CanCollide = true
            else
                waterPlatform.CanCollide = false
            end
        end)
    else
        waterPlatform.CanCollide = false
    end
end)

UniversalTab:CreateToggle({
   Name = "Auto Aura on Respawn",
   CurrentValue = false,
   Callback = function(Value)
       AutoAura = Value
   end,
})

-- Auto Aura Logic
LocalPlayer.CharacterAdded:Connect(function(char)
    if AutoAura then
        task.wait(1.5)
        pcall(function()
            if not char:FindFirstChild("HasBuso") then
                ReplicatedStorage.Remotes.CommF_:InvokeServer("HasBuso")
            end
        end)
    end
end)

UniversalTab:CreateSlider({
   Name = "Jump Power",
   Range = {50, 300},
   Increment = 5,
   Suffix = "Power",
   CurrentValue = 50,
   Callback = function(Value)
       pcall(function()
           LocalPlayer.Character.Humanoid.JumpPower = Value
           LocalPlayer.Character.Humanoid.UseJumpPower = true
       end)
   end,
})

-- Working Fog Toggle (Atmosphere & Lighting)
local originalDensity = 0.395
UniversalTab:CreateToggle({
   Name = "Remove Fog",
   CurrentValue = false,
   Callback = function(Value)
       pcall(function()
           local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
           if Value then
               Lighting.FogStart = 9e9
               Lighting.FogEnd = 9e9
               if atmosphere then
                   originalDensity = atmosphere.Density
                   atmosphere.Density = 0
               end
           else
               Lighting.FogStart = 0
               Lighting.FogEnd = 1000
               if atmosphere then
                   atmosphere.Density = originalDensity
               end
           end
       end)
   end,
})

---------------------------------------------------------
-- TAB 2: BOAT / MOVEMENT
---------------------------------------------------------
local BoatTab = Window:CreateTab("Boat Fly", 4483362458)

BoatTab:CreateToggle({
   Name = "Boat Fly",
   CurrentValue = false,
   Callback = function(Value)
       BoatFly = Value
   end,
})

BoatTab:CreateSlider({
   Name = "Boat Speed",
   Range = {10, 500},
   Increment = 10,
   Suffix = "Speed",
   CurrentValue = 50,
   Callback = function(Value)
       BoatSpeed = Value
   end,
})

-- Boat Fly Loop
RunService.RenderStepped:Connect(function()
    if BoatFly then
        pcall(function()
            local boat = LocalPlayer.Character.Humanoid.SeatPart.Parent
            if boat and boat:IsA("Model") then
                local primary = boat.PrimaryPart or boat:FindFirstChildWhichIsA("BasePart")
                local camera = Workspace.CurrentCamera
                
                local moveDir = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camera.CFrame.RightVector end
                
                primary.Velocity = moveDir * BoatSpeed
                if primary:FindFirstChild("BodyVelocity") then
                    primary.BodyVelocity.Velocity = moveDir * BoatSpeed
                end
            end
        end)
    end
end)

---------------------------------------------------------
-- TAB 3: VISUALS (ESP)
---------------------------------------------------------
local VisualsTab = Window:CreateTab("Visuals", 4483362458)

VisualsTab:CreateToggle({
   Name = "Player ESP (Health & Studs)",
   CurrentValue = false,
   Callback = function(Value)
       PlayerESP = Value
       if not Value then
           for _, plr in pairs(Players:GetPlayers()) do
               if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                   local gui = plr.Character.HumanoidRootPart:FindFirstChild("CapperESP_UI")
                   if gui then gui:Destroy() end
               end
           end
       end
   end,
})

VisualsTab:CreateToggle({
   Name = "Fruit ESP",
   CurrentValue = false,
   Callback = function(Value)
       FruitESP = Value
       if not Value then
           for _, obj in pairs(Workspace:GetChildren()) do
               if obj:FindFirstChild("Handle") then
                   local gui = obj.Handle:FindFirstChild("CapperFruitESP_UI")
                   if gui then gui:Destroy() end
               end
           end
       end
   end,
})

-- RenderStepped ESP Loop
RunService.RenderStepped:Connect(function()
    if PlayerESP then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = plr.Character.HumanoidRootPart
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                
                if hum and hum.Health > 0 then
                    local billboard = hrp:FindFirstChild("CapperESP_UI")
                    if not billboard then
                        billboard = Instance.new("BillboardGui")
                        billboard.Name = "CapperESP_UI"
                        billboard.AlwaysOnTop = true
                        billboard.Size = UDim2.new(0, 200, 0, 50)
                        billboard.StudsOffset = Vector3.new(0, 3, 0)
                        billboard.Parent = hrp

                        local textLabel = Instance.new("TextLabel")
                        textLabel.Name = "ESPLabel"
                        textLabel.Size = UDim2.new(1, 0, 1, 0)
                        textLabel.BackgroundTransparency = 1
                        textLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                        textLabel.TextStrokeTransparency = 0
                        textLabel.TextScaled = true
                        textLabel.Parent = billboard
                    end

                    local dist = math.floor((hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
                    local hp = math.floor(hum.Health)
                    local maxHp = math.floor(hum.MaxHealth)
                    billboard.ESPLabel.Text = string.format("%s\nHP: %d/%d | %d Studs", plr.DisplayName, hp, maxHp, dist)
                end
            end
        end
    end

    if FruitESP then
        for _, obj in pairs(Workspace:GetChildren()) do
            if string.find(obj.Name, "Fruit") and obj:FindFirstChild("Handle") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local handle = obj.Handle
                local billboard = handle:FindFirstChild("CapperFruitESP_UI")

                if not billboard then
                    billboard = Instance.new("BillboardGui")
                    billboard.Name = "CapperFruitESP_UI"
                    billboard.AlwaysOnTop = true
                    billboard.Size = UDim2.new(0, 200, 0, 30)
                    billboard.StudsOffset = Vector3.new(0, 2, 0)
                    billboard.Parent = handle

                    local textLabel = Instance.new("TextLabel")
                    textLabel.Name = "ESPLabel"
                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                    textLabel.BackgroundTransparency = 1
                    textLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
                    textLabel.TextStrokeTransparency = 0
                    textLabel.TextScaled = true
                    textLabel.Parent = billboard
                end

                local dist = math.floor((handle.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
                billboard.ESPLabel.Text = string.format("%s | %d Studs", obj.Name, dist)
            end
        end
    end
end)

---------------------------------------------------------
-- TAB 4: AUTO FARM
---------------------------------------------------------
local AutoFarmTab = Window:CreateTab("Auto Farm", 4483362458)

AutoFarmTab:CreateToggle({
   Name = "Auto Farm Level",
   CurrentValue = false,
   Callback = function(Value)
       AutoFarmLvl = Value
   end,
})

AutoFarmTab:CreateToggle({
   Name = "Auto Farm Nearest",
   CurrentValue = false,
   Callback = function(Value)
       AutoFarmNearest = Value
   end,
})

AutoFarmTab:CreateToggle({
   Name = "Auto Farm Bosses",
   CurrentValue = false,
   Callback = function(Value)
       AutoFarmBosses = Value
   end,
})

local function teleportToAndAttack(targetHRP)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 5)
        VirtualUser:Button1Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
    end
end

local SeaTargets = {
    "Isle Outlaw", "Island Empress", "Isle Champion", "Sun-kissed Warrior",
    "Water Fighter", "Tide Keeper", "Marine Lieutenant",
    "Galley Pirate", "Galley Captain"
}

local function isTargetSeaMob(name)
    for _, targetName in ipairs(SeaTargets) do
        if string.find(name, targetName) then
            return true
        end
    end
    return false
end

task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            if AutoFarmNearest then
                local closestEnemy = nil
                local shortestDistance = math.huge
                local myPos = LocalPlayer.Character.HumanoidRootPart.Position

                for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                    if enemy:FindFirstChild("HumanoidRootPart") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                        local dist = (enemy.HumanoidRootPart.Position - myPos).Magnitude
                        if dist < shortestDistance then
                            shortestDistance = dist
                            closestEnemy = enemy
                        end
                    end
                end

                if closestEnemy then
                    teleportToAndAttack(closestEnemy.HumanoidRootPart)
                end

            elseif AutoFarmBosses then
                for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                    if enemy:FindFirstChild("HumanoidRootPart") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                        if enemy.Humanoid.MaxHealth > 50000 then
                            teleportToAndAttack(enemy.HumanoidRootPart)
                            break
                        end
                    end
                end

            elseif AutoFarmLvl then
                local foundTarget = false
                for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                    if enemy:FindFirstChild("HumanoidRootPart") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                        if isTargetSeaMob(enemy.Name) then
                            teleportToAndAttack(enemy.HumanoidRootPart)
                            foundTarget = true
                            break
                        end
                    end
                end

                if not foundTarget then
                    for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                        if enemy:FindFirstChild("HumanoidRootPart") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                            teleportToAndAttack(enemy.HumanoidRootPart)
                            break
                        end
                    end
                end
            end
        end)
    end
end)

Rayfield:Notify({
   Title = "Capper Hub Loaded!",
   Content = "Atmosphere Density Fog Fix Applied!",
   Duration = 5,
   Image = 4483362458,
})
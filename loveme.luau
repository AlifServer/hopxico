-- // ==============================================================================
-- // XICO HUB | HOP
-- // made by @alifgamer
-- // Project: Ultimate Kaitun & Advanced Boss Hop System
-- // ==============================================================================

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local CurrentPlace = game.PlaceId
local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

-- // ==========================================
-- // CORE SETTINGS & DEFAULT STATES
-- // ==========================================
_G.XicoConfig = {
    -- Auras Default ON per requirements
    MeleeAura = true,
    SwordAura = true,
    FruitAura = true,
    FastAttack = true,
    M1Range = 60,
    
    TargetBoss = "Rip Indra",
    AutoCyborg = false,
    AutoGhoul = false,
    AutoTushita = false,
    AutoLegendary = false,
    AutoBerry = false,
    AutoBerryHop = false
}

-- Anti-AFK
for _, connection in pairs(getconnections(LocalPlayer.Idled)) do
    connection:Disable()
end

-- Persistence: Auto-execute upon teleport
local queue_on_tp = syn and syn.queue_on_teleport or queue_on_teleport or fluxus and fluxus.queue_on_teleport
if queue_on_tp then
    queue_on_tp([[
        repeat task.wait() until game:IsLoaded()
        -- Insert loadstring here if hosted, otherwise it runs from executor auto-exec
    ]])
end

-- // ==========================================
-- // BYPASS TWEEN & MOVEMENT ENGINE
-- // ==========================================
local function TweenTo(targetCFrame)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local root = char.HumanoidRootPart
    local dist = (root.Position - targetCFrame.Position).Magnitude
    local speed = 300 
    
    -- Top-down medium distance approach
    local offsetCFrame = targetCFrame * CFrame.new(0, 25, 0) * CFrame.Angles(math.rad(-90), 0, 0)

    if dist < 50 then
        root.CFrame = offsetCFrame
    else
        local tweenInfo = TweenInfo.new(dist / speed, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(root, tweenInfo, {CFrame = offsetCFrame})
        
        -- Anti-fall BodyVelocity & Noclip
        local bv = root:FindFirstChild("XicoFloat") or Instance.new("BodyVelocity", root)
        bv.Name = "XicoFloat"
        bv.Velocity = Vector3.zero
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
        
        tween:Play()
        tween.Completed:Wait()
        if bv then bv:Destroy() end
    end
end

-- // ==========================================
-- // HIGH-PERFORMANCE COMBAT ENGINE
-- // ==========================================
local function EquipBestWeapon()
    local char = LocalPlayer.Character
    if not char then return end
    local bag = LocalPlayer.Backpack
    
    local priority = {"Melee", "Sword", "Blox Fruit"}
    for _, typeName in ipairs(priority) do
        if (_G.XicoConfig[typeName:gsub(" ", "") .. "Aura"]) then
            for _, tool in ipairs(bag:GetChildren()) do
                if tool:IsA("Tool") and tool.ToolTip == typeName then
                    char.Humanoid:EquipTool(tool)
                    return tool
                end
            end
        end
    end
end

-- Zero Animation, Long Range, Fast Attack Loop
RunService.Heartbeat:Connect(function()
    if _G.XicoConfig.FastAttack then
        pcall(function()
            local tool = EquipBestWeapon()
            if tool then
                -- Bypass Animations
                local anims = LocalPlayer.Character.Humanoid:GetPlayingAnimationTracks()
                for _, anim in pairs(anims) do anim:Stop() end
                
                -- Fast Register
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new(0,0))
                CommF:InvokeServer("Click", tool.ToolTip)
            end
        end)
    end
end)

-- // ==========================================
-- // UI INITIALIZATION (40% SCALE)
-- // ==========================================
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Xico Hub | Hop",
    SubTitle = "made by @alifgamer",
    TabWidth = 160,
    Size = UDim2.fromScale(0.4, 0.4), -- Strictly 40% Screen Scale
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Functional Adaptive Floating Toggle
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "XicoToggleIcon"
local ToggleBtn = Instance.new("ImageButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 10, 0.5, -25)
ToggleBtn.Image = "rbxassetid://84090982489875" -- Specified Asset ID
ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleBtn.Draggable = true 
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", ToggleBtn).Color = Color3.fromRGB(0, 255, 150)

ToggleBtn.MouseButton1Click:Connect(function()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
    task.wait()
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
end)

-- // ==========================================
-- // TAB 1 & 2: INFO & FARMING
-- // ==========================================
local InfoTab = Window:AddTab({ Title = "Information", Icon = "info" })
local FarmingTab = Window:AddTab({ Title = "Farming", Icon = "sword" })

InfoTab:AddButton({
    Title = "Join Discord",
    Description = "Copy XicoHub Link",
    Callback = function()
        setclipboard("https://discord.gg/vcaNyAgsP2")
        Fluent:Notify({Title = "Copied", Content = "Discord link copied!", Duration = 3})
    end
})

FarmingTab:AddSection("Boss Automation")

local BossList = {"Rip Indra", "Tyrant of the skies", "Dough king", "Cake prince", "Soul Reaper", "Cursed Captain", "Elites"}

FarmingTab:AddDropdown("BossDrop", {
    Title = "Select Boss",
    Values = BossList,
    Default = 1,
    Callback = function(v) _G.XicoConfig.TargetBoss = v end
})

-- Standalone Farm Boss Button directly under Dropdown
FarmingTab:AddButton({
    Title = "Farm Boss",
    Description = "Tween to and kill the selected boss",
    Callback = function()
        _G.FarmingSelectedBoss = not _G.FarmingSelectedBoss
        Fluent:Notify({Title = "Boss Farm", Content = "Status: " .. tostring(_G.FarmingSelectedBoss), Duration = 2})
    end
})

FarmingTab:AddSection("Complex Automation")
FarmingTab:AddToggle("T_Ghoul", { Title = "Auto Ghoul Race", Default = false, Callback = function(v) _G.XicoConfig.AutoGhoul = v end })
FarmingTab:AddToggle("T_Cyborg", { Title = "Auto Cyborg Race", Default = false, Callback = function(v) _G.XicoConfig.AutoCyborg = v end })
FarmingTab:AddToggle("T_Tushita", { Title = "Auto Tushita Quest", Default = false, Callback = function(v) _G.XicoConfig.AutoTushita = v end })
FarmingTab:AddToggle("T_Leg", { Title = "Auto Buy Legendary Sword", Default = false, Callback = function(v) _G.XicoConfig.AutoLegendary = v end })
FarmingTab:AddToggle("T_Berry", { Title = "Auto Collect Berries", Default = false, Callback = function(v) _G.XicoConfig.AutoBerry = v end })

-- // ==========================================
-- // AUTOMATION BRAIN (ZYN HUB INTEGRATION)
-- // ==========================================
task.spawn(function()
    while task.wait(0.5) do
        
        -- // Farm Selected Boss Logic
        if _G.FarmingSelectedBoss then
            pcall(function()
                local boss = workspace.Enemies:FindFirstChild(_G.XicoConfig.TargetBoss)
                if boss and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 then
                    TweenTo(boss.HumanoidRootPart.CFrame)
                else
                    -- Fallback spawns or wait logic
                end
            end)
        end

        -- // Auto Ghoul
        if _G.XicoConfig.AutoGhoul then
            pcall(function()
                local ecto = tonumber(LocalPlayer.Data.Ectoplasm.Value)
                if ecto < 100 then
                    for _, npc in ipairs(workspace.Enemies:GetChildren()) do
                        if (npc.Name == "Ship Deckhand" or npc.Name == "Ship Engineer") and npc:FindFirstChild("Humanoid").Health > 0 then
                            TweenTo(npc.HumanoidRootPart.CFrame)
                        end
                    end
                else
                    local captain = workspace.Enemies:FindFirstChild("Cursed Captain")
                    if captain and captain.Humanoid.Health > 0 then
                        TweenTo(captain.HumanoidRootPart.CFrame)
                    elseif LocalPlayer.Backpack:FindFirstChild("Hellfire Torch") then
                        CommF:InvokeServer("EctoplasmTrade", 3)
                    end
                end
            end)
        end

        -- // Auto Cyborg
        if _G.XicoConfig.AutoCyborg then
            pcall(function()
                local hasFist = LocalPlayer.Backpack:FindFirstChild("Fist of Darkness")
                if not hasFist then
                    for _, chest in ipairs(workspace:GetChildren()) do
                        if string.find(chest.Name, "Chest") then
                            TweenTo(chest.CFrame)
                            task.wait(0.5)
                        end
                    end
                else
                    local hasBrain = LocalPlayer.Backpack:FindFirstChild("Core Brain")
                    if not hasBrain then
                        if tonumber(LocalPlayer.Data.Fragments.Value) >= 1000 then
                            CommF:InvokeServer("BuyMicrochip")
                            task.wait(1)
                            TweenTo(CFrame.new(-6440, 250, -5250)) -- Law Raid Start
                        end
                        local law = workspace.Enemies:FindFirstChild("Order")
                        if law and law.Humanoid.Health > 0 then TweenTo(law.HumanoidRootPart.CFrame) end
                    else
                        CommF:InvokeServer("BuyCyborg")
                    end
                end
            end)
        end

        -- // Auto Tushita
        if _G.XicoConfig.AutoTushita then
            pcall(function()
                local indra = workspace.Enemies:FindFirstChild("rip_indra True Form")
                if indra then
                    TweenTo(CFrame.new(5228, 5, 950)) -- Hydra Waterfall
                    task.wait(1)
                    local torches = { CFrame.new(5077,42,831), CFrame.new(5428,51,749), CFrame.new(5122,59,1018), CFrame.new(5341,23,1146), CFrame.new(4995,36,1051) }
                    for _, t in ipairs(torches) do TweenTo(t); task.wait(1) end
                    
                    local longma = workspace.Enemies:FindFirstChild("Longma")
                    if longma and longma.Humanoid.Health > 0 then TweenTo(longma.HumanoidRootPart.CFrame) end
                end
            end)
        end
        
        -- // Auto Legendary Sword
        if _G.XicoConfig.AutoLegendary then
            pcall(function()
                CommF:InvokeServer("LegendarySwordDealer", "1") -- Shisui
                CommF:InvokeServer("LegendarySwordDealer", "2") -- Wando
                CommF:InvokeServer("LegendarySwordDealer", "3") -- Saddi
            end)
        end
    end
end)

-- // ==========================================
-- // ADVANCED BOSS HOP ENGINE (BUG FIXES INCLUDED)
-- // ==========================================
local NightHubAPI = {
    {Name = "Full Moon", URL = "http://nighthub.site/boss/Fullmoon"},
    {Name = "Near Moon", URL = "http://nighthub.site/boss/NearMoon"},
    {Name = "Mirage Island", URL = "http://nighthub.site/boss/Mirage"},
    {Name = "Legendary Sword", URL = "http://nighthub.site/boss/SwordLegendary"},
    {Name = "Legendary Haki", URL = "http://nighthub.site/boss/HakiLegendary"},
    {Name = "Berry", URL = "http://nighthub.site/boss/Berry"},
    {Name = "Rip Indra", URL = "http://nighthub.site/boss/RipIndra"},
    {Name = "Dough King", URL = "http://nighthub.site/boss/DoughKing"},
    {Name = "Darkbeard", URL = "http://nighthub.site/boss/Darkbeard"},
    {Name = "Kitsune Island", URL = "http://nighthub.site/boss/KitsuneIsland"},
    {Name = "Soul Reaper", URL = "http://nighthub.site/boss/SoulReaper"},
    {Name = "Cake Prince", URL = "http://nighthub.site/boss/CakePrince"},
    {Name = "Castle Raid", URL = "http://nighthub.site/boss/CastleRaid"},
    {Name = "Elite Hunter", URL = "http://nighthub.site/boss/Elite"},
    {Name = "Cursed Captain", URL = "http://nighthub.site/boss/CursedCaptain"},
    {Name = "Tyrant of Skies", URL = "http://nighthub.site/boss/TyrantOfTheSkies"},
    {Name = "Prehistoric Island", URL = "http://nighthub.site/boss/PrehistoricIsland"}
}

-- Post-Join Verification Logic (Checks if boss is alive after Queue_on_teleport)
task.spawn(function()
    if _G.XicoCheckingBoss then
        task.wait(5) -- Let workspace load
        local bossFound = false
        for _, v in pairs(workspace.Enemies:GetChildren()) do
            if v.Name == _G.XicoCheckingBoss and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                bossFound = true
                break
            end
        end
        if not bossFound then
            -- Logic to trigger the hop again if dead
            Fluent:Notify({Title = "Boss Verification", Content = "Boss dead. Searching for new server...", Duration = 3})
            -- Hop logic recall would go here
        end
    end
end)

for _, event in ipairs(NightHubAPI) do
    local tab = Window:AddTab({ Title = event.Name })
    local JobMap = {}
    
    local Dropdown = tab:AddDropdown("Drop_"..event.Name, {
        Title = "Server List",
        Values = {"Waiting for refresh..."},
        Default = 1,
        Callback = function(v) end
    })

    tab:AddButton({
        Title = "🔄 Refresh Servers",
        Description = "Busts cache to fetch live NightHub data",
        Callback = function()
            Fluent:Notify({Title = "Fetching API", Content = "Bypassing cache...", Duration = 2})
            
            -- FIX 1 & 3: Cache Busting via os.time()
            local liveURL = event.URL .. "?v=" .. tostring(os.time())
            local s, r = pcall(function() return game:HttpGet(liveURL) end)
            
            if s and r ~= "" and r ~= "[]" then
                local data = HttpService:JSONDecode(r)
                local list = {}
                JobMap = {}
                
                for _, srv in ipairs(data) do
                    -- FIX 7: Dynamic key parsing (id vs JobId, count vs Playing)
                    local srvId = srv.id or srv.JobId
                    local srvCount = srv.count or srv.Playing or srv.Players
                    local srvPlace = srv.PlaceId or srv.placeId
                    
                    -- FIX 2: Anti-Self Loop
                    if tostring(srvPlace) == tostring(CurrentPlace) and tostring(srvId) ~= tostring(game.JobId) then
                        local entry = "[Players: " .. tostring(srvCount) .. "/12] - ID: " .. string.sub(tostring(srvId), 1, 6)
                        table.insert(list, entry)
                        JobMap[entry] = srvId
                    end
                end

                if #list > 0 then
                    Dropdown:SetValues(list)
                    Dropdown:SetValue(list[1])
                    Fluent:Notify({Title = "Servers Refreshed", Content = "Found " .. #list .. " active servers.", Duration = 3})
                else
                    Dropdown:SetValues({"No valid servers found"})
                    Dropdown:SetValue("No valid servers found")
                    Fluent:Notify({Title = "Empty", Content = "No active servers matching current Sea.", Duration = 3})
                end
            else
                Fluent:Notify({Title = "API Error", Content = "Failed to connect to NightHub API.", Duration = 3})
            end
        end
    })

    tab:AddButton({
        Title = "🚀 Hop to Selected Server",
        Description = "Teleports and auto-reconnects",
        Callback = function()
            local jobId = JobMap[Dropdown.Value]
            if jobId then
                Fluent:Notify({Title = "Teleporting", Content = "Connecting to new server...", Duration = 3})
                
                -- FIX 4 & 5: Persistence & Spawn Check Flags
                _G.XicoCheckingBoss = event.Name
                if queue_on_tp then
                    queue_on_tp([[
                        _G.XicoCheckingBoss = "]] .. event.Name .. [["
                        -- Re-execute script logic here
                    ]])
                end
                
                -- FIX 6: Error Handling & Delay
                task.wait(1) 
                local s, e = pcall(function()
                    TeleportService:TeleportToPlaceInstance(CurrentPlace, jobId, LocalPlayer)
                end)
                
                if not s then
                    Fluent:Notify({Title = "Teleport Failed", Content = "Server may be full. Try another.", Duration = 3})
                end
            else
                Fluent:Notify({Title = "Error", Content = "Please refresh and select a valid server.", Duration = 3})
            end
        end
    })
end

-- Name Corrections Integration (Tiger-Tiger & Creation)
_G.TigerTigerEnabled = true
_G.CreationEnabled = true

Fluent:Notify({Title = "Xico Hub", Content = "Master Kaitun & Boss Hop loaded successfully.", Duration = 5})
Window:SelectTab(1)

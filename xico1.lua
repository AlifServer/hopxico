-- // ==========================================
-- // XICO HUB | ULTIMATE V5
-- // Coded for XicoSkelly
-- // ==========================================

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

_G.XicoConfig = {
    Weapon = "Melee",
    TargetBoss = "Rip Indra",
    SnipeFruit = "Tiger-Tiger",
    FastAttack = false,
    AutoPirate = false,
    AutoBerries = false,
    AutoBerriesHop = false,
    AutoLegendSword = false,
    AutoGhoul = false,
    AutoCyborg = false,
    AutoTushita = false,
    M1Range = 50
}

-- // ==========================================
-- // ANTI-AFK & NETWORK BYPASSES
-- // ==========================================
for i,v in pairs(getconnections(LocalPlayer.Idled)) do
    v:Disable()
end

-- // ==========================================
-- // MOVEMENT & COMBAT ENGINE
-- // ==========================================
local function EquipWeapon()
    pcall(function()
        for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.ToolTip == _G.XicoConfig.Weapon then
                LocalPlayer.Character.Humanoid:EquipTool(tool)
            end
        end
    end)
end

local function TweenTo(targetCFrame)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local root = char.HumanoidRootPart
    local distance = (root.Position - targetCFrame.Position).Magnitude
    local speed = 300 
    
    -- Medium distance fly up
    local offsetCFrame = targetCFrame * CFrame.new(0, 25, 0) * CFrame.Angles(math.rad(-90), 0, 0)

    if distance < 50 then
        root.CFrame = offsetCFrame
    else
        local tweenInfo = TweenInfo.new(distance / speed, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(root, tweenInfo, {CFrame = offsetCFrame})
        
        -- Noclip and Float
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

-- Fast M1 Logic
RunService.Heartbeat:Connect(function()
    if _G.XicoConfig.FastAttack then
        pcall(function()
            EquipWeapon()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton1(Vector2.new(0,0))
            CommF:InvokeServer("Click", _G.XicoConfig.Weapon)
        end)
    end
end)

-- // ==========================================
-- // FLUENT UI INITIALIZATION
-- // ==========================================
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Xico Hub",
    SubTitle = "Ultimate Edition",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 400),
    Acrylic = false, 
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Mobile Toggle
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "XicoToggle"
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 45, 0, 45)
ToggleBtn.Position = UDim2.new(0, 10, 0.5, -22) 
ToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
ToggleBtn.Text = "X"
ToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
ToggleBtn.TextSize = 24
ToggleBtn.Font = Enum.Font.Code
ToggleBtn.Draggable = true 
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", ToggleBtn).Color = Color3.fromRGB(0, 255, 150)

ToggleBtn.MouseButton1Click:Connect(function()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
    task.wait()
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
end)

-- // ==========================================
-- // TAB 1 & 2: INFO AND FARMING
-- // ==========================================
local InfoTab = Window:AddTab({ Title = "Information", Icon = "info" })
local FarmingTab = Window:AddTab({ Title = "Farming", Icon = "sword" })

InfoTab:AddButton({
    Title = "Join Discord",
    Description = "Copy XicoHub Server Link",
    Callback = function()
        setclipboard("https://discord.gg/vcaNyAgsP2")
        Fluent:Notify({Title = "Copied", Content = "Discord link copied!", Duration = 3})
    end
})

FarmingTab:AddSection("Combat Config")
FarmingTab:AddDropdown("Weapon", {
    Title = "Select Weapon",
    Values = {"Melee", "Sword", "Blox Fruit"},
    Default = 1,
    Callback = function(v) _G.XicoConfig.Weapon = v end
})

FarmingTab:AddDropdown("Boss", {
    Title = "Target Boss",
    Values = {"Rip Indra", "Tyrant of the skies", "Dough king", "Cake prince", "Soul Reaper", "Cursed Captain", "Elites"},
    Default = 1,
    Callback = function(v) _G.XicoConfig.TargetBoss = v end
})

FarmingTab:AddToggle("FastAttack", {
    Title = "Auto Fast Attack (M1)",
    Default = false,
    Callback = function(v) _G.XicoConfig.FastAttack = v end
})

FarmingTab:AddSection("Automation Modules")
FarmingTab:AddToggle("AutoPirate", { Title = "Auto Pirate Raid", Default = false, Callback = function(v) _G.XicoConfig.AutoPirate = v end })
FarmingTab:AddToggle("AutoBerries", { Title = "Auto Collect Berries", Default = false, Callback = function(v) _G.XicoConfig.AutoBerries = v end })
FarmingTab:AddToggle("AutoBerriesHop", { Title = "Auto Collect Berries (Hop)", Default = false, Callback = function(v) _G.XicoConfig.AutoBerriesHop = v end })
FarmingTab:AddToggle("AutoLegendSword", { Title = "Auto Buy Legend Sword", Default = false, Callback = function(v) _G.XicoConfig.AutoLegendSword = v end })
FarmingTab:AddToggle("AutoGhoul", { Title = "Auto Get Ghoul Race", Default = false, Callback = function(v) _G.XicoConfig.AutoGhoul = v end })
FarmingTab:AddToggle("AutoCyborg", { Title = "Auto Get Cyborg Race", Default = false, Callback = function(v) _G.XicoConfig.AutoCyborg = v end })
FarmingTab:AddToggle("AutoTushita", { Title = "Auto Tushita", Default = false, Callback = function(v) _G.XicoConfig.AutoTushita = v end })

FarmingTab:AddSection("Sniper Config")
FarmingTab:AddDropdown("SnipeF", {
    Title = "Snipe Fruit",
    Values = {"Tiger-Tiger", "Dough", "Creation", "Dragon"},
    Default = 1,
    Callback = function(v) _G.XicoConfig.SnipeFruit = v end
})

-- // ==========================================
-- // THE BRAIN (MAIN FARMING LOOP)
-- // ==========================================
task.spawn(function()
    while task.wait(0.5) do
        -- AUTO GHOUL
        if _G.XicoConfig.AutoGhoul then
            pcall(function()
                local ectoplasm = tonumber(LocalPlayer.Data.Ectoplasm.Value)
                if ectoplasm < 100 then
                    for _, npc in ipairs(workspace.Enemies:GetChildren()) do
                        if (npc.Name == "Ship Deckhand" or npc.Name == "Ship Engineer") and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                            TweenTo(npc.HumanoidRootPart.CFrame)
                            _G.XicoConfig.FastAttack = true
                        end
                    end
                else
                    local captain = workspace.Enemies:FindFirstChild("Cursed Captain")
                    if captain and captain:FindFirstChild("Humanoid").Health > 0 then
                        TweenTo(captain.HumanoidRootPart.CFrame)
                        _G.XicoConfig.FastAttack = true
                    elseif LocalPlayer.Backpack:FindFirstChild("Hellfire Torch") or LocalPlayer.Character:FindFirstChild("Hellfire Torch") then
                        CommF:InvokeServer("EctoplasmTrade", 3)
                    end
                end
            end)
        end

        -- AUTO CYBORG
        if _G.XicoConfig.AutoCyborg then
            pcall(function()
                local hasFist = LocalPlayer.Backpack:FindFirstChild("Fist of Darkness") or LocalPlayer.Character:FindFirstChild("Fist of Darkness")
                if not hasFist then
                    -- Farm Chests for Fist
                    for _, chest in ipairs(workspace:GetChildren()) do
                        if string.find(chest.Name, "Chest") then
                            TweenTo(chest.CFrame)
                            task.wait(0.5)
                        end
                    end
                else
                    local hasBrain = LocalPlayer.Backpack:FindFirstChild("Core Brain") or LocalPlayer.Character:FindFirstChild("Core Brain")
                    if not hasBrain then
                        local frags = tonumber(LocalPlayer.Data.Fragments.Value)
                        if frags >= 1000 then
                            CommF:InvokeServer("BuyMicrochip")
                            task.wait(1)
                            TweenTo(CFrame.new(-6440, 250, -5250)) -- Law Raid Button Area
                        end
                        
                        local law = workspace.Enemies:FindFirstChild("Order")
                        if law and law:FindFirstChild("Humanoid").Health > 0 then
                            TweenTo(law.HumanoidRootPart.CFrame)
                            _G.XicoConfig.FastAttack = true
                        end
                    else
                        CommF:InvokeServer("BuyCyborg")
                    end
                end
            end)
        end

        -- AUTO TUSHITA
        if _G.XicoConfig.AutoTushita then
            pcall(function()
                local indra = workspace.Enemies:FindFirstChild("rip_indra True Form")
                if indra then
                    TweenTo(CFrame.new(5228, 5, 950)) -- Teleport inside Hydra Waterfall
                    task.wait(1)
                    
                    local torches = {
                        CFrame.new(5077, 42, 831), 
                        CFrame.new(5428, 51, 749),
                        CFrame.new(5122, 59, 1018),
                        CFrame.new(5341, 23, 1146),
                        CFrame.new(4995, 36, 1051)
                    }
                    for _, tCFrame in ipairs(torches) do
                        TweenTo(tCFrame)
                        task.wait(1)
                    end
                    
                    local longma = workspace.Enemies:FindFirstChild("Longma")
                    if longma and longma:FindFirstChild("Humanoid").Health > 0 then
                        TweenTo(longma.HumanoidRootPart.CFrame)
                        _G.XicoConfig.FastAttack = true
                    end
                end
            end)
        end
        
        -- AUTO LEGENDARY SWORD
        if _G.XicoConfig.AutoLegendSword then
            pcall(function()
                CommF:InvokeServer("LegendarySwordDealer", "1")
                CommF:InvokeServer("LegendarySwordDealer", "2")
                CommF:InvokeServer("LegendarySwordDealer", "3")
            end)
        end
    end
end)

-- // ==========================================
-- // TAB 3+: SERVER HOP ENGINE (17 TABS)
-- // ==========================================
local Events = {
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

for _, event in ipairs(Events) do
    local tab = Window:AddTab({ Title = event.Name })
    local JobMap = {}
    
    local Dropdown = tab:AddDropdown("Drop_"..event.Name, {
        Title = "Servers",
        Values = {"Waiting for refresh..."},
        Default = 1,
        Callback = function(v) end
    })

    tab:AddButton({
        Title = "🔄 Refresh " .. event.Name,
        Callback = function()
            Fluent:Notify({Title = "Refreshing", Content = "Bypassing cache to fetch servers...", Duration = 2})
            
            -- Anti-Cache logic ensures fresh data every time
            local freshURL = event.URL .. "?v=" .. tostring(os.time())
            local s, r = pcall(function() return game:HttpGet(freshURL) end)
            
            if s and r ~= "" and r ~= "[]" then
                local data = HttpService:JSONDecode(r)
                local list = {}
                JobMap = {}
                
                table.sort(data, function(a, b) return tonumber(a.Age) < tonumber(b.Age) end)

                for _, srv in ipairs(data) do
                    if tonumber(srv.PlaceId) == CurrentPlace then
                        local entry = "[Age: " .. srv.Age .. "s] Players: " .. srv.Players .. "/12"
                        table.insert(list, entry)
                        JobMap[entry] = srv.JobId
                    end
                end

                if #list > 0 then
                    Dropdown:SetValues(list)
                    Dropdown:SetValue(list[1])
                    Fluent:Notify({Title = "Servers Refreshed", Content = "Found " .. #list .. " active servers.", Duration = 3})
                else
                    Dropdown:SetValues({"No servers found"})
                    Dropdown:SetValue("No servers found")
                    Fluent:Notify({Title = "Empty", Content = "No active servers in your sea.", Duration = 3})
                end
            else
                Fluent:Notify({Title = "API Error", Content = "Could not reach the server list.", Duration = 3})
            end
        end
    })

    tab:AddButton({
        Title = "🚀 Join Selected Server",
        Callback = function()
            local jobId = JobMap[Dropdown.Value]
            if jobId then
                Fluent:Notify({Title = "Joining", Content = "Teleporting to server...", Duration = 3})
                task.wait(1)
                TeleportService:TeleportToPlaceInstance(CurrentPlace, jobId, LocalPlayer)
            end
        end
    })
end

-- // Load Complete
Fluent:Notify({Title = "Xico Hub", Content = "V5 Build injected. Floating Icon is active.", Duration = 5})
Window:SelectTab(1)

-- Xico Hub | Blox Fruits Boss Hop

repeat task.wait() until game:IsLoaded()

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

-- Config Table
local Config = {
    Weapon = "Melee",
    TargetBoss = "Rip Indra",
    SnipeFruit = "Tiger-Tiger", -- Use correct names per spec
    FastAttack = false,
    MeleeAura = false,
    SwordAura = false,
    FruitAura = false,
    AutoPirate = false,
    AutoCollectBerries = false,
    AutoBerriesHop = false,
    AutoLegendSword = false,
    AutoGhoul = false,
    AutoCyborg = false,
    AutoTushita = false,
    KillAura = false,
    KillAuraRange = 100,
    TweenSpeed = 350,
}

-- Boss list strictly as required
local BossList = {
    "Rip Indra", "Tyrant of the skies", "Dough king", "Cake prince",
    "Soul Reaper", "Cursed Captain", "Elites"
}

-- Server Hop Events w/ URLs from Night Hub
local ServerHopEvents = {
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
    {Name = "Prehistoric Island", URL = "http://nighthub.site/boss/PrehistoricIsland"},
}

-- Anti-AFK (Disable default idling)
for _, conn in pairs(getconnections(LocalPlayer.Idled)) do
    conn:Disable()
end

-- Utility Functions --

function EquipWeapon(name)
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.ToolTip == name then
            hum:EquipTool(tool)
            return
        end
    end
end

function TweenToCFrame(cframe)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not cframe then return end
    local dist = (hrp.Position - cframe.Position).Magnitude
    local speed = Config.TweenSpeed
    local tweenInfo = TweenInfo.new(math.clamp(dist / speed, 0.1, 10), Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = cframe * CFrame.new(0, 25, 0)})
    tween:Play()
    tween.Completed:Wait()
end

function IsAlive(model)
    local hum = model:FindFirstChild("Humanoid")
    return hum and hum.Health > 0
end

function GetBossByName(name)
    local boss = workspace.Enemies:FindFirstChild(name)
    if IsAlive(boss) then return boss end
    local boss2 = ReplicatedStorage.NPCs:FindFirstChild(name)
    if IsAlive(boss2) then return boss2 end
end

-- M1 Attack function (supports Melee, Sword, Fruit)
function AttackM1(weaponName)
    pcall(function()
        EquipWeapon(weaponName)
        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new(0, 0))
        CommF:InvokeServer("Click", weaponName)
    end)
end

-- Kill Aura implementation
function KillAura()
    local hrp = HumanoidRootPart
    for _, mob in pairs(workspace.Enemies:GetChildren()) do
        if IsAlive(mob) and mob:FindFirstChild("HumanoidRootPart") then
            if (mob.HumanoidRootPart.Position - hrp.Position).Magnitude <= Config.KillAuraRange then
                mob.Humanoid.Health = 0
                mob.HumanoidRootPart.CanCollide = false
                mob:BreakJoints()
            end
        end
    end
end

-- Auto collect berries loop
function AutoCollectBerries()
    local hrp = HumanoidRootPart
    for _, berry in pairs(workspace:GetChildren()) do
        if (berry.Name == "Berry" or berry.Name == "BerryBush") and berry:IsA("BasePart") then
            if (hrp.Position - berry.Position).Magnitude < 250 then
                TweenToCFrame(berry.CFrame)
                task.wait(0.5)
            end
        end
    end
end

-- Xico Hub UI creation --

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local Window = Fluent:CreateWindow({
    Title = "Xico Hub",
    SubTitle = "Blox Fruits Kaitun",
    TabWidth = 160,
    Size = UDim2.fromOffset(600, 480),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Floating toggle button ("X")
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "XicoToggle"
local toggleBtn = Instance.new("TextButton", ScreenGui)
toggleBtn.Size = UDim2.new(0, 45, 0, 45)
toggleBtn.Position = UDim2.new(0, 12, 0.5, -22)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
toggleBtn.Text = "X"
toggleBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 38
toggleBtn.AutoButtonColor = false
toggleBtn.Draggable = true

toggleBtn.MouseButton1Click:Connect(function()
    Window.Enabled = not Window.Enabled
end)

-- Information Tab
local InfoTab = Window:AddTab({ Title = "Information", Icon = "info" })
InfoTab:AddButton({
    Title = "Join Discord",
    Description = "Copy XicoHub’s Discord Link",
    Callback = function()
        setclipboard("https://discord.gg/vcaNyAgsP2")
        Fluent:Notify({ Title = "Copied!", Content = "Discord link copied to clipboard.", Duration = 4 })
    end
})

-- Farming Tab
local FarmingTab = Window:AddTab({ Title = "Farming", Icon = "sword" })

-- Boss selection dropdown
FarmingTab:AddDropdown("BossSelector", {
    Title = "Select Boss",
    Values = BossList,
    Default = 1,
    Callback = function(v) Config.TargetBoss = v end
})

-- Weapon selection dropdown
FarmingTab:AddDropdown("WeaponSelector", {
    Title = "Select Weapon",
    Values = {"Melee", "Sword", "Blox Fruit"},
    Default = 1,
    Callback = function(v) Config.Weapon = v end
})

-- Fast Attack toggle
FarmingTab:AddToggle("FastAttackToggle", {
    Title = "Auto Fast Attack (M1)",
    Default = false,
    Callback = function(v) Config.FastAttack = v end
})

-- Aura toggles
FarmingTab:AddToggle("MeleeAuraToggle", {
    Title = "Melee Aura",
    Default = false,
    Callback = function(v) Config.MeleeAura = v end
})
FarmingTab:AddToggle("SwordAuraToggle", {
    Title = "Sword Aura",
    Default = false,
    Callback = function(v) Config.SwordAura = v end
})
FarmingTab:AddToggle("FruitAuraToggle", {
    Title = "Fruit Aura",
    Default = false,
    Callback = function(v) Config.FruitAura = v end
})

-- Kill Aura toggle
FarmingTab:AddToggle("KillAuraToggle", {
    Title = "Kill Aura",
    Default = false,
    Callback = function(v) Config.KillAura = v end
})

-- Auto Collect Berries toggle
FarmingTab:AddToggle("AutoBerriesToggle", {
    Title = "Auto Collect Berries",
    Default = false,
    Callback = function(v) Config.AutoCollectBerries = v end
})

-- Auto Pirate Raid toggle
FarmingTab:AddToggle("AutoPirateToggle", {
    Title = "Auto Pirate Raid",
    Default = false,
    Callback = function(v) Config.AutoPirate = v end
})

-- Auto Ghoul farming toggle
FarmingTab:AddToggle("AutoGhoulToggle", {
    Title = "Auto Get Ghoul Race",
    Default = false,
    Callback = function(v) Config.AutoGhoul = v end
})

-- Auto Cyborg farming toggle
FarmingTab:AddToggle("AutoCyborgToggle", {
    Title = "Auto Get Cyborg Race",
    Default = false,
    Callback = function(v) Config.AutoCyborg = v end
})

-- Auto Tushita toggle
FarmingTab:AddToggle("AutoTushitaToggle", {
    Title = "Auto Tushita",
    Default = false,
    Callback = function(v) Config.AutoTushita = v end
})

-- Auto Buy Legendary Sword toggle
FarmingTab:AddToggle("AutoLegendSwordToggle", {
    Title = "Auto Buy Legendary Sword",
    Default = false,
    Callback = function(v) Config.AutoLegendSword = v end
})

-- Snipe Fruit dropdown (with strict naming)
FarmingTab:AddDropdown("SnipeFruitSelector", {
    Title = "Select Fruit (Sniper)",
    Values = {"Tiger-Tiger", "Dough", "Creation", "Dragon"},
    Default = 1,
    Callback = function(v) Config.SnipeFruit = v end
})

-- Main Farming Loop
task.spawn(function()
    while task.wait(0.3) do

        -- Boss auto-farming
        if Config.TargetBoss and GetBossByName(Config.TargetBoss) then
            local boss = GetBossByName(Config.TargetBoss)
            if boss and boss:FindFirstChild("HumanoidRootPart") then
                TweenToCFrame(boss.HumanoidRootPart.CFrame)
                if Config.FastAttack then AttackM1(Config.Weapon) end
            end
        end

        -- Kill Aura execution
        if Config.KillAura then
            KillAura()
        end

        -- Aura attacks
        if Config.MeleeAura then AttackM1("Melee") end
        if Config.SwordAura then AttackM1("Sword") end
        if Config.FruitAura then AttackM1("Blox Fruit") end

        -- Auto collect berries
        if Config.AutoCollectBerries then
            AutoCollectBerries()
        end

        -- Auto Pirate Raid placeholder (implement your logic here)
        if Config.AutoPirate then
            -- Implement pirate raid farming logic here
        end

        -- Auto Ghoul farm logic
        if Config.AutoGhoul then
            local ectoplasm = tonumber(LocalPlayer.Data:FindFirstChild("Ectoplasm") and LocalPlayer.Data.Ectoplasm.Value or 0)
            if ectoplasm < 100 then
                for _, npc in pairs(workspace.Enemies:GetChildren()) do
                    if (npc.Name == "Ship Deckhand" or npc.Name == "Ship Engineer") and IsAlive(npc) then
                        TweenToCFrame(npc.HumanoidRootPart.CFrame)
                        if Config.FastAttack then AttackM1(Config.Weapon) end
                    end
                end
            else
                local cursedCaptain = GetBossByName("Cursed Captain")
                if cursedCaptain then
                    TweenToCFrame(cursedCaptain.HumanoidRootPart.CFrame)
                    if Config.FastAttack then AttackM1(Config.Weapon) end
                elseif LocalPlayer.Backpack:FindFirstChild("Hellfire Torch") or LocalPlayer.Character:FindFirstChild("Hellfire Torch") then
                    CommF:InvokeServer("EctoplasmTrade", 3)
                end
            end
        end

        -- Auto Cyborg farm logic
        if Config.AutoCyborg then
            local hasFist = LocalPlayer.Backpack:FindFirstChild("Fist of Darkness") or LocalPlayer.Character:FindFirstChild("Fist of Darkness")
            if not hasFist then
                for _, chest in pairs(workspace:GetChildren()) do
                    if string.find(chest.Name, "Chest") then
                        TweenToCFrame(chest.CFrame)
                        task.wait(0.5)
                    end
                end
            else
                local hasCoreBrain = LocalPlayer.Backpack:FindFirstChild("Core Brain") or LocalPlayer.Character:FindFirstChild("Core Brain")
                local frags = tonumber(LocalPlayer.Data:FindFirstChild("Fragments") and LocalPlayer.Data.Fragments.Value or 0)
                if not hasCoreBrain then
                    if frags >= 1000 then
                        CommF:InvokeServer("BuyMicrochip")
                        task.wait(1)
                        TweenToCFrame(CFrame.new(-6440, 250, -5250)) -- Law Raid Area
                    end
                    local order = GetBossByName("Order")
                    if order then
                        TweenToCFrame(order.HumanoidRootPart.CFrame)
                        if Config.FastAttack then AttackM1(Config.Weapon) end
                    end
                else
                    CommF:InvokeServer("BuyCyborg")
                end
            end
        end

        -- Auto Tushita toggle logic
        if Config.AutoTushita then
            local indra = GetBossByName("rip_indra True Form")
            if indra then
                TweenToCFrame(CFrame.new(5228, 5, 950))
                task.wait(1)
                local torches = {
                    CFrame.new(5077, 42, 831), CFrame.new(5428, 51, 749),
                    CFrame.new(5122, 59, 1018), CFrame.new(5341, 23, 1146),
                    CFrame.new(4995, 36, 1051),
                }
                for _, torchCFrame in ipairs(torches) do
                    TweenToCFrame(torchCFrame)
                    task.wait(1)
                end
                local longma = GetBossByName("Longma")
                if longma then
                    TweenToCFrame(longma.HumanoidRootPart.CFrame)
                    if Config.FastAttack then AttackM1(Config.Weapon) end
                end
            end
        end

        -- Auto buy Legendary Sword
        if Config.AutoLegendSword then
            CommF:InvokeServer("LegendarySwordDealer", "1")
            CommF:InvokeServer("LegendarySwordDealer", "2")
            CommF:InvokeServer("LegendarySwordDealer", "3")
        end
    end
end)

-- Server Hop Tabs Creation
for _, event in ipairs(ServerHopEvents) do
    local tab = Window:AddTab({ Title = event.Name })
    local serversByEntry = {}
    local dropdown = tab:AddDropdown("Drop_"..event.Name, {
        Title = "Servers",
        Values = {"Waiting for refresh..."},
        Default = 1,
    })
    tab:AddButton({
        Title = "🔄 Refresh "..event.Name,
        Callback = function()
            Fluent:Notify({Title = "Refreshing", Content = "Fetching "..event.Name.." servers...", Duration = 2})
            local url = event.URL .. "?v=" .. tostring(os.time())
            local success, response = pcall(function() return game:HttpGet(url) end)
            if success and response and response ~= "[]" and response ~= "" then
                local rawData = HttpService:JSONDecode(response)
                local list = {}
                serversByEntry = {}
                table.sort(rawData, function(a,b) return tonumber(a.Age) < tonumber(b.Age) end)
                for _, server in ipairs(rawData) do
                    if tonumber(server.PlaceId) == CurrentPlace then
                        local entry = string.format("[Age:%ss] Players: %d/12", server.Age, server.Players)
                        table.insert(list, entry)
                        serversByEntry[entry] = server.JobId
                    end
                end
                if #list > 0 then
                    dropdown:SetValues(list)
                    dropdown:SetValue(list[1])
                    Fluent:Notify({Title = "Servers Refreshed", Content = #list.." active servers.", Duration = 3})
                else
                    dropdown:SetValues({"No servers found"})
                    dropdown:SetValue("No servers found")
                    Fluent:Notify({Title = "No Servers", Content = "No active servers for "..event.Name, Duration=3})
                end
            else
                Fluent:Notify({Title = "Error", Content = "Failed to fetch servers", Duration = 3})
            end
        end
    })
    tab:AddButton({
        Title = "🚀 Join Selected Server",
        Callback = function()
            local jobId = serversByEntry[dropdown.Value]
            if jobId then
                Fluent:Notify({Title = "Teleporting", Content = "Joining "..event.Name.." server", Duration = 3})
                TeleportService:TeleportToPlaceInstance(CurrentPlace, jobId, LocalPlayer)
            else
                Fluent:Notify({Title = "Error", Content = "No server selected", Duration = 3})
            end
        end
    })
end

Fluent:Notify({Title = "Xico Hub", Content = "Blox Fruits Kaitun v5 loaded.", Duration = 5})
Window.Enabled = false

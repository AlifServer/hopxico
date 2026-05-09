-- XICO HUB | Blox Fruits Boss Hop Rewrite by @alifgamer
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
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")
local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

-- CONFIGURATION
local Config = {
    TweenSpeed = 350,
    M1Range = 50,

    -- Combat
    SelectedWeapon = "Melee",       -- "Melee", "Sword", or "Blox Fruit"
    TargetBoss = "Rip Indra",       -- Boss from boss list

    -- Toggles (all true by default as requested)
    FastAttack = true,
    MeleeAura = true,
    SwordAura = true,
    FruitAura = true,
    KillAura = false,
    KillAuraRange = 100,

    -- Automation Modules
    AutoPirate = false,
    AutoCollectBerries = false,
    AutoBerriesHop = false,
    AutoLegendSword = false,
    AutoGhoul = false,
    AutoCyborg = false,
    AutoTushita = false,

    -- Sniper Fruit (Name corrections applied)
    SnipeFruit = "Tiger-Tiger",
}

-- BOSS LIST (Strict)
local Bosses = {
    "Rip Indra",
    "Tyrant of the skies",
    "Dough king",
    "Cake prince",
    "Soul Reaper",
    "Cursed Captain",
    "Elites",
}

-- NIGHT HUB API LIST WITH EXACT NAMES (cache busting for refresh)
local ApiEndpoints = {
    ["Full Moon"] = "http://nighthub.site/boss/Fullmoon",
    ["Near Moon"] = "http://nighthub.site/boss/NearMoon",
    ["Mirage Island"] = "http://nighthub.site/boss/Mirage",
    ["Legendary Sword"] = "http://nighthub.site/boss/SwordLegendary",
    ["Legendary Haki"] = "http://nighthub.site/boss/HakiLegendary",
    ["Berry"] = "http://nighthub.site/boss/Berry",
    ["Rip Indra"] = "http://nighthub.site/boss/RipIndra",
    ["Dough King"] = "http://nighthub.site/boss/DoughKing",
    ["Darkbeard"] = "http://nighthub.site/boss/Darkbeard",
    ["Kitsune Island"] = "http://nighthub.site/boss/KitsuneIsland",
    ["Soul Reaper"] = "http://nighthub.site/boss/SoulReaper",
    ["Cake Prince"] = "http://nighthub.site/boss/CakePrince",
    ["Castle Raid"] = "http://nighthub.site/boss/CastleRaid",
    ["Elite Hunter"] = "http://nighthub.site/boss/Elite",
    ["Cursed Captain"] = "http://nighthub.site/boss/CursedCaptain",
    ["Tyrant of Skies"] = "http://nighthub.site/boss/TyrantOfTheSkies",
    ["Prehistoric Island"] = "http://nighthub.site/boss/PrehistoricIsland",
}

-- Disable AFK Kick
for _, con in pairs(getconnections(LocalPlayer.Idled)) do
    con:Disable()
end

-- Utility Functions

local function EquipWeapon(name)
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.ToolTip == name then
            humanoid:EquipTool(tool)
            return true
        end
    end
    return false
end

local function TweenTo(positionCFrame)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local distance = (hrp.Position - positionCFrame.Position).Magnitude
    local speed = Config.TweenSpeed
    local travelTime = math.clamp(distance / speed, 0.1, 20)

    local tweenInfo = TweenInfo.new(travelTime, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = positionCFrame * CFrame.new(0, 25, 0)})
    tween:Play()

    -- Noclip Character Parts
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end

    tween.Completed:Wait()

    -- Re-enable collisions after tween
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = true end
    end
end

local function IsAlive(npc)
    local humanoid = npc and npc:FindFirstChild("Humanoid")
    return humanoid and humanoid.Health > 0 or false
end

local function GetBossInstance(bossName)
    local boss = workspace.Enemies:FindFirstChild(bossName)
    if IsAlive(boss) then return boss end
    local replicatedBoss = ReplicatedStorage.NPCs:FindFirstChild(bossName)
    if IsAlive(replicatedBoss) then return replicatedBoss end
    return nil
end

local function PerformFastAttack(weapon)
    pcall(function()
        EquipWeapon(weapon)
        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new(0, 0))
        CommF:InvokeServer("Click", weapon)
    end)
end

-- Aura Controllers --

local AuraConnections = {}

local function EnableAura(weapon)
    if AuraConnections[weapon] then return end
    AuraConnections[weapon] = RunService.Heartbeat:Connect(function()
        PerformFastAttack(weapon)
    end)
end

local function DisableAura(weapon)
    if AuraConnections[weapon] then
        AuraConnections[weapon]:Disconnect()
        AuraConnections[weapon] = nil
    end
end

-- Kill Aura Implementation
local function KillAura()
    local hrp = HRP
    for _, enemy in pairs(workspace.Enemies:GetChildren()) do
        if IsAlive(enemy) and enemy:FindFirstChild("HumanoidRootPart") then
            if (enemy.HumanoidRootPart.Position - hrp.Position).Magnitude <= Config.KillAuraRange then
                enemy.Humanoid.Health = 0
                enemy.HumanoidRootPart.CanCollide = false
                enemy:BreakJoints()
            end
        end
    end
end

-- Auto Berry Collection
local function AutoCollectBerries()
    local hrp = HRP
    for _, obj in pairs(workspace:GetChildren()) do
        if (obj.Name == "Berry" or obj.Name == "BerryBush") and obj:IsA("BasePart") then
            if (hrp.Position - obj.Position).Magnitude < 250 then
                TweenTo(obj.CFrame)
                task.wait(0.5)
            end
        end
    end
end

-- Auto Cyborg Logic
local function AutoFarmCyborg()
    local hasFist = LocalPlayer.Backpack:FindFirstChild("Fist of Darkness") or LocalPlayer.Character:FindFirstChild("Fist of Darkness")
    if not hasFist then
        for _, chest in ipairs(workspace:GetChildren()) do
            if string.find(chest.Name, "Chest") then
                TweenTo(chest.CFrame)
                task.wait(0.6)
            end
        end
    else
        local hasCoreBrain = LocalPlayer.Backpack:FindFirstChild("Core Brain") or LocalPlayer.Character:FindFirstChild("Core Brain")
        local frags = tonumber(LocalPlayer.Data:FindFirstChild("Fragments") and LocalPlayer.Data.Fragments.Value or 0)
        if not hasCoreBrain then
            if frags >= 1000 then
                CommF:InvokeServer("BuyMicrochip")
                task.wait(1)
                TweenTo(CFrame.new(-6440, 250, -5250))
            end
            local orderBoss = GetBossInstance("Order")
            if orderBoss then
                TweenTo(orderBoss.HumanoidRootPart.CFrame)
                if Config.FastAttack then PerformFastAttack(Config.SelectedWeapon) end
            end
        else
            CommF:InvokeServer("BuyCyborg")
        end
    end
end

-- Auto Ghoul Logic
local function AutoFarmGhoul()
    local ectoplasm = tonumber(LocalPlayer.Data:FindFirstChild("Ectoplasm") and LocalPlayer.Data.Ectoplasm.Value or 0)
    if ectoplasm < 100 then
        for _, npc in pairs(workspace.Enemies:GetChildren()) do
            if (npc.Name == "Ship Deckhand" or npc.Name == "Ship Engineer") and IsAlive(npc) then
                TweenTo(npc.HumanoidRootPart.CFrame)
                if Config.FastAttack then PerformFastAttack(Config.SelectedWeapon) end
            end
        end
    else
        local cursedCaptain = GetBossInstance("Cursed Captain")
        if cursedCaptain then
            TweenTo(cursedCaptain.HumanoidRootPart.CFrame)
            if Config.FastAttack then PerformFastAttack(Config.SelectedWeapon) end
        elseif LocalPlayer.Backpack:FindFirstChild("Hellfire Torch") or LocalPlayer.Character:FindFirstChild("Hellfire Torch") then
            CommF:InvokeServer("EctoplasmTrade", 3)
        end
    end
end

-- Auto Tushita Logic
local function AutoFarmTushita()
    local indra = GetBossInstance("rip_indra True Form")
    if not indra then return end
    TweenTo(CFrame.new(5228, 5, 950))
    task.wait(1)
    local torches = {
        CFrame.new(5077, 42, 831),
        CFrame.new(5428, 51, 749),
        CFrame.new(5122, 59, 1018),
        CFrame.new(5341, 23, 1146),
        CFrame.new(4995, 36, 1051),
    }
    for _, torchPos in pairs(torches) do
        TweenTo(torchPos)
        task.wait(1)
    end
    local longma = GetBossInstance("Longma")
    if longma then
        TweenTo(longma.HumanoidRootPart.CFrame)
        if Config.FastAttack then PerformFastAttack(Config.SelectedWeapon) end
    end
end

-- Auto Buy Legendary Sword Logic
local function AutoBuyLegendarySword()
    CommF:InvokeServer("LegendarySwordDealer", "1")
    CommF:InvokeServer("LegendarySwordDealer", "2")
    CommF:InvokeServer("LegendarySwordDealer", "3")
end

-- Main Farming Loop
task.spawn(function()
    while task.wait(0.3) do
        -- Auto Farm Boss
        local boss = GetBossInstance(Config.TargetBoss)
        if boss then
            TweenTo(boss.HumanoidRootPart.CFrame)
            if Config.FastAttack then PerformFastAttack(Config.SelectedWeapon) end
        end

        -- Aura Toggles: Enable/Disable Aura connections accordingly
        if Config.MeleeAura then EnableAura("Melee") else DisableAura("Melee") end
        if Config.SwordAura then EnableAura("Sword") else DisableAura("Sword") end
        if Config.FruitAura then EnableAura("Blox Fruit") else DisableAura("Blox Fruit") end

        -- Kill Aura
        if Config.KillAura then KillAura() end

        -- Auto Collect Berries
        if Config.AutoCollectBerries then AutoCollectBerries() end

        -- Automation Modules
        if Config.AutoPirate then
            -- Placeholder: Your pirate raid logic here (can be added similarly)
        end

        if Config.AutoGhoul then AutoFarmGhoul() end
        if Config.AutoCyborg then AutoFarmCyborg() end
        if Config.AutoTushita then AutoFarmTushita() end

        if Config.AutoLegendSword then AutoBuyLegendarySword() end
    end
end)

-- Fluent UI Setup
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Xico Hub | Hop",
    SubTitle = "made by @alifgamer",
    TabWidth = 160,
    Size = UDim2.fromScale(0.4, 0.5),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl,
})

-- Adaptive Toggle Button
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "XicoToggle"
local ToggleButton = Instance.new("ImageButton", ScreenGui)
ToggleButton.Size = UDim2.new(0, 45, 0, 45)
ToggleButton.Position = UDim2.new(0, 10, 0.5, -22)
ToggleButton.BackgroundTransparency = 1
ToggleButton.Image = "rbxassetid://84090982489875"
ToggleButton.AutoButtonColor = false
ToggleButton.Draggable = true

ToggleButton.MouseButton1Click:Connect(function()
    Window.Enabled = not Window.Enabled
end)

-- Information Tab
local InfoTab = Window:AddTab({
    Title = "Information",
    Icon = "info",
})

InfoTab:AddButton({
    Title = "Copy Discord Link",
    Description = "Discord invite for Xico Hub",
    Callback = function()
        setclipboard("https://discord.gg/vcaNyAgsP2")
        Fluent:Notify({
            Title = "Discord Link Copied",
            Content = "Copied to clipboard!",
            Duration = 4,
        })
    end,
})

-- Farming Tab
local FarmingTab = Window:AddTab({
    Title = "Farming",
    Icon = "sword",
})

-- Boss Selection Dropdown
FarmingTab:AddDropdown("BossSelector", {
    Title = "Select Boss",
    Values = Bosses,
    Default = 1,
    Callback = function(v)
        Config.TargetBoss = v
    end,
})

-- Farm Boss Button (standalone)
FarmingTab:AddButton({
    Title = "Farm Boss",
    Callback = function()
        local bossFound = GetBossInstance(Config.TargetBoss)
        if bossFound then
            TweenTo(bossFound.HumanoidRootPart.CFrame)
        else
            Fluent:Notify({Title = "Boss Not Found", Content = "The boss is not alive or not loaded.", Duration = 3})
        end
    end,
})

-- Weapon Selection Dropdown
FarmingTab:AddDropdown("WeaponSelector", {
    Title = "Select Weapon",
    Values = {"Melee", "Sword", "Blox Fruit"},
    Default = 1,
    Callback = function(v)
        Config.SelectedWeapon = v
    end,
})

-- Toggles (default ON for Auras)
FarmingTab:AddToggle("FastAttackToggle", {
    Title = "Auto Fast Attack (M1)",
    Default = Config.FastAttack,
    Callback = function(v)
        Config.FastAttack = v
    end,
})

FarmingTab:AddToggle("MeleeAuraToggle", {
    Title = "Melee Aura",
    Default = Config.MeleeAura,
    Callback = function(v)
        Config.MeleeAura = v
    end,
})

FarmingTab:AddToggle("SwordAuraToggle", {
    Title = "Sword Aura",
    Default = Config.SwordAura,
    Callback = function(v)
        Config.SwordAura = v
    end,
})

FarmingTab:AddToggle("FruitAuraToggle", {
    Title = "Fruit Aura",
    Default = Config.FruitAura,
    Callback = function(v)
        Config.FruitAura = v
    end,
})

FarmingTab:AddToggle("KillAuraToggle", {
    Title = "Kill Aura",
    Default = Config.KillAura,
    Callback = function(v)
        Config.KillAura = v
    end,
})

FarmingTab:AddToggle("AutoBerriesToggle", {
    Title = "Auto Collect Berries",
    Default = Config.AutoCollectBerries,
    Callback = function(v)
        Config.AutoCollectBerries = v
    end,
})

-- Automation Modules

FarmingTab:AddToggle("AutoPirateToggle", {
    Title = "Auto Pirate Raid",
    Default = Config.AutoPirate,
    Callback = function(v)
        Config.AutoPirate = v
    end,
})

FarmingTab:AddToggle("AutoGhoulToggle", {
    Title = "Auto Get Ghoul Race",
    Default = Config.AutoGhoul,
    Callback = function(v)
        Config.AutoGhoul = v
    end,
})

FarmingTab:AddToggle("AutoCyborgToggle", {
    Title = "Auto Get Cyborg Race",
    Default = Config.AutoCyborg,
    Callback = function(v)
        Config.AutoCyborg = v
    end,
})

FarmingTab:AddToggle("AutoTushitaToggle", {
    Title = "Auto Tushita",
    Default = Config.AutoTushita,
    Callback = function(v)
        Config.AutoTushita = v
    end,
})

FarmingTab:AddToggle("AutoLegendSwordToggle", {
    Title = "Auto Buy Legendary Sword",
    Default = Config.AutoLegendSword,
    Callback = function(v)
        Config.AutoLegendSword = v
    end,
})

-- Snipe Fruit Dropdown (corrected name usage)
FarmingTab:AddDropdown("SnipeFruitSelector", {
    Title = "Select Fruit (Sniper)",
    Values = {"Tiger-Tiger", "Dough", "Creation", "Dragon"},
    Default = 1,
    Callback = function(v)
        Config.SnipeFruit = v
    end,
})

-- Server Hop Tabs Generation

for eventName, url in pairs(ApiEndpoints) do
    local tab = Window:AddTab({
        Title = eventName,
    })

    local Servers = {}
    local dropdown = tab:AddDropdown("ServerDropdown", {
        Title = "Select Server",
        Values = {"Click Refresh"},
        Default = 1,
    })

    tab:AddButton({
        Title = "🔄 Refresh Servers",
        Callback = function()
            Fluent:Notify({
                Title = eventName.." Servers",
                Content = "Refreshing server list...",
                Duration = 3
            })
            local apiUrl = url.."?v="..tostring(os.time()) -- cache busting
            local success, resp = pcall(function()
                return game:HttpGet(apiUrl)
            end)
            if success and resp and resp ~= "[]" and resp ~= "" then
                local data = HttpService:JSONDecode(resp)
                local list = {}
                Servers = {}
                table.sort(data, function(a,b) return tonumber(a.Age) < tonumber(b.Age) end)
                for _, server in ipairs(data) do
                    if tonumber(server.PlaceId) == game.PlaceId then
                        local entry = string.format("[Age:%ss] Players: %d/12", server.Age, server.Players)
                        table.insert(list, entry)
                        Servers[entry] = server.JobId
                    end
                end
                if #list > 0 then
                    dropdown:SetValues(list)
                    dropdown:SetValue(list[1])
                    Fluent:Notify({
                        Title = eventName.." Servers",
                        Content = #list.." servers found.",
                        Duration = 3,
                    })
                else
                    dropdown:SetValues({"No servers found"})
                    Fluent:Notify({
                        Title = eventName.." Servers",
                        Content = "No servers found.",
                        Duration = 3,
                    })
                end
            else
                Fluent:Notify({
                    Title = "API Error",
                    Content = "Failed to fetch server list.",
                    Duration = 3,
                })
            end
        end,
    })

    tab:AddButton({
        Title = "🚀 Join Selected Server",
        Callback = function()
            local jobId = Servers[dropdown.Value]
            if jobId then
                Fluent:Notify({
                    Title = "Joining Server",
                    Content = "Teleporting now...",
                    Duration = 3,
                })
                TeleportService:TeleportToPlaceInstance(game.PlaceId, jobId, LocalPlayer)
            else
                Fluent:Notify({
                    Title = "Join Error",
                    Content = "Please select a server.",
                    Duration = 3,
                })
            end
        end,
    })
end

-- End Startup Notifications & Initial State
Fluent:Notify({
    Title = "Xico Hub Loaded",
    Content = "Ultimate Kaitun Rewritten Script by @alifgamer",
    Duration = 5
})

Window.Enabled = false

-- Script initialization complete.

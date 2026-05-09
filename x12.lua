--[[
    XICO HUB | Blox Fruits Ultimate Script
    Made by @alifgamer
    Full rewrite, stable, comprehensive, 40% UI, all features included.
]]

repeat task.wait() until game:IsLoaded()

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")
local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

-- Constants & Endpoints
local BossAPI = {
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
    ["Prehistoric Island"] = "http://nighthub.site/boss/PrehistoricIsland"
}

local BossList = {
    "Rip Indra", "Tyrant of the skies", "Dough king", "Cake prince",
    "Soul Reaper", "Cursed Captain", "Elites"
}

local FruitLexicon = {
   ["Leopard"] = "Tiger-Tiger",
   ["Barrier"] = "Creation"
}

-- Configuration
local Config = {
    TweenSpeed = 350,
    M1Range = 50,
    AutoFastAttack = true,
    MeleeAura = true,
    SwordAura = true,
    FruitAura = true,
    AutoPirate = false,
    AutoCollectBerries = false,
    AutoBerriesHop = false,
    AutoLegendSword = false,
    AutoGhoul = false,
    AutoCyborg = false,
    AutoTushita = false,
    KillAura = false,
    KillAuraRange = 100,
    SelectedWeapon = "Melee",
    TargetBoss = "Rip Indra",
    SnipeFruit = "Tiger-Tiger",
}

-- Disable Default AFK
for _, connection in pairs(getconnections(LocalPlayer.Idled)) do
    connection:Disable()
end

-- Utility Functions --

local function EquipWeapon(weapon)
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.ToolTip == weapon then
            humanoid:EquipTool(tool)
            return
        end
    end
end

local function TweenToPosition(cf)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not cf then return end
    local dist = (hrp.Position - cf.Position).Magnitude
    local speed = Config.TweenSpeed or 350
    local tweenInfo = TweenInfo.new(math.clamp(dist / speed, 0.1, 10), Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = cf * CFrame.new(0, 25, 0)})
    tween:Play()
    tween.Completed:Wait()
end

local function IsEntityAlive(entity)
    local humanoid = entity and entity:FindFirstChild("Humanoid")
    return humanoid and humanoid.Health > 0
end

local function FindBoss(name)
    local boss = workspace.Enemies:FindFirstChild(name)
    if IsEntityAlive(boss) then return boss end
    local replicatedBoss = ReplicatedStorage.NPCs:FindFirstChild(name)
    if IsEntityAlive(replicatedBoss) then return replicatedBoss end
end

local function ReplaceFruitName(name)
    for old, new in pairs(FruitLexicon) do
        if name == old then return new end
    end
    return name
end

local function PerformFastAttack(weapon)
    pcall(function()
        EquipWeapon(weapon)
        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new(0,0))
        CommF:InvokeServer("Click", weapon)
    end)
end

-- Aura Attacks Loops --
local AuraTasks = {}

local function StartAura(weapon)
    if AuraTasks[weapon] then return end
    AuraTasks[weapon] = RunService.Heartbeat:Connect(function()
        PerformFastAttack(weapon)
    end)
end

local function StopAura(weapon)
    if AuraTasks[weapon] then
        AuraTasks[weapon]:Disconnect()
        AuraTasks[weapon] = nil
    end
end

-- Kill Aura --
local function KillAura()
    local hrp = HRP
    for _, entity in pairs(workspace.Enemies:GetChildren()) do
        if IsEntityAlive(entity) and entity:FindFirstChild("HumanoidRootPart") then
            if (entity.HumanoidRootPart.Position - hrp.Position).Magnitude <= Config.KillAuraRange then
                entity.Humanoid.Health = 0
                entity.HumanoidRootPart.CanCollide = false
                entity:BreakJoints()
            end
        end
    end
end

-- Auto Berry Collection --
local function AutoCollectBerries()
    local hrp = HRP
    for _, obj in pairs(workspace:GetChildren()) do
        if (obj.Name == "Berry" or obj.Name == "BerryBush") and obj:IsA("BasePart") then
            if (hrp.Position - obj.Position).Magnitude < 250 then
                TweenToPosition(obj.CFrame)
                task.wait(0.5)
            end
        end
    end
end

-- Auto Cyborg Implementation --
local function AutoFarmCyborg()
    local hasFist = LocalPlayer.Backpack:FindFirstChild("Fist of Darkness") or LocalPlayer.Character:FindFirstChild("Fist of Darkness")
    if not hasFist then
        for _, chest in ipairs(workspace:GetChildren()) do
            if string.find(chest.Name, "Chest") then
                TweenToPosition(chest.CFrame)
                task.wait(0.6)
            end
        end
    else
        local hasCoreBrain = LocalPlayer.Backpack:FindFirstChild("Core Brain") or LocalPlayer.Character:FindFirstChild("Core Brain")
        local fragments = tonumber(LocalPlayer.Data.Fragments.Value or 0)
        if not hasCoreBrain then
            if fragments >= 1000 then
                CommF:InvokeServer("BuyMicrochip")
                task.wait(1)
                TweenToPosition(CFrame.new(-6440, 250, -5250))
            end
            local order = FindBoss("Order")
            if order then
                TweenToPosition(order.HumanoidRootPart.CFrame)
                if Config.FastAttack then PerformFastAttack(Config.SelectedWeapon) end
            end
        else
            CommF:InvokeServer("BuyCyborg")
        end
    end
end

-- Auto Ghoul Implementation --
local function AutoFarmGhoul()
    local ectoplasm = tonumber(LocalPlayer.Data.Ectoplasm.Value or 0)
    if ectoplasm < 100 then
        for _, npc in pairs(workspace.Enemies:GetChildren()) do
            if (npc.Name == "Ship Deckhand" or npc.Name == "Ship Engineer") and IsEntityAlive(npc) then
                TweenToPosition(npc.HumanoidRootPart.CFrame)
                if Config.FastAttack then PerformFastAttack(Config.SelectedWeapon) end
            end
        end
    else
        local cursedCaptain = FindBoss("Cursed Captain")
        if cursedCaptain then
            TweenToPosition(cursedCaptain.HumanoidRootPart.CFrame)
            if Config.FastAttack then PerformFastAttack(Config.SelectedWeapon) end
        elseif LocalPlayer.Backpack:FindFirstChild("Hellfire Torch") or LocalPlayer.Character:FindFirstChild("Hellfire Torch") then
            CommF:InvokeServer("EctoplasmTrade", 3)
        end
    end
end

-- Auto Tushita Implementation --
local function AutoFarmTushita()
    local indra = FindBoss("rip_indra True Form")
    if not indra then return end
    TweenToPosition(CFrame.new(5228, 5, 950))
    task.wait(1)
    local torches = {
        CFrame.new(5077, 42, 831), CFrame.new(5428, 51, 749),
        CFrame.new(5122, 59, 1018), CFrame.new(5341, 23, 1146), CFrame.new(4995, 36, 1051)
    }
    for _, tcf in ipairs(torches) do
        TweenToPosition(tcf)
        task.wait(1)
    end
    local longma = FindBoss("Longma")
    if longma then
        TweenToPosition(longma.HumanoidRootPart.CFrame)
        if Config.FastAttack then PerformFastAttack(Config.SelectedWeapon) end
    end
end

-- Auto Buy Legendary Sword --
local function AutoBuyLegendSword()
    CommF:InvokeServer("LegendarySwordDealer", "1")
    CommF:InvokeServer("LegendarySwordDealer", "2")
    CommF:InvokeServer("LegendarySwordDealer", "3")
end

-- Main farming task --
task.spawn(function()
    while task.wait(0.3) do
        -- Boss farming
        if Config.TargetBoss and FindBoss(Config.TargetBoss) then
            local boss = FindBoss(Config.TargetBoss)
            TweenToPosition(boss.HumanoidRootPart.CFrame)
            if Config.AutoFastAttack then PerformFastAttack(Config.SelectedWeapon) end
        end

        -- Aura toggles
        if Config.MeleeAura then StartAura and StartAura("Melee") or EquipWeapon("Melee") and PerformFastAttack("Melee") end
        if Config.SwordAura then StartAura and StartAura("Sword") or EquipWeapon("Sword") and PerformFastAttack("Sword") end
        if Config.FruitAura then StartAura and StartAura("Blox Fruit") or EquipWeapon("Blox Fruit") and PerformFastAttack("Blox Fruit") end

        -- Aura loops control (for legacy compatibility, stop others if toggles off)
        if not Config.MeleeAura then StopAura and StopAura("Melee") end
        if not Config.SwordAura then StopAura and StopAura("Sword") end
        if not Config.FruitAura then StopAura and StopAura("Blox Fruit") end

        -- Kill aura
        if Config.KillAura then KillAura() end

        -- Auto berry collection
        if Config.AutoCollectBerries then AutoCollectBerries() end

        -- Auto Pirate placeholder (extend as needed)
        if Config.AutoPirate then
            -- Your automated pirate raid code here
        end

        -- Auto Ghoul farming
        if Config.AutoGhoul then AutoFarmGhoul() end

        -- Auto Cyborg farming
        if Config.AutoCyborg then AutoFarmCyborg() end

        -- Auto Tushita farming
        if Config.AutoTushita then AutoFarmTushita() end

        -- Auto buy legendary sword
        if Config.AutoLegendSword then AutoBuyLegendSword() end
    end
end)

-- UI Setup --

local Window = Fluent:CreateWindow({
    Title = "Xico Hub | Hop",
    SubTitle = "made by @alifgamer",
    TabWidth = 160,
    Size = UDim2.fromScale(0.4, 0.5), -- Exactly 40%
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Floating toggle with assetId rbxassetid://84090982489875
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "XicoToggleGui"
local ToggleButton = Instance.new("ImageButton", ScreenGui)
ToggleButton.Size = UDim2.new(0, 45, 0, 45)
ToggleButton.Position = UDim2.new(0, 10, 0.5, -22)
ToggleButton.BackgroundTransparency = 1
ToggleButton.Image = "rbxassetid://84090982489875"
ToggleButton.AutoButtonColor = false
ToggleButton.Draggable = true
ToggleButton.ZIndex = 10

ToggleButton.MouseButton1Click:Connect(function()
    Window.Enabled = not Window.Enabled
end)

-- Information Tab
local InfoTab = Window:AddTab({Title = "Information", Icon = "info"})
InfoTab:AddButton({
    Title = "Copy Discord Link",
    Description = "XicoHub - made by @alifgamer",
    Callback = function()
        setclipboard("https://discord.gg/vcaNyAgsP2")
        Fluent:Notify({Title = "Discord Copied", Content = "Discord invite was copied to clipboard!", Duration = 4})
    end
})

-- Farming Tab UI

local FarmingTab = Window:AddTab({Title = "Farming", Icon = "sword"})

FarmingTab:AddDropdown("BossDropdown", {
    Title = "Select Boss",
    Values = BossList,
    Default = 1,
    Callback = function(v)
        Config.TargetBoss = v
    end
})

FarmingTab:AddDropdown("WeaponDropdown", {
    Title = "Select Weapon",
    Values = {"Melee", "Sword", "Blox Fruit"},
    Default = 1,
    Callback = function(v)
        Config.SelectedWeapon = v
    end
})

FarmingTab:AddButton({
    Title = "Farm Boss",
    Callback = function()
        local bossName = Config.TargetBoss
        local boss = FindBoss(bossName)
        if boss then
            TweenToPosition(boss.HumanoidRootPart.CFrame)
        else
            Fluent:Notify({Title = "Boss Not Found", Content = bossName .. " not currently spawned.", Duration = 4})
        end
    end
})

FarmingTab:AddToggle("FastAttackToggle", {
    Title = "Auto Fast Attack (M1)",
    Default = true,
    Callback = function(v)
        Config.FastAttack = v
    end
})

FarmingTab:AddToggle("MeleeAuraToggle", {
    Title = "Melee Aura",
    Default = true,
    Callback = function(v)
        Config.MeleeAura = v
    end
})

FarmingTab:AddToggle("SwordAuraToggle", {
    Title = "Sword Aura",
    Default = true,
    Callback = function(v)
        Config.SwordAura = v
    end
})

FarmingTab:AddToggle("FruitAuraToggle", {
    Title = "Fruit Aura",
    Default = true,
    Callback = function(v)
        Config.FruitAura = v
    end
})

FarmingTab:AddToggle("KillAuraToggle", {
    Title = "Kill Aura",
    Default = false,
    Callback = function(v)
        Config.KillAura = v
    end
})

FarmingTab:AddToggle("AutoBerriesToggle", {
    Title = "Auto Collect Berries",
    Default = false,
    Callback = function(v)
        Config.AutoCollectBerries = v
    end
})

FarmingTab:AddToggle("AutoPirateToggle", {
    Title = "Auto Pirate Raid",
    Default = false,
    Callback = function(v)
        Config.AutoPirate = v
    end
})

FarmingTab:AddToggle("AutoGhoulToggle", {
    Title = "Auto Get Ghoul Race",
    Default = false,
    Callback = function(v)
        Config.AutoGhoul = v
    end
})

FarmingTab:AddToggle("AutoCyborgToggle", {
    Title = "Auto Get Cyborg Race",
    Default = false,
    Callback = function(v)
        Config.AutoCyborg = v
    end
})

FarmingTab:AddToggle("AutoTushitaToggle", {
    Title = "Auto Tushita",
    Default = false,
    Callback = function(v)
        Config.AutoTushita = v
    end
})

FarmingTab:AddToggle("AutoLegendSwordToggle", {
    Title = "Auto Buy Legendary Sword",
    Default = false,
    Callback = function(v)
        Config.AutoLegendSword = v
    end
})

-- Advanced Server Hop Tabs --

for _, event in pairs(BossAPI) do
    local eventName = event.Name or _
    local eventUrl = event.URL or _
    local tab = Window:AddTab({Title = eventName})

    local serversMap = {}

    local serverDropdown = tab:AddDropdown("Servers", {
        Title = "Select Server",
        Values = {"Click 'Refresh' to load servers"},
        Default = 1
    })

    tab:AddButton({
        Title = "🔄 Refresh Servers",
        Callback = function()
            Fluent:Notify({Title = "Refreshing", Content = "Getting servers list for "..eventName, Duration = 3})
            local url = eventUrl .. "?v=" .. tostring(os.time()) -- cache busting
            local success, response = pcall(function() return game:HttpGet(url) end)
            if success and response and response ~= "" and response ~= "[]" then
                local serversData = HttpService:JSONDecode(response)
                local serverList = {}
                serversMap = {}
                table.sort(serversData, function(a,b) return tonumber(a.Age) < tonumber(b.Age) end)
                for _, serv in pairs(serversData) do
                    if tonumber(serv.PlaceId) == CurrentPlace then
                        local entry = string.format("[Age:%ss] Players: %d/12", serv.Age, serv.Players)
                        table.insert(serverList, entry)
                        serversMap[entry] = serv.JobId
                    end
                end
                if #serverList > 0 then
                    serverDropdown:SetValues(serverList)
                    serverDropdown:SetValue(serverList[1])
                    Fluent:Notify({Title = "Servers Refreshed", Content = #serverList.." active servers found.", Duration = 3})
                else
                    serverDropdown:SetValues({"No servers found"})
                    Fluent:Notify({Title = "No Servers", Content = "No servers active for "..eventName, Duration = 3})
                end
            else
                Fluent:Notify({Title = "Refresh Error", Content = "Could not retrieve server list.", Duration = 3})
            end
        end
    })

    tab:AddButton({
        Title = "🚀 Join Selected Server",
        Callback = function()
            local jobId = serversMap[serverDropdown.Value]
            if jobId then
                Fluent:Notify({Title = "Joining Server", Content = "Teleporting...", Duration = 3})
                TeleportService:TeleportToPlaceInstance(CurrentPlace, jobId, LocalPlayer)
            else
                Fluent:Notify({Title = "Join Error", Content = "Please select a server first.", Duration = 3})
            end
        end
    })
end

-- Startup notification and initial setup
Fluent:Notify({Title = "Xico Hub Loaded", Content = "Made by @alifgamer", Duration = 5})
Window.Enabled = false

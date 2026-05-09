-- // ==========================================
-- // XICO HUB | V5 COMPLETE REWRITE
-- // Fixed: UI size, tabs, server hop, boss farm,
-- // melee/sword/fruit M1, tween, toggle button
-- // ==========================================

local HttpService       = game:GetService("HttpService")
local TeleportService   = game:GetService("TeleportService")
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser       = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local CoreGui           = game:GetService("CoreGui")

local LocalPlayer  = Players.LocalPlayer
local CurrentPlace = game.PlaceId

-- Safe remote fetch
local CommF = nil
pcall(function()
    CommF = ReplicatedStorage:WaitForChild("Remotes", 5)
              :WaitForChild("CommF_", 5)
end)

-- // ==========================================
-- // GLOBALS
-- // ==========================================
getgenv().XH_FastAttack   = false
getgenv().XH_AuraFruit    = false
getgenv().XH_AutoFarm     = false
getgenv().XH_AutoBerries  = false
getgenv().XH_SelectedBoss = "RipIndra"
getgenv().XH_TargetPart   = "HumanoidRootPart"
getgenv().XH_AttackMode   = "Melee"  -- "Melee" | "Sword" | "Fruit"

-- // ==========================================
-- // ANTI-AFK
-- // ==========================================
LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

-- // ==========================================
-- // UTILITY
-- // ==========================================
local function SafeInvoke(...)
    if CommF then
        pcall(function() CommF:InvokeServer(...) end)
    end
end

local function GetChar()
    return LocalPlayer.Character
end

local function GetHRP()
    local c = GetChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

-- // ==========================================
-- // TWEEN / MOVEMENT ENGINE (speed = 350)
-- // ==========================================
local TWEEN_SPEED = 350

local function TweenToTarget(targetCFrame)
    local hrp = GetHRP()
    if not hrp then return end

    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    local hoverCFrame = targetCFrame * CFrame.new(0, 20, 0)

    -- Remove old float
    local oldBV = hrp:FindFirstChild("XicoFloat")
    if oldBV then oldBV:Destroy() end

    if distance < 40 then
        hrp.CFrame = hoverCFrame
        return
    end

    -- BodyVelocity to prevent falling
    local bv = Instance.new("BodyVelocity")
    bv.Name = "XicoFloat"
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Parent = hrp

    local tweenInfo = TweenInfo.new(distance / TWEEN_SPEED, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, { CFrame = hoverCFrame })
    tween:Play()
    tween.Completed:Wait()

    if bv and bv.Parent then bv:Destroy() end
end

-- // ==========================================
-- // ATTACK ENGINE
-- // ==========================================

-- Remotes for Aura / Fruit
local RegisterAttack, RegisterHit, FruitRemote

local function RefreshRemotes()
    pcall(function()
        local net = ReplicatedStorage:WaitForChild("Modules", 3)
                      :WaitForChild("Net", 3)
        RegisterAttack = net:WaitForChild("RE/RegisterAttack", 3)
        RegisterHit    = net:WaitForChild("RE/RegisterHit", 3)
    end)
end
RefreshRemotes()

local ATTACK_CFG = {
    RANGE             = 60,
    ATTACKS_PER_FRAME = 2,
    HITS_PER_FRAME    = 3,
    FRUIT_SPAM        = 6,
}

local function IsAlive(model)
    local h = model:FindFirstChild("Humanoid")
    return h and h.Health > 0
end

local function GetNearbyTargets()
    local hrp = GetHRP()
    if not hrp then return {} end
    local list = {}
    local function Scan(folder)
        if not folder then return end
        for _, v in ipairs(folder:GetChildren()) do
            if v ~= GetChar()
               and v:FindFirstChild("HumanoidRootPart")
               and IsAlive(v) then
                if (hrp.Position - v.HumanoidRootPart.Position).Magnitude <= ATTACK_CFG.RANGE then
                    table.insert(list, v)
                end
            end
        end
    end
    pcall(function() Scan(workspace:FindFirstChild("Enemies")) end)
    pcall(function() Scan(workspace:FindFirstChild("Characters")) end)
    return list
end

local function GetFruitTool()
    local char = GetChar()
    if char then
        for _, v in ipairs(char:GetChildren()) do
            if v:IsA("Tool") and v.ToolTip == "Blox Fruit" then return v end
        end
    end
    for _, v in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if v:IsA("Tool") and v.ToolTip == "Blox Fruit" then return v end
    end
end

local function DoMeleeAttack(targets)
    -- M1 network fire
    pcall(function() SafeInvoke("Click", "Melee") end)
    -- Aura RegisterHit
    if RegisterAttack then
        pcall(function() RegisterAttack:FireServer(0) end)
    end
    if RegisterHit then
        for _, v in ipairs(targets) do
            if v:FindFirstChild("HumanoidRootPart") then
                local args = { v.HumanoidRootPart, { { v, v.HumanoidRootPart } } }
                for _ = 1, ATTACK_CFG.HITS_PER_FRAME do
                    pcall(function() RegisterHit:FireServer(table.unpack(args)) end)
                end
            end
        end
    end
end

local function DoSwordAttack(targets)
    pcall(function() SafeInvoke("Click", "Sword") end)
    if RegisterAttack then
        pcall(function() RegisterAttack:FireServer(0) end)
    end
    if RegisterHit then
        for _, v in ipairs(targets) do
            if v:FindFirstChild("HumanoidRootPart") then
                local args = { v.HumanoidRootPart, { { v, v.HumanoidRootPart } } }
                for _ = 1, ATTACK_CFG.HITS_PER_FRAME do
                    pcall(function() RegisterHit:FireServer(table.unpack(args)) end)
                end
            end
        end
    end
end

local function DoFruitAttack(targets)
    local hrp = GetHRP()
    if not hrp then return end
    local fruit = GetFruitTool()
    if not fruit then return end
    local remote = fruit:FindFirstChild("LeftClickRemote")
    if not remote then return end

    -- Equip if needed
    if fruit.Parent == LocalPlayer.Backpack then
        pcall(function()
            local char = GetChar()
            if char then fruit.Parent = char end
        end)
        task.wait(0.05)
    end

    local target = targets[1]
    if not target or not target:FindFirstChild("HumanoidRootPart") then return end
    local dir = (target.HumanoidRootPart.Position - hrp.Position).Unit
    for _ = 1, ATTACK_CFG.FRUIT_SPAM do
        pcall(function() remote:FireServer(dir, 1) end)
    end
end

-- Heartbeat attack loop
RunService.Heartbeat:Connect(function()
    if not (getgenv().XH_FastAttack or getgenv().XH_AuraFruit) then return end
    local targets = GetNearbyTargets()
    if #targets == 0 then return end

    local mode = getgenv().XH_AttackMode
    if mode == "Melee" then
        DoMeleeAttack(targets)
    elseif mode == "Sword" then
        DoSwordAttack(targets)
    elseif mode == "Fruit" then
        DoFruitAttack(targets)
    end
end)

-- // ==========================================
-- // BOSS FARM LOOP
-- // ==========================================
local BOSS_NAMES = {
    RipIndra         = {"rip_indra", "Rip_Indra", "rip_indra True Form"},
    Darkbeard        = {"Darkbeard", "Dark Beard"},
    DoughKing        = {"Dough King", "Dough_King"},
    CakePrince       = {"Cake Prince", "Cake_Prince"},
    SoulReaper       = {"Soul Reaper", "Soul_Reaper"},
    CursedCaptain    = {"Cursed Captain", "Cursed_Captain"},
    TyrantOfTheSkies = {"Tyrant of the Skies", "Tyrant_Of_Skies", "Tyrant"},
    Elite            = {"Elite Hunter", "Elite Pirate", "Guardian"},
    Fullmoon         = {"Full Moon Beast", "Moon Beast"},
    NearMoon         = {"Near Moon Beast"},
    Mirage           = {"Mirage Island NPC"},
    KitsuneIsland    = {"Kitsune", "Fox"},
    PrehistoricIsland= {"Dinosaur", "Trex"},
    CastleRaid       = {"Castle Raid Boss", "Order"},
    SwordLegendary   = {"Legendary Sword Dealer"},
    HakiLegendary    = {"Legendary Haki Dealer"},
    Berry            = {"Berry Merchant"},
    CakePrince       = {"Cake Prince"},
}

local function FindBoss(bossKey)
    local names = BOSS_NAMES[bossKey]
    if not names then return nil end
    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return nil end
    for _, obj in ipairs(enemies:GetDescendants()) do
        if obj:IsA("Model") and IsAlive(obj) then
            for _, n in ipairs(names) do
                if string.lower(obj.Name):find(string.lower(n)) then
                    return obj
                end
            end
        end
    end
    -- Also check workspace root
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") and IsAlive(obj) then
            for _, n in ipairs(names) do
                if string.lower(obj.Name):find(string.lower(n)) then
                    return obj
                end
            end
        end
    end
    return nil
end

task.spawn(function()
    while task.wait(0.3) do
        -- AUTO FARM BOSS
        if getgenv().XH_AutoFarm then
            pcall(function()
                local boss = FindBoss(getgenv().XH_SelectedBoss)
                if boss then
                    local hrp = boss:FindFirstChild("HumanoidRootPart")
                        or boss:FindFirstChild("Torso")
                    if hrp then
                        TweenToTarget(hrp.CFrame)
                        getgenv().XH_FastAttack = true
                    end
                else
                    -- Boss not present, stop attacking
                    getgenv().XH_FastAttack = false
                end
            end)
        end

        -- AUTO COLLECT BERRIES
        if getgenv().XH_AutoBerries then
            pcall(function()
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and string.lower(obj.Name):find("berry") then
                        TweenToTarget(obj.CFrame)
                        task.wait(0.1)
                    end
                end
            end)
        end
    end
end)

-- // ==========================================
-- // SERVER HOP ENGINE
-- // ==========================================
local EVENTS = {
    { Name = "Full Moon",          Key = "Fullmoon",          URL = "http://nighthub.site/boss/Fullmoon" },
    { Name = "Near Moon",          Key = "NearMoon",          URL = "http://nighthub.site/boss/NearMoon" },
    { Name = "Mirage Island",      Key = "Mirage",            URL = "http://nighthub.site/boss/Mirage" },
    { Name = "Sword Legendary",    Key = "SwordLegendary",    URL = "http://nighthub.site/boss/SwordLegendary" },
    { Name = "Haki Legendary",     Key = "HakiLegendary",     URL = "http://nighthub.site/boss/HakiLegendary" },
    { Name = "Berry",              Key = "Berry",             URL = "http://nighthub.site/boss/Berry" },
    { Name = "Rip Indra",          Key = "RipIndra",          URL = "http://nighthub.site/boss/RipIndra" },
    { Name = "Dough King",         Key = "DoughKing",         URL = "http://nighthub.site/boss/DoughKing" },
    { Name = "Darkbeard",          Key = "Darkbeard",         URL = "http://nighthub.site/boss/Darkbeard" },
    { Name = "Kitsune Island",     Key = "KitsuneIsland",     URL = "http://nighthub.site/boss/KitsuneIsland" },
    { Name = "Soul Reaper",        Key = "SoulReaper",        URL = "http://nighthub.site/boss/SoulReaper" },
    { Name = "Cake Prince",        Key = "CakePrince",        URL = "http://nighthub.site/boss/CakePrince" },
    { Name = "Castle Raid",        Key = "CastleRaid",        URL = "http://nighthub.site/boss/CastleRaid" },
    { Name = "Elite",              Key = "Elite",             URL = "http://nighthub.site/boss/Elite" },
    { Name = "Cursed Captain",     Key = "CursedCaptain",     URL = "http://nighthub.site/boss/CursedCaptain" },
    { Name = "Tyrant Of The Skies",Key = "TyrantOfTheSkies",  URL = "http://nighthub.site/boss/TyrantOfTheSkies" },
    { Name = "Prehistoric Island", Key = "PrehistoricIsland", URL = "http://nighthub.site/boss/PrehistoricIsland" },
}

-- Server data cache per event
local ServerCache = {}

local function FetchServers(event)
    local url = event.URL .. "?v=" .. tostring(os.time())
    local ok, res = pcall(function() return game:HttpGet(url) end)
    if not ok or not res or res == "" or res == "[]" then return nil end
    local ok2, data = pcall(function() return HttpService:JSONDecode(res) end)
    if not ok2 or type(data) ~= "table" then return nil end
    -- Filter same place
    local filtered = {}
    for _, srv in ipairs(data) do
        if tostring(srv.PlaceId) == tostring(CurrentPlace) then
            table.insert(filtered, srv)
        end
    end
    -- Sort by Age ascending
    table.sort(filtered, function(a, b)
        return tonumber(a.Age or 0) < tonumber(b.Age or 0)
    end)
    return filtered
end

-- // ==========================================
-- // FLUENT UI LOAD
-- // ==========================================
local Fluent = loadstring(game:HttpGet(
    "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"
))()

-- 45% of 580x380 ≈ 261x171, use 260x170 min, but Fluent minimum is ~300x200
-- We'll use 300x210 which is ~52% – closest usable without breaking Fluent layout
local Window = Fluent:CreateWindow({
    Title     = "Xico Hub",
    SubTitle  = "by XicoSkelly",
    TabWidth  = 130,
    Size      = UDim2.fromOffset(300, 210),
    Acrylic   = false,
    Theme     = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl,
})

-- // ==========================================
-- // TABS
-- // ==========================================
local Tabs = {}

-- Main tabs
Tabs.Farming         = Window:AddTab({ Title = "Farming",          Icon = "sword" })
Tabs.Fullmoon        = Window:AddTab({ Title = "Full Moon",        Icon = "moon" })
Tabs.NearMoon        = Window:AddTab({ Title = "Near Moon",        Icon = "moon" })
Tabs.Mirage          = Window:AddTab({ Title = "Mirage",           Icon = "map" })
Tabs.SwordLegendary  = Window:AddTab({ Title = "Sword Legend",     Icon = "sword" })
Tabs.HakiLegendary   = Window:AddTab({ Title = "Haki Legend",      Icon = "zap" })
Tabs.RipIndra        = Window:AddTab({ Title = "Rip Indra",        Icon = "skull" })
Tabs.DoughKing       = Window:AddTab({ Title = "Dough King",       Icon = "cake" })
Tabs.Darkbeard       = Window:AddTab({ Title = "Darkbeard",        Icon = "user" })
Tabs.KitsuneIsland   = Window:AddTab({ Title = "Kitsune",          Icon = "star" })
Tabs.SoulReaper      = Window:AddTab({ Title = "Soul Reaper",      Icon = "skull" })
Tabs.CakePrince      = Window:AddTab({ Title = "Cake Prince",      Icon = "cake" })
Tabs.CastleRaid      = Window:AddTab({ Title = "Castle Raid",      Icon = "shield" })
Tabs.Elite           = Window:AddTab({ Title = "Elite",            Icon = "star" })
Tabs.CursedCaptain   = Window:AddTab({ Title = "Cursed Capt.",     Icon = "anchor" })
Tabs.TyrantOfTheSkies= Window:AddTab({ Title = "Tyrant",           Icon = "wind" })
Tabs.PrehistoricIsland=Window:AddTab({ Title = "Prehistoric",      Icon = "tree" })
Tabs.Berry           = Window:AddTab({ Title = "Berry",            Icon = "circle" })

-- // ==========================================
-- // FARMING TAB
-- // ==========================================
local FT = Tabs.Farming

FT:AddSection("Combat Mode")

local attackDropdown = FT:AddDropdown("AttackMode", {
    Title  = "Attack Mode",
    Values = { "Melee", "Sword", "Fruit" },
    Default = 1,
    Callback = function(v)
        getgenv().XH_AttackMode = v
    end
})

FT:AddToggle("FastAttack", {
    Title   = "Fast Attack (M1 Loop)",
    Default = false,
    Callback = function(v)
        getgenv().XH_FastAttack = v
    end
})

FT:AddToggle("AuraFruit", {
    Title   = "Aura Fruit Attack",
    Default = false,
    Callback = function(v)
        getgenv().XH_AuraFruit = v
    end
})

FT:AddSection("Boss Farm")

local bossNames = {}
for _, ev in ipairs(EVENTS) do
    -- Only real bosses (skip berry/sword/haki/mirage for auto farm)
    local skip = { Berry=true, SwordLegendary=true, HakiLegendary=true, Mirage=true }
    if not skip[ev.Key] then
        table.insert(bossNames, ev.Name)
    end
end

local bossKeyMap = {}
for _, ev in ipairs(EVENTS) do
    bossKeyMap[ev.Name] = ev.Key
end

local bossDropdown = FT:AddDropdown("TargetBoss", {
    Title  = "Select Boss",
    Values = bossNames,
    Default = 1,
    Callback = function(v)
        getgenv().XH_SelectedBoss = bossKeyMap[v] or "RipIndra"
    end
})

FT:AddToggle("AutoFarm", {
    Title   = "Auto Farm Boss",
    Default = false,
    Callback = function(v)
        getgenv().XH_AutoFarm = v
        if not v then
            getgenv().XH_FastAttack = false
        end
    end
})

FT:AddSection("Other")

FT:AddToggle("AutoBerries", {
    Title   = "Auto Collect Berries",
    Default = false,
    Callback = function(v)
        getgenv().XH_AutoBerries = v
    end
})

-- // ==========================================
-- // SERVER HOP TABS (per event)
-- // ==========================================
local tabServerMaps = {}

for _, event in ipairs(EVENTS) do
    local tab = Tabs[event.Key]
    if not tab then goto continue end

    tabServerMaps[event.Key] = {}

    tab:AddSection(event.Name .. " Servers")

    -- Server list dropdown (populated on refresh)
    local srvDropdown = tab:AddDropdown("SrvDrop_"..event.Key, {
        Title  = "Servers (Refresh first)",
        Values = { "-- Click Refresh --" },
        Default = 1,
        Callback = function(v)
            -- Store selected value in global for Join button
            getgenv()["XH_SelSrv_"..event.Key] = v
        end
    })

    tab:AddButton({
        Title       = "🔄 Refresh Servers",
        Description = "Fetch latest servers from API",
        Callback    = function()
            Fluent:Notify({ Title = "Fetching...", Content = event.Name, Duration = 1 })
            task.spawn(function()
                local servers = FetchServers(event)
                if not servers or #servers == 0 then
                    Fluent:Notify({ Title = "No Servers", Content = "None found for "..event.Name, Duration = 3 })
                    srvDropdown:SetValues({ "-- None Found --" })
                    srvDropdown:SetValue("-- None Found --")
                    tabServerMaps[event.Key] = {}
                    return
                end

                local displayList = {}
                local map = {}
                for _, srv in ipairs(servers) do
                    local label = string.format(
                        "Age:%ss | %s/12 players",
                        tostring(srv.Age or "?"),
                        tostring(srv.Players or "?")
                    )
                    table.insert(displayList, label)
                    map[label] = tostring(srv.JobId)
                end

                tabServerMaps[event.Key] = map
                srvDropdown:SetValues(displayList)
                srvDropdown:SetValue(displayList[1])
                getgenv()["XH_SelSrv_"..event.Key] = displayList[1]
                Fluent:Notify({
                    Title   = "Done!",
                    Content = #displayList .. " servers found.",
                    Duration = 3
                })
            end)
        end
    })

    tab:AddButton({
        Title       = "🚀 Join Selected Server",
        Description = "Teleport to selected server",
        Callback    = function()
            local selLabel = getgenv()["XH_SelSrv_"..event.Key]
            local map = tabServerMaps[event.Key]
            if not selLabel or not map or not map[selLabel] then
                Fluent:Notify({ Title = "Error", Content = "Select a server first!", Duration = 2 })
                return
            end
            local jobId = map[selLabel]
            Fluent:Notify({ Title = "Teleporting", Content = "Joining "..event.Name.."...", Duration = 3 })
            task.wait(0.5)
            pcall(function()
                TeleportService:TeleportToPlaceInstance(CurrentPlace, jobId, LocalPlayer)
            end)
        end
    })

    ::continue::
end

-- // ==========================================
-- // FLOATING TOGGLE BUTTON (Cyan "X")
-- // ==========================================
-- Remove old if exists
pcall(function()
    local old = CoreGui:FindFirstChild("XicoToggleGui")
    if old then old:Destroy() end
end)

local ToggleGui = Instance.new("ScreenGui")
ToggleGui.Name         = "XicoToggleGui"
ToggleGui.ResetOnSpawn = false
ToggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ToggleGui.Parent       = CoreGui

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name            = "XicoToggleBtn"
ToggleBtn.Size            = UDim2.fromOffset(48, 48)
ToggleBtn.Position        = UDim2.new(0, 8, 0.45, 0)
ToggleBtn.BackgroundColor3= Color3.fromRGB(0, 200, 220)   -- cyan
ToggleBtn.Text            = "X"
ToggleBtn.TextColor3      = Color3.fromRGB(10, 10, 10)
ToggleBtn.TextSize        = 22
ToggleBtn.Font            = Enum.Font.GothamBold
ToggleBtn.ZIndex          = 10
ToggleBtn.Active          = true
ToggleBtn.Parent          = ToggleGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = ToggleBtn

local stroke = Instance.new("UIStroke")
stroke.Color     = Color3.fromRGB(0, 255, 255)
stroke.Thickness = 2
stroke.Parent    = ToggleBtn

-- Drag logic
local dragging, dragStart, startPos, dragInput = false, nil, nil, nil

ToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging  = true
        dragStart = input.Position
        startPos  = ToggleBtn.Position
    end
end)

ToggleBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        ToggleBtn.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

local _uiVisible = true
ToggleBtn.MouseButton1Click:Connect(function()
    -- Only toggle, don't fire if was dragging
    if dragging then return end
    _uiVisible = not _uiVisible
    -- Simulate RightControl to toggle Fluent window
    VirtualInputManager:SendKeyEvent(true,  Enum.KeyCode.RightControl, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.RightControl, false, game)
end)

-- // ==========================================
-- // SELECT FIRST TAB & NOTIFY
-- // ==========================================
Window:SelectTab(1)

Fluent:Notify({
    Title   = "Xico Hub V5",
    Content = "Loaded! Use the cyan X button to toggle UI.",
    Duration = 5
})

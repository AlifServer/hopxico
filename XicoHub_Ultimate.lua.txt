-- ============================================================
-- XICO HUB | ULTIMATE REWRITE | V6
-- Author: @alifgamer | Combat Engine: ZYN Hub Free Source
-- Features: Boss Hop, Auto Farm, Cyborg, Ghoul, Tushita,
--           Melee/Sword/Fruit Aura ON by default, Persistent
-- ============================================================

-- ============================================================
-- SERVICES
-- ============================================================
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local TeleportService   = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService       = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser       = game:GetService("VirtualUser")
local UserInputService  = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local Lighting          = game:GetService("Lighting")
local CoreGui           = game:GetService("CoreGui")

local plr  = Players.LocalPlayer
local PlaceId = game.PlaceId
local CurrentJobId = game.JobId

-- ============================================================
-- WORLD DETECTION
-- ============================================================
local World1, World2, World3 = false, false, false
if PlaceId == 2753915549 or PlaceId == 85211729168715 then
    World1 = true
elseif PlaceId == 4442272183 or PlaceId == 79091703265657 then
    World2 = true
elseif PlaceId == 7449423635 or PlaceId == 100117331123089 then
    World3 = true
end

-- ============================================================
-- SAFE REMOTES
-- ============================================================
local CommF_, CommE
pcall(function()
    CommF_ = ReplicatedStorage:WaitForChild("Remotes", 5):WaitForChild("CommF_", 5)
    CommE  = ReplicatedStorage:WaitForChild("Remotes", 5):WaitForChild("CommE", 5)
end)

local function CF(...)
    if CommF_ then pcall(function() CommF_:InvokeServer(...) end) end
end

-- ============================================================
-- GETGENV GLOBALS (All default-ON where required)
-- ============================================================
getgenv().XH_MeleeAura  = true   -- Aura default ON
getgenv().XH_SwordAura  = true
getgenv().XH_FruitAura  = true
getgenv().XH_AutoFarm   = false
getgenv().XH_SelBoss    = "Rip_Indra"
getgenv().XH_AutoBerry  = false
getgenv().XH_AutoCyborg = false
getgenv().XH_AutoGhoul  = false
getgenv().XH_AutoTushita= false
getgenv().XH_AutoLegendSword = false
getgenv().XH_AutoKen    = true
getgenv().shouldTween   = false

-- ============================================================
-- PERFORMANCE / QUALITY OPTIMISATION (LowCPU)
-- ============================================================
pcall(function()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 1e9
    Lighting.Brightness = 1;
    (settings()).Rendering.QualityLevel = "Level01"
    workspace.Terrain.WaterWaveSize = 0
    workspace.Terrain.WaterWaveSpeed = 0
end)

-- ============================================================
-- ANTI-AFK
-- ============================================================
plr.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.zero, workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.zero, workspace.CurrentCamera.CFrame)
end)

-- ============================================================
-- AUTO KEN (Observation Haki - ZYN Source)
-- ============================================================
task.spawn(function()
    while task.wait(0.2) do
        if getgenv().XH_AutoKen then
            pcall(function()
                local char = plr.Character
                if char and not CollectionService:HasTag(char, "Ken") then
                    if CommE then CommE:FireServer("Ken", true) end
                end
            end)
        end
    end
end)

-- ============================================================
-- ANCHOR PART (ZYN tween anchor - anti detection)
-- ============================================================
local C = Instance.new("Part", workspace)
C.Size = Vector3.one
C.Name = "XicoAnchor"
C.Anchored = true
C.CanCollide = false
C.CanTouch = false
C.Transparency = 1

-- Keep anchor at player pos
task.spawn(function()
    repeat task.wait() until plr.Character and plr.Character.PrimaryPart
    C.CFrame = plr.Character.PrimaryPart.CFrame
    while task.wait() do
        pcall(function()
            if getgenv().shouldTween then
                local e = plr.Character and plr.Character.PrimaryPart
                if e then
                    if (e.Position - C.Position).Magnitude <= 200 then
                        e.CFrame = C.CFrame
                    else
                        C.CFrame = e.CFrame
                    end
                end
                -- Disable collisions while tweening
                if plr.Character then
                    for _, v in pairs(plr.Character:GetDescendants()) do
                        if v:IsA("BasePart") then v.CanCollide = false end
                    end
                end
            else
                if plr.Character then
                    for _, v in pairs(plr.Character:GetDescendants()) do
                        if v:IsA("BasePart") then v.CanCollide = true end
                    end
                end
            end
        end)
    end
end)

-- ============================================================
-- TWEEN ENGINE (ZYN bypass tween, dual-speed)
-- ============================================================
-- Far speed 300, near speed 900; uses invisible anchor part C
getgenv().TweenSpeedFar  = 300
getgenv().TweenSpeedNear = 900

local function _tp(targetCFrame)
    local char = plr.Character
    if not char then return end
    local HRP = char:FindFirstChild("HumanoidRootPart")
    if not HRP then return end

    getgenv().shouldTween = true

    -- BodyVelocity anti-fall
    local bv = HRP:FindFirstChild("BodyClip") or Instance.new("BodyVelocity")
    bv.Name = "BodyClip"
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.Velocity = Vector3.zero
    bv.Parent = HRP

    local dist = (targetCFrame.Position - C.Position).Magnitude
    local speed = dist <= 90 and getgenv().TweenSpeedNear or getgenv().TweenSpeedFar
    local info  = TweenInfo.new(dist / speed, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(C, info, { CFrame = targetCFrame })
    tween:Play()

    task.spawn(function()
        while tween.PlaybackState == Enum.PlaybackState.Playing do
            if not getgenv().shouldTween then tween:Cancel() break end
            task.wait(0.1)
        end
        if bv and bv.Parent then bv:Destroy() end
        getgenv().shouldTween = false
    end)
end

local function notween(cf)
    pcall(function() plr.Character.HumanoidRootPart.CFrame = cf end)
end

-- ============================================================
-- WEAPON HELPERS (ZYN Source)
-- ============================================================
local function EquipWeapon(name)
    if not name then return end
    local bp = plr.Backpack:FindFirstChild(name)
    if bp then
        pcall(function() plr.Character.Humanoid:EquipTool(bp) end)
    end
end

local function weaponSc(tipType)
    for _, K in pairs(plr.Backpack:GetChildren()) do
        if K:IsA("Tool") and K.ToolTip == tipType then
            EquipWeapon(K.Name)
        end
    end
end

local function GetFruitTool()
    local char = plr.Character
    if char then
        for _, v in ipairs(char:GetChildren()) do
            if v:IsA("Tool") and v.ToolTip == "Blox Fruit" then return v end
        end
    end
    for _, v in ipairs(plr.Backpack:GetChildren()) do
        if v:IsA("Tool") and v.ToolTip == "Blox Fruit" then return v end
    end
end

local function GetBP(name)
    return plr.Backpack:FindFirstChild(name) or (plr.Character and plr.Character:FindFirstChild(name))
end

local function GetM(matName)
    local ok, inv = pcall(function() return CommF_:InvokeServer("getInventory") end)
    if not ok or not inv then return 0 end
    for _, K in pairs(inv) do
        if type(K) == "table" and K.Type == "Material" and K.Name == matName then
            return K.Count or 0
        end
    end
    return 0
end

local function GetWP(swordName)
    local ok, inv = pcall(function() return CommF_:InvokeServer("getInventory") end)
    if not ok or not inv then return false end
    for _, K in pairs(inv) do
        if type(K) == "table" and K.Type == "Sword" and K.Name == swordName then return true end
    end
    return false
end

-- ============================================================
-- ENEMY FINDER
-- ============================================================
local function IsAlive(model)
    local h = model:FindFirstChild("Humanoid")
    return h and h.Health > 0
end

local function GetConnectionEnemies(nameOrTable)
    local function check(name, target)
        if type(nameOrTable) == "table" then return table.find(nameOrTable, name)
        else return name == nameOrTable end
    end
    for _, K in pairs(workspace.Enemies:GetChildren()) do
        if K:IsA("Model") and check(K.Name, K.Name) and IsAlive(K) then return K end
    end
    for _, K in pairs(ReplicatedStorage:GetChildren()) do
        if K:IsA("Model") and check(K.Name, K.Name) and IsAlive(K) then return K end
    end
    return nil
end

-- ============================================================
-- COMBAT ENGINE (Melee / Sword / Fruit Aura - ZYN + Koby M1)
-- ============================================================
local RegAttack, RegHit
pcall(function()
    local net = ReplicatedStorage:WaitForChild("Modules", 5):WaitForChild("Net", 5)
    RegAttack = net:WaitForChild("RE/RegisterAttack", 5)
    RegHit    = net:WaitForChild("RE/RegisterHit", 5)
end)

local AURA_RANGE = 10000
local HITS_PER_FRAME = 3
local FRUIT_SPAM = 8

local function GetAuraTargets()
    local HRP = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if not HRP then return {} end
    local list = {}
    local function Scan(folder)
        if not folder then return end
        for _, v in ipairs(folder:GetChildren()) do
            if v ~= plr.Character and v:FindFirstChild("HumanoidRootPart") and IsAlive(v) then
                if (HRP.Position - v.HumanoidRootPart.Position).Magnitude <= AURA_RANGE then
                    table.insert(list, v)
                end
            end
        end
    end
    pcall(function() Scan(workspace:FindFirstChild("Enemies")) end)
    pcall(function() Scan(workspace:FindFirstChild("Characters")) end)
    return list
end

-- M1 Network fire (zero animation - InvokeServer bypass)
local function FireMeleeM1()
    pcall(function() CF("Click", "Melee") end)
    pcall(function() if RegAttack then RegAttack:FireServer(0) end end)
end
local function FireSwordM1()
    pcall(function() CF("Click", "Sword") end)
    pcall(function() if RegAttack then RegAttack:FireServer(0) end end)
end

local function FireRegHit(targets)
    if not RegHit then return end
    for _, v in ipairs(targets) do
        if v:FindFirstChild("HumanoidRootPart") then
            for _ = 1, HITS_PER_FRAME do
                pcall(function()
                    RegHit:FireServer(v.HumanoidRootPart, { {v, v.HumanoidRootPart} })
                end)
            end
        end
    end
end

local function FireFruitM1(targets)
    local HRP = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if not HRP then return end
    local fruit = GetFruitTool()
    if not fruit then return end

    -- Auto-equip
    if fruit.Parent == plr.Backpack then
        pcall(function()
            if plr.Character then fruit.Parent = plr.Character end
        end)
        task.wait(0.05)
    end

    local remote = fruit:FindFirstChild("LeftClickRemote")
    if not remote then return end

    local target = targets[1]
    if not target or not target:FindFirstChild("HumanoidRootPart") then return end
    local dir = (target.HumanoidRootPart.Position - HRP.Position).Unit
    for _ = 1, FRUIT_SPAM do
        pcall(function() remote:FireServer(dir, 1) end)
    end
end

-- HEARTBEAT AURA LOOP (always-on)
RunService.Heartbeat:Connect(function()
    local targets = GetAuraTargets()
    if #targets == 0 then return end

    if getgenv().XH_MeleeAura then
        weaponSc("Melee")
        FireMeleeM1()
        FireRegHit(targets)
    end

    if getgenv().XH_SwordAura then
        weaponSc("Sword")
        FireSwordM1()
        FireRegHit(targets)
    end

    if getgenv().XH_FruitAura then
        FireFruitM1(targets)
    end
end)

-- ============================================================
-- BOSS KILL HELPER (ZYN G.Kill style with tween)
-- ============================================================
local function KillBoss(boss, flag)
    if not boss or not flag then return end
    local hrp = boss:FindFirstChild("HumanoidRootPart") or boss:FindFirstChild("Torso")
    if not hrp then return end
    _tp(hrp.CFrame * CFrame.new(0, 20, 0))
end

-- ============================================================
-- AUTO FARM BOSS LOOP
-- ============================================================
local BOSS_MAP = {
    Rip_Indra          = {"rip_indra", "Rip_Indra", "rip_indra True Form"},
    Darkbeard          = {"Darkbeard", "Dark Beard"},
    DoughKing          = {"Dough King"},
    CakePrince         = {"Cake Prince"},
    SoulReaper         = {"Soul Reaper"},
    CursedCaptain      = {"Cursed Captain"},
    TyrantOfTheSkies   = {"Tyrant of the Skies", "Tyrant"},
    Elite              = {"Elite Hunter", "Elite Pirate", "Guardian"},
    Fullmoon           = {"Full Moon Beast"},
    NearMoon           = {"Near Moon Beast"},
    KitsuneIsland      = {"Kitsune", "Fox Spirit"},
    PrehistoricIsland  = {"Lava Golem", "Dinosaur"},
    CastleRaid         = {"Order", "Castle Raid Boss"},
    Longma             = {"Longma"},
    Darkbeard          = {"Darkbeard"},
}

local BOSS_SPAWN = {
    Rip_Indra        = CFrame.new(5228, 5, 845),
    Darkbeard        = CFrame.new(-9551, 6, 5796),
    DoughKing        = CFrame.new(-3228, 7, 6098),
    CakePrince       = CFrame.new(-1340, 7, -11662),
    SoulReaper       = CFrame.new(-9524, 315, 6655),
    CursedCaptain    = CFrame.new(916, 181, 33422),
    TyrantOfTheSkies = CFrame.new(-7882, 5444, -366),
    Elite            = CFrame.new(-5750, 105, -4588),
    Longma           = CFrame.new(-10238, 389, -9549),
    CastleRaid       = CFrame.new(-6440, 250, -5250),
    KitsuneIsland    = CFrame.new(4900, 670, 40),
    PrehistoricIsland= CFrame.new(4620, 1002, 399),
}

local function FindBoss(key)
    local names = BOSS_MAP[key]
    if not names then return nil end
    for _, name in ipairs(names) do
        local found = GetConnectionEnemies(name)
        if found then return found end
    end
    -- search workspace directly
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and IsAlive(obj) then
            for _, name in ipairs(names) do
                if string.lower(obj.Name):find(string.lower(name)) then
                    return obj
                end
            end
        end
    end
    return nil
end

task.spawn(function()
    while task.wait(0.3) do
        if getgenv().XH_AutoFarm then
            pcall(function()
                local key = getgenv().XH_SelBoss
                local boss = FindBoss(key)
                if boss then
                    KillBoss(boss, true)
                    -- Fast attack is always on from aura, no need to toggle
                else
                    -- Boss not present: wait at spawn spot
                    local spawn = BOSS_SPAWN[key]
                    if spawn then _tp(spawn) end
                end
            end)
        end
    end
end)

-- ============================================================
-- AUTO COLLECT BERRIES (ZYN Source)
-- ============================================================
task.spawn(function()
    while task.wait(0.15) do
        if getgenv().XH_AutoBerry then
            pcall(function()
                local char = plr.Character
                if not char then return end
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if (obj.Name == "RedCherry" or obj.Name == "BlueIcicle" or
                        obj.Name == "GreenToad" or obj.Name == "OrangeFruit" or
                        string.lower(obj.Name):find("berry")) and obj:IsA("BasePart") then
                        char.HumanoidRootPart.CFrame = obj.CFrame
                        task.wait(0.05)
                    end
                end
                -- Also use workspace collectFruits style
                for _, obj in pairs(workspace:GetChildren()) do
                    if string.find(obj.Name, "Fruit") then
                        pcall(function() obj.Handle.CFrame = char.HumanoidRootPart.CFrame end)
                    end
                end
            end)
        end
    end
end)

-- ============================================================
-- AUTO CYBORG RACE (ZYN Source Port)
-- ============================================================
task.spawn(function()
    while task.wait(0.5) do
        if getgenv().XH_AutoCyborg then
            pcall(function()
                -- Step 1: Check Fist of Darkness
                if not GetBP("Fist of Darkness") then
                    -- Farm chests for Fist of Darkness (Sea Beast drop)
                    local cs = GetConnectionEnemies("Sea Beast") or GetConnectionEnemies("Order")
                    if cs then
                        KillBoss(cs, true)
                    else
                        _tp(CFrame.new(-6440, 250, -5250))
                    end
                else
                    -- Step 2: Buy Law Raid Chip with 1000 Frags
                    local frags = plr.Data and plr.Data.Fragments and plr.Data.Fragments.Value or 0
                    if tonumber(frags) >= 1000 and not GetBP("Microchip") then
                        CF("BuyMicrochip")
                        task.wait(1)
                    end
                    -- Step 3: Kill Order (Law) for Core Brain
                    local order = GetConnectionEnemies("Order")
                    if order then
                        KillBoss(order, true)
                    else
                        _tp(CFrame.new(-6440, 250, -5250))
                    end
                    -- Step 4: Buy Cyborg if Core Brain in backpack
                    if GetBP("Core Brain") then
                        CF("BuyCyborg")
                        getgenv().XH_AutoCyborg = false
                    end
                end
            end)
        end
    end
end)

-- ============================================================
-- AUTO GHOUL RACE (ZYN Source Port - Ectoplasm logic)
-- ============================================================
task.spawn(function()
    while task.wait(0.5) do
        if getgenv().XH_AutoGhoul then
            pcall(function()
                local ecto = GetM("Ectoplasm")
                if tonumber(ecto) < 99 then
                    -- Farm Cursed Captain for Ectoplasm
                    local captain = GetConnectionEnemies("Cursed Captain")
                    if captain then
                        KillBoss(captain, true)
                    else
                        -- Request ship entrance
                        CF("requestEntrance", Vector3.new(923.21252441406, 126.9760055542, 32852.83203125))
                        task.wait(0.5)
                        _tp(CFrame.new(916.928589, 181.092773, 33422))
                    end
                else
                    -- Has 99+ ecto - buy Ghoul race
                    -- Also check for Hellfire Torch (Midnight Blade route)
                    CF("Ectoplasm", "Buy", 3)
                    task.wait(1)
                    getgenv().XH_AutoGhoul = false
                end
            end)
        end
    end
end)

-- ============================================================
-- AUTO TUSHITA (ZYN/Kaitun Source Port)
-- ============================================================
-- Torch positions (Sea 3 Tushita route)
local TORCH_POSITIONS = {
    CFrame.new(5563.42, 5.18, -1249.7),   -- Torch 1
    CFrame.new(6200, 5, -1800),            -- Torch 2
    CFrame.new(5800, 5, -2200),            -- Torch 3
    CFrame.new(5400, 5, -2600),            -- Torch 4
    CFrame.new(5000, 5, -3000),            -- Torch 5 (Approximate)
}

task.spawn(function()
    while task.wait(0.5) do
        if getgenv().XH_AutoTushita then
            pcall(function()
                -- Check Rip Indra alive
                local indra = FindBoss("Rip_Indra")
                if not indra then
                    -- Go to Hydra Waterfall secret room
                    _tp(CFrame.new(5228, 5, 845))
                    task.wait(1.5)
                    -- Enter portal
                    _tp(CFrame.new(5228, 5, 950))
                    task.wait(1)
                    -- Light torches
                    for i, tPos in ipairs(TORCH_POSITIONS) do
                        _tp(tPos)
                        task.wait(0.8)
                        CF("LightBrazier", i)
                    end
                    -- Kill Longma
                    local longma = GetConnectionEnemies("Longma")
                    if longma then
                        KillBoss(longma, true)
                    else
                        _tp(CFrame.new(-10238, 389, -9549))
                    end
                    -- Collect Tushita if in backpack
                    if GetBP("Tushita") then
                        getgenv().XH_AutoTushita = false
                    end
                else
                    -- Indra alive, wait
                    task.wait(5)
                end
            end)
        end
    end
end)

-- ============================================================
-- AUTO LEGENDARY SWORD BUYER (ZYN Source)
-- ============================================================
-- Sea 3 legendary sword dealer logic
task.spawn(function()
    while task.wait(0.5) do
        if getgenv().XH_AutoLegendSword then
            pcall(function()
                -- Tp to legendary sword dealer NPC
                for _, npc in pairs(ReplicatedStorage:WaitForChild("NPCs", 3):GetChildren()) do
                    if npc.Name == "Legendary Sword Dealer" and npc:FindFirstChild("HumanoidRootPart") then
                        _tp(npc.HumanoidRootPart.CFrame)
                        task.wait(0.5)
                        CF("BuyItem", "True Triple Katana")
                        task.wait(0.3)
                        CF("BuyItem", "Shisui")
                        task.wait(0.3)
                        CF("BuyItem", "Saddi")
                        task.wait(0.3)
                        CF("BuyItem", "Wando")
                    end
                end
                -- Also try direct position (Sea 3 Legendary Sword)
                _tp(CFrame.new(-3228, 7, 6098))
                task.wait(0.5)
                CF("StartQuest", "LegendaryQuest", 1)
            end)
        end
    end
end)

-- ============================================================
-- SERVER HOP ENGINE
-- ============================================================
local API_ENDPOINTS = {
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

-- Cache: Key → { label → jobId }
local ServerCache = {}
local SelectedServer = {}

local function FetchServers(event)
    -- Cache buster (req #14 + #15)
    local url = event.URL .. "?v=" .. tostring(os.time())
    local ok, res = pcall(function() return game:HttpGet(url) end)
    if not ok or not res or res == "" or res == "[]" then return nil end

    local ok2, data = pcall(function() return HttpService:JSONDecode(res) end)
    if not ok2 or type(data) ~= "table" then return nil end

    -- Filter: same PlaceId, skip self (anti-self-join #18)
    local filtered = {}
    for _, srv in ipairs(data) do
        local pId = tostring(srv.PlaceId or "")
        local jId = tostring(srv.JobId or "")
        if pId == tostring(PlaceId) and jId ~= CurrentJobId then
            table.insert(filtered, srv)
        end
    end

    -- Sort by Age ascending (freshest boss first)
    table.sort(filtered, function(a, b)
        return tonumber(a.Age or 0) < tonumber(b.Age or 0)
    end)

    return filtered
end

-- Spawn-verification: check if boss humanoid is alive in that server
-- (We can only do this by checking the label data from API; Age ≈ 0 means freshly spawned)
local function BossAliveCheck(srv)
    -- Age 0-60s = likely alive; players > 0 = active server
    local age = tonumber(srv.Age or 999)
    local players = tonumber(srv.Players or 0)
    return age <= 120 and players < 12
end

local function TeleportToJobId(jobId, notifFn)
    task.wait(1) -- Anti-kick delay (#6)
    local ok, err = pcall(function()
        TeleportService:TeleportToPlaceInstance(PlaceId, jobId, plr)
    end)
    if not ok then
        if notifFn then notifFn("Teleport Error: " .. tostring(err)) end
    end
end

-- Persistent re-execution after teleport (#17)
local SCRIPT_URL = "https://raw.githubusercontent.com/XicoSkelly/XicoHub/main/XicoHub_Ultimate.lua"
pcall(function()
    if queue_on_teleport then
        queue_on_teleport(game:HttpGet(SCRIPT_URL))
    end
end)

-- ============================================================
-- FLUENT UI LOAD (40% scale = 232x152; min usable is ~280x190)
-- ============================================================
local Fluent = loadstring(game:HttpGet(
    "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"
))()

local Window = Fluent:CreateWindow({
    Title       = "Xico Hub | Hop",
    SubTitle    = "made by @alifgamer",
    TabWidth    = 120,
    Size        = UDim2.fromOffset(280, 190),  -- ~40% of 580×380
    Acrylic     = false,
    Theme       = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl,
})

-- ============================================================
-- FARMING TAB
-- ============================================================
local FarmTab = Window:AddTab({ Title = "Farm", Icon = "sword" })

FarmTab:AddSection("Aura (Auto-ON)")

local meleeToggle = FarmTab:AddToggle("MeleeAura", {
    Title   = "Melee Aura",
    Default = true,
    Callback = function(v) getgenv().XH_MeleeAura = v end
})
local swordToggle = FarmTab:AddToggle("SwordAura", {
    Title   = "Sword Aura",
    Default = true,
    Callback = function(v) getgenv().XH_SwordAura = v end
})
local fruitToggle = FarmTab:AddToggle("FruitAura", {
    Title   = "Fruit Aura (M1)",
    Default = true,
    Callback = function(v) getgenv().XH_FruitAura = v end
})

FarmTab:AddSection("Boss Farm")

local BOSS_DISPLAY = {
    "Rip Indra", "Darkbeard", "Dough King", "Cake Prince",
    "Soul Reaper", "Cursed Captain", "Tyrant Of The Skies",
    "Elite", "Longma", "Castle Raid", "Kitsune Island",
    "Prehistoric Island",
}
local BOSS_KEY_MAP = {
    ["Rip Indra"] = "Rip_Indra", ["Darkbeard"] = "Darkbeard",
    ["Dough King"] = "DoughKing", ["Cake Prince"] = "CakePrince",
    ["Soul Reaper"] = "SoulReaper", ["Cursed Captain"] = "CursedCaptain",
    ["Tyrant Of The Skies"] = "TyrantOfTheSkies", ["Elite"] = "Elite",
    ["Longma"] = "Longma", ["Castle Raid"] = "CastleRaid",
    ["Kitsune Island"] = "KitsuneIsland", ["Prehistoric Island"] = "PrehistoricIsland",
}

local bossDropdown = FarmTab:AddDropdown("BossDrop", {
    Title  = "Select Boss",
    Values = BOSS_DISPLAY,
    Default = 1,
    Callback = function(v)
        getgenv().XH_SelBoss = BOSS_KEY_MAP[v] or "Rip_Indra"
    end
})

-- Farm Boss button (standalone, under dropdown as per spec)
FarmTab:AddButton({
    Title       = "▶ Farm Boss",
    Description = "Toggle auto farm selected boss",
    Callback    = function()
        getgenv().XH_AutoFarm = not getgenv().XH_AutoFarm
        local state = getgenv().XH_AutoFarm and "ON" or "OFF"
        Fluent:Notify({ Title = "Auto Farm", Content = "Boss Farm: " .. state, Duration = 2 })
    end
})

FarmTab:AddSection("Utilities")

FarmTab:AddToggle("AutoBerry", {
    Title   = "Auto Collect Berries",
    Default = false,
    Callback = function(v) getgenv().XH_AutoBerry = v end
})
FarmTab:AddToggle("AutoKen", {
    Title   = "Auto Observation Haki",
    Default = true,
    Callback = function(v) getgenv().XH_AutoKen = v end
})
FarmTab:AddToggle("AutoLegendSword", {
    Title   = "Auto Buy Legendary Sword",
    Default = false,
    Callback = function(v) getgenv().XH_AutoLegendSword = v end
})

-- ============================================================
-- RACE TAB (Cyborg & Ghoul)
-- ============================================================
local RaceTab = Window:AddTab({ Title = "Race", Icon = "user" })

RaceTab:AddSection("Cyborg Race")
RaceTab:AddToggle("AutoCyborg", {
    Title   = "Auto Cyborg",
    Description = "Farm Fist → Law Raid → Core Brain → Buy",
    Default = false,
    Callback = function(v) getgenv().XH_AutoCyborg = v end
})

RaceTab:AddSection("Ghoul Race")
RaceTab:AddToggle("AutoGhoul", {
    Title   = "Auto Ghoul",
    Description = "Farm 99 Ectoplasm → Buy Race",
    Default = false,
    Callback = function(v) getgenv().XH_AutoGhoul = v end
})

RaceTab:AddSection("Tushita Sword")
RaceTab:AddToggle("AutoTushita", {
    Title   = "Auto Tushita",
    Description = "Indra check → Torches → Longma",
    Default = false,
    Callback = function(v) getgenv().XH_AutoTushita = v end
})

-- ============================================================
-- SERVER HOP TABS (one per event)
-- ============================================================
local tabObjects    = {}
local dropdownRefs  = {}

for _, ev in ipairs(API_ENDPOINTS) do
    local tab = Window:AddTab({ Title = ev.Name, Icon = "globe" })
    tabObjects[ev.Key] = tab
    ServerCache[ev.Key] = {}
    SelectedServer[ev.Key] = nil

    tab:AddSection(ev.Name .. " — Live Servers")

    -- Server dropdown (populated on refresh)
    local srvDrop = tab:AddDropdown("D_" .. ev.Key, {
        Title  = "Servers",
        Values = { "[ Click Refresh ]" },
        Default = 1,
        Callback = function(v)
            SelectedServer[ev.Key] = v
        end
    })
    dropdownRefs[ev.Key] = srvDrop

    -- Refresh
    tab:AddButton({
        Title       = "🔄 Refresh",
        Description = "Fetch live servers (cache-busted)",
        Callback    = function()
            Fluent:Notify({ Title = "Fetching", Content = ev.Name, Duration = 1 })
            task.spawn(function()
                local servers = FetchServers(ev)
                if not servers or #servers == 0 then
                    srvDrop:SetValues({ "[ No Servers Found ]" })
                    srvDrop:SetValue("[ No Servers Found ]")
                    ServerCache[ev.Key] = {}
                    Fluent:Notify({ Title = "Empty", Content = "No servers for " .. ev.Name, Duration = 3 })
                    return
                end
                local labels = {}
                local map    = {}
                for _, srv in ipairs(servers) do
                    local alive = BossAliveCheck(srv) and "✅" or "❓"
                    local label = string.format(
                        "%s Age:%ss | %s/12",
                        alive,
                        tostring(srv.Age or "?"),
                        tostring(srv.Players or "?")
                    )
                    table.insert(labels, label)
                    map[label] = tostring(srv.JobId)
                end
                ServerCache[ev.Key] = map
                srvDrop:SetValues(labels)
                srvDrop:SetValue(labels[1])
                SelectedServer[ev.Key] = labels[1]
                Fluent:Notify({
                    Title   = "Ready",
                    Content = #labels .. " servers loaded for " .. ev.Name,
                    Duration = 3
                })
            end)
        end
    })

    -- Join: with server-full handling (#19)
    tab:AddButton({
        Title       = "🚀 Join Server",
        Description = "Teleport using JobId",
        Callback    = function()
            local sel = SelectedServer[ev.Key]
            local map = ServerCache[ev.Key]
            if not sel or not map or not map[sel] then
                Fluent:Notify({ Title = "Error", Content = "Refresh and select a server first!", Duration = 2 })
                return
            end
            local jobId = map[sel]
            -- Anti-self-join check
            if jobId == CurrentJobId then
                Fluent:Notify({ Title = "Skip", Content = "Already in this server!", Duration = 2 })
                return
            end
            Fluent:Notify({ Title = "Teleporting", Content = "Joining " .. ev.Name .. "...", Duration = 4 })
            TeleportToJobId(jobId, function(msg)
                Fluent:Notify({ Title = "Error", Content = msg, Duration = 3 })
            end)
        end
    })

    -- Auto-hop: keep trying servers until boss found (#4 spawn verification)
    tab:AddButton({
        Title       = "🔁 Auto Hop (Boss Alive)",
        Description = "Hop servers until boss is verified alive",
        Callback    = function()
            task.spawn(function()
                local servers = FetchServers(ev)
                if not servers or #servers == 0 then
                    Fluent:Notify({ Title = "None", Content = "No servers for " .. ev.Name, Duration = 3 })
                    return
                end
                for _, srv in ipairs(servers) do
                    if BossAliveCheck(srv) then
                        local jobId = tostring(srv.JobId)
                        if jobId ~= CurrentJobId then
                            Fluent:Notify({
                                Title   = "Hopping → " .. ev.Name,
                                Content = "Age: " .. tostring(srv.Age) .. "s | Players: " .. tostring(srv.Players),
                                Duration = 4
                            })
                            TeleportToJobId(jobId)
                            return
                        end
                    end
                end
                Fluent:Notify({ Title = "No Live Servers", Content = "Boss not alive in any server.", Duration = 3 })
            end)
        end
    })
end

-- Select first tab
Window:SelectTab(1)

-- ============================================================
-- ADAPTIVE FLOATING TOGGLE BUTTON
-- Asset: rbxassetid://84090982489875 (as specified)
-- Cyan color, draggable, click = minimize/maximize
-- ============================================================
pcall(function()
    local old = CoreGui:FindFirstChild("XicoToggleGui")
    if old then old:Destroy() end
end)

local ToggleGui = Instance.new("ScreenGui")
ToggleGui.Name           = "XicoToggleGui"
ToggleGui.ResetOnSpawn   = false
ToggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ToggleGui.IgnoreGuiInset = true
ToggleGui.Parent         = CoreGui

-- Image button (specified asset)
local ToggleBtn = Instance.new("ImageButton")
ToggleBtn.Name              = "XicoToggle"
ToggleBtn.Size              = UDim2.fromOffset(52, 52)
ToggleBtn.Position          = UDim2.new(0, 6, 0.42, 0)
ToggleBtn.BackgroundColor3  = Color3.fromRGB(0, 210, 230)
ToggleBtn.Image             = "rbxassetid://84090982489875"
ToggleBtn.ImageColor3       = Color3.fromRGB(0, 255, 255)
ToggleBtn.ScaleType         = Enum.ScaleType.Fit
ToggleBtn.ZIndex            = 20
ToggleBtn.Active            = true
ToggleBtn.Parent            = ToggleGui

local tbCorner = Instance.new("UICorner")
tbCorner.CornerRadius = UDim.new(0, 14)
tbCorner.Parent = ToggleBtn

local tbStroke = Instance.new("UIStroke")
tbStroke.Color     = Color3.fromRGB(0, 255, 255)
tbStroke.Thickness = 2.5
tbStroke.Parent    = ToggleBtn

-- Drag logic (mobile + PC)
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

local wasDragging = false
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        wasDragging = dragging and
            (input.Position - (dragStart or input.Position)).Magnitude > 6
        dragging = false
    end
end)

-- Toggle minimize/maximize Fluent via RightControl key event
ToggleBtn.MouseButton1Click:Connect(function()
    if wasDragging then wasDragging = false return end
    VirtualInputManager:SendKeyEvent(true,  Enum.KeyCode.RightControl, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.RightControl, false, game)
end)

-- ============================================================
-- LOAD COMPLETE NOTIFICATION
-- ============================================================
Fluent:Notify({
    Title   = "Xico Hub V6 — Loaded",
    Content = "Aura ON | Use cyan icon to toggle UI | Press RCtrl",
    Duration = 6
})

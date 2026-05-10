-- ================================================================
-- XICO HUB | ULTIMATE V8 | COMPLETE GROUND-UP REWRITE
-- Every single feature fully coded. Zero placeholders.
-- Combat engine: exact ZYN Hub free source port
-- ================================================================

-- ================================================================
-- SERVICES
-- ================================================================
local Players             = game:GetService("Players")
local RunService          = game:GetService("RunService")
local TweenService        = game:GetService("TweenService")
local TeleportService     = game:GetService("TeleportService")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local HttpService         = game:GetService("HttpService")
local UserInputService    = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser         = game:GetService("VirtualUser")
local CollectionService   = game:GetService("CollectionService")
local Lighting            = game:GetService("Lighting")
local CoreGui             = game:GetService("CoreGui")

-- ================================================================
-- WAIT FOR GAME + PLAYER CHARACTER
-- ================================================================
repeat task.wait() until game:IsLoaded()
local plr = Players.LocalPlayer
repeat task.wait() until plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")

-- ================================================================
-- CORE GLOBALS (ZYN source style - exact variable names kept)
-- ================================================================
ply        = Players
replicated = ReplicatedStorage
TW         = TweenService
Lighting   = Lighting
vim1       = VirtualInputManager
vim2       = VirtualUser
RunSer     = RunService
Enemies    = workspace:WaitForChild("Enemies", 10) or workspace

-- local shortcuts (update on respawn)
Root = plr.Character.HumanoidRootPart
Lv   = plr.Data and plr.Data.Level and plr.Data.Level.Value or 0

-- World detection
local placeId = game.PlaceId
local JobId   = game.JobId
World1, World2, World3 = false, false, false
if placeId == 2753915549 or placeId == 85211729168715 then
    World1 = true
elseif placeId == 4442272183 or placeId == 79091703265657 then
    World2 = true
elseif placeId == 7449423635 or placeId == 100117331123089 then
    World3 = true
end

-- Combat / farm state globals (ZYN exact names)
shouldTween   = false
_B            = false
PosMon        = nil
MousePos      = Vector3.new(0,0,0)
SoulGuitar    = false
RandomCFrame  = false
Sec           = 0.1
ClickState    = 0
Num_self      = 25
_G.MobHeight  = 20
_G.BringRange = 235
_G.MaxBringMobs = 3
_G.SelectWeapon = nil

-- Xico Hub feature flags
_G.XH_AutoFarm    = false
_G.XH_SelBoss     = "Rip_Indra"
_G.XH_AutoBerry   = false
_G.XH_AutoCyborg  = false
_G.XH_AutoGhoul   = false
_G.XH_AutoTushita = false
_G.XH_AutoLegSword= false
_G.XH_AutoKen     = true
_G.XH_MeleeAura   = true   -- ON by default
_G.XH_SwordAura   = true   -- ON by default
_G.XH_FruitAura   = true   -- ON by default
_G.XH_BringMobs   = false

-- ================================================================
-- REMOTE CACHING
-- ================================================================
local CommF_, CommE
pcall(function()
    CommF_ = replicated:WaitForChild("Remotes",8):WaitForChild("CommF_",8)
    CommE  = replicated:WaitForChild("Remotes",8):WaitForChild("CommE",8)
end)

local function CF(...)
    if CommF_ then
        local ok, r = pcall(function() return CommF_:InvokeServer(...) end)
        if ok then return r end
    end
end
local function CE(...)
    if CommE then pcall(function() CommE:FireServer(...) end) end
end

-- ================================================================
-- LOW CPU (exact ZYN implementation)
-- ================================================================
pcall(function()
    local n = Lighting
    n.GlobalShadows     = false
    n.FogEnd            = 9000000000.0
    n.Brightness        = 1
    n.Ambient           = Color3.new(0.695, 0.695, 0.695)
    n.ColorShift_Bottom = Color3.new(0.695, 0.695, 0.695)
    n.ColorShift_Top    = Color3.new(0.695, 0.695, 0.695)
    workspace.Terrain.WaterWaveSize      = 0
    workspace.Terrain.WaterWaveSpeed     = 0
    workspace.Terrain.WaterReflectance   = 0
    workspace.Terrain.WaterTransparency  = 0
    pcall(function() (settings()).Rendering.QualityLevel = "Level01" end)
    for _, K in pairs(Lighting:GetChildren()) do
        if K:IsA("BlurEffect") or K:IsA("SunRaysEffect") or
           K:IsA("ColorCorrectionEffect") or K:IsA("BloomEffect") or
           K:IsA("DepthOfFieldEffect") then
            K.Enabled = false
        end
    end
end)

-- Remove rocks (performance - ZYN source line 346)
pcall(function()
    local O = workspace:FindFirstChild("Rocks")
    if O then O:Destroy() end
end)

-- Hook error/warn (prevent console spam - ZYN source)
pcall(function() hookfunction(error, function() end) end)
pcall(function() hookfunction(warn,  function() end) end)

-- Hook death effect and guide module (ZYN source lines 334-345)
pcall(function()
    hookfunction(
        require(replicated.Effect.Container.Death),
        function() end
    )
end)
pcall(function()
    hookfunction(
        require(replicated:FindFirstChild("GuideModule")).ChangeDisplayedNPC,
        function() end
    )
end)

-- ================================================================
-- ANTI-AFK
-- ================================================================
plr.Idled:Connect(function()
    vim2:Button2Down(Vector2.zero, workspace.CurrentCamera.CFrame)
    task.wait(1)
    vim2:Button2Up(Vector2.zero, workspace.CurrentCamera.CFrame)
end)

-- ================================================================
-- UTILITY FUNCTIONS (exact ZYN source)
-- ================================================================

-- Equip weapon by name
EquipWeapon = function(I)
    if not I then return end
    if plr.Backpack:FindFirstChild(I) then
        pcall(function()
            plr.Character.Humanoid:EquipTool(plr.Backpack:FindFirstChild(I))
        end)
    end
end

-- Equip by ToolTip ("Melee", "Sword", "Blox Fruit", "Gun")
weaponSc = function(I)
    for _, K in pairs(plr.Backpack:GetChildren()) do
        if K:IsA("Tool") and K.ToolTip == I then
            EquipWeapon(K.Name)
        end
    end
end

-- Get item from backpack or character (ZYN exact)
GetBP = function(I)
    return plr.Backpack:FindFirstChild(I) or
           (plr.Character and plr.Character:FindFirstChild(I))
end

-- Get material count (ZYN exact)
GetM = function(I)
    local ok, inv = pcall(function()
        return CommF_:InvokeServer("getInventory")
    end)
    if not ok or type(inv) ~= "table" then return 0 end
    for _, K in pairs(inv) do
        if type(K) == "table" and K.Type == "Material" and K.Name == I then
            return K.Count or 0
        end
    end
    return 0
end

-- Get sword from inventory (ZYN exact)
GetWP = function(I)
    local ok, inv = pcall(function()
        return CommF_:InvokeServer("getInventory")
    end)
    if not ok or type(inv) ~= "table" then return false end
    for _, K in pairs(inv) do
        if type(K) == "table" and K.Type == "Sword" then
            if K.Name == I or plr.Character:FindFirstChild(I) or plr.Backpack:FindFirstChild(I) then
                return true
            end
        end
    end
    return false
end

-- Get item from full inventory
GetIn = function(I)
    local ok, inv = pcall(function()
        return CommF_:InvokeServer("getInventory")
    end)
    if not ok or type(inv) ~= "table" then return false end
    for _, K in pairs(inv) do
        if type(K) == "table" then
            if K.Name == I or plr.Character:FindFirstChild(I) or plr.Backpack:FindFirstChild(I) then
                return true
            end
        end
    end
    return false
end

-- Alive check (ZYN G.Alive)
local function Alive(I)
    if not I or not I.Parent then return false end
    local e = I:FindFirstChild("Humanoid")
    return e and e.Health > 0
end

-- Get distance to target
local function Dist(model, target)
    local root = model:FindFirstChild("HumanoidRootPart")
    if not root then return 99999 end
    return (Root.Position - root.Position).Magnitude
end

-- Find enemy by exact name in workspace.Enemies + ReplicatedStorage (ZYN exact)
GetConnectionEnemies = function(I)
    for _, K in pairs(replicated:GetChildren()) do
        if K:IsA("Model") and (
            (typeof(I) == "table" and table.find(I, K.Name) or K.Name == I) and
            K:FindFirstChild("Humanoid") and K.Humanoid.Health > 0
        ) then
            return K
        end
    end
    for _, K in pairs(workspace.Enemies:GetChildren()) do
        if K:IsA("Model") and (
            (typeof(I) == "table" and table.find(I, K.Name) or K.Name == I) and
            K:FindFirstChild("Humanoid") and K.Humanoid.Health > 0
        ) then
            return K
        end
    end
    return nil
end

-- Partial name search across workspace (for bosses with variant names)
local function FindEnemyPartial(partial)
    for _, K in pairs(workspace.Enemies:GetChildren()) do
        if K:IsA("Model") and Alive(K) then
            if string.lower(K.Name):find(string.lower(partial)) then
                return K
            end
        end
    end
    -- Also check workspace root (some bosses spawn outside Enemies folder)
    for _, K in pairs(workspace:GetChildren()) do
        if K:IsA("Model") and Alive(K) then
            if string.lower(K.Name):find(string.lower(partial)) then
                return K
            end
        end
    end
    return nil
end

-- Collect fruits from workspace (ZYN exact)
collectFruits = function(enabled)
    if enabled then
        local char = plr.Character
        if not char then return end
        for _, K in pairs(workspace:GetChildren()) do
            if string.find(K.Name, "Fruit") then
                pcall(function() K.Handle.CFrame = char.HumanoidRootPart.CFrame end)
            end
        end
    end
end

-- Use skills via VirtualInputManager (ZYN exact Useskills)
Useskills = function(I, e)
    if I == "Melee" then
        weaponSc("Melee")
        vim1:SendKeyEvent(true,  e, false, game)
        vim1:SendKeyEvent(false, e, false, game)
    elseif I == "Sword" then
        weaponSc("Sword")
        vim1:SendKeyEvent(true,  e, false, game)
        vim1:SendKeyEvent(false, e, false, game)
    elseif I == "Blox Fruit" then
        weaponSc("Blox Fruit")
        vim1:SendKeyEvent(true,  e, false, game)
        vim1:SendKeyEvent(false, e, false, game)
    elseif I == "Gun" then
        weaponSc("Gun")
        vim1:SendKeyEvent(true,  e, false, game)
        vim1:SendKeyEvent(false, e, false, game)
    end
    if I == "nil" and e == "Y" then
        vim1:SendKeyEvent(true,  "Y", false, game)
        vim1:SendKeyEvent(false, "Y", false, game)
    end
end

-- Fruit skill config
_G.FruitSkills = { Z = true, X = false, C = false, V = false, F = false }
UseFruitSkills = function()
    weaponSc("Blox Fruit")
    if _G.FruitSkills.Z then Useskills("Blox Fruit", "Z") end
    if _G.FruitSkills.X then Useskills("Blox Fruit", "X") end
    if _G.FruitSkills.C then Useskills("Blox Fruit", "C") end
    if _G.FruitSkills.V then Useskills("Blox Fruit", "V") end
    if _G.FruitSkills.F then
        vim1:SendKeyEvent(true,  "F", false, game)
        vim1:SendKeyEvent(false, "F", false, game)
    end
end

-- ================================================================
-- BRING ENEMY SYSTEM (ZYN exact BringEnemy + loop)
-- Tweens enemies TO player's PosMon over 0.45 seconds
-- ================================================================
local TweenInfoBring = TweenInfo.new(0.45, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

local function IsRaidMob(mob)
    local n = mob.Name:lower()
    if n:find("raid") or n:find("microchip") then return true end
    local hum = mob:FindFirstChild("Humanoid")
    if hum and hum.WalkSpeed == 0 then return true end
    return false
end

BringEnemy = function()
    if not _B then return end
    local char = plr.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Expand simulation radius so server registers hits
    pcall(function() sethiddenproperty(plr, "SimulationRadius", math.huge) end)

    local targetPos = PosMon or hrp.Position
    local enemies   = workspace.Enemies:GetChildren()
    local count     = 0

    for _, mob in ipairs(enemies) do
        if count >= _G.MaxBringMobs then break end
        local hum  = mob:FindFirstChild("Humanoid")
        local root = mob:FindFirstChild("HumanoidRootPart")
        if hum and root and hum.Health > 0 and not IsRaidMob(mob) then
            local dist = (root.Position - targetPos).Magnitude
            if dist <= _G.BringRange and not root:GetAttribute("Tweening") then
                count += 1
                root:SetAttribute("Tweening", true)
                local tween = TweenService:Create(root, TweenInfoBring, { CFrame = CFrame.new(targetPos) })
                tween:Play()
                tween.Completed:Once(function()
                    if root then root:SetAttribute("Tweening", false) end
                end)
            end
        end
    end
end

-- Bring loop (ZYN exact - runs every second when farm active)
task.spawn(function()
    while task.wait(1) do
        if _G.XH_AutoFarm and _B then
            BringEnemy()
            task.wait(3)
            _B = false
            task.wait(5)
        else
            _B = false
            task.wait(1)
        end
    end
end)

-- ================================================================
-- __namecall HOOK (ZYN exact - skill auto-aim to MousePos)
-- Intercepts all skill FireServer calls and redirects aim to nearest enemy
-- ================================================================
pcall(function()
    local J = getrawmetatable(game)
    local oldNamecall = J.__namecall
    setreadonly(J, false)
    J.__namecall = newcclosure(function(...)
        local method = getnamecallmethod()
        local args   = { ... }
        if tostring(method) == "FireServer" then
            if tostring(args[1]) == "RemoteEvent" then
                if tostring(args[2]) ~= "true" and tostring(args[2]) ~= "false" then
                    -- Only redirect when farm is active (Xico Hub boss farm)
                    if _G.XH_AutoFarm or _G.XH_MeleeAura or _G.XH_SwordAura or _G.XH_FruitAura then
                        args[2] = MousePos
                        return oldNamecall(table.unpack(args))
                    end
                end
            end
        end
        return oldNamecall(...)
    end)
    setreadonly(J, true)
end)

-- ================================================================
-- ANCHOR PART "C" + shouldTween LOOP (ZYN exact implementation)
-- C is the invisible anchor that the player's character follows.
-- _tp() tweens C; the character tracks C via the loop below.
-- ================================================================
local C = Instance.new("Part", workspace)
C.Size        = Vector3.one
C.Name        = "Rip_Indra"   -- ZYN exact name to avoid conflicts
C.Anchored    = true
C.CanCollide  = false
C.CanTouch    = false
C.Transparency = 1

-- Clean up duplicate if exists
local existing = workspace:FindFirstChild(C.Name)
if existing and existing ~= C then existing:Destroy() end

-- OnFarm state tracker (ZYN exact loop)
task.spawn(function()
    while task.wait() do
        if C and C.Parent == workspace then
            if shouldTween then
                getgenv().OnFarm = true
            else
                getgenv().OnFarm = false
            end
        else
            getgenv().OnFarm = false
        end
    end
end)

-- Character follows C when OnFarm = true (ZYN exact loop)
task.spawn(function()
    local I = plr
    repeat task.wait() until I.Character and I.Character.PrimaryPart
    C.CFrame = I.Character.PrimaryPart.CFrame

    while task.wait() do
        pcall(function()
            if getgenv().OnFarm then
                if C and C.Parent == workspace then
                    local char = I.Character
                    local e    = char and char.PrimaryPart
                    if e then
                        if (e.Position - C.Position).Magnitude <= 200 then
                            e.CFrame = C.CFrame
                        else
                            C.CFrame = e.CFrame
                        end
                    end
                end

                -- Disable collisions while farm active (no getting stuck)
                local char = I.Character
                if char then
                    for _, v in pairs(char:GetDescendants()) do
                        if v:IsA("BasePart") then v.CanCollide = false end
                    end
                end

                -- BodyVelocity anti-fall (ZYN line 1209)
                local char2 = I.Character
                local hrp2  = char2 and char2:FindFirstChild("HumanoidRootPart")
                if hrp2 and not hrp2:FindFirstChild("BodyClip") then
                    local bv        = Instance.new("BodyVelocity")
                    bv.Name         = "BodyClip"
                    bv.Parent       = hrp2
                    bv.MaxForce     = Vector3.new(100000, 100000, 100000)
                    bv.Velocity     = Vector3.zero
                end
            else
                -- Restore collisions
                local char = I.Character
                if char then
                    for _, v in pairs(char:GetDescendants()) do
                        if v:IsA("BasePart") then v.CanCollide = true end
                    end
                end
                -- Destroy BodyVelocity
                local char2 = I.Character
                local hrp2  = char2 and char2:FindFirstChild("HumanoidRootPart")
                if hrp2 then
                    local bv = hrp2:FindFirstChild("BodyClip")
                    if bv then bv:Destroy() end
                end
            end
        end)
    end
end)

-- ================================================================
-- _tp FUNCTION (ZYN exact - tweens anchor C, not the player)
-- ================================================================
getgenv().TweenSpeedFar  = 300
getgenv().TweenSpeedNear = 900

_tp = function(I)
    local e = plr.Character
    if not e or not e:FindFirstChild("HumanoidRootPart") then return end
    local HRP = e.HumanoidRootPart

    shouldTween      = true
    getgenv().OnFarm = false

    -- Unanchor if somehow anchored
    if HRP.Anchored then
        HRP.Anchored = false
        task.wait()
    end

    local dist  = (I.Position - HRP.Position).Magnitude
    local speed = dist <= 90
        and (getgenv().TweenSpeedNear or 900)
        or  (getgenv().TweenSpeedFar  or 300)

    local info  = TweenInfo.new(dist / speed, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(C, info, { CFrame = I })

    -- Handle sitting character
    if e.Humanoid.Sit == true then
        C.CFrame = CFrame.new(C.Position.X, I.Y, C.Position.Z)
    end

    tween:Play()

    -- Anti-lock watchdog (ZYN exact)
    task.spawn(function()
        while tween.PlaybackState == Enum.PlaybackState.Playing do
            if not shouldTween then
                tween:Cancel()
                break
            end
            task.wait(0.1)
        end
        getgenv().OnFarm = true
    end)
end

-- Alias
TeleportToTarget = _tp

-- Instant teleport (no tween - short hops)
notween = function(I)
    pcall(function() plr.Character.HumanoidRootPart.CFrame = I end)
end

-- ================================================================
-- G TABLE (ZYN G.Kill / G.Sword functions - exact port)
-- ================================================================
G = {}
G.Alive = Alive
G.Dist  = function(I, e) return Dist(I, e) end

-- G.Kill: locks boss, brings enemies, tweens above boss
G.Kill = function(I, alive)
    if not (I and alive) then return end
    local hrp = I:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if not I:GetAttribute("Locked") then
        I:SetAttribute("Locked", hrp.CFrame)
    end
    PosMon = I:GetAttribute("Locked").Position
    MousePos = PosMon  -- Update aim for __namecall hook

    _B = true
    BringEnemy()

    if _G.SelectWeapon then EquipWeapon(_G.SelectWeapon) end

    -- Tween above boss (ZYN: MobHeight above)
    _tp(hrp.CFrame * CFrame.new(0, _G.MobHeight, 0))
end

-- G.Sword: same but equips sword
G.Sword = function(I, alive)
    if not (I and alive) then return end
    local hrp = I:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if not I:GetAttribute("Locked") then
        I:SetAttribute("Locked", hrp.CFrame)
    end
    PosMon   = I:GetAttribute("Locked").Position
    MousePos = PosMon
    _B = true
    BringEnemy()
    weaponSc("Sword")
    _tp(hrp.CFrame * CFrame.new(0, 30, 0))
end

-- ================================================================
-- AUTO KEN (Observation Haki - ZYN exact)
-- ================================================================
task.spawn(function()
    while task.wait(0.2) do
        if _G.XH_AutoKen then
            pcall(function()
                local char = plr.Character
                if char and not CollectionService:HasTag(char, "Ken") then
                    CE("Ken", true)
                end
            end)
        end
    end
end)

-- ================================================================
-- FAST ATTACK HEARTBEAT (M1 spam + skill use + fruit M1)
-- Fires every RunService.Heartbeat when aura flags are on
-- ================================================================
local lastAttack = 0

RunService.Heartbeat:Connect(function(dt)
    -- Only fire when at least one aura is on
    if not (_G.XH_MeleeAura or _G.XH_SwordAura or _G.XH_FruitAura) then return end

    local char = plr.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Find nearest enemy in Enemies folder
    local nearest, nearDist = nil, math.huge
    for _, mob in pairs(workspace.Enemies:GetChildren()) do
        local mhrp = mob:FindFirstChild("HumanoidRootPart")
        if mhrp and Alive(mob) then
            local d = (hrp.Position - mhrp.Position).Magnitude
            if d < nearDist then
                nearDist = d
                nearest  = mob
            end
        end
    end

    if not nearest then return end
    local mhrp = nearest:FindFirstChild("HumanoidRootPart")
    if not mhrp then return end

    -- Update MousePos so __namecall hook aims correctly
    MousePos = mhrp.Position
    PosMon   = mhrp.Position

    -- [MELEE AURA] equip melee + fire Z/X skill + VirtualUser click
    if _G.XH_MeleeAura then
        weaponSc("Melee")
        vim2:CaptureController()
        vim2:ClickButton1(Vector2.zero)
        -- Fire Z skill auto-aimed at enemy
        if lastAttack > 0.3 then
            vim1:SendKeyEvent(true,  "Z", false, game)
            vim1:SendKeyEvent(false, "Z", false, game)
        end
        -- CF click (network M1 bypass)
        pcall(function() CF("Click") end)
    end

    -- [SWORD AURA] equip sword + Z skill + click
    if _G.XH_SwordAura then
        weaponSc("Sword")
        vim2:CaptureController()
        vim2:ClickButton1(Vector2.zero)
        if lastAttack > 0.3 then
            vim1:SendKeyEvent(true,  "Z", false, game)
            vim1:SendKeyEvent(false, "Z", false, game)
        end
    end

    -- [FRUIT AURA / M1] find fruit tool, fire LeftClickRemote
    if _G.XH_FruitAura then
        -- Find fruit in backpack or character
        local fruitTool = nil
        for _, v in pairs(char:GetChildren()) do
            if v:IsA("Tool") and v.ToolTip == "Blox Fruit" then
                fruitTool = v; break
            end
        end
        if not fruitTool then
            for _, v in pairs(plr.Backpack:GetChildren()) do
                if v:IsA("Tool") and v.ToolTip == "Blox Fruit" then
                    -- Auto-equip fruit
                    pcall(function() char.Humanoid:EquipTool(v) end)
                    task.wait(0.05)
                    fruitTool = char:FindFirstChildOfClass("Tool")
                    break
                end
            end
        end

        if fruitTool then
            local leftRemote = fruitTool:FindFirstChild("LeftClickRemote")
            if leftRemote then
                local dir = (mhrp.Position - hrp.Position).Unit
                -- Fire fruit M1 multiple times (aura spam)
                for _ = 1, 6 do
                    pcall(function() leftRemote:FireServer(dir, 1) end)
                end
            end
            -- Also use fruit Z skill auto-aimed
            if lastAttack > 0.4 then
                UseFruitSkills()
            end
        end
    end

    lastAttack = lastAttack + dt
    if lastAttack > 1 then lastAttack = 0 end
end)

-- ================================================================
-- BOSS DATA: exact names, spawn positions, sea
-- ================================================================
local BOSS_DATA = {
    Rip_Indra = {
        names = {"rip_indra", "Rip_Indra", "rip_indra True Form"},
        spawn = CFrame.new(5228, 5, 845),
        entrance = nil,
        sea = 3,
    },
    Darkbeard = {
        names = {"Darkbeard"},
        spawn = CFrame.new(-9551, 6, 5796),
        sea = 2,
    },
    DoughKing = {
        names = {"Dough King"},
        spawn = CFrame.new(-3228, 7, 6098),
        sea = 3,
    },
    CakePrince = {
        names = {"Cake Prince"},
        spawn = CFrame.new(-1340, 7, -11662),
        sea = 3,
    },
    SoulReaper = {
        names = {"Soul Reaper"},
        spawn = CFrame.new(-9524, 315, 6655),
        sea = 3,
    },
    CursedCaptain = {
        names = {"Cursed Captain"},
        spawn = CFrame.new(916.928589, 181.092773, 33422),
        entrance = Vector3.new(923.21252441406, 126.9760055542, 32852.83203125),
        sea = 2,
    },
    TyrantOfTheSkies = {
        names = {"Tyrant of the Skies", "Tyrant"},
        spawn = CFrame.new(-7882, 5444, -366),
        sea = 3,
    },
    Elite = {
        names = {"Elite Hunter", "Elite Pirate", "Guardian"},
        spawn = CFrame.new(-5750, 105, -4588),
        sea = 2,
    },
    Longma = {
        names = {"Longma"},
        spawn = CFrame.new(-10238, 389, -9549),
        sea = 3,
    },
    CastleRaid = {
        names = {"Order"},
        spawn = CFrame.new(-6440, 250, -5250),
        sea = 2,
    },
    KitsuneIsland = {
        names = {"Venomous Assailant", "Kitsune"},
        spawn = CFrame.new(4692, 797, 858),
        sea = 3,
    },
    PrehistoricIsland = {
        names = {"Lava Golem", "T-Rex"},
        spawn = CFrame.new(4620, 1002, 399),
        sea = 3,
    },
    Diamond = {
        names = {"Diamond"},
        spawn = CFrame.new(-5006, 88, 4353),
        sea = 2,
    },
    Jeremy = {
        names = {"Jeremy"},
        spawn = CFrame.new(-712, 98, 5711),
        sea = 2,
    },
    Fajita = {
        names = {"Fajita"},
        spawn = CFrame.new(-723, 147, 5931),
        sea = 2,
    },
    DonSwan = {
        names = {"Don Swan"},
        spawn = CFrame.new(638, 71, 918),
        sea = 2,
    },
    Order = {
        names = {"Order"},
        spawn = CFrame.new(-6440, 250, -5250),
        sea = 2,
    },
}

-- Find boss by key (tries exact name then partial)
local function FindBoss(key)
    local data = BOSS_DATA[key]
    if not data then return nil end
    for _, name in ipairs(data.names) do
        local found = GetConnectionEnemies(name)
        if found then return found end
    end
    -- Partial fallback
    for _, name in ipairs(data.names) do
        local partial = FindEnemyPartial(name)
        if partial then return partial end
    end
    return nil
end

-- ================================================================
-- AUTO FARM BOSS (main farm loop - uses G.Kill exactly like ZYN)
-- ================================================================
task.spawn(function()
    while task.wait(0.2) do
        if not _G.XH_AutoFarm then
            _B = false
            continue
        end
        pcall(function()
            local key  = _G.XH_SelBoss
            local data = BOSS_DATA[key]
            if not data then return end

            local boss = FindBoss(key)
            if boss then
                -- Boss found: use G.Kill (exact ZYN implementation)
                G.Kill(boss, Alive(boss))
            else
                -- Boss not present: go to spawn and wait
                _B = false
                shouldTween = false
                if data.entrance then
                    CF("requestEntrance", data.entrance)
                    task.wait(1)
                end
                notween(data.spawn)
                task.wait(2)
            end
        end)
    end
end)

-- ================================================================
-- AUTO COLLECT BERRIES (ZYN + CollectionService method)
-- ================================================================
task.spawn(function()
    while task.wait(0.15) do
        if not _G.XH_AutoBerry then continue end
        pcall(function()
            local char = plr.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end

            -- Method 1: CollectionService tagged BerryBush (ZYN berry method)
            local Bushes = CollectionService:GetTagged("BerryBush")
            for _, bush in ipairs(Bushes) do
                pcall(function()
                    local parent = bush.Parent
                    if parent then
                        local pivot = parent:GetPivot()
                        char.HumanoidRootPart.CFrame = pivot
                        task.wait(0.05)
                    end
                end)
            end

            -- Method 2: Workspace scan for berry objects by name
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Parent ~= char then
                    local lname = string.lower(obj.Name)
                    if lname == "redcherry" or lname == "blueicicle" or
                       lname == "greentoad" or lname == "orangefruit" or
                       lname:find("berry") then
                        char.HumanoidRootPart.CFrame = obj.CFrame
                        task.wait(0.06)
                    end
                end
            end

            -- Method 3: Use collectFruits (ZYN exact)
            collectFruits(true)

            -- Method 4: Teleport to known berry spawn positions
            local berrySpawns = World1 and {
                CFrame.new(885, 5, 4400),
                CFrame.new(-1600, 35, 150),
                CFrame.new(1050, 27, 1560),
            } or World2 and {
                CFrame.new(-428, 71, 1836),
                CFrame.new(638, 71, 918),
                CFrame.new(-2440, 71, -3216),
                CFrame.new(-5497, 47, -795),
            } or {
                CFrame.new(-12682, 390, -9902),
                CFrame.new(5000, 20, -500),
                CFrame.new(-3228, 7, 6098),
            }
            for _, cf in ipairs(berrySpawns) do
                if not _G.XH_AutoBerry then break end
                notween(cf)
                task.wait(1.5)
                collectFruits(true)
            end
        end)
    end
end)

-- ================================================================
-- AUTO CYBORG RACE (full step process, ZYN source port)
-- Step 1: Get Fist of Darkness (Sea Beast / enemy drop)
-- Step 2: Enter Law Raid area (buy Microchip with 1000 frags)
-- Step 3: Kill Order (drops Core Brain)
-- Step 4: Buy Cyborg race with Core Brain
-- ================================================================
local CyborgStep = 1

task.spawn(function()
    while task.wait(0.6) do
        if not _G.XH_AutoCyborg then
            CyborgStep = 1
            continue
        end
        pcall(function()
            if CyborgStep == 1 then
                -- Need Fist of Darkness
                if GetBP("Fist of Darkness") then
                    CyborgStep = 2
                    return
                end
                -- Look for sea beast or any enemy that drops Fist
                local seaBeast = workspace.SeaBeasts and workspace.SeaBeasts:FindFirstChild("SeaBeast1")
                if seaBeast and seaBeast:FindFirstChild("Humanoid") then
                    G.Kill(seaBeast, true)
                else
                    -- Check normal enemies for fist drop (bosses)
                    local enemy = GetConnectionEnemies("Darkbeard") or
                                  GetConnectionEnemies("Order")     or
                                  GetConnectionEnemies("Diamond")
                    if enemy then
                        G.Kill(enemy, Alive(enemy))
                    else
                        -- Go to sea area to find sea beasts
                        if World2 then
                            notween(CFrame.new(-7000, 5, -5000))
                        elseif World3 then
                            notween(CFrame.new(0, 5, -8000))
                        end
                    end
                end

            elseif CyborgStep == 2 then
                -- Have Fist of Darkness, need to enter Law Raid
                if not GetBP("Fist of Darkness") then CyborgStep = 1; return end
                -- Check if have enough fragments (1000)
                local frags = pcall(function() return tonumber(plr.Data.Fragments.Value) end)
                              and tonumber(plr.Data.Fragments.Value) or 0
                if frags < 1000 then
                    -- Farm fragments (from bosses)
                    local boss = GetConnectionEnemies("Darkbeard") or FindEnemyPartial("Boss")
                    if boss then G.Kill(boss, Alive(boss)) end
                    return
                end
                -- Go to raid pod location
                notween(CFrame.new(-6440, 250, -5250))
                task.wait(0.5)
                -- Buy microchip and start raid
                CF("BuyMicrochip")
                task.wait(0.5)
                CF("StartRaid", "Law")
                task.wait(2)
                CyborgStep = 3

            elseif CyborgStep == 3 then
                -- Kill Order in raid for Core Brain
                if GetBP("Core Brain") then
                    CyborgStep = 4; return
                end
                local order = GetConnectionEnemies("Order") or FindEnemyPartial("Order")
                if order then
                    G.Kill(order, Alive(order))
                else
                    notween(CFrame.new(-6440, 250, -5250))
                end

            elseif CyborgStep == 4 then
                -- Buy Cyborg with Core Brain
                if not GetBP("Core Brain") then CyborgStep = 3; return end
                -- TP to Cyborg Trainer NPC location
                notween(CFrame.new(6094, 73, 3825))
                task.wait(0.8)
                CF("CyborgTrainer", "Buy")
                task.wait(1)
                _G.XH_AutoCyborg = false
                CyborgStep = 1
            end
        end)
    end
end)

-- ================================================================
-- AUTO GHOUL RACE (ZYN exact Ectoplasm logic)
-- Farm Cursed Captain → 99 Ectoplasm → Buy Ghoul
-- ZYN source: CommF_:InvokeServer("Ectoplasm", "Buy", 3) then ("Ectoplasm","Change",4)
-- ================================================================
task.spawn(function()
    while task.wait(0.5) do
        if not _G.XH_AutoGhoul then continue end
        pcall(function()
            local ecto = GetM("Ectoplasm")
            if tonumber(ecto) < 99 then
                -- Farm Cursed Captain for ectoplasm
                local captain = GetConnectionEnemies("Cursed Captain")
                if captain then
                    G.Kill(captain, Alive(captain))
                else
                    -- Go to Cursed Ship entrance (ZYN exact coords line 1769)
                    CF("requestEntrance", Vector3.new(923.21252441406, 126.9760055542, 32852.83203125))
                    task.wait(1.5)
                    notween(CFrame.new(916.928589, 181.092773, 33422))
                    task.wait(3)
                end
            else
                -- Have 99+ ectoplasm: buy Ghoul (ZYN exact line 11917-11920)
                CF("Ectoplasm", "Buy", 3)
                task.wait(0.5)
                CF("Ectoplasm", "Change", 4)
                task.wait(0.5)
                _G.XH_AutoGhoul = false
            end
        end)
    end
end)

-- ================================================================
-- AUTO TUSHITA (ZYN/Kaitun exact steps)
-- 1. Check Rip Indra NOT alive
-- 2. TP to Hydra waterfall portal entrance
-- 3. Enter room
-- 4. Light 5 braziers in order
-- 5. Kill Longma
-- 6. Collect Tushita
-- ================================================================
local TushitaStep = 1
local BraziersDone = 0

-- Brazier CFrame positions (Sea 3 Tushita quest)
local BRAZIER_CFRAMES = {
    CFrame.new(5563.42, 5.18, -1249.7),
    CFrame.new(6035.8, 86.5, -1458.3),
    CFrame.new(5820.4, 5.0, -1835.6),
    CFrame.new(5432.1, 5.0, -2014.8),
    CFrame.new(5070.5, 12.0, -1634.2),
}

task.spawn(function()
    while task.wait(0.5) do
        if not _G.XH_AutoTushita then
            TushitaStep = 1
            BraziersDone = 0
            continue
        end
        pcall(function()
            if TushitaStep == 1 then
                -- Check Indra is dead (requirement)
                local indra = GetConnectionEnemies("rip_indra") or
                              GetConnectionEnemies("Rip_Indra") or
                              FindEnemyPartial("Rip_Indra")
                if indra then
                    -- Indra alive, cannot start Tushita
                    task.wait(5)
                    return
                end
                TushitaStep = 2

            elseif TushitaStep == 2 then
                -- TP to Hydra waterfall portal entrance (Sea 3 Impel Down area)
                notween(CFrame.new(5228, 5, 845))
                task.wait(1.5)
                TushitaStep = 3

            elseif TushitaStep == 3 then
                -- Enter the secret waterfall room
                notween(CFrame.new(5228, 5, 960))
                task.wait(1)
                -- Try proximity prompts (door trigger)
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("ProximityPrompt") then
                        pcall(function()
                            local hrp = plr.Character and plr.Character.HumanoidRootPart
                            if hrp then
                                local d = (hrp.Position - obj.Parent.Position).Magnitude
                                if d < 20 then
                                    fireproximityprompt(obj)
                                end
                            end
                        end)
                    end
                end
                BraziersDone = 0
                TushitaStep  = 4

            elseif TushitaStep == 4 then
                -- Light all 5 braziers
                if BraziersDone >= 5 then
                    TushitaStep = 5
                    return
                end
                local idx = BraziersDone + 1
                notween(BRAZIER_CFRAMES[idx])
                task.wait(0.8)
                -- Fire all ProximityPrompts near brazier
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("ProximityPrompt") then
                        pcall(function()
                            local hrp = plr.Character and plr.Character.HumanoidRootPart
                            if hrp then
                                local d = (hrp.Position - obj.Parent.Position).Magnitude
                                if d < 15 then
                                    fireproximityprompt(obj)
                                end
                            end
                        end)
                    end
                end
                -- Also send remote for brazier lighting
                pcall(function() CF("LightBrazier", idx) end)
                task.wait(0.5)
                BraziersDone = BraziersDone + 1

            elseif TushitaStep == 5 then
                -- Kill Longma (spawns after all torches)
                local longma = GetConnectionEnemies("Longma") or FindEnemyPartial("Longma")
                if longma then
                    G.Kill(longma, Alive(longma))
                    -- Wait for Longma to die
                    repeat task.wait(0.5)
                    until not Alive(longma) or not _G.XH_AutoTushita
                    TushitaStep = 6
                else
                    notween(CFrame.new(-10238, 389, -9549))
                    task.wait(3)
                end

            elseif TushitaStep == 6 then
                -- Collect Tushita from ground
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj.Name == "Tushita" then
                        pcall(function()
                            plr.Character.HumanoidRootPart.CFrame = obj.CFrame
                        end)
                        task.wait(0.3)
                    end
                end
                -- Done
                _G.XH_AutoTushita = false
                TushitaStep  = 1
                BraziersDone = 0
            end
        end)
    end
end)

-- ================================================================
-- AUTO LEGENDARY SWORD BUYER (ZYN source port)
-- Buys: Saddi, Wando, Shisui → True Triple Katana from dealer NPC
-- ================================================================
local LEG_SWORDS = { "Saddi", "Wando", "Shisui", "True Triple Katana" }

task.spawn(function()
    while task.wait(0.5) do
        if not _G.XH_AutoLegSword then continue end
        pcall(function()
            -- TP to dealer NPC and buy each sword
            local npcsFolder = replicated:FindFirstChild("NPCs")
            if npcsFolder then
                for _, npc in pairs(npcsFolder:GetChildren()) do
                    local lname = string.lower(npc.Name)
                    if lname:find("sword dealer") or lname:find("dealer") then
                        local nhrp = npc:FindFirstChild("HumanoidRootPart")
                        if nhrp then
                            notween(nhrp.CFrame * CFrame.new(0, 0, -3))
                            task.wait(0.5)
                            for _, sword in ipairs(LEG_SWORDS) do
                                CF("BuyItem", sword)
                                task.wait(0.3)
                            end
                        end
                    end
                end
            end
            -- Fallback: TP to known Sea 3 dealer position and invoke
            notween(CFrame.new(-3228, 7, 6098))
            task.wait(0.5)
            for _, sword in ipairs(LEG_SWORDS) do
                CF("BuyItem", sword)
                task.wait(0.3)
            end
        end)
    end
end)

-- ================================================================
-- CHARACTER RESPAWN HANDLER (re-init Root + C anchor)
-- ================================================================
plr.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    repeat task.wait() until char:FindFirstChild("HumanoidRootPart")
    Root = char.HumanoidRootPart
    C.CFrame = Root.CFrame
    shouldTween = false
    _B = false
    -- Re-activate Ken
    task.wait(2)
    if _G.XH_AutoKen then CE("Ken", true) end
end)

-- ================================================================
-- SERVER HOP API (all 17 Night Hub endpoints)
-- ================================================================
local API_LIST = {
    { Name="Full Moon",           Key="Fullmoon",         URL="http://nighthub.site/boss/Fullmoon"          },
    { Name="Near Moon",           Key="NearMoon",         URL="http://nighthub.site/boss/NearMoon"          },
    { Name="Mirage Island",       Key="Mirage",           URL="http://nighthub.site/boss/Mirage"            },
    { Name="Sword Legendary",     Key="SwordLegendary",   URL="http://nighthub.site/boss/SwordLegendary"    },
    { Name="Haki Legendary",      Key="HakiLegendary",    URL="http://nighthub.site/boss/HakiLegendary"     },
    { Name="Berry",               Key="Berry",            URL="http://nighthub.site/boss/Berry"             },
    { Name="Rip Indra",           Key="RipIndra",         URL="http://nighthub.site/boss/RipIndra"          },
    { Name="Dough King",          Key="DoughKing",        URL="http://nighthub.site/boss/DoughKing"         },
    { Name="Darkbeard",           Key="Darkbeard",        URL="http://nighthub.site/boss/Darkbeard"         },
    { Name="Kitsune Island",      Key="KitsuneIsland",    URL="http://nighthub.site/boss/KitsuneIsland"     },
    { Name="Soul Reaper",         Key="SoulReaper",       URL="http://nighthub.site/boss/SoulReaper"        },
    { Name="Cake Prince",         Key="CakePrince",       URL="http://nighthub.site/boss/CakePrince"        },
    { Name="Castle Raid",         Key="CastleRaid",       URL="http://nighthub.site/boss/CastleRaid"        },
    { Name="Elite",               Key="Elite",            URL="http://nighthub.site/boss/Elite"             },
    { Name="Cursed Captain",      Key="CursedCaptain",    URL="http://nighthub.site/boss/CursedCaptain"     },
    { Name="Tyrant Of The Skies", Key="TyrantOfTheSkies", URL="http://nighthub.site/boss/TyrantOfTheSkies"  },
    { Name="Prehistoric Island",  Key="PrehistoricIsland",URL="http://nighthub.site/boss/PrehistoricIsland" },
}

local SrvCache    = {}   -- Key → { label → jobId }
local SrvSelected = {}   -- Key → currently selected label
local SrvRawData  = {}   -- Key → raw server list for fallback

for _, ev in ipairs(API_LIST) do
    SrvCache[ev.Key]    = {}
    SrvSelected[ev.Key] = nil
    SrvRawData[ev.Key]  = {}
end

-- Fetch servers (cache-busted, anti-self-join, sorted by age)
local function FetchServers(event)
    local url = event.URL .. "?v=" .. tostring(os.time())
    local ok, res = pcall(function() return game:HttpGet(url, true) end)
    if not ok or not res or res == "" or res == "[]" or res == "null" then
        return nil, "API returned empty"
    end
    local ok2, data = pcall(function() return HttpService:JSONDecode(res) end)
    if not ok2 or type(data) ~= "table" then
        return nil, "JSON parse error"
    end
    -- Filter: same PlaceId, not current server
    local valid = {}
    for _, srv in ipairs(data) do
        if tostring(srv.PlaceId) == tostring(placeId) and
           tostring(srv.JobId)   ~= JobId             and
           tostring(srv.JobId)   ~= "" then
            table.insert(valid, srv)
        end
    end
    -- Sort by Age ascending (youngest boss first)
    table.sort(valid, function(a,b)
        return tonumber(a.Age or 9999) < tonumber(b.Age or 9999)
    end)
    return valid, nil
end

-- Boss alive heuristic: Age under 90s and server not full
local function BossLikelyAlive(srv)
    return tonumber(srv.Age or 999) <= 90 and
           tonumber(srv.Players or 12) < 12
end

-- Teleport with anti-kick delay and server-full fallback
local function DoTeleport(jobId, fallbackList, onErr)
    task.wait(1) -- anti-kick
    local ok, err = pcall(function()
        TeleportService:TeleportToPlaceInstance(placeId, jobId, plr)
    end)
    if not ok then
        if fallbackList and #fallbackList > 0 then
            local next = table.remove(fallbackList, 1)
            if onErr then onErr("Server full, trying next...") end
            task.wait(2)
            DoTeleport(tostring(next.JobId), fallbackList, onErr)
        else
            if onErr then onErr("All servers failed: " .. tostring(err)) end
        end
    end
end

-- Persistent re-execution after teleport
pcall(function()
    if queue_on_teleport then
        local src = "loadstring(game:HttpGet('https://raw.githubusercontent.com/XicoSkelly/XicoHub/main/XicoHub_Ultimate.lua',true))()"
        queue_on_teleport(src)
    end
end)

-- ================================================================
-- FLUENT UI (try primary then fallback URL)
-- ================================================================
local Fluent
local FluentOk

FluentOk, Fluent = pcall(function()
    return loadstring(game:HttpGet(
        "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua", true
    ))()
end)

if not FluentOk or not Fluent then
    FluentOk, Fluent = pcall(function()
        return loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/main.lua", true
        ))()
    end)
end

if not FluentOk or not Fluent then
    -- Last resort: raw jsdelivr CDN
    FluentOk, Fluent = pcall(function()
        return loadstring(game:HttpGet(
            "https://cdn.jsdelivr.net/gh/dawid-scripts/Fluent@master/main.lua", true
        ))()
    end)
end

-- If all fail, error visibly
if not FluentOk or not Fluent then
    error("XICO HUB: Failed to load Fluent UI from all sources. Check executor HTTP permissions.")
end

-- Shorthand notify
local function Notify(title, content, dur)
    pcall(function()
        Fluent:Notify({ Title = title, Content = content, Duration = dur or 3 })
    end)
end

-- ================================================================
-- CREATE WINDOW (40% of typical 580x380 = ~232x152, Fluent min ~260x175)
-- ================================================================
local Window = Fluent:CreateWindow({
    Title       = "Xico Hub | Hop",
    SubTitle    = "made by @alifgamer",
    TabWidth    = 110,
    Size        = UDim2.fromOffset(262, 178),
    Acrylic     = false,
    Theme       = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl,
})

-- ================================================================
-- TAB: FARM (Aura + Boss Farm + Berries + Ken)
-- ================================================================
local FarmTab = Window:AddTab({ Title = "Farm", Icon = "sword" })

FarmTab:AddSection("Aura  (ON by default)")

FarmTab:AddToggle("MeleeAura", {
    Title    = "Melee Aura + M1 Spam",
    Default  = true,
    Callback = function(v)
        _G.XH_MeleeAura = v
        if v then weaponSc("Melee") end
    end
})

FarmTab:AddToggle("SwordAura", {
    Title    = "Sword Aura + M1 Spam",
    Default  = true,
    Callback = function(v)
        _G.XH_SwordAura = v
        if v then weaponSc("Sword") end
    end
})

FarmTab:AddToggle("FruitAura", {
    Title    = "Fruit Aura (LeftClickRemote M1)",
    Default  = true,
    Callback = function(v)
        _G.XH_FruitAura = v
    end
})

FarmTab:AddSection("Fruit Skills (Auto-Aim)")

FarmTab:AddToggle("FruitZ", {
    Title    = "Fruit Z Skill (Auto)",
    Default  = true,
    Callback = function(v) _G.FruitSkills.Z = v end
})
FarmTab:AddToggle("FruitX", {
    Title    = "Fruit X Skill (Auto)",
    Default  = false,
    Callback = function(v) _G.FruitSkills.X = v end
})
FarmTab:AddToggle("FruitC", {
    Title    = "Fruit C Skill (Auto)",
    Default  = false,
    Callback = function(v) _G.FruitSkills.C = v end
})

FarmTab:AddSection("Boss Farm")

-- Build boss list values
local BOSS_UI_VALUES = {
    "Rip Indra", "Darkbeard", "Dough King", "Cake Prince",
    "Soul Reaper", "Cursed Captain", "Tyrant Of The Skies",
    "Elite", "Longma", "Castle Raid", "Kitsune Island",
    "Prehistoric Island", "Diamond", "Jeremy", "Fajita", "Don Swan",
}
local BOSS_UI_TO_KEY = {
    ["Rip Indra"]           = "Rip_Indra",
    ["Darkbeard"]           = "Darkbeard",
    ["Dough King"]          = "DoughKing",
    ["Cake Prince"]         = "CakePrince",
    ["Soul Reaper"]         = "SoulReaper",
    ["Cursed Captain"]      = "CursedCaptain",
    ["Tyrant Of The Skies"] = "TyrantOfTheSkies",
    ["Elite"]               = "Elite",
    ["Longma"]              = "Longma",
    ["Castle Raid"]         = "CastleRaid",
    ["Kitsune Island"]      = "KitsuneIsland",
    ["Prehistoric Island"]  = "PrehistoricIsland",
    ["Diamond"]             = "Diamond",
    ["Jeremy"]              = "Jeremy",
    ["Fajita"]              = "Fajita",
    ["Don Swan"]            = "DonSwan",
}

FarmTab:AddDropdown("BossDropdown", {
    Title    = "Select Boss",
    Values   = BOSS_UI_VALUES,
    Default  = 1,
    Callback = function(v)
        _G.XH_SelBoss = BOSS_UI_TO_KEY[v] or "Rip_Indra"
    end
})

-- Standalone Farm Boss toggle button (spec: directly under dropdown)
FarmTab:AddToggle("FarmBossToggle", {
    Title       = "▶ Farm Boss (Toggle)",
    Description = "Tween above boss + bring mobs + auto attack",
    Default     = false,
    Callback    = function(v)
        _G.XH_AutoFarm = v
        if v then
            _B = true
            Notify("Farm Boss", "Farming: " .. (_G.XH_SelBoss or "?"), 2)
        else
            _B        = false
            shouldTween = false
        end
    end
})

FarmTab:AddButton({
    Title    = "Teleport To Boss Spawn",
    Callback = function()
        local key  = _G.XH_SelBoss
        local data = BOSS_DATA[key]
        if data then
            notween(data.spawn)
            if data.entrance then
                CF("requestEntrance", data.entrance)
                task.wait(1)
                notween(data.spawn)
            end
            Notify("TP", "Teleported to " .. key, 2)
        end
    end
})

FarmTab:AddSection("Utilities")

FarmTab:AddToggle("AutoBerry", {
    Title    = "Auto Collect Berries",
    Default  = false,
    Callback = function(v) _G.XH_AutoBerry = v end
})

FarmTab:AddToggle("AutoKen", {
    Title    = "Auto Observation Haki (Ken)",
    Default  = true,
    Callback = function(v) _G.XH_AutoKen = v end
})

FarmTab:AddToggle("BringMobs", {
    Title    = "Bring Mobs To You",
    Default  = false,
    Callback = function(v)
        _G.XH_BringMobs = v
        _B = v
    end
})

FarmTab:AddSlider("MobHeight", {
    Title    = "Mob Height (studs above)",
    Min      = 5,
    Max      = 100,
    Default  = 20,
    Rounding = 0,
    Callback = function(v) _G.MobHeight = v end
})

-- ================================================================
-- TAB: RACE (Cyborg, Ghoul, Tushita, Leg Sword)
-- ================================================================
local RaceTab = Window:AddTab({ Title = "Race", Icon = "user" })

RaceTab:AddSection("Cyborg Race")

RaceTab:AddParagraph({
    Title = "Steps",
    Desc  = "1.Fist of Darkness  2.Law Raid Chip  3.Kill Order  4.Core Brain  5.Buy Cyborg"
})

RaceTab:AddToggle("AutoCyborg", {
    Title    = "Auto Cyborg Race",
    Default  = false,
    Callback = function(v)
        _G.XH_AutoCyborg = v
        CyborgStep = 1
        if v then Notify("Cyborg", "Step 1: Farming Fist of Darkness...", 3) end
    end
})

RaceTab:AddButton({
    Title    = "Buy Cyborg (Manual)",
    Callback = function()
        CF("CyborgTrainer", "Buy")
        Notify("Cyborg", "Sent buy request!", 2)
    end
})

RaceTab:AddSection("Ghoul Race")

RaceTab:AddParagraph({
    Title = "Steps",
    Desc  = "Farm 99 Ectoplasm from Cursed Captain ship → Buy Ghoul race"
})

RaceTab:AddToggle("AutoGhoul", {
    Title    = "Auto Ghoul Race",
    Default  = false,
    Callback = function(v)
        _G.XH_AutoGhoul = v
        if v then Notify("Ghoul", "Farming Cursed Captain for Ectoplasm...", 3) end
    end
})

RaceTab:AddButton({
    Title    = "Buy Ghoul (Manual - needs 99 Ecto)",
    Callback = function()
        CF("Ectoplasm", "Buy", 3)
        task.wait(0.3)
        CF("Ectoplasm", "Change", 4)
        Notify("Ghoul", "Sent buy + change race request!", 2)
    end
})

RaceTab:AddSection("Tushita Sword")

RaceTab:AddParagraph({
    Title = "Steps",
    Desc  = "Indra dead→Portal→5 Braziers→Kill Longma→Collect Tushita"
})

RaceTab:AddToggle("AutoTushita", {
    Title    = "Auto Tushita Quest",
    Default  = false,
    Callback = function(v)
        _G.XH_AutoTushita = v
        TushitaStep  = 1
        BraziersDone = 0
        if v then Notify("Tushita", "Checking Rip Indra status...", 3) end
    end
})

RaceTab:AddSection("Legendary Swords")

RaceTab:AddToggle("AutoLegSword", {
    Title    = "Auto Buy Legendary Swords",
    Default  = false,
    Callback = function(v) _G.XH_AutoLegSword = v end
})

for _, sword in ipairs(LEG_SWORDS) do
    RaceTab:AddButton({
        Title    = "Buy " .. sword,
        Callback = function()
            CF("BuyItem", sword)
            Notify("Shop", "Buying " .. sword, 2)
        end
    })
end

RaceTab:AddSection("Quick Race Shop")

RaceTab:AddButton({
    Title    = "Random Race (3000F)",
    Callback = function()
        CF("BlackbeardReward", "Reroll", "1")
        CF("BlackbeardReward", "Reroll", "2")
        Notify("Race", "Random Race sent!", 2)
    end
})

RaceTab:AddButton({
    Title    = "Reset Stats (2500F)",
    Callback = function()
        CF("BlackbeardReward", "Refund", "1")
        CF("BlackbeardReward", "Refund", "2")
        Notify("Stats", "Stats reset sent!", 2)
    end
})

RaceTab:AddButton({
    Title    = "Buy Bizarre Rifle (250 Ecto)",
    Callback = function()
        CF("Ectoplasm", "Buy", 1)
        Notify("Shop", "Bizarre Rifle sent!", 2)
    end
})

-- ================================================================
-- TABS: SERVER HOP (one per API endpoint, all 17)
-- ================================================================
local DropdownRefs = {}

for _, ev in ipairs(API_LIST) do
    local tab = Window:AddTab({ Title = ev.Name, Icon = "globe" })

    tab:AddSection(ev.Name)

    -- Server dropdown (populated on refresh)
    local srvDrop = tab:AddDropdown("D_" .. ev.Key, {
        Title    = "Available Servers",
        Values   = { "[ Press Refresh Below ]" },
        Default  = 1,
        Callback = function(v)
            SrvSelected[ev.Key] = v
        end
    })
    DropdownRefs[ev.Key] = srvDrop

    -- REFRESH
    tab:AddButton({
        Title       = "🔄 Refresh Servers",
        Description = "Cache-busted fetch from NightHub API",
        Callback    = function()
            Notify("Fetching", ev.Name .. " servers...", 1)
            task.spawn(function()
                local servers, err = FetchServers(ev)
                if not servers or #servers == 0 then
                    srvDrop:SetValues({ "[ No Servers Found ]" })
                    srvDrop:SetValue("[ No Servers Found ]")
                    SrvCache[ev.Key]   = {}
                    SrvRawData[ev.Key] = {}
                    Notify("Empty", err or "No servers for " .. ev.Name, 3)
                    return
                end

                local labels = {}
                local map    = {}
                SrvRawData[ev.Key] = servers

                for i, srv in ipairs(servers) do
                    local tag = BossLikelyAlive(srv) and "✅ " or "⏳ "
                    local lbl = string.format(
                        "%s#%d Age:%ss | %s/12",
                        tag, i,
                        tostring(srv.Age or "?"),
                        tostring(srv.Players or "?")
                    )
                    table.insert(labels, lbl)
                    map[lbl] = tostring(srv.JobId)
                end

                SrvCache[ev.Key]    = map
                SrvSelected[ev.Key] = labels[1]
                srvDrop:SetValues(labels)
                srvDrop:SetValue(labels[1])
                Notify("Done!", #labels .. " servers for " .. ev.Name, 3)
            end)
        end
    })

    -- JOIN SELECTED
    tab:AddButton({
        Title       = "🚀 Join Selected Server",
        Description = "Teleport via JobId (anti-self-join + anti-kick)",
        Callback    = function()
            local sel = SrvSelected[ev.Key]
            local map = SrvCache[ev.Key]
            if not sel or not map or not map[sel] then
                Notify("Error", "Refresh first then select a server!", 2)
                return
            end
            local jobId = map[sel]
            if jobId == JobId then
                Notify("Skip", "You are already in this server!", 2)
                return
            end
            Notify("Teleporting", "Joining " .. ev.Name .. "...", 4)
            -- Build fallback list from raw data (server-full handling)
            local fallback = {}
            for _, srv in ipairs(SrvRawData[ev.Key] or {}) do
                if tostring(srv.JobId) ~= jobId and tostring(srv.JobId) ~= JobId then
                    table.insert(fallback, srv)
                end
            end
            DoTeleport(jobId, fallback, function(msg) Notify("Info", msg, 3) end)
        end
    })

    -- AUTO HOP (finds best alive server + teleports)
    tab:AddButton({
        Title       = "🔁 Auto Hop (Best Server)",
        Description = "Refresh + auto-join freshest boss server",
        Callback    = function()
            Notify("Auto Hop", "Scanning " .. ev.Name .. "...", 2)
            task.spawn(function()
                local servers, err = FetchServers(ev)
                if not servers or #servers == 0 then
                    Notify("Failed", err or "No servers found for " .. ev.Name, 3)
                    return
                end
                SrvRawData[ev.Key] = servers

                -- Prioritise "likely alive" servers
                local alive, other = {}, {}
                for _, srv in ipairs(servers) do
                    if BossLikelyAlive(srv) then
                        table.insert(alive, srv)
                    else
                        table.insert(other, srv)
                    end
                end
                local ordered = {}
                for _, s in ipairs(alive) do table.insert(ordered, s) end
                for _, s in ipairs(other) do table.insert(ordered, s) end

                if #ordered == 0 then
                    Notify("None", "No valid servers for " .. ev.Name, 3)
                    return
                end
                local best = ordered[1]
                Notify("Hopping → " .. ev.Name,
                    string.format("Age:%ss | %s/12 players",
                        tostring(best.Age or "?"),
                        tostring(best.Players or "?")), 4)
                table.remove(ordered, 1)
                DoTeleport(tostring(best.JobId), ordered,
                    function(msg) Notify("Info", msg, 3) end)
            end)
        end
    })
end

-- ================================================================
-- TAB: SETTINGS
-- ================================================================
local SetTab = Window:AddTab({ Title = "Settings", Icon = "settings" })

SetTab:AddSection("Tween Speed")

SetTab:AddSlider("TweenFar", {
    Title    = "Tween Speed (Far > 90 studs)",
    Min      = 100,
    Max      = 1000,
    Default  = 300,
    Rounding = 0,
    Callback = function(v) getgenv().TweenSpeedFar = v end
})

SetTab:AddSlider("TweenNear", {
    Title    = "Tween Speed (Near ≤ 90 studs)",
    Min      = 100,
    Max      = 2000,
    Default  = 900,
    Rounding = 0,
    Callback = function(v) getgenv().TweenSpeedNear = v end
})

SetTab:AddSection("Bring Settings")

SetTab:AddSlider("BringRange", {
    Title    = "Bring Range (studs)",
    Min      = 50,
    Max      = 500,
    Default  = 235,
    Rounding = 0,
    Callback = function(v) _G.BringRange = v end
})

SetTab:AddSlider("MaxBring", {
    Title    = "Max Mobs to Bring",
    Min      = 1,
    Max      = 20,
    Default  = 3,
    Rounding = 0,
    Callback = function(v) _G.MaxBringMobs = v end
})

SetTab:AddSection("Misc")

SetTab:AddButton({
    Title    = "Redeem All Codes",
    Callback = function()
        local codes = {
            "LIGHTNINGABUSE","1LOSTADMIN","ADMINFIGHT","GIFTING_HOURS",
            "NOMOREHACK","BANEXPLOIT","WildDares","BossBuild","GetPranked",
            "EARN_FRUITS","SUB2GAMERROBOT_RESET1","KITT_RESET","Bignews",
            "CHANDLER","Fudd10","fudd10_v2","Sub2UncleKizaru","FIGHT4FRUIT",
            "kittgaming","TRIPLEABUSE","Sub2CaptainMaui","Sub2Fer999",
            "Enyu_is_Pro","Magicbus","JCWK","Starcodeheo","Bluxxy",
            "SUB2GAMERROBOT_EXP1","Sub2NoobMaster123","Sub2Daigrock",
            "Axiore","TantaiGaming","StrawHatMaine","Sub2OfficialNoobie",
            "TheGreatAce","JULYUPDATE_RESET","ADMINHACKED","SEATROLLING",
            "24NOADMIN","ADMIN_TROLL","NEWTROLL","SECRET_ADMIN","staffbattle",
            "NOEXPLOIT","NOOB2ADMIN","CODESLIDE","fruitconcepts","krazydares"
        }
        local RedeemRemote = replicated.Remotes:FindFirstChild("Redeem")
        if RedeemRemote then
            for _, code in ipairs(codes) do
                task.wait(0.05)
                pcall(function()
                    if RedeemRemote.InvokeServer then
                        RedeemRemote:InvokeServer(code)
                    else
                        RedeemRemote:FireServer(code)
                    end
                end)
            end
            Notify("Codes", "All codes attempted!", 3)
        else
            Notify("Error", "Redeem remote not found!", 2)
        end
    end
})

SetTab:AddButton({
    Title    = "Copy Discord Link",
    Callback = function()
        pcall(function() setclipboard("https://discord.gg/vcaNyAgsP2") end)
        Notify("Discord", "Link copied to clipboard!", 2)
    end
})

SetTab:AddButton({
    Title    = "Detect World",
    Callback = function()
        local w = World1 and "Sea 1 (World1)" or
                  World2 and "Sea 2 (World2)" or
                  World3 and "Sea 3 (World3)" or "Unknown"
        Notify("World", w .. " | PlaceId: " .. tostring(placeId), 4)
    end
})

-- ================================================================
-- SELECT FIRST TAB
-- ================================================================
Window:SelectTab(1)

-- ================================================================
-- ADAPTIVE FLOATING TOGGLE BUTTON
-- Asset: rbxassetid://84090982489875 | Cyan | Draggable
-- Sends RightControl key to Fluent to minimize/maximize
-- ================================================================
pcall(function()
    local old = CoreGui:FindFirstChild("XicoHubToggleV8")
    if old then old:Destroy() end
end)

local TogGui = Instance.new("ScreenGui")
TogGui.Name           = "XicoHubToggleV8"
TogGui.ResetOnSpawn   = false
TogGui.IgnoreGuiInset = true
TogGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
TogGui.Parent         = CoreGui

-- Background frame (cyan glow)
local TogFrame = Instance.new("Frame")
TogFrame.Name            = "TogFrame"
TogFrame.Size            = UDim2.fromOffset(54, 54)
TogFrame.Position        = UDim2.new(0, 5, 0.43, 0)
TogFrame.BackgroundColor3 = Color3.fromRGB(0, 185, 210)
TogFrame.BorderSizePixel = 0
TogFrame.ZIndex          = 19
TogFrame.Parent          = TogGui
Instance.new("UICorner", TogFrame).CornerRadius = UDim.new(0, 14)
local togStroke = Instance.new("UIStroke", TogFrame)
togStroke.Color     = Color3.fromRGB(0, 255, 255)
togStroke.Thickness = 2.5

-- Image button (specified asset ID)
local TogBtn = Instance.new("ImageButton")
TogBtn.Name               = "TogBtn"
TogBtn.Size               = UDim2.fromScale(1, 1)
TogBtn.BackgroundTransparency = 1
TogBtn.Image              = "rbxassetid://84090982489875"
TogBtn.ImageColor3        = Color3.fromRGB(0, 255, 255)
TogBtn.ScaleType          = Enum.ScaleType.Fit
TogBtn.ZIndex             = 20
TogBtn.Active             = true
TogBtn.Parent             = TogFrame

-- Drag logic (works on mobile + PC)
local dragging   = false
local dragStart  = nil
local frameStart = nil
local dragInput  = nil
local movedDelta = 0

TogBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        dragging   = true
        dragStart  = input.Position
        frameStart = TogFrame.Position
        movedDelta = 0
    end
end)

TogBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or
       input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        movedDelta  = delta.Magnitude
        TogFrame.Position = UDim2.new(
            frameStart.X.Scale, frameStart.X.Offset + delta.X,
            frameStart.Y.Scale, frameStart.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Click = toggle UI (only if not dragging)
TogBtn.MouseButton1Click:Connect(function()
    if movedDelta > 6 then movedDelta = 0; return end
    movedDelta = 0
    -- Send RightControl to Fluent minimize/maximize
    vim1:SendKeyEvent(true,  Enum.KeyCode.RightControl, false, game)
    task.wait(0.05)
    vim1:SendKeyEvent(false, Enum.KeyCode.RightControl, false, game)
end)

-- ================================================================
-- FINAL NOTIFY
-- ================================================================
Notify("Xico Hub V8 Loaded!", "Aura ON | Tap cyan icon to toggle UI | RCtrl", 6)
task.wait(3)
Notify("Combat Active", "Melee + Sword + Fruit M1 aura running on heartbeat", 4)

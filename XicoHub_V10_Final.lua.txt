-- ================================================================
-- XICO HUB | HOP  |  V10  |  made by @alifgamer
-- Full rewrite using EXACT ZYN Hub free source logic.
-- All executor-specific calls wrapped in pcall so they never crash.
-- ================================================================

-- ================================================================
-- [A] WAIT FOR LOAD
-- ================================================================
repeat task.wait() until game:IsLoaded()

-- ================================================================
-- [B] SERVICES
-- ================================================================
local TweenService        = game:GetService("TweenService")
local TeleportService     = game:GetService("TeleportService")
local Players             = game:GetService("Players")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local HttpService         = game:GetService("HttpService")
local RunService          = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser         = game:GetService("VirtualUser")
local CollectionService   = game:GetService("CollectionService")
local Lighting            = game:GetService("Lighting")
local CoreGui             = game:GetService("CoreGui")
local UserInputService    = game:GetService("UserInputService")

-- ================================================================
-- [C] PLAYER + CHARACTER
-- ================================================================
local plr = Players.LocalPlayer
repeat task.wait() until plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")

-- ZYN exact globals
ply        = Players
replicated = ReplicatedStorage
TW         = TweenService
vim1       = VirtualInputManager
vim2       = VirtualUser
RunSer     = RunService

Root = plr.Character.HumanoidRootPart

-- World detection (ZYN exact)
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

-- ================================================================
-- [D] REMOTES
-- ================================================================
local CommF_ = ReplicatedStorage:WaitForChild("Remotes",10):WaitForChild("CommF_",10)
local commE  = ReplicatedStorage:WaitForChild("Remotes",10):WaitForChild("CommE",10)

local function CF(...)
    local ok,r = pcall(function() return CommF_:InvokeServer(...) end)
    if ok then return r end
end
local function CE(...)
    pcall(function() commE:FireServer(...) end)
end

-- ================================================================
-- [E] ZYN GLOBALS (exact variable names)
-- ================================================================
shouldTween = false
_B          = false
PosMon      = nil
MousePos    = Vector3.new(0,0,0)
RandomCFrame = false
SoulGuitar  = false
Sec         = 0.1

_G.MobHeight    = 20
_G.BringRange   = 235
_G.MaxBringMobs = 3
_G.SelectWeapon = nil
_G.FruitSkills  = { Z=true, X=false, C=false, V=false, F=false }
_G.StartFarm    = false   -- used by FarmAtivo

-- Xico Hub specific flags
_G.XH_AutoFarm     = false
_G.XH_SelBoss      = "rip_indra"
_G.XH_AutoBerry    = false
_G.XH_AutoCyborg   = false
_G.XH_AutoGhoul    = false
_G.XH_AutoTushita  = false
_G.XH_AutoLegSword = false
_G.XH_AutoKen      = true
_G.XH_BringMobs    = false

-- ================================================================
-- [F] LIGHTING (ZYN LowCpu exact)
-- ================================================================
pcall(function()
    local n = Lighting
    n.GlobalShadows     = false
    n.FogEnd            = 9000000000.0
    n.Brightness        = 1
    n.Ambient           = Color3.new(0.695,0.695,0.695)
    n.ColorShift_Bottom = Color3.new(0.695,0.695,0.695)
    n.ColorShift_Top    = Color3.new(0.695,0.695,0.695)
    workspace.Terrain.WaterWaveSize    = 0
    workspace.Terrain.WaterWaveSpeed   = 0
    workspace.Terrain.WaterReflectance = 0
    workspace.Terrain.WaterTransparency= 0
    pcall(function() settings().Rendering.QualityLevel = "Level01" end)
    for _,e in pairs(n:GetChildren()) do
        if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or
           e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or
           e:IsA("DepthOfFieldEffect") then
            e.Enabled = false
        end
    end
    -- Remove rocks
    local O = workspace:FindFirstChild("Rocks")
    if O then O:Destroy() end
end)

-- ================================================================
-- [G] ANTI-AFK
-- ================================================================
plr.Idled:Connect(function()
    vim2:Button2Down(Vector2.zero, workspace.CurrentCamera.CFrame)
    task.wait(1)
    vim2:Button2Up(Vector2.zero, workspace.CurrentCamera.CFrame)
end)

-- ================================================================
-- [H] UTILITY FUNCTIONS (ZYN exact)
-- ================================================================

-- ZYN exact EquipWeapon
EquipWeapon = function(I)
    if not I then return end
    if plr.Backpack:FindFirstChild(I) then
        plr.Character.Humanoid:EquipTool(plr.Backpack:FindFirstChild(I))
    end
end

-- ZYN exact weaponSc
weaponSc = function(I)
    for _,K in pairs(plr.Backpack:GetChildren()) do
        if K:IsA("Tool") and K.ToolTip == I then
            EquipWeapon(K.Name)
        end
    end
end

-- ZYN exact GetBP
GetBP = function(I)
    return plr.Backpack:FindFirstChild(I) or plr.Character:FindFirstChild(I)
end

-- ZYN exact GetM
GetM = function(I)
    local ok,inv = pcall(function() return CommF_:InvokeServer("getInventory") end)
    if not ok or type(inv)~="table" then return 0 end
    for _,K in pairs(inv) do
        if type(K)=="table" and K.Type=="Material" and K.Name==I then
            return K.Count or 0
        end
    end
    return 0
end

-- ZYN exact GetWP
GetWP = function(I)
    local ok,inv = pcall(function() return CommF_:InvokeServer("getInventory") end)
    if not ok or type(inv)~="table" then return false end
    for _,K in pairs(inv) do
        if type(K)=="table" and K.Type=="Sword" then
            if K.Name==I or plr.Character:FindFirstChild(I) or plr.Backpack:FindFirstChild(I) then
                return true
            end
        end
    end
    return false
end

-- ZYN exact GetIn
GetIn = function(I)
    local ok,inv = pcall(function() return CommF_:InvokeServer("getInventory") end)
    if not ok or type(inv)~="table" then return false end
    for _,K in pairs(inv) do
        if type(K)=="table" then
            if K.Name==I or plr.Character:FindFirstChild(I) or plr.Backpack:FindFirstChild(I) then
                return true
            end
        end
    end
    return false
end

-- ZYN exact collectFruits
collectFruits = function(I)
    if I then
        local chr = plr.Character
        for _,K in pairs(workspace:GetChildren()) do
            if string.find(K.Name,"Fruit") then
                pcall(function() K.Handle.CFrame = chr.HumanoidRootPart.CFrame end)
            end
        end
    end
end

-- ZYN exact GetConnectionEnemies
GetConnectionEnemies = function(I)
    for _,K in pairs(replicated:GetChildren()) do
        if K:IsA("Model") and (
            (type(I)=="table" and table.find(I,K.Name) or K.Name==I) and
            K:FindFirstChild("Humanoid") and K.Humanoid.Health>0
        ) then return K end
    end
    for _,K in pairs(workspace.Enemies:GetChildren()) do
        if K:IsA("Model") and (
            (type(I)=="table" and table.find(I,K.Name) or K.Name==I) and
            K:FindFirstChild("Humanoid") and K.Humanoid.Health>0
        ) then return K end
    end
end

-- Alive helper
local function Alive(I)
    if not I or not I.Parent then return false end
    local h = I:FindFirstChild("Humanoid")
    return h and h.Health>0
end

-- ZYN exact Useskills
Useskills = function(I,e)
    if I=="Melee" then
        weaponSc("Melee")
        if e=="Z" then vim1:SendKeyEvent(true,"Z",false,game); vim1:SendKeyEvent(false,"Z",false,game)
        elseif e=="X" then vim1:SendKeyEvent(true,"X",false,game); vim1:SendKeyEvent(false,"X",false,game)
        elseif e=="C" then vim1:SendKeyEvent(true,"C",false,game); vim1:SendKeyEvent(false,"C",false,game) end
    elseif I=="Sword" then
        weaponSc("Sword")
        if e=="Z" then vim1:SendKeyEvent(true,"Z",false,game); vim1:SendKeyEvent(false,"Z",false,game)
        elseif e=="X" then vim1:SendKeyEvent(true,"X",false,game); vim1:SendKeyEvent(false,"X",false,game) end
    elseif I=="Blox Fruit" then
        weaponSc("Blox Fruit")
        if e=="Z" then vim1:SendKeyEvent(true,"Z",false,game); vim1:SendKeyEvent(false,"Z",false,game)
        elseif e=="X" then vim1:SendKeyEvent(true,"X",false,game); vim1:SendKeyEvent(false,"X",false,game)
        elseif e=="C" then vim1:SendKeyEvent(true,"C",false,game); vim1:SendKeyEvent(false,"C",false,game)
        elseif e=="V" then vim1:SendKeyEvent(true,"V",false,game); vim1:SendKeyEvent(false,"V",false,game) end
    elseif I=="Gun" then
        weaponSc("Gun")
        if e=="Z" then vim1:SendKeyEvent(true,"Z",false,game); vim1:SendKeyEvent(false,"Z",false,game)
        elseif e=="X" then vim1:SendKeyEvent(true,"X",false,game); vim1:SendKeyEvent(false,"X",false,game) end
    end
    if I=="nil" and e=="Y" then
        vim1:SendKeyEvent(true,"Y",false,game); vim1:SendKeyEvent(false,"Y",false,game)
    end
end

-- ZYN exact UseFruitSkills
UseFruitSkills = function()
    weaponSc("Blox Fruit")
    if _G.FruitSkills.Z then Useskills("Blox Fruit","Z") end
    if _G.FruitSkills.X then Useskills("Blox Fruit","X") end
    if _G.FruitSkills.C then Useskills("Blox Fruit","C") end
    if _G.FruitSkills.V then Useskills("Blox Fruit","V") end
    if _G.FruitSkills.F then
        vim1:SendKeyEvent(true,"F",false,game)
        vim1:SendKeyEvent(false,"F",false,game)
    end
end

-- ================================================================
-- [I] G TABLE (ZYN exact G.Kill / G.Sword)
-- ================================================================
G = {}
G.__index = G

G.Alive = function(I)
    if not I then return end
    local e = I:FindFirstChild("Humanoid")
    return e and e.Health>0
end

-- ZYN exact G.Kill
G.Kill = function(I,e)
    if not (I and e) then return end
    local hrp = I:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if not I:GetAttribute("Locked") then
        I:SetAttribute("Locked", hrp.CFrame)
    end
    PosMon = (I:GetAttribute("Locked")).Position
    _B     = true
    BringEnemy()
    EquipWeapon(_G.SelectWeapon)
    local tool = plr.Character:FindFirstChildOfClass("Tool")
    if not tool then return end
    _tp(hrp.CFrame * CFrame.new(0, _G.MobHeight, 0))
end

-- ZYN exact G.Sword
G.Sword = function(I,e)
    if not (I and e) then return end
    if not I:GetAttribute("Locked") then
        I:SetAttribute("Locked", I.HumanoidRootPart.CFrame)
    end
    PosMon = (I:GetAttribute("Locked")).Position
    _B     = true
    BringEnemy()
    weaponSc("Sword")
    _tp(I.HumanoidRootPart.CFrame * CFrame.new(0,30,0))
end

-- ================================================================
-- [J] BRING ENEMY (ZYN exact BringEnemy + loop)
-- ================================================================
local TweenInfoBring = TweenInfo.new(0.45, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

local function IsRaidMob(mob)
    local n = mob.Name:lower()
    if n:find("raid") or n:find("microchip") or n:find("island") then return true end
    if mob:GetAttribute("IsRaid") or mob:GetAttribute("RaidMob") or mob:GetAttribute("IsBoss") then return true end
    local hum = mob:FindFirstChild("Humanoid")
    if hum and hum.WalkSpeed==0 then return true end
    return false
end

-- ZYN exact BringEnemy
BringEnemy = function()
    if not _B then return end
    local chr = plr.Character
    local hrp = chr and chr:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    pcall(function() sethiddenproperty(plr,"SimulationRadius",math.huge) end)
    local targetPos = PosMon or hrp.Position
    local enemies   = workspace.Enemies:GetChildren()
    local count     = 0
    for _,mob in ipairs(enemies) do
        if count >= _G.MaxBringMobs then break end
        local hum  = mob:FindFirstChild("Humanoid")
        local root = mob:FindFirstChild("HumanoidRootPart")
        if hum and root and hum.Health>0 and not IsRaidMob(mob) then
            local dist = (root.Position - targetPos).Magnitude
            if dist <= _G.BringRange and not root:GetAttribute("Tweening") then
                count += 1
                root:SetAttribute("Tweening",true)
                local tw = TweenService:Create(root, TweenInfoBring, {CFrame=CFrame.new(targetPos)})
                tw:Play()
                tw.Completed:Once(function()
                    if root then root:SetAttribute("Tweening",false) end
                end)
            end
        end
    end
end

-- ZYN exact bring loop
task.spawn(function()
    while task.wait(1) do
        if _G.XH_AutoFarm or _G.StartFarm then
            _B = true
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
-- [K] AUTO KEN (ZYN exact)
-- ================================================================
task.spawn(function()
    while _G.XH_AutoKen do
        task.wait(0.2)
        pcall(function()
            local chr = plr.Character
            if chr and not CollectionService:HasTag(chr,"Ken") then
                CE("Ken",true)
            end
        end)
    end
end)

-- ================================================================
-- [L] C ANCHOR PART + shouldTween LOOP (ZYN exact lines 1047-1172)
-- ================================================================

-- Clean up old anchor
local existing = workspace:FindFirstChild("Rip_Indra")
if existing then existing:Destroy() end

-- ZYN exact: create invisible anchor part C
local C = Instance.new("Part", workspace)
C.Size        = Vector3.new(1,1,1)
C.Name        = "Rip_Indra"
C.Anchored    = true
C.CanCollide  = false
C.CanTouch    = false
C.Transparency = 1

-- ZYN exact: OnFarm state loop
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

-- ZYN exact: character follows C when OnFarm
task.spawn(function()
    local I = plr
    repeat task.wait() until I.Character and I.Character.PrimaryPart
    C.CFrame = I.Character.PrimaryPart.CFrame
    while task.wait() do
        pcall(function()
            if getgenv().OnFarm then
                if C and C.Parent == workspace then
                    local e = I.Character and I.Character.PrimaryPart
                    if e then
                        if (e.Position - C.Position).Magnitude <= 200 then
                            e.CFrame = C.CFrame
                        else
                            C.CFrame = e.CFrame
                        end
                    end
                end
                -- Disable collisions while farming (ZYN exact)
                local e = I.Character
                if e then
                    for _,v in pairs(e:GetChildren()) do
                        if v:IsA("BasePart") then v.CanCollide = false end
                    end
                end
            else
                local e = I.Character
                if e then
                    for _,v in pairs(e:GetChildren()) do
                        if v:IsA("BasePart") then v.CanCollide = true end
                    end
                end
            end
        end)
    end
end)

-- ZYN exact: BodyVelocity + CanCollide loop (lines 1204-1232)
task.spawn(function()
    while task.wait() do
        pcall(function()
            if _G.XH_AutoFarm or _G.XH_AutoGhoul or _G.XH_AutoCyborg or
               _G.XH_AutoTushita or _G.XH_AutoBerry or _G.StartFarm then
                shouldTween = true
                local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp and not hrp:FindFirstChild("BodyClip") then
                    local bv = Instance.new("BodyVelocity")
                    bv.Name     = "BodyClip"
                    bv.Parent   = hrp
                    bv.MaxForce = Vector3.new(100000,100000,100000)
                    bv.Velocity = Vector3.new(0,0,0)
                end
                if plr.Character then
                    for _,e in pairs(plr.Character:GetDescendants()) do
                        if e:IsA("BasePart") then e.CanCollide = false end
                    end
                end
            else
                shouldTween = false
                local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local bv = hrp:FindFirstChild("BodyClip")
                    if bv then bv:Destroy() end
                end
                if plr.Character then
                    for _,e in pairs(plr.Character:GetDescendants()) do
                        if e:IsA("BasePart") then e.CanCollide = true end
                    end
                end
            end
        end)
    end
end)

-- ================================================================
-- [M] _tp FUNCTION (ZYN exact lines 1123-1172)
-- ================================================================
getgenv().TweenSpeedFar  = 300
getgenv().TweenSpeedNear = 900

_tp = function(I)
    local e = plr.Character
    if not e or not e:FindFirstChild("HumanoidRootPart") then return end
    local HRP = e.HumanoidRootPart
    shouldTween      = true
    getgenv().OnFarm = false
    if HRP.Anchored then HRP.Anchored=false; task.wait() end
    local dist  = (I.Position - HRP.Position).Magnitude
    local speed = dist<=90 and (getgenv().TweenSpeedNear or 900) or (getgenv().TweenSpeedFar or 300)
    local info  = TweenInfo.new(dist/speed, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(C, info, {CFrame=I})
    if e.Humanoid.Sit then
        C.CFrame = CFrame.new(C.Position.X, I.Y, C.Position.Z)
    end
    tween:Play()
    task.spawn(function()
        while tween.PlaybackState==Enum.PlaybackState.Playing do
            if not shouldTween then tween:Cancel(); break end
            task.wait(0.1)
        end
        getgenv().OnFarm = true
    end)
end

TeleportToTarget = _tp

-- ZYN exact notween
notween = function(I)
    plr.Character.HumanoidRootPart.CFrame = I
end

-- ================================================================
-- [N] __namecall HOOK (ZYN exact lines 767-784)
-- Redirects skill FireServer aim to MousePos (nearest enemy)
-- pcall-wrapped so if executor doesn't support it, it skips silently
-- ================================================================
pcall(function()
    local J = getrawmetatable(game)
    local i = J.__namecall
    setreadonly(J,false)
    J.__namecall = newcclosure(function(...)
        local I = getnamecallmethod()
        local e = {...}
        if tostring(I)=="FireServer" then
            if tostring(e[1])=="RemoteEvent" then
                if tostring(e[2])~="true" and tostring(e[2])~="false" then
                    if _G.XH_AutoFarm or _G.StartFarm then
                        e[2] = MousePos
                        return i(table.unpack(e))
                    end
                end
            end
        end
        return i(...)
    end)
    setreadonly(J,true)
end)

-- ================================================================
-- [O] AUTOMATIC AURA COMBAT ENGINE (Heartbeat - always running)
-- Melee + Sword + Fruit M1 fire automatically with no toggles
-- ================================================================
local atkTimer = 0
local AURA_ON = true  -- always ON per spec

RunService.Heartbeat:Connect(function(dt)
    if not AURA_ON then return end
    atkTimer = atkTimer + dt

    local chr = plr.Character
    if not chr then return end
    local hrp = chr:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Find nearest enemy
    local nearest, nDist = nil, math.huge
    for _,mob in pairs(workspace.Enemies:GetChildren()) do
        local mhrp = mob:FindFirstChild("HumanoidRootPart")
        local mhum = mob:FindFirstChild("Humanoid")
        if mhrp and mhum and mhum.Health>0 then
            local d = (hrp.Position - mhrp.Position).Magnitude
            if d < nDist then nDist=d; nearest=mob end
        end
    end

    if not nearest then return end
    local mhrp = nearest:FindFirstChild("HumanoidRootPart")
    if not mhrp then return end

    -- Update MousePos for __namecall hook
    MousePos = mhrp.Position
    PosMon   = mhrp.Position

    -- === MELEE AURA ===
    weaponSc("Melee")
    -- VirtualUser M1 click (triggers client animation)
    pcall(function()
        vim2:CaptureController()
        vim2:ClickButton1(Vector2.zero)
    end)
    -- Server-side M1 invoke
    pcall(function() CF("Click") end)
    -- Melee Z skill auto-aimed
    if atkTimer >= 0.35 then
        Useskills("Melee","Z")
        Useskills("Melee","X")
    end

    -- === SWORD AURA ===
    weaponSc("Sword")
    pcall(function()
        vim2:CaptureController()
        vim2:ClickButton1(Vector2.zero)
    end)
    pcall(function() CF("Click") end)
    if atkTimer >= 0.35 then
        Useskills("Sword","Z")
        Useskills("Sword","X")
    end

    -- === FRUIT AURA M1 + SKILLS ===
    -- Find fruit tool
    local fruitTool = nil
    for _,v in pairs(chr:GetChildren()) do
        if v:IsA("Tool") and v.ToolTip=="Blox Fruit" then fruitTool=v; break end
    end
    if not fruitTool then
        for _,v in pairs(plr.Backpack:GetChildren()) do
            if v:IsA("Tool") and v.ToolTip=="Blox Fruit" then
                -- auto-equip
                pcall(function() chr.Humanoid:EquipTool(v) end)
                task.wait(0.05)
                fruitTool = chr:FindFirstChildOfClass("Tool")
                break
            end
        end
    end
    if fruitTool then
        -- LeftClickRemote (direct fruit M1 damage)
        local lr = fruitTool:FindFirstChild("LeftClickRemote")
        if lr then
            local dir = (mhrp.Position - hrp.Position).Unit
            for _ = 1,6 do
                pcall(function() lr:FireServer(dir,1) end)
            end
        end
        pcall(function()
            vim2:CaptureController()
            vim2:ClickButton1(Vector2.zero)
        end)
        -- Fruit skills
        if atkTimer >= 0.4 then
            UseFruitSkills()
        end
    end

    if atkTimer >= 1 then atkTimer = 0 end
end)

-- ================================================================
-- [P] BOSS DATA TABLE (all bosses + exact spawn positions)
-- ================================================================
local BOSS_DATA = {
    -- Sea 3
    ["rip_indra"]           = {names={"rip_indra","Rip_Indra","rip_indra True Form"}, pos=CFrame.new(5228,5,845),       entrance=nil},
    ["Dough King"]          = {names={"Dough King"},             pos=CFrame.new(-3228,7,6098),     entrance=nil},
    ["Cake Prince"]         = {names={"Cake Prince"},            pos=CFrame.new(-1340,7,-11662),   entrance=nil},
    ["Soul Reaper"]         = {names={"Soul Reaper"},            pos=CFrame.new(-9524,315,6655),   entrance=nil},
    ["Tyrant of the Skies"] = {names={"Tyrant of the Skies","Tyrant"},pos=CFrame.new(-7882,5444,-366),entrance=nil},
    ["Longma"]              = {names={"Longma"},                 pos=CFrame.new(-10238,389,-9549), entrance=nil},
    ["Hydra Leader"]        = {names={"Hydra Leader"},           pos=CFrame.new(5251,5,1111),      entrance=nil},
    ["Kitsune Island"]      = {names={"Venomous Assailant"},     pos=CFrame.new(4692,797,858),     entrance=nil},
    ["Prehistoric Island"]  = {names={"Lava Golem","T-Rex"},     pos=CFrame.new(4620,1002,399),    entrance=nil},
    -- Sea 2
    ["Darkbeard"]           = {names={"Darkbeard"},              pos=CFrame.new(-9551,6,5796),     entrance=nil},
    ["Cursed Captain"]      = {names={"Cursed Captain"},         pos=CFrame.new(916.9,181.1,33422),entrance=Vector3.new(923.21,126.97,32852.83)},
    ["Order"]               = {names={"Order"},                  pos=CFrame.new(-6440,250,-5250),  entrance=nil},
    ["Elite Hunter"]        = {names={"Elite Hunter","Elite Pirate","Diablo","Deandre","Urban"},pos=CFrame.new(-5750,105,-4588),entrance=nil},
    ["Diamond"]             = {names={"Diamond"},                pos=CFrame.new(-5006,88,4353),    entrance=nil},
    ["Jeremy"]              = {names={"Jeremy"},                 pos=CFrame.new(2006.9,448.9,853.9),entrance=nil},
    ["Don Swan"]            = {names={"Don Swan"},               pos=CFrame.new(2286.2,15.1,863.8),entrance=nil},
    ["Darkbeard"]           = {names={"Darkbeard"},              pos=CFrame.new(-9551,6,5796),     entrance=nil},
}

-- Find boss by key
local function FindBoss(key)
    local d = BOSS_DATA[key]
    if not d then return nil end
    for _,name in ipairs(d.names) do
        local e = GetConnectionEnemies(name)
        if e then return e end
    end
    -- Partial search fallback
    for _,name in ipairs(d.names) do
        for _,K in pairs(workspace.Enemies:GetChildren()) do
            if K:IsA("Model") and Alive(K) and
               string.lower(K.Name):find(string.lower(name),1,true) then
                return K
            end
        end
    end
    return nil
end

-- ================================================================
-- [Q] AUTO FARM BOSS LOOP (uses G.Kill exactly like ZYN)
-- ================================================================
task.spawn(function()
    while task.wait(0.25) do
        if not _G.XH_AutoFarm then _B=false; continue end
        pcall(function()
            local key  = _G.XH_SelBoss
            local data = BOSS_DATA[key]
            if not data then return end
            local boss = FindBoss(key)
            if boss then
                G.Kill(boss, G.Alive(boss))
            else
                _B = false
                shouldTween = false
                if data.entrance then
                    CF("requestEntrance", data.entrance)
                    task.wait(1)
                end
                notween(data.pos)
                task.wait(2)
            end
        end)
    end
end)

-- ================================================================
-- [R] AUTO COLLECT BERRIES (ZYN collectFruits + scan)
-- ================================================================
task.spawn(function()
    while task.wait(0.15) do
        if not _G.XH_AutoBerry then continue end
        pcall(function()
            local chr = plr.Character
            if not chr then return end
            local hrp = chr:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            -- Method 1: CollectionService tagged BerryBush
            for _,bush in ipairs(CollectionService:GetTagged("BerryBush")) do
                pcall(function()
                    local p = bush.Parent
                    if p then hrp.CFrame = p:GetPivot() end
                    task.wait(0.05)
                end)
            end

            -- Method 2: Workspace scan for berry parts by name
            for _,obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Parent~=chr then
                    local n = string.lower(obj.Name)
                    if n=="redcherry" or n=="blueicicle" or n=="greentoad" or
                       n=="orangefruit" or n:find("berry") then
                        hrp.CFrame = obj.CFrame
                        task.wait(0.05)
                    end
                end
            end

            -- Method 3: ZYN collectFruits
            collectFruits(true)

            -- Method 4: Berry spawn positions per world
            local spots = World1 and {
                CFrame.new(885,5,4400), CFrame.new(-1600,35,150), CFrame.new(1050,27,1560)
            } or World2 and {
                CFrame.new(-428,71,1836), CFrame.new(638,71,918),
                CFrame.new(-2440,71,-3216), CFrame.new(-5497,47,-795)
            } or {
                CFrame.new(-12682,390,-9902), CFrame.new(5000,20,-500)
            }
            for _,cf in ipairs(spots) do
                if not _G.XH_AutoBerry then break end
                notween(cf)
                task.wait(1.5)
                collectFruits(true)
            end
        end)
    end
end)

-- ================================================================
-- [S] AUTO CYBORG RACE (full 4-step process)
-- ================================================================
local cybStep = 1
task.spawn(function()
    while task.wait(0.6) do
        if not _G.XH_AutoCyborg then cybStep=1; continue end
        pcall(function()
            if cybStep==1 then
                -- Need Fist of Darkness
                if GetBP("Fist of Darkness") then cybStep=2; return end
                -- Farm sea beast / enemies that drop it
                local sb = workspace.SeaBeasts and workspace.SeaBeasts:FindFirstChild("SeaBeast1")
                if sb and Alive(sb) then
                    G.Kill(sb, true)
                else
                    -- Go to sea area
                    if World2 then notween(CFrame.new(-7000,5,-5000))
                    elseif World3 then notween(CFrame.new(0,5,-8000)) end
                end

            elseif cybStep==2 then
                if not GetBP("Fist of Darkness") then cybStep=1; return end
                local frags = 0
                pcall(function() frags = tonumber(plr.Data.Fragments.Value) or 0 end)
                if frags < 1000 then
                    local b = GetConnectionEnemies("Darkbeard") or GetConnectionEnemies("Order")
                    if b then G.Kill(b, G.Alive(b)) end
                    return
                end
                notween(CFrame.new(-6440,250,-5250))
                task.wait(0.5)
                CF("BuyMicrochip")
                task.wait(0.5)
                CF("StartRaid","Law")
                task.wait(2)
                cybStep = 3

            elseif cybStep==3 then
                if GetBP("Core Brain") then cybStep=4; return end
                local order = GetConnectionEnemies("Order")
                if order then G.Kill(order, G.Alive(order))
                else notween(CFrame.new(-6440,250,-5250)) end

            elseif cybStep==4 then
                if not GetBP("Core Brain") then cybStep=3; return end
                notween(CFrame.new(6094,73,3825))
                task.wait(0.8)
                CF("CyborgTrainer","Buy")
                task.wait(1)
                _G.XH_AutoCyborg = false
                cybStep = 1
            end
        end)
    end
end)

-- ================================================================
-- [T] AUTO GHOUL RACE (ZYN exact Ectoplasm logic)
-- CommF_:InvokeServer("Ectoplasm","Buy",3) then ("Ectoplasm","Change",4)
-- ================================================================
task.spawn(function()
    while task.wait(0.5) do
        if not _G.XH_AutoGhoul then continue end
        pcall(function()
            local ecto = tonumber(GetM("Ectoplasm")) or 0
            if ecto < 99 then
                -- Farm Cursed Captain for ecto
                local cap = GetConnectionEnemies("Cursed Captain")
                if cap then
                    G.Kill(cap, G.Alive(cap))
                else
                    -- Go to Cursed Ship (ZYN exact coords)
                    CF("requestEntrance", Vector3.new(923.21252441406, 126.9760055542, 32852.83203125))
                    task.wait(1.5)
                    notween(CFrame.new(916.928589, 181.092773, 33422))
                    task.wait(3)
                end
            else
                -- Buy Ghoul (ZYN exact)
                CF("Ectoplasm","Buy",3)
                task.wait(0.5)
                CF("Ectoplasm","Change",4)
                task.wait(0.5)
                _G.XH_AutoGhoul = false
            end
        end)
    end
end)

-- ================================================================
-- [U] AUTO TUSHITA (5-brazier sequence)
-- ================================================================
local tushStep    = 1
local brazierDone = 0
local BRAZIERS = {
    CFrame.new(5563.42,5.18,-1249.7),
    CFrame.new(6035.8,86.5,-1458.3),
    CFrame.new(5820.4,5.0,-1835.6),
    CFrame.new(5432.1,5.0,-2014.8),
    CFrame.new(5070.5,12.0,-1634.2),
}
task.spawn(function()
    while task.wait(0.5) do
        if not _G.XH_AutoTushita then tushStep=1; brazierDone=0; continue end
        pcall(function()
            if tushStep==1 then
                local indra = GetConnectionEnemies("rip_indra") or GetConnectionEnemies("Rip_Indra")
                if indra then task.wait(5); return end
                tushStep = 2
            elseif tushStep==2 then
                notween(CFrame.new(5228,5,845))
                task.wait(1.5)
                tushStep = 3
            elseif tushStep==3 then
                notween(CFrame.new(5228,5,960))
                task.wait(1)
                -- Fire proximity prompts near entrance
                local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _,obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("ProximityPrompt") then
                            local d = (hrp.Position - obj.Parent.Position).Magnitude
                            if d < 20 then pcall(function() fireproximityprompt(obj) end) end
                        end
                    end
                end
                brazierDone = 0
                tushStep    = 4
            elseif tushStep==4 then
                if brazierDone >= 5 then tushStep=5; return end
                local bCF = BRAZIERS[brazierDone+1]
                notween(bCF)
                task.wait(0.8)
                local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _,obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("ProximityPrompt") then
                            local d = (hrp.Position - obj.Parent.Position).Magnitude
                            if d < 15 then pcall(function() fireproximityprompt(obj) end) end
                        end
                    end
                end
                pcall(function() CF("LightBrazier", brazierDone+1) end)
                task.wait(0.3)
                brazierDone += 1
            elseif tushStep==5 then
                local longma = GetConnectionEnemies("Longma")
                if longma then
                    G.Kill(longma, G.Alive(longma))
                    repeat task.wait(0.5) until not Alive(longma) or not _G.XH_AutoTushita
                    tushStep = 6
                else
                    notween(CFrame.new(-10238,389,-9549))
                    task.wait(3)
                end
            elseif tushStep==6 then
                for _,obj in pairs(workspace:GetDescendants()) do
                    if obj.Name=="Tushita" then
                        local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then pcall(function() hrp.CFrame = obj.CFrame end) end
                        task.wait(0.3)
                    end
                end
                _G.XH_AutoTushita = false
                tushStep=1; brazierDone=0
            end
        end)
    end
end)

-- ================================================================
-- [V] AUTO LEGENDARY SWORD BUYER
-- ================================================================
local LEG_SWORDS = {"Saddi","Wando","Shisui","True Triple Katana"}
task.spawn(function()
    while task.wait(0.5) do
        if not _G.XH_AutoLegSword then continue end
        pcall(function()
            -- Check LegendarySwordDealer remote
            local s1 = CF("LegendarySwordDealer","1")
            local s2 = CF("LegendarySwordDealer","2")
            local s3 = CF("LegendarySwordDealer","3")
            if s1 then notween(CFrame.new(-3228,7,6098)); task.wait(0.3); CF("BuyItem","Shisui") end
            if s2 then notween(CFrame.new(-3228,7,6098)); task.wait(0.3); CF("BuyItem","Wando")  end
            if s3 then notween(CFrame.new(-3228,7,6098)); task.wait(0.3); CF("BuyItem","Saddi")  end
            -- Direct buy fallback
            for _,sw in ipairs(LEG_SWORDS) do
                pcall(function() CF("BuyItem",sw) end)
                task.wait(0.2)
            end
        end)
    end
end)

-- ================================================================
-- [W] CHARACTER RESPAWN HANDLER
-- ================================================================
plr.CharacterAdded:Connect(function(chr)
    task.wait(0.5)
    repeat task.wait() until chr:FindFirstChild("HumanoidRootPart")
    Root = chr.HumanoidRootPart
    C.CFrame = Root.CFrame
    shouldTween = false
    _B          = false
    task.wait(2)
    if _G.XH_AutoKen then CE("Ken",true) end
end)

-- ================================================================
-- [X] SERVER HOP ENGINE (17 Night Hub API endpoints)
-- ================================================================
local API_TABS = {
    {Name="Full Moon",           Key="Fullmoon",         URL="http://nighthub.site/boss/Fullmoon"},
    {Name="Near Moon",           Key="NearMoon",         URL="http://nighthub.site/boss/NearMoon"},
    {Name="Mirage Island",       Key="Mirage",           URL="http://nighthub.site/boss/Mirage"},
    {Name="Sword Legendary",     Key="SwordLegendary",   URL="http://nighthub.site/boss/SwordLegendary"},
    {Name="Haki Legendary",      Key="HakiLegendary",    URL="http://nighthub.site/boss/HakiLegendary"},
    {Name="Berry",               Key="Berry",            URL="http://nighthub.site/boss/Berry"},
    {Name="Rip Indra",           Key="RipIndra",         URL="http://nighthub.site/boss/RipIndra"},
    {Name="Dough King",          Key="DoughKing",        URL="http://nighthub.site/boss/DoughKing"},
    {Name="Darkbeard",           Key="Darkbeard",        URL="http://nighthub.site/boss/Darkbeard"},
    {Name="Kitsune Island",      Key="KitsuneIsland",    URL="http://nighthub.site/boss/KitsuneIsland"},
    {Name="Soul Reaper",         Key="SoulReaper",       URL="http://nighthub.site/boss/SoulReaper"},
    {Name="Cake Prince",         Key="CakePrince",       URL="http://nighthub.site/boss/CakePrince"},
    {Name="Castle Raid",         Key="CastleRaid",       URL="http://nighthub.site/boss/CastleRaid"},
    {Name="Elite",               Key="Elite",            URL="http://nighthub.site/boss/Elite"},
    {Name="Cursed Captain",      Key="CursedCaptain",    URL="http://nighthub.site/boss/CursedCaptain"},
    {Name="Tyrant Of The Skies", Key="TyrantOfTheSkies", URL="http://nighthub.site/boss/TyrantOfTheSkies"},
    {Name="Prehistoric Island",  Key="PrehistoricIsland",URL="http://nighthub.site/boss/PrehistoricIsland"},
}

local SrvCache = {}
local SrvSel   = {}
local SrvRaw   = {}
for _,ev in ipairs(API_TABS) do SrvCache[ev.Key]={}; SrvSel[ev.Key]=nil; SrvRaw[ev.Key]={} end

local function FetchServers(ev)
    -- Cache buster: append ?v=os.time()
    local url = ev.URL.."?v="..os.time()
    local ok,res = pcall(function() return game:HttpGet(url,true) end)
    if not ok or not res or res=="" or res=="[]" or res=="null" then
        return nil,"API returned empty"
    end
    local ok2,data = pcall(function() return HttpService:JSONDecode(res) end)
    if not ok2 or type(data)~="table" then return nil,"JSON parse error" end

    local valid = {}
    for _,s in ipairs(data) do
        -- Anti-self-join: skip current server
        if tostring(s.PlaceId)==tostring(placeId) and
           tostring(s.JobId) ~= JobId             and
           tostring(s.JobId) ~= "" then
            table.insert(valid, s)
        end
    end
    -- Sort by Age ascending (youngest = boss most likely alive)
    table.sort(valid, function(a,b) return tonumber(a.Age or 9999)<tonumber(b.Age or 9999) end)
    return valid, nil
end

-- Spawn-verification heuristic
local function BossLikelyAlive(s)
    return tonumber(s.Age or 999)<=90 and tonumber(s.Players or 12)<12
end

-- ZYN-style Hop (public server fallback)
local function HopPublic()
    pcall(function()
        local Http  = HttpService
        local place = placeId
        local api   = "https://games.roblox.com/v1/games/"..place.."/servers/Public?sortOrder=Asc&limit=100"
        local raw   = game:HttpGet(api,true)
        local data  = Http:JSONDecode(raw)
        if data and data.data then
            for _,srv in pairs(data.data) do
                if tonumber(srv.playing) < 12 and tostring(srv.id)~=JobId then
                    task.wait(1)
                    TeleportService:TeleportToPlaceInstance(place, srv.id, plr)
                    return
                end
            end
        end
    end)
end

-- Teleport with anti-kick + server-full fallback
local function DoTP(jobId, fallback, onErr)
    task.wait(1)  -- anti-kick
    local ok,err = pcall(function()
        TeleportService:TeleportToPlaceInstance(placeId, jobId, plr)
    end)
    if not ok then
        if fallback and #fallback>0 then
            local nxt = table.remove(fallback,1)
            if onErr then onErr("Server full, trying next...") end
            task.wait(2)
            DoTP(tostring(nxt.JobId), fallback, onErr)
        else
            if onErr then onErr("All servers failed. Trying public hop...") end
            HopPublic()
        end
    end
end

-- Persistent re-execution on teleport
pcall(function()
    if queue_on_teleport then
        queue_on_teleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/XicoSkelly/XicoHub/main/XicoHub_Ultimate.lua',true))()")
    end
end)

-- ================================================================
-- [Y] FLUENT UI (3-URL fallback load)
-- ================================================================
local Fluent
local FLUENT_URLS = {
    "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua",
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/main.lua",
    "https://cdn.jsdelivr.net/gh/dawid-scripts/Fluent@master/main.lua",
}
for _,url in ipairs(FLUENT_URLS) do
    local ok,result = pcall(function()
        return loadstring(game:HttpGet(url,true))()
    end)
    if ok and result then Fluent=result; break end
    task.wait(0.5)
end
assert(Fluent, "XICO HUB: Failed to load Fluent UI. Enable HTTP in executor settings.")

local function Notify(t,c,d)
    pcall(function() Fluent:Notify({Title=t,Content=c,Duration=d or 3}) end)
end

-- ================================================================
-- [Z] CREATE WINDOW  (40% of screen = UDim2.fromScale(0.4, 0.4))
-- ================================================================
local Window = Fluent:CreateWindow({
    Title       = "Xico Hub | Hop",
    SubTitle    = "made by @alifgamer",
    TabWidth    = 110,
    Size        = UDim2.fromScale(0.4, 0.4),
    Acrylic     = false,
    Theme       = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl,
})

-- ================================================================
-- [Z1] FARM TAB
-- ================================================================
local FT = Window:AddTab({Title="Farm", Icon="sword"})

FT:AddSection("Combat (Auto-Active)")

FT:AddParagraph({
    Title = "Aura Status",
    Desc  = "Melee + Sword + Fruit M1 aura are ALWAYS active.\nNo toggle needed - runs automatically."
})

FT:AddSection("Boss Farm")

local BOSS_VALS = {
    "rip_indra","Darkbeard","Dough King","Cake Prince","Soul Reaper",
    "Cursed Captain","Tyrant of the Skies","Elite Hunter","Longma",
    "Order","Kitsune Island","Prehistoric Island","Diamond","Jeremy","Don Swan","Hydra Leader",
}

FT:AddDropdown("BossDrop",{
    Title   = "Select Boss",
    Values  = BOSS_VALS,
    Default = 1,
    Callback = function(v) _G.XH_SelBoss = v end
})

FT:AddToggle("AutoFarm",{
    Title   = "▶ Farm Boss",
    Default = false,
    Callback = function(v)
        _G.XH_AutoFarm = v
        _G.StartFarm   = v
        if not v then _B=false; shouldTween=false end
        if v then Notify("Farm Boss","Farming: ".._G.XH_SelBoss,2) end
    end
})

FT:AddButton({
    Title    = "Teleport To Boss Spawn",
    Callback = function()
        local d = BOSS_DATA[_G.XH_SelBoss]
        if d then
            if d.entrance then CF("requestEntrance",d.entrance); task.wait(1) end
            notween(d.pos)
            Notify("TP","Going to ".._G.XH_SelBoss,2)
        else
            Notify("Error","No spawn data for ".._G.XH_SelBoss,2)
        end
    end
})

FT:AddSection("Bring & Utilities")

FT:AddToggle("BringMobs",{
    Title="Bring Mobs To Player", Default=false,
    Callback=function(v) _G.XH_BringMobs=v; _B=v end
})

FT:AddSlider("MobH",{
    Title="Height Above Boss",Min=5,Max=100,Default=20,Rounding=0,
    Callback=function(v) _G.MobHeight=v end
})

FT:AddSlider("MaxBring",{
    Title="Max Bring Mobs",Min=1,Max=15,Default=3,Rounding=0,
    Callback=function(v) _G.MaxBringMobs=v end
})

FT:AddToggle("AutoBerry",{
    Title="Auto Collect Berries", Default=false,
    Callback=function(v) _G.XH_AutoBerry=v end
})

FT:AddToggle("AutoKen",{
    Title="Auto Observation Haki (Ken)", Default=true,
    Callback=function(v) _G.XH_AutoKen=v end
})

FT:AddSection("Fruit Skills")

FT:AddToggle("FZ",{Title="Fruit Z Skill",Default=true, Callback=function(v) _G.FruitSkills.Z=v end})
FT:AddToggle("FX",{Title="Fruit X Skill",Default=false,Callback=function(v) _G.FruitSkills.X=v end})
FT:AddToggle("FC",{Title="Fruit C Skill",Default=false,Callback=function(v) _G.FruitSkills.C=v end})
FT:AddToggle("FV",{Title="Fruit V Skill",Default=false,Callback=function(v) _G.FruitSkills.V=v end})

-- ================================================================
-- [Z2] RACE TAB
-- ================================================================
local RT = Window:AddTab({Title="Race", Icon="user"})

RT:AddSection("Cyborg Race")
RT:AddParagraph({Title="Steps",Desc="1.Fist of Darkness\n2.1000 Frags → Law Raid\n3.Kill Order → Core Brain\n4.Buy Cyborg"})
RT:AddToggle("ACyborg",{
    Title="Auto Cyborg Race",Default=false,
    Callback=function(v) _G.XH_AutoCyborg=v; cybStep=1
        if v then Notify("Cyborg","Step 1: Getting Fist of Darkness...",3) end
    end
})
RT:AddButton({Title="Buy Cyborg (Manual)",Callback=function()
    CF("CyborgTrainer","Buy"); Notify("Cyborg","Buy sent!",2)
end})

RT:AddSection("Ghoul Race")
RT:AddParagraph({Title="Steps",Desc="Farm 99 Ectoplasm from Cursed Captain → Buy Ghoul"})
RT:AddToggle("AGhoul",{
    Title="Auto Ghoul Race",Default=false,
    Callback=function(v) _G.XH_AutoGhoul=v
        if v then Notify("Ghoul","Farming Cursed Captain...",3) end
    end
})
RT:AddButton({Title="Buy Ghoul (needs 99 Ecto)",Callback=function()
    CF("Ectoplasm","Buy",3); task.wait(0.3); CF("Ectoplasm","Change",4)
    Notify("Ghoul","Buy sent!",2)
end})

RT:AddSection("Tushita Sword")
RT:AddParagraph({Title="Steps",Desc="Indra dead→Portal→5 Braziers→Kill Longma→Collect"})
RT:AddToggle("ATushita",{
    Title="Auto Tushita Quest",Default=false,
    Callback=function(v) _G.XH_AutoTushita=v; tushStep=1; brazierDone=0
        if v then Notify("Tushita","Checking Rip Indra...",3) end
    end
})

RT:AddSection("Legendary Swords")
RT:AddToggle("ALegSword",{
    Title="Auto Buy Legendary Swords",Default=false,
    Callback=function(v) _G.XH_AutoLegSword=v end
})
for _,sw in ipairs(LEG_SWORDS) do
    RT:AddButton({Title="Buy "..sw,Callback=function()
        CF("BuyItem",sw); Notify("Shop","Buying "..sw,2)
    end})
end

RT:AddSection("Race Quick Actions")
RT:AddButton({Title="Random Race (3000F)",Callback=function()
    CF("BlackbeardReward","Reroll","1"); CF("BlackbeardReward","Reroll","2")
    Notify("Race","Random race sent!",2)
end})
RT:AddButton({Title="Reset Stats (2500F)",Callback=function()
    CF("BlackbeardReward","Refund","1"); CF("BlackbeardReward","Refund","2")
    Notify("Stats","Stats reset sent!",2)
end})

-- ================================================================
-- [Z3] SERVER HOP TABS (all 17 API endpoints)
-- ================================================================
local DropRefs = {}

for _,ev in ipairs(API_TABS) do
    local tab = Window:AddTab({Title=ev.Name, Icon="globe"})
    tab:AddSection(ev.Name.." — Live Servers")

    local dd = tab:AddDropdown("D_"..ev.Key,{
        Title="Available Servers",
        Values={"[ Press Refresh Below ]"},
        Default=1,
        Callback=function(v) SrvSel[ev.Key]=v end
    })
    DropRefs[ev.Key] = dd

    -- REFRESH
    tab:AddButton({
        Title="🔄 Refresh Servers",
        Description="Cache-busted live fetch from NightHub API",
        Callback=function()
            Notify("Fetching",ev.Name.."...",1)
            task.spawn(function()
                local svrs,err = FetchServers(ev)
                if not svrs or #svrs==0 then
                    dd:SetValues({"[ No Servers Found ]"}); dd:SetValue("[ No Servers Found ]")
                    SrvCache[ev.Key]={}; SrvRaw[ev.Key]={}
                    Notify("Empty",err or "No servers for "..ev.Name,3)
                    return
                end
                local labels,map = {},{}
                SrvRaw[ev.Key] = svrs
                for i,s in ipairs(svrs) do
                    local tag = BossLikelyAlive(s) and "✅ " or "⏳ "
                    local lbl = string.format("%s#%d | Age:%ss | %s/12",tag,i,tostring(s.Age or "?"),tostring(s.Players or "?"))
                    table.insert(labels,lbl); map[lbl]=tostring(s.JobId)
                end
                SrvCache[ev.Key]=map; SrvSel[ev.Key]=labels[1]
                dd:SetValues(labels); dd:SetValue(labels[1])
                Notify("Done!",#labels.." servers for "..ev.Name,3)
            end)
        end
    })

    -- JOIN SELECTED
    tab:AddButton({
        Title="🚀 Join Selected Server",
        Description="TeleportToPlaceInstance(PlaceId, JobId)",
        Callback=function()
            local sel = SrvSel[ev.Key]
            local map = SrvCache[ev.Key]
            if not sel or not map or not map[sel] then
                Notify("Error","Refresh first then select a server!",2); return
            end
            local jId = map[sel]
            if jId==JobId then Notify("Skip","Already in this server!",2); return end
            Notify("Teleporting","Joining "..ev.Name.."...",4)
            local fb={}
            for _,s in ipairs(SrvRaw[ev.Key] or {}) do
                if tostring(s.JobId)~=jId and tostring(s.JobId)~=JobId then table.insert(fb,s) end
            end
            DoTP(jId, fb, function(m) Notify("Info",m,3) end)
        end
    })

    -- AUTO HOP (best alive server)
    tab:AddButton({
        Title="🔁 Auto Hop (Best Server)",
        Description="Refresh + teleport to freshest alive server",
        Callback=function()
            Notify("Auto Hop","Scanning "..ev.Name.."...",2)
            task.spawn(function()
                local svrs,err = FetchServers(ev)
                if not svrs or #svrs==0 then Notify("Failed",err or "No servers",3); return end
                SrvRaw[ev.Key]=svrs
                local ordered={}
                for _,s in ipairs(svrs) do if BossLikelyAlive(s) then table.insert(ordered,s) end end
                for _,s in ipairs(svrs) do if not BossLikelyAlive(s) then table.insert(ordered,s) end end
                if #ordered==0 then Notify("None","No valid servers",3); return end
                local best = table.remove(ordered,1)
                Notify("Hopping→"..ev.Name,
                    string.format("Age:%ss | %s/12",tostring(best.Age or"?"),tostring(best.Players or"?")),4)
                DoTP(tostring(best.JobId), ordered, function(m) Notify("Info",m,3) end)
            end)
        end
    })
end

-- ================================================================
-- [Z4] SETTINGS TAB
-- ================================================================
local ST = Window:AddTab({Title="Settings", Icon="settings"})

ST:AddSection("Tween Speed")
ST:AddSlider("TwnFar",{Title="Speed Far (>90 studs)",Min=50,Max=1000,Default=300,Rounding=0,
    Callback=function(v) getgenv().TweenSpeedFar=v end})
ST:AddSlider("TwnNear",{Title="Speed Near (≤90 studs)",Min=100,Max=2000,Default=900,Rounding=0,
    Callback=function(v) getgenv().TweenSpeedNear=v end})

ST:AddSection("Misc")
ST:AddButton({Title="Redeem All Codes",Callback=function()
    local codes={"LIGHTNINGABUSE","1LOSTADMIN","ADMINFIGHT","GIFTING_HOURS","NOMOREHACK","BANEXPLOIT",
        "WildDares","BossBuild","GetPranked","EARN_FRUITS","SUB2GAMERROBOT_RESET1","KITT_RESET",
        "Bignews","CHANDLER","Fudd10","fudd10_v2","Sub2UncleKizaru","FIGHT4FRUIT","kittgaming",
        "TRIPLEABUSE","Sub2CaptainMaui","Sub2Fer999","Enyu_is_Pro","Magicbus","JCWK",
        "Starcodeheo","Bluxxy","SUB2GAMERROBOT_EXP1","Sub2NoobMaster123","Sub2Daigrock",
        "Axiore","TantaiGaming","StrawHatMaine","Sub2OfficialNoobie","TheGreatAce",
        "JULYUPDATE_RESET","ADMINHACKED","SEATROLLING","24NOADMIN","ADMIN_TROLL",
        "NOEXPLOIT","NOOB2ADMIN","CODESLIDE","fruitconcepts","krazydares"}
    local rem = ReplicatedStorage.Remotes:FindFirstChild("Redeem")
    if rem then
        for _,c in ipairs(codes) do
            task.wait(0.05)
            pcall(function()
                if rem.InvokeServer then rem:InvokeServer(c) else rem:FireServer(c) end
            end)
        end
        Notify("Codes","All codes attempted!",3)
    else Notify("Error","Redeem remote not found",2) end
end})
ST:AddButton({Title="Detect World",Callback=function()
    local w=World1 and "Sea 1" or World2 and "Sea 2" or World3 and "Sea 3" or "Unknown"
    Notify("World",w.." | PlaceId:"..tostring(placeId),4)
end})
ST:AddButton({Title="Public Server Hop",Callback=function()
    HopPublic(); Notify("Hop","Hopping to random server...",3)
end})

-- ================================================================
-- SELECT FIRST TAB
-- ================================================================
Window:SelectTab(1)

-- ================================================================
-- [Z5] FLOATING TOGGLE BUTTON (Asset 84090982489875, Cyan, Draggable)
-- ================================================================
pcall(function()
    local old = CoreGui:FindFirstChild("XicoHubTog10")
    if old then old:Destroy() end
end)

local TogGui = Instance.new("ScreenGui")
TogGui.Name           = "XicoHubTog10"
TogGui.ResetOnSpawn   = false
TogGui.IgnoreGuiInset = true
TogGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
TogGui.Parent         = CoreGui

local TogFrame = Instance.new("Frame",TogGui)
TogFrame.Size            = UDim2.fromOffset(54,54)
TogFrame.Position        = UDim2.new(0,5,0.43,0)
TogFrame.BackgroundColor3= Color3.fromRGB(0,185,210)
TogFrame.BorderSizePixel = 0
TogFrame.ZIndex          = 19
Instance.new("UICorner",TogFrame).CornerRadius = UDim.new(0,13)
local tbS = Instance.new("UIStroke",TogFrame)
tbS.Color=Color3.fromRGB(0,255,255); tbS.Thickness=2.5

local TogBtn = Instance.new("ImageButton",TogFrame)
TogBtn.Size               = UDim2.fromScale(1,1)
TogBtn.BackgroundTransparency = 1
TogBtn.Image              = "rbxassetid://84090982489875"
TogBtn.ImageColor3        = Color3.fromRGB(0,255,255)
TogBtn.ScaleType          = Enum.ScaleType.Fit
TogBtn.ZIndex             = 20
TogBtn.Active             = true

local drg,drStart,frStart,drIn,drMov = false,nil,nil,nil,0
TogBtn.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        drg=true; drStart=i.Position; frStart=TogFrame.Position; drMov=0
    end
end)
TogBtn.InputChanged:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then drIn=i end
end)
UserInputService.InputChanged:Connect(function(i)
    if i==drIn and drg then
        local d=i.Position-drStart; drMov=d.Magnitude
        TogFrame.Position=UDim2.new(frStart.X.Scale,frStart.X.Offset+d.X,frStart.Y.Scale,frStart.Y.Offset+d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drg=false end
end)
TogBtn.MouseButton1Click:Connect(function()
    if drMov>6 then drMov=0; return end; drMov=0
    vim1:SendKeyEvent(true, Enum.KeyCode.RightControl, false, game)
    task.wait(0.05)
    vim1:SendKeyEvent(false, Enum.KeyCode.RightControl, false, game)
end)

-- ================================================================
-- DONE
-- ================================================================
Notify("Xico Hub V10","Loaded! Aura auto-active. Tap cyan icon.",6)
task.wait(3)
Notify("Combat","Melee+Sword+Fruit M1 firing on heartbeat.",4)

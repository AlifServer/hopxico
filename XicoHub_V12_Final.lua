-- ================================================================
-- XICO HUB | HOP  |  V12  |  made by @alifgamer
-- Based on ZYN Hub Free Source (exact lines copied)
-- Fluent UI | Delta/Fluxus/Synapse compatible
-- loadstring: game:HttpGet("https://raw.githubusercontent.com/AlifServer/hopxico/refs/heads/main/Vx10.lua")
-- ================================================================

--[[
════════════════════════════════════════════════
  GETGENV CONFIG — paste BEFORE your loadstring
════════════════════════════════════════════════
getgenv().XicoConfig = {
    Team         = "Marines",   -- "Marines" | "Pirates"
    AutoFarm     = false,
    SelBoss      = "rip_indra",
    AutoBerry    = false,
    AutoCyborg   = false,
    AutoGhoul    = false,
    AutoTushita  = false,
    AutoLegSword = false,
    AutoKen      = true,
    BringMobs    = false,
    MobHeight    = 20,
    TweenFar     = 300,
    TweenNear    = 900,
    BringRange   = 235,
    MaxBringMobs = 3,
    FruitZ       = true,
    FruitX       = false,
    FruitC       = false,
    FruitV       = false,
}
]]

-- ================================================================
-- [1] CONFIG READ
-- ================================================================
local Cfg = getgenv().XicoConfig or {}
local function Cv(k, def)
    local v = Cfg[k]; if v ~= nil then return v end; return def
end

-- ================================================================
-- [2] WAIT FOR GAME
-- ================================================================
repeat task.wait() until game:IsLoaded()

-- ================================================================
-- [3] SERVICES  (setmetatable style from ZYN)
-- ================================================================
local Services = setmetatable({}, {
    __index = function(s, n)
        local ok, svc = pcall(function() return game:GetService(n) end)
        if ok then rawset(s, n, svc); return svc end
    end
})

local TweenService        = Services.TweenService
local TeleportService     = Services.TeleportService
local Players             = Services.Players
local ReplicatedStorage   = Services.ReplicatedStorage
local HttpService         = Services.HttpService
local RunService          = Services.RunService
local VIM1                = Services.VirtualInputManager
local VIM2                = Services.VirtualUser
local CollectionService   = Services.CollectionService
local Lighting            = Services.Lighting
local CoreGui             = Services.CoreGui
local UIS                 = Services.UserInputService

-- ================================================================
-- [4] PLAYER  (wait for character)
-- ================================================================
local plr = Players.LocalPlayer
repeat task.wait() until plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")

-- ZYN exact globals
ply        = Players
replicated = ReplicatedStorage
TW         = TweenService
vim1       = VIM1
vim2       = VIM2
RunSer     = RunService

Root = plr.Character.HumanoidRootPart

-- World detection (ZYN exact lines 144-153)
local placeId = game.PlaceId
local JobId   = game.JobId
World1, World2, World3 = false, false, false
if placeId == 2753915549 or placeId == 85211729168715 then     World1 = true
elseif placeId == 4442272183 or placeId == 79091703265657 then World2 = true
elseif placeId == 7449423635 or placeId == 100117331123089 then World3 = true
end

-- ================================================================
-- [5] REMOTES
-- ================================================================
local _CommF, _CommE
pcall(function()
    local rem = ReplicatedStorage:WaitForChild("Remotes", 10)
    _CommF = rem:WaitForChild("CommF_", 10)
    _CommE = rem:WaitForChild("CommE", 10)
end)

local function CF(...)
    if not _CommF then return nil end
    local ok, r = pcall(function() return _CommF:InvokeServer(...) end)
    if ok then return r end
end
local function CE(...) pcall(function() _CommE:FireServer(...) end) end

-- ================================================================
-- [6] FLAGS  (from config, ZYN exact globals)
-- ================================================================
shouldTween  = false
SoulGuitar   = false
RandomCFrame = false
Sec          = 0.1
ClickState   = 0
Num_self     = 25
_B           = false
PosMon       = nil
MousePos     = Vector3.new(0,0,0)

_G.MobHeight    = Cv("MobHeight",   20)
_G.BringRange   = Cv("BringRange",  235)
_G.MaxBringMobs = Cv("MaxBringMobs",3)
_G.SelectWeapon = nil
_G.StartFarm    = false

_G.FruitSkills  = {
    Z = Cv("FruitZ", true), X = Cv("FruitX",false),
    C = Cv("FruitC",false), V = Cv("FruitV",false), F = false,
}

-- Xico Hub flags
_G.XH_AutoFarm     = Cv("AutoFarm",    false)
_G.XH_SelBoss      = Cv("SelBoss",     "rip_indra")
_G.XH_AutoBerry    = Cv("AutoBerry",   false)
_G.XH_AutoCyborg   = Cv("AutoCyborg",  false)
_G.XH_AutoGhoul    = Cv("AutoGhoul",   false)
_G.XH_AutoTushita  = Cv("AutoTushita", false)
_G.XH_AutoLegSword = Cv("AutoLegSword",false)
_G.XH_AutoKen      = Cv("AutoKen",     true)
_G.XH_BringMobs    = Cv("BringMobs",   false)

getgenv().TweenSpeedFar  = Cv("TweenFar",  300)
getgenv().TweenSpeedNear = Cv("TweenNear", 900)

-- ================================================================
-- [7] TEAM JOIN  (ZYN exact lines 80-86)
-- ================================================================
local desiredTeam = Cv("Team","Marines")
pcall(function()
    if not plr.Team or plr.Team.Name ~= desiredTeam then
        CF("SetTeam", desiredTeam)
    end
end)

Marines = function() pcall(function() CF("SetTeam","Marines") end) end
Pirates = function() pcall(function() CF("SetTeam","Pirates") end) end

-- ================================================================
-- [8] LIGHTING / LowCpu  (ZYN exact LowCpu + lines 88-96)
-- ================================================================
pcall(function()
    Lighting.Ambient           = Color3.new(0.695,0.695,0.695)
    Lighting.ColorShift_Bottom = Color3.new(0.695,0.695,0.695)
    Lighting.ColorShift_Top    = Color3.new(0.695,0.695,0.695)
    Lighting.Brightness        = 2
    Lighting.FogEnd            = 1e10
    Lighting.GlobalShadows     = false
    workspace.Terrain.WaterWaveSize    = 0
    workspace.Terrain.WaterWaveSpeed   = 0
    workspace.Terrain.WaterReflectance = 0
    workspace.Terrain.WaterTransparency= 0
    pcall(function() settings().Rendering.QualityLevel = "Level01" end)
    for _,e in pairs(Lighting:GetChildren()) do
        if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or
           e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or
           e:IsA("DepthOfFieldEffect") then e.Enabled = false end
    end
    local rocks = workspace:FindFirstChild("Rocks")
    if rocks then rocks:Destroy() end
end)

-- ZYN hookfunction calls (pcall-wrapped so Delta doesn't crash)
pcall(function() hookfunction(require(ReplicatedStorage.Effect.Container.Death), function() end) end)
pcall(function() hookfunction(require(ReplicatedStorage:WaitForChild("GuideModule")).ChangeDisplayedNPC, function() end) end)
pcall(function() hookfunction(error, function() end) end)
pcall(function() hookfunction(warn,  function() end) end)

-- ================================================================
-- [9] ANTI-AFK
-- ================================================================
plr.Idled:Connect(function()
    vim2:Button2Down(Vector2.zero, workspace.CurrentCamera.CFrame)
    task.wait(1)
    vim2:Button2Up(Vector2.zero, workspace.CurrentCamera.CFrame)
end)

-- ================================================================
-- [10] UTILITY  (ZYN exact)
-- ================================================================

-- ZYN exact lines 317-333
EquipWeapon = function(I)
    if not I then return end
    if plr.Backpack:FindFirstChild(I) then
        pcall(function() plr.Character.Humanoid:EquipTool(plr.Backpack:FindFirstChild(I)) end)
    end
end

weaponSc = function(I)
    for _,K in pairs(plr.Backpack:GetChildren()) do
        if K:IsA("Tool") and K.ToolTip == I then EquipWeapon(K.Name) end
    end
end

-- ZYN exact lines 968-1004
GetBP = function(I)
    return plr.Backpack:FindFirstChild(I) or plr.Character:FindFirstChild(I)
end

GetM = function(I)
    local ok,inv = pcall(function() return _CommF:InvokeServer("getInventory") end)
    if not ok or type(inv)~="table" then return 0 end
    for _,K in pairs(inv) do
        if type(K)=="table" and K.Type=="Material" and K.Name==I then return K.Count or 0 end
    end
    return 0
end

GetWP = function(I)
    local ok,inv = pcall(function() return _CommF:InvokeServer("getInventory") end)
    if not ok or type(inv)~="table" then return false end
    for _,K in pairs(inv) do
        if type(K)=="table" and K.Type=="Sword" then
            if K.Name==I or plr.Character:FindFirstChild(I) or plr.Backpack:FindFirstChild(I) then return true end
        end
    end
    return false
end

GetIn = function(I)
    local ok,inv = pcall(function() return _CommF:InvokeServer("getInventory") end)
    if not ok or type(inv)~="table" then return false end
    for _,K in pairs(inv) do
        if type(K)=="table" then
            if K.Name==I or plr.Character:FindFirstChild(I) or plr.Backpack:FindFirstChild(I) then return true end
        end
    end
    return false
end

-- ZYN exact lines 925-933
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

-- ZYN exact lines 785-796
GetConnectionEnemies = function(I)
    for _,K in pairs(replicated:GetChildren()) do
        if K:IsA("Model") and (
            (type(I)=="table" and table.find(I,K.Name) or K.Name==I)
            and K:FindFirstChild("Humanoid") and K.Humanoid.Health>0
        ) then return K end
    end
    for _,K in pairs(workspace.Enemies:GetChildren()) do
        if K:IsA("Model") and (
            (type(I)=="table" and table.find(I,K.Name) or K.Name==I)
            and K:FindFirstChild("Humanoid") and K.Humanoid.Health>0
        ) then return K end
    end
end

local function Alive(I)
    if not I or not I.Parent then return false end
    local h = I:FindFirstChild("Humanoid")
    return h and h.Health>0
end

-- ZYN exact lines 715-766
Useskills = function(I, e)
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

-- ZYN exact lines 491-510
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

-- ZYN exact Hop function lines 1035-1046
Hop = function()
    pcall(function()
        for I = math.random(1, math.random(40,75)), 100, 1 do
            local e = replicated.__ServerBrowser:InvokeServer(I)
            for I,e in next,e do
                if tonumber(e.Count) < 12 then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, I)
                end
            end
        end
    end)
end

-- ================================================================
-- [11] G TABLE  (ZYN exact lines 362-481)
-- ================================================================
G = {}; G.__index = G

G.Alive = function(I)
    if not I then return end
    local e = I:FindFirstChild("Humanoid")
    return e and e.Health>0
end

-- ZYN exact lines 383-409
G.Kill = function(I, e)
    if not (I and e) then return end
    local hrp = I:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if not I:GetAttribute("Locked") then I:SetAttribute("Locked", hrp.CFrame) end
    PosMon   = (I:GetAttribute("Locked")).Position
    MousePos = PosMon
    _B       = true
    BringEnemy()
    EquipWeapon(_G.SelectWeapon)
    local tool = plr.Character:FindFirstChildOfClass("Tool")
    if not tool then return end
    _tp(hrp.CFrame * CFrame.new(0, _G.MobHeight, 0))
end

-- ZYN exact G.Sword
G.Sword = function(I, e)
    if not (I and e) then return end
    local hrp = I:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if not I:GetAttribute("Locked") then I:SetAttribute("Locked", hrp.CFrame) end
    PosMon   = (I:GetAttribute("Locked")).Position
    MousePos = PosMon
    _B       = true
    BringEnemy()
    weaponSc("Sword")
    _tp(hrp.CFrame * CFrame.new(0, 30, 0))
end

-- ================================================================
-- [12] BRING ENEMY  (ZYN exact lines 580-714)
-- ================================================================
local TweenInfoBring = TweenInfo.new(0.45, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

local function IsRaidMob(mob)
    local n = mob.Name:lower()
    if n:find("raid") or n:find("microchip") then return true end
    if mob:GetAttribute("IsRaid") or mob:GetAttribute("RaidMob") then return true end
    local h = mob:FindFirstChild("Humanoid")
    return h and h.WalkSpeed == 0
end

BringEnemy = function()
    if not _B then return end
    local chr = plr.Character
    local hrp = chr and chr:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    pcall(function() sethiddenproperty(plr,"SimulationRadius",math.huge) end)
    local target = PosMon or hrp.Position
    local count  = 0
    for _,mob in ipairs(workspace.Enemies:GetChildren()) do
        if count >= _G.MaxBringMobs then break end
        local hum  = mob:FindFirstChild("Humanoid")
        local root = mob:FindFirstChild("HumanoidRootPart")
        if hum and root and hum.Health>0 and not IsRaidMob(mob) then
            local dist = (root.Position - target).Magnitude
            if dist <= _G.BringRange and not root:GetAttribute("Tweening") then
                count += 1
                root:SetAttribute("Tweening", true)
                local tw = TweenService:Create(root, TweenInfoBring, {CFrame=CFrame.new(target)})
                tw:Play()
                tw.Completed:Once(function()
                    if root then root:SetAttribute("Tweening", false) end
                end)
            end
        end
    end
end

-- ZYN exact bring loop lines 701-714
task.spawn(function()
    while task.wait(1) do
        if _G.XH_AutoFarm or _G.StartFarm then
            _B = true; BringEnemy()
            task.wait(3); _B = false; task.wait(5)
        else
            _B = false; task.wait(1)
        end
    end
end)

-- ================================================================
-- [13] AUTO KEN  (ZYN exact lines 59-75)
-- ================================================================
task.spawn(function()
    while task.wait(0.2) do
        if _G.XH_AutoKen then
            pcall(function()
                local chr = plr.Character
                if chr and not CollectionService:HasTag(chr,"Ken") then CE("Ken",true) end
            end)
        end
    end
end)

-- ================================================================
-- [14] __namecall HOOK  (ZYN exact lines 767-784, pcall-wrapped)
-- ================================================================
pcall(function()
    local J = getrawmetatable(game)
    local i = J.__namecall
    setreadonly(J, false)
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
    setreadonly(J, true)
end)

-- ================================================================
-- [15] C ANCHOR + shouldTween LOOPS  (ZYN exact lines 1047-1172)
-- ================================================================

-- Clean up old anchor
pcall(function()
    local old = workspace:FindFirstChild("Rip_Indra")
    if old then old:Destroy() end
end)

-- ZYN exact lines 1047-1053
local C = Instance.new("Part", workspace)
C.Size        = Vector3.new(1,1,1)
C.Name        = "Rip_Indra"
C.Anchored    = true
C.CanCollide  = false
C.CanTouch    = false
C.Transparency = 1

-- ZYN exact lines 1060-1072
task.spawn(function()
    while task.wait() do
        if C and C.Parent == workspace then
            if shouldTween then (getgenv()).OnFarm = true
            else (getgenv()).OnFarm = false end
        else (getgenv()).OnFarm = false end
    end
end)

-- ZYN exact lines 1074-1113
task.spawn(function()
    local I = plr
    repeat task.wait() until I.Character and I.Character.PrimaryPart
    C.CFrame = I.Character.PrimaryPart.CFrame
    while task.wait() do
        pcall(function()
            if (getgenv()).OnFarm then
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

-- ZYN exact lines 1204-1232 (BodyVelocity + shouldTween controller)
task.spawn(function()
    while task.wait() do
        pcall(function()
            local anyFarm = _G.XH_AutoFarm or _G.XH_AutoGhoul or _G.XH_AutoCyborg
                         or _G.XH_AutoTushita or _G.XH_AutoBerry or _G.StartFarm
            if anyFarm then
                shouldTween = true
                local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp and not hrp:FindFirstChild("BodyClip") then
                    local bv = Instance.new("BodyVelocity")
                    bv.Name="BodyClip"; bv.Parent=hrp
                    bv.MaxForce=Vector3.new(100000,100000,100000)
                    bv.Velocity=Vector3.zero
                end
                if plr.Character then
                    for _,e in pairs(plr.Character:GetDescendants()) do
                        if e:IsA("BasePart") then e.CanCollide=false end
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
                        if e:IsA("BasePart") then e.CanCollide=true end
                    end
                end
            end
        end)
    end
end)

-- ================================================================
-- [16] _tp and notween  (ZYN exact lines 1123-1180)
-- ================================================================
_tp = function(I)
    local e = plr.Character
    if not e or not e:FindFirstChild("HumanoidRootPart") then return end
    local HRP = e.HumanoidRootPart
    shouldTween = true; (getgenv()).OnFarm = false
    if HRP.Anchored then HRP.Anchored=false; task.wait() end
    local dist  = (I.Position - HRP.Position).Magnitude
    local speed = dist<=90 and ((getgenv()).TweenSpeedNear or 900) or ((getgenv()).TweenSpeedFar or 300)
    local info  = TweenInfo.new(dist/speed, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(C, info, {CFrame=I})
    if e.Humanoid and e.Humanoid.Sit then
        C.CFrame = CFrame.new(C.Position.X, I.Y, C.Position.Z)
    end
    tween:Play()
    task.spawn(function()
        while tween.PlaybackState==Enum.PlaybackState.Playing do
            if not shouldTween then tween:Cancel(); break end
            task.wait(0.1)
        end
        (getgenv()).OnFarm = true
    end)
end

TeleportToTarget = _tp

notween = function(I)
    pcall(function() plr.Character.HumanoidRootPart.CFrame = I end)
end

-- ================================================================
-- [17] COMBAT ENGINE  (Heartbeat - always ON, no toggles needed)
-- Melee + Sword + Fruit M1 fire automatically every frame
-- TopiHub M1 loaded as supplement
-- ================================================================

-- Load TopiHub fast attack (pcall-wrapped, doesn't crash if offline)
pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/TopiHub1909/TopiHub/main/main.lua", true))()
end)

-- Also load Koby fast attack as backup
pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/AnhDangNhoEm/TuanAnhIOS/refs/heads/main/koby", true))()
end)

-- Own heartbeat attack loop (runs even if TopiHub fails to load)
local atkTimer = 0
RunService.Heartbeat:Connect(function(dt)
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

    -- Update aim globals
    MousePos = mhrp.Position
    PosMon   = mhrp.Position

    -- MELEE AURA
    weaponSc("Melee")
    pcall(function() vim2:CaptureController(); vim2:ClickButton1(Vector2.zero) end)
    pcall(function() CF("Click") end)
    if atkTimer >= 0.3 then Useskills("Melee","Z"); Useskills("Melee","X") end

    -- SWORD AURA
    weaponSc("Sword")
    pcall(function() vim2:CaptureController(); vim2:ClickButton1(Vector2.zero) end)
    pcall(function() CF("Click") end)
    if atkTimer >= 0.3 then Useskills("Sword","Z"); Useskills("Sword","X") end

    -- FRUIT AURA  (LeftClickRemote direct fire + auto-equip)
    local ft = nil
    for _,v in pairs(chr:GetChildren()) do
        if v:IsA("Tool") and v.ToolTip=="Blox Fruit" then ft=v; break end
    end
    if not ft then
        for _,v in pairs(plr.Backpack:GetChildren()) do
            if v:IsA("Tool") and v.ToolTip=="Blox Fruit" then
                pcall(function() chr.Humanoid:EquipTool(v) end)
                task.wait(0.05); ft = chr:FindFirstChildOfClass("Tool"); break
            end
        end
    end
    if ft then
        local lr = ft:FindFirstChild("LeftClickRemote")
        if lr then
            local dir = (mhrp.Position - hrp.Position).Unit
            for _=1,6 do pcall(function() lr:FireServer(dir,1) end) end
        end
        pcall(function() vim2:CaptureController(); vim2:ClickButton1(Vector2.zero) end)
        if atkTimer >= 0.4 then UseFruitSkills() end
    end

    if atkTimer >= 1 then atkTimer = 0 end
end)

-- ================================================================
-- [18] BOSS DATA
-- ================================================================
local BOSS_DATA = {
    ["rip_indra"]           = {names={"rip_indra","Rip_Indra","rip_indra True Form"}, pos=CFrame.new(5228,5,845),        entrance=nil},
    ["Darkbeard"]           = {names={"Darkbeard"},                  pos=CFrame.new(-9551,6,5796),      entrance=nil},
    ["Dough King"]          = {names={"Dough King"},                 pos=CFrame.new(-3228,7,6098),      entrance=nil},
    ["Cake Prince"]         = {names={"Cake Prince"},                pos=CFrame.new(-1340,7,-11662),    entrance=nil},
    ["Soul Reaper"]         = {names={"Soul Reaper"},                pos=CFrame.new(-9524,315,6655),    entrance=nil},
    ["Cursed Captain"]      = {names={"Cursed Captain"},             pos=CFrame.new(916.9,181.1,33422), entrance=Vector3.new(923.21,126.97,32852.83)},
    ["Tyrant of the Skies"] = {names={"Tyrant of the Skies","Tyrant"},pos=CFrame.new(-7882,5444,-366), entrance=nil},
    ["Elite Hunter"]        = {names={"Elite Hunter","Elite Pirate","Diablo","Deandre","Urban"},pos=CFrame.new(-5750,105,-4588),entrance=nil},
    ["Longma"]              = {names={"Longma"},                     pos=CFrame.new(-10238,389,-9549),  entrance=nil},
    ["Order"]               = {names={"Order"},                      pos=CFrame.new(-6440,250,-5250),   entrance=nil},
    ["Kitsune Island"]      = {names={"Venomous Assailant"},         pos=CFrame.new(4692,797,858),      entrance=nil},
    ["Prehistoric Island"]  = {names={"Lava Golem","T-Rex"},         pos=CFrame.new(4620,1002,399),     entrance=nil},
    ["Diamond"]             = {names={"Diamond"},                    pos=CFrame.new(-5006,88,4353),     entrance=nil},
    ["Jeremy"]              = {names={"Jeremy"},                     pos=CFrame.new(2006.9,448.9,853.9),entrance=nil},
    ["Fajita"]              = {names={"Fajita"},                     pos=CFrame.new(-723.4,147.4,5931.9),entrance=nil},
    ["Don Swan"]            = {names={"Don Swan"},                   pos=CFrame.new(2286.2,15.1,863.8), entrance=nil},
    ["Hydra Leader"]        = {names={"Hydra Leader"},               pos=CFrame.new(5251,5,1111),       entrance=nil},
    ["Darkbeard"]           = {names={"Darkbeard"},                  pos=CFrame.new(-9551,6,5796),      entrance=nil},
}

local function FindBoss(key)
    local d = BOSS_DATA[key]; if not d then return nil end
    for _,name in ipairs(d.names) do
        local e = GetConnectionEnemies(name); if e then return e end
    end
    for _,name in ipairs(d.names) do
        for _,K in pairs(workspace.Enemies:GetChildren()) do
            if K:IsA("Model") and Alive(K) and
               string.lower(K.Name):find(string.lower(name),1,true) then return K end
        end
    end
end

-- ================================================================
-- [19] AUTO FARM LOOP
-- ================================================================
task.spawn(function()
    while task.wait(0.25) do
        if not _G.XH_AutoFarm then _B=false; continue end
        pcall(function()
            local data = BOSS_DATA[_G.XH_SelBoss]
            if not data then return end
            local boss = FindBoss(_G.XH_SelBoss)
            if boss then
                G.Kill(boss, G.Alive(boss))
            else
                _B=false; shouldTween=false
                if data.entrance then CF("requestEntrance",data.entrance); task.wait(1) end
                notween(data.pos); task.wait(2)
            end
        end)
    end
end)

-- ================================================================
-- [20] AUTO BERRY
-- ================================================================
task.spawn(function()
    while task.wait(0.15) do
        if not _G.XH_AutoBerry then continue end
        pcall(function()
            local chr = plr.Character; if not chr then return end
            local hrp = chr:FindFirstChild("HumanoidRootPart"); if not hrp then return end
            -- CollectionService berries
            for _,bush in ipairs(CollectionService:GetTagged("BerryBush")) do
                pcall(function()
                    local p = bush.Parent
                    if p then hrp.CFrame = p:GetPivot() end; task.wait(0.05)
                end)
            end
            -- Workspace scan
            for _,obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Parent~=chr then
                    local n = string.lower(obj.Name)
                    if n=="redcherry" or n=="blueicicle" or n=="greentoad" or
                       n=="orangefruit" or n:find("berry") then
                        hrp.CFrame = obj.CFrame; task.wait(0.05)
                    end
                end
            end
            collectFruits(true)
        end)
    end
end)

-- ================================================================
-- [21] AUTO CYBORG
-- ================================================================
local cybStep = 1
task.spawn(function()
    while task.wait(0.6) do
        if not _G.XH_AutoCyborg then cybStep=1; continue end
        pcall(function()
            if cybStep==1 then
                if GetBP("Fist of Darkness") then cybStep=2; return end
                if World2 then notween(CFrame.new(-7000,5,-5000))
                elseif World3 then notween(CFrame.new(0,5,-8000)) end
            elseif cybStep==2 then
                if not GetBP("Fist of Darkness") then cybStep=1; return end
                local frags=0; pcall(function() frags=tonumber(plr.Data.Fragments.Value)or 0 end)
                if frags<1000 then
                    local b=GetConnectionEnemies("Darkbeard") or GetConnectionEnemies("Order")
                    if b then G.Kill(b,G.Alive(b)) end; return
                end
                notween(CFrame.new(-6440,250,-5250)); task.wait(0.5)
                CF("BuyMicrochip"); task.wait(0.5); CF("StartRaid","Law"); task.wait(2); cybStep=3
            elseif cybStep==3 then
                if GetBP("Core Brain") then cybStep=4; return end
                local order=GetConnectionEnemies("Order")
                if order then G.Kill(order,G.Alive(order)) else notween(CFrame.new(-6440,250,-5250)) end
            elseif cybStep==4 then
                if not GetBP("Core Brain") then cybStep=3; return end
                notween(CFrame.new(6094,73,3825)); task.wait(0.8)
                CF("CyborgTrainer","Buy"); task.wait(1)
                _G.XH_AutoCyborg=false; cybStep=1
            end
        end)
    end
end)

-- ================================================================
-- [22] AUTO GHOUL  (ZYN exact Ectoplasm logic)
-- ================================================================
task.spawn(function()
    while task.wait(0.5) do
        if not _G.XH_AutoGhoul then continue end
        pcall(function()
            local ecto = tonumber(GetM("Ectoplasm")) or 0
            if ecto < 99 then
                local cap = GetConnectionEnemies("Cursed Captain")
                if cap then G.Kill(cap, G.Alive(cap))
                else
                    -- ZYN exact coords
                    CF("requestEntrance", Vector3.new(923.21252441406, 126.9760055542, 32852.83203125))
                    task.wait(1.5); notween(CFrame.new(916.928589, 181.092773, 33422)); task.wait(3)
                end
            else
                CF("Ectoplasm","Buy",3); task.wait(0.5)
                CF("Ectoplasm","Change",4); task.wait(0.5)
                _G.XH_AutoGhoul = false
            end
        end)
    end
end)

-- ================================================================
-- [23] AUTO TUSHITA
-- ================================================================
local tushStep=1; local brazierDone=0
local BRAZIERS = {
    CFrame.new(5563.42,5.18,-1249.7),  CFrame.new(6035.8,86.5,-1458.3),
    CFrame.new(5820.4,5.0,-1835.6),    CFrame.new(5432.1,5.0,-2014.8),
    CFrame.new(5070.5,12.0,-1634.2),
}
task.spawn(function()
    while task.wait(0.5) do
        if not _G.XH_AutoTushita then tushStep=1; brazierDone=0; continue end
        pcall(function()
            if tushStep==1 then
                local indra=GetConnectionEnemies("rip_indra") or GetConnectionEnemies("Rip_Indra")
                if indra then task.wait(5); return end; tushStep=2
            elseif tushStep==2 then
                notween(CFrame.new(5228,5,845)); task.wait(1.5); tushStep=3
            elseif tushStep==3 then
                notween(CFrame.new(5228,5,960)); task.wait(1)
                local hrp=plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _,obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("ProximityPrompt") and (hrp.Position-obj.Parent.Position).Magnitude<20 then
                            pcall(function() fireproximityprompt(obj) end)
                        end
                    end
                end
                brazierDone=0; tushStep=4
            elseif tushStep==4 then
                if brazierDone>=5 then tushStep=5; return end
                notween(BRAZIERS[brazierDone+1]); task.wait(0.8)
                local hrp=plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _,obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("ProximityPrompt") and (hrp.Position-obj.Parent.Position).Magnitude<15 then
                            pcall(function() fireproximityprompt(obj) end)
                        end
                    end
                end
                pcall(function() CF("LightBrazier", brazierDone+1) end)
                task.wait(0.3); brazierDone+=1
            elseif tushStep==5 then
                local longma=GetConnectionEnemies("Longma")
                if longma then
                    G.Kill(longma,G.Alive(longma))
                    repeat task.wait(0.5) until not Alive(longma) or not _G.XH_AutoTushita
                    tushStep=6
                else notween(CFrame.new(-10238,389,-9549)); task.wait(3) end
            elseif tushStep==6 then
                for _,obj in pairs(workspace:GetDescendants()) do
                    if obj.Name=="Tushita" then
                        local hrp=plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then pcall(function() hrp.CFrame=obj.CFrame end); task.wait(0.3) end
                    end
                end
                _G.XH_AutoTushita=false; tushStep=1; brazierDone=0
            end
        end)
    end
end)

-- ================================================================
-- [24] AUTO LEGENDARY SWORD
-- ================================================================
local LEG_SWORDS = {"Saddi","Wando","Shisui","True Triple Katana"}
task.spawn(function()
    while task.wait(0.5) do
        if not _G.XH_AutoLegSword then continue end
        pcall(function()
            notween(CFrame.new(-3228,7,6098)); task.wait(0.5)
            for _,sw in ipairs(LEG_SWORDS) do CF("BuyItem",sw); task.wait(0.2) end
        end)
    end
end)

-- ================================================================
-- [25] CHARACTER RESPAWN
-- ================================================================
plr.CharacterAdded:Connect(function(chr)
    task.wait(0.5)
    repeat task.wait() until chr:FindFirstChild("HumanoidRootPart")
    Root = chr.HumanoidRootPart
    C.CFrame = Root.CFrame
    shouldTween=false; _B=false
    task.wait(1)
    pcall(function() CF("SetTeam", desiredTeam) end)
    task.wait(1)
    if _G.XH_AutoKen then CE("Ken",true) end
end)

-- ================================================================
-- [26] SERVER HOP ENGINE  (NightHub API - 17 endpoints)
-- ================================================================
local API = {
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

local SrvCache={} local SrvSel={} local SrvRaw={}
for _,ev in ipairs(API) do SrvCache[ev.Key]={} SrvSel[ev.Key]=nil SrvRaw[ev.Key]={} end

-- Decode NIGHTHUB encoded JobId
-- Tries UUID pattern extraction first, then raw pass
local function DecodeJobId(enc)
    if not enc or enc=="" then return nil end
    -- Already UUID?
    if enc:match("^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$") then
        return enc
    end
    -- Strip NIGHTHUB prefix
    local stripped = enc:gsub("^NIGHTHUB","")
    -- Try UUID pattern inside
    local uuid = stripped:match("[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]%-[0-9a-f][0-9a-f][0-9a-f][0-9a-f]%-[0-9a-f][0-9a-f][0-9a-f][0-9a-f]%-[0-9a-f][0-9a-f][0-9a-f][0-9a-f]%-[0-9a-f]+")
    if uuid and #uuid==36 then return uuid end
    -- Return stripped as last attempt
    return stripped
end

local function FetchServers(ev)
    local url = ev.URL.."?v="..os.time()
    local ok,res = pcall(function() return game:HttpGet(url, true) end)
    if not ok or not res or res=="" or res=="[]" or res=="null" then
        return nil,"API empty or unreachable"
    end
    local ok2,data = pcall(function() return HttpService:JSONDecode(res) end)
    if not ok2 or type(data)~="table" then return nil,"JSON parse failed" end
    local valid={}
    for _,s in ipairs(data) do
        local pId = tostring(s.PlaceId or "")
        local jId = tostring(s.JobId or "")
        if pId==tostring(placeId) and jId~="" and jId~=JobId then
            table.insert(valid, s)
        end
    end
    table.sort(valid, function(a,b) return tonumber(a.Age or 9999)<tonumber(b.Age or 9999) end)
    return valid, nil
end

local function BossAlive(s)
    return tonumber(s.Age or 999)<=90 and tonumber(s.Players or 12)<12
end

-- Public server hop fallback (ZYN exact + Roblox API fallback)
local function HopPublic()
    pcall(function()
        -- Try ZYN __ServerBrowser first
        for I = math.random(1,math.random(40,75)), 100, 1 do
            local ok,e = pcall(function() return replicated.__ServerBrowser:InvokeServer(I) end)
            if ok and e then
                for jid,srv in next,e do
                    if tonumber(srv.Count)<12 then
                        task.wait(1)
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, jid)
                        return
                    end
                end
            end
        end
    end)
    -- Roblox games API fallback
    pcall(function()
        local raw = game:HttpGet("https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100", true)
        local data = HttpService:JSONDecode(raw)
        if data and data.data then
            for _,srv in pairs(data.data) do
                if tonumber(srv.playing)<12 and tostring(srv.id)~=JobId then
                    task.wait(1)
                    TeleportService:TeleportToPlaceInstance(placeId, srv.id, plr)
                    return
                end
            end
        end
    end)
end

local function DoTP(jobId, fallback, onErr)
    local decoded = DecodeJobId(jobId)
    task.wait(1) -- anti-kick
    local ok, err = pcall(function()
        TeleportService:TeleportToPlaceInstance(placeId, decoded, plr)
    end)
    if not ok then
        if fallback and #fallback>0 then
            local nxt = table.remove(fallback,1)
            if onErr then onErr("Server full, trying next...") end
            task.wait(2); DoTP(tostring(nxt.JobId), fallback, onErr)
        else
            if onErr then onErr("All servers tried. Hopping public...") end
            HopPublic()
        end
    end
end

pcall(function()
    if queue_on_teleport then
        queue_on_teleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/AlifServer/hopxico/refs/heads/main/Vx10.lua',true))()")
    end
end)

-- ================================================================
-- [27] LOAD FLUENT UI  (3 fallback CDNs, no assert crash)
-- ================================================================
local Fluent = nil
local fluentURLs = {
    "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua",
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/main.lua",
    "https://cdn.jsdelivr.net/gh/dawid-scripts/Fluent@master/main.lua",
}
for _,url in ipairs(fluentURLs) do
    if Fluent then break end
    local ok,r = pcall(function()
        return loadstring(game:HttpGet(url, true))()
    end)
    if ok and r then Fluent=r end
    task.wait(0.3)
end

if not Fluent then
    -- Last resort: simple GUI fallback (so script doesn't crash)
    warn("XICO HUB: Fluent failed to load. Check HTTP permissions in executor.")
    return
end

local function Notify(t,c,d)
    pcall(function() Fluent:Notify({Title=t,Content=c,Duration=d or 3}) end)
end

-- ================================================================
-- [28] WINDOW  (40% size)
-- ================================================================
local Window = Fluent:CreateWindow({
    Title       = "Xico Hub | Hop",
    SubTitle    = "made by @alifgamer",
    TabWidth    = 120,
    Size        = UDim2.fromOffset(260, 175),
    Acrylic     = false,
    Theme       = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl,
})

-- ================================================================
-- [29] FARM TAB
-- ================================================================
local FT = Window:AddTab({Title="⚔ Farm", Icon="sword"})

FT:AddSection("Auto Combat (Always ON)")
FT:AddParagraph({Title="Status",Desc="Melee + Sword + Fruit M1 Aura always active.\nAuto-equips weapons and fires every frame."})

FT:AddSection("Boss Farm")

local BOSS_VALS = {
    "rip_indra","Darkbeard","Dough King","Cake Prince","Soul Reaper",
    "Cursed Captain","Tyrant of the Skies","Elite Hunter","Longma",
    "Order","Kitsune Island","Prehistoric Island","Diamond","Jeremy","Fajita","Don Swan","Hydra Leader",
}

FT:AddDropdown("BossDrop",{
    Title="Select Boss", Values=BOSS_VALS, Default=1,
    Callback=function(v) _G.XH_SelBoss=v end
})

FT:AddToggle("AutoFarm",{
    Title="▶ Auto Farm Boss", Default=_G.XH_AutoFarm,
    Callback=function(v)
        _G.XH_AutoFarm=v; _G.StartFarm=v
        if not v then _B=false; shouldTween=false end
        if v then Notify("Farm","Farming: ".._G.XH_SelBoss,2) end
    end
})

FT:AddButton({Title="Teleport To Boss Spawn",
    Callback=function()
        local d=BOSS_DATA[_G.XH_SelBoss]
        if d then
            if d.entrance then CF("requestEntrance",d.entrance); task.wait(1) end
            notween(d.pos); Notify("TP","Going to ".._G.XH_SelBoss,2)
        end
    end
})

FT:AddSection("Utilities")

FT:AddToggle("BringMobs",{Title="Bring Mobs To Me",Default=_G.XH_BringMobs,
    Callback=function(v) _G.XH_BringMobs=v; _B=v end})
FT:AddToggle("AutoBerry",{Title="Auto Collect Berries",Default=_G.XH_AutoBerry,
    Callback=function(v) _G.XH_AutoBerry=v end})
FT:AddToggle("AutoKen",{Title="Auto Observation Haki",Default=_G.XH_AutoKen,
    Callback=function(v) _G.XH_AutoKen=v end})

FT:AddSlider("MobH",{Title="Height Above Boss",Min=5,Max=120,Default=_G.MobHeight,Rounding=0,
    Callback=function(v) _G.MobHeight=v end})
FT:AddSlider("MaxBring",{Title="Max Bring Mobs",Min=1,Max=15,Default=_G.MaxBringMobs,Rounding=0,
    Callback=function(v) _G.MaxBringMobs=v end})

FT:AddSection("Fruit Skills")
FT:AddToggle("FZ",{Title="Fruit Z",Default=_G.FruitSkills.Z,Callback=function(v) _G.FruitSkills.Z=v end})
FT:AddToggle("FX",{Title="Fruit X",Default=_G.FruitSkills.X,Callback=function(v) _G.FruitSkills.X=v end})
FT:AddToggle("FC",{Title="Fruit C",Default=_G.FruitSkills.C,Callback=function(v) _G.FruitSkills.C=v end})
FT:AddToggle("FV",{Title="Fruit V",Default=_G.FruitSkills.V,Callback=function(v) _G.FruitSkills.V=v end})

-- ================================================================
-- [30] RACE TAB
-- ================================================================
local RT = Window:AddTab({Title="🏁 Race", Icon="user"})

RT:AddSection("Cyborg Race")
RT:AddParagraph({Title="Steps",Desc="Fist of Darkness→Law Raid→Kill Order→Core Brain→Buy"})
RT:AddToggle("ACyborg",{Title="Auto Cyborg",Default=_G.XH_AutoCyborg,
    Callback=function(v) _G.XH_AutoCyborg=v; cybStep=1
        if v then Notify("Cyborg","Farming Fist of Darkness...",3) end
    end})
RT:AddButton({Title="Buy Cyborg (Manual)",
    Callback=function() CF("CyborgTrainer","Buy"); Notify("Cyborg","Sent!",2) end})

RT:AddSection("Ghoul Race")
RT:AddParagraph({Title="Steps",Desc="Farm 99 Ectoplasm from Cursed Captain→Buy Race"})
RT:AddToggle("AGhoul",{Title="Auto Ghoul",Default=_G.XH_AutoGhoul,
    Callback=function(v) _G.XH_AutoGhoul=v
        if v then Notify("Ghoul","Farming Ectoplasm...",3) end
    end})
RT:AddButton({Title="Buy Ghoul (needs 99 Ecto)",
    Callback=function()
        CF("Ectoplasm","Buy",3); task.wait(0.3); CF("Ectoplasm","Change",4)
        Notify("Ghoul","Sent!",2)
    end})

RT:AddSection("Tushita Sword")
RT:AddParagraph({Title="Steps",Desc="Indra dead→Portal→5 Braziers→Longma→Collect"})
RT:AddToggle("ATushita",{Title="Auto Tushita",Default=_G.XH_AutoTushita,
    Callback=function(v) _G.XH_AutoTushita=v; tushStep=1; brazierDone=0
        if v then Notify("Tushita","Checking Indra...",3) end
    end})

RT:AddSection("Legendary Swords")
RT:AddToggle("ALegSword",{Title="Auto Buy Legendary Swords",Default=_G.XH_AutoLegSword,
    Callback=function(v) _G.XH_AutoLegSword=v end})
for _,sw in ipairs(LEG_SWORDS) do
    RT:AddButton({Title="Buy "..sw,
        Callback=function() CF("BuyItem",sw); Notify("Shop","Buying "..sw,2) end})
end

RT:AddSection("Race Shop")
RT:AddButton({Title="Random Race (3000F)",Callback=function()
    CF("BlackbeardReward","Reroll","1"); CF("BlackbeardReward","Reroll","2")
    Notify("Race","Sent!",2)
end})
RT:AddButton({Title="Reset Stats (2500F)",Callback=function()
    CF("BlackbeardReward","Refund","1"); CF("BlackbeardReward","Refund","2")
    Notify("Stats","Sent!",2)
end})

-- ================================================================
-- [31] SERVER HOP TABS  (all 17 — matching NightHub screenshot layout)
-- Each tab: server dropdown + Refresh + Join + Auto Hop
-- Server entries show:  Name | JobId (short) | age:Xs | Players:X/12 | PlaceId:X
-- ================================================================
local DropRefs = {}

for _,ev in ipairs(API) do
    local tab = Window:AddTab({Title=ev.Name, Icon="globe"})
    tab:AddSection(ev.Name.." Servers")

    -- server dropdown (populated on refresh)
    local dd = tab:AddDropdown("D_"..ev.Key,{
        Title="Available Servers",
        Values={"[ Click Refresh Below ]"},
        Default=1,
        Callback=function(v) SrvSel[ev.Key]=v end
    })
    DropRefs[ev.Key] = dd

    -- REFRESH BUTTON — matches "Click to Refresh List" from NightHub screenshot
    tab:AddButton({
        Title="🔄 Refresh List",
        Description="Fetch live servers from NightHub API",
        Callback=function()
            Notify("Fetching",ev.Name.."...",1)
            task.spawn(function()
                local svrs,err = FetchServers(ev)
                if not svrs or #svrs==0 then
                    dd:SetValues({"[ No Servers Found ]"})
                    dd:SetValue("[ No Servers Found ]")
                    SrvCache[ev.Key]={}; SrvRaw[ev.Key]={}
                    Notify("Empty",err or "No servers for "..ev.Name,3); return
                end
                local labels, map = {}, {}
                SrvRaw[ev.Key] = svrs
                for i,s in ipairs(svrs) do
                    local alive = BossAlive(s) and "✅" or "⏳"
                    -- Format matches NightHub screenshot:
                    -- Name | JobId (16 chars) | age:Xs | X/12 | PlaceId
                    local jId = tostring(s.JobId or ""):sub(1,16)
                    local lbl = string.format(
                        "%s %s | %s... | age:%ss | %s/12 | PlaceId:%s",
                        alive,
                        tostring(s.Name or "Unknown"),
                        jId,
                        tostring(s.Age or "?"),
                        tostring(s.Players or "?"),
                        tostring(s.PlaceId or placeId)
                    )
                    table.insert(labels, lbl)
                    map[lbl] = tostring(s.JobId)
                end
                SrvCache[ev.Key]=map; SrvSel[ev.Key]=labels[1]
                dd:SetValues(labels); dd:SetValue(labels[1])
                Notify("Done!",#labels.." servers for "..ev.Name,3)
            end)
        end,
    })

    -- JOIN SELECTED SERVER
    tab:AddButton({
        Title="🚀 Join Selected Server",
        Description="Teleport using JobId (anti-kick + fallback)",
        Callback=function()
            local sel = SrvSel[ev.Key]
            local map = SrvCache[ev.Key]
            if not sel or not map or not map[sel] then
                Notify("Error","Refresh first, then select a server!",2); return
            end
            local jId = map[sel]
            if jId==JobId then Notify("Skip","Already in this server!",2); return end
            Notify("Teleporting","Joining "..ev.Name.."...",4)
            local fb={}
            for _,s in ipairs(SrvRaw[ev.Key] or {}) do
                if tostring(s.JobId)~=jId and tostring(s.JobId)~=JobId then table.insert(fb,s) end
            end
            DoTP(jId, fb, function(m) Notify("Info",m,3) end)
        end,
    })

    -- AUTO HOP (finds freshest alive server)
    tab:AddButton({
        Title="🔁 Auto Hop (Best Server)",
        Description="Refresh + auto-join youngest alive server",
        Callback=function()
            Notify("Auto Hop","Scanning "..ev.Name.."...",2)
            task.spawn(function()
                local svrs,err = FetchServers(ev)
                if not svrs or #svrs==0 then Notify("Failed",err or "None",3); return end
                SrvRaw[ev.Key]=svrs
                local ordered={}
                for _,s in ipairs(svrs) do if BossAlive(s) then table.insert(ordered,s) end end
                for _,s in ipairs(svrs) do if not BossAlive(s) then table.insert(ordered,s) end end
                if #ordered==0 then Notify("None","No valid servers",3); return end
                local best = table.remove(ordered,1)
                Notify("Hopping→"..ev.Name,
                    string.format("Name:%s | Age:%ss | %s/12",
                        tostring(best.Name or"Unknown"),
                        tostring(best.Age or"?"),
                        tostring(best.Players or"?")),4)
                DoTP(tostring(best.JobId), ordered, function(m) Notify("Info",m,3) end)
            end)
        end,
    })
end

-- ================================================================
-- [32] SETTINGS TAB
-- ================================================================
local ST = Window:AddTab({Title="⚙ Settings", Icon="settings"})

ST:AddSection("Tween")
ST:AddSlider("TwnFar",{Title="Far Speed (>90 studs)",Min=50,Max=1000,Default=getgenv().TweenSpeedFar,Rounding=0,
    Callback=function(v) getgenv().TweenSpeedFar=v end})
ST:AddSlider("TwnNear",{Title="Near Speed (≤90 studs)",Min=100,Max=2000,Default=getgenv().TweenSpeedNear,Rounding=0,
    Callback=function(v) getgenv().TweenSpeedNear=v end})

ST:AddSection("Team")
ST:AddButton({Title="Join Marines",Callback=function()
    pcall(function() CF("SetTeam","Marines") end); Notify("Team","Marines!",2)
end})
ST:AddButton({Title="Join Pirates",Callback=function()
    pcall(function() CF("SetTeam","Pirates") end); Notify("Team","Pirates!",2)
end})

ST:AddSection("Server")
ST:AddButton({Title="Public Server Hop",Callback=function()
    Notify("Hop","Hopping to random server...",3); HopPublic()
end})

ST:AddSection("Misc")
ST:AddButton({Title="Redeem All Codes",Callback=function()
    local codes={"LIGHTNINGABUSE","1LOSTADMIN","ADMINFIGHT","GIFTING_HOURS","NOMOREHACK","BANEXPLOIT",
        "WildDares","BossBuild","GetPranked","EARN_FRUITS","SUB2GAMERROBOT_RESET1","KITT_RESET",
        "Bignews","CHANDLER","Fudd10","fudd10_v2","Sub2UncleKizaru","FIGHT4FRUIT","kittgaming",
        "TRIPLEABUSE","Sub2CaptainMaui","Sub2Fer999","Enyu_is_Pro","Magicbus","JCWK",
        "Starcodeheo","Bluxxy","SUB2GAMERROBOT_EXP1","Sub2NoobMaster123","Sub2Daigrock",
        "Axiore","TantaiGaming","StrawHatMaine","Sub2OfficialNoobie","TheGreatAce"}
    local rem=ReplicatedStorage.Remotes:FindFirstChild("Redeem")
    if rem then
        for _,code in ipairs(codes) do
            task.wait(0.05)
            pcall(function()
                if rem.InvokeServer then rem:InvokeServer(code) else rem:FireServer(code) end
            end)
        end
        Notify("Codes","All codes attempted!",3)
    end
end})
ST:AddButton({Title="Detect World",Callback=function()
    local w=World1 and "Sea 1" or World2 and "Sea 2" or World3 and "Sea 3" or "Unknown"
    Notify("World",w.." | PlaceId:"..tostring(placeId),4)
end})

-- ================================================================
-- [33] SELECT FIRST TAB
-- ================================================================
Window:SelectTab(1)

-- ================================================================
-- [34] FLOATING TOGGLE BUTTON
-- Asset: rbxassetid://84090982489875 | Cyan | Draggable
-- Has BOTH ImageLabel (logo) + TextLabel "X" (visible fallback)
-- ================================================================
pcall(function()
    local old=CoreGui:FindFirstChild("XicoHubTogV12")
    if old then old:Destroy() end
end)

local TogGui = Instance.new("ScreenGui", CoreGui)
TogGui.Name="XicoHubTogV12"; TogGui.ResetOnSpawn=false
TogGui.IgnoreGuiInset=true; TogGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling

-- Outer frame (cyan background, always visible)
local TogFrame = Instance.new("Frame", TogGui)
TogFrame.Size=UDim2.fromOffset(52,52)
TogFrame.Position=UDim2.new(0,5,0.43,0)
TogFrame.BackgroundColor3=Color3.fromRGB(0,185,210)
TogFrame.BorderSizePixel=0; TogFrame.ZIndex=19
Instance.new("UICorner",TogFrame).CornerRadius=UDim.new(0,13)
local tbS=Instance.new("UIStroke",TogFrame)
tbS.Color=Color3.fromRGB(0,255,255); tbS.Thickness=2.5

-- Image (specified asset ID)
local TogImg = Instance.new("ImageLabel", TogFrame)
TogImg.Size=UDim2.fromScale(1,1); TogImg.BackgroundTransparency=1
TogImg.Image="rbxassetid://84090982489875"
TogImg.ImageColor3=Color3.fromRGB(0,255,255)
TogImg.ScaleType=Enum.ScaleType.Fit; TogImg.ZIndex=20

-- Text fallback "X" (visible if image fails to load)
local TogTxt = Instance.new("TextLabel", TogFrame)
TogTxt.Size=UDim2.fromScale(1,1); TogTxt.BackgroundTransparency=1
TogTxt.Text="X"; TogTxt.TextColor3=Color3.fromRGB(0,255,255)
TogTxt.TextSize=22; TogTxt.Font=Enum.Font.GothamBold
TogTxt.ZIndex=19; TogTxt.TextTransparency=0.5 -- subtle so image takes priority

-- Invisible click button on top
local TogBtn = Instance.new("TextButton", TogFrame)
TogBtn.Size=UDim2.fromScale(1,1); TogBtn.BackgroundTransparency=1
TogBtn.Text=""; TogBtn.ZIndex=21; TogBtn.Active=true

-- Drag
local drg,drS,frS,drI,drM = false,nil,nil,nil,0
TogBtn.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        drg=true; drS=i.Position; frS=TogFrame.Position; drM=0
    end
end)
TogBtn.InputChanged:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then drI=i end
end)
UIS.InputChanged:Connect(function(i)
    if i==drI and drg then
        local d=i.Position-drS; drM=d.Magnitude
        TogFrame.Position=UDim2.new(frS.X.Scale,frS.X.Offset+d.X,frS.Y.Scale,frS.Y.Offset+d.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drg=false end
end)

local UIVisible = true
TogBtn.MouseButton1Click:Connect(function()
    if drM>6 then drM=0; return end; drM=0
    UIVisible = not UIVisible
    -- Toggle via RightControl key (Fluent MinimizeKey)
    vim1:SendKeyEvent(true, Enum.KeyCode.RightControl, false, game)
    task.wait(0.05)
    vim1:SendKeyEvent(false, Enum.KeyCode.RightControl, false, game)
end)

-- ================================================================
-- [35] DONE
-- ================================================================
Notify("Xico Hub V12 Loaded!","Team:"..desiredTeam.." | Aura: Active | Tap cyan X to toggle",6)
task.wait(3)
Notify("Combat","Melee + Sword + Fruit M1 firing on heartbeat.",4)

-- Apply config auto-starts
if _G.XH_AutoFarm then
    _G.StartFarm=true
    Notify("Auto-Start","Farming: ".._G.XH_SelBoss,3)
end

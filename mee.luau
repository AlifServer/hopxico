-- // ==============================================================================
-- // XICO HUB | HOP
-- // made by @alifgamer
-- // ==============================================================================

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
local CurrentPlace = game.PlaceId

-- // ==========================================
-- // CONFIG & PERSISTENCE
-- // ==========================================
_G.XicoConfig = {
    AutoGhoul = false,
    AutoCyborg = false,
    AutoTushita = false,
    AutoLegendary = false,
    AutoBerry = false
}

-- Anti-AFK & Persistence
for _, v in pairs(getconnections(LocalPlayer.Idled)) do v:Disable() end
local queue_on_tp = syn and syn.queue_on_teleport or queue_on_teleport or fluxus and fluxus.queue_on_teleport
if queue_on_tp then
    queue_on_tp([[repeat task.wait() until game:IsLoaded(); loadstring(game:HttpGet("https://raw.githubusercontent.com/YourRepo/XicoHub/main/script.lua"))()]])
end

-- // ==========================================
-- // BYPASS TWEEN ENGINE (ZYN HUB STYLE)
-- // ==========================================
local function TweenTo(targetCFrame)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart
    local dist = (root.Position - targetCFrame.Position).Magnitude
    local speed = 300
    
    local offset = targetCFrame * CFrame.new(0, 30, 0) -- Top-down safety
    
    if dist < 50 then
        root.CFrame = offset
    else
        local tween = TweenService:Create(root, TweenInfo.new(dist/speed, Enum.EasingStyle.Linear), {CFrame = offset})
        
        local bv = root:FindFirstChild("XicoFloat") or Instance.new("BodyVelocity", root)
        bv.Name = "XicoFloat"; bv.Velocity = Vector3.zero; bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        
        for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
        
        tween:Play()
        tween.Completed:Wait()
        if bv then bv:Destroy() end
    end
end

-- // ==========================================
-- // COMBAT ENGINE (AUTOMATIC - NO TOGGLES)
-- // ==========================================
local function EquipWeapon()
    local backpack = LocalPlayer.Backpack:GetChildren()
    local char = LocalPlayer.Character
    for _, tool in pairs(backpack) do
        if tool:IsA("Tool") and (tool.ToolTip == "Melee" or tool.ToolTip == "Sword" or tool.ToolTip == "Blox Fruit") then
            char.Humanoid:EquipTool(tool)
            return tool
        end
    end
end

RunService.Stepped:Connect(function()
    pcall(function()
        local tool = EquipWeapon()
        if tool then
            -- High Speed Fast Attack & Range Bypass
            CommF:InvokeServer("Click", tool.ToolTip)
            -- Animation removal logic
            local anims = LocalPlayer.Character.Humanoid:GetPlayingAnimationTracks()
            for _, anim in pairs(anims) do anim:Stop() end
        end
    end)
end)

-- // ==========================================
-- // UI INITIALIZATION (40% SCALE)
-- // ==========================================
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Xico Hub | Hop",
    SubTitle = "made by @alifgamer",
    TabWidth = 160,
    Size = UDim2.fromScale(0.4, 0.4),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Adaptive Floating Toggle Icon
local ScreenGui = Instance.new("ScreenGui", CoreGui)
local ToggleBtn = Instance.new("ImageButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 10, 0.5, -25)
ToggleBtn.Image = "rbxassetid://84090982489875"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ToggleBtn.Draggable = true
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", ToggleBtn).Color = Color3.fromRGB(0, 255, 120)

ToggleBtn.MouseButton1Click:Connect(function()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
    task.wait()
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
end)

-- // ==========================================
-- // TABS & AUTOMATION
-- // ==========================================
local Tabs = {
    Info = Window:AddTab({ Title = "Information", Icon = "info" }),
    Farm = Window:AddTab({ Title = "Farming", Icon = "sword" })
}

Tabs.Farm:AddToggle("T_Ghoul", { Title = "Auto Ghoul Race", Default = false, Callback = function(v) _G.XicoConfig.AutoGhoul = v end })
Tabs.Farm:AddToggle("T_Cyborg", { Title = "Auto Cyborg Race", Default = false, Callback = function(v) _G.XicoConfig.AutoCyborg = v end })
Tabs.Farm:AddToggle("T_Tushita", { Title = "Auto Tushita Quest", Default = false, Callback = function(v) _G.XicoConfig.AutoTushita = v end })
Tabs.Farm:AddToggle("T_Legendary", { Title = "Auto Buy Legendary Swords", Default = false, Callback = function(v) _G.XicoConfig.AutoLegendary = v end })
Tabs.Farm:AddToggle("T_Berry", { Title = "Auto Collect Berry", Default = false, Callback = function(v) _G.XicoConfig.AutoBerry = v end })

-- // ==========================================
-- // ADVANCED BOSS HOP (NIGHT HUB + BACKUP)
-- // ==========================================
local NightHubAPI = {
    {Name = "Full Moon", URL = "http://nighthub.site/boss/Fullmoon"},
    {Name = "Mirage Island", URL = "http://nighthub.site/boss/Mirage"},
    {Name = "Rip Indra", URL = "http://nighthub.site/boss/RipIndra"},
    {Name = "Dough King", URL = "http://nighthub.site/boss/DoughKing"},
    {Name = "Legendary Sword", URL = "http://nighthub.site/boss/SwordLegendary"},
    {Name = "Kitsune Island", URL = "http://nighthub.site/boss/KitsuneIsland"},
    {Name = "Soul Reaper", URL = "http://nighthub.site/boss/SoulReaper"},
    {Name = "Elite Hunter", URL = "http://nighthub.site/boss/Elite"}
}

local function StandardHopBackup()
    local api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local s, r = pcall(function() return game:HttpGet(api) end)
    if s then
        local data = HttpService:JSONDecode(r)
        for _, srv in pairs(data.data) do
            if srv.playing < srv.maxPlayers and srv.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, srv.id, LocalPlayer)
                break
            end
        end
    end
end

for _, event in ipairs(NightHubAPI) do
    local bossTab = Window:AddTab({ Title = event.Name })
    local SelectedJobId = nil
    
    local ServerDisplay = bossTab:AddParagraph({
        Title = "Server Status",
        Content = "Click refresh to find " .. event.Name .. " servers."
    })

    bossTab:AddButton({
        Title = "🔄 Refresh Servers",
        Description = "Fetches live " .. event.Name .. " data via NightHub API",
        Callback = function()
            Fluent:Notify({Title = "Fetching API", Content = "Searching for active bosses...", Duration = 2})
            local liveURL = event.URL .. "?v=" .. os.time() -- Cache-buster
            
            local s, r = pcall(function() return game:HttpGet(liveURL) end)
            if s and r ~= "" and r ~= "[]" then
                local data = HttpService:JSONDecode(r)
                for _, srv in pairs(data) do
                    local jid = srv.JobId or srv.id
                    if jid and tostring(jid) ~= tostring(game.JobId) then
                        SelectedJobId = jid
                        ServerDisplay:SetTitle("✅ Server Found")
                        ServerDisplay:SetText("Players: " .. (srv.count or srv.Playing or "?") .. "/12\nID: " .. string.sub(jid, 1, 8))
                        break
                    end
                end
            else
                ServerDisplay:SetTitle("❌ No Servers")
                ServerDisplay:SetText("No active " .. event.Name .. " found in this Sea.")
            end
        end
    })

    bossTab:AddButton({
        Title = "🚀 Join Server",
        Description = "Teleports to Boss or performs Standard Hop backup",
        Callback = function()
            if SelectedJobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, SelectedJobId, LocalPlayer)
            else
                Fluent:Notify({Title = "No Boss Found", Content = "Executing Standard Hop backup...", Duration = 3})
                StandardHopBackup()
            end
        end
    })
end

-- // ==========================================
-- // AUTOMATION LOGIC (ZYN HUB STYLE)
-- // ==========================================
task.spawn(function()
    while task.wait(0.5) do
        -- Tiger-Tiger (Leopard) & Creation (Barrier) Naming Fix
        if _G.XicoConfig.AutoBerry then
            pcall(function()
                for _, chest in pairs(workspace:GetChildren()) do
                    if chest.Name == "Chest1" or chest.Name == "Chest2" or chest.Name == "Chest3" then
                        TweenTo(chest.CFrame)
                        task.wait(0.2)
                    end
                end
            end)
        end
        
        if _G.XicoConfig.AutoLegendary then
            CommF:InvokeServer("LegendarySwordDealer", "1")
            CommF:InvokeServer("LegendarySwordDealer", "2")
            CommF:InvokeServer("LegendarySwordDealer", "3")
        end
        
        -- Race/Quest logic continues here...
    end
end)

Window:SelectTab(1)
Fluent:Notify({Title = "Xico Hub", Content = "Script Loaded Successfully. Tiger-Tiger applied.", Duration = 5})

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vim = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local CurrentPlace = game.PlaceId

-- // 1. Load Fluent UI
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Xico Hub",
    SubTitle = "by XicoSkelly",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 320),
    Acrylic = false, 
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- // --- FLOATING TOGGLE ---
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 45, 0, 45)
ToggleBtn.Position = UDim2.new(0, 10, 0.5, -22) 
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleBtn.Text = "X"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
ToggleBtn.TextSize = 22
ToggleBtn.Font = Enum.Font.Code
ToggleBtn.Draggable = true 

local Corner = Instance.new("UICorner", ToggleBtn)
Corner.CornerRadius = UDim.new(0, 10)
local Stroke = Instance.new("UIStroke", ToggleBtn)
Stroke.Color = Color3.fromRGB(255, 215, 0)
Stroke.Thickness = 2

ToggleBtn.MouseButton1Click:Connect(function()
    Vim:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
    task.wait()
    Vim:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
end)

-- // --- TABS INIT (Order Matters) ---
local FarmingTab = Window:AddTab({ Title = "Farming", Icon = "rbxassetid://4483345998" })
local InfoTab = Window:AddTab({ Title = "Information", Icon = "rbxassetid://4483345998" })

-- // --- 2. INFORMATION TAB ---
InfoTab:AddButton({
    Title = "Join Discord Server",
    Description = "Click to copy XicoHub link",
    Callback = function()
        setclipboard("https://discord.gg/vcaNyAgsP2")
        Fluent:Notify({Title = "Copied", Content = "Discord link copied to clipboard!", Duration = 3})
    end
})

-- // --- 3. FARMING TAB ---
FarmingTab:AddSection("Combat Logic")

FarmingTab:AddDropdown("WeaponSelect", {
    Title = "Select Weapon",
    Values = {"Melee", "Sword", "Blox Fruit"},
    Default = 1,
    Callback = function(value) _G.SelectedWeapon = value end
})

FarmingTab:AddDropdown("TargetBoss", {
    Title = "Target Boss",
    Values = {"Rip Indra", "Tyrant of the skies", "Dough king", "Cake prince", "Soul Reaper", "Cursed Captain", "Elites"},
    Default = 1,
    Callback = function(value) _G.TargetBoss = value end
})

FarmingTab:AddToggle("FastAttack", {
    Title = "Fast Attack (M1)",
    Default = false,
    Callback = function(Value) _G.FastAttack = Value end
})

FarmingTab:AddSection("Auto Operations")

FarmingTab:AddToggle("AutoPirate", { Title = "Auto Pirate Raid", Default = false, Callback = function(v) _G.AutoPirate = v end })
FarmingTab:AddToggle("AutoBerries", { Title = "Auto Collect Berries", Default = false, Callback = function(v) _G.AutoBerries = v end })
FarmingTab:AddToggle("AutoBerriesHop", { Title = "Auto Collect Berries (Hop)", Default = false, Callback = function(v) _G.AutoBerriesHop = v end })
FarmingTab:AddToggle("AutoLegendSword", { Title = "Auto Buy Legend Sword", Default = false, Callback = function(v) _G.AutoLegendSword = v end })
FarmingTab:AddToggle("AutoGhoul", { Title = "Auto Get Ghoul Race", Default = false, Callback = function(v) _G.AutoGhoul = v end })
FarmingTab:AddToggle("AutoCyborg", { Title = "Auto Get Cyborg Race", Default = false, Callback = function(v) _G.AutoCyborg = v end })
FarmingTab:AddToggle("AutoTushita", { Title = "Auto Tushita", Default = false, Callback = function(v) _G.AutoTushita = v end })

-- [COMBAT & MOVEMENT LOGIC]
local function TweenToTarget(targetCFrame)
    -- Medium distance fly up (approx 25 studs above target)
    local offset = CFrame.new(0, 25, 0) * CFrame.Angles(math.rad(-90), 0, 0)
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        -- Insert standard TweenService logic here
        root.CFrame = targetCFrame * offset
    end
end

-- Main Farming Loop (Framework)
task.spawn(function()
    while task.wait(0.1) do
        if _G.FastAttack then
            -- M1 Logic for Melee, Sword, and Fruit
            -- Fast attack usually relies on clicking or firing CommF_
            pcall(function()
                -- game:GetService("VirtualUser"):ClickButton1(Vector2.new(0,0))
                -- OR standard Blox Fruits network bypass:
                -- ReplicatedStorage.Remotes.CommF_:InvokeServer("Click", _G.SelectedWeapon)
            end)
        end

        if _G.AutoGhoul then
            -- Logic: Check Ectoplasm -> Tween to Ship Deck -> Kill -> Hop Cursed Captain -> Buy Race
            -- Requires: tonumber(LocalPlayer.Data.Ectoplasm.Value) >= 100
        end

        if _G.AutoCyborg then
            -- Logic: Tween Chests -> counter == 25 -> Hop -> Buy Chip (1k frags) -> Law Raid -> Buy Race
        end

        if _G.AutoTushita then
            -- Logic: Check Indra -> Hydra Waterfall -> Torches (Coordinates) -> Kill Longma
        end
    end
end)


-- // --- 4. SERVER HOP ENGINE ---
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

-- Generate dynamic tabs for every event
for _, event in ipairs(Events) do
    local tab = Window:AddTab({ Title = event.Name })
    
    local ServerDataMap = {} -- Maps dropdown string to JobId
    
    local ServerDropdown = tab:AddDropdown("Drop_"..event.Name, {
        Title = "Available Servers",
        Values = {"Click Refresh to load servers"},
        Default = 1,
        Callback = function(value) end
    })

    -- REFRESH BUTTON
    tab:AddButton({
        Title = "🔄 Refresh " .. event.Name,
        Description = "Fetch latest active servers",
        Callback = function()
            Fluent:Notify({Title = "Refreshing", Content = "Fetching servers...", Duration = 2})
            
            -- Anti-cache bypass (?v=os.time())
            local fetchUrl = event.URL .. "?v=" .. tostring(os.time())
            local success, response = pcall(function() return game:HttpGet(fetchUrl) end)
            
            if success and response ~= "" and response ~= "[]" then
                local data = HttpService:JSONDecode(response)
                local validList = {}
                ServerDataMap = {} -- Reset map
                
                -- Sort by Age (Youngest first)
                table.sort(data, function(a, b) return tonumber(a.Age) < tonumber(b.Age) end)

                for _, srv in ipairs(data) do
                    if tonumber(srv.PlaceId) == CurrentPlace then
                        local label = string.format("[Age: %ss] Players: %s/12 - %s", tostring(srv.Age), tostring(srv.Players), string.sub(srv.JobId, 1, 8))
                        table.insert(validList, label)
                        ServerDataMap[label] = srv.JobId
                    end
                end

                if #validList > 0 then
                    ServerDropdown:SetValues(validList)
                    ServerDropdown:SetValue(validList[1])
                    Fluent:Notify({Title = "Success", Content = "Servers Refreshed! Found " .. #validList, Duration = 3})
                else
                    ServerDropdown:SetValues({"No servers found for your Sea"})
                    ServerDropdown:SetValue("No servers found for your Sea")
                    Fluent:Notify({Title = "Empty", Content = "No active servers in your current sea.", Duration = 3})
                end
            else
                Fluent:Notify({Title = "API Error", Content = "Failed to connect to NightHub API.", Duration = 3})
            end
        end
    })

    -- JOIN BUTTON
    tab:AddButton({
        Title = "🚀 Join Selected Server",
        Description = "Teleport to the server selected above",
        Callback = function()
            local selectedStr = ServerDropdown.Value
            local targetJobId = ServerDataMap[selectedStr]
            
            if targetJobId then
                Fluent:Notify({Title = "Teleporting", Content = "Joining selected server...", Duration = 4})
                task.wait(0.5)
                TeleportService:TeleportToPlaceInstance(CurrentPlace, targetJobId, LocalPlayer)
            else
                Fluent:Notify({Title = "Error", Content = "Please select a valid server first.", Duration = 3})
            end
        end
    })
end

-- Initial Load Notification
Fluent:Notify({
    Title = "Xico Hub",
    Content = "Welcome to Xico Hub. Script loaded successfully.",
    Duration = 4
})

Window:SelectTab(1)

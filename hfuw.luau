-- // ==============================================================================
-- // XICO HUB | BOSS HOP
-- // Name: XicoSkelly
-- // ==============================================================================

if not game:IsLoaded() then game.Loaded:Wait() end

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- // 1. STRICT SEA DETECTION (FIXED IDs) //
local CurrentPlaceId = game.PlaceId
local CurrentSea = "Unknown"

if CurrentPlaceId == 2753915549 then 
    CurrentSea = "Sea1"
elseif CurrentPlaceId == 4442272160 then 
    CurrentSea = "Sea2"
elseif CurrentPlaceId == 7449423635 then 
    CurrentSea = "Sea3" 
end

-- // 2. RELIABLE ANTI-AFK //
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- // 3. EXECUTOR UI BYPASS (FIXES INVISIBLE UI) //
local CoreTarget = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

-- // 4. LOAD FREE SOURCE UI (ORIONLIB FALLBACK) //
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

local Window = OrionLib:MakeWindow({
    Name = "XicoSkelly Hub | Boss Hop",
    HidePremium = true,
    SaveConfig = false,
    IntroText = "Xico Hub Loading...",
    IntroIcon = "rbxassetid://84090982489875"
})

-- // 5. MOBILE FLOATING TOGGLE //
local function MakeToggle()
    if CoreTarget:FindFirstChild("XicoMobileToggle") then 
        CoreTarget.XicoMobileToggle:Destroy() 
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "XicoMobileToggle"
    ScreenGui.Parent = CoreTarget
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

    local Btn = Instance.new("ImageButton")
    Btn.Parent = ScreenGui
    Btn.Size = UDim2.new(0, 50, 0, 50)
    Btn.Position = UDim2.new(0.1, 0, 0.2, 0)
    Btn.Image = "rbxassetid://84090982489875"
    Btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Btn.ZIndex = 999
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Btn
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(255, 0, 0)
    Stroke.Thickness = 2
    Stroke.Parent = Btn
    
    -- Smooth Dragging
    local dragging, dragInput, dragStart, startPos
    Btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Btn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    Btn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Toggle Window Visibility
    Btn.MouseButton1Click:Connect(function()
        local windowFrame = CoreTarget:FindFirstChild("Orion")
        if windowFrame then
            windowFrame.Enabled = not windowFrame.Enabled
        end
    end)
end
MakeToggle()

-- // 6. API ENDPOINTS & LOGIC //
local Endpoints = {
    ["Legendary Sword"] = "http://nighthub.site/boss/SwordLegendary",
    ["Legendary Haki"] = "http://nighthub.site/boss/HakiLegendary",
    ["Rip Indra"] = "http://nighthub.site/boss/RipIndra",
    ["Darkbeard"] = "http://nighthub.site/boss/Darkbeard",
    ["Dough King"] = "http://nighthub.site/boss/DoughKing",
    ["Berry"] = "http://nighthub.site/boss/Berry",
    ["Tyrant of Skies"] = "http://nighthub.site/boss/TyrantOfTheSkies",
    ["Cursed Captain"] = "http://nighthub.site/boss/CursedCaptain",
    ["Soul Reaper"] = "http://nighthub.site/boss/SoulReaper",
    ["Full Moon"] = "http://nighthub.site/boss/Fullmoon",
    ["Near Moon"] = "http://nighthub.site/boss/NearMoon",
    ["Mirage Island"] = "http://nighthub.site/boss/Mirage",
    ["Kitsune Island"] = "http://nighthub.site/boss/KitsuneIsland",
    ["Prehistoric Island"] = "http://nighthub.site/boss/PrehistoricIsland",
    ["Cake Prince"] = "http://nighthub.site/boss/CakePrince",
    ["Elite Hunter"] = "http://nighthub.site/boss/Elite",
    ["Castle Raid"] = "http://nighthub.site/boss/CastleRaid"
}

local BossNames = {}
for name, _ in pairs(Endpoints) do table.insert(BossNames, name) end
table.sort(BossNames)

local SelectedBoss = BossNames[1]
local SelectedServerLabel = ""
local ServerDataMap = {} 

-- // 7. UI CONSTRUCTION (SINGLE TAB DESIGN) //
local HopTab = Window:MakeTab({
    Name = "Server Hopper",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

HopTab:AddLabel("Detected Location: " .. CurrentSea)

if CurrentSea == "Unknown" then
    OrionLib:MakeNotification({Name = "Warning", Content = "Place ID mismatch. Teleports may fail.", Time = 5})
end

HopTab:AddDropdown({
    Name = "1. Select Boss Target",
    Default = BossNames[1],
    Options = BossNames,
    Callback = function(Value)
        SelectedBoss = Value
    end    
})

local ServerDropdown 
ServerDropdown = HopTab:AddDropdown({
    Name = "2. Active Servers List",
    Default = "Waiting for data...",
    Options = {"Waiting for data..."},
    Callback = function(Value)
        SelectedServerLabel = Value
    end    
})

HopTab:AddButton({
    Name = "🔄 Refresh Servers for Selected Boss",
    Callback = function()
        local url = Endpoints[SelectedBoss]
        if not url then return end

        OrionLib:MakeNotification({Name = "Fetching", Content = "Searching for " .. SelectedBoss .. "...", Time = 2})

        local success, response = pcall(function()
            return game:HttpGet(url .. "?v=" .. tostring(os.time()))
        end)

        if success and response and response ~= "[]" then
            local decodeSuccess, data = pcall(function()
                return HttpService:JSONDecode(response)
            end)
            
            if decodeSuccess and type(data) == "table" then
                local newList = {}
                ServerDataMap = {}
                
                for _, server in pairs(data) do
                    -- Strict validation
                    if type(server) == "table" and server.Sea == CurrentSea and tostring(server.JobId) ~= tostring(game.JobId) then
                        local pCount = server.Players or "?"
                        local sJob = server.JobId or server.id
                        local sPlace = server.PlaceId or server.placeId or CurrentPlaceId
                        
                        if sJob then
                            local label = "[" .. tostring(pCount) .. "/12] ID: " .. string.sub(tostring(sJob), 1, 8)
                            table.insert(newList, label)
                            ServerDataMap[label] = {JobId = sJob, PlaceId = tonumber(sPlace)}
                        end
                    end
                end
                
                if #newList > 0 then
                    ServerDropdown:Refresh(newList, true)
                    OrionLib:MakeNotification({Name = "Success", Content = "Found " .. #newList .. " servers!", Time = 3})
                else
                    ServerDropdown:Refresh({"No active servers found in " .. CurrentSea}, true)
                    OrionLib:MakeNotification({Name = "Empty", Content = "No active servers match your region.", Time = 3})
                end
            end
        else
            OrionLib:MakeNotification({Name = "API Error", Content = "Endpoint offline or empty.", Time = 3})
        end
    end
})

HopTab:AddButton({
    Name = "🚀 Connect to Selected Server",
    Callback = function()
        if SelectedServerLabel and ServerDataMap[SelectedServerLabel] then
            local target = ServerDataMap[SelectedServerLabel]
            OrionLib:MakeNotification({Name = "Hopping", Content = "Connecting to Instance...", Time = 5})
            
            pcall(function()
                TeleportService:TeleportToPlaceInstance(target.PlaceId, target.JobId, LocalPlayer)
            end)
        else
            OrionLib:MakeNotification({Name = "Error", Content = "Please refresh and select a server first.", Time = 3})
        end
    end
})

OrionLib:Init()

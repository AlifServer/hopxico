-- // ==============================================================================
-- // XICO HUB | ABSOLUTE BOSS HOP
-- // Profile Project: XicoSkelly
-- // Optimization: Pure Core Hopping Engine (Zero Automation, Zero Performance Lag)
-- // ==============================================================================

if not game:IsLoaded() then game.Loaded:Wait() end

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Tweens = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- // 1. ACCURATE SEA DETECTION SYSTEM //
local CurrentPlaceId = game.PlaceId
local CurrentSea = "Unknown"

if CurrentPlaceId == 2753915549 then 
    CurrentSea = "Sea1"
elseif CurrentPlaceId == 4442272160 then 
    CurrentSea = "Sea2"
elseif CurrentPlaceId == 7449423635 then 
    CurrentSea = "Sea3" 
end

-- // 2. ANTI-AFK BACKGROUND ENGINE //
for _, connection in pairs(getconnections(LocalPlayer.Idled)) do
    connection:Disable()
end
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- // 3. EXECUTOR INJECTION PROTECTION CONTAINER //
local TargetParent = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

if TargetParent:FindFirstChild("XicoHub_BossHop") then
    TargetParent.XicoHub_BossHop:Destroy()
end

-- // 4. DATA ENDPOINTS DIRECTORY //
local Endpoints = {
    ["Berry"] = "http://nighthub.site/boss/Berry",
    ["Cake Prince"] = "http://nighthub.site/boss/CakePrince",
    ["Castle Raid"] = "http://nighthub.site/boss/CastleRaid",
    ["Cursed Captain"] = "http://nighthub.site/boss/CursedCaptain",
    ["Darkbeard"] = "http://nighthub.site/boss/Darkbeard",
    ["Dough King"] = "http://nighthub.site/boss/DoughKing",
    ["Elite Hunter"] = "http://nighthub.site/boss/Elite",
    ["Full Moon"] = "http://nighthub.site/boss/Fullmoon",
    ["Kitsune Island"] = "http://nighthub.site/boss/KitsuneIsland",
    ["Legendary Haki"] = "http://nighthub.site/boss/HakiLegendary",
    ["Legendary Sword"] = "http://nighthub.site/boss/SwordLegendary",
    ["Mirage Island"] = "http://nighthub.site/boss/Mirage",
    ["Near Moon"] = "http://nighthub.site/boss/NearMoon",
    ["Prehistoric Island"] = "http://nighthub.site/boss/PrehistoricIsland",
    ["Rip Indra"] = "http://nighthub.site/boss/RipIndra",
    ["Soul Reaper"] = "http://nighthub.site/boss/SoulReaper",
    ["Tyrant of Skies"] = "http://nighthub.site/boss/TyrantOfTheSkies"
}

local BossList = {}
for name, _ in pairs(Endpoints) do table.insert(BossList, name) end
table.sort(BossList)

-- // 5. NATIVE STABLE UI BUILDING (SINGLE-TAB MOBILE OPTIMIZED) //
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "XicoHub_BossHop"
MainGui.Parent = TargetParent
MainGui.ResetOnSpawn = false
MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local BaseFrame = Instance.new("Frame")
BaseFrame.Name = "MainFrame"
BaseFrame.Parent = MainGui
BaseFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
BaseFrame.Position = UDim2.new(0.5, -165, 0.5, -150)
BaseFrame.Size = UDim2.new(0, 330, 0, 300)
BaseFrame.ClipsDescendants = false

local BaseCorner = Instance.new("UICorner")
BaseCorner.CornerRadius = UDim.new(0, 10)
BaseCorner.Parent = BaseFrame

local BaseStroke = Instance.new("UIStroke")
BaseStroke.Color = Color3.fromRGB(255, 50, 50)
BaseStroke.Thickness = 2
BaseStroke.Parent = BaseFrame

-- Header
local Header = Instance.new("TextLabel")
Header.Name = "Header"
Header.Parent = BaseFrame
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Header.Text = "  XicoSkelly Hub | Boss Hopper"
Header.TextColor3 = Color3.fromRGB(240, 240, 240)
Header.Font = Enum.Font.GothamBold
Header.TextSize = 14
Header.TextXAlignment = Enum.TextXAlignment.Left

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = Header

local HeaderFix = Instance.new("Frame")
HeaderFix.Size = UDim2.new(1, 0, 0, 10)
HeaderFix.Position = UDim2.new(0, 0, 1, -10)
HeaderFix.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
HeaderFix.BorderSizePixel = 0
HeaderFix.Parent = Header

-- Content Layout Container
local Container = Instance.new("Frame")
Container.Name = "Container"
Container.Parent = BaseFrame
Container.BackgroundTransparency = 1
Container.Position = UDim2.new(0, 15, 0, 55)
Container.Size = UDim2.new(1, -30, 1, -70)

local UIList = Instance.new("UIListLayout")
UIList.Parent = Container
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 10)

-- Location Status Label
local LocLabel = Instance.new("TextLabel")
LocLabel.Size = UDim2.new(1, 0, 0, 20)
LocLabel.BackgroundTransparency = 1
LocLabel.Text = "Current Filter Location: " .. string.upper(CurrentSea)
LocLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
LocLabel.Font = Enum.Font.GothamSemibold
LocLabel.TextSize = 12
LocLabel.TextXAlignment = Enum.TextXAlignment.Left
LocLabel.Parent = Container

-- STATE TRACKING
local SelectedBoss = BossList[1]
local SelectedServerLabel = ""
local ServerDataMap = {}

-- DROPDOWNS IMPLEMENTATION
local function CreateNativeDropdown(name, default, list, callback)
    local DropFrame = Instance.new("Frame")
    DropFrame.Size = UDim2.new(1, 0, 0, 35)
    DropFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    DropFrame.ClipsDescendants = true
    
    local DCorn = Instance.new("UICorner")
    DCorn.CornerRadius = UDim.new(0, 6)
    DCorn.Parent = DropFrame
    
    local MainBtn = Instance.new("TextButton")
    MainBtn.Size = UDim2.new(1, 0, 0, 35)
    MainBtn.BackgroundTransparency = 1
    MainBtn.Text = "  " .. name .. ": " .. default
    MainBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
    MainBtn.Font = Enum.Font.Gotham
    MainBtn.TextSize = 12
    MainBtn.TextXAlignment = Enum.TextXAlignment.Left
    MainBtn.Parent = DropFrame
    
    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Position = UDim2.new(0, 5, 0, 35)
    Scroll.Size = UDim2.new(1, -10, 0, 100)
    Scroll.BackgroundTransparency = 1
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    Scroll.ScrollBarThickness = 4
    Scroll.Parent = DropFrame
    
    local ScrollList = Instance.new("UIListLayout")
    ScrollList.Parent = Scroll
    ScrollList.Padding = UDim.new(0, 4)
    
    local isOpen = false
    
    local function popList(items)
        for _, c in pairs(Scroll:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        local canvasSizeY = 0
        for _, val in ipairs(items) do
            local ItemBtn = Instance.new("TextButton")
            ItemBtn.Size = UDim2.new(1, 0, 0, 25)
            ItemBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            ItemBtn.Text = tostring(val)
            ItemBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            ItemBtn.Font = Enum.Font.Gotham
            ItemBtn.TextSize = 11
            ItemBtn.Parent = Scroll
            
            local ICorn = Instance.new("UICorner")
            ICorn.CornerRadius = UDim.new(0, 4)
            ICorn.Parent = ItemBtn
            
            canvasSizeY = canvasSizeY + 29
            ItemBtn.MouseButton1Click:Connect(function()
                MainBtn.Text = "  " .. name .. ": " .. tostring(val)
                isOpen = false
                DropFrame.Size = UDim2.new(1, 0, 0, 35)
                DropFrame.ZIndex = 1
                callback(tostring(val))
            end)
        end
        Scroll.CanvasSize = UDim2.new(0, 0, 0, canvasSizeY)
    end
    
    popList(list)
    
    MainBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            DropFrame.Size = UDim2.new(1, 0, 0, 140)
            DropFrame.ZIndex = 100
        else
            DropFrame.Size = UDim2.new(1, 0, 0, 35)
            DropFrame.ZIndex = 1
        end
    end)
    
    return DropFrame, popList
end

-- Boss Dropdown Element
local BossDropElement, _ = CreateNativeDropdown("Target", BossList[1], BossList, function(value)
    SelectedBoss = value
end)
BossDropElement.Parent = Container

-- Server Dropdown Element
local ServerDropElement, RebuildServerOptions = CreateNativeDropdown("Server", "None Selected", {"Refresh Pool First"}, function(value)
    SelectedServerLabel = value
end)
ServerDropElement.Parent = Container

-- BUTTON CREATION FACTORY
local function CreateNativeButton(text, color, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 35)
    Btn.BackgroundColor3 = color
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 12
    
    local BCorn = Instance.new("UICorner")
    BCorn.CornerRadius = UDim.new(0, 6)
    BCorn.Parent = Btn
    
    Btn.MouseButton1Click:Connect(callback)
    return Btn
end

-- Refresh Action
local RefreshBtn = CreateNativeButton("🔄 Refresh Server Pool", Color3.fromRGB(35, 35, 35), function()
    local url = Endpoints[SelectedBoss]
    if not url then return end
    
    local success, response = pcall(function()
        return game:HttpGet(url .. "?v=" .. tostring(os.time()))
    end)
    
    if success and response and response ~= "[]" then
        local decodeSuccess, data = pcall(function()
            return HttpService:JSONDecode(response)
        end)
        
        if decodeSuccess and type(data) == "table" then
            local optionsList = {}
            ServerDataMap = {}
            
            for _, server in pairs(data) do
                -- CRITICAL STEP: FIXED THE CALLBACK 'SEA' PROPERTY RUNTIME EXCEPTION VIA TYPE-VALIDATION
                if type(server) == "table" then
                    local sSea = server.Sea
                    local sJobId = server.JobId or server.id
                    local sPlaceId = server.PlaceId or server.placeId or CurrentPlaceId
                    local sPlayers = server.Players or server.count or "?"
                    
                    if tostring(sSea) == CurrentSea and sJobId and tostring(sJobId) ~= tostring(game.JobId) then
                        local labelString = "[" .. tostring(sPlayers) .. "/12] ID: " .. string.sub(tostring(sJobId), 1, 8)
                        table.insert(optionsList, labelString)
                        ServerDataMap[labelString] = {JobId = sJobId, PlaceId = tonumber(sPlaceId)}
                    end
                end
            end
            
            if #optionsList > 0 then
                RebuildServerOptions(optionsList)
            else
                RebuildServerOptions({"No matching servers in " .. CurrentSea})
            end
        else
            RebuildServerOptions({"JSON Decoding Failure"})
        end
    else
        RebuildServerOptions({"NightHub Endpoint Offline"})
    end
end)
RefreshBtn.Parent = Container

-- Join Action
local JoinBtn = CreateNativeButton("🚀 Connect to Selected Server", Color3.fromRGB(230, 40, 40), function()
    local lookUpData = ServerDataMap[SelectedServerLabel]
    if lookUpData and lookUpData.JobId then
        pcall(function()
            TeleportService:TeleportToPlaceInstance(lookUpData.PlaceId, lookUpData.JobId, LocalPlayer)
        end)
    end
end)
JoinBtn.Parent = Container

-- // 6. MOBILE FLOATING TOGGLE ICON SYSTEM //
local function CreateMobileInterfaceToggle()
    if TargetParent:FindFirstChild("XicoHub_ToggleScreen") then
        TargetParent.XicoHub_ToggleScreen:Destroy()
    end

    local ToggleGui = Instance.new("ScreenGui")
    ToggleGui.Name = "XicoHub_ToggleScreen"
    ToggleGui.Parent = TargetParent
    ToggleGui.ResetOnSpawn = false

    local ToggleButton = Instance.new("ImageButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Parent = ToggleGui
    ToggleButton.Size = UDim2.new(0, 50, 0, 50)
    ToggleButton.Position = UDim2.new(0.05, 0, 0.15, 0)
    ToggleButton.Image = "rbxassetid://84090982489875"
    ToggleButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    ToggleButton.ZIndex = 1000
    
    local TCorner = Instance.new("UICorner")
    TCorner.CornerRadius = UDim.new(0, 12)
    TCorner.Parent = ToggleButton
    
    local TStroke = Instance.new("UIStroke")
    TStroke.Color = Color3.fromRGB(255, 50, 50)
    TStroke.Thickness = 2
    TStroke.Parent = ToggleButton
    
    -- Smooth Dragging Implementation Loop
    local isDragging = false
    local dragInput, dragStart, startPosition
    
    ToggleButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            dragStart = input.Position
            startPosition = ToggleButton.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isDragging = false
                end
            end)
        end
    end)
    
    ToggleButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and isDragging then
            local distanceDelta = input.Position - dragStart
            ToggleButton.Position = UDim2.new(
                startPosition.X.Scale, 
                startPosition.X.Offset + distanceDelta.X, 
                startPosition.Y.Scale, 
                startPosition.Y.Offset + distanceDelta.Y
            )
        end
    end)

    -- Window View State Action
    ToggleButton.MouseButton1Click:Connect(function()
        BaseFrame.Visible = not BaseFrame.Visible
    end)
end

CreateMobileInterfaceToggle()

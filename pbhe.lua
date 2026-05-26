-- // ==============================================================================
-- // XICO HUB | PREMIUM BOSS HOP ENGINE
-- // Profile Project: XicoSkelly
-- // Design Pattern: ProxyLib Inspired Grid Layout with Active Tweens
-- // ==============================================================================

if not game:IsLoaded() then game.Loaded:Wait() end

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- // 1. ANTI-AFK ENGINE //
for _, connection in pairs(getconnections(LocalPlayer.Idled)) do
    connection:Disable()
end
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- // 2. INJECTION LAYER ISOLATION //
local TargetParent = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
if TargetParent:FindFirstChild("XicoHub_MasterHop") then
    TargetParent.XicoHub_MasterHop:Destroy()
end

-- // 3. CORE PROPERTIES & DIRECTORY //
local ActiveBoss = "Berry"
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

local OrderedBosses = {}
for name, _ in pairs(Endpoints) do table.insert(OrderedBosses, name) end
table.sort(OrderedBosses)

-- // 4. TWEEN ANIMATION HELPER //
local function QuickTween(obj, duration, properties)
    local info = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local anim = TweenService:Create(obj, info, properties)
    anim:Play()
    return anim
end

-- // 5. PRIMARY UI FRAMEWORK INTERFACE //
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "XicoHub_MasterHop"
MainGui.Parent = TargetParent
MainGui.ResetOnSpawn = false

local BaseFrame = Instance.new("Frame")
BaseFrame.Name = "BaseFrame"
BaseFrame.Size = UDim2.new(0, 560, 0, 360)
BaseFrame.Position = UDim2.new(0.5, -280, 0.5, -180)
BaseFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
BaseFrame.BorderSizePixel = 0
BaseFrame.Parent = MainGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 8)
FrameCorner.Parent = BaseFrame

local FrameStroke = Instance.new("UIStroke")
FrameStroke.Color = Color3.fromRGB(35, 35, 35)
FrameStroke.Thickness = 1
FrameStroke.Parent = BaseFrame

-- Left Tab Navigation Panel
local SideBar = Instance.new("Frame")
SideBar.Name = "SideBar"
SideBar.Size = UDim2.new(0, 160, 1, 0)
SideBar.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
SideBar.BorderSizePixel = 0
SideBar.Parent = BaseFrame

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 8)
SideCorner.Parent = SideBar

local SideFix = Instance.new("Frame")
SideFix.Size = UDim2.new(0, 15, 1, 0)
SideFix.Position = UDim2.new(1, -15, 0, 0)
SideFix.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
SideFix.BorderSizePixel = 0
SideFix.Parent = SideBar

local SideTitle = Instance.new("TextLabel")
SideTitle.Size = UDim2.new(1, 0, 0, 40)
SideTitle.BackgroundTransparency = 1
SideTitle.Text = "  XicoSkelly Hub"
SideTitle.TextColor3 = Color3.fromRGB(255, 50, 50)
SideTitle.Font = Enum.Font.GothamBold
SideTitle.TextSize = 14
SideTitle.TextXAlignment = Enum.TextXAlignment.Left
SideTitle.Parent = SideBar

local TabScroller = Instance.new("ScrollingFrame")
TabScroller.Size = UDim2.new(1, 0, 1, -45)
TabScroller.Position = UDim2.new(0, 0, 0, 40)
TabScroller.BackgroundTransparency = 1
TabScroller.BorderSizePixel = 0
TabScroller.ScrollBarThickness = 2
TabScroller.ScrollBarImageColor3 = Color3.fromRGB(40, 40, 40)
TabScroller.Parent = SideBar

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Parent = TabScroller
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 2)

-- Right Data Grid Panel
local ContentPane = Instance.new("Frame")
ContentPane.Name = "ContentPane"
ContentPane.Size = UDim2.new(1, -160, 1, 0)
ContentPane.Position = UDim2.new(0, 160, 0, 0)
ContentPane.BackgroundTransparency = 1
ContentPane.Parent = BaseFrame

local ContentHeader = Instance.new("TextLabel")
ContentHeader.Size = UDim2.new(1, -15, 0, 40)
ContentHeader.Position = UDim2.new(0, 15, 0, 0)
ContentHeader.BackgroundTransparency = 1
ContentHeader.Text = "Selected: Berry"
ContentHeader.TextColor3 = Color3.fromRGB(240, 240, 240)
ContentHeader.Font = Enum.Font.GothamBold
ContentHeader.TextSize = 14
ContentHeader.TextXAlignment = Enum.TextXAlignment.Left
ContentHeader.Parent = ContentPane

-- Actions Bar (Refresh Container)
local ActionContainer = Instance.new("Frame")
ActionContainer.Size = UDim2.new(1, -30, 0, 40)
ActionContainer.Position = UDim2.new(0, 15, 0, 45)
ActionContainer.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
ActionContainer.Parent = ContentPane

local ActionCorner = Instance.new("UICorner")
ActionCorner.CornerRadius = UDim.new(0, 6)
ActionCorner.Parent = ActionContainer

local RefreshActionBtn = Instance.new("TextButton")
RefreshActionBtn.Size = UDim2.new(1, 0, 1, 0)
RefreshActionBtn.BackgroundTransparency = 1
RefreshActionBtn.Text = "🔄 Click to Refresh Server List"
RefreshActionBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
RefreshActionBtn.Font = Enum.Font.GothamSemibold
RefreshActionBtn.TextSize = 12
RefreshActionBtn.Parent = ActionContainer

-- Server Cards Window
local ServerScroller = Instance.new("ScrollingFrame")
ServerScroller.Size = UDim2.new(1, -30, 1, -100)
ServerScroller.Position = UDim2.new(0, 15, 0, 95)
ServerScroller.BackgroundTransparency = 1
ServerScroller.BorderSizePixel = 0
ServerScroller.ScrollBarThickness = 4
ServerScroller.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 50)
ServerScroller.Parent = ContentPane

local ServerGrid = Instance.new("UIListLayout")
ServerGrid.Parent = ServerScroller
ServerGrid.SortOrder = Enum.SortOrder.LayoutOrder
ServerGrid.Padding = UDim.new(0, 6)

-- // 6. DYNAMIC REFRESH AND SCRAPER ENGINE //
local function PopulateServerCards()
    -- Clear current listings
    for _, item in pairs(ServerScroller:GetChildren()) do
        if item:IsA("Frame") then item:Destroy() end
    end
    
    local url = Endpoints[ActiveBoss]
    if not url then return end
    
    QuickTween(RefreshActionBtn, 0.15, {TextColor3 = Color3.fromRGB(255, 50, 50)})
    RefreshActionBtn.Text = "⚡ Parsing Global Endpoints..."
    
    -- Clean network fetch execution
    task.spawn(function()
        local success, response = pcall(function()
            return game:HttpGet(url)
        end)
        
        RefreshActionBtn.Text = "🔄 Click to Refresh Server List"
        QuickTween(RefreshActionBtn, 0.15, {TextColor3 = Color3.fromRGB(200, 200, 200)})
        
        if success and response and response ~= "[]" then
            local decodeSuccess, data = pcall(function()
                return HttpService:JSONDecode(response)
            end)
            
            if decodeSuccess and type(data) == "table" then
                local counter = 0
                for _, server in pairs(data) do
                    -- STRICT VALIDATION LOOP FOR MALFORMED/CORRUPTED PAYLOAD ENTRIES
                    if type(server) == "table" then
                        counter = counter + 1
                        
                        local targetJobId = server.JobId or server.id or "N/A"
                        local targetPlaceId = tonumber(server.PlaceId or server.placeId) or game.PlaceId
                        local playerCount = server.Players or server.count or 0
                        local serverAge = server.Age or 0
                        local serverTitle = (server.Name and server.Name ~= "Unknown") and server.Name or (ActiveBoss .. " Instance")
                        
                        -- Card UI Element Container
                        local CardFrame = Instance.new("Frame")
                        CardFrame.Size = UDim2.new(1, -5, 0, 85)
                        CardFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                        CardFrame.BackgroundTransparency = 1
                        CardFrame.Parent = ServerScroller
                        
                        local CardCorner = Instance.new("UICorner")
                        CardCorner.CornerRadius = UDim.new(0, 6)
                        CardCorner.Parent = CardFrame
                        
                        local CardStroke = Instance.new("UIStroke")
                        CardStroke.Color = Color3.fromRGB(28, 28, 28)
                        CardStroke.Parent = CardFrame
                        
                        -- Content Layout Inside Card
                        local TitleLabel = Instance.new("TextLabel")
                        TitleLabel.Size = UDim2.new(0.8, 0, 0, 20)
                        TitleLabel.Position = UDim2.new(0, 10, 0, 8)
                        TitleLabel.BackgroundTransparency = 1
                        TitleLabel.Text = serverTitle
                        TitleLabel.TextColor3 = Color3.fromRGB(140, 210, 140)
                        TitleLabel.Font = Enum.Font.GothamBold
                        TitleLabel.TextSize = 11
                        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
                        TitleLabel.Parent = CardFrame
                        
                        local JobLabel = Instance.new("TextLabel")
                        JobLabel.Size = UDim2.new(0.8, 0, 0, 14)
                        JobLabel.Position = UDim2.new(0, 10, 0, 26)
                        JobLabel.BackgroundTransparency = 1
                        JobLabel.Text = tostring(targetJobId)
                        JobLabel.TextColor3 = Color3.fromRGB(130, 130, 130)
                        JobLabel.Font = Enum.Font.Code
                        JobLabel.TextSize = 10
                        JobLabel.TextXAlignment = Enum.TextXAlignment.Left
                        JobLabel.Parent = CardFrame
                        
                        local MetaLabel = Instance.new("TextLabel")
                        MetaLabel.Size = UDim2.new(0.8, 0, 0, 32)
                        MetaLabel.Position = UDim2.new(0, 10, 0, 42)
                        MetaLabel.BackgroundTransparency = 1
                        MetaLabel.Text = string.format("age: %s\nPlayers: %s/12\nPlaceId: %s", tostring(serverAge), tostring(playerCount), tostring(targetPlaceId))
                        MetaLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
                        MetaLabel.Font = Enum.Font.Gotham
                        MetaLabel.TextSize = 10
                        MetaLabel.TextXAlignment = Enum.TextXAlignment.Left
                        MetaLabel.Parent = CardFrame
                        
                        -- Join Action Button (Cursor Icon Style)
                        local ActionJoinBtn = Instance.new("ImageButton")
                        ActionJoinBtn.Size = UDim2.new(0, 28, 0, 28)
                        ActionJoinBtn.Position = UDim2.new(1, -38, 0.5, -14)
                        ActionJoinBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
                        ActionJoinBtn.Image = "rbxassetid://10826038165" -- Universal Interaction Pointer Icon
                        ActionJoinBtn.ImageColor3 = Color3.fromRGB(200, 200, 200)
                        ActionJoinBtn.Parent = CardFrame
                        
                        local ActionCorner = Instance.new("UICorner")
                        ActionCorner.CornerRadius = UDim.new(0, 6)
                        ActionCorner.Parent = ActionJoinBtn
                        
                        -- Interactive Component Animations
                        ActionJoinBtn.MouseEnter:Connect(function()
                            QuickTween(ActionJoinBtn, 0.15, {BackgroundColor3 = Color3.fromRGB(255, 50, 50), ImageColor3 = Color3.fromRGB(255, 255, 255)})
                        end)
                        ActionJoinBtn.MouseLeave:Connect(function()
                            QuickTween(ActionJoinBtn, 0.15, {BackgroundColor3 = Color3.fromRGB(28, 28, 28), ImageColor3 = Color3.fromRGB(200, 200, 200)})
                        end)
                        
                        ActionJoinBtn.MouseButton1Click:Connect(function()
                            QuickTween(ActionJoinBtn, 0.1, {Scale = Vector2.new(0.9, 0.9)})
                            pcall(function()
                                TeleportService:TeleportToPlaceInstance(targetPlaceId, targetJobId, LocalPlayer)
                            end)
                        end)
                        
                        -- ENTRANCE ANIMATION TWEEN
                        QuickTween(CardFrame, 0.25, {BackgroundTransparency = 0})
                    end
                end
                ServerScroller.CanvasSize = UDim2.new(0, 0, 0, ServerGrid.AbsoluteContentSize.Y + 10)
                if counter == 0 then
                    RefreshActionBtn.Text = "❌ No active servers found for this target."
                end
            end
        else
            RefreshActionBtn.Text = "⚠ Server pool response empty or offline."
        end
    end)
end

RefreshActionBtn.MouseButton1Click:Connect(PopulateServerCards)

-- // 7. TAB INSTANTIATION FACTORY //
local ActiveTabButton = nil

local function BuildNavigationTabs()
    for index, name in ipairs(OrderedBosses) do
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, -10, 0, 30)
        TabBtn.BackgroundTransparency = 1
        TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        TabBtn.Text = "   " .. name
        TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        TabBtn.Font = Enum.Font.GothamSemibold
        TabBtn.TextSize = 11
        TabBtn.TextXAlignment = Enum.TextXAlignment.Left
        TabBtn.LayoutOrder = index
        TabBtn.Parent = TabScroller
        
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 4)
        TabCorner.Parent = TabBtn
        
        -- Handle Defaults
        if name == ActiveBoss then
            ActiveTabButton = TabBtn
            TabBtn.BackgroundTransparency = 0
            TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
        
        -- Mouse Animations
        TabBtn.MouseEnter:Connect(function()
            if ActiveBoss ~= name then
                QuickTween(TabBtn, 0.15, {TextColor3 = Color3.fromRGB(220, 220, 220)})
            end
        end)
        
        TabBtn.MouseLeave:Connect(function()
            if ActiveBoss ~= name then
                QuickTween(TabBtn, 0.15, {TextColor3 = Color3.fromRGB(150, 150, 150)})
            end
        end)
        
        TabBtn.MouseButton1Click:Connect(function()
            if ActiveBoss == name then return end
            
            -- Revert old tab visual status
            if ActiveTabButton then
                QuickTween(ActiveTabButton, 0.15, {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(150, 150, 150)})
            end
            
            -- Target new tab state
            ActiveBoss = name
            ActiveTabButton = TabBtn
            ContentHeader.Text = "Selected: " .. name
            QuickTween(TabBtn, 0.15, {BackgroundTransparency = 0, TextColor3 = Color3.fromRGB(255, 255, 255)})
            
            -- Smooth Grid Refresh Fade
            PopulateServerCards()
        end)
    end
    TabScroller.CanvasSize = UDim2.new(0, 0, 0, TabListLayout.AbsoluteContentSize.Y + 10)
end

BuildNavigationTabs()
PopulateServerCards()

-- // 8. ADAPTIVE FLOATING TOGGLE ICON //
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
    ToggleButton.Size = UDim2.new(0, 46, 0, 46)
    ToggleButton.Position = UDim2.new(0.04, 0, 0.2, 0)
    ToggleButton.Image = "rbxassetid://84090982489875" -- Custom Adaptive Decal Asset Provided
    ToggleButton.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    ToggleButton.ZIndex = 2000
    
    local TCorner = Instance.new("UICorner")
    TCorner.CornerRadius = UDim.new(0, 8)
    TCorner.Parent = ToggleButton
    
    local TStroke = Instance.new("UIStroke")
    TStroke.Color = Color3.fromRGB(255, 50, 50)
    TStroke.Thickness = 1.5
    TStroke.Parent = ToggleButton
    
    -- High-Performance Touch / Mouse Dragging Implementation Loop
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

    ToggleButton.MouseButton1Click:Connect(function()
        BaseFrame.Visible = not BaseFrame.Visible
    end)
end

CreateMobileInterfaceToggle()

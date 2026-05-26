-- // ==============================================================================
-- // XICO HUB | PREMIUM CROSS-SEA SERVER HOPPER
-- // Profile Project: XicoSkelly
-- // Optimization: Compact UI Design (40% Reduced Footprint) & Full Tween Engine
-- // Credits: Made by @alifgamer | Discord: discord.gg/NightHub
-- // ==============================================================================

if not game:IsLoaded() then game.Loaded:Wait() end

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- // ANTI-AFK IMMUNITY SUBSYSTEM //
for _, connection in pairs(getconnections(LocalPlayer.Idled)) do
    connection:Disable()
end
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- // INTERFACE PURGE ENGINE //
local TargetParent = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
if TargetParent:FindFirstChild("XicoHub_HopEngine") then TargetParent.XicoHub_HopEngine:Destroy() end
if TargetParent:FindFirstChild("XicoHub_ToggleScreen") then TargetParent.XicoHub_ToggleScreen:Destroy() end

-- // CORE ARCHITECTURE VARIABLES //
local ActiveBoss = "Berry"
local IsInfoTabActive = false
local Endpoints = {
    ["Berry 🍓"] = "http://nighthub.site/boss/Berry",
    ["Cake Prince 👑"] = "http://nighthub.site/boss/CakePrince",
    ["Castle Raid 🏰"] = "http://nighthub.site/boss/CastleRaid",
    ["Cursed Captain 🏴‍☠️"] = "http://nighthub.site/boss/CursedCaptain",
    ["Darkbeard 🖤"] = "http://nighthub.site/boss/Darkbeard",
    ["Dough King 🍩"] = "http://nighthub.site/boss/DoughKing",
    ["Elite Hunter 🎯"] = "http://nighthub.site/boss/Elite",
    ["Full Moon 🌕"] = "http://nighthub.site/boss/Fullmoon",
    ["Kitsune Island 🦊"] = "http://nighthub.site/boss/KitsuneIsland",
    ["Legendary Haki ✨"] = "http://nighthub.site/boss/HakiLegendary",
    ["Legendary Sword ⚔️"] = "http://nighthub.site/boss/SwordLegendary",
    ["Mirage Island 🏝️"] = "http://nighthub.site/boss/Mirage",
    ["Near Moon 🌙"] = "http://nighthub.site/boss/NearMoon",
    ["Prehistoric Island 🦖"] = "http://nighthub.site/boss/PrehistoricIsland",
    ["Rip Indra ⚡"] = "http://nighthub.site/boss/RipIndra",
    ["Soul Reaper 💀"] = "http://nighthub.site/boss/SoulReaper",
    ["Tyrant of Skies ☁️"] = "http://nighthub.site/boss/TyrantOfTheSkies"
}

local OrderedBosses = {}
for display_name, url in pairs(Endpoints) do
    table.insert(OrderedBosses, {Name = display_name, URL = url})
end
table.sort(OrderedBosses, function(a, b) return a.Name < b.Name end)

-- // TWEEN UTILITY FUNCTIONS //
local function SmoothTween(obj, duration, properties, style, direction)
    local info = TweenInfo.new(duration, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out)
    local anim = TweenService:Create(obj, info, properties)
    anim:Play()
    return anim
end

-- // MAIN DISPLAY CONTAINER SETUP (-40% SCALED PROPORTIONS) //
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "XicoHub_HopEngine"
MainGui.Parent = TargetParent
MainGui.ResetOnSpawn = false

local BaseFrame = Instance.new("Frame")
BaseFrame.Name = "BaseFrame"
BaseFrame.Size = UDim2.new(0, 420, 0, 260) -- Compact professional engineering footprint
BaseFrame.Position = UDim2.new(0.5, -210, 0.5, -130)
BaseFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
BaseFrame.BorderSizePixel = 0
BaseFrame.ClipsDescendants = true
BaseFrame.Parent = MainGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 8)
FrameCorner.Parent = BaseFrame

local FrameStroke = Instance.new("UIStroke")
FrameStroke.Color = Color3.fromRGB(32, 32, 36)
FrameStroke.Thickness = 1.2
FrameStroke.Parent = BaseFrame

-- // SIDEBAR NAVIGATION WINDOW //
local SideBar = Instance.new("Frame")
SideBar.Name = "SideBar"
SideBar.Size = UDim2.new(0, 135, 1, 0)
SideBar.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
SideBar.BorderSizePixel = 0
SideBar.Parent = BaseFrame

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 8)
SideCorner.Parent = SideBar

local SideTitle = Instance.new("TextLabel")
SideTitle.Size = UDim2.new(1, 0, 0, 35)
SideTitle.BackgroundTransparency = 1
SideTitle.Text = "  XicoSkelly Hub"
SideTitle.TextColor3 = Color3.fromRGB(255, 60, 60)
SideTitle.Font = Enum.Font.GothamBold
SideTitle.TextSize = 12
SideTitle.TextXAlignment = Enum.TextXAlignment.Left
SideTitle.Parent = SideBar

local TabScroller = Instance.new("ScrollingFrame")
TabScroller.Size = UDim2.new(1, 0, 1, -75)
TabScroller.Position = UDim2.new(0, 0, 0, 35)
TabScroller.BackgroundTransparency = 1
TabScroller.BorderSizePixel = 0
TabScroller.ScrollBarThickness = 1.5
TabScroller.ScrollBarImageColor3 = Color3.fromRGB(45, 45, 50)
TabScroller.Parent = SideBar

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Parent = TabScroller
TabListLayout.Padding = UDim.new(0, 3)

-- // BOTTOM FIXED INFOMATION NAVIGATION TILE //
local InfoTabBtn = Instance.new("TextButton")
InfoTabBtn.Size = UDim2.new(1, -10, 0, 26)
InfoTabBtn.Position = UDim2.new(0, 5, 1, -32)
InfoTabBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
InfoTabBtn.BackgroundTransparency = 1
InfoTabBtn.Text = "  ℹ️ Information"
InfoTabBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
InfoTabBtn.Font = Enum.Font.GothamSemibold
InfoTabBtn.TextSize = 10
InfoTabBtn.TextXAlignment = Enum.TextXAlignment.Left
InfoTabBtn.Parent = SideBar

local InfoTabCorner = Instance.new("UICorner")
InfoTabCorner.CornerRadius = UDim.new(0, 4)
InfoTabCorner.Parent = InfoTabBtn

-- // RIGHT DYNAMIC VIEWPORT //
local ContentPane = Instance.new("Frame")
ContentPane.Name = "ContentPane"
ContentPane.Size = UDim2.new(1, -135, 1, 0)
ContentPane.Position = UDim2.new(0, 135, 0, 0)
ContentPane.BackgroundTransparency = 1
ContentPane.Parent = BaseFrame

local ContentHeader = Instance.new("TextLabel")
ContentHeader.Size = UDim2.new(1, -15, 0, 35)
ContentHeader.Position = UDim2.new(0, 12, 0, 0)
ContentHeader.BackgroundTransparency = 1
ContentHeader.Text = "Selected: Berry 🍓"
ContentHeader.TextColor3 = Color3.fromRGB(245, 245, 248)
ContentHeader.Font = Enum.Font.GothamBold
ContentHeader.TextSize = 12
ContentHeader.TextXAlignment = Enum.TextXAlignment.Left
ContentHeader.Parent = ContentPane

-- // ACTION BAR CONTAINER //
local ActionContainer = Instance.new("Frame")
ActionContainer.Size = UDim2.new(1, -24, 0, 32)
ActionContainer.Position = UDim2.new(0, 12, 0, 38)
ActionContainer.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
ActionContainer.Parent = ContentPane

local ActionCorner = Instance.new("UICorner")
ActionCorner.CornerRadius = UDim.new(0, 5)
ActionCorner.Parent = ActionContainer

local ActionStroke = Instance.new("UIStroke")
ActionStroke.Color = Color3.fromRGB(28, 28, 32)
ActionStroke.Parent = ActionContainer

local RefreshActionBtn = Instance.new("TextButton")
RefreshActionBtn.Size = UDim2.new(1, 0, 1, 0)
RefreshActionBtn.BackgroundTransparency = 1
RefreshActionBtn.Text = "🔄 Click to Refresh Server List"
RefreshActionBtn.TextColor3 = Color3.fromRGB(210, 210, 215)
RefreshActionBtn.Font = Enum.Font.GothamSemibold
RefreshActionBtn.TextSize = 10
RefreshActionBtn.Parent = ActionContainer

-- // REAL-TIME NETWORK DISPLAY PANEL //
local ServerScroller = Instance.new("ScrollingFrame")
ServerScroller.Size = UDim2.new(1, -24, 1, -82)
ServerScroller.Position = UDim2.new(0, 12, 0, 76)
ServerScroller.BackgroundTransparency = 1
ServerScroller.BorderSizePixel = 0
ServerScroller.ScrollBarThickness = 3
ServerScroller.ScrollBarImageColor3 = Color3.fromRGB(40, 40, 45)
ServerScroller.Parent = ContentPane

local ServerGrid = Instance.new("UIListLayout")
ServerGrid.Parent = ServerScroller
ServerGrid.Padding = UDim.new(0, 5)

-- // DEV CREDENTIALS INFO PANEL //
local InfoDisplayFrame = Instance.new("Frame")
InfoDisplayFrame.Size = UDim2.new(1, -24, 1, -50)
InfoDisplayFrame.Position = UDim2.new(0, 12, 0, 42)
InfoDisplayFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
InfoDisplayFrame.Visible = false
InfoDisplayFrame.Parent = ContentPane

local InfoCorner = Instance.new("UICorner")
InfoCorner.CornerRadius = UDim.new(0, 6)
InfoCorner.Parent = InfoDisplayFrame

local InfoDetails = Instance.new("TextLabel")
InfoDetails.Size = UDim2.new(1, -20, 1, -20)
InfoDetails.Position = UDim2.new(0, 10, 0, 10)
InfoDetails.BackgroundTransparency = 1
InfoDetails.Text = "👑 Developer Profile\nmade by : @alifgamer\n\n🌐 Community Hub\nLink: discord.gg/NightHub\n\n✨ Features Loaded\n• Real-Time Endpoint Fetch\n• Instant Cross-Sea Relocation\n• Memory Leak Mitigation Optimization"
InfoDetails.TextColor3 = Color3.fromRGB(200, 200, 205)
InfoDetails.Font = Enum.Font.GothamSemibold
InfoDetails.TextSize = 10
InfoDetails.TextYAlignment = Enum.TextYAlignment.Top
InfoDetails.TextXAlignment = Enum.TextXAlignment.Left
InfoDetails.Parent = InfoDisplayFrame

-- // WEB API NETWORKING & STRUCTURAL CARD REBUILD ENGINE //
local function ParseActiveAPIEndpoints()
    if IsInfoTabActive then return end
    
    -- Purge previous records cleanly
    for _, item in pairs(ServerScroller:GetChildren()) do
        if item:IsA("Frame") then item:Destroy() end
    end
    
    local TargetEndpointURL = nil
    for _, data in pairs(OrderedBosses) do
        if data.Name == ActiveBoss then
            TargetEndpointURL = data.URL
            break
        end
    end
    if not TargetEndpointURL then return end

    RefreshActionBtn.Text = "⚡ Processing Core API Cluster JSON Data..."
    SmoothTween(RefreshActionBtn, 0.2, {TextColor3 = Color3.fromRGB(255, 60, 60)})

    task.spawn(function()
        local success, rawPayload = pcall(function()
            return game:HttpGet(TargetEndpointURL)
        end)

        RefreshActionBtn.Text = "🔄 Click to Refresh Server List"
        SmoothTween(RefreshActionBtn, 0.2, {TextColor3 = Color3.fromRGB(210, 210, 215)})

        if success and rawPayload and rawPayload ~= "[]" then
            local decodeSuccess, serverCluster = pcall(function()
                return HttpService:JSONDecode(rawPayload)
            end)

            if decodeSuccess and type(serverCluster) == "table" then
                local generatedCardsCount = 0

                for _, node in pairs(serverCluster) do
                    if type(node) == "table" then
                        generatedCardsCount = generatedCardsCount + 1

                        -- Exact JSON Property Mappings From User Image Dataset
                        local NodeJobId = node.JobId or node.id or "N/A"
                        local NodePlaceId = tonumber(node.PlaceId or node.placeId) or game.PlaceId
                        local NodeCurrentPlayers = tonumber(node.Players or node.count) or 0
                        local NodeSeaEnvironment = node.Sea or "Unknown Sea Zone"
                        local NodeUptimeAge = node.Age or 0
                        local NodeServerTitle = (node.Name and node.Name ~= "Unknown" and node.Name ~= "") and node.Name or "Active Mission Variant Pool"

                        -- Standardized Visual Wrapper
                        local CardFrame = Instance.new("Frame")
                        CardFrame.Size = UDim2.new(1, -6, 0, 72)
                        CardFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
                        CardFrame.SizeToContents = Enum.SizeToContents.None
                        CardFrame.Parent = ServerScroller

                        local CardCorner = Instance.new("UICorner")
                        CardCorner.CornerRadius = UDim.new(0, 5)
                        CardCorner.Parent = CardFrame

                        local CardStroke = Instance.new("UIStroke")
                        CardStroke.Color = Color3.fromRGB(28, 28, 32)
                        CardStroke.Parent = CardFrame

                        local InfoContainerFrame = Instance.new("Frame")
                        InfoContainerFrame.Size = UDim2.new(0.8, 0, 1, 0)
                        InfoContainerFrame.BackgroundTransparency = 1
                        InfoContainerFrame.Parent = CardFrame

                        local TitleLabel = Instance.new("TextLabel")
                        TitleLabel.Size = UDim2.new(1, 0, 0, 16)
                        TitleLabel.Position = UDim2.new(0, 8, 0, 6)
                        TitleLabel.BackgroundTransparency = 1
                        TitleLabel.Text = NodeServerTitle
                        TitleLabel.TextColor3 = Color3.fromRGB(135, 220, 135)
                        TitleLabel.Font = Enum.Font.GothamBold
                        TitleLabel.TextSize = 10
                        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
                        TitleLabel.Parent = InfoContainerFrame

                        local JobLabel = Instance.new("TextLabel")
                        JobLabel.Size = UDim2.new(1, 0, 0, 12)
                        JobLabel.Position = UDim2.new(0, 8, 0, 22)
                        JobLabel.BackgroundTransparency = 1
                        JobLabel.Text = tostring(NodeJobId)
                        JobLabel.TextColor3 = Color3.fromRGB(110, 110, 115)
                        JobLabel.Font = Enum.Font.Code
                        JobLabel.TextSize = 8
                        JobLabel.TextXAlignment = Enum.TextXAlignment.Left
                        JobLabel.Parent = InfoContainerFrame

                        local MetaLabel = Instance.new("TextLabel")
                        MetaLabel.Size = UDim2.new(1, 0, 0, 30)
                        MetaLabel.Position = UDim2.new(0, 8, 0, 36)
                        MetaLabel.BackgroundTransparency = 1
                        MetaLabel.Text = string.format("age: %s  |  Players: %s/12  |  %s\nPlaceId: %s", tostring(NodeUptimeAge), tostring(NodeCurrentPlayers), tostring(NodeSeaEnvironment), tostring(NodePlaceId))
                        MetaLabel.TextColor3 = Color3.fromRGB(165, 165, 170)
                        MetaLabel.Font = Enum.Font.GothamSemibold
                        MetaLabel.TextSize = 8
                        MetaLabel.TextXAlignment = Enum.TextXAlignment.Left
                        MetaLabel.Parent = InfoContainerFrame

                        -- Functional Interaction Multi-Sea Pointer
                        local TeleportPointerBtn = Instance.new("ImageButton")
                        TeleportPointerBtn.Size = UDim2.new(0, 22, 0, 22)
                        TeleportPointerBtn.Position = UDim2.new(1, -30, 0.5, -11)
                        TeleportPointerBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
                        TeleportPointerBtn.Image = "rbxassetid://10826038165"
                        TeleportPointerBtn.ImageColor3 = Color3.fromRGB(210, 210, 215)
                        TeleportPointerBtn.Parent = CardFrame

                        local PointerCorner = Instance.new("UICorner")
                        PointerCorner.CornerRadius = UDim.new(0, 4)
                        PointerCorner.Parent = TeleportPointerBtn

                        -- Animations & Cross-Place Instance Hopping Connections
                        TeleportPointerBtn.MouseEnter:Connect(function()
                            SmoothTween(TeleportPointerBtn, 0.15, {BackgroundColor3 = Color3.fromRGB(255, 60, 60), ImageColor3 = Color3.fromRGB(255, 255, 255)})
                        end)
                        TeleportPointerBtn.MouseLeave:Connect(function()
                            SmoothTween(TeleportPointerBtn, 0.15, {BackgroundColor3 = Color3.fromRGB(28, 28, 34), ImageColor3 = Color3.fromRGB(210, 210, 215)})
                        end)

                        TeleportPointerBtn.MouseButton1Click:Connect(function()
                            SmoothTween(TeleportPointerBtn, 0.1, {Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(1, -28, 0.5, -9)})
                            task.wait(0.05)
                            pcall(function()
                                TeleportService:TeleportToPlaceInstance(NodePlaceId, NodeJobId, LocalPlayer)
                            end)
                        end)
                    end
                end
                
                ServerScroller.CanvasSize = UDim2.new(0, 0, 0, ServerGrid.AbsoluteContentSize.Y + 8)
                if generatedCardsCount == 0 then
                    RefreshActionBtn.Text = "❌ No matching instances active inside cluster."
                end
            else
                RefreshActionBtn.Text = "⚠ Abnormality identified during server string conversion."
            end
        else
            RefreshActionBtn.Text = "⚠ Destination network server offline or payload missing."
        end
    end)
end

RefreshActionBtn.MouseButton1Click:Connect(ParseActiveAPIEndpoints)

-- // FACTORY COMPONENT TAB PACKAGING ENGINE //
local SelectedTabGraphicButton = nil

local function InitializeUIStructuralTabs()
    for index, pack in ipairs(OrderedBosses) do
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, -10, 0, 24)
        TabBtn.BackgroundTransparency = 1
        TabBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
        TabBtn.Text = "  " .. pack.Name
        TabBtn.TextColor3 = Color3.fromRGB(145, 145, 150)
        TabBtn.Font = Enum.Font.GothamSemibold
        TabBtn.TextSize = 9.5
        TabBtn.TextXAlignment = Enum.TextXAlignment.Left
        TabBtn.Parent = TabScroller

        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 4)
        TabCorner.Parent = TabBtn

        -- Apply Active Default Layout Styles
        if pack.Name == ActiveBoss then
            SelectedTabGraphicButton = TabBtn
            TabBtn.BackgroundTransparency = 0
            TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end

        TabBtn.MouseEnter:Connect(function()
            if ActiveBoss ~= pack.Name and not IsInfoTabActive then
                SmoothTween(TabBtn, 0.15, {TextColor3 = Color3.fromRGB(230, 230, 235)})
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if ActiveBoss ~= pack.Name and not IsInfoTabActive then
                SmoothTween(TabBtn, 0.15, {TextColor3 = Color3.fromRGB(145, 145, 150)})
            end
        end)

        TabBtn.MouseButton1Click:Connect(function()
            if IsInfoTabActive then
                IsInfoTabActive = false
                InfoDisplayFrame.Visible = false
                ActionContainer.Visible = true
                ServerScroller.Visible = true
                SmoothTween(InfoTabBtn, 0.15, {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(150, 150, 160)})
            end
            if ActiveBoss == pack.Name then return end

            if SelectedTabGraphicButton then
                SmoothTween(SelectedTabGraphicButton, 0.15, {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(145, 145, 150)})
            end

            ActiveBoss = pack.Name
            SelectedTabGraphicButton = TabBtn
            ContentHeader.Text = "Selected: " .. pack.Name
            
            SmoothTween(TabBtn, 0.15, {BackgroundTransparency = 0, TextColor3 = Color3.fromRGB(255, 255, 255)})
            ParseActiveAPIEndpoints()
        end)
    end
    
    TabScroller.CanvasSize = UDim2.new(0, 0, 0, TabListLayout.AbsoluteContentSize.Y + 6)
end

-- // INFO TAB INTERACTION SEPARATION MODULE //
InfoTabBtn.MouseButton1Click:Connect(function()
    if IsInfoTabActive then return end
    IsInfoTabActive = true
    
    if SelectedTabGraphicButton then
        SmoothTween(SelectedTabGraphicButton, 0.15, {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(145, 145, 150)})
        SelectedTabGraphicButton = nil
        ActiveBoss = ""
    end
    
    SmoothTween(InfoTabBtn, 0.15, {BackgroundTransparency = 0, TextColor3 = Color3.fromRGB(255, 255, 255)})
    ContentHeader.Text = "System Information"
    ActionContainer.Visible = false
    ServerScroller.Visible = false
    InfoDisplayFrame.Visible = true
end)

InitializeUIStructuralTabs()
ParseActiveAPIEndpoints()

-- // ADAPTIVE ACCENT LAYER INTERACTION TOGGLE (HAT DECAL IMPL) //
local function AttachAdaptiveControlToggle()
    local ToggleGui = Instance.new("ScreenGui")
    ToggleGui.Name = "XicoHub_ToggleScreen"
    ToggleGui.Parent = TargetParent
    ToggleGui.ResetOnSpawn = false

    local ToggleButton = Instance.new("ImageButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Size = UDim2.new(0, 38, 0, 38)
    ToggleButton.Position = UDim2.new(0.02, 0, 0.15, 0)
    ToggleButton.Image = "rbxassetid://84090982489875" -- Retained explicit hat asset requested
    ToggleButton.BackgroundColor3 = Color3.fromRGB(14, 14, 16)
    ToggleButton.ZIndex = 5000
    ToggleButton.Parent = ToggleGui

    local TCorner = Instance.new("UICorner")
    TCorner.CornerRadius = UDim.new(0, 6)
    TCorner.Parent = ToggleButton

    local TStroke = Instance.new("UIStroke")
    TStroke.Color = Color3.fromRGB(255, 60, 60)
    TStroke.Thickness = 1.2
    TStroke.Parent = ToggleButton

    -- Mobile Optimization Drag Engine Context Loop
    local dragging, dragInput, dragStart, startPos
    
    ToggleButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = ToggleButton.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    ToggleButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            ToggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    ToggleButton.MouseButton1Click:Connect(function()
        BaseFrame.Visible = not BaseFrame.Visible
    end)
end

AttachAdaptiveControlToggle()

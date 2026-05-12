-- // ==============================================================================
-- // XICOSKELLY HUB | BOSS HOP
-- // made by @alifgamer
-- // ==============================================================================

repeat task.wait() until game:IsLoaded()

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Sea Detection Logic
local CurrentSea = "Sea1"
local pId = game.PlaceId
if pId == 4442272160 then CurrentSea = "Sea1"
elseif pId == 7449423635 then CurrentSea = "Sea2"
elseif pId == 2753915549 then CurrentSea = "Sea3" end

-- UI Library (Fluent)
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Xico Hub | Hop",
    SubTitle = "made by @alifgamer",
    TabWidth = 160,
    Size = UDim2.fromScale(0.4, 0.4), -- 40% Scale
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Functional Floating Toggle
local CoreGui = game:GetService("CoreGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ScreenGui = Instance.new("ScreenGui", CoreGui)
local ToggleBtn = Instance.new("ImageButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 10, 0.5, -25)
ToggleBtn.Image = "rbxassetid://84090982489875" 
ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleBtn.Draggable = true 
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", ToggleBtn).Color = Color3.fromRGB(255, 0, 0)

ToggleBtn.MouseButton1Click:Connect(function()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
    task.wait()
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
end)

-- API Mapping (From your code snippet)
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

-- Information Tab
local InfoTab = Window:AddTab({ Title = "Information", Icon = "info" })
InfoTab:AddParagraph({
    Title = "Xico Hub | Boss Hop",
    Content = "Select a boss from the sidebar and click Refresh to see available servers.\nCurrent Location: " .. CurrentSea
})

-- Generate Tabs and Logic
for name, url in pairs(Endpoints) do
    local tab = Window:AddTab({ Title = name })
    local container = tab:AddSection("Servers")

    tab:AddButton({
        Title = "🔄 Click to Refresh List",
        Description = "Fetch latest " .. name .. " data",
        Callback = function()
            -- Visual feedback that something is happening
            Fluent:Notify({Title = "Fetching API", Content = "Searching for " .. name .. " servers...", Duration = 2})
            
            local success, response = pcall(function() 
                return game:HttpGet(url .. "?v=" .. tostring(os.time())) 
            end)
            
            if success and response ~= "" and response ~= "[]" then
                local data = HttpService:JSONDecode(response)
                local serverFound = false
                
                -- Clear current section visuals by refreshing the tab internally (if supported)
                -- If not, we just append new buttons.
                for _, server in pairs(data) do
                    -- Filter for current sea and valid data
                    if server.Sea == CurrentSea and server.JobId ~= game.JobId then
                        serverFound = true
                        local playerCount = server.Players or "?"
                        
                        tab:AddButton({
                            Title = "Join: " .. playerCount .. "/12 Players",
                            Description = "ID: " .. string.sub(tostring(server.JobId), 1, 10),
                            Callback = function()
                                TeleportService:TeleportToPlaceInstance(server.PlaceId, server.JobId, LocalPlayer)
                            end
                        })
                    end
                end
                
                if not serverFound then
                    Fluent:Notify({Title = "Empty", Content = "No active servers found in " .. CurrentSea, Duration = 3})
                end
            else
                Fluent:Notify({Title = "Error", Content = "API currently unavailable for " .. name, Duration = 3})
            end
        end
    })
end

Window:SelectTab(1)
Fluent:Notify({Title = "Xico Hub", Content = "Ready for Boss Hopping.", Duration = 5})

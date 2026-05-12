-- // ==============================================================================
-- // XICO HUB | BOSS HOP
-- // made by @alifgamer
-- // STRICTLY BOSS HOP - NO KAITUN - NO COMBAT
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
    Size = UDim2.fromScale(0.4, 0.4), -- 40% Scale as requested
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Sidebar Categories (Exact matches from your images)
local Tabs = {
    Info = Window:AddTab({ Title = "Information", Icon = "info" }),
    Sword = Window:AddTab({ Title = "Sword Legend", Icon = "sword" }),
    Haki = Window:AddTab({ Title = "Haki Legendary", Icon = "sparkles" }),
    Indra = Window:AddTab({ Title = "Rip Indra", Icon = "skull" }),
    Darkbeard = Window:AddTab({ Title = "Darkbeard", Icon = "ghost" }),
    Dough = Window:AddTab({ Title = "Dough King", Icon = "crown" }),
    Berry = Window:AddTab({ Title = "Berry", Icon = "cherry" }),
    Moon = Window:AddTab({ Title = "Full Moon", Icon = "moon" }),
    Mirage = Window:AddTab({ Title = "Mirage Island", Icon = "map" }),
    Kitsune = Window:AddTab({ Title = "Kitsune Island", Icon = "star" }),
    Prince = Window:AddTab({ Title = "Cake Prince", Icon = "cake" }),
    Elite = Window:AddTab({ Title = "Elite Hunter", Icon = "target" }),
    Raid = Window:AddTab({ Title = "Castle Raid", Icon = "shield" })
}

-- API Mapping (Based on your code snippet image)
local Endpoints = {
    [Tabs.Sword] = "http://nighthub.site/boss/SwordLegendary",
    [Tabs.Haki] = "http://nighthub.site/boss/HakiLegendary",
    [Tabs.Indra] = "http://nighthub.site/boss/RipIndra",
    [Tabs.Darkbeard] = "http://nighthub.site/boss/Darkbeard",
    [Tabs.Dough] = "http://nighthub.site/boss/DoughKing",
    [Tabs.Berry] = "http://nighthub.site/boss/Berry",
    [Tabs.Moon] = "http://nighthub.site/boss/Fullmoon",
    [Tabs.Mirage] = "http://nighthub.site/boss/Mirage",
    [Tabs.Kitsune] = "http://nighthub.site/boss/KitsuneIsland",
    [Tabs.Prince] = "http://nighthub.site/boss/CakePrince",
    [Tabs.Elite] = "http://nighthub.site/boss/Elite",
    [Tabs.Raid] = "http://nighthub.site/boss/CastleRaid"
}

-- Function to generate the server list cards
local function RefreshServerList(tab, url)
    tab:Clear() -- Clear existing elements to prevent lag
    
    tab:AddButton({
        Title = "Click to Refresh List",
        Description = "Fetches live data for " .. tab.Title,
        Callback = function()
            local success, response = pcall(function() return game:HttpGet(url .. "?v=" .. os.time()) end)
            
            if success and response ~= "" and response ~= "[]" then
                local data = HttpService:JSONDecode(response)
                local found = false
                
                for _, server in pairs(data) do
                    -- Filter by current Sea strictly
                    if server.Sea == CurrentSea and server.JobId ~= game.JobId then
                        found = true
                        local players = server.Players or "?"
                        local max = 12
                        
                        -- Create individual Server Card
                        tab:AddButton({
                            Title = "Server: " .. players .. "/" .. max .. " Players",
                            Description = "ID: " .. string.sub(server.JobId, 1, 10) .. "...",
                            Callback = function()
                                Fluent:Notify({Title = "Teleporting", Content = "Joining " .. tab.Title .. " server...", Duration = 3})
                                TeleportService:TeleportToPlaceInstance(server.PlaceId, server.JobId, LocalPlayer)
                            end
                        })
                    end
                end
                
                if not found then
                    tab:AddParagraph({Title = "Empty", Content = "No active servers matching " .. CurrentSea})
                end
            else
                tab:AddParagraph({Title = "Error", Content = "API returned no data or timed out."})
            end
        end
    })
end

-- Initialize all tabs with their refresh logic
for tab, url in pairs(Endpoints) do
    RefreshServerList(tab, url)
end

Window:SelectTab(1)
Fluent:Notify({Title = "Xico Hub", Content = "Boss Hop Loaded. Current Location: " .. CurrentSea, Duration = 5})

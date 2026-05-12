-- // ==============================================================================
-- // XICO HUB | BOSS HOP
-- // made by @alifgamer
-- // FIXED: Callback Error, UI Scaling, and Floating Toggle
-- // ==============================================================================

repeat task.wait() until game:IsLoaded()

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Sea Detection
local CurrentSea = "Sea1"
local pId = game.PlaceId
if pId == 4442272160 then CurrentSea = "Sea1"
elseif pId == 7449423635 then CurrentSea = "Sea2"
elseif pId == 2753915549 then CurrentSea = "Sea3" end

-- Rayfield Library Load
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Xico Hub | Hop",
   LoadingTitle = "XicoSkelly Hub",
   LoadingSubtitle = "by @alifgamer",
   ConfigurationSaving = {
      Enabled = false
   },
   KeySystem = false
})

-- Floating Toggle Fix
local function CreateMobileToggle()
    if CoreGui:FindFirstChild("XicoMobileToggle") then 
        CoreGui.XicoMobileToggle:Destroy() 
    end

    local ScreenGui = Instance.new("ScreenGui")
    local ImageButton = Instance.new("ImageButton")
    local UICorner = Instance.new("UICorner")

    ScreenGui.Name = "XicoMobileToggle"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    ImageButton.Parent = ScreenGui
    ImageButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    ImageButton.BorderSizePixel = 0
    ImageButton.Position = UDim2.new(0.1, 0, 0.1, 0)
    ImageButton.Size = UDim2.new(0, 50, 0, 50)
    ImageButton.Image = "rbxassetid://84090982489875" -- Your requested ID
    ImageButton.Draggable = true

    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = ImageButton

    ImageButton.MouseButton1Click:Connect(function()
        local rWindow = game:GetService("CoreGui").Rayfield.Main
        rWindow.Visible = not rWindow.Visible
    end)
end
CreateMobileToggle()

-- API Mapping
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

-- Tab Creation Logic
for name, url in pairs(Endpoints) do
    local Tab = Window:CreateTab(name, "map-pin")
    local Section = Tab:CreateSection(name .. " Servers")
    
    local ServerData = {} -- Stores [DisplayString] = JobId
    local DropdownOptions = {"Refresh to see servers"}

    local Dropdown = Tab:CreateDropdown({
        Name = "Server List",
        Options = DropdownOptions,
        CurrentOption = {"Refresh to see servers"},
        MultipleOptions = false,
        Flag = "Dropdown_" .. name,
        Callback = function(Option) end,
    })

    Tab:CreateButton({
        Name = "🔄 Refresh List",
        Callback = function()
            Rayfield:Notify({Title = "API Fetch", Content = "Searching for " .. name .. "...", Duration = 2})
            
            local success, response = pcall(function() 
                return game:HttpGet(url .. "?v=" .. tostring(os.time())) 
            end)

            if success and response ~= "" and response ~= "[]" then
                local data = HttpService:JSONDecode(response)
                local newList = {}
                ServerData = {} -- Reset

                for _, server in pairs(data) do
                    -- FIX: Ensure 'server' is a table before checking for 'Sea' to avoid callback error
                    if type(server) == "table" and server.Sea == CurrentSea and server.JobId ~= game.JobId then
                        local label = "[" .. (server.Players or "?") .. "/12] " .. string.sub(tostring(server.JobId), 1, 8)
                        table.insert(newList, label)
                        ServerData[label] = {JobId = server.JobId, PlaceId = server.PlaceId}
                    end
                end

                if #newList > 0 then
                    Dropdown:Set(newList)
                    Rayfield:Notify({Title = "Success", Content = "Found " .. #newList .. " servers.", Duration = 3})
                else
                    Dropdown:Set({"No " .. CurrentSea .. " Servers Found"})
                end
            else
                Rayfield:Notify({Title = "Error", Content = "API Down or Empty.", Duration = 3})
            end
        end,
    })

    Tab:CreateButton({
        Name = "🚀 Join Selected Server",
        Callback = function()
            local selected = Dropdown.CurrentOption[1]
            local target = ServerData[selected]
            
            if target and target.JobId then
                Rayfield:Notify({Title = "Hopping", Content = "Joining " .. name .. "...", Duration = 5})
                TeleportService:TeleportToPlaceInstance(target.PlaceId, target.JobId, LocalPlayer)
            else
                Rayfield:Notify({Title = "Selection Error", Content = "Please select a valid server first.", Duration = 3})
            end
        end,
    })
end

Rayfield:Notify({Title = "Xico Hub Loaded", Content = "Running in " .. CurrentSea, Duration = 5})

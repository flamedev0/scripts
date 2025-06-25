repeat wait() until game:IsLoaded()

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Constants
-- Shared
local Shared = ReplicatedStorage.Shared
local SData = Shared.Data
local Framework = Shared.Framework
local Utils = Shared.Utils

-- Client
local Client = ReplicatedStorage.Client
local Tutorial = require(Client.Tutorial)

--// Utils
local StatsUtil = require(Utils.Stats.StatsUtil)

--// Data
local localData = require(Client.Framework.Services.LocalData)
local Data = localData:Get()

--// Handlers
local EventHandler = Framework.Network.Remote.RemoteEvent
local FunctionHandler = Framework.Network.Remote.RemoteFunction

--// UI Library (Fluent-Renewed)
local Library = loadstring(game:HttpGetAsync("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau"))()
local SaveManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/SaveManager.luau"))()
local InterfaceManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/InterfaceManager.luau"))()

local Window = Library:CreateWindow{
    Title = "Flame | BGSI",
    SubTitle = "by flame",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Resize = true,
    MinSize = Vector2.new(470, 380),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
}

local Tabs = {
    Bubbles = Window:CreateTab{ Title = "Bubbles", Icon = "shell" },
    Automation = Window:CreateTab{ Title = "Automation", Icon = "workflow" },
    Teleport = Window:CreateTab{ Title = "Teleportation", Icon = "move" },
    Pets = Window:CreateTab{ Title = "Pets", Icon = "paw-print" }
}

local Options = Library.Options

--// Bubbles Tab
Tabs.Bubbles:CreateParagraph("BubblesInfo", { Title = "Bubbles", Content = "Bubble-related automation." })
local autoSellPer = 50
local autoBlowValue = false
local autoSellValue = false

Tabs.Bubbles:CreateToggle("AutoBlowBubbles", {
    Title = "Auto Blow Bubbles",
    Default = false
}):OnChanged(function(state)
    autoBlowValue = state
end)

Tabs.Bubbles:CreateToggle("AutoSellBubbles", {
    Title = "Auto Sell Bubbles",
    Default = false
}):OnChanged(function(state)
    autoSellValue = state
end)

Tabs.Bubbles:CreateSlider("AutoSellPercentage", {
    Title = "Sell when reached % of storage",
    Default = 50,
    Min = 1,
    Max = 100,
    Rounding = 0
}):OnChanged(function(value)
    autoSellPer = value
end)

--// Automation Tab
Tabs.Automation:CreateParagraph("AutomationInfo", { Title = "Automation", Content = "Automate coins, areas, and prizes." })
local autoCollectCoinsValue = false
Tabs.Automation:CreateToggle("AutoCollectCoins", {
    Title = "Auto Collect Coins",
    Default = false
}):OnChanged(function(state)
    autoCollectCoinsValue = state
    if autoCollectCoinsValue then
        for i,v in pairs(Tutorial._activePickups) do
            v:Destroy()
            Tutorial._activePickups[tostring(i)] = nil
            game:GetService("ReplicatedStorage").Remotes.Pickups.CollectPickup:FireServer(i)
        end
    end
end)

Tabs.Automation:CreateButton{
    Title = "Unlock all areas",
    Description = "Unlocks all areas automatically",
    Callback = function()
        for i,v in pairs(workspace.Worlds["The Overworld"].Islands:GetChildren()) do
            firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, v.Island.UnlockHitbox, 0)
            task.wait(0.1)
            firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, v.Island.UnlockHitbox, 1)
            task.wait(10)
        end
    end
}

local autoclaimplaytimeval = false
local autoclaimchestsval = false
local autoClaimRiftGiftval = false
Tabs.Automation:CreateToggle("AutoClaimPlaytime", {
    Title = "Auto Claim Playtime",
    Default = false
}):OnChanged(function(state)
    autoclaimplaytimeval = state
end)
Tabs.Automation:CreateToggle("AutoClaimChests", {
    Title = "Auto Claim Chests",
    Default = false
}):OnChanged(function(state)
    autoclaimchestsval = state
end)
Tabs.Automation:CreateToggle("AutoClaimRiftGifts", {
    Title = "Auto Claim Rift Gifts",
    Default = false
}):OnChanged(function(state)
    autoClaimRiftGiftval = state
end)

--// Teleportation Tab
local selectedArea = "The Overworld"
Tabs.Teleport:CreateButton{
    Title = "Teleport",
    Description = "Teleport to the selected area",
    Callback = function()
        if selectedArea == "The Overworld" then
            EventHandler:FireServer("Teleport", "Workspace.Worlds.The Overworld.PortalSpawn")
        else
            EventHandler:FireServer("Teleport", "Workspace.Worlds.The Overworld.Islands."..selectedArea..".Island.Portal.Spawn")
        end
    end
}
Tabs.Teleport:CreateDropdown("AreaSelect", {
    Title = "Select area",
    Values = {"The Overworld", "Floating Island", "Outer Space", "Twilight", "The Void", "Zen"},
    Multi = false,
    Default = 1
}):OnChanged(function(val)
    selectedArea = val
end)

--// Pet Tab
Tabs.Pets:CreateParagraph("PetsInfo", { Title = "Pets", Content = "Pet hatching and gifts automation." })
local autoHatchValue = false
local selectedEgg = ""
local eggs = {}
for eggName, _ in pairs(require(SData.Eggs)) do
    table.insert(eggs, eggName)
end
Tabs.Pets:CreateDropdown("EggSelect", {
    Title = "Select Egg",
    Values = eggs,
    Multi = false,
    Default = 1
}):OnChanged(function(val)
    selectedEgg = val
end)
Tabs.Pets:CreateToggle("AutoHatch", {
    Title = "Auto Hatch",
    Default = false
}):OnChanged(function(state)
    autoHatchValue = state
end)
local autoGiftValue = false
Tabs.Pets:CreateToggle("AutoGift", {
    Title = "Auto Open Mystery Boxes",
    Default = false
}):OnChanged(function(state)
    autoGiftValue = state
end)

--// Event Handlers
coroutine.wrap(function()
    while wait(.5) do
        if autoBlowValue == true then
            EventHandler:FireServer("BlowBubble")
        end
        if autoSellValue == true and (autoSellPer/100)*StatsUtil:GetBubbleStorage(Data) <= Data.Bubble.Amount then
            EventHandler:FireServer("SellBubble")
        end
    end
end)()

workspace.Rendered:GetChildren()[14].ChildAdded:Connect(function(coin)
    if autoCollectCoinsValue == true then
        coin:Destroy()
        Tutorial._activePickups[tostring(coin.Name)] = nil
        game:GetService("ReplicatedStorage").Remotes.Pickups.CollectPickup:FireServer(coin.Name)
    end
end)

coroutine.wrap(function()
    while wait(0.1) do
        if autoclaimplaytimeval == true then
            local count = 1
            for i,v in pairs(Data.PlaytimeRewards.Claimed) do
                count+=1
            end
            FunctionHandler:InvokeServer("ClaimPlaytime", count)
        end
        if autoclaimchestsval == true then
            for i,v in pairs(require(SData.Chests)) do
                EventHandler:FireServer("ClaimChest", i)
            end
        end
    end
end)()

EventHandler.OnClientEvent:Connect(function(eventName, gifts)
    if eventName == "RenderGifts" and autoClaimRiftGiftval then
        for giftId, giftData in pairs(gifts) do
            task.delay(0.1, function()
                EventHandler:FireServer("ClaimRiftGift", giftId)
            end)
        end
    end
end)

coroutine.wrap(function()
    while wait(0.1) do
        if autoHatchValue and selectedEgg ~= "" then
            EventHandler:FireServer("HatchEgg", selectedEgg, 1)
        end
    end
end)()

coroutine.wrap(function()
    while wait(0.1) do
        if autoGiftValue then
            local giftAmount = require(Utils.Stats.ItemUtil):GetOwnedAmount(Data, {
                Type = "Powerup",
                Name = "Mystery Box"
            })
            local amountToOpen = 1
            if giftAmount >= 10 then
                amountToOpen = 10
            elseif giftAmount >= 5 then
                amountToOpen = 5
            end
            if giftAmount > 0 then
                EventHandler:FireServer("UseGift", "Mystery Box", amountToOpen)
                wait(0.5)
                for i = 1, 8 do
                    mouse1click()
                    task.wait(0.5)
                end
            end
        end
    end
end)()

-- CabbitWare.lua - MOBILE FRIENDLY + MORE SPAMTP POSITIONS
-- Features: VoidSpam, SpamTP (12 methods), Orbit (8 methods) + Team Check + Sticky Targeting + Watermark
-- NO EXTERNAL DEPENDENCIES - works on any executor

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--// Device Detection
local IsPC = UserInputService.KeyboardEnabled
local IsMobile = UserInputService.TouchEnabled

--// Settings
local Settings = {
    TeamCheck = false,
    StickyTarget = true,
    TargetPickMethod = "Closest",
    LockedTarget = nil,
    Watermark = false,
    LastPosition = nil,
    IsVoidSpamming = false,
    OrbitSpeed = 30,
    AimKeybindKey = nil,
    AimKeybindMouse = nil,
    AimKeybindName = "None",
    AimPrediction = 0.1,
    AimHoldMode = true,
    BoxESP = false,
    TracerESP = false,
    ESPColor = Color3.fromRGB(255, 50, 50)
}

--// Target pick methods (cycling order)
local TargetPickMethods = {
    "Closest",
    "Random",
    "LowestHealth",
    "HighestHealth",
    "NearestToCursor"
}

--// Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CabbitWare"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

--// Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 360, 0, 330)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -165)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

--// Corner & Stroke
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(80, 80, 90)
UIStroke.Thickness = 1.5
UIStroke.Parent = MainFrame

--// Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundTransparency = 1
TitleBar.Parent = MainFrame

--// Title
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "CabbitWare"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

--// Tab Buttons Frame
local TabFrame = Instance.new("Frame")
TabFrame.Name = "TabFrame"
TabFrame.Size = UDim2.new(1, -20, 0, 25)
TabFrame.Position = UDim2.new(0, 10, 0, 30)
TabFrame.BackgroundTransparency = 1
TabFrame.Parent = MainFrame

--// Info Display Frame
local InfoFrame = Instance.new("Frame")
InfoFrame.Name = "InfoFrame"
InfoFrame.Size = UDim2.new(1, -20, 0, 36)
InfoFrame.Position = UDim2.new(0, 10, 0, 58)
InfoFrame.BackgroundTransparency = 1
InfoFrame.Parent = MainFrame

--// Position Display
local PosDisplay = Instance.new("TextLabel")
PosDisplay.Name = "PosDisplay"
PosDisplay.Size = UDim2.new(1, 0, 0, 18)
PosDisplay.Position = UDim2.new(0, 0, 0, 0)
PosDisplay.BackgroundTransparency = 1
PosDisplay.Text = "Pos: Loading..."
PosDisplay.TextColor3 = Color3.fromRGB(100, 255, 100)
PosDisplay.TextSize = 11
PosDisplay.Font = Enum.Font.Gotham
PosDisplay.TextXAlignment = Enum.TextXAlignment.Left
PosDisplay.Parent = InfoFrame

--// Target Display
local TargetDisplay = Instance.new("TextLabel")
TargetDisplay.Name = "TargetDisplay"
TargetDisplay.Size = UDim2.new(1, 0, 0, 18)
TargetDisplay.Position = UDim2.new(0, 0, 0, 18)
TargetDisplay.BackgroundTransparency = 1
TargetDisplay.Text = "Target: None"
TargetDisplay.TextColor3 = Color3.fromRGB(255, 150, 100)
TargetDisplay.TextSize = 11
TargetDisplay.Font = Enum.Font.Gotham
TargetDisplay.TextXAlignment = Enum.TextXAlignment.Left
TargetDisplay.Parent = InfoFrame

--// Content Pages
local Pages = {}

local function CreatePage(name)
    local page = Instance.new("Frame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, 0, 1, -96)
    page.Position = UDim2.new(0, 0, 0, 96)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = MainFrame
    Pages[name] = page
    return page
end

local MainPage = CreatePage("Main")
local AimPage = CreatePage("Aim")
local VisualsPage = CreatePage("Visuals")
local MiscPage = CreatePage("Misc")
local PlayerListPage = CreatePage("PlayerList")

MainPage.Visible = true

--// Create Tab Button Function with click effect
local function CreateTabButton(text, position, pageName, btnSize)
    btnSize = btnSize or UDim2.new(0, 100, 1, 0)
    local btn = Instance.new("TextButton")
    btn.Name = text .. "Tab"
    btn.Size = btnSize
    btn.Position = position
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.Parent = TabFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = btn
    
    btn.MouseButton1Down:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(btnSize.X.Scale, btnSize.X.Offset - 4, btnSize.Y.Scale, btnSize.Y.Offset - 2), Position = position + UDim2.new(0, 2, 0, 1)}):Play()
    end)
    
    btn.MouseButton1Up:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {Size = btnSize, Position = position}):Play()
    end)
    
    btn.MouseButton1Click:Connect(function()
        for _, page in pairs(Pages) do
            page.Visible = false
        end
        Pages[pageName].Visible = true
        
        for _, child in pairs(TabFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
                child.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
        end
        btn.BackgroundColor3 = Color3.fromRGB(60, 100, 60)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    
    return btn
end

local tabBtnSize = UDim2.new(0, 64, 1, 0)
local MainTabBtn = CreateTabButton("Main", UDim2.new(0, 0, 0, 0), "Main", tabBtnSize)
local AimTabBtn = CreateTabButton("Aim", UDim2.new(0, 69, 0, 0), "Aim", tabBtnSize)
local VisualsTabBtn = CreateTabButton("Visuals", UDim2.new(0, 138, 0, 0), "Visuals", tabBtnSize)
local MiscTabBtn = CreateTabButton("Misc", UDim2.new(0, 207, 0, 0), "Misc", tabBtnSize)
local PlayerListTabBtn = CreateTabButton("List", UDim2.new(0, 276, 0, 0), "PlayerList", tabBtnSize)

MainTabBtn.BackgroundColor3 = Color3.fromRGB(60, 100, 60)
MainTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

--// Drag functionality
local dragging, dragInput, dragStart, startPos

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

--// Feature Data
local Features = {
    VoidSpam = {
        Enabled = false,
        Method = 1,
        Methods = {
            "Rapid Far",
            "Extreme Jitter",
            "Deep Spiral",
            "Far Circle",
            "Hyper Bounce",
            "Multi Teleport",
            "Far Orbit",
            "Absolute Chaos",
            "YoYo"
        }
    },
    SpamTP = {
        Enabled = false,
        Method = 1,
        Methods = {
            "Circle Target",
            "Teleport Behind",
            "Teleport Above",
            "Teleport Below",
            "Rapid Jitter",
            "Orbit Teleport",
            "Lag Teleport",
            "Teleport In Front",
            "Above Head",
            "Behind Head",
            "Random Around",
            "Teleport Inside"
        }
    },
    Orbit = {
        Enabled = false,
        Method = 1,
        Methods = {
            "Circle Orbit",
            "Figure Eight",
            "Spiral Orbit",
            "Vertical Loop",
            "Horizontal Loop",
            "Random Orbit",
            "Close Orbit",
            "Stationary Spin"
        }
    },
    Aim = {
        Enabled = false,
        Method = 1,
        Methods = {
            "Aimbot",
            "Silent Aim",
            "Smooth Aim",
            "FOV Aim"
        }
    }
}

--// Get Target Function
local function GetTarget()
    if Settings.StickyTarget and Settings.LockedTarget then
        local locked = Settings.LockedTarget
        if not locked.Parent or not locked.Character then
            Settings.LockedTarget = nil
        else
            local tHRP = locked.Character:FindFirstChild("HumanoidRootPart")
            local tHumanoid = locked.Character:FindFirstChildOfClass("Humanoid")
            if not tHRP or not tHumanoid or tHumanoid.Health <= 0 then
                Settings.LockedTarget = nil
            elseif Settings.TeamCheck and locked.Team == LocalPlayer.Team then
                Settings.LockedTarget = nil
            else
                local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if myHRP and tHRP then
                    local distance = (myHRP.Position - tHRP.Position).Magnitude
                    return locked, distance
                end
            end
        end
    end
    
    local validTargets = {}
    local myHRP = nil
    
    if LocalPlayer.Character then
        myHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    end
    
    if not myHRP then return nil end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if not (Settings.TeamCheck and player.Team == LocalPlayer.Team) then
                local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
                local tHumanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if targetHRP and tHumanoid and tHumanoid.Health > 0 then
                    local distance = (myHRP.Position - targetHRP.Position).Magnitude
                    table.insert(validTargets, {
                        Player = player,
                        HRP = targetHRP,
                        Humanoid = tHumanoid,
                        Distance = distance
                    })
                end
            end
        end
    end
    
    if #validTargets == 0 then return nil end
    
    local selected = nil
    
    if Settings.TargetPickMethod == "Closest" then
        table.sort(validTargets, function(a, b) return a.Distance < b.Distance end)
        selected = validTargets[1]
    elseif Settings.TargetPickMethod == "Random" then
        selected = validTargets[math.random(1, #validTargets)]
    elseif Settings.TargetPickMethod == "LowestHealth" then
        table.sort(validTargets, function(a, b) return a.Humanoid.Health < b.Humanoid.Health end)
        selected = validTargets[1]
    elseif Settings.TargetPickMethod == "HighestHealth" then
        table.sort(validTargets, function(a, b) return a.Humanoid.Health > b.Humanoid.Health end)
        selected = validTargets[1]
    elseif Settings.TargetPickMethod == "NearestToCursor" then
        local mouse = LocalPlayer:GetMouse()
        if mouse and mouse.Hit then
            local cursorPos = mouse.Hit.Position
            local closestDistToCursor = math.huge
            for _, target in pairs(validTargets) do
                local distToCursor = (target.HRP.Position - cursorPos).Magnitude
                if distToCursor < closestDistToCursor then
                    closestDistToCursor = distToCursor
                    selected = target
                end
            end
        else
            table.sort(validTargets, function(a, b) return a.Distance < b.Distance end)
            selected = validTargets[1]
        end
    else
        table.sort(validTargets, function(a, b) return a.Distance < b.Distance end)
        selected = validTargets[1]
    end
    
    if Settings.StickyTarget and selected then
        Settings.LockedTarget = selected.Player
    end
    
    return selected and selected.Player or nil, selected and selected.Distance or nil
end

--// Click Effect Function
local function AddClickEffect(button)
    button.AutoButtonColor = false
    
    local originalSize = button.Size
    local originalPos = button.Position
    
    button.MouseButton1Down:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.08), {
            Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset - 4, originalSize.Y.Scale, originalSize.Y.Offset - 4),
            Position = UDim2.new(originalPos.X.Scale, originalPos.X.Offset + 2, originalPos.Y.Scale, originalPos.Y.Offset + 2)
        }):Play()
    end)
    
    button.MouseButton1Up:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.08), {
            Size = originalSize,
            Position = originalPos
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.08), {
            Size = originalSize,
            Position = originalPos
        }):Play()
    end)
end

--// UI Creation Function for feature buttons
local function CreateFeatureButton(name, position, parent)
    local Container = Instance.new("Frame")
    Container.Name = name .. "Container"
    Container.Size = UDim2.new(0, 250, 0, 40)
    Container.Position = position
    Container.BackgroundTransparency = 1
    Container.Parent = parent

    local MainBtn = Instance.new("TextButton")
    MainBtn.Name = name .. "Btn"
    MainBtn.Size = UDim2.new(0, 150, 1, 0)
    MainBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    MainBtn.Text = name .. "\n" .. Features[name].Methods[1]
    MainBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    MainBtn.TextSize = 12
    MainBtn.Font = Enum.Font.Gotham
    MainBtn.TextWrapped = true
    MainBtn.Parent = Container

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = MainBtn

    local MethodLabel = Instance.new("TextLabel")
    MethodLabel.Name = "MethodLabel"
    MethodLabel.Size = UDim2.new(0, 50, 1, 0)
    MethodLabel.Position = UDim2.new(0, 155, 0, 0)
    MethodLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    MethodLabel.Text = "1/" .. #Features[name].Methods
    MethodLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    MethodLabel.TextSize = 11
    MethodLabel.Font = Enum.Font.Gotham
    MethodLabel.Parent = Container

    local MethodCorner = Instance.new("UICorner")
    MethodCorner.CornerRadius = UDim.new(0, 6)
    MethodCorner.Parent = MethodLabel

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Name = "ToggleBtn"
    ToggleBtn.Size = UDim2.new(0, 40, 1, 0)
    ToggleBtn.Position = UDim2.new(0, 210, 0, 0)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
    ToggleBtn.Text = "OFF"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    ToggleBtn.TextSize = 12
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.Parent = Container

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 6)
    ToggleCorner.Parent = ToggleBtn
    
    AddClickEffect(MainBtn)
    AddClickEffect(ToggleBtn)

    return MainBtn, MethodLabel, ToggleBtn
end

--// Create Main Page Buttons
local VoidBtn, VoidMethod, VoidToggle = CreateFeatureButton("VoidSpam", UDim2.new(0, 10, 0, 0), MainPage)
local TpBtn, TpMethod, TpToggle = CreateFeatureButton("SpamTP", UDim2.new(0, 10, 0, 45), MainPage)
local OrbitBtn, OrbitMethod, OrbitToggle = CreateFeatureButton("Orbit", UDim2.new(0, 10, 0, 90), MainPage)

--// Custom Aim Page UI
local AimContent = Instance.new("Frame")
AimContent.Name = "AimContent"
AimContent.Size = UDim2.new(1, -20, 1, -10)
AimContent.Position = UDim2.new(0, 10, 0, 5)
AimContent.BackgroundTransparency = 1
AimContent.Parent = AimPage

local function CreateAimRow(yPos)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 36)
    row.Position = UDim2.new(0, 0, 0, yPos)
    row.BackgroundTransparency = 1
    row.Parent = AimContent
    return row
end

--// Aim Toggle Row
local AimToggleRow = CreateAimRow(0)
local AimToggleLabel = Instance.new("TextLabel")
AimToggleLabel.Size = UDim2.new(0, 150, 1, 0)
AimToggleLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
AimToggleLabel.Text = "Aim Assist"
AimToggleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
AimToggleLabel.TextSize = 12
AimToggleLabel.Font = Enum.Font.GothamBold
AimToggleLabel.Parent = AimToggleRow
local AimToggleLabelCorner = Instance.new("UICorner")
AimToggleLabelCorner.CornerRadius = UDim.new(0, 6)
AimToggleLabelCorner.Parent = AimToggleLabel

local AimToggleBtn = Instance.new("TextButton")
AimToggleBtn.Size = UDim2.new(0, 80, 1, 0)
AimToggleBtn.Position = UDim2.new(0, 160, 0, 0)
AimToggleBtn.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
AimToggleBtn.Text = "OFF"
AimToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
AimToggleBtn.TextSize = 13
AimToggleBtn.Font = Enum.Font.GothamBold
AimToggleBtn.Parent = AimToggleRow
local AimToggleBtnCorner = Instance.new("UICorner")
AimToggleBtnCorner.CornerRadius = UDim.new(0, 6)
AimToggleBtnCorner.Parent = AimToggleBtn
AddClickEffect(AimToggleBtn)

AimToggleBtn.MouseButton1Click:Connect(function()
    Features.Aim.Enabled = not Features.Aim.Enabled
    if Features.Aim.Enabled then
        AimToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 80, 30)
        AimToggleBtn.Text = "ON"
        AimToggleBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        if FOVCircle then FOVCircle.Visible = true end
    else
        AimToggleBtn.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
        AimToggleBtn.Text = "OFF"
        AimToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        if FOVCircle then FOVCircle.Visible = false end
    end
end)

--// Method Dropdown Row
local AimMethodRow = CreateAimRow(42)
local AimMethodLabel = Instance.new("TextLabel")
AimMethodLabel.Size = UDim2.new(0, 80, 1, 0)
AimMethodLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
AimMethodLabel.Text = "Method"
AimMethodLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
AimMethodLabel.TextSize = 12
AimMethodLabel.Font = Enum.Font.GothamBold
AimMethodLabel.Parent = AimMethodRow
local AimMethodLabelCorner = Instance.new("UICorner")
AimMethodLabelCorner.CornerRadius = UDim.new(0, 6)
AimMethodLabelCorner.Parent = AimMethodLabel

local AimDropdownBtn = Instance.new("TextButton")
AimDropdownBtn.Size = UDim2.new(0, 170, 1, 0)
AimDropdownBtn.Position = UDim2.new(0, 90, 0, 0)
AimDropdownBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
AimDropdownBtn.Text = Features.Aim.Methods[1]
AimDropdownBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
AimDropdownBtn.TextSize = 11
AimDropdownBtn.Font = Enum.Font.Gotham
AimDropdownBtn.Parent = AimMethodRow
local AimDropdownBtnCorner = Instance.new("UICorner")
AimDropdownBtnCorner.CornerRadius = UDim.new(0, 6)
AimDropdownBtnCorner.Parent = AimDropdownBtn
AddClickEffect(AimDropdownBtn)

local AimDropdownFrame = Instance.new("Frame")
AimDropdownFrame.Name = "AimDropdownFrame"
AimDropdownFrame.Size = UDim2.new(0, 170, 0, #Features.Aim.Methods * 28)
AimDropdownFrame.Position = UDim2.new(0, 100, 0, 138)
AimDropdownFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
AimDropdownFrame.BorderSizePixel = 0
AimDropdownFrame.Visible = false
AimDropdownFrame.ZIndex = 20
AimDropdownFrame.Parent = AimPage
local AimDropdownFrameStroke = Instance.new("UIStroke")
AimDropdownFrameStroke.Color = Color3.fromRGB(80, 80, 90)
AimDropdownFrameStroke.Thickness = 1
AimDropdownFrameStroke.Parent = AimDropdownFrame
local AimDropdownFrameCorner = Instance.new("UICorner")
AimDropdownFrameCorner.CornerRadius = UDim.new(0, 6)
AimDropdownFrameCorner.Parent = AimDropdownFrame

local dropdownOpen = false
for i, methodName in ipairs(Features.Aim.Methods) do
    local option = Instance.new("TextButton")
    option.Name = "Option_" .. methodName
    option.Size = UDim2.new(1, 0, 0, 28)
    option.Position = UDim2.new(0, 0, 0, (i - 1) * 28)
    option.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    option.Text = methodName
    option.TextColor3 = Color3.fromRGB(200, 200, 200)
    option.TextSize = 11
    option.Font = Enum.Font.Gotham
    option.ZIndex = 21
    option.Parent = AimDropdownFrame
    local optionCorner = Instance.new("UICorner")
    optionCorner.CornerRadius = UDim.new(0, 4)
    optionCorner.Parent = option
    
    option.MouseEnter:Connect(function()
        option.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    end)
    option.MouseLeave:Connect(function()
        option.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    end)
    
    option.MouseButton1Click:Connect(function()
        Features.Aim.Method = i
        AimDropdownBtn.Text = methodName
        dropdownOpen = false
        AimDropdownFrame.Visible = false
    end)
end

AimDropdownBtn.MouseButton1Click:Connect(function()
    dropdownOpen = not dropdownOpen
    AimDropdownFrame.Visible = dropdownOpen
end)

--// Prediction Row
local AimPredRow = CreateAimRow(84)
local AimPredLabel = Instance.new("TextLabel")
AimPredLabel.Size = UDim2.new(0, 80, 1, 0)
AimPredLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
AimPredLabel.Text = "Predict"
AimPredLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
AimPredLabel.TextSize = 12
AimPredLabel.Font = Enum.Font.GothamBold
AimPredLabel.Parent = AimPredRow
local AimPredLabelCorner = Instance.new("UICorner")
AimPredLabelCorner.CornerRadius = UDim.new(0, 6)
AimPredLabelCorner.Parent = AimPredLabel

local AimPredMinus = Instance.new("TextButton")
AimPredMinus.Size = UDim2.new(0, 35, 1, 0)
AimPredMinus.Position = UDim2.new(0, 90, 0, 0)
AimPredMinus.BackgroundColor3 = Color3.fromRGB(80, 50, 50)
AimPredMinus.Text = "-"
AimPredMinus.TextColor3 = Color3.fromRGB(255, 100, 100)
AimPredMinus.TextSize = 18
AimPredMinus.Font = Enum.Font.GothamBold
AimPredMinus.Parent = AimPredRow
local AimPredMinusCorner = Instance.new("UICorner")
AimPredMinusCorner.CornerRadius = UDim.new(0, 6)
AimPredMinusCorner.Parent = AimPredMinus

local AimPredValue = Instance.new("TextLabel")
AimPredValue.Size = UDim2.new(0, 50, 1, 0)
AimPredValue.Position = UDim2.new(0, 130, 0, 0)
AimPredValue.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
AimPredValue.Text = string.format("%.2f", Settings.AimPrediction)
AimPredValue.TextColor3 = Color3.fromRGB(100, 255, 100)
AimPredValue.TextSize = 14
AimPredValue.Font = Enum.Font.GothamBold
AimPredValue.Parent = AimPredRow
local AimPredValueCorner = Instance.new("UICorner")
AimPredValueCorner.CornerRadius = UDim.new(0, 6)
AimPredValueCorner.Parent = AimPredValue

local AimPredPlus = Instance.new("TextButton")
AimPredPlus.Size = UDim2.new(0, 35, 1, 0)
AimPredPlus.Position = UDim2.new(0, 185, 0, 0)
AimPredPlus.BackgroundColor3 = Color3.fromRGB(50, 80, 50)
AimPredPlus.Text = "+"
AimPredPlus.TextColor3 = Color3.fromRGB(100, 255, 100)
AimPredPlus.TextSize = 18
AimPredPlus.Font = Enum.Font.GothamBold
AimPredPlus.Parent = AimPredRow
local AimPredPlusCorner = Instance.new("UICorner")
AimPredPlusCorner.CornerRadius = UDim.new(0, 6)
AimPredPlusCorner.Parent = AimPredPlus

AddClickEffect(AimPredMinus)
AddClickEffect(AimPredPlus)

AimPredMinus.MouseButton1Click:Connect(function()
    local val = (Settings.AimPrediction - 0.05) * 100
    Settings.AimPrediction = math.max(0, math.floor(val + 0.5) / 100)
    AimPredValue.Text = string.format("%.2f", Settings.AimPrediction)
end)

AimPredPlus.MouseButton1Click:Connect(function()
    local val = (Settings.AimPrediction + 0.05) * 100
    Settings.AimPrediction = math.min(1, math.floor(val + 0.5) / 100)
    AimPredValue.Text = string.format("%.2f", Settings.AimPrediction)
end)

--// Keybind Row (PC Only)
local AimKeybindRow = nil
local AimKeybindBtn = nil
if IsPC then
    AimKeybindRow = CreateAimRow(126)
    local AimKeybindLabel = Instance.new("TextLabel")
    AimKeybindLabel.Size = UDim2.new(0, 80, 1, 0)
    AimKeybindLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    AimKeybindLabel.Text = "Keybind"
    AimKeybindLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    AimKeybindLabel.TextSize = 12
    AimKeybindLabel.Font = Enum.Font.GothamBold
    AimKeybindLabel.Parent = AimKeybindRow
    local AimKeybindLabelCorner = Instance.new("UICorner")
    AimKeybindLabelCorner.CornerRadius = UDim.new(0, 6)
    AimKeybindLabelCorner.Parent = AimKeybindLabel
    
    AimKeybindBtn = Instance.new("TextButton")
    AimKeybindBtn.Size = UDim2.new(0, 130, 1, 0)
    AimKeybindBtn.Position = UDim2.new(0, 90, 0, 0)
    AimKeybindBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    AimKeybindBtn.Text = "Key: " .. Settings.AimKeybindName
    AimKeybindBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    AimKeybindBtn.TextSize = 12
    AimKeybindBtn.Font = Enum.Font.Gotham
    AimKeybindBtn.Parent = AimKeybindRow
    local AimKeybindBtnCorner = Instance.new("UICorner")
    AimKeybindBtnCorner.CornerRadius = UDim.new(0, 6)
    AimKeybindBtnCorner.Parent = AimKeybindBtn
    AddClickEffect(AimKeybindBtn)
    
    local listening = false
    AimKeybindBtn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        AimKeybindBtn.Text = "Press a key..."
        AimKeybindBtn.TextColor3 = Color3.fromRGB(255, 255, 100)
        
        local conn = nil
        conn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                Settings.AimKeybindKey = input.KeyCode
                Settings.AimKeybindMouse = nil
                Settings.AimKeybindName = input.KeyCode.Name
                AimKeybindBtn.Text = "Key: " .. Settings.AimKeybindName
                AimKeybindBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
                listening = false
                if conn then conn:Disconnect() end
            elseif input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.MouseButton2
                or input.UserInputType == Enum.UserInputType.MouseButton3 then
                Settings.AimKeybindKey = nil
                Settings.AimKeybindMouse = input.UserInputType
                local mouseName = (input.UserInputType == Enum.UserInputType.MouseButton1 and "LMB")
                    or (input.UserInputType == Enum.UserInputType.MouseButton2 and "RMB")
                    or "MMB"
                Settings.AimKeybindName = mouseName
                AimKeybindBtn.Text = "Key: " .. Settings.AimKeybindName
                AimKeybindBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
                listening = false
                if conn then conn:Disconnect() end
            end
        end)
    end)
end

--// Hold Mode Row
local AimModeRow = CreateAimRow(IsPC and 168 or 126)
local AimModeLabel = Instance.new("TextLabel")
AimModeLabel.Size = UDim2.new(0, 100, 1, 0)
AimModeLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
AimModeLabel.Text = "Aim Mode"
AimModeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
AimModeLabel.TextSize = 12
AimModeLabel.Font = Enum.Font.GothamBold
AimModeLabel.Parent = AimModeRow
local AimModeLabelCorner = Instance.new("UICorner")
AimModeLabelCorner.CornerRadius = UDim.new(0, 6)
AimModeLabelCorner.Parent = AimModeLabel

local AimModeBtn = Instance.new("TextButton")
AimModeBtn.Size = UDim2.new(0, 120, 1, 0)
AimModeBtn.Position = UDim2.new(0, 110, 0, 0)
AimModeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
AimModeBtn.Text = Settings.AimHoldMode and "Hold" or "Toggle"
AimModeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
AimModeBtn.TextSize = 12
AimModeBtn.Font = Enum.Font.GothamBold
AimModeBtn.Parent = AimModeRow
local AimModeBtnCorner = Instance.new("UICorner")
AimModeBtnCorner.CornerRadius = UDim.new(0, 6)
AimModeBtnCorner.Parent = AimModeBtn
AddClickEffect(AimModeBtn)

AimModeBtn.MouseButton1Click:Connect(function()
    Settings.AimHoldMode = not Settings.AimHoldMode
    AimModeBtn.Text = Settings.AimHoldMode and "Hold" or "Toggle"
end)

--// Create Misc Page
local MiscContent = Instance.new("Frame")
MiscContent.Name = "MiscContent"
MiscContent.Size = UDim2.new(1, -20, 1, -10)
MiscContent.Position = UDim2.new(0, 10, 0, 5)
MiscContent.BackgroundTransparency = 1
MiscContent.Parent = MiscPage

local function GetTargetPickMethodIndex()
    for i, m in ipairs(TargetPickMethods) do
        if m == Settings.TargetPickMethod then
            return i
        end
    end
    return 1
end

local function CreateCyclingButton(name, options, settingKey, position)
    local Container = Instance.new("Frame")
    Container.Name = name .. "Container"
    Container.Size = UDim2.new(0, 250, 0, 35)
    Container.Position = position
    Container.BackgroundTransparency = 1
    Container.Parent = MiscContent

    local Label = Instance.new("TextLabel")
    Label.Name = name .. "Label"
    Label.Size = UDim2.new(0, 100, 1, 0)
    Label.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamBold
    Label.Parent = Container

    local LabelCorner = Instance.new("UICorner")
    LabelCorner.CornerRadius = UDim.new(0, 6)
    LabelCorner.Parent = Label

    local CycleBtn = Instance.new("TextButton")
    CycleBtn.Name = name .. "CycleBtn"
    CycleBtn.Size = UDim2.new(0, 135, 1, 0)
    CycleBtn.Position = UDim2.new(0, 110, 0, 0)
    CycleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    CycleBtn.Text = Settings[settingKey] .. " (" .. GetTargetPickMethodIndex() .. "/" .. #options .. ")"
    CycleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    CycleBtn.TextSize = 11
    CycleBtn.Font = Enum.Font.Gotham
    CycleBtn.Parent = Container

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = CycleBtn
    
    AddClickEffect(CycleBtn)

    CycleBtn.MouseButton1Click:Connect(function()
        local currentIndex = GetTargetPickMethodIndex()
        local nextIndex = currentIndex % #options + 1
        Settings[settingKey] = options[nextIndex]
        CycleBtn.Text = Settings[settingKey] .. " (" .. nextIndex .. "/" .. #options .. ")"
        
        TweenService:Create(CycleBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(55, 55, 65)}):Play()
        task.wait(0.1)
        TweenService:Create(CycleBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(35, 35, 45)}):Play()
        
        if settingKey == "TargetPickMethod" and Settings.StickyTarget then
            Settings.LockedTarget = nil
        end
    end)
    
    return CycleBtn
end

local function CreateSpeedButtons(position)
    local Container = Instance.new("Frame")
    Container.Name = "OrbitSpeedContainer"
    Container.Size = UDim2.new(0, 250, 0, 40)
    Container.Position = position
    Container.BackgroundTransparency = 1
    Container.Parent = MiscContent

    local Label = Instance.new("TextLabel")
    Label.Name = "SpeedLabel"
    Label.Size = UDim2.new(0, 80, 1, 0)
    Label.Position = UDim2.new(0, 0, 0, 0)
    Label.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    Label.Text = "Orbit Speed"
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamBold
    Label.Parent = Container

    local LabelCorner = Instance.new("UICorner")
    LabelCorner.CornerRadius = UDim.new(0, 6)
    LabelCorner.Parent = Label

    local MinusBtn = Instance.new("TextButton")
    MinusBtn.Name = "MinusBtn"
    MinusBtn.Size = UDim2.new(0, 35, 1, 0)
    MinusBtn.Position = UDim2.new(0, 85, 0, 0)
    MinusBtn.BackgroundColor3 = Color3.fromRGB(80, 50, 50)
    MinusBtn.Text = "-"
    MinusBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    MinusBtn.TextSize = 18
    MinusBtn.Font = Enum.Font.GothamBold
    MinusBtn.Parent = Container
    
    local MinusCorner = Instance.new("UICorner")
    MinusCorner.CornerRadius = UDim.new(0, 6)
    MinusCorner.Parent = MinusBtn

    local SpeedValue = Instance.new("TextLabel")
    SpeedValue.Name = "SpeedValue"
    SpeedValue.Size = UDim2.new(0, 50, 1, 0)
    SpeedValue.Position = UDim2.new(0, 125, 0, 0)
    SpeedValue.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    SpeedValue.Text = tostring(Settings.OrbitSpeed)
    SpeedValue.TextColor3 = Color3.fromRGB(100, 255, 100)
    SpeedValue.TextSize = 14
    SpeedValue.Font = Enum.Font.GothamBold
    SpeedValue.Parent = Container
    
    local ValueCorner = Instance.new("UICorner")
    ValueCorner.CornerRadius = UDim.new(0, 6)
    ValueCorner.Parent = SpeedValue

    local PlusBtn = Instance.new("TextButton")
    PlusBtn.Name = "PlusBtn"
    PlusBtn.Size = UDim2.new(0, 35, 1, 0)
    PlusBtn.Position = UDim2.new(0, 180, 0, 0)
    PlusBtn.BackgroundColor3 = Color3.fromRGB(50, 80, 50)
    PlusBtn.Text = "+"
    PlusBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
    PlusBtn.TextSize = 18
    PlusBtn.Font = Enum.Font.GothamBold
    PlusBtn.Parent = Container
    
    local PlusCorner = Instance.new("UICorner")
    PlusCorner.CornerRadius = UDim.new(0, 6)
    PlusCorner.Parent = PlusBtn

    AddClickEffect(MinusBtn)
    AddClickEffect(PlusBtn)

    MinusBtn.MouseButton1Click:Connect(function()
        Settings.OrbitSpeed = math.max(5, Settings.OrbitSpeed - 5)
        SpeedValue.Text = tostring(Settings.OrbitSpeed)
        TweenService:Create(SpeedValue, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(55, 55, 65)}):Play()
        task.wait(0.1)
        TweenService:Create(SpeedValue, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(35, 35, 45)}):Play()
    end)

    PlusBtn.MouseButton1Click:Connect(function()
        Settings.OrbitSpeed = math.min(200, Settings.OrbitSpeed + 5)
        SpeedValue.Text = tostring(Settings.OrbitSpeed)
        TweenService:Create(SpeedValue, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(55, 55, 65)}):Play()
        task.wait(0.1)
        TweenService:Create(SpeedValue, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(35, 35, 45)}):Play()
    end)
    
    return Container
end

local function CreateMiscToggle(name, position, settingKey)
    local Container = Instance.new("Frame")
    Container.Name = name .. "Container"
    Container.Size = UDim2.new(0, 250, 0, 35)
    Container.Position = position
    Container.BackgroundTransparency = 1
    Container.Parent = MiscContent

    local Label = Instance.new("TextLabel")
    Label.Name = name .. "Label"
    Label.Size = UDim2.new(0, 150, 1, 0)
    Label.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamBold
    Label.Parent = Container

    local LabelCorner = Instance.new("UICorner")
    LabelCorner.CornerRadius = UDim.new(0, 6)
    LabelCorner.Parent = Label

    local Btn = Instance.new("TextButton")
    Btn.Name = name .. "Btn"
    Btn.Size = UDim2.new(0, 80, 1, 0)
    Btn.Position = UDim2.new(0, 160, 0, 0)
    Btn.BackgroundColor3 = Settings[settingKey] and Color3.fromRGB(30, 80, 30) or Color3.fromRGB(80, 30, 30)
    Btn.Text = Settings[settingKey] and "ON" or "OFF"
    Btn.TextColor3 = Settings[settingKey] and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    Btn.TextSize = 13
    Btn.Font = Enum.Font.GothamBold
    Btn.Parent = Container

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = Btn
    
    AddClickEffect(Btn)

    Btn.MouseButton1Click:Connect(function()
        Settings[settingKey] = not Settings[settingKey]
        
        if Settings[settingKey] then
            Btn.BackgroundColor3 = Color3.fromRGB(30, 80, 30)
            Btn.Text = "ON"
            Btn.TextColor3 = Color3.fromRGB(100, 255, 100)
            if settingKey == "TeamCheck" and Settings.LockedTarget and Settings.LockedTarget.Team == LocalPlayer.Team then
                Settings.LockedTarget = nil
            end
        else
            Btn.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
            Btn.Text = "OFF"
            Btn.TextColor3 = Color3.fromRGB(255, 100, 100)
            if settingKey == "StickyTarget" then
                Settings.LockedTarget = nil
            end
        end
    end)
    
    return Btn
end

local TargetPickCycleBtn = CreateCyclingButton("Target Pick", TargetPickMethods, "TargetPickMethod", UDim2.new(0, 0, 0, 0))
local TeamCheckToggle = CreateMiscToggle("Team Check", UDim2.new(0, 0, 0, 40), "TeamCheck")
local StickyTargetToggle = CreateMiscToggle("Sticky Target", UDim2.new(0, 0, 0, 80), "StickyTarget")
local OrbitSpeedButtons = CreateSpeedButtons(UDim2.new(0, 0, 0, 120))
local WatermarkToggle = CreateMiscToggle("Watermark", UDim2.new(0, 0, 0, 165), "Watermark")

local ComingSoonLabel = Instance.new("TextLabel")
ComingSoonLabel.Name = "ComingSoonLabel"
ComingSoonLabel.Size = UDim2.new(1, 0, 1, 0)
ComingSoonLabel.BackgroundTransparency = 1
ComingSoonLabel.Text = "Player List - Coming Soon"
ComingSoonLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
ComingSoonLabel.TextSize = 20
ComingSoonLabel.Font = Enum.Font.GothamBold
ComingSoonLabel.Parent = PlayerListPage

--// Visuals Page UI
local VisualsContent = Instance.new("Frame")
VisualsContent.Name = "VisualsContent"
VisualsContent.Size = UDim2.new(1, -20, 1, -10)
VisualsContent.Position = UDim2.new(0, 10, 0, 5)
VisualsContent.BackgroundTransparency = 1
VisualsContent.Parent = VisualsPage

local function CreateVisualsToggle(name, position, settingKey)
    local Container = Instance.new("Frame")
    Container.Name = name .. "Container"
    Container.Size = UDim2.new(0, 250, 0, 35)
    Container.Position = position
    Container.BackgroundTransparency = 1
    Container.Parent = VisualsContent

    local Label = Instance.new("TextLabel")
    Label.Name = name .. "Label"
    Label.Size = UDim2.new(0, 150, 1, 0)
    Label.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamBold
    Label.Parent = Container

    local LabelCorner = Instance.new("UICorner")
    LabelCorner.CornerRadius = UDim.new(0, 6)
    LabelCorner.Parent = Label

    local Btn = Instance.new("TextButton")
    Btn.Name = name .. "Btn"
    Btn.Size = UDim2.new(0, 80, 1, 0)
    Btn.Position = UDim2.new(0, 160, 0, 0)
    Btn.BackgroundColor3 = Settings[settingKey] and Color3.fromRGB(30, 80, 30) or Color3.fromRGB(80, 30, 30)
    Btn.Text = Settings[settingKey] and "ON" or "OFF"
    Btn.TextColor3 = Settings[settingKey] and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    Btn.TextSize = 13
    Btn.Font = Enum.Font.GothamBold
    Btn.Parent = Container

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = Btn
    
    AddClickEffect(Btn)

    Btn.MouseButton1Click:Connect(function()
        Settings[settingKey] = not Settings[settingKey]
        if Settings[settingKey] then
            Btn.BackgroundColor3 = Color3.fromRGB(30, 80, 30)
            Btn.Text = "ON"
            Btn.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            Btn.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
            Btn.Text = "OFF"
            Btn.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end)
    
    return Btn
end

local BoxESPToggle = CreateVisualsToggle("Box ESP", UDim2.new(0, 0, 0, 0), "BoxESP")
local TracerESPToggle = CreateVisualsToggle("Tracers", UDim2.new(0, 0, 0, 40), "TracerESP")

--// ESP Color Picker Row
local ESPColorRow = Instance.new("Frame")
ESPColorRow.Size = UDim2.new(0, 250, 0, 35)
ESPColorRow.Position = UDim2.new(0, 0, 0, 80)
ESPColorRow.BackgroundTransparency = 1
ESPColorRow.Parent = VisualsContent

local ESPColorLabel = Instance.new("TextLabel")
ESPColorLabel.Size = UDim2.new(0, 100, 1, 0)
ESPColorLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
ESPColorLabel.Text = "ESP Color"
ESPColorLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
ESPColorLabel.TextSize = 13
ESPColorLabel.Font = Enum.Font.GothamBold
ESPColorLabel.Parent = ESPColorRow
local ESPColorLabelCorner = Instance.new("UICorner")
ESPColorLabelCorner.CornerRadius = UDim.new(0, 6)
ESPColorLabelCorner.Parent = ESPColorLabel

local ESPColorPreview = Instance.new("Frame")
ESPColorPreview.Size = UDim2.new(0, 35, 1, 0)
ESPColorPreview.Position = UDim2.new(0, 110, 0, 0)
ESPColorPreview.BackgroundColor3 = Settings.ESPColor
ESPColorPreview.Parent = ESPColorRow
local ESPColorPreviewCorner = Instance.new("UICorner")
ESPColorPreviewCorner.CornerRadius = UDim.new(0, 6)
ESPColorPreviewCorner.Parent = ESPColorPreview

local ESPColorBtn = Instance.new("TextButton")
ESPColorBtn.Size = UDim2.new(0, 95, 1, 0)
ESPColorBtn.Position = UDim2.new(0, 150, 0, 0)
ESPColorBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
ESPColorBtn.Text = "Cycle"
ESPColorBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
ESPColorBtn.TextSize = 12
ESPColorBtn.Font = Enum.Font.GothamBold
ESPColorBtn.Parent = ESPColorRow
local ESPColorBtnCorner = Instance.new("UICorner")
ESPColorBtnCorner.CornerRadius = UDim.new(0, 6)
ESPColorBtnCorner.Parent = ESPColorBtn
AddClickEffect(ESPColorBtn)

local ESPColorIndex = 1
local ESPColors = {
    Color3.fromRGB(255, 50, 50),
    Color3.fromRGB(50, 255, 50),
    Color3.fromRGB(50, 150, 255),
    Color3.fromRGB(255, 255, 50),
    Color3.fromRGB(255, 50, 255),
    Color3.fromRGB(50, 255, 255),
    Color3.fromRGB(255, 255, 255),
}

ESPColorBtn.MouseButton1Click:Connect(function()
    ESPColorIndex = ESPColorIndex % #ESPColors + 1
    Settings.ESPColor = ESPColors[ESPColorIndex]
    ESPColorPreview.BackgroundColor3 = Settings.ESPColor
end)

local function SetupMethodHandler(button, methodLabel, toggleBtn, featureName)
    button.MouseButton1Click:Connect(function()
        Features[featureName].Method = Features[featureName].Method + 1
        if Features[featureName].Method > #Features[featureName].Methods then
            Features[featureName].Method = 1
        end
        
        local methodNum = Features[featureName].Method
        local methodName = Features[featureName].Methods[methodNum]
        
        button.Text = featureName .. "\n" .. methodName
        
        local maxMethods = #Features[featureName].Methods
        methodLabel.Text = methodNum .. "/" .. maxMethods
        
        TweenService:Create(button, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(70, 70, 80)
        }):Play()
        task.wait(0.1)
        
        local isEnabled = Features[featureName].Enabled
        button.BackgroundColor3 = isEnabled and Color3.fromRGB(45, 100, 55) or Color3.fromRGB(45, 45, 55)
    end)
end

SetupMethodHandler(VoidBtn, VoidMethod, VoidToggle, "VoidSpam")
SetupMethodHandler(TpBtn, TpMethod, TpToggle, "SpamTP")
SetupMethodHandler(OrbitBtn, OrbitMethod, OrbitToggle, "Orbit")

local function SetupToggleHandler(toggleBtn, mainBtn, featureName)
    toggleBtn.MouseButton1Click:Connect(function()
        Features[featureName].Enabled = not Features[featureName].Enabled
        local isEnabled = Features[featureName].Enabled
        
        if featureName == "VoidSpam" then
            if isEnabled then
                if HumanoidRootPart then
                    Settings.LastPosition = HumanoidRootPart.CFrame
                    Settings.IsVoidSpamming = true
                end
            else
                Settings.IsVoidSpamming = false
                if Settings.LastPosition and HumanoidRootPart then
                    task.spawn(function()
                        task.wait(0.1)
                        for i = 1, 10 do
                            if HumanoidRootPart and Settings.LastPosition then
                                HumanoidRootPart.CFrame = Settings.LastPosition
                                HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                            end
                            task.wait(0.05)
                        end
                    end)
                end
            end
        end
        
        if isEnabled then
            toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 80, 30)
            toggleBtn.Text = "ON"
            toggleBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
            mainBtn.BackgroundColor3 = Color3.fromRGB(45, 100, 55)
        else
            toggleBtn.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
            toggleBtn.Text = "OFF"
            toggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
            mainBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        end        
        local methodName = Features[featureName].Methods[Features[featureName].Method]
        mainBtn.Text = featureName .. "\n" .. methodName
    end)
end

SetupToggleHandler(VoidToggle, VoidBtn, "VoidSpam")
SetupToggleHandler(TpToggle, TpBtn, "SpamTP")
SetupToggleHandler(OrbitToggle, OrbitBtn, "Orbit")

--// Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -30, 0, 2)
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

AddClickEffect(CloseBtn)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

--// Minimize Button
local MinBtn = Instance.new("TextButton")
MinBtn.Name = "MinBtn"
MinBtn.Size = UDim2.new(0, 25, 0, 25)
MinBtn.Position = UDim2.new(1, -58, 0, 2)
MinBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 18
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Parent = TitleBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinBtn

AddClickEffect(MinBtn)

local minimized = false
local normalSize = UDim2.new(0, 360, 0, 330)
local minSize = UDim2.new(0, 360, 0, 32)

MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        for _, child in pairs(MainFrame:GetChildren()) do
            if child.Name ~= "TitleBar" and child.Name ~= "UICorner" and child.Name ~= "UIStroke" then
                child.Visible = false
            end
        end
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = minSize}):Play()
        MinBtn.Text = "+"
    else
        for _, child in pairs(MainFrame:GetChildren()) do
            if child.Name ~= "UICorner" and child.Name ~= "UIStroke" then
                child.Visible = true
            end
        end
        for name, page in pairs(Pages) do
            page.Visible = (name == "Main")
        end
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = normalSize}):Play()
        MinBtn.Text = "-"
    end
end)

--// WATERMARK
local WatermarkFrame = Instance.new("Frame")
WatermarkFrame.Name = "Watermark"
WatermarkFrame.Size = UDim2.new(0, 280, 0, 70)
WatermarkFrame.Position = UDim2.new(0, 10, 0, 10)
WatermarkFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
WatermarkFrame.BackgroundTransparency = 0
WatermarkFrame.BorderSizePixel = 0
WatermarkFrame.Visible = false
WatermarkFrame.Parent = ScreenGui

local WatermarkCorner = Instance.new("UICorner")
WatermarkCorner.CornerRadius = UDim.new(0, 8)
WatermarkCorner.Parent = WatermarkFrame

local WatermarkStroke = Instance.new("UIStroke")
WatermarkStroke.Color = Color3.fromRGB(80, 80, 90)
WatermarkStroke.Thickness = 1.5
WatermarkStroke.Parent = WatermarkFrame

local WatermarkText = Instance.new("TextLabel")
WatermarkText.Name = "WatermarkText"
WatermarkText.Size = UDim2.new(1, -10, 1, -10)
WatermarkText.Position = UDim2.new(0, 5, 0, 5)
WatermarkText.BackgroundTransparency = 1
WatermarkText.Text = "CabbitWare\nLoading..."
WatermarkText.TextColor3 = Color3.fromRGB(255, 255, 255)
WatermarkText.TextSize = 12
WatermarkText.Font = Enum.Font.Gotham
WatermarkText.TextWrapped = true
WatermarkText.TextXAlignment = Enum.TextXAlignment.Left
WatermarkText.Parent = WatermarkFrame

--// FOV Circle
local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "FOVCircle"
FOVCircle.Size = UDim2.new(0, 200, 0, 200)
FOVCircle.Position = UDim2.new(0.5, -100, 0.5, -100)
FOVCircle.BackgroundTransparency = 1
FOVCircle.BorderSizePixel = 0
FOVCircle.Visible = false
FOVCircle.ZIndex = 10
FOVCircle.Parent = ScreenGui

local FOVCircleCorner = Instance.new("UICorner")
FOVCircleCorner.CornerRadius = UDim.new(1, 0)
FOVCircleCorner.Parent = FOVCircle

local FOVCircleStroke = Instance.new("UIStroke")
FOVCircleStroke.Color = Color3.fromRGB(255, 255, 255)
FOVCircleStroke.Thickness = 1.5
FOVCircleStroke.Parent = FOVCircle

--// Feature Logic
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    Humanoid = char:WaitForChild("Humanoid")
    Settings.LockedTarget = nil
end)

--// BodyVelocity
local BodyVel = nil
local function GetBodyVel()
    if not HumanoidRootPart then return nil end
    if BodyVel and BodyVel.Parent then return BodyVel end
    
    BodyVel = Instance.new("BodyVelocity")
    BodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    BodyVel.Velocity = Vector3.zero
    BodyVel.Parent = HumanoidRootPart
    return BodyVel
end

--// Safe Teleport
local function SafeTeleport(cf)
    if not HumanoidRootPart then return end
    
    local bv = GetBodyVel()
    if bv then
        bv.Velocity = Vector3.zero
    end
    
    HumanoidRootPart.CFrame = cf
    
    if bv then
        bv.Velocity = Vector3.zero
    end
end

--// FPS Counter
local fps = 60
local lastTick = tick()
RunService.Heartbeat:Connect(function()
    local now = tick()
    fps = math.floor(1 / (now - lastTick))
    lastTick = now
end)

--// Live Info Update & Watermark
RunService.Heartbeat:Connect(function()
    if not HumanoidRootPart then return end
    
    local pos = HumanoidRootPart.Position
    PosDisplay.Text = string.format("Pos: X:%.0f Y:%.0f Z:%.0f", pos.X, pos.Y, pos.Z)
    
    local target, distance = GetTarget()
    local targetName = "None"
    local targetHealth = "?"
    local targetMaxHealth = "?"
    
    if target and target.Character then
        local tHumanoid = target.Character:FindFirstChildOfClass("Humanoid")
        targetName = target.Name
        targetHealth = tHumanoid and math.floor(tHumanoid.Health) or "?"
        targetMaxHealth = tHumanoid and math.floor(tHumanoid.MaxHealth) or "?"
        local lockedText = (Settings.StickyTarget and Settings.LockedTarget == target) and " [LOCKED]" or ""
        TargetDisplay.Text = string.format("Target: %s%s | %.0f studs | HP: %s/%s", targetName, lockedText, distance, targetHealth, targetMaxHealth)
        TargetDisplay.TextColor3 = Color3.fromRGB(255, 150, 100)
    else
        TargetDisplay.Text = "Target: None"
        TargetDisplay.TextColor3 = Color3.fromRGB(150, 150, 150)
    end
    
    if Settings.Watermark then
        if WatermarkFrame then
            WatermarkFrame.Visible = true
            WatermarkText.Text = string.format(
                "CabbitWare | FPS: %d\nPos: %.0f, %.0f, %.0f\nTarget: %s | %.0f studs | HP: %s/%s",
                fps, pos.X, pos.Y, pos.Z, targetName, distance or 0, targetHealth, targetMaxHealth
            )
        end
    else
        if WatermarkFrame then
            WatermarkFrame.Visible = false
        end
    end
end)

--// MASTER CONTROLLER
local voidTick = 0
local orbitAngle = 0
local yoyoState = "void"
local yoyoNextSwitch = 0

RunService.Heartbeat:Connect(function(dt)
    if not HumanoidRootPart then return end
    
    local currentOrbitSpeed = Settings.OrbitSpeed
    orbitAngle = orbitAngle + (dt * currentOrbitSpeed)
    voidTick = voidTick + dt
    
    local basePosition = nil
    local baseCFrame = nil
    local voidOffset = Vector3.zero
    local target = nil
    local tHRP = nil
    local tHead = nil
    
    if Features.SpamTP.Enabled or Features.Orbit.Enabled then
        target = GetTarget()
        if target and target.Character then
            tHRP = target.Character:FindFirstChild("HumanoidRootPart")
            tHead = target.Character:FindFirstChild("Head")
        end
    end
    
    if Features.SpamTP.Enabled and tHRP then
        local tpAngle = tick() * 20
        local method = Features.SpamTP.Method
        local tPos = tHRP.Position
        local tCF = tHRP.CFrame
        local headPos = tHead and tHead.Position or tPos + Vector3.new(0, 2, 0)
        
        if method == 1 then
            local radius = 8
            basePosition = tPos + Vector3.new(math.cos(tpAngle) * radius, 0, math.sin(tpAngle) * radius)
        elseif method == 2 then
            baseCFrame = tCF * CFrame.new(0, 0, 5)
        elseif method == 3 then
            basePosition = Vector3.new(tPos.X, tPos.Y + 10, tPos.Z)
        elseif method == 4 then
            basePosition = Vector3.new(tPos.X, tPos.Y - 5, tPos.Z)
        elseif method == 5 then
            basePosition = tPos + Vector3.new(math.random(-3, 3), math.random(-3, 3), math.random(-3, 3))
        elseif method == 6 then
            local radius = 6
            basePosition = Vector3.new(tPos.X + math.cos(tpAngle * 1.6) * radius, tPos.Y + 3, tPos.Z + math.sin(tpAngle * 1.6) * radius)
        elseif method == 7 then
            basePosition = tPos + Vector3.new(math.random(-10, 10), math.random(0, 10), math.random(-10, 10))
            SafeTeleport(CFrame.new(basePosition))
            task.wait(0.02)
            basePosition = tPos + Vector3.new(math.random(-5, 5), 5, math.random(-5, 5))
        elseif method == 8 then
            baseCFrame = tCF * CFrame.new(0, 0, -4)
        elseif method == 9 then
            basePosition = headPos + Vector3.new(0, 3, 0)
        elseif method == 10 then
            basePosition = headPos + (tCF.LookVector * -3)
        elseif method == 11 then
            local angle = math.random() * math.pi * 2
            local radius = math.random(4, 12)
            basePosition = tPos + Vector3.new(math.cos(angle) * radius, math.random(-3, 5), math.sin(angle) * radius)
        elseif method == 12 then
            basePosition = tPos
        end
        
    elseif Features.Orbit.Enabled and tHRP then
        local method = Features.Orbit.Method
        local tPos = tHRP.Position
        local fastAngle = orbitAngle * 1.5
        
        if method == 1 then
            local radius = 8
            basePosition = Vector3.new(tPos.X + math.cos(fastAngle) * radius, tPos.Y + 3, tPos.Z + math.sin(fastAngle) * radius)
        elseif method == 2 then
            local radius = 8
            basePosition = Vector3.new(tPos.X + math.sin(fastAngle) * radius, tPos.Y + 3, tPos.Z + math.sin(fastAngle * 2) * radius * 0.5)
        elseif method == 3 then
            local radius = 5 + math.sin(fastAngle * 0.5) * 5
            local y = math.sin(fastAngle) * 5
            basePosition = Vector3.new(tPos.X + math.cos(fastAngle) * radius, tPos.Y + y + 3, tPos.Z + math.sin(fastAngle) * radius)
        elseif method == 4 then
            local radius = 8
            basePosition = Vector3.new(tPos.X, tPos.Y + math.cos(fastAngle) * radius + 5, tPos.Z + math.sin(fastAngle) * radius)
        elseif method == 5 then
            local radius = 8
            basePosition = Vector3.new(tPos.X + math.cos(fastAngle) * radius, tPos.Y + 3, tPos.Z + math.sin(fastAngle) * radius)
        elseif method == 6 then
            basePosition = tPos + Vector3.new(math.sin(fastAngle * 1.3) * 10, math.cos(fastAngle * 0.7) * 5 + 3, math.sin(fastAngle * 1.7) * 10)
        elseif method == 7 then
            local radius = 3
            basePosition = Vector3.new(tPos.X + math.cos(fastAngle * 2) * radius, tPos.Y + math.sin(fastAngle * 3) * 2 + 2, tPos.Z + math.sin(fastAngle * 2) * radius)
        elseif method == 8 then
            baseCFrame = CFrame.new(tPos.X, tPos.Y + 5, tPos.Z) * CFrame.Angles(0, fastAngle * 2, 0)
        end
    end
    
    if Features.VoidSpam.Enabled then
        local method = Features.VoidSpam.Method
        local isSolo = not Features.SpamTP.Enabled and not Features.Orbit.Enabled
        
        if method == 9 then
            if tick() >= yoyoNextSwitch then
                yoyoState = (yoyoState == "void") and "target" or "void"
                yoyoNextSwitch = tick() + math.random(1, 3)
            end
            
            if yoyoState == "void" then
                voidOffset = Vector3.new(math.random(-999999, 999999), -500, math.random(-999999, 999999))
            else
                if basePosition then
                    voidOffset = Vector3.zero
                elseif baseCFrame then
                    voidOffset = Vector3.zero
                elseif tHRP then
                    basePosition = tHRP.Position
                    voidOffset = Vector3.zero
                else
                    voidOffset = Vector3.new(0, -500, 0)
                end
            end
        else
            local shouldTeleport = isSolo
            if not isSolo then
                local interval = 0.05
                if method == 1 then interval = 0.05
                elseif method == 2 then interval = 0.03
                elseif method == 3 then interval = 0.02
                elseif method == 4 then interval = 0.04
                elseif method == 5 then interval = 0.03
                elseif method == 6 then interval = 0.02
                elseif method == 7 then interval = 0.03
                elseif method == 8 then interval = 0.01
                end
                shouldTeleport = voidTick >= interval
            end
            
            if shouldTeleport then
                if not isSolo then voidTick = 0 end
                local voidAngle = tick() * 10
                
                if method == 1 then
                    voidOffset = Vector3.new(math.random(-999999, 999999), -500, math.random(-999999, 999999))
                elseif method == 2 then
                    voidOffset = Vector3.new(math.random(-9999999, 9999999), -500, math.random(-9999999, 9999999))
                elseif method == 3 then
                    local radius = 500000 + voidAngle * 1000
                    voidOffset = Vector3.new(math.cos(voidAngle) * radius, -500, math.sin(voidAngle) * radius)
                elseif method == 4 then
                    local radius = 1000000
                    voidOffset = Vector3.new(math.cos(voidAngle) * radius, -500, math.sin(voidAngle) * radius)
                elseif method == 5 then
                    voidOffset = Vector3.new(math.random(-500000, 500000), -500, math.random(-500000, 500000))
                elseif method == 6 then
                    for i = 1, 3 do
                        SafeTeleport(CFrame.new(math.random(-999999, 999999), -500, math.random(-999999, 999999)))
                    end
                    return
                elseif method == 7 then
                    local radius = 2000000
                    voidOffset = Vector3.new(math.cos(voidAngle) * radius, -500, math.sin(voidAngle) * radius)
                elseif method == 8 then
                    voidOffset = Vector3.new(math.random(-99999999, 99999999), -500, math.random(-99999999, 99999999))
                end
            end
        end
    end
    
    if baseCFrame then
        if Features.VoidSpam.Enabled and voidOffset.Magnitude > 0 then
            SafeTeleport(CFrame.new(baseCFrame.Position + voidOffset))
        else
            SafeTeleport(baseCFrame)
        end
    elseif basePosition then
        if Features.VoidSpam.Enabled and voidOffset.Magnitude > 0 then
            SafeTeleport(CFrame.new(basePosition + voidOffset))
        else
            SafeTeleport(CFrame.new(basePosition))
        end
    elseif Features.VoidSpam.Enabled and voidOffset.Magnitude > 0 then
        SafeTeleport(CFrame.new(voidOffset))
    end
end)

--// Aim Logic
local function GetAimTarget()
    local camera = workspace.CurrentCamera
    if not camera then return nil, math.huge, nil, nil end
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local bestTarget = nil
    local bestDist = math.huge
    local bestPos = nil
    local bestVel = nil

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if not (Settings.TeamCheck and player.Team == LocalPlayer.Team) then
                local head = player.Character:FindFirstChild("Head")
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if head and humanoid and humanoid.Health > 0 and hrp then
                    local pos, onScreen = camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local screenPos = Vector2.new(pos.X, pos.Y)
                        local dist = (screenPos - center).Magnitude
                        if dist < bestDist then
                            bestDist = dist
                            bestTarget = head
                            bestPos = head.Position
                            bestVel = hrp.AssemblyLinearVelocity
                        end
                    end
                end
            end
        end
    end
    return bestTarget, bestDist, bestPos, bestVel
end

local aimKeyPressed = false
if IsPC then
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if Settings.AimKeybindKey and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Settings.AimKeybindKey then
            aimKeyPressed = true
        end
        if Settings.AimKeybindMouse and input.UserInputType == Settings.AimKeybindMouse then
            aimKeyPressed = true
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if Settings.AimKeybindKey and input.KeyCode == Settings.AimKeybindKey then
            aimKeyPressed = false
        end
        if Settings.AimKeybindMouse and input.UserInputType == Settings.AimKeybindMouse then
            aimKeyPressed = false
        end
    end)
end

--// Silent Aim: snap camera for 1 frame on fire
if IsPC then
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if not Features.Aim.Enabled then return end
        if Features.Aim.Method ~= 2 then return end -- Only Silent Aim
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        
        local camera = workspace.CurrentCamera
        if not camera then return end
        
        local target, _, targetPos, targetVel = GetAimTarget()
        if target and targetPos then
            if targetVel and Settings.AimPrediction > 0 then
                targetPos = targetPos + (targetVel * Settings.AimPrediction)
            end
            local oldCF = camera.CFrame
            camera.CFrame = CFrame.new(camera.CFrame.Position, targetPos)
            task.spawn(function()
                RunService.RenderStepped:Wait()
                local cam = workspace.CurrentCamera
                if cam then
                    cam.CFrame = oldCF
                end
            end)
        end
    end)
end

RunService.RenderStepped:Connect(function()
    local camera = workspace.CurrentCamera
    if not camera then return end
    
    local shouldAim = Features.Aim.Enabled
    if IsPC and Settings.AimHoldMode and (Settings.AimKeybindKey or Settings.AimKeybindMouse) then
        shouldAim = shouldAim and aimKeyPressed
    end
    
    if shouldAim then
        local target, dist, targetPos, targetVel = GetAimTarget()
        if target and targetPos then
            if targetVel and Settings.AimPrediction > 0 then
                targetPos = targetPos + (targetVel * Settings.AimPrediction)
            end
            
            local method = Features.Aim.Method
            
            if method == 1 then -- Aimbot
                camera.CFrame = CFrame.new(camera.CFrame.Position, targetPos)
            elseif method == 3 then -- Smooth Aim
                local targetCF = CFrame.new(camera.CFrame.Position, targetPos)
                camera.CFrame = camera.CFrame:Lerp(targetCF, 0.12)
            elseif method == 4 then -- FOV Aim
                if dist <= 100 then
                    camera.CFrame = CFrame.new(camera.CFrame.Position, targetPos)
                end
            end
            -- method == 2 (Silent Aim) is handled in the InputBegan hook above
        end
    end
end)

--// ESP System
local ESPScreenGui = Instance.new("ScreenGui")
ESPScreenGui.Name = "CabbitWare_ESP"
ESPScreenGui.ResetOnSpawn = false
ESPScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ESPScreenGui.DisplayOrder = 10
ESPScreenGui.IgnoreGuiInset = true
ESPScreenGui.Parent = PlayerGui

local ESPObjects = {}

local function GetESP(player)
    if ESPObjects[player] then return ESPObjects[player] end
    
    local box = Instance.new("Frame")
    box.Name = player.Name .. "_Box"
    box.BackgroundTransparency = 0.92
    box.BackgroundColor3 = Settings.ESPColor
    box.BorderSizePixel = 0
    box.Visible = false
    box.ZIndex = 5
    box.Parent = ESPScreenGui
    
    local boxStroke = Instance.new("UIStroke")
    boxStroke.Color = Settings.ESPColor
    boxStroke.Thickness = 1.5
    boxStroke.Parent = box
    
    local tracer = Instance.new("Frame")
    tracer.Name = player.Name .. "_Tracer"
    tracer.BackgroundColor3 = Settings.ESPColor
    tracer.BorderSizePixel = 0
    tracer.Visible = false
    tracer.ZIndex = 4
    tracer.Parent = ESPScreenGui
    
    local obj = {Box = box, BoxStroke = boxStroke, Tracer = tracer, Player = player}
    ESPObjects[player] = obj
    return obj
end

local function RemoveESP(player)
    if ESPObjects[player] then
        if ESPObjects[player].Box then ESPObjects[player].Box:Destroy() end
        if ESPObjects[player].Tracer then ESPObjects[player].Tracer:Destroy() end
        ESPObjects[player] = nil
    end
end

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

RunService.RenderStepped:Connect(function()
    local camera = workspace.CurrentCamera
    if not camera then return end
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local esp = GetESP(player)
            local head = player.Character:FindFirstChild("Head")
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            
            if head and hrp and humanoid and humanoid.Health > 0 then
                if not (Settings.TeamCheck and player.Team == LocalPlayer.Team) then
                    local headPos = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                    local footPos = camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                    
                    if headPos.Z > 0 then
                        local boxHeight = math.abs(headPos.Y - footPos.Y) * 1.2
                        local boxWidth = boxHeight * 0.55
                        local boxX = (headPos.X + footPos.X) / 2 - boxWidth / 2
                        local boxY = headPos.Y - boxHeight * 0.15
                        
                        if Settings.BoxESP then
                            esp.Box.Visible = true
                            esp.Box.Size = UDim2.new(0, boxWidth, 0, boxHeight)
                            esp.Box.Position = UDim2.new(0, boxX, 0, boxY)
                            esp.Box.BackgroundColor3 = Settings.ESPColor
                            esp.BoxStroke.Color = Settings.ESPColor
                        else
                            esp.Box.Visible = false
                        end
                        
                        if Settings.TracerESP then
                            local midX = (headPos.X + footPos.X) / 2
                            local midY = (headPos.Y + footPos.Y) / 2
                            local dx = midX - center.X
                            local dy = midY - center.Y
                            local dist = math.sqrt(dx * dx + dy * dy)
                            local angle = math.deg(math.atan2(dy, dx))
                            
                            esp.Tracer.Visible = true
                            esp.Tracer.Size = UDim2.new(0, dist, 0, 1)
                            esp.Tracer.Position = UDim2.new(0, center.X, 0, center.Y)
                            esp.Tracer.Rotation = angle
                            esp.Tracer.BackgroundColor3 = Settings.ESPColor
                        else
                            esp.Tracer.Visible = false
                        end
                    else
                        esp.Box.Visible = false
                        esp.Tracer.Visible = false
                    end
                else
                    esp.Box.Visible = false
                    esp.Tracer.Visible = false
                end
            else
                esp.Box.Visible = false
                esp.Tracer.Visible = false
            end
        end
    end
end)

print("CabbitWare Loaded | Mobile/PC | Aim+Visuals | 12 SpamTP | Works on any executor")

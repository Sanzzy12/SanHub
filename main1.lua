-- ============================================================
--  SAN HUB — main.lua
--  Layout: Wrapper besar (draggable) = sidebar kiri + content kanan
--  Ukuran sama kayak script asli: 0.5w x 0.62h
-- ============================================================

pcall(function()

-- ============================================================
-- FEATURE URLs
-- ============================================================
local FeatureURLs = {
    Animation  = "https://raw.githubusercontent.com/Sanzzy12/SanHub/main/features/animation.lua",
    InfoServer = "https://raw.githubusercontent.com/Sanzzy12/SanHub/main/features/infoserver.lua",
    -- Walkspeed = "https://raw.githubusercontent.com/Sanzzy12/SanHub/main/features/walkspeed.lua",
}

-- ============================================================
-- SERVICES
-- ============================================================
local TweenService     = game:GetService("TweenService")
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")

cloneref = cloneref or function(o) return o end
local CoreGui = cloneref(game:GetService("CoreGui"))

-- ============================================================
-- DOUBLE EXECUTION GUARD
-- ============================================================
local GUI_NAME = "SanHubMain"
if CoreGui:FindFirstChild(GUI_NAME) then
    CoreGui:FindFirstChild(GUI_NAME):Destroy()
    task.wait(0.1)
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = GUI_NAME
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

-- ============================================================
-- SHARED TABLE
-- ============================================================
_G.SanHub = {}
_G.SanHub.Notify = nil
_G.SanHub.Theme  = nil
_G.SanHub.CurrentFrame = nil

-- ============================================================
-- THEME
-- ============================================================
local T = {
    Primary      = Color3.fromRGB(130, 90, 200),
    PrimaryLight = Color3.fromRGB(160, 120, 230),
    PrimaryDark  = Color3.fromRGB(90, 55, 150),
    Accent       = Color3.fromRGB(200, 160, 255),
    BgDark       = Color3.fromRGB(22, 18, 35),
    BgMid        = Color3.fromRGB(32, 26, 50),
    BgLight      = Color3.fromRGB(45, 36, 68),
    BgCard       = Color3.fromRGB(52, 42, 78),
    Text         = Color3.fromRGB(240, 235, 255),
    TextMuted    = Color3.fromRGB(170, 155, 200),
    Success      = Color3.fromRGB(100, 220, 160),
    Warning      = Color3.fromRGB(255, 200, 80),
    Error        = Color3.fromRGB(255, 100, 120),
    Info         = Color3.fromRGB(130, 190, 255),
}
_G.SanHub.Theme = T

-- ============================================================
-- NOTIFICATION SYSTEM
-- ============================================================
local Notifbro = {}
local NotifColors = {
    Default            = T.Primary,
    Loaded             = T.Success,
    Error              = T.Error,
    Warning            = T.Warning,
    Set                = T.PrimaryLight,
    Created            = T.Success,
    Copied             = T.Info,
    Database           = T.Info,
    Welcome            = T.Accent,
    Info               = T.Info,
    ["First Time"]     = T.Warning,
    ["Database Update"]= T.Success,
}
local NotifIcons = {
    Default            = "rbxassetid://134341920489415",
    Loaded             = "rbxassetid://134341920489415",
    Error              = "rbxassetid://16913919379",
    Warning            = "rbxassetid://16913919379",
    Set                = "rbxassetid://5578470911",
    Created            = "rbxassetid://5578470911",
    Copied             = "rbxassetid://5578470911",
    Database           = "rbxassetid://5578470911",
    Welcome            = "rbxassetid://134341920489415",
    Info               = "rbxassetid://134341920489415",
    ["First Time"]     = "rbxassetid://134341920489415",
    ["Database Update"]= "rbxassetid://134341920489415",
}

local function Notify(title, text, duration)
    coroutine.wrap(function()
        local cam = workspace.CurrentCamera
        local nw  = math.max(260, cam.ViewportSize.X / 5.5)
        local nh  = 70
        local ac  = NotifColors[title] or T.Primary
        local ico = NotifIcons[title]  or NotifIcons.Default

        local G = Instance.new("ScreenGui")
        G.Name = "SanNotif"; G.Parent = CoreGui

        local shadow = Instance.new("Frame", G)
        shadow.Size = UDim2.new(0, nw+8, 0, nh+8)
        shadow.BackgroundColor3 = Color3.new(0,0,0)
        shadow.BackgroundTransparency = 0.6
        shadow.BorderSizePixel = 0
        Instance.new("UICorner", shadow).CornerRadius = UDim.new(0,16)

        local card = Instance.new("Frame", G)
        card.Size = UDim2.new(0, nw, 0, nh)
        card.BackgroundColor3 = T.BgMid
        card.BackgroundTransparency = 0.05
        card.BorderSizePixel = 0
        Instance.new("UICorner", card).CornerRadius = UDim.new(0,14)

        local bar = Instance.new("Frame", card)
        bar.Size = UDim2.new(0,4,1,0); bar.BackgroundColor3 = ac; bar.BorderSizePixel = 0
        Instance.new("UICorner", bar).CornerRadius = UDim.new(0,4)

        local iF = Instance.new("Frame", card)
        iF.Size = UDim2.new(0,38,0,38); iF.Position = UDim2.new(0,16,0.5,-19)
        iF.BackgroundColor3 = ac; iF.BackgroundTransparency = 0.75; iF.BorderSizePixel = 0
        Instance.new("UICorner", iF).CornerRadius = UDim.new(0,10)
        local iI = Instance.new("ImageLabel", iF)
        iI.Size = UDim2.new(0,22,0,22); iI.Position = UDim2.new(0.5,-11,0.5,-11)
        iI.BackgroundTransparency = 1; iI.Image = ico; iI.ImageColor3 = ac

        local tl = Instance.new("TextLabel", card)
        tl.BackgroundTransparency = 1; tl.Size = UDim2.new(1,-80,0,22)
        tl.Position = UDim2.new(0,66,0,10); tl.Font = Enum.Font.GothamBold
        tl.TextSize = 13; tl.Text = title; tl.TextColor3 = ac
        tl.TextXAlignment = Enum.TextXAlignment.Left

        local ml = Instance.new("TextLabel", card)
        ml.BackgroundTransparency = 1; ml.Size = UDim2.new(1,-80,0,24)
        ml.Position = UDim2.new(0,66,0,33); ml.Font = Enum.Font.Gotham
        ml.TextSize = 11; ml.Text = text; ml.TextColor3 = T.TextMuted
        ml.TextXAlignment = Enum.TextXAlignment.Left; ml.TextWrapped = true

        local pbg = Instance.new("Frame", card)
        pbg.Size = UDim2.new(1,-8,0,3); pbg.Position = UDim2.new(0,4,1,-5)
        pbg.BackgroundColor3 = T.BgLight; pbg.BorderSizePixel = 0
        Instance.new("UICorner", pbg).CornerRadius = UDim.new(1,0)
        local pb = Instance.new("Frame", pbg)
        pb.Size = UDim2.new(1,0,1,0); pb.BackgroundColor3 = ac; pb.BorderSizePixel = 0
        Instance.new("UICorner", pb).CornerRadius = UDim.new(1,0)

        local offset = 20
        for _, n in ipairs(Notifbro) do offset = offset + n.Size.Y.Offset + 12 end
        local sX = UDim2.new(1, nw+10, 0, offset)
        local eX = UDim2.new(1,-nw-16, 0, offset)
        card.Position = sX
        shadow.Position = UDim2.new(sX.X.Scale, sX.X.Offset-4, sX.Y.Scale, sX.Y.Offset-4)
        table.insert(Notifbro, card)

        task.wait(0.05)
        TweenService:Create(card,   TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position=eX}):Play()
        TweenService:Create(shadow, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position=UDim2.new(eX.X.Scale,eX.X.Offset-4,eX.Y.Scale,eX.Y.Offset-4)}):Play()
        TweenService:Create(pb,     TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size=UDim2.new(0,0,1,0)}):Play()
        task.wait(duration)
        TweenService:Create(card,   TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position=sX, BackgroundTransparency=0.7}):Play()
        TweenService:Create(shadow, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position=UDim2.new(sX.X.Scale,sX.X.Offset-4,sX.Y.Scale,sX.Y.Offset-4), BackgroundTransparency=1}):Play()
        task.wait(0.38)
        G:Destroy()
        for i, n in ipairs(Notifbro) do
            if n == card then table.remove(Notifbro, i) break end
        end
        for i, n in ipairs(Notifbro) do
            TweenService:Create(n, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Position = UDim2.new(1,-nw-16, 0, 20+(nh+12)*(i-1))
            }):Play()
        end
    end)()
end

_G.SanHub.Notify = Notify

-- ============================================================
-- HELPER
-- ============================================================
local function mkCorner(p, r)
    Instance.new("UICorner", p).CornerRadius = UDim.new(0, r or 12)
end
local function mkStroke(p, col, thick, trans)
    local s = Instance.new("UIStroke", p)
    s.Color = col or T.Primary; s.Thickness = thick or 1.5
    s.Transparency = trans or 0.4
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

-- ============================================================
-- DETECT INPUT
-- ============================================================
local isTouchDevice = UserInputService.TouchEnabled
    and not UserInputService.KeyboardEnabled
    and not UserInputService.MouseEnabled

-- ============================================================
-- SIDEBAR WIDTH
-- ============================================================
local SIDEBAR_W = 160  -- lebar sidebar kiri

-- ============================================================
-- TOGGLE ICON BUTTON (draggable, selalu visible)
-- ============================================================
local toggleBtn = Instance.new("ImageButton")
toggleBtn.Name   = "ToggleButton"
toggleBtn.Image  = "rbxassetid://8215093320"
toggleBtn.ImageColor3 = T.Accent
toggleBtn.Size   = UDim2.new(0, 52, 0, 52)
toggleBtn.Position = UDim2.new(0, 10, 0.5, -26)
toggleBtn.BackgroundColor3 = T.BgMid
toggleBtn.BackgroundTransparency = 0.1
toggleBtn.BorderSizePixel = 0
toggleBtn.Active = true
toggleBtn.Draggable = true
toggleBtn.ZIndex = 10
toggleBtn.Parent = screenGui
mkCorner(toggleBtn, 26)
mkStroke(toggleBtn, T.Primary, 1.5, 0.3)

TweenService:Create(toggleBtn,
    TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
    {ImageColor3 = T.Primary}
):Play()

-- ============================================================
-- MAIN WRAPPER (draggable, ukuran sama kayak script asli)
-- Isi: sidebar kiri + content kanan
-- ============================================================
local mainFrame = Instance.new("Frame")
mainFrame.Name  = "MainFrame"
mainFrame.Size  = UDim2.new(0.68, 0, 0.75, 0)
mainFrame.Position = UDim2.new(0.16, 0, 0.12, 0)
mainFrame.BackgroundColor3 = T.BgDark
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.ClipsDescendants = true
mainFrame.ZIndex = 5
mainFrame.Parent = screenGui
mkCorner(mainFrame, 18)

local mainGrad = Instance.new("UIGradient", mainFrame)
mainGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, T.BgMid),
    ColorSequenceKeypoint.new(1, T.BgDark),
})
mainGrad.Rotation = 135

-- ============================================================
-- DRAG LOGIC (drag dari header)
-- ============================================================
local dragging, dragStart, startPos = false, nil, nil

local function onDragStart(input)
    dragging  = true
    dragStart = input.Position
    startPos  = mainFrame.Position
end

local function onDragMove(input)
    if not dragging then return end
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y
    )
end

local function onDragEnd()
    dragging = false
end

-- ============================================================
-- SIDEBAR FRAME (kiri, di dalam mainFrame)
-- ============================================================
local sidebar = Instance.new("Frame", mainFrame)
sidebar.Name  = "Sidebar"
sidebar.Size  = UDim2.new(0, SIDEBAR_W, 1, 0)
sidebar.Position = UDim2.new(0, 0, 0, 0)
sidebar.BackgroundColor3 = T.BgDark
sidebar.BorderSizePixel  = 0
sidebar.ZIndex = 6
sidebar.ClipsDescendants = false
-- Tidak pakai mkCorner di sidebar supaya rounded corner mainFrame tidak kepotong

-- Gradient sidebar
local sideGrad = Instance.new("UIGradient", sidebar)
sideGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, T.PrimaryDark),
    ColorSequenceKeypoint.new(1, T.BgDark),
})
sideGrad.Rotation = 135

-- Garis separator kanan sidebar
local sideDiv = Instance.new("Frame", sidebar)
sideDiv.Size  = UDim2.new(0, 1, 1, 0)
sideDiv.Position = UDim2.new(1, -1, 0, 0)
sideDiv.BackgroundColor3 = T.PrimaryDark
sideDiv.BackgroundTransparency = 0.3
sideDiv.BorderSizePixel = 0
sideDiv.ZIndex = 7

-- ============================================================
-- SIDEBAR HEADER (logo + title, juga area drag)
-- ============================================================
local sideHeader = Instance.new("Frame", sidebar)
sideHeader.Name  = "SideHeader"
sideHeader.Size  = UDim2.new(1, 0, 0, 56)
sideHeader.BackgroundColor3 = T.BgDark
sideHeader.BorderSizePixel  = 0
sideHeader.ZIndex = 7

local shGrad = Instance.new("UIGradient", sideHeader)
shGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, T.PrimaryDark),
    ColorSequenceKeypoint.new(1, T.BgDark),
})
shGrad.Rotation = 90

local shIcon = Instance.new("ImageLabel", sideHeader)
shIcon.Image  = "rbxassetid://12557404943"
shIcon.ImageColor3 = T.Accent
shIcon.Size   = UDim2.new(0, 24, 0, 24)
shIcon.Position = UDim2.new(0, 10, 0.5, -12)
shIcon.BackgroundTransparency = 1
shIcon.ZIndex = 8

local shTitle = Instance.new("TextLabel", sideHeader)
shTitle.Text  = "SAN HUB"
shTitle.Font  = Enum.Font.GothamBold
shTitle.TextSize = 13
shTitle.TextColor3 = T.Text
shTitle.BackgroundTransparency = 1
shTitle.Size  = UDim2.new(1, -42, 0, 18)
shTitle.Position = UDim2.new(0, 40, 0.5, -16)
shTitle.TextXAlignment = Enum.TextXAlignment.Left
shTitle.ZIndex = 8

local shSub = Instance.new("TextLabel", sideHeader)
shSub.Text   = "Script Hub"
shSub.Font   = Enum.Font.Gotham
shSub.TextSize = 9
shSub.TextColor3 = T.TextMuted
shSub.BackgroundTransparency = 1
shSub.Size   = UDim2.new(1, -42, 0, 12)
shSub.Position = UDim2.new(0, 40, 0.5, 4)
shSub.TextXAlignment = Enum.TextXAlignment.Left
shSub.ZIndex = 8

-- Header separator
local shLine = Instance.new("Frame", sideHeader)
shLine.Size  = UDim2.new(0.85, 0, 0, 1)
shLine.Position = UDim2.new(0.075, 0, 1, -1)
shLine.BackgroundColor3 = T.PrimaryDark
shLine.BackgroundTransparency = 0.4
shLine.BorderSizePixel = 0
shLine.ZIndex = 8

-- Drag dari header sidebar
sideHeader.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        onDragStart(input)
    end
end)
sideHeader.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        onDragEnd()
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        onDragMove(input)
    end
end)

-- ============================================================
-- INFO BAR di sidebar (Clock | FPS)
-- ============================================================
local infoBar = Instance.new("Frame", sidebar)
infoBar.Size  = UDim2.new(1, -12, 0, 26)
infoBar.Position = UDim2.new(0, 6, 0, 60)
infoBar.BackgroundColor3 = T.BgCard
infoBar.BackgroundTransparency = 0.2
infoBar.BorderSizePixel = 0
infoBar.ClipsDescendants = true
infoBar.ZIndex = 7
mkCorner(infoBar, 8)

local clockLbl = Instance.new("TextLabel", infoBar)
clockLbl.Text  = "00:00:00"
clockLbl.Font  = Enum.Font.GothamBold
clockLbl.TextSize = 10
clockLbl.TextColor3 = T.Accent
clockLbl.BackgroundTransparency = 1
clockLbl.Size  = UDim2.new(0.5, 0, 1, 0)
clockLbl.TextXAlignment = Enum.TextXAlignment.Center
clockLbl.TextYAlignment = Enum.TextYAlignment.Center
clockLbl.ZIndex = 8

local ibSep = Instance.new("Frame", infoBar)
ibSep.Size  = UDim2.new(0, 1, 0.5, 0)
ibSep.Position = UDim2.new(0.5, 0, 0.25, 0)
ibSep.BackgroundColor3 = T.PrimaryDark
ibSep.BackgroundTransparency = 0.3
ibSep.BorderSizePixel = 0
ibSep.ZIndex = 8

local fpsLbl = Instance.new("TextLabel", infoBar)
fpsLbl.Text  = "-- FPS"
fpsLbl.Font  = Enum.Font.GothamBold
fpsLbl.TextSize = 10
fpsLbl.TextColor3 = T.Success
fpsLbl.BackgroundTransparency = 1
fpsLbl.Size  = UDim2.new(0.5, 0, 1, 0)
fpsLbl.Position = UDim2.new(0.5, 0, 0, 0)
fpsLbl.TextXAlignment = Enum.TextXAlignment.Center
fpsLbl.TextYAlignment = Enum.TextYAlignment.Center
fpsLbl.ZIndex = 8

-- FPS + Clock updater
local fpsBuffer, lastFpsT, lastClkT = {}, 0, 0
RunService.RenderStepped:Connect(function(dt)
    local now = os.clock()
    table.insert(fpsBuffer, 1/dt)
    if #fpsBuffer > 20 then table.remove(fpsBuffer, 1) end
    if now - lastFpsT >= 0.3 then
        lastFpsT = now
        local s = 0
        for _, v in ipairs(fpsBuffer) do s = s + v end
        local avg = math.floor(s / #fpsBuffer)
        fpsLbl.Text = avg .. " FPS"
        fpsLbl.TextColor3 = avg >= 55 and T.Success or avg >= 30 and T.Warning or T.Error
    end
    if now - lastClkT >= 1 then
        lastClkT = now
        local t = math.floor(tick())
        clockLbl.Text = string.format("%02d:%02d:%02d",
            math.floor(t/3600)%24, math.floor(t/60)%60, t%60)
    end
end)

-- URL label bawah sidebar
local urlLbl = Instance.new("TextLabel", sidebar)
urlLbl.Text  = "sanzzy.xyz"
urlLbl.Font  = Enum.Font.GothamBold
urlLbl.TextSize = 9
urlLbl.TextColor3 = T.PrimaryLight
urlLbl.BackgroundTransparency = 1
urlLbl.Size  = UDim2.new(1, 0, 0, 16)
urlLbl.Position = UDim2.new(0, 0, 1, -20)
urlLbl.TextXAlignment = Enum.TextXAlignment.Center
urlLbl.ZIndex = 7

-- ============================================================
-- MENU LIST (di sidebar, di bawah info bar)
-- ============================================================
local menuList = Instance.new("Frame", sidebar)
menuList.Name  = "MenuList"
menuList.Size  = UDim2.new(1, -12, 1, -108)
menuList.Position = UDim2.new(0, 6, 0, 92)
menuList.BackgroundTransparency = 1
menuList.ZIndex = 7

local menuLayout = Instance.new("UIListLayout", menuList)
menuLayout.SortOrder = Enum.SortOrder.LayoutOrder
menuLayout.Padding   = UDim.new(0, 5)

-- ============================================================
-- CONTENT AREA (kanan, di dalam mainFrame)
-- ============================================================
local contentArea = Instance.new("Frame", mainFrame)
contentArea.Name  = "ContentArea"
contentArea.Size  = UDim2.new(1, -SIDEBAR_W, 1, 0)
contentArea.Position = UDim2.new(0, SIDEBAR_W, 0, 0)
contentArea.BackgroundColor3 = T.BgDark
contentArea.BorderSizePixel  = 0
contentArea.ClipsDescendants = false
contentArea.ZIndex = 6
-- Tidak pakai corner di sini supaya sudut kanan mainFrame tetap rounded

-- Placeholder saat belum ada fitur dibuka
local placeholderLbl = Instance.new("TextLabel", contentArea)
placeholderLbl.Text  = "← Pilih fitur dari menu"
placeholderLbl.Font  = Enum.Font.GothamBold
placeholderLbl.TextSize = 14
placeholderLbl.TextColor3 = T.TextMuted
placeholderLbl.BackgroundTransparency = 1
placeholderLbl.Size  = UDim2.new(1, 0, 1, 0)
placeholderLbl.TextXAlignment = Enum.TextXAlignment.Center
placeholderLbl.TextYAlignment = Enum.TextYAlignment.Center
placeholderLbl.ZIndex = 7

-- ============================================================
-- HEADER UTAMA (di content area, ada close button + title fitur)
-- ============================================================
local contentHeader = Instance.new("Frame", contentArea)
contentHeader.Name  = "ContentHeader"
contentHeader.Size  = UDim2.new(1, 0, 0, 56)
contentHeader.BackgroundColor3 = T.BgDark
contentHeader.BorderSizePixel  = 0
contentHeader.ZIndex = 7

local chGrad = Instance.new("UIGradient", contentHeader)
chGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, T.BgDark),
    ColorSequenceKeypoint.new(0.5, T.BgDark),
    ColorSequenceKeypoint.new(1, T.PrimaryDark),
})
chGrad.Rotation = 90

-- Title fitur aktif
local contentTitle = Instance.new("TextLabel", contentHeader)
contentTitle.Name  = "ContentTitle"
contentTitle.Text  = "SAN ANIMATIONS"
contentTitle.Font  = Enum.Font.GothamBold
contentTitle.TextScaled = true
contentTitle.TextColor3 = T.Text
contentTitle.BackgroundTransparency = 1
contentTitle.Size  = UDim2.new(0, 160, 0, 22)
contentTitle.Position = UDim2.new(0, 14, 0.5, -18)
contentTitle.TextXAlignment = Enum.TextXAlignment.Left
contentTitle.ZIndex = 8

local ctConstraint = Instance.new("UITextSizeConstraint", contentTitle)
ctConstraint.MinTextSize = 10
ctConstraint.MaxTextSize = 18

local contentSub = Instance.new("TextLabel", contentHeader)
contentSub.Name  = "ContentSub"
contentSub.Text  = "Animation Manager"
contentSub.Font  = Enum.Font.Gotham
contentSub.TextScaled = true
contentSub.TextColor3 = T.TextMuted
contentSub.BackgroundTransparency = 1
contentSub.Size  = UDim2.new(0, 160, 0, 13)
contentSub.Position = UDim2.new(0, 14, 0.5, 5)
contentSub.TextXAlignment = Enum.TextXAlignment.Left
contentSub.ZIndex = 8

local csConstraint = Instance.new("UITextSizeConstraint", contentSub)
csConstraint.MinTextSize = 8
csConstraint.MaxTextSize = 12

-- Close button di content header
local closeBtn = Instance.new("ImageButton", contentHeader)
closeBtn.Image = "rbxassetid://91182229617087"
closeBtn.ImageColor3 = T.Error
closeBtn.BackgroundColor3 = Color3.fromRGB(60, 28, 38)
closeBtn.Size  = UDim2.new(0, 36, 0, 36)
closeBtn.Position = UDim2.new(1, -46, 0.5, -18)
closeBtn.BorderSizePixel = 0
closeBtn.ZIndex = 8
mkCorner(closeBtn, 18)

closeBtn.MouseEnter:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(180,40,60)}):Play()
end)
closeBtn.MouseLeave:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(60,28,38)}):Play()
end)

-- Header line bawah
local chLine = Instance.new("Frame", contentHeader)
chLine.Size  = UDim2.new(0.9, 0, 0, 1)
chLine.Position = UDim2.new(0.05, 0, 1, -1)
chLine.BackgroundColor3 = T.PrimaryDark
chLine.BackgroundTransparency = 0.4
chLine.BorderSizePixel = 0
chLine.ZIndex = 8

-- Juga bisa drag dari content header
contentHeader.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        onDragStart(input)
    end
end)
contentHeader.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        onDragEnd()
    end
end)

-- ============================================================
-- FEATURE PAGE CONTAINER (di bawah content header)
-- ============================================================
local pageContainer = Instance.new("Frame", contentArea)
pageContainer.Name  = "PageContainer"
pageContainer.Size  = UDim2.new(1, 0, 1, -56)
pageContainer.Position = UDim2.new(0, 0, 0, 56)
pageContainer.BackgroundTransparency = 1
pageContainer.ClipsDescendants = true
pageContainer.ZIndex = 7
mkCorner(pageContainer, 18)

-- Border overlay — parent ke screenGui bukan mainFrame,
-- supaya tidak kepotong ClipsDescendants tapi tetap ngikutin posisi mainFrame
local borderOverlay = Instance.new("Frame", screenGui)
borderOverlay.Name  = "BorderOverlay"
borderOverlay.Size  = mainFrame.Size
borderOverlay.Position = mainFrame.Position
borderOverlay.BackgroundTransparency = 1
borderOverlay.BorderSizePixel = 0
borderOverlay.ZIndex = 20
mkCorner(borderOverlay, 18)
mkStroke(borderOverlay, T.Primary, 1.5, 0.5)

-- Sync posisi & size overlay saat mainFrame di-drag
RunService.RenderStepped:Connect(function()
    if mainFrame.Visible then
        borderOverlay.Position = mainFrame.Position
        borderOverlay.Size     = mainFrame.Size
        borderOverlay.Visible  = true
    else
        borderOverlay.Visible  = false
    end
end)

-- ============================================================
-- ERROR CARD
-- ============================================================
local function showErrorCard(frame, name, errMsg, onRetry)
    for _, ch in ipairs(frame:GetChildren()) do ch:Destroy() end

    local card = Instance.new("Frame", frame)
    card.Size  = UDim2.new(1, -24, 0, 0)
    card.Position = UDim2.new(0, 12, 0.5, 0)
    card.AnchorPoint = Vector2.new(0, 0.5)
    card.BackgroundColor3 = Color3.fromRGB(55, 22, 28)
    card.BorderSizePixel  = 0
    card.ZIndex = 8
    mkCorner(card, 12)

    local cs = Instance.new("UIStroke", card)
    cs.Color = T.Error; cs.Thickness = 1.5; cs.Transparency = 0.4

    local cL = Instance.new("UIListLayout", card)
    cL.SortOrder = Enum.SortOrder.LayoutOrder
    cL.Padding   = UDim.new(0, 6)
    cL.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local cP = Instance.new("UIPadding", card)
    cP.PaddingTop = UDim.new(0,14); cP.PaddingBottom = UDim.new(0,14)
    cP.PaddingLeft = UDim.new(0,12); cP.PaddingRight = UDim.new(0,12)

    local function addLbl(txt, font, size, color, lo, wrap)
        local l = Instance.new("TextLabel", card)
        l.Text = txt; l.Font = font; l.TextSize = size
        l.TextColor3 = color; l.BackgroundTransparency = 1
        l.Size = UDim2.new(1, 0, 0, 0)
        l.AutomaticSize = Enum.AutomaticSize.Y
        l.TextXAlignment = Enum.TextXAlignment.Center
        l.TextWrapped = wrap or false
        l.ZIndex = 9; l.LayoutOrder = lo
        return l
    end

    addLbl("⚠  " .. name .. " Failed to Load", Enum.Font.GothamBold, 13, T.Error, 1, true)

    local div = Instance.new("Frame", card)
    div.Size = UDim2.new(0.8, 0, 0, 1)
    div.BackgroundColor3 = T.Error; div.BackgroundTransparency = 0.6
    div.BorderSizePixel = 0; div.LayoutOrder = 2

    addLbl(tostring(errMsg):sub(1, 220), Enum.Font.Gotham, 10, T.TextMuted, 3, true)
    addLbl("Fitur lain tetap berfungsi normal.", Enum.Font.GothamItalic, 10, T.TextMuted, 4, false)

    local retryBtn = Instance.new("TextButton", card)
    retryBtn.Text = "↺  Retry"
    retryBtn.Font = Enum.Font.GothamBold; retryBtn.TextSize = 12
    retryBtn.TextColor3 = T.Text
    retryBtn.BackgroundColor3 = T.PrimaryDark
    retryBtn.BorderSizePixel = 0
    retryBtn.Size = UDim2.new(0.6, 0, 0, 30)
    retryBtn.ZIndex = 9; retryBtn.LayoutOrder = 5
    mkCorner(retryBtn, 8)

    retryBtn.MouseEnter:Connect(function()
        TweenService:Create(retryBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.Primary}):Play()
    end)
    retryBtn.MouseLeave:Connect(function()
        TweenService:Create(retryBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.PrimaryDark}):Play()
    end)
    retryBtn.MouseButton1Click:Connect(onRetry)

    cL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        card.Size = UDim2.new(1, -24, 0, cL.AbsoluteContentSize.Y + 28)
    end)
end

local function showLoadingCard(frame, name)
    for _, ch in ipairs(frame:GetChildren()) do ch:Destroy() end
    local lbl = Instance.new("TextLabel", frame)
    lbl.Text = "⏳  Loading " .. name .. "..."
    lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 13
    lbl.TextColor3 = T.TextMuted; lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.TextXAlignment = Enum.TextXAlignment.Center
    lbl.TextYAlignment = Enum.TextYAlignment.Center
    lbl.ZIndex = 8
    TweenService:Create(lbl,
        TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        {TextColor3 = T.PrimaryLight}
    ):Play()
end

-- ============================================================
-- MENU BUTTON + FEATURE SYSTEM
-- ============================================================
local menuBtns      = {}
local activePage    = nil
local loadedFeatures = {}

-- Nama & subtitle per fitur untuk content header
local FeatureTitles = {
    Animation  = {"SAN ANIMATIONS",  "Animation Manager"},
    Walkspeed  = {"WALKSPEED",        "Speed Controller"},
    InfoServer = {"INFO SERVER",      "Server Information"},
}

local function deselectAll()
    for _, btn in pairs(menuBtns) do
        TweenService:Create(btn, TweenInfo.new(0.18), {BackgroundColor3 = T.BgCard}):Play()
        local i = btn:FindFirstChild("Icon")
        local l = btn:FindFirstChild("Label")
        if i then i.ImageColor3 = T.TextMuted end
        if l then l.TextColor3  = T.TextMuted end
        -- reset accent bar
        local ab = btn:FindFirstChild("AccentBar")
        if ab then TweenService:Create(ab, TweenInfo.new(0.18), {BackgroundColor3 = T.Primary, BackgroundTransparency = 0.5}):Play() end
    end
end

local function selectBtn(name)
    local btn = menuBtns[name]
    if not btn then return end
    TweenService:Create(btn, TweenInfo.new(0.18), {BackgroundColor3 = T.PrimaryDark}):Play()
    local i = btn:FindFirstChild("Icon")
    local l = btn:FindFirstChild("Label")
    local ab = btn:FindFirstChild("AccentBar")
    if i  then i.ImageColor3  = T.Accent end
    if l  then l.TextColor3   = T.Accent end
    if ab then TweenService:Create(ab, TweenInfo.new(0.18), {BackgroundColor3 = T.Accent, BackgroundTransparency = 0}):Play() end

    -- Update content header title
    local titles = FeatureTitles[name]
    if titles then
        contentTitle.Text = titles[1]
        contentSub.Text   = titles[2]
    else
        contentTitle.Text = name:upper()
        contentSub.Text   = ""
    end
end

local function loadFeature(name)
    if loadedFeatures[name] and loadedFeatures[name].loaded then
        return loadedFeatures[name].frame
    end

    local url = FeatureURLs[name]
    local frame
    if loadedFeatures[name] then
        frame = loadedFeatures[name].frame
    else
        frame = Instance.new("Frame", pageContainer)
        frame.Name = name .. "Frame"
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.Visible = false
        frame.ZIndex  = 8
        loadedFeatures[name] = {frame = frame, loaded = false}
    end

    if not url then
        showErrorCard(frame, name, "URL tidak terdaftar di FeatureURLs.", function()
            Notify("Warning", name .. " tidak ada URL-nya!", 3)
        end)
        return frame
    end

    showLoadingCard(frame, name)

    coroutine.wrap(function()
        local scriptSource
        local fetchOk, fetchErr = pcall(function()
            scriptSource = game:HttpGet(url, true)
        end)

        if not fetchOk or not scriptSource or scriptSource == "" then
            showErrorCard(frame, name, "Gagal fetch URL:\n" .. tostring(fetchErr), function()
                loadedFeatures[name] = nil
                loadFeature(name)
            end)
            Notify("Error", name .. " gagal di-fetch!", 4)
            warn("[SanHub] Fetch error " .. name .. ": " .. tostring(fetchErr))
            return
        end

        local compiled, compileErr = loadstring(scriptSource)
        if not compiled then
            showErrorCard(frame, name, "Syntax error:\n" .. tostring(compileErr), function()
                loadedFeatures[name] = nil
                loadFeature(name)
            end)
            Notify("Error", name .. " syntax error!", 4)
            warn("[SanHub] Compile error " .. name .. ": " .. tostring(compileErr))
            return
        end

        _G.SanHub.CurrentFrame = frame
        _G.SanHub.Theme = T
        local runOk, runErr = pcall(compiled)

        if runOk then
            loadedFeatures[name].loaded = true
            Notify("Loaded", name .. " loaded!", 2)
        else
            showErrorCard(frame, name, "Runtime error:\n" .. tostring(runErr), function()
                loadedFeatures[name] = nil
                loadFeature(name)
            end)
            Notify("Error", name .. " runtime error!", 4)
            warn("[SanHub] Runtime error " .. name .. ": " .. tostring(runErr))
        end
    end)()

    return frame
end

local function showFeature(name)
    -- Toggle off kalau klik menu yang sama
    if activePage == name then
        deselectAll()
        activePage = nil
        for _, ch in ipairs(pageContainer:GetChildren()) do
            if ch:IsA("Frame") then ch.Visible = false end
        end
        placeholderLbl.Visible = true
        contentTitle.Text = "SAN HUB"
        contentSub.Text   = "Script Hub"
        return
    end

    deselectAll()
    selectBtn(name)
    activePage = name
    placeholderLbl.Visible = false

    for _, ch in ipairs(pageContainer:GetChildren()) do
        if ch:IsA("Frame") then ch.Visible = false end
    end

    local frame = loadFeature(name)
    if frame then frame.Visible = true end
end

-- ============================================================
-- ADD MENU BUTTON
-- ============================================================
local function addMenuBtn(name, iconId, order)
    local btn = Instance.new("TextButton", menuList)
    btn.Name  = name .. "Btn"
    btn.Text  = ""
    btn.BackgroundColor3 = T.BgCard
    btn.BorderSizePixel  = 0
    btn.Size  = UDim2.new(1, 0, 0, 40)
    btn.LayoutOrder = order
    btn.ZIndex = 8
    mkCorner(btn, 10)

    local accentBar = Instance.new("Frame", btn)
    accentBar.Name  = "AccentBar"
    accentBar.Size  = UDim2.new(0, 3, 0.6, 0)
    accentBar.Position = UDim2.new(0, 5, 0.2, 0)
    accentBar.BackgroundColor3 = T.Primary
    accentBar.BackgroundTransparency = 0.5
    accentBar.BorderSizePixel = 0
    accentBar.ZIndex = 9
    Instance.new("UICorner", accentBar).CornerRadius = UDim.new(1, 0)

    local ico = Instance.new("ImageLabel", btn)
    ico.Name  = "Icon"
    ico.Image = iconId
    ico.ImageColor3 = T.TextMuted
    ico.Size  = UDim2.new(0, 20, 0, 20)
    ico.Position = UDim2.new(0, 14, 0.5, -10)
    ico.BackgroundTransparency = 1
    ico.ZIndex = 9

    local lbl = Instance.new("TextLabel", btn)
    lbl.Name  = "Label"
    lbl.Text  = name
    lbl.Font  = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextColor3 = T.TextMuted
    lbl.BackgroundTransparency = 1
    lbl.Size  = UDim2.new(1, -42, 1, 0)
    lbl.Position = UDim2.new(0, 40, 0, 0)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 9

    btn.MouseEnter:Connect(function()
        if activePage ~= name then
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = T.BgLight}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if activePage ~= name then
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = T.BgCard}):Play()
        end
    end)
    btn.MouseButton1Click:Connect(function()
        showFeature(name)
    end)

    menuBtns[name] = btn
    return btn
end

-- ============================================================
-- DAFTAR MENU ← tambah fitur baru di sini
-- ============================================================
addMenuBtn("Animation",  "rbxassetid://129775391836345", 1)
addMenuBtn("InfoServer", "rbxassetid://7733960981",      2)
addMenuBtn("Walkspeed",  "rbxassetid://100773799716592", 3)
-- addMenuBtn("ESP",     "rbxassetid://7733960981",      4)

-- ============================================================
-- TOGGLE OPEN / CLOSE
-- ============================================================
local isOpen = false

local function openHub()
    isOpen = true
    mainFrame.Visible = true
    mainFrame.BackgroundTransparency = 0.4
    TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.05
    }):Play()
    TweenService:Create(toggleBtn, TweenInfo.new(0.2), {
        BackgroundColor3 = T.PrimaryDark,
        ImageColor3 = T.Text,
    }):Play()
end

local function closeHub()
    isOpen = false
    mainFrame.Visible = false
    TweenService:Create(toggleBtn, TweenInfo.new(0.2), {
        BackgroundColor3 = T.BgMid,
        ImageColor3 = T.Accent,
    }):Play()
end

toggleBtn.MouseButton1Click:Connect(function()
    if isOpen then closeHub() else openHub() end
end)

closeBtn.MouseButton1Click:Connect(closeHub)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.B then
        if isOpen then closeHub() else openHub() end
    end
end)

-- ============================================================
-- INIT
-- ============================================================
Notify("Welcome", isTouchDevice and "Tap icon to open Hub!" or "Press B to open Hub!", 6)

end)

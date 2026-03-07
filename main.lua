-- ============================================================
--  SAN HUB — main.lua
--  Jalankan file ini. Fitur di-load otomatis pas menu diklik.
-- ============================================================

pcall(function()

-- ============================================================
-- FEATURE URLs  ← ganti sesuai raw URL kamu
-- ============================================================
local FeatureURLs = {
    Animation  = "https://raw.githubusercontent.com/Sanzzy12/SanHub/main/features/animation.lua",
    -- Walkspeed  = "https://raw.githubusercontent.com/USERNAME/SanHub/main/features/walkspeed.lua",
    -- tambah fitur baru di sini:
    -- NamaFitur = "https://...",
}

-- ============================================================
-- SERVICES
-- ============================================================
local TweenService      = game:GetService("TweenService")
local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")

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
screenGui.Name  = GUI_NAME
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

-- ============================================================
-- SHARED TABLE  ← fitur baca/tulis di sini
-- ============================================================
_G.SanHub = _G.SanHub or {}
_G.SanHub.Notify = nil  -- akan diisi setelah Notify dibuat

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

-- ============================================================
-- NOTIFICATION SYSTEM
-- ============================================================
local Notifbro = {}

local NotifColors = {
    Default          = T.Primary,
    Loaded           = T.Success,
    Error            = T.Error,
    Warning          = T.Warning,
    Set              = T.PrimaryLight,
    Created          = T.Success,
    Copied           = T.Info,
    Database         = T.Info,
    Welcome          = T.Accent,
    Info             = T.Info,
    ["First Time"]   = T.Warning,
    ["Database Update"] = T.Success,
}
local NotifIcons = {
    Default          = "rbxassetid://134341920489415",
    Loaded           = "rbxassetid://134341920489415",
    Error            = "rbxassetid://16913919379",
    Warning          = "rbxassetid://16913919379",
    Set              = "rbxassetid://5578470911",
    Created          = "rbxassetid://5578470911",
    Copied           = "rbxassetid://5578470911",
    Database         = "rbxassetid://5578470911",
    Welcome          = "rbxassetid://134341920489415",
    Info             = "rbxassetid://134341920489415",
    ["First Time"]   = "rbxassetid://134341920489415",
    ["Database Update"] = "rbxassetid://134341920489415",
}

local function Notify(title, text, duration)
    coroutine.wrap(function()
        local cam = workspace.CurrentCamera
        local nw  = math.max(260, cam.ViewportSize.X / 5.5)
        local nh  = 70
        local ac  = NotifColors[title] or T.Primary
        local ico = NotifIcons[title]  or NotifIcons.Default

        local G = Instance.new("ScreenGui")
        G.Name   = "SanNotif"
        G.Parent = CoreGui

        local shadow = Instance.new("Frame", G)
        shadow.Size = UDim2.new(0, nw+8, 0, nh+8)
        shadow.BackgroundColor3 = Color3.new(0,0,0)
        shadow.BackgroundTransparency = 0.6
        shadow.BorderSizePixel = 0
        Instance.new("UICorner", shadow).CornerRadius = UDim.new(0,16)

        local card = Instance.new("Frame", G)
        card.Size  = UDim2.new(0, nw, 0, nh)
        card.BackgroundColor3 = T.BgMid
        card.BackgroundTransparency = 0.05
        card.BorderSizePixel = 0
        Instance.new("UICorner", card).CornerRadius = UDim.new(0,14)

        local bar = Instance.new("Frame", card)
        bar.Size = UDim2.new(0,4,1,0)
        bar.BackgroundColor3 = ac
        bar.BorderSizePixel = 0
        Instance.new("UICorner", bar).CornerRadius = UDim.new(0,4)

        local iFrame = Instance.new("Frame", card)
        iFrame.Size = UDim2.new(0,38,0,38)
        iFrame.Position = UDim2.new(0,16,0.5,-19)
        iFrame.BackgroundColor3 = ac
        iFrame.BackgroundTransparency = 0.75
        iFrame.BorderSizePixel = 0
        Instance.new("UICorner", iFrame).CornerRadius = UDim.new(0,10)

        local iImg = Instance.new("ImageLabel", iFrame)
        iImg.Size = UDim2.new(0,22,0,22)
        iImg.Position = UDim2.new(0.5,-11,0.5,-11)
        iImg.BackgroundTransparency = 1
        iImg.Image = ico
        iImg.ImageColor3 = ac

        local tl = Instance.new("TextLabel", card)
        tl.BackgroundTransparency = 1
        tl.Size = UDim2.new(1,-80,0,22)
        tl.Position = UDim2.new(0,66,0,10)
        tl.Font = Enum.Font.GothamBold
        tl.TextSize = 13
        tl.Text = title
        tl.TextColor3 = ac
        tl.TextXAlignment = Enum.TextXAlignment.Left

        local ml = Instance.new("TextLabel", card)
        ml.BackgroundTransparency = 1
        ml.Size = UDim2.new(1,-80,0,24)
        ml.Position = UDim2.new(0,66,0,33)
        ml.Font = Enum.Font.Gotham
        ml.TextSize = 11
        ml.Text = text
        ml.TextColor3 = T.TextMuted
        ml.TextXAlignment = Enum.TextXAlignment.Left
        ml.TextWrapped = true

        local pbg = Instance.new("Frame", card)
        pbg.Size = UDim2.new(1,-8,0,3)
        pbg.Position = UDim2.new(0,4,1,-5)
        pbg.BackgroundColor3 = T.BgLight
        pbg.BorderSizePixel = 0
        Instance.new("UICorner", pbg).CornerRadius = UDim.new(1,0)

        local pb = Instance.new("Frame", pbg)
        pb.Size = UDim2.new(1,0,1,0)
        pb.BackgroundColor3 = ac
        pb.BorderSizePixel = 0
        Instance.new("UICorner", pb).CornerRadius = UDim.new(1,0)

        local offset = 20
        for _, n in ipairs(Notifbro) do offset = offset + n.Size.Y.Offset + 12 end

        local sX = UDim2.new(1, nw+10, 0, offset)
        local eX = UDim2.new(1,-nw-16, 0, offset)
        card.Position   = sX
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

-- expose ke fitur
_G.SanHub.Notify = Notify

-- ============================================================
-- HELPER
-- ============================================================
local function corner(p, r) Instance.new("UICorner",p).CornerRadius=UDim.new(0,r or 12) end
local function stroke(p, col, thick, trans)
    local s = Instance.new("UIStroke",p)
    s.Color=col or T.Primary; s.Thickness=thick or 1.5
    s.Transparency=trans or 0.4; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
end

-- ============================================================
-- DETECT INPUT
-- ============================================================
local isTouchDevice = UserInputService.TouchEnabled
    and not UserInputService.KeyboardEnabled
    and not UserInputService.MouseEnabled

-- ============================================================
-- TOGGLE ICON BUTTON
-- ============================================================
local toggleBtn = Instance.new("ImageButton")
toggleBtn.Name   = "ToggleButton"
toggleBtn.Image  = "rbxassetid://8215093320"
toggleBtn.ImageColor3 = T.Accent
toggleBtn.Size   = UDim2.new(0,52,0,52)
toggleBtn.Position = UDim2.new(0,10,0.5,-26)
toggleBtn.BackgroundColor3 = T.BgMid
toggleBtn.BackgroundTransparency = 0.1
toggleBtn.BorderSizePixel = 0
toggleBtn.Active = true
toggleBtn.Draggable = true
toggleBtn.ZIndex = 10
toggleBtn.Parent = screenGui
corner(toggleBtn, 26)
stroke(toggleBtn, T.Primary, 1.5, 0.3)

TweenService:Create(toggleBtn,
    TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
    {ImageColor3 = T.Primary}
):Play()

-- ============================================================
-- HUB SIDEBAR FRAME
-- ============================================================
local HUB_W = 270
local hubFrame = Instance.new("Frame")
hubFrame.Name  = "HubFrame"
hubFrame.Size  = UDim2.new(0, HUB_W, 0.74, 0)
hubFrame.Position = UDim2.new(0, -HUB_W-20, 0.13, 0)
hubFrame.BackgroundColor3 = T.BgDark
hubFrame.BackgroundTransparency = 0.04
hubFrame.BorderSizePixel = 0
hubFrame.ClipsDescendants = true
hubFrame.ZIndex = 5
hubFrame.Visible = false
hubFrame.Parent = screenGui
corner(hubFrame, 16)
stroke(hubFrame, T.Primary, 1.5, 0.4)

local hubGrad = Instance.new("UIGradient", hubFrame)
hubGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, T.BgMid),
    ColorSequenceKeypoint.new(1, T.BgDark),
})
hubGrad.Rotation = 135

-- ============================================================
-- SIDEBAR HEADER
-- ============================================================
local header = Instance.new("Frame", hubFrame)
header.Size  = UDim2.new(1,0,0,58)
header.BackgroundColor3 = T.BgDark
header.BorderSizePixel = 0
header.ZIndex = 6
corner(header, 16)

local hGrad = Instance.new("UIGradient", header)
hGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, T.PrimaryDark),
    ColorSequenceKeypoint.new(1, T.BgDark),
})
hGrad.Rotation = 90

local hIcon = Instance.new("ImageLabel", header)
hIcon.Image  = "rbxassetid://12557404943"
hIcon.ImageColor3 = T.Accent
hIcon.Size   = UDim2.new(0,26,0,26)
hIcon.Position = UDim2.new(0,12,0.5,-13)
hIcon.BackgroundTransparency = 1
hIcon.ZIndex = 7

local hTitle = Instance.new("TextLabel", header)
hTitle.Text  = "SAN HUB"
hTitle.Font  = Enum.Font.GothamBold
hTitle.TextSize = 15
hTitle.TextColor3 = T.Text
hTitle.BackgroundTransparency = 1
hTitle.Size  = UDim2.new(0,140,0,20)
hTitle.Position = UDim2.new(0,46,0.5,-18)
hTitle.TextXAlignment = Enum.TextXAlignment.Left
hTitle.ZIndex = 7

local hSub = Instance.new("TextLabel", header)
hSub.Text   = "Script Hub"
hSub.Font   = Enum.Font.Gotham
hSub.TextSize = 10
hSub.TextColor3 = T.TextMuted
hSub.BackgroundTransparency = 1
hSub.Size   = UDim2.new(0,140,0,13)
hSub.Position = UDim2.new(0,46,0.5,4)
hSub.TextXAlignment = Enum.TextXAlignment.Left
hSub.ZIndex = 7

-- Close button
local closeBtn = Instance.new("ImageButton", header)
closeBtn.Image = "rbxassetid://91182229617087"
closeBtn.ImageColor3 = T.Error
closeBtn.BackgroundColor3 = Color3.fromRGB(60,28,38)
closeBtn.Size  = UDim2.new(0,28,0,28)
closeBtn.Position = UDim2.new(1,-38,0.5,-14)
closeBtn.BorderSizePixel = 0
closeBtn.ZIndex = 7
corner(closeBtn, 14)

closeBtn.MouseEnter:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(180,40,60)}):Play()
end)
closeBtn.MouseLeave:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(60,28,38)}):Play()
end)

-- Header separator
local hLine = Instance.new("Frame", header)
hLine.Size  = UDim2.new(0.88,0,0,1)
hLine.Position = UDim2.new(0.06,0,1,-1)
hLine.BackgroundColor3 = T.PrimaryDark
hLine.BackgroundTransparency = 0.4
hLine.BorderSizePixel = 0
hLine.ZIndex = 7

-- ============================================================
-- INFO BAR  (Clock | FPS | URL)
-- ============================================================
local infoBar = Instance.new("Frame", hubFrame)
infoBar.Size  = UDim2.new(1,-16,0,26)
infoBar.Position = UDim2.new(0,8,0,62)
infoBar.BackgroundColor3 = T.BgCard
infoBar.BackgroundTransparency = 0.2
infoBar.BorderSizePixel = 0
infoBar.ClipsDescendants = true
infoBar.ZIndex = 6
corner(infoBar, 8)

local function infoLabel(text, xScale, color)
    local l = Instance.new("TextLabel", infoBar)
    l.Text  = text
    l.Font  = Enum.Font.GothamBold
    l.TextSize = 10
    l.TextColor3 = color or T.Text
    l.BackgroundTransparency = 1
    l.Size  = UDim2.new(0.33,0,1,0)
    l.Position = UDim2.new(xScale,0,0,0)
    l.TextXAlignment = Enum.TextXAlignment.Center
    l.TextYAlignment = Enum.TextYAlignment.Center
    l.ZIndex = 7
    return l
end
local function infoSep(xScale)
    local s = Instance.new("Frame", infoBar)
    s.Size  = UDim2.new(0,1,0.5,0)
    s.Position = UDim2.new(xScale,0,0.25,0)
    s.BackgroundColor3 = T.PrimaryDark
    s.BackgroundTransparency = 0.3
    s.BorderSizePixel = 0
    s.ZIndex = 7
end

local clockLbl = infoLabel("00:00:00", 0,    T.Accent)
infoSep(0.33)
local fpsLbl   = infoLabel("-- FPS",   0.33, T.Success)
infoSep(0.66)
infoLabel("sanzzy.xyz", 0.66, T.PrimaryLight)

-- FPS + Clock updater
local fpsBuffer, lastFpsT, lastClkT = {}, 0, 0
RunService.RenderStepped:Connect(function(dt)
    local now = os.clock()
    table.insert(fpsBuffer, 1/dt)
    if #fpsBuffer > 20 then table.remove(fpsBuffer,1) end
    if now - lastFpsT >= 0.3 then
        lastFpsT = now
        local s = 0
        for _,v in ipairs(fpsBuffer) do s=s+v end
        local avg = math.floor(s/#fpsBuffer)
        fpsLbl.Text = avg.." FPS"
        fpsLbl.TextColor3 = avg>=55 and T.Success or avg>=30 and T.Warning or T.Error
    end
    if now - lastClkT >= 1 then
        lastClkT = now
        local t = math.floor(tick())
        clockLbl.Text = string.format("%02d:%02d:%02d", math.floor(t/3600)%24, math.floor(t/60)%60, t%60)
    end
end)

-- ============================================================
-- MENU CONTAINER  (auto-height)
-- ============================================================
local menuList = Instance.new("Frame", hubFrame)
menuList.Name  = "MenuList"
menuList.Size  = UDim2.new(1,-16,0,0)
menuList.Position = UDim2.new(0,8,0,94)
menuList.BackgroundTransparency = 1
menuList.ZIndex = 6

local menuLayout = Instance.new("UIListLayout", menuList)
menuLayout.SortOrder = Enum.SortOrder.LayoutOrder
menuLayout.Padding   = UDim.new(0,5)

menuLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    menuList.Size = UDim2.new(1,-16,0, menuLayout.AbsoluteContentSize.Y)
end)

-- ============================================================
-- CONTENT AREA  (shown below menu when feature active)
-- ============================================================
local contentArea = Instance.new("Frame", hubFrame)
contentArea.Name  = "ContentArea"
contentArea.Size  = UDim2.new(1,-16,0,200)
contentArea.Position = UDim2.new(0,8,0,200)
contentArea.BackgroundColor3 = T.BgCard
contentArea.BorderSizePixel  = 0
contentArea.ClipsDescendants = true
contentArea.Visible = false
contentArea.ZIndex  = 6
corner(contentArea, 12)
stroke(contentArea, T.PrimaryDark, 1.5, 0.6)

-- Reposition contentArea to sit right below menu
local function repositionContent()
    task.wait()
    local menuBottom = 94 + menuList.AbsoluteSize.Y + 8
    local available  = hubFrame.AbsoluteSize.Y - menuBottom - 10
    if available > 50 then
        contentArea.Position = UDim2.new(0,8,0,menuBottom)
        contentArea.Size     = UDim2.new(1,-16,0,available)
    end
end

menuLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(repositionContent)
hubFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(repositionContent)

-- ============================================================
-- MENU BUTTON FACTORY
-- ============================================================
local menuBtns   = {}
local activePage = nil
local loadedFeatures = {}  -- cache: nama → frame (sudah di-load)

local function deselectAll()
    for name, btn in pairs(menuBtns) do
        TweenService:Create(btn, TweenInfo.new(0.18), {BackgroundColor3 = T.BgCard}):Play()
        local i = btn:FindFirstChild("Icon")
        local l = btn:FindFirstChild("Label")
        if i then i.ImageColor3 = T.TextMuted end
        if l then l.TextColor3  = T.TextMuted end
    end
end

local function selectBtn(name)
    local btn = menuBtns[name]
    if not btn then return end
    TweenService:Create(btn, TweenInfo.new(0.18), {BackgroundColor3 = T.PrimaryDark}):Play()
    local i = btn:FindFirstChild("Icon")
    local l = btn:FindFirstChild("Label")
    if i then i.ImageColor3 = T.Accent end
    if l then l.TextColor3  = T.Accent end
end

-- ============================================================
-- ERROR CARD  (ditampilkan di dalam frame kalau fitur gagal load)
-- ============================================================
local function showErrorCard(frame, name, errMsg, onRetry)
    -- Bersihkan isi frame dulu (hapus loading label, dll)
    for _, ch in ipairs(frame:GetChildren()) do ch:Destroy() end

    -- Background card
    local card = Instance.new("Frame", frame)
    card.Name  = "ErrorCard"
    card.Size  = UDim2.new(1, -24, 0, 0)  -- height auto
    card.Position = UDim2.new(0, 12, 0.5, 0)
    card.AnchorPoint = Vector2.new(0, 0.5)
    card.BackgroundColor3 = Color3.fromRGB(55, 22, 28)
    card.BorderSizePixel  = 0
    card.ZIndex = 8
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)

    local cardStroke = Instance.new("UIStroke", card)
    cardStroke.Color = T.Error
    cardStroke.Thickness = 1.5
    cardStroke.Transparency = 0.4

    local cardLayout = Instance.new("UIListLayout", card)
    cardLayout.SortOrder = Enum.SortOrder.LayoutOrder
    cardLayout.Padding   = UDim.new(0, 6)
    cardLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local cardPad = Instance.new("UIPadding", card)
    cardPad.PaddingTop    = UDim.new(0, 14)
    cardPad.PaddingBottom = UDim.new(0, 14)
    cardPad.PaddingLeft   = UDim.new(0, 12)
    cardPad.PaddingRight  = UDim.new(0, 12)

    -- Icon error
    local iconFrame = Instance.new("Frame", card)
    iconFrame.Name  = "IconFrame"
    iconFrame.Size  = UDim2.new(0, 40, 0, 40)
    iconFrame.BackgroundColor3 = T.Error
    iconFrame.BackgroundTransparency = 0.8
    iconFrame.BorderSizePixel = 0
    iconFrame.LayoutOrder = 1
    Instance.new("UICorner", iconFrame).CornerRadius = UDim.new(0.5, 0)

    local icon = Instance.new("ImageLabel", iconFrame)
    icon.Image = "rbxassetid://16913919379"
    icon.ImageColor3 = T.Error
    icon.Size = UDim2.new(0, 24, 0, 24)
    icon.Position = UDim2.new(0.5, -12, 0.5, -12)
    icon.BackgroundTransparency = 1
    icon.ZIndex = 9

    -- Title
    local title = Instance.new("TextLabel", card)
    title.Text  = "⚠ " .. name .. " Failed to Load"
    title.Font  = Enum.Font.GothamBold
    title.TextSize = 13
    title.TextColor3 = T.Error
    title.BackgroundTransparency = 1
    title.Size  = UDim2.new(1, 0, 0, 18)
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.TextWrapped = true
    title.ZIndex = 9
    title.LayoutOrder = 2

    -- Divider
    local divider = Instance.new("Frame", card)
    divider.Size  = UDim2.new(0.8, 0, 0, 1)
    divider.BackgroundColor3 = T.Error
    divider.BackgroundTransparency = 0.6
    divider.BorderSizePixel = 0
    divider.LayoutOrder = 3

    -- Error message (detail)
    local errLbl = Instance.new("TextLabel", card)
    errLbl.Text  = tostring(errMsg):sub(1, 200)  -- limit panjang
    errLbl.Font  = Enum.Font.Gotham
    errLbl.TextSize = 10
    errLbl.TextColor3 = T.TextMuted
    errLbl.BackgroundTransparency = 1
    errLbl.Size  = UDim2.new(1, 0, 0, 0)
    errLbl.AutomaticSize = Enum.AutomaticSize.Y
    errLbl.TextXAlignment = Enum.TextXAlignment.Center
    errLbl.TextWrapped = true
    errLbl.ZIndex = 9
    errLbl.LayoutOrder = 4

    -- Hint text
    local hint = Instance.new("TextLabel", card)
    hint.Text  = "Fitur lain tetap berfungsi normal."
    hint.Font  = Enum.Font.GothamItalic
    hint.TextSize = 10
    hint.TextColor3 = T.TextMuted
    hint.BackgroundTransparency = 1
    hint.Size  = UDim2.new(1, 0, 0, 14)
    hint.TextXAlignment = Enum.TextXAlignment.Center
    hint.ZIndex = 9
    hint.LayoutOrder = 5

    -- Retry button
    local retryBtn = Instance.new("TextButton", card)
    retryBtn.Text  = "↺  Retry"
    retryBtn.Font  = Enum.Font.GothamBold
    retryBtn.TextSize = 12
    retryBtn.TextColor3 = T.Text
    retryBtn.BackgroundColor3 = T.PrimaryDark
    retryBtn.BorderSizePixel  = 0
    retryBtn.Size  = UDim2.new(0.6, 0, 0, 30)
    retryBtn.ZIndex = 9
    retryBtn.LayoutOrder = 6
    Instance.new("UICorner", retryBtn).CornerRadius = UDim.new(0, 8)

    retryBtn.MouseEnter:Connect(function()
        TweenService:Create(retryBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.Primary}):Play()
    end)
    retryBtn.MouseLeave:Connect(function()
        TweenService:Create(retryBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.PrimaryDark}):Play()
    end)
    retryBtn.MouseButton1Click:Connect(function()
        onRetry()
    end)

    -- Auto-size card height
    cardLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        card.Size = UDim2.new(1, -24, 0, cardLayout.AbsoluteContentSize.Y + 28)
    end)
end

-- ============================================================
-- LOADING CARD  (spinner saat fetch URL)
-- ============================================================
local function showLoadingCard(frame, name)
    for _, ch in ipairs(frame:GetChildren()) do ch:Destroy() end

    local lbl = Instance.new("TextLabel", frame)
    lbl.Name  = "LoadingLabel"
    lbl.Text  = "⏳  Loading " .. name .. "..."
    lbl.Font  = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.TextColor3 = T.TextMuted
    lbl.BackgroundTransparency = 1
    lbl.Size  = UDim2.new(1, 0, 1, 0)
    lbl.TextXAlignment = Enum.TextXAlignment.Center
    lbl.TextYAlignment = Enum.TextYAlignment.Center
    lbl.ZIndex = 8

    -- Subtle pulse animation
    TweenService:Create(lbl, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
        TextColor3 = T.PrimaryLight
    }):Play()
end

-- ============================================================
-- LAZY LOAD FEATURE  (isolated per-feature, error tidak menyebar)
-- ============================================================
local function loadFeature(name)
    -- Kalau sudah pernah di-load sukses, langsung return frame
    if loadedFeatures[name] and loadedFeatures[name].loaded then
        return loadedFeatures[name].frame
    end

    local url = FeatureURLs[name]

    -- Buat frame kalau belum ada
    local frame
    if loadedFeatures[name] then
        frame = loadedFeatures[name].frame
    else
        frame = Instance.new("Frame", contentArea)
        frame.Name  = name .. "Frame"
        frame.Size  = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.Visible = false
        frame.ZIndex  = 7
        loadedFeatures[name] = { frame = frame, loaded = false }
    end

    -- Kalau tidak ada URL → tampilkan error langsung
    if not url then
        showErrorCard(frame, name, "URL tidak terdaftar di FeatureURLs.", function()
            -- retry tidak bisa kalau URL memang tidak ada
            Notify("Warning", name .. " tidak ada URL-nya!", 3)
        end)
        return frame
    end

    -- Tampilkan loading state
    showLoadingCard(frame, name)

    -- Load script di coroutine terpisah — TIDAK mempengaruhi fitur lain
    coroutine.wrap(function()
        local scriptSource
        local fetchOk, fetchErr = pcall(function()
            scriptSource = game:HttpGet(url, true)
        end)

        if not fetchOk or not scriptSource or scriptSource == "" then
            -- Gagal fetch URL
            showErrorCard(frame, name, "Gagal mengambil script dari URL:\n" .. tostring(fetchErr), function()
                loadedFeatures[name] = nil  -- reset cache supaya bisa retry
                loadFeature(name)
            end)
            Notify("Error", name .. " gagal di-fetch!", 4)
            warn("[SanHub] Fetch error " .. name .. ": " .. tostring(fetchErr))
            return
        end

        -- Compile + execute script dalam pcall terpisah
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

        -- Jalankan script (runtime error ditangkap di sini)
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
    -- Toggle off jika klik menu yang sama
    if activePage == name then
        deselectAll()
        activePage = nil
        -- hide semua frame di contentArea
        for _, ch in ipairs(contentArea:GetChildren()) do
            if ch:IsA("Frame") then ch.Visible = false end
        end
        contentArea.Visible = false
        return
    end

    deselectAll()
    selectBtn(name)
    activePage = name

    -- Hide semua frame lain
    for _, ch in ipairs(contentArea:GetChildren()) do
        if ch:IsA("Frame") then ch.Visible = false end
    end

    -- Load (kalau belum) lalu show
    local frame = loadFeature(name)
    if frame then
        contentArea.Visible = true
        frame.Visible = true
    end

    -- Kalau masih loading (async), pantau sampai frame muncul kontennya
    -- (frame sudah di-return duluan, konten akan muncul otomatis setelah load)
end

local function addMenuBtn(name, iconId, order, onClick)
    local btn = Instance.new("TextButton", menuList)
    btn.Name  = name .. "Btn"
    btn.Text  = ""
    btn.BackgroundColor3 = T.BgCard
    btn.BorderSizePixel  = 0
    btn.Size  = UDim2.new(1,0,0,42)
    btn.LayoutOrder = order
    btn.ZIndex = 7
    corner(btn, 10)

    local accentBar = Instance.new("Frame", btn)
    accentBar.Size  = UDim2.new(0,3,0.6,0)
    accentBar.Position = UDim2.new(0,6,0.2,0)
    accentBar.BackgroundColor3 = T.Primary
    accentBar.BackgroundTransparency = 0.4
    accentBar.BorderSizePixel = 0
    accentBar.ZIndex = 8
    Instance.new("UICorner", accentBar).CornerRadius = UDim.new(1,0)

    local ico = Instance.new("ImageLabel", btn)
    ico.Name  = "Icon"
    ico.Image = iconId
    ico.ImageColor3 = T.TextMuted
    ico.Size  = UDim2.new(0,20,0,20)
    ico.Position = UDim2.new(0,16,0.5,-10)
    ico.BackgroundTransparency = 1
    ico.ZIndex = 8

    local lbl = Instance.new("TextLabel", btn)
    lbl.Name  = "Label"
    lbl.Text  = name
    lbl.Font  = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.TextColor3 = T.TextMuted
    lbl.BackgroundTransparency = 1
    lbl.Size  = UDim2.new(1,-46,1,0)
    lbl.Position = UDim2.new(0,44,0,0)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 8

    -- Arrow indicator kanan
    local arrow = Instance.new("TextLabel", btn)
    arrow.Text  = "›"
    arrow.Font  = Enum.Font.GothamBold
    arrow.TextSize = 18
    arrow.TextColor3 = T.TextMuted
    arrow.BackgroundTransparency = 1
    arrow.Size  = UDim2.new(0,18,1,0)
    arrow.Position = UDim2.new(1,-22,0,0)
    arrow.TextXAlignment = Enum.TextXAlignment.Center
    arrow.ZIndex = 8

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

    btn.MouseButton1Click:Connect(onClick or function()
        showFeature(name)
    end)

    menuBtns[name] = btn
    return btn
end

-- ============================================================
-- DAFTAR MENU  ← tambah fitur baru di sini
-- ============================================================
addMenuBtn("Animation", "rbxassetid://129775391836345", 1)
addMenuBtn("Walkspeed",  "rbxassetid://100773799716592", 2)
-- addMenuBtn("ESP",     "rbxassetid://7733960981",      3)

-- ============================================================
-- DIVIDER LABEL helper (opsional)
-- ============================================================
local function addDivider(labelText, order)
    local div = Instance.new("Frame", menuList)
    div.Size  = UDim2.new(1,0,0,20)
    div.BackgroundTransparency = 1
    div.LayoutOrder = order
    div.ZIndex = 6

    local line = Instance.new("Frame", div)
    line.Size  = UDim2.new(0.85,0,0,1)
    line.Position = UDim2.new(0.075,0,0.5,0)
    line.BackgroundColor3 = T.PrimaryDark
    line.BackgroundTransparency = 0.5
    line.BorderSizePixel = 0

    local lbl = Instance.new("TextLabel", div)
    lbl.Text  = labelText
    lbl.Font  = Enum.Font.GothamBold
    lbl.TextSize = 9
    lbl.TextColor3 = T.TextMuted
    lbl.BackgroundColor3 = T.BgDark
    lbl.Size  = UDim2.new(0,70,1,0)
    lbl.Position = UDim2.new(0.5,-35,0,0)
    lbl.TextXAlignment = Enum.TextXAlignment.Center
    lbl.ZIndex = 7
end

-- ============================================================
-- TOGGLE OPEN / CLOSE (slide kiri)
-- ============================================================
local isOpen   = false
local OPEN_POS = UDim2.new(0, 70, 0.13, 0)
local HIDE_POS = UDim2.new(0, -HUB_W-20, 0.13, 0)

local function openHub()
    isOpen = true
    hubFrame.Visible  = true
    hubFrame.Position = HIDE_POS
    TweenService:Create(hubFrame,   TweenInfo.new(0.32, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = OPEN_POS}):Play()
    TweenService:Create(toggleBtn,  TweenInfo.new(0.2),  {BackgroundColor3 = T.PrimaryDark, ImageColor3 = T.Text}):Play()
    repositionContent()
end

local function closeHub()
    isOpen = false
    TweenService:Create(hubFrame,  TweenInfo.new(0.26, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = HIDE_POS}):Play()
    TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = T.BgMid, ImageColor3 = T.Accent}):Play()
    task.wait(0.28)
    if not isOpen then hubFrame.Visible = false end
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
local isTouchDevice = UserInputService.TouchEnabled
    and not UserInputService.KeyboardEnabled
    and not UserInputService.MouseEnabled

Notify("Welcome", isTouchDevice and "Tap icon to open Hub!" or "Press B to open Hub!", 6)

end)

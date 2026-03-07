-- ============================================================
--  SAN HUB — features/infoserver.lua
--  Di-load oleh main.lua secara lazy
--  Komunikasi dengan hub lewat _G.SanHub
-- ============================================================

local TweenService     = game:GetService("TweenService")
local HttpService      = game:GetService("HttpService")
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local TeleportService  = game:GetService("TeleportService")

local Notify      = _G.SanHub.Notify
local T           = _G.SanHub.Theme
local parentFrame = _G.SanHub.CurrentFrame

if not parentFrame or not Notify or not T then
    warn("[SanHub/InfoServer] _G.SanHub tidak lengkap!")
    return
end

-- Bersihkan loading label
for _, ch in ipairs(parentFrame:GetChildren()) do ch:Destroy() end

-- ============================================================
-- HELPER
-- ============================================================
local function mkCorner(p, r)
    Instance.new("UICorner", p).CornerRadius = UDim.new(0, r or 10)
end
local function mkStroke(p, col, trans)
    local s = Instance.new("UIStroke", p)
    s.Color = col or T.Primary
    s.Thickness = 1.2
    s.Transparency = trans or 0.5
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end
local function mkLabel(parent, text, font, size, color, zindex)
    local l = Instance.new("TextLabel", parent)
    l.Text = text
    l.Font = font or Enum.Font.Gotham
    l.TextSize = size or 12
    l.TextColor3 = color or T.Text
    l.BackgroundTransparency = 1
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = zindex or 9
    return l
end

-- ============================================================
-- SCROLL CONTAINER (semua konten bisa discroll)
-- ============================================================
local scroll = Instance.new("ScrollingFrame", parentFrame)
scroll.Size = UDim2.new(1, 0, 1, 0)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = T.Primary
scroll.ScrollingDirection = Enum.ScrollingDirection.Y
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.ZIndex = 8

local scrollLayout = Instance.new("UIListLayout", scroll)
scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
scrollLayout.Padding = UDim.new(0, 8)

local scrollPad = Instance.new("UIPadding", scroll)
scrollPad.PaddingTop    = UDim.new(0, 10)
scrollPad.PaddingBottom = UDim.new(0, 10)
scrollPad.PaddingLeft   = UDim.new(0, 10)
scrollPad.PaddingRight  = UDim.new(0, 14)

-- ============================================================
-- CARD FACTORY
-- ============================================================
local function makeCard(order, height)
    local card = Instance.new("Frame", scroll)
    card.Size = UDim2.new(1, 0, 0, height or 80)
    card.BackgroundColor3 = T.BgMid
    card.BorderSizePixel = 0
    card.LayoutOrder = order
    card.ZIndex = 8
    mkCorner(card, 12)
    mkStroke(card, T.PrimaryDark, 0.5)
    local pad = Instance.new("UIPadding", card)
    pad.PaddingTop    = UDim.new(0, 10)
    pad.PaddingBottom = UDim.new(0, 10)
    pad.PaddingLeft   = UDim.new(0, 12)
    pad.PaddingRight  = UDim.new(0, 12)
    return card
end

local function cardTitle(card, icon, text, zindex)
    local row = Instance.new("Frame", card)
    row.Size = UDim2.new(1, 0, 0, 18)
    row.BackgroundTransparency = 1
    row.ZIndex = zindex or 9

    local ico = Instance.new("ImageLabel", row)
    ico.Image = icon
    ico.ImageColor3 = T.Accent
    ico.Size = UDim2.new(0, 14, 0, 14)
    ico.Position = UDim2.new(0, 0, 0.5, -7)
    ico.BackgroundTransparency = 1
    ico.ZIndex = zindex or 9

    local lbl = Instance.new("TextLabel", row)
    lbl.Text = text
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextColor3 = T.Accent
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, -20, 1, 0)
    lbl.Position = UDim2.new(0, 20, 0, 0)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = zindex or 9
    return row
end

-- ============================================================
-- COPY BUTTON FACTORY
-- ============================================================
local function makeCopyBtn(parent, getValue, xPos, yPos, zindex)
    local btn = Instance.new("TextButton", parent)
    btn.Text = "⎘ Copy"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.TextColor3 = T.Text
    btn.BackgroundColor3 = T.PrimaryDark
    btn.BorderSizePixel = 0
    btn.Size = UDim2.new(0, 58, 0, 22)
    btn.Position = xPos or UDim2.new(1, -58, 0, 0)
    btn.ZIndex = zindex or 10
    mkCorner(btn, 6)

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = T.Primary}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = T.PrimaryDark}):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        local val = getValue()
        if val and val ~= "" and val ~= "N/A" and val ~= "Loading..." then
            setclipboard(val)
            btn.Text = "✓ Copied"
            btn.BackgroundColor3 = T.Success
            task.delay(1.5, function()
                btn.Text = "⎘ Copy"
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = T.PrimaryDark}):Play()
            end)
            Notify("Copied", "Copied to clipboard!", 2)
        else
            Notify("Warning", "Data belum tersedia!", 2)
        end
    end)
    return btn
end

-- ============================================================
-- STATUS INDICATOR DOT
-- ============================================================
local function makeStatusDot(parent, pos)
    local dot = Instance.new("Frame", parent)
    dot.Size = UDim2.new(0, 8, 0, 8)
    dot.Position = pos or UDim2.new(0, 0, 0.5, -4)
    dot.BackgroundColor3 = T.Success
    dot.BorderSizePixel = 0
    dot.ZIndex = 10
    mkCorner(dot, 4)
    -- Pulse animation
    TweenService:Create(dot, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
        BackgroundTransparency = 0.5
    }):Play()
    return dot
end

-- ============================================================
-- DATA STATE
-- ============================================================
local serverData = {
    jobId       = "Loading...",
    placeId     = "Loading...",
    serverUrl   = "Loading...",
    region      = "Loading...",
    ping        = "Loading...",
    serverAge   = "Loading...",
    playerCount = "Loading...",
    maxPlayers  = "Loading...",
    vipUrl      = "N/A",
    status      = "Online",
    uptime      = 0,
}

-- ============================================================
-- CARD 1 — SERVER INFO
-- ============================================================
local card1 = makeCard(2, 210)
cardTitle(card1, "rbxassetid://7733960981", "SERVER INFO", 9)

local infoLayout = Instance.new("UIListLayout", card1)
infoLayout.SortOrder = Enum.SortOrder.LayoutOrder
infoLayout.Padding = UDim.new(0, 4)

-- Row helper
local function infoRow(card, labelTxt, order, withCopy)
    local row = Instance.new("Frame", card)
    row.Size = UDim2.new(1, 0, 0, 22)
    row.BackgroundTransparency = 1
    row.LayoutOrder = order
    row.ZIndex = 9
    row.ClipsDescendants = false

    local lbl = Instance.new("TextLabel", row)
    lbl.Text = labelTxt
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextColor3 = T.TextMuted
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(0, 80, 1, 0)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 9

    -- Val width depends on whether there's a copy button
    local valRight = withCopy and -150 or -86
    local val = Instance.new("TextLabel", row)
    val.Text = "Loading..."
    val.Font = Enum.Font.Gotham
    val.TextSize = 11
    val.TextColor3 = T.Text
    val.BackgroundTransparency = 1
    val.Size = UDim2.new(1, valRight, 1, 0)
    val.Position = UDim2.new(0, 84, 0, 0)
    val.TextXAlignment = Enum.TextXAlignment.Left
    val.TextTruncate = Enum.TextTruncate.AtEnd
    val.ZIndex = 9

    if withCopy then
        makeCopyBtn(row, function() return val.Text end, UDim2.new(1, -62, 0.5, -11), nil, 10)
    end

    return row, val
end

-- Spacer after title
local sp0 = Instance.new("Frame", card1)
sp0.Size = UDim2.new(1,0,0,2); sp0.BackgroundTransparency=1; sp0.LayoutOrder=0

local _, serverNameVal = infoRow(card1, "Srv Name",  1, false)
local _, jobIdVal      = infoRow(card1, "Job ID",    2, false)
local placeIdRow, placeIdVal = infoRow(card1, "Place ID",  3, true)
local _, regionVal     = infoRow(card1, "Region",    4, false)
local _, pingVal       = infoRow(card1, "Ping",      5, false)
local _, ageVal        = infoRow(card1, "Server Age",6, false)

-- Status row (special)
local statusRow = Instance.new("Frame", card1)
statusRow.Size = UDim2.new(1,0,0,22)
statusRow.BackgroundTransparency = 1
statusRow.LayoutOrder = 7
statusRow.ZIndex = 9

local statusLblKey = Instance.new("TextLabel", statusRow)
statusLblKey.Text = "Status"
statusLblKey.Font = Enum.Font.GothamBold
statusLblKey.TextSize = 11
statusLblKey.TextColor3 = T.TextMuted
statusLblKey.BackgroundTransparency = 1
statusLblKey.Size = UDim2.new(0,90,1,0)
statusLblKey.TextXAlignment = Enum.TextXAlignment.Left
statusLblKey.ZIndex = 9

local statusDot = makeStatusDot(statusRow, UDim2.new(0, 96, 0.5, -4))

local statusValLbl = Instance.new("TextLabel", statusRow)
statusValLbl.Text = "Online"
statusValLbl.Font = Enum.Font.GothamBold
statusValLbl.TextSize = 11
statusValLbl.TextColor3 = T.Success
statusValLbl.BackgroundTransparency = 1
statusValLbl.Size = UDim2.new(1,-110,1,0)
statusValLbl.Position = UDim2.new(0,110,0,0)
statusValLbl.TextXAlignment = Enum.TextXAlignment.Left
statusValLbl.ZIndex = 9

-- ============================================================
-- CARD 2 — PLAYERS
-- ============================================================
local card2 = makeCard(3, 110)

local c2layout = Instance.new("UIListLayout", card2)
c2layout.SortOrder = Enum.SortOrder.LayoutOrder
c2layout.Padding = UDim.new(0, 6)

cardTitle(card2, "rbxassetid://5578470911", "PLAYERS", 9).LayoutOrder = 0

-- Player count fraction
local playerRow = Instance.new("Frame", card2)
playerRow.Size = UDim2.new(1,0,0,28)
playerRow.BackgroundTransparency = 1
playerRow.LayoutOrder = 1
playerRow.ZIndex = 9

local playerCountLbl = Instance.new("TextLabel", playerRow)
playerCountLbl.Text = "0 / 0"
playerCountLbl.Font = Enum.Font.GothamBold
playerCountLbl.TextSize = 22
playerCountLbl.TextColor3 = T.Text
playerCountLbl.BackgroundTransparency = 1
playerCountLbl.Size = UDim2.new(0,120,1,0)
playerCountLbl.TextXAlignment = Enum.TextXAlignment.Left
playerCountLbl.ZIndex = 9

local playerSubLbl = Instance.new("TextLabel", playerRow)
playerSubLbl.Text = "players in server"
playerSubLbl.Font = Enum.Font.Gotham
playerSubLbl.TextSize = 10
playerSubLbl.TextColor3 = T.TextMuted
playerSubLbl.BackgroundTransparency = 1
playerSubLbl.Size = UDim2.new(1,-120,1,0)
playerSubLbl.Position = UDim2.new(0,124,0,0)
playerSubLbl.TextXAlignment = Enum.TextXAlignment.Left
playerSubLbl.ZIndex = 9

-- Player capacity bar
local barBg = Instance.new("Frame", card2)
barBg.Size = UDim2.new(1,0,0,8)
barBg.BackgroundColor3 = T.BgLight
barBg.BorderSizePixel = 0
barBg.LayoutOrder = 2
barBg.ZIndex = 9
mkCorner(barBg, 4)

local barFill = Instance.new("Frame", barBg)
barFill.Size = UDim2.new(0,0,1,0)
barFill.BackgroundColor3 = T.Primary
barFill.BorderSizePixel = 0
barFill.ZIndex = 10
mkCorner(barFill, 4)

-- Player list names (scrollable single line)
local playerNamesLbl = Instance.new("TextLabel", card2)
playerNamesLbl.Text = "Loading players..."
playerNamesLbl.Font = Enum.Font.Gotham
playerNamesLbl.TextSize = 10
playerNamesLbl.TextColor3 = T.TextMuted
playerNamesLbl.BackgroundTransparency = 1
playerNamesLbl.Size = UDim2.new(1,0,0,14)
playerNamesLbl.TextXAlignment = Enum.TextXAlignment.Left
playerNamesLbl.TextTruncate = Enum.TextTruncate.AtEnd
playerNamesLbl.LayoutOrder = 3
playerNamesLbl.ZIndex = 9

-- ============================================================
-- CARD 3 — SERVER URL
-- ============================================================
local card3 = makeCard(4, 100)

local c3layout = Instance.new("UIListLayout", card3)
c3layout.SortOrder = Enum.SortOrder.LayoutOrder
c3layout.Padding = UDim.new(0, 6)

cardTitle(card3, "rbxassetid://98908450631624", "SERVER URL", 9).LayoutOrder = 0

-- Public URL row
local pubRow = Instance.new("Frame", card3)
pubRow.Size = UDim2.new(1,0,0,26)
pubRow.BackgroundTransparency = 1
pubRow.LayoutOrder = 1
pubRow.ZIndex = 9

local pubLblKey = Instance.new("TextLabel", pubRow)
pubLblKey.Text = "Public"
pubLblKey.Font = Enum.Font.GothamBold
pubLblKey.TextSize = 11
pubLblKey.TextColor3 = T.TextMuted
pubLblKey.BackgroundTransparency = 1
pubLblKey.Size = UDim2.new(0,50,1,0)
pubLblKey.TextXAlignment = Enum.TextXAlignment.Left
pubLblKey.ZIndex = 9

local pubUrlBg = Instance.new("Frame", pubRow)
pubUrlBg.Size = UDim2.new(1,-120,1,0)
pubUrlBg.Position = UDim2.new(0,54,0,0)
pubUrlBg.BackgroundColor3 = T.BgCard
pubUrlBg.BorderSizePixel = 0
pubUrlBg.ZIndex = 9
mkCorner(pubUrlBg, 5)

local pubUrlLbl = Instance.new("TextLabel", pubUrlBg)
pubUrlLbl.Text = "Loading..."
pubUrlLbl.Font = Enum.Font.Gotham
pubUrlLbl.TextSize = 10
pubUrlLbl.TextColor3 = T.Info
pubUrlLbl.BackgroundTransparency = 1
pubUrlLbl.Size = UDim2.new(1,-8,1,0)
pubUrlLbl.Position = UDim2.new(0,6,0,0)
pubUrlLbl.TextXAlignment = Enum.TextXAlignment.Left
pubUrlLbl.TextTruncate = Enum.TextTruncate.AtEnd
pubUrlLbl.ZIndex = 10

makeCopyBtn(pubRow, function() return pubUrlLbl.Text end,
    UDim2.new(1,-62,0.5,-11), nil, 10)

-- Private (VIP) URL row
local vipRow = Instance.new("Frame", card3)
vipRow.Size = UDim2.new(1,0,0,26)
vipRow.BackgroundTransparency = 1
vipRow.LayoutOrder = 2
vipRow.ZIndex = 9

local vipLblKey = Instance.new("TextLabel", vipRow)
vipLblKey.Text = "Private"
vipLblKey.Font = Enum.Font.GothamBold
vipLblKey.TextSize = 11
vipLblKey.TextColor3 = T.TextMuted
vipLblKey.BackgroundTransparency = 1
vipLblKey.Size = UDim2.new(0,50,1,0)
vipLblKey.TextXAlignment = Enum.TextXAlignment.Left
vipLblKey.ZIndex = 9

local vipUrlBg = Instance.new("Frame", vipRow)
vipUrlBg.Size = UDim2.new(1,-120,1,0)
vipUrlBg.Position = UDim2.new(0,54,0,0)
vipUrlBg.BackgroundColor3 = T.BgCard
vipUrlBg.BorderSizePixel = 0
vipUrlBg.ZIndex = 9
mkCorner(vipUrlBg, 5)

local vipUrlLbl = Instance.new("TextLabel", vipUrlBg)
vipUrlLbl.Text = "N/A"
vipUrlLbl.Font = Enum.Font.Gotham
vipUrlLbl.TextSize = 10
vipUrlLbl.TextColor3 = T.TextMuted
vipUrlLbl.BackgroundTransparency = 1
vipUrlLbl.Size = UDim2.new(1,-8,1,0)
vipUrlLbl.Position = UDim2.new(0,6,0,0)
vipUrlLbl.TextXAlignment = Enum.TextXAlignment.Left
vipUrlLbl.TextTruncate = Enum.TextTruncate.AtEnd
vipUrlLbl.ZIndex = 10

makeCopyBtn(vipRow, function() return vipUrlLbl.Text end,
    UDim2.new(1,-62,0.5,-11), nil, 10)

-- ============================================================
-- CARD 4 — JOIN SERVER BY URL
-- ============================================================
local card4 = makeCard(5, 120)

local c4layout = Instance.new("UIListLayout", card4)
c4layout.SortOrder = Enum.SortOrder.LayoutOrder
c4layout.Padding = UDim.new(0, 8)

cardTitle(card4, "rbxassetid://7733720784", "JOIN SERVER", 9).LayoutOrder = 0

-- TextBox row
local joinRow = Instance.new("Frame", card4)
joinRow.Size = UDim2.new(1,0,0,30)
joinRow.BackgroundTransparency = 1
joinRow.LayoutOrder = 1
joinRow.ZIndex = 9

local joinBox = Instance.new("TextBox", joinRow)
joinBox.Text = ""
joinBox.PlaceholderText = "Paste server URL here..."
joinBox.Font = Enum.Font.Gotham
joinBox.TextSize = 11
joinBox.TextColor3 = T.Text
joinBox.PlaceholderColor3 = T.TextMuted
joinBox.BackgroundColor3 = T.BgCard
joinBox.BorderSizePixel = 0
joinBox.ClearTextOnFocus = false
joinBox.Size = UDim2.new(1,-68,1,0)
joinBox.ZIndex = 10
mkCorner(joinBox, 7)
mkStroke(joinBox, T.PrimaryDark, 0.4)

joinBox.Focused:Connect(function()
    TweenService:Create(joinBox, TweenInfo.new(0.2), {BackgroundColor3 = T.BgLight}):Play()
    mkStroke(joinBox, T.Primary, 0.2)
end)
joinBox.FocusLost:Connect(function()
    TweenService:Create(joinBox, TweenInfo.new(0.2), {BackgroundColor3 = T.BgCard}):Play()
end)

-- Paste button
local pasteBtn = Instance.new("TextButton", joinRow)
pasteBtn.Text = "⎘ Paste"
pasteBtn.Font = Enum.Font.GothamBold
pasteBtn.TextSize = 10
pasteBtn.TextColor3 = T.Text
pasteBtn.BackgroundColor3 = T.BgLight
pasteBtn.BorderSizePixel = 0
pasteBtn.Size = UDim2.new(0,58,1,0)
pasteBtn.Position = UDim2.new(1,-58,0,0)
pasteBtn.ZIndex = 10
mkCorner(pasteBtn, 7)

pasteBtn.MouseEnter:Connect(function()
    TweenService:Create(pasteBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.BgCard}):Play()
end)
pasteBtn.MouseLeave:Connect(function()
    TweenService:Create(pasteBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.BgLight}):Play()
end)
pasteBtn.MouseButton1Click:Connect(function()
    local ok, clip = pcall(function() return getclipboard() end)
    if ok and clip and clip ~= "" then
        joinBox.Text = clip
    else
        Notify("Warning", "Clipboard kosong!", 2)
    end
end)

-- Join button row
local joinBtnRow = Instance.new("Frame", card4)
joinBtnRow.Size = UDim2.new(1,0,0,30)
joinBtnRow.BackgroundTransparency = 1
joinBtnRow.LayoutOrder = 2
joinBtnRow.ZIndex = 9

local joinBtn = Instance.new("TextButton", joinBtnRow)
joinBtn.Text = "⟶  Join Server"
joinBtn.Font = Enum.Font.GothamBold
joinBtn.TextSize = 12
joinBtn.TextColor3 = T.Text
joinBtn.BackgroundColor3 = T.Primary
joinBtn.BorderSizePixel = 0
joinBtn.Size = UDim2.new(1,0,1,0)
joinBtn.ZIndex = 10
mkCorner(joinBtn, 8)

joinBtn.MouseEnter:Connect(function()
    TweenService:Create(joinBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.PrimaryLight}):Play()
end)
joinBtn.MouseLeave:Connect(function()
    TweenService:Create(joinBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.Primary}):Play()
end)

-- Parse URL dan join
local function parseJobIdFromUrl(url)
    -- Format: https://www.roblox.com/games/PLACEID?privateServerLinkCode=XXX
    -- atau:   https://www.roblox.com/share?code=XXX&type=Server
    -- atau langsung jobId string
    if url:match("privateServerLinkCode=") then
        return nil, url  -- VIP server, teleport via URL langsung
    end
    local jobId = url:match("gameInstanceId=([%w%-]+)")
    if jobId then return jobId, nil end
    -- Kalau pure jobId (UUID format)
    if url:match("^[%w%-]+$") and #url > 20 then
        return url, nil
    end
    return nil, nil
end

joinBtn.MouseButton1Click:Connect(function()
    local url = joinBox.Text:gsub("^%s+", ""):gsub("%s+$", "")
    if url == "" then
        Notify("Warning", "Masukkan URL dulu!", 2)
        return
    end

    joinBtn.Text = "Joining..."
    TweenService:Create(joinBtn, TweenInfo.new(0.1), {BackgroundColor3 = T.PrimaryDark}):Play()

    local placeId = game.PlaceId
    local jobId, vipUrl = parseJobIdFromUrl(url)

    local ok, err = pcall(function()
        if vipUrl then
            -- VIP / private server
            TeleportService:TeleportToPrivateServer(placeId, vipUrl, {Players.LocalPlayer})
        elseif jobId then
            -- Public server via jobId
            TeleportService:TeleportToPlaceInstance(placeId, jobId, Players.LocalPlayer)
        else
            -- Coba parse place id dari URL
            local pid = url:match("/games/(%d+)")
            if pid then
                TeleportService:Teleport(tonumber(pid), Players.LocalPlayer)
            else
                error("Format URL tidak dikenali")
            end
        end
    end)

    if ok then
        Notify("Loaded", "Joining server...", 3)
    else
        Notify("Error", "Gagal join: " .. tostring(err):sub(1,60), 4)
        joinBtn.Text = "⟶  Join Server"
        TweenService:Create(joinBtn, TweenInfo.new(0.2), {BackgroundColor3 = T.Primary}):Play()
    end
end)

-- ============================================================
-- CARD 5 — EXTRA INFO
-- ============================================================
local card5 = makeCard(6, 130)

local c5layout = Instance.new("UIListLayout", card5)
c5layout.SortOrder = Enum.SortOrder.LayoutOrder
c5layout.Padding = UDim.new(0, 4)

cardTitle(card5, "rbxassetid://134341920489415", "EXTRA", 9).LayoutOrder = 0

local _, uptimeVal   = infoRow(card5, "Uptime",      1, false)
local _, placeVerVal = infoRow(card5, "Place Ver",   2, false)
local _, gameNameVal = infoRow(card5, "Game Name",   3, false)
local _, creatorVal  = infoRow(card5, "Creator",     4, false)
local _, serverIpVal = infoRow(card5, "Server IP",   5, false)

-- ============================================================
-- CARD 6 — MAP / GAME STATUS
-- ============================================================
local card6 = makeCard(7, 160)

local c6layout = Instance.new("UIListLayout", card6)
c6layout.SortOrder = Enum.SortOrder.LayoutOrder
c6layout.Padding = UDim.new(0, 4)

cardTitle(card6, "rbxassetid://7733960981", "MAP & GAME STATUS", 9).LayoutOrder = 0

local _, mapNameVal     = infoRow(card6, "Map / Place",  1, false)
local _, lightingVal    = infoRow(card6, "Time of Day",  2, false)
local _, weatherVal     = infoRow(card6, "Atmosphere",   3, false)
local _, gravityVal     = infoRow(card6, "Gravity",      4, false)
local _, ambientVal     = infoRow(card6, "Ambient",      5, false)
local _, streamingVal   = infoRow(card6, "Streaming",    6, false)

-- Populate static map/game data immediately (no HTTP needed)
do
    local lighting = game:GetService("Lighting")
    local workspace = game:GetService("Workspace")

    mapNameVal.Text   = game:GetService("MarketplaceService") and game.Name or game.Name
    lightingVal.Text  = tostring(lighting.TimeOfDay)
    gravityVal.Text   = tostring(workspace.Gravity) .. " studs/s²"
    streamingVal.Text = workspace.StreamingEnabled and "Enabled" or "Disabled"
    streamingVal.TextColor3 = workspace.StreamingEnabled and T.Warning or T.Success

    -- Atmosphere check
    local atmo = lighting:FindFirstChildOfClass("Atmosphere")
    weatherVal.Text = atmo and string.format("Density %.2f", atmo.Density) or "None"

    -- Ambient color as hex
    local a = lighting.Ambient
    ambientVal.Text = string.format("RGB(%d,%d,%d)",
        math.floor(a.R*255), math.floor(a.G*255), math.floor(a.B*255))
end

-- ============================================================
-- CARD 7 — REJOIN
-- ============================================================
local card7 = makeCard(1, 105)

local c7layout = Instance.new("UIListLayout", card7)
c7layout.SortOrder = Enum.SortOrder.LayoutOrder
c7layout.Padding = UDim.new(0, 8)

cardTitle(card7, "rbxassetid://7733720784", "REJOIN", 9).LayoutOrder = 0

-- Info text
local rejoinInfo = Instance.new("TextLabel", card7)
rejoinInfo.Text = "Rejoin to same server or respawn to a new one"
rejoinInfo.Font = Enum.Font.Gotham
rejoinInfo.TextSize = 10
rejoinInfo.TextColor3 = T.TextMuted
rejoinInfo.BackgroundTransparency = 1
rejoinInfo.Size = UDim2.new(1,0,0,14)
rejoinInfo.TextXAlignment = Enum.TextXAlignment.Left
rejoinInfo.TextWrapped = true
rejoinInfo.ZIndex = 9
rejoinInfo.LayoutOrder = 1

-- Button row
local rejoinBtnRow = Instance.new("Frame", card7)
rejoinBtnRow.Size = UDim2.new(1,0,0,32)
rejoinBtnRow.BackgroundTransparency = 1
rejoinBtnRow.LayoutOrder = 2
rejoinBtnRow.ZIndex = 9

local rejoinSameBtn = Instance.new("TextButton", rejoinBtnRow)
rejoinSameBtn.Text = "↺  Same Server"
rejoinSameBtn.Font = Enum.Font.GothamBold
rejoinSameBtn.TextSize = 11
rejoinSameBtn.TextColor3 = T.Text
rejoinSameBtn.BackgroundColor3 = T.PrimaryDark
rejoinSameBtn.BorderSizePixel = 0
rejoinSameBtn.Size = UDim2.new(0.48, 0, 1, 0)
rejoinSameBtn.ZIndex = 10
mkCorner(rejoinSameBtn, 8)

local rejoinNewBtn = Instance.new("TextButton", rejoinBtnRow)
rejoinNewBtn.Text = "⟶  New Server"
rejoinNewBtn.Font = Enum.Font.GothamBold
rejoinNewBtn.TextSize = 11
rejoinNewBtn.TextColor3 = T.Text
rejoinNewBtn.BackgroundColor3 = T.BgLight
rejoinNewBtn.BorderSizePixel = 0
rejoinNewBtn.Size = UDim2.new(0.48, 0, 1, 0)
rejoinNewBtn.Position = UDim2.new(0.52, 0, 0, 0)
rejoinNewBtn.ZIndex = 10
mkCorner(rejoinNewBtn, 8)
mkStroke(rejoinNewBtn, T.PrimaryDark, 0.4)

-- Hover
for _, btn in ipairs({rejoinSameBtn, rejoinNewBtn}) do
    local base = btn.BackgroundColor3
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = T.Primary}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = base}):Play()
    end)
end

-- Rejoin same server (teleport ke jobId yang sama)
rejoinSameBtn.MouseButton1Click:Connect(function()
    local jobId = game.JobId
    if jobId == "" then
        Notify("Warning", "Tidak bisa rejoin di Studio!", 3)
        return
    end
    rejoinSameBtn.Text = "Rejoining..."
    Notify("Loaded", "Rejoining same server...", 3)
    pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, jobId, Players.LocalPlayer)
    end)
    task.delay(3, function()
        rejoinSameBtn.Text = "↺  Same Server"
    end)
end)

-- Rejoin new server (teleport ke game, Roblox pilihkan server baru)
rejoinNewBtn.MouseButton1Click:Connect(function()
    rejoinNewBtn.Text = "Joining..."
    Notify("Loaded", "Joining new server...", 3)
    pcall(function()
        TeleportService:Teleport(game.PlaceId, Players.LocalPlayer)
    end)
    task.delay(3, function()
        rejoinNewBtn.Text = "⟶  New Server"
    end)
end)

-- ============================================================
-- CARD 8 — JOIN LOW PLAYER SERVER
-- ============================================================
local card8 = makeCard(8, 120)

local c8layout = Instance.new("UIListLayout", card8)
c8layout.SortOrder = Enum.SortOrder.LayoutOrder
c8layout.Padding = UDim.new(0, 8)

cardTitle(card8, "rbxassetid://5578470911", "JOIN LOW PLAYER", 9).LayoutOrder = 0

-- Info text
local lowInfo = Instance.new("TextLabel", card8)
lowInfo.Text = "Find and join a server with the fewest players"
lowInfo.Font = Enum.Font.Gotham
lowInfo.TextSize = 10
lowInfo.TextColor3 = T.TextMuted
lowInfo.BackgroundTransparency = 1
lowInfo.Size = UDim2.new(1, 0, 0, 14)
lowInfo.TextXAlignment = Enum.TextXAlignment.Left
lowInfo.TextWrapped = true
lowInfo.ZIndex = 9
lowInfo.LayoutOrder = 1

-- Status label
local lowStatusLbl = Instance.new("TextLabel", card8)
lowStatusLbl.Text = ""
lowStatusLbl.Font = Enum.Font.Gotham
lowStatusLbl.TextSize = 10
lowStatusLbl.TextColor3 = T.TextMuted
lowStatusLbl.BackgroundTransparency = 1
lowStatusLbl.Size = UDim2.new(1, 0, 0, 14)
lowStatusLbl.TextXAlignment = Enum.TextXAlignment.Left
lowStatusLbl.ZIndex = 9
lowStatusLbl.LayoutOrder = 2

-- Button row
local lowBtnRow = Instance.new("Frame", card8)
lowBtnRow.Size = UDim2.new(1, 0, 0, 32)
lowBtnRow.BackgroundTransparency = 1
lowBtnRow.LayoutOrder = 3
lowBtnRow.ZIndex = 9

local joinLowBtn = Instance.new("TextButton", lowBtnRow)
joinLowBtn.Text = "🔍  Find Low Player Server"
joinLowBtn.Font = Enum.Font.GothamBold
joinLowBtn.TextSize = 11
joinLowBtn.TextColor3 = T.Text
joinLowBtn.BackgroundColor3 = T.Primary
joinLowBtn.BorderSizePixel = 0
joinLowBtn.Size = UDim2.new(1, 0, 1, 0)
joinLowBtn.ZIndex = 10
mkCorner(joinLowBtn, 8)
mkStroke(joinLowBtn, T.PrimaryDark, 0.4)

joinLowBtn.MouseEnter:Connect(function()
    TweenService:Create(joinLowBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.PrimaryLight}):Play()
end)
joinLowBtn.MouseLeave:Connect(function()
    TweenService:Create(joinLowBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.Primary}):Play()
end)

joinLowBtn.MouseButton1Click:Connect(function()
    joinLowBtn.Text = "🔍  Searching..."
    TweenService:Create(joinLowBtn, TweenInfo.new(0.1), {BackgroundColor3 = T.PrimaryDark}):Play()
    lowStatusLbl.Text = "Fetching server list..."
    lowStatusLbl.TextColor3 = T.TextMuted

    coroutine.wrap(function()
        local placeId = game.PlaceId
        local cursor = ""
        local bestJobId = nil
        local bestCount = math.huge
        local found = false

        -- Fetch up to 3 pages of servers to find the lowest
        for page = 1, 3 do
            local url = string.format(
                "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=25%s",
                placeId,
                cursor ~= "" and ("&cursor=" .. cursor) or ""
            )
            local ok, res = pcall(function()
                return HttpService:RequestAsync({Url = url, Method = "GET"})
            end)

            if ok and res and res.StatusCode == 200 then
                local ok2, data = pcall(function()
                    return HttpService:JSONDecode(res.Body)
                end)
                if ok2 and data and data.data then
                    for _, srv in ipairs(data.data) do
                        local count = srv.playing or 0
                        local maxP  = srv.maxPlayers or 1
                        -- Skip full or current server, prefer servers with players > 0
                        if count < bestCount and srv.id ~= game.JobId and count < maxP then
                            bestCount  = count
                            bestJobId  = srv.id
                            found = true
                        end
                    end
                    lowStatusLbl.Text = "Scanned page " .. page .. "..."
                    if data.nextPageCursor and data.nextPageCursor ~= "" then
                        cursor = data.nextPageCursor
                    else
                        break
                    end
                else
                    break
                end
            else
                lowStatusLbl.Text = "HTTP failed (HttpService off?)"
                lowStatusLbl.TextColor3 = T.Error
                break
            end
        end

        if found and bestJobId then
            lowStatusLbl.Text = "Found! Players: " .. bestCount .. " — Joining..."
            lowStatusLbl.TextColor3 = T.Success
            Notify("Loaded", "Joining low player server (" .. bestCount .. " players)...", 3)
            task.wait(0.5)
            pcall(function()
                TeleportService:TeleportToPlaceInstance(placeId, bestJobId, Players.LocalPlayer)
            end)
        else
            lowStatusLbl.Text = "No suitable server found."
            lowStatusLbl.TextColor3 = T.Warning
            Notify("Warning", "Tidak ada server yang ditemukan!", 3)
        end

        task.delay(2, function()
            joinLowBtn.Text = "🔍  Find Low Player Server"
            TweenService:Create(joinLowBtn, TweenInfo.new(0.2), {BackgroundColor3 = T.Primary}):Play()
        end)
    end)()
end)

-- ============================================================
-- REFRESH BUTTON
-- ============================================================
local refreshCard = makeCard(9, 38)
refreshCard.BackgroundTransparency = 1

local refreshBtn = Instance.new("TextButton", refreshCard)
refreshBtn.Text = "↺  Refresh Data"
refreshBtn.Font = Enum.Font.GothamBold
refreshBtn.TextSize = 12
refreshBtn.TextColor3 = T.Text
refreshBtn.BackgroundColor3 = T.BgMid
refreshBtn.BorderSizePixel = 0
refreshBtn.Size = UDim2.new(1,0,1,0)
refreshBtn.ZIndex = 9
mkCorner(refreshBtn, 10)
mkStroke(refreshBtn, T.PrimaryDark, 0.4)

refreshBtn.MouseEnter:Connect(function()
    TweenService:Create(refreshBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.BgLight}):Play()
end)
refreshBtn.MouseLeave:Connect(function()
    TweenService:Create(refreshBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.BgMid}):Play()
end)

-- ============================================================
-- DATA FETCHER
-- ============================================================
local uptimeStart = os.clock()
local isRefreshing = false

local function formatUptime(seconds)
    local s = math.floor(seconds)
    local h = math.floor(s/3600)
    local m = math.floor((s%3600)/60)
    local sec = s%60
    if h > 0 then
        return string.format("%dh %dm %ds", h, m, sec)
    elseif m > 0 then
        return string.format("%dm %ds", m, sec)
    else
        return string.format("%ds", sec)
    end
end

local function refreshData()
    if isRefreshing then return end
    isRefreshing = true
    refreshBtn.Text = "↺  Refreshing..."
    TweenService:Create(refreshBtn, TweenInfo.new(0.1), {BackgroundColor3 = T.PrimaryDark}):Play()

    coroutine.wrap(function()
        -- Basic data (instant, no HTTP needed)
        local jobId    = game.JobId
        local placeId  = tostring(game.PlaceId)
        local maxP     = Players.MaxPlayers
        local curP     = #Players:GetPlayers()
        local placeVer = tostring(game.PlaceVersion)

        jobIdVal.Text   = jobId ~= "" and jobId or "Studio/Unknown"
        placeIdVal.Text = placeId
        placeVerVal.Text = placeVer
        gameNameVal.Text = game.Name ~= "" and game.Name or "Unknown"
        creatorVal.Text  = game.CreatorId ~= 0 and tostring(game.CreatorId) or "Unknown"

        -- Server name (try from MarketplaceService)
        local snOk, snData = pcall(function()
            return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
        end)
        serverNameVal.Text = (snOk and snData and snData.Name) and snData.Name or game.Name

        -- Player count & bar
        playerCountLbl.Text = curP .. " / " .. maxP
        local ratio = maxP > 0 and (curP / maxP) or 0
        TweenService:Create(barFill, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(ratio, 0, 1, 0)
        }):Play()
        barFill.BackgroundColor3 = ratio >= 0.9 and T.Error or ratio >= 0.6 and T.Warning or T.Success

        -- Player names
        local names = {}
        for _, p in ipairs(Players:GetPlayers()) do
            table.insert(names, p.Name)
        end
        playerNamesLbl.Text = #names > 0 and table.concat(names, ", ") or "No players"

        -- Public server URL
        local pubUrl = string.format(
            "https://www.roblox.com/games/%s?gameInstanceId=%s",
            placeId, jobId
        )
        pubUrlLbl.Text = pubUrl
        pubUrlLbl.TextColor3 = T.Info

        -- Server URL (short display)
        serverData.serverUrl = pubUrl
        serverData.jobId     = jobId

        -- Ping via HTTP request timing
        local pingStart = os.clock()
        local pingOk = pcall(function()
            HttpService:RequestAsync({Url="https://www.roblox.com", Method="GET"})
        end)
        local pingMs = math.floor((os.clock() - pingStart) * 1000)
        pingVal.Text = pingOk and (pingMs .. " ms") or "N/A"
        pingVal.TextColor3 = pingMs < 80 and T.Success or pingMs < 150 and T.Warning or T.Error

        -- Region via IP geolocation
        local regionOk, regionRes = pcall(function()
            return HttpService:RequestAsync({Url="https://ipapi.co/json/", Method="GET"})
        end)
        if regionOk and regionRes and regionRes.StatusCode == 200 then
            local ok2, data = pcall(function()
                return HttpService:JSONDecode(regionRes.Body)
            end)
            if ok2 and data then
                regionVal.Text   = (data.city or "?") .. ", " .. (data.country_name or "?")
                serverIpVal.Text = data.ip or "Hidden"
            end
        else
            regionVal.Text   = "N/A"
            serverIpVal.Text = "N/A"
        end

        -- Server age (estimated from uptime)
        local age = os.clock() - uptimeStart
        ageVal.Text = formatUptime(age) .. " ago"

        -- VIP server check
        local vipCode = game:GetService("TeleportService"):GetLocalPlayerTeleportData()
        if vipCode and type(vipCode) == "table" and vipCode.privateServerLinkCode then
            local code = vipCode.privateServerLinkCode
            local vUrl = "https://www.roblox.com/games/" .. placeId .. "?privateServerLinkCode=" .. code
            vipUrlLbl.Text = vUrl
            vipUrlLbl.TextColor3 = T.Accent
        else
            vipUrlLbl.Text = "Not a VIP server"
            vipUrlLbl.TextColor3 = T.TextMuted
        end

        -- Status
        statusValLbl.Text = "Online"
        statusValLbl.TextColor3 = T.Success
        statusDot.BackgroundColor3 = T.Success

        isRefreshing = false
        refreshBtn.Text = "↺  Refresh Data"
        TweenService:Create(refreshBtn, TweenInfo.new(0.2), {BackgroundColor3 = T.BgMid}):Play()
        Notify("Loaded", "Server data refreshed!", 2)
    end)()
end

refreshBtn.MouseButton1Click:Connect(refreshData)

-- ============================================================
-- LIVE UPTIME + PLAYER COUNT UPDATER
-- ============================================================
local lastLiveUpdate = 0
RunService.RenderStepped:Connect(function()
    local now = os.clock()
    if now - lastLiveUpdate >= 1 then
        lastLiveUpdate = now

        -- Uptime
        local elapsed = now - uptimeStart
        uptimeVal.Text = formatUptime(elapsed)

        -- Live player count
        local curP = #Players:GetPlayers()
        local maxP = Players.MaxPlayers
        playerCountLbl.Text = curP .. " / " .. maxP

        local ratio = maxP > 0 and (curP / maxP) or 0
        barFill.BackgroundColor3 = ratio >= 0.9 and T.Error or ratio >= 0.6 and T.Warning or T.Success

        -- Live player names
        local names = {}
        for _, p in ipairs(Players:GetPlayers()) do table.insert(names, p.Name) end
        playerNamesLbl.Text = #names > 0 and table.concat(names, ", ") or "No players"

        -- Server age
        ageVal.Text = formatUptime(elapsed) .. " (this session)"
    end
end)

-- ============================================================
-- INIT — auto refresh saat pertama dibuka
-- ============================================================
task.spawn(refreshData)

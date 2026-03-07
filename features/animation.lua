-- ============================================================
--  SAN HUB — features/animation.lua
--  Di-load oleh main.lua secara lazy (pas menu Animation diklik)
--  Komunikasi dengan hub lewat _G.SanHub
-- ============================================================

local TweenService = game:GetService("TweenService")
local HttpService  = game:GetService("HttpService")
local Players      = game:GetService("Players")

-- Ambil dari hub
local Notify      = _G.SanHub.Notify
local T           = _G.SanHub.Theme
local parentFrame = _G.SanHub.CurrentFrame  -- Frame dari contentArea hub

if not parentFrame or not Notify or not T then
    warn("[SanHub/Animation] _G.SanHub tidak lengkap!")
    return
end

-- ============================================================
-- R15 CHECK
-- ============================================================
if not game.Players.LocalPlayer.Character
    or game.Players.LocalPlayer.Character:WaitForChild("Humanoid").RigType ~= Enum.HumanoidRigType.R15 then
    Notify("Error", "You're on R6! Change to R15!", 5)
    return
end

-- ============================================================
-- FOLDER & FILE PATHS
-- ============================================================
local FOLDER        = "SanVerificator"
local FILE_PRESET   = FOLDER .. "/UserPreset.json"
local FILE_DATABASE = FOLDER .. "/AnimDatabase.json"

if not isfolder(FOLDER) then
    makefolder(FOLDER)
end

-- ============================================================
-- CATEGORY ICONS
-- ============================================================
local CategoryIcons = {
    Idle     = "rbxassetid://129775391836345",
    Walk     = "rbxassetid://100773799716592",
    Run      = "rbxassetid://134314542459823",
    Jump     = "rbxassetid://81557655286768",
    Fall     = "rbxassetid://106215247611433",
    Climb    = "rbxassetid://74367187017671",
    Swim     = "rbxassetid://118863319136660",
    SwimIdle = "rbxassetid://84289638742203",
}

-- ============================================================
-- STATE
-- ============================================================
local OriginalAnimations = {
    Idle={}, Walk={}, Run={}, Jump={},
    Fall={}, Climb={}, Swim={}, SwimIdle={},
}
local Animations      = OriginalAnimations
local fileAnimations  = {}
local lastAnimations  = {}
local currentCategory = "Idle"
local categoryButtons = {}

-- ============================================================
-- HELPER
-- ============================================================
local function corner(p, r)
    Instance.new("UICorner", p).CornerRadius = UDim.new(0, r or 10)
end

local function addGlow(parent, color, transparency)
    local stroke = Instance.new("UIStroke", parent)
    stroke.Color = color or T.Primary
    stroke.Thickness = 1.5
    stroke.Transparency = transparency or 0.4
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return stroke
end

-- ============================================================
-- ANIMATION CORE FUNCTIONS
-- ============================================================
local function freeze()
    local char = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
    local hum  = char:WaitForChild("Humanoid")
    hum.WalkSpeed = 0
    hum.JumpPower = 0
end

local function unfreeze()
    local char = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
    local hum  = char:WaitForChild("Humanoid")
    hum.WalkSpeed = 16
    hum.JumpPower = 50
end

local function StopAnim()
    local char = Players.LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        for _, track in pairs(hum:GetPlayingAnimationTracks()) do
            track:Stop()
        end
    end
end

local function setAnimation(animType, animName)
    freeze()

    local char     = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid")
    local animate  = char:WaitForChild("Animate")

    if not Animations[animType] or not Animations[animType][animName] then
        Notify("Error", "Animation not found!", 3)
        unfreeze()
        return
    end

    local animData   = Animations[animType][animName]
    local animFolder = animate:FindFirstChild(animType:lower())

    if not animFolder then
        Notify("Error", animType .. " folder not found!", 3)
        unfreeze()
        return
    end

    for _, child in ipairs(animFolder:GetChildren()) do
        if child:IsA("Animation") then child:Destroy() end
    end

    if type(animData) == "table" then
        for i, id in ipairs(animData) do
            local anim = Instance.new("Animation")
            anim.Name  = animType .. tostring(i)
            anim.AnimationId = "rbxassetid://" .. tostring(id)
            anim.Parent = animFolder
        end
    else
        local anim = Instance.new("Animation")
        anim.Name  = animType .. "Anim"
        anim.AnimationId = "rbxassetid://" .. tostring(animData)
        anim.Parent = animFolder
    end

    lastAnimations[animType] = animName

    local saveData = {}
    for k, v in pairs(lastAnimations) do saveData[k] = v end

    local ok, err = pcall(function()
        writefile(FILE_PRESET, HttpService:JSONEncode(saveData))
    end)
    if not ok then warn("Failed to save:", err) end

    StopAnim()
    humanoid:ChangeState(Enum.HumanoidStateType.Landed)
    wait(0.1)
    unfreeze()
end

-- ============================================================
-- BUILD UI (semua di dalam parentFrame yang dikasih hub)
-- ============================================================

-- Search bar
local searchContainer = Instance.new("Frame", parentFrame)
searchContainer.Size  = UDim2.new(1, -12, 0, 36)
searchContainer.Position = UDim2.new(0, 6, 0, 6)
searchContainer.BackgroundColor3 = T.BgCard
searchContainer.BorderSizePixel  = 0
searchContainer.ZIndex = 8
corner(searchContainer, 10)
addGlow(searchContainer, T.PrimaryDark, 0.5)

local searchIcon = Instance.new("ImageLabel", searchContainer)
searchIcon.Image = "rbxassetid://98908450631624"
searchIcon.ImageColor3 = T.TextMuted
searchIcon.Size  = UDim2.new(0, 18, 0, 18)
searchIcon.Position = UDim2.new(0, 10, 0.5, -9)
searchIcon.BackgroundTransparency = 1
searchIcon.ZIndex = 9

local searchBar = Instance.new("TextBox", searchContainer)
searchBar.Text  = ""
searchBar.PlaceholderText = "Search animations..."
searchBar.Font  = Enum.Font.Gotham
searchBar.TextScaled = true
searchBar.TextColor3 = T.Text
searchBar.PlaceholderColor3 = T.TextMuted
searchBar.BackgroundTransparency = 1
searchBar.Size  = UDim2.new(1, -42, 1, 0)
searchBar.Position = UDim2.new(0, 36, 0, 0)
searchBar.ClearTextOnFocus = false
searchBar.ZIndex = 9

local searchConstraint = Instance.new("UITextSizeConstraint", searchBar)
searchConstraint.MinTextSize = 10
searchConstraint.MaxTextSize = 14

searchBar.Focused:Connect(function()
    TweenService:Create(searchContainer, TweenInfo.new(0.2), {BackgroundColor3 = T.BgLight}):Play()
end)
searchBar.FocusLost:Connect(function()
    TweenService:Create(searchContainer, TweenInfo.new(0.2), {BackgroundColor3 = T.BgCard}):Play()
end)

-- Category scroll (horizontal)
local categoryWrapper = Instance.new("Frame", parentFrame)
categoryWrapper.Name  = "CategoryWrapper"
categoryWrapper.Size  = UDim2.new(1, -12, 0, 70)
categoryWrapper.Position = UDim2.new(0, 6, 0, 48)
categoryWrapper.BackgroundTransparency = 1
categoryWrapper.ClipsDescendants = true
categoryWrapper.ZIndex = 8

local categoryContainer = Instance.new("ScrollingFrame", categoryWrapper)
categoryContainer.Name  = "CategoryContainer"
categoryContainer.Size  = UDim2.new(1, 0, 1, 0)
categoryContainer.BackgroundTransparency = 1
categoryContainer.BorderSizePixel  = 0
categoryContainer.ScrollBarThickness = 0
categoryContainer.ScrollingDirection = Enum.ScrollingDirection.X
categoryContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
categoryContainer.AutomaticCanvasSize = Enum.AutomaticSize.X
categoryContainer.ZIndex = 8

local categoryLayout = Instance.new("UIListLayout", categoryContainer)
categoryLayout.FillDirection = Enum.FillDirection.Horizontal
categoryLayout.SortOrder = Enum.SortOrder.LayoutOrder
categoryLayout.Padding   = UDim.new(0, 7)
categoryLayout.VerticalAlignment = Enum.VerticalAlignment.Center

local categoryPadding = Instance.new("UIPadding", categoryContainer)
categoryPadding.PaddingLeft  = UDim.new(0, 2)
categoryPadding.PaddingRight = UDim.new(0, 2)

-- Content frame (anim list)
local contentFrame = Instance.new("Frame", parentFrame)
contentFrame.Name  = "ContentFrame"
contentFrame.Size  = UDim2.new(1, -12, 1, -126)
contentFrame.Position = UDim2.new(0, 6, 0, 124)
contentFrame.BackgroundColor3 = T.BgCard
contentFrame.BorderSizePixel  = 0
contentFrame.ZIndex = 8
corner(contentFrame, 12)
addGlow(contentFrame, T.PrimaryDark, 0.6)

local scrollFrame = Instance.new("ScrollingFrame", contentFrame)
scrollFrame.Name  = "ScrollFrame"
scrollFrame.Size  = UDim2.new(1, -10, 1, -10)
scrollFrame.Position = UDim2.new(0, 5, 0, 5)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel  = 0
scrollFrame.ScrollBarThickness = 5
scrollFrame.ScrollBarImageColor3 = T.Primary
scrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.ZIndex = 9

local listLayout = Instance.new("UIListLayout", scrollFrame)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding   = UDim.new(0, 5)

-- ============================================================
-- ANIMATION BUTTON
-- ============================================================
local function createAnimationButton(text, callback)
    local button = Instance.new("TextButton", scrollFrame)
    button.Name  = text
    button.Text  = ""
    button.Font  = Enum.Font.Gotham
    button.TextSize = 14
    button.TextColor3 = T.Text
    button.BackgroundColor3 = T.BgMid
    button.Size  = UDim2.new(1, 0, 0, 46)
    button.BorderSizePixel = 0
    button.ZIndex = 10
    corner(button, 10)

    local dot = Instance.new("Frame", button)
    dot.Size  = UDim2.new(0, 4, 0, 24)
    dot.Position = UDim2.new(0, 10, 0.5, -12)
    dot.BackgroundColor3 = T.Primary
    dot.BorderSizePixel  = 0
    dot.BackgroundTransparency = 0.3
    dot.ZIndex = 11
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local nameLabel = Instance.new("TextLabel", button)
    nameLabel.Name  = "NameLabel"
    nameLabel.Text  = text
    nameLabel.Font  = Enum.Font.Gotham
    nameLabel.TextSize = 13
    nameLabel.TextColor3 = T.Text
    nameLabel.BackgroundTransparency = 1
    nameLabel.Size  = UDim2.new(1, -70, 1, 0)
    nameLabel.Position = UDim2.new(0, 22, 0, 0)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 11

    local applyIcon = Instance.new("ImageLabel", button)
    applyIcon.Image = "rbxassetid://14562122532"
    applyIcon.ImageColor3 = T.PrimaryLight
    applyIcon.Size  = UDim2.new(0, 20, 0, 20)
    applyIcon.Position = UDim2.new(1, -36, 0.5, -10)
    applyIcon.BackgroundTransparency = 1
    applyIcon.ImageTransparency = 0.5
    applyIcon.ZIndex = 11

    button.MouseEnter:Connect(function()
        TweenService:Create(button,    TweenInfo.new(0.15), {BackgroundColor3 = T.BgLight}):Play()
        TweenService:Create(dot,       TweenInfo.new(0.15), {BackgroundColor3 = T.Accent, BackgroundTransparency = 0}):Play()
        TweenService:Create(applyIcon, TweenInfo.new(0.15), {ImageTransparency = 0}):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button,    TweenInfo.new(0.15), {BackgroundColor3 = T.BgMid}):Play()
        TweenService:Create(dot,       TweenInfo.new(0.15), {BackgroundColor3 = T.Primary, BackgroundTransparency = 0.3}):Play()
        TweenService:Create(applyIcon, TweenInfo.new(0.15), {ImageTransparency = 0.5}):Play()
    end)

    button.MouseButton1Click:Connect(callback)
    return button
end

-- ============================================================
-- REFRESH ANIMATION LIST
-- ============================================================
local function refreshAnimationList()
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    local searchText = searchBar.Text:lower()
    local count = 0

    if Animations[currentCategory] then
        for animName, _ in pairs(Animations[currentCategory]) do
            if searchText == "" or animName:lower():find(searchText, 1, true) then
                createAnimationButton(animName, function()
                    setAnimation(currentCategory, animName)
                    Notify("Set", currentCategory .. ": " .. animName, 2)
                end)
                count = count + 1
            end
        end
    end

    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, count * 51)
end

searchBar:GetPropertyChangedSignal("Text"):Connect(refreshAnimationList)

-- ============================================================
-- CATEGORY BUTTONS
-- ============================================================
local function createCategoryButton(category, iconId)
    local button = Instance.new("TextButton", categoryContainer)
    button.Name  = category .. "Button"
    button.Text  = ""
    button.Font  = Enum.Font.GothamBold
    button.BackgroundColor3 = T.BgCard
    button.BorderSizePixel  = 0
    button.Size  = UDim2.new(0, 62, 0, 62)
    button.ZIndex = 9
    corner(button, 12)

    local iconImg = Instance.new("ImageLabel", button)
    iconImg.Name  = "Icon"
    iconImg.Image = iconId
    iconImg.ImageColor3 = T.TextMuted
    iconImg.Size  = UDim2.new(0, 48, 0, 48)
    iconImg.Position = UDim2.new(0.5, -24, 0, 6)
    iconImg.BackgroundTransparency = 1
    iconImg.ZIndex = 10

    local label = Instance.new("TextLabel", button)
    label.Name  = "Label"
    label.Text  = category
    label.Font  = Enum.Font.Gotham
    label.TextScaled = true
    label.TextColor3 = T.TextMuted
    label.BackgroundTransparency = 1
    label.Size  = UDim2.new(1, -4, 0, 16)
    label.Position = UDim2.new(0, 2, 1, -18)
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.ZIndex = 10

    local labelConstraint = Instance.new("UITextSizeConstraint", label)
    labelConstraint.MinTextSize = 7
    labelConstraint.MaxTextSize = 10

    categoryButtons[category] = button

    button.MouseEnter:Connect(function()
        if currentCategory ~= category then
            TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = T.BgLight}):Play()
        end
    end)
    button.MouseLeave:Connect(function()
        if currentCategory ~= category then
            TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = T.BgCard}):Play()
        end
    end)

    button.MouseButton1Click:Connect(function()
        currentCategory = category
        for cat, btn in pairs(categoryButtons) do
            local ico = btn:FindFirstChild("Icon")
            local lbl = btn:FindFirstChild("Label")
            if cat == category then
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = T.PrimaryDark}):Play()
                if ico then ico.ImageColor3 = T.Accent end
                if lbl then lbl.TextColor3  = T.Accent end
            else
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = T.BgCard}):Play()
                if ico then ico.ImageColor3 = T.TextMuted end
                if lbl then lbl.TextColor3  = T.TextMuted end
            end
        end
        refreshAnimationList()
    end)

    return button
end

-- Buat semua category button
createCategoryButton("Idle",     CategoryIcons.Idle)
createCategoryButton("Walk",     CategoryIcons.Walk)
createCategoryButton("Run",      CategoryIcons.Run)
createCategoryButton("Jump",     CategoryIcons.Jump)
createCategoryButton("Fall",     CategoryIcons.Fall)
createCategoryButton("Climb",    CategoryIcons.Climb)
createCategoryButton("Swim",     CategoryIcons.Swim)
createCategoryButton("SwimIdle", CategoryIcons.SwimIdle)

-- Default: Idle selected
do
    local btn = categoryButtons["Idle"]
    if btn then
        btn.BackgroundColor3 = T.PrimaryDark
        local ico = btn:FindFirstChild("Icon")
        local lbl = btn:FindFirstChild("Label")
        if ico then ico.ImageColor3 = T.Accent end
        if lbl then lbl.TextColor3  = T.Accent end
    end
end

-- ============================================================
-- LOAD ANIMATIONS FROM FILE
-- ============================================================
if isfile(FILE_DATABASE) then
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(FILE_DATABASE))
    end)
    if ok and type(data) == "table" then
        fileAnimations = data
        Animations = data
        Notify("Loaded", "Animations from file", 2)
    end
else
    pcall(function()
        writefile(FILE_DATABASE, HttpService:JSONEncode(OriginalAnimations))
        fileAnimations = HttpService:JSONDecode(HttpService:JSONEncode(OriginalAnimations))
    end)
    Animations = OriginalAnimations
    Notify("Created", "New animation file", 2)
end

-- ============================================================
-- LOAD SAVED USER PRESET
-- ============================================================
local function loadLastAnimations()
    if isfile(FILE_PRESET) then
        local ok, saved = pcall(function()
            return HttpService:JSONDecode(readfile(FILE_PRESET))
        end)
        if ok and type(saved) == "table" then
            Notify("Loaded", "Saved animations loaded!", 3)
            for _, t in ipairs({"Idle","Walk","Run","Jump","Fall","Climb","Swim","SwimIdle"}) do
                if saved[t] then setAnimation(t, saved[t]) end
            end
        end
    else
        Notify("First Time", "No saved animations found", 3)
    end
end

-- ============================================================
-- UPDATE FROM ONLINE DATABASE (GitHub Gist)
-- ============================================================
local function LoadAndUpdateAnimations()
    local function fetchOnlineAnimations()
        local ok, result = pcall(function()
            return HttpService:RequestAsync({
                Url    = "https://gist.githubusercontent.com/Sanzzy111/400782ef2879d1da54caccacf156a58f/raw/dataanimasi.txt",
                Method = "GET",
            })
        end)
        if ok and result and result.StatusCode == 200 and result.Body ~= "" then
            local okD, data = pcall(function()
                return HttpService:JSONDecode(result.Body)
            end)
            if okD and type(data) == "table" then return data end
        end
        return nil
    end

    local onlineAnimations = fetchOnlineAnimations()

    if not onlineAnimations then
        Notify("Database", "Failed to load online database", 3)
        return
    end

    local newAnimationsFound = 0
    local updatedAnimations  = 0
    local hadChanges = false

    local function compareAnimData(a, b)
        if type(a) ~= type(b) then return false end
        if type(a) == "table" then
            if #a ~= #b then return false end
            for i = 1, #a do
                if tostring(a[i]) ~= tostring(b[i]) then return false end
            end
            return true
        else
            return tostring(a) == tostring(b)
        end
    end

    for animType, typeAnims in pairs(onlineAnimations) do
        local fileTypeAnims = fileAnimations[animType] or {}
        for animName, animData in pairs(typeAnims) do
            local fileData = fileTypeAnims[animName]
            if not fileData then
                newAnimationsFound = newAnimationsFound + 1
                hadChanges = true
                Animations[animType] = Animations[animType] or {}
                Animations[animType][animName] = animData
                fileAnimations[animType] = fileAnimations[animType] or {}
                fileAnimations[animType][animName] = animData
            elseif not compareAnimData(animData, fileData) then
                updatedAnimations = updatedAnimations + 1
                hadChanges = true
                Animations[animType][animName] = animData
                fileAnimations[animType][animName] = animData
            end
        end
    end

    if hadChanges then
        pcall(function()
            writefile(FILE_DATABASE, HttpService:JSONEncode(Animations))
            local newData = readfile(FILE_DATABASE)
            fileAnimations = HttpService:JSONDecode(newData)
        end)
        refreshAnimationList()
        Notify("Database Update",
            string.format("New: %d | Updated: %d", newAnimationsFound, updatedAnimations), 5)
    else
        Notify("Database", "All animations up to date!", 3)
    end
end

-- ============================================================
-- CHARACTER RESPAWN HANDLER
-- ============================================================
Players.LocalPlayer.CharacterAdded:Connect(function(character)
    local animate = character:WaitForChild("Animate", 10)
    if not animate then
        Notify("Error", "Animate script not found!", 5)
        return
    end
    for _, t in ipairs({"Idle","Walk","Run","Jump","Fall","Climb","Swim","SwimIdle"}) do
        if lastAnimations[t] then setAnimation(t, lastAnimations[t]) end
    end
end)

-- ============================================================
-- INITIALIZE
-- ============================================================
LoadAndUpdateAnimations()
loadLastAnimations()
refreshAnimationList()

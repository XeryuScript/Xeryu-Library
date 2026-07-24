local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local function getParent()
    local success, hui = pcall(function()
        return typeof(gethui) == "function" and gethui()
    end)
    if success and hui then
        return hui
    end
    
    local successRef, coreGui = pcall(function()
        local cl = typeof(cloneref) == "function" and cloneref or function(v) return v end
        return cl(game:GetService("CoreGui"))
    end)
    if successRef and coreGui then
        return coreGui
    end

    return Players.LocalPlayer:WaitForChild("PlayerGui")
end

local Library = {
    Flags = {},
    Unloaded = false
}

local Utility = {}

function Utility:Tween(instance, properties, duration, style, direction)
    style = style or Enum.EasingStyle.Quart
    direction = direction or Enum.EasingDirection.Out
    duration = duration or 0.25
    local tween = TweenService:Create(instance, TweenInfo.new(duration, style, direction), properties)
    tween:Play()
    return tween
end

function Library:CreateWindow(titleText)
    titleText = titleText or "XeryuLib"

    -- Root ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "XeryuLib_" .. math.random(100000, 999999)
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = getParent()

    -- Main Container Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.BorderSizePixel = 0
    MainFrame.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
    MainFrame.Size = UDim2.new(0, 206, 0, 38) -- Starts at header size, resizes automatically
    MainFrame.Position = UDim2.new(0, 270, 0, 12)
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 4)
    MainCorner.Parent = MainFrame

    -- Header Frame
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 34)
    Header.BackgroundTransparency = 1
    Header.Parent = MainFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    TitleLabel.BorderSizePixel = 0
    TitleLabel.TextSize = 15
    TitleLabel.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
    TitleLabel.FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal)
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.Size = UDim2.new(1, -28, 1, 0)
    TitleLabel.Position = UDim2.new(0, 0, 0, 0)
    TitleLabel.Text = "  " .. titleText
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Header

    local CollapseButton = Instance.new("TextButton")
    CollapseButton.Name = "CollapseButton"
    CollapseButton.TextWrapped = true
    CollapseButton.BorderSizePixel = 0
    CollapseButton.TextScaled = true
    CollapseButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    CollapseButton.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
    CollapseButton.Size = UDim2.new(0, 28, 1, 0)
    CollapseButton.Position = UDim2.new(1, -28, 0, 0)
    CollapseButton.Text = "▲"
    CollapseButton.Parent = Header

    -- Scrolling Content Area
    local ScrollingFrame = Instance.new("ScrollingFrame")
    ScrollingFrame.Name = "Content"
    ScrollingFrame.BorderSizePixel = 0
    ScrollingFrame.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
    ScrollingFrame.BackgroundTransparency = 1
    ScrollingFrame.Position = UDim2.new(0, 0, 0, 38)
    ScrollingFrame.Size = UDim2.new(1, 0, 1, -38)
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollingFrame.ScrollBarThickness = 2
    ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
    ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ScrollingFrame.Parent = MainFrame

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 6)
    UIListLayout.Parent = ScrollingFrame

    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingTop = UDim.new(0, 4)
    UIPadding.PaddingLeft = UDim.new(0, 4)
    UIPadding.PaddingRight = UDim.new(0, 4)
    UIPadding.PaddingBottom = UDim.new(0, 6)
    UIPadding.Parent = ScrollingFrame

    -- Dragging Logic for Main Window
    local dragging, dragInput, dragStart, startPos
    Header.InputBegan:Connect(function(input)
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

    Header.InputChanged:Connect(function(input)
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

    -- Auto Height & Collapse Logic
    local collapsed = false
    local lastExpandedHeight = 250

    local function updateWindowSize()
        if not collapsed then
            local contentHeight = UIListLayout.AbsoluteContentSize.Y + 48
            lastExpandedHeight = math.clamp(contentHeight, 50, 500)
            Utility:Tween(MainFrame, {Size = UDim2.new(0, 206, 0, lastExpandedHeight)}, 0.15)
        end
    end

    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateWindowSize)

    CollapseButton.MouseButton1Click:Connect(function()
        collapsed = not collapsed
        if collapsed then
            Utility:Tween(CollapseButton, {Rotation = 180}, 0.25)
            Utility:Tween(MainFrame, {Size = UDim2.new(0, 206, 0, 34)}, 0.25)
        else
            Utility:Tween(CollapseButton, {Rotation = 0}, 0.25)
            Utility:Tween(MainFrame, {Size = UDim2.new(0, 206, 0, lastExpandedHeight)}, 0.25)
        end
    end)

    -- Anti-Swipe Mobile / Scroll Lockdown helper
    local function setScrollLock(locked)
        ScrollingFrame.ScrollingEnabled = not locked
    end

    ----------------------------------------------------------------------------
    -- WINDOW ELEMENTS API
    ----------------------------------------------------------------------------
    local Tab = {}
    
    function Tab:AddDropdown(options)
        options = options or {}
        local text = options.text or options.Text or "Select Option"
        local values = options.values or options.Values or {}
        local selectVal = options.select or options.Select or 1
        local flag = options.flag or options.Flag
        local callback = options.callback or options.Callback or function() end

        -- Determine initial selection
        local currentSelection = ""
        if type(selectVal) == "number" then
            currentSelection = values[selectVal] or values[1] or ""
        elseif type(selectVal) == "string" then
            currentSelection = selectVal
        end

        local Container = Instance.new("Frame")
        Container.Name = "DropdownContainer"
        Container.Size = UDim2.new(1, 0, 0, 30)
        Container.BackgroundTransparency = 1
        Container.Parent = ContentContainer

        local DropdownBtn = Instance.new("TextButton")
        DropdownBtn.Name = "DropdownButton"
        DropdownBtn.Size = UDim2.new(1, 0, 1, 0)
        DropdownBtn.BackgroundColor3 = Theme.Buttons
        DropdownBtn.BorderSizePixel = 0
        DropdownBtn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal)
        DropdownBtn.Text = text .. ": " .. tostring(currentSelection)
        DropdownBtn.TextColor3 = Theme.Text
        DropdownBtn.TextSize = 12
        DropdownBtn.TextWrapped = true
        DropdownBtn.Parent = Container

        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 3)
        UICorner.Parent = DropdownBtn

        -- Modal Modal Overlay
        local Overlay = Instance.new("TextButton")
        Overlay.Name = "DropdownModalOverlay"
        Overlay.Size = UDim2.new(1, 0, 1, 0)
        Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Overlay.BackgroundTransparency = 0.5
        Overlay.Text = ""
        Overlay.Visible = false
        Overlay.ZIndex = 100
        Overlay.Parent = ScreenGui

        local ModalFrame = Instance.new("Frame")
        ModalFrame.Name = "ModalFrame"
        ModalFrame.Size = UDim2.new(0, 180, 0, 0)
        ModalFrame.Position = UDim2.new(0.5, -90, 0.5, 0)
        ModalFrame.AnchorPoint = Vector2.new(0, 0.5)
        ModalFrame.BackgroundColor3 = Theme.Background
        ModalFrame.BorderSizePixel = 0
        ModalFrame.ClipsDescendants = true
        ModalFrame.ZIndex = 101
        ModalFrame.Parent = Overlay

        local ModalCorner = Instance.new("UICorner")
        ModalCorner.CornerRadius = UDim.new(0, 6)
        ModalCorner.Parent = ModalFrame

        local ModalStroke = Instance.new("UIStroke")
        ModalStroke.Thickness = 1
        ModalStroke.Color = Theme.InputBorder
        ModalStroke.Parent = ModalFrame

        local ModalScroll = Instance.new("ScrollingFrame")
        ModalScroll.Size = UDim2.new(1, 0, 1, 0)
        ModalScroll.BackgroundTransparency = 1
        ModalScroll.ScrollBarThickness = 2
        ModalScroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
        ModalScroll.ZIndex = 102
        ModalScroll.Parent = ModalFrame

        local ModalList = Instance.new("UIListLayout")
        ModalList.SortOrder = Enum.SortOrder.LayoutOrder
        ModalList.Padding = UDim.new(0, 4)
        ModalList.Parent = ModalScroll

        local ModalPadding = Instance.new("UIPadding")
        ModalPadding.PaddingTop = UDim.new(0, 6)
        ModalPadding.PaddingBottom = UDim.new(0, 6)
        ModalPadding.PaddingLeft = UDim.new(0, 6)
        ModalPadding.PaddingRight = UDim.new(0, 6)
        ModalPadding.Parent = ModalScroll

        local function closeModal()
            TweenService:Create(ModalFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 180, 0, 0)
            }):Play()
            task.delay(0.2, function()
                Overlay.Visible = false
            end)
        end

        local function openModal()
            -- Re-populate list
            for _, child in ipairs(ModalScroll:GetChildren()) do
                if child:IsA("TextButton") then
                    child:Destroy()
                end
            end

            local calculatedHeight = (#values * 28) + ((#values - 1) * 4) + 12
            local targetHeight = math.clamp(calculatedHeight, 40, 200)

            for _, val in ipairs(values) do
                local ItemBtn = Instance.new("TextButton")
                ItemBtn.Size = UDim2.new(1, 0, 0, 28)
                ItemBtn.BackgroundColor3 = (val == currentSelection) and Color3.fromRGB(60, 60, 60) or Theme.Buttons
                ItemBtn.BorderSizePixel = 0
                ItemBtn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal)
                ItemBtn.Text = tostring(val)
                ItemBtn.TextColor3 = Theme.Text
                ItemBtn.TextSize = 12
                ItemBtn.ZIndex = 103
                ItemBtn.Parent = ModalScroll

                local ItemCorner = Instance.new("UICorner")
                ItemCorner.CornerRadius = UDim.new(0, 4)
                ItemCorner.Parent = ItemBtn

                ItemBtn.MouseButton1Click:Connect(function()
                    currentSelection = val
                    DropdownBtn.Text = text .. ": " .. tostring(currentSelection)
                    if flag then Library.Flags[flag] = currentSelection end
                    closeModal()
                    task.spawn(callback, currentSelection)
                end)
            end

            ModalScroll.CanvasSize = UDim2.new(0, 0, 0, calculatedHeight)
            Overlay.Visible = true

            TweenService:Create(ModalFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 180, 0, targetHeight)
            }):Play()
        end

        DropdownBtn.MouseButton1Click:Connect(openModal)
        Overlay.MouseButton1Click:Connect(closeModal)

        if flag then Library.Flags[flag] = currentSelection end

        return Container
    end

    -- 1. BUTTON
    function Tab:AddButton(options)
        options = options or {}
        local text = options.text or "Button"
        local callback = options.callback or function() end

        local Button = Instance.new("TextButton")
        Button.Name = "Button"
        Button.Size = UDim2.new(1, 0, 0, 28)
        Button.BackgroundColor3 = Color3.fromRGB(48, 48, 48)
        Button.BorderSizePixel = 0
        Button.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal)
        Button.Text = text
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.TextSize = 14
        Button.TextWrapped = true
        Button.Parent = ScrollingFrame

        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 3)
        UICorner.Parent = Button

        Button.MouseEnter:Connect(function()
            Utility:Tween(Button, {BackgroundColor3 = Color3.fromRGB(58, 58, 58)}, 0.15)
        end)
        Button.MouseLeave:Connect(function()
            Utility:Tween(Button, {BackgroundColor3 = Color3.fromRGB(48, 48, 48)}, 0.15)
        end)
        Button.MouseButton1Down:Connect(function()
            Utility:Tween(Button, {BackgroundColor3 = Color3.fromRGB(38, 38, 38)}, 0.1)
        end)
        Button.MouseButton1Up:Connect(function()
            Utility:Tween(Button, {BackgroundColor3 = Color3.fromRGB(58, 58, 58)}, 0.1)
            callback()
        end)

        return Button
    end

    -- 2. TOGGLE
    function Tab:AddToggle(options)
        options = options or {}
        local text = options.text or "Toggle"
        local flag = options.flag
        local default = options.default or false
        local callback = options.callback or function() end

        local state = default

        local ToggleRow = Instance.new("TextButton")
        ToggleRow.Name = "ToggleRow"
        ToggleRow.Size = UDim2.new(1, 0, 0, 32)
        ToggleRow.BackgroundTransparency = 1
        ToggleRow.Text = ""
        ToggleRow.Parent = ScrollingFrame

        local ToggleLabel = Instance.new("TextLabel")
        ToggleLabel.Name = "ToggleLabel"
        ToggleLabel.Size = UDim2.new(1, -36, 1, 0)
        ToggleLabel.Position = UDim2.new(0, 2, 0, 0)
        ToggleLabel.BackgroundTransparency = 1
        ToggleLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal)
        ToggleLabel.Text = text
        ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleLabel.TextSize = 14
        ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        ToggleLabel.Parent = ToggleRow

        local ToggleIndicator = Instance.new("Frame")
        ToggleIndicator.Name = "ToggleIndicator"
        ToggleIndicator.Size = UDim2.new(0, 26, 0, 26)
        ToggleIndicator.Position = UDim2.new(1, -28, 0, 3)
        ToggleIndicator.BackgroundColor3 = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        ToggleIndicator.Parent = ToggleRow

        local IndicatorCorner = Instance.new("UICorner")
        IndicatorCorner.CornerRadius = UDim.new(0, 4)
        IndicatorCorner.Parent = ToggleIndicator

        local function updateToggle(val)
            state = val
            if flag then Library.Flags[flag] = state end
            local targetColor = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            Utility:Tween(ToggleIndicator, {BackgroundColor3 = targetColor}, 0.2)
            callback(state)
        end

        ToggleRow.MouseButton1Click:Connect(function()
            setScrollLock(true)
            updateToggle(not state)
            task.delay(0.05, function() setScrollLock(false) end)
        end)

        if flag then Library.Flags[flag] = state end

        return ToggleRow
    end

    -- 3. LABEL
    function Tab:AddLabel(options)
        options = options or {}
        local text = options.text or "Label"

        local LabelFrame = Instance.new("TextLabel")
        LabelFrame.Name = "Label"
        LabelFrame.Size = UDim2.new(1, 0, 0, 24)
        LabelFrame.BackgroundTransparency = 1
        LabelFrame.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal)
        LabelFrame.Text = text
        LabelFrame.TextColor3 = Color3.fromRGB(255, 255, 255)
        LabelFrame.TextSize = 14
        LabelFrame.TextXAlignment = Enum.TextXAlignment.Left
        LabelFrame.Parent = ScrollingFrame

        return LabelFrame
    end

    -- 4. SLIDER
    function Tab:AddSlider(options)
        options = options or {}
        local text = options.text or "Slider"
        local min = options.min or 0
        local max = options.max or 100
        local default = options.default or min
        local flag = options.flag
        local callback = options.callback or function() end

        local currentValue = math.clamp(default, min, max)

        local SliderContainer = Instance.new("Frame")
        SliderContainer.Name = "Slider"
        SliderContainer.Size = UDim2.new(1, 0, 0, 42)
        SliderContainer.BackgroundTransparency = 1
        SliderContainer.Parent = ScrollingFrame

        local SliderLabel = Instance.new("TextLabel")
        SliderLabel.Name = "SliderLabel"
        SliderLabel.Size = UDim2.new(1, -45, 0, 18)
        SliderLabel.BackgroundTransparency = 1
        SliderLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal)
        SliderLabel.Text = text
        SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        SliderLabel.TextSize = 13
        SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
        SliderLabel.Parent = SliderContainer

        local ValueBox = Instance.new("TextBox")
        ValueBox.Name = "ValueBox"
        ValueBox.Size = UDim2.new(0, 40, 0, 18)
        ValueBox.Position = UDim2.new(1, -40, 0, 0)
        ValueBox.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
        ValueBox.BorderSizePixel = 1
        ValueBox.BorderColor3 = Color3.fromRGB(61, 61, 61)
        ValueBox.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal)
        ValueBox.Text = tostring(currentValue)
        ValueBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        ValueBox.TextSize = 12
        ValueBox.Parent = SliderContainer

        local Track = Instance.new("Frame")
        Track.Name = "SliderTrack"
        Track.Size = UDim2.new(1, 0, 0, 12)
        Track.Position = UDim2.new(0, 0, 0, 24)
        Track.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        Track.BorderSizePixel = 0
        Track.Parent = SliderContainer

        local TrackCorner = Instance.new("UICorner")
        TrackCorner.CornerRadius = UDim.new(0, 4)
        TrackCorner.Parent = Track

        local Fill = Instance.new("Frame")
        Fill.Name = "SliderFill"
        Fill.Size = UDim2.new((currentValue - min) / (max - min), 0, 1, 0)
        Fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Fill.BorderSizePixel = 0
        Fill.Parent = Track

        local FillCorner = Instance.new("UICorner")
        FillCorner.CornerRadius = UDim.new(0, 4)
        FillCorner.Parent = Fill

        local Knob = Instance.new("Frame")
        Knob.Name = "SliderKnob"
        Knob.Size = UDim2.new(0, 14, 0, 14)
        Knob.AnchorPoint = Vector2.new(0.5, 0.5)
        Knob.Position = UDim2.new(1, 0, 0.5, 0)
        Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Knob.BorderSizePixel = 0
        Knob.Parent = Fill

        local KnobCorner = Instance.new("UICorner")
        KnobCorner.CornerRadius = UDim.new(1, 0)
        KnobCorner.Parent = Knob

        local draggingSlider = false

        local function setValue(val, skipBox)
            currentValue = math.clamp(math.round(val), min, max)
            local percent = (currentValue - min) / (max - min)
            Fill.Size = UDim2.new(percent, 0, 1, 0)
            if not skipBox then
                ValueBox.Text = tostring(currentValue)
            end
            if flag then Library.Flags[flag] = currentValue end
            callback(currentValue)
        end

        local function updateFromInput(input)
            local posX = input.Position.X - Track.AbsolutePosition.X
            local percent = math.clamp(posX / Track.AbsoluteSize.X, 0, 1)
            setValue(min + (max - min) * percent)
        end

        Track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                draggingSlider = true
                setScrollLock(true)
                updateFromInput(input)
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                updateFromInput(input)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if draggingSlider then
                    draggingSlider = false
                    setScrollLock(false)
                end
            end
        end)

        ValueBox.FocusLost:Connect(function()
            local num = tonumber(ValueBox.Text)
            if num then
                setValue(num)
            else
                ValueBox.Text = tostring(currentValue)
            end
        end)

        ValueBox.Focused:Connect(function()
            setScrollLock(true)
        end)

        if flag then Library.Flags[flag] = currentValue end

        return SliderContainer
    end

    -- 5. KEYBIND
    function Tab:AddBind(options)
        options = options or {}
        local text = options.text or "Keybind"
        local key = options.key or "X"
        local hold = options.hold or false
        local flag = options.flag
        local callback = options.callback or function() end

        local currentKey = Enum.KeyCode[key] or Enum.KeyCode.X
        local binding = false

        local BindRow = Instance.new("Frame")
        BindRow.Name = "KeybindRow"
        BindRow.Size = UDim2.new(1, 0, 0, 30)
        BindRow.BackgroundTransparency = 1
        BindRow.Parent = ScrollingFrame

        local BindLabel = Instance.new("TextLabel")
        BindLabel.Name = "BindLabel"
        BindLabel.Size = UDim2.new(1, -50, 1, 0)
        BindLabel.Position = UDim2.new(0, 2, 0, 0)
        BindLabel.BackgroundTransparency = 1
        BindLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal)
        BindLabel.Text = text
        BindLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        BindLabel.TextSize = 14
        BindLabel.TextXAlignment = Enum.TextXAlignment.Left
        BindLabel.Parent = BindRow

        local KeybindBtn = Instance.new("TextButton")
        KeybindBtn.Name = "KeybindButton"
        KeybindBtn.Size = UDim2.new(0, 44, 0, 26)
        KeybindBtn.Position = UDim2.new(1, -44, 0, 2)
        KeybindBtn.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
        KeybindBtn.BorderSizePixel = 0
        KeybindBtn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal)
        KeybindBtn.Text = currentKey.Name
        KeybindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        KeybindBtn.TextSize = 12
        KeybindBtn.Parent = BindRow

        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 4)
        BtnCorner.Parent = KeybindBtn

        local Stroke = Instance.new("UIStroke")
        Stroke.Thickness = 1.5
        Stroke.Color = Color3.fromRGB(56, 56, 56)
        Stroke.Parent = KeybindBtn

        KeybindBtn.MouseButton1Click:Connect(function()
            binding = true
            setScrollLock(true)
            KeybindBtn.Text = "..."
        end)

        UserInputService.InputBegan:Connect(function(input, gpe)
            if binding then
                if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
                    currentKey = input.KeyCode
                    KeybindBtn.Text = currentKey.Name
                    binding = false
                    setScrollLock(false)
                    if flag then Library.Flags[flag] = currentKey end
                end
            elseif not gpe and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKey then
                if not hold then
                    callback()
                else
                    callback(true)
                end
            end
        end)

        if hold then
            UserInputService.InputEnded:Connect(function(input, gpe)
                if not gpe and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKey then
                    callback(false)
                end
            end)
        end

        if flag then Library.Flags[flag] = currentKey end

        return BindRow
    end

    -- 6. INPUT (TEXTBOX)
    function Tab:AddInput(options)
        options = options or {}
        local placeholder = options.placeholder or "Input..."
        local flag = options.flag
        local callback = options.callback or function() end

        local InputBox = Instance.new("TextBox")
        InputBox.Name = "InputBox"
        InputBox.Size = UDim2.new(1, 0, 0, 32)
        InputBox.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
        InputBox.BorderSizePixel = 1
        InputBox.BorderColor3 = Color3.fromRGB(61, 61, 61)
        InputBox.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal)
        InputBox.PlaceholderText = placeholder
        InputBox.Text = ""
        InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        InputBox.TextSize = 13
        InputBox.Parent = ScrollingFrame

        InputBox.Focused:Connect(function()
            setScrollLock(true)
        end)

        InputBox.FocusLost:Connect(function(enterPressed)
            setScrollLock(false)
            if enterPressed then
                if flag then Library.Flags[flag] = InputBox.Text end
                callback(InputBox.Text)
            end
        end)

        return InputBox
    end

    Library.ScreenGui = ScreenGui
    return Tab
end

function Library:Init()
    -- Library initialized and ready
end

function Library:Close()
    if Library.ScreenGui then
        Library.ScreenGui:Destroy()
    end
    Library.Unloaded = true
end

return Library

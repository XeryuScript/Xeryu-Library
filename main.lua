local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local function getClonedRef(object)
    if typeof(cloneref) == "function" then
        return cloneref(object)
    end
    return object
end

local LocalPlayer = getClonedRef(Players.LocalPlayer)

local function getGuiContainer()
    local success, hui = pcall(function()
        return typeof(gethui) == "function" and gethui()
    end)
    if success and hui then
        return hui
    end

    local successCore, cGui = pcall(function()
        return CoreGui:FindFirstChild("RobloxGui") and CoreGui
    end)
    if successCore and cGui then
        return cGui
    end

    return LocalPlayer:WaitForChild("PlayerGui")
end

-- Library State
local Library = {
    Flags = {},
    Unloaded = false,
    CurrentWindow = nil
}

local Theme = {
    Background = Color3.fromRGB(21, 21, 21),
    Header = Color3.fromRGB(36, 36, 36),
    Buttons = Color3.fromRGB(48, 48, 48),
    SliderBg = Color3.fromRGB(40, 40, 40),
    SliderFill = Color3.fromRGB(255, 255, 255),
    InputBorder = Color3.fromRGB(61, 61, 61),
    ToggleOff = Color3.fromRGB(200, 50, 50),
    ToggleOn = Color3.fromRGB(0, 255, 0),
    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(180, 180, 180)
}

-- Utility Helpers
local Utility = {}
function Utility:Tween(instance, properties, duration, style, direction)
    style = style or Enum.EasingStyle.Quart
    direction = direction or Enum.EasingDirection.Out
    duration = duration or 0.25
    local tween = TweenService:Create(instance, TweenInfo.new(duration, style, direction), properties)
    tween:Play()
    return tween
end

-- Create Main ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XeryuLib_Gui"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = getGuiContainer()

--------------------------------------------------------------------------------
-- WINDOW CREATION
--------------------------------------------------------------------------------
function Library:CreateWindow(titleText)
    titleText = titleText or "XeryuLib"

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.BorderSizePixel = 0
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.Size = UDim2.new(0, 210, 0, 36)
    MainFrame.Position = UDim2.new(0.5, -105, 0.3, 0)
    MainFrame.ClipsDescendants = true
    MainFrame.Active = true
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 4)
    MainCorner.Parent = MainFrame

    -- Header Title
    local Header = Instance.new("TextLabel")
    Header.Name = "Header"
    Header.BorderSizePixel = 0
    Header.TextSize = 15
    Header.BackgroundColor3 = Theme.Header
    Header.FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal)
    Header.TextColor3 = Theme.Text
    Header.Size = UDim2.new(1, -30, 0, 34)
    Header.Position = UDim2.new(0, 0, 0, 0)
    Header.Text = titleText
Header.TextXAlignment = Enum.TextXAlignment.Center
    Header.Parent = MainFrame

    -- Collapse/Expand Arrow Button
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Name = "OpenUi/CloseUi"
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.TextSize = 12
    ToggleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    ToggleBtn.BackgroundColor3 = Theme.Header
    ToggleBtn.Size = UDim2.new(0, 30, 0, 34)
    ToggleBtn.Position = UDim2.new(1, -30, 0, 0)
    ToggleBtn.Text = "▲"
    ToggleBtn.Parent = MainFrame

    -- Dynamic Content Container (ScrollingFrame)
    local ContentContainer = Instance.new("ScrollingFrame")
    ContentContainer.Name = "Content"
    ContentContainer.BorderSizePixel = 0
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Position = UDim2.new(0, 0, 0, 36)
    ContentContainer.Size = UDim2.new(1, 0, 1, -36)
    ContentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    ContentContainer.ScrollBarThickness = 2
    ContentContainer.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
    ContentContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ContentContainer.Parent = MainFrame

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 6)
    UIListLayout.Parent = ContentContainer

    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingTop = UDim.new(0, 6)
    UIPadding.PaddingBottom = UDim.new(0, 8)
    UIPadding.PaddingLeft = UDim.new(0, 6)
    UIPadding.PaddingRight = UDim.new(0, 6)
    UIPadding.Parent = ContentContainer

    ----------------------------------------------------------------------------
    -- DRAGGING MECHANIC
    ----------------------------------------------------------------------------
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end

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
            update(input)
        end
    end)

    ----------------------------------------------------------------------------
    -- ANTI-SWIPE (MOBILE SCROLL PROTECTION)
    ----------------------------------------------------------------------------
    local function setScrollingEnabled(enabled)
        ContentContainer.ScrollingEnabled = enabled
    end

    ----------------------------------------------------------------------------
    -- AUTO-RESIZING & COLLAPSE LOGIC
    ----------------------------------------------------------------------------
    local expanded = true
    local lastContentHeight = 0

    local function updateWindowSize()
        local absoluteContentSize = UIListLayout.AbsoluteContentSize.Y + UIPadding.PaddingTop.Offset + UIPadding.PaddingBottom.Offset
        lastContentHeight = math.clamp(absoluteContentSize, 0, 350)
        ContentContainer.Size = UDim2.new(1, 0, 0, lastContentHeight)

        if expanded then
            Utility:Tween(MainFrame, {
                Size = UDim2.new(0, 210, 0, 36 + lastContentHeight)
            }, 0.25)
        end
    end

    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateWindowSize)

    ToggleBtn.MouseButton1Click:Connect(function()
        expanded = not expanded
        local targetHeight = expanded and (36 + lastContentHeight) or 36
        local targetRotation = expanded and 0 or 180

        Utility:Tween(MainFrame, {
            Size = UDim2.new(0, 210, 0, targetHeight)
        }, 0.25)

        Utility:Tween(ToggleBtn, {
            Rotation = targetRotation
        }, 0.25)
    end)

    ----------------------------------------------------------------------------
    -- ELEMENT FACTORY (Tab Object)
    ----------------------------------------------------------------------------
    local Tab = {}

    -- 1. BUTTON
    function Tab:AddButton(options)
        options = options or {}
        local text = options.text or "Button"
        local callback = options.callback or function() end

        local Button = Instance.new("TextButton")
        Button.Name = "Button"
        Button.Size = UDim2.new(1, 0, 0, 28)
        Button.BackgroundColor3 = Theme.Buttons
        Button.BorderSizePixel = 0
        Button.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal)
        Button.Text = text
        Button.TextColor3 = Theme.Text
        Button.TextSize = 13
        Button.TextWrapped = true
        Button.Parent = ContentContainer

        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 3)
        UICorner.Parent = Button

        Button.MouseButton1Down:Connect(function()
            Utility:Tween(Button, {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}, 0.1)
        end)

        Button.MouseButton1Up:Connect(function()
            Utility:Tween(Button, {BackgroundColor3 = Theme.Buttons}, 0.1)
        end)

        Button.MouseButton1Click:Connect(function()
            task.spawn(callback)
        end)

        return Button
    end

    -- 2. TOGGLE
    function Tab:AddToggle(options)
        options = options or {}
        local text = options.text or "Toggle"
        local flag = options.flag
        local defaultState = options.default or false
        local callback = options.callback or function() end

        local toggled = defaultState

        local Container = Instance.new("Frame")
        Container.Name = "ToggleContainer"
        Container.Size = UDim2.new(1, 0, 0, 30)
        Container.BackgroundTransparency = 1
        Container.Parent = ContentContainer

        local Label = Instance.new("TextLabel")
        Label.Name = "TextLabel2"
        Label.Size = UDim2.new(1, -34, 1, 0)
        Label.Position = UDim2.new(0, 0, 0, 0)
        Label.BackgroundTransparency = 1
        Label.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal)
        Label.Text = text
        Label.TextColor3 = Theme.Text
        Label.TextSize = 13
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Container

        local ToggleBtn = Instance.new("TextButton")
        ToggleBtn.Name = "TextButton2"
        ToggleBtn.Size = UDim2.new(0, 26, 0, 26)
        ToggleBtn.Position = UDim2.new(1, -26, 0.5, -13)
        ToggleBtn.BackgroundColor3 = toggled and Theme.ToggleOn or Theme.ToggleOff
        ToggleBtn.Text = ""
        ToggleBtn.Parent = Container

        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 4)
        UICorner.Parent = ToggleBtn

        local function updateToggle(state)
            toggled = state
            if flag then Library.Flags[flag] = toggled end
            local targetColor = toggled and Theme.ToggleOn or Theme.ToggleOff
            Utility:Tween(ToggleBtn, {BackgroundColor3 = targetColor}, 0.2)
            task.spawn(callback, toggled)
        end

        local ClickArea = Instance.new("TextButton")
        ClickArea.Size = UDim2.new(1, 0, 1, 0)
        ClickArea.BackgroundTransparency = 1
        ClickArea.Text = ""
        ClickArea.Parent = Container

        ClickArea.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                setScrollingEnabled(false)
            end
        end)

        ClickArea.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                setScrollingEnabled(true)
            end
        end)

        ClickArea.MouseButton1Click:Connect(function()
            updateToggle(not toggled)
        end)

        if flag then Library.Flags[flag] = toggled end

        return Container
    end

    -- 3. LABEL
    function Tab:AddLabel(options)
        options = options or {}
        local text = options.text or "Label"

        local Label = Instance.new("TextLabel")
        Label.Name = "Label"
        Label.Size = UDim2.new(1, 0, 0, 24)
        Label.BackgroundTransparency = 1
        Label.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal)
        Label.Text = text
        Label.TextColor3 = Theme.Text
        Label.TextSize = 13
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = ContentContainer

        return Label
    end

    -- 4. INPUT BOX
    function Tab:AddInput(options)
        options = options or {}
        local placeholder = options.placeholder or options.text or "Input..."
        local callback = options.callback or function() end
        local numericOnly = options.numeric or false

        local InputBox = Instance.new("TextBox")
        InputBox.Name = "InputBox"
        InputBox.Size = UDim2.new(1, 0, 0, 32)
        InputBox.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
        InputBox.BorderColor3 = Theme.InputBorder
        InputBox.BorderSizePixel = 1
        InputBox.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal)
        InputBox.PlaceholderText = placeholder
        InputBox.Text = ""
        InputBox.TextColor3 = Theme.Text
        InputBox.TextSize = 13
        InputBox.ClearTextOnFocus = false
        InputBox.Parent = ContentContainer

        InputBox.Focused:Connect(function()
            setScrollingEnabled(false)
        end)

        InputBox.FocusLost:Connect(function(enterPressed)
            setScrollingEnabled(true)
            local text = InputBox.Text
            if numericOnly then
                text = text:gsub("%D+", "")
                InputBox.Text = text
            end
            task.spawn(callback, text)
        end)

        return InputBox
    end

    -- 5. SLIDER
    function Tab:AddSlider(options)
        options = options or {}
        local text = options.text or "Slider"
        local min = options.min or 0
        local max = options.max or 100
        local defaultVal = options.default or min
        local flag = options.flag
        local callback = options.callback or function() end

        local Container = Instance.new("Frame")
        Container.Name = "SliderContainer"
        Container.Size = UDim2.new(1, 0, 0, 42)
        Container.BackgroundTransparency = 1
        Container.Parent = ContentContainer

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -45, 0, 18)
        Label.BackgroundTransparency = 1
        Label.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal)
        Label.Text = text
        Label.TextColor3 = Theme.Text
        Label.TextSize = 12
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Container

        local ValueBox = Instance.new("TextBox")
        ValueBox.Name = "ValueBox"
        ValueBox.Size = UDim2.new(0, 40, 0, 18)
        ValueBox.Position = UDim2.new(1, -40, 0, 0)
        ValueBox.BackgroundTransparency = 1
        ValueBox.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal)
        ValueBox.Text = tostring(defaultVal)
        ValueBox.TextColor3 = Theme.Text
        ValueBox.TextSize = 12
        ValueBox.TextXAlignment = Enum.TextXAlignment.Right
        ValueBox.Parent = Container

        local SliderTrack = Instance.new("Frame")
        SliderTrack.Name = "Slider"
        SliderTrack.Size = UDim2.new(1, 0, 0, 8)
        SliderTrack.Position = UDim2.new(0, 0, 0, 24)
        SliderTrack.BackgroundColor3 = Theme.SliderBg
        SliderTrack.BorderSizePixel = 0
        SliderTrack.Parent = Container

        local TrackCorner = Instance.new("UICorner")
        TrackCorner.CornerRadius = UDim.new(1, 0)
        TrackCorner.Parent = SliderTrack

        local SliderFill = Instance.new("Frame")
        SliderFill.Name = "SliderFill"
        SliderFill.Size = UDim2.new((defaultVal - min) / (max - min), 0, 1, 0)
        SliderFill.BackgroundColor3 = Theme.SliderFill
        SliderFill.BorderSizePixel = 0
        SliderFill.Parent = SliderTrack

        local FillCorner = Instance.new("UICorner")
        FillCorner.CornerRadius = UDim.new(1, 0)
        FillCorner.Parent = SliderFill

        local SliderKnob = Instance.new("Frame")
        SliderKnob.Name = "SliderKnob"
        SliderKnob.Size = UDim2.new(0, 12, 0, 12)
        SliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
        SliderKnob.Position = UDim2.new(1, 0, 0.5, 0)
        SliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SliderKnob.BorderSizePixel = 0
        SliderKnob.Parent = SliderFill

        local KnobCorner = Instance.new("UICorner")
        KnobCorner.CornerRadius = UDim.new(1, 0)
        KnobCorner.Parent = SliderKnob

        local value = defaultVal

        local function setValue(newVal)
            value = math.clamp(math.round(newVal), min, max)
            local percent = (value - min) / (max - min)
            SliderFill.Size = UDim2.new(percent, 0, 1, 0)
            ValueBox.Text = tostring(value)
            if flag then Library.Flags[flag] = value end
            task.spawn(callback, value)
        end

        local sliding = false

        local function updateFromInput(input)
            local mousePos = input.Position.X
            local trackPos = SliderTrack.AbsolutePosition.X
            local trackWidth = SliderTrack.AbsoluteSize.X
            local scale = math.clamp((mousePos - trackPos) / trackWidth, 0, 1)
            setValue(min + (scale * (max - min)))
        end

        SliderTrack.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                sliding = true
                setScrollingEnabled(false)
                updateFromInput(input)
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                updateFromInput(input)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if sliding then
                    sliding = false
                    setScrollingEnabled(true)
                end
            end
        end)

        ValueBox.FocusLost:Connect(function()
            local num = tonumber(ValueBox.Text)
            if num then
                setValue(num)
            else
                ValueBox.Text = tostring(value)
            end
        end)

        if flag then Library.Flags[flag] = value end

        return Container
    end

    -- 6. DROPDOWN
    function Tab:AddDropdown(options)
        options = options or {}
        local text = options.text or options.Text or "Select Option"
        local values = options.values or options.Values or {}
        local selectVal = options.select or options.Select or 1
        local flag = options.flag or options.Flag
        local callback = options.callback or options.Callback or function() end

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
        Container.Parent = ContentContainer -- Fixed Parent reference

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

        -- Fullscreen Overlay Context Modal
        local Overlay = Instance.new("TextButton")
        Overlay.Name = "DropdownModalOverlay"
        Overlay.Size = UDim2.new(1, 0, 1, 0)
        Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Overlay.BackgroundTransparency = 0.5
        Overlay.Text = ""
        Overlay.AutoButtonColor = false
        Overlay.Visible = false
        Overlay.ZIndex = 100
        Overlay.Parent = ScreenGui

        local ModalFrame = Instance.new("TextButton")
        ModalFrame.Name = "ModalFrame"
        ModalFrame.Size = UDim2.new(0, 180, 0, 0)
        ModalFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        ModalFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        ModalFrame.BackgroundColor3 = Theme.Background
        ModalFrame.BorderSizePixel = 0
        ModalFrame.ClipsDescendants = true
        ModalFrame.Text = ""
        ModalFrame.AutoButtonColor = false
        ModalFrame.Active = true
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
            Utility:Tween(ModalFrame, {Size = UDim2.new(0, 180, 0, 0)}, 0.2)
            task.delay(0.2, function()
                Overlay.Visible = false
            end)
        end

        local function openModal()
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

            Utility:Tween(ModalFrame, {Size = UDim2.new(0, 180, 0, targetHeight)}, 0.2)
        end

        DropdownBtn.MouseButton1Click:Connect(openModal)

        Overlay.MouseButton1Click:Connect(function()
            closeModal()
        end)

        if flag then Library.Flags[flag] = currentSelection end

        return Container
    end

    return Tab
end

return Library

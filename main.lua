--[[
    XeryuLib - Luau UI Library
    Fixed line 4 nil indexing & runtime safety checks
]]

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- Safe CoreGui / LocalPlayer Parent Resolution
local function getParent()
    local success, hui = pcall(function()
        return typeof(gethui) == "function" and gethui()
    end)
    if success and hui then
        return hui
    end
    
    local coreGui
    pcall(function()
        local cl = typeof(cloneref) == "function" and cloneref or function(v) return v end
        coreGui = cl(game:GetService("CoreGui"))
    end)
    if coreGui then
        return coreGui
    end

    local localPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    return localPlayer:WaitForChild("PlayerGui", 5) or game:GetService("CoreGui")
end

local Library = {
    Flags = {},
    Unloaded = false
}

function Library:CreateWindow(titleText)
    titleText = titleText or "PISTOL ARENA"

    -- ScreenGui
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
    MainFrame.Size = UDim2.new(0, 210, 0, 34)
    MainFrame.Position = UDim2.new(0, 270, 0, 12)
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local UICorner_a = Instance.new("UICorner")
    UICorner_a.CornerRadius = UDim.new(0, 4)
    UICorner_a.Parent = MainFrame

    -- Header Frame
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 34)
    Header.BackgroundTransparency = 1
    Header.Parent = MainFrame

    -- Title Label
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    TitleLabel.BorderSizePixel = 0
    TitleLabel.TextSize = 18
    TitleLabel.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
    TitleLabel.FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal)
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.Size = UDim2.new(0, 180, 0, 34)
    TitleLabel.Position = UDim2.new(0, 2, 0, 0)
    TitleLabel.Text = titleText
    TitleLabel.Parent = Header

    -- Collapse Button (No Tweening)
    local CollapseButton = Instance.new("TextButton")
    CollapseButton.Name = "OpenUi/CloseUi"
    CollapseButton.TextWrapped = true
    CollapseButton.BorderSizePixel = 0
    CollapseButton.TextScaled = true
    CollapseButton.TextColor3 = Color3.fromRGB(180, 180, 180)
    CollapseButton.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
    CollapseButton.Size = UDim2.new(0, 26, 0, 34)
    CollapseButton.Position = UDim2.new(0, 182, 0, 0)
    CollapseButton.Text = "▲"
    CollapseButton.Parent = Header

    -- Content Scrolling Frame
    local ScrollingFrame = Instance.new("ScrollingFrame")
    ScrollingFrame.Name = "Content"
    ScrollingFrame.BorderSizePixel = 0
    ScrollingFrame.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
    ScrollingFrame.BackgroundTransparency = 1
    ScrollingFrame.Position = UDim2.new(0, 0, 0, 34)
    ScrollingFrame.Size = UDim2.new(1, 0, 1, -34)
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
    UIPadding.PaddingLeft = UDim.new(0, 3)
    UIPadding.PaddingRight = UDim.new(0, 3)
    UIPadding.PaddingBottom = UDim.new(0, 6)
    UIPadding.Parent = ScrollingFrame

    -- Main Dragging Logic
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

    -- Auto Size & Collapse Logic
    local collapsed = false
    local lastExpandedHeight = 250

    local function updateWindowSize()
        if not collapsed then
            local contentHeight = UIListLayout.AbsoluteContentSize.Y + 44
            lastExpandedHeight = math.clamp(contentHeight, 40, 600)
            MainFrame.Size = UDim2.new(0, 210, 0, lastExpandedHeight)
        end
    end

    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateWindowSize)

    CollapseButton.MouseButton1Click:Connect(function()
        collapsed = not collapsed
        if collapsed then
            CollapseButton.Text = "▼"
            MainFrame.Size = UDim2.new(0, 210, 0, 34)
        else
            CollapseButton.Text = "▲"
            MainFrame.Size = UDim2.new(0, 210, 0, lastExpandedHeight)
        end
    end)

    -- Helper to disable scrolling frame lock
    local function setScrollLock(locked)
        ScrollingFrame.ScrollingEnabled = not locked
    end

    ----------------------------------------------------------------------------
    -- LIBRARY ELEMENTS
    ----------------------------------------------------------------------------
    local Tab = {}

    -- 1. BUTTON
    function Tab:AddButton(options)
        options = options or {}
        local text = options.text or "Click The Button!"
        local callback = options.callback or function() end

        local Button = Instance.new("TextButton")
        Button.Name = "Button"
        Button.TextWrapped = true
        Button.BorderSizePixel = 0
        Button.TextSize = 15
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.BackgroundColor3 = Color3.fromRGB(48, 48, 48)
        Button.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal)
        Button.Size = UDim2.new(1, 0, 0, 30)
        Button.Text = text
        Button.Parent = ScrollingFrame

        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 3)
        UICorner.Parent = Button

        Button.MouseButton1Click:Connect(function()
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
        ToggleLabel.BorderSizePixel = 0
        ToggleLabel.TextSize = 15
        ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        ToggleLabel.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
        ToggleLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal)
        ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleLabel.Size = UDim2.new(1, -34, 1, 0)
        ToggleLabel.Text = text
        ToggleLabel.Parent = ToggleRow

        local ToggleIndicator = Instance.new("Frame")
        ToggleIndicator.Name = "ToggleIndicator"
        ToggleIndicator.BorderSizePixel = 0
        ToggleIndicator.BackgroundColor3 = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        ToggleIndicator.Size = UDim2.new(0, 28, 0, 28)
        ToggleIndicator.Position = UDim2.new(1, -28, 0, 2)
        ToggleIndicator.Parent = ToggleRow

        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 4)
        UICorner.Parent = ToggleIndicator

        local UIStroke = Instance.new("UIStroke")
        UIStroke.Thickness = 1
        UIStroke.Color = Color3.fromRGB(91, 91, 91)
        UIStroke.Parent = ToggleIndicator

        local function updateToggle(val)
            state = val
            if flag then Library.Flags[flag] = state end
            ToggleIndicator.BackgroundColor3 = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            callback(state)
        end

        local startTouchPos = nil

        ToggleRow.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                startTouchPos = input.Position
            end
        end)

        ToggleRow.Activated:Connect(function(input)
            if startTouchPos and input.Position then
                local dist = (input.Position - startTouchPos).Magnitude
                if dist > 15 then
                    return
                end
            end
            updateToggle(not state)
        end)

        if flag then Library.Flags[flag] = state end

        return ToggleRow
    end

    -- 3. LABEL
    function Tab:AddLabel(options)
        options = options or {}
        local text = options.text or "This Is Sick!"

        local Label = Instance.new("TextLabel")
        Label.Name = "Label"
        Label.BorderSizePixel = 0
        Label.TextSize = 15
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
        Label.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal)
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.Size = UDim2.new(1, 0, 0, 28)
        Label.Text = text
        Label.Parent = ScrollingFrame

        return Label
    end

    -- 4. INPUT (TEXTBOX)
    function Tab:AddInput(options)
        options = options or {}
        local placeholder = options.placeholder or "Add Wins"
        local flag = options.flag
        local callback = options.callback or function() end

        local InputContainer = Instance.new("Frame")
        InputContainer.Name = "InputContainer"
        InputContainer.Size = UDim2.new(1, 0, 0, 36)
        InputContainer.BackgroundTransparency = 1
        InputContainer.Parent = ScrollingFrame

        local InputBox = Instance.new("TextBox")
        InputBox.Name = "InputBox"
        InputBox.BorderSizePixel = 2
        InputBox.TextWrapped = true
        InputBox.TextSize = 16
        InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        InputBox.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
        InputBox.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal)
        InputBox.PlaceholderText = placeholder
        InputBox.Size = UDim2.new(1, 0, 1, 0)
        InputBox.BorderColor3 = Color3.fromRGB(61, 61, 61)
        InputBox.Text = ""
        InputBox.Parent = InputContainer

        local TextLabel = Instance.new("TextLabel")
        TextLabel.Name = "Label"
        TextLabel.TextStrokeTransparency = 0
        TextLabel.BorderSizePixel = 0
        TextLabel.TextSize = 11
        TextLabel.TextTransparency = 0.5
        TextLabel.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
        TextLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal)
        TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel.Size = UDim2.new(0, 70, 0, 12)
        TextLabel.Position = UDim2.new(0, 4, 0, -6)
        TextLabel.Text = placeholder
        TextLabel.Parent = InputBox

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

        return InputContainer
    end

    -- 5. KEYBIND
    function Tab:AddBind(options)
        options = options or {}
        local text = options.text or "KEYBIND"
        local key = options.key or "X"
        local hold = options.hold or false
        local flag = options.flag
        local callback = options.callback or function() end

        local currentKey = Enum.KeyCode[key] or Enum.KeyCode.X
        local binding = false

        local Keybind = Instance.new("TextLabel")
        Keybind.Name = "Keybind"
        Keybind.BorderSizePixel = 0
        Keybind.TextSize = 15
        Keybind.TextXAlignment = Enum.TextXAlignment.Left
        Keybind.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
        Keybind.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal)
        Keybind.TextColor3 = Color3.fromRGB(255, 255, 255)
        Keybind.Size = UDim2.new(1, 0, 0, 30)
        Keybind.Text = text
        Keybind.Parent = ScrollingFrame

        local BindFrame = Instance.new("Frame")
        BindFrame.Name = "BindFrame"
        BindFrame.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
        BindFrame.Size = UDim2.new(0, 42, 0, 28)
        BindFrame.Position = UDim2.new(1, -42, 0, 1)
        BindFrame.BorderColor3 = Color3.fromRGB(56, 56, 56)
        BindFrame.Parent = Keybind

        local UICorner_6 = Instance.new("UICorner")
        UICorner_6.CornerRadius = UDim.new(0, 4)
        UICorner_6.Parent = BindFrame

        local KeybindBtn = Instance.new("TextButton")
        KeybindBtn.Name = "TextButton"
        KeybindBtn.BorderSizePixel = 0
        KeybindBtn.TextSize = 13
        KeybindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        KeybindBtn.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
        KeybindBtn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy, Enum.FontStyle.Normal)
        KeybindBtn.Size = UDim2.new(1, 0, 1, 0)
        KeybindBtn.Text = currentKey.Name
        KeybindBtn.Parent = BindFrame

        local UIStroke_9 = Instance.new("UIStroke")
        UIStroke_9.Thickness = 2
        UIStroke_9.Color = Color3.fromRGB(56, 56, 56)
        UIStroke_9.Parent = BindFrame

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

        return Keybind
    end

    -- 6. SLIDER
    function Tab:AddSlider(options)
        options = options or {}
        local text = options.text or "Fov"
        local min = options.min or 70
        local max = options.max or 170
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
        SliderLabel.TextSize = 14
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
        Track.Position = UDim2.new(0, 0, 0, 22)
        Track.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        Track.BorderSizePixel = 0
        Track.Parent = SliderContainer

        local TrackCorner = Instance.new("UICorner")
        TrackCorner.CornerRadius = UDim.new(0, 4)
        TrackCorner.Parent = Track

        local Fill = Instance.new("Frame")
        Fill.Name = "SliderFill"
        Fill.Size = UDim2.new((currentValue - min) / (max - min), 0, 1, 0)
        Fill.BackgroundColor3 = Color3.fromRGB(130, 130, 130)
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
        local startInputPos = nil
        local targetPercent = (currentValue - min) / (max - min)

        local function updateValue(val)
            currentValue = math.clamp(math.round(val), min, max)
            ValueBox.Text = tostring(currentValue)
            if flag then Library.Flags[flag] = currentValue end
            callback(currentValue)
        end

        RunService.RenderStepped:Connect(function(dt)
            if math.abs(Fill.Size.X.Scale - targetPercent) > 0.001 then
                local nextPercent = math.clamp(Fill.Size.X.Scale + (targetPercent - Fill.Size.X.Scale) * math.clamp(dt * 20, 0, 1), 0, 1)
                Fill.Size = UDim2.new(nextPercent, 0, 1, 0)
            end
        end)

        Track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                draggingSlider = true
                startInputPos = input.Position
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local moveDist = (input.Position - startInputPos).Magnitude
                if moveDist > 15 then
                    setScrollLock(true)
                end
                
                local posX = input.Position.X - Track.AbsolutePosition.X
                targetPercent = math.clamp(posX / Track.AbsoluteSize.X, 0, 1)
                updateValue(min + (max - min) * targetPercent)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if draggingSlider then
                    draggingSlider = false
                    setScrollLock(false)
                    startInputPos = nil
                end
            end
        end)

        ValueBox.FocusLost:Connect(function()
            local num = tonumber(ValueBox.Text)
            if num then
                currentValue = math.clamp(math.round(num), min, max)
                targetPercent = (currentValue - min) / (max - min)
                updateValue(currentValue)
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

    Library.ScreenGui = ScreenGui
    return Tab
end

function Library:Init()
end

function Library:Close()
    if Library.ScreenGui then
        Library.ScreenGui:Destroy()
    end
    Library.Unloaded = true
end

return Library

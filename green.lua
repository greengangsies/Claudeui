-- UI Library v1.0 - FIXED with your notification UI
-- Full-featured UI library for exploit development

local Library = {}
Library.__index = Library

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- Compatibility function for ScreenGui parent
local function getScreenGuiParent()
    if gethui then
        return gethui()
    elseif syn and syn.protect_gui then
        local gui = Instance.new("ScreenGui")
        syn.protect_gui(gui)
        gui.Parent = game:GetService("CoreGui")
        return game:GetService("CoreGui")
    else
        return Players.LocalPlayer:WaitForChild("PlayerGui")
    end
end

-- Create main library object
function Library:New()
    local library = setmetatable({}, Library)
    library.Windows = {}
    return library
end

-- Notification System (Using your exact UI)
function Library:Notify(options)
    local title = options.Title or "Notification"
    local description = options.Description or ""
    local type = options.Type or "Success" -- "Success" or "Error"
    local duration = options.Duration or 3
    
    local screenGuiParent = getScreenGuiParent()
    local ScreenGui = screenGuiParent:FindFirstChild("LibraryNotifications")
    
    if not ScreenGui then
        ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "LibraryNotifications"
        ScreenGui.Parent = screenGuiParent
        ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        ScreenGui.ResetOnSpawn = false
    end
    
    -- Using your exact notification structure
    local Notification = Instance.new("Frame")
    local TweenFrame = Instance.new("Frame")
    local UIGradient = Instance.new("UIGradient")
    local Icon = Instance.new("TextLabel")
    local Title = Instance.new("TextLabel")
    local Description = Instance.new("TextLabel")
    local UICorner = Instance.new("UICorner")
    
    -- Properties based on your code
    Notification.Name = type == "Success" and "Successful Notification" or "UnSuccessful Notification"
    Notification.Parent = ScreenGui
    Notification.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
    Notification.BackgroundTransparency = 0.150
    Notification.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Notification.BorderSizePixel = 0
    Notification.Position = UDim2.new(1.1, 0, 0.265423238, 0)
    Notification.Size = UDim2.new(0, 271, 0, 73)
    
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = Notification
    
    TweenFrame.Name = "Tween Frame[Frame That represents the time left before the ui fades out]"
    TweenFrame.Parent = Notification
    TweenFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TweenFrame.BackgroundTransparency = 0.150
    TweenFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TweenFrame.BorderSizePixel = 0
    TweenFrame.Position = UDim2.new(0, 0, 1, 0)
    TweenFrame.Size = UDim2.new(0, 271, 0, 3)
    
    if type == "Success" then
        UIGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(141, 255, 27)),
            ColorSequenceKeypoint.new(0.46, Color3.fromRGB(166, 255, 134)),
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 132, 37))
        }
        Icon.Text = "✓"
        Icon.TextColor3 = Color3.fromRGB(141, 255, 27)
    else
        UIGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 25, 48)),
            ColorSequenceKeypoint.new(0.46, Color3.fromRGB(255, 88, 91)),
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(132, 0, 2))
        }
        Icon.Text = "X"
        Icon.TextColor3 = Color3.fromRGB(255, 25, 48)
    end
    UIGradient.Parent = TweenFrame
    
    Icon.Name = "Icon"
    Icon.Parent = Notification
    Icon.BackgroundTransparency = 1.000
    Icon.Position = UDim2.new(0, 12, 0, 12)
    Icon.Size = UDim2.new(0, 24, 0, 24)
    Icon.Font = Enum.Font.GothamBold
    Icon.TextSize = 22.000
    
    Title.Name = "Title"
    Title.Parent = Notification
    Title.BackgroundTransparency = 1.000
    Title.Position = UDim2.new(0, 44, 0, 10)
    Title.Size = UDim2.new(0, 215, 0, 20)
    Title.Font = Enum.Font.GothamBold
    Title.Text = title
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16.000
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    Description.Name = "Description"
    Description.Parent = Notification
    Description.BackgroundTransparency = 1.000
    Description.Position = UDim2.new(0, 44, 0, 32)
    Description.Size = UDim2.new(0, 215, 0, 32)
    Description.Font = Enum.Font.Gotham
    Description.Text = description
    Description.TextColor3 = Color3.fromRGB(200, 200, 200)
    Description.TextSize = 13.000
    Description.TextWrapped = true
    Description.TextXAlignment = Enum.TextXAlignment.Left
    Description.TextYAlignment = Enum.TextYAlignment.Top
    
    -- Slide in animation
    Notification:TweenPosition(
        UDim2.new(0.740917802, 0, 0.265423238, 0),
        Enum.EasingDirection.Out,
        Enum.EasingStyle.Quad,
        0.5,
        true
    )
    
    -- Timer bar animation (shrinks from right to left)
    TweenFrame:TweenSize(
        UDim2.new(0, 0, 0, 3),
        Enum.EasingDirection.InOut,
        Enum.EasingStyle.Linear,
        duration,
        true
    )
    
    -- Fade out and destroy
    task.wait(duration)
    Notification:TweenPosition(
        UDim2.new(1.1, 0, 0.265423238, 0),
        Enum.EasingDirection.In,
        Enum.EasingStyle.Quad,
        0.5,
        true,
        function()
            Notification:Destroy()
        end
    )
end

-- Create Window
function Library:CreateWindow(windowTitle)
    local window = {}
    window.Title = windowTitle or "UI Library v1.0"
    window.Tabs = {}
    window.CurrentTab = nil
    
    -- Create ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "LibraryGui"
    ScreenGui.Parent = getScreenGuiParent()
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    -- Main Window Frame
    local MainWindow = Instance.new("Frame")
    local UICorner = Instance.new("UICorner")
    local Line = Instance.new("Frame")
    local UIGradient = Instance.new("UIGradient")
    local LineGlow = Instance.new("ImageLabel")
    local TopBar = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local CloseButton = Instance.new("TextButton")
    local MinimizeButton = Instance.new("TextButton")
    local Sidebar = Instance.new("Frame")
    local SidebarUICorner = Instance.new("UICorner")
    local SidebarTitle = Instance.new("TextLabel")
    local TabContainer = Instance.new("ScrollingFrame")
    local TabUIListLayout = Instance.new("UIListLayout")
    local ContentFrame = Instance.new("Frame")
    
    MainWindow.Name = "MainWindow"
    MainWindow.Parent = ScreenGui
    MainWindow.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    MainWindow.BackgroundTransparency = 0.05
    MainWindow.BorderSizePixel = 0
    MainWindow.Position = UDim2.new(0.5, -337, 0.5, -225)
    MainWindow.Size = UDim2.new(0, 674, 0, 450)
    MainWindow.Active = true
    MainWindow.Draggable = true
    
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = MainWindow
    
    -- Top gradient line
    Line.Name = "Line"
    Line.Parent = MainWindow
    Line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Line.BorderSizePixel = 0
    Line.Size = UDim2.new(1, 0, 0, 3)
    
    UIGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(141, 255, 27)),
        ColorSequenceKeypoint.new(0.46, Color3.fromRGB(166, 255, 134)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 132, 37))
    }
    UIGradient.Parent = Line
    
    LineGlow.Name = "LineGlow"
    LineGlow.Parent = Line
    LineGlow.BackgroundTransparency = 1
    LineGlow.Position = UDim2.new(0, 0, 0, -10)
    LineGlow.Size = UDim2.new(1, 0, 0, 23)
    LineGlow.Image = "rbxassetid://4996891970"
    LineGlow.ImageColor3 = Color3.fromRGB(141, 255, 27)
    LineGlow.ImageTransparency = 0.5
    LineGlow.ScaleType = Enum.ScaleType.Slice
    LineGlow.SliceCenter = Rect.new(128, 128, 128, 128)
    
    -- Top bar
    TopBar.Name = "TopBar"
    TopBar.Parent = MainWindow
    TopBar.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
    TopBar.BorderSizePixel = 0
    TopBar.Position = UDim2.new(0, 0, 0.00667, 0)
    TopBar.Size = UDim2.new(1, 0, 0, 35)
    
    Title.Name = "Title"
    Title.Parent = TopBar
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.Size = UDim2.new(0, 250, 0, 35)
    Title.Font = Enum.Font.GothamBold
    Title.Text = window.Title
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 15
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    CloseButton.Name = "CloseButton"
    CloseButton.Parent = TopBar
    CloseButton.BackgroundTransparency = 1
    CloseButton.Position = UDim2.new(1, -40, 0, 0)
    CloseButton.Size = UDim2.new(0, 35, 0, 35)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "×"
    CloseButton.TextColor3 = Color3.fromRGB(255, 85, 85)
    CloseButton.TextSize = 22
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Parent = TopBar
    MinimizeButton.BackgroundTransparency = 1
    MinimizeButton.Position = UDim2.new(1, -75, 0, 0)
    MinimizeButton.Size = UDim2.new(0, 35, 0, 35)
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.Text = "_"
    MinimizeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    MinimizeButton.TextSize = 16
    
    local minimized = false
    local originalSize = MainWindow.Size
    MinimizeButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            MainWindow:TweenSize(UDim2.new(0, 674, 0, 38), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
        else
            MainWindow:TweenSize(originalSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
        end
    end)
    
    -- Sidebar
    Sidebar.Name = "Sidebar"
    Sidebar.Parent = MainWindow
    Sidebar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Sidebar.BorderSizePixel = 0
    Sidebar.Position = UDim2.new(0, 0, 0.0844, 0)
    Sidebar.Size = UDim2.new(0, 163, 0, 412)
    
    SidebarUICorner.CornerRadius = UDim.new(0, 0)
    SidebarUICorner.Parent = Sidebar
    
    SidebarTitle.Name = "SidebarTitle"
    SidebarTitle.Parent = Sidebar
    SidebarTitle.BackgroundTransparency = 1
    SidebarTitle.Position = UDim2.new(0, 15, 0, 15)
    SidebarTitle.Size = UDim2.new(1, -30, 0, 25)
    SidebarTitle.Font = Enum.Font.GothamBold
    SidebarTitle.Text = "Tabs"
    SidebarTitle.TextColor3 = Color3.fromRGB(141, 255, 27)
    SidebarTitle.TextSize = 13
    SidebarTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    TabContainer.Name = "TabContainer"
    TabContainer.Parent = Sidebar
    TabContainer.BackgroundTransparency = 1
    TabContainer.BorderSizePixel = 0
    TabContainer.Position = UDim2.new(0, 0, 0, 50)
    TabContainer.Size = UDim2.new(1, 0, 1, -50)
    TabContainer.ScrollBarThickness = 4
    TabContainer.ScrollBarImageColor3 = Color3.fromRGB(141, 255, 27)
    TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    TabUIListLayout.Parent = TabContainer
    TabUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabUIListLayout.Padding = UDim.new(0, 5)
    
    TabUIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabUIListLayout.AbsoluteContentSize.Y + 10)
    end)
    
    -- Content Frame
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Parent = MainWindow
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Position = UDim2.new(0.242, 0, 0.0844, 0)
    ContentFrame.Size = UDim2.new(0.758, 0, 0.916, 0)
    
    window.MainWindow = MainWindow
    window.ContentFrame = ContentFrame
    window.TabContainer = TabContainer
    window.ScreenGui = ScreenGui
    
    -- Create Tab function
    function window:CreateTab(tabName)
        local tab = {}
        tab.Name = tabName
        tab.Sections = {}
        tab.Window = window
        
        -- Tab Button
        local TabButton = Instance.new("TextButton")
        local TabUICorner = Instance.new("UICorner")
        
        TabButton.Name = tabName .. "Tab"
        TabButton.Parent = TabContainer
        TabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        TabButton.BorderSizePixel = 0
        TabButton.Size = UDim2.new(1, -10, 0, 35)
        TabButton.Font = Enum.Font.GothamSemibold
        TabButton.Text = "  " .. tabName
        TabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        TabButton.TextSize = 13
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        
        TabUICorner.CornerRadius = UDim.new(0, 4)
        TabUICorner.Parent = TabButton
        
        -- Tab Content
        local TabContent = Instance.new("ScrollingFrame")
        local ContentUIListLayout = Instance.new("UIListLayout")
        
        TabContent.Name = tabName .. "Content"
        TabContent.Parent = ContentFrame
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.Size = UDim2.new(1, -20, 1, -20)
        TabContent.Position = UDim2.new(0, 10, 0, 10)
        TabContent.ScrollBarThickness = 6
        TabContent.ScrollBarImageColor3 = Color3.fromRGB(141, 255, 27)
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabContent.Visible = false
        
        ContentUIListLayout.Parent = TabContent
        ContentUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentUIListLayout.Padding = UDim.new(0, 15)
        
        ContentUIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentUIListLayout.AbsoluteContentSize.Y + 20)
        end)
        
        tab.TabButton = TabButton
        tab.TabContent = TabContent
        
        -- Tab selection function
        local function selectTab()
            for _, t in pairs(window.Tabs) do
                t.TabContent.Visible = false
                t.TabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                t.TabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
            
            TabContent.Visible = true
            TabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            TabButton.TextColor3 = Color3.fromRGB(141, 255, 27)
            window.CurrentTab = tab
        end
        
        tab.Select = selectTab
        
        TabButton.MouseButton1Click:Connect(selectTab)
        
        -- Create Section function
        function tab:CreateSection(sectionName)
            local section = {}
            section.Name = sectionName
            section.Elements = {}
            
            local SectionFrame = Instance.new("Frame")
            local SectionTitle = Instance.new("TextLabel")
            local ElementContainer = Instance.new("Frame")
            local ElementUIListLayout = Instance.new("UIListLayout")
            
            SectionFrame.Name = sectionName .. "Section"
            SectionFrame.Parent = TabContent
            SectionFrame.BackgroundTransparency = 1
            SectionFrame.Size = UDim2.new(1, 0, 0, 50)
            
            SectionTitle.Name = "SectionTitle"
            SectionTitle.Parent = SectionFrame
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.Size = UDim2.new(1, 0, 0, 25)
            SectionTitle.Font = Enum.Font.GothamBold
            SectionTitle.Text = sectionName
            SectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
            SectionTitle.TextSize = 14
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            
            ElementContainer.Name = "ElementContainer"
            ElementContainer.Parent = SectionFrame
            ElementContainer.BackgroundTransparency = 1
            ElementContainer.Position = UDim2.new(0, 0, 0, 30)
            ElementContainer.Size = UDim2.new(1, 0, 1, -30)
            
            ElementUIListLayout.Parent = ElementContainer
            ElementUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ElementUIListLayout.Padding = UDim.new(0, 8)
            
            ElementUIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                SectionFrame.Size = UDim2.new(1, 0, 0, ElementUIListLayout.AbsoluteContentSize.Y + 35)
            end)
            
            section.Container = ElementContainer
            
            -- Create Button
            function section:CreateButton(options)
                local buttonText = options.Text or options.Name or "Button"
                local callback = options.Callback or function() end
                
                local Button = Instance.new("TextButton")
                local ButtonUICorner = Instance.new("UICorner")
                local ButtonUIStroke = Instance.new("UIStroke")
                
                Button.Name = "Button"
                Button.Parent = ElementContainer
                Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                Button.BorderSizePixel = 0
                Button.Size = UDim2.new(1, 0, 0, 35)
                Button.Font = Enum.Font.GothamSemibold
                Button.Text = buttonText
                Button.TextColor3 = Color3.fromRGB(141, 255, 27)
                Button.TextSize = 13
                
                ButtonUICorner.CornerRadius = UDim.new(0, 4)
                ButtonUICorner.Parent = Button
                
                ButtonUIStroke.Name = "Bloom"
                ButtonUIStroke.Parent = Button
                ButtonUIStroke.Color = Color3.fromRGB(141, 255, 27)
                ButtonUIStroke.Thickness = 0
                ButtonUIStroke.Transparency = 0.7
                
                Button.MouseEnter:Connect(function()
                    ButtonUIStroke.Thickness = 1
                    Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                end)
                
                Button.MouseLeave:Connect(function()
                    ButtonUIStroke.Thickness = 0
                    Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                end)
                
                Button.MouseButton1Click:Connect(callback)
                
                return Button
            end
            
            -- Create Toggle
            function section:CreateToggle(options)
                local toggleText = options.Text or options.Name or "Toggle"
                local default = options.Default or false
                local callback = options.Callback or function() end
                
                local ToggleFrame = Instance.new("Frame")
                local Label = Instance.new("TextLabel")
                local ToggleButton = Instance.new("TextButton")
                local ToggleUICorner = Instance.new("UICorner")
                local Switch = Instance.new("Frame")
                local SwitchUICorner = Instance.new("UICorner")
                local SwitchUIStroke = Instance.new("UIStroke")
                
                ToggleFrame.Name = "Toggle"
                ToggleFrame.Parent = ElementContainer
                ToggleFrame.BackgroundTransparency = 1
                ToggleFrame.Size = UDim2.new(1, 0, 0, 35)
                
                Label.Name = "Label"
                Label.Parent = ToggleFrame
                Label.BackgroundTransparency = 1
                Label.Size = UDim2.new(0.7, 0, 1, 0)
                Label.Font = Enum.Font.Gotham
                Label.Text = toggleText
                Label.TextColor3 = Color3.fromRGB(220, 220, 220)
                Label.TextSize = 13
                Label.TextXAlignment = Enum.TextXAlignment.Left
                
                ToggleButton.Name = "ToggleButton"
                ToggleButton.Parent = ToggleFrame
                ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                ToggleButton.BorderSizePixel = 0
                ToggleButton.Position = UDim2.new(1, -55, 0, 5)
                ToggleButton.Size = UDim2.new(0, 50, 0, 24)
                ToggleButton.Text = ""
                
                ToggleUICorner.CornerRadius = UDim.new(1, 0)
                ToggleUICorner.Parent = ToggleButton
                
                Switch.Name = "Switch"
                Switch.Parent = ToggleButton
                Switch.BackgroundColor3 = default and Color3.fromRGB(141, 255, 27) or Color3.fromRGB(100, 100, 100)
                Switch.BorderSizePixel = 0
                Switch.Position = default and UDim2.new(0, 28, 0, 2) or UDim2.new(0, 2, 0, 2)
                Switch.Size = UDim2.new(0, 20, 0, 20)
                
                SwitchUICorner.CornerRadius = UDim.new(1, 0)
                SwitchUICorner.Parent = Switch
                
                SwitchUIStroke.Name = "Bloom"
                SwitchUIStroke.Parent = Switch
                SwitchUIStroke.Color = Color3.fromRGB(141, 255, 27)
                SwitchUIStroke.Thickness = default and 2 or 0
                SwitchUIStroke.Transparency = 0.5
                
                local toggled = default
                
                ToggleButton.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    
                    Switch:TweenPosition(
                        toggled and UDim2.new(0, 28, 0, 2) or UDim2.new(0, 2, 0, 2),
                        Enum.EasingDirection.Out,
                        Enum.EasingStyle.Quad,
                        0.2,
                        true
                    )
                    
                    TweenService:Create(Switch, TweenInfo.new(0.2), {
                        BackgroundColor3 = toggled and Color3.fromRGB(141, 255, 27) or Color3.fromRGB(100, 100, 100)
                    }):Play()
                    
                    SwitchUIStroke.Thickness = toggled and 2 or 0
                    
                    callback(toggled)
                end)
                
                local toggleObj = {}
                function toggleObj:Set(value)
                    toggled = value
                    Switch.Position = toggled and UDim2.new(0, 28, 0, 2) or UDim2.new(0, 2, 0, 2)
                    Switch.BackgroundColor3 = toggled and Color3.fromRGB(141, 255, 27) or Color3.fromRGB(100, 100, 100)
                    SwitchUIStroke.Thickness = toggled and 2 or 0
                    callback(toggled)
                end
                
                return toggleObj
            end
            
            -- Create Slider
            function section:CreateSlider(options)
                local sliderText = options.Text or options.Name or "Slider"
                local min = options.Min or 0
                local max = options.Max or 100
                local default = options.Default or 50
                local increment = options.Increment or 1
                local callback = options.Callback or function() end
                
                local SliderFrame = Instance.new("Frame")
                local Label = Instance.new("TextLabel")
                local Value = Instance.new("TextLabel")
                local Track = Instance.new("Frame")
                local TrackUICorner = Instance.new("UICorner")
                local Fill = Instance.new("Frame")
                local FillUICorner = Instance.new("UICorner")
                local FillUIStroke = Instance.new("UIStroke")
                local SliderButton = Instance.new("TextButton")
                local SliderButtonUICorner = Instance.new("UICorner")
                local SliderButtonUIStroke = Instance.new("UIStroke")
                
                SliderFrame.Name = "Slider"
                SliderFrame.Parent = ElementContainer
                SliderFrame.BackgroundTransparency = 1
                SliderFrame.Size = UDim2.new(1, 0, 0, 45)
                
                Label.Name = "Label"
                Label.Parent = SliderFrame
                Label.BackgroundTransparency = 1
                Label.Size = UDim2.new(0.6, 0, 0, 20)
                Label.Font = Enum.Font.Gotham
                Label.Text = sliderText
                Label.TextColor3 = Color3.fromRGB(220, 220, 220)
                Label.TextSize = 13
                Label.TextXAlignment = Enum.TextXAlignment.Left
                
                Value.Name = "Value"
                Value.Parent = SliderFrame
                Value.BackgroundTransparency = 1
                Value.Position = UDim2.new(1, -50, 0, 0)
                Value.Size = UDim2.new(0, 50, 0, 20)
                Value.Font = Enum.Font.GothamSemibold
                Value.Text = tostring(default)
                Value.TextColor3 = Color3.fromRGB(141, 255, 27)
                Value.TextSize = 13
                Value.TextXAlignment = Enum.TextXAlignment.Right
                
                Track.Name = "Track"
                Track.Parent = SliderFrame
                Track.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                Track.BorderSizePixel = 0
                Track.Position = UDim2.new(0, 0, 0, 28)
                Track.Size = UDim2.new(1, 0, 0, 6)
                
                TrackUICorner.CornerRadius = UDim.new(1, 0)
                TrackUICorner.Parent = Track
                
                Fill.Name = "Fill"
                Fill.Parent = Track
                Fill.BackgroundColor3 = Color3.fromRGB(141, 255, 27)
                Fill.BorderSizePixel = 0
                Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                
                FillUICorner.CornerRadius = UDim.new(1, 0)
                FillUICorner.Parent = Fill
                
                FillUIStroke.Name = "Bloom"
                FillUIStroke.Parent = Fill
                FillUIStroke.Color = Color3.fromRGB(141, 255, 27)
                FillUIStroke.Thickness = 1.5
                FillUIStroke.Transparency = 0.3
                
                SliderButton.Name = "Button"
                SliderButton.Parent = Track
                SliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SliderButton.BorderSizePixel = 0
                SliderButton.Position = UDim2.new((default - min) / (max - min), -8, 0, -5)
                SliderButton.Size = UDim2.new(0, 16, 0, 16)
                SliderButton.Text = ""
                
                SliderButtonUICorner.CornerRadius = UDim.new(1, 0)
                SliderButtonUICorner.Parent = SliderButton
                
                SliderButtonUIStroke.Name = "Bloom"
                SliderButtonUIStroke.Parent = SliderButton
                SliderButtonUIStroke.Color = Color3.fromRGB(141, 255, 27)
                SliderButtonUIStroke.Thickness = 2
                SliderButtonUIStroke.Transparency = 0.4
                
                local dragging = false
                local currentValue = default
                
                local function updateSlider(input)
                    local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                    currentValue = math.floor((min + (max - min) * pos) / increment + 0.5) * increment
                    currentValue = math.clamp(currentValue, min, max)
                    
                    Fill.Size = UDim2.new(pos, 0, 1, 0)
                    SliderButton.Position = UDim2.new(pos, -8, 0, -5)
                    Value.Text = tostring(currentValue)
                    
                    callback(currentValue)
                end
                
                SliderButton.MouseButton1Down:Connect(function()
                    dragging = true
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        updateSlider(input)
                    end
                end)
                
                Track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        updateSlider(input)
                    end
                end)
                
                local sliderObj = {}
                function sliderObj:Set(value)
                    currentValue = math.clamp(value, min, max)
                    local pos = (currentValue - min) / (max - min)
                    Fill.Size = UDim2.new(pos, 0, 1, 0)
                    SliderButton.Position = UDim2.new(pos, -8, 0, -5)
                    Value.Text = tostring(currentValue)
                    callback(currentValue)
                end
                
                return sliderObj
            end
            
            -- Create Input
            function section:CreateInput(options)
                local inputText = options.Text or options.Name or "Input"
                local placeholder = options.Placeholder or "Enter text..."
                local default = options.Default or ""
                local callback = options.Callback or function() end
                
                local InputFrame = Instance.new("Frame")
                local Label = Instance.new("TextLabel")
                local InputBox = Instance.new("TextBox")
                local InputUICorner = Instance.new("UICorner")
                local InputUIStroke = Instance.new("UIStroke")
                
                InputFrame.Name = "Input"
                InputFrame.Parent = ElementContainer
                InputFrame.BackgroundTransparency = 1
                InputFrame.Size = UDim2.new(1, 0, 0, 62)
                
                Label.Name = "Label"
                Label.Parent = InputFrame
                Label.BackgroundTransparency = 1
                Label.Size = UDim2.new(1, 0, 0, 20)
                Label.Font = Enum.Font.Gotham
                Label.Text = inputText
                Label.TextColor3 = Color3.fromRGB(220, 220, 220)
                Label.TextSize = 13
                Label.TextXAlignment = Enum.TextXAlignment.Left
                
                InputBox.Name = "InputBox"
                InputBox.Parent = InputFrame
                InputBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                InputBox.BorderSizePixel = 0
                InputBox.Position = UDim2.new(0, 0, 0, 25)
                InputBox.Size = UDim2.new(1, 0, 0, 32)
                InputBox.Font = Enum.Font.Gotham
                InputBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
                InputBox.PlaceholderText = placeholder
                InputBox.Text = default
                InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                InputBox.TextSize = 13
                InputBox.TextXAlignment = Enum.TextXAlignment.Left
                InputBox.ClearTextOnFocus = false
                
                InputUICorner.CornerRadius = UDim.new(0, 4)
                InputUICorner.Parent = InputBox
                
                InputUIStroke.Name = "Bloom"
                InputUIStroke.Parent = InputBox
                InputUIStroke.Color = Color3.fromRGB(141, 255, 27)
                InputUIStroke.Thickness = 0
                InputUIStroke.Transparency = 0.8
                
                InputBox.Focused:Connect(function()
                    InputUIStroke.Thickness = 1
                end)
                
                InputBox.FocusLost:Connect(function()
                    InputUIStroke.Thickness = 0
                    callback(InputBox.Text)
                end)
                
                local inputObj = {}
                function inputObj:Set(text)
                    InputBox.Text = text
                    callback(text)
                end
                
                return inputObj
            end
            
            -- Create Dropdown
            function section:CreateDropdown(options)
                local dropdownText = options.Text or options.Name or "Dropdown"
                local list = options.List or {"Option 1", "Option 2", "Option 3"}
                local default = options.Default or list[1]
                local callback = options.Callback or function() end
                
                local DropdownFrame = Instance.new("Frame")
                local Label = Instance.new("TextLabel")
                local DropdownButton = Instance.new("TextButton")
                local DropdownUICorner = Instance.new("UICorner")
                local Arrow = Instance.new("TextLabel")
                local DropdownList = Instance.new("Frame")
                local ListUICorner = Instance.new("UICorner")
                local ListContainer = Instance.new("ScrollingFrame")
                local ListUIListLayout = Instance.new("UIListLayout")
                
                DropdownFrame.Name = "Dropdown"
                DropdownFrame.Parent = ElementContainer
                DropdownFrame.BackgroundTransparency = 1
                DropdownFrame.Size = UDim2.new(1, 0, 0, 62)
                DropdownFrame.ClipsDescendants = true
                
                Label.Name = "Label"
                Label.Parent = DropdownFrame
                Label.BackgroundTransparency = 1
                Label.Size = UDim2.new(1, 0, 0, 20)
                Label.Font = Enum.Font.Gotham
                Label.Text = dropdownText
                Label.TextColor3 = Color3.fromRGB(220, 220, 220)
                Label.TextSize = 13
                Label.TextXAlignment = Enum.TextXAlignment.Left
                
                DropdownButton.Name = "Button"
                DropdownButton.Parent = DropdownFrame
                DropdownButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                DropdownButton.BorderSizePixel = 0
                DropdownButton.Position = UDim2.new(0, 0, 0, 25)
                DropdownButton.Size = UDim2.new(1, 0, 0, 32)
                DropdownButton.Font = Enum.Font.Gotham
                DropdownButton.Text = "  " .. default
                DropdownButton.TextColor3 = Color3.fromRGB(200, 200, 200)
                DropdownButton.TextSize = 13
                DropdownButton.TextXAlignment = Enum.TextXAlignment.Left
                
                DropdownUICorner.CornerRadius = UDim.new(0, 4)
                DropdownUICorner.Parent = DropdownButton
                
                Arrow.Name = "Arrow"
                Arrow.Parent = DropdownButton
                Arrow.BackgroundTransparency = 1
                Arrow.Position = UDim2.new(1, -30, 0, 0)
                Arrow.Size = UDim2.new(0, 30, 1, 0)
                Arrow.Font = Enum.Font.GothamBold
                Arrow.Text = "▼"
                Arrow.TextColor3 = Color3.fromRGB(141, 255, 27)
                Arrow.TextSize = 10
                
                DropdownList.Name = "List"
                DropdownList.Parent = DropdownFrame
                DropdownList.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                DropdownList.BorderSizePixel = 0
                DropdownList.Position = UDim2.new(0, 0, 0, 60)
                DropdownList.Size = UDim2.new(1, 0, 0, 0)
                DropdownList.Visible = false
                DropdownList.ClipsDescendants = true
                
                ListUICorner.CornerRadius = UDim.new(0, 4)
                ListUICorner.Parent = DropdownList
                
                ListContainer.Name = "Container"
                ListContainer.Parent = DropdownList
                ListContainer.BackgroundTransparency = 1
                ListContainer.BorderSizePixel = 0
                ListContainer.Size = UDim2.new(1, 0, 1, 0)
                ListContainer.ScrollBarThickness = 4
                ListContainer.ScrollBarImageColor3 = Color3.fromRGB(141, 255, 27)
                ListContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
                
                ListUIListLayout.Parent = ListContainer
                ListUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                ListUIListLayout.Padding = UDim.new(0, 2)
                
                local isOpen = false
                local selectedValue = default
                
                for _, item in ipairs(list) do
                    local OptionButton = Instance.new("TextButton")
                    
                    OptionButton.Name = item
                    OptionButton.Parent = ListContainer
                    OptionButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                    OptionButton.BorderSizePixel = 0
                    OptionButton.Size = UDim2.new(1, -4, 0, 30)
                    OptionButton.Font = Enum.Font.Gotham
                    OptionButton.Text = "  " .. item
                    OptionButton.TextColor3 = Color3.fromRGB(200, 200, 200)
                    OptionButton.TextSize = 12
                    OptionButton.TextXAlignment = Enum.TextXAlignment.Left
                    
                    OptionButton.MouseEnter:Connect(function()
                        OptionButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
                    end)
                    
                    OptionButton.MouseLeave:Connect(function()
                        OptionButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                    end)
                    
                    OptionButton.MouseButton1Click:Connect(function()
                        selectedValue = item
                        DropdownButton.Text = "  " .. item
                        isOpen = false
                        
                        DropdownList:TweenSize(
                            UDim2.new(1, 0, 0, 0),
                            Enum.EasingDirection.Out,
                            Enum.EasingStyle.Quad,
                            0.2,
                            true,
                            function()
                                DropdownList.Visible = false
                                Arrow.Text = "▼"
                                DropdownFrame.Size = UDim2.new(1, 0, 0, 62)
                            end
                        )
                        
                        callback(item)
                    end)
                end
                
                ListUIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    ListContainer.CanvasSize = UDim2.new(0, 0, 0, ListUIListLayout.AbsoluteContentSize.Y + 5)
                end)
                
                DropdownButton.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    
                    if isOpen then
                        local listHeight = math.min(ListUIListLayout.AbsoluteContentSize.Y + 10, 150)
                        DropdownList.Visible = true
                        DropdownList:TweenSize(
                            UDim2.new(1, 0, 0, listHeight),
                            Enum.EasingDirection.Out,
                            Enum.EasingStyle.Quad,
                            0.2,
                            true
                        )
                        Arrow.Text = "▲"
                        DropdownFrame.Size = UDim2.new(1, 0, 0, 62 + listHeight + 5)
                    else
                        DropdownList:TweenSize(
                            UDim2.new(1, 0, 0, 0),
                            Enum.EasingDirection.Out,
                            Enum.EasingStyle.Quad,
                            0.2,
                            true,
                            function()
                                DropdownList.Visible = false
                                Arrow.Text = "▼"
                                DropdownFrame.Size = UDim2.new(1, 0, 0, 62)
                            end
                        )
                    end
                end)
                
                local dropdownObj = {}
                function dropdownObj:Set(value)
                    if table.find(list, value) then
                        selectedValue = value
                        DropdownButton.Text = "  " .. value
                        callback(value)
                    end
                end
                
                function dropdownObj:Refresh(newList, keepSelection)
                    list = newList
                    for _, child in pairs(ListContainer:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    
                    for _, item in ipairs(list) do
                        local OptionButton = Instance.new("TextButton")
                        
                        OptionButton.Name = item
                        OptionButton.Parent = ListContainer
                        OptionButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                        OptionButton.BorderSizePixel = 0
                        OptionButton.Size = UDim2.new(1, -4, 0, 30)
                        OptionButton.Font = Enum.Font.Gotham
                        OptionButton.Text = "  " .. item
                        OptionButton.TextColor3 = Color3.fromRGB(200, 200, 200)
                        OptionButton.TextSize = 12
                        OptionButton.TextXAlignment = Enum.TextXAlignment.Left
                        
                        OptionButton.MouseEnter:Connect(function()
                            OptionButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
                        end)
                        
                        OptionButton.MouseLeave:Connect(function()
                            OptionButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                        end)
                        
                        OptionButton.MouseButton1Click:Connect(function()
                            selectedValue = item
                            DropdownButton.Text = "  " .. item
                            isOpen = false
                            
                            DropdownList:TweenSize(
                                UDim2.new(1, 0, 0, 0),
                                Enum.EasingDirection.Out,
                                Enum.EasingStyle.Quad,
                                0.2,
                                true,
                                function()
                                    DropdownList.Visible = false
                                    Arrow.Text = "▼"
                                    DropdownFrame.Size = UDim2.new(1, 0, 0, 62)
                                end
                            )
                            
                            callback(item)
                        end)
                    end
                    
                    if not keepSelection or not table.find(list, selectedValue) then
                        selectedValue = list[1]
                        DropdownButton.Text = "  " .. selectedValue
                    end
                end
                
                return dropdownObj
            end
            
            -- Create Checkbox
            function section:CreateCheckbox(options)
                local checkboxText = options.Text or options.Name or "Checkbox"
                local default = options.Default or false
                local callback = options.Callback or function() end
                
                local CheckboxFrame = Instance.new("Frame")
                local CheckButton = Instance.new("TextButton")
                local CheckUICorner = Instance.new("UICorner")
                local CheckUIStroke = Instance.new("UIStroke")
                local Check = Instance.new("TextLabel")
                local Label = Instance.new("TextLabel")
                
                CheckboxFrame.Name = "Checkbox"
                CheckboxFrame.Parent = ElementContainer
                CheckboxFrame.BackgroundTransparency = 1
                CheckboxFrame.Size = UDim2.new(1, 0, 0, 30)
                
                CheckButton.Name = "CheckButton"
                CheckButton.Parent = CheckboxFrame
                CheckButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                CheckButton.BorderSizePixel = 0
                CheckButton.Size = UDim2.new(0, 22, 0, 22)
                CheckButton.Text = ""
                
                CheckUICorner.CornerRadius = UDim.new(0, 3)
                CheckUICorner.Parent = CheckButton
                
                CheckUIStroke.Name = "Bloom"
                CheckUIStroke.Parent = CheckButton
                CheckUIStroke.Color = Color3.fromRGB(141, 255, 27)
                CheckUIStroke.Thickness = default and 1 or 0
                CheckUIStroke.Transparency = 0.6
                
                Check.Name = "Check"
                Check.Parent = CheckButton
                Check.BackgroundTransparency = 1
                Check.Size = UDim2.new(1, 0, 1, 0)
                Check.Font = Enum.Font.GothamBold
                Check.Text = default and "✓" or ""
                Check.TextColor3 = Color3.fromRGB(141, 255, 27)
                Check.TextSize = 16
                
                Label.Name = "Label"
                Label.Parent = CheckboxFrame
                Label.BackgroundTransparency = 1
                Label.Position = UDim2.new(0, 32, 0, 0)
                Label.Size = UDim2.new(1, -32, 1, 0)
                Label.Font = Enum.Font.Gotham
                Label.Text = checkboxText
                Label.TextColor3 = Color3.fromRGB(220, 220, 220)
                Label.TextSize = 13
                Label.TextXAlignment = Enum.TextXAlignment.Left
                
                local checked = default
                
                CheckButton.MouseButton1Click:Connect(function()
                    checked = not checked
                    Check.Text = checked and "✓" or ""
                    CheckUIStroke.Thickness = checked and 1 or 0
                    callback(checked)
                end)
                
                local checkboxObj = {}
                function checkboxObj:Set(value)
                    checked = value
                    Check.Text = checked and "✓" or ""
                    CheckUIStroke.Thickness = checked and 1 or 0
                    callback(checked)
                end
                
                return checkboxObj
            end
            
            -- Create Label
            function section:CreateLabel(text)
                local Label = Instance.new("TextLabel")
                
                Label.Name = "Label"
                Label.Parent = ElementContainer
                Label.BackgroundTransparency = 1
                Label.Size = UDim2.new(1, 0, 0, 25)
                Label.Font = Enum.Font.Gotham
                Label.Text = text or "Label"
                Label.TextColor3 = Color3.fromRGB(200, 200, 200)
                Label.TextSize = 13
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.TextWrapped = true
                
                local labelObj = {}
                function labelObj:Set(newText)
                    Label.Text = newText
                end
                
                return labelObj
            end
            
            table.insert(tab.Sections, section)
            return section
        end
        
        table.insert(window.Tabs, tab)
        
        -- Auto-select first tab
        if #window.Tabs == 1 then
            tab.Select()
        end
        
        return tab
    end
    
    table.insert(self.Windows, window)
    return window
end

-- Initialize and return
return Library:New()

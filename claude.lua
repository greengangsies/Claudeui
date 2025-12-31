--[[
    ╔═══════════════════════════════════════════════════════════════════════════════╗
    ║                                                                               ║
    ║     ██████╗██╗      █████╗ ██╗   ██╗██████╗ ███████╗    ██╗   ██╗██╗          ║
    ║    ██╔════╝██║     ██╔══██╗██║   ██║██╔══██╗██╔════╝    ██║   ██║██║          ║
    ║    ██║     ██║     ███████║██║   ██║██║  ██║█████╗      ██║   ██║██║          ║
    ║    ██║     ██║     ██╔══██║██║   ██║██║  ██║██╔══╝      ██║   ██║██║          ║
    ║    ╚██████╗███████╗██║  ██║╚██████╔╝██████╔╝███████╗    ╚██████╔╝██║          ║
    ║     ╚═════╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝     ╚═════╝ ╚═╝          ║
    ║                                                                               ║
    ║                    Professional Roblox UI Library v2.0                        ║
    ║                       Created by Claude (Anthropic)                           ║
    ║                                                                               ║
    ╚═══════════════════════════════════════════════════════════════════════════════╝
    
    ClaudeUI - A comprehensive, professional-grade UI library for Roblox
    
    FEATURES:
    • Modern design with Dark/Light/Midnight/Emerald themes
    • Smooth animations with custom easing
    • Windows, Tabs, Sections with all standard UI elements
    • Buttons, Toggles, Sliders, Inputs, Dropdowns, Color Pickers, Keybinds
    • Toast notifications, Modal dialogs, Context menus, Tooltips
    • Drag & drop, Resizable windows, State management
    
    License: MIT | Copyright (c) 2025 Claude (Anthropic)
--]]

-- ═══════════════════════════════════════════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local LIBRARY_NAME = "ClaudeUI"
local VERSION = "2.0.0"

-- ═══════════════════════════════════════════════════════════════════════════════
-- UTILITY MODULE
-- ═══════════════════════════════════════════════════════════════════════════════

local Utility = {}

function Utility.GenerateUID()
    return HttpService:GenerateGUID(false)
end

function Utility.DeepCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            copy[k] = Utility.DeepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

function Utility.Merge(base, override)
    local result = Utility.DeepCopy(base)
    for k, v in pairs(override or {}) do
        if type(v) == "table" and type(result[k]) == "table" then
            result[k] = Utility.Merge(result[k], v)
        else
            result[k] = v
        end
    end
    return result
end

function Utility.Clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

function Utility.Lerp(a, b, t)
    return a + (b - a) * t
end

function Utility.Round(value, decimals)
    local mult = 10 ^ (decimals or 0)
    return math.floor(value * mult + 0.5) / mult
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- ANIMATION MODULE
-- ═══════════════════════════════════════════════════════════════════════════════

local Animation = {}

Animation.Easing = {
    Linear = function(t) return t end,
    QuadIn = function(t) return t * t end,
    QuadOut = function(t) return t * (2 - t) end,
    QuadInOut = function(t) return t < 0.5 and 2 * t * t or -1 + (4 - 2 * t) * t end,
    CubicIn = function(t) return t * t * t end,
    CubicOut = function(t) return (t - 1) ^ 3 + 1 end,
    CubicInOut = function(t) return t < 0.5 and 4 * t * t * t or (t - 1) * (2 * t - 2) * (2 * t - 2) + 1 end,
    QuartIn = function(t) return t * t * t * t end,
    QuartOut = function(t) return 1 - (t - 1) ^ 4 end,
    SineIn = function(t) return 1 - math.cos(t * math.pi / 2) end,
    SineOut = function(t) return math.sin(t * math.pi / 2) end,
    ExpoOut = function(t) return t == 1 and 1 or 1 - 2 ^ (-10 * t) end,
    BackIn = function(t)
        local c1 = 1.70158
        local c3 = c1 + 1
        return c3 * t * t * t - c1 * t * t
    end,
    BackOut = function(t)
        local c1 = 1.70158
        local c3 = c1 + 1
        return 1 + c3 * (t - 1) ^ 3 + c1 * (t - 1) ^ 2
    end,
    ElasticOut = function(t)
        if t == 0 then return 0 end
        if t == 1 then return 1 end
        return 2 ^ (-10 * t) * math.sin((t * 10 - 0.75) * (2 * math.pi) / 3) + 1
    end,
    BounceOut = function(t)
        local n1 = 7.5625
        local d1 = 2.75
        if t < 1 / d1 then return n1 * t * t
        elseif t < 2 / d1 then t = t - 1.5 / d1; return n1 * t * t + 0.75
        elseif t < 2.5 / d1 then t = t - 2.25 / d1; return n1 * t * t + 0.9375
        else t = t - 2.625 / d1; return n1 * t * t + 0.984375 end
    end,
    Spring = function(t)
        return 1 - math.exp(-4 * t) * math.cos(3 * math.pi * t)
    end,
}

function Animation.Tween(instance, properties, duration, easingStyle, easingDirection)
    local tweenInfo = TweenInfo.new(
        duration or 0.3,
        easingStyle or Enum.EasingStyle.Quart,
        easingDirection or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

function Animation.Animate(duration, easingFunc, callback, onComplete)
    local startTime = tick()
    local connection
    connection = RunService.RenderStepped:Connect(function()
        local elapsed = tick() - startTime
        local progress = math.min(elapsed / duration, 1)
        local easedProgress = easingFunc(progress)
        callback(easedProgress)
        if progress >= 1 then
            connection:Disconnect()
            if onComplete then onComplete() end
        end
    end)
    return {Cancel = function() connection:Disconnect() end}
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- SIGNAL (EVENT SYSTEM)
-- ═══════════════════════════════════════════════════════════════════════════════

local Signal = {}
Signal.__index = Signal

function Signal.new()
    return setmetatable({_connections = {}}, Signal)
end

function Signal:Connect(callback)
    local connection = {Callback = callback, Connected = true}
    function connection:Disconnect() self.Connected = false end
    table.insert(self._connections, connection)
    return connection
end

function Signal:Once(callback)
    local connection
    connection = self:Connect(function(...)
        connection:Disconnect()
        callback(...)
    end)
    return connection
end

function Signal:Fire(...)
    for _, conn in ipairs(self._connections) do
        if conn.Connected then
            task.spawn(conn.Callback, ...)
        end
    end
end

function Signal:Wait()
    local waiting = coroutine.running()
    local connection
    connection = self:Connect(function(...)
        connection:Disconnect()
        coroutine.resume(waiting, ...)
    end)
    return coroutine.yield()
end

function Signal:Destroy()
    self._connections = {}
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- THEME MODULE
-- ═══════════════════════════════════════════════════════════════════════════════

local Theme = {}

Theme.Presets = {
    Dark = {
        Name = "Dark",
        Primary = Color3.fromRGB(210, 139, 97),
        PrimaryHover = Color3.fromRGB(225, 160, 115),
        PrimaryActive = Color3.fromRGB(190, 120, 80),
        Secondary = Color3.fromRGB(100, 110, 130),
        SecondaryHover = Color3.fromRGB(120, 130, 150),
        Background = Color3.fromRGB(24, 24, 27),
        BackgroundSecondary = Color3.fromRGB(32, 32, 36),
        BackgroundTertiary = Color3.fromRGB(40, 40, 45),
        BackgroundElevated = Color3.fromRGB(45, 45, 52),
        Surface = Color3.fromRGB(39, 39, 42),
        SurfaceHover = Color3.fromRGB(50, 50, 55),
        SurfaceActive = Color3.fromRGB(60, 60, 67),
        Border = Color3.fromRGB(63, 63, 70),
        BorderLight = Color3.fromRGB(82, 82, 91),
        BorderFocus = Color3.fromRGB(210, 139, 97),
        TextPrimary = Color3.fromRGB(250, 250, 250),
        TextSecondary = Color3.fromRGB(161, 161, 170),
        TextTertiary = Color3.fromRGB(113, 113, 122),
        TextDisabled = Color3.fromRGB(82, 82, 91),
        TextInverse = Color3.fromRGB(24, 24, 27),
        Success = Color3.fromRGB(34, 197, 94),
        SuccessBackground = Color3.fromRGB(20, 83, 45),
        Warning = Color3.fromRGB(250, 204, 21),
        WarningBackground = Color3.fromRGB(113, 63, 18),
        Error = Color3.fromRGB(239, 68, 68),
        ErrorBackground = Color3.fromRGB(127, 29, 29),
        Info = Color3.fromRGB(59, 130, 246),
        InfoBackground = Color3.fromRGB(30, 58, 138),
        Accent1 = Color3.fromRGB(139, 92, 246),
        Accent2 = Color3.fromRGB(236, 72, 153),
        Accent3 = Color3.fromRGB(20, 184, 166),
        Shadow = Color3.fromRGB(0, 0, 0),
        ShadowOpacity = 0.5,
        Overlay = Color3.fromRGB(0, 0, 0),
        OverlayOpacity = 0.7,
        ScrollbarTrack = Color3.fromRGB(39, 39, 42),
        ScrollbarThumb = Color3.fromRGB(82, 82, 91),
        ScrollbarThumbHover = Color3.fromRGB(113, 113, 122),
        FontFamily = Enum.Font.GothamMedium,
        FontFamilyMono = Enum.Font.RobotoMono,
        FontFamilyHeading = Enum.Font.GothamBold,
        FontSizeXS = 10, FontSizeSM = 12, FontSizeMD = 14, FontSizeLG = 16, FontSizeXL = 18,
        FontSize2XL = 24, FontSize3XL = 30,
        SpacingXS = 4, SpacingSM = 8, SpacingMD = 12, SpacingLG = 16, SpacingXL = 24, Spacing2XL = 32,
        RadiusSM = 4, RadiusMD = 6, RadiusLG = 8, RadiusXL = 12, Radius2XL = 16, RadiusFull = 9999,
        TransitionFast = 0.15, TransitionNormal = 0.25, TransitionSlow = 0.35,
        ZIndexDropdown = 100, ZIndexModal = 200, ZIndexToast = 300, ZIndexTooltip = 400,
    },
    
    Light = {
        Name = "Light",
        Primary = Color3.fromRGB(180, 100, 60),
        PrimaryHover = Color3.fromRGB(160, 85, 50),
        PrimaryActive = Color3.fromRGB(140, 75, 45),
        Secondary = Color3.fromRGB(100, 116, 139),
        SecondaryHover = Color3.fromRGB(71, 85, 105),
        Background = Color3.fromRGB(255, 255, 255),
        BackgroundSecondary = Color3.fromRGB(248, 250, 252),
        BackgroundTertiary = Color3.fromRGB(241, 245, 249),
        BackgroundElevated = Color3.fromRGB(255, 255, 255),
        Surface = Color3.fromRGB(248, 250, 252),
        SurfaceHover = Color3.fromRGB(241, 245, 249),
        SurfaceActive = Color3.fromRGB(226, 232, 240),
        Border = Color3.fromRGB(226, 232, 240),
        BorderLight = Color3.fromRGB(241, 245, 249),
        BorderFocus = Color3.fromRGB(180, 100, 60),
        TextPrimary = Color3.fromRGB(15, 23, 42),
        TextSecondary = Color3.fromRGB(71, 85, 105),
        TextTertiary = Color3.fromRGB(100, 116, 139),
        TextDisabled = Color3.fromRGB(148, 163, 184),
        TextInverse = Color3.fromRGB(255, 255, 255),
        Success = Color3.fromRGB(22, 163, 74),
        SuccessBackground = Color3.fromRGB(220, 252, 231),
        Warning = Color3.fromRGB(202, 138, 4),
        WarningBackground = Color3.fromRGB(254, 249, 195),
        Error = Color3.fromRGB(220, 38, 38),
        ErrorBackground = Color3.fromRGB(254, 226, 226),
        Info = Color3.fromRGB(37, 99, 235),
        InfoBackground = Color3.fromRGB(219, 234, 254),
        Accent1 = Color3.fromRGB(124, 58, 237),
        Accent2 = Color3.fromRGB(219, 39, 119),
        Accent3 = Color3.fromRGB(13, 148, 136),
        Shadow = Color3.fromRGB(0, 0, 0),
        ShadowOpacity = 0.1,
        Overlay = Color3.fromRGB(0, 0, 0),
        OverlayOpacity = 0.5,
        ScrollbarTrack = Color3.fromRGB(241, 245, 249),
        ScrollbarThumb = Color3.fromRGB(203, 213, 225),
        ScrollbarThumbHover = Color3.fromRGB(148, 163, 184),
        FontFamily = Enum.Font.GothamMedium,
        FontFamilyMono = Enum.Font.RobotoMono,
        FontFamilyHeading = Enum.Font.GothamBold,
        FontSizeXS = 10, FontSizeSM = 12, FontSizeMD = 14, FontSizeLG = 16, FontSizeXL = 18,
        FontSize2XL = 24, FontSize3XL = 30,
        SpacingXS = 4, SpacingSM = 8, SpacingMD = 12, SpacingLG = 16, SpacingXL = 24, Spacing2XL = 32,
        RadiusSM = 4, RadiusMD = 6, RadiusLG = 8, RadiusXL = 12, Radius2XL = 16, RadiusFull = 9999,
        TransitionFast = 0.15, TransitionNormal = 0.25, TransitionSlow = 0.35,
        ZIndexDropdown = 100, ZIndexModal = 200, ZIndexToast = 300, ZIndexTooltip = 400,
    },
    
    Midnight = {
        Name = "Midnight",
        Primary = Color3.fromRGB(99, 102, 241),
        PrimaryHover = Color3.fromRGB(129, 140, 248),
        PrimaryActive = Color3.fromRGB(79, 70, 229),
        Secondary = Color3.fromRGB(107, 114, 142),
        SecondaryHover = Color3.fromRGB(127, 134, 162),
        Background = Color3.fromRGB(15, 15, 25),
        BackgroundSecondary = Color3.fromRGB(22, 22, 35),
        BackgroundTertiary = Color3.fromRGB(30, 30, 45),
        BackgroundElevated = Color3.fromRGB(35, 35, 55),
        Surface = Color3.fromRGB(25, 25, 40),
        SurfaceHover = Color3.fromRGB(35, 35, 55),
        SurfaceActive = Color3.fromRGB(45, 45, 70),
        Border = Color3.fromRGB(50, 50, 80),
        BorderLight = Color3.fromRGB(70, 70, 100),
        BorderFocus = Color3.fromRGB(99, 102, 241),
        TextPrimary = Color3.fromRGB(240, 240, 255),
        TextSecondary = Color3.fromRGB(160, 165, 190),
        TextTertiary = Color3.fromRGB(120, 125, 150),
        TextDisabled = Color3.fromRGB(80, 85, 110),
        TextInverse = Color3.fromRGB(15, 15, 25),
        Success = Color3.fromRGB(52, 211, 153),
        SuccessBackground = Color3.fromRGB(20, 60, 50),
        Warning = Color3.fromRGB(251, 191, 36),
        WarningBackground = Color3.fromRGB(70, 50, 20),
        Error = Color3.fromRGB(251, 113, 133),
        ErrorBackground = Color3.fromRGB(80, 30, 40),
        Info = Color3.fromRGB(96, 165, 250),
        InfoBackground = Color3.fromRGB(30, 50, 80),
        Accent1 = Color3.fromRGB(167, 139, 250),
        Accent2 = Color3.fromRGB(244, 114, 182),
        Accent3 = Color3.fromRGB(45, 212, 191),
        Shadow = Color3.fromRGB(0, 0, 15),
        ShadowOpacity = 0.6,
        Overlay = Color3.fromRGB(0, 0, 15),
        OverlayOpacity = 0.8,
        ScrollbarTrack = Color3.fromRGB(25, 25, 40),
        ScrollbarThumb = Color3.fromRGB(70, 70, 100),
        ScrollbarThumbHover = Color3.fromRGB(99, 102, 241),
        FontFamily = Enum.Font.GothamMedium,
        FontFamilyMono = Enum.Font.RobotoMono,
        FontFamilyHeading = Enum.Font.GothamBold,
        FontSizeXS = 10, FontSizeSM = 12, FontSizeMD = 14, FontSizeLG = 16, FontSizeXL = 18,
        FontSize2XL = 24, FontSize3XL = 30,
        SpacingXS = 4, SpacingSM = 8, SpacingMD = 12, SpacingLG = 16, SpacingXL = 24, Spacing2XL = 32,
        RadiusSM = 4, RadiusMD = 6, RadiusLG = 8, RadiusXL = 12, Radius2XL = 16, RadiusFull = 9999,
        TransitionFast = 0.15, TransitionNormal = 0.25, TransitionSlow = 0.35,
        ZIndexDropdown = 100, ZIndexModal = 200, ZIndexToast = 300, ZIndexTooltip = 400,
    },
    
    Emerald = {
        Name = "Emerald",
        Primary = Color3.fromRGB(16, 185, 129),
        PrimaryHover = Color3.fromRGB(52, 211, 153),
        PrimaryActive = Color3.fromRGB(5, 150, 105),
        Secondary = Color3.fromRGB(100, 116, 139),
        SecondaryHover = Color3.fromRGB(71, 85, 105),
        Background = Color3.fromRGB(10, 20, 18),
        BackgroundSecondary = Color3.fromRGB(15, 28, 25),
        BackgroundTertiary = Color3.fromRGB(20, 36, 32),
        BackgroundElevated = Color3.fromRGB(25, 42, 38),
        Surface = Color3.fromRGB(18, 32, 28),
        SurfaceHover = Color3.fromRGB(25, 42, 38),
        SurfaceActive = Color3.fromRGB(32, 52, 48),
        Border = Color3.fromRGB(40, 65, 58),
        BorderLight = Color3.fromRGB(55, 80, 72),
        BorderFocus = Color3.fromRGB(16, 185, 129),
        TextPrimary = Color3.fromRGB(236, 253, 245),
        TextSecondary = Color3.fromRGB(167, 243, 208),
        TextTertiary = Color3.fromRGB(110, 231, 183),
        TextDisabled = Color3.fromRGB(64, 120, 100),
        TextInverse = Color3.fromRGB(10, 20, 18),
        Success = Color3.fromRGB(74, 222, 128),
        SuccessBackground = Color3.fromRGB(20, 83, 45),
        Warning = Color3.fromRGB(250, 204, 21),
        WarningBackground = Color3.fromRGB(113, 63, 18),
        Error = Color3.fromRGB(248, 113, 113),
        ErrorBackground = Color3.fromRGB(127, 29, 29),
        Info = Color3.fromRGB(96, 165, 250),
        InfoBackground = Color3.fromRGB(30, 58, 138),
        Accent1 = Color3.fromRGB(52, 211, 153),
        Accent2 = Color3.fromRGB(110, 231, 183),
        Accent3 = Color3.fromRGB(167, 243, 208),
        Shadow = Color3.fromRGB(0, 10, 8),
        ShadowOpacity = 0.5,
        Overlay = Color3.fromRGB(0, 10, 8),
        OverlayOpacity = 0.7,
        ScrollbarTrack = Color3.fromRGB(18, 32, 28),
        ScrollbarThumb = Color3.fromRGB(55, 80, 72),
        ScrollbarThumbHover = Color3.fromRGB(16, 185, 129),
        FontFamily = Enum.Font.GothamMedium,
        FontFamilyMono = Enum.Font.RobotoMono,
        FontFamilyHeading = Enum.Font.GothamBold,
        FontSizeXS = 10, FontSizeSM = 12, FontSizeMD = 14, FontSizeLG = 16, FontSizeXL = 18,
        FontSize2XL = 24, FontSize3XL = 30,
        SpacingXS = 4, SpacingSM = 8, SpacingMD = 12, SpacingLG = 16, SpacingXL = 24, Spacing2XL = 32,
        RadiusSM = 4, RadiusMD = 6, RadiusLG = 8, RadiusXL = 12, Radius2XL = 16, RadiusFull = 9999,
        TransitionFast = 0.15, TransitionNormal = 0.25, TransitionSlow = 0.35,
        ZIndexDropdown = 100, ZIndexModal = 200, ZIndexToast = 300, ZIndexTooltip = 400,
    },
}

function Theme.Create(base, overrides)
    local baseTheme = Theme.Presets[base] or Theme.Presets.Dark
    return Utility.Merge(baseTheme, overrides)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- ICONS
-- ═══════════════════════════════════════════════════════════════════════════════

local Icons = {
    -- Navigation
    ChevronRight = "rbxassetid://7072706663",
    ChevronLeft = "rbxassetid://7072706318",
    ChevronDown = "rbxassetid://7072706014",
    ChevronUp = "rbxassetid://7072707092",
    ArrowRight = "rbxassetid://7072705973",
    ArrowLeft = "rbxassetid://7072705846",
    ArrowUp = "rbxassetid://7072706103",
    ArrowDown = "rbxassetid://7072705752",
    -- Actions
    Close = "rbxassetid://7072725342",
    Check = "rbxassetid://7072706620",
    Plus = "rbxassetid://7072720687",
    Minus = "rbxassetid://7072720429",
    Edit = "rbxassetid://7072717857",
    Delete = "rbxassetid://7072717594",
    Copy = "rbxassetid://7072717448",
    Save = "rbxassetid://7072721068",
    Refresh = "rbxassetid://7072720774",
    Search = "rbxassetid://7072721154",
    Download = "rbxassetid://7072717747",
    Upload = "rbxassetid://7072722071",
    -- Status
    Info = "rbxassetid://7072718493",
    Warning = "rbxassetid://7072722163",
    Error = "rbxassetid://7072717976",
    Success = "rbxassetid://7072721412",
    Question = "rbxassetid://7072720868",
    -- UI Elements
    Menu = "rbxassetid://7072720340",
    MoreHorizontal = "rbxassetid://7072720506",
    MoreVertical = "rbxassetid://7072720583",
    Settings = "rbxassetid://7072721326",
    Home = "rbxassetid://7072718397",
    User = "rbxassetid://7072722002",
    Users = "rbxassetid://7072722088",
    Lock = "rbxassetid://7072720227",
    Unlock = "rbxassetid://7072721909",
    Eye = "rbxassetid://7072718089",
    EyeOff = "rbxassetid://7072718172",
    Heart = "rbxassetid://7072718307",
    Star = "rbxassetid://7072721496",
    Bell = "rbxassetid://7072706491",
    Calendar = "rbxassetid://7072706834",
    Clock = "rbxassetid://7072706924",
    Globe = "rbxassetid://7072718572",
    Mail = "rbxassetid://7072720260",
    Phone = "rbxassetid://7072720678",
    Camera = "rbxassetid://7072706749",
    Image = "rbxassetid://7072718661",
    File = "rbxassetid://7072718173",
    Folder = "rbxassetid://7072718340",
    Database = "rbxassetid://7072717505",
    Cloud = "rbxassetid://7072717364",
    Power = "rbxassetid://7072720775",
    Sun = "rbxassetid://7072721580",
    Moon = "rbxassetid://7072720420",
    -- Media
    Play = "rbxassetid://7072720673",
    Pause = "rbxassetid://7072720588",
    Stop = "rbxassetid://7072721501",
    VolumeHigh = "rbxassetid://7072722156",
    VolumeMute = "rbxassetid://7072722319",
    Maximize = "rbxassetid://7072720334",
    Minimize = "rbxassetid://7072720412",
    -- Misc
    Chat = "rbxassetid://7072717277",
    Send = "rbxassetid://7072721157",
    Sparkles = "rbxassetid://7072721419",
    Zap = "rbxassetid://7072722407",
    Target = "rbxassetid://7072721663",
    Flag = "rbxassetid://7072718257",
    Bookmark = "rbxassetid://7072706663",
    Link = "rbxassetid://7072720147",
    ExternalLink = "rbxassetid://7072718005",
    Code = "rbxassetid://7072717361",
    Terminal = "rbxassetid://7072721743",
    Cpu = "rbxassetid://7072717471",
    Gamepad = "rbxassetid://7072718425",
    Trophy = "rbxassetid://7072721825",
    Gift = "rbxassetid://7072718489",
    ShoppingCart = "rbxassetid://7072721321",
    CreditCard = "rbxassetid://7072717485",
}

-- ═══════════════════════════════════════════════════════════════════════════════
-- CLAUDE UI - PART 2: Main Library & Window System
-- ═══════════════════════════════════════════════════════════════════════════════

-- MAIN LIBRARY
local ClaudeUI = {}
ClaudeUI.__index = ClaudeUI
ClaudeUI.Version = VERSION
ClaudeUI.Theme = Theme
ClaudeUI.Animation = Animation
ClaudeUI.Utility = Utility
ClaudeUI.Signal = Signal
ClaudeUI.Icons = Icons

ClaudeUI._windows = {}
ClaudeUI._activeTheme = Theme.Presets.Dark
ClaudeUI._screenGui = nil
ClaudeUI._toastContainer = nil

-- Initialize Library
function ClaudeUI:Init()
    local success, screenGui = pcall(function()
        local gui = Instance.new("ScreenGui")
        gui.Name = LIBRARY_NAME
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.Parent = CoreGui
        return gui
    end)
    
    if not success then
        local player = Players.LocalPlayer
        if player then
            screenGui = Instance.new("ScreenGui")
            screenGui.Name = LIBRARY_NAME
            screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            screenGui.ResetOnSpawn = false
            screenGui.IgnoreGuiInset = true
            screenGui.Parent = player:WaitForChild("PlayerGui")
        end
    end
    
    self._screenGui = screenGui
    self:_createToastContainer()
    return self
end

function ClaudeUI:_createToastContainer()
    local container = Instance.new("Frame")
    container.Name = "ToastContainer"
    container.BackgroundTransparency = 1
    container.Position = UDim2.new(1, -20, 0, 20)
    container.Size = UDim2.new(0, 360, 1, -40)
    container.AnchorPoint = Vector2.new(1, 0)
    container.ZIndex = self._activeTheme.ZIndexToast
    container.Parent = self._screenGui
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 8)
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    listLayout.Parent = container
    
    self._toastContainer = container
end

function ClaudeUI:SetTheme(themeName)
    if type(themeName) == "string" then
        self._activeTheme = Theme.Presets[themeName] or Theme.Presets.Dark
    elseif type(themeName) == "table" then
        self._activeTheme = themeName
    end
    for _, window in ipairs(self._windows) do
        if window.OnThemeChange then
            window:OnThemeChange(self._activeTheme)
        end
    end
end

function ClaudeUI:GetTheme()
    return self._activeTheme
end

function ClaudeUI:CreateTheme(base, overrides)
    return Theme.Create(base, overrides)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- WINDOW COMPONENT
-- ═══════════════════════════════════════════════════════════════════════════════

function ClaudeUI:CreateWindow(config)
    local theme = self._activeTheme
    
    config = Utility.Merge({
        Title = "ClaudeUI Window",
        Subtitle = nil,
        Size = UDim2.new(0, 550, 0, 420),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        MinSize = Vector2.new(400, 300),
        MaxSize = Vector2.new(1200, 900),
        Draggable = true,
        Resizable = true,
        Closable = true,
        Minimizable = true,
        ShowClaudeIcon = true,
        Theme = theme,
    }, config)
    
    theme = config.Theme
    
    local Window = {
        Config = config,
        Theme = theme,
        Tabs = {},
        ActiveTab = nil,
        IsMinimized = false,
        IsDestroyed = false,
        Events = {
            OnClose = Signal.new(),
            OnMinimize = Signal.new(),
            OnResize = Signal.new(),
            OnTabChange = Signal.new(),
            OnThemeChange = Signal.new(),
        }
    }
    
    -- Main Window Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "Window"
    mainFrame.BackgroundColor3 = theme.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.Position = config.Position
    mainFrame.Size = config.Size
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.ClipsDescendants = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, theme.RadiusXL)
    corner.Parent = mainFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = theme.Border
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = mainFrame
    
    -- Drop Shadow
    local shadowContainer = Instance.new("Frame")
    shadowContainer.Name = "ShadowContainer"
    shadowContainer.BackgroundTransparency = 1
    shadowContainer.Size = UDim2.new(1, 40, 1, 40)
    shadowContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadowContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    shadowContainer.ZIndex = -1
    shadowContainer.Parent = mainFrame
    
    for i = 1, 4 do
        local shadow = Instance.new("Frame")
        shadow.Name = "Shadow" .. i
        shadow.BackgroundColor3 = theme.Shadow
        shadow.BackgroundTransparency = 1 - (0.1 / i)
        shadow.BorderSizePixel = 0
        shadow.Size = UDim2.new(1, i * 8, 1, i * 8)
        shadow.Position = UDim2.new(0.5, 0, 0.5, i * 2)
        shadow.AnchorPoint = Vector2.new(0.5, 0.5)
        shadow.ZIndex = -i
        shadow.Parent = shadowContainer
        
        local shadowCorner = Instance.new("UICorner")
        shadowCorner.CornerRadius = UDim.new(0, theme.RadiusXL + i * 2)
        shadowCorner.Parent = shadow
    end
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.BackgroundColor3 = theme.BackgroundSecondary
    titleBar.BorderSizePixel = 0
    titleBar.Size = UDim2.new(1, 0, 0, 50)
    titleBar.Parent = mainFrame
    
    local titleBarCorner = Instance.new("UICorner")
    titleBarCorner.CornerRadius = UDim.new(0, theme.RadiusXL)
    titleBarCorner.Parent = titleBar
    
    local titleBarFix = Instance.new("Frame")
    titleBarFix.Name = "CornerFix"
    titleBarFix.BackgroundColor3 = theme.BackgroundSecondary
    titleBarFix.BorderSizePixel = 0
    titleBarFix.Size = UDim2.new(1, 0, 0, 16)
    titleBarFix.Position = UDim2.new(0, 0, 1, -16)
    titleBarFix.Parent = titleBar
    
    local titleBarBorder = Instance.new("Frame")
    titleBarBorder.Name = "Border"
    titleBarBorder.BackgroundColor3 = theme.Border
    titleBarBorder.BorderSizePixel = 0
    titleBarBorder.Size = UDim2.new(1, 0, 0, 1)
    titleBarBorder.Position = UDim2.new(0, 0, 1, 0)
    titleBarBorder.Parent = titleBar
    
    -- Claude Icon
    if config.ShowClaudeIcon then
        local iconContainer = Instance.new("Frame")
        iconContainer.Name = "IconContainer"
        iconContainer.BackgroundColor3 = theme.Primary
        iconContainer.BorderSizePixel = 0
        iconContainer.Size = UDim2.new(0, 32, 0, 32)
        iconContainer.Position = UDim2.new(0, 12, 0.5, 0)
        iconContainer.AnchorPoint = Vector2.new(0, 0.5)
        iconContainer.Parent = titleBar
        
        local iconCorner = Instance.new("UICorner")
        iconCorner.CornerRadius = UDim.new(0, theme.RadiusMD)
        iconCorner.Parent = iconContainer
        
        local iconText = Instance.new("TextLabel")
        iconText.Name = "IconText"
        iconText.BackgroundTransparency = 1
        iconText.Size = UDim2.new(1, 0, 1, 0)
        iconText.Font = Enum.Font.GothamBold
        iconText.Text = "C"
        iconText.TextColor3 = theme.TextInverse
        iconText.TextSize = 18
        iconText.Parent = iconContainer
    end
    
    -- Title Container
    local titleContainer = Instance.new("Frame")
    titleContainer.Name = "TitleContainer"
    titleContainer.BackgroundTransparency = 1
    titleContainer.Position = UDim2.new(0, config.ShowClaudeIcon and 52 or 16, 0, 0)
    titleContainer.Size = UDim2.new(1, -140, 1, 0)
    titleContainer.Parent = titleBar
    
    local titleText = Instance.new("TextLabel")
    titleText.Name = "Title"
    titleText.BackgroundTransparency = 1
    titleText.Size = UDim2.new(1, 0, 0, 20)
    titleText.Position = UDim2.new(0, 0, 0.5, config.Subtitle and -8 or 0)
    titleText.AnchorPoint = Vector2.new(0, 0.5)
    titleText.Font = theme.FontFamilyHeading
    titleText.Text = config.Title
    titleText.TextColor3 = theme.TextPrimary
    titleText.TextSize = theme.FontSizeLG
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.TextTruncate = Enum.TextTruncate.AtEnd
    titleText.Parent = titleContainer
    
    if config.Subtitle then
        local subtitleText = Instance.new("TextLabel")
        subtitleText.Name = "Subtitle"
        subtitleText.BackgroundTransparency = 1
        subtitleText.Size = UDim2.new(1, 0, 0, 14)
        subtitleText.Position = UDim2.new(0, 0, 0.5, 6)
        subtitleText.AnchorPoint = Vector2.new(0, 0.5)
        subtitleText.Font = theme.FontFamily
        subtitleText.Text = config.Subtitle
        subtitleText.TextColor3 = theme.TextSecondary
        subtitleText.TextSize = theme.FontSizeSM
        subtitleText.TextXAlignment = Enum.TextXAlignment.Left
        subtitleText.TextTruncate = Enum.TextTruncate.AtEnd
        subtitleText.Parent = titleContainer
    end
    
    -- Window Controls
    local controlsContainer = Instance.new("Frame")
    controlsContainer.Name = "Controls"
    controlsContainer.BackgroundTransparency = 1
    controlsContainer.Size = UDim2.new(0, 80, 0, 32)
    controlsContainer.Position = UDim2.new(1, -12, 0.5, 0)
    controlsContainer.AnchorPoint = Vector2.new(1, 0.5)
    controlsContainer.Parent = titleBar
    
    local controlsLayout = Instance.new("UIListLayout")
    controlsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    controlsLayout.FillDirection = Enum.FillDirection.Horizontal
    controlsLayout.Padding = UDim.new(0, 8)
    controlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    controlsLayout.Parent = controlsContainer
    
    local function createControlButton(name, icon, order)
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.BackgroundColor3 = theme.Surface
        btn.BorderSizePixel = 0
        btn.Size = UDim2.new(0, 32, 0, 32)
        btn.Text = ""
        btn.LayoutOrder = order
        btn.AutoButtonColor = false
        btn.Parent = controlsContainer
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, theme.RadiusMD)
        btnCorner.Parent = btn
        
        local btnIcon = Instance.new("ImageLabel")
        btnIcon.Name = "Icon"
        btnIcon.BackgroundTransparency = 1
        btnIcon.Size = UDim2.new(0, 16, 0, 16)
        btnIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
        btnIcon.AnchorPoint = Vector2.new(0.5, 0.5)
        btnIcon.Image = icon
        btnIcon.ImageColor3 = theme.TextSecondary
        btnIcon.Parent = btn
        
        btn.MouseEnter:Connect(function()
            Animation.Tween(btn, {BackgroundColor3 = theme.SurfaceHover}, 0.15)
            Animation.Tween(btnIcon, {ImageColor3 = theme.TextPrimary}, 0.15)
        end)
        
        btn.MouseLeave:Connect(function()
            Animation.Tween(btn, {BackgroundColor3 = theme.Surface}, 0.15)
            Animation.Tween(btnIcon, {ImageColor3 = theme.TextSecondary}, 0.15)
        end)
        
        return btn
    end
    
    if config.Minimizable then
        local minimizeBtn = createControlButton("Minimize", Icons.Minus, 1)
        minimizeBtn.MouseButton1Click:Connect(function()
            Window:ToggleMinimize()
        end)
    end
    
    if config.Closable then
        local closeBtn = createControlButton("Close", Icons.Close, 2)
        closeBtn.MouseButton1Click:Connect(function()
            Window:Close()
        end)
    end
    
    -- Content Container
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.BackgroundTransparency = 1
    contentContainer.BorderSizePixel = 0
    contentContainer.Position = UDim2.new(0, 0, 0, 51)
    contentContainer.Size = UDim2.new(1, 0, 1, -51)
    contentContainer.ClipsDescendants = true
    contentContainer.Parent = mainFrame
    
    -- Tab Container (Sidebar)
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.BackgroundColor3 = theme.BackgroundSecondary
    tabContainer.BorderSizePixel = 0
    tabContainer.Size = UDim2.new(0, 180, 1, 0)
    tabContainer.Parent = contentContainer
    
    local tabContainerBorder = Instance.new("Frame")
    tabContainerBorder.Name = "Border"
    tabContainerBorder.BackgroundColor3 = theme.Border
    tabContainerBorder.BorderSizePixel = 0
    tabContainerBorder.Size = UDim2.new(0, 1, 1, 0)
    tabContainerBorder.Position = UDim2.new(1, 0, 0, 0)
    tabContainerBorder.Parent = tabContainer
    
    -- Tab Scroll Frame
    local tabScroll = Instance.new("ScrollingFrame")
    tabScroll.Name = "TabScroll"
    tabScroll.BackgroundTransparency = 1
    tabScroll.BorderSizePixel = 0
    tabScroll.Size = UDim2.new(1, 0, 1, -20)
    tabScroll.Position = UDim2.new(0, 0, 0, 10)
    tabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabScroll.ScrollBarThickness = 3
    tabScroll.ScrollBarImageColor3 = theme.ScrollbarThumb
    tabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabScroll.Parent = tabContainer
    
    local tabPadding = Instance.new("UIPadding")
    tabPadding.PaddingLeft = UDim.new(0, 8)
    tabPadding.PaddingRight = UDim.new(0, 8)
    tabPadding.PaddingTop = UDim.new(0, 4)
    tabPadding.PaddingBottom = UDim.new(0, 4)
    tabPadding.Parent = tabScroll
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 4)
    tabLayout.Parent = tabScroll
    
    -- Main Content Area
    local mainContent = Instance.new("Frame")
    mainContent.Name = "MainContent"
    mainContent.BackgroundTransparency = 1
    mainContent.BorderSizePixel = 0
    mainContent.Position = UDim2.new(0, 181, 0, 0)
    mainContent.Size = UDim2.new(1, -181, 1, 0)
    mainContent.Parent = contentContainer
    
    -- Tab Content Container
    local tabContentContainer = Instance.new("Frame")
    tabContentContainer.Name = "TabContent"
    tabContentContainer.BackgroundTransparency = 1
    tabContentContainer.Size = UDim2.new(1, 0, 1, 0)
    tabContentContainer.Parent = mainContent
    
    Window.Instance = mainFrame
    Window.ContentContainer = contentContainer
    Window.TabContainer = tabContainer
    Window.TabScroll = tabScroll
    Window.MainContent = mainContent
    Window.TabContentContainer = tabContentContainer
    Window.TitleBar = titleBar
    Window.TitleText = titleText
    
    -- Dragging Functionality
    if config.Draggable then
        local dragging = false
        local dragStart = nil
        local startPos = nil
        
        titleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = mainFrame.Position
            end
        end)
        
        titleBar.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                mainFrame.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end)
    end
    
    -- Resizing Functionality
    if config.Resizable then
        local resizeHandle = Instance.new("TextButton")
        resizeHandle.Name = "ResizeHandle"
        resizeHandle.BackgroundTransparency = 1
        resizeHandle.Size = UDim2.new(0, 20, 0, 20)
        resizeHandle.Position = UDim2.new(1, -20, 1, -20)
        resizeHandle.Text = ""
        resizeHandle.ZIndex = 10
        resizeHandle.Parent = mainFrame
        
        local resizeIcon = Instance.new("Frame")
        resizeIcon.BackgroundTransparency = 1
        resizeIcon.Size = UDim2.new(1, -6, 1, -6)
        resizeIcon.Position = UDim2.new(0, 6, 0, 6)
        resizeIcon.Parent = resizeHandle
        
        for i = 0, 2 do
            local line = Instance.new("Frame")
            line.BackgroundColor3 = theme.TextTertiary
            line.BorderSizePixel = 0
            line.Size = UDim2.new(0, 2, 0, 8 + i * 4)
            line.Position = UDim2.new(1, -2, 1, -(8 + i * 4))
            line.AnchorPoint = Vector2.new(1, 1)
            line.Rotation = -45
            line.Parent = resizeIcon
            
            local lineCorner = Instance.new("UICorner")
            lineCorner.CornerRadius = UDim.new(1, 0)
            lineCorner.Parent = line
        end
        
        local resizing = false
        local resizeStart = nil
        local startSize = nil
        
        resizeHandle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                resizing = true
                resizeStart = input.Position
                startSize = mainFrame.Size
            end
        end)
        
        resizeHandle.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                resizing = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - resizeStart
                local newWidth = Utility.Clamp(startSize.X.Offset + delta.X, config.MinSize.X, config.MaxSize.X)
                local newHeight = Utility.Clamp(startSize.Y.Offset + delta.Y, config.MinSize.Y, config.MaxSize.Y)
                mainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
                Window.Events.OnResize:Fire(newWidth, newHeight)
            end
        end)
    end
    
    -- Window Methods
    function Window:SetTitle(title)
        titleText.Text = title
    end
    
    function Window:ToggleMinimize()
        self.IsMinimized = not self.IsMinimized
        if self.IsMinimized then
            Animation.Tween(contentContainer, {Size = UDim2.new(1, 0, 0, 0)}, 0.3, Enum.EasingStyle.Quart)
            Animation.Tween(mainFrame, {Size = UDim2.new(0, mainFrame.Size.X.Offset, 0, 50)}, 0.3, Enum.EasingStyle.Quart)
        else
            Animation.Tween(mainFrame, {Size = config.Size}, 0.3, Enum.EasingStyle.Quart)
            task.delay(0.1, function()
                Animation.Tween(contentContainer, {Size = UDim2.new(1, 0, 1, -51)}, 0.25, Enum.EasingStyle.Quart)
            end)
        end
        self.Events.OnMinimize:Fire(self.IsMinimized)
    end
    
    function Window:Close()
        if self.IsDestroyed then return end
        self.Events.OnClose:Fire()
        
        Animation.Tween(mainFrame, {
            Size = UDim2.new(0, mainFrame.Size.X.Offset * 0.9, 0, mainFrame.Size.Y.Offset * 0.9),
            BackgroundTransparency = 1
        }, 0.25, Enum.EasingStyle.Quart)
        
        for _, child in ipairs(mainFrame:GetDescendants()) do
            if child:IsA("GuiObject") then
                pcall(function() Animation.Tween(child, {BackgroundTransparency = 1}, 0.2) end)
            end
            if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                pcall(function() Animation.Tween(child, {TextTransparency = 1}, 0.2) end)
            end
            if child:IsA("ImageLabel") or child:IsA("ImageButton") then
                pcall(function() Animation.Tween(child, {ImageTransparency = 1}, 0.2) end)
            end
        end
        
        task.delay(0.3, function()
            self.IsDestroyed = true
            mainFrame:Destroy()
            for i, w in ipairs(ClaudeUI._windows) do
                if w == self then
                    table.remove(ClaudeUI._windows, i)
                    break
                end
            end
        end)
    end
    
    function Window:Show()
        mainFrame.Visible = true
        mainFrame.BackgroundTransparency = 1
        mainFrame.Size = UDim2.new(0, config.Size.X.Offset * 0.9, 0, config.Size.Y.Offset * 0.9)
        
        Animation.Tween(mainFrame, {
            BackgroundTransparency = 0,
            Size = config.Size
        }, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end
    
    function Window:Hide()
        Animation.Tween(mainFrame, {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, config.Size.X.Offset * 0.9, 0, config.Size.Y.Offset * 0.9)
        }, 0.25, Enum.EasingStyle.Quart)
        task.delay(0.25, function()
            mainFrame.Visible = false
        end)
    end
    
    function Window:OnThemeChange(newTheme)
        self.Theme = newTheme
        mainFrame.BackgroundColor3 = newTheme.Background
        titleBar.BackgroundColor3 = newTheme.BackgroundSecondary
        tabContainer.BackgroundColor3 = newTheme.BackgroundSecondary
        titleText.TextColor3 = newTheme.TextPrimary
        stroke.Color = newTheme.Border
        self.Events.OnThemeChange:Fire(newTheme)
    end
    
    -- Select Tab Method
    function Window:SelectTab(tab)
        if self.ActiveTab then
            self.ActiveTab:Deactivate()
        end
        self.ActiveTab = tab
        tab:Activate()
        self.Events.OnTabChange:Fire(tab)
    end

-- ═══════════════════════════════════════════════════════════════════════════════
-- CLAUDE UI - PART 3: Tab System, Sections, Button & Toggle Elements
-- ═══════════════════════════════════════════════════════════════════════════════

    -- Create Tab Method (continues from Window in Part 2)
    function Window:CreateTab(tabConfig)
        tabConfig = Utility.Merge({
            Title = "Tab",
            Icon = nil,
            LayoutOrder = #self.Tabs + 1
        }, tabConfig)
        
        local Tab = {
            Config = tabConfig,
            Sections = {},
            IsActive = false,
            Elements = {}
        }
        
        -- Tab Button
        local tabButton = Instance.new("TextButton")
        tabButton.Name = tabConfig.Title
        tabButton.BackgroundColor3 = theme.Surface
        tabButton.BackgroundTransparency = 1
        tabButton.BorderSizePixel = 0
        tabButton.Size = UDim2.new(1, 0, 0, 36)
        tabButton.Text = ""
        tabButton.AutoButtonColor = false
        tabButton.LayoutOrder = tabConfig.LayoutOrder
        tabButton.Parent = tabScroll
        
        local tabButtonCorner = Instance.new("UICorner")
        tabButtonCorner.CornerRadius = UDim.new(0, theme.RadiusMD)
        tabButtonCorner.Parent = tabButton
        
        local tabButtonLayout = Instance.new("Frame")
        tabButtonLayout.Name = "Layout"
        tabButtonLayout.BackgroundTransparency = 1
        tabButtonLayout.Size = UDim2.new(1, -16, 1, 0)
        tabButtonLayout.Position = UDim2.new(0, 8, 0, 0)
        tabButtonLayout.Parent = tabButton
        
        if tabConfig.Icon then
            local tabIcon = Instance.new("ImageLabel")
            tabIcon.Name = "Icon"
            tabIcon.BackgroundTransparency = 1
            tabIcon.Size = UDim2.new(0, 18, 0, 18)
            tabIcon.Position = UDim2.new(0, 0, 0.5, 0)
            tabIcon.AnchorPoint = Vector2.new(0, 0.5)
            tabIcon.Image = tabConfig.Icon
            tabIcon.ImageColor3 = theme.TextSecondary
            tabIcon.Parent = tabButtonLayout
        end
        
        local tabLabel = Instance.new("TextLabel")
        tabLabel.Name = "Label"
        tabLabel.BackgroundTransparency = 1
        tabLabel.Size = UDim2.new(1, tabConfig.Icon and -26 or 0, 1, 0)
        tabLabel.Position = UDim2.new(0, tabConfig.Icon and 26 or 0, 0, 0)
        tabLabel.Font = theme.FontFamily
        tabLabel.Text = tabConfig.Title
        tabLabel.TextColor3 = theme.TextSecondary
        tabLabel.TextSize = theme.FontSizeMD
        tabLabel.TextXAlignment = Enum.TextXAlignment.Left
        tabLabel.TextTruncate = Enum.TextTruncate.AtEnd
        tabLabel.Parent = tabButtonLayout
        
        local activeIndicator = Instance.new("Frame")
        activeIndicator.Name = "ActiveIndicator"
        activeIndicator.BackgroundColor3 = theme.Primary
        activeIndicator.BorderSizePixel = 0
        activeIndicator.Size = UDim2.new(0, 3, 0, 0)
        activeIndicator.Position = UDim2.new(0, 0, 0.5, 0)
        activeIndicator.AnchorPoint = Vector2.new(0, 0.5)
        activeIndicator.Parent = tabButton
        
        local indicatorCorner = Instance.new("UICorner")
        indicatorCorner.CornerRadius = UDim.new(0, 2)
        indicatorCorner.Parent = activeIndicator
        
        -- Tab Content Frame
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Name = tabConfig.Title .. "Content"
        tabContent.BackgroundTransparency = 1
        tabContent.BorderSizePixel = 0
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabContent.ScrollBarThickness = 4
        tabContent.ScrollBarImageColor3 = theme.ScrollbarThumb
        tabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
        tabContent.Visible = false
        tabContent.Parent = tabContentContainer
        
        local contentPadding = Instance.new("UIPadding")
        contentPadding.PaddingLeft = UDim.new(0, 16)
        contentPadding.PaddingRight = UDim.new(0, 16)
        contentPadding.PaddingTop = UDim.new(0, 16)
        contentPadding.PaddingBottom = UDim.new(0, 16)
        contentPadding.Parent = tabContent
        
        local contentLayout = Instance.new("UIListLayout")
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, 12)
        contentLayout.Parent = tabContent
        
        Tab.Button = tabButton
        Tab.Label = tabLabel
        Tab.Content = tabContent
        Tab.ActiveIndicator = activeIndicator
        Tab.Icon = tabButtonLayout:FindFirstChild("Icon")
        
        -- Hover Effects
        tabButton.MouseEnter:Connect(function()
            if not Tab.IsActive then
                Animation.Tween(tabButton, {BackgroundTransparency = 0.5}, 0.15)
                Animation.Tween(tabLabel, {TextColor3 = theme.TextPrimary}, 0.15)
                if Tab.Icon then
                    Animation.Tween(Tab.Icon, {ImageColor3 = theme.TextPrimary}, 0.15)
                end
            end
        end)
        
        tabButton.MouseLeave:Connect(function()
            if not Tab.IsActive then
                Animation.Tween(tabButton, {BackgroundTransparency = 1}, 0.15)
                Animation.Tween(tabLabel, {TextColor3 = theme.TextSecondary}, 0.15)
                if Tab.Icon then
                    Animation.Tween(Tab.Icon, {ImageColor3 = theme.TextSecondary}, 0.15)
                end
            end
        end)
        
        tabButton.MouseButton1Click:Connect(function()
            Window:SelectTab(Tab)
        end)
        
        -- Activate/Deactivate
        function Tab:Activate()
            if self.IsActive then return end
            self.IsActive = true
            
            Animation.Tween(tabButton, {BackgroundTransparency = 0, BackgroundColor3 = theme.Primary}, 0.2)
            Animation.Tween(tabLabel, {TextColor3 = theme.TextInverse}, 0.2)
            Animation.Tween(activeIndicator, {Size = UDim2.new(0, 3, 0.6, 0)}, 0.2, Enum.EasingStyle.Back)
            if self.Icon then
                Animation.Tween(self.Icon, {ImageColor3 = theme.TextInverse}, 0.2)
            end
            
            tabContent.Visible = true
            tabContent.GroupTransparency = 1
            Animation.Tween(tabContent, {GroupTransparency = 0}, 0.25)
        end
        
        function Tab:Deactivate()
            if not self.IsActive then return end
            self.IsActive = false
            
            Animation.Tween(tabButton, {BackgroundTransparency = 1}, 0.2)
            Animation.Tween(tabLabel, {TextColor3 = theme.TextSecondary}, 0.2)
            Animation.Tween(activeIndicator, {Size = UDim2.new(0, 3, 0, 0)}, 0.2)
            if self.Icon then
                Animation.Tween(self.Icon, {ImageColor3 = theme.TextSecondary}, 0.2)
            end
            
            Animation.Tween(tabContent, {GroupTransparency = 1}, 0.15)
            task.delay(0.15, function()
                if not self.IsActive then
                    tabContent.Visible = false
                end
            end)
        end
        
        -- ═══════════════════════════════════════════════════════════════════
        -- CREATE SECTION METHOD
        -- ═══════════════════════════════════════════════════════════════════
        
        function Tab:CreateSection(sectionConfig)
            sectionConfig = Utility.Merge({
                Title = "Section",
                Description = nil,
                Collapsible = false,
                DefaultOpen = true,
                LayoutOrder = #self.Sections + 1
            }, sectionConfig)
            
            local Section = {
                Config = sectionConfig,
                IsOpen = sectionConfig.DefaultOpen,
                Elements = {}
            }
            
            local sectionFrame = Instance.new("Frame")
            sectionFrame.Name = sectionConfig.Title
            sectionFrame.BackgroundColor3 = theme.Surface
            sectionFrame.BorderSizePixel = 0
            sectionFrame.Size = UDim2.new(1, 0, 0, 0)
            sectionFrame.AutomaticSize = Enum.AutomaticSize.Y
            sectionFrame.LayoutOrder = sectionConfig.LayoutOrder
            sectionFrame.ClipsDescendants = true
            sectionFrame.Parent = tabContent
            
            local sectionCorner = Instance.new("UICorner")
            sectionCorner.CornerRadius = UDim.new(0, theme.RadiusLG)
            sectionCorner.Parent = sectionFrame
            
            local sectionStroke = Instance.new("UIStroke")
            sectionStroke.Color = theme.Border
            sectionStroke.Thickness = 1
            sectionStroke.Transparency = 0.5
            sectionStroke.Parent = sectionFrame
            
            -- Section Header
            local headerFrame = Instance.new("Frame")
            headerFrame.Name = "Header"
            headerFrame.BackgroundTransparency = 1
            headerFrame.Size = UDim2.new(1, 0, 0, sectionConfig.Description and 56 or 44)
            headerFrame.Parent = sectionFrame
            
            local headerPadding = Instance.new("UIPadding")
            headerPadding.PaddingLeft = UDim.new(0, 14)
            headerPadding.PaddingRight = UDim.new(0, 14)
            headerPadding.Parent = headerFrame
            
            local headerTitle = Instance.new("TextLabel")
            headerTitle.Name = "Title"
            headerTitle.BackgroundTransparency = 1
            headerTitle.Size = UDim2.new(1, -30, 0, 20)
            headerTitle.Position = UDim2.new(0, 0, 0, sectionConfig.Description and 10 or 12)
            headerTitle.Font = theme.FontFamilyHeading
            headerTitle.Text = sectionConfig.Title
            headerTitle.TextColor3 = theme.TextPrimary
            headerTitle.TextSize = theme.FontSizeMD
            headerTitle.TextXAlignment = Enum.TextXAlignment.Left
            headerTitle.Parent = headerFrame
            
            if sectionConfig.Description then
                local headerDesc = Instance.new("TextLabel")
                headerDesc.Name = "Description"
                headerDesc.BackgroundTransparency = 1
                headerDesc.Size = UDim2.new(1, -30, 0, 16)
                headerDesc.Position = UDim2.new(0, 0, 0, 32)
                headerDesc.Font = theme.FontFamily
                headerDesc.Text = sectionConfig.Description
                headerDesc.TextColor3 = theme.TextTertiary
                headerDesc.TextSize = theme.FontSizeSM
                headerDesc.TextXAlignment = Enum.TextXAlignment.Left
                headerDesc.TextTruncate = Enum.TextTruncate.AtEnd
                headerDesc.Parent = headerFrame
            end
            
            -- Collapse Button
            if sectionConfig.Collapsible then
                local collapseBtn = Instance.new("TextButton")
                collapseBtn.Name = "CollapseButton"
                collapseBtn.BackgroundTransparency = 1
                collapseBtn.Size = UDim2.new(0, 24, 0, 24)
                collapseBtn.Position = UDim2.new(1, -10, 0.5, 0)
                collapseBtn.AnchorPoint = Vector2.new(1, 0.5)
                collapseBtn.Text = ""
                collapseBtn.Parent = headerFrame
                
                local collapseIcon = Instance.new("ImageLabel")
                collapseIcon.BackgroundTransparency = 1
                collapseIcon.Size = UDim2.new(0, 16, 0, 16)
                collapseIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
                collapseIcon.AnchorPoint = Vector2.new(0.5, 0.5)
                collapseIcon.Image = Icons.ChevronDown
                collapseIcon.ImageColor3 = theme.TextSecondary
                collapseIcon.Rotation = Section.IsOpen and 0 or -90
                collapseIcon.Parent = collapseBtn
                
                Section.CollapseIcon = collapseIcon
                
                collapseBtn.MouseButton1Click:Connect(function()
                    Section:Toggle()
                end)
            end
            
            -- Content Container
            local contentFrame = Instance.new("Frame")
            contentFrame.Name = "Content"
            contentFrame.BackgroundTransparency = 1
            contentFrame.Size = UDim2.new(1, 0, 0, 0)
            contentFrame.AutomaticSize = Enum.AutomaticSize.Y
            contentFrame.Position = UDim2.new(0, 0, 0, sectionConfig.Description and 56 or 44)
            contentFrame.Parent = sectionFrame
            
            local contentPadding = Instance.new("UIPadding")
            contentPadding.PaddingLeft = UDim.new(0, 14)
            contentPadding.PaddingRight = UDim.new(0, 14)
            contentPadding.PaddingBottom = UDim.new(0, 14)
            contentPadding.Parent = contentFrame
            
            local contentLayout = Instance.new("UIListLayout")
            contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
            contentLayout.Padding = UDim.new(0, 10)
            contentLayout.Parent = contentFrame
            
            Section.Frame = sectionFrame
            Section.Header = headerFrame
            Section.Content = contentFrame
            
            function Section:Toggle()
                self.IsOpen = not self.IsOpen
                if self.CollapseIcon then
                    Animation.Tween(self.CollapseIcon, {Rotation = self.IsOpen and 0 or -90}, 0.25, Enum.EasingStyle.Quart)
                end
                if self.IsOpen then
                    contentFrame.Visible = true
                    Animation.Tween(contentFrame, {GroupTransparency = 0}, 0.25)
                else
                    Animation.Tween(contentFrame, {GroupTransparency = 1}, 0.15)
                    task.delay(0.15, function()
                        if not self.IsOpen then
                            contentFrame.Visible = false
                        end
                    end)
                end
            end
            
            -- ═══════════════════════════════════════════════════════════════
            -- BUTTON ELEMENT
            -- ═══════════════════════════════════════════════════════════════
            
            function Section:CreateButton(buttonConfig)
                buttonConfig = Utility.Merge({
                    Title = "Button",
                    Description = nil,
                    Icon = nil,
                    Variant = "Primary",
                    Size = "Medium",
                    Callback = function() end,
                    LayoutOrder = #self.Elements + 1
                }, buttonConfig)
                
                local variants = {
                    Primary = {bg = theme.Primary, hover = theme.PrimaryHover, active = theme.PrimaryActive, text = theme.TextInverse},
                    Secondary = {bg = theme.Surface, hover = theme.SurfaceHover, active = theme.SurfaceActive, text = theme.TextPrimary},
                    Ghost = {bg = Color3.new(1,1,1), bgTransparency = 1, hover = theme.Surface, active = theme.SurfaceActive, text = theme.TextPrimary},
                    Danger = {bg = theme.Error, hover = Color3.fromRGB(220, 50, 50), active = Color3.fromRGB(180, 40, 40), text = theme.TextInverse},
                    Success = {bg = theme.Success, hover = Color3.fromRGB(30, 180, 90), active = Color3.fromRGB(25, 150, 75), text = theme.TextInverse},
                }
                
                local sizes = {
                    Small = {height = 28, fontSize = theme.FontSizeSM, padding = 10},
                    Medium = {height = 36, fontSize = theme.FontSizeMD, padding = 14},
                    Large = {height = 44, fontSize = theme.FontSizeLG, padding = 18},
                }
                
                local variant = variants[buttonConfig.Variant] or variants.Primary
                local size = sizes[buttonConfig.Size] or sizes.Medium
                
                local btn = Instance.new("TextButton")
                btn.Name = buttonConfig.Title
                btn.BackgroundColor3 = variant.bg
                btn.BackgroundTransparency = variant.bgTransparency or 0
                btn.BorderSizePixel = 0
                btn.Size = UDim2.new(1, 0, 0, size.height)
                btn.Text = ""
                btn.AutoButtonColor = false
                btn.LayoutOrder = buttonConfig.LayoutOrder
                btn.Parent = contentFrame
                
                local btnCorner = Instance.new("UICorner")
                btnCorner.CornerRadius = UDim.new(0, theme.RadiusMD)
                btnCorner.Parent = btn
                
                if buttonConfig.Variant == "Secondary" or buttonConfig.Variant == "Ghost" then
                    local btnStroke = Instance.new("UIStroke")
                    btnStroke.Color = theme.Border
                    btnStroke.Thickness = 1
                    btnStroke.Parent = btn
                end
                
                local btnContent = Instance.new("Frame")
                btnContent.Name = "Content"
                btnContent.BackgroundTransparency = 1
                btnContent.Size = UDim2.new(1, 0, 1, 0)
                btnContent.Parent = btn
                
                local btnLayout = Instance.new("UIListLayout")
                btnLayout.FillDirection = Enum.FillDirection.Horizontal
                btnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                btnLayout.VerticalAlignment = Enum.VerticalAlignment.Center
                btnLayout.Padding = UDim.new(0, 8)
                btnLayout.Parent = btnContent
                
                if buttonConfig.Icon then
                    local btnIcon = Instance.new("ImageLabel")
                    btnIcon.Name = "Icon"
                    btnIcon.BackgroundTransparency = 1
                    btnIcon.Size = UDim2.new(0, 16, 0, 16)
                    btnIcon.Image = buttonConfig.Icon
                    btnIcon.ImageColor3 = variant.text
                    btnIcon.LayoutOrder = 1
                    btnIcon.Parent = btnContent
                end
                
                local btnLabel = Instance.new("TextLabel")
                btnLabel.Name = "Label"
                btnLabel.BackgroundTransparency = 1
                btnLabel.Size = UDim2.new(0, 0, 1, 0)
                btnLabel.AutomaticSize = Enum.AutomaticSize.X
                btnLabel.Font = theme.FontFamily
                btnLabel.Text = buttonConfig.Title
                btnLabel.TextColor3 = variant.text
                btnLabel.TextSize = size.fontSize
                btnLabel.LayoutOrder = 2
                btnLabel.Parent = btnContent
                
                btn.MouseEnter:Connect(function()
                    Animation.Tween(btn, {BackgroundColor3 = variant.hover, BackgroundTransparency = 0}, 0.15)
                end)
                
                btn.MouseLeave:Connect(function()
                    Animation.Tween(btn, {BackgroundColor3 = variant.bg, BackgroundTransparency = variant.bgTransparency or 0}, 0.15)
                end)
                
                btn.MouseButton1Down:Connect(function()
                    Animation.Tween(btn, {BackgroundColor3 = variant.active}, 0.1)
                    Animation.Tween(btn, {Size = UDim2.new(1, -4, 0, size.height - 2)}, 0.1)
                end)
                
                btn.MouseButton1Up:Connect(function()
                    Animation.Tween(btn, {BackgroundColor3 = variant.hover}, 0.1)
                    Animation.Tween(btn, {Size = UDim2.new(1, 0, 0, size.height)}, 0.15, Enum.EasingStyle.Back)
                end)
                
                btn.MouseButton1Click:Connect(function()
                    buttonConfig.Callback()
                end)
                
                table.insert(self.Elements, btn)
                return btn
            end
            
            -- ═══════════════════════════════════════════════════════════════
            -- TOGGLE ELEMENT
            -- ═══════════════════════════════════════════════════════════════
            
            function Section:CreateToggle(toggleConfig)
                toggleConfig = Utility.Merge({
                    Title = "Toggle",
                    Description = nil,
                    Default = false,
                    Callback = function(value) end,
                    LayoutOrder = #self.Elements + 1
                }, toggleConfig)
                
                local isEnabled = toggleConfig.Default
                
                local toggleFrame = Instance.new("Frame")
                toggleFrame.Name = toggleConfig.Title
                toggleFrame.BackgroundTransparency = 1
                toggleFrame.Size = UDim2.new(1, 0, 0, toggleConfig.Description and 52 or 36)
                toggleFrame.LayoutOrder = toggleConfig.LayoutOrder
                toggleFrame.Parent = contentFrame
                
                local toggleLabel = Instance.new("TextLabel")
                toggleLabel.Name = "Label"
                toggleLabel.BackgroundTransparency = 1
                toggleLabel.Size = UDim2.new(1, -60, 0, 18)
                toggleLabel.Position = UDim2.new(0, 0, 0, toggleConfig.Description and 4 or 9)
                toggleLabel.Font = theme.FontFamily
                toggleLabel.Text = toggleConfig.Title
                toggleLabel.TextColor3 = theme.TextPrimary
                toggleLabel.TextSize = theme.FontSizeMD
                toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                toggleLabel.Parent = toggleFrame
                
                if toggleConfig.Description then
                    local toggleDesc = Instance.new("TextLabel")
                    toggleDesc.Name = "Description"
                    toggleDesc.BackgroundTransparency = 1
                    toggleDesc.Size = UDim2.new(1, -60, 0, 16)
                    toggleDesc.Position = UDim2.new(0, 0, 0, 24)
                    toggleDesc.Font = theme.FontFamily
                    toggleDesc.Text = toggleConfig.Description
                    toggleDesc.TextColor3 = theme.TextTertiary
                    toggleDesc.TextSize = theme.FontSizeSM
                    toggleDesc.TextXAlignment = Enum.TextXAlignment.Left
                    toggleDesc.TextWrapped = true
                    toggleDesc.Parent = toggleFrame
                end
                
                local switchBg = Instance.new("TextButton")
                switchBg.Name = "Switch"
                switchBg.BackgroundColor3 = isEnabled and theme.Primary or theme.Surface
                switchBg.BorderSizePixel = 0
                switchBg.Size = UDim2.new(0, 48, 0, 26)
                switchBg.Position = UDim2.new(1, 0, 0.5, 0)
                switchBg.AnchorPoint = Vector2.new(1, 0.5)
                switchBg.Text = ""
                switchBg.AutoButtonColor = false
                switchBg.Parent = toggleFrame
                
                local switchCorner = Instance.new("UICorner")
                switchCorner.CornerRadius = UDim.new(1, 0)
                switchCorner.Parent = switchBg
                
                local switchStroke = Instance.new("UIStroke")
                switchStroke.Color = isEnabled and theme.Primary or theme.Border
                switchStroke.Thickness = 1
                switchStroke.Parent = switchBg
                
                local switchKnob = Instance.new("Frame")
                switchKnob.Name = "Knob"
                switchKnob.BackgroundColor3 = Color3.new(1, 1, 1)
                switchKnob.BorderSizePixel = 0
                switchKnob.Size = UDim2.new(0, 20, 0, 20)
                switchKnob.Position = UDim2.new(0, isEnabled and 25 or 3, 0.5, 0)
                switchKnob.AnchorPoint = Vector2.new(0, 0.5)
                switchKnob.Parent = switchBg
                
                local knobCorner = Instance.new("UICorner")
                knobCorner.CornerRadius = UDim.new(1, 0)
                knobCorner.Parent = switchKnob
                
                local function updateToggle()
                    Animation.Tween(switchBg, {BackgroundColor3 = isEnabled and theme.Primary or theme.Surface}, 0.2)
                    Animation.Tween(switchStroke, {Color = isEnabled and theme.Primary or theme.Border}, 0.2)
                    Animation.Tween(switchKnob, {Position = UDim2.new(0, isEnabled and 25 or 3, 0.5, 0)}, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                end
                
                switchBg.MouseButton1Click:Connect(function()
                    isEnabled = not isEnabled
                    updateToggle()
                    toggleConfig.Callback(isEnabled)
                end)
                
                local ToggleAPI = {}
                function ToggleAPI:Set(value)
                    isEnabled = value
                    updateToggle()
                end
                function ToggleAPI:Get()
                    return isEnabled
                end
                
                table.insert(self.Elements, toggleFrame)
                return ToggleAPI
            end

-- ═══════════════════════════════════════════════════════════════════════════════
-- CLAUDE UI - PART 4: Slider, Input, Dropdown Elements
-- ═══════════════════════════════════════════════════════════════════════════════

            -- ═══════════════════════════════════════════════════════════════
            -- SLIDER ELEMENT
            -- ═══════════════════════════════════════════════════════════════
            
            function Section:CreateSlider(sliderConfig)
                sliderConfig = Utility.Merge({
                    Title = "Slider",
                    Description = nil,
                    Min = 0,
                    Max = 100,
                    Default = 50,
                    Increment = 1,
                    Suffix = "",
                    Callback = function(value) end,
                    LayoutOrder = #self.Elements + 1
                }, sliderConfig)
                
                local currentValue = sliderConfig.Default
                
                local sliderFrame = Instance.new("Frame")
                sliderFrame.Name = sliderConfig.Title
                sliderFrame.BackgroundTransparency = 1
                sliderFrame.Size = UDim2.new(1, 0, 0, sliderConfig.Description and 68 or 52)
                sliderFrame.LayoutOrder = sliderConfig.LayoutOrder
                sliderFrame.Parent = contentFrame
                
                local sliderHeader = Instance.new("Frame")
                sliderHeader.Name = "Header"
                sliderHeader.BackgroundTransparency = 1
                sliderHeader.Size = UDim2.new(1, 0, 0, 20)
                sliderHeader.Parent = sliderFrame
                
                local sliderLabel = Instance.new("TextLabel")
                sliderLabel.Name = "Label"
                sliderLabel.BackgroundTransparency = 1
                sliderLabel.Size = UDim2.new(0.7, 0, 1, 0)
                sliderLabel.Font = theme.FontFamily
                sliderLabel.Text = sliderConfig.Title
                sliderLabel.TextColor3 = theme.TextPrimary
                sliderLabel.TextSize = theme.FontSizeMD
                sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                sliderLabel.Parent = sliderHeader
                
                local sliderValue = Instance.new("TextLabel")
                sliderValue.Name = "Value"
                sliderValue.BackgroundTransparency = 1
                sliderValue.Size = UDim2.new(0.3, 0, 1, 0)
                sliderValue.Position = UDim2.new(0.7, 0, 0, 0)
                sliderValue.Font = theme.FontFamilyMono
                sliderValue.Text = tostring(currentValue) .. sliderConfig.Suffix
                sliderValue.TextColor3 = theme.Primary
                sliderValue.TextSize = theme.FontSizeMD
                sliderValue.TextXAlignment = Enum.TextXAlignment.Right
                sliderValue.Parent = sliderHeader
                
                if sliderConfig.Description then
                    local sliderDesc = Instance.new("TextLabel")
                    sliderDesc.Name = "Description"
                    sliderDesc.BackgroundTransparency = 1
                    sliderDesc.Size = UDim2.new(1, 0, 0, 14)
                    sliderDesc.Position = UDim2.new(0, 0, 0, 22)
                    sliderDesc.Font = theme.FontFamily
                    sliderDesc.Text = sliderConfig.Description
                    sliderDesc.TextColor3 = theme.TextTertiary
                    sliderDesc.TextSize = theme.FontSizeSM
                    sliderDesc.TextXAlignment = Enum.TextXAlignment.Left
                    sliderDesc.Parent = sliderFrame
                end
                
                local trackFrame = Instance.new("Frame")
                trackFrame.Name = "Track"
                trackFrame.BackgroundColor3 = theme.Surface
                trackFrame.BorderSizePixel = 0
                trackFrame.Size = UDim2.new(1, 0, 0, 8)
                trackFrame.Position = UDim2.new(0, 0, 1, -16)
                trackFrame.Parent = sliderFrame
                
                local trackCorner = Instance.new("UICorner")
                trackCorner.CornerRadius = UDim.new(1, 0)
                trackCorner.Parent = trackFrame
                
                local trackStroke = Instance.new("UIStroke")
                trackStroke.Color = theme.Border
                trackStroke.Thickness = 1
                trackStroke.Parent = trackFrame
                
                local fillFrame = Instance.new("Frame")
                fillFrame.Name = "Fill"
                fillFrame.BackgroundColor3 = theme.Primary
                fillFrame.BorderSizePixel = 0
                fillFrame.Size = UDim2.new((currentValue - sliderConfig.Min) / (sliderConfig.Max - sliderConfig.Min), 0, 1, 0)
                fillFrame.Parent = trackFrame
                
                local fillCorner = Instance.new("UICorner")
                fillCorner.CornerRadius = UDim.new(1, 0)
                fillCorner.Parent = fillFrame
                
                local knob = Instance.new("TextButton")
                knob.Name = "Knob"
                knob.BackgroundColor3 = Color3.new(1, 1, 1)
                knob.BorderSizePixel = 0
                knob.Size = UDim2.new(0, 20, 0, 20)
                knob.Position = UDim2.new((currentValue - sliderConfig.Min) / (sliderConfig.Max - sliderConfig.Min), 0, 0.5, 0)
                knob.AnchorPoint = Vector2.new(0.5, 0.5)
                knob.Text = ""
                knob.AutoButtonColor = false
                knob.ZIndex = 2
                knob.Parent = trackFrame
                
                local knobCorner = Instance.new("UICorner")
                knobCorner.CornerRadius = UDim.new(1, 0)
                knobCorner.Parent = knob
                
                local knobStroke = Instance.new("UIStroke")
                knobStroke.Color = theme.Primary
                knobStroke.Thickness = 2
                knobStroke.Parent = knob
                
                local dragging = false
                
                local function updateSlider(input)
                    local relativeX = (input.Position.X - trackFrame.AbsolutePosition.X) / trackFrame.AbsoluteSize.X
                    relativeX = Utility.Clamp(relativeX, 0, 1)
                    
                    local rawValue = sliderConfig.Min + (sliderConfig.Max - sliderConfig.Min) * relativeX
                    local steppedValue = math.floor(rawValue / sliderConfig.Increment + 0.5) * sliderConfig.Increment
                    currentValue = Utility.Clamp(steppedValue, sliderConfig.Min, sliderConfig.Max)
                    
                    local fillPercent = (currentValue - sliderConfig.Min) / (sliderConfig.Max - sliderConfig.Min)
                    fillFrame.Size = UDim2.new(fillPercent, 0, 1, 0)
                    knob.Position = UDim2.new(fillPercent, 0, 0.5, 0)
                    sliderValue.Text = tostring(Utility.Round(currentValue, 2)) .. sliderConfig.Suffix
                    
                    sliderConfig.Callback(currentValue)
                end
                
                knob.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        Animation.Tween(knob, {Size = UDim2.new(0, 24, 0, 24)}, 0.15, Enum.EasingStyle.Back)
                    end
                end)
                
                knob.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                        Animation.Tween(knob, {Size = UDim2.new(0, 20, 0, 20)}, 0.15)
                    end
                end)
                
                trackFrame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        updateSlider(input)
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        updateSlider(input)
                    end
                end)
                
                local SliderAPI = {}
                function SliderAPI:Set(value)
                    currentValue = Utility.Clamp(value, sliderConfig.Min, sliderConfig.Max)
                    local fillPercent = (currentValue - sliderConfig.Min) / (sliderConfig.Max - sliderConfig.Min)
                    fillFrame.Size = UDim2.new(fillPercent, 0, 1, 0)
                    knob.Position = UDim2.new(fillPercent, 0, 0.5, 0)
                    sliderValue.Text = tostring(Utility.Round(currentValue, 2)) .. sliderConfig.Suffix
                end
                function SliderAPI:Get()
                    return currentValue
                end
                
                table.insert(self.Elements, sliderFrame)
                return SliderAPI
            end
            
            -- ═══════════════════════════════════════════════════════════════
            -- INPUT ELEMENT
            -- ═══════════════════════════════════════════════════════════════
            
            function Section:CreateInput(inputConfig)
                inputConfig = Utility.Merge({
                    Title = "Input",
                    Description = nil,
                    Placeholder = "Enter text...",
                    Default = "",
                    ClearOnFocus = false,
                    NumberOnly = false,
                    MaxLength = nil,
                    Callback = function(value) end,
                    LayoutOrder = #self.Elements + 1
                }, inputConfig)
                
                local inputFrame = Instance.new("Frame")
                inputFrame.Name = inputConfig.Title
                inputFrame.BackgroundTransparency = 1
                inputFrame.Size = UDim2.new(1, 0, 0, inputConfig.Description and 72 or 56)
                inputFrame.LayoutOrder = inputConfig.LayoutOrder
                inputFrame.Parent = contentFrame
                
                local inputLabel = Instance.new("TextLabel")
                inputLabel.Name = "Label"
                inputLabel.BackgroundTransparency = 1
                inputLabel.Size = UDim2.new(1, 0, 0, 18)
                inputLabel.Font = theme.FontFamily
                inputLabel.Text = inputConfig.Title
                inputLabel.TextColor3 = theme.TextPrimary
                inputLabel.TextSize = theme.FontSizeMD
                inputLabel.TextXAlignment = Enum.TextXAlignment.Left
                inputLabel.Parent = inputFrame
                
                if inputConfig.Description then
                    local inputDesc = Instance.new("TextLabel")
                    inputDesc.Name = "Description"
                    inputDesc.BackgroundTransparency = 1
                    inputDesc.Size = UDim2.new(1, 0, 0, 14)
                    inputDesc.Position = UDim2.new(0, 0, 0, 20)
                    inputDesc.Font = theme.FontFamily
                    inputDesc.Text = inputConfig.Description
                    inputDesc.TextColor3 = theme.TextTertiary
                    inputDesc.TextSize = theme.FontSizeSM
                    inputDesc.TextXAlignment = Enum.TextXAlignment.Left
                    inputDesc.Parent = inputFrame
                end
                
                local inputBox = Instance.new("TextBox")
                inputBox.Name = "TextBox"
                inputBox.BackgroundColor3 = theme.Surface
                inputBox.BorderSizePixel = 0
                inputBox.Size = UDim2.new(1, 0, 0, 36)
                inputBox.Position = UDim2.new(0, 0, 1, -36)
                inputBox.Font = theme.FontFamily
                inputBox.PlaceholderText = inputConfig.Placeholder
                inputBox.PlaceholderColor3 = theme.TextTertiary
                inputBox.Text = inputConfig.Default
                inputBox.TextColor3 = theme.TextPrimary
                inputBox.TextSize = theme.FontSizeMD
                inputBox.ClearTextOnFocus = inputConfig.ClearOnFocus
                inputBox.Parent = inputFrame
                
                local inputCorner = Instance.new("UICorner")
                inputCorner.CornerRadius = UDim.new(0, theme.RadiusMD)
                inputCorner.Parent = inputBox
                
                local inputStroke = Instance.new("UIStroke")
                inputStroke.Color = theme.Border
                inputStroke.Thickness = 1
                inputStroke.Parent = inputBox
                
                local inputPadding = Instance.new("UIPadding")
                inputPadding.PaddingLeft = UDim.new(0, 12)
                inputPadding.PaddingRight = UDim.new(0, 12)
                inputPadding.Parent = inputBox
                
                inputBox.Focused:Connect(function()
                    Animation.Tween(inputStroke, {Color = theme.Primary}, 0.15)
                    Animation.Tween(inputBox, {BackgroundColor3 = theme.BackgroundElevated}, 0.15)
                end)
                
                inputBox.FocusLost:Connect(function(enterPressed)
                    Animation.Tween(inputStroke, {Color = theme.Border}, 0.15)
                    Animation.Tween(inputBox, {BackgroundColor3 = theme.Surface}, 0.15)
                    if enterPressed then
                        inputConfig.Callback(inputBox.Text)
                    end
                end)
                
                inputBox:GetPropertyChangedSignal("Text"):Connect(function()
                    local text = inputBox.Text
                    if inputConfig.NumberOnly then
                        text = text:gsub("[^%d%.%-]", "")
                    end
                    if inputConfig.MaxLength and #text > inputConfig.MaxLength then
                        text = text:sub(1, inputConfig.MaxLength)
                    end
                    if text ~= inputBox.Text then
                        inputBox.Text = text
                    end
                end)
                
                local InputAPI = {}
                function InputAPI:Set(value)
                    inputBox.Text = tostring(value)
                end
                function InputAPI:Get()
                    return inputBox.Text
                end
                function InputAPI:Focus()
                    inputBox:CaptureFocus()
                end
                
                table.insert(self.Elements, inputFrame)
                return InputAPI
            end
            
            -- ═══════════════════════════════════════════════════════════════
            -- DROPDOWN ELEMENT
            -- ═══════════════════════════════════════════════════════════════
            
            function Section:CreateDropdown(dropdownConfig)
                dropdownConfig = Utility.Merge({
                    Title = "Dropdown",
                    Description = nil,
                    Options = {},
                    Default = nil,
                    MultiSelect = false,
                    Callback = function(value) end,
                    LayoutOrder = #self.Elements + 1
                }, dropdownConfig)
                
                local isOpen = false
                local selectedValues = {}
                
                if dropdownConfig.Default then
                    if dropdownConfig.MultiSelect and type(dropdownConfig.Default) == "table" then
                        selectedValues = Utility.DeepCopy(dropdownConfig.Default)
                    else
                        selectedValues = {dropdownConfig.Default}
                    end
                end
                
                local dropdownFrame = Instance.new("Frame")
                dropdownFrame.Name = dropdownConfig.Title
                dropdownFrame.BackgroundTransparency = 1
                dropdownFrame.Size = UDim2.new(1, 0, 0, dropdownConfig.Description and 72 or 56)
                dropdownFrame.LayoutOrder = dropdownConfig.LayoutOrder
                dropdownFrame.ClipsDescendants = false
                dropdownFrame.ZIndex = 10
                dropdownFrame.Parent = contentFrame
                
                local dropdownLabel = Instance.new("TextLabel")
                dropdownLabel.Name = "Label"
                dropdownLabel.BackgroundTransparency = 1
                dropdownLabel.Size = UDim2.new(1, 0, 0, 18)
                dropdownLabel.Font = theme.FontFamily
                dropdownLabel.Text = dropdownConfig.Title
                dropdownLabel.TextColor3 = theme.TextPrimary
                dropdownLabel.TextSize = theme.FontSizeMD
                dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                dropdownLabel.ZIndex = 10
                dropdownLabel.Parent = dropdownFrame
                
                if dropdownConfig.Description then
                    local dropdownDesc = Instance.new("TextLabel")
                    dropdownDesc.Name = "Description"
                    dropdownDesc.BackgroundTransparency = 1
                    dropdownDesc.Size = UDim2.new(1, 0, 0, 14)
                    dropdownDesc.Position = UDim2.new(0, 0, 0, 20)
                    dropdownDesc.Font = theme.FontFamily
                    dropdownDesc.Text = dropdownConfig.Description
                    dropdownDesc.TextColor3 = theme.TextTertiary
                    dropdownDesc.TextSize = theme.FontSizeSM
                    dropdownDesc.TextXAlignment = Enum.TextXAlignment.Left
                    dropdownDesc.ZIndex = 10
                    dropdownDesc.Parent = dropdownFrame
                end
                
                local mainButton = Instance.new("TextButton")
                mainButton.Name = "MainButton"
                mainButton.BackgroundColor3 = theme.Surface
                mainButton.BorderSizePixel = 0
                mainButton.Size = UDim2.new(1, 0, 0, 36)
                mainButton.Position = UDim2.new(0, 0, 1, -36)
                mainButton.Text = ""
                mainButton.AutoButtonColor = false
                mainButton.ZIndex = 11
                mainButton.Parent = dropdownFrame
                
                local mainCorner = Instance.new("UICorner")
                mainCorner.CornerRadius = UDim.new(0, theme.RadiusMD)
                mainCorner.Parent = mainButton
                
                local mainStroke = Instance.new("UIStroke")
                mainStroke.Color = theme.Border
                mainStroke.Thickness = 1
                mainStroke.Parent = mainButton
                
                local mainLabel = Instance.new("TextLabel")
                mainLabel.Name = "Label"
                mainLabel.BackgroundTransparency = 1
                mainLabel.Size = UDim2.new(1, -40, 1, 0)
                mainLabel.Position = UDim2.new(0, 12, 0, 0)
                mainLabel.Font = theme.FontFamily
                mainLabel.Text = #selectedValues > 0 and table.concat(selectedValues, ", ") or "Select..."
                mainLabel.TextColor3 = #selectedValues > 0 and theme.TextPrimary or theme.TextTertiary
                mainLabel.TextSize = theme.FontSizeMD
                mainLabel.TextXAlignment = Enum.TextXAlignment.Left
                mainLabel.TextTruncate = Enum.TextTruncate.AtEnd
                mainLabel.ZIndex = 11
                mainLabel.Parent = mainButton
                
                local chevron = Instance.new("ImageLabel")
                chevron.Name = "Chevron"
                chevron.BackgroundTransparency = 1
                chevron.Size = UDim2.new(0, 16, 0, 16)
                chevron.Position = UDim2.new(1, -28, 0.5, 0)
                chevron.AnchorPoint = Vector2.new(0, 0.5)
                chevron.Image = Icons.ChevronDown
                chevron.ImageColor3 = theme.TextSecondary
                chevron.ZIndex = 11
                chevron.Parent = mainButton
                
                local optionsFrame = Instance.new("Frame")
                optionsFrame.Name = "Options"
                optionsFrame.BackgroundColor3 = theme.BackgroundElevated
                optionsFrame.BorderSizePixel = 0
                optionsFrame.Size = UDim2.new(1, 0, 0, 0)
                optionsFrame.Position = UDim2.new(0, 0, 1, 4)
                optionsFrame.ClipsDescendants = true
                optionsFrame.Visible = false
                optionsFrame.ZIndex = 100
                optionsFrame.Parent = mainButton
                
                local optionsCorner = Instance.new("UICorner")
                optionsCorner.CornerRadius = UDim.new(0, theme.RadiusMD)
                optionsCorner.Parent = optionsFrame
                
                local optionsStroke = Instance.new("UIStroke")
                optionsStroke.Color = theme.Border
                optionsStroke.Thickness = 1
                optionsStroke.Parent = optionsFrame
                
                local optionsList = Instance.new("ScrollingFrame")
                optionsList.Name = "List"
                optionsList.BackgroundTransparency = 1
                optionsList.Size = UDim2.new(1, 0, 1, 0)
                optionsList.CanvasSize = UDim2.new(0, 0, 0, 0)
                optionsList.ScrollBarThickness = 3
                optionsList.ScrollBarImageColor3 = theme.ScrollbarThumb
                optionsList.AutomaticCanvasSize = Enum.AutomaticSize.Y
                optionsList.ZIndex = 101
                optionsList.Parent = optionsFrame
                
                local optionsPadding = Instance.new("UIPadding")
                optionsPadding.PaddingTop = UDim.new(0, 4)
                optionsPadding.PaddingBottom = UDim.new(0, 4)
                optionsPadding.PaddingLeft = UDim.new(0, 4)
                optionsPadding.PaddingRight = UDim.new(0, 4)
                optionsPadding.Parent = optionsList
                
                local optionsLayout = Instance.new("UIListLayout")
                optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
                optionsLayout.Padding = UDim.new(0, 2)
                optionsLayout.Parent = optionsList
                
                local function updateDisplay()
                    mainLabel.Text = #selectedValues > 0 and table.concat(selectedValues, ", ") or "Select..."
                    mainLabel.TextColor3 = #selectedValues > 0 and theme.TextPrimary or theme.TextTertiary
                end
                
                local function createOption(optionText, index)
                    local isSelected = table.find(selectedValues, optionText) ~= nil
                    
                    local optionButton = Instance.new("TextButton")
                    optionButton.Name = optionText
                    optionButton.BackgroundColor3 = isSelected and theme.Primary or theme.Surface
                    optionButton.BackgroundTransparency = isSelected and 0.1 or 1
                    optionButton.BorderSizePixel = 0
                    optionButton.Size = UDim2.new(1, 0, 0, 32)
                    optionButton.Text = ""
                    optionButton.AutoButtonColor = false
                    optionButton.LayoutOrder = index
                    optionButton.ZIndex = 102
                    optionButton.Parent = optionsList
                    
                    local optionCorner = Instance.new("UICorner")
                    optionCorner.CornerRadius = UDim.new(0, theme.RadiusSM)
                    optionCorner.Parent = optionButton
                    
                    local optionLabel = Instance.new("TextLabel")
                    optionLabel.Name = "Label"
                    optionLabel.BackgroundTransparency = 1
                    optionLabel.Size = UDim2.new(1, dropdownConfig.MultiSelect and -30 or -16, 1, 0)
                    optionLabel.Position = UDim2.new(0, 8, 0, 0)
                    optionLabel.Font = theme.FontFamily
                    optionLabel.Text = optionText
                    optionLabel.TextColor3 = isSelected and theme.Primary or theme.TextPrimary
                    optionLabel.TextSize = theme.FontSizeMD
                    optionLabel.TextXAlignment = Enum.TextXAlignment.Left
                    optionLabel.ZIndex = 102
                    optionLabel.Parent = optionButton
                    
                    if dropdownConfig.MultiSelect then
                        local checkbox = Instance.new("Frame")
                        checkbox.Name = "Checkbox"
                        checkbox.BackgroundColor3 = isSelected and theme.Primary or theme.Surface
                        checkbox.BorderSizePixel = 0
                        checkbox.Size = UDim2.new(0, 18, 0, 18)
                        checkbox.Position = UDim2.new(1, -26, 0.5, 0)
                        checkbox.AnchorPoint = Vector2.new(0, 0.5)
                        checkbox.ZIndex = 102
                        checkbox.Parent = optionButton
                        
                        local checkCorner = Instance.new("UICorner")
                        checkCorner.CornerRadius = UDim.new(0, 4)
                        checkCorner.Parent = checkbox
                        
                        local checkStroke = Instance.new("UIStroke")
                        checkStroke.Color = isSelected and theme.Primary or theme.Border
                        checkStroke.Thickness = 1
                        checkStroke.Parent = checkbox
                        
                        if isSelected then
                            local checkIcon = Instance.new("ImageLabel")
                            checkIcon.Name = "Check"
                            checkIcon.BackgroundTransparency = 1
                            checkIcon.Size = UDim2.new(0, 12, 0, 12)
                            checkIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
                            checkIcon.AnchorPoint = Vector2.new(0.5, 0.5)
                            checkIcon.Image = Icons.Check
                            checkIcon.ImageColor3 = Color3.new(1, 1, 1)
                            checkIcon.ZIndex = 103
                            checkIcon.Parent = checkbox
                        end
                    end
                    
                    optionButton.MouseEnter:Connect(function()
                        Animation.Tween(optionButton, {BackgroundTransparency = 0, BackgroundColor3 = theme.SurfaceHover}, 0.1)
                    end)
                    
                    optionButton.MouseLeave:Connect(function()
                        local sel = table.find(selectedValues, optionText) ~= nil
                        Animation.Tween(optionButton, {BackgroundTransparency = sel and 0.1 or 1, BackgroundColor3 = sel and theme.Primary or theme.Surface}, 0.1)
                    end)
                    
                    optionButton.MouseButton1Click:Connect(function()
                        if dropdownConfig.MultiSelect then
                            local idx = table.find(selectedValues, optionText)
                            if idx then
                                table.remove(selectedValues, idx)
                            else
                                table.insert(selectedValues, optionText)
                            end
                            updateDisplay()
                            dropdownConfig.Callback(selectedValues)
                            for _, child in ipairs(optionsList:GetChildren()) do
                                if child:IsA("TextButton") then child:Destroy() end
                            end
                            for i, opt in ipairs(dropdownConfig.Options) do
                                createOption(opt, i)
                            end
                        else
                            selectedValues = {optionText}
                            updateDisplay()
                            dropdownConfig.Callback(optionText)
                            isOpen = false
                            Animation.Tween(chevron, {Rotation = 0}, 0.2)
                            Animation.Tween(optionsFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.2, Enum.EasingStyle.Quart)
                            Animation.Tween(mainStroke, {Color = theme.Border}, 0.15)
                            task.delay(0.2, function()
                                if not isOpen then optionsFrame.Visible = false end
                            end)
                        end
                    end)
                    
                    return optionButton
                end
                
                for i, option in ipairs(dropdownConfig.Options) do
                    createOption(option, i)
                end
                
                mainButton.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    if isOpen then
                        optionsFrame.Visible = true
                        local maxHeight = math.min(#dropdownConfig.Options * 34 + 8, 200)
                        Animation.Tween(optionsFrame, {Size = UDim2.new(1, 0, 0, maxHeight)}, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                        Animation.Tween(chevron, {Rotation = 180}, 0.2)
                        Animation.Tween(mainStroke, {Color = theme.Primary}, 0.15)
                    else
                        Animation.Tween(optionsFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.2, Enum.EasingStyle.Quart)
                        Animation.Tween(chevron, {Rotation = 0}, 0.2)
                        Animation.Tween(mainStroke, {Color = theme.Border}, 0.15)
                        task.delay(0.2, function()
                            if not isOpen then optionsFrame.Visible = false end
                        end)
                    end
                end)
                
                local DropdownAPI = {}
                function DropdownAPI:Set(value)
                    if dropdownConfig.MultiSelect then
                        selectedValues = type(value) == "table" and value or {value}
                    else
                        selectedValues = {value}
                    end
                    updateDisplay()
                end
                function DropdownAPI:Get()
                    return dropdownConfig.MultiSelect and selectedValues or selectedValues[1]
                end
                function DropdownAPI:SetOptions(newOptions)
                    dropdownConfig.Options = newOptions
                    for _, child in ipairs(optionsList:GetChildren()) do
                        if child:IsA("TextButton") then child:Destroy() end
                    end
                    for i, option in ipairs(newOptions) do
                        createOption(option, i)
                    end
                end
                
                table.insert(self.Elements, dropdownFrame)
                return DropdownAPI
            end

-- ═══════════════════════════════════════════════════════════════════════════════
-- CLAUDE UI - PART 5: ColorPicker, Keybind, Label, Paragraph, Divider
-- ═══════════════════════════════════════════════════════════════════════════════

            -- ═══════════════════════════════════════════════════════════════
            -- COLOR PICKER ELEMENT
            -- ═══════════════════════════════════════════════════════════════
            
            function Section:CreateColorPicker(colorConfig)
                colorConfig = Utility.Merge({
                    Title = "Color Picker",
                    Description = nil,
                    Default = Color3.fromRGB(210, 139, 97),
                    Callback = function(color) end,
                    LayoutOrder = #self.Elements + 1
                }, colorConfig)
                
                local currentColor = colorConfig.Default
                local isOpen = false
                local h, s, v = currentColor:ToHSV()
                
                local colorFrame = Instance.new("Frame")
                colorFrame.Name = colorConfig.Title
                colorFrame.BackgroundTransparency = 1
                colorFrame.Size = UDim2.new(1, 0, 0, colorConfig.Description and 52 or 36)
                colorFrame.LayoutOrder = colorConfig.LayoutOrder
                colorFrame.ClipsDescendants = false
                colorFrame.ZIndex = 5
                colorFrame.Parent = contentFrame
                
                local colorLabel = Instance.new("TextLabel")
                colorLabel.Name = "Label"
                colorLabel.BackgroundTransparency = 1
                colorLabel.Size = UDim2.new(1, -60, 0, 18)
                colorLabel.Position = UDim2.new(0, 0, 0, colorConfig.Description and 4 or 9)
                colorLabel.Font = theme.FontFamily
                colorLabel.Text = colorConfig.Title
                colorLabel.TextColor3 = theme.TextPrimary
                colorLabel.TextSize = theme.FontSizeMD
                colorLabel.TextXAlignment = Enum.TextXAlignment.Left
                colorLabel.ZIndex = 5
                colorLabel.Parent = colorFrame
                
                if colorConfig.Description then
                    local colorDesc = Instance.new("TextLabel")
                    colorDesc.Name = "Description"
                    colorDesc.BackgroundTransparency = 1
                    colorDesc.Size = UDim2.new(1, -60, 0, 14)
                    colorDesc.Position = UDim2.new(0, 0, 0, 24)
                    colorDesc.Font = theme.FontFamily
                    colorDesc.Text = colorConfig.Description
                    colorDesc.TextColor3 = theme.TextTertiary
                    colorDesc.TextSize = theme.FontSizeSM
                    colorDesc.TextXAlignment = Enum.TextXAlignment.Left
                    colorDesc.ZIndex = 5
                    colorDesc.Parent = colorFrame
                end
                
                local previewButton = Instance.new("TextButton")
                previewButton.Name = "Preview"
                previewButton.BackgroundColor3 = currentColor
                previewButton.BorderSizePixel = 0
                previewButton.Size = UDim2.new(0, 48, 0, 28)
                previewButton.Position = UDim2.new(1, 0, 0.5, 0)
                previewButton.AnchorPoint = Vector2.new(1, 0.5)
                previewButton.Text = ""
                previewButton.AutoButtonColor = false
                previewButton.ZIndex = 5
                previewButton.Parent = colorFrame
                
                local previewCorner = Instance.new("UICorner")
                previewCorner.CornerRadius = UDim.new(0, theme.RadiusMD)
                previewCorner.Parent = previewButton
                
                local previewStroke = Instance.new("UIStroke")
                previewStroke.Color = theme.Border
                previewStroke.Thickness = 1
                previewStroke.Parent = previewButton
                
                local pickerFrame = Instance.new("Frame")
                pickerFrame.Name = "Picker"
                pickerFrame.BackgroundColor3 = theme.BackgroundElevated
                pickerFrame.BorderSizePixel = 0
                pickerFrame.Size = UDim2.new(0, 220, 0, 0)
                pickerFrame.Position = UDim2.new(1, 0, 1, 8)
                pickerFrame.AnchorPoint = Vector2.new(1, 0)
                pickerFrame.Visible = false
                pickerFrame.ClipsDescendants = true
                pickerFrame.ZIndex = 50
                pickerFrame.Parent = previewButton
                
                local pickerCorner = Instance.new("UICorner")
                pickerCorner.CornerRadius = UDim.new(0, theme.RadiusLG)
                pickerCorner.Parent = pickerFrame
                
                local pickerStroke = Instance.new("UIStroke")
                pickerStroke.Color = theme.Border
                pickerStroke.Thickness = 1
                pickerStroke.Parent = pickerFrame
                
                local gradientFrame = Instance.new("Frame")
                gradientFrame.Name = "Gradient"
                gradientFrame.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                gradientFrame.BorderSizePixel = 0
                gradientFrame.Size = UDim2.new(1, -16, 0, 140)
                gradientFrame.Position = UDim2.new(0, 8, 0, 8)
                gradientFrame.ZIndex = 51
                gradientFrame.Parent = pickerFrame
                
                local gradientCorner = Instance.new("UICorner")
                gradientCorner.CornerRadius = UDim.new(0, theme.RadiusMD)
                gradientCorner.Parent = gradientFrame
                
                local whiteGradient = Instance.new("UIGradient")
                whiteGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                    ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
                })
                whiteGradient.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 1)
                })
                whiteGradient.Parent = gradientFrame
                
                local blackOverlay = Instance.new("Frame")
                blackOverlay.Name = "BlackOverlay"
                blackOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
                blackOverlay.BorderSizePixel = 0
                blackOverlay.Size = UDim2.new(1, 0, 1, 0)
                blackOverlay.ZIndex = 52
                blackOverlay.Parent = gradientFrame
                
                local blackCorner = Instance.new("UICorner")
                blackCorner.CornerRadius = UDim.new(0, theme.RadiusMD)
                blackCorner.Parent = blackOverlay
                
                local blackGradient = Instance.new("UIGradient")
                blackGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
                    ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
                })
                blackGradient.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0)
                })
                blackGradient.Rotation = 90
                blackGradient.Parent = blackOverlay
                
                local colorSelector = Instance.new("Frame")
                colorSelector.Name = "Selector"
                colorSelector.BackgroundColor3 = currentColor
                colorSelector.BorderSizePixel = 0
                colorSelector.Size = UDim2.new(0, 16, 0, 16)
                colorSelector.Position = UDim2.new(s, 0, 1 - v, 0)
                colorSelector.AnchorPoint = Vector2.new(0.5, 0.5)
                colorSelector.ZIndex = 53
                colorSelector.Parent = gradientFrame
                
                local selectorCorner = Instance.new("UICorner")
                selectorCorner.CornerRadius = UDim.new(1, 0)
                selectorCorner.Parent = colorSelector
                
                local selectorStroke = Instance.new("UIStroke")
                selectorStroke.Color = Color3.new(1, 1, 1)
                selectorStroke.Thickness = 2
                selectorStroke.Parent = colorSelector
                
                local hueFrame = Instance.new("Frame")
                hueFrame.Name = "HueSlider"
                hueFrame.BackgroundColor3 = Color3.new(1, 1, 1)
                hueFrame.BorderSizePixel = 0
                hueFrame.Size = UDim2.new(1, -16, 0, 16)
                hueFrame.Position = UDim2.new(0, 8, 0, 156)
                hueFrame.ZIndex = 51
                hueFrame.Parent = pickerFrame
                
                local hueCorner = Instance.new("UICorner")
                hueCorner.CornerRadius = UDim.new(1, 0)
                hueCorner.Parent = hueFrame
                
                local hueGradient = Instance.new("UIGradient")
                hueGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
                    ColorSequenceKeypoint.new(0.167, Color3.fromHSV(0.167, 1, 1)),
                    ColorSequenceKeypoint.new(0.333, Color3.fromHSV(0.333, 1, 1)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
                    ColorSequenceKeypoint.new(0.667, Color3.fromHSV(0.667, 1, 1)),
                    ColorSequenceKeypoint.new(0.833, Color3.fromHSV(0.833, 1, 1)),
                    ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
                })
                hueGradient.Parent = hueFrame
                
                local hueSelector = Instance.new("Frame")
                hueSelector.Name = "Selector"
                hueSelector.BackgroundColor3 = Color3.new(1, 1, 1)
                hueSelector.BorderSizePixel = 0
                hueSelector.Size = UDim2.new(0, 8, 0, 20)
                hueSelector.Position = UDim2.new(h, 0, 0.5, 0)
                hueSelector.AnchorPoint = Vector2.new(0.5, 0.5)
                hueSelector.ZIndex = 52
                hueSelector.Parent = hueFrame
                
                local hueSelectorCorner = Instance.new("UICorner")
                hueSelectorCorner.CornerRadius = UDim.new(0, 2)
                hueSelectorCorner.Parent = hueSelector
                
                local hueSelectorStroke = Instance.new("UIStroke")
                hueSelectorStroke.Color = theme.Border
                hueSelectorStroke.Thickness = 1
                hueSelectorStroke.Parent = hueSelector
                
                local function updateColor()
                    currentColor = Color3.fromHSV(h, s, v)
                    previewButton.BackgroundColor3 = currentColor
                    colorSelector.BackgroundColor3 = currentColor
                    gradientFrame.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                    colorConfig.Callback(currentColor)
                end
                
                local function updateSelectors()
                    colorSelector.Position = UDim2.new(s, 0, 1 - v, 0)
                    hueSelector.Position = UDim2.new(h, 0, 0.5, 0)
                end
                
                local draggingGradient = false
                local draggingHue = false
                
                gradientFrame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingGradient = true
                        local relX = Utility.Clamp((input.Position.X - gradientFrame.AbsolutePosition.X) / gradientFrame.AbsoluteSize.X, 0, 1)
                        local relY = Utility.Clamp((input.Position.Y - gradientFrame.AbsolutePosition.Y) / gradientFrame.AbsoluteSize.Y, 0, 1)
                        s = relX
                        v = 1 - relY
                        updateColor()
                        updateSelectors()
                    end
                end)
                
                gradientFrame.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingGradient = false
                    end
                end)
                
                hueFrame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingHue = true
                        local relX = Utility.Clamp((input.Position.X - hueFrame.AbsolutePosition.X) / hueFrame.AbsoluteSize.X, 0, 1)
                        h = relX
                        updateColor()
                        updateSelectors()
                    end
                end)
                
                hueFrame.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingHue = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        if draggingGradient then
                            local relX = Utility.Clamp((input.Position.X - gradientFrame.AbsolutePosition.X) / gradientFrame.AbsoluteSize.X, 0, 1)
                            local relY = Utility.Clamp((input.Position.Y - gradientFrame.AbsolutePosition.Y) / gradientFrame.AbsoluteSize.Y, 0, 1)
                            s = relX
                            v = 1 - relY
                            updateColor()
                            updateSelectors()
                        elseif draggingHue then
                            local relX = Utility.Clamp((input.Position.X - hueFrame.AbsolutePosition.X) / hueFrame.AbsoluteSize.X, 0, 1)
                            h = relX
                            updateColor()
                            updateSelectors()
                        end
                    end
                end)
                
                previewButton.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    if isOpen then
                        pickerFrame.Visible = true
                        Animation.Tween(pickerFrame, {Size = UDim2.new(0, 220, 0, 188)}, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                    else
                        Animation.Tween(pickerFrame, {Size = UDim2.new(0, 220, 0, 0)}, 0.2)
                        task.delay(0.2, function()
                            if not isOpen then pickerFrame.Visible = false end
                        end)
                    end
                end)
                
                local ColorAPI = {}
                function ColorAPI:Set(color)
                    currentColor = color
                    h, s, v = color:ToHSV()
                    previewButton.BackgroundColor3 = color
                    if isOpen then
                        updateColor()
                        updateSelectors()
                    end
                end
                function ColorAPI:Get()
                    return currentColor
                end
                
                table.insert(self.Elements, colorFrame)
                return ColorAPI
            end
            
            -- ═══════════════════════════════════════════════════════════════
            -- KEYBIND ELEMENT
            -- ═══════════════════════════════════════════════════════════════
            
            function Section:CreateKeybind(keybindConfig)
                keybindConfig = Utility.Merge({
                    Title = "Keybind",
                    Description = nil,
                    Default = Enum.KeyCode.E,
                    IgnoreInput = {Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.Space},
                    Callback = function(keyCode) end,
                    LayoutOrder = #self.Elements + 1
                }, keybindConfig)
                
                local currentKey = keybindConfig.Default
                local listening = false
                
                local keybindFrame = Instance.new("Frame")
                keybindFrame.Name = keybindConfig.Title
                keybindFrame.BackgroundTransparency = 1
                keybindFrame.Size = UDim2.new(1, 0, 0, keybindConfig.Description and 52 or 36)
                keybindFrame.LayoutOrder = keybindConfig.LayoutOrder
                keybindFrame.Parent = contentFrame
                
                local keybindLabel = Instance.new("TextLabel")
                keybindLabel.Name = "Label"
                keybindLabel.BackgroundTransparency = 1
                keybindLabel.Size = UDim2.new(1, -80, 0, 18)
                keybindLabel.Position = UDim2.new(0, 0, 0, keybindConfig.Description and 4 or 9)
                keybindLabel.Font = theme.FontFamily
                keybindLabel.Text = keybindConfig.Title
                keybindLabel.TextColor3 = theme.TextPrimary
                keybindLabel.TextSize = theme.FontSizeMD
                keybindLabel.TextXAlignment = Enum.TextXAlignment.Left
                keybindLabel.Parent = keybindFrame
                
                if keybindConfig.Description then
                    local keybindDesc = Instance.new("TextLabel")
                    keybindDesc.Name = "Description"
                    keybindDesc.BackgroundTransparency = 1
                    keybindDesc.Size = UDim2.new(1, -80, 0, 14)
                    keybindDesc.Position = UDim2.new(0, 0, 0, 24)
                    keybindDesc.Font = theme.FontFamily
                    keybindDesc.Text = keybindConfig.Description
                    keybindDesc.TextColor3 = theme.TextTertiary
                    keybindDesc.TextSize = theme.FontSizeSM
                    keybindDesc.TextXAlignment = Enum.TextXAlignment.Left
                    keybindDesc.Parent = keybindFrame
                end
                
                local keyButton = Instance.new("TextButton")
                keyButton.Name = "KeyButton"
                keyButton.BackgroundColor3 = theme.Surface
                keyButton.BorderSizePixel = 0
                keyButton.Size = UDim2.new(0, 70, 0, 28)
                keyButton.Position = UDim2.new(1, 0, 0.5, 0)
                keyButton.AnchorPoint = Vector2.new(1, 0.5)
                keyButton.Font = theme.FontFamilyMono
                keyButton.Text = currentKey.Name
                keyButton.TextColor3 = theme.TextPrimary
                keyButton.TextSize = theme.FontSizeSM
                keyButton.AutoButtonColor = false
                keyButton.Parent = keybindFrame
                
                local keyCorner = Instance.new("UICorner")
                keyCorner.CornerRadius = UDim.new(0, theme.RadiusMD)
                keyCorner.Parent = keyButton
                
                local keyStroke = Instance.new("UIStroke")
                keyStroke.Color = theme.Border
                keyStroke.Thickness = 1
                keyStroke.Parent = keyButton
                
                keyButton.MouseButton1Click:Connect(function()
                    listening = true
                    keyButton.Text = "..."
                    Animation.Tween(keyStroke, {Color = theme.Primary}, 0.15)
                    Animation.Tween(keyButton, {BackgroundColor3 = theme.BackgroundElevated}, 0.15)
                end)
                
                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                        if not table.find(keybindConfig.IgnoreInput, input.KeyCode) then
                            currentKey = input.KeyCode
                            keyButton.Text = currentKey.Name
                            listening = false
                            Animation.Tween(keyStroke, {Color = theme.Border}, 0.15)
                            Animation.Tween(keyButton, {BackgroundColor3 = theme.Surface}, 0.15)
                        end
                    elseif not listening and input.KeyCode == currentKey and not gameProcessed then
                        keybindConfig.Callback(currentKey)
                    end
                end)
                
                local KeybindAPI = {}
                function KeybindAPI:Set(keyCode)
                    currentKey = keyCode
                    keyButton.Text = keyCode.Name
                end
                function KeybindAPI:Get()
                    return currentKey
                end
                
                table.insert(self.Elements, keybindFrame)
                return KeybindAPI
            end
            
            -- ═══════════════════════════════════════════════════════════════
            -- LABEL ELEMENT
            -- ═══════════════════════════════════════════════════════════════
            
            function Section:CreateLabel(text, layoutOrder)
                local labelFrame = Instance.new("TextLabel")
                labelFrame.Name = "Label"
                labelFrame.BackgroundTransparency = 1
                labelFrame.Size = UDim2.new(1, 0, 0, 0)
                labelFrame.AutomaticSize = Enum.AutomaticSize.Y
                labelFrame.Font = theme.FontFamily
                labelFrame.Text = text
                labelFrame.TextColor3 = theme.TextSecondary
                labelFrame.TextSize = theme.FontSizeSM
                labelFrame.TextWrapped = true
                labelFrame.TextXAlignment = Enum.TextXAlignment.Left
                labelFrame.LayoutOrder = layoutOrder or (#self.Elements + 1)
                labelFrame.Parent = contentFrame
                
                local LabelAPI = {}
                function LabelAPI:Set(newText)
                    labelFrame.Text = newText
                end
                
                table.insert(self.Elements, labelFrame)
                return LabelAPI
            end
            
            -- ═══════════════════════════════════════════════════════════════
            -- PARAGRAPH ELEMENT
            -- ═══════════════════════════════════════════════════════════════
            
            function Section:CreateParagraph(paragraphConfig)
                paragraphConfig = Utility.Merge({
                    Title = "Paragraph",
                    Content = "",
                    LayoutOrder = #self.Elements + 1
                }, paragraphConfig)
                
                local paragraphFrame = Instance.new("Frame")
                paragraphFrame.Name = paragraphConfig.Title
                paragraphFrame.BackgroundTransparency = 1
                paragraphFrame.Size = UDim2.new(1, 0, 0, 0)
                paragraphFrame.AutomaticSize = Enum.AutomaticSize.Y
                paragraphFrame.LayoutOrder = paragraphConfig.LayoutOrder
                paragraphFrame.Parent = contentFrame
                
                local paragraphTitle = Instance.new("TextLabel")
                paragraphTitle.Name = "Title"
                paragraphTitle.BackgroundTransparency = 1
                paragraphTitle.Size = UDim2.new(1, 0, 0, 18)
                paragraphTitle.Font = theme.FontFamilyHeading
                paragraphTitle.Text = paragraphConfig.Title
                paragraphTitle.TextColor3 = theme.TextPrimary
                paragraphTitle.TextSize = theme.FontSizeMD
                paragraphTitle.TextXAlignment = Enum.TextXAlignment.Left
                paragraphTitle.Parent = paragraphFrame
                
                local paragraphContent = Instance.new("TextLabel")
                paragraphContent.Name = "Content"
                paragraphContent.BackgroundTransparency = 1
                paragraphContent.Size = UDim2.new(1, 0, 0, 0)
                paragraphContent.AutomaticSize = Enum.AutomaticSize.Y
                paragraphContent.Position = UDim2.new(0, 0, 0, 22)
                paragraphContent.Font = theme.FontFamily
                paragraphContent.Text = paragraphConfig.Content
                paragraphContent.TextColor3 = theme.TextSecondary
                paragraphContent.TextSize = theme.FontSizeSM
                paragraphContent.TextWrapped = true
                paragraphContent.TextXAlignment = Enum.TextXAlignment.Left
                paragraphContent.Parent = paragraphFrame
                
                local ParagraphAPI = {}
                function ParagraphAPI:SetTitle(title)
                    paragraphTitle.Text = title
                end
                function ParagraphAPI:SetContent(content)
                    paragraphContent.Text = content
                end
                
                table.insert(self.Elements, paragraphFrame)
                return ParagraphAPI
            end
            
            -- ═══════════════════════════════════════════════════════════════
            -- DIVIDER ELEMENT
            -- ═══════════════════════════════════════════════════════════════
            
            function Section:CreateDivider(layoutOrder)
                local dividerFrame = Instance.new("Frame")
                dividerFrame.Name = "Divider"
                dividerFrame.BackgroundColor3 = theme.Border
                dividerFrame.BorderSizePixel = 0
                dividerFrame.Size = UDim2.new(1, 0, 0, 1)
                dividerFrame.LayoutOrder = layoutOrder or (#self.Elements + 1)
                dividerFrame.Parent = contentFrame
                
                table.insert(self.Elements, dividerFrame)
                return dividerFrame
            end
            
            table.insert(self.Sections, Section)
            return Section
        end
        
        table.insert(self.Tabs, Tab)
        
        if #self.Tabs == 1 then
            self:SelectTab(Tab)
        end
        
        return Tab
    end
    
    -- Mount window
    mainFrame.Parent = self._screenGui
    Window:Show()
    table.insert(self._windows, Window)
    
    return Window
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- CLAUDE UI - PART 6: Toast, Modal, ContextMenu, Tooltip, Utilities, Cleanup
-- ═══════════════════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════════════════
-- TOAST NOTIFICATIONS
-- ═══════════════════════════════════════════════════════════════════════════════

function ClaudeUI:Toast(toastConfig)
    toastConfig = Utility.Merge({
        Title = "Notification",
        Description = nil,
        Type = "Info",
        Duration = 4,
        Icon = nil,
    }, toastConfig)
    
    local theme = self._activeTheme
    
    local typeColors = {
        Info = {bg = theme.InfoBackground, accent = theme.Info, icon = Icons.Info},
        Success = {bg = theme.SuccessBackground, accent = theme.Success, icon = Icons.Success},
        Warning = {bg = theme.WarningBackground, accent = theme.Warning, icon = Icons.Warning},
        Error = {bg = theme.ErrorBackground, accent = theme.Error, icon = Icons.Error},
    }
    
    local typeData = typeColors[toastConfig.Type] or typeColors.Info
    
    local toastFrame = Instance.new("Frame")
    toastFrame.Name = "Toast"
    toastFrame.BackgroundColor3 = theme.BackgroundElevated
    toastFrame.BorderSizePixel = 0
    toastFrame.Size = UDim2.new(0, 340, 0, toastConfig.Description and 68 or 48)
    toastFrame.Position = UDim2.new(1, 20, 0, 0)
    toastFrame.ClipsDescendants = true
    toastFrame.Parent = self._toastContainer
    
    local toastCorner = Instance.new("UICorner")
    toastCorner.CornerRadius = UDim.new(0, theme.RadiusLG)
    toastCorner.Parent = toastFrame
    
    local toastStroke = Instance.new("UIStroke")
    toastStroke.Color = theme.Border
    toastStroke.Thickness = 1
    toastStroke.Parent = toastFrame
    
    local accentBar = Instance.new("Frame")
    accentBar.Name = "Accent"
    accentBar.BackgroundColor3 = typeData.accent
    accentBar.BorderSizePixel = 0
    accentBar.Size = UDim2.new(0, 4, 1, 0)
    accentBar.Parent = toastFrame
    
    local toastIcon = Instance.new("ImageLabel")
    toastIcon.Name = "Icon"
    toastIcon.BackgroundTransparency = 1
    toastIcon.Size = UDim2.new(0, 20, 0, 20)
    toastIcon.Position = UDim2.new(0, 16, 0, toastConfig.Description and 14 or 14)
    toastIcon.Image = toastConfig.Icon or typeData.icon
    toastIcon.ImageColor3 = typeData.accent
    toastIcon.Parent = toastFrame
    
    local toastTitle = Instance.new("TextLabel")
    toastTitle.Name = "Title"
    toastTitle.BackgroundTransparency = 1
    toastTitle.Size = UDim2.new(1, -80, 0, 18)
    toastTitle.Position = UDim2.new(0, 44, 0, toastConfig.Description and 12 or 15)
    toastTitle.Font = theme.FontFamilyHeading
    toastTitle.Text = toastConfig.Title
    toastTitle.TextColor3 = theme.TextPrimary
    toastTitle.TextSize = theme.FontSizeMD
    toastTitle.TextXAlignment = Enum.TextXAlignment.Left
    toastTitle.TextTruncate = Enum.TextTruncate.AtEnd
    toastTitle.Parent = toastFrame
    
    if toastConfig.Description then
        local toastDesc = Instance.new("TextLabel")
        toastDesc.Name = "Description"
        toastDesc.BackgroundTransparency = 1
        toastDesc.Size = UDim2.new(1, -80, 0, 16)
        toastDesc.Position = UDim2.new(0, 44, 0, 34)
        toastDesc.Font = theme.FontFamily
        toastDesc.Text = toastConfig.Description
        toastDesc.TextColor3 = theme.TextSecondary
        toastDesc.TextSize = theme.FontSizeSM
        toastDesc.TextXAlignment = Enum.TextXAlignment.Left
        toastDesc.TextTruncate = Enum.TextTruncate.AtEnd
        toastDesc.Parent = toastFrame
    end
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "Close"
    closeBtn.BackgroundTransparency = 1
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -32, 0.5, 0)
    closeBtn.AnchorPoint = Vector2.new(0, 0.5)
    closeBtn.Text = ""
    closeBtn.Parent = toastFrame
    
    local closeIcon = Instance.new("ImageLabel")
    closeIcon.BackgroundTransparency = 1
    closeIcon.Size = UDim2.new(0, 14, 0, 14)
    closeIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    closeIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    closeIcon.Image = Icons.Close
    closeIcon.ImageColor3 = theme.TextTertiary
    closeIcon.Parent = closeBtn
    
    closeBtn.MouseEnter:Connect(function()
        Animation.Tween(closeIcon, {ImageColor3 = theme.TextPrimary}, 0.15)
    end)
    
    closeBtn.MouseLeave:Connect(function()
        Animation.Tween(closeIcon, {ImageColor3 = theme.TextTertiary}, 0.15)
    end)
    
    local function dismissToast()
        Animation.Tween(toastFrame, {Position = UDim2.new(1, 20, 0, 0)}, 0.3, Enum.EasingStyle.Quart)
        task.delay(0.3, function()
            toastFrame:Destroy()
        end)
    end
    
    closeBtn.MouseButton1Click:Connect(dismissToast)
    
    task.defer(function()
        Animation.Tween(toastFrame, {Position = UDim2.new(0, 0, 0, 0)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end)
    
    if toastConfig.Duration > 0 then
        task.delay(toastConfig.Duration, dismissToast)
    end
    
    return {Dismiss = dismissToast}
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- MODAL DIALOGS
-- ═══════════════════════════════════════════════════════════════════════════════

function ClaudeUI:Modal(modalConfig)
    modalConfig = Utility.Merge({
        Title = "Modal",
        Description = nil,
        Content = nil,
        Buttons = {
            {Text = "Cancel", Variant = "Secondary", Callback = function() end},
            {Text = "Confirm", Variant = "Primary", Callback = function() end},
        },
        CloseOnOverlayClick = true,
        Width = 400,
    }, modalConfig)
    
    local theme = self._activeTheme
    
    local overlay = Instance.new("TextButton")
    overlay.Name = "ModalOverlay"
    overlay.BackgroundColor3 = theme.Overlay
    overlay.BackgroundTransparency = 1
    overlay.BorderSizePixel = 0
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.Text = ""
    overlay.AutoButtonColor = false
    overlay.ZIndex = theme.ZIndexModal
    overlay.Parent = self._screenGui
    
    Animation.Tween(overlay, {BackgroundTransparency = theme.OverlayOpacity}, 0.3)
    
    local modalFrame = Instance.new("Frame")
    modalFrame.Name = "Modal"
    modalFrame.BackgroundColor3 = theme.BackgroundElevated
    modalFrame.BorderSizePixel = 0
    modalFrame.Size = UDim2.new(0, modalConfig.Width, 0, 0)
    modalFrame.AutomaticSize = Enum.AutomaticSize.Y
    modalFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    modalFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    modalFrame.ZIndex = theme.ZIndexModal + 1
    modalFrame.Parent = overlay
    
    local modalCorner = Instance.new("UICorner")
    modalCorner.CornerRadius = UDim.new(0, theme.RadiusXL)
    modalCorner.Parent = modalFrame
    
    local modalStroke = Instance.new("UIStroke")
    modalStroke.Color = theme.Border
    modalStroke.Thickness = 1
    modalStroke.Parent = modalFrame
    
    local modalPadding = Instance.new("UIPadding")
    modalPadding.PaddingTop = UDim.new(0, 20)
    modalPadding.PaddingBottom = UDim.new(0, 20)
    modalPadding.PaddingLeft = UDim.new(0, 20)
    modalPadding.PaddingRight = UDim.new(0, 20)
    modalPadding.Parent = modalFrame
    
    local modalLayout = Instance.new("UIListLayout")
    modalLayout.SortOrder = Enum.SortOrder.LayoutOrder
    modalLayout.Padding = UDim.new(0, 16)
    modalLayout.Parent = modalFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, 0, 0, 24)
    titleLabel.Font = theme.FontFamilyHeading
    titleLabel.Text = modalConfig.Title
    titleLabel.TextColor3 = theme.TextPrimary
    titleLabel.TextSize = theme.FontSizeXL
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.LayoutOrder = 1
    titleLabel.ZIndex = theme.ZIndexModal + 2
    titleLabel.Parent = modalFrame
    
    if modalConfig.Description then
        local descLabel = Instance.new("TextLabel")
        descLabel.Name = "Description"
        descLabel.BackgroundTransparency = 1
        descLabel.Size = UDim2.new(1, 0, 0, 0)
        descLabel.AutomaticSize = Enum.AutomaticSize.Y
        descLabel.Font = theme.FontFamily
        descLabel.Text = modalConfig.Description
        descLabel.TextColor3 = theme.TextSecondary
        descLabel.TextSize = theme.FontSizeMD
        descLabel.TextWrapped = true
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.LayoutOrder = 2
        descLabel.ZIndex = theme.ZIndexModal + 2
        descLabel.Parent = modalFrame
    end
    
    if modalConfig.Content then
        modalConfig.Content.LayoutOrder = 3
        modalConfig.Content.ZIndex = theme.ZIndexModal + 2
        modalConfig.Content.Parent = modalFrame
    end
    
    local buttonsFrame = Instance.new("Frame")
    buttonsFrame.Name = "Buttons"
    buttonsFrame.BackgroundTransparency = 1
    buttonsFrame.Size = UDim2.new(1, 0, 0, 36)
    buttonsFrame.LayoutOrder = 4
    buttonsFrame.ZIndex = theme.ZIndexModal + 2
    buttonsFrame.Parent = modalFrame
    
    local buttonsLayout = Instance.new("UIListLayout")
    buttonsLayout.FillDirection = Enum.FillDirection.Horizontal
    buttonsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    buttonsLayout.Padding = UDim.new(0, 10)
    buttonsLayout.Parent = buttonsFrame
    
    local function closeModal()
        Animation.Tween(overlay, {BackgroundTransparency = 1}, 0.2)
        Animation.Tween(modalFrame, {
            Size = UDim2.new(0, modalConfig.Width * 0.95, 0, modalFrame.Size.Y.Offset * 0.95),
            GroupTransparency = 1
        }, 0.2, Enum.EasingStyle.Quart)
        task.delay(0.25, function()
            overlay:Destroy()
        end)
    end
    
    for i, btnConfig in ipairs(modalConfig.Buttons) do
        local variants = {
            Primary = {bg = theme.Primary, hover = theme.PrimaryHover, text = theme.TextInverse},
            Secondary = {bg = theme.Surface, hover = theme.SurfaceHover, text = theme.TextPrimary},
            Danger = {bg = theme.Error, hover = Color3.fromRGB(220, 50, 50), text = theme.TextInverse},
        }
        local variant = variants[btnConfig.Variant] or variants.Secondary
        
        local btn = Instance.new("TextButton")
        btn.Name = btnConfig.Text
        btn.BackgroundColor3 = variant.bg
        btn.BorderSizePixel = 0
        btn.Size = UDim2.new(0, 0, 0, 36)
        btn.AutomaticSize = Enum.AutomaticSize.X
        btn.Font = theme.FontFamily
        btn.Text = btnConfig.Text
        btn.TextColor3 = variant.text
        btn.TextSize = theme.FontSizeMD
        btn.AutoButtonColor = false
        btn.LayoutOrder = #modalConfig.Buttons - i + 1
        btn.ZIndex = theme.ZIndexModal + 3
        btn.Parent = buttonsFrame
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, theme.RadiusMD)
        btnCorner.Parent = btn
        
        local btnPadding = Instance.new("UIPadding")
        btnPadding.PaddingLeft = UDim.new(0, 16)
        btnPadding.PaddingRight = UDim.new(0, 16)
        btnPadding.Parent = btn
        
        if btnConfig.Variant == "Secondary" then
            local btnStroke = Instance.new("UIStroke")
            btnStroke.Color = theme.Border
            btnStroke.Thickness = 1
            btnStroke.Parent = btn
        end
        
        btn.MouseEnter:Connect(function()
            Animation.Tween(btn, {BackgroundColor3 = variant.hover}, 0.15)
        end)
        
        btn.MouseLeave:Connect(function()
            Animation.Tween(btn, {BackgroundColor3 = variant.bg}, 0.15)
        end)
        
        btn.MouseButton1Click:Connect(function()
            closeModal()
            if btnConfig.Callback then btnConfig.Callback() end
        end)
    end
    
    if modalConfig.CloseOnOverlayClick then
        overlay.MouseButton1Click:Connect(function()
            local mousePos = UserInputService:GetMouseLocation()
            local absPos = modalFrame.AbsolutePosition
            local absSize = modalFrame.AbsoluteSize
            local inModal = mousePos.X >= absPos.X and mousePos.X <= absPos.X + absSize.X and
                           mousePos.Y >= absPos.Y and mousePos.Y <= absPos.Y + absSize.Y
            if not inModal then closeModal() end
        end)
    end
    
    modalFrame.GroupTransparency = 1
    modalFrame.Size = UDim2.new(0, modalConfig.Width * 0.9, 0, 0)
    
    task.defer(function()
        Animation.Tween(modalFrame, {
            Size = UDim2.new(0, modalConfig.Width, 0, 0),
            GroupTransparency = 0
        }, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end)
    
    return {Close = closeModal}
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- CONTEXT MENU
-- ═══════════════════════════════════════════════════════════════════════════════

function ClaudeUI:ContextMenu(position, items)
    local theme = self._activeTheme
    
    for _, child in ipairs(self._screenGui:GetChildren()) do
        if child.Name == "ContextMenu" then child:Destroy() end
    end
    
    local menuFrame = Instance.new("Frame")
    menuFrame.Name = "ContextMenu"
    menuFrame.BackgroundColor3 = theme.BackgroundElevated
    menuFrame.BorderSizePixel = 0
    menuFrame.Size = UDim2.new(0, 180, 0, 0)
    menuFrame.AutomaticSize = Enum.AutomaticSize.Y
    menuFrame.Position = UDim2.new(0, position.X, 0, position.Y)
    menuFrame.ClipsDescendants = true
    menuFrame.ZIndex = theme.ZIndexDropdown
    menuFrame.Parent = self._screenGui
    
    local menuCorner = Instance.new("UICorner")
    menuCorner.CornerRadius = UDim.new(0, theme.RadiusMD)
    menuCorner.Parent = menuFrame
    
    local menuStroke = Instance.new("UIStroke")
    menuStroke.Color = theme.Border
    menuStroke.Thickness = 1
    menuStroke.Parent = menuFrame
    
    local menuPadding = Instance.new("UIPadding")
    menuPadding.PaddingTop = UDim.new(0, 4)
    menuPadding.PaddingBottom = UDim.new(0, 4)
    menuPadding.PaddingLeft = UDim.new(0, 4)
    menuPadding.PaddingRight = UDim.new(0, 4)
    menuPadding.Parent = menuFrame
    
    local menuLayout = Instance.new("UIListLayout")
    menuLayout.SortOrder = Enum.SortOrder.LayoutOrder
    menuLayout.Padding = UDim.new(0, 2)
    menuLayout.Parent = menuFrame
    
    local function closeMenu()
        Animation.Tween(menuFrame, {Size = UDim2.new(0, 180, 0, 0)}, 0.15)
        task.delay(0.15, function() menuFrame:Destroy() end)
    end
    
    for i, item in ipairs(items) do
        if item.Type == "Divider" then
            local divider = Instance.new("Frame")
            divider.Name = "Divider"
            divider.BackgroundColor3 = theme.Border
            divider.BorderSizePixel = 0
            divider.Size = UDim2.new(1, 0, 0, 1)
            divider.LayoutOrder = i
            divider.ZIndex = theme.ZIndexDropdown + 1
            divider.Parent = menuFrame
        else
            local itemBtn = Instance.new("TextButton")
            itemBtn.Name = item.Text
            itemBtn.BackgroundTransparency = 1
            itemBtn.Size = UDim2.new(1, 0, 0, 32)
            itemBtn.Text = ""
            itemBtn.AutoButtonColor = false
            itemBtn.LayoutOrder = i
            itemBtn.ZIndex = theme.ZIndexDropdown + 1
            itemBtn.Parent = menuFrame
            
            local itemCorner = Instance.new("UICorner")
            itemCorner.CornerRadius = UDim.new(0, theme.RadiusSM)
            itemCorner.Parent = itemBtn
            
            if item.Icon then
                local itemIcon = Instance.new("ImageLabel")
                itemIcon.Name = "Icon"
                itemIcon.BackgroundTransparency = 1
                itemIcon.Size = UDim2.new(0, 16, 0, 16)
                itemIcon.Position = UDim2.new(0, 8, 0.5, 0)
                itemIcon.AnchorPoint = Vector2.new(0, 0.5)
                itemIcon.Image = item.Icon
                itemIcon.ImageColor3 = item.Disabled and theme.TextDisabled or (item.Danger and theme.Error or theme.TextSecondary)
                itemIcon.ZIndex = theme.ZIndexDropdown + 2
                itemIcon.Parent = itemBtn
            end
            
            local itemLabel = Instance.new("TextLabel")
            itemLabel.Name = "Label"
            itemLabel.BackgroundTransparency = 1
            itemLabel.Size = UDim2.new(1, -50, 1, 0)
            itemLabel.Position = UDim2.new(0, item.Icon and 32 or 10, 0, 0)
            itemLabel.Font = theme.FontFamily
            itemLabel.Text = item.Text
            itemLabel.TextColor3 = item.Disabled and theme.TextDisabled or (item.Danger and theme.Error or theme.TextPrimary)
            itemLabel.TextSize = theme.FontSizeMD
            itemLabel.TextXAlignment = Enum.TextXAlignment.Left
            itemLabel.ZIndex = theme.ZIndexDropdown + 2
            itemLabel.Parent = itemBtn
            
            if item.Shortcut then
                local shortcutLabel = Instance.new("TextLabel")
                shortcutLabel.Name = "Shortcut"
                shortcutLabel.BackgroundTransparency = 1
                shortcutLabel.Size = UDim2.new(0, 40, 1, 0)
                shortcutLabel.Position = UDim2.new(1, -48, 0, 0)
                shortcutLabel.Font = theme.FontFamilyMono
                shortcutLabel.Text = item.Shortcut
                shortcutLabel.TextColor3 = theme.TextTertiary
                shortcutLabel.TextSize = theme.FontSizeSM
                shortcutLabel.TextXAlignment = Enum.TextXAlignment.Right
                shortcutLabel.ZIndex = theme.ZIndexDropdown + 2
                shortcutLabel.Parent = itemBtn
            end
            
            if not item.Disabled then
                itemBtn.MouseEnter:Connect(function()
                    Animation.Tween(itemBtn, {BackgroundTransparency = 0, BackgroundColor3 = theme.SurfaceHover}, 0.1)
                end)
                itemBtn.MouseLeave:Connect(function()
                    Animation.Tween(itemBtn, {BackgroundTransparency = 1}, 0.1)
                end)
                itemBtn.MouseButton1Click:Connect(function()
                    closeMenu()
                    if item.Callback then item.Callback() end
                end)
            end
        end
    end
    
    local clickConnection
    clickConnection = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = UserInputService:GetMouseLocation()
            local absPos = menuFrame.AbsolutePosition
            local absSize = menuFrame.AbsoluteSize
            local inMenu = mousePos.X >= absPos.X and mousePos.X <= absPos.X + absSize.X and
                          mousePos.Y >= absPos.Y and mousePos.Y <= absPos.Y + absSize.Y
            if not inMenu then
                closeMenu()
                clickConnection:Disconnect()
            end
        end
    end)
    
    task.defer(function()
        Animation.Tween(menuFrame, {Size = UDim2.new(0, 180, 0, menuFrame.AbsoluteSize.Y)}, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end)
    
    return {Close = closeMenu}
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- TOOLTIP
-- ═══════════════════════════════════════════════════════════════════════════════

function ClaudeUI:Tooltip(target, text, position)
    position = position or "Top"
    local theme = self._activeTheme
    
    local tooltipFrame = Instance.new("Frame")
    tooltipFrame.Name = "Tooltip"
    tooltipFrame.BackgroundColor3 = theme.BackgroundElevated
    tooltipFrame.BorderSizePixel = 0
    tooltipFrame.Size = UDim2.new(0, 0, 0, 28)
    tooltipFrame.AutomaticSize = Enum.AutomaticSize.X
    tooltipFrame.Visible = false
    tooltipFrame.ZIndex = theme.ZIndexTooltip
    tooltipFrame.Parent = self._screenGui
    
    local tooltipCorner = Instance.new("UICorner")
    tooltipCorner.CornerRadius = UDim.new(0, theme.RadiusSM)
    tooltipCorner.Parent = tooltipFrame
    
    local tooltipStroke = Instance.new("UIStroke")
    tooltipStroke.Color = theme.Border
    tooltipStroke.Thickness = 1
    tooltipStroke.Parent = tooltipFrame
    
    local tooltipLabel = Instance.new("TextLabel")
    tooltipLabel.Name = "Label"
    tooltipLabel.BackgroundTransparency = 1
    tooltipLabel.Size = UDim2.new(0, 0, 1, 0)
    tooltipLabel.AutomaticSize = Enum.AutomaticSize.X
    tooltipLabel.Font = theme.FontFamily
    tooltipLabel.Text = text
    tooltipLabel.TextColor3 = theme.TextPrimary
    tooltipLabel.TextSize = theme.FontSizeSM
    tooltipLabel.ZIndex = theme.ZIndexTooltip + 1
    tooltipLabel.Parent = tooltipFrame
    
    local tooltipPadding = Instance.new("UIPadding")
    tooltipPadding.PaddingLeft = UDim.new(0, 10)
    tooltipPadding.PaddingRight = UDim.new(0, 10)
    tooltipPadding.Parent = tooltipLabel
    
    local showDelay = nil
    
    local function updatePosition()
        local targetPos = target.AbsolutePosition
        local targetSize = target.AbsoluteSize
        local tooltipSize = tooltipFrame.AbsoluteSize
        local x, y
        
        if position == "Top" then
            x = targetPos.X + targetSize.X / 2 - tooltipSize.X / 2
            y = targetPos.Y - tooltipSize.Y - 8
        elseif position == "Bottom" then
            x = targetPos.X + targetSize.X / 2 - tooltipSize.X / 2
            y = targetPos.Y + targetSize.Y + 8
        elseif position == "Left" then
            x = targetPos.X - tooltipSize.X - 8
            y = targetPos.Y + targetSize.Y / 2 - tooltipSize.Y / 2
        elseif position == "Right" then
            x = targetPos.X + targetSize.X + 8
            y = targetPos.Y + targetSize.Y / 2 - tooltipSize.Y / 2
        end
        
        tooltipFrame.Position = UDim2.new(0, x, 0, y)
    end
    
    target.MouseEnter:Connect(function()
        showDelay = task.delay(0.5, function()
            updatePosition()
            tooltipFrame.Visible = true
            tooltipFrame.GroupTransparency = 1
            Animation.Tween(tooltipFrame, {GroupTransparency = 0}, 0.15)
        end)
    end)
    
    target.MouseLeave:Connect(function()
        if showDelay then
            task.cancel(showDelay)
            showDelay = nil
        end
        Animation.Tween(tooltipFrame, {GroupTransparency = 1}, 0.1)
        task.delay(0.1, function()
            tooltipFrame.Visible = false
        end)
    end)
    
    return {
        SetText = function(newText) tooltipLabel.Text = newText end,
        Destroy = function() tooltipFrame:Destroy() end
    }
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- LOADING INDICATOR
-- ═══════════════════════════════════════════════════════════════════════════════

function ClaudeUI:CreateLoader(parent, size)
    size = size or 32
    local theme = self._activeTheme
    
    local loaderFrame = Instance.new("Frame")
    loaderFrame.Name = "Loader"
    loaderFrame.BackgroundTransparency = 1
    loaderFrame.Size = UDim2.new(0, size, 0, size)
    loaderFrame.Parent = parent or self._screenGui
    
    local spinner = Instance.new("ImageLabel")
    spinner.Name = "Spinner"
    spinner.BackgroundTransparency = 1
    spinner.Size = UDim2.new(1, 0, 1, 0)
    spinner.Image = "rbxassetid://6031302931"
    spinner.ImageColor3 = theme.Primary
    spinner.Parent = loaderFrame
    
    local spinConnection
    local rotation = 0
    
    spinConnection = RunService.RenderStepped:Connect(function(dt)
        rotation = (rotation + dt * 360) % 360
        spinner.Rotation = rotation
    end)
    
    return {
        Instance = loaderFrame,
        Stop = function() spinConnection:Disconnect() end,
        Destroy = function()
            spinConnection:Disconnect()
            loaderFrame:Destroy()
        end
    }
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- PROGRESS BAR
-- ═══════════════════════════════════════════════════════════════════════════════

function ClaudeUI:CreateProgressBar(parent, config)
    config = Utility.Merge({
        Value = 0,
        ShowLabel = true,
        Animated = true,
        Color = nil,
        Height = 8,
    }, config)
    
    local theme = self._activeTheme
    local currentValue = config.Value
    
    local progressFrame = Instance.new("Frame")
    progressFrame.Name = "ProgressBar"
    progressFrame.BackgroundTransparency = 1
    progressFrame.Size = UDim2.new(1, 0, 0, config.ShowLabel and (config.Height + 20) or config.Height)
    progressFrame.Parent = parent
    
    if config.ShowLabel then
        local progressLabel = Instance.new("TextLabel")
        progressLabel.Name = "Label"
        progressLabel.BackgroundTransparency = 1
        progressLabel.Size = UDim2.new(1, 0, 0, 16)
        progressLabel.Font = theme.FontFamilyMono
        progressLabel.Text = math.floor(currentValue * 100) .. "%"
        progressLabel.TextColor3 = theme.TextSecondary
        progressLabel.TextSize = theme.FontSizeSM
        progressLabel.TextXAlignment = Enum.TextXAlignment.Right
        progressLabel.Parent = progressFrame
    end
    
    local trackFrame = Instance.new("Frame")
    trackFrame.Name = "Track"
    trackFrame.BackgroundColor3 = theme.Surface
    trackFrame.BorderSizePixel = 0
    trackFrame.Size = UDim2.new(1, 0, 0, config.Height)
    trackFrame.Position = UDim2.new(0, 0, 1, -config.Height)
    trackFrame.Parent = progressFrame
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = trackFrame
    
    local fillFrame = Instance.new("Frame")
    fillFrame.Name = "Fill"
    fillFrame.BackgroundColor3 = config.Color or theme.Primary
    fillFrame.BorderSizePixel = 0
    fillFrame.Size = UDim2.new(currentValue, 0, 1, 0)
    fillFrame.Parent = trackFrame
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fillFrame
    
    if config.Animated then
        local shimmer = Instance.new("Frame")
        shimmer.Name = "Shimmer"
        shimmer.BackgroundColor3 = Color3.new(1, 1, 1)
        shimmer.BackgroundTransparency = 0.7
        shimmer.BorderSizePixel = 0
        shimmer.Size = UDim2.new(0.3, 0, 1, 0)
        shimmer.Position = UDim2.new(-0.3, 0, 0, 0)
        shimmer.Parent = fillFrame
        
        local shimmerGradient = Instance.new("UIGradient")
        shimmerGradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.5, 0.7),
            NumberSequenceKeypoint.new(1, 1),
        })
        shimmerGradient.Parent = shimmer
        
        task.spawn(function()
            while progressFrame.Parent do
                shimmer.Position = UDim2.new(-0.3, 0, 0, 0)
                Animation.Tween(shimmer, {Position = UDim2.new(1, 0, 0, 0)}, 1.5, Enum.EasingStyle.Linear)
                task.wait(2)
            end
        end)
    end
    
    local ProgressAPI = {Instance = progressFrame}
    
    function ProgressAPI:SetValue(value)
        currentValue = Utility.Clamp(value, 0, 1)
        Animation.Tween(fillFrame, {Size = UDim2.new(currentValue, 0, 1, 0)}, 0.3)
        if config.ShowLabel then
            local label = progressFrame:FindFirstChild("Label")
            if label then label.Text = math.floor(currentValue * 100) .. "%" end
        end
    end
    
    function ProgressAPI:GetValue()
        return currentValue
    end
    
    function ProgressAPI:SetColor(color)
        fillFrame.BackgroundColor3 = color
    end
    
    return ProgressAPI
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- BADGE COMPONENT
-- ═══════════════════════════════════════════════════════════════════════════════

function ClaudeUI:CreateBadge(text, variant, parent)
    variant = variant or "Default"
    local theme = self._activeTheme
    
    local variants = {
        Default = {bg = theme.Surface, text = theme.TextPrimary},
        Primary = {bg = theme.Primary, text = theme.TextInverse},
        Secondary = {bg = theme.Secondary, text = theme.TextInverse},
        Success = {bg = theme.Success, text = theme.TextInverse},
        Warning = {bg = theme.Warning, text = theme.TextInverse},
        Error = {bg = theme.Error, text = theme.TextInverse},
        Info = {bg = theme.Info, text = theme.TextInverse},
    }
    
    local style = variants[variant] or variants.Default
    
    local badge = Instance.new("Frame")
    badge.Name = "Badge"
    badge.BackgroundColor3 = style.bg
    badge.BorderSizePixel = 0
    badge.Size = UDim2.new(0, 0, 0, 20)
    badge.AutomaticSize = Enum.AutomaticSize.X
    badge.Parent = parent
    
    local badgeCorner = Instance.new("UICorner")
    badgeCorner.CornerRadius = UDim.new(1, 0)
    badgeCorner.Parent = badge
    
    local badgeLabel = Instance.new("TextLabel")
    badgeLabel.Name = "Label"
    badgeLabel.BackgroundTransparency = 1
    badgeLabel.Size = UDim2.new(0, 0, 1, 0)
    badgeLabel.AutomaticSize = Enum.AutomaticSize.X
    badgeLabel.Font = theme.FontFamily
    badgeLabel.Text = text
    badgeLabel.TextColor3 = style.text
    badgeLabel.TextSize = theme.FontSizeSM
    badgeLabel.Parent = badge
    
    local badgePadding = Instance.new("UIPadding")
    badgePadding.PaddingLeft = UDim.new(0, 8)
    badgePadding.PaddingRight = UDim.new(0, 8)
    badgePadding.Parent = badgeLabel
    
    return {
        Instance = badge,
        SetText = function(newText) badgeLabel.Text = newText end,
        SetVariant = function(newVariant)
            local newStyle = variants[newVariant] or variants.Default
            badge.BackgroundColor3 = newStyle.bg
            badgeLabel.TextColor3 = newStyle.text
        end
    }
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- AVATAR COMPONENT
-- ═══════════════════════════════════════════════════════════════════════════════

function ClaudeUI:CreateAvatar(config)
    config = Utility.Merge({
        UserId = nil,
        Image = nil,
        Size = 40,
        Rounded = true,
        Border = false,
        Status = nil,
        Parent = nil,
    }, config)
    
    local theme = self._activeTheme
    
    local avatarFrame = Instance.new("Frame")
    avatarFrame.Name = "Avatar"
    avatarFrame.BackgroundColor3 = theme.Surface
    avatarFrame.BorderSizePixel = 0
    avatarFrame.Size = UDim2.new(0, config.Size, 0, config.Size)
    avatarFrame.Parent = config.Parent
    
    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = config.Rounded and UDim.new(1, 0) or UDim.new(0, theme.RadiusMD)
    avatarCorner.Parent = avatarFrame
    
    if config.Border then
        local avatarStroke = Instance.new("UIStroke")
        avatarStroke.Color = theme.Border
        avatarStroke.Thickness = 2
        avatarStroke.Parent = avatarFrame
    end
    
    local avatarImage = Instance.new("ImageLabel")
    avatarImage.Name = "Image"
    avatarImage.BackgroundTransparency = 1
    avatarImage.Size = UDim2.new(1, 0, 1, 0)
    avatarImage.ScaleType = Enum.ScaleType.Crop
    avatarImage.Parent = avatarFrame
    
    local imageCorner = Instance.new("UICorner")
    imageCorner.CornerRadius = config.Rounded and UDim.new(1, 0) or UDim.new(0, theme.RadiusMD)
    imageCorner.Parent = avatarImage
    
    if config.UserId then
        local success, result = pcall(function()
            return Players:GetUserThumbnailAsync(config.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        end)
        if success then avatarImage.Image = result end
    elseif config.Image then
        avatarImage.Image = config.Image
    end
    
    if config.Status then
        local statusColors = {
            Online = theme.Success,
            Offline = theme.TextTertiary,
            Away = theme.Warning,
            Busy = theme.Error,
        }
        
        local statusDot = Instance.new("Frame")
        statusDot.Name = "Status"
        statusDot.BackgroundColor3 = statusColors[config.Status] or theme.TextTertiary
        statusDot.BorderSizePixel = 0
        statusDot.Size = UDim2.new(0, config.Size * 0.25, 0, config.Size * 0.25)
        statusDot.Position = UDim2.new(1, -2, 1, -2)
        statusDot.AnchorPoint = Vector2.new(1, 1)
        statusDot.Parent = avatarFrame
        
        local statusCorner = Instance.new("UICorner")
        statusCorner.CornerRadius = UDim.new(1, 0)
        statusCorner.Parent = statusDot
        
        local statusStroke = Instance.new("UIStroke")
        statusStroke.Color = theme.Background
        statusStroke.Thickness = 2
        statusStroke.Parent = statusDot
    end
    
    return {
        Instance = avatarFrame,
        SetImage = function(image) avatarImage.Image = image end,
        SetStatus = function(status)
            local statusDot = avatarFrame:FindFirstChild("Status")
            if statusDot then
                local statusColors = {
                    Online = theme.Success,
                    Offline = theme.TextTertiary,
                    Away = theme.Warning,
                    Busy = theme.Error,
                }
                statusDot.BackgroundColor3 = statusColors[status] or theme.TextTertiary
            end
        end
    }
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- CLEAN UP & DESTROY
-- ═══════════════════════════════════════════════════════════════════════════════

function ClaudeUI:Destroy()
    for _, window in ipairs(self._windows) do
        window:Close()
    end
    
    if self._screenGui then
        self._screenGui:Destroy()
    end
    
    self._windows = {}
    self._screenGui = nil
    self._toastContainer = nil
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- AUTO-INITIALIZE & RETURN
-- ═══════════════════════════════════════════════════════════════════════════════

ClaudeUI:Init()

return ClaudeUI

-- ═══════════════════════════════════════════════════════════════════════════════
-- END OF PART 6 - END OF LIBRARY
-- ═══════════════════════════════════════════════════════════════════════════════

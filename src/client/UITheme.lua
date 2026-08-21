local TweenService = game:GetService("TweenService")

local Theme = {}

Theme.Colors = {
    Ink = Color3.fromRGB(28, 31, 44),
    InkSoft = Color3.fromRGB(45, 50, 68),
    Surface = Color3.fromRGB(248, 250, 255),
    SurfaceBlue = Color3.fromRGB(226, 241, 255),
    Blue = Color3.fromRGB(66, 156, 255),
    BlueDark = Color3.fromRGB(36, 100, 205),
    Green = Color3.fromRGB(71, 212, 126),
    GreenDark = Color3.fromRGB(35, 145, 82),
    Gold = Color3.fromRGB(255, 190, 62),
    Orange = Color3.fromRGB(255, 129, 58),
    Purple = Color3.fromRGB(161, 96, 255),
    Red = Color3.fromRGB(244, 82, 92),
    Cyan = Color3.fromRGB(77, 220, 241),
    Muted = Color3.fromRGB(111, 121, 145),
    White = Color3.new(1, 1, 1),
}

function Theme.corner(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 14)
    corner.Parent = instance
    return corner
end

function Theme.stroke(instance, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Colors.Ink
    stroke.Thickness = thickness or 2
    stroke.Transparency = transparency or 0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = instance
    return stroke
end

function Theme.gradient(instance, topColor, bottomColor, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(topColor, bottomColor)
    gradient.Rotation = rotation or 90
    gradient.Parent = instance
    return gradient
end

function Theme.padding(instance, amount)
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, amount)
    padding.PaddingBottom = UDim.new(0, amount)
    padding.PaddingLeft = UDim.new(0, amount)
    padding.PaddingRight = UDim.new(0, amount)
    padding.Parent = instance
    return padding
end

function Theme.styleButton(button, baseColor, hoverColor, radius)
    button.AutoButtonColor = false
    button.BackgroundColor3 = baseColor
    Theme.corner(button, radius or 12)
    Theme.stroke(button, Theme.Colors.Ink, 2, 0.55)

    local scale = Instance.new("UIScale")
    scale.Name = "ButtonScale"
    scale.Parent = button

    local normal = baseColor
    local hover = hoverColor or baseColor:Lerp(Color3.new(1, 1, 1), 0.12)

    local function tweenScale(value, duration)
        TweenService:Create(scale, TweenInfo.new(duration or 0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = value}):Play()
    end

    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.12), {BackgroundColor3 = hover}):Play()
        tweenScale(1.035)
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.12), {BackgroundColor3 = normal}):Play()
        tweenScale(1)
    end)
    button.MouseButton1Down:Connect(function()
        tweenScale(0.96, 0.07)
    end)
    button.MouseButton1Up:Connect(function()
        tweenScale(1.02, 0.08)
    end)

    return button
end

function Theme.makeOpenButton(parent, text, icon, color, position)
    local button = Instance.new("TextButton")
    button.Name = "Open" .. text:gsub("%W", "")
    button.AnchorPoint = Vector2.new(1, 0.5)
    button.Position = position
    button.Size = UDim2.fromOffset(158, 50)
    button.Text = string.format("%s  %s", icon or "★", text)
    button.TextColor3 = Theme.Colors.White
    button.TextSize = 16
    button.Font = Enum.Font.GothamBlack
    button.Parent = parent
    Theme.styleButton(button, color, color:Lerp(Color3.new(1, 1, 1), 0.13), 14)
    return button
end

function Theme.makeOverlay(parent, panelSize)
    local overlay = Instance.new("Frame")
    overlay.Name = "Overlay"
    overlay.Size = UDim2.fromScale(1, 1)
    overlay.BackgroundColor3 = Color3.fromRGB(8, 10, 18)
    overlay.BackgroundTransparency = 0.48
    overlay.Visible = false
    overlay.Active = true
    overlay.ZIndex = 20
    overlay.Parent = parent

    local panel = Instance.new("Frame")
    panel.Name = "Panel"
    panel.AnchorPoint = Vector2.new(0.5, 0.5)
    panel.Position = UDim2.fromScale(0.5, 0.5)
    panel.Size = panelSize
    panel.BackgroundColor3 = Theme.Colors.Surface
    panel.ZIndex = 21
    panel.Parent = overlay
    Theme.corner(panel, 22)
    Theme.stroke(panel, Theme.Colors.Ink, 3, 0.15)

    local scale = Instance.new("UIScale")
    scale.Name = "OpenScale"
    scale.Scale = 1
    scale.Parent = panel

    return overlay, panel, scale
end

function Theme.openOverlay(overlay, scale)
    overlay.Visible = true
    scale.Scale = 0.86
    TweenService:Create(scale, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
end

function Theme.closeOverlay(overlay, scale)
    local tween = TweenService:Create(scale, TweenInfo.new(0.13, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 0.9})
    tween:Play()
    tween.Completed:Once(function()
        overlay.Visible = false
        scale.Scale = 1
    end)
end

function Theme.makeCloseButton(parent)
    local button = Instance.new("TextButton")
    button.AnchorPoint = Vector2.new(1, 0)
    button.Position = UDim2.new(1, -14, 0, 14)
    button.Size = UDim2.fromOffset(42, 42)
    button.Text = "×"
    button.TextColor3 = Theme.Colors.White
    button.TextSize = 27
    button.Font = Enum.Font.GothamBlack
    button.ZIndex = parent.ZIndex + 2
    button.Parent = parent
    Theme.styleButton(button, Theme.Colors.Red, Color3.fromRGB(255, 108, 116), 12)
    return button
end

function Theme.makeBadge(parent, text, color, size, position)
    local badge = Instance.new("TextLabel")
    badge.Size = size or UDim2.fromOffset(90, 26)
    badge.Position = position or UDim2.new()
    badge.BackgroundColor3 = color
    badge.Text = text
    badge.TextColor3 = Theme.Colors.White
    badge.TextSize = 12
    badge.Font = Enum.Font.GothamBlack
    badge.ZIndex = parent.ZIndex + 2
    badge.Parent = parent
    Theme.corner(badge, 999)
    return badge
end

function Theme.iconBubble(parent, glyph, color, size, position)
    local bubble = Instance.new("TextLabel")
    bubble.Size = UDim2.fromOffset(size or 54, size or 54)
    bubble.Position = position or UDim2.new()
    bubble.BackgroundColor3 = color
    bubble.Text = glyph
    bubble.TextColor3 = Theme.Colors.White
    bubble.TextScaled = true
    bubble.Font = Enum.Font.GothamBlack
    bubble.ZIndex = parent.ZIndex + 2
    bubble.Parent = parent
    Theme.corner(bubble, 16)
    Theme.stroke(bubble, Theme.Colors.Ink, 2, 0.6)
    local p = Theme.padding(bubble, 9)
    return bubble, p
end

return Theme

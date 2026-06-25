--该脚本属于开源脚本，严禁将此脚本进行倒卖牟利！
--This script is open source; reselling it for profit is strictly prohibited!
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local FlyEnabled = false
local FlySpeed = 65
local AntiFlingEnabled = false
local NoClipEnabled = false
local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
local flyConnection, currentLinVel, currentAlignOri, currentAttachment, antiFlingConnection, noclipConnection
function toggleFly()
    local character = LocalPlayer.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    if not hrp or not humanoid then return end
    if FlyEnabled then
        humanoid.PlatformStand = true
        if not currentAttachment then
            currentAttachment = Instance.new("Attachment")
            currentAttachment.Parent = hrp
        end
        if not currentLinVel then
            currentLinVel = Instance.new("LinearVelocity")
            currentLinVel.Attachment0 = currentAttachment
            currentLinVel.MaxForce = math.huge
            currentLinVel.RelativeTo = Enum.ActuatorRelativeTo.World
            currentLinVel.Parent = hrp
        end
        if not currentAlignOri then
            currentAlignOri = Instance.new("AlignOrientation")
            currentAlignOri.Attachment0 = currentAttachment
            currentAlignOri.Mode = Enum.OrientationAlignmentMode.OneAttachment
            currentAlignOri.MaxTorque = math.huge
            currentAlignOri.Responsiveness = 200
            currentAlignOri.Parent = hrp
        end
        flyConnection = RunService.RenderStepped:Connect(function()
            if not FlyEnabled or not character.Parent then return end
            local moveDirection = humanoid.MoveDirection
            currentAlignOri.CFrame = Camera.CFrame
            if moveDirection.Magnitude > 0 then
                local camCF = Camera.CFrame
                local localSpace = camCF:VectorToObjectSpace(moveDirection)
                local flyDir = (camCF.RightVector * localSpace.X) + (camCF.LookVector * -localSpace.Z)
                currentLinVel.VectorVelocity = flyDir.Unit * FlySpeed
            else
                currentLinVel.VectorVelocity = Vector3.zero
            end
        end)
    else
        humanoid.PlatformStand = false
        if flyConnection then flyConnection:Disconnect() flyConnection = nil end
        if currentLinVel then currentLinVel:Destroy() currentLinVel = nil end
        if currentAlignOri then currentAlignOri:Destroy() currentAlignOri = nil end
        if currentAttachment then currentAttachment:Destroy() currentAttachment = nil end
    end
end
function toggleAntiFling(state)
    AntiFlingEnabled = state
    if AntiFlingEnabled then
        antiFlingConnection = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local linV = hrp.AssemblyLinearVelocity
                    if linV.Magnitude > 250 then
                        hrp.AssemblyLinearVelocity = linV.Unit * 250
                    end
                    local angV = hrp.AssemblyAngularVelocity
                    if angV.Magnitude > 250 then
                        hrp.AssemblyAngularVelocity = angV.Unit * 250
                    end
                end
            end
        end)
    else
        if antiFlingConnection then antiFlingConnection:Disconnect() antiFlingConnection = nil end
    end
end
function toggleNoClip(state)
    NoClipEnabled = state
    if NoClipEnabled then
        noclipConnection = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                end
            end
        end
    end
end
local function applyiOSGlassEffect(gui, cornerVal, baseZIndex)
    baseZIndex = baseZIndex or 1
    gui.ZIndex = baseZIndex
    local corner = Instance.new("UICorner")
    corner.CornerRadius = cornerVal or UDim.new(1, 0)
    corner.Parent = gui
    local glassShine = Instance.new("Frame")
    glassShine.Name = "GlassShine"
    glassShine.Size = UDim2.new(1, 0, 1, 0)
    glassShine.Position = UDim2.new(0, 0, 0, 0)
    glassShine.BackgroundTransparency = 1
    glassShine.ZIndex = baseZIndex + 1
    glassShine.Parent = gui
    local shineCorner = Instance.new("UICorner")
    shineCorner.CornerRadius = cornerVal or UDim.new(1, 0)
    shineCorner.Parent = glassShine
    local shineGrad = Instance.new("UIGradient")
    shineGrad.Rotation = 45
    shineGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.4),
        NumberSequenceKeypoint.new(0.5, 1),
        NumberSequenceKeypoint.new(1, 0.4)
    })
    shineGrad.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
    shineGrad.Parent = glassShine
    local edgeStroke = Instance.new("UIStroke")
    edgeStroke.Name = "GlassEdge"
    edgeStroke.Thickness = 1.2
    edgeStroke.Color = Color3.fromRGB(255, 255, 255)
    edgeStroke.Transparency = 0.8
    edgeStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    edgeStroke.Parent = gui
    local edgeGrad = Instance.new("UIGradient")
    edgeGrad.Rotation = 45
    edgeGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(0.5, 0.9),
        NumberSequenceKeypoint.new(1, 0.1)
    })
    edgeGrad.Parent = edgeStroke
end
local function createMobileUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "FlySystemUI"
    gui.ResetOnSpawn = false
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    local welcomeGui = Instance.new("ScreenGui")
    welcomeGui.Name = "WelcomeUI"
    welcomeGui.IgnoreGuiInset = true
    welcomeGui.DisplayOrder = 999
    welcomeGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    local welcomeText = Instance.new("TextLabel")
    welcomeText.Size = UDim2.new(0, 400, 0, 100)
    welcomeText.Position = UDim2.new(0.5, 0, 0.5, 0)
    welcomeText.AnchorPoint = Vector2.new(0.5, 0.5)
    welcomeText.BackgroundTransparency = 1
    welcomeText.Text = "欢迎使用黄某飞行脚本 \n V 1.0"
    welcomeText.TextColor3 = Color3.fromRGB(255, 255, 255)
    welcomeText.TextTransparency = 1
    welcomeText.TextScaled = true
    welcomeText.Font = Enum.Font.GothamBold
    welcomeText.Parent = welcomeGui
    local wScale = Instance.new("UIScale")
    wScale.Scale = 0
    wScale.Parent = welcomeText
    local wGradient = Instance.new("UIGradient")
    wGradient.Rotation = 0
    wGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.166, Color3.fromRGB(255, 165, 0)),
        ColorSequenceKeypoint.new(0.333, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.666, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.833, Color3.fromRGB(128, 0, 128)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
    })
    wGradient.Parent = welcomeText
    local moveTween = TweenService:Create(wGradient, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1), {Offset = Vector2.new(-1, 0)})
    moveTween:Play()
    TweenService:Create(wScale, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
    local fadeTween = TweenService:Create(welcomeText, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0})
    fadeTween:Play()
    task.delay(3, function()
        TweenService:Create(wScale, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 0}):Play()
        local fadeOut = TweenService:Create(welcomeText, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1})
        fadeOut:Play()
        fadeOut.Completed:Connect(function()
            moveTween:Cancel()
            welcomeGui:Destroy()
        end)
    end)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, 220, 0, 40)
    container.Position = UDim2.new(0.5, 0, 0.8, 0)
    container.AnchorPoint = Vector2.new(0.5, 0.5)
    container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    container.BackgroundTransparency = 0.15
    container.Parent = gui
    applyiOSGlassEffect(container, UDim.new(1, 0), 1)
    local uiScale = Instance.new("UIScale")
    uiScale.Scale = 0
    uiScale.Parent = container
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 50, 0, 40)
    closeBtn.Position = UDim2.new(0, 0, 0, 0)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18
    closeBtn.BackgroundTransparency = 1
    closeBtn.ZIndex = 3
    closeBtn.Parent = container
    local div1 = Instance.new("Frame")
    div1.Size = UDim2.new(0, 1, 0, 24)
    div1.Position = UDim2.new(0, 50, 0.5, -12)
    div1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    div1.BackgroundTransparency = 0.7
    div1.BorderSizePixel = 0
    div1.ZIndex = 3
    div1.Parent = container
    local flyHighlight = Instance.new("Frame")
    flyHighlight.Size = UDim2.new(0, 120, 0, 30)
    flyHighlight.Position = UDim2.new(0, 51, 0, 5)
    flyHighlight.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    flyHighlight.BackgroundTransparency = 1
    flyHighlight.Parent = container
    applyiOSGlassEffect(flyHighlight, UDim.new(1, 0), 2)
    local capsuleBtn = Instance.new("TextButton")
    capsuleBtn.Size = UDim2.new(0, 120, 0, 40)
    capsuleBtn.Position = UDim2.new(0, 51, 0, 0)
    capsuleBtn.Text = "飞行"
    capsuleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    capsuleBtn.BackgroundTransparency = 1
    capsuleBtn.AutoButtonColor = false
    capsuleBtn.ZIndex = 5
    capsuleBtn.Parent = container
    local expandBtn = Instance.new("TextButton")
    expandBtn.Size = UDim2.new(0.33, 0, 1, 0)
    expandBtn.Position = UDim2.new(0.66, 0, 0, 0)
    expandBtn.Text = ""
    expandBtn.BackgroundTransparency = 1
    expandBtn.ZIndex = 5
    expandBtn.Parent = capsuleBtn
    local arrowIcon = Instance.new("ImageLabel")
    arrowIcon.Size = UDim2.new(0, 20, 0, 20)
    arrowIcon.Position = UDim2.new(0.5, -10, 0.5, -10)
    arrowIcon.BackgroundTransparency = 1
    arrowIcon.Image = "rbxassetid://6035047377"
    arrowIcon.ZIndex = 5
    arrowIcon.Parent = expandBtn
    local div2 = Instance.new("Frame")
    div2.Size = UDim2.new(0, 1, 0, 24)
    div2.Position = UDim2.new(0, 171, 0.5, -12)
    div2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    div2.BackgroundTransparency = 0.7
    div2.BorderSizePixel = 0
    div2.ZIndex = 3
    div2.Parent = container
    local dragBtn = Instance.new("TextButton")
    dragBtn.Size = UDim2.new(0, 48, 0, 40)
    dragBtn.Position = UDim2.new(0, 172, 0, 0)
    dragBtn.Text = ""
    dragBtn.BackgroundTransparency = 1
    dragBtn.AutoButtonColor = false
    dragBtn.ZIndex = 3
    dragBtn.Parent = container
    local dragIcon = Instance.new("ImageLabel")
    dragIcon.Size = UDim2.new(0, 20, 0, 20)
    dragIcon.Position = UDim2.new(0.5, -10, 0.5, -10)
    dragIcon.BackgroundTransparency = 1
    dragIcon.Image = "rbxassetid://6034768640"
    dragIcon.ZIndex = 3
    dragIcon.Parent = dragBtn
    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(0, 120, 0, 0)
    panel.Position = UDim2.new(0, 51, 0, 45)
    panel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    panel.BackgroundTransparency = 0.15
    panel.Visible = false
    panel.Parent = container
    applyiOSGlassEffect(panel, UDim.new(0, 12), 1)
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(0.3, 0, 0, 25)
    speedLabel.Position = UDim2.new(0.05, 0, 0, 10)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "速度:"
    speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedLabel.TextTransparency = 1
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.ZIndex = 3
    speedLabel.Parent = panel
    local speedBox = Instance.new("TextBox")
    speedBox.Size = UDim2.new(0.55, 0, 0, 25)
    speedBox.Position = UDim2.new(0.4, 0, 0, 10)
    speedBox.Text = tostring(FlySpeed)
    speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    speedBox.BackgroundTransparency = 1
    speedBox.TextTransparency = 1
    speedBox.ZIndex = 3
    speedBox.Parent = panel
    applyiOSGlassEffect(speedBox, UDim.new(1, 0), 3)
    speedBox.FocusLost:Connect(function()
        local num = tonumber(speedBox.Text)
        if num then
            FlySpeed = math.clamp(math.floor(num), 10, 1000)
        end
        speedBox.Text = tostring(FlySpeed)
    end)
    local antiFlingBtn = Instance.new("TextButton")
    antiFlingBtn.Size = UDim2.new(0.9, 0, 0, 25)
    antiFlingBtn.Position = UDim2.new(0.05, 0, 0, 45)
    antiFlingBtn.Text = "反甩飞: 关"
    antiFlingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    antiFlingBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    antiFlingBtn.BackgroundTransparency = 1
    antiFlingBtn.TextTransparency = 1
    antiFlingBtn.ZIndex = 3
    antiFlingBtn.Parent = panel
    applyiOSGlassEffect(antiFlingBtn, UDim.new(1, 0), 3)
    local noclipBtn = Instance.new("TextButton")
    noclipBtn.Size = UDim2.new(0.9, 0, 0, 25)
    noclipBtn.Position = UDim2.new(0.05, 0, 0, 80)
    noclipBtn.Text = "穿墙: 关"
    noclipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    noclipBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    noclipBtn.BackgroundTransparency = 1
    noclipBtn.TextTransparency = 1
    noclipBtn.ZIndex = 3
    noclipBtn.Parent = panel
    applyiOSGlassEffect(noclipBtn, UDim.new(1, 0), 3)
    local uiElements = {speedLabel, speedBox, antiFlingBtn, noclipBtn}
    local isExpanded = false
    local function toggleExpand(state)
        if isExpanded == state then return end
        isExpanded = state
        if state then
            panel.Visible = true
            local tw = TweenService:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 120, 0, 115), Position = UDim2.new(0, 51, 0, 45)})
            tw:Play()
            tw.Completed:Connect(function()
                if isExpanded then
                    for _, el in ipairs(uiElements) do
                        TweenService:Create(el, TweenInfo.new(0.2), {BackgroundTransparency = 0.15, TextTransparency = 0}):Play()
                    end
                end
            end)
            TweenService:Create(arrowIcon, TweenInfo.new(0.3), {Rotation = 90}):Play()
        else
            for _, el in ipairs(uiElements) do
                TweenService:Create(el, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
            end
            task.wait(0.2)
            local tw = TweenService:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 120, 0, 0), Position = UDim2.new(0, 51, 0, 45)})
            tw:Play()
            tw.Completed:Connect(function() if not isExpanded then panel.Visible = false end end)
            TweenService:Create(arrowIcon, TweenInfo.new(0.3), {Rotation = 0}):Play()
        end
    end
    expandBtn.MouseButton1Click:Connect(function()
        toggleExpand(not isExpanded)
    end)
    antiFlingBtn.MouseButton1Click:Connect(function()
        toggleAntiFling(not AntiFlingEnabled)
        if AntiFlingEnabled then
            antiFlingBtn.Text = "反甩飞: 开"
            antiFlingBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
        else
            antiFlingBtn.Text = "反甩飞: 关"
            antiFlingBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        end
    end)
    noclipBtn.MouseButton1Click:Connect(function()
        toggleNoClip(not NoClipEnabled)
        if NoClipEnabled then
            noclipBtn.Text = "穿墙: 开"
            noclipBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
        else
            noclipBtn.Text = "穿墙: 关"
            noclipBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        end
    end)
    closeBtn.MouseButton1Click:Connect(function()
        if flyConnection then flyConnection:Disconnect() flyConnection = nil end
        if antiFlingConnection then antiFlingConnection:Disconnect() antiFlingConnection = nil end
        if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then hum.PlatformStand = false end
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                end
            end
        end
        local tw = TweenService:Create(uiScale, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 0})
        tw:Play()
        tw.Completed:Connect(function()
            gui:Destroy()
        end)
    end)
    local dragStart = nil
    local startPos = nil
    local isDraggingUI = false
    local uiTargetPos = container.Position
    dragBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingUI = true
            dragStart = input.Position
            startPos = container.Position
            uiTargetPos = startPos
            TweenService:Create(uiScale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 1.1}):Play()
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if isDraggingUI and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            uiTargetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if isDraggingUI then
                isDraggingUI = false
                TweenService:Create(uiScale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 1.0}):Play()
            end
        end
    end)
    RunService.RenderStepped:Connect(function()
        local cx, cy = container.Position.X.Offset, container.Position.Y.Offset
        local tx, ty = uiTargetPos.X.Offset, uiTargetPos.Y.Offset
        if math.abs(tx - cx) > 0.1 or math.abs(ty - cy) > 0.1 then
            container.Position = UDim2.new(uiTargetPos.X.Scale, cx + (tx - cx) * 0.2, uiTargetPos.Y.Scale, cy + (ty - cy) * 0.2)
        end
    end)
    capsuleBtn.MouseButton1Click:Connect(function()
        FlyEnabled = not FlyEnabled
        if FlyEnabled then
            capsuleBtn.Text = "飞行中"
            TweenService:Create(flyHighlight, TweenInfo.new(0.3), {BackgroundTransparency = 0.15}):Play()
        else
            capsuleBtn.Text = "飞行"
            TweenService:Create(flyHighlight, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        end
        toggleFly()
    end)
    TweenService:Create(uiScale, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
end
local function setupInputs()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.F then
            FlyEnabled = not FlyEnabled
            toggleFly()
        end
    end)
end
LocalPlayer.CharacterAdded:Connect(function()
    FlyEnabled = false
    if flyConnection then flyConnection:Disconnect() flyConnection = nil end
    if currentLinVel then currentLinVel:Destroy() end
    if currentAlignOri then currentAlignOri:Destroy() end
    if currentAttachment then currentAttachment:Destroy() end
end)
if isMobile then
    createMobileUI()
else
    setupInputs()
end

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- KÍCH THƯỚC GIỚI HẠN CỦA UI (Tối ưu cho cả Mobile và PC)
local MIN_WIDTH, MAX_WIDTH = 550, 850
local MIN_HEIGHT, MAX_HEIGHT = 380, 520
local MINI_WIDTH = 280 -- Chiều rộng cực gọn khi thu nhỏ menu

-- SCREENGUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- MAIN FRAME
local Main = Instance.new("Frame")
Main.Parent = ScreenGui
Main.AnchorPoint = Vector2.new(0, 0) -- Chuyển về góc (0,0) để xử lý kéo thả di chuyển chính xác 100%
Main.BackgroundColor3 = Color3.fromRGB(13, 13, 20)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)

-- Hàm tính toán kích thước động theo màn hình thiết bị
local function GetTargetSize()
	local Viewport = workspace.CurrentCamera.ViewportSize
	if Viewport.X == 0 or Viewport.Y == 0 then
		return UDim2.fromOffset(MIN_WIDTH, MIN_HEIGHT)
	end
	local Width = math.clamp(Viewport.X * 0.7, MIN_WIDTH, MAX_WIDTH)
	local Height = math.clamp(Viewport.Y * 0.75, MIN_HEIGHT, MAX_HEIGHT)
	
	if Width > Viewport.X then Width = Viewport.X * 0.9 end
	if Height > Viewport.Y then Height = Viewport.Y * 0.9 end
	return UDim2.fromOffset(Width, Height)
end

-- Vị trí xuất hiện ban đầu (Chính giữa màn hình)
local function CenterUI(targetSize)
	local Viewport = workspace.CurrentCamera.ViewportSize
	local X = (Viewport.X - targetSize.X.Offset) / 2
	local Y = (Viewport.Y - targetSize.Y.Offset) / 2
	Main.Position = UDim2.fromOffset(X, Y)
end

-- TOPBAR
local TopBar = Instance.new("Frame")
TopBar.Parent = Main
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
TopBar.BorderSizePixel = 0
TopBar.ZIndex = 10

-- TopBar accent line
local AccentLine = Instance.new("Frame")
AccentLine.Parent = TopBar
AccentLine.Position = UDim2.new(0, 0, 1, -2)
AccentLine.Size = UDim2.new(1, 0, 0, 2)
AccentLine.BackgroundColor3 = Color3.fromRGB(95, 95, 255)
AccentLine.BorderSizePixel = 0

-- Dot indicator
local Dot = Instance.new("Frame")
Dot.Parent = TopBar
Dot.Size = UDim2.new(0, 10, 0, 10)
Dot.Position = UDim2.new(0, 14, 0.5, -5)
Dot.BackgroundColor3 = Color3.fromRGB(95, 95, 255)
Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

-- Title (Đã cập nhật tên mới)
local Title = Instance.new("TextLabel")
Title.Parent = TopBar
Title.Position = UDim2.new(0, 32, 0, 0)
Title.Size = UDim2.new(1, -95, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "VanDayModZ V3"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Minimize Button
local MinBtn = Instance.new("TextButton")
MinBtn.Parent = TopBar
MinBtn.AnchorPoint = Vector2.new(1, 0.5)
MinBtn.Position = UDim2.new(1, -52, 0.5, 0)
MinBtn.Size = UDim2.new(0, 32, 0, 32)
MinBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
MinBtn.Text = "—"
MinBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 14
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 8)

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TopBar
CloseBtn.AnchorPoint = Vector2.new(1, 0.5)
CloseBtn.Position = UDim2.new(1, -14, 0.5, 0)
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

CloseBtn.MouseButton1Click:Connect(function()
	local CurrentSize = Main.Size
	TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Size = UDim2.fromOffset(CurrentSize.X.Offset, 0)}):Play()
	task.wait(0.28)
	ScreenGui:Destroy()
end)

-- BODY CONTAINER
local Body = Instance.new("Frame")
Body.Parent = Main
Body.Position = UDim2.new(0, 0, 0, 42)
Body.Size = UDim2.new(1, 0, 1, -42)
Body.BackgroundTransparency = 1
Body.ZIndex = 2

local minimized = false
local LastFullSize = GetTargetSize()

MinBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		-- Thu nhỏ: Lưu lại size cũ, co kích thước chiều ngang lẫn chiều cao thật gọn
		LastFullSize = Main.Size
		Body.Visible = false
		TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Size = UDim2.fromOffset(MINI_WIDTH, 42)
		}):Play()
	else
		-- Phóng to: Trả lại kích thước menu ban đầu và hiển thị lại nội dung tính năng
		local ExpandTween = TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Size = LastFullSize
		})
		ExpandTween:Play()
		ExpandTween.Completed:Connect(function()
			if not minimized then Body.Visible = true end
		end)
	end
end)

-- ========================
-- SIDEBAR
-- ========================
local Sidebar = Instance.new("Frame")
Sidebar.Parent = Body
Sidebar.Size = UDim2.new(0.24, 0, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
Sidebar.BorderSizePixel = 0

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.Parent = Sidebar
SidebarLayout.Padding = UDim.new(0, 5)
SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local SidebarPad = Instance.new("UIPadding")
SidebarPad.Parent = Sidebar
SidebarPad.PaddingTop = UDim.new(0, 12)

local SidebarLine = Instance.new("Frame")
SidebarLine.Parent = Body
SidebarLine.Position = UDim2.new(0.24, 0, 0, 0)
SidebarLine.Size = UDim2.new(0, 1, 1, 0)
SidebarLine.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
SidebarLine.BorderSizePixel = 0

-- CONTENT AREA
local Content = Instance.new("Frame")
Content.Parent = Body
Content.Position = UDim2.new(0.24, 1, 0, 0)
Content.Size = UDim2.new(0.76, -1, 1, 0)
Content.BackgroundTransparency = 1
Content.ClipsDescendants = true

-- ========================
-- PAGE SYSTEM
-- ========================
local Pages = {}
local SideButtons = {}

local function createPage(name)
	local Page = Instance.new("ScrollingFrame")
	Page.Parent = Content
	Page.Size = UDim2.new(1, 0, 1, 0)
	Page.BackgroundTransparency = 1
	Page.ScrollBarThickness = 4
	Page.ScrollBarImageColor3 = Color3.fromRGB(95, 95, 255)
	Page.CanvasSize = UDim2.new(0, 0, 0, 0)
	Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	Page.Visible = false

	local Layout = Instance.new("UIListLayout")
	Layout.Parent = Page
	Layout.Padding = UDim.new(0, 10)
	Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	local Pad = Instance.new("UIPadding")
	Pad.Parent = Page
	Pad.PaddingTop = UDim.new(0, 12)
	Pad.PaddingBottom = UDim.new(0, 12)
	Pad.PaddingLeft = UDim.new(0, 12)
	Pad.PaddingRight = UDim.new(0, 12)

	Pages[name] = Page
	return Page
end

local function openPage(name)
	for n, page in pairs(Pages) do page.Visible = false end
	for n, btn in pairs(SideButtons) do
		TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(0,0,0)}):Play()
		btn.BackgroundTransparency = 1
		for _, c in ipairs(btn:GetChildren()) do
			if c:IsA("TextLabel") then c.TextColor3 = Color3.fromRGB(140,140,160) end
			if c:IsA("ImageLabel") then c.ImageColor3 = Color3.fromRGB(140,140,160) end
		end
	end
	if Pages[name] then
		Pages[name].Visible = true
		local btn = SideButtons[name]
		if btn then
			btn.BackgroundTransparency = 0
			TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(25,25,45)}):Play()
			for _, c in ipairs(btn:GetChildren()) do
				if c:IsA("TextLabel") then c.TextColor3 = Color3.fromRGB(255,255,255) end
				if c:IsA("ImageLabel") then c.ImageColor3 = Color3.fromRGB(95,95,255) end
			end
		end
	end
end

local function addSidebarButton(name, icon)
	local Btn = Instance.new("TextButton")
	Btn.Parent = Sidebar
	Btn.Size = UDim2.new(1, -12, 0, 40)
	Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
	Btn.BackgroundTransparency = 1
	Btn.Text = ""
	Btn.AutoButtonColor = false
	Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)

	local IconLabel = Instance.new("ImageLabel")
	IconLabel.Parent = Btn
	IconLabel.Size = UDim2.new(0, 16, 0, 16)
	IconLabel.Position = UDim2.new(0, 12, 0.5, -8)
	IconLabel.BackgroundTransparency = 1
	IconLabel.Image = icon
	IconLabel.ImageColor3 = Color3.fromRGB(140, 140, 160)

	local Label = Instance.new("TextLabel")
	Label.Parent = Btn
	Label.Position = UDim2.new(0, 36, 0, 0)
	Label.Size = UDim2.new(1, -42, 1, 0)
	Label.BackgroundTransparency = 1
	Label.Text = name
	Label.TextColor3 = Color3.fromRGB(140, 140, 160)
	Label.Font = Enum.Font.GothamSemibold
	Label.TextSize = 13
	Label.TextXAlignment = Enum.TextXAlignment.Left

	SideButtons[name] = Btn
	Btn.MouseButton1Click:Connect(function() openPage(name) end)
	return Btn
end

-- ========================
-- HELPERS (SECTION, ROW, BUTTON, TOGGLE, SLIDER)
-- ========================
local function addSection(page, title)
	local Sec = Instance.new("Frame")
	Sec.Parent = page
	Sec.Size = UDim2.new(1, 0, 0, 26)
	Sec.BackgroundTransparency = 1

	local Dot2 = Instance.new("Frame")
	Dot2.Parent = Sec
	Dot2.Size = UDim2.new(0, 6, 0, 6)
	Dot2.Position = UDim2.new(0, 4, 0.5, -3)
	Dot2.BackgroundColor3 = Color3.fromRGB(95, 95, 255)
	Instance.new("UICorner", Dot2).CornerRadius = UDim.new(1, 0)

	local SLabel = Instance.new("TextLabel")
	SLabel.Parent = Sec
	SLabel.Position = UDim2.new(0, 18, 0, 0)
	SLabel.Size = UDim2.new(1, -18, 1, 0)
	SLabel.BackgroundTransparency = 1
	SLabel.Text = title
	SLabel.TextColor3 = Color3.fromRGB(180, 180, 220)
	SLabel.Font = Enum.Font.GothamSemibold
	SLabel.TextSize = 12
	SLabel.TextXAlignment = Enum.TextXAlignment.Left
end

local function makeRow(page, labelText, descText)
	local Row = Instance.new("Frame")
	Row.Parent = page
	Row.Size = UDim2.new(1, 0, 0, 60)
	Row.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
	Row.BorderSizePixel = 0
	Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 10)

	local LabelMain = Instance.new("TextLabel")
	LabelMain.Parent = Row
	LabelMain.Position = UDim2.new(0, 16, 0, 10)
	LabelMain.Size = UDim2.new(0.55, 0, 0, 20)
	LabelMain.BackgroundTransparency = 1
	LabelMain.Text = labelText
	LabelMain.TextColor3 = Color3.fromRGB(235, 235, 255)
	LabelMain.Font = Enum.Font.GothamSemibold
	LabelMain.TextSize = 13
	LabelMain.TextXAlignment = Enum.TextXAlignment.Left

	local Desc = Instance.new("TextLabel")
	Desc.Parent = Row
	Desc.Position = UDim2.new(0, 16, 0, 30)
	Desc.Size = UDim2.new(0.55, 0, 0, 18)
	Desc.BackgroundTransparency = 1
	Desc.Text = descText
	Desc.TextColor3 = Color3.fromRGB(100, 100, 130)
	Desc.Font = Enum.Font.Gotham
	Desc.TextSize = 11
	Desc.TextXAlignment = Enum.TextXAlignment.Left

	return Row
end

local function addButton(page, label, desc, btnText, callback)
	local Row = makeRow(page, label, desc)
	local Btn = Instance.new("TextButton")
	Btn.Parent = Row
	Btn.AnchorPoint = Vector2.new(1, 0.5)
	Btn.Position = UDim2.new(1, -14, 0.5, 0)
	Btn.Size = UDim2.new(0, 110, 0, 34)
	Btn.Text = btnText
	Btn.TextColor3 = Color3.new(1, 1, 1)
	Btn.Font = Enum.Font.GothamBold
	Btn.TextSize = 12
	Btn.BackgroundColor3 = Color3.fromRGB(95, 95, 255)
	Btn.AutoButtonColor = false
	Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)

	Btn.MouseEnter:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(120, 120, 255)}):Play() end)
	Btn.MouseLeave:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(95, 95, 255)}):Play() end)
	Btn.MouseButton1Click:Connect(function()
		TweenService:Create(Btn, TweenInfo.new(0.05), {BackgroundColor3 = Color3.fromRGB(70, 70, 200)}):Play()
		task.wait(0.05)
		TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(95, 95, 255)}):Play()
		if callback then callback() end
	end)
	return Row
end

local function addToggle(page, label, desc, default, callback)
	local Row = makeRow(page, label, desc)
	local state = default or false

	local ToggleBG = Instance.new("TextButton")
	ToggleBG.Parent = Row
	ToggleBG.AnchorPoint = Vector2.new(1, 0.5)
	ToggleBG.Position = UDim2.new(1, -14, 0.5, 0)
	ToggleBG.Size = UDim2.new(0, 50, 0, 26)
	ToggleBG.Text = ""
	ToggleBG.BackgroundColor3 = state and Color3.fromRGB(95, 95, 255) or Color3.fromRGB(45, 45, 65)
	ToggleBG.AutoButtonColor = false
	Instance.new("UICorner", ToggleBG).CornerRadius = UDim.new(1, 0)

	local Circle = Instance.new("Frame")
	Circle.Parent = ToggleBG
	Circle.Size = UDim2.new(0, 20, 0, 20)
	Circle.Position = state and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
	Circle.BackgroundColor3 = Color3.new(1, 1, 1)
	Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

	ToggleBG.MouseButton1Click:Connect(function()
		state = not state
		TweenService:Create(ToggleBG, TweenInfo.new(0.15), {BackgroundColor3 = state and Color3.fromRGB(95, 95, 255) or Color3.fromRGB(45, 45, 65)}):Play()
		TweenService:Create(Circle, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {Position = state and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)}):Play()
		if callback then callback(state) end
	end)
	return Row
end

local function addSlider(page, label, desc, min, max, default, callback)
	local Row = Instance.new("Frame")
	Row.Parent = page
	Row.Size = UDim2.new(1, 0, 0, 76)
	Row.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
	Row.BorderSizePixel = 0
	Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 10)

	local LabelMain = Instance.new("TextLabel")
	LabelMain.Parent = Row
	LabelMain.Position = UDim2.new(0, 16, 0, 8)
	LabelMain.Size = UDim2.new(0.7, 0, 0, 20)
	LabelMain.BackgroundTransparency = 1
	LabelMain.Text = label
	LabelMain.TextColor3 = Color3.fromRGB(235, 235, 255)
	LabelMain.Font = Enum.Font.GothamSemibold
	LabelMain.TextSize = 13
	LabelMain.TextXAlignment = Enum.TextXAlignment.Left

	local ValueLabel = Instance.new("TextLabel")
	ValueLabel.Parent = Row
	ValueLabel.AnchorPoint = Vector2.new(1, 0)
	ValueLabel.Position = UDim2.new(1, -16, 0, 8)
	ValueLabel.Size = UDim2.new(0, 40, 0, 20)
	ValueLabel.BackgroundTransparency = 1
	ValueLabel.Text = tostring(default or min)
	ValueLabel.TextColor3 = Color3.fromRGB(95, 95, 255)
	ValueLabel.Font = Enum.Font.GothamBold
	ValueLabel.TextSize = 12
	ValueLabel.TextXAlignment = Enum.TextXAlignment.Right

	local Desc = Instance.new("TextLabel")
	Desc.Parent = Row
	Desc.Position = UDim2.new(0, 16, 0, 26)
	Desc.Size = UDim2.new(1, -32, 0, 16)
	Desc.BackgroundTransparency = 1
	Desc.Text = desc
	Desc.TextColor3 = Color3.fromRGB(100, 100, 130)
	Desc.Font = Enum.Font.Gotham
	Desc.TextSize = 11
	Desc.TextXAlignment = Enum.TextXAlignment.Left

	local Bar = Instance.new("Frame")
	Bar.Parent = Row
	Bar.Position = UDim2.new(0, 16, 0, 52)
	Bar.Size = UDim2.new(1, -32, 0, 6)
	Bar.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
	Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)

	local pct = ((default or min) - min) / math.max(max - min, 1)

	local Fill = Instance.new("Frame")
	Fill.Parent = Bar
	Fill.Size = UDim2.new(pct, 0, 1, 0)
	Fill.BackgroundColor3 = Color3.fromRGB(95, 95, 255)
	Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

	local Handle = Instance.new("Frame")
	Handle.Parent = Bar
	Handle.Size = UDim2.new(0, 12, 0, 12)
	Handle.Position = UDim2.new(pct, -6, 0.5, -6)
	Handle.BackgroundColor3 = Color3.new(1, 1, 1)
	Instance.new("UICorner", Handle).CornerRadius = UDim.new(1, 0)

	local dragging = false
	Bar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
	UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local p = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
			Fill.Size = UDim2.new(p, 0, 1, 0)
			Handle.Position = UDim2.new(p, -6, 0.5, -6)
			local val = math.floor(min + (max - min) * p)
			ValueLabel.Text = tostring(val)
			if callback then callback(val) end
		end
	end)
	return Row
end

-- ========================
-- BUILD PAGES & INTERFACE DATA
-- ========================
local MainPage = createPage("Main")
addSidebarButton("Main", "rbxassetid://7733960981")

local ProfileCard = Instance.new("Frame")
ProfileCard.Parent = MainPage
ProfileCard.Size = UDim2.new(1,0,0,100)
ProfileCard.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
ProfileCard.BorderSizePixel = 0
Instance.new("UICorner", ProfileCard).CornerRadius = UDim.new(0, 10)

local PAccent = Instance.new("Frame")
PAccent.Parent = ProfileCard
PAccent.Size = UDim2.new(0, 3, 0.6, 0)
PAccent.Position = UDim2.new(0, 0, 0.2, 0)
PAccent.BackgroundColor3 = Color3.fromRGB(95, 95, 255)
Instance.new("UICorner", PAccent).CornerRadius = UDim.new(1, 0)

local AvatarBG = Instance.new("Frame")
AvatarBG.Parent = ProfileCard
AvatarBG.Size = UDim2.new(0, 56, 0, 56)
AvatarBG.Position = UDim2.new(0, 16, 0.5, -28)
AvatarBG.BackgroundColor3 = Color3.fromRGB(95, 95, 255)
Instance.new("UICorner", AvatarBG).CornerRadius = UDim.new(1, 0)

local Avatar = Instance.new("ImageLabel")
Avatar.Parent = AvatarBG
Avatar.Size = UDim2.new(1, -4, 1, -4)
Avatar.Position = UDim2.new(0, 2, 0, 2)
Avatar.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
Avatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. LocalPlayer.UserId .. "&width=150&height=150&format=png"
Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1, 0)

local NameLabel = Instance.new("TextLabel")
NameLabel.Parent = ProfileCard
NameLabel.Position = UDim2.new(0, 86, 0, 14)
NameLabel.Size = UDim2.new(1, -96, 0, 22)
NameLabel.BackgroundTransparency = 1
NameLabel.Text = "@" .. LocalPlayer.Name
NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
NameLabel.Font = Enum.Font.GothamBold
NameLabel.TextSize = 14
NameLabel.TextXAlignment = Enum.TextXAlignment.Left

local DisplayLabel = Instance.new("TextLabel")
DisplayLabel.Parent = ProfileCard
DisplayLabel.Position = UDim2.new(0, 86, 0, 36)
DisplayLabel.Size = UDim2.new(1, -96, 0, 18)
DisplayLabel.BackgroundTransparency = 1
DisplayLabel.Text = "Display: " .. LocalPlayer.DisplayName
DisplayLabel.TextColor3 = Color3.fromRGB(160, 160, 200)
DisplayLabel.Font = Enum.Font.Gotham
DisplayLabel.TextSize = 12
DisplayLabel.TextXAlignment = Enum.TextXAlignment.Left

local IDLabel = Instance.new("TextLabel")
IDLabel.Parent = ProfileCard
IDLabel.Position = UDim2.new(0, 86, 0, 54)
IDLabel.Size = UDim2.new(1, -96, 0, 18)
IDLabel.BackgroundTransparency = 1
IDLabel.Text = "ID: " .. LocalPlayer.UserId
IDLabel.TextColor3 = Color3.fromRGB(110, 110, 140)
IDLabel.Font = Enum.Font.Gotham
IDLabel.TextSize = 11
IDLabel.TextXAlignment = Enum.TextXAlignment.Left

addSection(MainPage, "Main Hacks")
addButton(MainPage, "Test Button", "Execute sample function", "Click", function() print("Executed successfully!") end)
addToggle(MainPage, "Test Toggle", "Enable/Disable feature", false, function(val) print("Status:", val) end)
addSlider(MainPage, "Test Slider", "Control parameters", 0, 100, 30, function(val) print("Value:", val) end)

local MiscPage = createPage("Misc")
addSidebarButton("Misc", "rbxassetid://7743878857")
addSection(MiscPage, "Miscellaneous")
addButton(MiscPage, "Rejoin Server", "Reconnect to this server", "Rejoin", function()
	game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end)
addSlider(MiscPage, "WalkSpeed", "Modify local speed", 16, 150, 16, function(val)
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = val end
end)
addSlider(MiscPage, "JumpPower", "Modify jump height", 50, 300, 50, function(val)
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.JumpPower = val end
end)

-- =============================================================================
-- KHỞI TẠO PAGE ESP NÂNG CẤP (HEALTH BAR, SKELETON, CORNER BOX, CHAMS)
-- =============================================================================
local ESPPage = createPage("ESP")
addSidebarButton("ESP", "rbxassetid://7734053499")

-- Các biến quản lý trạng thái Toggles
local ESP_CornerBoxes = false
local ESP_Skeleton = false
local ESP_Lines = false
local ESP_Distance = false
local ESP_HealthBar = false
local ESP_CheckTeam = true
local ESP_Chams = false
local Chams_Color_Index = 0

local ChamsColors = {
	[1] = Color3.fromRGB(255, 0, 0),     -- Đỏ
	[2] = Color3.fromRGB(0, 255, 0),     -- Xanh lá
	[3] = Color3.fromRGB(0, 0, 255),     -- Xanh dương
	[4] = Color3.fromRGB(255, 255, 0),   -- Vàng
	[5] = Color3.fromRGB(255, 0, 255),   -- Hồng
	[6] = Color3.fromRGB(0, 255, 255),   -- Xanh ngọc
	[7] = Color3.fromRGB(255, 128, 0)    -- Cam
}

-- UI Giao diện điều khiển
addSection(ESPPage, "ESP Counters")
local EnemiesCountRow = makeRow(ESPPage, "Enemies Nearby: 0", "Counts enemies in real-time")

addSection(ESPPage, "ESP Visuals")
addToggle(ESPPage, "ESP Team Check", "Ignore teammates", true, function(val) ESP_CheckTeam = val end)
addToggle(ESPPage, "ESP Corner Box", "Draw corner borders around targets", false, function(val) ESP_CornerBoxes = val end)
addToggle(ESPPage, "ESP Health Bar", "Show dynamic health bar on left side", false, function(val) ESP_HealthBar = val end)
addToggle(ESPPage, "ESP Skeleton", "Draw character joint bones line", false, function(val) ESP_Skeleton = val end)
addToggle(ESPPage, "ESP Line (Tracers)", "Lines from bottom center to target", false, function(val) ESP_Lines = val end)
addToggle(ESPPage, "ESP Distance", "Show distance text (Optimized Size)", false, function(val) ESP_Distance = val end)
addToggle(ESPPage, "ESP Chams", "Optimized Wallhack Highlight", false, function(val) ESP_Chams = val end)
addSlider(ESPPage, "Chams Color", "0: Team Color | 1-7: Custom Rainbow", 0, 7, 0, function(val) Chams_Color_Index = val end)

-- =============================================================================
-- LOGIC CORE ENGINE ESP (CHỐNG RENDER LAG & TỐI ƯU HÓA MOBILE)
-- =============================================================================
local Camera = workspace.CurrentCamera
local CoreGui = ScreenGui
local ESP_Cache = {}

-- Hàm tạo các nét vẽ cho Corner Box
local function CreateCornerLines(parent)
	local corners = {}
	for i = 1, 8 do
		local line = Instance.new("Frame")
		line.BorderSizePixel = 0
		line.Visible = false
		line.Parent = parent
		table.insert(corners, line)
	end
	return corners
end

-- Hàm tạo các nét vẽ cho Khung xương (Skeleton)
local function CreateSkeletonLines()
	local bones = {}
	-- Cần 6 đường line để nối các khớp chính: Đầu-Cổ, Cổ-TayTrái, Cổ-TayPhải, Cổ-Hông, Hông-ChânTrái, Hông-ChânPhải
	for i = 1, 6 do
		local line = Instance.new("Frame")
		line.BorderSizePixel = 0
		line.Visible = false
		line.Parent = CoreGui
		table.insert(bones, line)
	end
	return bones
end

local function CreateESPStorage(player)
	if ESP_Cache[player] then return end
	local store = {}
	
	-- 1. Container cho Corner Box
	store.CornerContainer = Instance.new("Frame")
	store.CornerContainer.BackgroundTransparency = 1
	store.CornerContainer.Visible = false
	store.CornerContainer.Parent = CoreGui
	store.Corners = CreateCornerLines(store.CornerContainer)
	
	-- 2. Thanh máu (Health Bar)
	local HealthBG = Instance.new("Frame")
	HealthBG.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	HealthBG.BorderSizePixel = 0
	HealthBG.Visible = false
	HealthBG.Parent = CoreGui
	store.HealthBG = HealthBG
	
	local HealthMain = Instance.new("Frame")
	HealthMain.BorderSizePixel = 0
	HealthMain.Parent = HealthBG
	store.HealthMain = HealthMain
	
	-- 3. Khung xương (Skeleton)
	store.Skeleton = CreateSkeletonLines()
	
	-- 4. Line Tracer
	local Tracer = Instance.new("Frame")
	Tracer.AnchorPoint = Vector2.new(0.5, 0)
	Tracer.BorderSizePixel = 0
	Tracer.Visible = false
	Tracer.Parent = CoreGui
	store.Tracer = Tracer
	
	-- 5. Distance Label (Đã tối ưu font size 10 nhỏ gọn, có viền đen sắc nét)
	local DistLabel = Instance.new("TextLabel")
	DistLabel.BackgroundTransparency = 1
	DistLabel.Size = UDim2.fromOffset(80, 16)
	DistLabel.Font = Enum.Font.GothamBold
	DistLabel.TextSize = 10 -- Test size nhỏ gọn chống tràn màn hình mobile
	DistLabel.TextColor3 = Color3.fromRGB(255, 230, 100)
	DistLabel.TextStrokeTransparency = 0
	DistLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	DistLabel.Visible = false
	DistLabel.Parent = CoreGui
	store.Distance = DistLabel
	
	-- 6. Tối ưu Chams: Chỉ khởi tạo Highlight sẵn 1 lần duy nhất ở đây
	local ChamsHighlight = Instance.new("Highlight")
	ChamsHighlight.Enabled = false
	store.Highlight = ChamsHighlight
	
	ESP_Cache[player] = store
end

local function RemoveESPStorage(player)
	if ESP_Cache[player] then
		local store = ESP_Cache[player]
		store.CornerContainer:Destroy()
		store.HealthBG:Destroy()
		store.Tracer:Destroy()
		store.Distance:Destroy()
		store.Highlight:Destroy()
		for _, line in ipairs(store.Skeleton) do line:Destroy() end
		ESP_Cache[player] = nil
	end
end

-- Tự động dọn dẹp cache / chống render lag khi người chơi thoát
Players.PlayerAdded:Connect(CreateESPStorage)
Players.PlayerRemoving:Connect(RemoveESPStorage)
for _, p in ipairs(Players:GetPlayers()) do
	if p ~= LocalPlayer then CreateESPStorage(p) end
end

-- Hàm phụ trợ vẽ đường nối thẳng giữa 2 điểm vector màn hình
local function DrawLineBetweenPoints(lineFrame, p1, p2, color)
	local distanceX = p2.X - p1.X
	local distanceY = p2.Y - p1.Y
	local angle = math.deg(math.atan2(distanceY, distanceX))
	local length = math.sqrt(distanceX^2 + distanceY^2)
	
	lineFrame.Position = UDim2.fromOffset(p1.X, p1.Y)
	lineFrame.Size = UDim2.fromOffset(length, 1.5)
	lineFrame.Rotation = angle
	lineFrame.BackgroundColor3 = color
	lineFrame.Visible = true
end

-- VÒNG LẶP RENDER CHÍNH (RENDERSTEPPED)
game:GetService("RunService").RenderStepped:Connect(function()
	local EnemiesCount = 0
	local ViewportSize = Camera.ViewportSize
	
	for player, store in pairs(ESP_Cache) do
		local character = player.Character
		local rootPart = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		
		-- Kiểm tra Team Check
		local isTeammate = LocalPlayer.Team and player.Team == LocalPlayer.Team
		local allowedByTeamCheck = not (ESP_CheckTeam and isTeammate)
		
		-- Đếm số lượng kẻ địch thực tế trong server
		if character and rootPart and humanoid and humanoid.Health > 0 and player ~= LocalPlayer then
			if not isTeammate then EnemiesCount = EnemiesCount + 1 end
		end

		-- Điều kiện để tiến hành vẽ các hiệu ứng đồ họa
		if character and rootPart and humanoid and humanoid.Health > 0 and allowedByTeamCheck then
			local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
			
			-- 1. XỬ LÝ CHAMS TỐI ƯU (Tận dụng Highlight có sẵn, không tạo mới vô tội vạ)
			if ESP_Chams then
				if store.Highlight.Parent ~= character then store.Highlight.Parent = character end
				store.Highlight.Enabled = true
				store.Highlight.FillTransparency = 0.35
				store.Highlight.OutlineTransparency = 0.1
				if Chams_Color_Index == 0 then
					store.Highlight.FillColor = isTeammate and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
				else
					local c = ChamsColors[Chams_Color_Index] or Color3.fromRGB(255,255,255)
					store.Highlight.FillColor = c
					store.Highlight.OutlineColor = c
				end
			else
				store.Highlight.Enabled = false
			end
			
			-- NẾU ĐỐI THỦ LẰM TRONG TẦM NHÌN MÀN HÌNH
			if onScreen then
				local factor = 1 / (screenPos.Z * math.tan(math.rad(Camera.FieldOfView / 2))) * 1000
				local boxWidth, boxHeight = 4.2 * factor, 5.8 * factor
				local renderColor = isTeammate and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 40, 40)
				
				local topX, topY = screenPos.X - boxWidth/2, screenPos.Y - boxHeight/2
				
				-- 2. VẼ ESP CORNER BOX (4 Góc chữ L tinh tế)
				if ESP_CornerBoxes then
					store.CornerContainer.Visible = true
					local thick = 1.5
					local len = math.clamp(boxWidth * 0.2, 5, 15) -- Chiều dài thanh góc tỉ lệ theo khoảng cách
					
					-- Góc trên bên trái
					store.Corners[1]:Configure({Position = UDim2.fromOffset(topX, topY), Size = UDim2.fromOffset(len, thick), BackgroundColor3 = renderColor, Visible = true})
					store.Corners[2]:Configure({Position = UDim2.fromOffset(topX, topY), Size = UDim2.fromOffset(thick, len), BackgroundColor3 = renderColor, Visible = true})
					-- Góc trên bên phải
					store.Corners[3]:Configure({Position = UDim2.fromOffset(topX + boxWidth - len, topY), Size = UDim2.fromOffset(len, thick), BackgroundColor3 = renderColor, Visible = true})
					store.Corners[4]:Configure({Position = UDim2.fromOffset(topX + boxWidth - thick, topY), Size = UDim2.fromOffset(thick, len), BackgroundColor3 = renderColor, Visible = true})
					-- Góc dưới bên trái
					store.Corners[5]:Configure({Position = UDim2.fromOffset(topX, topY + boxHeight - thick), Size = UDim2.fromOffset(len, thick), BackgroundColor3 = renderColor, Visible = true})
					store.Corners[6]:Configure({Position = UDim2.fromOffset(topX, topY + boxHeight - len), Size = UDim2.fromOffset(thick, len), BackgroundColor3 = renderColor, Visible = true})
					-- Góc dưới bên phải
					store.Corners[7]:Configure({Position = UDim2.fromOffset(topX + boxWidth - len, topY + boxHeight - thick), Size = UDim2.fromOffset(len, thick), BackgroundColor3 = renderColor, Visible = true})
					store.Corners[8]:Configure({Position = UDim2.fromOffset(topX + boxWidth - thick, topY + boxHeight - len), Size = UDim2.fromOffset(thick, len), BackgroundColor3 = renderColor, Visible = true})
				else
					store.CornerContainer.Visible = false
				end
				
				-- 3. VẼ ESP HEALTH BAR ĐỘNG (Thanh máu thông minh tự đổi màu)
				if ESP_HealthBar then
					local barWidth = 2.5
					local padding = 5
					local healthPct = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
					
					-- Đổi màu mượt mà: Đầy máu = Xanh lá, Ít máu = Đỏ rực
					local healthColor = Color3.fromHSV((healthPct * 120) / 360, 1, 1)
					
					store.HealthBG.Position = UDim2.fromOffset(topX - barWidth - padding, topY)
					store.HealthBG.Size = UDim2.fromOffset(barWidth, boxHeight)
					store.HealthBG.Visible = true
					
					store.HealthMain.Size = UDim2.new(1, 0, healthPct, 0)
					store.HealthMain.Position = UDim2.new(0, 0, 1 - healthPct, 0) -- Giảm dần từ trên xuống dưới
					store.HealthMain.BackgroundColor3 = healthColor
				else
					store.HealthBG.Visible = false
				end
				
				-- 4. VẼ ESP SKELETON (Khung xương nhân vật R15 / R6)
				if ESP_Skeleton then
					local head = character:FindFirstChild("Head")
					local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
					local leftHand = character:FindFirstChild("LeftHand") or character:FindFirstChild("Left Arm")
					local rightHand = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
					local leftFoot = character:FindFirstChild("LeftFoot") or character:FindFirstChild("Left Leg")
					local rightFoot = character:FindFirstChild("RightFoot") or character:FindFirstChild("Right Leg")
					
					if head and torso and leftHand and rightHand and leftFoot and rightFoot then
						local pHead = Camera:WorldToViewportPoint(head.Position)
						local pTorso = Camera:WorldToViewportPoint(torso.Position)
						local pLHand = Camera:WorldToViewportPoint(leftHand.Position)
						local pRHand = Camera:WorldToViewportPoint(rightHand.Position)
						local pLFoot = Camera:WorldToViewportPoint(leftFoot.Position)
						local pRFoot = Camera:WorldToViewportPoint(rightFoot.Position)
						
						local skColor = Color3.fromRGB(255, 255, 255) -- Khung xương trắng tinh tế chuyên nghiệp
						
						DrawLineBetweenPoints(store.Skeleton[1], pHead, pTorso, skColor)
						DrawLineBetweenPoints(store.Skeleton[2], pTorso, pLHand, skColor)
						DrawLineBetweenPoints(store.Skeleton[3], pTorso, pRHand, skColor)
						DrawLineBetweenPoints(store.Skeleton[4], pTorso, Vector2.new((pLFoot.X + pRFoot.X)/2, (pLFoot.Y + pRFoot.Y)/2), skColor) -- Điểm hông giữa
						DrawLineBetweenPoints(store.Skeleton[5], Vector2.new((pLFoot.X + pRFoot.X)/2, (pLFoot.Y + pRFoot.Y)/2), pLFoot, skColor)
						DrawLineBetweenPoints(store.Skeleton[6], Vector2.new((pLFoot.X + pRFoot.X)/2, (pLFoot.Y + pRFoot.Y)/2), pRFoot, skColor)
					else
						for _, line in ipairs(store.Skeleton) do line.Visible = false end
					end
				else
					for _, line in ipairs(store.Skeleton) do line.Visible = false end
				end
				
				-- 5. VẼ ESP LINES TRACER (Từ giữa đáy màn hình chỉa thẳng lên đối thủ)
				if ESP_Lines then
					DrawLineBetweenPoints(store.Tracer, Vector2.new(ViewportSize.X / 2, ViewportSize.Y), Vector2.new(screenPos.X, topY + boxHeight), renderColor)
				else
					store.Tracer.Visible = false
				end
				
				-- 6. VẼ ESP DISTANCE (Khoảng cách mét)
				if ESP_Distance then
					store.Distance.Text = tostring(math.floor(screenPos.Z)) .. "m"
					store.Distance.Position = UDim2.fromOffset(screenPos.X - 40, topY + boxHeight + 2)
					store.Distance.Visible = true
				else
					store.Distance.Visible = false
				end
			else
				-- Khuất màn hình -> Ẩn toàn bộ linh kiện vẽ lập tức chống tốn tài nguyên máy
				store.CornerContainer.Visible = false
				store.HealthBG.Visible = false
				store.Tracer.Visible = false
				store.Distance.Visible = false
				for _, line in ipairs(store.Skeleton) do line.Visible = false end
			end
		else
			-- Người chơi chết hoặc là đồng đội (khi bật Team check) -> Ẩn hết
			store.CornerContainer.Visible = false
			store.HealthBG.Visible = false
			store.Tracer.Visible = false
			store.Distance.Visible = false
			for _, line in ipairs(store.Skeleton) do line.Visible = false end
			if store.Highlight.Parent then store.Highlight.Enabled = false end
		end
	end
	
	-- Cập nhật số lượng địch lên Menu Real-time
	local txtLabel = EnemiesCountRow:FindFirstChildOfClass("TextLabel")
	if txtLabel then txtLabel.Text = "Enemies Nearby: " .. tostring(EnemiesCount) end
end)

-- Hàm tối ưu cấu hình nhanh cho các đối tượng Instance UI
function Instance:Configure(properties)
	for k, v in pairs(properties) do self[k] = v end
end


openPage("Main")

-- ========================
-- HỆ THỐNG DRAG CHUẨN (Hoạt động hoàn hảo cho cả thu nhỏ/phóng to)
-- ========================
local dragToggle = false
local dragStart, startPos

TopBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragToggle = true
		dragStart = input.Position
		startPos = Main.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragToggle = false
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		Main.Position = UDim2.fromOffset(startPos.X.Offset + delta.X, startPos.Y.Offset + delta.Y)
	end
end)

-- ========================
-- HIỆU ỨNG KHỞI CHẠY (Bung mở mượt từ tâm)
-- ========================
local InitialSize = GetTargetSize()
Main.Size = UDim2.fromOffset(InitialSize.X.Offset, 0)
CenterUI(InitialSize)

TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
	Size = InitialSize
}):Play()

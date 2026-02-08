-- Ultra Optimized Reconstructor ESP
-- Fixed & FPS-friendly (100+ models safe)

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local ReconESP = {}

-- ================= CONFIG =================

ReconESP.Enabled = true
ReconESP.ShowName = true
ReconESP.ShowDistance = true
ReconESP.ShowOutline = true
ReconESP.TeamCheck = false

ReconESP.DefaultColor = Color3.fromRGB(255,255,255)
ReconESP.FillTransparency = 0.8
ReconESP.OutlineTransparency = 0

-- ================= CACHE =================

local ActiveESP = {} -- [model] = {Highlight, Tag, Label, LastColor}

-- ================= UTILS =================

local function getReconstructorColor(model)
	if not ReconESP.TeamCheck then
		return ReconESP.DefaultColor
	end

	local lights = model:FindFirstChild("Lights")
	if not lights then return ReconESP.DefaultColor end

	for _, part in ipairs(lights:GetChildren()) do
		if part:IsA("BasePart") and part.Name == "Part" then
			return part.Color
		end
	end

	return ReconESP.DefaultColor
end

local function getDistance(model)
	if not model.PrimaryPart then return "" end
	local dist = (model.PrimaryPart.Position - Camera.CFrame.Position).Magnitude
	return string.format("[%dm]", math.floor(dist))
end

-- ================= ESP CORE =================

local function removeESP(model)
	local data = ActiveESP[model]
	if not data then return end

	if data.Highlight then data.Highlight:Destroy() end
	if data.Tag then data.Tag:Destroy() end

	ActiveESP[model] = nil
end

local function createESP(model)
	if ActiveESP[model] or not model.PrimaryPart then return end

	local color = getReconstructorColor(model)

	-- Highlight
	local hl = Instance.new("Highlight")
	hl.Name = "ReconESP_HL"
	hl.Adornee = model
	hl.FillColor = color
	hl.OutlineColor = color
	hl.FillTransparency = ReconESP.FillTransparency
	hl.OutlineTransparency = ReconESP.ShowOutline and ReconESP.OutlineTransparency or 1
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Parent = model

	-- Billboard
	local gui, label
	if ReconESP.ShowName or ReconESP.ShowDistance then
		gui = Instance.new("BillboardGui")
		gui.Name = "ReconESP_Tag"
		gui.Adornee = model.PrimaryPart
		gui.Size = UDim2.fromOffset(150, 28)
		gui.StudsOffset = Vector3.new(0, 3, 0)
		gui.AlwaysOnTop = true
		gui.Parent = model.PrimaryPart

		label = Instance.new("TextLabel")
		label.BackgroundTransparency = 1
		label.Size = UDim2.fromScale(1,1)
		label.Font = Enum.Font.Gotham
		label.TextScaled = true
		label.TextStrokeTransparency = 0.85
		label.TextColor3 = color
		label.Parent = gui
	end

	ActiveESP[model] = {
		Highlight = hl,
		Tag = gui,
		Label = label,
		LastColor = color
	}
end

local function updateESP(model)
	local data = ActiveESP[model]
	if not data then return end
	if not model.PrimaryPart then
		return removeESP(model)
	end

	-- Cor
	local color = getReconstructorColor(model)
	if data.LastColor ~= color then
		data.LastColor = color
		data.Highlight.FillColor = color
		data.Highlight.OutlineColor = color
		if data.Label then
			data.Label.TextColor3 = color
		end
	end

	-- Outline toggle
	data.Highlight.OutlineTransparency =
		ReconESP.ShowOutline and ReconESP.OutlineTransparency or 1

	-- Texto
	if data.Label then
		if ReconESP.ShowName or ReconESP.ShowDistance then
			local txt = ""
			if ReconESP.ShowName then
				txt = "Reconstructor"
			end
			if ReconESP.ShowDistance then
				txt ..= " " .. getDistance(model)
			end
			data.Label.Text = txt
		else
			data.Label.Text = ""
		end
	end
end

-- ================= SCAN LOOP =================

task.spawn(function()
	while true do
		if ReconESP.Enabled then
			local plots = Workspace:FindFirstChild("Plots")
			if plots then
				for _, recon in ipairs(plots:GetChildren()) do
					if recon:IsA("Model") and recon.Name == "Reconstructor" then
						local lights = recon:FindFirstChild("Lights")
						if lights then
							for _, part in ipairs(lights:GetChildren()) do
								if part:IsA("BasePart") and part.Name == "Part" then
									createESP(recon)
									break
								end
							end
						end
					end
				end
			end
		end
		task.wait(0.5)
	end
end)

-- ================= UPDATE LOOP =================

RunService.RenderStepped:Connect(function()
	if not ReconESP.Enabled then return end
	for model in pairs(ActiveESP) do
		updateESP(model)
	end
end)

-- ================= API =================

function ReconESP.SetEnabled(v)
	if ReconESP.Enabled == v then return end
	ReconESP.Enabled = v

	if not v then
		for model in pairs(ActiveESP) do
			removeESP(model)
		end
	end
end

function ReconESP.SetShowName(v) ReconESP.ShowName = v end
function ReconESP.SetShowDistance(v) ReconESP.ShowDistance = v end
function ReconESP.SetShowOutline(v) ReconESP.ShowOutline = v end
function ReconESP.SetTeamCheck(v) ReconESP.TeamCheck = v end
function ReconESP.SetColor(c) ReconESP.DefaultColor = c end

return ReconESP

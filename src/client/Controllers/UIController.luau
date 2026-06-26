local Directory = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared").Directory)
local Trove = require(Directory.Packages.trove)

local Spr = require(Directory.Packages.spr)

local TweenService = Directory.TweenService

local POP_TIME = 0.18 -- seconds for a pop-in scale tween

local UIController = {
    OverlayTrove = Trove.new()
}

local LocalPlayer = Directory.Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local screenGuiRef: ScreenGui? = nil
function UIController:resolveScreenGui(): ScreenGui?
	if screenGuiRef and screenGuiRef.Parent then
		return screenGuiRef
	end
	local gui = PlayerGui:FindFirstChild("ScreenGui")
	if gui and gui:IsA("ScreenGui") then
		screenGuiRef = gui
		return gui
	end
	return nil
end

function UIController:BindButtonEffect(
	button: GuiButton,
	showFrame: Frame?,
	buttonDownScale: number?,
	buttonHoverscale: number?,
	onHoverCallback: (() -> ())?,
	OnHoverEndCallback: (() -> ())?,
	clickSoundName: string?,
	buttonNormalScale: number?
)
	--
	local cleaner = Trove.new()

	--
	showFrame = showFrame or button

	--
	local uiScale = showFrame:FindFirstChildOfClass("UIScale")
	if not uiScale then
		uiScale = Instance.new("UIScale")
		uiScale.Parent = showFrame
	end

	local damping = 0.7
	local frequency = 5

	local buttonSprings = {
		Press = function()
			Spr.target(uiScale, damping, frequency, {
				Scale = buttonDownScale or 0.95,
			})
		end,

		Hover = function()
			Spr.target(uiScale, damping, frequency, {
				Scale = buttonHoverscale or 1.05,
			})
		end,

		Normal = function()
			Spr.target(uiScale, damping, frequency, {
				Scale = buttonNormalScale or 1,
			})
		end,
	}

	--
	cleaner:Add(button.MouseButton1Down:Connect(function()
		--SoundController:PlaySound(clickSoundName or "InteractUI")
		buttonSprings.Press()
	end))

	cleaner:Add(button.MouseButton1Up:Connect(function()
		buttonSprings.Normal()
	end))

	cleaner:Add(button.MouseEnter:Connect(function()
		if onHoverCallback then
			onHoverCallback()
		end

		--SoundController:PlaySound("ButtonHover")
		buttonSprings.Hover()
	end))

	cleaner:Add(button.MouseLeave:Connect(function()
		if OnHoverEndCallback then
			OnHoverEndCallback()
		end

		buttonSprings.Normal()
	end))

	cleaner:Add(buttonSprings.Normal)

	return {
		Disconnect = function()
			cleaner:Destroy()
		end,
	}
end

-- Ensures the GuiObject has a UIScale to animate, creating one if needed.
local function ensureUIScale(gui: GuiObject): UIScale
	local scale = gui:FindFirstChildOfClass("UIScale")
	if not scale then
		scale = Instance.new("UIScale")
		scale.Parent = gui
	end
	return scale
end

function UIController:ToggleOverlay()

    if self.OverlayTrove then
        self.OverlayTrove:Clean()
    end

    local screen = self:resolveScreenGui()

    local BlackOverlay: Frame = screen:FindFirstChild("BlackOverlay")
    if not BlackOverlay then
        return
    end

    BlackOverlay.Visible = true
    BlackOverlay.Transparency = 1

    local Blur = Instance.new("BlurEffect")
    Blur.Size = 0
    Blur.Parent = Directory.Lighting

    Spr.target(BlackOverlay, 0.55, 3, {
        Transparency = 0.3
    })

    Spr.target(Blur, 0.55, 3, {
        Size = 10
    })

    self.OverlayTrove:Add(function()
    Spr.target(BlackOverlay, 0.4, 2.5, {
        Transparency = 1
    })

    Spr.target(Blur, 0.4, 2.5, {
        Size = 0
    })

        task.delay(0.25, function()
            if Blur.Parent then
                BlackOverlay.Visible = false
                Blur:Destroy()
            end
        end)
    end)
end

-- Pops a GuiObject in from zero to `targetScale` (default 1) with a slight
-- overshoot. Reused for circle spawns and the win text. Non-yielding.
function UIController:PopGui(gui: any, targetScale: number?)
	local scale = ensureUIScale(gui)
	scale.Scale = 0

    gui.TextTransparency = 0
    gui.Visible = true

	TweenService:Create(
		scale,
		TweenInfo.new(POP_TIME, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Scale = targetScale or 1 }
	):Play()
end

-- Reveals + pops the WinText label. The caller decides when to hide it again.
-- Non-yielding.
function UIController:PlayWinText(label: TextLabel)
	label.Visible = true
	self:PopGui(label, 1)
end

--[[
	Frame open / close (spring-based)
	---------------------------------
	Bouncy spring pop for opening/closing whole frames (shops, panels, ...). Unlike
	PopGui these are SPRING-driven and make no TextTransparency assumptions, so they're
	safe on any GuiObject (a plain Frame included). Non-yielding.
]]

-- Spring-pops a GuiObject open: snaps to `fromScale` (default 0.8) then springs up to 1.
function UIController:SpringOpen(gui: GuiObject, fromScale: number?, damping: number?, frequency: number?)
	local scale = ensureUIScale(gui)
	Spr.stop(scale)
	scale.Scale = fromScale or 0.8
	gui.Visible = true
	Spr.target(scale, damping or 0.6, frequency or 4, {
		Scale = 1,
	})
end

-- Spring-shrinks a GuiObject closed, then hides it once it has actually shrunk (so a
-- quick re-open cancels the hide).
function UIController:SpringClose(gui: GuiObject, damping: number?, frequency: number?)
	local scale = ensureUIScale(gui)
	Spr.target(scale, damping or 0.7, frequency or 5, {
		Scale = 0,
	})
	task.delay(0.25, function()
		if scale.Scale < 0.1 then
			gui.Visible = false
		end
	end)
end

function UIController:Iris(Duration: number?, Close: boolean)
	local TransitionGui = PlayerGui.TransitionGui :: ScreenGui
	local Frame = TransitionGui.Iris :: Frame

	if Close == nil then Close = true end
	Duration = Duration or 3

	Frame.Visible = true

	local GoalSize = Close
		and UDim2.fromScale(0.001, 0.001)
		or UDim2.fromScale(2, 2)

	local Tween: Tween = TweenService:Create(
		Frame,
		TweenInfo.new(
			Duration,
			Enum.EasingStyle.Quart,
			Enum.EasingDirection.InOut
		),
		{
			Size = GoalSize
		}
	)

	Tween:Play()

	return Close == true or nil
end

function UIController:TypeWriterEffect(TextLabel: TextLabel, Text: string)

end

function UIController:ShowDialogue(Billboard: BillboardGui)
	-- Show Effects etc, then TypeWrite effect.
end

return UIController
--[[
-!MyhichF12
 -- This is a cool module for creating cutscenes.
 -- Put the module in local side folders
_______________________________________________________________________________________________________________________________________________________________________

 | Example code |

-- make a local script inside StarterPlayerScripts or whatever
 local CutsceneCreator = require(script.Parent:WaitForChild("CutsceneCreator"))

local MyCutscene = CutsceneCreator.Create()
MyCutscene.EasingStyle = Enum.EasingStyle.Quad
MyCutscene.EasingDirection = Enum.EasingDirection.InOut
MyCutscene.Name = "My First Cutscene"

MyCutscene.PlayersToLockOn = {"MyhichF12"} -- This is required

MyCutscene.StarterCFrame = workspace:WaitForChild("Start").CFrame      -- This is required

MyCutscene:AddKeyframe(5, workspace:WaitForChild("Point1").CFrame, 1, 2)
MyCutscene:AddKeyframe(2,workspace:WaitForChild("Point2").CFrame, 2, 1)


MyCutscene.KeyframeStarted:Connect(function (keyframe)
	print("yooo my cutscene just started "..keyframe.Name)
end)

MyCutscene:Start()

task.wait(0.2)
print(MyCutscene.Lenght)


_______________________________________________________________________________________________________________________________________________________________________

 * local CutsceneCreator = require(path to module)
     Description
       Requires the module

| FUNCTIONS |

 * CutsceneCreator.Create()
     Description
       -- Creates a cutscene table, returns cutscene

 * cutscene:Start()
     Description
       -- Starts the cutscene, returns nil
       -- Fires the Started signal, End signal, KeyframeStarted signal, KeyframeEnded signal

  * cutscene:End()
     Description
       -- End the cutscenem returns nil
       -- Fires the End signal

  * cutscene:AddKeyframe(time, cframe, index, sleep)
     Description
      -- creates a new keyframe
      -- Parameters
        > time: number
          - The time for the tween to finish
        > cframe: CFrame
          - The CFrame for the tween to go
        > index: number
          - The index of the keyframe
        > sleep: number
          - The amount of time to sleep when the tween of keyframe is finished

_______________________________________________________________________________________________________________________________________________________________________

| CUTSCENE PARAMETERS |
  > EasingStyle : Enum.EasingStyle
    - The EasingStyle of tween
  > EasingDirection : Enum.EasingDirection
    - The EasingDirection of tween
  > PlayersToLockOn : table or string
    - Players  the cutscene is playing for, you can set its value to "All" if you want to put in the table all the players
  > Name : string
    - Name of the cutscene, used for debugging
  > StarterCFrame : CFrame
    - The CFrame of the CameraPart, basicly when will the start of cutscene appear
  > AutoClearCutscene : Boolean
   - if set to true, automaticly deletes the physical cutscene at server storage
  > Lenght : number
   - The lenght of the cutscene, you cant set it by yourself, its calculated with keyframe time and sleep
  > AutoEndDelay : number
   - Delay for automatic end in :Start function

_______________________________________________________________________________________________________________________________________________________________________

| SIGNALS |
  * Started
    -- Fires when the cutscene starts, returns nothing

  * Ended
    -- Fires when the cutscene ends, returns nothing

  * KeyframeStarted
    -- Fires when a keyframe starts, returns a keyframe instance

  * KeyframeEnded
    -- Fires when a keyframe ends, returns a keyframe instance





_______________________________________________________________________________________________________________________________________________________________________





  ]]
local goodSignal = require(game:WaitForChild("ReplicatedStorage"):WaitForChild("GoodSignal"))
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local Tweenservice = game:GetService("TweenService")
local cutscene = {}
cutscene.__index = cutscene


function cutscene.Create()
	local self = setmetatable({}, cutscene)

	self.EasingStyle = Enum.EasingStyle.Sine
	self.EasingDirection = Enum.EasingDirection.Out
	self.PlayersToLockOn = {}

	self.Name = "Cutscene "..math.random(1,100)
	self.CutsceneThread = nil  --#dontouchme
	self.StarterCFrame = CFrame.new()
	self.AutoclearCutscene = false
	self.Tween = nil --#dontouchme

	self.Lenght = 0
	self.AutoEndDelay = 0.2

	self.DisableRunService = goodSignal.new()
	self.Ended = goodSignal.new()  --#dontouchme
	self.KeyframeStarted = goodSignal.new()  --#dontouchme
	self.KeyframeEnded = goodSignal.new()  --#dontouchme
	self.Started = goodSignal.new()  --#dontouchme



	return self
end

local function CalculateLenght(physCutscene:Folder)
	local numberToReturn = 0
for _, v in physCutscene:GetDescendants() do
	if v:IsA("NumberValue") or v:IsA("IntValue") then
	numberToReturn += v.Value
	end
end
return numberToReturn
end


function cutscene:AddKeyframe(gtime: number, gCFrame:CFrame, index:number, Sleep:number)
	local mainFolder
	local keyprefix = "keyframe"
	local folder = ServerStorage:FindFirstChild(self.Name)
	if folder then

	mainFolder = folder

	else

		mainFolder = Instance.new("Folder")
	mainFolder.Name = self.Name
	mainFolder.Parent = ServerStorage

	end

	local keyframe = Instance.new("BoolValue")
	keyframe.Name = keyprefix..index
	keyframe.Parent = mainFolder

	local Time = Instance.new("NumberValue")
	Time.Name = "Time"
	Time.Parent = keyframe
	Time.Value = gtime

	local CF = Instance.new("CFrameValue")
	CF.Name = "CFrameValue"
	CF.Parent = keyframe
	CF.Value = gCFrame

	if Sleep then
		local sleep = Instance.new("NumberValue")
		sleep.Name = "Sleep"
		sleep.Parent = keyframe
	sleep.Value = Sleep
	end

end

function cutscene:Start()
	self.Started:Fire()


	self.Lenght = CalculateLenght(ServerStorage:FindFirstChild(self.Name))
	local CamPart = Instance.new("Part")
	CamPart.Name = "CamPart"
	CamPart.Parent = workspace
	CamPart.CFrame = self.StarterCFrame
	CamPart.Anchored = true
	CamPart.CanCollide = false

	local CutsceneValue = Instance.new("ObjectValue")
CutsceneValue.Parent = CamPart
CutsceneValue.Name = "ChildOf"
CutsceneValue.Value = ServerStorage:FindFirstChild(self.Name)
if CutsceneValue == nil then
	warn("no cutscene folder found")
	return
end

	local plrs = game.Players

	if self.PlayersToLockOn == "All" then
		table.clear(self.PLayersToLockOm)
		for _, plr in plrs:GetChildren() do

			table.insert(self.PlayersToLockOn,plr.Name)

				local player = plrs:FindFirstChild(plr)
				local camera = workspace.Camera
				local runConnection = RunService.RenderStepped:Connect(function ()
					camera.CFrame = CamPart.CFrame

				end)
			self.DisableRunService:Connect(function ()
				runConnection:Disconnect()
			end)

		end
	else
		for _, plr in self.PlayersToLockOn do
			if plrs:FindFirstChild(plr) then

					local player = plrs:FindFirstChild(plr)
					local camera = workspace.Camera
					local runConnection = RunService.RenderStepped:Connect(function ()
						camera.CFrame = CamPart.CFrame
						print("running for "..player.Name)

					end)
				self.DisableRunService:Connect(function ()
					runConnection:Disconnect()
				end)

			end
		end
	end

	local Cutscene = task.spawn(function()
		local phisycalCutscene = ServerStorage:FindFirstChild(self.Name)
	if phisycalCutscene then
		for i = 1, #phisycalCutscene:GetChildren() do
			local keyframe = phisycalCutscene:GetChildren()[i]
			local CF = keyframe.CFrameValue.Value
			local Time = keyframe.Time.Value
			self.KeyframeStarted:Fire(keyframe)

			local tween = Tweenservice:Create(CamPart, TweenInfo.new(Time, self.EasingStyle, self.EasingDirection), {CFrame = CF})
			self.Tween = tween
			tween:Play()

			task.wait(Time)
			if keyframe:FindFirstChild("Sleep") then
					task.wait(keyframe:FindFirstChild("Sleep").Value)
			end

			self.KeyframeEnded:Fire(keyframe)
		end


	end



    end)
self.CutsceneThread = Cutscene
task.delay(self.Lenght + self.AutoEndDelay, function ()
	self:End()
end)




end



function cutscene:End()

	if self.CutsceneThread then
		task.cancel(self.CutsceneThread)
	end

	if self.Tween then
		self.Tween:Cancel()
		self.Tween:Destroy()
	end
	self.DisableRunService:Fire()

local function Clear()
	local camPart = workspace:FindFirstChild("CamPart")
	if camPart:FindFirstChild("ChildOf") then
		camPart:Destroy()
	end
	if self.AutoClearCutscene == true then
		local physCutscene = ServerStorage:FindFirstChild(self.Name)
		if physCutscene then
			physCutscene:Destroy()
		end
	end
end
	Clear()
	self.Ended:Fire()

end


return cutscene


--:API
--This is a very basic blood emitter module



--[[FUNCTIONS

--bloodModule.Emit() -- How much blood parts do you want to emit on specific instance
    Arguments{}: Num:Number -- how much blood parts is gonna be emitted
               OnWhat:BasePart -- part where the bloodParts will be appearing (Part and bloodPart cant collide together)
               CollisionGroupName:String -- name of the CollisionGroup of the blood parts
                
--bloodModule.EmitOnCharacter() -- Does the same thing but on character, use this to emit blood on character
    Arguments{}: Character:Model -- The character where the blood will be emitted on
                 Num:Number -- how much bloodParts will be emitted


--bloodModule.TagCharacter() --Automaticly emits blood when humanoid.HealthChanged event fires, how much blood will be emitted is based on how much health humanoid lost
    Arguments{}: Character:Model -- The character to target

]]--

--[[CONFIG

--Velocity:Boolean -- add velocity on bloodPart spawn
--DisappearEffect:Boolean -- adds some disappear effetcs
--BloodSize:Vector3 -- size of a bloodPart will be
--TimeToDisappear:Number -- aftes this time the bloodpart will be destroyed by debris Service
--BloodColor:Color3 -- the color of the blood
--MiniBlood:Boolead -- replaces some bloodParts by a mini bloodParts or custom size ones
--MiniBloodSize:Vector3 -- size of a mini bloodPart

]]
local Debris = game:GetService("Debris")
local tweens = game:GetService("TweenService")






local config = {
Velocity = true,

DisappearEffect = true,

BLoodSize = Vector3.new(1,1,1),

TimeToDisappear = 4,

BloodColor = Color3.new(0.666667, 0, 0),

MiniBlood = true,

MiniBloodSize = Vector3.new(0.5,0.5,0.5)
}


local bloodModule = {}


function bloodModule.Emit(Num:number, OnWhat:BasePart, CollisionGroupName:string)
	OnWhat.CollisionGroup = OnWhat.Name.." Blood"
	
		
	for blood = 1, Num do 
		local bloodDebris = Instance.new("Part")
		
		bloodDebris.Parent = workspace
		bloodDebris.Name = "BLood"
		if CollisionGroupName then
			bloodDebris.CollisionGroup = CollisionGroupName
		else
			
		bloodDebris.CollisionGroup = OnWhat.Name.." BLood"
		end
		bloodDebris.Position = OnWhat.Position
		
		if config.MiniBlood == true then
			local random = math.random(1,2)
			if random == 1 then
				bloodDebris.Size = config.MiniBloodSize
			else
				bloodDebris.Size = config.BLoodSize
			end
		else
		bloodDebris.Size = config.BLoodSize
		end
		bloodDebris.Color = config.BloodColor
		if config.Velocity == true then
		
		
		bloodDebris.AssemblyLinearVelocity = Vector3.new(math.random(-10,15),math.random(5,50),math.random(-10,15)) --customize velocity here
			bloodDebris.AssemblyAngularVelocity = Vector3.new(math.random(-10,15),math.random(5,50),math.random(-10,15)) --customize velocity here
			
		
		end
		
		
		if config.DisappearEffect == true then
			task.delay(1,function()
			
			local tween = tweens:Create(bloodDebris, TweenInfo.new(5, Enum.EasingStyle.Sine), {Position = bloodDebris.Position - Vector3.new(0, 10, 0)}):Play()
			end)
			
		end
		Debris:AddItem(bloodDebris, config.TimeToDissapear)
	end
	
	OnWhat.CollisionGroup ="Default"
end

function bloodModule.EmitOnCharacter(Num:number, character:Instance)
	local root = character:FindFirstChild("HumanoidRootPart")
	if root then
		for _, part in character:GetChildren() do
			if part:IsA("BasePart") then
			part.CollisionGroup = character.Name.." Blood"
			end
		end
		bloodModule.Emit(Num, root, character.Name.." Blood")
		
	end
end


function bloodModule.TagCharacter(Character:Instance) 
	if Character:FindFirstChild("HumanoidRootPart") then
		local humroot: Instance = Character.HumanoidRootPart
		if humroot:HasTag("BloodTag") then warn("This humanoid already have BloodTag on") return end
		humroot:AddTag("BloodTag")
		
		local humanoid = humroot.Parent:FindFirstChild("Humanoid")
		humanoid.HealthChanged:Connect(function(health)
			if health < 0 then
				health = 0
			end
			local Damage = humanoid.MaxHealth - health
			bloodModule.EmitOnCharacter(math.floor(Damage)/5, humanoid.Parent)
		end)
		end
end




return bloodModule


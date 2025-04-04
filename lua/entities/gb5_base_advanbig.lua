AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

local Models = {}
Models[1]                            =  "testmodel"

local ExploSnds = {}
ExploSnds[1]                         =  "BaseExplosionEffect.Sound"

local damagesound                    =  "weapons/rpg/shotdown.wav"

ENT.Spawnable		            	 =  false         
ENT.AdminSpawnable		             =  false       

ENT.PrintName		                 =  "Name"        
ENT.Author			                 =  "natsu"      
ENT.Contact			                 =  "natsu" 
ENT.Category                         =  ""            

ENT.Model                            =  ""            
ENT.Effect                           =  ""            
ENT.EffectAir                        =  ""           
ENT.EffectWater                      =  ""            
ENT.ExplosionSound                   =  "gbombs_5/explosions/heavy_bomb/ex2.mp3"          
ENT.ArmSound                         =  ""            
ENT.ActivationSound                  =  ""    
ENT.NBCEntity                        =  ""   


ENT.ShouldUnweld                     =  false         
ENT.ShouldIgnite                     =  false         
ENT.ShouldExplodeOnImpact            =  false         
ENT.Flamable                         =  false        
ENT.UseRandomSounds                  =  true         
ENT.UseRandomModels                  =  false                
ENT.Timed                            =  false    
ENT.IsNBC                            =  false

ENT.ExplosionDamage                  =  0             
ENT.PhysForce                        =  0             
ENT.ExplosionRadius                  =  0            
ENT.SpecialRadius                    =  0             
ENT.MaxIgnitionTime                  =  5             
ENT.Life                             =  20           
ENT.MaxDelay                         =  2             
ENT.TraceLength                      =  500           
ENT.ImpactSpeed                      =  500          
ENT.Mass                             =  0                     
ENT.ArmDelay                         =  2                      
ENT.Timer                            =  0
ENT.Shocktime                        =  1

ENT.DEFAULT_PHYSFORCE                = 500
ENT.DEFAULT_PHYSFORCE_PLYAIR         = 100
ENT.DEFAULT_PHYSFORCE_PLYGROUND         = 5000 
ENT.GBOWNER                          =  nil            

function ENT:Initialize()
 if (SERVER) then
     self:LoadModel()
	 self:PhysicsInit( SOLID_VPHYSICS )
	 self:SetSolid( SOLID_VPHYSICS )
	 self:SetMoveType( MOVETYPE_VPHYSICS )
	 self:SetUseType( ONOFF_USE ) 
	 local phys = self:GetPhysicsObject()
	 local skincount = self:SkinCount()
	 if (phys:IsValid()) then
		 phys:SetMass(self.Mass)
		 phys:Wake()
     end
	 if (skincount > 0) then
	     self:SetSkin(math.random(0,skincount))
	 end
	 self.Armed    = false
	 self.Exploded = false
	 self.Used     = false
	 self.Arming   = false
	  if not (WireAddon == nil) then self.Inputs   = Wire_CreateInputs(self, { "Arm", "Detonate" }) end
	end
end

function ENT:TriggerInput(iname, value)
     if (not self:IsValid()) then return end
	 if (iname == "Detonate") then
         if (value >= 1) then
		     if (not self.Exploded and self.Armed) then
			     timer.Simple(math.Rand(0,self.MaxDelay),function()
				     if not self:IsValid() then return end
	                 self.Exploded = true
			         self:Explode()
				 end)
		     end
		 end
	 end
	 if (iname == "Arm") then
         if (value >= 1) then
             if (not self.Exploded and not self.Armed and not self.Arming) then
			     self:EmitSound(self.ActivationSound)
                 self:Arm()
             end 
         end
     end		 
end 

function ENT:LoadModel()
     if self.UseRandomModels then
	     self:SetModel(table.Random(Models))
	 else
	     self:SetModel(self.Model)
	 end
end
	 


function ENT:Explode()
    if not self.Exploded then return end
    if self.Exploding then return end
    
    local pos = self:LocalToWorld(self:OBBCenter())
    self:SetModel("models/gibs/scanner_gib02.mdl")
    self.Exploding = true
    constraint.RemoveAll(self)
    local physo = self:GetPhysicsObject()
    physo:Wake()
    physo:EnableMotion(false)
    local ent = ents.Create("gb5_shockwave_sound_lowsh")
    ent:SetPos(pos)
    ent:Spawn()
    ent:Activate()
    ent:SetVar("GBOWNER", self.GBOWNER)
    ent:SetVar("MAX_RANGE", 500000)
    ent:SetVar("SHOCKWAVE_INCREMENT", 20000)
    ent:SetVar("DELAY", 0.01)
    ent:SetVar("Shocktime", 5)
    ent:SetVar("SOUND", "gbombs_5/explosions/heavy_bomb/ex2.mp3")
    self.affected = {}
    for k, v in pairs(ents.FindInSphere(pos, 1800)) do
        if v:IsPlayer() then
            table.insert(self.affected, v)
        end
    end
	
	   local targets = ents.FindInSphere(self:GetPos(), self.ExplosionRadius)
    for _, target in ipairs(targets) do
        if target:IsValid() and target:IsPlayer() then
            local damageInfo = DamageInfo()
            damageInfo:SetDamage(self.ExplosionDamage)
            damageInfo:SetAttacker(self.GBOWNER)
            damageInfo:SetInflictor(self)
            damageInfo:SetDamageType(DMG_BLAST)
            target:TakeDamageInfo(damageInfo)
        end
    end

    timer.Simple(2.5, function()
        if not self:IsValid() then return end
        local ent = ents.Create("gb5_shockwave_sound_lowsh")
        ent:SetPos(pos)
        ent:Spawn()
        ent:Activate()
        ent:SetVar("GBOWNER", self.GBOWNER)
        ent:SetVar("MAX_RANGE", 1500)
        ent:SetVar("SHOCKWAVE_INCREMENT", 100)
        ent:SetVar("DELAY", 0.01)
        ent:SetVar("Shocktime", 1)
        ent:SetVar("SOUND", "gbombs_5/explosions/special/endothermic_freeze.wav")

        local ent = ents.Create("gb5_shockwave_cold")
        ent:SetPos(pos)
        ent:Spawn()
        ent:Activate()
        ent:SetVar("DEFAULT_PHYSFORCE", 25)
        ent:SetVar("DEFAULT_PHYSFORCE_PLYAIR", 25)
        ent:SetVar("DEFAULT_PHYSFORCE_PLYGROUND", 25)
        ent:SetVar("GBOWNER", self.GBOWNER)
        ent:SetVar("MAX_RANGE", 1500)
        ent:SetVar("SHOCKWAVE_INCREMENT", 100)
        ent:SetVar("DELAY", 0.1)
        timer.Simple(10, function()
            if not self:IsValid() then return end
            self:Remove()
        end)
    end)
	
	 if(self:WaterLevel() >= 1) then
		 local trdata   = {}
		 local trlength = Vector(0,0,9000)
		 
	     trdata.start   = pos
		 trdata.endpos  = trdata.start + trlength
		 trdata.filter  = self
		 
		 local tr = util.TraceLine(trdata) 
		 local trdat2   = {}
	     trdat2.start   = tr.HitPos
		 trdat2.endpos  = trdata.start - trlength
		 trdat2.filter  = self
		 trdat2.mask    = MASK_WATER + CONTENTS_TRANSLUCENT
			
		 local tr2 = util.TraceLine(trdat2)
			 
		 if tr2.Hit then
		     ParticleEffect(self.EffectWater, tr2.HitPos, Angle(0,0,0), nil)
		 end
	 else
		 local tracedata    = {}
	     tracedata.start    = pos
		 tracedata.endpos   = tracedata.start - Vector(0, 0, self.TraceLength)
		 tracedata.filter   = self.Entity
				
		 local trace = util.TraceLine(tracedata)
	     
		 if trace.HitWorld then
		     ParticleEffect(self.Effect,pos,Angle(0,0,0),nil)
		 else 
			 ParticleEffect(self.EffectAir,pos,Angle(0,0,0),nil) 
		 end
     end
	 if self.IsNBC then
	     local nbc = ents.Create(self.NBCEntity)
		 nbc:SetVar("GBOWNER",self.GBOWNER)
		 nbc:SetPos(self:GetPos())
		 nbc:Spawn()
		 nbc:Activate()
	 end
     self:Remove()
end

function ENT:OnTakeDamage(dmginfo)
     if self.Exploded then return end
     self:TakePhysicsDamage(dmginfo)
	 
	 local phys = self:GetPhysicsObject()
	 
     if (self.Life <= 0) then return end
	 if(GetConVar("gb5_fragility"):GetInt() >= 1) then
	     if(not self.Armed and not self.Arming) then
	         self:Arm()
	     end
	 end
	 
     if(not self.Armed) then return end

	 if self:IsValid() then
	     self.Life = self.Life - dmginfo:GetDamage()
		 if (self.Life <= self.Life/2) and not self.Exploded and self.Flamable then
		     self:Ignite(self.MaxDelay,0)
		 end
		 if (self.Life <= 0) then 
		     timer.Simple(math.Rand(0,self.MaxDelay),function()
			     if not self:IsValid() then return end 
			     self.Exploded = true
			     self:Explode()
			 end)
	     end
	end
end

function ENT:PhysicsCollide( data, physobj )
     if(self.Exploded) then return end
     if(not self:IsValid()) then return end
	 if(self.Life <= 0) then return end
	 if(GetConVar("gb5_fragility"):GetInt() >= 1) then
	     if(data.Speed > self.ImpactSpeed) then
	 	     if(not self.Armed and not self.Arming) then
		         self:EmitSound(damagesound)
	             self:Arm()
	         end
		 end
	 end
	 if(not self.Armed) then return end
     if self.ShouldExplodeOnImpact then
	     if (data.Speed > self.ImpactSpeed ) then
			 self.Exploded = true
			 self:Explode()
		 end
	 end
end

function ENT:Arm()
     if(not self:IsValid()) then return end
	 if(self.Exploded) then return end
	 if(self.Armed) then return end
	 self.Arming = true
	 self.Used = true
	 timer.Simple(self.ArmDelay, function()
	     if not self:IsValid() then return end 
	     self.Armed = true
		 self.Arming = false
		 self:EmitSound(self.ArmSound)
		 if(self.Timed) then
	         timer.Simple(self.Timer, function()
	             if not self:IsValid() then return end 
				 timer.Simple(math.Rand(0,self.MaxDelay),function()
			         if not self:IsValid() then return end 
			         self.Exploded = true
			         self:Explode()
				 end)
	         end)
	     end
	 end)
end	 

function ENT:Use( activator, caller )
     if(self.Exploded) then return end
     if(self:IsValid()) then
	     if(GetConVar("gb5_easyuse"):GetInt() >= 1) then
	         if(not self.Armed) then
		         if(not self.Exploded) and (not self.Used) then
		             if(activator:IsPlayer()) then
                         self:EmitSound(self.ActivationSound)
                         self:Arm()
		             end
	             end
             end
         end
	 end
end

function ENT:OnRemove()
	 self:StopParticles()
	-- Wire_Remove(self)
end

if ( CLIENT ) then
     function ENT:Draw()
         self:DrawModel()
		 if not (WireAddon == nil) then Wire_Render(self.Entity) end
     end
end

function ENT:OnRestore()
     Wire_Restored(self.Entity)
end

function ENT:BuildDupeInfo()
     return WireLib.BuildDupeInfo(self.Entity)
end

function ENT:ApplyDupeInfo(ply, ent, info, GetEntByID)
     WireLib.ApplyDupeInfo( ply, ent, info, GetEntByID )
end

function ENT:PrentityCopy()
     local DupeInfo = self:BuildDupeInfo()
     if(DupeInfo) then
         duplicator.StorentityModifier(self,"WireDupeInfo",DupeInfo)
     end
end

function ENT:PostEntityPaste(Player,Ent,CreatedEntities)
     if(Ent.EntityMods and Ent.EntityMods.WireDupeInfo) then
         Ent:ApplyDupeInfo(Player, Ent, Ent.EntityMods.WireDupeInfo, function(id) return CreatedEntities[id] end)
     end
end

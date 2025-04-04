AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_advanced" )

ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "Endothermic Bomb"
ENT.Author			                 =  "Natsu"
ENT.Contact		                     =  ""
ENT.Category                         =  "GB5: Specials"

ENT.Model                            =  "models/thedoctor/en.mdl"                      
ENT.Effect                           =  ""                  
ENT.EffectAir                        =  ""                   
ENT.EffectWater                      =  "water_huge"
ENT.ExplosionSound                   =  "gbombs/fab/fab_explo.wav"
ENT.ArmSound                         =  "npc/roller/mine/rmine_blip3.wav"            
ENT.ActivationSound                  =  "buttons/button14.wav"     

ENT.ShouldUnweld                     =  true
ENT.ShouldIgnite                     =  false
ENT.ShouldExplodeOnImpact            =  true
ENT.Flamable                         =  false
ENT.UseRandomSounds                  =  false
ENT.Timed                            =  false

ENT.ExplosionDamage                  =  500
ENT.PhysForce                        =  2500
ENT.ExplosionRadius                  =  2000
ENT.SpecialRadius                    =  3000
ENT.MaxIgnitionTime                  =  0
ENT.Life                             =  25                                  
ENT.MaxDelay                         =  2                                 
ENT.TraceLength                      =  3000
ENT.ImpactSpeed                      =  700
ENT.Mass                             =  500
ENT.ArmDelay                         =  1   
ENT.Timer                            =  0

ENT.GBOWNER                          =  nil             -- don't you fucking touch this.

function ENT:Initialize()
 if (SERVER) then
     self:SetModel(self.Model)
	 self:PhysicsInit( SOLID_VPHYSICS )
	 self:SetSolid( SOLID_VPHYSICS )
	 self:SetMoveType( MOVETYPE_VPHYSICS )
	 self:SetUseType( ONOFF_USE ) -- doesen't fucking work
	 local phys = self:GetPhysicsObject()
	 if (phys:IsValid()) then
		 phys:SetMass(self.Mass)
		 phys:Wake()
     end 
	 if(self.Dumb) then
	     self.Armed    = true
	 else
	     self.Armed    = false
	 end
	 self.Exploded = false
	 self.Used     = false
	 self.Arming = false
	 self.Exploding = false
	 if not (WireAddon == nil) then self.Inputs   = Wire_CreateInputs(self, { "Arm", "Detonate" }) end
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
    ent:SetVar("SOUND", "gbombs_5/explosions/special/endothermic_bomb.mp3")
    self.affected = {}
    for k, v in pairs(ents.FindInSphere(pos, 1800)) do
        if v:IsPlayer() then
            table.insert(self.affected, v)
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
			ParticleEffect("beam_endothermic",pos,Angle(0,0,0),nil)	
			timer.Simple(0.1, function()
				if not self:IsValid() then return end 
					ParticleEffect("",trace.HitPos,Angle(0,0,0),nil)	
			end)	
		else 
			ParticleEffect("beam_endothermic",pos,Angle(0,0,0),nil) 

		end
	end
end
if SERVER then
	function ENT:OnRemove()
		if self.affected==nil then return end
		for k, v in pairs(self.affected) do	
			if v:IsValid() then
				v:ConCommand("coldno")
				v:Freeze(false)
			end
		end
	end
end
function ENT:SpawnFunction( ply, tr )
     if ( not tr.Hit ) then return end
	 self.GBOWNER = ply
     local ent = ents.Create( self.ClassName )
	 ent:SetPhysicsAttacker(ply)
     ent:SetPos( tr.HitPos + tr.HitNormal * 16 ) 
     ent:Spawn()
     ent:Activate()

     return ent
end
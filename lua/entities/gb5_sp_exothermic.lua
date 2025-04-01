AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_advanced" )

ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "Exothermic Bomb"
ENT.Author			                 =  "Natsu"
ENT.Contact		                     =  ""
ENT.Category                         =  "GB5: Specials"

ENT.Model                            =  "models/thedoctor/ex.mdl"                      
ENT.Effect                           =  "light_exothermic"                  
ENT.EffectAir                        =  "beam_exothermic"                   
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
    if SERVER then
        self:SetModel("models/thedoctor/ex.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetUseType(ONOFF_USE)
        local phys = self:GetPhysicsObject()
        if phys:IsValid() then
            phys:SetMass(500)
            phys:Wake()
        end
        self.Armed = false
        self.Exploded = false
    end
end

function ENT:Explode()
    if not self.Exploded then return end
    if self.Exploding then return end
	
	ParticleEffect("beam_exothermic",self:GetPos(),Angle(0,0,0),nil)

    local pos = self:GetPos()
    local owner = self.GBOWNER

    -- Create shockwave sound entity
    local soundEnt = ents.Create("gb5_shockwave_sound_lowsh")
    soundEnt:SetPos(pos)
    soundEnt:Spawn()
    soundEnt:Activate()
    soundEnt:SetPhysicsAttacker(owner)
    soundEnt:SetVar("GBOWNER", owner)
    soundEnt:SetVar("MAX_RANGE", 500000)
    soundEnt:SetVar("SHOCKWAVE_INCREMENT", 20000)
    soundEnt:SetVar("DELAY", 0.01)
    soundEnt:SetVar("Shocktime", 12)
    soundEnt:SetVar("SOUND", "gbombs_5/explosions/special/exothermic_bomb.mp3")

    -- Create shockwave fire entity
    local fireEnt = ents.Create("gb5_shockwave_fire")
    fireEnt:SetPos(pos)
    fireEnt:Spawn()
    fireEnt:Activate()
    fireEnt:SetVar("DEFAULT_PHYSFORCE", 25)
    fireEnt:SetVar("DEFAULT_PHYSFORCE_PLYAIR", 25)
    fireEnt:SetVar("DEFAULT_PHYSFORCE_PLYGROUND", 25)
    fireEnt:SetVar("GBOWNER", owner)
    fireEnt:SetVar("MAX_RANGE", 3500)
    fireEnt:SetVar("SHOCKWAVE_INCREMENT", 100)
    fireEnt:SetVar("DELAY", 0.1)

    self:Remove()
end

function ENT:SpawnFunction(ply, tr)
    if not tr.Hit then return end
    local ent = ents.Create(self.ClassName)
    ent.GBOWNER = ply
    ent:SetPos(tr.HitPos + tr.HitNormal * 16)
    ent:Spawn()
    ent:Activate()
    return ent
end


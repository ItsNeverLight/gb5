AddCSLuaFile()

DEFINE_BASECLASS("gb5_base_advanced")

ENT.Spawnable = true
ENT.AdminSpawnable = true

ENT.PrintName = "Supersonic Bomb"
ENT.Author = "Natsu"
ENT.Contact = ""
ENT.Category = "GB5: Specials"

ENT.Model = "models/thedoctor/supersonic.mdl"
ENT.Effect = ""
ENT.EffectAir = ""
ENT.EffectWater = "water_huge"
ENT.ExplosionSound = "gbombs/fab/fab_explo.wav"
ENT.ArmSound = "npc/roller/mine/rmine_blip3.wav"
ENT.ActivationSound = "buttons/button14.wav"

ENT.ShouldUnweld = true
ENT.ShouldIgnite = false
ENT.ShouldExplodeOnImpact = true
ENT.Flamable = false
ENT.UseRandomSounds = false
ENT.Timed = false

ENT.ExplosionDamage = 500
ENT.PhysForce = 2500
ENT.ExplosionRadius = 2000
ENT.SpecialRadius = 3000
ENT.MaxIgnitionTime = 0
ENT.Life = 25
ENT.MaxDelay = 2
ENT.TraceLength = 3000
ENT.ImpactSpeed = 700
ENT.Mass = 500
ENT.ArmDelay = 1
ENT.Timer = 0

ENT.GBOWNER = nil -- Don't modify this variable.

function ENT:Initialize()
    if SERVER then
        self:SetModel(self.Model)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetUseType(ONOFF_USE) -- Does not work
        local phys = self:GetPhysicsObject()
        if phys:IsValid() then
            phys:SetMass(self.Mass)
            phys:Wake()
        end
        if self.Dumb then
            self.Armed = true
        else
            self.Armed = false
        end
        self.Exploded = false
        self.Used = false
        self.Arming = false
        self.Exploding = false
        if WireAddon then
            self.Inputs = Wire_CreateInputs(self, { "Arm", "Detonate" })
        end
    end
end

function ENT:Explode()
    if not self.Exploded then return end
    if self.Exploding then return end

    self:SetMoveType(MOVETYPE_NONE)
    self:SetMaterial("phoenix_storms/glass")
    self:SetModel("models/hunter/plates/plate.mdl")

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
    ent:SetVar("Shocktime", 10)
    ent:SetVar("SOUND", "gbombs_5/explosions/special/supersonic.mp3")

    local ent = ents.Create("gb5_shockwave_ent_dir_vec")
    ent:SetPos(pos)
    ent:Spawn()
    ent:Activate()
    ent:SetVar("PropForce", 300)
    ent:SetVar("PlyForce", 500)
    ent:SetVar("PlyAirForce", 200)
    ent:SetVar("GBOWNER", self.GBOWNER)
    ent:SetVar("MAX_RANGE", 1200)
    ent:SetVar("Burst", 10)
    ent:SetVar("DELAY", 0.2)
    if self:WaterLevel() >= 1 then
        local trdata = {}
        local trlength = Vector(0, 0, 9000)

        trdata.start = pos
        trdata.endpos = trdata.start + trlength
        trdata.filter = self
        local tr = util.TraceLine(trdata)

        local trdat2 = {}
        trdat2.start = tr.HitPos
        trdat2.endpos = trdata.start - trlength
        trdat2.filter = self
        trdat2.mask = MASK_WATER + CONTENTS_TRANSLUCENT

        local tr2 = util.TraceLine(trdat2)

        if tr2.Hit then
            ParticleEffect(self.EffectWater, tr2.HitPos, Angle(0, 0, 0), nil)
        end
    else
        local tracedata = {}
        tracedata.start = pos
        tracedata.endpos = tracedata.start - Vector(0, 0, self.TraceLength)
        tracedata.filter = self.Entity

        local trace = util.TraceLine(tracedata)

        if trace.HitWorld then
            ParticleEffect("supersonic", pos, Angle(0, 0, 0), nil)
            timer.Simple(0.1, function()
                if not self:IsValid() then return end
                ParticleEffect("", trace.HitPos, Angle(0, 0, 0), nil)
            end)
        else
            ParticleEffect("supersonic", pos, Angle(0, 0, 0), nil)
        end
    end
    self:Remove()
end

function ENT:SpawnFunction(ply, tr)
    if not tr.Hit then return end
    local ent = ents.Create(self.ClassName)
    ent:SetPos(tr.HitPos + tr.HitNormal * 16)
    ent:Spawn()
    ent:Activate()
    ent:SetAngles(Angle(0, 0, 90))

    -- Set the GBOWNER variable to the player who spawned the entity
    ent.GBOWNER = ply

    -- Set the physics attacker to the player who spawned the entity
    ent:SetPhysicsAttacker(ply)

    return ent
end

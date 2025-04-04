AddCSLuaFile()

DEFINE_BASECLASS("gb5_base_advanced")

ENT.Spawnable = true
ENT.AdminSpawnable = true

ENT.PrintName = "Hypersonic Bomb"
ENT.Author = "Natsu"
ENT.Contact = ""
ENT.Category = "GB5: Specials"

ENT.Model = "models/thedoctor/hypersonic.mdl"
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

ENT.GBOWNER = nil -- Don't modify this line.

function ENT:Initialize()
    if SERVER then
        self:SetModel(self.Model)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetUseType(ONOFF_USE)

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
            self.Inputs = Wire_CreateInputs(self, {"Arm", "Detonate"})
        end
    end
end

function ENT:Explode()
    if not self.Exploded then
        return
    end
    if self.Exploding then
        return
    end

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
    ent:SetVar("GBOWNER", self.GBOWNER or self:GetOwner())
    ent:SetVar("MAX_RANGE", 500000)
    ent:SetVar("SHOCKWAVE_INCREMENT", 20000)
    ent:SetVar("DELAY", 0.01)
    ent:SetVar("Shocktime", 10)
    ent:SetVar("SOUND", "gbombs_5/explosions/special/hypersonic.mp3")

    local ent2 = ents.Create("gb5_shockwave_ent_dir_vec")
    ent2:SetPos(pos)
    ent2:Spawn()
    ent2:Activate()
    ent2:SetVar("PropForce", 600)
    ent2:SetVar("PlyForce", 800)
    ent2:SetVar("PlyAirForce", 300)
    ent2:SetVar("GBOWNER", self.GBOWNER or self:GetOwner())
    ent2:SetVar("MAX_RANGE", 2400)
    ent2:SetVar("Burst", 10)
    ent2:SetVar("DELAY", 0.2)

    if self:WaterLevel() >= 1 then
        local trdata = {}
        trdata.start = pos
        trdata.endpos = trdata.start + Vector(0, 0, 9000)
        trdata.filter = self
        local tr = util.TraceLine(trdata)

        local trdat2 = {}
        trdat2.start = tr.HitPos
        trdat2.endpos = trdata.start - Vector(0, 0, 9000)
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
            ParticleEffect("", trace.HitPos, Angle(0, 0, 0), nil)
            timer.Simple(0.1, function()
                if not self:IsValid() then
                    return
                end
                ParticleEffect("", trace.HitPos, Angle(0, 0, 0), nil)
            end)
        else
            ParticleEffect("hypersonic", pos, Angle(0, 0, 0), nil)
        end
    end

    self:Remove()
end

function ENT:SpawnFunction(ply, tr)
    if not tr.Hit then
        return
    end
    local ent = ents.Create(self.ClassName)
    ent:SetPos(tr.HitPos + tr.HitNormal * 16)
    ent:Spawn()
    ent:Activate()
    ent:SetAngles(Angle(0, 0, 90))
    ent.GBOWNER = ply -- Assign the GBOWNER variable to the owner of the entity

    return ent
end

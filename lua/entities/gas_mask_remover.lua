AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.PrintName		= "Gas Mask Remover"
ENT.Author		= ""
ENT.Information		= ""
ENT.Category		= "GB5: Protection"

ENT.Editable		= false
ENT.Spawnable		= true
ENT.AdminOnly		= true
ENT.Contact			                 =  ""  

function GasMask()
	local tex = surface.GetTextureID("hud/mask_overlay")
	surface.SetTexture(tex)
	surface.SetDrawColor( 255, 255, 255, 255 );
	surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
end

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	local ent = ents.Create( "gas_mask_remover" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent
end

if SERVER then
	function ENT:Initialize()
		self.Entity:SetModel("models/Items/item_item_crate.mdl")
		self.Entity:PhysicsInit( SOLID_VPHYSICS )
		self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
		self.Entity:SetSolid( SOLID_VPHYSICS )
		local phys = self.Entity:GetPhysicsObject()
		if (phys:IsValid()) then	
			phys:Wake()
		end	
	end
end

if SERVER then
	function ENT:Use( activator, caller )
		if activator.gasmasked==true then	
			activator:EmitSound("gbombs_5/protection_used.wav",50,190)
			activator.gasmasked=true
			net.Start( "gbombs5_net" )        
				net.WriteBit( false )
				activator:StopSound("breathing")				
			net.Send(activator)
			activator.gasmasked=false
			
			self:Remove()
		end
	end
end

if CLIENT then
	function ENT:OnRemove()
		net.Receive( "gbombs5_net", function( len )
		
			local mask_on = net.ReadBit()
			if mask_on==1 then
				hook.Add( "RenderScreenspaceEffects", "GasMask", GasMask)
			else
				hook.Remove("RenderScreenspaceEffects", "GasMask", GasMask)
			end
		end)
    end
end
		



if CLIENT then
	function ENT:Draw()
		self.Entity:DrawModel()

		local squad = self:GetNetworkedString( 12 )
		if ( LocalPlayer():GetEyeTrace().Entity == self.Entity && EyePos():Distance( self.Entity:GetPos() ) < 256 ) then
		AddWorldTip( self.Entity:EntIndex(), ( "Gas Mask Remover" ), 0.5, self.Entity:GetPos(), self.Entity  )
		end
	end

	language.Add( 'Gas Mask Remover', 'Gas Mask Remover' )
end


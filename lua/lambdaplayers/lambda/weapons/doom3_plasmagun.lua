local cvars_Number = cvars.Number
local EffectData = EffectData
local CurTime = CurTime
local util_Effect = util.Effect
local util_Decal = util.Decal
local ents_Create = ents.Create
local IsValid = IsValid

-- Why
local function OnPlasmaCollide( self, data, physObj )
	local dmg = cvars_Number( "doom3_sk_plasmagun_damage" )
	data.HitEntity:TakeDamage( dmg, self:GetOwner(), self )

	util_Decal( "dark", ( data.HitPos + data.HitNormal ), ( data.HitPos - data.HitNormal ) )
    self:Explode()
end

table.Merge( _LAMBDAPLAYERSWEAPONS, {
    doom3_plasmagun = {
        model = "models/weapons/doom3/w_plasmagun.mdl",
        origin = "DOOM 3",
        prettyname = "Plasmagun",
        holdtype = "ar2",
        killicon = "weapon_doom3_plasmagun",
        bonemerge = true,
        keepdistance = 400,
        attackrange = 1500,
        islethal = true,
        dropentity = "weapon_doom3_plasmagun",
        deploydelay = 0.5,
        deploysound = "weapons/doom3/plasmagun/plasma_use_01.wav",

        OnDeploy = function( self, wepent )
            local clipSize = cvars_Number( "doom3_sk_plasmagun_ammocapacity" )
            self.l_Clip = clipSize
            self.l_MaxClip = clipSize
        end,

        clip = 30,
        OnAttack = function( self, wepent, target )
            if self.l_Clip <= 0 then self:ReloadWeapon() return true end
            self.l_WeaponUseCooldown = ( CurTime() + 0.12 )

            self:RemoveGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2 )
            self:AddGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2 )

            wepent:EmitSound( "weapons/doom3/plasmagun/2plasma_fire" .. LambdaRNG( 3 ) .. ".wav", 100 )
        
            local shootPos = wepent:GetPos()
            local targetPos = ( target:WorldSpaceCenter() + target:GetVelocity() * LambdaRNG( 0.33, 0.66, true ) )
            
            local shootAng = ( targetPos - shootPos ):Angle()
            shootAng:RotateAroundAxis( shootAng:Up(), LambdaRNG( -2, 2 ) )
            shootAng:RotateAroundAxis( shootAng:Right(), LambdaRNG( -2, 2 ) )
            shootPos = ( shootPos + shootAng:Forward() * 14 )
            
            local entPlasma = ents_Create( "doom3_plasma" )
            entPlasma:SetAngles( shootAng )
            entPlasma:SetPos( shootPos )
            entPlasma:SetOwner( self )
            entPlasma:Spawn()
            entPlasma:Activate()

            entPlasma.l_UseLambdaDmgModifier = true
            entPlasma.l_killiconname = "weapon_doom3_plasmagun"
            entPlasma.PhysicsCollide = OnPlasmaCollide

            local phys = entPlasma:GetPhysicsObject()
            if IsValid( phys ) then phys:SetVelocity( shootAng:Forward() * 700 ) end

            if IsFirstTimePredicted() then
                local muzzleFx = EffectData()
                muzzleFx:SetEntity( wepent )
                muzzleFx:SetOrigin( shootPos )
                muzzleFx:SetAttachment( 1 )
                util_Effect( "doom3_plasma_muzzle", muzzleFx )
            end

            self.l_Clip = ( self.l_Clip - 1 )
            return true
        end,

        reloadtime = 2.36,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_AR2,
        reloadsounds = "weapons/doom3/plasmagun/plasma_reload_01.wav"
    }
} )
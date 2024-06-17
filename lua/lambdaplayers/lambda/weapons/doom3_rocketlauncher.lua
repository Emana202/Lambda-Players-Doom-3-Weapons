local EffectData = EffectData
local CurTime = CurTime
local util_Effect = util.Effect
local ents_Create = ents.Create
local IsValid = IsValid

table.Merge( _LAMBDAPLAYERSWEAPONS, {
    doom3_rocketlauncher = {
        model = "models/weapons/doom3/w_rocketlauncher.mdl",
        origin = "DOOM 3",
        prettyname = "Rocket Launcher",
        holdtype = "rpg",
        killicon = "weapon_doom3_rocketlauncher",
        bonemerge = true,
        keepdistance = 550,
        attackrange = 1750,
        islethal = true,
        dropentity = "weapon_doom3_rocketlauncher",
        deploydelay = 0.5,
        deploysound = "weapons/doom3/rocket/raise.wav",

        clip = 5,
        OnAttack = function( self, wepent, target )
            if self.l_Clip <= 0 then self:ReloadWeapon() return true end
            self.l_WeaponUseCooldown = ( CurTime() + 1 )

            self:RemoveGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_RPG )
            self:AddGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_RPG )

            wepent:EmitSound( "weapons/doom3/rocket/rocket_launcher_blast_" .. LambdaRNG( 4 ) .. ".wav", 100 )
        
            local shootPos = wepent:GetPos()
            local targetPos = target:GetPos()
            
            local predPos = ( targetPos + target:GetVelocity() * LambdaRNG( 0.2, 0.4, true ) )
            if shootPos:DistToSqr( predPos ) > shootPos:DistToSqr( targetPos ) then targetPos = predPos end

            local shootAng = ( targetPos - shootPos ):Angle()
            shootAng:RotateAroundAxis( shootAng:Up(), LambdaRNG( -2, 2 ) )
            shootAng:RotateAroundAxis( shootAng:Right(), LambdaRNG( -3, 3 ) )
            shootPos = ( shootPos + shootAng:Forward() * 16 )

            local entRocket = ents_Create( "doom3_rocket" )
            entRocket:SetAngles( shootAng )
            entRocket:SetPos( shootPos )
            entRocket:SetOwner( self )
            entRocket:Spawn()
            entRocket:Activate()

            entRocket.l_UseLambdaDmgModifier = true

            local phys = entRocket:GetPhysicsObject()
            if IsValid( phys ) then phys:SetVelocity( shootAng:Forward() * 900 ) end

            if IsFirstTimePredicted() then
                local muzzleFx = EffectData()
                muzzleFx:SetEntity( wepent )
                muzzleFx:SetOrigin( shootPos )
                muzzleFx:SetAttachment( 1 )
                util_Effect( "doom3_muzzlelight", muzzleFx )

                local smokeFx = EffectData()
                smokeFx:SetEntity( wepent )
                smokeFx:SetOrigin( shootPos + shootAng:Forward() * 30 + shootAng:Right() * 6 + shootAng:Up() * 0 )
                smokeFx:SetNormal( shootAng:Forward() )
                smokeFx:SetAttachment( 1 )
                smokeFx:SetScale( 20 )
                util_Effect( "doom3_smoke", smokeFx )
            end

            self.l_Clip = ( self.l_Clip - 1 )
            return true
        end,

        reloadtime = 1.96,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_AR2,
        reloadsounds = "weapons/doom3/rocket/rocket_launcher_reload.wav"
    }
} )
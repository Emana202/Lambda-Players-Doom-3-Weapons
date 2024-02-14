local EffectData = EffectData
local CurTime = CurTime
local util_Effect = util.Effect
local ents_Create = ents.Create
local IsValid = IsValid
local min = math.min
local floor = math.floor
local Round = math.Round
local FrameTime = FrameTime
local ScreenShake = util.ScreenShake
local BlastDamage = util.BlastDamage

table.Merge( _LAMBDAPLAYERSWEAPONS, {
    doom3_bfg = {
        model = "models/weapons/doom3/w_bfg.mdl",
        origin = "DOOM 3",
        prettyname = "BFG9K",
        holdtype = "physgun",
        killicon = "weapon_doom3_bfg",
        bonemerge = true,
        keepdistance = 600,
        attackrange = 2000,
        islethal = true,
        dropentity = "weapon_doom3_bfg",
        deploydelay = 0.5,
        deploysound = "weapons/doom3/bfg/bfg_raise.wav",

        OnDeploy = function( self, wepent )
            local idleSnd = CreateSound( wepent, "weapons/doom3/bfg/bfg_idle.wav" )
            if idleSnd then idleSnd:PlayEx( 0.5, 100 ) end
            wepent.IdleSnd = idleSnd
        end,
        
        OnHolster = function( self, wepent )
            if wepent.IdleSnd then
                wepent.IdleSnd:Stop()
                wepent.IdleSnd = nil
            end
            if wepent.ChargeSnd then
                wepent.ChargeSnd:Stop()
                wepent.ChargeSnd = nil
            end
        end,

        clip = 4,
        OnAttack = function( self, wepent, target )
            if self.l_Clip <= 0 then self:ReloadWeapon() return true end
            self.l_WeaponUseCooldown = ( CurTime() + 3 )

            local chargeSnd = CreateSound( wepent, "weapons/doom3/bfg/bfg_firebegin.wav" )
            if chargeSnd then
                chargeSnd:SetSoundLevel( 90 )
                chargeSnd:Play()
            end
            
            wepent.ChargeSnd = chargeSnd
            ScreenShake( wepent:GetPos(), ( FrameTime() * 100 ), 255, 1.5, 64 )

            local chargeTime = LambdaRNG( 0.05, 2.5, true )
            self:SimpleWeaponTimer( chargeTime, function()
                if wepent.ChargeSnd then
                    wepent.ChargeSnd:Stop()
                    wepent.ChargeSnd = nil
                end

                self:RemoveGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_CROSSBOW )
                self:AddGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_CROSSBOW )

                local shootPos = wepent:GetPos()
                if Round( chargeTime, 1 ) >= 2.5 then
                    local effectData = EffectData()
                    effectData:SetOrigin( shootPos )
                    util_Effect( "HelicopterMegaBomb", effectData )

                    wepent:EmitSound( "weapons/doom3/bfg/bfg_explode" .. LambdaRNG( 4 ) .. ".wav", 100, 100 )
                    BlastDamage( wepent, self, shootPos, 500, 500 )
                    
                    self.l_WeaponUseCooldown = ( CurTime() + LambdaRNG( 2, 3, true ) )
                    self.l_Clip = 0
                    return
                end

                local power = min( 4 * ( chargeTime / 2 ), 4 )
                local dmgPower = ( floor( power ) + 1 )
                if dmgPower > self.l_Clip then dmgPower = self.l_Clip end
            
                self.l_Clip = ( self.l_Clip - dmgPower )
                self.l_WeaponUseCooldown = ( CurTime() + LambdaRNG( 1, 3, true ) )
                wepent:EmitSound( "weapons/doom3/bfg/bfg_fire.wav" )

                local shootAng = ( IsValid( target ) and ( ( target:GetPos() + target:GetVelocity() * 0.2 ) - shootPos ):Angle() or self:EyeAngles() )
                if IsFirstTimePredicted() then
                    local effectData = EffectData()
                    effectData:SetOrigin( shootPos + shootAng:Forward() * 50 + shootAng:Right() * 8 + shootAng:Up() * -10 )
                    util_Effect( "doom3_bfg_muzzle", effectData )
                end

                shootPos = ( shootPos + shootAng:Right() * 5 + shootAng:Up() * -5 )
                shootAng = ( IsValid( target ) and ( ( target:GetPos() + target:GetVelocity() * 0.2 ) - shootPos ):Angle() or self:EyeAngles() )

                local ent = ents_Create( "doom3_bfg" )
                ent:SetPos( shootPos )
                ent:SetAngles( shootAng )
                ent:SetOwner( self )
                ent:SetDamage( 200 * dmgPower, 200 * dmgPower)
                ent:Spawn()
                ent:Activate()

                ent.l_UseLambdaDmgModifier = true
                ScreenShake( shootPos, ( FrameTime() * 100 ), 255, 1.5, 64 )

                local phys = ent:GetPhysicsObject()
                if IsValid(phys) then phys:SetVelocity( shootAng:Forward() * 350 ) end
            end )

            return true
        end,

        reloadtime = 2.36,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_SHOTGUN,
        reloadsounds = "weapons/doom3/bfg/bfg_reload.wav"
    }
} )
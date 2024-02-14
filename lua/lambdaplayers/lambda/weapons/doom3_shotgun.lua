local cvars_Number = cvars.Number
local EffectData = EffectData
local CurTime = CurTime
local util_Effect = util.Effect
local coroutine_wait = coroutine.wait
local min = math.min

local bulletTbl = {
    Num = 13,
    Tracer = 3,
    Force = 4,
    Spread = Vector( 0.1, 0.1, 0 )
}

table.Merge( _LAMBDAPLAYERSWEAPONS, {
    doom3_shotgun = {
        model = "models/weapons/doom3/w_shotgun.mdl",
        origin = "DOOM 3",
        prettyname = "Shotgun",
        holdtype = "shotgun",
        killicon = "weapon_doom3_shotgun",
        bonemerge = true,
        keepdistance = 300,
        attackrange = 750,
        islethal = true,
        dropentity = "weapon_doom3_shotgun",
        deploydelay = 0.5,
        deploysound = "weapons/doom3/shotgun/shotgun_use_01.wav",

        clip = 8,
        OnAttack = function( self, wepent, target )
            if self.l_Clip <= 0 then self:ReloadWeapon() return true end
            self.l_WeaponUseCooldown = ( CurTime() + 1.33 )

            self:RemoveGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_SHOTGUN )
            self:AddGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_SHOTGUN )

            wepent:EmitSound( "weapons/doom3/shotgun/fire/sgfire_0" .. LambdaRNG( 3 ) .. ".wav", 100 )

            local shootPos = wepent:GetPos()
            local shootAng = ( target:WorldSpaceCenter() - shootPos ):Angle()
            bulletTbl.Src = shootPos
            bulletTbl.Dir = shootAng:Forward()
         
            bulletTbl.Attacker = self
            bulletTbl.IgnoreEntity = self
            bulletTbl.Damage = cvars_Number( "doom3_sk_shotgun_damage" )
            wepent:FireBullets( bulletTbl )

            if IsFirstTimePredicted() then
                local muzzleFx = EffectData()
                muzzleFx:SetEntity( wepent )
                muzzleFx:SetOrigin( shootPos )
                muzzleFx:SetAttachment( 1 )
                util_Effect( "doom3_muzzlelight", muzzleFx )

                local smokeFx = EffectData()
                smokeFx:SetEntity( wepent )
                smokeFx:SetOrigin( shootPos + shootAng:Forward() * 30 + shootAng:Right() * 6 + shootAng:Up() * -18 )
                smokeFx:SetNormal( shootAng:Forward() )
                smokeFx:SetAttachment( 1 )
                smokeFx:SetScale( 20 )
                util_Effect( "doom3_smoke", smokeFx )
            end

            self:SimpleWeaponTimer( 0.5, function()
                wepent:EmitSound( "weapons/doom3/shotgun/shotgun_cock_01.wav" )

                local shellAng = ( self:GetAngles() + Angle( 0, 90, 0 ) )        
                local shellFx = EffectData()
                shellFx:SetOrigin( wepent:WorldSpaceCenter() + shellAng:Right() * 8 + shellAng:Up() * 3 )
                shellFx:SetAngles( shellAng )
                shellFx:SetEntity( wepent )
                util_Effect( "ShotgunShellEject", shellFx )
            end )

            self.l_Clip = ( self.l_Clip - 1 )
            return true
        end,

        OnReload = function( self, wepent )
            self:SetIsReloading( true )
            
            self:Thread( function()
                coroutine_wait( 0.35 )
                wepent:EmitSound( "weapons/doom3/shotgun/reload/sgreload_start_0" .. LambdaRNG( 3 ) .. ".wav" )

                local interrupted = false
                while ( self.l_Clip < self.l_MaxClip ) do
                    local ene = self:GetEnemy()
                    if self.l_Clip > 0 and LambdaRNG( 3 ) == 1 and self:InCombat() and self:IsInRange( ene, 350 ) and self:CanSee( ene ) then 
                        interrupted = true
                        break 
                    end

                    wepent:EmitSound( "weapons/doom3/shotgun/reload/sgreload_addshell_0" .. LambdaRNG( 4 ) .. ".wav" )
                    coroutine_wait( 0.65 )
                    self.l_Clip = min( self.l_Clip + 2, self.l_MaxClip )
                end

                if interrupted then
                    self:SimpleWeaponTimer( 0.4, function()
                        wepent:EmitSound( "weapons/doom3/shotgun/shotgun_cock_01.wav" )
                    end )
                end

                self:SetIsReloading( false )
            end, "Doom3_ShotgunReload" )

            return true
        end
    }
} )
local cvars_Number = cvars.Number
local EffectData = EffectData
local CurTime = CurTime
local util_Effect = util.Effect

local bulletTbl = {
    Num = 1,
    Tracer = 3,
    Force = 4,
    Spread = Vector( 0.125, 0.125, 0 )
}

table.Merge( _LAMBDAPLAYERSWEAPONS, {
    doom3_machinegun = {
        model = "models/weapons/doom3/w_machinegun.mdl",
        origin = "DOOM 3",
        prettyname = "Machinegun",
        holdtype = "smg",
        killicon = "weapon_doom3_machinegun",
        bonemerge = true,
        keepdistance = 400,
        attackrange = 1000,
        islethal = true,
        dropentity = "weapon_doom3_machinegun",
        deploydelay = 0.5,
        deploysound = "weapons/doom3/machinegun/mg_use_01.wav",

        clip = 60,
        OnAttack = function( self, wepent, target )
            if self.l_Clip <= 0 then self:ReloadWeapon() return true end
            self.l_WeaponUseCooldown = ( CurTime() + 0.1 )

            self:RemoveGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_SMG1 )
            self:AddGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_SMG1 )

            wepent:EmitSound( "weapons/doom3/machinegun/mg_mech_0" .. LambdaRNG( 3 ) .. ".wav", 75 )
            wepent:EmitSound( "weapons/doom3/machinegun/fire/machgun_shot_" .. LambdaRNG( 5 ) .. ".wav", 100 )

            local shootPos = wepent:GetPos()
            local shootAng = ( target:WorldSpaceCenter() - shootPos ):Angle()
            bulletTbl.Src = shootPos
            bulletTbl.Dir = shootAng:Forward()
         
            bulletTbl.Attacker = self
            bulletTbl.IgnoreEntity = self
            bulletTbl.Damage = cvars_Number( "doom3_sk_machinegun_damage" )
            wepent:FireBullets( bulletTbl )

            if IsFirstTimePredicted() then
                local muzzleFx = EffectData()
                muzzleFx:SetEntity( wepent )
                muzzleFx:SetOrigin( shootPos )
                muzzleFx:SetAttachment( 1 )
                util_Effect( "doom3_muzzlelight", muzzleFx )

                local smokeFx = EffectData()
                smokeFx:SetEntity( wepent )
                smokeFx:SetOrigin( shootPos + shootAng:Forward() * 30 + shootAng:Right() * 6 + shootAng:Up() * -12 )
                smokeFx:SetNormal( shootAng:Forward() )
                smokeFx:SetAttachment( 1 )
                smokeFx:SetScale( 1 )
                util_Effect( "doom3_smoke", smokeFx )
            end

            if self.l_Clip == 10 then wepent:EmitSound( "weapons/doom3/machinegun/lowammo3.wav" ) end
            self.l_Clip = ( self.l_Clip - 1 )

            return true
        end,

        reloadtime = 2.36,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_SMG1,
        reloadsounds = "weapons/doom3/machinegun/mg_reload_01.wav"
    }
} )
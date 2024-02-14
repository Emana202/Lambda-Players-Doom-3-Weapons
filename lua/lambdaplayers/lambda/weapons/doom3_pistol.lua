local cvars_Number = cvars.Number
local EffectData = EffectData
local CurTime = CurTime
local util_Effect = util.Effect

local bulletTbl = {
    Num = 1,
    Tracer = 3,
    Force = 4,
    Spread = Vector( 0.08, 0.08, 0 )
}

table.Merge( _LAMBDAPLAYERSWEAPONS, {
    doom3_pistol = {
        model = "models/weapons/doom3/w_pistol.mdl",
        origin = "DOOM 3",
        prettyname = "Pistol",
        holdtype = "pistol",
        killicon = "weapon_doom3_pistol",
        bonemerge = true,
        keepdistance = 400,
        attackrange = 1250,
        islethal = true,
        dropentity = "weapon_doom3_pistol",
        deploydelay = 0.5,
        deploysound = "weapons/doom3/pistol/pistol_use_01.wav",

        clip = 12,
        OnAttack = function( self, wepent, target )
            if self.l_Clip <= 0 then self:ReloadWeapon() return true end
            self.l_WeaponUseCooldown = ( CurTime() + 0.4 )

            self:RemoveGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL )
            self:AddGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL )

            wepent:EmitSound( "weapons/doom3/pistol/fire/pfire_0" .. LambdaRNG( 3 ) .. ".wav", 100 )

            local shootPos = wepent:GetPos()
            local shootAng = ( target:WorldSpaceCenter() - shootPos ):Angle()
            bulletTbl.Src = shootPos
            bulletTbl.Dir = shootAng:Forward()
         
            bulletTbl.Attacker = self
            bulletTbl.IgnoreEntity = self
            bulletTbl.Damage = cvars_Number( "doom3_sk_pistol_damage" )
            wepent:FireBullets( bulletTbl )

            if IsFirstTimePredicted() then
                local muzzleFx = EffectData()
                muzzleFx:SetEntity( wepent )
                muzzleFx:SetOrigin( shootPos )
                muzzleFx:SetAttachment( 1 )
                util_Effect( "doom3_muzzlelight", muzzleFx )

                local smokeFx = EffectData()
                smokeFx:SetEntity( wepent )
                smokeFx:SetOrigin( shootPos + shootAng:Forward() * 30 + shootAng:Right() * 6 + shootAng:Up() * -7 )
                smokeFx:SetNormal( shootAng:Forward() )
                smokeFx:SetAttachment( 1 )
                smokeFx:SetScale( 4 )
                util_Effect( "doom3_smoke", smokeFx )
            end

            self.l_Clip = ( self.l_Clip - 1 )
            return true
        end,

        reloadtime = 2.08,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_PISTOL,
        reloadsounds = "weapons/doom3/pistol/pistol_reload_01.wav"
    }
} )
local EffectData = EffectData
local CurTime = CurTime
local util_Effect = util.Effect
local coroutine_wait = coroutine.wait
local min = math.min

local bulletTbl = {
    Num = 18,
    Tracer = 3,
    Force = 4,
    Spread = Vector( 0.18, 0.18, 0 ),
    Damage = 16
}

table.Merge( _LAMBDAPLAYERSWEAPONS, {
    doom3_doublebarrel = {
        model = "models/weapons/doom3/w_dshotgun.mdl",
        origin = "DOOM 3",
        prettyname = "Super Shotgun",
        holdtype = "shotgun",
        killicon = "weapon_doom3_doublebarrel",
        bonemerge = true,
        keepdistance = 200,
        attackrange = 300,
        islethal = true,
        dropentity = "weapon_doom3_doublebarrel",
        deploydelay = 0.5,
        deploysound = "weapons/doom3/shotgun/shotgun_use_01.wav",

        clip = 2,
        OnAttack = function( self, wepent, target )
            if self.l_Clip <= 0 then self:ReloadWeapon() return true end
            self.l_WeaponUseCooldown = ( CurTime() + 0.4 )

            self:RemoveGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_SHOTGUN )
            self:AddGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_SHOTGUN )
            self:AddGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_SHOTGUN )

            wepent:EmitSound( "weapons/doom3/ssg/fire_04.wav", 100 )
            wepent:EmitSound( "weapons/doom3/ssg/fire_04.wav", 100 )

            local shootPos = wepent:GetPos()
            local shootAng = ( target:WorldSpaceCenter() - shootPos ):Angle()
            bulletTbl.Src = shootPos
            bulletTbl.Dir = shootAng:Forward()
         
            bulletTbl.Attacker = self
            bulletTbl.IgnoreEntity = self
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

            self.l_Clip = ( self.l_Clip - 2 )
            return true
        end,

        reloadtime = 2.05,
        reloadsounds = { 
            { 0.36, "weapons/doom3/ssg/click_01.wav" },
            { 1.08, "weapons/doom3/ssg/insert_01.wav" },
            { 1.32, "weapons/doom3/ssg/insert_02.wav" },
            { 1.9, "weapons/doom3/ssg/clack_01.wav" }
        },

        OnReload = function( self, wepent )
            local animID = self:LookupSequence( "reload_shotgun_base_layer" )
            if animID != -1 then 
                self:AddGestureSequence( animID ) 
            else 
                self:AddGesture( ACT_HL2MP_GESTURE_RELOAD_SHOTGUN )
            end
        end
    }
} )
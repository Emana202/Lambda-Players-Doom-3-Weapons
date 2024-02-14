local cvars_Number = cvars.Number
local EffectData = EffectData
local CurTime = CurTime
local util_Effect = util.Effect

local bulletTbl = {
    Num = 1,
    Tracer = 3,
    Force = 4,
    Spread = Vector( 0.15, 0.15, 0 )
}

table.Merge( _LAMBDAPLAYERSWEAPONS, {
    doom3_chaingun = {
        model = "models/weapons/doom3/w_chaingun.mdl",
        origin = "DOOM 3",
        prettyname = "Chaingun",
        holdtype = "crossbow",
        killicon = "weapon_doom3_chaingun",
        bonemerge = true,
        keepdistance = 400,
        attackrange = 1250,
        islethal = true,
        dropentity = "weapon_doom3_chaingun",
        deploydelay = 0.5,
        deploysound = "weapons/doom3/chaingun/cg_use_01.wav",

        OnDeploy = function( self, wepent )
            wepent.AttackDelay = false
            wepent.LoopSound = CreateSound( wepent, "weapons/doom3/chaingun/cg_motor_loop_01.wav" )
        end,

        OnHolster = function( self, wepent )
            if wepent.AttackDelay then
                wepent:EmitSound( "weapons/doom3/chaingun/cg_winddown_mix_01.wav", 75, 100, 1, CHAN_ITEM )
            end
            wepent.AttackDelay = nil

            if wepent.LoopSound then
                wepent.LoopSound:Stop()
                wepent.LoopSound = nil
            end
        end,

        OnThink = function( self, wepent, isDead )
            if wepent.AttackDelay and ( isDead or self:GetIsReloading() or CurTime() >= wepent.AttackDelay and CurTime() >= self.l_WeaponUseCooldown + 0.33 ) then
                wepent:EmitSound( "weapons/doom3/chaingun/cg_winddown_mix_01.wav", 75, 100, 1, CHAN_ITEM )
                wepent.AttackDelay = false

                if wepent.LoopSound then
                    wepent.LoopSound:Stop()
                end
            end
        end,

        clip = 60,
        OnAttack = function( self, wepent, target )
            if self.l_Clip <= 0 then self:ReloadWeapon() return true end
            if !wepent.AttackDelay then
                wepent:EmitSound( "weapons/doom3/chaingun/cg_windup_mix_01.wav", 75, 100, 1, CHAN_ITEM )
                wepent.AttackDelay = ( CurTime() + 0.5 )

                if wepent.LoopSound then
                    wepent.LoopSound:Play()
                end
            end
            if CurTime() < wepent.AttackDelay then
                return true 
            end

            self:RemoveGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_CROSSBOW )
            self:AddGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_CROSSBOW )
            
            self.l_WeaponUseCooldown = ( CurTime() + 0.09 )
            wepent:EmitSound( "weapons/doom3/chaingun/chaingun_shot_" .. LambdaRNG( 4 ) .. ".wav", 100 )

            local shootPos = wepent:GetPos()
            local shootAng = ( target:WorldSpaceCenter() - shootPos ):Angle()
            bulletTbl.Src = shootPos
            bulletTbl.Dir = shootAng:Forward()
         
            bulletTbl.Attacker = self
            bulletTbl.IgnoreEntity = self
            bulletTbl.Damage = cvars_Number( "doom3_sk_chaingun_damage" )
            wepent:FireBullets( bulletTbl )

            if IsFirstTimePredicted() then
                local muzzleFx = EffectData()
                muzzleFx:SetEntity( wepent )
                muzzleFx:SetOrigin( shootPos )
                muzzleFx:SetAttachment( 1 )
                util_Effect( "doom3_muzzlelight", muzzleFx )

                local smokeFx = EffectData()
                smokeFx:SetEntity( wepent )
                smokeFx:SetOrigin( shootPos + shootAng:Forward() * 42 + shootAng:Right() * 6 + shootAng:Up() * -51 )
                smokeFx:SetNormal( shootAng:Forward() )
                smokeFx:SetAttachment( 1 )
                smokeFx:SetScale( 5 )
                util_Effect( "doom3_smoke", smokeFx )
            end

            self.l_Clip = ( self.l_Clip - 1 )
            if self.l_Clip == 10 then wepent:EmitSound( "weapons/doom3/machinegun/lowammo3.wav" ) end

            return true
        end,

        reloadtime = 1.96,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_AR2,
        reloadsounds = "weapons/doom3/chaingun/cg_reload_twist_01.wav"
    }
} )
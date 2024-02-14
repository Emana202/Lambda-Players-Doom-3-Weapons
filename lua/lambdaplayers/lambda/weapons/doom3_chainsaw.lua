local CurTime = CurTime
local EffectData = EffectData
local util_Effect = util.Effect
local IsFirstTimePredicted = IsFirstTimePredicted
local CreateSound = CreateSound
local TraceLine = util.TraceLine
local trTbl = { mask = MASK_SHOT_PORTAL }
local bulletTbl = {
    Num = 1,
	Spread = vector_origin,
	Tracer = 0,
	Force = 5,
	Damage = 50
}

table.Merge( _LAMBDAPLAYERSWEAPONS, {
    doom3_chainsaw = {
        model = "models/weapons/doom3/w_chainsaw.mdl",
        origin = "DOOM 3",
        prettyname = "Chainsaw",
        holdtype = "shotgun",
        killicon = "weapon_doom3_chainsaw",
        ismelee = true,
        islethal = true,
        bonemerge = true,
        keepdistance = 32,
        attackrange = 80,
        dropentity = "weapon_doom3_chainsaw",
        deploydelay = 1,
        deploysound = {
            { 0, "weapons/doom3/chainsaw/pull.wav" },
            { 0, "weapons/doom3/chainsaw/pull_zip.wav" }
        },
        holstersound = "weapons/doom3/chainsaw/put_away.wav",

        OnDeploy = function( self, wepent )
            wepent.ChainStopT = 0
            wepent.ChainHitSnd = 0
            wepent.ChainIdlePlayT = ( CurTime() + 0.5 )
        end,

        OnHolster = function( self, wepent )
            if wepent.ChainAttackSnd then
                wepent.ChainAttackSnd:Stop()
                wepent.ChainAttackSnd = nil
            end
            if wepent.ChainIdleSnd then
                wepent.ChainIdleSnd:Stop()
                wepent.ChainIdleSnd = nil
            end
        end,

        OnThink = function( self, wepent, isDead )
            if wepent.ChainsawDmgDelay and ( isDead or CurTime() >= wepent.ChainStopT ) then
                wepent.ChainsawDmgDelay = nil
                self.l_WeaponUseCooldown = ( CurTime() + 0.8 )

                wepent.ChainIdlePlayT = ( CurTime() + 1 )
                if wepent.ChainAttackSnd then wepent.ChainAttackSnd:Stop() end

                wepent:EmitSound( "weapons/doom3/chainsaw/stop_attack.wav", 100 )
            end

            if !isDead and wepent.ChainIdlePlayT and CurTime() > wepent.ChainIdlePlayT then
                wepent.ChainIdlePlayT = nil

                local idleSnd = wepent.ChainIdleSnd
                if !idleSnd then
                    idleSnd = CreateSound( wepent, "weapons/doom3/chainsaw/idle.wav" )
                    if idleSnd then
                        idleSnd:SetSoundLevel( 90 )
                        idleSnd:PlayEx( 0.75, 100 )
                    end
                    wepent.ChainIdleSnd = idleSnd
                else
                    if IsFirstTimePredicted() and idleSnd:IsPlaying() then
                        idleSnd:Stop()
                    end
                    idleSnd:PlayEx( 0.75, 100 )
                end
            end
        end,

        OnAttack = function( self, wepent, target )
            self:RemoveGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_SHOTGUN )
            self:AddGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_SHOTGUN ) 

            trTbl.start = self:EyePos()
            trTbl.filter = self
            
            local aimDir = ( target:WorldSpaceCenter() - trTbl.start ):GetNormalized()
            trTbl.endpos = ( trTbl.start + aimDir * 75 )

            local trace = TraceLine( trTbl )
            if trace.Hit then
                bulletTbl.Src = trTbl.start
                bulletTbl.Dir = aimDir
                bulletTbl.Attacker = self
                bulletTbl.IgnoreEntity = self

                wepent:FireBullets( bulletTbl )
            end

            if !wepent.ChainsawDmgDelay then
                wepent:EmitSound( "weapons/doom3/chainsaw/start_attack.wav", 100 )

                wepent.ChainsawDmgDelay = ( CurTime() + 0.3 )
                self.l_WeaponUseCooldown = wepent.ChainsawDmgDelay
            elseif CurTime() >= wepent.ChainsawDmgDelay then
                self.l_WeaponUseCooldown = ( CurTime() + 0.1 )
                if wepent.ChainIdleSnd then wepent.ChainIdleSnd:Stop() end

                local loopSnd = wepent.ChainAttackSnd
                if !loopSnd then
                    loopSnd = CreateSound( wepent, "weapons/doom3/chainsaw/attack.wav" )
                    if loopSnd then
                        loopSnd:SetSoundLevel( 100 )
                        loopSnd:PlayEx( 0.75, 100 )
                    end
                    wepent.ChainAttackSnd = loopSnd
                elseif !loopSnd:IsPlaying() then
                    loopSnd:PlayEx( 0.75, 100 )
                end

                if trace.Hit then
                    local hitEnt = trace.Entity
                    if hitEnt:IsPlayer() or hitEnt:IsNPC() then
                        wepent:EmitSound( "weapons/doom3/chainsaw/hit_0" .. LambdaRNG( 0, 9 ) .. ".wav", 100 )
                    end
                    if trace.HitWorld then
                        if CurTime() >= wepent.ChainHitSnd then
                            wepent:EmitSound( "weapons/doom3/chainsaw/hit_metal_0" .. LambdaRNG( 4 ) .. ".wav", 100, 100, 1, CHAN_ITEM )
                            wepent.ChainHitSnd = ( CurTime() + 0.2 )
                        end
                        if IsFirstTimePredicted() then
                            local effectData = EffectData()
                            effectData:SetOrigin( trace.HitPos )
                            util_Effect( "cball_explode", effectData )
                        end
                    end
                end
            end

            wepent.ChainStopT = self.l_WeaponUseCooldown
            return true
        end
    }
} )
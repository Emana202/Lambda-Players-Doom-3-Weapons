local IsValid = IsValid
local CurTime = CurTime
local DamageInfo = DamageInfo
local TraceLine = util.TraceLine
local TraceHull = util.TraceHull
local trTbl = {
    mins = Vector( -6, -6, -4 ),
    maxs = Vector( 6, 6, 4 ),
    mask = MASK_SHOT_HULL
}

table.Merge( _LAMBDAPLAYERSWEAPONS, {
    doom3_fists = {
        model = "",
        origin = "DOOM 3",
        prettyname = "Fists",
        holdtype = "fist",
        killicon = "weapon_doom3_fists",
        ismelee = true,
        nodraw = true,
        islethal = true,
        keepdistance = 32,
        attackrange = 70,
        dropondeath = false,
        deploydelay = 0.5,
        deploysound = "weapons/doom3/fists/raise_fists_01.wav",

        OnAttack = function( self, wepent, target )
            self.l_WeaponUseCooldown = ( CurTime() + 0.6 )

            self:RemoveGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST )
            self:AddGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST ) 

            self:SimpleWeaponTimer( 0.1, function()
                trTbl.start = self:EyePos()
                trTbl.filter = self

                local aimDir = ( IsValid( target ) and ( target:WorldSpaceCenter() - trTbl.start ):GetNormalized() or self:GetAimVector() )
                trTbl.endpos = ( trTbl.start + aimDir * 60 )

                local trace = TraceLine( trTbl )
                if !IsValid( trace.Entity ) then trace = TraceHull( trTbl ) end
    
                if !trace.Hit then
                    wepent:EmitSound( "weapons/doom3/fists/punch/whoosh_0" .. LambdaRNG( 4 ) .. ".wav" )
                    return
                end
                wepent:EmitSound( "weapons/doom3/fists/default_punch_0" .. LambdaRNG( 4 ) .. ".wav" )
                    
                local hitEnt = trace.Entity
                if IsValid( hitEnt ) and ( hitEnt:IsNPC() or hitEnt:IsPlayer() or hitEnt:Health() > 0 ) then
                    local dmginfo = DamageInfo()
                    dmginfo:SetDamage( 20 )
                    dmginfo:SetDamageForce( self:GetUp() * 4000 + self:GetForward() * 10000 )
                    dmginfo:SetInflictor( wepent )
                    dmginfo:SetAttacker( self )
                    hitEnt:TakeDamageInfo( dmginfo )
                end
            end )

            return true
        end
    }
} )
local IsValid = IsValid
local CurTime = CurTime
local DamageInfo = DamageInfo
local TraceLine = util.TraceLine
local TraceHull = util.TraceHull
local trTbl = {
    mins = Vector( -4, -4, -2 ),
    maxs = Vector( 4, 4, 2 ),
    mask = MASK_SHOT_HULL
}

if ( CLIENT ) then
    hook.Add( "LambdaOnThink", "LambdaDoom3_FlashlightPermaOn", function( self, wepent, isDead )
        if isDead or self:GetWeaponName() != "doom3_flashlight" then return end
        local delay = wepent:GetNW2Float( "doom3_flashlightdelay", 0 )
        self.l_flashlighton = ( CurTime() >= delay )
        self.l_lightupdate = ( CurTime() + 0.1 )
    end )
end

table.Merge( _LAMBDAPLAYERSWEAPONS, {
    doom3_flashlight = {
        model = "models/weapons/doom3/w_flashlight.mdl",
        origin = "DOOM 3",
        prettyname = "Flashlight",
        holdtype = "slam",
        killicon = "weapon_doom3_flashlight",
        ismelee = true,
        islethal = true,
        bonemerge = true,
        keepdistance = 32,
        attackrange = 70,
        dropentity = "weapon_doom3_flashlight",
        deploydelay = 0.5,
        deploysound = "weapons/doom3/fists/raise_fists_01.wav",

        OnAttack = function( self, wepent, target )
            self.l_WeaponUseCooldown = ( CurTime() + 1 )
            wepent:SetNW2Float( "doom3_flashlightdelay", ( CurTime() + 0.6 ) )

            self:RemoveGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE )
            self:AddGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE ) 

            self:SimpleWeaponTimer( 0.1, function()
                trTbl.start = self:EyePos()
                trTbl.filter = self

                local aimDir = ( IsValid( target ) and ( target:WorldSpaceCenter() - trTbl.start ):GetNormalized() or self:GetAimVector() )
                trTbl.endpos = ( trTbl.start + aimDir * 67 )

                local trace = TraceLine( trTbl )
                if !IsValid( trace.Entity ) then trace = TraceHull( trTbl ) end
    
                if !trace.Hit then
                    wepent:EmitSound( "weapons/doom3/fists/punch/whoosh_0" .. LambdaRNG( 4 ) .. ".wav" )
                    return
                end

                local hitEnt = trace.Entity
                if hitEnt:IsNPC() or hitEnt:IsPlayer() then
                    wepent:EmitSound( "weapons/doom3/flashlight/impact_0" .. LambdaRNG( 5 ) .. ".wav" )
                elseif trace.HitWorld or trace.HitNonWorld then 
                    wepent:EmitSound( "weapons/doom3/flashlight/wrench_impact" .. LambdaRNG( 2 ) .. ".wav" )
                end

                if IsValid( hitEnt ) and ( hitEnt:IsNPC() or hitEnt:IsPlayer() or hitEnt:Health() > 0 ) then
                    local dmginfo = DamageInfo()
                    dmginfo:SetDamage( 40 )
                    dmginfo:SetDamageForce( self:GetUp() * 2000 + self:GetForward() * 12000 )
                    dmginfo:SetInflictor( wepent )
                    dmginfo:SetAttacker( self )
                    hitEnt:TakeDamageInfo( dmginfo )
                end
            end )

            return true
        end
    }
} )
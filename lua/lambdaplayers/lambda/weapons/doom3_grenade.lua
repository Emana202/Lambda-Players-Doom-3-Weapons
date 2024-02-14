local Clamp = math.Clamp
local CurTime = CurTime
local IsValid = IsValid
local ents_Create = ents.Create
local CreateSound = CreateSound
local angOffset = Angle( 0, 90, 0 )

table.Merge( _LAMBDAPLAYERSWEAPONS, {
    doom3_grenade = {
        model = "models/projectiles/doom3/grenade.mdl",
        origin = "DOOM 3",
        prettyname = "Grenade",
        holdtype = "grenade",
        killicon = "weapon_doom3_grenade",
        bonemerge = true,
        keepdistance = 600,
        attackrange = 1500,
        islethal = true,
        dropentity = "weapon_doom3_grenade",
        deploydelay = 0.5,
        deploysound = "weapons/doom3/grenades/gren_use.wav",

        clip = -1,
        OnAttack = function( self, wepent, target )
            local targetPos = ( target:WorldSpaceCenter() + target:GetVelocity() * 0.75 )
            local startTime = CurTime()
            
            local throwTime = ( Clamp( 5 * ( self:GetRangeTo( target ) / 400 ), 5, 25 ) / 10 )
            self.l_WeaponUseCooldown = ( CurTime() + 2.5 + throwTime )
            
            local chargeSnd = CreateSound( wepent, "weapons/doom3/grenades/gren_throw_mix.wav" )
            if chargeSnd then chargeSnd:Play() end

            self:SimpleWeaponTimer( throwTime, function()
                if chargeSnd then chargeSnd:FadeOut( 1 ) end

                self:RemoveGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_GRENADE )
                self:AddGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_GRENADE )
                
                if IsValid( target ) then
                    targetPos = ( target:WorldSpaceCenter() + target:GetVelocity() * 0.75 )
                end
                local shootPos = wepent:GetPos()
                local shootAng = ( targetPos - shootPos ):Angle()
    
                local entGrenade = ents_Create( "doom3_grenade" )
                entGrenade:SetPos( shootPos )
                entGrenade:SetAngles( shootAng + angOffset )
                entGrenade:SetOwner( self )
                entGrenade:SetExplodeDelay( 3.5 - ( CurTime() - ( startTime - 0.8 ) ) )
                entGrenade:Spawn()
                entGrenade:Activate()

                entGrenade.l_UseLambdaDmgModifier = true
                entGrenade.entOwner = self

                local phys = entGrenade:GetPhysicsObject()
                if IsValid( phys ) then
                    local vel = ( shootAng:Forward() * ( 160 * ( CurTime() - ( startTime - 2 ) ) ) + shootAng:Up() * 40 )
                    phys:SetVelocity( vel )
                end
            end )

            return true
        end
    }
} )
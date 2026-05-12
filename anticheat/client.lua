function Flag(reason)
    TriggerServerEvent('usrp:flag', reason)
end

CreateThread(function()
    while true do
        Wait(2000)

        local ped = PlayerPedId()

        -- GODMODE
        if GetPlayerInvincible(PlayerId()) then
            Flag("Godmode")
        end

        -- HEALTH
        if GetEntityHealth(ped) > Config.MaxHealth then
            Flag("Health Hack")
        end

        -- ARMOR
        if GetPedArmour(ped) > Config.MaxArmor then
            Flag("Armor Hack")
        end

        -- INVISIBLE
        if not IsEntityVisible(ped) then
            Flag("Invisible")
        end

        -- SPEEDHACK
        local speed = GetEntitySpeed(ped)

        if not IsPedInAnyVehicle(ped, false) then
            if speed > Config.MaxFootSpeed then
                Flag("Speedhack")
            end
        end

        -- SUPERJUMP
        if IsPedJumping(ped) and GetEntityHeightAboveGround(ped) > 5.0 then
            Flag("Super Jump")
        end

        -- BLACKLISTED WEAPONS
        for _,weapon in pairs(Config.BlacklistedWeapons) do
            if HasPedGotWeapon(ped, GetHashKey(weapon), false) then
                RemoveWeaponFromPed(ped, GetHashKey(weapon))
                Flag("Blacklisted Weapon: "..weapon)
            end
        end

        -- VEHICLE CHECK
        if IsPedInAnyVehicle(ped, false) then

            local veh = GetVehiclePedIsIn(ped, false)
            local model = GetDisplayNameFromVehicleModel(GetEntityModel(veh))

            local vehSpeed = GetEntitySpeed(veh) * 3.6

            if vehSpeed > Config.MaxVehicleSpeed then
                Flag("Vehicle Speedhack")
            end

            for _,blacklisted in pairs(Config.BlacklistedVehicles) do
                if model == blacklisted then
                    DeleteEntity(veh)
                    Flag("Blacklisted Vehicle: "..model)
                end
            end
        end
    end
end)

-- EXPLOSION LOGGING
AddEventHandler('explosionEvent', function(sender, ev)

    for _,v in pairs(Config.BlacklistedExplosions) do
        if ev.explosionType == v then
            CancelEvent()
            Flag("Explosion Spawn")
        end
    end
end)

-- CHAT LOGGING
AddEventHandler('chatMessage', function(author, color, text)
    TriggerServerEvent('usrp:chatlog', text)
end)

-- DEATH LOGGING
CreateThread(function()
    local wasDead = false

    while true do
        Wait(1000)

        local ped = PlayerPedId()

        if IsEntityDead(ped) and not wasDead then
            wasDead = true

            local killer = GetPedSourceOfDeath(ped)

            TriggerServerEvent('usrp:deathlog', killer)
        end

        if not IsEntityDead(ped) then
            wasDead = false
        end
    end
end)
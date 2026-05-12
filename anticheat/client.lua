CreateThread(function()
    while true do
        Wait(5000)

        local ped = PlayerPedId()

        -- Speed hack check
        if IsPedInAnyVehicle(ped, false) then
            local veh = GetVehiclePedIsIn(ped, false)
            local speed = GetEntitySpeed(veh) * 3.6

            if speed > 450.0 then
                TriggerServerEvent("anticheat:trigger", "kick", "Speed hack detected")
            end
        end

        -- Godmode check (simple)
        if GetEntityHealth(ped) > 200 then
            TriggerServerEvent("anticheat:trigger", "kick", "Godmode detected")
        end
    end
end)
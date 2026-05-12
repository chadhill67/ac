function SendWebhook(title, desc, color)

    if Config.Webhook == "" then
        return
    end

    local embed = {
        {
            ["title"] = title,
            ["description"] = desc,
            ["color"] = color,
            ["footer"] = {
                ["text"] = os.date("%Y-%m-%d %H:%M:%S")
            }
        }
    }

    PerformHttpRequest(Config.Webhook, function(err, text, headers) end, 'POST', json.encode({
        username = "USRP ANTICHEAT",
        embeds = embed
    }), {
        ['Content-Type'] = 'application/json'
    })
end

function GetIdentifiers(src)

    local identifiers = {
        steam = "N/A",
        license = "N/A",
        discord = "N/A",
        ip = "N/A"
    }

    for _,id in pairs(GetPlayerIdentifiers(src)) do

        if string.find(id, "steam") then
            identifiers.steam = id
        end

        if string.find(id, "license") then
            identifiers.license = id
        end

        if string.find(id, "discord") then
            identifiers.discord = id
        end

        if string.find(id, "ip") then
            identifiers.ip = id
        end
    end

    return identifiers
end

RegisterServerEvent('usrp:flag')
AddEventHandler('usrp:flag', function(reason)

    local src = source
    local name = GetPlayerName(src)
    local ids = GetIdentifiers(src)

    local message = [[
**Player:** ]]..name..[[

**Reason:** ]]..reason..[[

**Steam:** ]]..ids.steam..[[

**License:** ]]..ids.license..[[

**Discord:** ]]..ids.discord..[[

**IP:** ]]..ids.ip

    SendWebhook(
        "CHEATER DETECTED",
        message,
        16711680
    )

    DropPlayer(src, "Cheating Detected")
end)

-- PLAYER JOIN
AddEventHandler('playerConnecting', function(name)

    local src = source
    local ids = GetIdentifiers(src)

    SendWebhook(
        "PLAYER CONNECTING",

        "**Player:** "..name..
        "\n**License:** "..ids.license,

        65280
    )
end)

-- PLAYER LEAVE
AddEventHandler('playerDropped', function(reason)

    local src = source
    local name = GetPlayerName(src)

    SendWebhook(
        "PLAYER LEFT",

        "**Player:** "..name..
        "\n**Reason:** "..reason,

        16753920
    )
end)

-- CHAT LOGS
RegisterServerEvent('usrp:chatlog')
AddEventHandler('usrp:chatlog', function(msg)

    local src = source
    local name = GetPlayerName(src)

    SendWebhook(
        "CHAT MESSAGE",

        "**Player:** "..name..
        "\n**Message:** "..msg,

        65535
    )
end)

-- DEATH LOGS
RegisterServerEvent('usrp:deathlog')
AddEventHandler('usrp:deathlog', function(killer)

    local src = source

    SendWebhook(
        "PLAYER DEATH",

        "**Victim:** "..GetPlayerName(src),

        16711935
    )
end)

-- ENTITY PROTECTION
AddEventHandler('entityCreating', function(entity)

    local owner = NetworkGetEntityOwner(entity)

    if owner == 0 then
        CancelEvent()
        return
    end

    local entityType = GetEntityType(entity)

    if entityType == 1 then

        local model = GetEntityModel(entity)

        for _,ped in pairs(Config.BlacklistedPeds) do

            if model == GetHashKey(ped) then

                CancelEvent()

                DropPlayer(owner, "Blacklisted Ped Spawn")
            end
        end
    end
end)

-- RESOURCE LOGGING
AddEventHandler('onResourceStart', function(resource)

    SendWebhook(
        "RESOURCE STARTED",

        "**Resource:** "..resource,

        3066993
    )
end)

AddEventHandler('onResourceStop', function(resource)

    SendWebhook(
        "RESOURCE STOPPED",

        "**Resource:** "..resource,

        15158332
    )
end)
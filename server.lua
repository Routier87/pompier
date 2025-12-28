ESX = exports["es_extended"]:getSharedObject()
local calls = {}

-- Annonces
RegisterServerEvent('pompier:annonce')
AddEventHandler('pompier:annonce', function(message)
    TriggerClientEvent('chat:addMessage', -1, {
        color = {255, 0, 0},
        multiline = true,
        args = {"Pompiers Normandie", message}
    })
end)

-- Gestion appels
RegisterServerEvent('pompier:newCall')
AddEventHandler('pompier:newCall', function(reason, coords)
    table.insert(calls, {
        reason = reason,
        coords = coords
    })
    TriggerClientEvent('pompier:updateCalls', -1, calls)
end)

RegisterServerEvent('pompier:acceptCall')
AddEventHandler('pompier:acceptCall', function(id)
    if calls[id] then
        table.remove(calls, id)
        TriggerClientEvent('pompier:updateCalls', -1, calls)
    end
end)

RegisterServerEvent('pompier:refuseCall')
AddEventHandler('pompier:refuseCall', function(id)
    if calls[id] then
        table.remove(calls, id)
        TriggerClientEvent('pompier:updateCalls', -1, calls)
    end
end)

RegisterServerEvent('pompier:transferToSAMU')
AddEventHandler('pompier:transferToSAMU', function(id)
    if calls[id] then
        table.remove(calls, id)
        TriggerClientEvent('pompier:updateCalls', -1, calls)
    end
end)

-- Premiers secours
RegisterServerEvent('pompier:firstAid')
AddEventHandler('pompier:firstAid', function(target)
    TriggerClientEvent('pompier:healSmall', target)
end)

-- Réanimation
RegisterServerEvent('pompier:reanimate')
AddEventHandler('pompier:reanimate', function(target)
    TriggerClientEvent('pompier:revive', target)
end)

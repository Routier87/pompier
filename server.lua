ESX = exports["es_extended"]:getSharedObject()
local calls = {}

-- Annonces en bas à gauche
RegisterServerEvent('pompier:annonce')
AddEventHandler('pompier:annonce', function(message)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer.job.name == 'pompier' then
        TriggerClientEvent('pompier:showAdvancedNotification', -1, 
            '🚒 POMPIERS NORMANDIE', 
            'Annonce Officielle', 
            message, 
            'CHAR_CALL911', 
            1
        )
        
        -- Log dans la console
        print(('^5[POMPIERS]^0 %s (%s) a envoyé une annonce: %s'):format(
            xPlayer.getName(), xPlayer.job.grade_label, message
        ))
    end
end)

-- Gestion des appels
RegisterServerEvent('pompier:newCall')
AddEventHandler('pompier:newCall', function(reason, coords)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerName = xPlayer.getName()
    
    table.insert(calls, {
        reason = reason,
        coords = coords,
        caller = playerName,
        time = os.date('%H:%M:%S')
    })
    
    TriggerClientEvent('pompier:updateCalls', -1, calls)
    
    -- Notification aux pompiers
    local pompiers = ESX.GetPlayers()
    for i=1, #pompiers do
        local xTarget = ESX.GetPlayerFromId(pompiers[i])
        if xTarget.job.name == 'pompier' then
            TriggerClientEvent('pompier:showAdvancedNotification', pompiers[i],
                '📞 NOUVEL APPEL',
                'Urgence signalée',
                reason .. '\nPar: ' .. playerName,
                'CHAR_CALL911',
                1
            )
        end
    end
end)

RegisterServerEvent('pompier:acceptCall')
AddEventHandler('pompier:acceptCall', function(id)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if calls[id] then
        local call = calls[id]
        table.remove(calls, id)
        TriggerClientEvent('pompier:updateCalls', -1, calls)
        
        TriggerClientEvent('pompier:showAdvancedNotification', -1,
            '🚒 INTERVENTION',
            'Appel accepté',
            call.reason .. '\nPompier: ' .. xPlayer.getName(),
            'CHAR_CALL911',
            1
        )
        
        -- Log
        print(('^5[POMPIERS]^0 %s a accepté l\'appel: %s'):format(
            xPlayer.getName(), call.reason
        ))
    end
end)

RegisterServerEvent('pompier:refuseCall')
AddEventHandler('pompier:refuseCall', function(id)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if calls[id] then
        local call = calls[id]
        table.remove(calls, id)
        TriggerClientEvent('pompier:updateCalls', -1, calls)
        
        TriggerClientEvent('pompier:showAdvancedNotification', -1,
            '🚒 POMPIERS',
            'Appel refusé',
            call.reason,
            'CHAR_CALL911',
            1
        )
        
        print(('^5[POMPIERS]^0 %s a refusé l\'appel: %s'):format(
            xPlayer.getName(), call.reason
        ))
    end
end)

RegisterServerEvent('pompier:transferToSAMU')
AddEventHandler('pompier:transferToSAMU', function(id)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if calls[id] then
        local call = calls[id]
        table.remove(calls, id)
        TriggerClientEvent('pompier:updateCalls', -1, calls)
        
        TriggerClientEvent('pompier:showAdvancedNotification', -1,
            '🚒 ➡️ 🚑',
            'Transfert SAMU',
            call.reason .. '\nTransféré par: ' .. xPlayer.getName(),
            'CHAR_CALL911',
            1
        )
        
        print(('^5[POMPIERS]^0 %s a transféré l\'appel au SAMU: %s'):format(
            xPlayer.getName(), call.reason
        ))
    end
end)

-- Premiers secours (ALT)
RegisterServerEvent('pompier:firstAid')
AddEventHandler('pompier:firstAid', function(target)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(target)
    
    if xPlayer.job.name == 'pompier' and xTarget then
        TriggerClientEvent('pompier:healSmall', target)
        
        TriggerClientEvent('pompier:showAdvancedNotification', source,
            '💉 PREMIERS SECOURS',
            'Soins administrés',
            'Vous avez soigné: ' .. xTarget.getName(),
            'CHAR_CALL911',
            1
        )
    end
end)

-- Réanimation (ALT + R)
RegisterServerEvent('pompier:reanimate')
AddEventHandler('pompier:reanimate', function(target)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(target)
    
    if xPlayer.job.name == 'pompier' and xTarget then
        TriggerClientEvent('pompier:revive', target)
        
        TriggerClientEvent('pompier:showAdvancedNotification', source,
            '🧑‍⚕️ RÉANIMATION',
            'Réussie',
            'Vous avez réanimé: ' .. xTarget.getName(),
            'CHAR_CALL911',
            1
        )
    end
end)

-- Gestion Boss (Grades 10-11)

-- Promouvoir un pompier
RegisterServerEvent('pompier:promote')
AddEventHandler('pompier:promote', function(targetId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(targetId)
    
    if xPlayer.job.name == 'pompier' and xPlayer.job.grade >= 10 then
        if xTarget and xTarget.job.name == 'pompier' then
            local newGrade = xTarget.job.grade + 1
            
            if newGrade <= 11 then
                xTarget.setJob('pompier', newGrade)
                
                TriggerClientEvent('pompier:showAdvancedNotification', source,
                    '🎖️ PROMOTION',
                    'Succès',
                    'Vous avez promu: ' .. xTarget.getName() .. '\nNouveau grade: ' .. xTarget.job.grade_label,
                    'CHAR_CALL911',
                    1
                )
                
                TriggerClientEvent('pompier:showAdvancedNotification', targetId,
                    '🎖️ FÉLICITATIONS',
                    'Promotion',
                    'Vous avez été promu par ' .. xPlayer.getName() .. '\nNouveau grade: ' .. xTarget.job.grade_label,
                    'CHAR_CALL911',
                    1
                )
            else
                TriggerClientEvent('esx:showNotification', source, '❌ Grade maximum atteint')
            end
        else
            TriggerClientEvent('esx:showNotification', source, '❌ Joueur non trouvé ou n\'est pas pompier')
        end
    else
        TriggerClientEvent('esx:showNotification', source, '❌ Vous n\'avez pas les permissions')
    end
end)

-- Rétrograder un pompier
RegisterServerEvent('pompier:demote')
AddEventHandler('pompier:demote', function(targetId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(targetId)
    
    if xPlayer.job.name == 'pompier' and xPlayer.job.grade >= 10 then
        if xTarget and xTarget.job.name == 'pompier' then
            local newGrade = xTarget.job.grade - 1
            
            if newGrade >= 0 then
                xTarget.setJob('pompier', newGrade)
                
                TriggerClientEvent('pompier:showAdvancedNotification', source,
                    '📉 RÉTROGRADATION',
                    'Effectuée',
                    'Vous avez rétrogradé: ' .. xTarget.getName() .. '\nNouveau grade: ' .. xTarget.job.grade_label,
                    'CHAR_CALL911',
                    1
                )
                
                TriggerClientEvent('pompier:showAdvancedNotification', targetId,
                    '📉 AVERTISSEMENT',
                    'Rétrogradation',
                    'Vous avez été rétrogradé par ' .. xPlayer.getName() .. '\nNouveau grade: ' .. xTarget.job.grade_label,
                    'CHAR_CALL911',
                    1
                )
            else
                TriggerClientEvent('esx:showNotification', source, '❌ Grade minimum atteint')
            end
        else
            TriggerClientEvent('esx:showNotification', source, '❌ Joueur non trouvé ou n\'est pas pompier')
        end
    else
        TriggerClientEvent('esx:showNotification', source, '❌ Vous n\'avez pas les permissions')
    end
end)

-- Licencier un pompier
RegisterServerEvent('pompier:fire')
AddEventHandler('pompier:fire', function(targetId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(targetId)
    
    if xPlayer.job.name == 'pompier' and xPlayer.job.grade >= 10 then
        if xTarget and xTarget.job.name == 'pompier' then
            xTarget.setJob('unemployed', 0)
            
            TriggerClientEvent('pompier:showAdvancedNotification', source,
                '🚫 LICENCIEMENT',
                'Effectué',
                'Vous avez licencié: ' .. xTarget.getName(),
                'CHAR_CALL911',
                1
            )
            
            TriggerClientEvent('pompier:showAdvancedNotification', targetId,
                '🚫 LICENCIEMENT',
                'Vous avez été licencié',
                'Par: ' .. xPlayer.getName(),
                'CHAR_CALL911',
                1
            )
            
            print(('^5[POMPIERS]^0 %s a licencié %s'):format(
                xPlayer.getName(), xTarget.getName()
            ))
        else
            TriggerClientEvent('esx:showNotification', source, '❌ Joueur non trouvé ou n\'est pas pompier')
        end
    else
        TriggerClientEvent('esx:showNotification', source, '❌ Vous n\'avez pas les permissions')
    end
end)

-- Récupérer les appels pour les nouveaux joueurs
ESX.RegisterServerCallback('pompier:getCalls', function(source, cb)
    cb(calls)
end)

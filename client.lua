local ESX = exports["es_extended"]:getSharedObject()
RegisterNetEvent('dps_tone:playTone')
AddEventHandler('dps_tone:playTone', function(coords, location, message)
    PlaySoundFrontend(-1, "TIMER_STOP", "HUD_MINI_GAME_SOUNDSET", 1)
    Wait(800)
    PlaySoundFrontend(-1, "TIMER_STOP", "HUD_MINI_GAME_SOUNDSET", 1)
    Wait(800)
    PlaySoundFrontend(-1, "TIMER_STOP", "HUD_MINI_GAME_SOUNDSET", 1)
    SetNewWaypoint(coords.x, coords.y)
    ESX.ShowAdvancedNotification(
        'DISPATCH', 
        'FIRE TONE OUT', 
        'Responding to: ' .. location .. message, 
        'CHAR_CALL911', 
        1
    )
end)

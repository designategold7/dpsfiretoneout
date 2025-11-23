local ESX = exports["es_extended"]:getSharedObject()

RegisterNetEvent('dps_tone:playTone')
AddEventHandler('dps_tone:playTone', function(coords, location)
    -- Play Pager Tone (Native GTA Sound)
    -- Repeat 3 times for effect
    PlaySoundFrontend(-1, "TIMER_STOP", "HUD_MINI_GAME_SOUNDSET", 1)
    Wait(800)
    PlaySoundFrontend(-1, "TIMER_STOP", "HUD_MINI_GAME_SOUNDSET", 1)
    Wait(800)
    PlaySoundFrontend(-1, "TIMER_STOP", "HUD_MINI_GAME_SOUNDSET", 1)
    
    -- Set GPS Waypoint
    SetNewWaypoint(coords.x, coords.y)

    -- Visual Alert
    ESX.ShowAdvancedNotification(
        'DISPATCH', 
        'FIRE TONE OUT', 
        'Responding to: ' .. location, 
        'CHAR_CALL911', 
        1
    )
end)

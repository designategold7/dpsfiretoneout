local ESX = exports["es_extended"]:getSharedObject()

-- ================= CONFIGURATION =================
local SENDER_JOB = 'dps' -- The ESX job name 
local AFD_JOBS = { 
    ['ambulance'] = true, 
    ['fire'] = true,
    ['afd'] = true 
}

local COOLDOWN_TIME = 30 -- Seconds per user
local cooldowns = {} 

-- Sonoran CAD Credentials
local SONORAN_COMM_ID = "CHANGE_ME"
local SONORAN_API_KEY = "CHANGE_ME"
local SERVER_PORT = GetConvar("sv_port", "30120")
-- =================================================

-- Wrapper for Knight Duty export
local function IsClockedIn(targetSource)
    local status, result = pcall(function()
        return exports['knight_duty']:isOnDuty(targetSource)
    end)
    if status then return result else return false end
end

RegisterCommand('tonefd', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    -- Verify Sender Authorization (Job + Duty Status)
    if xPlayer.job.name == SENDER_JOB then
        if not IsClockedIn(source) then
            xPlayer.showNotification("~r~Access Denied:~s~ You must be clocked in (~b~/duty DPS~s~).")
            return
        end

        -- Cooldown Logic
        local currentTime = os.time()
        if cooldowns[source] and (currentTime - cooldowns[source] < COOLDOWN_TIME) then
            local timeRemaining = COOLDOWN_TIME - (currentTime - cooldowns[source])
            xPlayer.showNotification("~o~Tone Cooldown Active: ~s~Wait " .. timeRemaining .. "s.")
            return
        end
        cooldowns[source] = currentTime

        -- Execution
        local coords = xPlayer.getCoords(true)
        local streetName = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
        local locationInfo = GetStreetNameFromHashKey(streetName)
        local afdCount = 0
        local xPlayers = ESX.GetPlayers()

        -- Loop through players to find valid AFD recipients
        for i=1, #xPlayers, 1 do
            local xTarget = ESX.GetPlayerFromId(xPlayers[i])
            if xTarget and AFD_JOBS[xTarget.job.name] and IsClockedIn(xPlayers[i]) then
                afdCount = afdCount + 1
                TriggerClientEvent('dps_tone:playTone', xPlayers[i], coords, locationInfo)
            end
        end

        if afdCount > 0 then
            xPlayer.showNotification("~r~[Dispatch]~s~ AFD Toned Out. ("..afdCount.." units notified)")
        else
            xPlayer.showNotification("~y~[Dispatch]~s~ Tone sent to CAD. No active AFD units on duty.")
        end

        -- Sonoran CAD API Integration
        local callData = {
            ["id"] = SONORAN_COMM_ID,
            ["key"] = SONORAN_API_KEY,
            ["type"] = "NEW_DISPATCH",
            ["data"] = {
                {
                    ["serverId"] = SERVER_PORT,
                    ["isEmergency"] = true,
                    ["origin"] = "Radio",
                    ["status"] = "PENDING",
                    ["priority"] = 1,
                    ["address"] = locationInfo,
                    ["title"] = "AFD TONE OUT",
                    ["code"] = "FIRE-1", 
                    ["description"] = "DPS requesting immediate Fire/EMS assistance.",
                    ["units"] = {} 
                }
            }
        }

        PerformHttpRequest("https://api.sonorancad.com/emergency/new_dispatch", function(err, text, headers)
            if err ~= 200 then
                print("[SonoranCAD] API Error: " .. tostring(err)) 
            end
        end, 'POST', json.encode(callData), { ['Content-Type'] = 'application/json' })

    else
        -- UPDATED MESSAGE HERE
        xPlayer.showNotification("~r~Access Denied:~s~ DPS Only.")
    end
end)

local ESX = exports["es_extended"]:getSharedObject()
-- CONFIGURATION
local SENDER_JOB = 'police'
local AFD_JOBS = { ['ambulance'] = true }
local COOLDOWN_TIME = 30
local cooldowns = {}
-- SONORAN CAD SETUP
local SONORAN_COMM_ID = "CHANGE_ME"
local SONORAN_API_KEY = "CHANGE_ME"
local SERVER_PORT = GetConvar("sv_port", "30120")
RegisterCommand('tonefd', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    if xPlayer.job.name == SENDER_JOB then
        local currentTime = os.time()
        if cooldowns[source] and (currentTime - cooldowns[source] < COOLDOWN_TIME) then
            local timeRemaining = COOLDOWN_TIME - (currentTime - cooldowns[source])
            xPlayer.showNotification("~o~Tone Cooldown: ~s~Wait " .. timeRemaining .. "s.")
            return
        end
        cooldowns[source] = currentTime
        -- Message Logic
        local userMsg = table.concat(args, " ")
        local cadDesc = "DPS requesting immediate Fire/EMS assistance."
        local clientMsg = ""
        if userMsg ~= "" then
            cadDesc = cadDesc .. " | Details: " .. userMsg
            clientMsg = "\nInfo: " .. userMsg
        end
        local coords = xPlayer.getCoords(true)
        local streetName = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
        local locationInfo = GetStreetNameFromHashKey(streetName)
        local afdCount = 0
        local xPlayers = ESX.GetPlayers()
        for i=1, #xPlayers, 1 do
            local xTarget = ESX.GetPlayerFromId(xPlayers[i])
            if xTarget and AFD_JOBS[xTarget.job.name] then
                afdCount = afdCount + 1
                TriggerClientEvent('dps_tone:playTone', xPlayers[i], coords, locationInfo, clientMsg)
            end
        end
        if afdCount > 0 then
            xPlayer.showNotification("~r~[Dispatch]~s~ AFD Toned Out. ("..afdCount.." units notified)")
        else
            xPlayer.showNotification("~y~[Dispatch]~s~ Tone sent. No active AFD units found.")
        end
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
                    ["description"] = cadDesc,
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
        xPlayer.showNotification("~r~Access Denied:~s~ DPS Only.")
    end
end)

local ESX = exports["es_extended"]:getSharedObject()
local SENDER_JOB = 'police'
local AFD_JOBS = { ['ambulance'] = true }
local COOLDOWN_TIME = 30
local cooldowns = {}
local SONORAN_COMM_ID = "CHANGE_ME"
local SONORAN_API_KEY = "CHANGE_ME"
local SERVER_PORT = GetConvar("sv_port", "30120")
local UPDATE_URL = "https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/version"
Citizen.CreateThread(function()
    local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version', 0)
    if currentVersion then
        PerformHttpRequest(UPDATE_URL, function(err, text, headers)
            if (text) and (text:gsub("%s+", "") ~= currentVersion:gsub("%s+", "")) then
                print("\n^1[AHP-TONE] UPDATE AVAILABLE! Current: " .. currentVersion .. " | New: " .. text .. "^7\n")
            end
        end, "GET", "", {})
    end
end)
RegisterNetEvent('dps_tone:requestTone')
AddEventHandler('dps_tone:requestTone', function(coords, streetName, userMsg)
    local source = source
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
        local cadDesc = "DPS requesting immediate Fire/EMS assistance."
        local clientMsg = ""
        if userMsg and userMsg ~= "" then
            cadDesc = cadDesc .. " | Details: " .. userMsg
            clientMsg = "~n~Info: " .. userMsg 
        end
        local afdCount = 0
        local xPlayers = ESX.GetPlayers()
        for i=1, #xPlayers, 1 do
            local xTarget = ESX.GetPlayerFromId(xPlayers[i])
            if xTarget and AFD_JOBS[xTarget.job.name] then
                afdCount = afdCount + 1
                TriggerClientEvent('dps_tone:playTone', xPlayers[i], coords, streetName, clientMsg)
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
                    ["address"] = streetName,
                    ["title"] = "AFD TONE OUT",
                    ["code"] = "FIRE-1", 
                    ["description"] = cadDesc,
                    ["units"] = {} 
                }
            }
        }
        PerformHttpRequest("https://api.sonorancad.com/emergency/new_dispatch", function(err, text, headers) end, 'POST', json.encode(callData), { ['Content-Type'] = 'application/json' })
    else
        xPlayer.showNotification("~r~Access Denied:~s~ Police Only.")
    end
end)

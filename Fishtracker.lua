-- Initialize settings
if not FishtrackerSettings then
    FishtrackerSettings = {
        chatOutputMode = "both",  -- Default output is "both"
    }
end


-- Initialize all-time data
if not FishtrackerDB then
    FishtrackerDB = {}
end


-- Initialize current session's data
local FishtrackerSessionDB = {}


-- Throttle variable for event listener to avoid double counting due to bad latency
local isThrottleActive = false


-- Function to get the current time period based on server time
local function GetTimePeriod()
    local hour, minute = GetGameTime()

    if hour >= 0 and hour < 6 then
        return "Night"
    elseif hour >= 6 and hour < 12 then
        return "Morning"
    elseif hour >= 12 and hour < 18 then
        return "Day"
    else
        return "Evening"
    end
end


-- Function to get the current season based on the WoW seasonal calendar
local function GetCurrentSeason()
    local month = tonumber(date("%m"))
    local day = tonumber(date("%d"))

    -- March 20 - September 22 is Summer
    if (month == 3 and day >= 20) or (month > 3 and month < 9) or (month == 9 and day <= 22) then
        return "Summer"
    else
        return "Winter"
    end
end


-- Initialize fish data for a given zone, season, and time period if it doesn't exist
local function InitializeFishingData(database, zone, season, timePeriod, fishType)
    if not database[zone] then
        database[zone] = {}
    end
    if not database[zone][season] then
        database[zone][season] = {}
    end
    if not database[zone][season][timePeriod] then
        database[zone][season][timePeriod] = {}
    end
    if not database[zone][season][timePeriod][fishType] then
        database[zone][season][timePeriod][fishType] = 0
    end
end


-- Function for loot event
local function OnLootReady()
    -- If the throttle is active, skip lootwindow - this should prevent double counting with bad latency in the case of fishing.
    if isThrottleActive then
        return
    end
    isThrottleActive = true     -- Set the throttle to active to prevent multiple triggers

    -- Process the loot event
    -- Get the current zone name
    local currentZone = GetRealZoneText()

    -- Get the current time period (Night, Morning, Day or Evening)
    local currentTimePeriod = GetTimePeriod()

    -- Get the current season (Winter, Summer)
    local currentSeason = GetCurrentSeason()

    -- Variables for the total fish for all-time and session data.
    local totalFishInZoneSeasonTime = 0
    local totalSessionFishInZoneSeasonTime = 0

    -- Loop through all the loot slots
    for i = 1, GetNumLootItems() do
        -- Get information about the loot
        local lootIcon, lootName, lootQuantity, lootQuality, locked, isQuestItem, lootID = GetLootSlotInfo(i)

        -- Check if the player is currently fishing
        if IsFishingLoot() then
            -- Create database entrys if its something that hasnt been tracked before.
            InitializeFishingData(FishtrackerDB, currentZone, currentSeason, currentTimePeriod, lootName)
            InitializeFishingData(FishtrackerSessionDB, currentZone, currentSeason, currentTimePeriod, lootName)

            -- Upade databases with fish count
            FishtrackerDB[currentZone][currentSeason][currentTimePeriod][lootName] = FishtrackerDB[currentZone][currentSeason][currentTimePeriod][lootName] + lootQuantity
            FishtrackerSessionDB[currentZone][currentSeason][currentTimePeriod][lootName] = FishtrackerSessionDB[currentZone][currentSeason][currentTimePeriod][lootName] + lootQuantity

            -- Calculate total fish caught  all time
            for _, count in pairs(FishtrackerDB[currentZone][currentSeason][currentTimePeriod]) do
                totalFishInZoneSeasonTime = totalFishInZoneSeasonTime + count
            end

            -- Calculate total fish caught in the current session
            for _, count in pairs(FishtrackerSessionDB[currentZone][currentSeason][currentTimePeriod]) do
                totalSessionFishInZoneSeasonTime = totalSessionFishInZoneSeasonTime + count
            end

            -- Print based on chat output settings
            local chatOutputMode = FishtrackerSettings.chatOutputMode
            local message = ""

            if chatOutputMode == "alltime" then
                local fishCount = FishtrackerDB[currentZone][currentSeason][currentTimePeriod][lootName]
                local percentage = (fishCount / totalFishInZoneSeasonTime) * 100
                message = string.format(
                    "Fishtracker: You fished %s. All time in %s during the %s (%s): %d out of %d (%.2f%%).",
                    lootName,
                    currentZone,
                    currentTimePeriod,
                    currentSeason,
                    fishCount,
                    totalFishInZoneSeasonTime,
                    percentage
                )
                print(message)
            end

            if chatOutputMode == "session" then
                local sessionFishCount = FishtrackerSessionDB[currentZone][currentSeason][currentTimePeriod][lootName]
                local sessionPercentage = (sessionFishCount / totalSessionFishInZoneSeasonTime) * 100
                local sessionMessage = string.format(
                    "Fishtracker: You fished %s. Session in %s during the %s (%s): %d out of %d (%.2f%%).",
                    lootName,
                    currentZone,
                    currentTimePeriod,
                    currentSeason,
                    sessionFishCount,
                    totalSessionFishInZoneSeasonTime,
                    sessionPercentage
                )
                print(sessionMessage)
            end

            if chatOutputMode == "both" then
                local fishCount = FishtrackerDB[currentZone][currentSeason][currentTimePeriod][lootName]
                local percentage = (fishCount / totalFishInZoneSeasonTime) * 100
                local sessionFishCount = FishtrackerSessionDB[currentZone][currentSeason][currentTimePeriod][lootName]
                local sessionPercentage = (sessionFishCount / totalSessionFishInZoneSeasonTime) * 100
                
                message = string.format(
                    "Fishtracker: You fished %s. Session in %s during the %s (%s): %d out of %d (%.2f%%). All time: %d out of %d (%.2f%%).",
                    lootName,
                    currentZone,
                    currentTimePeriod,
                    currentSeason,
                    sessionFishCount,
                    totalSessionFishInZoneSeasonTime,
                    sessionPercentage,
                    fishCount,
                    totalFishInZoneSeasonTime,
                    percentage
                )
                print(message)
            end
        end
    end

    -- Set a timer for the throttle
    C_Timer.After(0.5, function()
        isThrottleActive = false
    end)
end


-- Function to set the chat output mode
local function SetChatOutputMode(mode)
    if mode == "none" or mode == "session" or mode == "alltime" or mode == "both" then
        FishtrackerSettings.chatOutputMode = mode
        print("Fishtracker: Output mode set to " .. mode)
    else
        print("Fishtracker: Invalid mode. Use 'none', 'session', 'alltime', or 'both'.")
    end
end


-- Function to dump fish data for a given zone, season, and time period for all-time and session
local function DumpFishData(database, zone, season, timePeriod, isSession)
    if not database[zone] or not database[zone][season] or not database[zone][season][timePeriod] then
        print("Fishtracker: No data available for " .. zone .. " in the " .. timePeriod .. " during " .. season .. ".")
        return
    end

    print("Fishtracker: Data for " .. zone .. " in the " .. timePeriod .. " during " .. season .. (isSession and " (Session):" or ":"))
    
    for fishType, count in pairs(database[zone][season][timePeriod]) do
        print(fishType .. ": " .. count)
    end
end


-- Slash command ingame
SLASH_FISHTRACKER1 = "/Fishtracker"
SlashCmdList["FISHTRACKER"] = function(msg)
    -- Isolate the command from the rest of the message using regex
    local command, rest = msg:match("^(%S+)%s*(.*)$")
    
    if command == "setmode" then
        SetChatOutputMode(rest)
    elseif command == "dump" then
        -- Extract the zone and get the last two words for season and time period. Zone name can have spaces, Season and timePeriod does not.
        local zone, season, timePeriod = rest:match("^(.-)%s+(%S+)%s+(%S+)$")
        -- Dump all-time fish data
        DumpFishData(FishtrackerDB, zone, season, timePeriod, false)
    elseif command == "dumpsession" then
        -- Extract the zone and get the last two words for season and time period. Zone name can have spaces, Season and timePeriod does not.
        local zone, season, timePeriod = rest:match("^(.-)%s+(%S+)%s+(%S+)$")
        -- Dump session fish data
        DumpFishData(FishtrackerSessionDB, zone, season, timePeriod, true)
    else
        print("Fishtracker: Invalid command. Use '/Fishtracker setmode {mode}', '/Fishtracker dump {zone} {season} {timePeriod}', or '/Fishtracker dumpsession {zone} {season} {timePeriod}'.")
    end
end


-- Event listeners for loot ready
local frame = CreateFrame("FRAME")
frame:RegisterEvent("LOOT_READY")
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "LOOT_READY" then
        OnLootReady()
    end
end)
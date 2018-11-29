-- KebnoaLogger
-- Author: Kebnoa
-- DateCreated: 10/11/2018 18:47:53
-- Main entry point for the KebnoaLogger mod, everything loaded from here
-------------------------------------------------------------------------

-- Setup logger as first order of business. (Using Thalassicus' LuaLogger code)
include("LuaLogger.lua")
log = Events.LuaLogger:New()
log:SetLevel("INFO") -- Change to "ERROR" or "WARN" when ready to release
log:Trace("Thalassicus' Lua Logger loaded")

include("KebnoaTimer.lua")
log:Trace("Kebnoa's timer loaded")

include("dkjson.lua")
log:Trace("David Kolf's JSON for Lua loaded")

include("KebnoaCommon.lua")
log:Trace("Kebnoa's common code loaded")

-- Need to work on somehow saving the state, 
-- but as I am only recording first 54 or so turns it isn't critical
gKebnoaLoggerTable = gKebnoaLoggerTable or {
	jsonSchemaVersion = 3,
	gameConfig = {},
	citySettledLog = {},
	cityPerTurnLog = {}
}

gStopRecordingCitySettledAtTurn = 3
gTurnsToCaptureDataFor = 50
gStopRecordingCityPerTurnAtTurn = gStopRecordingCitySettledAtTurn + gTurnsToCaptureDataFor + 1
gCitiesBeingTracked = gCitiesBeingTracked or {}

-- Record the data of interest when a city is settled. Triggered by Events.CityInitialized
-- The event provides more parameters but I have no idea what they are for now, so ignoring them
function RecordCitySettled(playerId, cityId, x, y)
	log:Trace(string.format("RecordCitySettled called with - player ID: %d, city ID: %d, x: %d, y: %d", playerId, cityId, x, y))
	local currentTurn = Game.GetCurrentGameTurn()
	
	-- stop recording settled cities as those settled later wont have the right duration to be useable
	if currentTurn > gStopRecordingCitySettledAtTurn then return end

	local city = Cities.GetCityInPlot(x, y)
	local	cityName  = L(city:GetName())
	-- Track when cities settled so we know when to stop tracking and which to exclude...
	gCitiesBeingTracked[cityName] = currentTurn

	local citySettledTable = {
		turn      = currentTurn,
		cityName  = cityName,
		ownerName = L(PlayerConfigurations[playerId]:GetLeaderName()),
		ownerCiv  = L(PlayerConfigurations[playerId]:GetCivilizationShortDescription()),
		plots     = {},
	}

	for x, y, ring in PlotCoordinatesInRangeOf(x, y, 2) do
		if x == nil or y == nil or ring == nil then log:Error("Missing plot coordinates after call to PlotCoordinatesInRangeOf()") return end
			table.insert(citySettledTable.plots, PlotInfoAt(x, y, ring))
	end

	log:Debug("CitySettled Table in JSON format:\n\n" .. json.encode(citySettledTable))
	table.insert(gKebnoaLoggerTable.citySettledLog, citySettledTable)
end

function RecordMetrics()
	atEndOfTurn = Game.GetCurrentGameTurn() - 1
  log:Trace(string.format("RecordMetrics called on - turn: %d", atEndOfTurn + 1))

	if atEndOfTurn > gStopRecordingCityPerTurnAtTurn then
		print(string.format("Turn (%s), no longer capturing data, extract recorded data!"))
		return 
	end

	-- The Events.TurnBegin first fires at start of Turn 2 it seems ...
	-- Capture the game configuration once
	if atEndOfTurn == 1 then
		gameConfigTable = GetGameConfigInfo()
		log:Debug("GameConfig Table in JSON format:\n\n" .. json.encode(gameConfigTable))
		table.insert(gKebnoaLoggerTable.gameConfig, gameConfigTable)
	end

	-- Capture all the player's city's information per turn at start of turn...
	-- Will record as current turn - 1 to signify this is actually the state at the end
	-- of the previous turn :-)
	cityPerTurnLogTableEntry = {
		atEndTurn = atEndOfTurn,
		cityLog = {}
	}
  local players = Game.GetPlayers()
  for k, player in pairs(players) do
		local playerId = player:GetID()
		local playerName = L(PlayerConfigurations[playerId]:GetLeaderName())
		if playerName ~= 'Free Cities' and playerName ~= 'Barbarians' then 
			for i, city in player:GetCities():Members() do
				log:Trace(string.format("RecordMetrics at start of turn %d for player ID: %d and city ID: %d", atEndOfTurn, playerId, city:GetID()))

				-- only do this if the city is in the to track list...
				local cityName = L(city:GetName())
				if(	gCitiesBeingTracked[cityName] ~= nil ) then 

					cityPerTurnLogTableEntry = GetCityInfo(playerId, city)
					if (cityPerTurnLogTableEntry == nil) then log.Warning("No data in cityPerTurnLogTable!") end
					--table.insert(cityPerTurnLogTableEntry.cityLog, cityLogTableEntry)
					table.insert(gKebnoaLoggerTable.cityPerTurnLog, cityPerTurnLogTableEntry)
					log:Debug("CityLog Table in JSON format:\n\n" .. json.encode(cityLogTableEntry))
				end
			end
		end
  end
end

-- All set-up, trigger mod loaded, initialise database if necessary.
function OnModLoaded()
	log:Trace("OnModLoaded called")

  Events.TurnBegin.Add(RecordMetrics)
  Events.CityInitialized.Add(RecordCitySettled)

end

-- Do it!
OnModLoaded()
-- If we get here then all should be good!?
log:Info("Kebnoa Logger loaded")

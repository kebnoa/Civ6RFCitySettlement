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

--[[
-- Storing state as a JSON string in the savefile
-- This failed as string gets tooooooo looooong!!!
gKebnoaLoggerTableAsJsonSlotName = 'gKebnoaLoggerTableAsJson'
gKebnoaLoggerTableAsJson = GameConfiguration.GetValue(gKebnoaLoggerTableAsJsonSlotName) or
	string.format("{\"cityOnSettledLog\":[],\"loggerVersion\":1,\"gameConfig\":[],\"date\":\"%s\",\"cityPerTurnLog\":[]}", os.date("%Y%m%d"))
gKebnoaLoggerTable = json.decode(gKebnoaLoggerTableAsJson)

gCitiesBeingTrackedTableAsJsonSlotName = 'gCitiesBeingTrackedTableAsJson'
gCitiesBeingTrackedTableAsJson = GameConfiguration.GetValue(gCitiesBeingTrackedTableAsJsonSlotName) or "[]"
gCitiesBeingTracked = json.decode(gCitiesBeingTrackedTableAsJson)
--GameConfiguration.SetValue(gCitiesBeingTrackedTableAsJsonSlotName, json.encode(gCitiesBeingTracked))
--]]
gKebnoaLoggerTable = gKebnoaLoggerTable or {
	loggerVersion = 2,
	date = os.date("%Y%m%d"),
	gameConfig = {},
	cityOnSettledLog = {},
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

	local cityOnSettledTable = {
		turn      = currentTurn,
		cityName  = cityName,
		ownerName = L(PlayerConfigurations[playerId]:GetLeaderName()),
		plots     = {},
	}

--	cityPlotInfo  = PlotInfoAt(x, y, 0),
--	ring1PlotInfo = {},
--	ring2PlotInfo = {},
--	ring3PlotInfo = {},


	for x, y, ring in PlotCoordinatesInRangeOf(x, y, 2) do
		if x == nil or y == nil or ring == nil then log:Error("Missing plot coordinates after call to PlotCoordinatesInRangeOf()") return end
			table.insert(cityOnSettledTable.plots, PlotInfoAt(x, y, ring))
--    if ring == 1 then
--			table.insert(cityOnSettledTable.ring1PlotInfo, PlotInfoAt(x, y))
--		elseif ring == 2 then
--			table.insert(cityOnSettledTable.ring2PlotInfo, PlotInfoAt(x, y))
--		else
--			table.insert(cityOnSettledTable.ring3PlotInfo, PlotInfoAt(x, y))
--		end
	end
	log:Debug("CityOnSettled Table in JSON format:\n\n" .. json.encode(cityOnSettledTable))
	table.insert(gKebnoaLoggerTable.cityOnSettledLog, cityOnSettledTable)

	---- time this!!!

--	GameConfiguration.SetValue(gKebnoaLoggerTableAsJsonSlotName, json.encode(gKebnoaLoggerTable))
--	local t = Timer:new()
--	log:Debug(string.format("CityOnSettled took %s seconds", t:stop()))
end

function RecordMetrics()
	atEndOfTurn = Game.GetCurrentGameTurn() - 1
  log:Trace(string.format("RecordMetrics called on - turn: %d", atEndOfTurn + 1))

	if atEndOfTurn > gStopRecordingCityPerTurnAtTurn then
		print(string.format("Turn (%s), no longer capturing data, extract recorded data!"))
		return 
	end

--	if currentTurn == gStopRecordingCitySettledAtTurn then
--		log:Debug(string.format("Current Turn: %s and Stop Recording City Settled Turn: %s", currentTurn, gStopRecordingCitySettledAtTurn))
--		local lastCitySettledOnTurn = 0
--		for i, v in ipairs(gCitiesBeingTracked) do
--			if v > lastCitySettledOnTurn then lastCitySettledOnTurn = v end
--		end
--	  -- set the stop recording value to 50 more than last turn settled + 1 to cater for capture at start of turn
--		gStopRecordingCityPerTurnAtTurn = lastCitySettledOnTurn + gTurnsToCaptureDataFor + 1
--	end

--	-- No need to record anything here afer 55 or so turns
--		if atEndOfTurn > gStopRecordingCityPerTurnAtTurn then
--			print(json.encode(gKebnoaLoggerTable))
--			return
--		end

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
--	log:Debug("CitiesPerTurn Table in JSON format:\n\n" .. json.encode(cityPerTurnLogTableEntry))
--	table.insert(gKebnoaLoggerTable.cityPerTurnLog, cityPerTurnLogTableEntry)

--	GameConfiguration.SetValue(gKebnoaLoggerTableAsJsonSlotName, json.encode(gKebnoaLoggerTable))

--	local t = Timer:new()
--	kebnoaLoggerJson = json.encode(gKebnoaLoggerTable)
--	log:Debug(string.format("Encoding KebnoaLogger Table in JSON format took %s seconds...", t:stop()))
--	log:Debug("KebnoaLogger Table in JSON format:\n\n" .. kebnoaLoggerJson)
end

-- All set-up, trigger mod loaded, initialise database if necessary.
function OnModLoaded()
	log:Trace("OnModLoaded called")
--	if (InitDatabase() ~= true) then
--		log:Error("Unable to initialise database, aborting...")
--		return nil
--	else
--		log:Trace("Successfully loaded all code and passed pre-flight checks. Hook up all the events")
--		Events.NewGameTurn.Add(CaptureMetrics)
--	end

  Events.TurnBegin.Add(RecordMetrics)
  Events.CityInitialized.Add(RecordCitySettled)

end

-- Do it!
OnModLoaded()
-- If we get here then all should be good!?
log:Info("Kebnoa Logger loaded")

-- KebnoaLogger
-- Author: Kebnoa
-- DateCreated: 10/11/2018 18:47:53
-- Main entry point for the KebnoaLogger mod, everything loaded from here
-------------------------------------------------------------------------

-- Store everything here in one place!
-- TODO: make this save aware so can leave game etc!?
gKebnoaLoggerTable = gKebnoaLoggerTable or {
	loggerVersion = 1,
	date = os.date("%Y%m%d"),
	gameGonfig = {},
	cityOnSettledLog = {},
	cityPerTurnLog = {} }

gStopRecordingCitySettledAtTurn = 5
gStopRecordingCityPerTurnAtTurn = 50 + gStopRecordingCitySettledAtTurn
gCitiesBeingTracked= {}

-- Setup logger as first order of business. (Using Thalassicus' LuaLogger code)
include("LuaLogger.lua")
log = Events.LuaLogger:New()
log:SetLevel("DEBUG") -- Change to "ERROR" or "WARN" when ready to release
log:Trace("Thalassicus' Lua Logger loaded...")

include("dkjson.lua")
log:Trace("David Kolf's JSON for Lua loaded...")

include("KebnoaCommon.lua")
log:Trace("Kebnoa's common code loaded...")

function RecordMetrics()
	atEndOfTurn = Game.GetCurrentGameTurn() - 1
  log:Trace(string.format("Entered RecordMetrics, turn %d", atEndOfTurn + 1))

	-- No need to record anything here afer 55 or so turns
		if atEndOfTurn > gStopRecordingCityPerTurnAtTurn then
			print(json.encode(gKebnoaLoggerTable))
			return
		end

	-- The Events.TurnBegin first fires in Current Turn 2 ...
	-- Capture the game configuration once
	if atEndOfTurn == 1 then
		gameConfigTable = GetGameConfigInfo()
		table.insert(gKebnoaLoggerTable.gameGonfig, gameConfigTable)
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
				if(	gCitiesBeingTracked[cityName] ) then 

					cityLogTableEntry = GetCityInfo(playerId, city)
					if (cityLogTableEntry == nil) then log.Error("No data in cityLogTable!") end
					table.insert(cityPerTurnLogTableEntry.cityLog, cityLogTableEntry)

					print(json.encode(cityLogTableEntry))

--				log:Debug(json.encode(cityLogTableEntry))
				end
			end
		end
  end
	table.insert(gKebnoaLoggerTable.cityPerTurnLog, cityPerTurnLogTableEntry)
	log:Debug(json.encode(gKebnoaLoggerTable))
end

function RecordCitySettled(playerId, cityId, x, y)
  local currentTurn = Game.GetCurrentGameTurn()
	-- No need to capture new cities after turn 5 or so ... all starting cities settled by now
	if currentTurn > gStopRecordingCitySettledAtTurn then return end

  log:Trace("Entered RecordCitySettled")
  log:Trace(string.format("RecordCitySettled on turn %d - playerID: %d, cityID: %d, X: %d, Y: %d", currentTurn, playerId, cityId, x, y))

	local city = Cities.GetCityInPlot(x, y)
	local cityName = L(city:GetName())
	gCitiesBeingTracked[cityName] = true

	local cityOnSettledTable = {
		cityName      = cityName,
		settledBy     = L(PlayerConfigurations[playerId]:GetLeaderName()),
		settledOnTurn = currentTurn,
		cityPlotInfo  = PlotInfoAt(x, y),
		ring1PlotInfo = {},
		ring2PlotInfo = {},
		ring3PlotInfo = {},
	}

	for x, y, ring in PlotCoordinatesInRangeOf(x, y) do
		if x == nil or y == nil then log:Error("Missing plot coordinates after call to PlotCoordinatesInRangeOf()") return end
		log:Trace(string.format("PlotCoordinatesInRangeOf - x: %d, y: %d, ring: %d", x, y, ring))

    if ring == 1 then
			table.insert(cityOnSettledTable.ring1PlotInfo, PlotInfoAt(x, y))
		elseif ring == 2 then
			table.insert(cityOnSettledTable.ring2PlotInfo, PlotInfoAt(x, y))
		else
			table.insert(cityOnSettledTable.ring3PlotInfo, PlotInfoAt(x, y))
		end
	end

	log:Trace(json.encode(cityOnSettledTable))

	table.insert(gKebnoaLoggerTable.cityOnSettledLog, cityOnSettledTable)
end

-- All set-up, trigger mod loaded, initialise database if necessary.
function OnModLoaded()
	log:Trace("Entered OnModLoaded...")
--	if (InitDatabase() ~= true) then
--		log:Error("Unable to initialise database, aborting...")
--		return nil
--	else
--		log:Trace("Successfully loaded all code and passed pre-flight checks. Hook up all the events")
--		Events.NewGameTurn.Add(CaptureMetrics)
--	end

  Events.TurnBegin.Add(RecordMetrics)
  Events.CityInitialized.Add(RecordCitySettled)

	log:Info("Kebnoa Logger loaded successfully")
end

-- Do it!
OnModLoaded()
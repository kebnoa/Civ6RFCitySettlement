-- KebLogMain
-- Author: Kebnoa
-- DateCreated: 10/11/2018 18:47:53
-- Main entry point for the KebnoaLogger mod, everything loaded from here
-------------------------------------------------------------------------

-- Neither of these seem relavant for what I need... Leave for now, but delete once checked!
--include("Civ6Common.lua")
--include("ModTools")

-- Setup logger as first order of business. (Using Thalassicus' LuaLogger code)
include("LuaLogger.lua")
local log = Events.LuaLogger:New()
log:SetLevel("TRACE") -- Change to "ERROR" or "WARN" when ready to release
log:Trace("Logger loaded...")

include("dkjson.lua")
log:Trace("JSON module loaded...")

-- Do LOTS of stuff here :-)
--function RecordCityMetrics()
--	log:Trace("Entered RecordCityMetrics")
--end

function RecordMetrics()
  log:Trace("Entered RecordMetrics")
  local players = Game.GetPlayers()
  for k, v in pairs(players) do
--	if v:IsInitialzed() == true then
		-- , v:TypeName()
	message = string.format("Id: %d5, IsMajor: %s, IsHuman: %s", v:GetID(), tostring(v:IsMajor()), tostring(v:IsHuman()))
	print(message)
--	end
  end
end

function RecordCitySettled()
  log:Trace("Entered RecordCitySettled")
--  str = string.format("%d2, %d5, %d2, %d2 playerID, cityID, X, Y)
--  log:Debug(str)
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
--  Events.LocalPlayerTurnBegin.Add(RecordCityMetrics)
end

-- Do it!
OnModLoaded()

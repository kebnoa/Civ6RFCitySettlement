-- KebnoaCommon
-- Author: Kebnoa
-- DateCreated: 11/15/2018 7:41:11 AM
-- Storing common and re-useable code here
--------------------------------------------------------------

log:Trace("Kebnoa's common code load started...")

--[[
function GetKebnoaLoggerSaveFilename()
  math.randomseed(os.rawclock()); math.random(); math.random(); math.random();

  local lookup = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
                   'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
                   'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T',
                   'U', 'V', 'W', 'X', 'Y', 'Z' }

  local str = lookup[math.random(1, 36)] .. lookup[math.random(1, 36)] .. lookup[math.random(1, 36)] ..
              lookup[math.random(1, 36)] .. lookup[math.random(1, 36)] .. lookup[math.random(1, 36)]

  return "KebnoaLogger_01_" .. os.date("%Y%m%d_") .. str
end
--]]

-- For consistency across datasets selecting English for data capture
function L(str) return Locale.LookupLanguage('en_US', str) end

-- Create string with number rounded to 2 decimal places.
function D2(num) return string.format("%.2f", num) end

-- Clean up ToolTip strings
function TT(str) a, b = str:gsub("%[ICON_Bullet%]", "  "):gsub("%%", "pct"); return a end

--[==[
Iterator function that loops through all plots within 3 tiles of the X, Y co-ordinates provided. (origin excluded)

It returns the X, Y co-ordinates of a plot in range, as well as the distance from the origin, with each iteration.

X values wrap at GameInfo.Maps[Map.GetMapSize()].GridWidth like the Civ6 maps do.
Plots with Y values less than 0 or more than GameInfo.Maps[Map.GetMapSize()].GridHeight are discarded.
--]==]
function PlotCoordinatesInRangeOf (x, y)
  if x == nil or y == nil then return nil end
  
  local deltasOnEvenX = {
    {x =  0, y =  1, r = 1}, {x =  1, y =  0, r = 1}, {x =  0, y = -1, r = 1}, {x = -1, y = -1, r = 1},
    {x = -1, y =  0, r = 1}, {x = -1, y =  1, r = 1}, {x =  1, y =  2, r = 2}, {x =  1, y =  1, r = 2}, {x =  2, y =  0, r = 2},
    {x =  1, y = -1, r = 2}, {x =  1, y = -2, r = 2}, {x =  0, y = -2, r = 2}, {x = -1, y = -2, r = 2}, {x = -2, y = -1, r = 2},
    {x = -2, y =  0, r = 2}, {x = -2, y =  1, r = 2}, {x = -1, y =  2, r = 2}, {x =  0, y =  2, r = 2}, {x =  1, y =  3, r = 3},
    {x =  2, y =  2, r = 3}, {x =  2, y =  1, r = 3}, {x =  3, y =  0, r = 3}, {x =  2, y = -1, r = 3}, {x =  2, y = -2, r = 3},
    {x =  1, y = -3, r = 3}, {x =  0, y = -3, r = 3}, {x = -1, y = -3, r = 3}, {x = -2, y = -3, r = 3}, {x = -2, y = -2, r = 3},
    {x = -3, y = -1, r = 3}, {x = -3, y =  0, r = 3}, {x = -3, y =  1, r = 3}, {x = -2, y =  2, r = 3}, {x = -2, y =  3, r = 3},
    {x = -1, y =  3, r = 3}, {x =  0, y =  3, r = 3}, }

  local deltasOnOddX = {
    {x =  1, y =  1, r = 1}, {x =  1, y =  0, r = 1}, {x =  1, y = -1, r = 1}, {x =  0, y = -1, r = 1},
    {x = -1, y =  0, r = 1}, {x =  0, y =  1, r = 1}, {x =  1, y =  2, r = 2}, {x =  2, y =  1, r = 2}, {x =  2, y =  0, r = 2},
    {x =  2, y = -1, r = 2}, {x =  1, y = -2, r = 2}, {x =  0, y = -2, r = 2}, {x = -1, y = -2, r = 2}, {x = -1, y = -1, r = 2},
    {x = -2, y =  0, r = 2}, {x = -1, y =  1, r = 2}, {x = -1, y =  2, r = 2}, {x =  0, y =  2, r = 2}, {x =  2, y =  3, r = 3},
    {x =  2, y =  2, r = 3}, {x =  3, y =  1, r = 3}, {x =  3, y =  0, r = 3}, {x =  3, y = -1, r = 3}, {x =  2, y = -2, r = 3},
    {x =  2, y = -3, r = 3}, {x =  1, y = -3, r = 3}, {x =  0, y = -3, r = 3}, {x = -1, y = -3, r = 3}, {x = -2, y = -2, r = 3},
    {x = -2, y = -1, r = 3}, {x = -3, y =  0, r = 3}, {x = -2, y =  1, r = 3}, {x = -2, y =  2, r = 3}, {x = -1, y =  3, r = 3},
    {x =  0, y =  3, r = 3}, {x =  1, y =  3, r = 3}, }
  
	local mapType = Map.GetMapSize();
	local mapX = GameInfo.Maps[mapType].GridWidth;
	local mapY = GameInfo.Maps[mapType].GridHeight;
  local xWrapsAt = mapX
  local yMin = 0
  local yMax = mapY
      
  if x % 2 == 0 then deltas = deltasOnEvenX else deltas = deltasOnOddX end
  
  local plotsInRange = {}
	local n = 0 -- use this to count the number of elements so can use in iterator function below
  for i, d in ipairs(deltas) do
    newX = (x + d.x) % xWrapsAt
    newY = y + d.y
		log:Trace(string.format("PlotCoordinatesInRangeOf - new X: %d, new Y: %d", newX, newY))
    if (newY >= yMin) and (newY <= yMax) then
		  n = n + 1
      table.insert(plotsInRange, {x = newX, y = newY, ring = d.r})
    end
  end

	log:Trace(string.format("PlotCoordinatesInRangeOf - plots in range: %s", tostring(plotsInRange)))
  
	-- The actual iterator...
  local i = 0
  return function ()
    i = i + 1
    if i <= n then
      return plotsInRange[i].x, plotsInRange[i].y, plotsInRange[i].ring
    end
  end
end

--[==[
Function that gets the plot (or tile) in for the X, Y co-ordinates provided.

It return a table containing key measurements of interest.

No checks are done for whether X or Y are valid!
--]==]
function PlotInfoAt (x, y)
	if x == nil or y == nil then return {} end

	local plot = Map.GetPlot(x, y)
	local plotOwnerId = plot:GetOwner()
	local plotCity = Cities.GetPlotPurchaseCity(plot)
	local plotOwnerName = plotOwnerId ~= -1 and L(PlayerConfigurations[plotOwnerId]:GetLeaderName()) or "None"
	local plotOwnerCiv = plotOwnerId ~= -1 and L(PlayerConfigurations[plotOwnerId]:GetCivilizationShortDescription()) or "None"
	local plotOwnerCity = plotCity ~= nil and L(plotCity:GetName()) or "None"
	local plotDistrict = plot:GetDistrictType() ~= -1 and L(GameInfo.Districts[plot:GetDistrictType()].Name) or "None"
	local plotFeature = plot:GetFeatureType() ~= -1 and L(GameInfo.Features[plot:GetFeatureType()].Name) or "None"
	local plotResource = plot:GetResourceType() ~= -1 and L(GameInfo.Resources[plot:GetResourceType()].Name) or "None"
	local plotResourceType = plot:GetResourceType() ~= -1 and L("LOC_" .. GameInfo.Resources[plot:GetResourceType()].ResourceClassType .. "_NAME") or "None"

	log:Trace(string.format("PlotInfoAt - x: %d, y: %d", x, y))
	local plotInfoTableEntry = {
		x             = x,
		y             = y,
		index         = plot:GetIndex(),
		ownerName     = plotOwnerName,
		ownerCiv      = plotOwnerCiv,
		ownerCity     = plotOwnerCity,
		terrain       = L(GameInfo.Terrains[plot:GetTerrainType()].Name),
		feature       = plotFeature,
		resource      = plotResource,
		resourceCount	= plot:GetResourceCount(),
		resourceType  = plotResourceType,
		workers       = plot:GetWorkerCount(),
		district      = plotDistrict,
		hasRiver			= plot:IsRiver(),				
		isWater				= plot:IsWater(),
		isLake				= plot:IsLake(),
		isCity				= plot:IsCity(),
	}
	
	log:Trace("PlotInfoAt - plotInfoTableEntry: ", json.encode(plotInfoTableEntry))

	return plotInfoTableEntry
end

function GetGameConfigInfo()

	playerId = Game.GetLocalPlayer()
	player = Players[playerId]
	playerConfig = PlayerConfigurations[playerId]

	gameConfigTable = {
		leader = L(playerConfig:GetLeaderName()),
		ruleSet = GameConfiguration.GetRuleSet(),
		difficulty = L(GameInfo.Difficulties[playerConfig:GetHandicapTypeID()].Name),
		startEra = L(GameInfo.Eras[GameConfiguration.GetStartEra()].Name),
		gameSpeed = L(GameInfo.GameSpeeds[GameConfiguration.GetGameSpeedType()].Name),
		mapType = "ToDo",
		mapSize = L(GameInfo.Maps[Map.GetMapSize()].Name),
		players = {}
	}

  local players = Game.GetPlayers()
  for k, player in pairs(players) do
		local playerId = player:GetID()
		local playerName = L(PlayerConfigurations[playerId]:GetLeaderName())
		if playerName ~= 'Free Cities' and playerName ~= 'Barbarians' then 
			playerTableEntry = {
				playerName = playerName,
				playerCiv  = L(PlayerConfigurations[playerId]:GetCivilizationShortDescription())
			}
			table.insert(gameConfigTable.players, playerTableEntry)
		end
	end

	log:Trace("GetGameConfigInfo - gameConfigTable: ", json.encode(gameConfigTable))

	return gameConfigTable
end

function GetCityInfo(playerId, city)
	if playerId == nil or city == nil then return {Error = "Either playerId or city is null"} end

	local cityGrowth	= city:GetGrowth()

	cityLogTableEntry = {
		ownerName         = L(PlayerConfigurations[playerId]:GetLeaderName()),
		cityName          = L(city:GetName()),
		foodPerTurn       = D2(city:GetYield(YieldTypes.FOOD)),
		foodToolTip       = TT(city:GetYieldToolTip(YieldTypes.FOOD)),
		productionPerTurn = D2(city:GetYield(YieldTypes.PRODUCTION)),
		productionToolTip = TT(city:GetYieldToolTip(YieldTypes.PRODUCTION)),
		goldPerTurn       = D2(city:GetYield(YieldTypes.GOLD)),
		goldToolTip       = TT(city:GetYieldToolTip(YieldTypes.GOLD)),
		sciencePerTurn    = D2(city:GetYield(YieldTypes.SCIENCE)),
		scienceToolTip    = TT(city:GetYieldToolTip(YieldTypes.SCIENCE)),
		culturePerTurn    = D2(city:GetYield(YieldTypes.CULTURE)),
		cultureToolTip    = TT(city:GetYieldToolTip(YieldTypes.CULTURE)),
		faithPerTurn      = D2(city:GetYield(YieldTypes.FAITH)),
		faithToolTip      = TT(city:GetYieldToolTip(YieldTypes.FAITH)),
		population        = city:GetPopulation(),
		amenities         = cityGrowth:GetAmenities(),
		amenitiesNeeded   = cityGrowth:GetAmenitiesNeeded(),
		housing           = cityGrowth:GetHousing(),
		happiness         = L("LOC_" .. GameInfo.Happinesses_XP1[cityGrowth:GetHappiness()].HappinessType .. "_NAME") 
	}
	-- ptGoldSurplus     = D2(city:GetGold()),

	log:Debug("GetCityInfo - cityLogTableEntry", json.encode(cityLogTableEntry))

	return cityLogTableEntry
end
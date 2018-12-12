from datetime import datetime 
import pkg_resources
import json
import sqlite3
import fastjsonschema

class Loader(object):

  def __init__(self, jsonDataFilename):
    hasInitialisationError = False
    try:
      with open(jsonDataFilename, encoding='utf8') as f:
        self.jsonData = json.load(f)
      self.jsonDataSchemaDefinitionVersion = int(self.jsonData['jsonSchemaVersion'])
    except FileNotFoundError:
      print("Couldn't find the file specified. You specified: '{}'".format(jsonDataFilename))
      hasInitialisationError = True
    except KeyError:
      print("Couldn't locate the 'jsonSchemaVersion' key in: {}".format(jsonDataFilename))
      hasInitialisationError = True
    except ValueError:
      print("Couldn't detemine the 'jsonSchemaVersion' version number in: {}".format(jsonDataFilename))
      hasInitialisationError = True
    if (hasInitialisationError == False):
      self.hasInitialsedCorrectly = True
    else:
      self.hasInitialsedCorrectly = False
    
  def connectValidationDb(self):
    print("\nConnecting (and initialising) InMemory Database:")
    try:
      sqlInitFilename = pkg_resources.resource_filename(__name__, 'resources/CityAnalysisDatabaseInitialisation04_data.sql')
      with open(sqlInitFilename, encoding='utf8') as f:
        sqlInitScript = f.read()
      db = sqlite3.connect(":memory:")
      cur = db.cursor()
      cur.executescript(sqlInitScript)
      cur.close()
    except FileNotFoundError:
      print("Unexpected error, unable to locate the sql initialisation file.")
      return None
    except sqlite3.OperationalError:
      print("Unexpected error, unable to initialisation InMemory database. Most likely a script error")
      return None
    return db

  def connectDb(self, sqlite3DbFilename):
    print("\nConnecting to {} Database:".format(sqlite3DbFilename))
    try:
      db = sqlite3.connect(sqlite3DbFilename)
    except sqlite3.OperationalError as ex:
      print("Error using database file ({}) specified.\n - System message: {}".format(sqlite3DbFilename, ex))
      return None
    return db

  def uploadToDatabase(self, db):
    if not(isinstance(db, sqlite3.Connection)):
      print("{} is not a Sqlite3 database connection. Type: {}".format(db, type(db)))
      return False
    cur = db.cursor()
    try:
      # Populate game table
      gameData = self.jsonData['gameConfig'][0]
      game = {
        'gameId': None,
        'date': datetime.strptime(gameData['date'], '%Y%m%d').date(),
        'difficulty': gameData['difficulty'],
        'mapType': 'Continents',
        'mapSize': gameData['mapSize'],
        'gameSpeed': gameData['gameSpeed'],
        'startEra': gameData['startEra'],
        'ruleSet': gameData['ruleSet'],
      }
      query = 'INSERT INTO game VALUES(:gameId, :date, :difficulty, :mapType, :mapSize, :gameSpeed, :startEra, :ruleSet)'
      cur.execute(query, game)
      gameId = cur.lastrowid
      print(" - game table populated, gameId: ", gameId)

      # Populate leader table
      queryLeaderID = 'SELECT LeaderId FROM leader WHERE name = :leaderName AND civ = :leaderCiv'
      newLeaders = []
      for leader in gameData['leaders']:
        name = leader['leaderName']
        civ = leader['leaderCiv']
        params = { 'leaderName': name, 'leaderCiv': civ }
        leaderId = cur.execute(queryLeaderID, params).fetchone()
        if leaderId is None:
          newLeader = {
            'leaderId': None,
            'name': name,
            'civ': civ,
            'isMajor':leader['isMajor'],
          }
          newLeaders.append(newLeader)
      query = 'INSERT INTO leader VALUES(:leaderId, :name, :civ, :isMajor)'
      for leader in newLeaders:
        cur.execute(query, leader)
      print(" - leader table populated, added {} leaders".format(len(newLeaders)))

      # Populate gameLeader table
      gameLeaders = []
      for leader in gameData['leaders']:
        name = leader['leaderName']
        civ = leader['leaderCiv']
        params = { 'leaderName': name, 'leaderCiv': civ }
        # Assume that leaderId has value as we just added any missing ones
        leaderId = cur.execute(queryLeaderID, params).fetchone()[0]
        gameLeader = {
          'gameId': gameId,
          'leaderId':leaderId,
          'isHuman':leader['isHuman'],
        }
        gameLeaders.append(gameLeader)
      query = 'INSERT INTO gameLeader VALUES(:gameId, :leaderId, :isHuman)'
      for gameLeader in gameLeaders:
        cur.execute(query, gameLeader)
      print(" - gameLeaders table populated, added {} gameLeaders".format(len(gameLeaders)))

      # Populate citySettled and gameCity tables
      citySettledLog = self.jsonData['citySettledLog']
      for city in citySettledLog:
        settledByName = city['ownerName']
        settledByCiv = city['ownerCiv']
        params = { 'leaderName': settledByName, 'leaderCiv': settledByCiv }
        settledById = cur.execute(queryLeaderID, params).fetchone()[0]
        cityName = city['cityName']

        query = 'INSERT INTO citySettledLog VALUES(:cityId, :name, :settledById, :onTurn)'
        params = {'cityId': None, 'name': cityName, 'settledById':settledById, 'onTurn':city['turn']}
        cur.execute(query, params)
        cityId = cur.lastrowid

        query = 'INSERT INTO gameCity VALUES(:gameId, :cityId)'
        params = {'gameId':gameId, 'cityId':cityId}
        cur.execute(query, params)
      print(" - citySettledLog and gameCity tables updated. Added {} cities".format(len(citySettledLog)))

      # Populate cityPlotsSettled
      cityPlotsInfo = []
      for city in citySettledLog:
        queryCityId = 'SELECT cityId FROM gameCityLeaderSettledView WHERE gameId = :gameId AND cityName = :cityName'
        params = {'gameId': gameId, 'cityName':city['cityName']}
        # Need this value to ensure all the plots per city are identifiable
        recordedCityId = cur.execute(queryCityId, params).fetchone()[0]
        for plot in city['plots']:
          params = {'gameId': gameId, 'cityName': plot['ownerCity']}
          ownerCityId = cur.execute(queryCityId, params).fetchone()
          if ownerCityId is not None:
            ownerCityId = ownerCityId[0]
          plotInfo = {
            'plotId': None,
            'ownerCityId': ownerCityId,
            'recordedCityId': recordedCityId,
            'ring': plot['r'],
            'terrain': plot['terrain'],
            'feature': plot['feature'],
            'resource': plot['resource'],
            'resourceCount': plot['resourceCount'],
            'resourceType': plot['resourceType'],
            'workers': plot['workers'],
            'district': plot['district'],
            'hasRiver': plot['hasRiver'],
            'isWater': plot['isWater'],
            'isLake': plot['isLake'],
            'isCity': plot['isCity'],
          }
          cityPlotsInfo.append(plotInfo)
      query = 'INSERT INTO cityPlotsSettled VALUES(:plotId, :ownerCityId, :recordedCityId, :ring, :terrain, :feature, :resource, :resourceCount, :resourceType, :workers, :district, :hasRiver, :isWater, :isLake, :isCity )'
      for plotInfo in cityPlotsInfo:
        cur.execute(query, plotInfo)
      print(" - cityPlotsSettled table updated. Added {} plots".format(len(cityPlotsInfo)))

      # Populate cityPerTurnLog
      cityPerTurnLog = []
      for logEntry in self.jsonData['cityPerTurnLog']:
        params = { 'leaderName': logEntry['ownerName'], 'leaderCiv': logEntry['ownerCiv'] }
        leaderId = cur.execute(queryLeaderID, params).fetchone()[0]
        params = {'gameId': gameId, 'cityName': logEntry['cityName']}
        cityId = cur.execute(queryCityId, params).fetchone()[0]
        turnInfo = {
          'cityId': cityId,
          'turn': int(logEntry['turn']),
          'ownerId': leaderId,
          'foodPerTurn': logEntry['foodPerTurn'],
          'foodToolTip': logEntry['foodToolTip'],
          'productionPerTurn': logEntry['productionPerTurn'],
          'productionToolTip': logEntry['productionToolTip'],
          'goldPerTurn': logEntry['goldPerTurn'],
          'goldToolTip': logEntry['goldToolTip'],
          'sciencePerTurn': logEntry['sciencePerTurn'],
          'scienceToolTip': logEntry['scienceToolTip'],
          'culturePerTurn': logEntry['culturePerTurn'],
          'cultureToolTip': logEntry['cultureToolTip'],
          'faithPerTurn': logEntry['faithPerTurn'],
          'faithToolTip': logEntry['faithToolTip'],
          'population': logEntry['population'],
          'housing': logEntry['housing'],
          'amenities': logEntry['amenities'],
          'amenitiesNeeded': logEntry['amenitiesNeeded'],
          'happiness': logEntry['happiness'],
        }
        cityPerTurnLog.append(turnInfo)
      query = 'INSERT INTO cityPerTurnLog VALUES(:cityId, :turn, :ownerId, :foodPerTurn, :foodToolTip, :productionPerTurn, :productionToolTip, :goldPerTurn, :goldToolTip, :sciencePerTurn, :scienceToolTip, :culturePerTurn, :cultureToolTip, :faithPerTurn, :faithToolTip, :population, :housing, :amenities, :amenitiesNeeded, :happiness)'
      for cityPerTurnLogEnty in cityPerTurnLog:
        cur.execute(query, cityPerTurnLogEnty)
      print(" - cityPerTurnLog table updated. Added {} entries.".format(len(cityPerTurnLog)))

    except sqlite3.OperationalError as ex:
      print("Unexpected error, database update failure: {}".format(ex))
      db.rollback()
      cur.close()
      db.close()
      return False
    db.commit()
    cur.close()
    db.close()
    return True

# CityAnalysisJsonSchema_Ver03.json schema file created using https://jsonschema.net/
  def jsonDataPassesValidation(self):
    # Current only version 3 is supported
    if (self.jsonDataSchemaDefinitionVersion == 3):
      schemaFilename = pkg_resources.resource_filename(__name__, 'resources/CityAnalysisJsonSchema_Ver03.json')
    else:
      print("Unexpected error, no support for json schema version number: {}".format(self.jsonDataSchemaDefinitionVersion))
      return False
    # Open schema and valdiate the jsonData
    try:
      with open(schemaFilename, encoding='utf8') as f:
        jsonSchemaDefinition = json.load(f)
      # validate returns validated jsonData and raises exceptions if NOT valid.
      self.jsonData = fastjsonschema.validate(jsonSchemaDefinition, self.jsonData)
    except FileNotFoundError:
      print("Unexpected error, unable to locate the json validation schema file.")
      return False
    except fastjsonschema.JsonSchemaDefinitionException:
      print("Unexpected error, unable to validate the json validation schema file.")      
      return False
    except fastjsonschema.JsonSchemaException as ex:
      print("{} failed json schema validation with error:\n{}".format(self.jsonDataFilename, ex))
      return False
    # We have a valid json Data input file with basic validation of the schema, now we load it into memory 
    # to ensure it loads fine...
    db = self.connectValidationDb()
    if (db == None):
      return False
    hasLoadedSuccessfully = self.uploadToDatabase(db)
    return hasLoadedSuccessfully




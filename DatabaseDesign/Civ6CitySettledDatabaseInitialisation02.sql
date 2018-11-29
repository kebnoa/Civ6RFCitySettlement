/*
 Navicat SQLite Data Transfer

 Source Server         : Civ6CitySettleData
 Source Server Type    : SQLite
 Source Server Version : 3021000
 Source Schema         : main

 Target Server Type    : SQLite
 Target Server Version : 3021000
 File Encoding         : 65001

 Date: 26/11/2018 20:35:01
*/

PRAGMA foreign_keys = false;

-- ----------------------------
-- Table structure for cityPerTurnLog
-- ----------------------------
DROP TABLE IF EXISTS "cityPerTurnLog";
CREATE TABLE "cityPerTurnLog" (
  "cityId" INTEGER NOT NULL COLLATE NOCASE,
  "turn" INTEGER NOT NULL COLLATE NOCASE,
  "ownerId" INTEGER NOT NULL COLLATE NOCASE,
  "foodPerTurn" REAL NOT NULL COLLATE NOCASE,
  "foodToolTip" VARCHAR (256) COLLATE NOCASE,
  "productionPerTurn" REAL NOT NULL COLLATE NOCASE,
  "productionToolTip" VARCHAR (256) COLLATE NOCASE,
  "goldPerTurn" REAL NOT NULL COLLATE NOCASE,
  "goldToolTip" VARCHAR (256) COLLATE NOCASE,
  "sciencePerTurn" REAL NOT NULL COLLATE NOCASE,
  "scienceToolTip" VARCHAR (256) COLLATE NOCASE,
  "culturePerTurn" REAL NOT NULL COLLATE NOCASE,
  "cultureToolTip" VARCHAR (256) COLLATE NOCASE,
  "faithPerTurn" REAL NOT NULL COLLATE NOCASE,
  "faithToolTip" VARCHAR (256) COLLATE NOCASE,
  "population" INTEGER NOT NULL COLLATE NOCASE,
  "housing" INTEGER NOT NULL COLLATE NOCASE,
  "amenities" INTEGER NOT NULL COLLATE NOCASE,
  "amenitiesNeeded" INTEGER NOT NULL COLLATE NOCASE,
  "happiness" VARCHAR (32) NOT NULL COLLATE NOCASE,
  CONSTRAINT "cityPerTurnLog_cityId" FOREIGN KEY ("cityId") REFERENCES "citySettled" ("cityId") ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT "cityPerTurnLog_leaderId" FOREIGN KEY ("ownerId") REFERENCES "leader" ("leaderId") ON DELETE NO ACTION ON UPDATE NO ACTION
);

-- ----------------------------
-- Table structure for cityPlotsSettled
-- ----------------------------
DROP TABLE IF EXISTS "cityPlotsSettled";
CREATE TABLE "cityPlotsSettled" (
  "plotId" INTEGER COLLATE NOCASE,
  "ownerCityId" INTEGER COLLATE NOCASE,
  "ring" INTEGER NOT NULL COLLATE NOCASE,
  "terrain" VARCHAR (32) NOT NULL COLLATE NOCASE,
  "feature" VARCHAR (32) NOT NULL COLLATE NOCASE,
  "resource" VARCHAR (32) NOT NULL COLLATE NOCASE,
  "resourceCount" INTEGER NOT NULL COLLATE NOCASE,
  "resourceType" VARCHAR (32) NOT NULL COLLATE NOCASE,
  "workers" INTEGER NOT NULL COLLATE NOCASE,
  "district" VARCHAR (32) NOT NULL COLLATE NOCASE,
  "hasRiver" BOOLEAN NOT NULL COLLATE NOCASE,
  "isWater" BOOLEAN NOT NULL COLLATE NOCASE,
  "isLake" BOOLEAN NOT NULL COLLATE NOCASE,
  "isCity" BOOLEAN NOT NULL COLLATE NOCASE,
  PRIMARY KEY ("plotId"),
  CONSTRAINT "cityPlotsSettled_ownerCityId" FOREIGN KEY ("ownerCityId") REFERENCES "citySettled" ("cityId") ON DELETE NO ACTION ON UPDATE NO ACTION
);

-- ----------------------------
-- Table structure for citySettled
-- ----------------------------
DROP TABLE IF EXISTS "citySettled";
CREATE TABLE "citySettled" (
  "cityId" INTEGER COLLATE NOCASE,
  "name" VARCHAR (32) NOT NULL COLLATE NOCASE,
  "settledBy" INTEGER NOT NULL COLLATE NOCASE,
  "onTurn" INTEGER NOT NULL COLLATE NOCASE,
  PRIMARY KEY ("cityId"),
  CONSTRAINT "citySettled_leaderId" FOREIGN KEY ("settledBy") REFERENCES "leader" ("leaderId") ON DELETE NO ACTION ON UPDATE NO ACTION
);

-- ----------------------------
-- Table structure for game
-- ----------------------------
DROP TABLE IF EXISTS "game";
CREATE TABLE "game" (
  "gameId" INTEGER COLLATE NOCASE,
  "date" DATE NOT NULL COLLATE NOCASE,
  "difficulty" VARCHAR (32) NOT NULL COLLATE NOCASE,
  "mapType" VARCHAR (32) NOT NULL COLLATE NOCASE,
  "mapSize" VARCHAR (32) NOT NULL COLLATE NOCASE,
  "gameSpeed" VARCHAR (32) NOT NULL COLLATE NOCASE,
  "startEra" VARCHAR (32) NOT NULL COLLATE NOCASE,
  "ruleSet" VARCHAR (32) NOT NULL COLLATE NOCASE,
  PRIMARY KEY ("gameId")
);

-- ----------------------------
-- Table structure for gameCity
-- ----------------------------
DROP TABLE IF EXISTS "gameCity";
CREATE TABLE "gameCity" (
  "gameId" INTEGER NOT NULL COLLATE NOCASE,
  "cityId" INTEGER NOT NULL COLLATE NOCASE,
  CONSTRAINT "gameCity_gameId" FOREIGN KEY ("gameId") REFERENCES "game" ("gameId") ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT "gameCity_cityId" FOREIGN KEY ("cityId") REFERENCES "citySettled" ("cityId") ON DELETE NO ACTION ON UPDATE NO ACTION
);

-- ----------------------------
-- Table structure for gameLeader
-- ----------------------------
DROP TABLE IF EXISTS "gameLeader";
CREATE TABLE "gameLeader" (
  "gameId" INTEGER NOT NULL COLLATE NOCASE,
  "leaderId" INTEGER NOT NULL COLLATE NOCASE,
  "isHuman" BOOLEAN NOT NULL COLLATE NOCASE,
  CONSTRAINT "gameLeader_gameId" FOREIGN KEY ("gameId") REFERENCES "game" ("gameId") ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT "gameLeader_leaderId" FOREIGN KEY ("leaderId") REFERENCES "leader" ("leaderId") ON DELETE NO ACTION ON UPDATE NO ACTION
);

-- ----------------------------
-- Table structure for leader
-- ----------------------------
DROP TABLE IF EXISTS "leader";
CREATE TABLE "leader" (
  "leaderId" INTEGER COLLATE NOCASE,
  "name" VARCHAR (32) NOT NULL COLLATE NOCASE,
  "civ" VARCHAR (32) NOT NULL COLLATE NOCASE,
  "isMajor" BOOLEAN NOT NULL COLLATE NOCASE,
  PRIMARY KEY ("leaderId")
);

-- ----------------------------
-- Table structure for sqlite_stat1
-- ----------------------------
DROP TABLE IF EXISTS "sqlite_stat1";
CREATE TABLE "sqlite_stat1" (
  "tbl",
  "idx",
  "stat"
);

-- ----------------------------
-- View structure for cityPerTurnView
-- ----------------------------
DROP VIEW IF EXISTS "cityPerTurnView";
CREATE VIEW "cityPerTurnView" AS SELECT cptl.cityId,
       cs.name AS cityName,
       l.name AS ownerName,
       l.civ AS ownerCiv,
       cptl.turn,
       cptl.foodPerTurn,
       cptl.foodToolTip,
       cptl.productionPerTurn,
       cptl.productionToolTip,
       cptl.goldPerTurn,
       cptl.goldToolTip,
       cptl.sciencePerTurn,
       cptl.scienceToolTip,
       cptl.culturePerTurn,
       cptl.cultureToolTip,
       cptl.faithPerTurn,
       cptl.faithToolTip,
       cptl.population,
       cptl.housing,
       cptl.amenities,
       cptl.amenitiesNeeded,
       cptl.happiness
FROM cityPerTurnLog cptl
       INNER JOIN
       leader l ON cptl.ownerId = l.leaderId
       INNER JOIN
       citySettled cs ON cptl.cityId = cs.cityId;

-- ----------------------------
-- View structure for gameCityLeaderSettledView
-- ----------------------------
DROP VIEW IF EXISTS "gameCityLeaderSettledView";
CREATE VIEW "gameCityLeaderSettledView" AS SELECT gc.gameId,
       gc.cityId,
       cs.name AS cityName,
       l.name AS leaderName,
       l.leaderId AS leaderId,
       l.civ AS leaderCiv,
       l.isMajor AS isMajorLeader,
       gl.isHuman AS isHumanLeader,
       cs.onTurn AS onTurn
  FROM gameCity gc
       INNER JOIN
       game g ON gc.gameId = g.gameId
       INNER JOIN
       citySettled cs ON gc.cityId = cs.cityId
       JOIN
       leader l ON cs.settledBy = l.leaderId
       JOIN
       gameLeader gl ON g.gameId = gl.gameId AND l.leaderId = gl.leaderId;

-- ----------------------------
-- Indexes structure for table cityPerTurnLog
-- ----------------------------
CREATE UNIQUE INDEX "city_turn_idx"
ON "cityPerTurnLog" (
  "cityId" ASC,
  "turn" ASC
);

-- ----------------------------
-- Indexes structure for table gameCity
-- ----------------------------
CREATE UNIQUE INDEX "game_city_idx"
ON "gameCity" (
  "gameId" ASC,
  "cityId" ASC
);

-- ----------------------------
-- Indexes structure for table leader
-- ----------------------------
CREATE UNIQUE INDEX "name_civ_idx"
ON "leader" (
  "name" ASC,
  "civ" ASC
);

PRAGMA foreign_keys = true;

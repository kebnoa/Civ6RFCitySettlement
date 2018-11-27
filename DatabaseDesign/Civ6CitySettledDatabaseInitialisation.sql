--
-- File generated with SQLiteStudio v3.2.1 on Sat Nov 24 23:15:28 2018
--
-- Text encoding used: UTF-8
--
PRAGMA foreign_keys = off;
BEGIN TRANSACTION;

-- Table: cityPerTurnLog
CREATE TABLE cityPerTurnLog (
    cityId            INTEGER       NOT NULL
                                    CONSTRAINT cityPerTurnLog_cityId REFERENCES citySettled (cityId),
    turn              INTEGER       NOT NULL,
    ownerId           INTEGER       CONSTRAINT cityPerTurnLog_leaderId REFERENCES citySettled (cityId) 
                                    NOT NULL,
    foodPerTurn       REAL          NOT NULL,
    foodToolTip       VARCHAR (256),
    productionPerTurn REAL          NOT NULL,
    productionToolTip VARCHAR (256),
    goldPerTurn       REAL          NOT NULL,
    goldToolTip       VARCHAR (256),
    sciencePerTurn    REAL          NOT NULL,
    scienceToolTip    VARCHAR (256),
    culturePerTurn    REAL          NOT NULL,
    cultureToolTip    VARCHAR (256),
    faithPerTurn      REAL          NOT NULL,
    faithToolTip      VARCHAR (256),
    population        INTEGER       NOT NULL,
    amenities         INTEGER       NOT NULL,
    amenitiesNeeded   INTEGER       NOT NULL,
    happiness         VARCHAR (32)  NOT NULL
);


-- Table: cityPlotsSettled
CREATE TABLE cityPlotsSettled (
    plotId        INTEGER      PRIMARY KEY,
    ownerCityId   INTEGER      CONSTRAINT cityPlotsSettled_ownerCityId REFERENCES citySettled (cityId) 
                               NOT NULL,
    ring          INTEGER      NOT NULL,
    idx           INTEGER      NOT NULL,
    terrain       VARCHAR (32) NOT NULL,
    feature       VARCHAR (32) NOT NULL,
    resource      VARCHAR (32) NOT NULL,
    resourceCount INTEGER      NOT NULL,
    resourceType  VARCHAR (32) NOT NULL,
    workers       INTEGER      NOT NULL,
    district      VARCHAR (32) NOT NULL,
    hasRiver      BOOLEAN      NOT NULL,
    isWater       BOOLEAN      NOT NULL,
    isLake        BOOLEAN      NOT NULL,
    isCity        BOOLEAN      NOT NULL
);


-- Table: citySettled
CREATE TABLE citySettled (
    cityId    INTEGER      PRIMARY KEY,
    name      VARCHAR (32) NOT NULL,
    settledBy INTEGER      NOT NULL
                           CONSTRAINT citySettled_leaderId REFERENCES leader (leaderId),
    onTurn    INTEGER      NOT NULL
);


-- Table: game
CREATE TABLE game (
    gameId     INTEGER      PRIMARY KEY,
    date       DATE         NOT NULL,
    difficulty VARCHAR (32) NOT NULL,
    mapType    VARCHAR (32) NOT NULL,
    mapSize    VARCHAR (32) NOT NULL,
    startEra   VARCHAR (32) NOT NULL,
    ruleSet    VARCHAR (32) NOT NULL
);


-- Table: gameCity
CREATE TABLE gameCity (
    gameId INTEGER CONSTRAINT gameCity_gameId REFERENCES game (gameId) 
                   NOT NULL,
    cityId INTEGER CONSTRAINT gameCity_cityId REFERENCES citySettled (cityId) 
                   NOT NULL
);


-- Table: gameLeader
CREATE TABLE gameLeader (
    gameId   INTEGER CONSTRAINT gameLeader_gameId REFERENCES game (gameId) 
                     NOT NULL,
    leaderId INTEGER CONSTRAINT gameLeader_leaderId REFERENCES leader (leaderId) 
                     NOT NULL,
    isHuman  BOOLEAN NOT NULL
);


-- Table: leader
CREATE TABLE leader (
    leaderId INTEGER      PRIMARY KEY,
    name     VARCHAR (32) NOT NULL,
    civ      VARCHAR (32) NOT NULL,
    isMajor  BOOLEAN      NOT NULL
);


-- Index: city_turn_idx
CREATE UNIQUE INDEX city_turn_idx ON cityPerTurnLog (
    cityId,
    turn
);


-- Index: game_city_idx
CREATE UNIQUE INDEX game_city_idx ON gameCity (
    gameId,
    cityId
);


-- Index: name_civ_idx
CREATE UNIQUE INDEX name_civ_idx ON leader (
    name,
    civ
);


COMMIT TRANSACTION;
PRAGMA foreign_keys = on;

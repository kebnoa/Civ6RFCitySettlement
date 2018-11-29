--
-- File generated with SQLiteStudio v3.2.1 on Thu Nov 29 14:46:58 2018
--
-- Text encoding used: UTF-8
--
PRAGMA foreign_keys = off;
BEGIN TRANSACTION;

-- Table: cityPerTurnLog
CREATE TABLE cityPerTurnLog (
    cityId            INTEGER       NOT NULL
                                    COLLATE NOCASE,
    turn              INTEGER       NOT NULL
                                    COLLATE NOCASE,
    ownerId           INTEGER       NOT NULL
                                    COLLATE NOCASE,
    foodPerTurn       REAL          NOT NULL
                                    COLLATE NOCASE,
    foodToolTip       VARCHAR (256) COLLATE NOCASE,
    productionPerTurn REAL          NOT NULL
                                    COLLATE NOCASE,
    productionToolTip VARCHAR (256) COLLATE NOCASE,
    goldPerTurn       REAL          NOT NULL
                                    COLLATE NOCASE,
    goldToolTip       VARCHAR (256) COLLATE NOCASE,
    sciencePerTurn    REAL          NOT NULL
                                    COLLATE NOCASE,
    scienceToolTip    VARCHAR (256) COLLATE NOCASE,
    culturePerTurn    REAL          NOT NULL
                                    COLLATE NOCASE,
    cultureToolTip    VARCHAR (256) COLLATE NOCASE,
    faithPerTurn      REAL          NOT NULL
                                    COLLATE NOCASE,
    faithToolTip      VARCHAR (256) COLLATE NOCASE,
    population        INTEGER       NOT NULL
                                    COLLATE NOCASE,
    housing           INTEGER       NOT NULL
                                    COLLATE NOCASE,
    amenities         INTEGER       NOT NULL
                                    COLLATE NOCASE,
    amenitiesNeeded   INTEGER       NOT NULL
                                    COLLATE NOCASE,
    happiness         VARCHAR (32)  NOT NULL
                                    COLLATE NOCASE,
    CONSTRAINT cityPerTurnLog_cityId FOREIGN KEY (
        cityId
    )
    REFERENCES citySettledLog (cityId) ON DELETE NO ACTION
                                       ON UPDATE NO ACTION,
    CONSTRAINT cityPerTurnLog_leaderId FOREIGN KEY (
        ownerId
    )
    REFERENCES leader (leaderId) ON DELETE NO ACTION
                                 ON UPDATE NO ACTION
);


-- Table: cityPlotsSettled
CREATE TABLE cityPlotsSettled (
    plotId        INTEGER      COLLATE NOCASE,
    ownerCityId   INTEGER      COLLATE NOCASE,
    ring          INTEGER      NOT NULL
                               COLLATE NOCASE,
    terrain       VARCHAR (32) NOT NULL
                               COLLATE NOCASE,
    feature       VARCHAR (32) NOT NULL
                               COLLATE NOCASE,
    resource      VARCHAR (32) NOT NULL
                               COLLATE NOCASE,
    resourceCount INTEGER      NOT NULL
                               COLLATE NOCASE,
    resourceType  VARCHAR (32) NOT NULL
                               COLLATE NOCASE,
    workers       INTEGER      NOT NULL
                               COLLATE NOCASE,
    district      VARCHAR (32) NOT NULL
                               COLLATE NOCASE,
    hasRiver      BOOLEAN      NOT NULL
                               COLLATE NOCASE,
    isWater       BOOLEAN      NOT NULL
                               COLLATE NOCASE,
    isLake        BOOLEAN      NOT NULL
                               COLLATE NOCASE,
    isCity        BOOLEAN      NOT NULL
                               COLLATE NOCASE,
    PRIMARY KEY (
        plotId
    ),
    CONSTRAINT cityPlotsSettled_ownerCityId FOREIGN KEY (
        ownerCityId
    )
    REFERENCES citySettledLog (cityId) ON DELETE NO ACTION
                                       ON UPDATE NO ACTION
);


-- Table: citySettledLog
CREATE TABLE citySettledLog (
    cityId      INTEGER      COLLATE NOCASE,
    name        VARCHAR (32) NOT NULL
                             COLLATE NOCASE,
    settledById INTEGER      NOT NULL
                             COLLATE NOCASE,
    onTurn      INTEGER      NOT NULL
                             COLLATE NOCASE,
    PRIMARY KEY (
        cityId
    ),
    CONSTRAINT citySettled_leaderId FOREIGN KEY (
        settledById
    )
    REFERENCES leader (leaderId) ON DELETE NO ACTION
                                 ON UPDATE NO ACTION
);


-- Table: game
CREATE TABLE game (
    gameId     INTEGER      COLLATE NOCASE,
    date       DATE         NOT NULL
                            COLLATE NOCASE,
    difficulty VARCHAR (32) NOT NULL
                            COLLATE NOCASE,
    mapType    VARCHAR (32) NOT NULL
                            COLLATE NOCASE
                            DEFAULT Continents,
    mapSize    VARCHAR (32) NOT NULL
                            COLLATE NOCASE,
    gameSpeed  VARCHAR (32) NOT NULL
                            COLLATE NOCASE,
    startEra   VARCHAR (32) NOT NULL
                            COLLATE NOCASE,
    ruleSet    VARCHAR (32) NOT NULL
                            COLLATE NOCASE,
    PRIMARY KEY (
        gameId
    )
);


-- Table: gameCity
CREATE TABLE gameCity (
    gameId INTEGER NOT NULL
                   COLLATE NOCASE,
    cityId INTEGER NOT NULL
                   COLLATE NOCASE,
    CONSTRAINT gameCity_gameId FOREIGN KEY (
        gameId
    )
    REFERENCES game (gameId) ON DELETE NO ACTION
                             ON UPDATE NO ACTION,
    CONSTRAINT gameCity_cityId FOREIGN KEY (
        cityId
    )
    REFERENCES citySettledLog (cityId) ON DELETE NO ACTION
                                       ON UPDATE NO ACTION
);


-- Table: gameLeader
CREATE TABLE gameLeader (
    gameId   INTEGER NOT NULL
                     COLLATE NOCASE,
    leaderId INTEGER NOT NULL
                     COLLATE NOCASE,
    isHuman  BOOLEAN NOT NULL
                     COLLATE NOCASE,
    CONSTRAINT gameLeader_gameId FOREIGN KEY (
        gameId
    )
    REFERENCES game (gameId) ON DELETE NO ACTION
                             ON UPDATE NO ACTION,
    CONSTRAINT gameLeader_leaderId FOREIGN KEY (
        leaderId
    )
    REFERENCES leader (leaderId) ON DELETE NO ACTION
                                 ON UPDATE NO ACTION
);


-- Table: leader
CREATE TABLE leader (
    leaderId INTEGER      COLLATE NOCASE,
    name     VARCHAR (32) NOT NULL
                          COLLATE NOCASE,
    civ      VARCHAR (32) NOT NULL
                          COLLATE NOCASE,
    isMajor  BOOLEAN      NOT NULL
                          COLLATE NOCASE,
    PRIMARY KEY (
        leaderId
    )
);


-- Index: city_turn_idx
CREATE UNIQUE INDEX city_turn_idx ON cityPerTurnLog (
    "cityId" ASC,
    "turn" ASC
);


-- Index: game_city_idx
CREATE UNIQUE INDEX game_city_idx ON gameCity (
    "gameId" ASC,
    "cityId" ASC
);


-- Index: name_civ_idx
CREATE UNIQUE INDEX name_civ_idx ON leader (
    "name" ASC,
    "civ" ASC
);


-- View: cityPerTurnView
CREATE VIEW cityPerTurnView AS
    SELECT cptl.cityId,
           gclsv.gameId,
           gclsv.leaderId AS settledById,
           cptl.ownerId AS currentOwnerId,
           gclsv.cityName,
           gclsv.leaderName AS settledByName,
           gclsv.leaderCiv AS settledByCiv,
           l.name AS currentOwnerName,
           l.civ AS currentOwnerCiv,
           gclsv.onTurn AS settledOnTurn,
           cptl.turn AS gameTurn,
           cptl.turn - gclsv.onTurn + 1 AS turns,
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
           gameCityLeaderSettledView gclsv ON cptl.cityId = gclsv.cityId
           LEFT JOIN
           leader l ON cptl.ownerId = l.leaderId;


-- View: gameCityLeaderSettledView
CREATE VIEW gameCityLeaderSettledView AS
    SELECT gc.gameId,
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
           citySettledLog cs ON gc.cityId = cs.cityId
           JOIN
           leader l ON cs.settledById = l.leaderId
           JOIN
           gameLeader gl ON g.gameId = gl.gameId AND 
                            l.leaderId = gl.leaderId;


COMMIT TRANSACTION;
PRAGMA foreign_keys = on;

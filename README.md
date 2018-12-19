# Introduction 

This project uses Machine Learning, specifically a XGBoost Binary Classifier and SHAP Explorer, to determine optimal start city settlement condidions. At least that is the concept.

## High-level findings

![SHAP impact on model Summary](/Analysis/Images/SHAP_summary_01.png)

This diagram summarises the influence the various plots at city settlement have on its eventual prosperity. Simplified, the model recommends the following in order of significance (desireability?):

* 2 or more Grassland (Hills) with Woods tiles are great. (1 is better than none, though)
* 1x Luxury is great. (More than 1 isn't significant, not having one is significantly negative).
* 2x Stone is good. (1 is better than none)
* Bonus resources are good and are significant in this order of preference:
  * 1x Bananas tile.
  * 1x Rice tile, more than 1 isn't significant.
  * 2 or more Wheat tiles.
  * 1x Deer tile
  * 1x Fish tile
* 2x Plains with Woods is good.
* 2x Plains (Hills) with Rainforest is good.
* Minimal, or no, Grassland with Woods tiles are preferable.
* Plains with Rainforest are positive.
* 8 or more Grassland tiles are positive. (Less than this is generally negative)
* 4 or more Grassland (Hills) tiles are positive.
* 1x Coast and Lake tile is marginally positive, more than this is negative.
* Minimal Plains tiles are preferable.
* 1 or more Grassland Mountain tiles are positive
* Not settling next to a River is negative.

Read the full report: [Civ6RFCitySettlement.pdf](Civ6RFCitySettlement.pdf)

## The project contains 3 major components:

1. A Civilization 6 Mod - KebnoaLogger (and an associated Live Tuner Panel)
2. A SQLite database to store the information captured via the Mod
3. A Jupyter/Python based set of workbooks to train and explore a XGBoost model as imput to a Shapley co-operation game theory explanation, using SHAP, of desirable features.

### 1. KebnoaLogger

The mod code (Modbuddy Solution) can be found in the KebnoaLogger folder. All cities, that are settled during the first 3 turns of the game, are recorded. The mod captures information regarding all the tiles within 2 tiles from the city centre. It then also captures the key yields per turn for all those cities.

The data is captured in-game in Json format. To export the data you need to use the Live Tuner panel in the LiveTunerPanel folder to then write the Json to the console where you can copy and paste it.

At this time I do not know of another way to do this, if you know how let me know :-)

### 2. SQLite database

In order to faciliate data processing the per-game, per-city, per-turn data is converted from Json file format to a SQLite compatible form and stored in a database.

Check the [database schema](DatabaseDesign/Civ6CitySettlementDataModel_04.pdf) for more information.

The database can be found in the Analysis/Database folder.

### 3. Jupyter/Python workbooks

The notebooks are numbered in the order they are used.

#### 01 Data Conversion

Convert and import the json based data exported from Civilization 6 into the SQLite database. Uses Json Schema validation to check format is as expected, then loads the data to an in-memory database to verify the contents. If all the checks are passed the data is added to the database.

#### 02 Data Exploration - City Per Turn

Explore the data captured for the city yield. For example the city with the most food, produced very near 1100 Food. This averages nearly 22 Food per turn for 50 turns which is exceptional!

#### 03 Data Exploration - City Plots Settled

Explore what plot distribution looks like. Grassland and Plains are the most common, followed by Plains (Hills).

#### 04 Data Selection - Create features and lables

Extract the per turn yield per city for the first 50 turns. Calculates the cumulative total per yield. We then use this turn 50 total to split the cities into deciles. Then we combine all these individual scores to a city score and then mark the top 25% as being good.

Convert the 19 tiles into a set of categories that can be used by a machine learning algorythm.

Save this to the features and labels csv files for use by XGBoost.

#### 05a Modelling - Create XGBoost model

According to [Kaggle](https://www.kaggle.com/) XGBoost is very successful at creating winning ML Models. After using it I have to agree it is remarkable easy to use and produced a decent model with limited data.

#### 05b Modelling - Tune XGBoost model

Use randomized search cross-validation to improve the model. One interesting observation is that training for optimal Recall and combination of metrics with Recall produced less accurate models than simply tuning for balanced_accuracy/auc. That is, the optimal model based on the available data was foudn by optimising for the Area Under the Curve.

#### 05c Modelling - Explore and evaluate the XGBoost model

Use the SHAP Python module to interpret the model.

## Contribute

**Help gather more data.** The rough guideline is that you need 20 observations per feature. If we used all the available features we need around 1000-1500 observations. At the moment I grouped many features together. That is, I think the model could be improved by gathering more data.

**Improve the Civ 6 mod.** This is the first mod I've written and there are some flaws. For example, I wasn't able to store the state. That is, you need to play all 53-55 turns in one sitting. Also using the Live Tuner to export the Json is not exactly user friendly.

**Review the XGBoost model.** Any recommendations on how to improve the model will be gratefully received.

**Review the model interpretation.** When reading the full report, does the results make sense given your Civilization 6 knowledge.

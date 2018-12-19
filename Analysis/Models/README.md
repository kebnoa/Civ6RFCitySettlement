# Model creation and results log

## 20181219_103330.xgbmodel

### Input parameters

* Feature input is percentage based and excluded grouped bonus resources
* XGBClassifier with 'binary:logistic' objective.
* Used RandomSearchCV with 20 iterations and 10 cross validations.
  * n_estimators = random int between 10 and 300
  * learning_rate = 0.05
  * max_depth = 1, 2, 3, or 4
  * min_child_weight = 1, 2, 3, or 4
  * subsample = random number between 0.0 and 0.3
  * colsample_bytree = random number between 0.7 and 1.0
* Used StratifiedKFold with 10 splits
  * scoring and refit = balanced_accuracy
* XGBClassifier fitted with eval_metric 'auc'

### Results against test set

             Accuracy: 0.772
                Error: 0.228
            Precision: 0.536
                  AUC: 0.753

               Recall: 0.600
    Misclassification: 0.228

    Predicted   0   1  All
    Actual
    0          63  13   76
    1          10  15   25  
    All        73  28  101

### Model features

           base_score:        0.5
              booster:     gbtree
    colsample_bylevel:          1
     colsample_bytree: 0.9679565829535766
                gamma:          0
        learning_rate:       0.05
       max_delta_step:          0
            max_depth:          1
     min_child_weight:          2
              missing:        nan
         n_estimators:        130
               n_jobs:          1
              nthread:       None
            objective: binary:logistic
         random_state:          0
            reg_alpha:          0
           reg_lambda:          1
     scale_pos_weight:          3
                 seed:       None
               silent:       True
            subsample: 0.18394341516375318

## Previous models

All the previous models are flawed for various reason. I have not specified them as it wouldn't serve any useful purpose.
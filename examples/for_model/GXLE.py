import pandas as pd
data_train=pd.read_csv("./trainingset-gxl.csv")
x_train=data_train[["GBSA-Evdw","GBSA-Eele","GBSA-GGB","GBSA-GSA","HB","RT","VDW","HP","HM","HS","charge","C","N","O","F","P","S","Cl","Br","I","heavy atoms","H"]]
y_train=data_train["deltaGexp"]

data_test=pd.read_csv("./test.csv")
x_test=data_test[["GBSA-Evdw","GBSA-Eele","GBSA-GGB","GBSA-GSA","HB","RT","VDW","HP","HM","HS","charge","C","N","O","F","P","S","Cl","Br","I","heavy atoms","H"]]

from sklearn.preprocessing import StandardScaler
transfer=StandardScaler()
x_train=transfer.fit_transform(x_train)
x_test=transfer.fit_transform(x_test)

from sklearn.ensemble import ExtraTreesRegressor
import numpy as np
params={'n_estimators':50,'random_state':np.random.RandomState(1)}
estimator=ExtraTreesRegressor(**params)
# estimator.fit(x_train,y_train)

import joblib
# joblib.dump(estimator,"E:/github/for_model/GXLE.pkl")
estimator=joblib.load("./GXLE.pkl")

y_pre=estimator.predict(x_test)
data_test["Pre"]=y_pre
data_test.to_csv("./results.csv")
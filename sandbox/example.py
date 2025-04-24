# reticulate::use_virtualenv("BCCenv", required = TRUE)
import pandas as pd
columns = ["var", "skew", "curt", "entr", "class"]
data = pd.read_csv("data_banknote_authentication.txt", names = columns)
data = data[["skew", "curt", "class"]]

dataPos = data[data["class"]==1]
dataNeg = data[data["class"]==0]
Training = pd.concat([dataPos.iloc[0:200], dataNeg.iloc[0:200]])
X = Training[["skew", "curt"]].to_numpy()
y = Training["class"].to_numpy()

from BayesCCal import calibrator_binary
from sklearn.linear_model import LogisticRegression

clf = LogisticRegression(random_state=0)
cclf = calibrator_binary(clf).fit(X,y)

Test = pd.concat([dataPos.iloc[200:].sample(n=100), dataNeg.iloc[200:].sample(n=400)])
Xtest = Test[["skew", "curt"]].to_numpy()
ytest = Test["class"].to_numpy()


print("predicted positives: ", sum(cclf.predict(Xtest)))

print("originally predicted:", sum(clf.predict(Xtest)))

from sklearn.datasets import load_iris
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score

X, y = load_iris(return_X_y=True)
Xtr, Xte, ytr, yte = train_test_split(X, y, test_size=0.2, random_state=0)
model = LogisticRegression(max_iter=1000).fit(Xtr, ytr)
print("Accuracy:", accuracy_score(yte, model.predict(Xte)))

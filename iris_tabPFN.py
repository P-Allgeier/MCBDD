from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
from tabpfn import TabPFNClassifier

# We use the scikit iris dataset because it's included in scikit-learn lmao
X, y = load_iris(return_X_y=True)

print(f"Dataset shape: {X.shape}")
print(f"Classes: {set(y)}")

X_train, X_test, y_train, y_test = train_test_split(
    X,
    y,
    test_size=0.2,
    random_state=42
)

clf = TabPFNClassifier()
clf.fit(X_train, y_train)
predictions = clf.predict(X_test)
accuracy = accuracy_score(y_test, predictions)

print("Predictions:", predictions[:10])
print("Accuracy:", accuracy)
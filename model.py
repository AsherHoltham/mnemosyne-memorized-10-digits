#accuracy: 0.9899 - loss: 0.0312 - val_accuracy: 0.9775 - val_loss: 0.0919

import json
import numpy as np
from tensorflow.keras.datasets import mnist
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense
from tensorflow.keras.utils import to_categorical

(x_train, y_train), (x_test, y_test) = mnist.load_data()
x_train = x_train.reshape(-1, 28*28).astype("float32") / 255.0
x_test  = x_test .reshape(-1, 28*28).astype("float32") / 255.0
y_train = to_categorical(y_train, 10)
y_test  = to_categorical(y_test, 10)

model = Sequential([
    Dense(512, activation="relu", input_shape=(784,)),
    Dense(256, activation="relu"),
    Dense(128, activation="relu"),
    Dense(10 , activation="softmax"),
])

model.compile(
    optimizer="adam",
    loss="categorical_crossentropy",
    metrics=["accuracy"],
)

model.fit(
    x_train, y_train,
    epochs=5,
    batch_size=128,
    validation_split=0.1,
    verbose=2
)

out = {}
for idx, layer in enumerate(model.layers):
    w, b = layer.get_weights()
    out[f"layer_{idx}_weights"] = w.tolist()
    out[f"layer_{idx}_biases"]  = b.tolist()

with open("mnist_weights.json", "w") as f:
    json.dump(out, f)

print("✅ Saved weights & biases to mnist_weights.json")

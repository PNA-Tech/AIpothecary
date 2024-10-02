import json
import tensorflow as tf
from pathlib import Path

dataset_path = Path("C:/Users/achar/OneDrive/Documents/GitHub/healthassistant/ML/tf/train/")
annotations_path = 'C:/Users/achar/OneDrive/Documents/GitHub/healthassistant/ML/tf/annotations/_coco.json'
with open(annotations_path, 'r') as f:
    coco_data = json.load(f)

# conversion
images = {img['id']: img['file_name'] for img in coco_data['images']}
annotations = {img['id']: [] for img in coco_data['images']}

for annotation in coco_data['annotations']:
    annotations[annotation['image_id']].append(annotation)

data_augmentation = tf.keras.Sequential([
    tf.keras.layers.RandomFlip("horizontal_and_vertical"),
    tf.keras.layers.RandomRotation(0.2),
    tf.keras.layers.RandomZoom(0.2),
])

# preprocessing
def preprocess_image(image_path, label, target_size=(224, 224)):
    img = tf.io.read_file(image_path)
    img = tf.image.decode_jpeg(img, channels=3)
    img = tf.image.resize(img, target_size)
    img = img / 255.0
    img = data_augmentation(img)
    return img, label

# load everything
def load_data():
    image_paths = []
    labels = []

    for image_id, annotations_list in annotations.items():
        image_path = dataset_path / images[image_id]
        for annotation in annotations_list:
            category_id = annotation['category_id'] - 1
            image_paths.append(str(image_path))
            labels.append(category_id)
    
    dataset = tf.data.Dataset.from_tensor_slices((image_paths, labels))
    dataset = dataset.map(preprocess_image)
    return dataset

dataset = load_data()
dataset = dataset.batch(32).shuffle(buffer_size=100)

# nn model
model = tf.keras.Sequential([
    tf.keras.layers.InputLayer(input_shape=(224, 224, 3)),
    tf.keras.layers.Conv2D(32, (3, 3), activation='relu',
                           kernel_regularizer=tf.keras.regularizers.l2(0.001)),
    tf.keras.layers.MaxPooling2D(),
    tf.keras.layers.Conv2D(64, (3, 3), activation='relu',
                           kernel_regularizer=tf.keras.regularizers.l2(0.001)),
    tf.keras.layers.MaxPooling2D(),
    tf.keras.layers.Conv2D(128, (3, 3), activation='relu',
                           kernel_regularizer=tf.keras.regularizers.l2(0.001)),
    tf.keras.layers.MaxPooling2D(),
    tf.keras.layers.Flatten(),
    tf.keras.layers.Dense(128, activation='relu',
                          kernel_regularizer=tf.keras.regularizers.l2(0.001)),
    tf.keras.layers.Dense(6, activation='softmax')  # Output layer for 6 classes
])

lr_schedule = tf.keras.optimizers.schedules.ExponentialDecay(
    initial_learning_rate=1e-3,
    decay_steps=10000,
    decay_rate=0.9)

optimizer = tf.keras.optimizers.Adam(learning_rate=lr_schedule)

model.compile(optimizer=optimizer,
              loss='sparse_categorical_crossentropy',
              metrics=['accuracy'])

# prevent overfitting
early_stopping = tf.keras.callbacks.EarlyStopping(
    monitor='loss', patience=3, restore_best_weights=True)

# train!
print("Starting training...")
model.fit(dataset, epochs=5, callbacks=[early_stopping])

# convert keras to tflite
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

with open("model.tflite", "wb") as f:
    f.write(tflite_model)

print("Model successfully converted to TensorFlow Lite and saved at 'model.tflite'")

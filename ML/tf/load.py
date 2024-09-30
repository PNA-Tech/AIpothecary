import tensorflow as tf
import tensorflow_datasets as tfds

# Load the COCO dataset using TensorFlow datasets
dataset, info = tfds.load('coco/2017', split='train', with_info=True)

# Preprocessing function
def preprocess(image, label):
    # Resize and normalize image
    image = tf.image.resize(image, (300, 300))
    image = tf.cast(image, tf.float32) / 255.0
    return image, label

# Prepare the dataset
dataset = dataset.map(lambda x: (x['image'], x['objects']['label']))
dataset = dataset.map(preprocess)
dataset = dataset.batch(32)

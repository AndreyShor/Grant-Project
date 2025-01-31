import os
import pandas as pd
import numpy as np
import torch
import joblib
from transformers import DistilBertTokenizer, DistilBertModel
from sklearn.preprocessing import LabelEncoder, StandardScaler
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
from tensorflow.keras import layers, models, regularizers

#tensorFlow Setup (install tensorflow 2.10 and under for gpu training)

os.environ["TF_GPU_ALLOCATOR"] = "cuda_malloc_async"
import tensorflow as tf

#enable Mixed Precision (for speedup on GPU)
tf.keras.mixed_precision.set_global_policy('mixed_float16')

gpus = tf.config.list_physical_devices('GPU')
if gpus:
    try:
        tf.config.experimental.set_memory_growth(gpus[0], True)
        print("Enabled TensorFlow memory growth on GPU.")
    except RuntimeError as e:
        print("Could not set memory growth:", e)


#load Data

FILE_PATH = "cleaned_no_duplicates.csv"
df = pd.read_csv(FILE_PATH, low_memory=False)

df.rename(columns=lambda x: x.replace(" ", "_").replace(":", "_"), inplace=True)
TARGET_COL = 'Amount_Awarded'

print(f"Initial number of rows: {len(df)}")

#filter out zero/negative targets
df = df[df[TARGET_COL] > 0].copy()
print(f"After filtering targets <= 0, rows left: {len(df)}")


#convert mixed-type columns to numeric (keep missing values)

maybe_mixed_indices = [10, 11, 18, 21]
for idx in maybe_mixed_indices:
    if idx < len(df.columns):
        colname = df.columns[idx]
        df[colname] = pd.to_numeric(df[colname], errors='coerce').fillna(-1)  #fill NaN with -1 instead of dropping
        print(f"Converted column '{colname}' to numeric. Missing values filled.")


#drop Low-Importance Columns
DROP_COLS = ['Currency', 'Award_type', 'Number_of_recipients', 'Recipient_Org_Charity_Number']
df.drop(columns=[c for c in DROP_COLS if c in df.columns], inplace=True)
print(f"After dropping low-importance columns, rows left: {len(df)}, columns: {df.shape[1]}")


#handle 'Description' column
if 'Description' in df.columns:
    text_series = df['Description'].astype(str).fillna("No description provided")
    df.drop(columns=['Description'], inplace=True)
else:
    text_series = pd.Series(["No description provided"] * len(df))


#label encode categorical columns
cat_cols = df.select_dtypes(include='object').columns.tolist()
label_encoders = {}
for col in cat_cols:
    le = LabelEncoder()
    df[col] = le.fit_transform(df[col].astype(str))
    label_encoders[col] = le

print(f"After label encoding, rows left: {len(df)}")


#log transform target
df['log_target'] = np.log1p(df[TARGET_COL])
y = df['log_target'].values

#scale Numeric Columns

numeric_cols = df.select_dtypes(include=[np.number]).columns.tolist()
for rm_col in [TARGET_COL, 'log_target']:
    if rm_col in numeric_cols:
        numeric_cols.remove(rm_col)

scaler = StandardScaler()
df[numeric_cols] = scaler.fit_transform(df[numeric_cols])
print(f"After scaling numeric cols, rows left: {len(df)}")


# Generate BERT Embeddings (From Bert Documentation)
device = "cuda" if torch.cuda.is_available() else "cpu"
print(f"Using device: {device}")

tokenizer = DistilBertTokenizer.from_pretrained("distilbert-base-uncased")
bert_model = DistilBertModel.from_pretrained("distilbert-base-uncased").to(device)
bert_model.eval()

def get_bert_embedding(text_batch):
    inputs = tokenizer(text_batch, truncation=True, padding=True, max_length=32, return_tensors="pt")
    input_ids = inputs["input_ids"].to(device)
    attention_mask = inputs["attention_mask"].to(device)
    with torch.no_grad():
        outputs = bert_model(input_ids, attention_mask=attention_mask)
        cls_embed = outputs.last_hidden_state[:, 0, :]
    return cls_embed.cpu().numpy()

#batch processing
batch_size_bert = 4096  #my 3080 10gb fits 4096 batch size perfectly using 8.7 gb
text_list = text_series.tolist()
all_embs = [get_bert_embedding([text]) for text in text_list]
all_embeddings = np.vstack(all_embs).astype(np.float32)

torch.cuda.empty_cache()


#splitting the train and test data
X_combined = np.concatenate([df.drop(columns=[TARGET_COL, 'log_target']).values, all_embeddings], axis=1)
X_train, X_test, y_train, y_test = train_test_split(X_combined, y, test_size=0.2, random_state=42)


#train mlp model (optimized)

model = tf.keras.Sequential([
    layers.Input(shape=(X_train.shape[1],)),
    layers.Dense(512, activation='leaky_relu', kernel_regularizer=regularizers.l2(0.01)),
    layers.BatchNormalization(),
    layers.Dropout(0.15),
    layers.Dense(512, activation='leaky_relu', kernel_regularizer=regularizers.l2(0.01)),
    layers.BatchNormalization(),
    layers.Dropout(0.15),
    layers.Dense(1)  #predicting log_target
])

opt = tf.keras.optimizers.Adam(learning_rate=1e-4)  #lowered the learning rate for longer training (hopefully more accurate)
model.compile(optimizer=opt, loss='mse', metrics=['mae'])

early_stop = tf.keras.callbacks.EarlyStopping(monitor='val_loss', patience=50, restore_best_weights=True)

model.fit(X_train, y_train, validation_split=0.2, epochs=200, batch_size=2048, callbacks=[early_stop], verbose=1)

#save model

model.save("bert2/bert_model.h5")
joblib.dump(label_encoders, "bert2/bert_label_encoders.pkl")
joblib.dump(scaler, "bert2/bert_scaler.pkl")
joblib.dump(numeric_cols, "bert2/bert_numeric_cols.pkl")

print("Training complete and model saved.")

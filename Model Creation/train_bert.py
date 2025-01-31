import os
import pandas as pd
import numpy as np
import torch
import joblib
from transformers import DistilBertTokenizer, DistilBertModel
from sklearn.preprocessing import LabelEncoder, StandardScaler
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
from tensorflow.keras import layers, models

# set tensorflow to gpu (must be tensorflow 3.10 or under on windows)
os.environ["TF_GPU_ALLOCATOR"] = "cuda_malloc_async"
import tensorflow as tf

gpus = tf.config.list_physical_devices('GPU')
if gpus:
    try:
        tf.config.experimental.set_memory_growth(gpus[0], True)
        print("Enabled TF memory growth on GPU.")
    except RuntimeError as e:
        print("Could not set memory growth:", e)




#lLoad data

FILE_PATH = "cleaned_no_duplicates.csv"
df = pd.read_csv(FILE_PATH, low_memory=False)

df.rename(columns=lambda x: x.replace(" ", "_").replace(":", "_"), inplace=True)
TARGET_COL = 'Amount_Awarded'

#debug row count
# initial_len = len(df)
# print(f"Initial number of rows: {initial_len}")

#filter out zero/negative targets

df = df[df[TARGET_COL] > 0].copy()
print(f"After filtering targets <= 0, rows left: {len(df)}")


#convert known mixed-type columns to numeric (but keep rows)

maybe_mixed_indices = [10, 11, 18, 21]
for idx in maybe_mixed_indices:
    if idx < len(df.columns):
        colname = df.columns[idx]
        df[colname] = pd.to_numeric(df[colname], errors='coerce').fillna(-1)  # **Use -1 instead of dropping**
        print(f"Converted column '{colname}' to numeric. Missing values filled.")


#drop Rows Where More Than 80% of Columns Are Missing

row_threshold = int(len(df.columns) * 0.2)  #setting threshold for rows
df.dropna(thresh=row_threshold, inplace=True)
print(f"After dropping rows with too many NaNs, rows left: {len(df)}")


#drop low-importance columns (feature selection)

DROP_COLS = ['Currency', 'Award_type', 'Number_of_recipients', 'Recipient_Org_Charity_Number']
df.drop(columns=[c for c in DROP_COLS if c in df.columns], inplace=True)
print(f"After dropping low-importance columns, rows left: {len(df)}, columns: {df.shape[1]}")

# =========================================================
#handle 'Description' Column (bert requires it , its in documentation)

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


if len(df) > 0:
    df['log_target'] = np.log1p(df[TARGET_COL])
else:
    raise ValueError("No rows left for log transformation.")

y = df['log_target'].values


#scaling numeric columns

numeric_cols = df.select_dtypes(include=[np.number]).columns.tolist()
for rm_col in [TARGET_COL, 'log_target']:
    if rm_col in numeric_cols:
        numeric_cols.remove(rm_col)

scaler = StandardScaler()
df[numeric_cols] = scaler.fit_transform(df[numeric_cols])
print(f"After scaling numeric cols, rows left: {len(df)}")


#Generate BERT Embeddings( from bert documentation)

device = "cuda" if torch.cuda.is_available() else "cpu"
print("Using device:", device)

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

batch_size_bert = 4096 #fits on my 10gb 3080 at 8.7gb vram usage
text_list = text_series.tolist()

all_embs = []
for i in range(0, len(text_list), batch_size_bert):
    batch_texts = text_list[i : i + batch_size_bert]
    emb = get_bert_embedding(batch_texts)
    all_embs.append(emb)

all_embeddings = np.concatenate(all_embs, axis=0).astype(np.float32)
torch.cuda.empty_cache()


#setting train/test split
X_combined = np.concatenate([df.drop(columns=[TARGET_COL, 'log_target']).values, all_embeddings], axis=1)
X_train, X_test, y_train, y_test = train_test_split(X_combined, y, test_size=0.3, random_state=42)

#train mlp
model = tf.keras.Sequential([
    layers.Input(shape=(X_train.shape[1],)),
    layers.Dense(512, activation='relu'),
    layers.BatchNormalization(),
    layers.Dropout(0.1),
    layers.Dense(512, activation='relu'),
    layers.BatchNormalization(),
    layers.Dropout(0.1),
    layers.Dense(1)  #predicting log_target
])

opt = tf.keras.optimizers.Adam(learning_rate=3e-4)
model.compile(optimizer=opt, loss='mse', metrics=['mae'])

early_stop = tf.keras.callbacks.EarlyStopping(monitor='val_loss', patience=250, restore_best_weights=True)

model.fit(X_train, y_train, validation_split=0.2, epochs=500, batch_size=2048, callbacks=[early_stop], verbose=1)


#save model
model.save("bert/bert_model.h5")
joblib.dump(label_encoders, "bert/bert_label_encoders.pkl")
joblib.dump(scaler, "bert/bert_scaler.pkl")
joblib.dump(numeric_cols, "bert/bert_numeric_cols.pkl")

print("Training complete and model saved.")

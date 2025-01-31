import os
import joblib
import numpy as np
import pandas as pd
import tensorflow as tf
import torch
from transformers import DistilBertTokenizer, DistilBertModel

num_rows_to_process = 100  #testing only 100 rows

#load trained model and preprocessing objects
MODEL_PATH = "bert2/bert_model.h5"
LABEL_ENCODERS_PATH = "bert2/bert_label_encoders.pkl"
SCALER_PATH = "bert2/bert_scaler.pkl"
NUMERIC_COLS_PATH = "bert2/bert_numeric_cols.pkl"

#load Trained Model
model = tf.keras.models.load_model(MODEL_PATH)
print("BERT Model Loaded")

#load Preprocessing Objects
label_encoders = joblib.load(LABEL_ENCODERS_PATH)
scaler = joblib.load(SCALER_PATH)
numeric_cols = joblib.load(NUMERIC_COLS_PATH)
print("Preprocessing Objects Loaded")

#load Test Data from CSV
TEST_FILE_PATH = "cleaned_no_duplicates.csv"
df_test = pd.read_csv(TEST_FILE_PATH, low_memory=False)

#ensure column names are consistent
df_test.rename(columns=lambda x: x.replace(" ", "_").replace(":", "_"), inplace=True)

#select relevant columns for testing
required_columns = [
    "Title", "Grant_Programme_Title", "Funding_Org_Name",
    "Recipient_Org_Name", "Amount_Awarded", "Description",
    "Region", "County", "Ward", "Country", "Population"
]

#keep only relevant columns and limit rows
df_test = df_test[required_columns].dropna().reset_index(drop=True)
df_test = df_test.head(num_rows_to_process)

print(f"Loaded {len(df_test)} test samples.")

#keep a copy of actual values before processing
df_test["Actual_Amount_Awarded"] = df_test["Amount_Awarded"]

#ensure missing columns are added with default values (setting all to 0)
for col in numeric_cols:
    if col not in df_test.columns:
        df_test[col] = 0

for col in label_encoders:
    if col not in df_test.columns:
        df_test[col] = "Unknown"

print("All Required Columns Added")

#handle categorical one hot encoding
for col in label_encoders:
    if col in df_test.columns:
        le = label_encoders[col]
        known_classes = set(le.classes_)

        #ensure "Unknown" exists in the encoder
        if "Unknown" not in known_classes:
            le.classes_ = np.append(le.classes_, "Unknown")

        #replace unseen categories with "Unknown"
        df_test[col] = df_test[col].astype(str).apply(lambda x: x if x in known_classes else "Unknown")

        #transform the values
        df_test[col] = le.transform(df_test[col])

print("Categorical Encoding Handled")

#scale numeric features
df_test[numeric_cols] = scaler.transform(df_test[numeric_cols])
print("Numeric Features Scaled")

#generate BERT Embeddings for Descriptions (bert documentation)
device = "cuda" if torch.cuda.is_available() else "cpu"
print(f"Using Device: {device}")

#load DistilBERT Model & Tokenizer (bert documentation)
tokenizer = DistilBertTokenizer.from_pretrained("distilbert-base-uncased")
bert_model = DistilBertModel.from_pretrained("distilbert-base-uncased").to(device)
bert_model.eval()


# Function to Generate BERT Embeddings in Batches
def get_bert_embedding(text_list, batch_size=32):
    all_embeddings = []
    for i in range(0, len(text_list), batch_size):
        batch_texts = text_list[i: i + batch_size]
        inputs = tokenizer(batch_texts, truncation=True, padding=True, max_length=32, return_tensors="pt")
        input_ids = inputs["input_ids"].to(device)
        attention_mask = inputs["attention_mask"].to(device)
        with torch.no_grad():
            outputs = bert_model(input_ids, attention_mask=attention_mask)
            cls_embed = outputs.last_hidden_state[:, 0, :].cpu().numpy()
        all_embeddings.append(cls_embed)
    return np.vstack(all_embeddings).astype(np.float32)


# Generate BERT Embeddings for Test Samples
descriptions = df_test["Description"].astype(str).tolist()
bert_embeddings = get_bert_embedding(descriptions, batch_size=32)

# Drop `Description` Before Merging
df_test.drop(columns=["Description"], inplace=True)

# Ensure embeddings shape matches dataframe row count
if bert_embeddings.shape[0] != df_test.shape[0]:
    raise ValueError(f"Shape mismatch: BERT embeddings ({bert_embeddings.shape}) vs Test Data ({df_test.shape})")

# Convert to float32 and Merge Tabular & BERT Features
X_test = np.concatenate([df_test.values.astype(np.float32), bert_embeddings], axis=1)
print(f"Final Test Dataset Shape: {X_test.shape}")

# Ensure Correct Input Shape for Model
expected_shape = model.input_shape[1]
current_shape = X_test.shape[1]

if current_shape != expected_shape:
    if current_shape > expected_shape:
        X_test = X_test[:, :expected_shape]
        print(f"Trimmed X_test to expected shape: {X_test.shape}")
    else:
        padding = np.zeros((X_test.shape[0], expected_shape - current_shape), dtype=np.float32)
        X_test = np.hstack([X_test, padding])
        print(f"Padded X_test to expected shape: {X_test.shape}")

# Make Predictions for All Test Samples
y_pred_log = model.predict(X_test.astype(np.float32)).flatten()

# Convert Log-Scaled Predictions Back to Original Scale
y_pred = np.expm1(y_pred_log)

# Prevent Negative Predictions
#y_pred = np.maximum(y_pred, 0)

# Debugging: Check if predictions are all zeros
if np.all(y_pred == 0):
    print(
        "WARNING: All predictions are zero! Check if model input shape is correct or try reloading the trained model.")

# Save Actual and Predicted Values to a New CSV File
df_test["Predicted_Amount_Awarded"] = y_pred
output_path = "predicted_funding_limited.csv"
df_test[["Actual_Amount_Awarded", "Predicted_Amount_Awarded"]].to_csv(output_path, index=False)

print(f"Predictions saved to {output_path}")

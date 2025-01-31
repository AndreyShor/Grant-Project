import os
import joblib
import numpy as np
import pandas as pd
import tensorflow as tf
import torch
from transformers import DistilBertTokenizer, DistilBertModel

#load Trained Model and Preprocessing Objects
MODEL_PATH = "bert/bert_model.h5"
LABEL_ENCODERS_PATH = "bert/bert_label_encoders.pkl"
SCALER_PATH = "bert/bert_scaler.pkl"
NUMERIC_COLS_PATH = "bert/bert_numeric_cols.pkl"

#load trained Model
model = tf.keras.models.load_model(MODEL_PATH)
print("BERT Model Loaded")

#load preprocessing Objects
label_encoders = joblib.load(LABEL_ENCODERS_PATH)
scaler = joblib.load(SCALER_PATH)
numeric_cols = joblib.load(NUMERIC_COLS_PATH)
print("Preprocessing Objects Loaded")

#creating a new test sample
test_sample = {
    "Title": "Recovery Premium Grant",
    "Grant_Programme_Title": "Education Grant",
    "Funding_Org_Name": "Department for Education",
    "Recipient_Org_Name": "Highfield Academy",
    "Amount_Awarded": 10875,
    "Description": "Funding for education programs aimed at improving literacy.",
    "Region": "North East",
    "County": "Tyne and Wear",
    "Ward": "Pallion",
    "Country": "England",
    "Population": 277417
}

#converting the sample to a dataframe
test_df = pd.DataFrame([test_sample])
print("Test Sample Created")

#ensuring missing columns are added with default values
for col in numeric_cols:
    if col not in test_df.columns:
        test_df[col] = 0

for col in label_encoders:
    if col not in test_df.columns:
        test_df[col] = "Unknown"

print("All Required Columns Added")

#handle categorical encoding safely
for col in label_encoders:
    if col in test_df.columns:
        le = label_encoders[col]
        known_classes = set(le.classes_)

        #check if any values are unseen
        test_df[col] = test_df[col].astype(str).apply(lambda x: x if x in known_classes else "Unknown")

        #ensure "Unknown" exists in the encoder
        if "Unknown" not in known_classes:
            le.classes_ = np.append(le.classes_, "Unknown")

        #transform the values
        test_df[col] = le.transform(test_df[col])

print("Categorical Encoding Handled")

#scale Numeric Features
test_df[numeric_cols] = scaler.transform(test_df[numeric_cols])
print("Numeric Features Scaled")

#generate BERT Embeddings for Description
device = "cuda" if torch.cuda.is_available() else "cpu"
print(f"Using Device: {device}")

#load DistilBERT Model & Tokenizer (this is from the bert documentation)
tokenizer = DistilBertTokenizer.from_pretrained("distilbert-base-uncased")
bert_model = DistilBertModel.from_pretrained("distilbert-base-uncased").to(device)
bert_model.eval()

# Function to Generate BERT Embeddings (also from bert documentation)
def get_bert_embedding(text_batch):
    inputs = tokenizer(text_batch, truncation=True, padding=True, max_length=32, return_tensors="pt")
    input_ids = inputs["input_ids"].to(device)
    attention_mask = inputs["attention_mask"].to(device)
    with torch.no_grad():
        outputs = bert_model(input_ids, attention_mask=attention_mask)
        cls_embed = outputs.last_hidden_state[:, 0, :]
    return cls_embed.cpu().numpy().astype(np.float32)

#convert description column to BERT embedding
bert_embedding = get_bert_embedding([test_sample["Description"]])

#drop `description` before merging
test_df.drop(columns=["Description"], inplace=True)

#convert to float32 and merge tabular & BERT features
X_test = np.concatenate([test_df.values.astype(np.float32), bert_embedding], axis=1)
print(f"Final Test Sample Shape: {X_test.shape}")

#adjust shape to match model input
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

#make a prediction with safety checks
y_pred_log = model.predict(X_test.astype(np.float32)).flatten()

#convert Log-Scaled Prediction Back to Original Scale (bert documentation)
y_pred = np.expm1(y_pred_log)

#setting all negative predictions to 0
y_pred = np.maximum(y_pred, 0)

#debugging information for analysis
print(f"Raw Log Prediction: {y_pred_log[0]}")
print(f"Final Adjusted Prediction: {y_pred[0]:,.2f} GBP")

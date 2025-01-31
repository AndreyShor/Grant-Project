import joblib
import pandas as pd
import numpy as np

#load pre-trained model
model = joblib.load("lightgbm\lightgbm_model.pkl")
label_encoders = joblib.load("lightgbm\lightgbm_label_encoders.pkl")

#load test data
test_data = pd.DataFrame([
    {
        "Title": "Recovery Premium Grant",
        "Grant_Programme_Title": "Education Grant",
        "Funding_Org_Name": "Department for Education",
        "Recipient_Org_Name": "Highfield Academy",
        "Description": "Funding for education programs aimed at improving literacy.",
        "Region": "North East",
        "County": "Tyne and Wear",
        "Ward": "Pallion",
        "Country": "England",
        "Population": 277417
    }
])

#encode categorical columns
for col in label_encoders:
    if col in test_data.columns:
        le = label_encoders[col]
        test_data[col] = test_data[col].astype(str).map(lambda x: le.transform([x])[0] if x in le.classes_ else 0)

#ensure all features match training
missing_cols = [col for col in model.booster_.feature_name() if col not in test_data.columns]
for col in missing_cols:
    test_data[col] = 0  # fill missing columns

#predict funding amount
predicted_amount = model.predict(test_data)
print(f"Predicted Funding Amount: {predicted_amount[0]:,.2f} GBP")

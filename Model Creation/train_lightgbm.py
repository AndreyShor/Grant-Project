import os
import pandas as pd
import numpy as np
import lightgbm as lgb
import joblib
from sklearn.model_selection import train_test_split, RandomizedSearchCV
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
from sklearn.preprocessing import LabelEncoder

#reduce cpu overhead (honestly didnt work my cpu was still at 100%)
os.environ["OMP_NUM_THREADS"] = "8"
os.environ["MKL_NUM_THREADS"] = "8"


#load and preprocess data
FILE_PATH = "cleaned_no_duplicates.csv"
df = pd.read_csv(FILE_PATH, low_memory=False)

#standardize column names
df.rename(columns=lambda x: x.replace(" ", "_").replace(":", "_"), inplace=True)

#drop irrelevant columns
drop_columns = [
    "Identifier", "Currency", "Award_Date", "Recipient_Org_Identifier",
    "Recipient_Org_Charity_Number", "Recipient_Org_Company_Number",
    "Recipient_Org_Street_Address", "Recipient_Org_City", "Recipient_Org_Country",
    "Recipient_Org_Postal_Code", "Funding_Org_Identifier", "Managed_by__Organisation_Name",
    "Last_modified", "Award_Authority_Act__Authority_Act_Name"
]
df.drop(columns=[col for col in drop_columns if col in df.columns], inplace=True)

#drop missing target values & filter valid data
target_column = "Amount_Awarded"
df = df.dropna(subset=[target_column])
df = df[df[target_column] > 0].reset_index(drop=True)

print(f"Data Loaded. {df.shape[0]} rows and {df.shape[1]} columns remain.")


#one hot encoding categorical variables for regression
categorical_cols = df.select_dtypes(include=["object"]).columns.tolist()
label_encoders = {}

for col in categorical_cols:
    le = LabelEncoder()
    df[col] = le.fit_transform(df[col].astype(str))
    label_encoders[col] = le

print("Categorical Encoding Completed.")



#defining the dataset
X = df.drop(columns=[target_column])
y = df[target_column]

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

print(f"Train-Test Split Done. Training on {X_train.shape[0]} samples.")


#ensuring the model trains with gpu and cpu not just cpu(speedy)
lgb_model = lgb.LGBMRegressor(
    objective="regression",
    boosting_type="gbdt",
    device="gpu",
    gpu_platform_id=0,
    gpu_device_id=0,
    force_col_wise=True,
    max_bin=255,
    n_jobs=8,
    random_state=42
)

#hyperparameter grid (Optimized)
param_grid = {
    "num_leaves": [50, 80, 120, 160],
    "learning_rate": [0.002, 0.005, 0.01],
    "n_estimators": [10000, 15000, 25000],
    "colsample_bytree": [0.8, 1.0],
    "subsample": [0.8, 1.0],
    "max_bin": [255],
    "min_data_in_leaf": [20, 50, 100, 200],
    "reg_alpha": [0, 0.1, 0.5],
    "reg_lambda": [0.1, 0.5, 1.0]
}

grid_search = RandomizedSearchCV(
    lgb_model, param_distributions=param_grid,
    cv=3, scoring="neg_mean_absolute_error",
    n_iter=10, verbose=2, n_jobs=8, random_state=42
)

grid_search.fit(X_train, y_train)

best_lgb = grid_search.best_estimator_
print(f"Best LightGBM Parameters: {grid_search.best_params_}")

def evaluate_model(model, X_test, y_test):
    y_pred = model.predict(X_test)
    mae = mean_absolute_error(y_test, y_pred)
    rmse = np.sqrt(mean_squared_error(y_test, y_pred))
    r2 = r2_score(y_test, y_pred)
    print(f"Model Performance:\nMAE: {mae:.2f}, RMSE: {rmse:.2f}, R²: {r2:.4f}")
    return mae, rmse, r2

mae, rmse, r2 = evaluate_model(best_lgb, X_test, y_test)


#check if the folder exists
os.makedirs("lightgbm", exist_ok=True)
joblib.dump(best_lgb, "lightgbm/lightgbm_model.pkl")
joblib.dump(label_encoders, "lightgbm/lightgbm_label_encoders.pkl")

print("Model and encoders saved for future use.")

import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder, StandardScaler
from sklearn.feature_extraction.text import TfidfVectorizer
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
import joblib

#loading in the datafile
file_path = "cleaned_no_duplicates.csv"
df = pd.read_csv(file_path, low_memory=False)

#rename columns to avoid special chars
df.rename(columns=lambda x: x.replace(" ", "_").replace(":", "_"), inplace=True)

#target column
target_column = 'Amount_Awarded'
df = df.dropna(subset=[target_column])

#drop low-importance columns
drop_columns = ['Currency', 'Award_type', 'Number_of_recipients', 'Recipient_Org_Charity_Number']
df.drop(columns=[c for c in drop_columns if c in df.columns], inplace=True)



#label encode string columns
label_encoders = {}
for col in df.select_dtypes(include='object').columns:
    le = LabelEncoder()
    df[col] = le.fit_transform(df[col].astype(str))
    label_encoders[col] = le

# TF-IDF on "Description"(saw this on bert documentation wanted to test it here)
if 'Description' in df.columns:
    tfidf = TfidfVectorizer(max_features=50)
    tfidf_matrix = tfidf.fit_transform(df['Description'].astype(str))
    tfidf_df = pd.DataFrame(tfidf_matrix.toarray(),
                            columns=[f"desc_tfidf_{i}" for i in range(50)])
    df = pd.concat([df.drop(columns=['Description']), tfidf_df], axis=1)
else:
    tfidf = None

#scale numeric columns
scaler = StandardScaler()
numeric_cols = df.select_dtypes(include=['int64', 'float64']).columns.tolist()
numeric_cols.remove(target_column)
df[numeric_cols] = scaler.fit_transform(df[numeric_cols])


#preparing the dataset
X = df.drop(columns=[target_column]).values
y = df[target_column].values

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.3, random_state=42
)

# =====================================
#building the nn model
#2 hidden layers with 64 neurons each, ReLU activation
model = keras.Sequential([
    layers.Dense(128, activation='relu'),
    layers.Dropout(0.2),
    layers.Dense(128, activation='relu'),
    layers.Dropout(0.2),
    layers.Dense(1)
])


#compile the model (use MSE loss for regression, MAE as a metric) (metrics documentation)
model.compile(
    optimizer=keras.optimizers.Adam(learning_rate=0.001),
    loss='mean_squared_error',
    metrics=['mean_absolute_error']
)

#model training section
history = model.fit(
    X_train, y_train,
    validation_split=0.2, #80% train 20% validation
    epochs=200,            #setting epochs to 200
    batch_size=64,        #64 works really well with 10gb vram
    verbose=1 #outputs logs
)


#evaluation on the test set
y_pred = model.predict(X_test).flatten()

mae = mean_absolute_error(y_test, y_pred)
mse = mean_squared_error(y_test, y_pred)
rmse = np.sqrt(mse)
r2 = r2_score(y_test, y_pred)

print(f"\nNeural Network Performance on Test Set:")
print(f"MAE:  {mae}")
print(f"RMSE: {rmse}")
print(f"R²:   {r2}")


#saving the model and the preprocessors
model.save('nn/nn_model.h5')
print("Neural network model saved to nn_model.h5")

#saving the labelencoders, TF-IDF vectorizer, and scaler (bert documentation)
joblib.dump(label_encoders, 'nn/nn_label_encoders.pkl')
joblib.dump(tfidf, 'nn/nn_tfidf.pkl')
joblib.dump(scaler, 'nn/nn_scaler.pkl')
joblib.dump(numeric_cols, 'nn/nn_numeric_cols.pkl')
print("Preprocessing objects saved.")


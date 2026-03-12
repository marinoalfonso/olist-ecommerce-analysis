"""
load_data.py
------------
Script di caricamento una tantum — popola il database MySQL
con i CSV del dataset Olist Brazilian E-Commerce.

Eseguire una sola volta dopo aver creato le tabelle con 01_setup.sql.
Non rieseguire senza aver prima svuotato le tabelle con TRUNCATE.
"""

import os
import pandas as pd
from sqlalchemy import create_engine
from urllib.parse import quote_plus
from dotenv import load_dotenv

# Carica le variabili dal file .env
load_dotenv()

password = quote_plus(os.getenv("DB_PASSWORD"))
user     = os.getenv("DB_USER")
host     = os.getenv("DB_HOST")
db       = os.getenv("DB_NAME")

engine = create_engine(
    f"mysql+mysqlconnector://{user}:{password}@{host}/{db}"
)

# Percorso della cartella con i CSV
data_path = "data/"

# Dizionario — nome file : nome tabella
files = {
    "olist_customers_dataset.csv":            "customers",
    "olist_products_dataset.csv":             "products",
    "olist_sellers_dataset.csv":              "sellers",
    "product_category_name_translation.csv":  "category_translation",
    "olist_geolocation_dataset.csv":          "geolocation",
    "olist_orders_dataset.csv":               "orders",
    "olist_order_items_dataset.csv":          "order_items",
    "olist_order_payments_dataset.csv":       "order_payments",
    "olist_order_reviews_dataset.csv":        "order_reviews",
}

for filename, table in files.items():
    df = pd.read_csv(data_path + filename)
    df.to_sql(
        table,
        engine,
        if_exists="append",
        index=False,
        chunksize=1000
    )
    print(f"✅ {table} — {len(df):,} righe caricate")
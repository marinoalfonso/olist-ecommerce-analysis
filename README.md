# Olist E-Commerce Analysis

End-to-end data analysis project on the [Olist Brazilian E-Commerce dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce), covering SQL data modelling, exploratory analysis, data visualisation and machine learning.

---

## Project Structure

```
olist-ecommerce-analysis/
│
├── sql/
│   ├── 01_setup.sql            # Database schema — tables and foreign keys
│   ├── 02_exploration.sql      # Orders, payments, top customers
│   ├── 03_delivery.sql         # Delivery delay analysis by state
│   ├── 04_products.sql         # Product rankings, window functions
│   ├── 05_rfm.sql              # RFM customer segmentation
│   └── 06_ml_features.sql      # Feature engineering for ML
│
├── notebooks/
│   └── analysis.ipynb          # Full analysis and visualisations
│
├── output/                     # Generated charts (git-ignored)
│
├── load_data.py                # One-time script to populate MySQL from CSV
├── .env.example                # Environment variables template
├── requirements.txt
├── .gitignore
└── README.md
```

---

## Dataset

The Olist dataset contains anonymised commercial data from a Brazilian e-commerce marketplace, covering orders placed between 2016 and 2018.

| Table | Rows | Description |
|---|---|---|
| customers | 99,441 | Customer registry |
| orders | 99,441 | Order lifecycle and timestamps |
| order_items | 112,650 | Products within each order |
| order_payments | 103,886 | Payment methods and values |
| order_reviews | 99,224 | Customer reviews and scores |
| products | 32,951 | Product catalogue |
| sellers | 3,095 | Seller registry |
| geolocation | 1,000,163 | Zip code coordinates |
| category_translation | 71 | Portuguese to English category names |

> Data source: [Kaggle — Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

---

## Analysis

### 1. Payment Methods
Breakdown of transaction volume and total revenue by payment type (credit card, boleto, voucher, debit card).

### 2. Delivery Performance
Minute-by-state analysis of delivery delays across Brazil, comparing actual vs estimated delivery dates. Identifies states with consistently late deliveries using `DATEDIFF`, `CASE` and `HAVING` filters.

Key finding: Olist systematically overestimates delivery times — the majority of orders arrive before the estimated date. However, northern and northeastern states show late delivery rates above 10%.

### 3. Product Analysis
Top products by revenue within each category, computed using `ROW_NUMBER()` window functions partitioned by category.

### 4. RFM Customer Segmentation
Customers segmented into 7 groups (Champions, Loyal Customers, At Risk, etc.) based on Recency, Frequency and Monetary scores computed with `NTILE(4)`.

Key finding: the majority of customers have frequency = 1, reflecting the one-time purchase nature of the platform. The "At Risk" segment generates the highest total revenue — a signal for re-engagement campaigns.

### 5. Late Delivery Prediction (Machine Learning)
Binary classification model predicting whether an order will be delivered late.

| | Value |
|---|---|
| Model | Random Forest |
| Features | 9 (price, freight, weight, delivery estimate, states, category, installments) |
| Class imbalance handling | `class_weight='balanced'` |
| ROC-AUC | 0.760 |
| Recall (late, default threshold) | 0.16 |
| Recall (late, optimised threshold) | 0.33 |

The decision threshold was optimised from 0.5 to 0.22 to maximise F1 on the minority class. In an e-commerce context, a false negative (missed delay) is more costly than a false positive (unnecessary intervention), justifying a lower threshold despite reduced precision.

Top predictive features: `price`, `freight_value`, `giorni_stimati_consegna`.

---

## Setup

### Prerequisites
- Python 3.12+
- MySQL 8.0+

### Installation

```bash
git clone https://github.com/marinoalfonso/olist-ecommerce-analysis.git
cd olist-ecommerce-analysis

python -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### Database setup

1. Create the database schema in MySQL Workbench:
```sql
source sql/01_setup.sql
```

2. Download the dataset from [Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) and place the CSV files in `data/`

3. Configure your credentials:
```bash
cp .env.example .env
# Edit .env with your MySQL password
```

4. Load the data:
```bash
python load_data.py
```

5. Open the notebook:
```bash
jupyter notebook notebooks/analysis.ipynb
```

---

## Key SQL Concepts Covered

- DDL — `CREATE TABLE`, `ALTER TABLE`, foreign keys, composite primary keys
- Aggregations — `GROUP BY`, `HAVING`, `COUNT`, `SUM`, `AVG`, `ROUND`
- Joins — `INNER JOIN`, `LEFT JOIN` across multiple tables
- Conditional logic — `CASE WHEN`, `IS NULL`, `DATEDIFF`
- Window functions — `ROW_NUMBER()`, `NTILE()`, `AVG() OVER (PARTITION BY)`
- CTEs — multi-step `WITH` clauses for readable complex queries

---

## Tech Stack

| Tool | Purpose |
|---|---|
| MySQL | Relational database |
| MySQL Workbench | SQL client and schema management |
| Python | Analysis and ML |
| pandas | Data manipulation |
| SQLAlchemy | Python–MySQL connection |
| scikit-learn | Machine learning |
| matplotlib / seaborn | Visualisation |
| geopandas | Brazil state map |

---

## License

MIT License — see [LICENSE](LICENSE).  
Dataset by Olist, made available on Kaggle under a CC BY-NC-SA 4.0 license.

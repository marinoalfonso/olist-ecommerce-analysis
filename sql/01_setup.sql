-- ============================================================
-- 01_setup.sql
-- Olist Brazilian E-Commerce — Database setup
-- Crea tutte le tabelle e i vincoli di integrità referenziale
-- ============================================================

CREATE DATABASE IF NOT EXISTS olist;
USE olist;

-- ── Tabelle indipendenti (nessuna foreign key in entrata) ────

CREATE TABLE customers (
    customer_id              VARCHAR(50) PRIMARY KEY,
    customer_unique_id       VARCHAR(50) NOT NULL,
    customer_zip_code_prefix VARCHAR(10),
    customer_city            VARCHAR(100),
    customer_state           CHAR(2)
);

CREATE TABLE products (
    product_id                 VARCHAR(50) PRIMARY KEY,
    product_category_name      VARCHAR(100),
    product_name_lenght        INT,
    product_description_lenght INT,
    product_photos_qty         INT,
    product_weight_g           INT,
    product_length_cm          INT,
    product_height_cm          INT,
    product_width_cm           INT
);

CREATE TABLE sellers (
    seller_id                VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix   VARCHAR(10),
    seller_city              VARCHAR(100),
    seller_state             CHAR(2)
);

CREATE TABLE category_translation (
    product_category_name         VARCHAR(100) PRIMARY KEY,
    product_category_name_english VARCHAR(100)
);

-- Nessuna FK — tabella di riferimento geografico per zip code
CREATE TABLE geolocation (
    geolocation_zip_code_prefix VARCHAR(10),
    geolocation_lat             DECIMAL(18,15),
    geolocation_lng             DECIMAL(18,15),
    geolocation_city            VARCHAR(100),
    geolocation_state           CHAR(2)
);

-- ── Tabelle dipendenti ───────────────────────────────────────

CREATE TABLE orders (
    order_id                      VARCHAR(50) PRIMARY KEY,
    customer_id                   VARCHAR(50) NOT NULL,
    order_status                  VARCHAR(20),
    order_purchase_timestamp      DATETIME,
    order_approved_at             DATETIME,
    order_delivered_carrier_date  DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME
);

-- Primary key composta: un ordine può contenere più prodotti
CREATE TABLE order_items (
    order_id            VARCHAR(50),
    order_item_id       INT,
    product_id          VARCHAR(50),
    seller_id           VARCHAR(50),
    shipping_limit_date DATETIME,
    price               DECIMAL(10,2),
    freight_value       DECIMAL(10,2),
    PRIMARY KEY (order_id, order_item_id)
);

-- Primary key composta: un ordine può avere più metodi di pagamento
CREATE TABLE order_payments (
    order_id             VARCHAR(50),
    payment_sequential   INT,
    payment_type         VARCHAR(20),
    payment_installments INT,
    payment_value        DECIMAL(10,2),
    PRIMARY KEY (order_id, payment_sequential)
);

CREATE TABLE order_reviews (
    review_id               VARCHAR(50),
    order_id                VARCHAR(50),
    review_score            INT,
    review_comment_title    VARCHAR(100),
    review_comment_message  TEXT,
    review_creation_date    DATETIME,
    review_answer_timestamp DATETIME,
    PRIMARY KEY (review_id, order_id)
);

-- ── Foreign key (integrità referenziale) ─────────────────────

ALTER TABLE orders
    ADD CONSTRAINT fk_orders_customers
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id);

ALTER TABLE order_items
    ADD CONSTRAINT fk_items_orders
    FOREIGN KEY (order_id) REFERENCES orders(order_id);

ALTER TABLE order_items
    ADD CONSTRAINT fk_items_products
    FOREIGN KEY (product_id) REFERENCES products(product_id);

ALTER TABLE order_items
    ADD CONSTRAINT fk_items_sellers
    FOREIGN KEY (seller_id) REFERENCES sellers(seller_id);

ALTER TABLE order_payments
    ADD CONSTRAINT fk_payments_orders
    FOREIGN KEY (order_id) REFERENCES orders(order_id);

ALTER TABLE order_reviews
    ADD CONSTRAINT fk_reviews_orders
    FOREIGN KEY (order_id) REFERENCES orders(order_id);

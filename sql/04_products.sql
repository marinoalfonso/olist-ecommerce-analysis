-- ============================================================
-- 04_products.sql
-- Olist Brazilian E-Commerce — Analisi prodotti e categorie
-- Top prodotti per categoria, ranking con window functions
-- ============================================================

USE olist;

-- ── 1. Media pagamenti per stato — GROUP BY vs Window Function ──
-- Confronto tra le due approcci:
-- GROUP BY collassa le righe (una per stato)
-- Window function mantiene tutte le righe aggiungendo la media

-- Con GROUP BY — 27 righe, una per stato
SELECT
    customer_state,
    ROUND(AVG(payment_value), 2) AS media_pagamento_stato
FROM order_payments p
JOIN orders o
    ON p.order_id = o.order_id
JOIN customers c
    ON o.customer_id = c.customer_id
GROUP BY customer_state
ORDER BY media_pagamento_stato DESC;

-- Con window function — tutte le righe con media stato affiancata
SELECT
    o.order_id,
    c.customer_state,
    p.payment_value,
    ROUND(AVG(payment_value) OVER (
        PARTITION BY c.customer_state
    ), 2) AS media_pagamento_stato
FROM order_payments p
JOIN orders o
    ON p.order_id = o.order_id
JOIN customers c
    ON o.customer_id = c.customer_id
LIMIT 20;


-- ── 2. Top 3 prodotti per fatturato in ogni categoria ────────
-- ROW_NUMBER() assegna un ranking all'interno di ogni categoria
-- LEFT JOIN su category_translation per avere il nome in inglese
-- (alcune categorie non hanno traduzione → NULL)

WITH ranked_products AS (
    SELECT
        p.product_category_name,
        t.product_category_name_english,
        p.product_id,
        COUNT(oi.order_id)          AS numero_vendite,
        ROUND(SUM(oi.price), 2)     AS fatturato,
        ROW_NUMBER() OVER (
            PARTITION BY p.product_category_name
            ORDER BY SUM(oi.price) DESC
        )                           AS rank_in_categoria
    FROM order_items oi
    JOIN products p
        ON oi.product_id = p.product_id
    LEFT JOIN category_translation t
        ON p.product_category_name = t.product_category_name
    GROUP BY
        p.product_category_name,
        t.product_category_name_english,
        p.product_id
)
SELECT *
FROM ranked_products
WHERE rank_in_categoria <= 3
ORDER BY product_category_name, rank_in_categoria;


-- ── 3. Categorie senza traduzione ────────────────────────────
-- Identifica le categorie presenti in products ma assenti
-- nella tabella di mapping category_translation

SELECT DISTINCT p.product_category_name
FROM products p
LEFT JOIN category_translation t
    ON p.product_category_name = t.product_category_name
WHERE t.product_category_name IS NULL;

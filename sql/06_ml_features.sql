-- ============================================================
-- 06_ml_features.sql
-- Olist Brazilian E-Commerce — Feature engineering per ML
-- Estrae le feature per la previsione del ritardo di consegna
-- ============================================================

USE olist;

-- ── Late Delivery Prediction — Feature Set ───────────────────
-- Target: in_ritardo = 1 se consegna effettiva > consegna stimata
--
-- Feature utilizzate:
--   customer_state_enc   : stato del cliente (encoded)
--   seller_state_enc     : stato del venditore (encoded)
--   category_enc         : categoria prodotto (encoded)
--   product_weight_g     : peso del prodotto in grammi
--   price                : prezzo del prodotto
--   freight_value        : costo di spedizione
--   payment_installments : numero di rate del pagamento
--   giorni_stimati_consegna : giorni tra acquisto e consegna stimata
--   stesso_stato         : 1 se cliente e venditore sono nello stesso stato
--
-- Note:
--   - Solo ordini con status 'delivered' e data consegna non NULL
--   - payment_sequential = 1 per evitare duplicati da pagamenti multipli
--   - NULL in product_category_name → imputati come 'unknown' in Python
--   - NULL in product_weight_g → imputati con la mediana in Python
-- ─────────────────────────────────────────────────────────────

SELECT
    o.order_id,
    c.customer_state,
    s.seller_state,
    p.product_category_name,
    p.product_weight_g,
    oi.price,
    oi.freight_value,
    op.payment_installments,
    DATEDIFF(
        o.order_estimated_delivery_date,
        o.order_purchase_timestamp
    )                                           AS giorni_stimati_consegna,
    CASE
        WHEN c.customer_state = s.seller_state
        THEN 1 ELSE 0
    END                                         AS stesso_stato,
    CASE
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
        THEN 1 ELSE 0
    END                                         AS in_ritardo
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
JOIN sellers s
    ON oi.seller_id = s.seller_id
JOIN order_payments op
    ON o.order_id = op.order_id
WHERE o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL
    AND op.payment_sequential = 1;


-- ── Analisi distribuzione target ─────────────────────────────
-- Verifica il bilanciamento del dataset prima del training

SELECT
    in_ritardo,
    COUNT(*)                            AS numero_ordini,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS percentuale
FROM (
    SELECT
        CASE
            WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
            THEN 1 ELSE 0
        END AS in_ritardo
    FROM orders o
    WHERE o.order_status = 'delivered'
        AND o.order_delivered_customer_date IS NOT NULL
) AS target_distribution
GROUP BY in_ritardo;

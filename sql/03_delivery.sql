-- ============================================================
-- 03_delivery.sql
-- Olist Brazilian E-Commerce — Analisi tempi di consegna
-- Ritardi, giorni medi di consegna per stato brasiliano
-- ============================================================

USE olist;

-- ── 1. Esplorazione base — giorni di ritardo per ordine ─────
-- Valori negativi = consegna in anticipo rispetto alla stima
-- Valori positivi = consegna in ritardo
-- NULL = ordine non ancora consegnato

SELECT
    order_id,
    order_status,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    DATEDIFF(
        order_delivered_customer_date,
        order_estimated_delivery_date
    ) AS giorni_ritardo
FROM orders
LIMIT 20;


-- ── 2. Analisi ritardi per stato brasiliano ──────────────────
-- Ritardo medio, giorni medi di consegna dal momento dell'acquisto,
-- numero e percentuale di ordini in ritardo per stato
-- Solo ordini effettivamente consegnati (IS NOT NULL)

SELECT
    customer_state,
    COUNT(*)                                         AS numero_ordini,
    ROUND(AVG(DATEDIFF(
        order_delivered_customer_date,
        order_estimated_delivery_date)), 1)          AS ritardo_medio_giorni,
    ROUND(AVG(DATEDIFF(
        order_delivered_customer_date,
        order_purchase_timestamp)), 1)               AS giorni_medi_consegna,
    SUM(CASE
        WHEN order_delivered_customer_date > order_estimated_delivery_date
        THEN 1 ELSE 0 END)                           AS ordini_in_ritardo,
    ROUND(100.0 * SUM(CASE
        WHEN order_delivered_customer_date > order_estimated_delivery_date
        THEN 1 ELSE 0 END) / COUNT(*), 1)            AS percentuale_ritardo
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
WHERE order_delivered_customer_date IS NOT NULL
GROUP BY customer_state
ORDER BY ritardo_medio_giorni DESC;


-- ── 3. Filtro su stati con volume significativo ──────────────
-- HAVING filtra dopo il GROUP BY — non è possibile farlo con WHERE
-- Soglia: almeno 500 ordini e percentuale ritardo > 10%

SELECT
    customer_state,
    COUNT(*)                                         AS numero_ordini,
    ROUND(AVG(DATEDIFF(
        order_delivered_customer_date,
        order_estimated_delivery_date)), 1)          AS ritardo_medio_giorni,
    ROUND(AVG(DATEDIFF(
        order_delivered_customer_date,
        order_purchase_timestamp)), 1)               AS giorni_medi_consegna,
    SUM(CASE
        WHEN order_delivered_customer_date > order_estimated_delivery_date
        THEN 1 ELSE 0 END)                           AS ordini_in_ritardo,
    ROUND(100.0 * SUM(CASE
        WHEN order_delivered_customer_date > order_estimated_delivery_date
        THEN 1 ELSE 0 END) / COUNT(*), 1)            AS percentuale_ritardo
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
WHERE order_delivered_customer_date IS NOT NULL
GROUP BY customer_state
HAVING COUNT(*) >= 500
    AND ROUND(100.0 * SUM(CASE
        WHEN order_delivered_customer_date > order_estimated_delivery_date
        THEN 1 ELSE 0 END) / COUNT(*), 1) > 10
ORDER BY percentuale_ritardo DESC;

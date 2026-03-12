-- ============================================================
-- 02_exploration.sql
-- Olist Brazilian E-Commerce — Analisi esplorativa
-- Distribuzione ordini, metodi di pagamento, top clienti
-- ============================================================

USE olist;

-- ── 1. Distribuzione ordini per stato ───────────────────────
-- Quanti ordini ci sono per ogni stato (delivered, cancelled, ecc.)

SELECT
    order_status,
    COUNT(*) AS numero_ordini
FROM orders
GROUP BY order_status
ORDER BY numero_ordini DESC;


-- ── 2. Analisi metodi di pagamento ──────────────────────────
-- Utilizzo, valore medio e fatturato totale per tipo di pagamento

SELECT
    payment_type,
    COUNT(*)                     AS numero_transazioni,
    ROUND(AVG(payment_value), 2) AS valore_medio,
    ROUND(SUM(payment_value), 2) AS valore_totale
FROM order_payments
WHERE payment_type != 'not_defined'
GROUP BY payment_type
ORDER BY valore_totale DESC;


-- ── 3. Top 20 clienti per numero di ordini e spesa totale ───
-- Usa customer_unique_id per identificare la persona reale
-- (customer_id è univoco per ordine, non per persona)

SELECT
    c.customer_unique_id,
    c.customer_state,
    COUNT(DISTINCT o.order_id)        AS numero_ordini,
    ROUND(SUM(p.payment_value), 2)    AS spesa_totale
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_payments p
    ON o.order_id = p.order_id
GROUP BY
    c.customer_unique_id,
    c.customer_state
ORDER BY numero_ordini DESC
LIMIT 20;


-- ── 4. Verifica clienti senza ordini (LEFT JOIN) ─────────────
-- In Olist i clienti entrano nel db solo al momento dell'acquisto
-- quindi il risultato atteso è zero righe

SELECT
    c.customer_unique_id,
    o.order_id
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

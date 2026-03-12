-- ============================================================
-- 05_rfm.sql
-- Olist Brazilian E-Commerce — RFM Analysis
-- Segmentazione clienti per Recency, Frequency, Monetary value
-- ============================================================

USE olist;

-- ── Logica RFM ───────────────────────────────────────────────
-- Recency  (R): quanto tempo fa ha fatto l'ultimo ordine?
--              Score 4 = acquisto recente (migliore)
--              Score 1 = acquisto lontano nel tempo (peggiore)
--
-- Frequency (F): quante volte ha acquistato?
--              Score 4 = alta frequenza (migliore)
--              Score 1 = bassa frequenza (peggiore)
--
-- Monetary  (M): quanto ha speso in totale?
--              Score 4 = alta spesa (migliore)
--              Score 1 = bassa spesa (peggiore)
--
-- NTILE(4) divide i clienti in 4 gruppi uguali (quartili)
-- Nota: customer_unique_id identifica la persona reale
-- (customer_id è univoco per ordine, non per persona)
-- ─────────────────────────────────────────────────────────────

WITH rfm_base AS (
    -- Step 1: calcola le metriche grezze per ogni cliente
    -- COUNT(DISTINCT order_id) evita duplicati dovuti al JOIN
    -- con order_payments (un ordine può avere più pagamenti)
    SELECT
        c.customer_unique_id,
        MAX(o.order_purchase_timestamp)      AS ultimo_acquisto,
        COUNT(DISTINCT o.order_id)           AS frequenza,
        ROUND(SUM(p.payment_value), 2)       AS spesa_totale
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_payments p
        ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
rfm_scores AS (
    -- Step 2: trasforma le metriche in punteggi 1-4 con NTILE
    SELECT
        customer_unique_id,
        ultimo_acquisto,
        frequenza,
        spesa_totale,
        NTILE(4) OVER (ORDER BY ultimo_acquisto DESC) AS r_score,
        NTILE(4) OVER (ORDER BY frequenza ASC)        AS f_score,
        NTILE(4) OVER (ORDER BY spesa_totale ASC)     AS m_score
    FROM rfm_base
),
rfm_segments AS (
    -- Step 3: assegna il segmento in base alla combinazione di score
    SELECT
        customer_unique_id,
        ultimo_acquisto,
        frequenza,
        spesa_totale,
        r_score,
        f_score,
        m_score,
        CONCAT(r_score, f_score, m_score) AS rfm_combined,
        CASE
            WHEN r_score = 4 AND f_score = 4 AND m_score = 4
                THEN 'Champions'
            WHEN r_score >= 3 AND f_score >= 3
                THEN 'Loyal Customers'
            WHEN r_score = 4 AND f_score <= 2
                THEN 'Recent Customers'
            WHEN r_score >= 3 AND m_score >= 3
                THEN 'Potential Loyalists'
            WHEN r_score <= 2 AND f_score >= 3 AND m_score >= 3
                THEN 'At Risk'
            WHEN r_score = 1 AND f_score = 1
                THEN 'Lost'
            ELSE
                'Needs Attention'
        END AS segmento
    FROM rfm_scores
)
-- Step 4: aggrega per segmento e calcola KPI di business
SELECT
    segmento,
    COUNT(*)                         AS numero_clienti,
    ROUND(AVG(frequenza), 2)         AS freq_media,
    ROUND(AVG(spesa_totale), 2)      AS spesa_media,
    ROUND(SUM(spesa_totale), 2)      AS fatturato_totale
FROM rfm_segments
GROUP BY segmento
ORDER BY fatturato_totale DESC;

-- ================================================
-- Digital Payment Fraud Risk Analysis
-- File 02: Fraud Overview Analysis
-- Author: Aryan
-- ================================================

-- 1. Fraud breakdown by transaction type
SELECT 
    type,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraud_cases,
    ROUND(SUM(is_fraud)::DECIMAL / COUNT(*) * 100, 4) AS fraud_rate_percent,
    ROUND(SUM(CASE WHEN is_fraud = 1 THEN amount ELSE 0 END), 2) AS fraud_exposure
FROM paysim_transactions
GROUP BY type
ORDER BY fraud_rate_percent DESC;

-- 2. System detection failure analysis
SELECT
    COUNT(*) AS total_fraud_cases,
    SUM(is_flagged_fraud) AS system_flagged,
    SUM(is_fraud) - SUM(is_flagged_fraud) AS missed_by_system,
    ROUND(SUM(is_flagged_fraud)::NUMERIC / SUM(is_fraud) * 100, 2) AS detection_rate_percent,
    ROUND((SUM(is_fraud) - SUM(is_flagged_fraud))::NUMERIC / SUM(is_fraud) * 100, 2) AS missed_rate_percent
FROM paysim_transactions
WHERE is_fraud = 1;

-- 3. Average fraud amount vs legitimate amount
SELECT
    is_fraud,
    COUNT(*) AS total_transactions,
    ROUND(AVG(amount)::NUMERIC, 2) AS avg_amount,
    ROUND(MIN(amount)::NUMERIC, 2) AS min_amount,
    ROUND(MAX(amount)::NUMERIC, 2) AS max_amount
FROM paysim_transactions
GROUP BY is_fraud
ORDER BY is_fraud DESC;

-- 4. Amount bucket analysis - where does fraud concentrate?
SELECT
    CASE 
        WHEN amount < 10000 THEN '1. Below 10K'
        WHEN amount BETWEEN 10000 AND 100000 THEN '2. 10K - 100K'
        WHEN amount BETWEEN 100000 AND 500000 THEN '3. 100K - 500K'
        WHEN amount BETWEEN 500000 AND 1000000 THEN '4. 500K - 1M'
        ELSE '5. Above 1M'
    END AS amount_bucket,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraud_cases,
    ROUND(SUM(is_fraud)::NUMERIC / COUNT(*) * 100, 4) AS fraud_rate_percent
FROM paysim_transactions
GROUP BY amount_bucket
ORDER BY amount_bucket;


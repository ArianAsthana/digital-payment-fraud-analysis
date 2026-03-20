-- 03: Behavioral Patterns
-- 1. Account draining analysis
SELECT
    is_fraud,
    COUNT(*) AS total_transactions,
    SUM(is_fully_drained) AS fully_drained_accounts,
    ROUND(SUM(is_fully_drained)::NUMERIC / COUNT(*) * 100, 2) AS drain_rate_percent
FROM paysim_transactions
GROUP BY is_fraud
ORDER BY is_fraud DESC;

-- 2. Balance before vs after fraud
SELECT
    type,
    ROUND(AVG(old_balance_orig)::NUMERIC, 2) AS avg_balance_before,
    ROUND(AVG(new_balance_orig)::NUMERIC, 2) AS avg_balance_after,
    ROUND(AVG(amount)::NUMERIC, 2) AS avg_fraud_amount
FROM paysim_transactions
WHERE is_fraud = 1
GROUP BY type
ORDER BY avg_fraud_amount DESC;

-- 3. Suspicious destination accounts - repeat fraud recipients
SELECT
    name_dest,
    COUNT(*) AS times_received_fraud,
    ROUND(SUM(amount)::NUMERIC, 2) AS total_received,
    ROUND(AVG(amount)::NUMERIC, 2) AS avg_amount_received
FROM paysim_transactions
WHERE is_fraud = 1
GROUP BY name_dest
HAVING COUNT(*) > 1
ORDER BY times_received_fraud DESC
LIMIT 10;


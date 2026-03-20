-- 04: Trend Analysis using Window Functions
-- 1. Running total of fraud exposure over time steps
SELECT
    step,
    COUNT(*) AS transactions_in_step,
    SUM(is_fraud) AS fraud_in_step,
    SUM(amount * is_fraud) AS fraud_exposure_in_step,
    SUM(SUM(amount * is_fraud)) OVER (ORDER BY step) AS running_fraud_exposure,
    SUM(SUM(is_fraud)) OVER (ORDER BY step) AS running_fraud_count
FROM paysim_transactions
GROUP BY step
ORDER BY step
LIMIT 20;

-- 2. Fraud velocity - which steps have highest fraud concentration
SELECT
    step,
    SUM(is_fraud) AS fraud_count,
    RANK() OVER (ORDER BY SUM(is_fraud) DESC) AS fraud_rank,
    ROUND(SUM(is_fraud)::NUMERIC / COUNT(*) * 100, 4) AS fraud_rate_percent,
    LAG(SUM(is_fraud)) OVER (ORDER BY step) AS prev_step_fraud,
    SUM(is_fraud) - LAG(SUM(is_fraud)) OVER (ORDER BY step) AS fraud_change
FROM paysim_transactions
GROUP BY step
ORDER BY fraud_count DESC
LIMIT 20;

-- 3. Transaction volume vs fraud rate correlation by step
SELECT
    CASE
        WHEN step BETWEEN 1 AND 186 THEN '1. First Quarter'
        WHEN step BETWEEN 187 AND 372 THEN '2. Second Quarter'
        WHEN step BETWEEN 373 AND 558 THEN '3. Third Quarter'
        ELSE '4. Fourth Quarter'
    END AS time_period,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraud_cases,
    ROUND(SUM(is_fraud)::NUMERIC / COUNT(*) * 100, 4) AS fraud_rate_percent,
    ROUND(SUM(CASE WHEN is_fraud = 1 THEN amount ELSE 0 END)::NUMERIC, 2) AS fraud_exposure
FROM paysim_transactions
GROUP BY time_period
ORDER BY time_period;


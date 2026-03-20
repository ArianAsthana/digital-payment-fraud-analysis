-- 05: Risk Scoring Framework
-- Assign risk tiers to every transaction
-- Refined Risk Scoring
WITH risk_scored AS (
    SELECT
        *,
        CASE
            WHEN is_fraud = 1 THEN 'CONFIRMED FRAUD'
            WHEN type IN ('TRANSFER', 'CASH_OUT')
                AND amount > 500000
                AND is_fully_drained = 1
                AND old_balance_orig > 0 THEN 'HIGH RISK'
            WHEN type IN ('TRANSFER', 'CASH_OUT')
                AND amount > 200000
                AND is_fully_drained = 1 THEN 'HIGH RISK'
            WHEN type IN ('TRANSFER', 'CASH_OUT')
                AND amount BETWEEN 100000 AND 500000 THEN 'MEDIUM RISK'
            WHEN type IN ('TRANSFER', 'CASH_OUT')
                AND amount < 100000 THEN 'LOW RISK'
            ELSE 'SAFE'
        END AS risk_tier
    FROM paysim_transactions
),
summary AS (
    SELECT
        risk_tier,
        COUNT(*) AS total_transactions,
        ROUND(COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER () * 100, 2) AS pct_of_total,
        ROUND(SUM(amount)::NUMERIC, 2) AS total_exposure,
        SUM(is_fraud) AS actual_fraud_cases
    FROM risk_scored
    GROUP BY risk_tier
)
SELECT
    *,
    ROUND(actual_fraud_cases::NUMERIC / NULLIF(total_transactions, 0) * 100, 4) AS fraud_rate_in_tier
FROM summary
ORDER BY total_exposure DESC;

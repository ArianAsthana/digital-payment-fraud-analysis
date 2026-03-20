-- ================================================
-- Digital Payment Fraud Risk Analysis
-- File 01: Schema Setup & Data Validation
-- Author: Aryan
-- ================================================

-- Check PaySim table
SELECT 
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS total_fraud,
    ROUND(SUM(is_fraud)::DECIMAL / COUNT(*) * 100, 4) AS fraud_rate_percent,
    SUM(CASE WHEN is_fraud = 1 THEN amount ELSE 0 END) AS total_fraud_exposure
FROM paysim_transactions;

-- Check IEEE table
SELECT 
    COUNT(*) AS total_transactions,
    SUM("isFraud") AS total_fraud,
    ROUND(SUM("isFraud")::DECIMAL / COUNT(*) * 100, 4) AS fraud_rate_percent
FROM ieee_transactions;
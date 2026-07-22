-- ============================================================
-- SQL DATA PERSISTENCE & RELATIONAL AUDIT SUITE
-- Author: Senior QA & Functional Specialist
-- Focus: Multi-table joins, orphaned record detection, and ledger consistency
-- ============================================================

-- 1. Identify Orphaned Transaction Records (Left Join Validation)
-- Purpose: Verify if backend payment records exist without valid registered user profiles.
SELECT 
    t.transaction_id,
    t.user_id,
    t.amount,
    t.status,
    t.created_at
FROM transactions t
LEFT JOIN users u ON t.user_id = u.user_id
WHERE u.user_id IS NULL;

-- 2. Data Reconciliation & Aggregation Audit (GROUP BY & HAVING)
-- Purpose: Audit users whose processed transaction totals do not match recorded balances.
SELECT 
    u.user_id,
    u.email,
    SUM(t.amount) AS calculated_total_spend,
    l.recorded_balance
FROM users u
JOIN transactions t ON u.user_id = t.user_id
JOIN ledger l ON u.user_id = l.user_id
WHERE t.status = 'COMPLETED'
GROUP BY u.user_id, u.email, l.recorded_balance
HAVING SUM(t.amount) <> l.recorded_balance;
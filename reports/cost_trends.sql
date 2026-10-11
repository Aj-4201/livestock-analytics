-- Report: Cost trends (historical, for forecasting input)
-- Params: :tenant_id, :from, :to
-- Monthly income/expense/net plus a simple 3-month moving average.
WITH monthly AS (
  SELECT date_trunc('month', t.occurred_on)::date AS month,
         COALESCE(sum(t.amount) FILTER (WHERE t.txn_type = 'income'), 0)  AS income,
         COALESCE(sum(t.amount) FILTER (WHERE t.txn_type = 'expense'), 0) AS expense
  FROM fct_transaction t
  WHERE t.tenant_id = :tenant_id
    AND t.occurred_on BETWEEN :from AND :to
  GROUP BY 1
)
SELECT month,
       income,
       expense,
       income - expense AS net,
       round(avg(expense) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2)
         AS expense_ma3
FROM monthly
ORDER BY month;

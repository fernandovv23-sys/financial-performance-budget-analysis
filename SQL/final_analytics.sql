WITH revenue_actuals AS (
  SELECT
    DATE_TRUNC(transaction_date, MONTH) AS month,
    SUM(transaction_amount) AS actual_revenue
  FROM `seventh-jet-478719-g8.finance_project.transactions`
  WHERE transaction_amount > 0
  GROUP BY month
),

expense_actuals AS (
  SELECT
    DATE_TRUNC(expense_date, MONTH) AS month,
    department,
    SUM(expense_amount) AS actual_expense
  FROM `seventh-jet-478719-g8.finance_project.expenses`
  WHERE expense_amount > 0
  GROUP BY month, department
),

budget_monthly AS (
  SELECT
    DATE_TRUNC(month, MONTH) AS month,
    department,
    SUM(budgeted_revenue) AS budgeted_revenue,
    SUM(budgeted_expense) AS budgeted_expense
  FROM `seventh-jet-478719-g8.finance_project.budget`
  GROUP BY month, department
)

SELECT
  b.month,
  b.department,
  ROUND(COALESCE(r.actual_revenue, 0), 2) AS actual_revenue,
  ROUND(COALESCE(b.budgeted_revenue, 0), 2) AS budgeted_revenue,

  ROUND(
    COALESCE(r.actual_revenue, 0) - COALESCE(b.budgeted_revenue, 0),
    2
  ) AS revenue_variance,

  ROUND(
    100 * SAFE_DIVIDE(
      COALESCE(r.actual_revenue, 0) - COALESCE(b.budgeted_revenue, 0),
      NULLIF(b.budgeted_revenue, 0)
    ),
    2
  ) AS revenue_variance_pct,
  ROUND(COALESCE(e.actual_expense, 0), 2) AS actual_expense,
  ROUND(COALESCE(b.budgeted_expense, 0), 2) AS budgeted_expense,

  ROUND(
    COALESCE(e.actual_expense, 0) - COALESCE(b.budgeted_expense, 0),
    2
  ) AS expense_variance,

  ROUND(
    100 * SAFE_DIVIDE(
      COALESCE(e.actual_expense, 0) - COALESCE(b.budgeted_expense, 0),
      NULLIF(b.budgeted_expense, 0)
    ),
    2
  ) AS expense_variance_pct

FROM budget_monthly b
LEFT JOIN revenue_actuals r
  ON b.month = r.month
LEFT JOIN expense_actuals e
  ON b.month = e.month
 AND b.department = e.department
ORDER BY b.month, b.department;

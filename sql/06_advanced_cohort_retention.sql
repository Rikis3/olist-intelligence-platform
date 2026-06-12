-- ====================================================================
-- Project: Olist Intelligence Platform
-- Phase 3: Advanced SQL - Cohort Retention
-- Author: Senior Analytics Engineer
-- ====================================================================

WITH first_purchase AS (
  -- Find the month of the first purchase for each customer
  SELECT
    c.customer_unique_id,
    DATE_TRUNC(MIN(d.full_date), MONTH) AS cohort_month
  FROM `project.olist_dwh.fact_orders` f
  JOIN `project.olist_dwh.dim_customers` c ON f.customer_sk = c.customer_sk
  JOIN `project.olist_dwh.dim_date` d ON f.date_sk = d.date_sk
  GROUP BY 1
),

all_purchases AS (
  -- Find the month of all subsequent purchases
  SELECT
    c.customer_unique_id,
    DATE_TRUNC(d.full_date, MONTH) AS purchase_month
  FROM `project.olist_dwh.fact_orders` f
  JOIN `project.olist_dwh.dim_customers` c ON f.customer_sk = c.customer_sk
  JOIN `project.olist_dwh.dim_date` d ON f.date_sk = d.date_sk
  GROUP BY 1, 2
),

cohort_metrics AS (
  -- Calculate the month index (months since first purchase)
  SELECT
    fp.cohort_month,
    ap.purchase_month,
    DATE_DIFF(ap.purchase_month, fp.cohort_month, MONTH) AS month_index,
    COUNT(DISTINCT ap.customer_unique_id) AS active_customers
  FROM first_purchase fp
  JOIN all_purchases ap ON fp.customer_unique_id = ap.customer_unique_id
  GROUP BY 1, 2, 3
)

-- Pivot or display cohort retention
SELECT
  cohort_month,
  month_index,
  active_customers,
  FIRST_VALUE(active_customers) OVER (PARTITION BY cohort_month ORDER BY month_index ASC) AS cohort_size,
  ROUND(
    active_customers / FIRST_VALUE(active_customers) OVER (PARTITION BY cohort_month ORDER BY month_index ASC),
    4
  ) AS retention_rate
FROM cohort_metrics
ORDER BY cohort_month, month_index;

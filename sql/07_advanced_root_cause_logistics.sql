-- ====================================================================
-- Project: Olist Intelligence Platform
-- Phase 3: Advanced SQL - Root Cause Analysis (Logistics vs Churn)
-- Author: Senior Analytics Engineer
-- ====================================================================

-- Hypothesis: SLA breaches (late deliveries) cause 1-star reviews, 
-- which in turn drastically reduces repeat purchase rates.

WITH customer_first_order AS (
  -- Isolate the very first order a customer makes to see if it was breached
  SELECT
    c.customer_unique_id,
    MIN(f.order_id) AS first_order_id,
    MIN(f.purchase_timestamp) AS first_purchase_time
  FROM `project.olist_dwh.fact_fulfillment` f
  JOIN `project.olist_dwh.fact_orders` fo ON f.order_id = fo.order_id
  JOIN `project.olist_dwh.dim_customers` c ON fo.customer_sk = c.customer_sk
  GROUP BY 1
),

first_order_experience AS (
  -- Get the logistics performance and review score of that first order
  SELECT
    cfo.customer_unique_id,
    f.is_sla_breach,
    f.lead_time_days,
    r.review_score,
    CASE WHEN r.review_score <= 2 THEN TRUE ELSE FALSE END AS is_detractor
  FROM customer_first_order cfo
  JOIN `project.olist_dwh.fact_fulfillment` f ON cfo.first_order_id = f.order_id
  LEFT JOIN `project.olist_dwh.fact_reviews` r ON cfo.first_order_id = r.order_id
),

lifetime_behavior AS (
  -- Join with the customer health mart to see if they ever came back
  SELECT
    foe.is_sla_breach,
    foe.is_detractor,
    COUNT(foe.customer_unique_id) AS total_cohort_customers,
    SUM(CASE WHEN mch.is_repeat_customer THEN 1 ELSE 0 END) AS returning_customers
  FROM first_order_experience foe
  JOIN `project.olist_dwh.mart_customer_health` mch ON foe.customer_unique_id = mch.customer_unique_id
  GROUP BY 1, 2
)

-- Final Root Cause Impact
SELECT
  is_sla_breach AS experienced_late_delivery,
  is_detractor AS left_negative_review,
  total_cohort_customers,
  returning_customers,
  ROUND(returning_customers / total_cohort_customers * 100, 2) AS repeat_purchase_rate_percentage
FROM lifetime_behavior
ORDER BY 1, 2;

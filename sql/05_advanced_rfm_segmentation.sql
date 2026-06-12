-- ====================================================================
-- Project: Olist Intelligence Platform
-- Phase 3: Advanced SQL - RFM Segmentation
-- Author: Senior Analytics Engineer
-- ====================================================================

-- Calculate Recency, Frequency, and Monetary value per customer
WITH rfm_base AS (
  SELECT
    customer_unique_id,
    MAX(d.full_date) AS last_purchase_date,
    DATE_DIFF(CURRENT_DATE(), MAX(d.full_date), DAY) AS recency_days,
    COUNT(DISTINCT f.order_id) AS frequency,
    SUM(f.price + f.freight_value) AS monetary
  FROM `project.olist_dwh.fact_orders` f
  JOIN `project.olist_dwh.dim_customers` c ON f.customer_sk = c.customer_sk
  JOIN `project.olist_dwh.dim_date` d ON f.date_sk = d.date_sk
  GROUP BY 1
),

-- Assign quartiles (1-4) for each metric
rfm_scores AS (
  SELECT
    customer_unique_id,
    recency_days,
    frequency,
    monetary,
    NTILE(4) OVER (ORDER BY recency_days DESC) AS r_score, -- 4 is best (most recent)
    NTILE(4) OVER (ORDER BY frequency ASC) AS f_score,     -- 4 is best (highest frequency)
    NTILE(4) OVER (ORDER BY monetary ASC) AS m_score       -- 4 is best (highest spend)
  FROM rfm_base
)

-- Define Business Segments based on RFM score
SELECT
  customer_unique_id,
  recency_days,
  frequency,
  monetary,
  CONCAT(CAST(r_score AS STRING), CAST(f_score AS STRING), CAST(m_score AS STRING)) AS rfm_cell,
  CASE
    WHEN r_score = 4 AND f_score = 4 AND m_score = 4 THEN 'Champions'
    WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal Customers'
    WHEN r_score >= 3 AND f_score <= 2 THEN 'Recent Users'
    WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk (High Value)'
    WHEN r_score = 1 AND f_score <= 2 THEN 'Lost Customers'
    ELSE 'Average Users'
  END AS customer_segment
FROM rfm_scores
ORDER BY m_score DESC, r_score DESC;

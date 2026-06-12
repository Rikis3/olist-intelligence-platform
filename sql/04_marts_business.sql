-- ====================================================================
-- Project: Olist Intelligence Platform
-- Phase 2: DDL/DML - Business Analytical Marts
-- Author: Senior Analytics Engineer
-- ====================================================================

-- --------------------------------------------------------------------
-- Mart 1: Logistics Performance
-- Grain: 1 row per seller per delivery geography
-- --------------------------------------------------------------------
CREATE OR REPLACE TABLE `project.olist_dwh.mart_logistics_performance` AS
SELECT
  f.seller_sk,
  s.state AS seller_state,
  f.geo_sk AS delivery_geo_sk,
  g.state AS delivery_state,
  COUNT(f.order_id) AS total_orders_delivered,
  AVG(f.lead_time_days) AS avg_lead_time_days,
  SUM(CASE WHEN f.is_sla_breach THEN 1 ELSE 0 END) / COUNT(f.order_id) AS sla_breach_rate,
  AVG(r.review_score) AS avg_csat_score
FROM `project.olist_dwh.fact_fulfillment` f
LEFT JOIN `project.olist_dwh.dim_sellers` s ON f.seller_sk = s.seller_sk
LEFT JOIN `project.olist_dwh.dim_geography` g ON f.geo_sk = g.geo_sk
LEFT JOIN (
  SELECT order_id, AVG(review_score) as review_score 
  FROM `project.olist_dwh.fact_reviews` GROUP BY 1
) r ON f.order_id = r.order_id
GROUP BY 1, 2, 3, 4;

-- --------------------------------------------------------------------
-- Mart 2: Revenue Summary
-- Grain: 1 row per Month per Product Category
-- --------------------------------------------------------------------
CREATE OR REPLACE TABLE `project.olist_dwh.mart_revenue_summary` AS
SELECT
  d.year,
  d.month,
  p.category_name,
  COUNT(DISTINCT f.order_id) AS total_orders,
  SUM(f.price) AS net_revenue,
  SUM(f.freight_value) AS total_freight,
  SUM(f.price + f.freight_value) AS gmv,
  SUM(f.price) / COUNT(DISTINCT f.order_id) AS aov
FROM `project.olist_dwh.fact_orders` f
JOIN `project.olist_dwh.dim_date` d ON f.date_sk = d.date_sk
JOIN `project.olist_dwh.dim_products` p ON f.product_sk = p.product_sk
GROUP BY 1, 2, 3;

-- --------------------------------------------------------------------
-- Mart 3: Customer Health & CLV
-- Grain: 1 row per unique customer
-- --------------------------------------------------------------------
CREATE OR REPLACE TABLE `project.olist_dwh.mart_customer_health` AS
WITH customer_orders AS (
  SELECT
    c.customer_sk,
    c.customer_unique_id,
    c.state,
    MIN(d.full_date) AS first_purchase_date,
    MAX(d.full_date) AS last_purchase_date,
    COUNT(DISTINCT f.order_id) AS total_orders,
    SUM(f.price + f.freight_value) AS lifetime_value_gmv
  FROM `project.olist_dwh.fact_orders` f
  JOIN `project.olist_dwh.dim_customers` c ON f.customer_sk = c.customer_sk
  JOIN `project.olist_dwh.dim_date` d ON f.date_sk = d.date_sk
  GROUP BY 1, 2, 3
)
SELECT
  *,
  DATE_DIFF(CURRENT_DATE(), last_purchase_date, DAY) AS days_since_last_purchase,
  CASE WHEN total_orders > 1 THEN TRUE ELSE FALSE END AS is_repeat_customer
FROM customer_orders;

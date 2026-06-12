-- ====================================================================
-- Project: Olist Intelligence Platform
-- Phase 2: DML - Loading Facts (BigQuery Dialect)
-- Author: Senior Analytics Engineer
-- ====================================================================

-- --------------------------------------------------------------------
-- 1. Load fact_orders
-- --------------------------------------------------------------------
INSERT INTO `project.olist_dwh.fact_orders`
SELECT
  TO_HEX(MD5(CONCAT(i.order_id, CAST(i.order_item_id AS STRING)))) AS order_item_sk,
  i.order_id,
  i.order_item_id,
  TO_HEX(MD5(c.customer_unique_id)) AS customer_sk,
  TO_HEX(MD5(i.product_id)) AS product_sk,
  TO_HEX(MD5(i.seller_id)) AS seller_sk,
  CAST(FORMAT_TIMESTAMP('%Y%m%d', o.order_purchase_timestamp) AS INT64) AS date_sk,
  i.price,
  i.freight_value
FROM `project.raw_data.olist_order_items_dataset` i
JOIN `project.raw_data.olist_orders_dataset` o ON i.order_id = o.order_id
JOIN `project.raw_data.olist_customers_dataset` c ON o.customer_id = c.customer_id
WHERE o.order_status NOT IN ('canceled', 'unavailable');

-- --------------------------------------------------------------------
-- 2. Load fact_payments
-- --------------------------------------------------------------------
INSERT INTO `project.olist_dwh.fact_payments`
SELECT
  TO_HEX(MD5(CONCAT(p.order_id, CAST(p.payment_sequential AS STRING)))) AS payment_sk,
  p.order_id,
  TO_HEX(MD5(c.customer_unique_id)) AS customer_sk,
  CAST(FORMAT_TIMESTAMP('%Y%m%d', o.order_purchase_timestamp) AS INT64) AS date_sk,
  p.payment_type,
  p.payment_installments,
  p.payment_value
FROM `project.raw_data.olist_order_payments_dataset` p
JOIN `project.raw_data.olist_orders_dataset` o ON p.order_id = o.order_id
JOIN `project.raw_data.olist_customers_dataset` c ON o.customer_id = c.customer_id;

-- --------------------------------------------------------------------
-- 3. Load fact_reviews
-- --------------------------------------------------------------------
INSERT INTO `project.olist_dwh.fact_reviews`
SELECT
  r.review_id AS review_sk,
  r.order_id,
  TO_HEX(MD5(c.customer_unique_id)) AS customer_sk,
  CAST(FORMAT_TIMESTAMP('%Y%m%d', r.review_creation_date) AS INT64) AS date_sk,
  r.review_score,
  r.review_comment_title AS review_title,
  r.review_comment_message AS review_message
FROM `project.raw_data.olist_order_reviews_dataset` r
JOIN `project.raw_data.olist_orders_dataset` o ON r.order_id = o.order_id
JOIN `project.raw_data.olist_customers_dataset` c ON o.customer_id = c.customer_id;

-- --------------------------------------------------------------------
-- 4. Load fact_fulfillment
-- --------------------------------------------------------------------
INSERT INTO `project.olist_dwh.fact_fulfillment`
SELECT
  TO_HEX(MD5(o.order_id)) AS fulfillment_sk,
  o.order_id,
  TO_HEX(MD5(i.seller_id)) AS seller_sk,
  TO_HEX(MD5(c.customer_zip_code_prefix)) AS geo_sk,
  o.order_purchase_timestamp AS purchase_timestamp,
  o.order_approved_at AS approved_at,
  o.order_delivered_carrier_date AS carrier_delivered_date,
  o.order_delivered_customer_date AS customer_delivered_date,
  o.order_estimated_delivery_date AS estimated_delivery_date,
  DATE_DIFF(DATE(o.order_delivered_customer_date), DATE(o.order_purchase_timestamp), DAY) AS lead_time_days,
  CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN TRUE ELSE FALSE END AS is_sla_breach
FROM `project.raw_data.olist_orders_dataset` o
JOIN `project.raw_data.olist_customers_dataset` c ON o.customer_id = c.customer_id
LEFT JOIN (
  -- Resolving order grain to single primary seller for fulfillment tracking
  SELECT order_id, MIN(seller_id) as seller_id 
  FROM `project.raw_data.olist_order_items_dataset` 
  GROUP BY 1
) i ON o.order_id = i.order_id
WHERE o.order_status = 'delivered';

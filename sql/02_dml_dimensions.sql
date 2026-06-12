-- ====================================================================
-- Project: Olist Intelligence Platform
-- Phase 2: DML - Loading Dimensions (BigQuery Dialect)
-- Author: Senior Analytics Engineer
-- ====================================================================

-- --------------------------------------------------------------------
-- 1. Load dim_customers
-- --------------------------------------------------------------------
INSERT INTO `project.olist_dwh.dim_customers`
SELECT DISTINCT
  TO_HEX(MD5(customer_unique_id)) AS customer_sk,
  customer_unique_id,
  customer_zip_code_prefix AS zip_code_prefix,
  customer_city AS city,
  customer_state AS state
FROM `project.raw_data.olist_customers_dataset`;

-- --------------------------------------------------------------------
-- 2. Load dim_sellers
-- --------------------------------------------------------------------
INSERT INTO `project.olist_dwh.dim_sellers`
SELECT DISTINCT
  TO_HEX(MD5(seller_id)) AS seller_sk,
  seller_id,
  seller_zip_code_prefix AS zip_code_prefix,
  seller_city AS city,
  seller_state AS state
FROM `project.raw_data.olist_sellers_dataset`;

-- --------------------------------------------------------------------
-- 3. Load dim_products
-- --------------------------------------------------------------------
INSERT INTO `project.olist_dwh.dim_products`
SELECT DISTINCT
  TO_HEX(MD5(p.product_id)) AS product_sk,
  p.product_id,
  COALESCE(t.product_category_name_english, p.product_category_name) AS category_name,
  p.product_weight_g AS weight_g,
  p.product_length_cm AS length_cm,
  p.product_height_cm AS height_cm,
  p.product_width_cm AS width_cm
FROM `project.raw_data.olist_products_dataset` p
LEFT JOIN `project.raw_data.product_category_name_translation` t
  ON p.product_category_name = t.product_category_name;

-- --------------------------------------------------------------------
-- 4. Load dim_geography (Deduplicated)
-- --------------------------------------------------------------------
INSERT INTO `project.olist_dwh.dim_geography`
SELECT
  TO_HEX(MD5(geolocation_zip_code_prefix)) AS geo_sk,
  geolocation_zip_code_prefix AS zip_code_prefix,
  ANY_VALUE(geolocation_city) AS city,
  ANY_VALUE(geolocation_state) AS state,
  AVG(geolocation_lat) AS lat,
  AVG(geolocation_lng) AS lng
FROM `project.raw_data.olist_geolocation_dataset`
GROUP BY 1, 2;

-- --------------------------------------------------------------------
-- 5. Load dim_date
-- --------------------------------------------------------------------
INSERT INTO `project.olist_dwh.dim_date`
SELECT
  CAST(FORMAT_DATE('%Y%m%d', d) AS INT64) AS date_sk,
  d AS full_date,
  EXTRACT(YEAR FROM d) AS year,
  EXTRACT(QUARTER FROM d) AS quarter,
  EXTRACT(MONTH FROM d) AS month,
  EXTRACT(ISOWEEK FROM d) AS week,
  EXTRACT(DAYOFWEEK FROM d) AS day_of_week,
  FORMAT_DATE('%A', d) AS day_name,
  IF(EXTRACT(DAYOFWEEK FROM d) IN (1, 7), TRUE, FALSE) AS is_weekend
FROM UNNEST(GENERATE_DATE_ARRAY('2016-01-01', '2019-12-31')) AS d;

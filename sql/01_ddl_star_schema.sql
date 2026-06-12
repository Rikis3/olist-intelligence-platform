-- ====================================================================
-- Project: Olist Intelligence Platform
-- Phase 1: Star Schema DDL (BigQuery Dialect)
-- Author: Senior Analytics Engineer
-- ====================================================================

-- --------------------------------------------------------------------
-- 1. DIMENSIONS
-- --------------------------------------------------------------------

CREATE OR REPLACE TABLE `project.olist_dwh.dim_geography` (
    geo_sk STRING OPTIONS(description="Surrogate key (MD5 hash of zip code)"),
    zip_code_prefix STRING OPTIONS(description="First 5 digits of zip code"),
    city STRING OPTIONS(description="City name"),
    state STRING OPTIONS(description="State code (e.g., SP, RJ)"),
    lat FLOAT64 OPTIONS(description="Latitude coordinate"),
    lng FLOAT64 OPTIONS(description="Longitude coordinate")
)
PARTITION BY state;

CREATE OR REPLACE TABLE `project.olist_dwh.dim_customers` (
    customer_sk STRING OPTIONS(description="Surrogate key (MD5 hash of unique customer id)"),
    customer_unique_id STRING OPTIONS(description="Business key identifying a unique person"),
    zip_code_prefix STRING OPTIONS(description="Customer location"),
    city STRING,
    state STRING
)
CLUSTER BY state;

CREATE OR REPLACE TABLE `project.olist_dwh.dim_sellers` (
    seller_sk STRING OPTIONS(description="Surrogate key (MD5 hash of seller id)"),
    seller_id STRING OPTIONS(description="Business key identifying a seller"),
    zip_code_prefix STRING,
    city STRING,
    state STRING
)
CLUSTER BY state;

CREATE OR REPLACE TABLE `project.olist_dwh.dim_products` (
    product_sk STRING OPTIONS(description="Surrogate key (MD5 hash of product id)"),
    product_id STRING,
    category_name STRING OPTIONS(description="English translation of category"),
    weight_g INT64,
    length_cm INT64,
    height_cm INT64,
    width_cm INT64
)
CLUSTER BY category_name;

CREATE OR REPLACE TABLE `project.olist_dwh.dim_date` (
    date_sk INT64 OPTIONS(description="Format YYYYMMDD"),
    full_date DATE,
    year INT64,
    quarter INT64,
    month INT64,
    week INT64,
    day_of_week INT64,
    day_name STRING,
    is_weekend BOOLEAN
)
CLUSTER BY year, month;

-- --------------------------------------------------------------------
-- 2. FACTS
-- --------------------------------------------------------------------

CREATE OR REPLACE TABLE `project.olist_dwh.fact_orders` (
    order_item_sk STRING OPTIONS(description="Surrogate key (MD5 hash of order_id + order_item_id)"),
    order_id STRING,
    order_item_id INT64,
    customer_sk STRING OPTIONS(description="FK to dim_customers"),
    product_sk STRING OPTIONS(description="FK to dim_products"),
    seller_sk STRING OPTIONS(description="FK to dim_sellers"),
    date_sk INT64 OPTIONS(description="FK to dim_date (Purchase date)"),
    price FLOAT64 OPTIONS(description="Item price"),
    freight_value FLOAT64 OPTIONS(description="Item freight cost")
)
PARTITION BY RANGE_BUCKET(date_sk, GENERATE_ARRAY(20160101, 20181231, 100))
CLUSTER BY customer_sk, product_sk;

CREATE OR REPLACE TABLE `project.olist_dwh.fact_payments` (
    payment_sk STRING OPTIONS(description="Surrogate key (MD5 hash of order_id + seq)"),
    order_id STRING,
    customer_sk STRING OPTIONS(description="FK to dim_customers"),
    date_sk INT64 OPTIONS(description="FK to dim_date"),
    payment_type STRING OPTIONS(description="credit_card, boleto, voucher, debit_card"),
    payment_installments INT64,
    payment_value FLOAT64
)
PARTITION BY RANGE_BUCKET(date_sk, GENERATE_ARRAY(20160101, 20181231, 100))
CLUSTER BY payment_type;

CREATE OR REPLACE TABLE `project.olist_dwh.fact_reviews` (
    review_sk STRING OPTIONS(description="PK - Original review_id"),
    order_id STRING,
    customer_sk STRING,
    date_sk INT64,
    review_score INT64 OPTIONS(description="Score from 1 to 5"),
    review_title STRING,
    review_message STRING
)
CLUSTER BY review_score;

CREATE OR REPLACE TABLE `project.olist_dwh.fact_fulfillment` (
    fulfillment_sk STRING OPTIONS(description="MD5 hash of order_id"),
    order_id STRING,
    seller_sk STRING,
    geo_sk STRING OPTIONS(description="FK to delivery destination"),
    purchase_timestamp TIMESTAMP,
    approved_at TIMESTAMP,
    carrier_delivered_date TIMESTAMP,
    customer_delivered_date TIMESTAMP,
    estimated_delivery_date TIMESTAMP,
    lead_time_days INT64 OPTIONS(description="Days from purchase to customer delivery"),
    is_sla_breach BOOLEAN OPTIONS(description="True if customer_delivered_date > estimated_delivery_date")
);

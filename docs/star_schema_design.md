# Dimensional Model: Star Schema Design

This document details the analytical data model optimized for OLAP querying in BigQuery.

## 1. Dimensions (Conformed)

### `dim_customers`
* **Grain:** 1 row per unique customer (`customer_unique_id`).
* **Keys:** `customer_sk` (Surrogate Key, PK), `customer_unique_id` (Business Key).
* **Attributes:** `zip_code_prefix`, `city`, `state`.
* **Business Purpose:** Analyzing user demographics and performing cohort retention/RFM analysis without duplicating individuals who made multiple purchases under different operational `customer_id`s.

### `dim_products`
* **Grain:** 1 row per product item.
* **Keys:** `product_sk` (PK), `product_id` (BK).
* **Attributes:** `category_name`, `weight_g`, `length_cm`, `height_cm`, `width_cm`.
* **Business Purpose:** Analyzing revenue and freight costs by product category and physical dimensions.

### `dim_sellers`
* **Grain:** 1 row per marketplace seller.
* **Keys:** `seller_sk` (PK), `seller_id` (BK).
* **Attributes:** `zip_code_prefix`, `city`, `state`.
* **Business Purpose:** Analyzing seller fulfillment speed, rating quality, and regional distribution.

### `dim_geography`
* **Grain:** 1 row per unique zip code prefix.
* **Keys:** `geo_sk` (PK), `zip_code_prefix` (BK).
* **Attributes:** `city`, `state`, `lat`, `lng`.
* **Business Purpose:** Spatial analysis of fulfillment networks and regional GMV generation.

### `dim_date`
* **Grain:** 1 row per calendar day.
* **Keys:** `date_sk` (PK), `full_date` (BK).
* **Attributes:** `year`, `quarter`, `month`, `week`, `day_of_week`.
* **Business Purpose:** Standardized time-series analysis (YoY, MoM) across all fact tables.

---

## 2. Fact Tables

### `fact_orders`
* **Grain:** 1 row per order item (Line item level). This allows slicing revenue by product and seller.
* **Keys:** `order_item_sk` (PK), `order_id`, `customer_sk` (FK), `product_sk` (FK), `seller_sk` (FK), `date_sk` (FK).
* **Measures:** `price`, `freight_value`.
* **Business Purpose:** Core financial fact for calculating GMV, Net Revenue, and AOV.

### `fact_payments`
* **Grain:** 1 row per payment transaction.
* **Keys:** `payment_sk` (PK), `order_id` (FK), `customer_sk` (FK), `date_sk` (FK).
* **Measures:** `payment_value`, `payment_installments`.
* **Business Purpose:** Understanding payment method adoption and credit usage.

### `fact_reviews`
* **Grain:** 1 row per submitted review.
* **Keys:** `review_sk` (PK), `order_id` (FK), `customer_sk` (FK), `date_sk` (FK).
* **Measures:** `review_score`.
* **Attributes:** `review_title`, `review_message`.
* **Business Purpose:** Sentiment analysis and CSAT scoring.

### `fact_fulfillment`
* **Grain:** 1 row per distinct order.
* **Keys:** `fulfillment_sk` (PK), `order_id` (FK), `seller_sk` (FK), `geo_sk` (FK).
* **Measures:** `lead_time_days`, `estimated_vs_actual_variance_days`.
* **Attributes:** `is_sla_breach` (BOOLEAN), `order_status`.
* **Business Purpose:** Operational fact for tracking logistics health, SLA breaches, and delivery bottlenecks.

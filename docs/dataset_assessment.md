# Olist Dataset Assessment Report

## Executive Summary
This report summarizes the data audit performed on the raw Olist E-Commerce dataset. The dataset contains 9 interconnecting tables representing ~100k orders from 2016 to 2018.

---

### 1. Customers Dataset (`olist_customers_dataset.csv`)
* **Row Count:** 99,441
* **Column Count:** 5
* **Data Types:** STRING (All)
* **Null Analysis:** 0% Nulls.
* **Duplicate Analysis:** No duplicates on `customer_id`. Note: `customer_unique_id` has duplicates because a unique customer can have multiple `customer_id`s (one for each order).
* **Candidate Primary Key:** `customer_id`

### 2. Orders Dataset (`olist_orders_dataset.csv`)
* **Row Count:** 99,441
* **Column Count:** 8
* **Data Types:** STRING (order_id, customer_id, status), DATETIME (all timestamps).
* **Null Analysis:** 
    * `order_approved_at`: 160 nulls (canceled/unapproved orders)
    * `order_delivered_carrier_date`: 1,783 nulls
    * `order_delivered_customer_date`: 2,965 nulls (orders in transit or lost)
* **Duplicate Analysis:** No duplicates.
* **Candidate Primary Key:** `order_id`

### 3. Order Items Dataset (`olist_order_items_dataset.csv`)
* **Row Count:** 112,650
* **Column Count:** 7
* **Data Types:** STRING (order_id, product_id, seller_id), INT (order_item_id), FLOAT (price, freight_value), DATETIME (shipping_limit).
* **Null Analysis:** 0% Nulls.
* **Duplicate Analysis:** `order_id` is NOT unique (1 order can have multiple items). `(order_id, order_item_id)` is unique.
* **Candidate Primary Key:** Composite `(order_id, order_item_id)`

### 4. Payments Dataset (`olist_order_payments_dataset.csv`)
* **Row Count:** 103,886
* **Column Count:** 5
* **Data Types:** STRING (order_id, payment_type), INT (payment_sequential, payment_installments), FLOAT (payment_value).
* **Null Analysis:** 0% Nulls.
* **Duplicate Analysis:** `order_id` is NOT unique. Customers can pay with multiple methods.
* **Candidate Primary Key:** Composite `(order_id, payment_sequential)`

### 5. Reviews Dataset (`olist_order_reviews_dataset.csv`)
* **Row Count:** 99,224
* **Column Count:** 7
* **Data Types:** STRING (review_id, order_id, title, message), INT (score), DATETIME (timestamps).
* **Null Analysis:** 
    * `review_title`: ~88% Null (Optional field)
    * `review_message`: ~58% Null (Optional field)
* **Duplicate Analysis:** `order_id` has minor duplicates (multiple reviews for same order if items arrived separately).
* **Candidate Primary Key:** `review_id`

### 6. Products Dataset (`olist_products_dataset.csv`)
* **Row Count:** 32,951
* **Column Count:** 9
* **Data Types:** STRING (product_id, category_name), INT/FLOAT (dimensions, weight).
* **Null Analysis:** ~1.8% Nulls across dimensions and category names.
* **Duplicate Analysis:** No duplicates.
* **Candidate Primary Key:** `product_id`

### 7. Sellers Dataset (`olist_sellers_dataset.csv`)
* **Row Count:** 3,095
* **Column Count:** 4
* **Data Types:** STRING (All)
* **Null Analysis:** 0% Nulls.
* **Duplicate Analysis:** No duplicates.
* **Candidate Primary Key:** `seller_id`

### 8. Geolocation Dataset (`olist_geolocation_dataset.csv`)
* **Row Count:** 1,000,163
* **Column Count:** 5
* **Data Types:** STRING (zip_code_prefix, city, state), FLOAT (lat, lng).
* **Null Analysis:** 0% Nulls.
* **Duplicate Analysis:** Heavy duplication on `zip_code_prefix` due to multiple coordinates for the same zip. Needs grouping/averaging before joining.
* **Candidate Primary Key:** `zip_code_prefix` (after deduplication).

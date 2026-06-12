# Data Quality Framework

To ensure trust in the BI platform, we will implement the following data quality checks (simulating a `dbt test` structure).

## 1. Primary Key Checks
Every dimension and fact table must pass `unique` and `not_null` assertions on their surrogate keys (`_sk`).
- **`dim_customers`**: `unique(customer_sk)`, `not_null(customer_sk)`
- **`fact_orders`**: `unique(order_item_sk)`, `not_null(order_item_sk)`

## 2. Referential Integrity Checks
Fact tables must not contain foreign keys that do not exist in the corresponding dimensions.
- **`fact_orders.customer_sk`** must exist in `dim_customers.customer_sk`.
- **`fact_orders.product_sk`** must exist in `dim_products.product_sk`.
- **`fact_orders.seller_sk`** must exist in `dim_sellers.seller_sk`.

## 3. Business Rule Validations

### Order Integrity
- `fact_orders.price` > 0 (Free items are not allowed in this system).
- `fact_orders.freight_value` >= 0.

### Fulfillment Logic
- `fact_fulfillment.customer_delivered_date` >= `fact_fulfillment.purchase_timestamp` (Delivery cannot happen before purchase).
- `fact_fulfillment.is_sla_breach` must be explicitly defined as TRUE if delivered > estimated, else FALSE.

### Review Validity
- `fact_reviews.review_score` must be IN `(1, 2, 3, 4, 5)`.

### Payment Validations
- `fact_payments.payment_installments` >= 1.
- The sum of `payment_value` in `fact_payments` for an `order_id` must closely match the sum of `price + freight_value` in `fact_orders` for the same `order_id` (accounting for rounding or voucher edge cases).

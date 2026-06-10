CREATE VIEW v_funnel AS
SELECT 'purchased' AS stage, 1 AS stage_order,
       COUNT(*) AS n_orders,
       ROUND(100.0 * COUNT(*) / COUNT(*), 2) AS pct_of_top
FROM olist_orders_dataset
UNION ALL
SELECT 'approved', 2,
       COUNT(order_approved_at),
       ROUND(100.0 * COUNT(order_approved_at) / COUNT(*), 2)
FROM olist_orders_dataset
UNION ALL
SELECT 'shipped', 3,
       COUNT(order_delivered_carrier_date),
       ROUND(100.0 * COUNT(order_delivered_carrier_date) / COUNT(*), 2)
FROM olist_orders_dataset
UNION ALL
SELECT 'delivered', 4,
       COUNT(order_delivered_customer_date),
       ROUND(100.0 * COUNT(order_delivered_customer_date) / COUNT(*), 2)
FROM olist_orders_dataset;
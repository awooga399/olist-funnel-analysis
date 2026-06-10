CREATE VIEW v_kpi AS
SELECT
    (SELECT COUNT(*) FROM olist_orders_dataset) AS total_orders,
    (SELECT ROUND(100.0 * COUNT(order_delivered_customer_date) / COUNT(*), 2)
     FROM olist_orders_dataset) AS delivery_rate,
    (SELECT ROUND(100.0 * COUNT(*) FILTER (WHERE oc > 1) / COUNT(*), 2)
     FROM (SELECT c.customer_unique_id, COUNT(o.order_id) AS oc
           FROM olist_customers_dataset c
           JOIN olist_orders_dataset o ON o.customer_id = c.customer_id
           GROUP BY c.customer_unique_id) t) AS repeat_rate;
CREATE VIEW v_rfm AS
WITH customer_orders_table AS(
	SELECT c.customer_unique_id,
	o.order_id, o.order_purchase_timestamp,
	i.price, i.freight_value
	FROM olist_customers_dataset c
	JOIN olist_orders_dataset o ON c.customer_id = o.customer_id
	JOIN olist_order_items_dataset i ON o.order_id = i.order_id
),
frequency AS(
	SELECT customer_unique_id,
	COUNT(DISTINCT order_id) AS frequency
	FROM customer_orders_table
	GROUP BY customer_unique_id
),
monetary AS(
	SELECT customer_unique_id,
	SUM(price + freight_value) AS monetary
	FROM customer_orders_table
	GROUP BY customer_unique_id
),
purch_dates AS(
	SELECT customer_unique_id,
	MAX(order_purchase_timestamp) AS last_purchase
	FROM customer_orders_table
	GROUP BY customer_unique_id
),
recency AS(
	SELECT
    customer_unique_id,
    (SELECT MAX(order_purchase_timestamp)::date FROM olist_orders_dataset)
      - last_purchase::date AS recency
	FROM purch_dates
),
r_f_m AS(
	SELECT 
	f.customer_unique_id,
	f.frequency,
	m.monetary,
	r.recency
	FROM frequency f
	JOIN monetary m ON f.customer_unique_id = m.customer_unique_id
	JOIN recency r ON f.customer_unique_id = r.customer_unique_id
),

rfm_score AS(
	SELECT
	customer_unique_id,
	NTILE(5) OVER(ORDER BY recency DESC) AS r_score,
	NTILE(5) OVER(ORDER BY frequency) AS f_score,
	NTILE(5) OVER(ORDER BY monetary) AS m_score
	FROM r_f_m
),
rfm_segment AS(
	SELECT
	customer_unique_id,
	r_score, f_score, m_score,
	CASE
	    WHEN r_score >= 4 AND m_score >= 4 THEN 'Champions'
	    WHEN m_score >= 4 AND r_score <= 3 THEN 'Big Spenders'
	    WHEN r_score >= 4 AND m_score <= 3 THEN 'Recent'
	    WHEN r_score <= 2 AND m_score <= 2 THEN 'At Risk'
	    ELSE 'Others'
	END AS segment
	FROM rfm_score
	ORDER BY r_score DESC, f_score DESC, m_score DESC
)

SELECT 
rs.segment, 
COUNT(*) AS n_customers,
SUM(m.monetary) AS total_revenue,
ROUND(AVG(m.monetary), 2) AS avg_revenue,
ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS pct_customers,
ROUND(100.0 * SUM(m.monetary) / SUM(SUM(m.monetary)) OVER(), 2) AS pct_revenue
FROM rfm_segment rs
JOIN monetary m ON rs.customer_unique_id = m.customer_unique_id
GROUP BY rs.segment
ORDER BY total_revenue DESC







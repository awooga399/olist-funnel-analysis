CREATE VIEW v_cohorts AS
WITH first_purchase AS(
	SELECT
	    c.customer_unique_id,
	    DATE_TRUNC('month', MIN(o.order_purchase_timestamp)) AS cohort_month
	FROM olist_customers_dataset c
	JOIN olist_orders_dataset o ON o.customer_id = c.customer_id
	GROUP BY c.customer_unique_id
),
month_diff AS(
	SELECT c.customer_unique_id,
	f.cohort_month,
	DATE_TRUNC('month', o.order_purchase_timestamp) AS order_month,
	((EXTRACT(YEAR FROM o.order_purchase_timestamp) - EXTRACT(YEAR FROM f.cohort_month)) * 12 + 
	(EXTRACT(MONTH FROM o.order_purchase_timestamp) - EXTRACT(MONTH FROM f.cohort_month))) AS month_number
	FROM olist_customers_dataset c
	JOIN first_purchase f ON c.customer_unique_id = f.customer_unique_id
	JOIN olist_orders_dataset o ON c.customer_id = o.customer_id
),
cohort_long AS(
	SELECT 
	cohort_month,
	month_number,
	COUNT(DISTINCT customer_unique_id) AS n_customers 
	FROM month_diff
	GROUP BY cohort_month, month_number
),
cohort_pivot AS(
	SELECT cohort_month,
	SUM(CASE WHEN month_number = 0 THEN n_customers  ELSE 0 END) AS m0,
	SUM(CASE WHEN month_number = 1 THEN n_customers  ELSE 0 END) AS m1,
	SUM(CASE WHEN month_number = 2 THEN n_customers  ELSE 0 END) AS m2,
	SUM(CASE WHEN month_number = 3 THEN n_customers  ELSE 0 END) AS m3,
	SUM(CASE WHEN month_number = 4 THEN n_customers  ELSE 0 END) AS m4,
	SUM(CASE WHEN month_number = 5 THEN n_customers  ELSE 0 END) AS m5,
	SUM(CASE WHEN month_number = 6 THEN n_customers  ELSE 0 END) AS m6
	FROM cohort_long
	GROUP BY cohort_month
)

SELECT cohort_month,
m0,
ROUND((100.0 * m1)/m0, 2) AS m1_pct,
ROUND((100.0 * m2)/m0, 2) AS m2_pct,
ROUND((100.0 * m3)/m0, 2) AS m3_pct,
ROUND((100.0 * m4)/m0, 2) AS m4_pct,
ROUND((100.0 * m5)/m0, 2) AS m5_pct,
ROUND((100.0 * m6)/m0, 2) AS m6_pct
FROM cohort_pivot
ORDER BY cohort_month;
-- DATA SEGMENTATION

/* Segment products into cost ranges and
count how many products fall into each segment */

WITH cte_product_cost AS (
	SELECT 
		product_key,
		product_name,
		product_cost,
		CASE 
			WHEN product_cost <= 100 THEN 'below 100'
			WHEN product_cost BETWEEN 101 AND 500 THEN '101-500'
			WHEN product_cost BETWEEN 501 AND 1000 THEN '501-1000'
			ELSE 'above 1000'
		END AS cost_range
	FROM gold.dim_products
)
SELECT 
	cost_range,
	COUNT(*) total_products
FROM cte_product_cost
GROUP BY cost_range
ORDER BY total_products DESC;


/* Group customers into 3 segments based on their spending behaviour
VIP: at least 12 months of history and spending more than 5000.
Regular: at least 12 months of history but spending 5000 or less.
New: lifespan less than 12 months

And find the total number of customers by each group
*/

WITH cte_customer_segment AS (
	SELECT 
		c.customer_key,
		SUM(f.sales) total_sales,
		MIN(f.order_date) min_date,
		MAX(f.order_date) max_date,
		CASE
			WHEN DATEDIFF(month, MIN(f.order_date), MAX(f.order_date)) >= 12 AND SUM(f.sales) >= 5000 THEN 'VIP'
			WHEN DATEDIFF(month, MIN(f.order_date), MAX(f.order_date)) > 12 AND SUM(f.sales) < 5000 THEN 'Regular'
			ELSE 'NEW'
		END customer_segment
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_customers c
	ON f.customer_key = c.customer_key
	GROUP BY c.customer_key
)
SELECT
	customer_segment,
	COUNT(*) total_customers
FROM cte_customer_segment
GROUP BY customer_segment;

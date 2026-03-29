-- PERFORMANCE ANALYSIS
/* Analyze the yearly performance of products by comparing thier sales to both the average sales performance
of the product and the previous year's sales */

WITH cte_product_yearly_performance AS (
	SELECT 
		YEAR(f.order_date) order_year,
		p.product_name,
		SUM(f.sales) current_sales
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
	ON f.product_key = p.product_key
	WHERE f.order_date IS NOT NULL
	GROUP BY p.product_name, YEAR(f.order_date)
)
SELECT
	order_year,
	product_name,
	current_sales,
	AVG(current_sales) OVER(PARTITION BY product_name) AS product_avg,
	current_sales - AVG(current_sales) OVER(PARTITION BY product_name) AS avg_diff,
	CASE
		WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) > 0 THEN 'Above Average'
		WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) < 0 THEN 'Below Average'
		ELSE 'Avg'
	END avg_flag,
	LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) prev_year_sales,
	current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) py_diff,
	CASE
		WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Above py sales'
		WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Below py sales'
		ELSE 'equal'
	END avg_flag
FROM cte_product_yearly_performance
ORDER BY product_name, order_year;

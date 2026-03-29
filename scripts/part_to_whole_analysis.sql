-- PART TO WHOLE ANALYSIS (PROPORTIONAL ANALYSIS)

-- which category contribute most to the overall sales

WITH cte_category_sales AS (
	SELECT 
		product_category AS category,
		SUM(sales) total_sales
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
	ON f.product_key = p.product_key
	GROUP BY product_category
)
SELECT 
	category,
	total_sales,
	SUM(total_sales) OVER() overall_sales,
	CONCAT(ROUND(((CAST(total_sales AS FLOAT)/ SUM(total_sales) OVER()) * 100), 2), '%') [percentage]
FROM cte_category_sales
ORDER BY total_sales DESC;

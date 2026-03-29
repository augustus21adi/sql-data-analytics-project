-- CUMULATIVE ANALYSIS

SELECT
	*,
	SUM(total_sales) OVER(ORDER BY order_month) running_total_sales,
	SUM(total_sales) OVER(PARTITION BY YEAR(order_month) ORDER BY order_month) running_total_sales_year,
	AVG(total_sales) OVER(ORDER BY order_month) moving_average
FROM (
	SELECT 
		DATETRUNC(month, order_date) order_month,
		SUM(sales) total_sales
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(month, order_date)
) t;

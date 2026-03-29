-- CHANGE OVER TIME ANALYSIS
-- find sales performance over time

SELECT 
	YEAR(order_date) order_year,
	MONTH(order_date) order_month,
	SUM(sales) total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date);


SELECT
	DATETRUNC(month, order_date) as order_month,
	SUM(sales) total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
ORDER BY DATETRUNC(month, order_date);

SELECT
	FORMAT(order_date, 'yyyy-MMM') order_month,
	SUM(sales) total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY FORMAT(order_date, 'yyyy-MMM');

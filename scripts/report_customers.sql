/* 
Cusomter Report

purpose:
	 this report conslidates key customer metrics and behaviours

highlights:
	gathers essential fields such as name, ages, and transaction details
	segments customers into categories (vip, regular, new) and age groups
	Aggregates customer-level metrics
		total orders
		total sales
		total quantity purchased
		total products
		lifespan (in months)
	calculate valuable kpis
		recency (months since last order)
		average order value
		average monthly spend
*/

WITH cte_base_customer_query AS (
	SELECT 
		f.sales_order_number,
		c.customer_key, 
		c.customer_number,
		CONCAT(c.first_name, ' ', c.lat_name) customer_name,
		DATEDIFF(year, c.birthdate, GETDATE()) age,
		f.product_key,
		f.order_date,
		f.sales,
		f.quantity
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_customers c
	ON f.customer_key = c.customer_key
),
cte_customer_query AS (
	SELECT
		customer_key,
		customer_number,
		customer_name,
		age,
		MAX(order_date) last_order_date,
		DATEDIFF(month, MIN(order_date), MAX(order_date)) lifespan,
		COUNT(DISTINCT sales_order_number) total_orders,
		SUM(sales) total_sales
	FROM cte_base_customer_query
	GROUP BY 
		customer_key,
		customer_number,
		customer_name,
		age
)
SELECT 
	customer_key,
	customer_number,
	customer_name,
	age,
	CASE
		WHEN age <= 30 THEN 'below 30'
		WHEN age BETWEEN 31 AND 40 THEN '31-40'
		WHEN age BETWEEN 41 AND 50 THEN '41-50'
		ELSE 'above 50'
	END AS age_group,
	last_order_date,
	DATEDIFF(month, last_order_date, GETDATE()) recency,
	lifespan,
	total_orders,
	total_sales,
	CASE
		WHEN total_orders = 0 THEN 0
		ELSE total_sales / total_orders
	END AS avg_order_value,
	CASE
		WHEN lifespan = 0 THEN total_sales
		ELSE total_sales / lifespan
	END AS avg_monthly_spend
FROM cte_customer_query
ORDER BY customer_key;

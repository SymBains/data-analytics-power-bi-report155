-- Which month in 2022 has had the highest revenue?
SELECT d.month_name, SUM(p.sale_price * o.product_quantity) AS total_revenue
FROM orders o
JOIN dim_date d ON o.order_date = d.date
JOIN dim_products p ON o.product_code = p.product_code
WHERE d.year = 2022
GROUP BY d.month_name, d.month_number
ORDER BY total_revenue DESC
LIMIT 1;

--  Which German store type had the highest revenue for 2022? 
SELECT s.store_type, SUM(p.sale_price * o.product_quantity) AS total_revenue
FROM orders o
JOIN dim_stores s ON o.store_code = s.store_code
JOIN dim_date d ON o.order_date = d.date
JOIN dim_products p ON o.product_code = p.product_code
WHERE s.country = 'Germany' AND d.year = 2022
GROUP BY s.store_type
ORDER BY total_revenue DESC
LIMIT 1;

-- Which product category generated the most profit for the "Wiltshire, UK" region in 2021?
SELECT p.category, 
       SUM((p.sale_price - p.cost_price) * o.product_quantity) AS total_profit
FROM orders o
JOIN dim_stores s ON o.store_code = s.store_code
JOIN dim_date d ON o.order_date = d.date
JOIN dim_products p ON o.product_code = p.product_code
WHERE s.country_region = 'Wiltshire' AND d.year = 2021
GROUP BY p.category
ORDER BY total_profit DESC
LIMIT 1;

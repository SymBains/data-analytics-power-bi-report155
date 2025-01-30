-- Create a view where the rows are the store types and the columns are the total sales, percentage of total sales and the count of orders 
CREATE OR REPLACE VIEW store_sales_summary AS
SELECT 
    s.store_type,
    SUM(p.sale_price * o.product_quantity) AS total_sales,
    (SUM(p.sale_price * o.product_quantity) / SUM(SUM(p.sale_price * o.product_quantity)) OVER ()) * 100 AS percentage_of_total_sales,
    COUNT(o.index) AS count_of_orders
FROM orders o
JOIN dim_stores s ON o.store_code = s.store_code
JOIN dim_products p ON o.product_code = p.product_code
GROUP BY s.store_type;


/* =========================================================
 04_query_examples.sql
 Example join/report queries for cafe order system
 ========================================================= */
/* =========================================================
 1. PRODUCTS WITH CATEGORIES
 ========================================================= */
SELECT p.product_id,
    p.product_name,
    pc.category_name,
    p.price,
    p.is_available
FROM products p
    JOIN product_categories pc ON p.category_id = pc.category_id
ORDER BY pc.category_name,
    p.product_name;
/* =========================================================
 2. ALL ORDERS WITH TABLE + STATUS
 ========================================================= */
SELECT o.order_id,
    ct.table_number,
    os.status_name,
    o.order_created_at,
    o.notes
FROM orders o
    JOIN cafe_tables ct ON o.table_id = ct.table_id
    JOIN order_statuses os ON o.status_id = os.status_id
ORDER BY o.order_created_at DESC;
/* =========================================================
 3. ORDER DETAILS
 ========================================================= */
SELECT o.order_id,
    ct.table_number,
    os.status_name,
    o.order_created_at,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price) AS line_total
FROM orders o
    JOIN cafe_tables ct ON o.table_id = ct.table_id
    JOIN order_statuses os ON o.status_id = os.status_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
ORDER BY o.order_id,
    oi.order_item_id;
/* =========================================================
 4. SINGLE ORDER DETAIL
 ========================================================= */
SELECT o.order_id,
    ct.table_number,
    os.status_name,
    o.order_created_at,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price) AS line_total
FROM orders o
    JOIN cafe_tables ct ON o.table_id = ct.table_id
    JOIN order_statuses os ON o.status_id = os.status_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
WHERE o.order_id = 1
ORDER BY oi.order_item_id;
/* =========================================================
 5. ORDER TOTALS
 ========================================================= */
SELECT o.order_id,
    ct.table_number,
    os.status_name,
    SUM(oi.quantity * oi.unit_price) AS order_total
FROM orders o
    JOIN cafe_tables ct ON o.table_id = ct.table_id
    JOIN order_statuses os ON o.status_id = os.status_id
    JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id,
    ct.table_number,
    os.status_name
ORDER BY o.order_id;
/* =========================================================
 6. ACTIVE ORDERS
 ========================================================= */
SELECT o.order_id,
    ct.table_number,
    os.status_name,
    o.order_created_at
FROM orders o
    JOIN cafe_tables ct ON o.table_id = ct.table_id
    JOIN order_statuses os ON o.status_id = os.status_id
WHERE os.status_name IN ('Pending', 'Preparing', 'Served')
ORDER BY o.order_created_at;
/* =========================================================
 7. PAID ORDERS
 ========================================================= */
SELECT o.order_id,
    ct.table_number,
    o.order_created_at
FROM orders o
    JOIN cafe_tables ct ON o.table_id = ct.table_id
    JOIN order_statuses os ON o.status_id = os.status_id
WHERE os.status_name = 'Paid'
ORDER BY o.order_created_at DESC;
/* =========================================================
 8. TOTAL SALES BY PRODUCT
 ========================================================= */
SELECT p.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_quantity_sold,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    JOIN orders o ON oi.order_id = o.order_id
    JOIN order_statuses os ON o.status_id = os.status_id
WHERE os.status_name = 'Paid'
GROUP BY p.product_id,
    p.product_name
ORDER BY total_quantity_sold DESC,
    total_revenue DESC;
/* =========================================================
 9. TOTAL SALES BY CATEGORY
 ========================================================= */
SELECT pc.category_name,
    SUM(oi.quantity) AS total_items_sold,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    JOIN product_categories pc ON p.category_id = pc.category_id
    JOIN orders o ON oi.order_id = o.order_id
    JOIN order_statuses os ON o.status_id = os.status_id
WHERE os.status_name = 'Paid'
GROUP BY pc.category_name
ORDER BY total_revenue DESC;
/* =========================================================
 10. MOST USED TABLES
 ========================================================= */
SELECT ct.table_number,
    COUNT(o.order_id) AS total_orders
FROM orders o
    JOIN cafe_tables ct ON o.table_id = ct.table_id
GROUP BY ct.table_number
ORDER BY total_orders DESC,
    ct.table_number;
/* =========================================================
 11. CURRENT OPEN ORDER COUNT PER TABLE
 ========================================================= */
SELECT ct.table_number,
    COUNT(o.order_id) AS open_order_count
FROM cafe_tables ct
    LEFT JOIN orders o ON ct.table_id = o.table_id
    LEFT JOIN order_statuses os ON o.status_id = os.status_id
WHERE os.status_name IN ('Pending', 'Preparing', 'Served')
GROUP BY ct.table_number
ORDER BY ct.table_number;
/* =========================================================
 12. AVAILABLE PRODUCTS
 ========================================================= */
SELECT p.product_id,
    p.product_name,
    pc.category_name,
    p.price
FROM products p
    JOIN product_categories pc ON p.category_id = pc.category_id
WHERE p.is_available = TRUE
ORDER BY pc.category_name,
    p.product_name;
/* =========================================================
 13. UNAVAILABLE PRODUCTS
 ========================================================= */
SELECT p.product_id,
    p.product_name,
    pc.category_name,
    p.price
FROM products p
    JOIN product_categories pc ON p.category_id = pc.category_id
WHERE p.is_available = FALSE
ORDER BY pc.category_name,
    p.product_name;
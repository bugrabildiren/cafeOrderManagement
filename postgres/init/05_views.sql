/* =========================================================
 05_views.sql
 Reusable views for cafe order system
 ========================================================= */
/* =========================================================
 1. ORDER DETAILS VIEW
 One row per order item
 ========================================================= */
CREATE OR REPLACE VIEW vw_order_details AS
SELECT o.order_id,
    ct.table_number,
    os.status_name,
    o.order_created_at,
    o.notes,
    oi.order_item_id,
    p.product_id,
    p.product_name,
    pc.category_name,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price) AS line_total
FROM orders o
    JOIN cafe_tables ct ON o.table_id = ct.table_id
    JOIN order_statuses os ON o.status_id = os.status_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    JOIN product_categories pc ON p.category_id = pc.category_id;
/* =========================================================
 2. ORDER TOTALS VIEW
 One row per order
 ========================================================= */
CREATE OR REPLACE VIEW vw_order_totals AS
SELECT o.order_id,
    ct.table_number,
    os.status_name,
    o.order_created_at,
    COUNT(oi.order_item_id) AS item_line_count,
    COALESCE(SUM(oi.quantity), 0) AS total_quantity,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS order_total
FROM orders o
    JOIN cafe_tables ct ON o.table_id = ct.table_id
    JOIN order_statuses os ON o.status_id = os.status_id
    LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id,
    ct.table_number,
    os.status_name,
    o.order_created_at;
/* =========================================================
 3. ACTIVE ORDERS VIEW
 Open orders only
 ========================================================= */
CREATE OR REPLACE VIEW vw_active_orders AS
SELECT o.order_id,
    ct.table_number,
    os.status_name,
    o.order_created_at,
    o.notes
FROM orders o
    JOIN cafe_tables ct ON o.table_id = ct.table_id
    JOIN order_statuses os ON o.status_id = os.status_id
WHERE os.status_name IN ('Pending', 'Preparing', 'Served');
/* =========================================================
 4. AVAILABLE PRODUCTS VIEW
 ========================================================= */
CREATE OR REPLACE VIEW vw_available_products AS
SELECT p.product_id,
    p.product_name,
    pc.category_name,
    p.price,
    p.is_available
FROM products p
    JOIN product_categories pc ON p.category_id = pc.category_id
WHERE p.is_available = TRUE;
/* =========================================================
 5. PRODUCT SALES VIEW
 Paid orders only
 ========================================================= */
CREATE OR REPLACE VIEW vw_product_sales AS
SELECT p.product_id,
    p.product_name,
    pc.category_name,
    COALESCE(SUM(oi.quantity), 0) AS total_quantity_sold,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS total_revenue
FROM products p
    JOIN product_categories pc ON p.category_id = pc.category_id
    LEFT JOIN order_items oi ON p.product_id = oi.product_id
    LEFT JOIN orders o ON oi.order_id = o.order_id
    LEFT JOIN order_statuses os ON o.status_id = os.status_id
WHERE os.status_name = 'Paid'
GROUP BY p.product_id,
    p.product_name,
    pc.category_name;
/* =========================================================
 6. CATEGORY SALES VIEW
 Paid orders only
 ========================================================= */
CREATE OR REPLACE VIEW vw_category_sales AS
SELECT pc.category_id,
    pc.category_name,
    COALESCE(SUM(oi.quantity), 0) AS total_items_sold,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS total_revenue
FROM product_categories pc
    LEFT JOIN products p ON pc.category_id = p.category_id
    LEFT JOIN order_items oi ON p.product_id = oi.product_id
    LEFT JOIN orders o ON oi.order_id = o.order_id
    LEFT JOIN order_statuses os ON o.status_id = os.status_id
WHERE os.status_name = 'Paid'
GROUP BY pc.category_id,
    pc.category_name;
/* =========================================================
 7. TABLE ORDER SUMMARY VIEW
 ========================================================= */
CREATE OR REPLACE VIEW vw_table_order_summary AS
SELECT ct.table_id,
    ct.table_number,
    ct.capacity,
    ct.is_active,
    COUNT(o.order_id) AS total_orders
FROM cafe_tables ct
    LEFT JOIN orders o ON ct.table_id = o.table_id
GROUP BY ct.table_id,
    ct.table_number,
    ct.capacity,
    ct.is_active;
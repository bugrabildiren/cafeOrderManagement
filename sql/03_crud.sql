/* =========================================================
 03_crud.sql
 Basic CRUD statements for cafe order system
 ========================================================= */
/* =========================================================
 CAFE TABLES
 ========================================================= */
/* INSERT */
INSERT INTO cafe_tables (table_number, capacity, is_active)
VALUES (10, 4, TRUE);
/* SELECT */
SELECT *
FROM cafe_tables;
SELECT *
FROM cafe_tables
WHERE is_active = TRUE;
SELECT *
FROM cafe_tables
WHERE table_number = 10;
/* UPDATE */
UPDATE cafe_tables
SET capacity = 6
WHERE table_number = 10;
/* SOFT UPDATE */
UPDATE cafe_tables
SET is_active = FALSE
WHERE table_number = 10;
/* DELETE */
DELETE FROM cafe_tables
WHERE table_number = 10;
/* =========================================================
 PRODUCT CATEGORIES
 ========================================================= */
/* INSERT */
INSERT INTO product_categories (category_name)
VALUES ('Breakfast');
/* SELECT */
SELECT *
FROM product_categories;
SELECT *
FROM product_categories
WHERE category_name = 'Breakfast';
/* UPDATE */
UPDATE product_categories
SET category_name = 'Breakfast Menu'
WHERE category_name = 'Breakfast';
/* DELETE */
DELETE FROM product_categories
WHERE category_name = 'Breakfast Menu';
/* =========================================================
 PRODUCTS
 ========================================================= */
/* INSERT */
INSERT INTO products (category_id, product_name, price, is_available)
VALUES (
        (
            SELECT category_id
            FROM product_categories
            WHERE category_name = 'Hot Drinks'
        ),
        'Cappuccino',
        90.00,
        TRUE
    );
/* SELECT */
SELECT *
FROM products;
SELECT p.product_id,
    p.product_name,
    pc.category_name,
    p.price,
    p.is_available
FROM products p
    JOIN product_categories pc ON p.category_id = pc.category_id
ORDER BY p.product_id;
/* UPDATE */
UPDATE products
SET price = 95.00
WHERE product_name = 'Cappuccino';
/* AVAILABILITY UPDATE */
UPDATE products
SET is_available = FALSE
WHERE product_name = 'Cappuccino';
/* DELETE */
DELETE FROM products
WHERE product_name = 'Cappuccino';
/* =========================================================
 ORDER STATUSES
 ========================================================= */
/* INSERT */
INSERT INTO order_statuses (status_name)
VALUES ('Ready');
/* SELECT */
SELECT *
FROM order_statuses;
/* UPDATE */
UPDATE order_statuses
SET status_name = 'Ready To Serve'
WHERE status_name = 'Ready';
/* DELETE */
DELETE FROM order_statuses
WHERE status_name = 'Ready To Serve';
/* =========================================================
 ORDERS
 ========================================================= */
/* INSERT */
INSERT INTO orders (table_id, status_id, notes)
VALUES (
        (
            SELECT table_id
            FROM cafe_tables
            WHERE table_number = 1
        ),
        (
            SELECT status_id
            FROM order_statuses
            WHERE status_name = 'Pending'
        ),
        'Customer asked for fast service'
    );
/* SELECT */
SELECT *
FROM orders;
SELECT o.order_id,
    ct.table_number,
    os.status_name,
    o.order_created_at,
    o.notes
FROM orders o
    JOIN cafe_tables ct ON o.table_id = ct.table_id
    JOIN order_statuses os ON o.status_id = os.status_id
ORDER BY o.order_id;
/* UPDATE STATUS */
UPDATE orders
SET status_id = (
        SELECT status_id
        FROM order_statuses
        WHERE status_name = 'Preparing'
    )
WHERE order_id = 1;
/* UPDATE NOTE */
UPDATE orders
SET notes = 'No sugar for drinks'
WHERE order_id = 1;
/* DELETE */
DELETE FROM orders
WHERE order_id = 1;
/* =========================================================
 ORDER ITEMS
 ========================================================= */
/* INSERT */
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES (
        1,
        (
            SELECT product_id
            FROM products
            WHERE product_name = 'Latte'
        ),
        2,
        (
            SELECT price
            FROM products
            WHERE product_name = 'Latte'
        )
    ),
    (
        1,
        (
            SELECT product_id
            FROM products
            WHERE product_name = 'Cheesecake'
        ),
        1,
        (
            SELECT price
            FROM products
            WHERE product_name = 'Cheesecake'
        )
    );
/* SELECT */
SELECT *
FROM order_items;
SELECT oi.order_item_id,
    oi.order_id,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price) AS line_total
FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
ORDER BY oi.order_item_id;
/* UPDATE QUANTITY */
UPDATE order_items
SET quantity = 3
WHERE order_item_id = 1;
/* UPDATE UNIT PRICE */
UPDATE order_items
SET unit_price = 92.50
WHERE order_item_id = 1;
/* DELETE */
DELETE FROM order_items
WHERE order_item_id = 1;
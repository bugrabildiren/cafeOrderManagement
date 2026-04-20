/* =========================================================
 08_sample_flow.sql
 End-to-end sample usage flow for cafe order system
 ========================================================= */
/* =========================================================
 STEP 1 - OPEN A NEW ORDER FOR TABLE 2
 ========================================================= */
INSERT INTO orders (table_id, status_id, notes)
VALUES (
      (
         SELECT table_id
         FROM cafe_tables
         WHERE table_number = 2
      ),
      (
         SELECT status_id
         FROM order_statuses
         WHERE status_name = 'Pending'
      ),
      'Sample flow order for testing'
   );
/* =========================================================
 STEP 2 - ADD PRODUCTS WITH THE FUNCTION
 ========================================================= */
SELECT add_order_item(
      (
         SELECT MAX(order_id)
         FROM orders
      ),
      (
         SELECT product_id
         FROM products
         WHERE product_name = 'Latte'
      ),
      2
   );
SELECT add_order_item(
      (
         SELECT MAX(order_id)
         FROM orders
      ),
      (
         SELECT product_id
         FROM products
         WHERE product_name = 'Cheesecake'
      ),
      1
   );
SELECT add_order_item(
      (
         SELECT MAX(order_id)
         FROM orders
      ),
      (
         SELECT product_id
         FROM products
         WHERE product_name = 'Latte'
      ),
      1
   );
/* =========================================================
 STEP 3 - CHECK ORDER DETAILS
 ========================================================= */
SELECT *
FROM vw_order_details
WHERE order_id = (
      SELECT MAX(order_id)
      FROM orders
   );
/* =========================================================
 STEP 4 - CHECK ORDER TOTAL
 ========================================================= */
SELECT *
FROM vw_order_totals
WHERE order_id = (
      SELECT MAX(order_id)
      FROM orders
   );
/* =========================================================
 STEP 5 - MOVE STATUS: Pending -> Preparing
 ========================================================= */
UPDATE orders
SET status_id = (
      SELECT status_id
      FROM order_statuses
      WHERE status_name = 'Preparing'
   )
WHERE order_id = (
      SELECT MAX(order_id)
      FROM orders
   );
/* =========================================================
 STEP 6 - MOVE STATUS: Preparing -> Served
 ========================================================= */
UPDATE orders
SET status_id = (
      SELECT status_id
      FROM order_statuses
      WHERE status_name = 'Served'
   )
WHERE order_id = (
      SELECT MAX(order_id)
      FROM orders
   );
/* =========================================================
 STEP 7 - MOVE STATUS: Served -> Paid
 ========================================================= */
UPDATE orders
SET status_id = (
      SELECT status_id
      FROM order_statuses
      WHERE status_name = 'Paid'
   )
WHERE order_id = (
      SELECT MAX(order_id)
      FROM orders
   );
/* =========================================================
 STEP 8 - FINAL CHECK
 ========================================================= */
SELECT *
FROM vw_order_totals
WHERE order_id = (
      SELECT MAX(order_id)
      FROM orders
   );
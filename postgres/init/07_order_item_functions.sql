/* =========================================================
 07_order_item_functions.sql
 Helper function for adding products into an order
 
 Goal:
 - If the product already exists in the order, increase quantity
 - If the product does not exist, insert a new row
 - Get unit_price automatically from products.price
 - Respect business rules already enforced by triggers
 ========================================================= */
/* =========================================================
 0. CLEANUP
 ========================================================= */
DROP FUNCTION IF EXISTS add_order_item(BIGINT, BIGINT, INT);
/* =========================================================
 1. MAIN FUNCTION
 ========================================================= */
CREATE OR REPLACE FUNCTION add_order_item(
        p_order_id BIGINT,
        p_product_id BIGINT,
        p_quantity INT
    ) RETURNS VOID LANGUAGE plpgsql AS $$
DECLARE v_existing_order_item_id BIGINT;
v_current_price NUMERIC(10, 2);
BEGIN IF p_quantity IS NULL
OR p_quantity < 1 THEN RAISE EXCEPTION 'Quantity must be at least 1.';
END IF;
SELECT price INTO v_current_price
FROM products
WHERE product_id = p_product_id;
IF v_current_price IS NULL THEN RAISE EXCEPTION 'Product with id % does not exist.',
p_product_id;
END IF;
SELECT order_item_id INTO v_existing_order_item_id
FROM order_items
WHERE order_id = p_order_id
    AND product_id = p_product_id;
IF v_existing_order_item_id IS NOT NULL THEN
UPDATE order_items
SET quantity = quantity + p_quantity
WHERE order_item_id = v_existing_order_item_id;
ELSE
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES (
        p_order_id,
        p_product_id,
        p_quantity,
        v_current_price
    );
END IF;
END;
$$;
/* =========================================================
 2. USAGE EXAMPLES
 ========================================================= */
-- Example 1: Add 2 Latte into order 1
-- SELECT add_order_item(
--     1,
--     (SELECT product_id FROM products WHERE product_name = 'Latte'),
--     2
-- );
-- Example 2: Add 1 Cheesecake into order 1
-- SELECT add_order_item(
--     1,
--     (SELECT product_id FROM products WHERE product_name = 'Cheesecake'),
--     1
-- );
-- Example 3: Add the same product again -> quantity increases
-- SELECT add_order_item(
--     1,
--     (SELECT product_id FROM products WHERE product_name = 'Latte'),
--     1
-- );
/* =========================================================
 3. TEST QUERIES
 ========================================================= */
-- See items of one order
-- SELECT
--     oi.order_item_id,
--     oi.order_id,
--     p.product_name,
--     oi.quantity,
--     oi.unit_price,
--     (oi.quantity * oi.unit_price) AS line_total
-- FROM order_items oi
-- JOIN products p
--     ON oi.product_id = p.product_id
-- WHERE oi.order_id = 1
-- ORDER BY oi.order_item_id;
-- See order total
-- SELECT
--     order_id,
--     SUM(quantity * unit_price) AS total_amount
-- FROM order_items
-- WHERE order_id = 1
-- GROUP BY order_id;
/* =========================================================
 06_business_rules.sql
 Business rules for cafe order system
 Based on agreed decisions:
 1) One open order per table
 2) Same product in same order -> quantity should increase
 3) Paid orders cannot be changed
 4) Cancelled orders cannot be changed
 5) Unavailable products cannot be added to new orders
 6) Allowed status flow:
 Pending -> Preparing
 Preparing -> Served
 Served -> Paid
 Pending/Preparing/Served -> Cancelled
 7) Empty order can exist temporarily
 8) Quantity must be >= 1
 9) Order total is calculated from order_items
 10) Inactive tables cannot receive new orders
 11) Same product cannot exist twice in same order
 12) Status list may expand later, but core rules use current statuses
 ========================================================= */
/* =========================================================
 0. CLEANUP (safe for rerun during development)
 ========================================================= */
DROP TRIGGER IF EXISTS trg_orders_before_insert_check_table ON orders;
DROP TRIGGER IF EXISTS trg_orders_before_update_status_guard ON orders;
DROP TRIGGER IF EXISTS trg_order_items_before_insert_rules ON order_items;
DROP TRIGGER IF EXISTS trg_order_items_before_update_rules ON order_items;
DROP TRIGGER IF EXISTS trg_order_items_before_delete_rules ON order_items;
DROP FUNCTION IF EXISTS fn_check_order_insert_rules();
DROP FUNCTION IF EXISTS fn_check_order_status_update_rules();
DROP FUNCTION IF EXISTS fn_check_order_item_insert_rules();
DROP FUNCTION IF EXISTS fn_check_order_item_update_rules();
DROP FUNCTION IF EXISTS fn_check_order_item_delete_rules();
DROP INDEX IF EXISTS uq_order_items_order_product;
/* =========================================================
 1. UNIQUE RULE:
 Same product cannot appear twice in the same order
 ========================================================= */
CREATE UNIQUE INDEX uq_order_items_order_product ON order_items(order_id, product_id);
/* =========================================================
 2. ORDERS INSERT RULES
 - inactive table cannot receive new order
 - a table can have only one open order at a time
 ========================================================= */
CREATE OR REPLACE FUNCTION fn_check_order_insert_rules() RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE v_table_active BOOLEAN;
v_status_name VARCHAR(50);
v_open_order_count INT;
BEGIN
SELECT is_active INTO v_table_active
FROM cafe_tables
WHERE table_id = NEW.table_id;
IF v_table_active IS NULL THEN RAISE EXCEPTION 'Table with id % does not exist.',
NEW.table_id;
END IF;
IF v_table_active = FALSE THEN RAISE EXCEPTION 'Inactive table % cannot receive a new order.',
NEW.table_id;
END IF;
SELECT status_name INTO v_status_name
FROM order_statuses
WHERE status_id = NEW.status_id;
IF v_status_name IS NULL THEN RAISE EXCEPTION 'Status with id % does not exist.',
NEW.status_id;
END IF;
IF v_status_name IN ('Pending', 'Preparing', 'Served') THEN
SELECT COUNT(*) INTO v_open_order_count
FROM orders o
    JOIN order_statuses os ON o.status_id = os.status_id
WHERE o.table_id = NEW.table_id
    AND os.status_name IN ('Pending', 'Preparing', 'Served');
IF v_open_order_count > 0 THEN RAISE EXCEPTION 'Table % already has an open order.',
NEW.table_id;
END IF;
END IF;
RETURN NEW;
END;
$$;
CREATE TRIGGER trg_orders_before_insert_check_table BEFORE
INSERT ON orders FOR EACH ROW EXECUTE FUNCTION fn_check_order_insert_rules();
/* =========================================================
 3. ORDERS STATUS UPDATE RULES
 - Paid orders cannot change
 - Cancelled orders cannot change
 - Allowed flow:
 Pending -> Preparing / Cancelled
 Preparing -> Served / Cancelled
 Served -> Paid / Cancelled
 - inactive table cannot receive open order state
 ========================================================= */
CREATE OR REPLACE FUNCTION fn_check_order_status_update_rules() RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE v_old_status_name VARCHAR(50);
v_new_status_name VARCHAR(50);
v_table_active BOOLEAN;
BEGIN
SELECT status_name INTO v_old_status_name
FROM order_statuses
WHERE status_id = OLD.status_id;
SELECT status_name INTO v_new_status_name
FROM order_statuses
WHERE status_id = NEW.status_id;
IF v_old_status_name IS NULL
OR v_new_status_name IS NULL THEN RAISE EXCEPTION 'Invalid status transition.';
END IF;
IF v_old_status_name = v_new_status_name THEN RETURN NEW;
END IF;
IF v_old_status_name = 'Paid' THEN RAISE EXCEPTION 'Paid orders cannot be changed.';
END IF;
IF v_old_status_name = 'Cancelled' THEN RAISE EXCEPTION 'Cancelled orders cannot be changed.';
END IF;
IF v_old_status_name = 'Pending'
AND v_new_status_name NOT IN ('Preparing', 'Cancelled') THEN RAISE EXCEPTION 'Invalid status transition: % -> %',
v_old_status_name,
v_new_status_name;
END IF;
IF v_old_status_name = 'Preparing'
AND v_new_status_name NOT IN ('Served', 'Cancelled') THEN RAISE EXCEPTION 'Invalid status transition: % -> %',
v_old_status_name,
v_new_status_name;
END IF;
IF v_old_status_name = 'Served'
AND v_new_status_name NOT IN ('Paid', 'Cancelled') THEN RAISE EXCEPTION 'Invalid status transition: % -> %',
v_old_status_name,
v_new_status_name;
END IF;
IF v_new_status_name IN ('Pending', 'Preparing', 'Served') THEN
SELECT is_active INTO v_table_active
FROM cafe_tables
WHERE table_id = NEW.table_id;
IF v_table_active = FALSE THEN RAISE EXCEPTION 'Inactive table % cannot have an open order.',
NEW.table_id;
END IF;
END IF;
RETURN NEW;
END;
$$;
CREATE TRIGGER trg_orders_before_update_status_guard BEFORE
UPDATE OF status_id ON orders FOR EACH ROW EXECUTE FUNCTION fn_check_order_status_update_rules();
/* =========================================================
 4. ORDER_ITEMS INSERT RULES
 - cannot add item to Paid or Cancelled order
 - product must be available
 - quantity must be >= 1 (already ensured by CHECK)
 - same product cannot be inserted twice due to unique index
 ========================================================= */
CREATE OR REPLACE FUNCTION fn_check_order_item_insert_rules() RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE v_order_status_name VARCHAR(50);
v_product_available BOOLEAN;
BEGIN
SELECT os.status_name INTO v_order_status_name
FROM orders o
    JOIN order_statuses os ON o.status_id = os.status_id
WHERE o.order_id = NEW.order_id;
IF v_order_status_name IS NULL THEN RAISE EXCEPTION 'Order with id % does not exist.',
NEW.order_id;
END IF;
IF v_order_status_name IN ('Paid', 'Cancelled') THEN RAISE EXCEPTION 'Cannot add items to a % order.',
v_order_status_name;
END IF;
SELECT is_available INTO v_product_available
FROM products
WHERE product_id = NEW.product_id;
IF v_product_available IS NULL THEN RAISE EXCEPTION 'Product with id % does not exist.',
NEW.product_id;
END IF;
IF v_product_available = FALSE THEN RAISE EXCEPTION 'Unavailable product % cannot be added to a new order.',
NEW.product_id;
END IF;
RETURN NEW;
END;
$$;
CREATE TRIGGER trg_order_items_before_insert_rules BEFORE
INSERT ON order_items FOR EACH ROW EXECUTE FUNCTION fn_check_order_item_insert_rules();
/* =========================================================
 5. ORDER_ITEMS UPDATE RULES
 - cannot change items of Paid or Cancelled order
 - quantity must stay >= 1
 - if product changes, new product must be available
 ========================================================= */
CREATE OR REPLACE FUNCTION fn_check_order_item_update_rules() RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE v_order_status_name VARCHAR(50);
v_product_available BOOLEAN;
BEGIN
SELECT os.status_name INTO v_order_status_name
FROM orders o
    JOIN order_statuses os ON o.status_id = os.status_id
WHERE o.order_id = NEW.order_id;
IF v_order_status_name IS NULL THEN RAISE EXCEPTION 'Order with id % does not exist.',
NEW.order_id;
END IF;
IF v_order_status_name IN ('Paid', 'Cancelled') THEN RAISE EXCEPTION 'Cannot update items of a % order.',
v_order_status_name;
END IF;
IF NEW.quantity < 1 THEN RAISE EXCEPTION 'Quantity must be at least 1.';
END IF;
IF NEW.product_id <> OLD.product_id THEN
SELECT is_available INTO v_product_available
FROM products
WHERE product_id = NEW.product_id;
IF v_product_available IS NULL THEN RAISE EXCEPTION 'Product with id % does not exist.',
NEW.product_id;
END IF;
IF v_product_available = FALSE THEN RAISE EXCEPTION 'Unavailable product % cannot be assigned.',
NEW.product_id;
END IF;
END IF;
RETURN NEW;
END;
$$;
CREATE TRIGGER trg_order_items_before_update_rules BEFORE
UPDATE ON order_items FOR EACH ROW EXECUTE FUNCTION fn_check_order_item_update_rules();
/* =========================================================
 6. ORDER_ITEMS DELETE RULES
 - cannot delete item from Paid or Cancelled order
 ========================================================= */
CREATE OR REPLACE FUNCTION fn_check_order_item_delete_rules() RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE v_order_status_name VARCHAR(50);
BEGIN
SELECT os.status_name INTO v_order_status_name
FROM orders o
    JOIN order_statuses os ON o.status_id = os.status_id
WHERE o.order_id = OLD.order_id;
IF v_order_status_name IS NULL THEN RAISE EXCEPTION 'Order with id % does not exist.',
OLD.order_id;
END IF;
IF v_order_status_name IN ('Paid', 'Cancelled') THEN RAISE EXCEPTION 'Cannot delete items from a % order.',
v_order_status_name;
END IF;
RETURN OLD;
END;
$$;
CREATE TRIGGER trg_order_items_before_delete_rules BEFORE DELETE ON order_items FOR EACH ROW EXECUTE FUNCTION fn_check_order_item_delete_rules();
/* =========================================================
 7. OPTIONAL HELPER QUERY EXAMPLES
 ========================================================= */
-- Check current status flow candidates
-- SELECT * FROM order_statuses ORDER BY status_id;
-- See open orders
-- SELECT * FROM vw_active_orders;
-- Calculate order total dynamically
-- SELECT order_id, SUM(quantity * unit_price) AS total_amount
-- FROM order_items
-- GROUP BY order_id;
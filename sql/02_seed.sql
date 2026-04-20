INSERT INTO cafe_tables (table_number, capacity, is_active)
VALUES (1, 2, TRUE),
    (2, 4, TRUE),
    (3, 4, TRUE),
    (4, 6, TRUE),
    (5, 2, TRUE) ON CONFLICT (table_number) DO NOTHING;
INSERT INTO product_categories (category_name)
VALUES ('Hot Drinks'),
    ('Cold Drinks'),
    ('Desserts'),
    ('Main Course') ON CONFLICT (category_name) DO NOTHING;
INSERT INTO products (category_id, product_name, price, is_available)
VALUES (
        (
            SELECT category_id
            FROM product_categories
            WHERE category_name = 'Hot Drinks'
        ),
        'Espresso',
        65.00,
        TRUE
    ),
    (
        (
            SELECT category_id
            FROM product_categories
            WHERE category_name = 'Hot Drinks'
        ),
        'Latte',
        85.00,
        TRUE
    ),
    (
        (
            SELECT category_id
            FROM product_categories
            WHERE category_name = 'Cold Drinks'
        ),
        'Iced Americano',
        80.00,
        TRUE
    ),
    (
        (
            SELECT category_id
            FROM product_categories
            WHERE category_name = 'Desserts'
        ),
        'Cheesecake',
        120.00,
        TRUE
    ),
    (
        (
            SELECT category_id
            FROM product_categories
            WHERE category_name = 'Main Course'
        ),
        'Chicken Sandwich',
        150.00,
        TRUE
    ) ON CONFLICT (product_name) DO NOTHING;
INSERT INTO order_statuses (status_name)
VALUES ('Pending'),
    ('Preparing'),
    ('Served'),
    ('Paid'),
    ('Cancelled') ON CONFLICT (status_name) DO NOTHING;
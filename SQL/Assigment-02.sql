-- 2.1
SELECT
    p.product_name,
    b.brand_name
FROM production.products AS p
LEFT JOIN production.brands AS b
    ON p.brand_id = b.brand_id;


-- 2.2
SELECT
    s.store_id,
    s.store_name
FROM sales.stores AS s
LEFT JOIN sales.staffs AS st
    ON s.store_id = st.store_id
WHERE st.staff_id IS NULL;


-- 2.3
-- LEFT JOIN returns every product because it keeps all
-- rows from the products table, even when no matching
-- stock meets the conditions in the ON clause.
-- Products without matching stock have NULL values.

-- Correct Query:
SELECT
    p.product_name,
    s.quantity
FROM production.products AS p
INNER JOIN production.stocks AS s
    ON p.product_id = s.product_id
WHERE s.quantity < 5
  AND s.store_id = 1;


-- 2.4
SELECT
    m.staff_id AS manager_id,
    m.first_name AS manager_first_name,
    m.last_name AS manager_last_name,
    e.staff_id AS employee_id,
    e.first_name AS employee_first_name,
    e.last_name AS employee_last_name,
    1 AS employee_count
FROM sales.staffs AS e
INNER JOIN sales.staffs AS m
    ON e.manager_id = m.staff_id;


-- 2.5
SELECT
    o.order_id,
    p.product_name,
    oi.quantity
FROM sales.orders AS o
INNER JOIN sales.order_items AS oi
    ON o.order_id = oi.order_id
INNER JOIN production.products AS p
    ON oi.product_id = p.product_id
WHERE o.order_id = 1;


-- 2.6
-- The mistake is that one order can have multiple items.
-- When we join orders with order_items, an order appears
-- multiple times if it contains multiple products.
-- So 4,658 joined rows do not mean 4,658 unique orders.
-- We should count unique order IDs instead.

SELECT COUNT(DISTINCT o.order_id) AS total_orders
FROM sales.orders AS o
INNER JOIN sales.order_items AS oi
    ON o.order_id = oi.order_id;


-- 2.7
-- CROSS JOIN combines every row from one table with
-- every row from another table.
-- Example: If one table has 5 rows and another has
-- 10 rows, CROSS JOIN will return 50 rows.
-- It can be useful when we want every possible
-- combination, such as all stores and all products.
-- To avoid using it by mistake, we should always
-- check JOIN conditions and use an ON clause when
-- matching rows between tables.

SELECT
    s.store_name,
    p.product_name
FROM sales.stores AS s
CROSS JOIN production.products AS p;
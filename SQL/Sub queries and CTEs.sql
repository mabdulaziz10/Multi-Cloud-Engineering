
----Q1
SELECT TOP 10
first_name AS [First_Name],
last_name AS [Last Name],
email AS [Email],
city AS [City]
FROM sales.customers
WHERE state = 'NY' AND phone IS NULL
ORDER BY last_name, first_name;

----Q2
SELECT product_id, product_name, model_year, list_price
FROM production.products
WHERE model_year IN (2017, 2018)
AND list_price BETWEEN 500 AND 1500
AND product_name LIKE '%Trek%'
AND product_name NOT LIKE '%Kids%'
ORDER BY list_price DESC;

----Q3(a)
SELECT DISTINCT order_status
FROM sales.orders;

----Q3(b)
SELECT order_id, customer_id, store_id, order_date, required_date
FROM sales.orders
WHERE shipped_date IS NULL
AND store_id IN (1, 3)
AND YEAR(order_date) = 2018
ORDER BY order_date;

----Q4
SELECT
o.order_id,
o.order_date,
c.first_name + ' ' + c.last_name AS customer_name,
p.product_name,
b.brand_name,
cat.category_name,
oi.quantity,
oi.list_price,
oi.discount,
oi.quantity * oi.list_price * (1 - oi.discount) AS line_revenue
FROM sales.orders o
JOIN sales.customers c ON o.customer_id = c.customer_id
JOIN sales.order_items oi ON o.order_id = oi.order_id
JOIN production.products p ON oi.product_id = p.product_id
JOIN production.brands b ON p.brand_id = b.brand_id
JOIN production.categories cat ON p.category_id = cat.category_id
WHERE o.order_id = 1;

----Q5
SELECT
s.first_name + ' ' + s.last_name AS staff_name,
st.store_name,
ISNULL(m.first_name + ' ' + m.last_name, 'No Manager') AS manager_name
FROM sales.staffs s
JOIN sales.stores st ON s.store_id = st.store_id
LEFT JOIN sales.staffs m ON s.manager_id = m.staff_id;

----Q6
SELECT p.product_id, p.product_name, b.brand_name, p.model_year
FROM production.products p
JOIN production.brands b ON p.brand_id = b.brand_id
LEFT JOIN sales.order_items oi ON p.product_id = oi.product_id
WHERE oi.product_id IS NULL;

----Q7(a)
GO
CREATE VIEW sales.vw_order_line_details AS
SELECT
o.order_id,
o.order_date,
c.first_name + ' ' + c.last_name AS customer_name,
p.product_name,
b.brand_name,
cat.category_name,
oi.quantity,
oi.list_price,
oi.discount,
oi.quantity * oi.list_price * (1 - oi.discount) AS line_revenue,
st.store_name,
o.order_status
FROM sales.orders o
JOIN sales.customers c ON o.customer_id = c.customer_id
JOIN sales.order_items oi ON o.order_id = oi.order_id
JOIN production.products p ON oi.product_id = p.product_id
JOIN production.brands b ON p.brand_id = b.brand_id
JOIN production.categories cat ON p.category_id = cat.category_id
JOIN sales.stores st ON o.store_id = st.store_id;
GO

----Q7(b)
SELECT *
FROM sales.vw_order_line_details
WHERE order_date >= '2018-01-01'
AND order_date < '2018-02-01'
ORDER BY order_date, order_id;

----Q8(a)
GO
CREATE VIEW production.vw_product_catalog AS
SELECT
p.product_id,
p.product_name,
b.brand_name,
c.category_name,
p.model_year,
p.list_price
FROM production.products p
JOIN production.brands b ON p.brand_id = b.brand_id
JOIN production.categories c ON p.category_id = c.category_id;
GO

----Q8(b)
SELECT *
FROM production.vw_product_catalog
WHERE category_name = 'Electric Bikes'
AND list_price > 3000
ORDER BY list_price DESC;

----Q9
SELECT
store_name,
YEAR(order_date) AS order_year,
COUNT(DISTINCT order_id) AS total_orders,
SUM(line_revenue) AS total_revenue
FROM sales.vw_order_line_details
GROUP BY store_name, YEAR(order_date)
ORDER BY store_name, order_year;

----Q10
SELECT
b.brand_name,
COUNT(p.product_id) AS total_products,
MIN(p.list_price) AS min_price,
AVG(p.list_price) AS avg_price,
MAX(p.list_price) AS max_price
FROM production.products p
JOIN production.brands b ON p.brand_id = b.brand_id
GROUP BY b.brand_name
HAVING COUNT(p.product_id) > 10
ORDER BY avg_price DESC;

----Q11
SELECT
p.product_name,
c.category_name,
p.list_price,
(SELECT AVG(p2.list_price)
FROM production.products p2
WHERE p2.category_id = p.category_id) AS category_avg_price
FROM production.products p
JOIN production.categories c ON p.category_id = c.category_id
WHERE p.list_price > (
SELECT AVG(p2.list_price)
FROM production.products p2
WHERE p2.category_id = p.category_id
);

----Q12(a)
SELECT
customer_id,
first_name + ' ' + last_name AS customer_name,
email,
state
FROM sales.customers
WHERE customer_id IN (
SELECT customer_id
FROM sales.orders
WHERE YEAR(order_date) = 2016
)
AND customer_id NOT IN (
SELECT customer_id
FROM sales.orders
WHERE YEAR(order_date) = 2018
);

----Q12(b)
SELECT
c.customer_id,
c.first_name + ' ' + c.last_name AS customer_name,
c.email,
c.state
FROM sales.customers c
WHERE EXISTS (
SELECT 1
FROM sales.orders o
WHERE o.customer_id = c.customer_id
AND YEAR(o.order_date) = 2016
)
AND NOT EXISTS (
SELECT 1
FROM sales.orders o
WHERE o.customer_id = c.customer_id
AND YEAR(o.order_date) = 2018
);

----Q13
WITH StoreRevenue AS (
SELECT store_name, SUM(line_revenue) AS total_revenue
FROM sales.vw_order_line_details
GROUP BY store_name
),
AverageRevenue AS (
SELECT AVG(total_revenue) AS avg_revenue
FROM StoreRevenue
)
SELECT
s.store_name,
s.total_revenue,
a.avg_revenue,
s.total_revenue - a.avg_revenue AS revenue_difference
FROM StoreRevenue s
CROSS JOIN AverageRevenue a
WHERE s.total_revenue > a.avg_revenue;

----Q14
WITH StaffHierarchy AS (
SELECT
staff_id,
first_name + ' ' + last_name AS staff_name,
manager_id,
1 AS level,
CAST(first_name + ' ' + last_name AS VARCHAR(MAX)) AS reporting_path
FROM sales.staffs
WHERE manager_id IS NULL

UNION ALL

SELECT
s.staff_id,
s.first_name + ' ' + s.last_name,
s.manager_id,
h.level + 1,
CAST(h.reporting_path + ' > ' + s.first_name + ' ' + s.last_name AS VARCHAR(MAX))
FROM sales.staffs s
JOIN StaffHierarchy h ON s.manager_id = h.staff_id
)
SELECT staff_id, staff_name, manager_id, level, reporting_path
FROM StaffHierarchy
ORDER BY reporting_path;

----Q15(a)
WITH ProductSales AS (
SELECT
c.category_name,
p.product_name,
p.product_id,
SUM(oi.quantity) AS total_quantity,
SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue
FROM sales.orders o
JOIN sales.order_items oi ON o.order_id = oi.order_id
JOIN production.products p ON oi.product_id = p.product_id
JOIN production.categories c ON p.category_id = c.category_id
WHERE YEAR(o.order_date) = 2017
GROUP BY c.category_name, p.product_name, p.product_id
),
RankedProducts AS (
SELECT
category_name,
product_name,
total_quantity,
total_revenue,
ROW_NUMBER() OVER 
(PARTITION BY category_name
ORDER BY total_revenue DESC, product_id) AS product_rank
FROM ProductSales
)
SELECT
category_name,
product_name,
total_quantity,
total_revenue,
product_rank AS [rank]
FROM RankedProducts
WHERE product_rank <= 3
ORDER BY category_name, product_rank;

----Q15(b)
WITH Months AS (
SELECT 1 AS month_number

UNION ALL

SELECT month_number + 1
FROM Months
WHERE month_number < 12
),
MonthlySales AS (
SELECT
MONTH(o.order_date) AS month_number,
COUNT(DISTINCT o.order_id) AS total_orders,
SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue
FROM sales.orders o
JOIN sales.order_items oi ON o.order_id = oi.order_id
WHERE YEAR(o.order_date) = 2017
GROUP BY MONTH(o.order_date)
)
SELECT
m.month_number,
DATENAME(MONTH, DATEFROMPARTS(2017, m.month_number, 1)) AS month_name,
ISNULL(s.total_orders, 0) AS total_orders,
ISNULL(s.total_revenue, 0) AS total_revenue
FROM Months m
LEFT JOIN MonthlySales s ON m.month_number = s.month_number
ORDER BY m.month_number;

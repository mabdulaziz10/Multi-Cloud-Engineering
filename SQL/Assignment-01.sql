----1.1
Select product_name,list_price,list_price / 1000 as price_in_thousands
from production.products;

----1.2
Select distinct state 
from sales.customers;

----1.3
select product_name,list_price
from production.products 
order by list_price asc
offset 0 rows fetch next 5 rows only;


----1.4
select product_name
from production.products
where category_id in (1,6) and list_price between 200 and 600;

----1.5
Select product_name,category_id, 
list_price
from production.products
where category_id in (6,7) and list_price <1000;

----1.6
Select * from sales.customers
where email like '%.com' and last_name like 'M%';

----1.7
select product_name,list_price
from production.products
order by list_price desc
offset 10 rows fetch next 10 rows only;

----1.8
----To find order items where the discount is not NULL, we should use IS NOT NULL.
---Correct Query:
----SELECT *
---FROM sales.order_items
---WHERE discount IS NOT NULL;
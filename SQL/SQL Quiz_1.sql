-----Q1
Select first_name,last_name,city
from sales.customers
where state ='NA' or state='CA' and email like '%.com' and last_name like 'M%';

-----Q2 
Select product_name,list_price,list_price-(list_price*0.1) as discounted_price
from production.products
where list_price >500
order by list_price desc
offset 10 rows fetch next 10 rows only;

----Q3
select order_id,order_date,required_date,order_status
from sales.orders
where order_status ='1' or order_status='2' and order_date between '2018-01-01' and '2018-06-30';


----Q4
select c.first_name,
o.order_id,
o.order_date,
s.store_name,
p.product_name,
st.quantity
from sales.customers as c
inner join sales.orders as o
on c.customer_id = o.customer_id
inner join sales.stores as s
on o.store_id= s.store_id
inner join production.products as p 
inner join sales.order_items as oi
on p.product_id = oi.product_id
inner join production.stocks as st
on p.product_id = st.product_id
order by o.order_date desc;

----Q5
Select p.product_name,c.category_name,b.brand_name
from production.products as p
left join production.categories as c
on p.category_id = c.category_id
inner join production.brands as b
on p.brand_id = b.brand_id;

----Q7
Create view sales.vw_order_details as joins
o.order_id, o.order_date, o.order_status, c.customer_id, c.first_name, c.last_name, p.product_name, oi.quantity,
(oi.quantity × oi.list_price × (1 − discount)).as line_total 
from sales.customers as c
inner join sales.orders as o
on c.customer_id = o.customer_id
inner join sales.order_items as oi
on o.order_id = oi.order_id
inner join production.products as p
on oi.product_id = p.product_id;


----Q10
select first_name,last_name
from sales.customers;


----Q11
select 
from sales.customers
left join 

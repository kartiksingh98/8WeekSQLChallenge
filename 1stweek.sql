--1
select customer_id,sum(a.price) as total_spent from menu a
inner join sales b on 
a.product_id=b.product_id
group by customer_id;

--2
select customer_id, count(distinct(order_date)) from 
sales 
group by customer_id


--3
with cte as (
select customer_id, order_date, product_name, 
dense_rank() over( partition by a.customer_id order by a.order_Date) as ranki
from sales a inner join menu b on a.product_id=b.product_id
)

select * from cte where ranki=1


--4

select top 1 count(a.product_id) as most, b.product_name  from sales a
inner join menu b on a.product_id=b.product_id
group by a.product_id, b.product_name
order by most desc


--5
with cte as (
select count(a.product_id) as order_count, a.customer_id, b.product_name,
dense_rank() over ( partition by a.customer_id order by count(customer_id) desc) as rank1
from sales a
inner join menu b on a.product_id=b.product_id
group by a.customer_id, a.product_id, b.product_name
)

select * from cte where rank1=1

--6

with cte as(
select a.customer_id, a.product_id, order_date, c.product_name,
DENSE_RANK() over( partition by a.customer_id order by order_date) as rank1
from sales a inner join members b
on a.customer_id=b.customer_id
inner join menu c on a.product_id=c.product_id
where a.order_date>=b.join_date
group by a.customer_id, a.product_id, order_date, c.product_name
)
select customer_id, order_date, product_id, product_name from cte where rank1=1

--7

with cte as(
select a.customer_id, a.product_id, order_date, c.product_name,
DENSE_RANK() over( partition by a.customer_id order by order_date desc) as rank1
from sales a inner join members b
on a.customer_id=b.customer_id
inner join menu c on a.product_id=c.product_id
where a.order_date<b.join_date
group by a.customer_id, a.product_id, order_date, c.product_name
)
select * from cte where rank1=1

--8


select a.customer_id, 
count(distinct a.product_id) as count,
sum(c.price) as total 
from sales a inner join members b
on a.customer_id=b.customer_id
inner join menu c on a.product_id=c.product_id
where a.order_date<b.join_date
group by a.customer_id

--9

with cte as(
select *, 
case when product_id=1
then price*20
else 
price*10
end as points
from menu)

select a.customer_id, sum(b.points) from 
sales a inner join cte b on a.product_id=b.product_id
group by a.customer_id


--10
with cte as
(
select *,
dateadd(day, 6, join_date) as oneweek,
cast('2021-01-31' as date) as end_date
from members
)

select b.customer_id,
sum( case when order_date between join_date and oneweek
then
price*20
else 
price*10
end) as points 
from cte a inner join sales b
on a.customer_id=b.customer_id
inner join menu c on
c.product_id=b.product_id
group by b.customer_id
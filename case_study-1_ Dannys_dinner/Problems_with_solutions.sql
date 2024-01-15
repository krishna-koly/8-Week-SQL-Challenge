select * from sales;
select * from menu;
select * from members;

-- Question 01 : What is the total amount each customer spent at the restaurant? --
Select customer_id as Customer, sum(m.price) as Total_amount
from sales
join menu m using(product_id)
group by customer_id;

-- Question 02 : How many days has each customer visited the restaurant? --
Select customer_id as Customer, count(distinct(order_date)) as Total_visited_days
from sales
join menu m using(product_id)
group by customer_id;

-- Question 03 : What was the first item from the menu purchased by each customer? --
with temp as 
(select s.customer_id as Customer, product_name, order_date, dense_rank() over(partition by s.customer_id order by order_date) as rnk
from menu
join sales s using(product_id)
)
Select Customer, product_name, order_date
From temp
Where rnk = 1;
-- Question 04 : What is the most purchased item on the menu and how many times was it purchased by all customers? --
select product_name, count(product_id)as most_purchased
from menu
join sales using(product_id)
group by product_name
order by most_purchased desc
limit 1;

-- Question 05 : Which item was the most popular for each customer? --

with temp as
(select customer_id,product_name,count(product_id), dense_rank()over(partition by customer_id order by count(product_id) desc) as most_popular
from menu
join sales using(product_id)
group by customer_id,product_name
)
select customer_id,product_name, most_popular from temp
where most_popular =1;


-- 6. Which item was purchased first by the customer after they became a member?

With temp as
(
select *,dense_rank() over(partition by s.customer_id order by s.order_date) as first_purchase
from sales s 
join members mb using(customer_id)
where mb.join_date<=s.order_date
) 
select customer_id,product_name,order_date 
from temp
join menu using(product_id)
where first_purchase = 1;

-- 07 Which item was purchased just before the customer became a member?

with temp as
(
select *,
dense_rank() over(partition by s.customer_id order by order_date desc) as just_purchase_before_a_member
from sales s 
join members mb 
using(customer_id)
where mb.join_date>order_date
) 
select customer_id,product_name,order_date 
from temp
join menu using(product_id)
where just_purchase_before_a_member = 1;


-- 08 What is the total items and amount spent for each member before they became a member? --

select customer_id, count(DISTINCT(product_id)) as total_items,sum(price) as amount_spent
from sales s 
join members m
using(customer_id)
join menu
using(product_id)
where join_date>order_date
group by customer_id;

-- 09. If each $1 spent equates to 10 points and sushi has a 2x points multiplier, how many points would each customer have? --
with points as
(
select *,
(case when product_name = 'Sushi' then price*10*2
else price*10
end
) as point_earned
from menu
join sales 
using (product_id)
)

select customer_id, sum(point_earned) as total_point
from points
group by customer_id
order by customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi-- how many points do customer A and B have at the end of January?

WITH points_calc AS (
  SELECT *,
    (
      CASE
        WHEN s.order_date - m.join_date >= 0 and s.order_date — m.join_date <= 6 THEN price * 10 * 2
        WHEN product_name = ‘sushi’ THEN price * 10 * 2
        ELSE price * 10
      END
    ) as points
  FROM sales s
  JOIN menu mu
  USING (product_id)
  JOIN members m
  USING (customer_id)
  WHERE EXTRACT(MONTH FROM order_date) = 1 AND EXTRACT(YEAR FROM order_date) = 2021
)
SELECT customer_id, SUM(points) AS points_total
FROM points_calc
GROUP BY customer_id;











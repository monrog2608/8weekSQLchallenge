'1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01) '

Select count(runner_id) as runner_sign_up, week(date_add(registration_date, Interval 2 Day)) as number_of_week
From runners
Group by number_of_week;

'2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order? '

Create View Delivery_Time_By_Runner As Select r.runner_id, r.pickup_time, c.order_time, 
TIMESTAMPDIFF(minute, c.order_time, r.pickup_time) as delivery_time_in_minutes
From runner_orders as r
Join customer_orders as c On r.order_id = c.order_id
Where pickup_time != 0;

Select runner_id, round(avg(delivery_time_in_minutes),0) as average_time
From delivery_time_by_runner
Group by runner_id;

'3. Is there any relationship between the number of pizzas and how long the order takes to prepare? '

Create View Order_time_pizza As
Select c.order_id, count(c.order_id) as number_of_pizza, c.order_time, r.pickup_time,
TIMESTAMPDIFF(minute, c.order_time, r.pickup_time) as delivery_time_in_minutes
From customer_orders as c
Join runner_orders as r On c.order_id = r.order_id
Where pickup_time != 0
Group by c.order_id, c.order_time, r.pickup_time;

Select number_of_pizza, round(avg(delivery_time_in_minutes),0) as average_delivery_time
From Order_time_pizza
Group by number_of_pizza;

'4. What was the average distance travelled for each customer?'

Select c.customer_id, round(avg(r.distance),0) as average_distance
From customer_orders as c
Join runner_orders as r On c.order_id = r.order_id
Where r.duration != 0
Group by c.customer_id;

'5. What was the difference between the longest and shortest delivery times for all orders? '

SELECT 
  max(left(duration,2)) - min(left(duration,2)) as the_biggest_difference
FROM runner_orders
WHERE duration != 'null';

'6. What was the average speed for each runner for each delivery and do you notice any trend for these values? '

Select r.runner_id, c.customer_id, c.order_id, count(c.order_id) as quality_of_pizzas,
 r.distance, round(avg(r.distance/(left(r.duration,2))*60),2) as average_speed
From runner_orders as r
Join customer_orders as c On r.order_id=c.order_id
Where r.duration != 'null'
Group by r.runner_id,  c.customer_id, c.order_id
Order by c. order_id;

'7. What is the successful delivery percentage for each runner? '

Select runner_id, 
round( 100* sum(case when distance = 'null' Then 0 Else 1 END) / count(distance),0) as successful_delivery_percentage
From runner_orders
Group by runner_id;

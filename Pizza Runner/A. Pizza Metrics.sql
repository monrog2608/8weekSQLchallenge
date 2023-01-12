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


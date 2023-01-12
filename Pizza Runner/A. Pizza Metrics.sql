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

Select runner_id, count(runner_id) as number_of_successful_orders
From Runner_orders
Where distance !=0
Group by runner_id;

'4. How many of each type of pizza was delivered?'

Select p.pizza_name, count(c.pizza_id) as number_of_delivered_pizza
From customer_orders as c
Join runner_orders as r On c.order_id=r.order_id
Join pizza_names as p on c.pizza_id=p.pizza_id
Where distance !=0
Group by p.pizza_name;

'5. How many Vegetarian and Meatlovers were ordered by each customer?'

Select c.customer_id, p.pizza_name, count(p.pizza_name) as quatity
From customer_orders as c
Join pizza_names as p on c.pizza_id=p.pizza_id
Group by c.customer_id, p.pizza_name
Order by c.customer_id;

'6. What was the maximum number of pizzas delivered in a single order?'

Create view count_of_pizza As
Select c.order_id, count(c.pizza_id) as quantity_of_pizza
From customer_orders as c
Join runner_orders as r on c.order_id = r.order_id
Where r.distance !=0
Group by c.order_id;

Select max(quantity_of_pizza) as maximum_number_of_pizzas_delivered
From count_of_pizza;

'7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?'

Select c.customer_id,
sum(case when c.exclusions != '' and c.exclusions != 'null' or c.extras != '' and c.extras != 'null' Then 1 Else 0 END) as at_least_1_change,
sum(case when c.exclusions = '' or c.exclusions = 'null' and c.extras = '' or c.extras = 'null' Then 1 Else 0 END) as no_changes
From customer_orders as c
Join runner_orders as r on c.order_id = r.order_id
Where r.distance !=0
Group by c.customer_id
Order by c.customer_id;

' 8. How many pizzas were delivered that had both exclusions and extras?'

Select sum(case
when c.exclusions != '' and c.exclusions != 'null' and c.extras != '' and c.extras != 'null' 
Then 1 Else 0 END) as exclusions_and_extras
From customer_orders as c
Join runner_orders as r on c.order_id = r.order_id
Where r.distance !=0;

'9. What was the total volume of pizzas ordered for each hour of the day?'

Select count(order_id) as quatity_of_pizzas, hour(order_time) as hours_of_the_day
From customer_orders as c
Group by hours_of_the_day
Order by hours_of_the_day;

'10. What was the volume of orders for each day of the week?'

Select date_format(date_add(order_time, Interval 2 Day), '%W') as day_of_the_week, count(order_id) as total_of_pizzas
From customer_orders 
Group by day_of_the_week
Order by total_of_pizzas DESC;


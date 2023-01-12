'1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - 
how much money has Pizza Runner made so far if there are no delivery fees? '

Select sum(case
when c.pizza_id =1 Then 12
Else 10 End) as money_earned
From runner_orders as r
Join customer_orders as c On r.order_id=c.order_id
Where r.distance != 0;

'2. What if there was an additional $1 charge for any pizza extras? 
Add cheese is $1 extra '

Create view total_money as
Select (case
when c.pizza_id =1 Then 12
Else 10 End) as money_earned, c.extras, c.exclusions
From runner_orders as r
Join customer_orders as c On r.order_id=c.order_id
Where r.distance != 0;

Select sum(case
when (extras ='' or extras ='null' or extras is null) Then money_earned
when length(extras) = 1 Then money_earned +1
Else money_earned + 2
End) as total_cost
From total_money;

'3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, 
how would you design an additional table for this new dataset - 
generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5. 
4. Using your newly generated table - can you join all of the information together to form a table 
which has the following information for successful deliveries?
customer_id   order_id   runner_id  rating  order_time 
pickup_time  Time between order and pickup  Delivery duration Average speed Total number of pizzas '

Create View All_information As
Select c.customer_id, c.order_id, r.runner_id, c.order_time, r.pickup_time, 
timestampdiff( minute, c.order_time, r.pickup_time) as time_between_order_and_pickup_time, r.duration as delivery_duration,
round(avg(r.distance/(left(r.duration,2))*60),2) as average_speed, count(c.order_id) as total_number_of_pizzas
From customer_orders as c
Join runner_orders as r On c.order_id=r.order_id
Group by c.customer_id, c.order_id, r.runner_id, c.order_time, r.pickup_time,time_between_order_and_pickup_time, r.duration
Order by c.customer_id;

Create View All_information_with_rating as
Select *, (case 
when time_between_order_and_pickup_time is null Then 1
when time_between_order_and_pickup_time > 25 Then 2
when time_between_order_and_pickup_time >= 20 and time_between_order_and_pickup_time <25 Then 3
when time_between_order_and_pickup_time >10 and time_between_order_and_pickup_time < 20  Then 4
Else 5 End) as rating
From All_information;

Select runner_id, round(avg(rating),2) as average_rating
From All_information_with_rating
Group by runner_id
Order by runner_id;

'5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras 
and each runner is paid $0.30 per kilometre traveled - 
how much money does Pizza Runner have left over after these deliveries? '

SELECT round(sum(CASE 
WHEN c.pizza_id=1 THEN 12
WHEN c.pizza_id = 2 THEN 10 END)  - SUM((r.distance+0) * 0.3),2) AS pizza_cost
FROM runner_orders r
JOIN customer_orders c ON c.order_id = r.order_id
WHERE r.distance != 0;
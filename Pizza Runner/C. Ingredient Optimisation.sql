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
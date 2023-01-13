' 1 What are the standard ingredients for each pizza?'

Create table pizza_recipos_2
(pizza_id int,
toppinings int);

Insert into pizza_recipos_2(pizza_id, toppinings)
value
(1,1), (1,2), (1,3), (1,4), (1,5), (1,6), (1,8), (1,10),
(2,4), (2,6), (2,7), (2,9), (2,11), (2,12);

Select *
From pizza_recipos_2;

Create View Ingredietns_pizza As
Select pn.pizza_name, pr2.pizza_id, pt.topping_name
From pizza_recipos_2 as pr2
Join pizza_toppings as pt On pr2.toppinings = pt.topping_id
Join pizza_names as pn On pr2.pizza_id=pn.pizza_id
Order by pr2.pizza_id;

Select pizza_name, group_concat(topping_name) as all_ingredients
From ingredients_pizza
Group by pizza_name;

'2. What was the most commonly added extra?'

Select pizza_id, extras
From customer_orders
Where extras != '' and extras != 'null'

Create table extras_pizza
(pizza_id int
extras int);

Insert into extras_pizza(pizza_id, extras)
values
(1,1),(2,1),(1,1),(1,5),(1,1),(1,4);

Select *
From extras_pizza;

Select ep.extras, pt.topping_name, count(ep.extras) as number_of_repetitions
From extras_pizza as ep
Join pizza_toppings as pt On ep.extras = pt.topping_id
Group by ep.extras;

'3. What was the most common exclusion?'

Select pizza_id, exclusions
From customer_orders
Where exclusions != '' and exclusions != 'null';

Create table exclusions_pizza
(pizza_id int,
exclusions int);

Insert table exclusions_pizza(pizza_id,exlucions)
values
(1,4), (1,4), (2,4), (1,4), (1,2),(1,6);

Select *
From exclusions_pizza;

Select xp.exclusions, pt.topping_name, count( xp.exclusions) as number_of_repetitions
From exclusions_pizza as xp
Join pizza_toppings as pt On xp.exclusions = pt.topping_id
Group by xp.exclusions;

'4. Generate an order item for each record in the customers_orders table in the format of one of the following:
a. Meat Lovers
b. Meat Lovers - Exclude Beef
c. Meat Lovers - Extra Bacon
d. Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers'

Select c.order_id, c.customer_id, c.pizza_id, c.exclusions, c.extras, c.order_time, case
when c.pizza_id = 1 and (exclusions ='' or exclusions ='null') and (extras ='null' or extras = '') then 'Meat Lovers'
when c.pizza_id = 1 and (exclusions like '%3' or exclusions = 3) and (extras ='null' or extras ='') then 'Meat Lovers - Exclude Beef'
when c.pizza_id = 1 and (extras like '%1' or extras =1) and (exclusions ='null' or exclusions ='') then 'Meat Lovers - Extra Bacon'
when c.pizza_id = 1 and (exclusions like '%1' or exclusions = 1) and (exclusions like '%4' or exclusions = 4)
and (extras like '%6' or extras =6) and (extras like '%9' or extras =9) then 'Meat Lovers - Excluse Cheese, Bacon - Extras Mushrooms, Peppers'
when c.pizza_id = 1 and (exclusions like '%4' or exclusions = 4) and (extras ='null' or extras ='') then 'Meat Lovers - Exclude Cheese'
when c.pizza_id = 1 and (exclusions like '%4' or exclusions = 4) and (extras like '%1' or extras =1) and (extras like '%5' or extras =5)
then 'Meat Lovers - Exclude Cheese - Extras Bacon, Chicken'
when c.pizza_id = 1 and (exclusions like '%2' or exclusions = 2) and (exclusions like '%6' or exclusions = 6)
and (extras like '%1' or extras =1) and (extras like '%4' or extras =4)
then 'Meat Lovers - Exclude BBQ Sauce, Mushrooms - Extras Bacon, Cheese'
when c.pizza_id = 2 and (exclusions ='' or exclusions ='null') and (extras ='null' or extras = '') then 'Veg Lovers'
when c.pizza_id = 2 and (exclusions like '%4' or exclusions = 4) 
and (extras ='null' or extras ='' or extras is null) then 'Veg Lovers -  Exlude Cheese'
when c.pizza_id = 2 and (extras like '%1' or extras =1) and (exclusions ='' or exclusions ='null') then 'Veg Lovers- Extra Bacon'
End as Order_item
From customer_orders as c
Join pizza_names as p On p.pizza_id=c.pizza_id;

'5. Generate an alphabetically ordered comma separated ingredient list for each pizza order 
from the customer_orders table and add a 2x in front of any relevant ingredients
a. For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"'

Create view ingredient_names as 
Select pr.pizza_id, group_concat(topping_name) as ingredients
From pizza_recipos_2 as pr
Join pizza_toppings as pt On pr.toppinings = pt.topping_id
Group by pr.pizza_id;

Create view table_of_extras as 
Select c.order_id, case
when (c.extras like '%1' or c.extras =1) Then 'Bacon'
Else ''
End as Extras_Ingredients_1, case
when (c.extras like '%4' or c.extras =4) Then 'Cheese'
when (c.extras like '%5' or c.extras =5) Then 'Cheese'
Else ''
End as Extras_Ingredients_2, pn.pizza_name, i.ingredients
From customer_orders as c
Join pizza_names as pn On c.pizza_id = pn.pizza_id
Join ingredient_names as i On pn.pizza_id=i.pizza_id;

Select *
From table_of_extras;

Select order_id, CONCAT(pizza_name, ': ', case
when Extras_Ingredients_1 != ''
Then REPLACE(REPLACE(ingredients, Extras_Ingredients_2,
CONCAT('2x', Extras_Ingredients_2)), Extras_Ingredients_1, CONCAT('2x', Extras_Ingredients_1))
Else ingredients
End)
as pizza_ingredients
From table_of_extras;

'6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?'

Select pt.topping_name, count(c.pizza_id) as number_of_used
From customer_orders as c
Join pizza_recipos_2 as pr On pr.pizza_id = c.pizza_id
Join pizza_toppings as pt On pt.topping_id = pr.toppinings
Join runner_orders as r On r.order_id=c.order_id
Where r.distance != 0
Group by pr.toppinings
Order by number_of_used Desc;

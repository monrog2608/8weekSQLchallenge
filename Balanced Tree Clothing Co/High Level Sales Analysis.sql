'1. What was the total quantity sold for all products? '

Select sum(qty) as total_quantity_sold_products
From sales;

'2. What is the total generated revenue for all products before discounts? '

Select sum(qty *price) as total_revenue
From sales;

'3. What was the total discount amount for all products? '

Select round(sum(qty * price * discount/100),2) as total_discount
From sales;
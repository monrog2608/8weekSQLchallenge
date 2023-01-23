'Using a single SQL query - create a new output table which has the following details: 
How many times was each product viewed? 
How many times was each product added to cart? 
How many times was each product added to a cart but not purchased (abandoned)? 
How many times was each product purchased? '

Create View page_view_cart_add As
SELECT e.visit_id, h.product_id, h.page_name AS product_name, h.product_category,
SUM(CASE WHEN e.event_type = 1 THEN 1 ELSE 0 END) AS page_view,
SUM(CASE WHEN e.event_type = 2 THEN 1 ELSE 0 END) AS cart_add
FROM events AS e
JOIN page_hierarchy AS h ON e.page_id = h.page_id
WHERE h.product_id IS NOT NULL
GROUP BY e.visit_id, h.product_id, h.page_name, h.product_category;

Create View purchase_table As
SELECT DISTINCT visit_id
FROM events
WHERE event_type = 3;

Create View page_card_purchase As
SELECT pv.visit_id, pv.product_id, pv.product_name, pv.product_category, pv.page_view, pv.cart_add,
CASE WHEN pt.visit_id IS NOT NULL THEN 1 ELSE 0 END AS purchase
FROM page_view_cart_add AS pv
LEFT JOIN purchase_table AS pt ON pv.visit_id = pt.visit_id;

Create View combined_table As
SELECT product_name, product_category, SUM(page_view) AS views, SUM(cart_add) AS cart_adds, 
SUM(CASE WHEN cart_add = 1 AND purchase = 0 THEN 1 ELSE 0 END) AS abandoned,
SUM(CASE WHEN cart_add = 1 AND purchase = 1 THEN 1 ELSE 0 END) AS purchases
FROM page_card_purchase
GROUP BY product_id, product_name, product_category;

Select *
From combined_table
Order by product_name;

'Additionally, create another table which further aggregates the data for the above points 
but this time for each product category instead of individual products. '

Create View combined_table_2 As
SELECT product_category, SUM(page_view) AS views, SUM(cart_add) AS cart_adds, 
SUM(CASE WHEN cart_add = 1 AND purchase = 0 THEN 1 ELSE 0 END) AS abandoned,
SUM(CASE WHEN cart_add = 1 AND purchase = 1 THEN 1 ELSE 0 END) AS purchases
FROM page_card_purchase
GROUP BY product_category;

'10. Which product had the most views, cart adds and purchases? '

Select product_name, views, cart_adds, purchases
From combined_table
Order by views DESC, cart_adds DESC, purchases DESC LIMIT 1;

Select product_name, views, cart_adds, purchases
From combined_table
Order by cart_adds DESC, views DESC, purchases DESC LIMIT 1;

'11. Which product was most likely to be abandoned? '

Select product_name, abandoned as most_likely_to_be_abandoned
From combined_table
Order by most_likely_to_be_abandoned DESC Limit 1;

'12.Which product had the highest view to purchase percentage? '

Select product_name, round(100* purchases/views,2) as purchase_percentage
From combined_table
Order by purchase_percentage DESC LIMIT 1;

'13. What is the average conversion rate from view to cart add? '

Select round(100* sum(cart_adds)/sum(views) ,2) as average_view_to_cart_add_conversion_rate
From combined_table;

'14. What is the average conversion rate from cart add to purchase? '

Select round(100* sum(purchases)/sum(cart_adds) ,2) as average_view_to_cart_add_conversion_rate
From combined_table;


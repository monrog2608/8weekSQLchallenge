'1. How many users are there?'

Select count(distinct(user_id)) as number_of_users
From users;

'2. How many cookies does each user have on average? '

Select round(count(distinct(cookie_id))/count(distinct(user_id)),0) as average_cookies
From users;

'3. What is the unique number of visits by all users per month? '

Select month(event_time) as number_of_month, count(distinct(visit_id)) as number_of_visits
From events
Group by number_of_month
Order by number_of_month;

'4. What is the number of events for each event type? '

Select e.event_type, i.event_name, count(e.visit_id) as number_of_events
From events as e
Join event_identifier as i On i.event_type = e.event_type
Group by event_type
Order by event_type;

'5. What is the percentage of visits which have a purchase event? '

SELECT round(100 * COUNT(DISTINCT e.visit_id)/(SELECT COUNT(DISTINCT visit_id) FROM events),2) AS percentage_purchase
FROM events AS e
JOIN event_identifier AS i ON e.event_type = i.event_type
WHERE i.event_name = 'Purchase';

'6. What is the percentage of visits which view the checkout page but do not have a purchase event? '

Create View Checkout_and_purchase As
Select visit_id, max(case 
when event_type = 1 and page_id =12 Then 1 Else 0 End )as view_the_checkout_page,
max(case when event_type = 3 Then 1 Else 0 End) as purchase_event
From events
Group by visit_id
Order by visit_id;

SELECT 100-round((100*sum(purchase_event)/sum(view_the_checkout_page)),2) as percentage_checkout_page_not_purchase
FROM Checkout_and_purchase;

'7. What are the top 3 pages by number of views? '

Select e.page_id, h.page_name, count(e.visit_id) as number_of_views
From events as e
Join page_hierarchy as h on e.page_id = h.page_id
Where e.event_type = 1
Group by e.page_id
Order by number_of_views DESC Limit 3;

'8. What is the number of views and cart adds for each product category? '

Select h.product_category, sum(
case when e.event_type = 1 Then 1 Else 0 End) as number_of_views,
sum(case when e.event_type = 2 Then 1 Else 0 End) as number_of_cart_adds
From events as e
Join page_hierarchy as h On e.page_id = h.page_id
Where h.product_category is not null
Group by h.product_category
Order by h.product_category;

'9. What are the top 3 products by purchases? '

Create View Purchase As
Select e.visit_id, e.page_id, max(case when e.event_type = 3 Then 1 Else 0 End) as purchase_event, h.product_id
From events as e
Join page_hierarchy as h On h.page_id = e.page_id
Where h.product_id is not null 
Group by e.visit_id
Order by e.visit_id;

Select product_id, count(purchase_event)
From Purchase
Where purchase_event = 1;

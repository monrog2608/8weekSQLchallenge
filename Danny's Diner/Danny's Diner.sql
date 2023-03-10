CREATE SCHEMA dannys_diner;

CREATE TABLE Sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INT);

INSERT INTO sales(customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE Menu (
  product_id INT,
  product_name VARCHAR(5),
  price INT);

INSERT INTO Menu(product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE Members (
  customer_id VARCHAR(1),
  join_date DATE);

INSERT INTO Members(customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
'1. What is the total amount each customer spent at the restaurant?'
Select customer_id, sum(price) as total_amount
From Sales as s
Join Menu as m on s.product_id=m.product_id
Group by customer_id;

'2. How many days has each customer visited the restaurant?'
Select customer_id, count(distinct(order_date)) as sum_of_days
From Sales
Group by customer_id;

'3. What was the first item from the menu purchased by each customer?'
Select customer_id, product_name, order_date
From Menu as M
Join Sales as S on M.product_id = S.product_id
Group by customer_id;

'4 What is the most purchased item on the menu and how many times was it purchased by all customers?'
SELECT COUNT(s.product_id) AS most_purchased, product_name
FROM sales AS s
JOIN menu AS m ON s.product_id = m.product_id
GROUP BY s.product_id, product_name
ORDER BY most_purchased DESC
Limit 1;

'5. Which item was the most popular for each customer?'
Create View Ranking_of_items As
Select customer_id, count(s.product_id) as quantity_of_item, product_name,
Dense_rank() over(partition by customer_id order by count(s.product_id) DESC) as ranking
From sales as S
Join Menu as M On S.product_id=M.product_id
Group by customer_id, product_name;

Select customer_id, product_name
From ranking_of_items
Where ranking=1;

'6.Which item was purchased first by the customer after they became a member?'

Create View Ranking_of_date As
Select s.customer_id, order_date, product_id, join_date, 
Dense_rank() over(partition by s.customer_id order by order_date) as ranking
From Sales as S
Join Members as Mb On S.customer_id=Mb.customer_id
Where order_date >= join_date;

Select customer_id, order_date, M.product_name
From ranking_of_date as RD
Join Menu as M On RD.product_id=M.product_id
Where ranking =1;

'7.Which item was purchased just before the customer became a member?'
Create View Ranking_of_date2 As
Select s.customer_id, order_date, product_id, join_date, 
Dense_rank() over(partition by s.customer_id order by order_date DESC) as ranking
From Sales as S
Join Members as Mb On S.customer_id=Mb.customer_id
Where order_date < join_date;

Select customer_id, order_date, M.product_name
From ranking_of_date2 as RD2
Join Menu as M On RD2.product_id=M.product_id
Where ranking =1;

'8. What is the total items and amount spent for each member before they became a member?'
SELECT s.customer_id, COUNT(s.product_id) AS total_items, SUM(m.price) AS total_sales
FROM sales AS s
JOIN members AS mb ON s.customer_id = mb.customer_id
JOIN menu AS m ON s.product_id = m.product_id
WHERE s.order_date < mb.join_date
GROUP BY s.customer_id;

'9 If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?'
Create view Points as
Select *, 
Case
When m.product_id = 1 Then m.price * 20
Else m.price *10 
End as total_points
From Menu as M;

Select s.customer_id, sum(p.total_points) as customer_points
From Points as p
Join sales as S on p.product_id = s. product_id
Group by s.customer_id;

'10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - 
how many points do customer A and B have at the end of January?'

Create view table_of_days as
Select *, date_add(join_date, interval 6 Day) as after_first_week, last_day('2021-01-31') AS last_date
From members as mb;

SELECT t.customer_id,
SUM( CASE 
WHEN m.product_name = 'sushi' THEN 2 * 10 * m.price
WHEN s.order_date BETWEEN t.join_date AND t.after_first_week THEN 2 * 10 * m.price
ELSE 10 * m.price END) AS points
FROM table_of_days AS t
JOIN sales AS s ON t.customer_id = s.customer_id
JOIN menu AS m ON s.product_id = m.product_id
WHERE s.order_date < t.last_date
GROUP BY t.customer_id;






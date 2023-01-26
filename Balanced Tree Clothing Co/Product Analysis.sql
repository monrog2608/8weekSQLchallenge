 '10 .What are the top 3 products by total revenue before discount? '
 
 Select s. prod_id, d.product_name, sum(s.qty*s.price) as revenue
 From sales as s
 Join product_details as d On s.prod_id = d.product_id
 Group by prod_id, d.product_name
 Order by revenue DESC Limit 3;

'11. What is the total quantity, revenue and discount for each segment? '

Select d.segment_name, sum(s.qty) as total_quantity, sum(s.qty*s.price) as revenue, 
round(sum((s.qty*s.discount*s.price)/100),2) as total_discount
 From sales as s
 Join product_details as d On s.prod_id = d.product_id
 Group by d.segment_name
 Order by d.segment_name;

'12. What is the top selling product for each segment? '

Select d.segment_name, d.product_name, sum(s.qty) as total_selling,
RANK() OVER (PARTITION BY d.segment_name ORDER BY SUM(s.QTY) DESC) AS rank_selling
From sales as s
Join product_details as d On s.prod_id = d.product_id
Group by d.segment_name, d.product_name
Order by rank_selling;

'13. What is the total quantity, revenue and discount for each category? ' 

Select d.category_name, sum(s.qty) as total_quantity, sum(s.qty*s.price) as revenue, 
round(sum((s.qty*s.discount*s.price)/100),2) as total_discount
 From sales as s
 Join product_details as d On s.prod_id = d.product_id
 Group by d.category_name
 Order by d.category_name;
 
'14. What is the top selling product for each category? '

Select d.category_name, d.product_name, sum(s.qty) as total_selling,
RANK() OVER (PARTITION BY d.category_name ORDER BY SUM(s.QTY) DESC) AS rank_selling
From sales as s
Join product_details as d On s.prod_id = d.product_id
Group by d.category_name, d.product_name
Order by rank_selling;

'15. What is the percentage split of revenue by product for each segment? '

Create View revenue_segment As
Select d.segment_name, d.product_name, sum(s.qty*s.price) as revenue
From sales as s
Join product_details as d On s.prod_id = d.product_id
Group by d.segment_name, d.product_name
Order by revenue DESC;

Create view total_revenue_segment As
Select d.segment_name, sum(s.qty*s.price) as total_revenue
From sales as s
Join product_details as d On s.prod_id = d.product_id
Group by d.segment_name
Order by total_revenue DESC;

Select s.segment_name, s.product_name, round(100*s.revenue/t.total_revenue,2) as percentage_split_of_revenue
From revenue_segment as s
Join total_revenue_segment as t On s.segment_name=t.segment_name
Order by percentage_split_of_revenue DESC;

'16. What is the percentage split of revenue by segment for each category? '

Create View revenue_category As
Select d.category_name, d.segment_name, sum(s.qty*s.price) as revenue
From sales as s
Join product_details as d On s.prod_id = d.product_id
Group by d.category_name, d.segment_name
Order by revenue DESC;

Create view total_revenue_category As
Select d.category_name, sum(s.qty*s.price) as total_revenue
From sales as s
Join product_details as d On s.prod_id = d.product_id
Group by d.category_name
Order by total_revenue DESC;

Select c.category_name, c.segment_name, round(100*c.revenue/t.total_revenue,2) as percentage_split_of_revenue
From revenue_category as c
Join total_revenue_category as t On c.category_name=t.category_name
Order by percentage_split_of_revenue DESC;


'17. What is the percentage split of total revenue by category?' 

Select d.category_name, sum(s.qty*s.price) as total_revenue
From sales as s
Join product_details as d On s.prod_id = d.product_id
Group by d.category_name
Order by total_revenue DESC;

Select category_name, round(100*total_revenue/(Select sum(total_revenue) 
From total_revenue_category),2) as percentage_split_of_total_revenue
From total_revenue_category;

'18.What is the total transaction “penetration” for each product? 
(hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided
 by total number of transactions) '

Select d.product_name, count(s.txn_id) as total_transaction, round(100 *count(s.txn_id)/
(Select count(distinct(s.txn_id)) From Sales as s),2) as penetration
From sales as s
Join product_details as d On s.prod_id = d.product_id
Group by d.product_name;

'19. What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction? '

Create View transaction_and_product As
Select s.txn_id, d.product_name
From sales as s
Join product_details as d On s.prod_id = d.product_id;

Select p1.product_name as product_1, p2.product_name as product_2, p3.product_name as product_3, count(*) as transactions
From transaction_and_product as p1
Join transaction_and_product as p2 On p1.txn_id = p2.txn_id and p1.product_name < p2.product_name
Join transaction_and_product as p3 On p1.txn_id = p3.txn_id 
and p1.product_name < p3.product_name and p2.product_name < p3.product_name
Where p1.product_name is not null and p2.product_name is not null and p3.product_name is not null
Group by p1.product_name, p2.product_name, p3.product_name
Order by transactions DESC Limit 1;

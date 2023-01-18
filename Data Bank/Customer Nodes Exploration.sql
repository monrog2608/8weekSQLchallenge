'1. How many unique nodes are there on the Data Bank system? ' 

Select count(distinct(node_id)) as unique_nodes
From customer_nodes;

'2. What is the number of nodes per region? '

Select c.region_id, r.region_name, count(c.node_id) as number_of_nodes
From customer_nodes as c
Join regions as r On r.region_id = c.region_id
Group by c.region_id
Order by c.region_id;

'3. How many customers are allocated to each region? '

Select c.region_id, r.region_name, count(distinct(customer_id)) as customers
From customer_nodes as c
Join regions as r On r.region_id = c.region_id
Group by c.region_id
Order by c.region_id;

'4. How many days on average are customers reallocated to a different node? '

SELECT round(avg(datediff(end_date, start_date)), 2) AS avg_reallocation_days
FROM customer_nodes
WHERE end_date!='9999-12-31';

  '5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region? '

Create View reallocation_days_table as
Select c.customer_id, c.region_id, c.node_id, r.region_name, datediff(c.end_date, c.start_date) as reallocation_day
From customer_nodes as c
Join regions as r On r.region_id = c.region_id
Where c.end_date != '9999-12-31';

Create View percentile As
Select *, percent_rank() over(partition by region_id order by reallocation_day)*100 as percent 
From reallocation_days_table;

Select region_id, region_name, reallocation_day
From percentile
Where percent>95
Group by region_id;

Select region_id, region_name, reallocation_day
From percentile
Where percent>80 
Group by region_id;





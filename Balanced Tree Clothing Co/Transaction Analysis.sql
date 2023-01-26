'4. How many unique transactions were there? '

Select count(distinct(txn_id)) as number_of_transactions
From sales;

'5. What is the average unique products purchased in each transaction? '

Select round(avg(unique_products),0) as average_unique_products 
From (Select txn_id, count(distinct(prod_id)) as unique_products
From sales
Group by txn_id)temp;


'6 What are the 25th, 50th and 75th percentile values for the revenue per transaction? '

Create View Revenue_transaction As
SELECT distinct(txn_id), SUM(qty*price) AS revenue
FROM sales
GROUP BY txn_id;

Create View percentile_rank As
SELECT txn_id, revenue, ROUND(PERCENT_RANK() OVER (ORDER BY txn_id),2) as percentile_rank
FROM Revenue_transaction
Order by percentile_rank DESC;

Select *
From percentile_rank
Where percentile_rank>0.50
Group by txn_id;


'7. What is the average discount value per transaction? '

Select round(avg(total_discount),2) as average_discount_per_transaction
From
(Select txn_id, sum(qty*price*discount /100) as total_discount
From sales
Group by txn_id) temp;

'8. What is the percentage split of all transactions for members vs non-members? '

Select round(100*count(distinct case
when members = 1 Then txn_id Else 0 End)/count(distinct(txn_id)),2) as members_percentage,
round(100*count(distinct case when members= 0 Then txn_id Else 0 End)/count(distinct(txn_id)),2) as non_members_percentage
From sales;

'9. What is the average revenue for member transactions and non-member transactions? '

Create View members_revenu As
Select members, txn_id, sum(qty*price) as revenue
From sales
Group by members, txn_id;

Select members, round(avg(revenue),2) as average_revenue
From members_revenu
Group by members;
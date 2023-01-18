'1. What is the unique count and total amount for each transaction type? '

Select txn_type, count(txn_amount) as unique_count, sum(txn_amount) as total_amount
From customer_transactions
Group by txn_type
Order by txn_type;

'2. What is the average total historical deposit counts and amounts for all customers? '

Create View deposit As
Select customer_id, txn_type, count(*) as txn_count, avg(txn_amount) as average_amount
From customer_transactions
Where txn_type = 'deposit'
Group by customer_id, txn_type;

Select round(avg(txn_count),0) as avg_count, round(avg(average_amount),2) as avg_amount
From deposit;

'3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month? '

Create View transaction_count As
Select customer_id, month(txn_date) as txn_month, 
sum(if(txn_type='deposit',1,0)) as deposit_count,
sum(if(txn_type='purchase',1,0)) as purchase_count,
sum(if(txn_type='withdrawal',1,0)) as withdrawal_count
From customer_transactions
Group by customer_id, txn_month;

Select txn_month, count(distinct customer_id) as customer_count
From transaction_count
Where deposit_count > 1 and (purchase_count =1 or withdrawal_count =1)
Group by txn_month;

'4. What is the closing balance for each customer at the end of the month? '

Create View last_day_month As
Select customer_id, last_day(txn_date) as closing_month,
txn_type, txn_amount,
sum(case when txn_type = 'withdrawal' or txn_type = 'purchase' then (-txn_amount) Else txn_amount End) as transaction_balance
From customer_transactions
Group by customer_id, last_day(txn_date)
Order by customer_id;

Create View table_ex_4 As
SELECT customer_id, closing_month, COALESCE(transaction_balance, 0) AS monthly_change,
SUM(transaction_balance) OVER (PARTITION BY customer_id ORDER BY closing_month 
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS closing_balance
FROM last_day_month;

'5. What is the percentage of customers who increase their closing balance by more than 5%?'

Create View sequence_table As
SELECT customer_id, closing_month, closing_balance,
ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY closing_month) AS sequence
FROM table_ex_4;

Create View next_balance_table As
SELECT customer_id, closing_month, closing_balance, 
LEAD(closing_balance) OVER (PARTITION BY customer_id ORDER BY closing_month) AS next_balance
FROM sequence_table;

SELECT customer_id, closing_month, closing_balance, next_balance,  
ROUND((1.0 * (next_balance - closing_balance)) / closing_balance,2) AS variance_value
FROM next_balance_table
WHERE closing_month = '2020-01-31' and next_balance is not null
GROUP BY customer_id, closing_month, closing_balance, next_balance
HAVING round(1.0 *(next_balance - closing_balance) / closing_balance,2) > 5.0;





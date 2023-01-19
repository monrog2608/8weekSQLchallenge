'1. What day of the week is used for each week_date value? '

Select dayname(week_date) as day_of_the_week
From clean_weekly_sales
Group by day_of_the_week;

 '2. What range of week numbers are missing from the dataset? '

CREATE TABLE numbers (n INT);
INSERT INTO numbers VALUES (1),(2),(3),(4),(5), (6), (7), (8),(9),
(10), (11),(12),(13),(14),(15), (16), (17), (18),(19),
(20), (21),(22),(23),(24),(25), (26), (27), (28),(29),
(30), (31),(32),(33),(34),(35), (36), (37), (38),(39),
(40), (41),(42),(43),(44),(45), (46), (47), (48),(49),
(50), (51), (52);

Select n.n as missing_week_number
From numbers as n
LEFT OUTER JOIN clean_weekly_sales as s
ON n.n = s.week_number
WHERE s.week_number IS NULL;

'3. How many total transactions were there for each year in the dataset? '

Select calendar_year, sum(transactions) as total_transactions
From clean_weekly_sales
Group by calendar_year
Order by calendar_year;

'4. What is the total sales for each region for each month?'

Select region, month_number, sum(sales) as total_sales
From clean_weekly_sales
Group by region, month_number
Order by region, month_number;

'5. What is the total count of transactions for each platform '

Select platform, count(transactions) as total_count_of_transactions
From clean_weekly_sales
Group by platform
Order by total_count_of_transactions;

'6. What is the percentage of sales for Retail vs Shopify for each month? '

Create View Sales_platform As
Select calendar_year, month_number, platform, sum(sales) as total_sales
From clean_weekly_sales
Group by calendar_year, month_number, platform;

Select calendar_year, month_number,
Round(100*Max(Case When platform = 'Retail' Then total_sales Else Null End)/sum(total_sales),2) as retail_percentage,
Round(100*Max(Case When platform = 'Shopify' Then total_sales Else Null End)/sum(total_sales),2) as shopify_percentage
From Sales_platform
Group by calendar_year, month_number
Order by calendar_year, month_number;

'7. What is the percentage of sales by demographic for each year in the dataset?'

Create View Sales_demographic As
Select calendar_year, demographic, sum(sales) as total_sales
From clean_weekly_sales
Group by calendar_year, demographic
Order by calendar_year;

Select calendar_year, 
Round(100*Max(Case When demographic = 'Couples' Then total_sales Else Null End)/sum(total_sales),2) as couples_percentage,
Round(100*Max(Case When demographic = 'Families' Then total_sales Else Null End)/sum(total_sales),2) as families_percentage,
Round(100*Max(Case When demographic = 'unknown' Then total_sales Else Null End)/sum(total_sales),2) as unknow_percentage
From Sales_demographic
Group by calendar_year
Order by calendar_year;

'8. Which age_band and demographic values contribute the most to Retail sales? '

Select age_band, demographic, platform, sum(sales) as retail_sales
From clean_weekly_sales
Where platform = 'Retail'
Group by age_band, demographic
Order by retail_sales DESC;

'9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? 
If not - how would you calculate it instead?'

Select calendar_year, platform, round(avg(avg_transaction),2) as average_transaction_by_row,
round(sum(sales)/sum(transactions),2) as average_transaction_by_group
From clean_weekly_sales
Group by calendar_year, platform
Order by calendar_year, platform;

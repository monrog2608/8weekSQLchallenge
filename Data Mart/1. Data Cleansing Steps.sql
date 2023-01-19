Create View clean_weekly_sales As
Select
str_to_date(week_date, '%d/%m/%Y') AS week_date,
week(str_to_date(week_date, '%d/%m/%Y')) as week_number,
month(str_to_date(week_date, '%d/%m/%Y')) as month_number,
year(str_to_date(week_date, '%d/%m/%Y')) as calendar_year,
region,
platform,
segment,
(Case When Right(segment,1) = 1 Then 'Young Adults' 
When Right(segment,1) = 2 Then 'Middle Aged'
When Right(segment,1) in (3,4) Then 'Retirees'
Else 'unknown' End) As age_band,
(Case When Left(segment,1) = 'C' Then 'Couples' 
When Left(segment,1) = 'F' Then 'Families'
Else 'unknown' End) As demographic,
customer_type,
transactions,
round(sales/transactions,2) as avg_transaction,
sales
From weekly_sales;



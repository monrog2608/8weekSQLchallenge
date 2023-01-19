' 1. What is the total sales for the 4 weeks before and after 2020-06-15? 
What is the growth or reduction rate in actual values and percentage of sales? '

Create View week_number_20_27 As
Select week_date, week_number, sum(sales) as total_sales
From clean_weekly_sales
Where (week_number between 20 and 27) and calendar_year = 2020
Group by week_date, week_number;

Create View changes As
Select sum(case when week_number between 20 and 23 Then total_sales End) as before_change,
sum(case when week_number between 24 and 27 Then total_sales End) as after_change
From week_number_20_27;


Select before_change, after_change, (after_change - before_change) as growth_or_reduction,
round(100*(after_change-before_change)/before_change,2) as percentage
From changes;

'2. What about the entire 12 weeks before and after? '

Create View week_number_12_35 As
Select week_date, week_number, sum(sales) as total_sales
From clean_weekly_sales
Where (week_number between 12 and 35) and calendar_year = 2020
Group by week_date, week_number;

Create View changes_2 As
Select sum(case when week_number between 12 and 23 Then total_sales End) as before_change,
sum(case when week_number between 24 and 35 Then total_sales End) as after_change
From week_number_12_35;


Select before_change, after_change, (after_change - before_change) as growth_or_reduction,
round(100*(after_change-before_change)/before_change,2) as percentage
From changes_2;

'3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019? '

Create View week_number_12_35_years As
Select calendar_year, week_date, week_number, sum(sales) as total_sales
From clean_weekly_sales
Where (week_number between 12 and 35)
Group by calendar_year, week_date, week_number;

Create View changes_3 As
Select sum(case when week_number between 12 and 23 Then total_sales End) as before_change,
sum(case when week_number between 24 and 35 Then total_sales End) as after_change, calendar_year
From week_number_12_35_years
Group by calendar_year;


Select calendar_year, before_change, after_change, (after_change - before_change) as growth_or_reduction,
round(100*(after_change-before_change)/before_change,2) as percentage
From changes_3
order by calendar_year;

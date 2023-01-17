'1.How many customers has Foodie-Fi ever had?'

Select count(distinct(customer_id)) as unique_customers
From subscriptions;

'2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value '

Select monthname(start_date) as months, count(customer_id) as number_of_customer
From subscriptions
Where plan_id = 0
Group by months
Order by start_date;

'3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name '

Select p.plan_name, count(s.customer_id) as year_2021
From subscriptions as s
Join plans as p On p.plan_id=s.plan_id
Where year(s.start_date) = 2021
Group by p.plan_id
Order by p.plan_id;

'4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place? '

Select count(customer_id) as churn_count, round(100*count(customer_id)/
(Select count(distinct customer_id) From subscriptions),1) as churn_percentage
From subscriptions
Where plan_id = 4;

'5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number? '

Create View ranking As
SELECT s.customer_id, s.plan_id, p.plan_name,
ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.plan_id) AS plan_rank 
FROM subscriptions as s
JOIN plans as p ON s.plan_id = p.plan_id;

Select count(customer_id) as resignation_after_trial_plan, 
round(100*count(customer_id)/
(Select count(distinct customer_id) From subscriptions),1) as churn_percentage
From ranking
Where plan_id = 4 and plan_rank =2;

'6. What is the number and percentage of customer plans after their initial free trial? '

Select  (case
when plan_id = 1 and plan_rank = 2 Then '1'
when plan_id = 2 and plan_rank = 2 Then '2'
when plan_id = 3 and plan_rank = 2 Then '3'
when plan_id =4 and plan_rank = 2 Then '4'
End) as plan, count(customer_id) as number_of_customer, 
round(100*count(customer_id)/
(Select count(distinct customer_id) From subscriptions),1) as percentage_of_customer
From ranking
Where plan_rank = 2
Group by plan
Order by plan;

'7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?'

Create view next_plan As
SELECT customer_id, plan_id, start_date,
LEAD(start_date, 1) OVER (PARTITION BY customer_id ORDER BY start_date) as next_date
FROM subscriptions
Where start_date <= '2020-12-31';

Select plan_id, count(customer_id) as customer, 
round(100*count(customer_id)/
(Select count(distinct customer_id) From subscriptions),1) as percentage_of_customer
From next_plan
Where next_date is null  
Group by plan_id
Order by plan_id;

'8. How many customers have upgraded to an annual plan in 2020? '

Select count(customer_id) as upgrade_to_an_annual_plan_in_2020
From subscriptions
Where plan_id = 3 and year(start_date) = 2020;

'9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?' 

Create View Trial_date_table As
Select customer_id, start_date as trial_date
From subscriptions
Where plan_id = 0;

Create View Annual_date_table As
Select customer_id, start_date as annual_date
From subscriptions
Where plan_id = 3;

Select round(avg(datediff(a.annual_date, t.trial_date)),0) as average_number_of_days_to_annual_plan
From Trial_date_table as t
Join Annual_date_table as a On t.customer_id = a.customer_id;

'10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc) '

Select (case 
when datediff(a.annual_date, t.trial_date) <30 Then '0-30 days'
when datediff(a.annual_date, t.trial_date) <60 and datediff(a.annual_date, t.trial_date) >=30 Then '30-60 days'
when datediff(a.annual_date, t.trial_date) <90 and datediff(a.annual_date, t.trial_date) >=60  Then '60-90 days'
when datediff(a.annual_date, t.trial_date) <120 and datediff(a.annual_date, t.trial_date) >=90 Then '90-120 days'
when datediff(a.annual_date, t.trial_date) <150 and datediff(a.annual_date, t.trial_date) >=120 Then '120-150 days'
when datediff(a.annual_date, t.trial_date) <180 and datediff(a.annual_date, t.trial_date) >=150 Then '150-180 days'
when datediff(a.annual_date, t.trial_date) <210 and datediff(a.annual_date, t.trial_date) >=180 Then '180-210 days'
when datediff(a.annual_date, t.trial_date) <240 and datediff(a.annual_date, t.trial_date) >=210 Then '210-240 days'
when datediff(a.annual_date, t.trial_date) <270 and datediff(a.annual_date, t.trial_date) >=240 Then '240-270 days'
when datediff(a.annual_date, t.trial_date) <300 and datediff(a.annual_date, t.trial_date) >=270 Then '270-300 days'
when datediff(a.annual_date, t.trial_date) <330 and datediff(a.annual_date, t.trial_date) >=300 Then '300-330 days'
Else '330-360 days'
End) as range_of_days, count(*) as customer
From Trial_date_table as t
Join Annual_date_table as a On t.customer_id = a.customer_id
Group by range_of_days
Order by datediff(a.annual_date, t.trial_date);

'11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020? '

Create view next_plan_id As
SELECT customer_id, plan_id, start_date,
LEAD(plan_id, 1) OVER (PARTITION BY customer_id ORDER BY plan_id) as next_plan_id
FROM subscriptions
Where start_date <= '2020-12-31';

Select count(customer_id) as customers_downgraded_from_promonthly_to_basic_2020
From next_plan_id
Where plan_id = 2 and next_plan_id =1;






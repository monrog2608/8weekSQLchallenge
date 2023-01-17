Create View All_Information As
Select s.customer_id, p.plan_id, p.plan_name, p.price, s.start_date
From plans as p
Join subscriptions as s On p.plan_id=s.plan_id
Where s.customer_id In (1, 2, 11, 13, 15, 16, 18, 19) and p.plan_id !=0;

Select customer_id, plan_name, price, start_date
From All_Information
Where plan_id = 0;

Select customer_id, plan_name, price, start_date
From All_Information
Where plan_id = 1;

Select customer_id, plan_name, price, start_date
From All_Information
Where plan_id = 2 and customer_id != 13 and customer_id != 1 and customer_id != 16;

Select customer_id, plan_name, price, start_date
From All_Information
Where plan_id = 4 and customer_id != 13 and customer_id != 1 and customer_id != 16
and customer_id != 15 and customer_id != 18 and customer_id != 19 and customer_id != 2;

Select customer_id, plan_name, price, start_date
From All_Information
Where plan_id = 4 and customer_id !=11;


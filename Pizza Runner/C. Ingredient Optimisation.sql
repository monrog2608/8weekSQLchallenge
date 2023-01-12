' 1 What are the standard ingredients for each pizza?'

Create table pizza_recipos_2
(pizza_id int,
toppinings int);

Insert into pizza_recipos_2(pizza_id, toppininigs)
value
(1,1), (1,2), (1,3), (1,4), (1,5), (1,6), (1,8), (1,10),
(2,4), (2,6), (2,7), (2,9), (2,11), (2,12);

Select *
From pizza_recipos_2;

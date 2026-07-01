select * from walmart_sales
select count(distinct Branch) from walmart_sales
drop table walmart_sales
select count(distinct branch) from walmart_sales
select payment_method, count(*) as count_method
from walmart_sales group by 1

select min(quantity) from walmart_sales

-- Business Problems
--Q.1 Find different payment method and number of transactions, number of qty sold
select payment_method,count(*) as no_of_transactions,
sum(quantity) as no_of_quantity_sold
from walmart_sales
group by 1

--Q2 Identify the highest-rated category in each branch, displaying the branch, category
-- AVG RATING
select * from 
(select branch,category,avg(rating) as avg_rating,
rank() over(partition by branch order by avg(rating) desc) as rank
from walmart_sales
group by 1,2)
where rank=1

--Q3  Identify the busiest day for each branch based on the number of transactions
select branch,day,no_of_transactions from 
(select branch, to_char(to_date(date,'dd/mm/yy'),'Day') as day,
count(*) as no_of_transactions,
rank() over(partition by branch order by count(*) desc) as rnk
from walmart_sales
group by 1,2)
where rnk=1

-- Q. 4 
-- Calculate the total quantity of items sold per payment method. List payment_method and total_quantity.
select * from walmart_sales

select payment_method,sum(quantity) as no_of_item_sold
from walmart_sales
group by 1

--Q.5
-- Determine the average, minimum, and maximum rating of category for each city. 
-- List the city, average_rating, min_rating, and max_rating.
select city,category,min(rating) as min_rating,max(rating) as max_rating,avg(rating) as avg_rating
from walmart_sales
group by 1,2

--Q.6
-- Calculate the total profit for each category by considering total_profit as
-- (unit_price * quantity * profit_margin). 
-- List category and total_profit, ordered from highest to lowest profit.

select category,sum(total_amount) as total_revenue,sum(total_amount*profit_margin) as total_profit
from walmart_sales
group by 1
order by 2 desc,3 desc

-- Q.7
-- Determine the most common payment method for each Branch. 
-- Display Branch and the preferred_payment_method.
select * from walmart_sales;
select branch,payment_method,no_of_transaction from
(
select branch,payment_method,count(*) as no_of_transaction,
rank() over(partition by branch order by count(*) desc) as rnk
from walmart_sales
group by 1,2
)
where rnk=1

---- Q.8
-- Categorize sales into 3 group MORNING, AFTERNOON, EVENING 
-- Find out each of the shift and number of invoices
select * from walmart_sales
select count(*) as no_of_transaction,
case when extract(hour from (time::time))<12 then 'Morning'
     when extract(hour from (time::time)) between 12 and 17 then 'Afternoon'
	 else 'Evening'
	 end as shift
from walmart_sales
group by 2

--Identify 5 branch with highest revenue decrease ratio in 
-- revevenue compare to last year(current year 2023 and last year 2022)

-- rdr == last_year_rev-current_year_rev/last_year_rev*100

select *,extract( year from to_date(date,'dd/mm/yy')) as year_formatted
from walmart_sales
--2022 sales 
with revenue_2022 as (
select branch,sum(total_amount) as total_revenue
from walmart_sales
where extract( year from to_date(date,'dd/mm/yy'))=2022
group by 1
order by 1
),

 revenue_2023 as
(
select branch,sum(total_amount) as total_revenue
from walmart_sales
where extract( year from to_date(date,'dd/mm/yy'))=2023
group by 1
order by 1
)
select ls.branch,ls.total_revenue as last_year_revenue,cs.total_revenue as current_year_revenue,
round((ls.total_revenue-cs.total_revenue)::numeric/ls.total_revenue::numeric*100,2) as rdr
from revenue_2022 ls join revenue_2023 cs on ls.branch=cs.branch
where ls.total_revenue>cs.total_revenue
order by 4 desc
limit 5

--Q10 which branches have high sales but poor customer satisfaction
with business_status1 as (
select branch,sum(total_amount) as total_revenue,avg(rating) as avg_rating,
case when sum(total_amount)>25000 and avg(rating)<6 then 'High sales --low satisfaction'
when sum(total_amount) between 10000 and 25000 and avg(rating) between 6 and 8 then 'Medium sales and Medium satisfaction'
when sum(total_amount)>25000 and avg(rating)>8 then 'Strong Performnace'
else 'Need attention'
end as business_status
from walmart_sales
group by 1
order by 1
)
select branch,total_revenue,avg_rating,business_status
from business_status1
where business_status = 'High sales --low satisfaction'

--Q11 which product categories generate high revenue but low profitability
select * from walmart_sales;
with category_segmentation1 as(
select category,sum(total_amount) as total_revenue,avg(profit_margin) as avg_profit_margin,
case when sum(total_amount)>60000 and avg(profit_margin)>0.60 then 'High margin category'
when sum(total_amount)>60000 and avg(profit_margin)<0.40 then 'Volume heavy but profit light'
when sum(total_amount) between 40000 and 60000 and avg(profit_margin) between 0.40 and 0.60 then 'revenue driver but weak profitability'
else 'low margin'
end as category_segmentation
from walmart_sales
group by 1
order by 2 desc
) 
select category,total_revenue,avg_profit_margin,category_segmentation
from category_segmentation1
where category_segmentation= 'Volume heavy but profit light'

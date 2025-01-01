create database case1;
use case1;

-- ## Data Cleansing 

create table clean_weekly_sales  as 
select week_date ,
 week(week_date) as week_number,
 month(week_date) as month_number,
 year(week_date) as calender_year,
 region , platform ,
case 
     when segment is null then 'Unknown'
     else segment
end as segment,
case 
      when right(segment , 1) = 1 then 'Young Adults'
      when right(segment , 1) =  2  then 'Middle Aged'
       when right(segment , 1) in  (3,4)  then 'Retirees'
      else 'Unknown'
end as age_band,
case 
    when left(segment , 1) = 'C' then 'Couples'
    when left(segment , 1) = 'F' then 'Families'
    else 'Unknown'
end as demographic,
customer_type,
transactions,
sales,
round((sales/transactions),2) as 'avg_transactions'
from weekly_sales;


-- Data Exploration

## 1. Which week numbers are missing from the dataset?
    --   there are 52 week in a year now we make a table of sequence 100
    
create table seq100 (x int auto_increment primary key);
insert into seq100 values (),(),(),(),(),(),(),(),(),();
insert into seq100 values (),(),(),(),(),(),(),(),(),();
insert into seq100 values (),(),(),(),(),(),(),(),(),();
insert into seq100 values (),(),(),(),(),(),(),(),(),();
insert into seq100 values (),(),(),(),(),(),(),(),(),();

-- x is auto incriment so we dont fill this bracket and the value starts from 1

insert into seq100 select x+50 from seq100;

-- they insert another 50 incrimented values and inserted into seq100

create table seq52 as (select x from seq100 limit 52);

-- we create a table of 52 sequence because 52 weeks in a year.

select *from seq52;

-- main query for checking missing weeks from data sets 

select distinct x  from seq52
where x  not in (select distinct week_number  
                 from clean_weekly_sales);

SELECT week_number
FROM clean_weekly_sales;

# 2.How many total transactions were there for each year in the dataset?

select calender_year , sum(transactions) as total_transactions
from clean_weekly_sales
group by calender_year
order by calender_year;


# 3.What are the total sales for each region for each month?

select month_number , region , sum(sales) as total_sales
from clean_weekly_sales
group by month_number , region ;

# 4.What is the total count of transactions for each platform?

select platform , sum(transactions) as total_count_of_transactions
from clean_weekly_sales 
group by platform;

# 5.What is the percentage of sales for Retail vs Shopify for each month?

with cte_mothly_platform_sales as
(select 
month_number,
calender_year,
platform,
sum(sales) as monthly_sales
from clean_weekly_sales
group by platform , month_number , calender_year
)

select month_number , calender_year ,
round(100*max(case when platform = 'shopify' then monthly_sales else null end)/sum(monthly_sales),2) as shopify_percentage,
round(100*max(case when platform = 'retail' then monthly_sales else null end)/sum(monthly_sales),2) as retail_percentage
from cte_mothly_platform_sales
group by month_number , calender_year;

-- for retail percentage we do  ---->>>>   100*(retail sales)/(total monthly sales)  and same as for shopify percentage.
-- is used to calculate the percentage contribution of retail sales to the total monthly sales, rounded to 2 decimal places.



# 6.What is the percentage of sales by demographic for each year in the dataset?
select  calender_year ,
demographic,
sum(sales) as yearly_sales,
round(100*sum(sales)/sum(sum(sales))over(partition by demographic),2)
from clean_weekly_sales
group by calender_year , demographic;

-- The formula 100 * SUM(sales) / SUM(SUM(sales)) is typically used to calculate the percentage contribution
--  of a subset of sales relative to a total sum of sales. 

# 7. Which age_band and demographic values contribute the most to Retail sales?

select 
age_band,
demographic,
sum(sales) as most_retail_sales
from clean_weekly_sales 
where platform = 'retail'
group by age_band , demographic
order by most_retail_sales desc
limit 1 ;





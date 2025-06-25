create database wallmart;

use wallmart;
select * from sales_data;

#Renaming columns
ALTER TABLE sales_data
CHANGE `Invoice Id` invoice_id VARCHAR(255);

ALTER TABLE sales_data
CHANGE `Customer type` customer_type VARCHAR(255);

ALTER TABLE sales_data
CHANGE `Product line` product_line VARCHAR(255);

ALTER TABLE sales_data
CHANGE `Unit price` unit_price VARCHAR(255);

ALTER TABLE sales_data
CHANGE `Tax 5%` tax_5perc VARCHAR(255);

ALTER TABLE sales_data
CHANGE `gross margin percentage` gross_margin_perc VARCHAR(255);

ALTER TABLE sales_data
CHANGE `gross income` gross_income VARCHAR(255);

#unique city
select count(distinct City) from sales_data;

#unique branch, city
select distinct Branch, City from sales_data; 

#Product
#How many unique product lines does the data have?
select count(distinct product_line) from sales_data;

#most common payment method
select Payment, 
count(Payment) payment_count 
from sales_data 
group by Payment
order by count(Payment) desc;

#most selling product line
select product_line, 
sum(Quantity) total_quantity
from sales_data 
group by product_line
order by total_Quantity desc;

#total revenue by month
select monthname(Date), 
month(Date) month_number,
sum(Total) total_revenue
from sales_data
group by monthname(Date), month(Date)
order by month(Date);

#largest COGS
select monthname(Date), 
month(Date) month_number,
sum(COGS) total_cogs
from sales_data
group by monthname(Date), month(Date)
order by sum(COGS) desc;

#product line with the largest revenue
select product_line, 
sum(total) total_revenue
from sales_data
group by product_line
order by sum(total) desc;

#product line with the most amount of VAT
select product_line, 
sum(tax_5perc) total_VAT
from sales_data
group by product_line
order by sum(tax_5perc) desc;

#Product performance analysis by average revenue
select product_line, 
avg(total) product_line_avg_revenue,
(Select avg(total) from sales_data) as overall_avg_revenue,
case when avg(total)>(select avg(total) from sales_data) then 'Good'
else 'Bad'
end as product_performance
from sales_data
group by product_line;

#branch with more than average product
select Branch, 
avg(Quantity) branch_avg_quantity,
(Select avg(Quantity) from sales_data) as overall_avg_quantity
from sales_data
group by Branch
having avg(Quantity)>(Select avg(Quantity) from sales_data) ;

#most common product line by gender
select Gender,
product_line, 
count(product_line) product_line_count
from sales_data
group by Gender, product_line
order by count(product_line) desc
limit 2;


#Most bought product line by each gender  
with product_line_count as 
(select Gender,
product_line, 
count(product_line) product_line_count
from sales_data
group by Gender, product_line),

product_line_rank as 
(select Gender,
product_line, 
product_line_count,
dense_rank() over(partition by Gender order by product_line_count desc) as pl_rank
from product_line_count)
select Gender,
product_line, 
product_line_count
from product_line_rank where pl_rank=1;

#Average rating of each product line
select product_line,
round(avg(Rating),2) avg_rating
from sales_data
group by product_line;

#Number of sales made in each time of the day per weekday
with order_count as
(select hour(Time) hour,
count(invoice_id) as no_of_order
from sales_data
where weekday(Date) between 0 and 4
group by hour(Time)
order by hour(Time))
select hour,
round(avg(no_of_order),0) as avg_no_of_order
from order_count
group by hour;

#Which of the customer types brings the most revenue?
select customer_type,
sum(total) as total_revenue
from sales_data
group by customer_type
order by sum(total) desc;

#Which city has the largest tax percent/ VAT (Value Added Tax)?
select City,
sum(tax_5perc) as total_tax
from sales_data
group by City
order by sum(tax_5perc) desc;

#Which customer type pays the most in VAT?
select customer_type,
sum(tax_5perc) as total_tax
from sales_data
group by customer_type
order by sum(tax_5perc) desc;

#What is the gender of most of the customers?
select Gender,
count(Gender) as count
from sales_data
group by Gender
order by count(Gender) desc;

#What is the gender distribution per branch?
with customer_count as
(select Branch,
Gender,
count(Gender) as count
from sales_data
group by Branch,Gender)
select Branch,
Gender,
row_number() over(partition by Branch) as row_no,
count
from  customer_count;

#Which time of the day do customers give most ratings?
select hour(Time) hour,
round(avg(Rating),2) as avg_rating
from sales_data
group by hour(Time)
order by avg(Rating) desc;

select hour(Time) hour,
count(Rating) as rating_count
from sales_data
group by hour(Time) 
order by count(Rating) desc;


#Which time of the day do customers give most ratings per branch?
with avg_rating as
(select 
Branch,
hour(Time) hour,
round(avg(Rating),2) as avg_rating
from sales_data
group by Branch,hour(Time)
order by avg(Rating) desc),
most_rating as
(select 
Branch,
hour,
avg_rating,
dense_rank() over(partition by Branch order by avg_rating desc) as rating_rank
from avg_rating)
select 
Branch,
hour,
avg_rating
from most_rating
where rating_rank=1;

with avg_rating as
(select 
Branch,
hour(Time) hour,
count(Rating) as rating_count
from sales_data
group by Branch,hour(Time)
order by count(Rating) desc),
most_rating as
(select 
Branch,
hour,
rating_count,
dense_rank() over(partition by Branch order by rating_count desc) as rating_count_rank
from avg_rating)
select 
Branch,
hour,
rating_count
from most_rating
where rating_count_rank=1;


#Which day fo the week has the best avg ratings?
with cal_avg_rating as
(select 
dayname(Date) Day,
avg(Rating) as avg_rating
from sales_data
group by dayname(Date)
),
best_rating as
(select 
Day,
avg_rating,
dense_rank() over(order by avg_rating desc) as avg_rating_rank
from cal_avg_rating)
select 
Day,
avg_rating
from best_rating
where avg_rating_rank=1;

#Which day of the week has the best average ratings per branch?
with cal_avg_rating as
(select 
Branch,
dayname(Date) Day,
avg(Rating) as avg_rating
from sales_data
group by Branch,dayname(Date)
),
best_rating as
(select 
Branch,
Day,
avg_rating,
dense_rank() over(partition by Branch order by avg_rating desc) as avg_rating_rank
from cal_avg_rating)
select 
Branch,
Day,
avg_rating
from best_rating
where avg_rating_rank=1;







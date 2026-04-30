CREATE TABLE superstore (
	RowID INT,
    OrderID VARCHAR(20),
    OrderDate DATE,
    Shipdate DATE,
    Shipmode VARCHAR(30),
    customerID VARCHAR(20),
    CustomerName VARCHAR(100),
    Segment VARCHAR(30),
	Country VARCHAR(50),
    City VARCHAR(50),
    State VARCHAR(50),
    PostalCode VARCHAR(20),
    Region VARCHAR(20),
	ProductID VARCHAR(30),
    Category VARCHAR(50),
    SubCategory VARCHAR(50),
    ProductName VARCHAR(130),
    Sales decimal (10,2),
    Quantity INT,
	Discount FLOAT,
    Profit FLOAT
);
select * from superstore limit 5;
select count(*) from superstore;


--Sales Analysis 
--Que1 What is the total sales amount?
select sum(sales) as total_sales from superstore;

--Que2 What are monthly sales trends?
select to_char(orderdate,'yyyy-mm') as year_month,
	   sum (sales) as monthly_sales 
from superstore 
group by year_month
order by year_month;

--Que3 Which year had the highest sales?
select extract(year from orderdate) as year ,
       sum(sales) as total_sales 
from superstore
group by year
order by total_sales desc limit 1;



--What are the top 10 days with highest sales?
select orderdate ,
       sum(sales) as total_sales 
from superstore 
group by orderdate 
order by total_sales desc 
limit 10;

--Which region generates the most sales?
select region,
       sum(sales) as highest_sales 
from superstore 
group by region
order by highest_sales desc 
limit 1;

--Which city has the highest total sales?
select city,
      sum(sales) as highest_sales 
from superstore 
group by city 
order by highest_sales desc 
limit 1;

--Which state contributes the most revenue?
select state,
      sum(sales) as highest_revenue 
from superstore 
group by state 
order by highest_revenue desc 
limit 1;

--What is average sales per order?

select
       avg(total_sales) as avg_sales  
from (
     select orderid,
	        sum(sales) as total_sales 
	 from superstore 
	 group by orderid
  )t;

--Which segment generates the highest sales?
select segment,
      sum(sales) as highest_revenue 
from superstore 
group by segment 
order by highest_revenue desc 
limit 1;


--What is daily/weekly sales trend?
SELECT 
    EXTRACT(YEAR FROM orderdate) AS year,
    EXTRACT(WEEK FROM orderdate) AS week,
    SUM(sales) AS weekly_sales
FROM superstore
GROUP BY 1, 2
ORDER BY year, week;

--👥 2. Customer Analysis 
--Who are the top 10 customers by sales?
select customerid,
       customername,
       sum(sales) as total_sales 
from superstore 
group by customerid,customername
order by total_sales desc 
limit 10;

--Which customer placed the most orders?

select customerid,
       customername,
       sum(quantity) as total_quantity
from superstore 
group by customerid,customername
order by total_quantity desc 
limit 1;

--Which segment has the most customers?

with  t as (
select segment ,
       count(customerid) as total_customer 
from superstore 
group by segment)
select * from t 
where total_customer=(select max(total_customer) from t);

OR
 select segment ,
        count(customerid) as total_customer 
from superstore 
group by segment 
order by total_customer desc 
limit 1;


--What is average spending per customer?

SELECT 
    AVG(total_spent) AS avg_spending_per_customer
FROM (
    SELECT 
        customerid,
        SUM(sales) AS total_spent
    FROM superstore
    GROUP BY customerid
) t;

--Which city has the highest number of customers?
select city,
       count(customerid) as total_customer 
from superstore 
group by city
order by total_customer desc limit 1;

--Who are repeat customers?
select customerid,
       count( distinct orderid) as total_order 
from superstore 
group by customerid 
having count(orderid)>1;

--What is customer distribution by region?
select region,
       count(customerid) as total_customer 
from superstore 
group by region
order by total_customer desc ;

--Which customers are most profitable?
select customerid,
       customername ,
	   sum(profit) as total_profit 
from superstore 
group by customerid,customername 
order by total_profit desc;


--How many unique customers are there?
select count(distinct customerid) as unique_customer 
from superstore;

--Which segment gives highest revenue per customer?
SELECT 
    segment,
    AVG(customer_revenue) AS avg_revenue_per_customer
FROM (
    SELECT 
        segment,
        customerid,
        SUM(sales) AS customer_revenue
    FROM superstore
    GROUP BY segment, customerid
) t
GROUP BY segment
ORDER BY avg_revenue_per_customer DESC;

-- Product Analysis (10 Questions)

--Which product has highest sales?
select productid,
       productname ,
	   sum(sales) as total_sales 
from superstore 
group by productid,productname 
order by total_sales desc 
limit 1;

 select * 
 from (
     select productid,
            productname ,
	        total_sales ,
		    dense_rank() over(order by total_sales desc) as dn		
     from (
	     select productid,
		        productname,
				sum(sales) as total_sales from superstore 
          group by productid,productname)t)x
where dn=1;


--Which product has highest profit?
select * 
 from (
     select productid,
            productname ,
	        total_profit ,
		    dense_rank() over(order by total_profit desc) as dn		
     from (
	     select productid,
		        productname,
				sum(profit) as total_profit from superstore 
          group by productid,productname)t)x
where dn=1;

--Which product has highest quantity sold?

select * from (
           select productid,
                  productname, 
	              sum(quantity) as total_quantity 
           from superstore 
		   group by productid,productname
		   )x
		   where total_quantity= (
		    select max(total_quantity) 
		    from(
			    select productid,
                       productname ,
	                   sum(quantity)as total_quantity 
                from superstore 
                group by productid,productname
				)t
	);

--Which sub-category sells most?
select * from (select subcategory ,
       total_quantity,
	   dense_rank() over(order by total_quantity desc) as dn 
from (
     select subcategory,
	        sum(quantity) as total_quantity 
	 from superstore 
	 group by subcategory 
)t )
where dn=1;


--Which category performs best overall

select category,
       sum(sales)as total_sales ,
	   sum(profit) as total_profit 
from superstore 
group by category 
order by total_profit desc;

--Which products have negative profit?
select productid,
       productname,
	   sum(profit) as product_profit 
from superstore 
group by productid,productname 
having sum(profit) <0
order by product_profit desc;

--Which products are most frequently ordered?
select productid,
       productname ,
	   count( distinct orderid) as total_order 
from superstore 
group by productid,productname 
order by total_order desc 
limit 1;

--What are top 10 best-selling products?
select productid,
       productname ,
	   sum(quantity) as total_order 
from superstore 
group by productid,productname 
order by total_order desc 
limit 10;


--Which products are least sold?
select productid,
       productname ,
	   sum(quantity) as total_order 
from superstore 
group by productid,productname 
order by total_order asc 
limit 1;

--Which category has highest average discount?
select category,
       avg(discount) as avg_discount 
from superstore 
group by category 
order by avg_discount desc 
limit 1; 

select * from superstore limit 5;

🚚 4. Shipping & Delivery Analysis (5 Questions)

--Which ship mode is most used?

select shipmode,
       count(orderid) as shipmode_used 
	   from superstore 
group by shipmode
order by shipmode_used desc limit 1;

--Which ship mode generates highest profit?
select shipmode,
       sum(profit) as total_profit 
	   from superstore 
group by shipmode
order by total_profit desc 
limit 1;

--What is average shipping time?

SELECT 
    AVG(shipping_time) AS avg_shipping_time_days
FROM (
    SELECT 
        orderid,
        (shipdate - orderdate) AS shipping_time
    FROM superstore
    GROUP BY orderid, shipdate, orderdate
) t;

--Which region uses fastest shipping mode most?
select
    Region,
    count(*) as total_same_day_orders
from superstore
where ShipMode = 'Same Day'
group by Region
order by  total_same_day_orders desc;

--Does shipping mode affect profit?
select shipmode,
       sum(profit) as total_profit 
from superstore 
group by shipmode;

-- 5. Region & Geography Analysis 

--Which region generates highest sales?

with sales as (select region ,
      sum(sales) as total_sales 
from superstore 
group by region)
select * from sales where total_sales=(select max(total_sales) from sales);

--Which region has highest profit?

with region_profit as (select region ,
      sum(profit) as total_profit 
from superstore 
group by region)
select * from region_profit where total_profit=(select max(total_profit) from region_profit);

--Which state is most profitable?

select state ,total_profit 
from (
     select state,
	        sum(profit) as total_profit 
	 from superstore 
	 group by state
 )x
where total_profit=(
       select max (state_profit) 
	   from ( 
	        select state,
	               sum(profit) as state_profit 
			 from superstore 
			 group by state
		 )t
);

--Which city has highest loss?
select city,
      sum(profit) as total_loss 
from superstore 
group by city 
order by total_loss asc 
limit 1

--Which region has highest discount usage?
select region,
       avg(discount) as avg_discount 
from superstore 
group by region
order by avg_discount desc 
limit 1;

-- 6. Profit & Discount Analysis (5 Questions)

--What is total profit?

select sum(profit) as total_profit 
from superstore;

--Which category gives highest profit margin?
with profit_margins as (select category,
       sum(profit)as total_profit,
	   sum(sales) as total_sales,
	   sum(profit)/sum(sales) as profit_margin 
from superstore
group by category
order by profit_margin desc)
select * 
from profit_margins 
where profit_margin=(select max(profit_margin) from profit_margins);

--Which orders have negative profit?

select orderid,
       sum(profit) as total_profit
from superstore 
group by orderid
having sum(profit) <0
order by total_profit asc;

--Does higher discount reduce profit?
select 
     case
	    when discount =0 then 'no discount' 
		when discount <=0.2 then 'Low discount'
		when discount<=0.5 then 'medium discount'
		else 'higher dicount'
	end as discount_category,
avg(profit) as avg_profit,
count(*) as orders
from superstore 
group by discount_category
order by avg_profit ;



--What is average discount per category?
select category,
       round(avg(discount)::numeric,2) as avg_discount 
from superstore 
group by category;

--📊 7. Advanced Business Insights (5 Questions)


--What is sales vs profit correlation?


--Which products drive 80% of revenue (Pareto analysis)?
with product_sales as (
         select productid,
	            productname,
			    sum(sales) as product_revenue
	    from superstore 
		group by productid,productname
),	
ranked as (
select productid,
       productname,
	   product_revenue,
	   sum(product_revenue) over(order by product_revenue desc) as running_revenue,
	   sum(product_revenue) over() as total_revenue
from product_sales)
select productid,
       productname,
	   product_revenue,
	   running_revenue,
	   (running_revenue*100/total_revenue) as cummulative_pct
from ranked
where (running_revenue*100/total_revenue)<=80;


--Which customers give high sales but low profit?
with customer_data as (
       select customerid,
       customername ,
	   sum(sales)as total_sales ,
	   sum(profit) as total_profit 
from superstore 
group by  customerid,customername
order by total_sales desc)
SELECT *
FROM customer_data
WHERE total_sales > (
        SELECT AVG(total_sales) FROM customer_data
)
AND total_profit < (
        SELECT AVG(total_profit) FROM customer_data
)
ORDER BY total_sales DESC;

--Which combinations of category + region are most profitable?
select category,
       region,
	   sum(profit) as total_profit 
from superstore 
group by category,region 
order by total_profit desc 
limit 1 ;

--What are overall business growth trends over time?

with sales_growth as (
           select year_month,
                 monthly_sales,
	             lag(monthly_sales) over(order by year_month ) as prev_month_sales
	       from(
	             select to_char( orderdate,'yyyy-mm') as year_month,
                        sum(quantity) as total_quantity,
                        sum(sales) as monthly_sales,
	                    sum(profit) as monthly_Profit 
                 from superstore
                 group by year_month
                 order by  year_month)t)
select year_month,
       monthly_sales,
	   prev_month_sales,
	   (monthly_sales-prev_month_sales)*100/prev_month_sales as monthly_sales_growth
from sales_growth;

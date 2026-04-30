# Superstore_Sql_analysis
SQL and Excel analysis of Superstore sales and profit trends.

## Tools Used
- PostgreSql(Data analysis ,Sql Queries)
- MS Excel (cleaning,Pivot Charts,Dashboard).

## Key Question?
- What is the relationship between sales and profit?
- Which region offers the highest discounts?
- Which region uses fastest shipping the most?
- Which categories are most profitable?
- How do discounts impact profit?

## Key Insights
- High sales do not always result in high profit due to heavy discounting
- Central region has higher discount usage and lower profitability
- Same Day shipping increases cost and impacts profit
- Furniture category often has low or negative profit
- Technology category generates the highest profit

  ## Visualizations
- Sales vs Profit (Scatter Plot)
- Region-wise Sales & Profit (Bar Chart)
- Discount vs Profit Analysis
- Shipping Mode Distribution
- City-wise Sales Map

## Project Structure
- data/ → dataset files  
- sql/ → SQL queries  
- dashboard/ → Excel file  
- images/ → charts/screenshots

  ## How to Use
1. Run SQL queries in PostgreSQL
2. Export results to CSV
3. Open Excel dashboard to explore insights


## Sample queries
  
-- What are overall business growth trends over time?
```
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
```


--Which products drive 80% of revenue (Pareto analysis)?
```
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
```

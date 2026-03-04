/* Rank Function Tasks 
Question 1: Rank the orders based on their sales from highest to lowest */

select orderid,
sales,
row_number() over(order by sales desc) as sales_row,
rank() over(order by sales desc) as sales_rank,
dense_rank() over(order by sales desc) as dense_sales_rank
from salesdb.orders;

/* Question 2: Find the top highest sales for each product 
Explanation
- RANK() - Returns all highest ties
- ROW_NUMBER() - Returns exactly one highest row
- PARTITION BY - Resets ranking per product
- ORDER BY sales DESC - Ensures highest sales come first*/

select productid, 
sales,
product_sales_rank
from (select productid,
sales,
rank() over(partition by productid order by sales desc) as product_sales_rank
from salesdb.orders ) t
where product_sales_rank = 1;

/* QUESTION 3: Find the lowest 2 customers based on their total sales 
Explanation
- First find the total sales for each customer
- Rank their totals
- filter the lowest 2 customers based on their sales*/
select * 
from (
select customerid, 
sum(sales) as total_sales,
row_number() over(order by sum(sales)) as total_sales_rank 
from salesdb.orders
group by customerid ) t
where total_sales_rank <= 2
;

/* QUESTION 4: Assign unique IDs to the rows of the 'Orders_Archive' table */

select *,
row_number() over(order by orderid, orderdate) as unique_id
from salesdb.orders_archive;

/* QUESTION 5: Identify duplicate rows in the table 'Orders Archive' and return a clean result without any duplicate
What this does?
- Partition by orderid - Groups duplicate orderIDs
- order by creationtime desc - Keeps the most recent record
- row_number() - Assigns:
	1 to the newest record
	2,3, ... - Keeps only the latest record per order*/
select *
from (
select *,
row_number() over(partition by orderid order by creationtime desc) as rn
from salesdb.orders_archive) t
where rn = 1;

/* NTILE TASKS 
QUESTION 1 - Segment all orders into 3 categories: high, medium and low sales
Explanation 
- Sort orders by sales (highest first)
- Divide them into 3 equal groups
- Label the groups High, Medium, Low */

 select orderid,
 sales,
 bucket,
 case 
	when bucket = 1 then 'High'
    when bucket = 2 then 'Medium'
    when bucket = 3 then 'Low'
end as Order_cat
 from (select orderid,
 sales,
 ntile(3) over(order by sales desc) as bucket
 from salesdb.orders) t
 ;
 
 /* QUESTION 2: In order to export the data, divide the orders into 2 groups
 this is useful for exporting
 For instance
 
 select *
 from (select *,
 ntile(2) over(order by orderid) as bucket
 from salesdb.orders) t
 where bucket = 1;
 */
 
 select *,
 ntile(2) over(order by orderid) as bucket
 from salesdb.orders;
 
 /* QUESTION 3: Find the products that fall within the highest 40% prices (cume_dist) */
 
 select *,
 concat(round(Dist_rank * 100, 2), ' ', '%') as percent_dist_rank
 from (Select product,
 price,
 cume_dist() over(order by price desc) as Dist_rank   
 from salesdb.products) t
 where Dist_rank <= 0.4;
 

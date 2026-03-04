# SQL-Window-Functions-Ranking-Segmentation-Tasks
## TOOL - MySQL
## DATE - 04/03/2026

## OVERVIEW 
This document covers practical use cases of: 
* ROW_NUMBER()
* RANK()
* DENSE_RANK()
* NTILE()
* CUME_DIST()
* PARTITION BY
*  ORDER BY inside window functions

---

ORDER BY inside window functions

🔹 RANK FUNCTION TASKS

--- 
✅ Question 1: Rank Orders by Sales (Highest to Lowest)
🎯 Goal

Rank all orders based on sales amount.
```sql
select orderid,
       sales,
       row_number() over(order by sales desc) as sales_row,
       rank() over(order by sales desc) as sales_rank,
       dense_rank() over(order by sales desc) as dense_sales_rank
from salesdb.orders;
```

## EXPLANATION

| **FUNCTION** | **Behaviour** |
| ------------ | -------------- |
| `ROW_NUMBER()` | Gives unique sequential numbers (no ties) |
| `RANK()` | Same rank for ties, skips number after ties |
| `DENSE_RANK()` | Same rank for ties, does NOT skip numbers |

📌 Example (Sales: 500, 500, 400)

| **Sales** | **Row_Number** | **Rank** | **Dense_Rank** |
| --------- | -------------- | -------- | --------------- |
| 500 | 1 | 1 | 1 |
| 500 | 2 | 1 | 1 |
| 400 | 3 | 3 | 2 |

---

✅ Question 2: Find Highest Sale Per Product
🎯 Goal

Return the highest sales value for each product.

```sql
select productid, 
       sales,
       product_sales_rank
from (
    select productid,
           sales,
           rank() over(partition by productid order by sales desc) as product_sales_rank
    from salesdb.orders
) t
where product_sales_rank = 1;
```

🧠 Explanation

* PARTITION BY productid → Resets ranking per product

* ORDER BY sales DESC → Highest sale first

* RANK() → Returns all tied highest sales

✔ If two sales tie for highest, both are returned.

---

✅ Question 3: Find Lowest 2 Customers by Total Sales
🎯 Goal

Identify customers with the lowest total sales.

```sql
select * 
from (
    select customerid, 
           sum(sales) as total_sales,
           row_number() over(order by sum(sales)) as total_sales_rank 
    from salesdb.orders
    group by customerid
) t
where total_sales_rank <= 2;
```
🧠 Approach

* Calculate total sales per customer.

* Rank customers by total sales (ascending).

* Select the lowest 2.

---

✅ Question 4: Assign Unique IDs to Orders_Archive
🎯 Goal

Generate unique sequential IDs.
```sql
select *,
       row_number() over(order by orderid, orderdate) as unique_id
from salesdb.orders_archive;
```
🧠 Why Use This?

Useful when:

* Table has no primary key

* Preparing data for export

* Creating temporary unique identifiers

---

✅ Question 5: Remove Duplicate Rows (Keep Latest)
🎯 Goal

Return clean data without duplicates.

```sql
select *
from (
    select *,
           row_number() over(partition by orderid order by creationtime desc) as rn
    from salesdb.orders_archive
) t
where rn = 1;
```

🧠 Explanation

* PARTITION BY orderid → Groups duplicates

* ORDER BY creationtime DESC → Most recent first

* ROW_NUMBER() → Assigns 1 to latest record

* Filter rn = 1 → Keeps only newest row

---

🔹 NTILE TASKS (Data Segmentation)

---
✅ Question 1: Segment Orders into 3 Categories
🎯 Goal

Divide orders into High, Medium, Low sales groups.

```sql
select orderid,
       sales,
       bucket,
       case 
           when bucket = 1 then 'High'
           when bucket = 2 then 'Medium'
           when bucket = 3 then 'Low'
       end as Order_cat
from (
    select orderid,
           sales,
           ntile(3) over(order by sales desc) as bucket
    from salesdb.orders
) t;
```

🧠 Explanation

* Sort by sales (highest first)

* Divide into 3 equal groups

* Label groups

📌 NTILE() splits by number of rows, not sales range.

---

✅ Question 2: Divide Orders into 2 Groups (For Export)

🎯 Goal

Split dataset into two equal parts.

```sql
select *,
       ntile(2) over(order by orderid) as bucket
from salesdb.orders;
```
🧠 Why Useful?

* Export large data in batches

* Parallel processing

* File splitting

Example:
```sql
-- Export first half
where bucket = 1;

-- Export second half
where bucket = 2;
```
---

🔹 CUME_DIST TASK
---

✅ Question 3: Find Products in Highest 40% by Price
🎯 Goal

Return products in the top 40% of prices.

```sql
select *,
       concat(round(Dist_rank * 100, 2), '%') as percent_dist_rank
from (
    select product,
           price,
           cume_dist() over(order by price desc) as Dist_rank   
    from salesdb.products
) t
where Dist_rank <= 0.4;
```

🧠 Explanation

CUME_DIST() returns cumulative distribution (0–1)

Sorted by price DESC

<= 0.4 keeps top 40% most expensive products

✔ More precise than NTILE() for percentile filtering.

---

### SUMMARY 
| **FUNCTION** | **Behaviour** |
| ------------ | -------------- |
| `ROW_NUMBER()` | Unique sequential numbering |
| `RANK()` | Ranking with skipped numbers on ties |
| `DENSE_RANK()` | Ranking without skipped numbers |
| `NTILE(n)` | Divide rows into n equal groups |
| `CUME_DIST()` | Calculate percentile position |

---

🚀 Final Takeaway

These window functions are used for:

* Ranking

* Top/Bottom analysis

* Deduplication

* Segmentation

* Export batching

* Percentile filtering

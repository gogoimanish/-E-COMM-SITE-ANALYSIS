----most bought sub category-------------------------------------------------------------------------------------------------
     
      SELECT 
      sub,
      count(sub) as ct_sub
     group by 
       sub
	order by 
	    ct_sub desc;
  
---- most bought category------------------------------------------------------------------------------------------------------
  
  select 
     category,
    count(category) as ct_cat
   from  
     order_details
   group by 
     Category
    order by
     ct_cat desc;
    
----most valuable customer & item category they demand the most-----------------------------------------------------------------

select 
     l.customer_name,
     count(d.order_id) as total_orders
from 
      order_details d
join 
      order_list l
on 
       d.order_id=l.order_id
group by 
        l.customer_name
order by
        total_orders desc;

with cte1 as 
(
  SELECT 
         l.customer_name, 
         d.category,
         COUNT(d.category) AS total_orders,
         ROW_NUMBER() OVER (PARTITION BY d.category ORDER BY COUNT(d.category) DESC) AS rn
  FROM 
         order_details d
  JOIN 
         order_list l ON d.order_id = l.order_id
  GROUP BY 
         l.customer_name, d.category
) 
SELECT 
        customer_name, 
        category, 
        total_orders
from 
        cte1
WHERE 
        rn = 1
ORDER BY category;

----state & city who has most orders-------------------------------------------------------------------------------------------------

 with cte1 as 
(
SELECT
   l.city ,
   l.State,
    count(d.Order_ID) as total_orders,
    dense_rank() over (PARTITION BY  l.state ORDER BY COUNT(d.Order_ID) DESC) AS rnk
FROM 
   ecomm.order_details d
join  
    order_list l
on 
    d.Order_ID=l.Order_ID
group by  
    l.city,l.State
order by 
     total_orders desc)
select  
      state,city,
      total_orders
from 
     cte1
where 
     rnk=1
order by 
     total_orders desc

---- Total loss by Category FY 18-19-------------------------------------------------------------------------------------------------------- 

WITH cte1 AS (
    SELECT
        l.Fiscal_year,
        d.category,
        SUM(d.profit) AS total_pr
    FROM
        order_details d
    LEFT JOIN
        order_list l ON d.Order_ID = l.Order_ID
    WHERE
        l.Fiscal_year = 'FY 18-19'
    GROUP BY
        d.category, l.Fiscal_year
), cte2 AS (
    SELECT
        category,
        SUM(target) AS total_target,
        fy
    FROM
        ecomm.sales_target
    WHERE
        fy = '18-19'
    GROUP BY
        category, fy
)
SELECT
    COALESCE(cte2.total_target, 0) - COALESCE(cte1.total_pr, 0) AS total_loss,
    cte2.category,
    cte2.fy
FROM
    cte2
LEFT JOIN
    cte1 ON cte2.category = cte1.category
ORDER BY
    total_loss DESC;

----state and city generating most revenues---------------------------------------------------------------------------------------------------------------------

WITH cte1 AS (
    SELECT
        l.state,
        l.city,
        sum(d.amount * d.quantity) AS total_rev,
        ROW_NUMBER() OVER (PARTITION BY l.state ORDER BY sum(d.amount * d.quantity)) AS rn
    FROM
        order_list l
    JOIN order_details d ON l.order_id = d.order_id
    WHERE
        fiscal_year LIKE '18-19'
    GROUP BY
        l.state,
        l.city
)
SELECT
    state,
    city,
    total_rev
FROM
    cte1
WHERE
    rn = 1
ORDER BY
    total_rev DESC;







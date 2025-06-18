use supply_db ;

/*  Question: Month-wise NIKE sales

	Description:
		Find the combined month-wise sales and quantities sold for all the Nike products. 
        The months should be formatted as ‘YYYY-MM’ (for example, ‘2019-01’ for January 2019). 
        Sort the output based on the month column (from the oldest to newest). The output should have following columns :
			-Month
			-Quantities_sold
			-Sales
		HINT:
			Use orders, ordered_items, and product_info tables from the Supply chain dataset.
*/		

SELECT DATE_FORMAT(Order_Date,'%Y-%m') AS Month,
SUM(Quantity) AS Quantities_Sold,
SUM(Sales) AS Sales
FROM
orders AS o
LEFT JOIN
ordered_items AS oi
ON o.Order_Id = oi.Order_Id
LEFT JOIN
product_info AS pi
ON oi.Item_Id=pi.Product_Id
WHERE LOWER(Product_Name) LIKE '%nike%'
GROUP BY Month
ORDER BY Month;



-- **********************************************************************************************************************************
/*

Question : Costliest products

Description: What are the top five costliest products in the catalogue? Provide the following information/details:
-Product_Id
-Product_Name
-Category_Name
-Department_Name
-Product_Price

Sort the result in the descending order of the Product_Price.

HINT:
Use product_info, category, and department tables from the Supply chain dataset.


*/
SELECT Product_Id,
Product_Name,
c.Name AS Category_Name,
d.Name AS Department_Name,
Product_Price
FROM product_info pi
LEFT JOIN category c
ON pi.category_id = c.id
LEFT JOIN department d
ON pi.department_id = d.id
ORDER BY Product_Price DESC
LIMIT 5;
-- **********************************************************************************************************************************

/*

Question : Cash customers

Description: Identify the top 10 most ordered items based on sales from all the ‘CASH’ type orders. 
Provide the Product Name, Sales, and Distinct Order count for these items. Sort the table in descending
 order of Order counts and for the cases where the order count is the same, sort based on sales (highest to
 lowest) within that group.
 
HINT: Use orders, ordered_items, and product_info tables from the Supply chain dataset.

*/
SELECT Product_Name, sum(Sales) AS Sales, count(DISTINCT o.order_id) AS Order_counts
FROM orders o
INNER JOIN ordered_items oi
USING(order_id)
INNER JOIN product_info pi
ON oi.item_id = pi.product_id
WHERE o.type = 'CASH'
GROUP BY Product_Name
ORDER BY count(DISTINCT o.order_id) DESC,sum(Sales) DESC
LIMIT 10;
-- **********************************************************************************************************************************
/*
Question : Customers from texas

Obtain all the details from the Orders table (all columns) for customer orders in the state of Texas (TX),
whose street address contains the word ‘Plaza’ but not the word ‘Mountain’. The output should be sorted by the Order_Id.

HINT: Use orders and customer_info tables from the Supply chain dataset.

*/
SELECT o.*, State, Street
FROM orders o
INNER JOIN customer_info ci
ON ci.id = o.customer_id
WHERE state = 'TX' AND lower(street) like '%plaza%' AND lower(street) NOT LIKE '%mountain%'
ORDER BY order_id;
-- **********************************************************************************************************************************
/*
 
Question: Home office

For all the orders of the customers belonging to “Home Office” Segment and have ordered items belonging to
“Apparel” or “Outdoors” departments. Compute the total count of such orders. The final output should contain the 
following columns:
-Order_Count

*/
SELECT count(order_id) AS Order_count
FROM customer_info ci
INNER JOIN orders o 
ON ci.id = o.customer_id
INNER JOIN ordered_items oi
USING(order_id)
INNER JOIN product_info pi
ON  oi.item_id = pi.product_id 
INNER JOIN department d
ON d.id = pi.department_id
WHERE lower(segment) = 'home office' AND lower(d.Name) = 'apparel' OR lower(d.Name)= 'outdoors'
;
-- **********************************************************************************************************************************
/*

Question : Within state ranking
 
For all the orders of the customers belonging to “Home Office” Segment and have ordered items belonging
to “Apparel” or “Outdoors” departments. Compute the count of orders for all combinations of Order_State and Order_City. 
Rank each Order_City within each Order State based on the descending order of their order count (use dense_rank). 
The states should be ordered alphabetically, and Order_Cities within each state should be ordered based on their rank. 
If there is a clash in the city ranking, in such cases, it must be ordered alphabetically based on the city name. 
The final output should contain the following columns:
-Order_State
-Order_City
-Order_Count
-City_rank

HINT: Use orders, ordered_items, product_info, customer_info, and department tables from the Supply chain dataset.

*/
WITH Orders_summary AS
(
SELECT o.Order_ID , o.Customer_Id
FROM orders o 
INNER JOIN customer_info ci 
ON o.Customer_Id = ci.Id
INNER JOIN ordered_items oi 
USING(Order_Id) 
INNER JOIN product_info pi 
ON oi.Item_Id = pi.Product_Id 
INNER JOIN department d 
ON pi.Department_Id = d.Id
WHERE Segment = 'Home Office' AND d.Name = 'Apparel' OR d.Name = 'Outdoors'
)
SELECT State,City,COUNT(Order_ID),
DENSE_RANK() OVER(PARTITION BY State ORDER BY COUNT(ORDER_ID) DESC) As City_rank
FROM customer_info c  INNER JOIN 
Orders_summary os
ON os.Customer_Id = c.Id
GROUP BY State,City
ORDER BY State,City_rank,City;

-- **********************************************************************************************************************************
/*
Question : Underestimated orders

Rank (using row_number so that irrespective of the duplicates, so you obtain a unique ranking) the 
shipping mode for each year, based on the number of orders when the shipping days were underestimated 
(i.e., Scheduled_Shipping_Days < Real_Shipping_Days). The shipping mode with the highest orders that meet 
the required criteria should appear first. Consider only ‘COMPLETE’ and ‘CLOSED’ orders and those belonging to 
the customer segment: ‘Consumer’. The final output should contain the following columns:
-Shipping_Mode,
-Shipping_Underestimated_Order_Count,
-Shipping_Mode_Rank

HINT: Use orders and customer_info tables from the Supply chain dataset.


*/
SELECT Shipping_Mode,
count(order_id) AS Shipping_Underestimated_Order_Count,
ROW_NUMBER() OVER(PARTITION BY YEAR(order_date) ORDER BY count(order_id) DESC) AS Shipping_Mode_Rank
FROM orders o
INNER JOIN customer_info ci
ON o.Customer_Id = ci.id
WHERE segment = 'Consumer' AND (order_status = 'COMPLETE' OR order_status = 'CLOSED') AND  Scheduled_Shipping_Days < Real_Shipping_Days
GROUP BY Shipping_Mode,YEAR(Order_Date);
-- **********************************************************************************************************************************






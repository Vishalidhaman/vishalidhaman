use supply_db ;


 /* Question : Golf related products

List all products in categories related to golf. Display the Product_Id, Product_Name in the output. Sort the output in the order of product id.
Hint: You can identify a Golf category by the name of the category that contains golf.

*/

select Product_Id, Product_Name
from product_info pi
left join category c
on pi.category_id = c.id
where lower(name) like '%golf%'
order by Product_Id;

-- **********************************************************************************************************************************

/*
Question : Most sold golf products

Find the top 10 most sold products (based on sales) in categories related to golf. Display the Product_Name and Sales column in the output. Sort the output in the descending order of sales.
Hint: You can identify a Golf category by the name of the category that contains golf.

HINT:
Use orders, ordered_items, product_info, and category tables from the Supply chain dataset.


*/
select Product_Name, sum(sales) as Sales
from product_info pi
left join category c
on pi.Category_Id = c.id
left join ordered_items oi
on oi.Item_Id = pi.Product_Id
where lower(name) like '%golf%'
group by Product_Name
order by sales desc
limit 10;

-- **********************************************************************************************************************************

/*
Question: Segment wise orders

Find the number of orders by each customer segment for orders. Sort the result from the highest to the lowest 
number of orders.The output table should have the following information:
-Customer_segment
-Orders


*/
select segment as Customer_segment, count(order_id) as Orders
from customer_info ci
left join orders o
on ci.id = o.Customer_Id
group by Segment
order by Orders desc;


-- **********************************************************************************************************************************
/*
Question : Percentage of order split

Description: Find the percentage of split of orders by each customer segment for orders that took six days 
to ship (based on Real_Shipping_Days). Sort the result from the highest to the lowest percentage of split orders,
rounding off to one decimal place. The output table should have the following information:
-Customer_segment
-Percentage_order_split

HINT:
Use the orders and customer_info tables from the Supply chain dataset.


*/
with segment_split as
(
select segment as Customer_segment, count(order_id) as orders
from customer_info ci
join orders o
on ci.id = o.Customer_Id
where Real_Shipping_Days = 6
group by segment
)
select x.Customer_segment,
round((x.orders)/sum(y.orders) * 100,1) as percentage_order_split
from segment_split as x
join segment_split as y 
group by x.customer_segment
order by percentage_order_split desc;

-- **********************************************************************************************************************************




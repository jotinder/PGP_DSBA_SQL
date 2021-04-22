********************************************************* 1 *********************************************************
select product_class_code, product_id, product_desc,product_price,
CASE
WHEN PRODUCT_CLASS_CODE = 2050 THEN PRODUCT_PRICE+2000
WHEN PRODUCT_CLASS_CODE = 2051 THEN PRODUCT_PRICE+500
WHEN PRODUCT_CLASS_CODE = 2052 THEN PRODUCT_PRICE+600
else PRODUCT_PRICE
END as "UPDATED_PRICE"
from PRODUCT
order by PRODUCT_CLASS_CODE desc;

********************************************************* 2 *********************************************************

select pc.product_class_desc, p.product_id, p.product_desc,p.product_quantity_avail,
CASE
	WHEN pc.PRODUCT_CLASS_DESC in('Electronics','Computer') THEN
		CASE
			WHEN p.PRODUCT_QUANTITY_AVAIL = 0 THEN "Out of Stock"
			WHEN p.PRODUCT_QUANTITY_AVAIL <=10 THEN "Low Stock"
			WHEN p.PRODUCT_QUANTITY_AVAIL >=11 and p.PRODUCT_QUANTITY_AVAIL <=30 THEN "In Stock"
			WHEN p.PRODUCT_QUANTITY_AVAIL >=31 THEN "Enough Stock"
		END
	WHEN pc.PRODUCT_CLASS_DESC in ('Stationery','Clothes') THEN
		CASE
			WHEN p.PRODUCT_QUANTITY_AVAIL = 0 THEN "Out of Stock"
			WHEN p.PRODUCT_QUANTITY_AVAIL <=20 THEN "Low Stock"
			WHEN p.PRODUCT_QUANTITY_AVAIL >=21 and p.PRODUCT_QUANTITY_AVAIL <=80 THEN "In Stock"
			WHEN p.PRODUCT_QUANTITY_AVAIL >=81 THEN "Enough Stock"
		END
	WHEN pc.PRODUCT_CLASS_DESC not in ('Electronics','Computer','Stationery','Clothes') THEN
		CASE
			WHEN p.PRODUCT_QUANTITY_AVAIL = 0 THEN "Out of Stock"
			WHEN p.PRODUCT_QUANTITY_AVAIL <=15 THEN "Low Stock"
			WHEN p.PRODUCT_QUANTITY_AVAIL >=16 and p.PRODUCT_QUANTITY_AVAIL <=50 THEN "In Stock"
			WHEN p.PRODUCT_QUANTITY_AVAIL >=51 THEN "Enough Stock"
		END
END as "INVENTORY_STATUS"
from PRODUCT p
INNER JOIN PRODUCT_CLASS pc
on p.PRODUCT_CLASS_CODE = pc.PRODUCT_CLASS_CODE;

********************************************************* 3 *********************************************************

SELECT COUNTRY,count(CITY) as COUNT_OF_CITIES from ADDRESS
where COUNTRY not in ('USA','Malaysia')
group by COUNTRY
HAVING count(CITY) > 1
order by count(CITY) desc;

********************************************************* 4 *********************************************************


SELECT ORDER_HEADER.CUSTOMER_ID , ONLINE_CUSTOMER.CUSTOMER_FNAME || " " || ONLINE_CUSTOMER.CUSTOMER_LNAME as CUSTOMER_NAME,
ADDRESS.CITY as "City", ADDRESS.PINCODE ,
--ORDER_HEADER.ORDER_ID || ", " || ORDER_HEADER.ORDER_DATE || ", " || PRODUCT_CLASS.PRODUCT_CLASS_DESC || ", " || PRODUCT.PRODUCT_DESC as "Order Details",
ORDER_HEADER.ORDER_ID ,ORDER_HEADER.ORDER_DATE ,PRODUCT_CLASS.PRODUCT_CLASS_DESC,PRODUCT.PRODUCT_DESC,
ORDER_ITEMS.PRODUCT_QUANTITY*PRODUCT.PRODUCT_PRICE as SUBTOTAL
from ONLINE_CUSTOMER
INNER JOIN ADDRESS
on ONLINE_CUSTOMER.ADDRESS_ID = ADDRESS.ADDRESS_ID
INNER JOIN ORDER_HEADER
on ONLINE_CUSTOMER.CUSTOMER_ID = ORDER_HEADER.CUSTOMER_ID
INNER JOIN ORDER_ITEMS
on ORDER_HEADER.ORDER_ID = ORDER_ITEMS.ORDER_ID
INNER JOIN PRODUCT
on ORDER_ITEMS.PRODUCT_ID = PRODUCT.PRODUCT_ID
INNER JOIN PRODUCT_CLASS
on PRODUCT.PRODUCT_CLASS_CODE = PRODUCT_CLASS.PRODUCT_CLASS_CODE
WHERE ADDRESS.PINCODE not like "%0%" and 
ORDER_HEADER.ORDER_STATUS='Shipped'
ORDER BY CUSTOMER_NAME, ORDER_HEADER.ORDER_DATE, SUBTOTAL;



********************************************************* 5 *********************************************************

SELECT PRODUCT.PRODUCT_ID,PRODUCT.PRODUCT_DESC,sum(ORDER_ITEMS.PRODUCT_QUANTITY) as QUANTITY
from PRODUCT 
INNER JOIN ORDER_ITEMS 
on PRODUCT.PRODUCT_ID = ORDER_ITEMS.PRODUCT_ID
where PRODUCT.PRODUCT_ID in (
	SELECT ORDER_ITEMS.PRODUCT_ID from ORDER_ITEMS  where ORDER_ITEMS.ORDER_ID in (
		select ORDER_ITEMS.ORDER_ID from ORDER_ITEMS where ORDER_ITEMS.PRODUCT_ID=201)
	group by ORDER_ITEMS.PRODUCT_ID order by sum(PRODUCT_QUANTITY) desc limit 1)
and ORDER_ITEMS.ORDER_ID in (
	select ORDER_ITEMS.ORDER_ID from ORDER_ITEMS where ORDER_ITEMS.PRODUCT_ID=201);

********************************************************* 6 *********************************************************

select ONLINE_CUSTOMER.CUSTOMER_ID ,ONLINE_CUSTOMER.CUSTOMER_FNAME || ' ' ||  ONLINE_CUSTOMER.CUSTOMER_LNAME as CUSTOMER_FULL_NAME, ONLINE_CUSTOMER.CUSTOMER_EMAIL,
--ORDER_HEADER.ORDER_ID || ", " || PRODUCT.PRODUCT_DESC || ", " || ORDER_ITEMS.PRODUCT_QUANTITY as "Order Details",  ORDER_ITEMS.PRODUCT_QUANTITY*PRODUCT.PRODUCT_PRICE as "Substotal"
ORDER_HEADER.ORDER_ID , PRODUCT.PRODUCT_DESC ,ORDER_ITEMS.PRODUCT_QUANTITY ,ORDER_ITEMS.PRODUCT_QUANTITY * PRODUCT.PRODUCT_PRICE as SUBTOTAL
from ONLINE_CUSTOMER
LEFT JOIN ORDER_HEADER
on ONLINE_CUSTOMER.CUSTOMER_ID = ORDER_HEADER.CUSTOMER_ID
LEFT JOIN ORDER_ITEMS
on ORDER_HEADER.ORDER_ID = ORDER_ITEMS.ORDER_ID
LEFT JOIN PRODUCT
on PRODUCT.PRODUCT_ID = ORDER_ITEMS.PRODUCT_ID;

********************************************************* 7 *********************************************************

select carton_id, len*width*height as "vol" from carton order by "vol" desc;

select carton_id, len*width*height as CARTON_VOL from carton
having CARTON_VOL > (
select sum(order_items.product_quantity*product.len*product.width*product.height) as "Total volume" from order_items
inner join product
on order_items.product_id = product.product_id
where order_items.order_id = 10006)
order by CARTON_VOL ASC limit 1;

********************************************************* 8 *********************************************************

select oc.CUSTOMER_ID,concat(oc.customer_fname," ",oc.customer_lname) as CUSTOMER_FULL_NAME, oh.ORDER_ID, sum(oi.product_quantity) as TOTAL_QUANTITY from online_customer oc
inner join order_header oh
on oc.customer_id = oh.customer_id
inner join order_items oi
on oi.order_id = oh.order_id
where oh.order_id in (
select order_id from order_items group by order_id having sum(product_quantity)  > 10)
and oh.order_status = 'Shipped'
group by oc.customer_id, CUSTOMER_FULL_NAME, oh.order_id
order by CUSTOMER_ID ASC;

********************************************************* 9 *********************************************************

select oh.ORDER_ID,oc.CUSTOMER_ID,concat(oc.customer_fname," ",oc.customer_lname) as CUSTOMER_FULL_NAME,  sum(oi.product_quantity) as TOTAL_QUANTITY from online_customer oc
inner join order_header oh
on oc.customer_id = oh.customer_id
inner join order_items oi
on oi.order_id = oh.order_id
where oh.order_id in (
select order_id from order_items where order_id > 10060)
and oh.order_status = 'Shipped'
group by oc.customer_id, CUSTOMER_FULL_NAME, oh.order_id
order by CUSTOMER_ID ASC;


********************************************************* 10 *********************************************************

select pc.PRODUCT_CLASS_DESC,sum(oi.product_quantity) as TOTAL_QUANTITY ,oi.product_quantity*prd.product_price as TOTAL_VALUE from
online_customer oc
inner join address addr
on oc.address_id = addr.address_id
inner join order_header oh
on oc.customer_id = oh.customer_id
inner join order_items oi
on oh.order_id = oi.order_id
inner join product prd
on oi.product_id = prd.product_id
inner join product_class pc
on prd.product_class_code = pc.product_class_code
where oh.order_status = 'Shipped' and
addr.country not in ('India','USA')
group by pc.product_class_desc
order by TOTAL_QUANTITY desc limit 1;




********************************************************* end *********************************************************
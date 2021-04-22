use orders;
####################################################### QUESTION 7 #######################################################
#Write a query to display carton id, (len*width*height) as carton_vol and identify the optimum carton (carton with the least volume whose volume is greater than the total volume of 
#all items (len * width * height * product_quantity)) for a given order whose order id is 10006, Assume all items of an order are packed into one single carton (box). (1 ROW) [NOTE: CARTON TABLE]

select CARTON_ID, len*width*height as CARTON_VOL from carton
having CARTON_VOL > (
select sum(order_items.product_quantity*product.len*product.width*product.height) as "Total volume" from order_items
inner join product
on order_items.product_id = product.product_id
where order_items.order_id = 10006)
order by CARTON_VOL ASC limit 1;

####################################################### QUESTION 8 #######################################################
#Write a query to display details (customer id,customer fullname,order id,product quantity) of customers who bought more than ten (i.e. total order qty) products per shipped order. (11 ROWS) 
#[NOTE: TABLES TO BE USED - online_customer, order_header, order_items,]

select oc.CUSTOMER_ID,concat(oc.customer_fname," ",oc.customer_lname) as CUSTOMER_FULL_NAME, oh.ORDER_ID, sum(oi.product_quantity) as TOTAL_QUANTITY from online_customer oc
inner join order_header oh
on oc.customer_id = oh.customer_id
inner join order_items oi
on oi.order_id = oh.order_id
where oh.order_id in (
select order_id from order_items group by order_id having sum(product_quantity)  > 10)
and oh.order_status = 'Shipped'
group by oc.customer_id, CUSTOMER_FULL_NAME, oh.order_id
order by TOTAL_QUANTITY DESC;

####################################################### QUESTION 9 #######################################################
#Write a query to display the order_id, customer id and cutomer full name of customers along with (product_quantity) as total quantity of products shipped for order ids > 10060. (6 ROWS)
#[NOTE: TABLES TO BE USED - online_customer, order_header, order_items]

select oh.ORDER_ID,oc.CUSTOMER_ID,concat(oc.customer_fname," ",oc.customer_lname) as CUSTOMER_FULL_NAME,  sum(oi.product_quantity) as TOTAL_QUANTITY from online_customer oc
inner join order_header oh
on oc.customer_id = oh.customer_id
inner join order_items oi
on oi.order_id = oh.order_id
where oh.order_id in (
select order_id from order_items where order_id > 10060)
and oh.order_status = 'Shipped'
group by oc.customer_id, CUSTOMER_FULL_NAME, oh.order_id
order by TOTAL_QUANTITY DESC;


####################################################### QUESTION 10 #######################################################
#Write a query to display product class description ,total quantity (sum(product_quantity),Total value (product_quantity * product price) and show which class of products have
# been shipped highest(Quantity) to countries outside India other than USA? Also show the total value of those items. (1 ROWS)
#[NOTE:PRODUCT TABLE,ADDRESS TABLE,ONLINE_CUSTOMER TABLE,ORDER_HEADER TABLE,ORDER_ITEMS TABLE,PRODUCT_CLASS TABLE]

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
where oh.order_status = 'Shipped'
and addr.country not in ('India','USA')
group by pc.product_class_desc
order by TOTAL_QUANTITY desc limit 1;

####################################################### END OF PROJECT FILE #######################################################
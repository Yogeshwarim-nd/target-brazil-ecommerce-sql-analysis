
-------customer table -------------------------
CREATE TABLE customer (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix NUMERIC(7,2),
    customer_city VARCHAR(100),
    customer_state VARCHAR(10)
);


------------------sellers table---------------------------

CREATE TABLE sellers (
    seller_id VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix NUMERIC(7,2),
    seller_city VARCHAR(100),
    seller_state VARCHAR(10)
);

----------------order_items-----------------------------
CREATE TABLE order_items (
    order_id VARCHAR(50),
    order_item_id INTEGER,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date TIMESTAMP,
    price FLOAT,
    freight_value FLOAT,
    PRIMARY KEY (order_id, order_item_id)
);


---------------------payments-----------------------
CREATE TABLE payments (
    order_id VARCHAR(50),
    payment_sequential INTEGER,
    payment_type VARCHAR(30),
    payment_installments INTEGER,
    payment_value FLOAT,
    PRIMARY KEY (order_id, payment_sequential)
);


-------------------------geolocation---------------

CREATE TABLE geolocation (
    geolocation_zip_code_prefix INTEGER,
    geolocation_lat FLOAT,
    geolocation_lng FLOAT,
    geolocation_city VARCHAR(100),
    geolocation_state VARCHAR(10)
);

------------------------products---------------

CREATE TABLE products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category VARCHAR(100),
    product_name_length INTEGER,
    product_description_length INTEGER,
    product_photos_qty INTEGER,
    product_weight_g INTEGER,
    product_length_cm INTEGER,
    product_height_cm INTEGER,
    product_width_cm INTEGER
);

------------orders-----------------

CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(30),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);

-- 1.Import the dataset and do usual exploratory analysis steps like checking the 
-- structure & characteristics of the dataset:


-- 1.Data type of all columns in the "customers" table. 

select column_name,data_type from INFORMATION_SCHEMA.COLUMNS where table_name='customer'


---2. Get the time range between which the orders were placed. 

select min(order_purchase_timestamp) as 
order_placement_started_time,max(order_purchase_timestamp) as 
order_placement_stopped_time 
from orders

---3. Count the Cities & States of customers who ordered during the given period.

SELECT 
    gl.geolocation_city AS city,
    gl.geolocation_state AS state,
    COUNT(*) AS count_of_locations
FROM customer c
JOIN orders o 
    ON c.customer_id = o.customer_id
JOIN geolocation gl 
    ON c.customer_zip_code_prefix = gl.geolocation_zip_code_prefix
GROUP BY 
    gl.geolocation_city,
    gl.geolocation_state
ORDER BY 
    count_of_locations DESC;


-- 2.In-depth Exploration: 

-- 1.Is there a growing trend in the no. of orders placed over the past years? 

select extract(year from order_purchase_timestamp) as year, 
count(order_id) as number_of_orders 
from orders group by year 
order by year 

-- 2. Can we see some kind of monthly seasonality in terms of the no. of orders being 
-- placed? 

SELECT 
    EXTRACT(MONTH FROM order_purchase_timestamp) AS month_no,
    TO_CHAR(order_purchase_timestamp, 'Month') AS month_name,
    EXTRACT(YEAR FROM order_purchase_timestamp) AS year,
    COUNT(*) AS number_of_orders
FROM orders
GROUP BY DATE_TRUNC('month', order_purchase_timestamp),
         year,
         month_no,
         month_name
ORDER BY year, month_no;



-- 3.order volumes in that month. 
-- During what time of the day, do the Brazilian customers mostly place their orders? 
-- (Dawn, Morning, Afternoon or Night) 
-- o 0-6 hrs : Dawn 
-- o 7-12 hrs : Mornings 
-- o 13-18 hrs : Afternoon 
-- o 19-23 hrs : Night


select count(case when extract(hour from order_purchase_timestamp) between 
0 and 6 
then order_id end) as orders_in_Dawn, 
count(case when extract(hour from order_purchase_timestamp) between 
7 and 12 
then order_id end) as orders_in_Morning, 
count(case when extract(hour from order_purchase_timestamp) between  
13 and 18 
then order_id end) as orders_in_Afternoon, 
count(case when extract(hour from order_purchase_timestamp) between 
19 and 23 
then order_id end) as orders_in_night 
from orders


-- 3. Evolution of E-commerce orders in the Brazil region: 

-- 1. Get the month on month no. of orders placed in each state. 

SELECT 
    EXTRACT(MONTH FROM o.order_purchase_timestamp) AS month_no,
    TO_CHAR(o.order_purchase_timestamp, 'FMMonth') AS month_name,
    c.customer_state AS state,
    COUNT(o.order_id) AS count_of_orders
FROM orders o
JOIN customer c 
    ON o.customer_id = c.customer_id
JOIN geolocation gl 
    ON c.customer_zip_code_prefix = gl.geolocation_zip_code_prefix
GROUP BY 
    EXTRACT(MONTH FROM o.order_purchase_timestamp),
    TO_CHAR(o.order_purchase_timestamp, 'FMMonth'),
    c.customer_state
ORDER BY 
    state,
    month_no;
	
-- 2. How are the customers distributed across all the states? 

select customer_state,count(customer_id) as number_of_customers 
from customer
group by customer_state 
order by number_of_customers desc 


-- 4. Impact on Economy: Analyze the money movement by e-commerce by looking at 
-- order prices, freight and others. 

-- 1. Get the % increase in the cost of orders from year 2017 to 2018 (include months 
-- between Jan to Aug only). 
-- You can use the "payment_value" column in the payments table to get the cost of 
-- orders.

WITH year_wise_payment AS (
    SELECT 
        EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
        ROUND(SUM(p.payment_value)::numeric, 2) AS total_payment
    FROM orders o
    JOIN payments p
        ON o.order_id = p.order_id
    WHERE EXTRACT(YEAR FROM o.order_purchase_timestamp) IN (2017, 2018)
      AND EXTRACT(MONTH FROM o.order_purchase_timestamp) BETWEEN 1 AND 8
    GROUP BY EXTRACT(YEAR FROM o.order_purchase_timestamp)
)

SELECT 
    MAX(CASE WHEN year = 2017 THEN total_payment END) AS payment_2017,
    MAX(CASE WHEN year = 2018 THEN total_payment END) AS payment_2018,
    ROUND(
        (
            MAX(CASE WHEN year = 2018 THEN total_payment END) -
            MAX(CASE WHEN year = 2017 THEN total_payment END)
        )
        /
        MAX(CASE WHEN year = 2017 THEN total_payment END) * 100
    , 2) AS percent_increase
FROM year_wise_payment;


-- 2. Calculate the Total & Average value of order price for each state. 
select c.customer_state,round(sum(oi.price)::numeric,2) as total_price,round(avg(oi.price)::numeric,2) as 
average_price 
from geolocation gl join customer c 
on gl.geolocation_zip_code_prefix=c.customer_zip_code_prefix 
join orders o 
on c.customer_id = o.customer_id 
join order_items oi 
on o.order_id=oi.order_id 
group by c.customer_state 
order by total_price desc 



-- 3. Calculate the Total & Average value of order freight for each state.

select c.customer_state,round(sum(oi.freight_value::numeric),2) as 
total_freight_value,round(avg(oi.freight_value::numeric),2) as average_freight_value 
from geolocation gl join customer c 
on gl.geolocation_zip_code_prefix=c.customer_zip_code_prefix 
join orders o 
on c.customer_id = o.customer_id 
join order_items oi 
on o.order_id=oi.order_id 
group by c.customer_state 



-- 5. Analysis based on sales, freight and delivery time.

-- 1. Find the no. of days taken to deliver each order from the order’s purchase date as 
-- delivery time. 
-- Also, calculate the difference (in days) between the estimated & actual delivery date of 
-- an order. 
-- Do this in a single query. 
-- You can calculate the delivery time and the difference between the estimated & actual 
-- delivery date using the given formula: 
--   o time_to_deliver = order_delivered_customer_date - order_purchase_timestamp 
--   o diff_estimated_delivery = order_delivered_customer_date - 
-- order_estimated_delivery_date 

SELECT 
    p.product_category,
    o.order_id,
    (o.order_delivered_customer_date - o.order_purchase_timestamp) 
        AS no_of_days_to_deliver,
    (o.order_delivered_customer_date - o.order_estimated_delivery_date) 
        AS no_of_days_diff_estimated_delivery
FROM orders o
JOIN order_items oi 
    ON o.order_id = oi.order_id
JOIN products p 
    ON oi.product_id = p.product_id
WHERE o.order_status = 'delivered'
ORDER BY no_of_days_to_deliver DESC;


-- 2. Find out the top 5 states with the highest & lowest average freight value. 

with avg_freight_tab as 
( 
select c.customer_state,round(avg(oi.freight_value)::numeric,2) as avg_freight_value 
from customer c join orders o 
on c.customer_id=o.customer_id 
join order_items oi 
on oi.order_id=o.order_id  
group by c.customer_state 
order by avg_freight_value 
) 
(select *,'top_5_highest_freight_value' as category from avg_freight_tab order by 
avg_freight_value desc limit 5) 
union all 
(select *,'top_5_lowest_freight_value' as category from avg_freight_tab order by 
avg_freight_value asc limit 5)


-- 3. Find out the top 5 states with the highest & lowest average delivery time.

WITH delivery_duration AS (
    SELECT 
        c.customer_state,
        ROUND(
            AVG(
                EXTRACT(EPOCH FROM (o.order_delivered_customer_date - o.order_purchase_timestamp)) / 3600
            )::numeric
        ,2) AS avg_delivery_time_in_hours
    FROM customer c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_state
)

(
SELECT 
    *,
    'top_5_highest_delivery_duration' AS category
FROM delivery_duration
ORDER BY avg_delivery_time_in_hours DESC
LIMIT 5
)

UNION ALL

(
SELECT 
    *,
    'top_5_lowest_delivery_duration' AS category
FROM delivery_duration
ORDER BY avg_delivery_time_in_hours ASC
LIMIT 5
);

-- 4. Find out the top 5 states where the order delivery is really fast as compared to the 
-- estimated date of delivery. 
-- You can use the difference between the averages of actual & estimated delivery date to 
-- figure out how fast the delivery was for each state. 

SELECT 
    c.customer_state,
    ROUND(
        AVG(
            EXTRACT(EPOCH FROM (o.order_delivered_customer_date - o.order_estimated_delivery_date)) / 86400
        )::numeric
    ,0) AS avg_diff_days
FROM orders o
JOIN customer c
    ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY avg_diff_days ASC
LIMIT 5;

-- 6. Analysis based on the payments 
-- 1. Find the month on month no. of orders placed using different payment types.

select extract(month from  order_purchase_timestamp) as month,round(sum(case 
when payment_type='credit_card' then payment_value end)::numeric,2) as 
total_credit_card_payment, 
round(sum(case when payment_type='UPI' then payment_value end)::numeric,2) as 
total_UPI_payment, 
round(sum(case when payment_type='voucher' then payment_value end)::numeric,2) as 
total_voucher_payment, 
round(sum(case when payment_type='debit_card' then payment_value end)::numeric,2) as 
total_debit_card_payment, 
round(sum(case when payment_type='not_defined' then payment_value end)::numeric,2) as 
total_payment_not_defined 
from orders o join payments p 
on o.order_id=p.order_id 
group by month order by month 

-- 2. Find the no. of orders placed on the basis of the payment installments that have been 
-- paid. 

select p.payment_installments,count(o.order_id) as number_of_orders 
from orders o join payments p 
on o.order_id=p.order_id 
group by p.payment_installments 
order by p.payment_installments 







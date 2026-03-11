# Target Brazil E-Commerce SQL Analysis

## Project Overview
This project analyzes the **Target Brazil E-Commerce dataset** containing approximately **100,000 orders between 2016 and 2018**.

Target is a globally recognized retail brand known for providing value, innovation, and exceptional customer experiences. This dataset provides insights into Target's **e-commerce operations in Brazil**, including customer demographics, order details, delivery performance, product attributes, and customer reviews.

The goal of this project is to perform **exploratory data analysis using SQL** to understand customer behavior, operational efficiency, payment patterns, and delivery performance.

---

## Business Objective
As a **Data Analyst at Target**, the objective is to extract actionable insights from the dataset to help improve:

- Customer experience
- Delivery efficiency
- Payment and pricing strategies
- Operational performance across Brazilian states

The analysis focuses on identifying patterns in **orders, payments, delivery time, freight cost, and customer distribution**.

---

## Dataset

Dataset Source:  
https://drive.google.com/drive/folders/1TGEc66YKbD443nslRi1bWgVd238gJCnb

The dataset consists of **8 CSV files**:

| File | Description |
|------|-------------|
| customers.csv | Customer information and location |
| sellers.csv | Seller information |
| orders.csv | Order details and timestamps |
| order_items.csv | Product items in each order |
| products.csv | Product attributes |
| payments.csv | Payment information |
| geolocation.csv | Location coordinates for zip codes |

Total records analyzed: **~100,000 orders**

---

## Database Schema

The dataset consists of multiple relational tables that can be linked using common identifiers.  
Although explicit foreign key constraints were not created in the database, the tables are logically related through shared columns and were connected during analysis using SQL joins.

Key relationships used in the analysis include:

- `customers.customer_id` → `orders.customer_id`
- `orders.order_id` → `order_items.order_id`
- `orders.order_id` → `payments.order_id`
- `orders.order_id` → `reviews.order_id`
- `products.product_id` → `order_items.product_id`
- `sellers.seller_id` → `order_items.seller_id`

These relationships enable integrated analysis across **customers, orders, products, sellers, payments, and delivery performance**.

---

## Tools & Technologies

- **PostgreSQL**
- **SQL (Joins, Aggregations, Window Functions, Date Functions)**
- **Git & GitHub**
- **Jupyter Notebook**

---

## Data Exploration

Initial exploratory analysis included:

- Checking **data types and structure of tables**
- Identifying **time range of orders**
- Counting **number of unique cities and states**
- Understanding **data distribution across tables**

---

## Key Business Questions

### 1. Order Trends

- Is there a **growth trend in orders over the years**?
- Is there **monthly seasonality in order volume**?
- What **time of day** do customers place most orders?

Time categories used in the analysis:

| Time Period | Hours |
|-------------|------|
| Dawn | 0 – 6 |
| Morning | 7 – 12 |
| Afternoon | 13 – 18 |
| Night | 19 – 23 |

---

### 2. Regional E-Commerce Growth

- Month-on-month number of orders placed in each **state**
- Distribution of **customers across states**

---

### 3. Economic Impact

Analysis of **money movement in e-commerce** including:

- Order price
- Freight value
- Payment value

Key analysis performed:

- Percentage increase in **cost of orders from 2017 to 2018 (Jan–Aug)**
- **Total and average order price per state**
- **Total and average freight value per state**

---

### 4. Delivery Performance

Delivery efficiency analysis included:

**Delivery time calculation**

time_to_deliver = order_delivered_customer_date - order_purchase_timestamp

**Estimated vs actual delivery difference**

diff_estimated_delivery = order_delivered_customer_date - order_estimated_delivery_date


Key insights analyzed:

- Top 5 states with **highest and lowest average freight**
- Top 5 states with **highest and lowest average delivery time**
- States where delivery was **faster than estimated**

---

### 5. Payment Behavior

Analysis of payment patterns included:

- Month-on-month orders by **payment type**
- Orders based on **number of payment installments**

Common payment types:

- Credit Card
- Debit Card
- Voucher
- Boleto

---

## Project Structure

target-brazil-ecommerce-sql-analysis
│
├── dataset/
│ └── csv files
│
├── sql/
│ └── Target_data_analysis.sql
│
├── Insights_and_recommendation/
│ └── target.pdf
│
└── README.md


---

## Skills Demonstrated

- SQL Data Analysis
- Complex Joins
- Aggregations
- Date & Time Analysis
- Business Problem Solving
- Data Exploration
- Analytical Thinking

---

## Conclusion

This project provides insights into **Target's e-commerce operations in Brazil**. By analyzing order patterns, delivery performance, and payment behavior, businesses can optimize:

- Logistics and delivery timelines
- Pricing and freight strategies
- Customer experience

The analysis demonstrates how **SQL-based data analysis can support business decision-making in large-scale e-commerce operations**.




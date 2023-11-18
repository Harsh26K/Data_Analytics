SELECT * FROM dim_customers;

SELECT * FROM dim_products;

SELECT * FROM fact_gross_price;

SELECT * FROM fact_manufacturing_cost;

SELECT * FROM fact_pre_invoice_deductions;

SELECT * FROM fact_sales_monthly;


--1. Provide the list of markets in which customer "Atliq Exclusive" operates its
--business in the APAC region.

SELECT market
FROM dim_customers
WHERE customer = 'Atliq Exclusive' AND region = 'APAC' ;


--2. What is the percentage of unique product increase in 2021 vs. 2020? The
--final output contains these fields,
--unique_products_2020
--unique_products_2021
--percentage_chg

WITH products_20 AS
(SELECT fiscal_year ,COUNT(DISTINCT(product_code)) AS unique_products_2020
FROM fact_sales_monthly
WHERE fiscal_year = 2020
GROUP BY fiscal_year),

products_21 AS 
(SELECT fiscal_year ,COUNT(DISTINCT(product_code)) AS unique_products_2021
FROM fact_sales_monthly
WHERE fiscal_year = 2021
GROUP BY fiscal_year)

SELECT p0.unique_products_2020, 
p1.unique_products_2021,
ROUND(100*(p1.unique_products_2021-p0.unique_products_2020)/p0.unique_products_2020,2) AS percentage_chg
FROM products_20 p0
CROSS JOIN
products_21 p1;
 

--3. Provide a report with all the unique product counts for each segment and
--sort them in descending order of product counts. The final output contains
--2 fields,
--segment
--product_count

SELECT segment, COUNT(DISTINCT(product_code)) AS product_count
FROM dim_products
GROUP BY segment
ORDER BY product_count DESC;


--4. Follow-up: Which segment had the most increase in unique products in
--2021 vs 2020? The final output contains these fields,
--segment
--product_count_2020
--product_count_2021
--difference

WITH products_20(segment,product_count_2020) AS
(SELECT p.segment, COUNT(DISTINCT(s.product_code)) AS product_count_2020
FROM fact_sales_monthly s
JOIN dim_products p
ON s.product_code = p.product_code
WHERE s.fiscal_year = 2020
GROUP BY p.segment),

products_21(segment,product_count_2021) AS
(SELECT p.segment, COUNT(DISTINCT(s.product_code)) AS product_count_2021
FROM fact_sales_monthly s
JOIN dim_products p
ON s.product_code = p.product_code
WHERE s.fiscal_year = 2021
GROUP BY p.segment)

SELECT p0.segment, 
p0.product_count_2020,
p1.product_count_2021,
p1.product_count_2021 - p0.product_count_2020 AS difference
FROM products_20 p0
JOIN products_21 p1
ON p0.segment = p1.segment
ORDER BY difference DESC;

--5. Get the products that have the highest and lowest manufacturing costs.
--The final output should contain these fields,
--product_code
--product
--manufacturing_cost

SELECT m.product_code , p.product ,m.manufacturing_cost
FROM fact_manufacturing_cost m
JOIN dim_products p
ON m.product_code = p.product_code
WHERE m.manufacturing_cost = (
SELECT MIN(manufacturing_cost)
FROM fact_manufacturing_cost) 
or 
m.manufacturing_cost = (SELECT MAX(manufacturing_cost)
FROM fact_manufacturing_cost);


--6. Generate a report which contains the top 5 customers who received an
--average high pre_invoice_discount_pct for the fiscal year 2021 and in the
--Indian market. The final output contains these fields,
--customer_code
--customer
--average_discount_percentage

SELECT TOP 5 c.customer_code, c.customer, AVG(i.pre_invoice_discount_pct) AS average_discount_percentage
FROM dim_customers c
JOIN fact_pre_invoice_deductions i
ON c.customer_code = i.customer_code
WHERE c.market = 'India' AND i.fiscal_year = 2021
GROUP BY c.customer_code,c.customer
ORDER BY average_discount_percentage DESC;

--7. Get the complete report of the Gross sales amount for the customer “Atliq
--Exclusive” for each month. This analysis helps to get an idea of low and
--high-performing months and take strategic decisions.
--The final report contains these columns:
--Month
--Year
--Gross sales Amount


WITH AEdata AS
(SELECT s.customer_code,s.date,s.product_code,s.fiscal_year,g.gross_price,s.sold_quantity,i.pre_invoice_discount_pct
FROM fact_gross_price g
JOIN fact_sales_monthly s
ON g.product_code = s.product_code
JOIN fact_pre_invoice_deductions i
ON s.customer_code = i.customer_code
WHERE s.customer_code = 70002017)
SELECT
MONTH(date) AS month,
YEAR(date) AS year,
ROUND(SUM(gross_price*(1-pre_invoice_discount_pct)*sold_quantity)/1000000,2) AS gross_sales_amount_mln
FROM AEdata
GROUP BY date
ORDER BY date;


--8. In which quarter of 2020, got the maximum total_sold_quantity? The final
--output contains these fields sorted by the total_sold_quantity,
--Quarter
--total_sold_quantity

WITH QData AS
( SELECT 
CASE
	WHEN MONTH(date) IN (9,10,11) THEN 'Q1' 
	WHEN MONTH(date) IN (12,1,2) THEN 'Q2'
	WHEN MONTH(date) IN (3,4,5) THEN 'Q3'
	WHEN MONTH(date) IN (6,7,8) THEN 'Q4'
END AS Quarter,
sold_quantity
FROM fact_sales_monthly
WHERE fiscal_year = 2020)
SELECT 
Quarter,
SUM(sold_quantity) AS total_sold_quantity
FROM QDAta
GROUP BY Quarter
ORDER BY total_sold_quantity;


--9. Which channel helped to bring more gross sales in the fiscal year 2021
--and the percentage of contribution? The final output contains these fields,
--channel
--gross_sales_mln
--percentage

WITH channelData AS
(SELECT 
c.channel,
ROUND(SUM(g.gross_price*(1-i.pre_invoice_discount_pct)*s.sold_quantity)/1000000,2) AS gross_sales_mln
FROM dim_customers c
JOIN fact_sales_monthly s
ON s.customer_code = c.customer_code
JOIN fact_gross_price g
ON s.product_code = g.product_code
JOIN fact_pre_invoice_deductions i
ON s.customer_code = i.customer_code
WHERE s.fiscal_year = 2021
GROUP BY c.channel
)
SELECT 
channel,
gross_sales_mln,
ROUND(gross_sales_mln*100/total,2) AS percentage
FROM
(SELECT SUM(gross_sales_mln) AS total FROM channelData)A,
(SELECT * FROM channelData)B
ORDER BY percentage DESC;


----10. Get the Top 3 products in each division that have a high
----total_sold_quantity in the fiscal_year 2021? The final output contains these
----fields,
----division
----product_code

WITH prodQntData AS
(SELECT
p.division,
p.product_code,
SUM(s.sold_quantity) AS total_sold_quantity
FROM dim_products p
JOIN fact_sales_monthly s
ON p.product_code = s.product_code
WHERE s.fiscal_year = 2021
GROUP BY p.division, p.product_code),
rankedData AS
(SELECT
*,
DENSE_RANK() OVER(PARTITION BY division ORDER BY total_sold_quantity DESC) AS prank
FROM prodQntData)
SELECT division,product_code,total_sold_quantity 
FROM rankedData
WHERE prank <=3;
use bikestores;

-- Tables

SELECT * FROM production.brands;

SELECT * FROM production.categories;

SELECT * FROM production.products;

SELECT * FROM production.stocks;

SELECT * FROM sales.customers;

SELECT * FROM sales.order_items;

SELECT * FROM sales.orders;

SELECT * FROM sales.staffs;

SELECT * FROM sales.stores;

-- Overall sales 
SELECT SUM((ite.list_price*ite.quantity)*(1-ite.discount)) AS OverallRevenue
FROM sales.order_items ite;

-- Total Customers
SELECT COUNT(customer_id) AS TotalCustomers
FROM sales.customers;

-- Total Stores
SELECT COUNT(store_id) AS TotalStores
FROM sales.stores;

-- Total Products Sold
SELECT SUM(quantity) AS ProductsSold
FROM sales.order_items;

-- total sales per year
SELECT YEAR(ord.order_date) as year, SUM(ite.quantity) AS Units_sold, 
SUM((ite.quantity*ite.list_price)*(1 - ite.discount)) AS Revenue
FROM sales.orders ord 
JOIN sales.order_items ite
ON ord.order_id = ite.order_id
GROUP BY YEAR(ord.order_date);

-- total sales per month
SELECT MONTH(ord.order_date) AS Month, SUM(ite.quantity) AS Units_Sold, 
SUM((ite.list_price*ite.quantity)*(1- ite.discount)) AS Revenue
FROM sales.orders ord 
JOIN sales.order_items ite
ON ord.order_id = ite.order_id
GROUP BY MONTH(ord.order_date)
ORDER BY MONTH(ord.order_date);

-- total sales per region
SELECT cust.state, SUM((ite.list_price*ite.quantity)*(1- ite.discount)) AS Revenue
FROM sales.customers cust
JOIN sales.orders ord
ON cust.customer_id = ord.customer_id
JOIN sales.order_items ite
ON ite.order_id = ord.order_id
GROUP BY cust.state;

-- total sales per brand
SELECT bra.brand_name AS brand, SUM((ite.list_price*ite.quantity)*(1-ite.discount)) AS Revenue
FROM production.brands bra
JOIN production.products prod
ON bra.brand_id = prod.brand_id
JOIN sales.order_items ite
ON ite.product_id = prod.product_id
GROUP BY bra.brand_name
ORDER BY Revenue DESC;

-- total sales per category
SELECT cat.category_name AS Category, SUM((ite.list_price*ite.quantity)*(1-ite.discount)) AS Revenue
FROM production.categories cat
JOIN production.products prod
ON cat.category_id = prod.category_id
JOIN sales.order_items ite
on prod.product_id = ite.product_id
GROUP BY cat.category_name
ORDER BY Revenue DESC;

-- Top 10 cutomers
SELECT TOP 10 CONCAT_WS(' ',cust.first_name,cust.last_name) AS customer,
cust.city,
SUM((ite.list_price*ite.quantity)*(1-ite.discount)) AS TotalPurchase
FROM sales.customers cust
JOIN sales.orders ord
ON cust.customer_id = ord.customer_id
JOIN sales.order_items ite
ON ord.order_id = ite.order_id
GROUP BY CONCAT_WS(' ',cust.first_name,cust.last_name),cust.city
ORDER BY TotalPurchase DESC;

-- TOP 10 Sales Rep
SELECT TOP 10 CONCAT(sta.first_name,' ',sta.last_name) AS SalesRep,
SUM((ite.list_price*ite.quantity)*(1-ite.discount)) AS TotalProfit
FROM sales.staffs sta
JOIN sales.orders ord
ON sta.staff_id = ord.staff_id
JOIN sales.order_items ite
ON ord.order_id = ite.order_id
GROUP BY CONCAT(sta.first_name,' ',sta.last_name)
ORDER BY TotalProfit DESC;

-- Top 3 brands each year by revenue
WITH CTE
AS
(
	SELECT YEAR(ord.order_date) AS year,
	bra.brand_name as brand,
	SUM((ite.list_price*ite.quantity)*(1-ite.discount)) AS Revenue,
	ROW_NUMBER() OVER (
	PARTITION BY YEAR(ord.order_date) 
	ORDER BY SUM((ite.list_price*ite.quantity)*(1-ite.discount)) DESC) AS Sno#
	FROM sales.orders ord
	JOIN sales.order_items ite
	ON ord.order_id = ite.order_id
	JOIN production.products prod
	ON prod.product_id = ite.product_id
	JOIN production.brands bra
	ON bra.brand_id = prod.brand_id
	GROUP BY YEAR(ord.order_date),bra.brand_name
)
SELECT * FROM CTE WHERE Sno# <=3;

-- Top 3 categories each year per sales
WITH CTE
AS
(
	SELECT YEAR(ord.order_date) AS year,
	cat.category_name AS category,
	SUM((ite.list_price*ite.quantity)*(1-ite.discount)) AS Revenue,
	ROW_NUMBER() OVER (
	PARTITION BY YEAR(ord.order_date)
	ORDER BY SUM((ite.list_price*ite.quantity)*(1-ite.discount)) DESC
	) AS RNK
	FROM sales.orders ord
	JOIN sales.order_items ite
	ON ord.order_id = ite.order_id
	JOIN production.products prod
	ON ite.product_id = prod.product_id
	JOIN production.categories cat
	ON cat.category_id = prod.category_id
	GROUP BY YEAR(ord.order_date), cat.category_name
)
SELECT * FROM CTE WHERE RNK <=3;

-- Favorite product each year
WITH CTE
AS
(
	SELECT YEAR(ord.order_date) AS year,
	prod.product_name AS product,
	SUM(ite.quantity) AS QuantitySold,
	ROW_NUMBER() OVER (
	PARTITION BY YEAR(ord.order_Date)
	ORDER BY SUM(ite.quantity) DESC) AS RNK
	FROM sales.orders ord
	JOIN sales.order_items ite
	ON ord.order_id = ite.order_id
	JOIN production.products prod
	ON ite.product_id = prod.product_id
	GROUP BY YEAR(ord.order_date),prod.product_name
)
SELECT * FROM CTE WHERE RNK=1;

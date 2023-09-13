use bikeStores;

-- Gathering Required Data from all the tables
-- and creating a new table bikeSales

SELECT
	ord.order_id,
	CONCAT(cus.first_name,' ',cus.last_name) AS customer_name,
	cus.city,
	cus.state,
	ord.order_date,
	SUM(ite.quantity) AS total_units,
	SUM(ite.quantity * ite.list_price) AS revenue,
	prod.product_name,
	bra.brand_name,
	cat.category_name,
	sto.store_name,
	CONCAT(sta.first_name,' ',sta.last_name) AS sales_rep
INTO bikeSales
FROM sales.orders ord
JOIN sales.customers cus
ON ord.customer_id = cus.customer_id
JOIN sales.order_items ite
ON ord.order_id = ite.order_id
JOIN production.products prod
ON ite.product_id = prod.product_id
JOIN production.brands bra 
ON prod.brand_id = bra.brand_id
JOIN production.categories cat
ON prod.category_id = cat.category_id
JOIN sales.stores sto
ON ord.store_id = sto.store_id
JOIN sales.staffs sta
ON sta.staff_id = ord.staff_id
GROUP BY
	ord.order_id,
	CONCAT(cus.first_name,' ',cus.last_name),
	cus.city,
	cus.state,
	ord.order_date,
	prod.product_name,
	bra.brand_name,
	cat.category_name,
	sto.store_name,
	CONCAT(sta.first_name,' ',sta.last_name);

CREATE DATABASE AtliqHW;

USE AtliqHW;

CREATE TABLE dim_customers(
	customer_code INTEGER NOT NULL,
	customer VARCHAR(150) COLLATE Latin1_General_CI_AI NOT NULL,
	platform VARCHAR(45) COLLATE Latin1_General_CI_AI NOT NULL,
	channel VARCHAR(45) COLLATE Latin1_General_CI_AI NOT NULL,
	market VARCHAR(45) COLLATE Latin1_General_CI_AI NOT NULL,
	sub_zone VARCHAR(45) COLLATE Latin1_General_CI_AI NOT NULL,
	region VARCHAR(45) COLLATE Latin1_General_CI_AI NOT NULL,
);

CREATE TABLE dim_products (
  product_code varchar(45) COLLATE Latin1_General_CI_AI NOT NULL,
  division varchar(45) COLLATE Latin1_General_CI_AI NOT NULL,
  segment varchar(45) COLLATE Latin1_General_CI_AI NOT NULL,
  category varchar(45) COLLATE Latin1_General_CI_AI NOT NULL,
  product varchar(200) COLLATE Latin1_General_CI_AI NOT NULL,
  variant varchar(45) COLLATE Latin1_General_CI_AI DEFAULT NULL
);

CREATE TABLE fact_gross_price (
  product_code varchar(45) COLLATE Latin1_General_CI_AI NOT NULL,
  fiscal_year INTEGER NOT NULL,
  gross_price decimal(15,4) NOT NULL
);

CREATE TABLE fact_manufacturing_cost (
  product_code varchar(45) COLLATE Latin1_General_CI_AI NOT NULL,
  cost_year INTEGER NOT NULL,
  manufacturing_cost decimal(15,4) NOT NULL
);

CREATE TABLE fact_pre_invoice_deductions (
  customer_code int NOT NULL,
  fiscal_year INTEGER NOT NULL,
  pre_invoice_discount_pct decimal(5,4) NOT NULL
);

CREATE TABLE fact_sales_monthly (
  date date NOT NULL,
  product_code varchar(45) COLLATE Latin1_General_CI_AI NOT NULL,
  customer_code int NOT NULL,
  sold_quantity int NOT NULL,
  fiscal_year INTEGER DEFAULT NULL
);


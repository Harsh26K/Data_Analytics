-- fact_sales_monthly

BULK INSERT fact_sales_monthly
FROM 'C:\Users\harsh\Desktop\Desktop\DataAnalytics\Work\Data_analysis\Consumer_Goods_Data_Analysis\Data-SQL_SERVER\fact_monthly_sales.csv'
WITH (FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	BATCHSIZE = 250000,
	MAXERRORS = 2);
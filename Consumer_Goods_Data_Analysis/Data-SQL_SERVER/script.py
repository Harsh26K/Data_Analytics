# the new.txt file was created as-

# 1. copy all the insert statements from the monthly_sales sql file
# 2. Replace all the 'Insert Into values' with '' and ';' with ','

f = open('./new.txt','r')

l = f.readlines()

f.close()

f1 = open('./fact_monthly_sales.csv','a')

s = "date,product_code,customer_code,sold_quantity,fiscal_year\n"
f1.write(s)
for s in l:
    f1.write(s.replace('),','\n').replace('(',''))

f1.close()

/* Insert cleaned data into crm_cust_info table in silver layer */

insert into silver.crm_cust_info(
cst_id,
cst_key,
cst_firstname,
cst_lastname,
cst_marital_status,
cst_gender,
cst_create_date)

select cst_id,cst_key,TRIM(cst_firstname) as cst_firstname,
trim(cst_lastname) as cst_lastname, 
case when upper(trim(cst_marital_status)) = 'M' then 'Married'
     when upper(trim(cst_marital_status)) = 'S' then 'Single'
else 'n/a'
end cst_marital_status,
case when upper(trim(cst_gender))= 'F' then 'Female'
     when upper(trim(cst_gender)) = 'M' then 'Male'
     else 'n/a'
end cst_gender,cst_create_date
FROM(
select *,
row_number() over (partition by cst_id order by cst_create_date DESC) as flag_last
from bronze.crm_cust_info
) where flag_last = 1


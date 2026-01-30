create view gold.dim_customers AS
select 
row_number() over (order by cst_id) as customer_key,
ci.cst_id as customer_id,
ci.cst_key as customer_number,
ci.cst_firstname as first_name,
ci.cst_lastname as last_name,
ci.cst_marital_status as marital_status,
case when ci.cst_gender != 'n/a' then ci.cst_gender 
     else COALESCE(ca.gen,'n/a')
end as gender,
ci.cst_create_date as create_date,
ca.bdate as birthdate,
la.cntry as country 
from silver.crm_cust_info ci 
left join silver.erp_cust_az12 ca
on ci.cst_key = ca.cid 
left join silver.erp_loc_a101 la
on ci.cst_key = la.cid;
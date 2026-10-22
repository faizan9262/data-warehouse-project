-- Creating Customer object using three tables; silver.crm_cust_info, silver.erp_cust_az12, silver.erp_loc_a101

-- Added Surrogate Id(Unique Indentifier attached to rach table) using ROW_NUMBER().

-- Problem crm_cust_info.cst_gndr - erp_cust_az12
--                         Female - Male
--                         Male   - Female
--                         Female - n/a
--                         Male   - n/a
--                         n/a    - Female
--                         n/a    - Male
--                         n/a    - n/a
-- Solved using CASE - Prioritized CRM source then ERP source.

-- Changed Column Names to User-Friendly Names

-- Dimension --> Answers questions like WHO, WHAT, WHERE?
-- Fact      --> Answers questions like HOW MANY, HOW MUCH?
DROP VIEW gold.dim_customers;
CREATE VIEW gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER(ORDER BY ci.cst_id) AS customer_key,
    ci.cst_id AS customer_id,
    ci.cst_key AS customer_number,
    ci.cst_firstname AS first_name,
    ci.cst_lastname AS last_name,
    la.cntry AS country,
    ci.cst_marital_status AS marital_status,
    CASE
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
        ELSE COALESCE(ca.gen,'n/a')
    END AS gender,
    ca.bdate AS birthdate,
    ci.cst_create_date AS create_date
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca ON ca.cid = ci.cst_key
LEFT JOIN silver.erp_loc_a101 AS la ON la.cid = ci.cst_key;



SELECT * FROM gold.dim_customers;

-- Creating Product Object using Two tables; silver.crm_prd_info & silver.erp_px_cat_g1v2

-- Added Surrogate Id(Unique Indentifier attached to rach table) using ROW_NUMBER().
-- Changed Column Names to User-Friendly Names
-- Filtered Using end_date = NULL - Drop duplicate historical record of same product and only include opened products/all products only once.
DROP VIEW gold.dim_products
CREATE VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER(ORDER BY pn.prd_start_dt,pn.prd_key) AS product_key,
    pn.prd_id AS product_id,
    pn.prd_key AS product_number,
    pn.prd_nm AS product_name,
    pn.cat_id AS category_id,
    pc.cat AS category,
    pc.subcat AS subcategory,
    pc.maintenance,
    pn.prd_cost AS product_cost,
    pn.prd_line AS product_line,
    pn.prd_start_dt AS start_date
FROM silver.crm_prd_info AS pn
LEFT JOIN silver.erp_px_cat_g1v2 AS pc ON pc.id = pn.cat_id
WHERE pn.prd_end_dt IS NULL;

SELECT * FROM gold.dim_products;

-- Creating Sale Object/Dimension unsing silver.crm_sales_details
-- This is the fact
-- Added Two keys; customer key from customer dimension & product key from product dimension from gold layer, using JOINS.

DROP VIEW gold.fact_sales;
CREATE VIEW gold.fact_sales AS
SELECT
    sd.sls_ord_num AS order_number,
    pr.product_key,
    ca.customer_key,
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt AS shipping_date,
    sd.sls_due_dt AS due_date,
    sd.sls_sales AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price AS price
FROM silver.crm_sales_details AS sd
LEFT JOIN gold.dim_products AS pr ON pr.product_number = sd.sls_prd_key
LEFT JOIN gold.dim_customers AS ca ON ca.customer_id = sd.sls_cust_id


-- In Start Schema, the relationship between fact and dimension is 1-to-many (1:N)

SELECT 
* 
FROM gold.fact_sales AS fs  
LEFT JOIN gold.dim_customers AS dc ON dc.customer_key = fs.customer_key
LEFT JOIN gold.dim_products AS dp ON dp.product_key = fs.product_key
WHERE dc.customer_key IS NULL OR dp.product_key IS NULL
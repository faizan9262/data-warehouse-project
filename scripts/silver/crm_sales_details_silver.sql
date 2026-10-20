-- Cleansing of crm_sales_details table from bronze layer to insert it into silver layer.

-- Query - 1

-- Check for unwanted spaces in sls_ord_num column
-- Execpted : No Results


SELECT
    sls_ord_num
FROM bronze.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num);

-- Query - 2

-- Checking if all sls_prd_key from crm_sales_details is exists in prd_key from crm_prd_info for joining purpose.
-- Expected : No Results

SELECT
    sls_prd_key
FROM bronze.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info);

-- Query - 3

-- Checking if all sls_cust_id from crm_sales_details is exists in cst_id from crm_cust_info for joining purpose.
-- Expected : No Results

SELECT
    sls_cust_id
FROM bronze.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info);

-- Query - 4

-- Check for Invalid Order Dates, Shipping Date, Due Date
-- Check if date id negative or zero
-- Detected 0s - Replacing 0 with Null using NULLIF
-- LENGTH only work for strings, sls_order_dt is INTEGER, need to cast it to TEXT usning ::TEXT
-- Added Date boundry from 01-01-1900 to 01-01-2050, Date should somewhere in between
-- Now all updated into Main Query
--Exptected : No Results

SELECT
    NULLIF(sls_order_dt,0) AS sls_order_dt
FROM silver.crm_sales_details
WHERE sls_order_dt <= 0 
OR LENGTH(sls_order_dt::TEXT) != 8
OR sls_order_dt > 20500101
OR sls_order_dt < 19000101;

-- Query - 5

-- Check for invalid shipping dates WHERE sls_ship_dt < sls_order_dt
-- Expected : No Result

SELECT
*
FROM bronze.crm_sales_details
WHERE sls_ship_dt < sls_order_dt OR sls_due_dt < sls_order_dt;

-- Query - 6

-- Sales, Quantity & Price Must Not Be NULL, ZERO or NEGATIVE.

-- Rules

-- If Sales is negative, zero or null, derive it unsing Quantity and Price
-- If Price is zero or null, calculate is using Sales and Quantity
-- If Price is negative, convert it into positive 

SELECT DISTINCT
    sls_sales AS old_sls_sales,
    sls_quantity,
    sls_price AS old_sls_price,
    CASE
        WHEN sls_sales IS NULL OR sls_quantity <= 0 OR sls_sales != sls_quantity * ABS(sls_price) THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS sls_sales,
    CASE
        WHEN sls_price IS NULL OR sls_price <=0 THEN sls_sales / NULLIF(sls_quantity,0)
        ELSE sls_price
    END AS sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0  OR sls_price IS NULL
ORDER BY sls_sales, sls_quantity, sls_price

-- Main Query

TRUNCATE TABLE silver.crm_sales_details;
INSERT INTO silver.crm_sales_details(
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
)
SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    CASE
        WHEN sls_order_dt < 0 OR LENGTH(sls_order_dt::TEXT) != 8 THEN NULL
        ELSE CAST(sls_order_dt::TEXT AS DATE)
    END AS sls_order_dt,
    CASE
        WHEN sls_ship_dt < 0 OR LENGTH(sls_ship_dt::TEXT) != 8 THEN NULL
        ELSE CAST(sls_ship_dt::TEXT AS DATE)
    END AS sls_ship_dt,
    CASE
        WHEN sls_due_dt < 0 OR LENGTH(sls_due_dt::TEXT) != 8 THEN NULL
        ELSE CAST(sls_due_dt::TEXT AS DATE)
    END AS sls_due_dt,
    CASE
        WHEN sls_sales IS NULL OR sls_quantity <= 0 OR sls_sales != sls_quantity * ABS(sls_price) THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS sls_sales,
    sls_quantity,
    CASE
        WHEN sls_price IS NULL OR sls_price <=0 THEN sls_sales / NULLIF(sls_quantity,0)
        ELSE sls_price
    END AS sls_price
FROM bronze.crm_sales_details;

SELECT
*
FROM silver.crm_sales_details


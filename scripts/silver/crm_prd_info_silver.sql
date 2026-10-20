-- Cleansing of crm_prd_info table from bronze layer to insert it into silver layer.

-- Query - 1

-- Check for duplicates / NULLs in Primary Key
-- Expected : No Results

SELECT
    prd_id
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Query - 2

-- Checking for unwanted spaces in product name
-- Expected : No Results.
-- No Need to trim - no unwanted spaces.

SELECT
    prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Query - 3

-- Check for NULLS and Negative Numbers in Product Cost
-- Expeted : No Result
-- Nulls found - Replacing nulls with 0 using COALESCE in Main Query.

SELECT
    prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost IS NULL OR prd_cost < 0;

-- Query - 4

-- Data Standardization & Consistency - for prd_line
-- Transforming short abbreviation to Full Forms using CASE in Main Query.
-- M --> Mountain, R --> Road, S --> other Sales, T --> Touring

SELECT DISTINCT
prd_line
FROM bronze.crm_prd_info;

-- Query - 5 

-- Check for Invalid Dates Orders
-- Expected : No Result
-- Invalid Dates Detected
-- Solved using LEAD fucntion to add next products date as new end_date in Main Query.

SELECT
*
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- prd_key contains category id and product key, CO-RF-FR-R92B-58 , Here CO-RF is category id and FR-R92B-58 Product id.
-- Using SUBSTRING to exytract that as cat_id in Main Query
-- Category table cat_id contains (_)"Underscore" While Subtring extracted cat_id   contains (-)"Dahs", Nedd to convert it to (_)"underscore for joining table on later stage."
-- Using REPLACE to replace (-)"Dash" with (_)"Underscore".
-- Same SUSTRING for Remaing part fo prd_key to extract prd key that will help to join table with sales details table. 

TRUNCATE TABLE silver.crm_prd_info;
INSERT INTO silver.crm_prd_info(
    prd_id,
    cat_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
)

-- Main Query

SELECT
    prd_id,
    REPLACE(SUBSTRING(prd_key, 1, 5),'-','_') AS cat_id,
    SUBSTRING(prd_key,7,LENGTH(prd_key)) AS prd_key,
    prd_nm,
    COALESCE(prd_cost,0) AS prd_cost,
    CASE UPPER(TRIM(prd_line))
        WHEN 'M' THEN 'Mountain'
        WHEN 'R' THEN 'Road'
        WHEN 'S' THEN 'Other Sales'
        WHEN 'T' THEN 'Touring'
        ELSE 'n/a'
    END AS prd_line,
    prd_start_dt::DATE,
    LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)::DATE - 1 AS prd_end_dt
FROM bronze.crm_prd_info;

SELECT
* FROM silver.crm_prd_info

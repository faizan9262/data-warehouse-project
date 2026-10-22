-- Cleansing of erp_cust_az12 table from bronze layer to insert it into silver layer.

-- Query - 1
-- Checking cleaning customer id
-- erp_cust_az12 cid = NASAW00019902 , crm_cust_info cst_id = AW00019902
-- Need to remove that extra 'NAS' from cid for joining purpose for further stage.
-- Removed usnig CASE and SUBSTRING


-- Query - 2
-- Checking out of range bdate
-- bdates older that 100 years or bdates from future using CURRENT_DATE and CASE

SELECT
    CASE
        WHEN bdate > CURRENT_DATE THEN NULL
        ELSE bdate
    END AS bdate
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > CURRENT_DATE;


-- Query - 3

-- Data Standardization & Consistency

SELECT DISTINCT
    CASE
        WHEN UPPER(TRIM(gen)) IN ('FEMALE','F') THEN 'Female'
        WHEN UPPER(TRIM(gen)) IN ('MALE','M') THEN 'Male'
        ELSE 'n/a'
    END AS gen
FROM bronze.erp_cust_az12;


-- Main Query

RAISE NOTICE 'Truncating Table: silver.erp_cust_az12';
TRUNCATE TABLE silver.erp_cust_az12;
RAISE NOTICE 'Inserting Data Into: silver.erp_cust_az12';
TRUNCATE TABLE silver.erp_cust_az12;
INSERT INTO silver.erp_cust_az12(
    cid,
    bdate,
    gen
)
SELECT
    CASE 
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4 , LENGTH(cid))
        ELSE cid
    END AS cid,
    CASE
        WHEN bdate > CURRENT_DATE THEN NULL
        ELSE bdate
    END AS bdate,
    CASE
        WHEN UPPER(TRIM(gen)) IN ('FEMALE','F') THEN 'Female'
        WHEN UPPER(TRIM(gen)) IN ('MALE','M') THEN 'Male'
        ELSE 'n/a'
    END AS gen
FROM bronze.erp_cust_az12;

SELECT
*
FROM silver.erp_cust_az12
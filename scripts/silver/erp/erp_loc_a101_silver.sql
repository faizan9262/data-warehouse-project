-- Cleansing of erp_loc_a101 table from bronze layer to insert it into silver layer.

-- Query - 1
-- Replace '-' with '' in cid using REPLACE

SELECT
    cid,
    REPLACE(cid, '-', '')
FROM bronze.erp_loc_a101;


-- Query - 2
-- Data Standardization & Consistency

SELECT DISTINCT
    cntry,
    CASE
        WHEN TRIM(cntry) = 'DE' THEN 'Germany'
        WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
        WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
        ELSE TRIM(cntry)
    END cntry
FROM bronze.erp_loc_a101;


-- Main Query

RAISE NOTICE 'Truncating Table: silver.erp_loc_a101';
TRUNCATE TABLE silver.erp_loc_a101;
RAISE NOTICE 'Inserting Data Into: silver.erp_loc_a101';
TRUNCATE TABLE silver.erp_loc_a101;
INSERT INTO silver.erp_loc_a101(
    cid,
    cntry
)
SELECT
    REPLACE(cid, '-', '') AS cid,
    CASE
        WHEN TRIM(cntry) = 'DE' THEN 'Germany'
        WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
        WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
        ELSE TRIM(cntry)
    END cntry
FROM bronze.erp_loc_a101;

SELECT
*
FROM silver.erp_loc_a101
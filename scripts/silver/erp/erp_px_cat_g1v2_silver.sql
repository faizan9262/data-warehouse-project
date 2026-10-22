-- Cleansing of erp_px_cat_g1v2 table from bronze layer to insert it into silver layer.

-- Query - 1
-- Check for unwanted spaces in cat, subcat and maintenace
-- Expected : No Results

SELECT
cat,
subcat,
maintenance
FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance);

-- Query - 2
-- Data Standardization & Consistency

SELECT DISTINCT
maintenance
FROM bronze.erp_px_cat_g1v2;

-- Main Query

RAISE NOTICE 'Truncating Table: silver.erp_px_cat_g1v2';
TRUNCATE TABLE silver.erp_px_cat_g1v2;
RAISE NOTICE 'Inserting Data Into: silver.erp_px_cat_g1v2';
INSERT INTO silver.erp_px_cat_g1v2(
    id,
    cat,
    subcat,
    maintenance
)
SELECT
    id,
    cat,
    subcat,
    maintenance
FROM bronze.erp_px_cat_g1v2;

SELECT
*
FROM silver.erp_px_cat_g1v2
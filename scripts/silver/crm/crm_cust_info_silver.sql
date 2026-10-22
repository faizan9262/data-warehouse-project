-- Cleansing of crm_cust_info table from bronze layer to insert it into silver layer.

-- Query - 1

-- Check for nulls or duplicate in primary key
-- Expetctation Output : No Result

SELECT 
    cst_id,
    COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1
    OR cst_id IS NULL;

-- Query - 2

-- Date Standardization & Consistency
-- For cst_marital_status, cst_gndr
-- No Result

SELECT DISTINCT
cst_gndr
FROM bronze.crm_cust_info;

SELECT DISTINCT
cst_marital_status
FROM bronze.crm_cust_info;

-- Query - 3

-- Check for unwated spaces in Strings/Text
-- Expectation : No Result

SELECT
    cst_lastname
FROM bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

-- Final Transformation Query

-- Query - 4 (Transforming Bronze.crm_cust_info for Insertion into silver layer silver.crm_cust_info)

-- Flag latest record usnig row_number & order by creation date and pick flag 1.
-- This remove all duplicates in primary key (cst_id), not primary key is unique and not null. -> Query - 1
-- TRIM firstname and last as they have unwanted spaces -> Query-3
-- Final Insertion After Transformation

RAISE NOTICE 'Truncating Table: silver.crm_cust_info';
TRUNCATE TABLE silver.crm_cust_info;
RAISE NOTICE 'Inserting Data Into: silver.crm_cust_info';
INSERT INTO silver.crm_cust_info(
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date
)

-- Main Query

SELECT 
    cst_id,
    cst_key,
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_lastname,
    CASE
        WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
        ELSE 'n/a'
    END AS cst_marital_status,
    CASE
        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
        ELSE 'n/a'
    END AS cst_gndr,
    cst_create_date
FROM(
        SELECT 
            *,
            ROW_NUMBER() OVER(
                PARTITION BY cst_id
                ORDER BY cst_create_date DESC
            ) AS flag_last
        FROM bronze.crm_cust_info
        WHERE cst_id IS NOT NULL
    ) AS ranked
WHERE flag_last = 1;

SELECT
*
FROM silver.crm_cust_info
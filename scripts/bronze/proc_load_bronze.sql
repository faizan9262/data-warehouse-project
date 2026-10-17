CREATE OR REPLACE PROCEDURE bronze.load_bronze()
LANGUAGE plpgsql
AS $$
DECLARE
    start_time TIMESTAMP;
    end_time   TIMESTAMP;
    batch_start TIMESTAMP;
    batch_end TIMESTAMP;
    duration_seconds NUMERIC;
    batch_duration NUMERIC;
BEGIN
    batch_start := clock_timestamp();
    RAISE NOTICE '===========================================================================';
    RAISE NOTICE 'Loading Bronze Later';
    RAISE NOTICE '===========================================================================';

    -- Loading CRM 

    RAISE NOTICE '---------------------------------------------------------------------------';
    RAISE NOTICE 'Loading Source CRM Tables';
    RAISE NOTICE '---------------------------------------------------------------------------';

    start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: bronze.crm_cust_info';
    TRUNCATE TABLE bronze.crm_cust_info;

    RAISE NOTICE '>> Inserting Data Into : bronze.crm_cust_info';
    COPY bronze.crm_cust_info
    FROM '/Users/shaikhfaizan/Data Warehouse Project/datasets/source_crm/cust_info.csv'
    WITH(
        FORMAT CSV,
        HEADER TRUE,
        DELIMITER ','
    );

    end_time := clock_timestamp();
    duration_seconds := EXTRACT(EPOCH FROM (end_time - start_time));
    RAISE NOTICE 'Total loading time: % seconds', ROUND(duration_seconds, 2);


    start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: bronze.crm_prd_info';
    TRUNCATE TABLE bronze.crm_prd_info;

    RAISE NOTICE '>> Inserting Data Into : bronze.crm_prd_info';
    COPY bronze.crm_prd_info
    FROM '/Users/shaikhfaizan/Data Warehouse Project/datasets/source_crm/prd_info.csv'
    WITH(
        FORMAT CSV,
        HEADER TRUE,
        DELIMITER ','
    );
    end_time := clock_timestamp();
    duration_seconds := EXTRACT(EPOCH FROM (end_time - start_time));
    RAISE NOTICE 'Total loading time: % seconds', ROUND(duration_seconds, 2);


    start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: bronze.crm_sales_details';
    TRUNCATE TABLE bronze.crm_sales_details;

    RAISE NOTICE '>> Inserting Data Into : bronze.crm_sales_details';
    COPY bronze.crm_sales_details
    FROM '/Users/shaikhfaizan/Data Warehouse Project/datasets/source_crm/sales_details.csv'
    WITH(
        FORMAT CSV,
        HEADER TRUE,
        DELIMITER ',' 
    );
    end_time := clock_timestamp();
    duration_seconds := EXTRACT(EPOCH FROM (end_time - start_time));
    RAISE NOTICE 'Total loading time: % seconds', ROUND(duration_seconds, 2);

    -- Loading ERP

    RAISE NOTICE '---------------------------------------------------------------------------';
    RAISE NOTICE 'Loading Source ERP Tables';
    RAISE NOTICE '---------------------------------------------------------------------------';

    start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: bronze.erp_cust_az12';
    TRUNCATE TABLE bronze.erp_cust_az12;

    RAISE NOTICE '>> Inserting Data Into : bronze.erp_cust_az12';
    COPY bronze.erp_cust_az12
    FROM '/Users/shaikhfaizan/Data Warehouse Project/datasets/source_erp/CUST_AZ12.csv'
    WITH(
        FORMAT CSV,
        HEADER TRUE,
        DELIMITER ',' 
    );
    end_time := clock_timestamp();
    duration_seconds := EXTRACT(EPOCH FROM (end_time - start_time));
    RAISE NOTICE 'Total loading time: % seconds', ROUND(duration_seconds, 2);

    start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: bronze.erp_loc_a101';
    TRUNCATE TABLE bronze.erp_loc_a101;

    RAISE NOTICE '>> Inserting Data Into : bronze.erp_loc_a101';
    COPY bronze.erp_loc_a101
    FROM '/Users/shaikhfaizan/Data Warehouse Project/datasets/source_erp/LOC_A101.csv'
    WITH(
        FORMAT CSV,
        HEADER TRUE,
        DELIMITER ',' 
    );
    end_time := clock_timestamp();
    duration_seconds := EXTRACT(EPOCH FROM (end_time - start_time));
    RAISE NOTICE 'Total loading time: % seconds', ROUND(duration_seconds, 2);

    start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: bronze.erp_px_cat_g1v2';
    TRUNCATE TABLE bronze.erp_px_cat_g1v2;

    RAISE NOTICE '>> Inserting Data Into : bronze.erp_px_cat_g1v2';
    COPY bronze.erp_px_cat_g1v2
    FROM '/Users/shaikhfaizan/Data Warehouse Project/datasets/source_erp/PX_CAT_G1V2.csv'
    WITH(
        FORMAT CSV,
        HEADER TRUE,
        DELIMITER ',' 
    );
    end_time := clock_timestamp();
    duration_seconds := EXTRACT(EPOCH FROM (end_time - start_time));
    RAISE NOTICE 'Total loading time: % seconds', ROUND(duration_seconds, 2);

    batch_end := clock_timestamp();
    batch_duration := EXTRACT(EPOCH FROM (batch_end - batch_start));
    RAISE NOTICE 'Total loading time for bronze: % seconds', ROUND(batch_duration, 2);

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error message: %', SQLERRM;
        RAISE;
END; 
$$;

CALL bronze.load_bronze();
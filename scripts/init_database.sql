/*
=============================================================
Create Database and Schemas (PostgreSQL)
=============================================================
Script Purpose:
    Creates the 'datawarehouse' database if needed and sets up
    the bronze, silver, and gold schemas.

WARNING:
    The DROP DATABASE statement permanently deletes the database
    and all its data. It is commented out by default for safety.

Usage:
    1. Connect to the 'postgres' database in psql.
    2. If you intentionally want to reset the project database,
       uncomment the DROP DATABASE line below and run it separately.
       PostgreSQL cannot drop the database you are currently connected to.
    3. Run CREATE DATABASE if it does not already exist.
    4. Connect to 'datawarehouse' using: \c datawarehouse
    5. Run the schema statements.

Note:
    \c is a psql command, not SQL. If using a GUI client such as
    pgAdmin, create/connect to the database using its interface, then
    execute only the CREATE SCHEMA statements.
=============================================================
*/

-- Run while connected to the 'postgres' database in psql:

-- Check whether the database exists:
SELECT datname
FROM pg_database
WHERE datname = 'datawarehouse';

-- DANGER: Uncomment and run separately only if you intend to
-- permanently delete the existing database and all its data.
-- DROP DATABASE IF EXISTS datawarehouse;

-- Create the database only if it does not already exist.
-- PostgreSQL has no CREATE DATABASE IF NOT EXISTS syntax.
-- If the database already exists, skip this statement.
CREATE DATABASE datawarehouse;

-- In psql, connect to the new database before running the schemas:
-- \c datawarehouse

-- Run the following statements while connected to 'datawarehouse':
CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;

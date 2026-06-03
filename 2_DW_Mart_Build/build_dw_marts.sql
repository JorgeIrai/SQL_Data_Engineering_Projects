-- Local Execution: duckdb dw_marts.duckdb -c ".read build_dw_marts.sql"


-- Step 1 - DW - Create star schema tables
.read 01_create_tables_dw.sql

-- Step 2 - DW - Load data from CSV files into tables
.read 02_load_schema_dw.sql

-- Step 3: Marte - Create flat mart table
.read 03_create_flat_mart.sql

-- Step 4: Mart - Create skills demand mart
.read 04_create_skills_mart.sql

-- Step 5: Mart - Create priority roles mart
.read 05_create_priority_mart.sql

-- Step 6 - Update priority roles mart
.read 06_update_priority_mart.sql


-- Create Data Warehouse in Motherduck:
-- duckdb md:
-- CREATE DATABASE dw_marts;

-- Upload DW into motherduck
-- duckdb md:dw_marts -c ".read build_dw_marts.sql"
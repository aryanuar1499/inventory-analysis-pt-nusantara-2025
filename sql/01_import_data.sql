
-- ============================================================
-- Project 01: Inventory Analysis
-- PT Nusantara Distribution | Dataset Year: 2025
-- File: 01_import_data.sql
-- Purpose: Document CSV import procedures using pgAdmin 4
-- ============================================================

-- PREREQUISITES
-- 1. Create the inventory_analysis database.
-- 2. Execute 01_create_tables.sql.
-- 3. Ensure all CSV files are available locally.
-- 4. Use pgAdmin 4 Import/Export Data for each table.

-- ============================================================
-- CSV IMPORT ORDER
-- ============================================================

-- Import master tables first to satisfy foreign keys.

-- 1. products
-- Source: data/processed/products_clean.csv

-- 2. warehouses
-- Source: data/raw/warehouses.csv

-- 3. opening_inventory
-- Source: data/raw/opening_inventory.csv

-- 4. inventory_transactions
-- Source: data/raw/inventory_transactions.csv

-- 5. sales
-- Source: data/raw/sales.csv

-- ============================================================
-- PGADMIN 4 IMPORT SETTINGS
-- ============================================================

-- Right-click the target table:
-- Import/Export Data > Import

-- Format: CSV
-- Header: Yes
-- Encoding: UTF8
-- Delimiter: ,
-- Quote: "

-- Confirm that CSV column order matches the target table.
-- Use the Columns tab to select or reorder columns if needed.

-- ============================================================
-- POST-IMPORT VALIDATION
-- ============================================================

-- Expected record counts:
-- products:                40
-- warehouses:               3
-- opening_inventory:      120
-- inventory_transactions: 29430
-- sales:                  28169

-- Execute 02_data_validation.sql after import.

-- IMPORTANT:
-- Do not import products.csv directly.
-- Use products_clean.csv to reproduce the cleaned dataset.

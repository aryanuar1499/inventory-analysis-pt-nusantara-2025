-- ============================================================
-- PROJECT 01: INVENTORY ANALYSIS
-- PHASE 05: BUSINESS INTELLIGENCE & POWER BI
-- MODULE 01: DATA SOURCE VALIDATION
-- ============================================================
--
-- Database : inventory_analysis
-- Source   : vw_daily_inventory_balance
-- Period   : 2025-01-01 to 2025-12-31
--
-- Purpose:
-- Validate data quality, granularity, and coverage
-- before importing inventory data into Power BI.
--
-- ============================================================

-- ============================================================
-- VALIDATION 01: DAILY INVENTORY GRANULARITY
-- ============================================================
--
-- Objective:
-- Verify that each stock_date, warehouse_id, and product_id
-- combination appears at most once.
--
-- Expected Result:
-- 0 rows returned.
--
-- Actual Result:
-- 0 rows returned (PASSED).
--
-- ============================================================

SELECT
    stock_date,
    warehouse_id,
    product_id,
    COUNT(*) AS row_count
FROM vw_daily_inventory_balance
GROUP BY
    stock_date,
    warehouse_id,
    product_id
HAVING COUNT(*) > 1
ORDER BY row_count DESC;

-- ============================================================
-- VALIDATION 02: DAILY INVENTORY NULL VALUE INSPECTION
-- ============================================================
--
-- Objective:
-- Verify that all four columns in vw_daily_inventory_balance
-- contain no NULL values.
--
-- Expected Result:
-- Total records: 43,800
-- NULL values in all inspected columns: 0
--
-- Actual Result:
-- Total records: 43,800
-- null_stock_date: 0
-- null_warehouse_id: 0
-- null_product_id: 0
-- null_closing_stock: 0
--
-- Validation Status: PASSED
--
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (
        WHERE stock_date IS NULL
    ) AS null_stock_date,
    COUNT(*) FILTER (
        WHERE warehouse_id IS NULL
    ) AS null_warehouse_id,
    COUNT(*) FILTER (
        WHERE product_id IS NULL
    ) AS null_product_id,
    COUNT(*) FILTER (
        WHERE daily_closing_stock IS NULL
    ) AS null_closing_stock
FROM vw_daily_inventory_balance;

-- ============================================================
-- VALIDATION 03: DAILY INVENTORY DATE COVERAGE
-- ============================================================
--
-- Objective:
-- Verify that daily inventory records cover the full
-- calendar year 2025.
--
-- Expected Result:
-- Earliest date: 2025-01-01
-- Latest date: 2025-12-31
-- Total unique dates: 365
--
-- Actual Result:
-- Earliest date: 2025-01-01
-- Latest date: 2025-12-31
-- Total unique dates: 365
--
-- Validation Status: PASSED
--
-- ============================================================

SELECT
    MIN(stock_date) AS earliest_date,
    MAX(stock_date) AS latest_date,
    COUNT(DISTINCT stock_date) AS total_unique_dates
FROM vw_daily_inventory_balance;

-- ============================================================
-- VALIDATION 04: DAILY INVENTORY RECORD CONSISTENCY
-- ============================================================
--
-- Objective:
-- Verify that the number of inventory records remains
-- consistent across all dates in 2025.
--
-- Expected Result:
-- Total dates: 365
-- Records per date: 120
--
-- Actual Result:
-- Total dates: 365
-- Records per date: 120
--
-- Validation Status: PASSED
--
-- ============================================================

SELECT
    stock_date,
    COUNT(*) AS daily_records
FROM vw_daily_inventory_balance
GROUP BY stock_date
ORDER BY stock_date;

-- ============================================================
-- VALIDATION 05: PRODUCT-WAREHOUSE DATE COVERAGE
-- ============================================================
--
-- Objective:
-- Verify that every existing product-warehouse combination
-- has inventory records for all 365 days in 2025.
--
-- Expected Result:
-- 0 rows returned.
--
-- Actual Result:
-- 0 rows returned.
--
-- Validation Status: PASSED
--
-- ============================================================

SELECT
    warehouse_id,
    product_id,
    COUNT(DISTINCT stock_date) AS total_days
FROM vw_daily_inventory_balance
GROUP BY
    warehouse_id,
    product_id
HAVING COUNT(DISTINCT stock_date) <> 365
ORDER BY
    warehouse_id,
    product_id;

-- ============================================================
-- Project 01: Inventory Analysis
-- PT Nusantara Distribution | Dataset Year: 2025
-- File: 02_data_validation.sql
-- Purpose: Validate imported datasets before analysis
-- ============================================================

-- SECTION 01: ROW COUNT VALIDATION
-- Objective:
-- Verify the number of records imported into each table.
--
-- Expected:
-- All five tables contain data after CSV import.

SELECT
    'products' AS table_name,
    COUNT(*) AS total_rows
FROM products

UNION ALL

SELECT
    'warehouses',
    COUNT(*)
FROM warehouses

UNION ALL

SELECT
    'opening_inventory',
    COUNT(*)
FROM opening_inventory

UNION ALL

SELECT
    'inventory_transactions',
    COUNT(*)
FROM inventory_transactions

UNION ALL

SELECT
    'sales',
    COUNT(*)
FROM sales;


-- ============================================================
-- SECTION 02: MISSING VALUES VALIDATION
-- Objective:
-- Check missing values in critical business columns.
-- ============================================================

SELECT
    'products' AS table_name,
    COUNT(*) FILTER (
        WHERE product_id IS NULL
    ) AS missing_id,
    COUNT(*) FILTER (
        WHERE product_name IS NULL
    ) AS missing_detail
FROM products

UNION ALL

SELECT
    'warehouses',
    COUNT(*) FILTER (
        WHERE warehouse_id IS NULL
    ),
    COUNT(*) FILTER (
        WHERE warehouse_name IS NULL
    )
FROM warehouses

UNION ALL

SELECT
    'opening_inventory',
    COUNT(*) FILTER (
        WHERE product_id IS NULL
           OR warehouse_id IS NULL
    ),
    COUNT(*) FILTER (
        WHERE opening_qty IS NULL
    )
FROM opening_inventory

UNION ALL

SELECT
    'inventory_transactions',
    COUNT(*) FILTER (
        WHERE transaction_id IS NULL
    ),
    COUNT(*) FILTER (
        WHERE quantity IS NULL
           OR transaction_date IS NULL
    )
FROM inventory_transactions

UNION ALL

SELECT
    'sales',
    COUNT(*) FILTER (
        WHERE sales_id IS NULL
    ),
    COUNT(*) FILTER (
        WHERE quantity IS NULL
           OR unit_price IS NULL
           OR discount_pct IS NULL
    )
FROM sales;


-- ============================================================
-- SECTION 03: DUPLICATE KEY VALIDATION
-- Objective:
-- Detect duplicate primary key combinations.
-- Expected result: 0 duplicate keys in every table.
-- ============================================================

SELECT
    'products' AS table_name,
    COUNT(*) AS duplicate_key_groups
FROM (
    SELECT product_id
    FROM products
    GROUP BY product_id
    HAVING COUNT(*) > 1
) duplicates

UNION ALL

SELECT
    'warehouses',
    COUNT(*)
FROM (
    SELECT warehouse_id
    FROM warehouses
    GROUP BY warehouse_id
    HAVING COUNT(*) > 1
) duplicates

UNION ALL

SELECT
    'opening_inventory',
    COUNT(*)
FROM (
    SELECT
        snapshot_date,
        warehouse_id,
        product_id
    FROM opening_inventory
    GROUP BY
        snapshot_date,
        warehouse_id,
        product_id
    HAVING COUNT(*) > 1
) duplicates

UNION ALL

SELECT
    'inventory_transactions',
    COUNT(*)
FROM (
    SELECT transaction_id
    FROM inventory_transactions
    GROUP BY transaction_id
    HAVING COUNT(*) > 1
) duplicates

UNION ALL

SELECT
    'sales',
    COUNT(*)
FROM (
    SELECT sales_id
    FROM sales
    GROUP BY sales_id
    HAVING COUNT(*) > 1
) duplicates;


-- ============================================================
-- SECTION 04: REFERENTIAL INTEGRITY VALIDATION
-- Objective:
-- Detect records referencing non-existent products or warehouses.
-- Expected result: 0 orphan records for every relationship.
-- ============================================================

SELECT
    'sales' AS source_table,
    'products' AS reference_table,
    COUNT(*) AS orphan_records
FROM sales s
LEFT JOIN products p
    ON s.product_id = p.product_id
WHERE p.product_id IS NULL

UNION ALL

SELECT
    'sales',
    'warehouses',
    COUNT(*)
FROM sales s
LEFT JOIN warehouses w
    ON s.warehouse_id = w.warehouse_id
WHERE w.warehouse_id IS NULL

UNION ALL

SELECT
    'inventory_transactions',
    'products',
    COUNT(*)
FROM inventory_transactions it
LEFT JOIN products p
    ON it.product_id = p.product_id
WHERE p.product_id IS NULL

UNION ALL

SELECT
    'inventory_transactions',
    'warehouses',
    COUNT(*)
FROM inventory_transactions it
LEFT JOIN warehouses w
    ON it.warehouse_id = w.warehouse_id
WHERE w.warehouse_id IS NULL

UNION ALL

SELECT
    'opening_inventory',
    'products',
    COUNT(*)
FROM opening_inventory oi
LEFT JOIN products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL

UNION ALL

SELECT
    'opening_inventory',
    'warehouses',
    COUNT(*)
FROM opening_inventory oi
LEFT JOIN warehouses w
    ON oi.warehouse_id = w.warehouse_id
WHERE w.warehouse_id IS NULL;


-- ============================================================
-- SECTION 05: BUSINESS RULE VALIDATION
-- Objective:
-- Detect invalid quantities, prices, discounts, and capacities.
-- Expected result: 0 violations for valid business rules.
-- ============================================================

SELECT
    'products' AS table_name,
    'negative_unit_cost' AS validation_rule,
    COUNT(*) AS invalid_records
FROM products
WHERE unit_cost < 0

UNION ALL

SELECT
    'products',
    'negative_selling_price',
    COUNT(*)
FROM products
WHERE selling_price < 0

UNION ALL

SELECT
    'warehouses',
    'negative_capacity',
    COUNT(*)
FROM warehouses
WHERE capacity_units < 0

UNION ALL

SELECT
    'opening_inventory',
    'negative_opening_qty',
    COUNT(*)
FROM opening_inventory
WHERE opening_qty < 0

UNION ALL

SELECT
    'inventory_transactions',
    'non_positive_quantity',
    COUNT(*)
FROM inventory_transactions
WHERE quantity <= 0

UNION ALL

SELECT
    'sales',
    'non_positive_quantity',
    COUNT(*)
FROM sales
WHERE quantity <= 0

UNION ALL

SELECT
    'sales',
    'negative_unit_price',
    COUNT(*)
FROM sales
WHERE unit_price < 0

UNION ALL

SELECT
    'sales',
    'invalid_discount_pct',
    COUNT(*)
FROM sales
WHERE discount_pct < 0
   OR discount_pct > 100;


-- ============================================================
-- SECTION 06: TRANSACTION TYPE VALIDATION
-- Objective:
-- Validate allowed inventory transaction categories.
-- ============================================================

-- 6.1 Transaction distribution
SELECT
    transaction_type,
    COUNT(*) AS total_transactions,
    SUM(quantity) AS total_quantity
FROM inventory_transactions
GROUP BY transaction_type
ORDER BY transaction_type;

-- 6.2 Invalid transaction categories
SELECT
    COUNT(*) AS invalid_transaction_types
FROM inventory_transactions
WHERE transaction_type NOT IN (
    'INBOUND',
    'OUTBOUND',
    'RETURN',
    'DAMAGE'
);


-- ============================================================
-- SECTION 07: DATE RANGE VALIDATION
-- Objective:
-- Verify dataset coverage and detect dates outside 2025.
-- ============================================================

SELECT
    'opening_inventory' AS table_name,
    MIN(snapshot_date) AS earliest_date,
    MAX(snapshot_date) AS latest_date,
    COUNT(*) FILTER (
        WHERE snapshot_date < DATE '2025-01-01'
           OR snapshot_date >= DATE '2026-01-01'
    ) AS records_outside_2025
FROM opening_inventory

UNION ALL

SELECT
    'inventory_transactions',
    MIN(transaction_date),
    MAX(transaction_date),
    COUNT(*) FILTER (
        WHERE transaction_date < DATE '2025-01-01'
           OR transaction_date >= DATE '2026-01-01'
    )
FROM inventory_transactions

UNION ALL

SELECT
    'sales',
    MIN(sales_date),
    MAX(sales_date),
    COUNT(*) FILTER (
        WHERE sales_date < DATE '2025-01-01'
           OR sales_date >= DATE '2026-01-01'
    )
FROM sales;


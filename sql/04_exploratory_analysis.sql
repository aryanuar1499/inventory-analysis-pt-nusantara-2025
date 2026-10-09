-- =====================================================
-- PROJECT 01: INVENTORY ANALYSIS
-- PT NUSANTARA DISTRIBUTION 2025
-- PHASE 03: EXPLORATORY DATA ANALYSIS
-- =====================================================

-- STEP 01: DATABASE STRUCTURE VALIDATION

SELECT
    table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- STEP 02: TABLE ROW COUNT VALIDATION

SELECT 'inventory_transactions' AS table_name,
       COUNT(*) AS total_rows
FROM inventory_transactions

UNION ALL

SELECT 'opening_inventory', COUNT(*)
FROM opening_inventory

UNION ALL

SELECT 'products', COUNT(*)
FROM products

UNION ALL

SELECT 'sales', COUNT(*)
FROM sales

UNION ALL

SELECT 'warehouses', COUNT(*)
FROM warehouses;

-- STEP 03: OPENING INVENTORY COVERAGE VALIDATION

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT (product_id, warehouse_id))
        AS unique_product_warehouse,
    COUNT(*) - COUNT(DISTINCT (product_id, warehouse_id))
        AS duplicate_combinations
FROM opening_inventory;

-- STEP 04: PRODUCT-WAREHOUSE COMPLETENESS VALIDATION

SELECT
    (SELECT COUNT(*) FROM products)
        AS total_products,

    (SELECT COUNT(*) FROM warehouses)
        AS total_warehouses,

    (SELECT COUNT(*) FROM products)
    * (SELECT COUNT(*) FROM warehouses)
        AS expected_combinations,

    (SELECT COUNT(DISTINCT (product_id, warehouse_id))
     FROM opening_inventory)
        AS actual_combinations;

-- STEP 05: MISSING PRODUCT-WAREHOUSE COMBINATIONS

SELECT
    p.product_id,
    w.warehouse_id
FROM products p
CROSS JOIN warehouses w
LEFT JOIN opening_inventory oi
    ON p.product_id = oi.product_id
   AND w.warehouse_id = oi.warehouse_id
WHERE oi.product_id IS NULL
ORDER BY p.product_id, w.warehouse_id;

-- STEP 06: OPENING INVENTORY NULL VALIDATION

SELECT
    COUNT(*) AS total_records,

    COUNT(*) FILTER (
        WHERE product_id IS NULL
    ) AS null_product_id,

    COUNT(*) FILTER (
        WHERE warehouse_id IS NULL
    ) AS null_warehouse_id

FROM opening_inventory;

-- STEP 07: OPENING INVENTORY COLUMN STRUCTURE

SELECT
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'opening_inventory'
ORDER BY ordinal_position;

-- STEP 08: OPENING INVENTORY QUANTITY VALIDATION

SELECT
    COUNT(*) AS total_records,

    COUNT(*) FILTER (
        WHERE opening_qty < 0
    ) AS negative_stock,

    COUNT(*) FILTER (
        WHERE opening_qty = 0
    ) AS zero_stock,

    MIN(opening_qty) AS minimum_stock,

    MAX(opening_qty) AS maximum_stock,

    SUM(opening_qty) AS total_opening_stock

FROM opening_inventory;

-- STEP 09: OPENING INVENTORY SNAPSHOT DATE VALIDATION

SELECT
    snapshot_date,
    COUNT(*) AS total_records,
    SUM(opening_qty) AS total_opening_qty
FROM opening_inventory
GROUP BY snapshot_date
ORDER BY snapshot_date;

-- STEP 10: INVENTORY TRANSACTION DATE COLUMN IDENTIFICATION

SELECT
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'inventory_transactions'
ORDER BY ordinal_position;

-- STEP 11: INVENTORY TRANSACTION DATE RANGE VALIDATION

SELECT
    COUNT(*) AS total_transactions,

    MIN(transaction_date) AS earliest_transaction,

    MAX(transaction_date) AS latest_transaction,

    COUNT(*) FILTER (
        WHERE transaction_date < DATE '2025-01-01'
           OR transaction_date >= DATE '2026-01-01'
    ) AS transactions_outside_2025

FROM inventory_transactions;

-- STEP 12: INVENTORY TRANSACTION QUANTITY VALIDATION

SELECT
    COUNT(*) AS total_transactions,

    COUNT(*) FILTER (
        WHERE quantity < 0
    ) AS negative_quantity,

    COUNT(*) FILTER (
        WHERE quantity = 0
    ) AS zero_quantity,

    MIN(quantity) AS minimum_quantity,

    MAX(quantity) AS maximum_quantity,

    SUM(quantity) AS total_transaction_quantity

FROM inventory_transactions;

-- STEP 13: INVENTORY TRANSACTION TYPE VALIDATION

SELECT
    transaction_type,
    COUNT(*) AS total_transactions,
    SUM(quantity) AS total_quantity
FROM inventory_transactions
GROUP BY transaction_type
ORDER BY transaction_type;

-- STEP 14: INVENTORY TRANSACTION
-- REFERENTIAL INTEGRITY VALIDATION

SELECT
    COUNT(*) AS total_transactions,

    COUNT(*) FILTER (
        WHERE p.product_id IS NULL
    ) AS invalid_product_id,

    COUNT(*) FILTER (
        WHERE w.warehouse_id IS NULL
    ) AS invalid_warehouse_id

FROM inventory_transactions it

LEFT JOIN products p
    ON it.product_id = p.product_id

LEFT JOIN warehouses w
    ON it.warehouse_id = w.warehouse_id;

    -- STEP 15: INVENTORY TRANSACTION ID UNIQUENESS

SELECT
    COUNT(*) AS total_transactions,

    COUNT(DISTINCT transaction_id)
        AS unique_transaction_ids,

    COUNT(*) - COUNT(DISTINCT transaction_id)
        AS duplicate_transaction_ids

FROM inventory_transactions;

-- =====================================================
-- STEP 16: FINAL INVENTORY DATA QUALITY SUMMARY
-- =====================================================

SELECT
    COUNT(*) AS total_transactions,

    COUNT(DISTINCT transaction_id)
        AS unique_transactions,

    COUNT(*) FILTER (
        WHERE quantity <= 0
    ) AS invalid_quantity,

    COUNT(*) FILTER (
        WHERE transaction_date < DATE '2025-01-01'
           OR transaction_date >= DATE '2026-01-01'
    ) AS invalid_transaction_date,

    COUNT(*) FILTER (
        WHERE transaction_type NOT IN (
            'INBOUND',
            'OUTBOUND',
            'RETURN',
            'DAMAGE'
        )
    ) AS invalid_transaction_type

FROM inventory_transactions;
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

-- =====================================================
-- PHASE 03: INVENTORY MOVEMENT ANALYSIS
-- STEP 27: INVENTORY MOVEMENT SUMMARY
-- =====================================================

SELECT
    SUM(CASE
        WHEN transaction_type IN ('INBOUND', 'RETURN')
        THEN quantity
        ELSE 0
    END) AS total_stock_in,

    SUM(CASE
        WHEN transaction_type IN ('OUTBOUND', 'DAMAGE')
        THEN quantity
        ELSE 0
    END) AS total_stock_out,

    SUM(CASE
        WHEN transaction_type IN ('INBOUND', 'RETURN')
        THEN quantity
        WHEN transaction_type IN ('OUTBOUND', 'DAMAGE')
        THEN -quantity
        ELSE 0
    END) AS net_inventory_movement

FROM inventory_transactions;

-- STEP 28: INVENTORY MOVEMENT BY WAREHOUSE

SELECT
    warehouse_id,

    SUM(CASE
        WHEN transaction_type IN ('INBOUND', 'RETURN')
        THEN quantity
        ELSE 0
    END) AS stock_in,

    SUM(CASE
        WHEN transaction_type IN ('OUTBOUND', 'DAMAGE')
        THEN quantity
        ELSE 0
    END) AS stock_out,

    SUM(CASE
        WHEN transaction_type IN ('INBOUND', 'RETURN')
        THEN quantity
        WHEN transaction_type IN ('OUTBOUND', 'DAMAGE')
        THEN -quantity
        ELSE 0
    END) AS net_movement

FROM inventory_transactions
GROUP BY warehouse_id
ORDER BY warehouse_id;

SELECT DISTINCT
    warehouse_id
FROM inventory_transactions
ORDER BY warehouse_id;

-- STEP 29: ESTIMATED CLOSING INVENTORY BY WAREHOUSE

WITH opening_stock AS (
    SELECT
        warehouse_id,
        SUM(opening_qty) AS opening_qty
    FROM opening_inventory
    GROUP BY warehouse_id
),
movement AS (
    SELECT
        warehouse_id,
        SUM(
            CASE
                WHEN transaction_type IN ('INBOUND', 'RETURN')
                THEN quantity
                WHEN transaction_type IN ('OUTBOUND', 'DAMAGE')
                THEN -quantity
                ELSE 0
            END
        ) AS net_movement
    FROM inventory_transactions
    GROUP BY warehouse_id
)
SELECT
    o.warehouse_id,
    o.opening_qty,
    m.net_movement,
    o.opening_qty + m.net_movement AS estimated_closing_qty
FROM opening_stock o
JOIN movement m
    ON o.warehouse_id = m.warehouse_id
ORDER BY o.warehouse_id;

-- STEP 30: PRODUCT-WAREHOUSE CLOSING STOCK VALIDATION

WITH movement AS (
    SELECT
        warehouse_id,
        product_id,
        SUM(
            CASE
                WHEN transaction_type IN ('INBOUND', 'RETURN')
                    THEN quantity
                WHEN transaction_type IN ('OUTBOUND', 'DAMAGE')
                    THEN -quantity
                ELSE 0
            END
        ) AS net_movement
    FROM inventory_transactions
    GROUP BY warehouse_id, product_id
),
closing_stock AS (
    SELECT
        oi.warehouse_id,
        oi.product_id,
        oi.opening_qty,
        COALESCE(m.net_movement, 0) AS net_movement,
        oi.opening_qty + COALESCE(m.net_movement, 0)
            AS closing_qty
    FROM opening_inventory oi
    LEFT JOIN movement m
        ON oi.warehouse_id = m.warehouse_id
       AND oi.product_id = m.product_id
)
SELECT
    COUNT(*) AS total_combinations,
    COUNT(*) FILTER (WHERE closing_qty < 0)
        AS negative_closing_stock,
    COUNT(*) FILTER (WHERE closing_qty = 0)
        AS zero_closing_stock,
    MIN(closing_qty) AS minimum_closing_stock,
    MAX(closing_qty) AS maximum_closing_stock,
    SUM(closing_qty) AS total_closing_stock
FROM closing_stock;

-- STEP 31: MONTHLY INVENTORY MOVEMENT ANALYSIS

SELECT
    DATE_TRUNC('month', transaction_date)::date
        AS transaction_month,

    SUM(CASE
        WHEN transaction_type IN ('INBOUND', 'RETURN')
        THEN quantity
        ELSE 0
    END) AS stock_in,

    SUM(CASE
        WHEN transaction_type IN ('OUTBOUND', 'DAMAGE')
        THEN quantity
        ELSE 0
    END) AS stock_out,

    SUM(CASE
        WHEN transaction_type IN ('INBOUND', 'RETURN')
        THEN quantity
        WHEN transaction_type IN ('OUTBOUND', 'DAMAGE')
        THEN -quantity
        ELSE 0
    END) AS net_movement

FROM inventory_transactions
GROUP BY DATE_TRUNC('month', transaction_date)
ORDER BY transaction_month;

-- STEP 32: JANUARY TRANSACTION BREAKDOWN

SELECT
    transaction_type,
    COUNT(*) AS total_transactions,
    SUM(quantity) AS total_quantity
FROM inventory_transactions
WHERE transaction_date >= '2025-01-01'
  AND transaction_date < '2025-02-01'
GROUP BY transaction_type
ORDER BY total_quantity DESC;

-- STEP 33: JANUARY INVENTORY MOVEMENT BY WAREHOUSE

SELECT
    warehouse_id,

    SUM(
        CASE
            WHEN transaction_type IN ('INBOUND', 'RETURN')
                THEN quantity
            ELSE 0
        END
    ) AS stock_in,

    SUM(
        CASE
            WHEN transaction_type IN ('OUTBOUND', 'DAMAGE')
                THEN quantity
            ELSE 0
        END
    ) AS stock_out,

    SUM(
        CASE
            WHEN transaction_type IN ('INBOUND', 'RETURN')
                THEN quantity
            WHEN transaction_type IN ('OUTBOUND', 'DAMAGE')
                THEN -quantity
            ELSE 0
        END
    ) AS net_movement

FROM inventory_transactions
WHERE transaction_date >= '2025-01-01'
  AND transaction_date < '2025-02-01'
GROUP BY warehouse_id
ORDER BY warehouse_id;

-- STEP 34: VERIFY OPENING INVENTORY SNAPSHOT DATE

SELECT
    MIN(snapshot_date) AS earliest_snapshot,
    MAX(snapshot_date) AS latest_snapshot,
    COUNT(DISTINCT snapshot_date) AS snapshot_dates,
    COUNT(*) AS total_records
FROM opening_inventory;

-- STEP 35: ESTIMATED JANUARY CLOSING STOCK BY WAREHOUSE

WITH opening_stock AS (
    SELECT
        warehouse_id,
        SUM(opening_qty) AS opening_qty
    FROM opening_inventory
    GROUP BY warehouse_id
),
january_movement AS (
    SELECT
        warehouse_id,
        SUM(
            CASE
                WHEN transaction_type IN ('INBOUND', 'RETURN')
                    THEN quantity
                WHEN transaction_type IN ('OUTBOUND', 'DAMAGE')
                    THEN -quantity
                ELSE 0
            END
        ) AS net_movement
    FROM inventory_transactions
    WHERE transaction_date >= '2025-01-01'
      AND transaction_date < '2025-02-01'
    GROUP BY warehouse_id
)
SELECT
    o.warehouse_id,
    o.opening_qty,
    COALESCE(j.net_movement, 0) AS january_net_movement,
    o.opening_qty + COALESCE(j.net_movement, 0)
        AS january_closing_qty
FROM opening_stock o
LEFT JOIN january_movement j
    ON o.warehouse_id = j.warehouse_id
ORDER BY o.warehouse_id;


-- ============================================================
-- PHASE 03 - PART 03: SALES PERFORMANCE & PROFITABILITY ANALYSIS
-- Dataset: PT Nusantara Distribution 2025
-- ============================================================

-- STEP 36: SALES PERFORMANCE OVERVIEW 2025
-- Business Objective:
-- Measure total sales records, units sold, and gross revenue
-- during the 2025 reporting period.

SELECT
    COUNT(*) AS total_sales_records,
    SUM(quantity) AS total_units_sold,
    SUM(quantity * unit_price) AS gross_sales
FROM sales
WHERE sales_date >= DATE '2025-01-01'
    AND sales_date < DATE '2026-01-01';

-- Validated Results:
-- Total Sales Records : 28,169
-- Total Units Sold    : 209,924
-- Gross Sales         : IDR 4,182,694,000.00
--
-- Business Insight:
-- The company recorded 209,924 units sold during 2025,
-- generating IDR 4.18 billion in gross sales before discounts.
-- Sales records represent table rows, not necessarily
-- unique customer orders.

-- ============================================================
-- STEP 37: GROSS SALES, DISCOUNT AMOUNT & NET SALES
-- ============================================================

-- Business Objective:
-- Calculate gross revenue, total discounts, and net revenue
-- during the 2025 reporting period.

SELECT
    SUM(quantity * unit_price) AS gross_sales,
    SUM(
        quantity * unit_price * discount_pct / 100
    ) AS discount_amount,
    SUM(
        quantity * unit_price * (1 - discount_pct / 100)
    ) AS net_sales
FROM sales
WHERE sales_date >= DATE '2025-01-01'
    AND sales_date < DATE '2026-01-01';

-- Validated Results:
-- Gross Sales     : IDR 4,182,694,000.00
-- Discount Amount : IDR    74,524,550.00
-- Net Sales       : IDR 4,108,169,450.00
--
-- Validation:
-- Gross Sales - Discount Amount = Net Sales
-- IDR 4,182,694,000 - IDR 74,524,550
-- = IDR 4,108,169,450
--
-- Effective Discount Rate: 1.78%
--
-- Business Insight:
-- The company generated IDR 4.11 billion in net sales
-- after applying IDR 74.52 million in discounts.
-- Discounts represented approximately 1.78% of gross sales.
-- Net sales do not represent net profit.

-- ============================================================
-- STEP 38: TOP 10 PRODUCTS BY NET SALES
-- ============================================================

-- Business Objective:
-- Identify the ten products generating the highest net sales
-- during 2025, including sales volume and product category.

SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(s.quantity) AS total_units_sold,
    ROUND(
        SUM(
            s.quantity * s.unit_price
            * (1 - s.discount_pct / 100)
        ), 2
    ) AS net_sales
FROM sales AS s
JOIN products AS p
    ON s.product_id = p.product_id
WHERE s.sales_date >= DATE '2025-01-01'
    AND s.sales_date < DATE '2026-01-01'
GROUP BY
    p.product_id,
    p.product_name,
    p.category
ORDER BY net_sales DESC
LIMIT 10;

-- Validated Results:
-- Rank 1: Beras Premium 5kg
-- Net Sales  : IDR 611,580,750.00
-- Units Sold : 8,306
--
-- Rank 2: Minyak Goreng 1L
-- Net Sales  : IDR 236,246,940.00
-- Units Sold : 13,356
--
-- Rank 3: Detergen Bubuk 800g
-- Net Sales  : IDR 212,548,290.00
-- Units Sold : 9,412
--
-- Business Insight:
-- Beras Premium 5kg generated the highest net sales,
-- contributing approximately 14.89% of company net sales.
-- Minyak Goreng 1L sold more units but generated less revenue.
-- High sales volume does not necessarily mean high revenue.

-- ============================================================
-- STEP 39: SALES-PRODUCT RECONCILIATION
-- ============================================================

-- Business Objective:
-- Verify that all 2025 sales records have matching
-- product references before performing product-level analysis.

SELECT
    COUNT(*) AS unmatched_sales_records,
    COALESCE(SUM(s.quantity), 0) AS unmatched_units,
    COALESCE(
        SUM(
            s.quantity * s.unit_price
            * (1 - s.discount_pct / 100)
        ), 0
    ) AS unmatched_net_sales
FROM sales AS s
LEFT JOIN products AS p
    ON s.product_id = p.product_id
WHERE s.sales_date >= DATE '2025-01-01'
    AND s.sales_date < DATE '2026-01-01'
    AND p.product_id IS NULL;

-- Validated Results:
-- Unmatched Sales Records : 0
-- Unmatched Units         : 0
-- Unmatched Net Sales     : IDR 0.00
--
-- Validation:
-- All 2025 sales records have matching product references.
-- No sales records were excluded due to missing product IDs.
--
-- Business Insight:
-- Product reference completeness supports reliable
-- product-level sales aggregation and reporting.
-- This check does not independently verify that
-- product IDs are unique in the products table.

-- ============================================================
-- STEP 40: SALES PERFORMANCE BY PRODUCT CATEGORY
-- ============================================================

-- Business Objective:
-- Analyze sales records, sales volume, and net revenue
-- across product categories during 2025.

SELECT
    p.category,
    COUNT(*) AS total_sales_records,
    SUM(s.quantity) AS total_units_sold,
    ROUND(
        SUM(
            s.quantity * s.unit_price
            * (1 - s.discount_pct / 100)
        ), 2
    ) AS net_sales
FROM sales AS s
JOIN products AS p
    ON s.product_id = p.product_id
WHERE s.sales_date >= DATE '2025-01-01'
    AND s.sales_date < DATE '2026-01-01'
GROUP BY p.category
ORDER BY net_sales DESC;

-- Validated Results:
-- Food & Beverage:
-- Records   : 8,315
-- Units     : 85,014
-- Net Sales : IDR 1,550,716,430.00
--
-- Home Care:
-- Records   : 6,848
-- Units     : 48,085
-- Net Sales : IDR 919,456,660.00
--
-- Household:
-- Records   : 5,683
-- Units     : 25,548
-- Net Sales : IDR 824,882,580.00
--
-- Personal Care:
-- Records   : 7,323
-- Units     : 51,277
-- Net Sales : IDR 813,113,780.00
--
-- Reconciliation:
-- Total Sales Records : 28,169
-- Total Units Sold    : 209,924
-- Total Net Sales     : IDR 4,108,169,450.00
--
-- Business Insight:
-- Food & Beverage contributed approximately 37.75%
-- of total company net sales and recorded the highest
-- sales volume at 85,014 units.
-- Household generated higher revenue than Personal Care
-- despite selling substantially fewer units.

-- ============================================================
-- STEP 41: AVERAGE NET SALES PER UNIT BY CATEGORY
-- ============================================================

-- Business Objective:
-- Measure the average net revenue generated per unit sold
-- across product categories during 2025.

SELECT
    p.category,
    SUM(s.quantity) AS total_units_sold,
    ROUND(
        SUM(
            s.quantity * s.unit_price
            * (1 - s.discount_pct / 100)
        ) / NULLIF(SUM(s.quantity), 0),
        2
    ) AS avg_net_sales_per_unit
FROM sales AS s
JOIN products AS p
    ON s.product_id = p.product_id
WHERE s.sales_date >= DATE '2025-01-01'
    AND s.sales_date < DATE '2026-01-01'
GROUP BY p.category
ORDER BY avg_net_sales_per_unit DESC;

-- Validated Results:
-- Household       : IDR 32,287.56 per unit
-- Home Care       : IDR 19,121.49 per unit
-- Food & Beverage : IDR 18,240.72 per unit
-- Personal Care   : IDR 15,857.28 per unit
--
-- Business Insight:
-- Household generated the highest average net revenue
-- per unit sold, despite having the lowest sales volume.
--
-- Food & Beverage relied more heavily on sales volume
-- to generate the highest total net revenue.
--
-- Higher revenue per unit does not necessarily indicate
-- higher profitability, since product costs must also
-- be considered.

-- ============================================================
-- STEP 42: ESTIMATED GROSS PROFIT BY CATEGORY
-- ============================================================

-- Business Objective:
-- Estimate gross profit by product category using
-- recorded net sales and reference product unit costs.

SELECT
    p.category,
    ROUND(
        SUM(
            s.quantity * s.unit_price
            * (1 - s.discount_pct / 100)
        ), 2
    ) AS net_sales,
    ROUND(
        SUM(s.quantity * p.unit_cost), 2
    ) AS estimated_cogs,
    ROUND(
        SUM(
            s.quantity * s.unit_price
            * (1 - s.discount_pct / 100)
        ) - SUM(s.quantity * p.unit_cost),
        2
    ) AS estimated_gross_profit
FROM sales AS s
JOIN products AS p
    ON s.product_id = p.product_id
WHERE s.sales_date >= DATE '2025-01-01'
    AND s.sales_date < DATE '2026-01-01'
GROUP BY p.category
ORDER BY estimated_gross_profit DESC;

-- Validated Results:
-- Food & Beverage : IDR 257,020,430.00
-- Home Care       : IDR 219,111,660.00
-- Household       : IDR 207,290,580.00
-- Personal Care   : IDR 206,068,780.00
--
-- Total Net Sales              : IDR 4,108,169,450.00
-- Total Estimated COGS         : IDR 3,218,678,000.00
-- Total Estimated Gross Profit : IDR   889,491,450.00
--
-- Reconciliation:
-- Net Sales - Estimated COGS = Estimated Gross Profit
--
-- Business Insight:
-- Food & Beverage generated the highest estimated
-- gross profit in absolute monetary terms.
--
-- However, higher gross profit does not necessarily
-- indicate a higher gross profit margin.
--
-- Methodology Limitation:
-- Estimated COGS uses products.unit_cost as a reference.
-- Historical purchase costs, cost adjustments, and
-- inventory valuation methods have not been validated.
-- Therefore, gross profit is an estimate rather than
-- an audited financial result.

-- ============================================================
-- STEP 43: ESTIMATED GROSS MARGIN BY CATEGORY
-- ============================================================

-- Business Objective:
-- Compare estimated gross profit margins across product
-- categories to identify relative profitability.

SELECT
    p.category,
    ROUND(
        SUM(
            s.quantity * s.unit_price
            * (1 - s.discount_pct / 100)
        ) - SUM(s.quantity * p.unit_cost),
        2
    ) AS estimated_gross_profit,
    ROUND(
        (
            SUM(
                s.quantity * s.unit_price
                * (1 - s.discount_pct / 100)
            ) - SUM(s.quantity * p.unit_cost)
        )
        / NULLIF(
            SUM(
                s.quantity * s.unit_price
                * (1 - s.discount_pct / 100)
            ), 0
        ) * 100,
        2
    ) AS estimated_gross_margin_pct
FROM sales AS s
JOIN products AS p
    ON s.product_id = p.product_id
WHERE s.sales_date >= DATE '2025-01-01'
    AND s.sales_date < DATE '2026-01-01'
GROUP BY p.category
ORDER BY estimated_gross_margin_pct DESC;

-- Validated Results:
-- Personal Care   : 25.34%
-- Household       : 25.13%
-- Home Care       : 23.83%
-- Food & Beverage : 16.57%
--
-- Total Estimated Gross Profit : IDR 889,491,450.00
-- Company Estimated Gross Margin: 21.65%
--
-- Business Insight:
-- Personal Care recorded the highest estimated
-- gross margin at 25.34%, despite generating
-- the lowest total net sales.
--
-- Food & Beverage generated the highest total
-- revenue and estimated gross profit, but had
-- the lowest estimated gross margin at 16.57%.
--
-- This demonstrates that revenue leadership
-- does not necessarily indicate margin leadership.
--
-- Methodology Limitation:
-- Gross margins are estimated using reference
-- product unit costs, not validated historical COGS.
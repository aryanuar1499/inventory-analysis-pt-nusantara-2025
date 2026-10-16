-- ============================================================
-- PROJECT 01: INVENTORY ANALYSIS
-- PT NUSANTARA DISTRIBUTION | 2025
-- PHASE 04: INVENTORY KPI & STOCK PERFORMANCE ANALYSIS
-- ============================================================

-- Purpose:
-- Calculate inventory KPIs and evaluate stock performance
-- across products and warehouses during 2025.
--
-- Data Period: 2025-01-01 to 2025-12-31
-- Database: PostgreSQL
--
-- ============================================================
-- SECTION 01: INVENTORY VALUATION
-- ============================================================

-- 1.1 Opening Inventory Value
-- Calculate the total opening stock quantity and inventory
-- value using the unit cost of each product.

SELECT
    SUM(oi.opening_qty) AS total_opening_stock,
    SUM(oi.opening_qty * p.unit_cost) AS opening_inventory_value
FROM opening_inventory oi
JOIN products p
    ON oi.product_id = p.product_id;

-- 1.2 Closing Inventory Value
-- Reconstruct ending inventory from opening stock
-- and net inventory movements throughout 2025.

WITH stock_movement AS (
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
    GROUP BY
        warehouse_id,
        product_id
),
closing_inventory AS (
    SELECT
        oi.warehouse_id,
        oi.product_id,
        oi.opening_qty
            + COALESCE(sm.net_movement, 0) AS closing_qty
    FROM opening_inventory oi
    LEFT JOIN stock_movement sm
        ON oi.warehouse_id = sm.warehouse_id
        AND oi.product_id = sm.product_id
)
SELECT
    SUM(ci.closing_qty) AS total_closing_stock,
    SUM(ci.closing_qty * p.unit_cost) AS closing_inventory_value
FROM closing_inventory ci
JOIN products p
    ON ci.product_id = p.product_id;

-- 1.3 Average Inventory Value
-- Calculate the average inventory value using
-- opening and closing inventory valuations.
-- This is a two-point average, not a daily average.
-- Version 1: Initial calculation using validated fixed values (Learning Reference).

WITH inventory_values AS (
    SELECT
        350900000::numeric AS opening_inventory_value,
        209516500::numeric AS closing_inventory_value
)
SELECT
    opening_inventory_value,
    closing_inventory_value,
    ROUND(
        (opening_inventory_value + closing_inventory_value) / 2,
        2
    ) AS average_inventory_value
FROM inventory_values;

-- 1.3 Average Inventory Value
-- Calculate the average of opening and closing inventory
-- values dynamically from source tables.
-- Assumption: Product unit costs remain constant in 2025.
-- Version 2: Final dynamic calculation from source tables (Final).

WITH stock_movement AS (
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
    WHERE transaction_date BETWEEN '2025-01-01' AND '2025-12-31'
    GROUP BY
        warehouse_id,
        product_id
),
inventory_values AS (
    SELECT
        SUM(oi.opening_qty * p.unit_cost)
            AS opening_inventory_value,
        SUM(
            (oi.opening_qty + COALESCE(sm.net_movement, 0))
            * p.unit_cost
        ) AS closing_inventory_value
    FROM opening_inventory oi
    JOIN products p
        ON oi.product_id = p.product_id
    LEFT JOIN stock_movement sm
        ON oi.warehouse_id = sm.warehouse_id
        AND oi.product_id = sm.product_id
)
SELECT
    opening_inventory_value,
    closing_inventory_value,
    ROUND(
        (opening_inventory_value + closing_inventory_value) / 2,
        2
    ) AS average_inventory_value
FROM inventory_values;

-- ============================================================
-- SECTION 02: INVENTORY PERFORMANCE KPIs
-- ============================================================

-- 2.1 Estimated Cost of Goods Sold (COGS)
-- Estimate the cost of products sold during 2025
-- using sales quantity and product unit cost.
-- Assumption: Unit costs remain constant throughout 2025.

SELECT
    COUNT(*) AS total_sales_transactions,
    SUM(s.quantity) AS total_units_sold,
    SUM(s.quantity * p.unit_cost) AS estimated_cogs
FROM sales s
JOIN products p
    ON s.product_id = p.product_id
WHERE s.sales_date BETWEEN '2025-01-01' AND '2025-12-31';

-- 2.2 Inventory Turnover Ratio
-- Measure estimated annual COGS relative to
-- the average opening and closing inventory value.
-- Assumption: Product unit costs remain constant in 2025.
-- Version 1: Initial Calculation (Learning Reference)

WITH estimated_cogs AS (
    SELECT
        SUM(s.quantity * p.unit_cost) AS cogs_value
    FROM sales s
    JOIN products p
        ON s.product_id = p.product_id
    WHERE s.sales_date BETWEEN '2025-01-01' AND '2025-12-31'
),
inventory_values AS (
    SELECT
        350900000::numeric AS opening_inventory_value,
        209516500::numeric AS closing_inventory_value
),
average_inventory AS (
    SELECT
        (opening_inventory_value + closing_inventory_value) / 2
            AS average_inventory_value
    FROM inventory_values
)
SELECT
    ROUND(ec.cogs_value, 2) AS estimated_cogs,
    ROUND(ai.average_inventory_value, 2) AS average_inventory_value,
    ROUND(
        ec.cogs_value / NULLIF(ai.average_inventory_value, 0),
        2
    ) AS inventory_turnover_ratio
FROM estimated_cogs ec
CROSS JOIN average_inventory ai;

-- 2.2 Inventory Turnover Ratio
-- Calculate annual inventory turnover using estimated COGS
-- and dynamically calculated average inventory value.
-- Assumption: Product unit costs remain constant in 2025.
-- Version 2: Dynamic Calculation (Final)

WITH stock_movement AS (
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
    WHERE transaction_date BETWEEN '2025-01-01' AND '2025-12-31'
    GROUP BY
        warehouse_id,
        product_id
),
inventory_values AS (
    SELECT
        SUM(oi.opening_qty * p.unit_cost)
            AS opening_inventory_value,
        SUM(
            (oi.opening_qty + COALESCE(sm.net_movement, 0))
            * p.unit_cost
        ) AS closing_inventory_value
    FROM opening_inventory oi
    JOIN products p
        ON oi.product_id = p.product_id
    LEFT JOIN stock_movement sm
        ON oi.warehouse_id = sm.warehouse_id
        AND oi.product_id = sm.product_id
),
average_inventory AS (
    SELECT
        (opening_inventory_value + closing_inventory_value) / 2
            AS average_inventory_value
    FROM inventory_values
),
estimated_cogs AS (
    SELECT
        SUM(s.quantity * p.unit_cost) AS cogs_value
    FROM sales s
    JOIN products p
        ON s.product_id = p.product_id
    WHERE s.sales_date BETWEEN '2025-01-01' AND '2025-12-31'
)
SELECT
    ROUND(ec.cogs_value, 2) AS estimated_cogs,
    ROUND(ai.average_inventory_value, 2) AS average_inventory_value,
    ROUND(
        ec.cogs_value / NULLIF(ai.average_inventory_value, 0),
        2
    ) AS inventory_turnover_ratio
FROM estimated_cogs ec
CROSS JOIN average_inventory ai;

-- 2.3 Days Inventory Outstanding (DIO)
-- Estimate inventory holding days based on annual COGS
-- and the average opening and closing inventory value.
-- Assumption: Product unit costs remain constant in 2025.
-- Version 1: Initial Calculation (Learning Reference)

WITH estimated_cogs AS (
    SELECT
        SUM(s.quantity * p.unit_cost) AS cogs_value
    FROM sales s
    JOIN products p
        ON s.product_id = p.product_id
    WHERE s.sales_date BETWEEN '2025-01-01' AND '2025-12-31'
),
inventory_values AS (
    SELECT
        350900000::numeric AS opening_inventory_value,
        209516500::numeric AS closing_inventory_value
),
average_inventory AS (
    SELECT
        (opening_inventory_value + closing_inventory_value) / 2
            AS average_inventory_value
    FROM inventory_values
)
SELECT
    ROUND(ai.average_inventory_value, 2) AS average_inventory_value,
    ROUND(ec.cogs_value, 2) AS estimated_cogs,
    ROUND(
        ai.average_inventory_value * 365
        / NULLIF(ec.cogs_value, 0),
        2
    ) AS dio_days
FROM average_inventory ai
CROSS JOIN estimated_cogs ec;

-- 2.3 Days Inventory Outstanding (DIO)
-- Estimate inventory holding days using annual COGS
-- and dynamically calculated average inventory value.
-- Assumption: Product unit costs remain constant in 2025.
-- Version 2: Dynamic Calculation (Final)

WITH stock_movement AS (
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
    WHERE transaction_date BETWEEN '2025-01-01' AND '2025-12-31'
    GROUP BY
        warehouse_id,
        product_id
),
inventory_values AS (
    SELECT
        SUM(oi.opening_qty * p.unit_cost)
            AS opening_inventory_value,
        SUM(
            (oi.opening_qty + COALESCE(sm.net_movement, 0))
            * p.unit_cost
        ) AS closing_inventory_value
    FROM opening_inventory oi
    JOIN products p
        ON oi.product_id = p.product_id
    LEFT JOIN stock_movement sm
        ON oi.warehouse_id = sm.warehouse_id
        AND oi.product_id = sm.product_id
),
average_inventory AS (
    SELECT
        (opening_inventory_value + closing_inventory_value) / 2
            AS average_inventory_value
    FROM inventory_values
),
estimated_cogs AS (
    SELECT
        SUM(s.quantity * p.unit_cost) AS cogs_value
    FROM sales s
    JOIN products p
        ON s.product_id = p.product_id
    WHERE s.sales_date BETWEEN '2025-01-01' AND '2025-12-31'
)
SELECT
    ROUND(ai.average_inventory_value, 2) AS average_inventory_value,
    ROUND(ec.cogs_value, 2) AS estimated_cogs,
    ROUND(
        ai.average_inventory_value * 365
        / NULLIF(ec.cogs_value, 0),
        2
    ) AS dio_days
FROM average_inventory ai
CROSS JOIN estimated_cogs ec;

-- ============================================================
-- SECTION 03: DAILY INVENTORY RECONSTRUCTION
-- ============================================================

-- 3.1 Daily Closing Stock Reconstruction
-- Reconstruct daily closing stock for every product-warehouse
-- combination, including days without inventory transactions.
-- Assumption: Opening stock is measured before Jan 1 movements.

/*CREATE OR REPLACE VIEW vw_daily_inventory_balance AS*/ --Add Reusable Daily Inventory View
WITH calendar AS (
    SELECT
        generate_series(
            '2025-01-01'::date,
            '2025-12-31'::date,
            INTERVAL '1 day'
        )::date AS stock_date
),
daily_movement AS (
    SELECT
        transaction_date,
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
    WHERE transaction_date BETWEEN '2025-01-01' AND '2025-12-31'
    GROUP BY
        transaction_date,
        warehouse_id,
        product_id
),
daily_stock AS (
    SELECT
        c.stock_date,
        oi.warehouse_id,
        oi.product_id,
        oi.opening_qty,
        COALESCE(dm.net_movement, 0) AS daily_net_movement
    FROM calendar c
    CROSS JOIN opening_inventory oi
    LEFT JOIN daily_movement dm
        ON c.stock_date = dm.transaction_date
        AND oi.warehouse_id = dm.warehouse_id
        AND oi.product_id = dm.product_id
),
daily_balance AS (
    SELECT
        stock_date,
        warehouse_id,
        product_id,
        opening_qty
            + SUM(daily_net_movement) OVER (
                PARTITION BY warehouse_id, product_id
                ORDER BY stock_date
                ROWS BETWEEN UNBOUNDED PRECEDING
                         AND CURRENT ROW
            ) AS daily_closing_stock
    FROM daily_stock
)
SELECT
    stock_date,
    warehouse_id,
    product_id,
    daily_closing_stock
FROM daily_balance
ORDER BY
    stock_date,
    warehouse_id,
    product_id;

-- ============================================================
-- SECTION 04: STOCK AVAILABILITY & STOCKOUT ANALYSIS
-- ============================================================

-- 4.1 Daily Stock Status Validation
-- Classify daily closing stock as positive, zero, or negative.
-- Each observation represents one product-warehouse-day.
--
-- Reuse the calendar, daily_movement, daily_stock,
-- and daily_balance CTEs from Section 03.

SELECT
    COUNT(*) AS total_stock_days,
    COUNT(*) FILTER (
        WHERE daily_closing_stock > 0
    ) AS positive_stock_days,
    COUNT(*) FILTER (
        WHERE daily_closing_stock = 0
    ) AS zero_stock_days,
    COUNT(*) FILTER (
        WHERE daily_closing_stock < 0
    ) AS negative_stock_days,
    MIN(daily_closing_stock) AS minimum_stock,
    MAX(daily_closing_stock) AS maximum_stock
FROM daily_balance;
/*FROM vw_daily_inventory_balance;*/ --Add Reusable Daily Inventory View

-- 4.2 Stockout Exposure by Product and Warehouse
-- Identify product-warehouse combinations with the highest
-- number of days with zero closing stock during 2025.
-- This measures end-of-day stockout exposure.

SELECT
    warehouse_id,
    product_id,
    COUNT(*) FILTER (
        WHERE daily_closing_stock = 0
    ) AS zero_stock_days,
    MIN(daily_closing_stock) AS minimum_stock,
    MAX(daily_closing_stock) AS maximum_stock
FROM vw_daily_inventory_balance
GROUP BY
    warehouse_id,
    product_id
HAVING COUNT(*) FILTER (
    WHERE daily_closing_stock = 0
) > 0
ORDER BY
    zero_stock_days DESC,
    warehouse_id,
    product_id
LIMIT 10;

-- 4.3 Stockout Episode Analysis
-- Identify how many separate zero-stock periods occurred
-- for each product-warehouse combination during 2025.
-- Consecutive zero-stock days count as one episode.

WITH stockout_flags AS (
    SELECT
        stock_date,
        warehouse_id,
        product_id,
        daily_closing_stock,
        LAG(daily_closing_stock) OVER (
            PARTITION BY warehouse_id, product_id
            ORDER BY stock_date
        ) AS previous_day_stock
    FROM vw_daily_inventory_balance
)
SELECT
    warehouse_id,
    product_id,
    COUNT(*) FILTER (
        WHERE daily_closing_stock = 0
    ) AS zero_stock_days,
    COUNT(*) FILTER (
        WHERE daily_closing_stock = 0
          AND (
              previous_day_stock > 0
              OR previous_day_stock IS NULL
          )
    ) AS stockout_episodes
FROM stockout_flags
GROUP BY
    warehouse_id,
    product_id
HAVING COUNT(*) FILTER (
    WHERE daily_closing_stock = 0
) > 0
ORDER BY
    zero_stock_days DESC,
    warehouse_id,
    product_id
LIMIT 10;

-- 4.4 Stockout Exposure by Warehouse
-- Measure the number and percentage of product-days
-- with zero closing stock in each warehouse during 2025.

SELECT
    warehouse_id,
    COUNT(*) AS total_stock_days,
    COUNT(*) FILTER (
        WHERE daily_closing_stock = 0
    ) AS zero_stock_days,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE daily_closing_stock = 0
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS zero_stock_rate_pct
FROM vw_daily_inventory_balance
GROUP BY warehouse_id
ORDER BY zero_stock_days DESC;

-- 4.5 Stock Availability Rate by Warehouse
-- Calculate the percentage of product-days with
-- positive end-of-day inventory in each warehouse.
-- This is not a customer order fulfillment rate.

SELECT
    warehouse_id,
    COUNT(*) AS total_stock_days,
    COUNT(*) FILTER (
        WHERE daily_closing_stock > 0
    ) AS positive_stock_days,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE daily_closing_stock > 0
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS stock_availability_rate_pct
FROM vw_daily_inventory_balance
GROUP BY warehouse_id
ORDER BY stock_availability_rate_pct DESC;

-- ============================================================
-- SECTION 05: PRODUCT-LEVEL INVENTORY PERFORMANCE
-- ============================================================

-- 5.1 Product-Level Inventory Valuation
-- Purpose:
-- Reconstruct opening and closing inventory quantities
-- for each product across all warehouses.
--
-- Validation:
-- Total products: 40
-- Opening inventory: 22,520 units
-- Closing inventory: 13,729 units
--
-- Note:
-- This analysis aggregates inventory by product_id.
-- Warehouse-level differences are not shown in this query.

WITH opening_stock AS (
    SELECT
        product_id,
        SUM(opening_qty) AS opening_quantity
    FROM opening_inventory
    GROUP BY product_id
),
inventory_movement AS (
    SELECT
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
    GROUP BY product_id
)
SELECT
    p.product_id,
    p.product_name,
    o.opening_quantity,
    COALESCE(m.net_movement, 0) AS net_movement,
    o.opening_quantity + COALESCE(m.net_movement, 0) AS closing_quantity,
    p.unit_cost
FROM products p
JOIN opening_stock o
    ON p.product_id = o.product_id
LEFT JOIN inventory_movement m
    ON p.product_id = m.product_id
ORDER BY p.product_id;

-- 5.2 Product-Level Inventory Turnover Analysis
--
-- 5.2A Estimated COGS by Product
-- Purpose:
-- Calculate estimated COGS and units sold for each product.
--
-- Validation:
-- Total products: 40
-- Total estimated COGS: IDR 3,218,678,000
--
-- Business Insight:
-- Higher sales volume does not necessarily mean higher COGS.
-- Product unit cost affects the total estimated COGS.
--
-- Note:
-- Estimated COGS uses a constant product unit_cost.
-- Products without sales are retained using LEFT JOIN.

SELECT
    p.product_id,
    p.product_name,
    p.category,
    COALESCE(SUM(s.quantity), 0) AS units_sold,
    p.unit_cost,
    COALESCE(SUM(s.quantity * p.unit_cost), 0) AS estimated_cogs
FROM products p
LEFT JOIN sales s
    ON p.product_id = s.product_id
GROUP BY
    p.product_id,
    p.product_name,
    p.category,
    p.unit_cost
ORDER BY estimated_cogs DESC;

-- 5.2B Average Inventory Value by Product
-- Purpose:
-- Calculate opening, closing, and average inventory values
-- for each product across all warehouses.
--
-- Validation:
-- Total products: 40
-- All calculated average inventory values are positive.
--
-- Reconciliation Targets:
-- Opening inventory value: IDR 350,900,000
-- Closing inventory value: IDR 209,516,500
-- Average inventory value: IDR 280,208,250
--
-- Methodology:
-- Average inventory value is calculated using the
-- opening and closing inventory values for 2025.
-- This is a two-point average, not a daily average.
--
-- Business Insight:
-- High inventory value does not necessarily indicate
-- slow-moving inventory. Inventory turnover analysis
-- is required to evaluate product-level efficiency.

WITH opening_stock AS (
    SELECT
        product_id,
        SUM(opening_qty) AS opening_quantity
    FROM opening_inventory
    GROUP BY product_id
),
inventory_movement AS (
    SELECT
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
    GROUP BY product_id
),
inventory_balance AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        o.opening_quantity,
        o.opening_quantity + COALESCE(m.net_movement, 0)
            AS closing_quantity,
        p.unit_cost
    FROM products p
    JOIN opening_stock o
        ON p.product_id = o.product_id
    LEFT JOIN inventory_movement m
        ON p.product_id = m.product_id
)
SELECT
    product_id,
    product_name,
    category,
    opening_quantity,
    closing_quantity,
    opening_quantity * unit_cost AS opening_inventory_value,
    closing_quantity * unit_cost AS closing_inventory_value,
    ROUND(
        (
            opening_quantity * unit_cost
            + closing_quantity * unit_cost
        ) / 2.0,
        2
    ) AS average_inventory_value
FROM inventory_balance
ORDER BY average_inventory_value DESC;

-- 5.2C Product-Level Inventory Turnover Calculation
-- Purpose:
-- Calculate annual inventory turnover for each product
-- using estimated COGS and average inventory value.
--
-- Validation:
-- Total products: 40
-- Highest turnover: P004 (16.32)
-- Lowest turnover: P028 (5.79)
--
-- Methodology:
-- Inventory Turnover = Estimated COGS / Average Inventory Value
-- Average inventory uses opening and closing values.
-- NULLIF prevents division by zero.
--
-- Business Insight:
-- Product-level turnover varies significantly.
-- Higher turnover indicates greater estimated COGS
-- relative to average inventory investment.
--
-- Note:
-- Turnover classifications require defined thresholds.
-- High turnover alone does not prove optimal inventory
-- performance or customer service levels.

WITH opening_stock AS (
    SELECT
        product_id,
        SUM(opening_qty) AS opening_quantity
    FROM opening_inventory
    GROUP BY product_id
),
inventory_movement AS (
    SELECT
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
    GROUP BY product_id
),
inventory_balance AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        o.opening_quantity,
        o.opening_quantity + COALESCE(m.net_movement, 0)
            AS closing_quantity,
        p.unit_cost
    FROM products p
    JOIN opening_stock o
        ON p.product_id = o.product_id
    LEFT JOIN inventory_movement m
        ON p.product_id = m.product_id
),
average_inventory AS (
    SELECT
        product_id,
        product_name,
        category,
        ROUND(
            (
                opening_quantity * unit_cost
                + closing_quantity * unit_cost
            ) / 2.0,
            2
        ) AS average_inventory_value
    FROM inventory_balance
),
product_cogs AS (
    SELECT
        p.product_id,
        COALESCE(SUM(s.quantity * p.unit_cost), 0)
            AS estimated_cogs
    FROM products p
    LEFT JOIN sales s
        ON p.product_id = s.product_id
    GROUP BY p.product_id
)
SELECT
    a.product_id,
    a.product_name,
    a.category,
    c.estimated_cogs,
    a.average_inventory_value,
    ROUND(
        c.estimated_cogs
        / NULLIF(a.average_inventory_value, 0),
        2
    ) AS inventory_turnover
FROM average_inventory a
JOIN product_cogs c
    ON a.product_id = c.product_id
ORDER BY inventory_turnover DESC NULLS LAST;

-- ============================================================
-- 5.2D Product-Level Inventory Turnover Reconciliation
-- ============================================================
-- Purpose:
-- Reconcile product-level estimated COGS and average
-- inventory values with company-level inventory KPIs.
--
-- Validation Results:
-- Total products: 40
-- Total estimated COGS: IDR 3,218,678,000
-- Total average inventory value: IDR 280,208,250
-- Reconciled inventory turnover: 11.49
--
-- Methodology:
-- Company-level turnover is calculated by dividing
-- total estimated COGS by total average inventory value.
-- Individual product turnover ratios are not averaged.
--
-- Business Insight:
-- Product-level financial calculations reconcile with
-- company-level inventory performance indicators.

WITH opening_value AS (
    SELECT
        SUM(o.opening_qty * p.unit_cost) AS total_opening_value
    FROM opening_inventory o
    JOIN products p
        ON o.product_id = p.product_id
),
closing_value AS (
    SELECT
        SUM(
            (o.opening_qty + COALESCE(m.net_movement, 0))
            * p.unit_cost
        ) AS total_closing_value
    FROM opening_inventory o
    JOIN products p
        ON o.product_id = p.product_id
    LEFT JOIN (
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
    ) m
        ON o.warehouse_id = m.warehouse_id
       AND o.product_id = m.product_id
),
total_cogs AS (
    SELECT
        SUM(s.quantity * p.unit_cost) AS estimated_cogs
    FROM sales s
    JOIN products p
        ON s.product_id = p.product_id
)
SELECT
    ov.total_opening_value,
    cv.total_closing_value,
    ROUND(
        (ov.total_opening_value + cv.total_closing_value) / 2.0,
        2
    ) AS average_inventory_value,
    tc.estimated_cogs,
    ROUND(
        tc.estimated_cogs
        / NULLIF(
            (ov.total_opening_value + cv.total_closing_value) / 2.0,
            0
        ),
        2
    ) AS inventory_turnover
FROM opening_value ov
CROSS JOIN closing_value cv
CROSS JOIN total_cogs tc;

-- ============================================================
-- SQL 5.2C - PRODUCT-LEVEL INVENTORY TURNOVER
-- ============================================================

-- Version 1: Product-Level Turnover Calculation
-- Purpose: Calculate inventory turnover for each product.

-- [Query SQL 5.2C yang sudah berhasil dijalankan]


-- ============================================================
-- SQL 5.2D - INVENTORY TURNOVER RECONCILIATION
-- ============================================================

-- Version 1: Company-Level KPI Validation
-- Purpose: Validate inventory KPIs directly from source tables.



-- Version 2: Product-Level KPI Reconciliation
-- Purpose: Reconcile aggregated product-level results
--          with company-level inventory KPIs.

WITH opening_stock AS (
    SELECT
        product_id,
        SUM(opening_qty) AS opening_quantity
    FROM opening_inventory
    GROUP BY product_id
),
inventory_movement AS (
    SELECT
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
    GROUP BY product_id
),
inventory_balance AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        o.opening_quantity,
        o.opening_quantity + COALESCE(m.net_movement, 0)
            AS closing_quantity,
        p.unit_cost
    FROM products p
    JOIN opening_stock o
        ON p.product_id = o.product_id
    LEFT JOIN inventory_movement m
        ON p.product_id = m.product_id
),
average_inventory AS (
    SELECT
        product_id,
        product_name,
        category,
        ROUND(
            (
                opening_quantity * unit_cost
                + closing_quantity * unit_cost
            ) / 2.0,
            2
        ) AS average_inventory_value
    FROM inventory_balance
),
product_cogs AS (
    SELECT
        p.product_id,
        COALESCE(SUM(s.quantity * p.unit_cost), 0)
            AS estimated_cogs
    FROM products p
    LEFT JOIN sales s
        ON p.product_id = s.product_id
    GROUP BY p.product_id
),

product_turnover AS (
    SELECT
        a.product_id,
        c.estimated_cogs,
        a.average_inventory_value
    FROM average_inventory a
    JOIN product_cogs c
        ON a.product_id = c.product_id
)

SELECT
    COUNT(*) AS total_products,
    SUM(estimated_cogs) AS total_estimated_cogs,
    SUM(average_inventory_value) AS total_average_inventory_value,
    ROUND(
        SUM(estimated_cogs)
        / NULLIF(SUM(average_inventory_value), 0),
        2
    ) AS reconciled_inventory_turnover
FROM product_turnover;

-- ============================================================
-- SQL 5.3A - INVENTORY MOVEMENT CLASSIFICATION
-- ============================================================
-- Purpose:
-- Classify products into Fast-Moving, Medium-Moving,
-- and Slow-Moving groups based on inventory turnover.
--
-- Methodology:
-- NTILE(4) divides 40 products into four equal groups
-- ordered by annual inventory turnover descending.
--
-- Quartile 1: Fast-Moving
-- Quartile 2-3: Medium-Moving
-- Quartile 4: Slow-Moving
--
-- Validation Results:
-- Total products: 40
-- Fast-Moving: 10 products
-- Medium-Moving: 20 products
-- Slow-Moving: 10 products
--
-- Business Insight:
-- Slow-moving products may require inventory review
-- because capital can remain tied up in stock.
-- However, slow-moving does not necessarily mean
-- unprofitable.
--
-- Limitation:
-- Classification is relative to this dataset and
-- does not represent universal industry thresholds.

WITH product_turnover AS (
                        WITH opening_stock AS (
                        SELECT
                            product_id,
                            SUM(opening_qty) AS opening_quantity
                        FROM opening_inventory
                        GROUP BY product_id
                    ),
                    inventory_movement AS (
                        SELECT
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
                        GROUP BY product_id
                    ),
                    inventory_balance AS (
                        SELECT
                            p.product_id,
                            p.product_name,
                            p.category,
                            o.opening_quantity,
                            o.opening_quantity + COALESCE(m.net_movement, 0)
                                AS closing_quantity,
                            p.unit_cost
                        FROM products p
                        JOIN opening_stock o
                            ON p.product_id = o.product_id
                        LEFT JOIN inventory_movement m
                            ON p.product_id = m.product_id
                    ),
                    average_inventory AS (
                        SELECT
                            product_id,
                            product_name,
                            category,
                            ROUND(
                                (
                                    opening_quantity * unit_cost
                                    + closing_quantity * unit_cost
                                ) / 2.0,
                                2
                            ) AS average_inventory_value
                        FROM inventory_balance
                    ),
                    product_cogs AS (
                        SELECT
                            p.product_id,
                            COALESCE(SUM(s.quantity * p.unit_cost), 0)
                                AS estimated_cogs
                        FROM products p
                        LEFT JOIN sales s
                            ON p.product_id = s.product_id
                        GROUP BY p.product_id
                    )
                    SELECT
                        a.product_id,
                        a.product_name,
                        a.category,
                        c.estimated_cogs,
                        a.average_inventory_value,
                        ROUND(
                            c.estimated_cogs
                            / NULLIF(a.average_inventory_value, 0),
                            2
                        ) AS inventory_turnover
                    FROM average_inventory a
                    JOIN product_cogs c
                        ON a.product_id = c.product_id
),
ranked_products AS (
    SELECT
        product_id,
        product_name,
        category,
        inventory_turnover,
        NTILE(4) OVER (
            ORDER BY inventory_turnover DESC, product_id
        ) AS turnover_quartile
    FROM product_turnover
)
SELECT
    product_id,
    product_name,
    category,
    inventory_turnover,
    turnover_quartile,
    CASE
        WHEN turnover_quartile = 1 THEN 'Fast-Moving'
        WHEN turnover_quartile IN (2, 3) THEN 'Medium-Moving'
        ELSE 'Slow-Moving'
    END AS movement_classification
FROM ranked_products
ORDER BY inventory_turnover DESC, product_id;

-- ============================================================
-- SQL 5.3B - MOVEMENT CLASSIFICATION SUMMARY
-- ============================================================
-- Purpose:
-- Analyze estimated COGS and average inventory value
-- contribution by inventory movement classification.
--
-- Methodology:
-- Group products into Fast, Medium, and Slow-Moving
-- based on NTILE(4) ranking of inventory turnover.
-- Calculate total estimated COGS, average inventory
-- value, and percentage contribution per group.
--
-- Validation Results:
-- Total products: 40
-- Total estimated COGS: IDR 3,218,678,000
-- Total average inventory value: IDR 280,208,250
--
-- Fast-Moving:
-- 10 products | COGS: 45.29% | Inventory Value: 33.89%
--
-- Medium-Moving:
-- 20 products | COGS: 37.14% | Inventory Value: 39.53%
--
-- Slow-Moving:
-- 10 products | COGS: 17.57% | Inventory Value: 26.57%
--
-- Business Insight:
-- Slow-Moving products account for 26.57% of average
-- inventory value but contribute only 17.57% of
-- estimated COGS, indicating relatively slower
-- inventory capital turnover.
--
-- Limitation:
-- Movement classification is relative to the dataset.
-- Estimated COGS is not sales revenue or profit.

WITH product_turnover AS (
                        WITH opening_stock AS (
                        SELECT
                            product_id,
                            SUM(opening_qty) AS opening_quantity
                        FROM opening_inventory
                        GROUP BY product_id
                    ),
                    inventory_movement AS (
                        SELECT
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
                        GROUP BY product_id
                    ),
                    inventory_balance AS (
                        SELECT
                            p.product_id,
                            p.product_name,
                            p.category,
                            o.opening_quantity,
                            o.opening_quantity + COALESCE(m.net_movement, 0)
                                AS closing_quantity,
                            p.unit_cost
                        FROM products p
                        JOIN opening_stock o
                            ON p.product_id = o.product_id
                        LEFT JOIN inventory_movement m
                            ON p.product_id = m.product_id
                    ),
                    average_inventory AS (
                        SELECT
                            product_id,
                            product_name,
                            category,
                            ROUND(
                                (
                                    opening_quantity * unit_cost
                                    + closing_quantity * unit_cost
                                ) / 2.0,
                                2
                            ) AS average_inventory_value
                        FROM inventory_balance
                    ),
                    product_cogs AS (
                        SELECT
                            p.product_id,
                            COALESCE(SUM(s.quantity * p.unit_cost), 0)
                                AS estimated_cogs
                        FROM products p
                        LEFT JOIN sales s
                            ON p.product_id = s.product_id
                        GROUP BY p.product_id
                    )
                    SELECT
                        a.product_id,
                        a.product_name,
                        a.category,
                        c.estimated_cogs,
                        a.average_inventory_value,
                        ROUND(
                            c.estimated_cogs
                            / NULLIF(a.average_inventory_value, 0),
                            2
                        ) AS inventory_turnover
                    FROM average_inventory a
                    JOIN product_cogs c
                        ON a.product_id = c.product_id
),
ranked_products AS (
    SELECT
        product_id,
        product_name,
        category,
        estimated_cogs,
        average_inventory_value,
        inventory_turnover,
        NTILE(4) OVER (
            ORDER BY inventory_turnover DESC, product_id
        ) AS turnover_quartile
    FROM product_turnover
),
classified_products AS (
    SELECT
        *,
        CASE
            WHEN turnover_quartile = 1 THEN 'Fast-Moving'
            WHEN turnover_quartile IN (2, 3) THEN 'Medium-Moving'
            ELSE 'Slow-Moving'
        END AS movement_classification
    FROM ranked_products
)
SELECT
    movement_classification,
    COUNT(*) AS total_products,
    SUM(estimated_cogs) AS total_estimated_cogs,
    SUM(average_inventory_value) AS total_average_inventory_value,
    ROUND(
        SUM(estimated_cogs) * 100.0
        / NULLIF(SUM(SUM(estimated_cogs)) OVER (), 0),
        2
    ) AS cogs_contribution_pct,
    ROUND(
        SUM(average_inventory_value) * 100.0
        / NULLIF(SUM(SUM(average_inventory_value)) OVER (), 0),
        2
    ) AS inventory_value_share_pct
FROM classified_products
GROUP BY movement_classification
ORDER BY
    CASE movement_classification
        WHEN 'Fast-Moving' THEN 1
        WHEN 'Medium-Moving' THEN 2
        ELSE 3
    END;

-- ============================================================
-- SQL 5.3C - SLOW-MOVING INVENTORY RISK ANALYSIS
-- ============================================================
-- Purpose:
-- Identify slow-moving products with the highest
-- average inventory value for management review.
--
-- Methodology:
-- Filter Slow-Moving products using the NTILE(4)
-- classification established in SQL 5.3A.
-- Calculate each product's percentage contribution
-- to total Slow-Moving average inventory value.
--
-- Validation Results:
-- Slow-Moving products: 10
-- Total average inventory value: IDR 74,455,500
--
-- Top Inventory Value Exposure:
-- P035: IDR 13,387,500 (17.98%)
-- P011: IDR 11,025,000 (14.81%)
-- P039: IDR 10,560,000 (14.18%)
--
-- Business Insight:
-- The five largest products account for approximately
-- 68.68% of Slow-Moving average inventory value.
-- P035 has the largest inventory value exposure.
-- P039 combines relatively high inventory value
-- with particularly low inventory turnover.
--
-- Limitation:
-- Inventory value exposure is not a financial loss.
-- Further demand, margin, and stock-level analysis
-- is needed before recommending inventory reductions.

WITH product_turnover AS (
                        WITH opening_stock AS (
                        SELECT
                            product_id,
                            SUM(opening_qty) AS opening_quantity
                        FROM opening_inventory
                        GROUP BY product_id
                    ),
                    inventory_movement AS (
                        SELECT
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
                        GROUP BY product_id
                    ),
                    inventory_balance AS (
                        SELECT
                            p.product_id,
                            p.product_name,
                            p.category,
                            o.opening_quantity,
                            o.opening_quantity + COALESCE(m.net_movement, 0)
                                AS closing_quantity,
                            p.unit_cost
                        FROM products p
                        JOIN opening_stock o
                            ON p.product_id = o.product_id
                        LEFT JOIN inventory_movement m
                            ON p.product_id = m.product_id
                    ),
                    average_inventory AS (
                        SELECT
                            product_id,
                            product_name,
                            category,
                            ROUND(
                                (
                                    opening_quantity * unit_cost
                                    + closing_quantity * unit_cost
                                ) / 2.0,
                                2
                            ) AS average_inventory_value
                        FROM inventory_balance
                    ),
                    product_cogs AS (
                        SELECT
                            p.product_id,
                            COALESCE(SUM(s.quantity * p.unit_cost), 0)
                                AS estimated_cogs
                        FROM products p
                        LEFT JOIN sales s
                            ON p.product_id = s.product_id
                        GROUP BY p.product_id
                    )
                    SELECT
                        a.product_id,
                        a.product_name,
                        a.category,
                        c.estimated_cogs,
                        a.average_inventory_value,
                        ROUND(
                            c.estimated_cogs
                            / NULLIF(a.average_inventory_value, 0),
                            2
                        ) AS inventory_turnover
                    FROM average_inventory a
                    JOIN product_cogs c
                        ON a.product_id = c.product_id
),
ranked_products AS (
    SELECT
        product_id,
        product_name,
        category,
        estimated_cogs,
        average_inventory_value,
        inventory_turnover,
        NTILE(4) OVER (
            ORDER BY inventory_turnover DESC, product_id
        ) AS turnover_quartile
    FROM product_turnover
),
classified_products AS (
    SELECT
        *,
        CASE
            WHEN turnover_quartile = 1 THEN 'Fast-Moving'
            WHEN turnover_quartile IN (2, 3) THEN 'Medium-Moving'
            ELSE 'Slow-Moving'
        END AS movement_classification
    FROM ranked_products
)
SELECT
    product_id,
    product_name,
    category,
    estimated_cogs,
    average_inventory_value,
    inventory_turnover,
    movement_classification,
    ROUND(
        average_inventory_value * 100.0
        / NULLIF(
            SUM(average_inventory_value) OVER (),
            0
        ),
        2
    ) AS share_of_slow_inventory_pct
FROM classified_products
WHERE movement_classification = 'Slow-Moving'
ORDER BY
    average_inventory_value DESC,
    inventory_turnover ASC,
    product_id;

-- ============================================================
-- SQL 5.3D - INVENTORY MOVEMENT CLASSIFICATION VALIDATION
-- ============================================================
-- Purpose:
-- Validate completeness, uniqueness, and financial
-- consistency of inventory movement classifications.
--
-- Validation Results:
-- Total rows: 40
-- Unique products: 40
-- Fast-Moving: 10
-- Medium-Moving: 20
-- Slow-Moving: 10
-- Unclassified products: 0
--
-- Financial Reconciliation:
-- Total estimated COGS: IDR 3,218,678,000
-- Total average inventory value: IDR 280,208,250
--
-- Conclusion:
-- All 40 products have been classified successfully.
-- No duplicate or unclassified products were found.
-- Aggregated financial values reconcile with SQL 5.2D.
--
-- Methodology Note:
-- Movement classification is relative to the
-- inventory turnover distribution of this dataset.

WITH product_turnover AS (
                        WITH opening_stock AS (
                        SELECT
                            product_id,
                            SUM(opening_qty) AS opening_quantity
                        FROM opening_inventory
                        GROUP BY product_id
                    ),
                    inventory_movement AS (
                        SELECT
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
                        GROUP BY product_id
                    ),
                    inventory_balance AS (
                        SELECT
                            p.product_id,
                            p.product_name,
                            p.category,
                            o.opening_quantity,
                            o.opening_quantity + COALESCE(m.net_movement, 0)
                                AS closing_quantity,
                            p.unit_cost
                        FROM products p
                        JOIN opening_stock o
                            ON p.product_id = o.product_id
                        LEFT JOIN inventory_movement m
                            ON p.product_id = m.product_id
                    ),
                    average_inventory AS (
                        SELECT
                            product_id,
                            product_name,
                            category,
                            ROUND(
                                (
                                    opening_quantity * unit_cost
                                    + closing_quantity * unit_cost
                                ) / 2.0,
                                2
                            ) AS average_inventory_value
                        FROM inventory_balance
                    ),
                    product_cogs AS (
                        SELECT
                            p.product_id,
                            COALESCE(SUM(s.quantity * p.unit_cost), 0)
                                AS estimated_cogs
                        FROM products p
                        LEFT JOIN sales s
                            ON p.product_id = s.product_id
                        GROUP BY p.product_id
                    )
                    SELECT
                        a.product_id,
                        a.product_name,
                        a.category,
                        c.estimated_cogs,
                        a.average_inventory_value,
                        ROUND(
                            c.estimated_cogs
                            / NULLIF(a.average_inventory_value, 0),
                            2
                        ) AS inventory_turnover
                    FROM average_inventory a
                    JOIN product_cogs c
                        ON a.product_id = c.product_id
),
ranked_products AS (
    SELECT
        product_id,
        product_name,
        category,
        estimated_cogs,
        average_inventory_value,
        inventory_turnover,
        NTILE(4) OVER (
            ORDER BY inventory_turnover DESC, product_id
        ) AS turnover_quartile
    FROM product_turnover
),
classified_products AS (
    SELECT
        *,
        CASE
            WHEN turnover_quartile = 1 THEN 'Fast-Moving'
            WHEN turnover_quartile IN (2, 3) THEN 'Medium-Moving'
            ELSE 'Slow-Moving'
        END AS movement_classification
    FROM ranked_products
)
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT product_id) AS unique_products,
    COUNT(*) FILTER (
        WHERE movement_classification = 'Fast-Moving'
    ) AS fast_moving_products,
    COUNT(*) FILTER (
        WHERE movement_classification = 'Medium-Moving'
    ) AS medium_moving_products,
    COUNT(*) FILTER (
        WHERE movement_classification = 'Slow-Moving'
    ) AS slow_moving_products,
    COUNT(*) FILTER (
        WHERE movement_classification IS NULL
    ) AS unclassified_products,
    ROUND(
        SUM(estimated_cogs),
        2
    ) AS total_estimated_cogs,
    ROUND(
        SUM(average_inventory_value),
        2
    ) AS total_average_inventory_value
FROM classified_products;
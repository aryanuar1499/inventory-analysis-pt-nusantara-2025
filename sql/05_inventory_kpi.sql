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
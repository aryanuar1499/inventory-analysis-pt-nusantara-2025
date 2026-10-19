# Phase 05 — Power BI KPI Development & Validation

**Project:** Inventory Analysis — PT Nusantara 2025  
**Tools:** Power BI Desktop, PostgreSQL, DAX  
**Data Source:** PostgreSQL — `inventory_analysis`  
**Validation Method:** DAX-to-SQL Reconciliation

## 1. KPI 01 — Total Units Sold

### 1.1 Business Objective

Measure the total number of product units sold during the reporting period.

This KPI provides a baseline for evaluating sales volume and can support further analysis by product category, warehouse, and reporting period.

### 1.2 DAX Measure

```dax
Total Units Sold =
SUM('public sales'[quantity])
```

**Explanation:**

- `SUM()` aggregates the quantity of units sold.
- `'public sales'[quantity]` references the quantity column in the imported sales table.
- The measure responds dynamically to the filter context applied in Power BI.

### 1.3 PostgreSQL Validation Query

```sql
SELECT
    SUM(quantity) AS total_units_sold
FROM sales;
```

### 1.4 Validation Results

| Validation Component | Result |
|---|---:|
| Power BI DAX | 209,924 |
| PostgreSQL SQL | 209,924 |
| Difference | 0 |
| Validation Status | PASS |

**Validation Conditions:**

- The Power BI Card was evaluated without report filters affecting the sales data.
- The PostgreSQL query aggregated the full `sales` table.
- Both calculations returned identical results.

### 1.5 Business Interpretation

The dataset records **209,924 units sold** across all sales transactions included in the reporting data.

This result represents sales volume rather than revenue or profit. It provides a baseline for subsequent KPI development, including revenue analysis and sales performance by product category or warehouse.

### 1.6 Power BI Implementation

- **Visual:** Card
- **Measure:** `Total Units Sold`
- **Display Units:** None
- **Decimal Places:** 0
- **Validation:** Passed

---

## 2. KPI Validation Log

| KPI | DAX Result | SQL Result | Difference | Status |
|---|---:|---:|---:|---|
| Total Units Sold | 209,924 | 209,924 | 0 | PASS |
| Inventory Turnover Ratio | 11.49 | 11.49 | 0.00 | PASS |
| Days Inventory Outstanding | 31.78 | 31.78 | 0.00 | PASS |
| Zero Stock Exposure (%) | 0,29% | 0,29% | 0.00 | PASS |
| Total Stock on Hand | 13.729 | 13.729 | 0.00 | PASS |

*Additional validated KPIs will be documented in subsequent sections.*

### 1.7 KPI 02 — Total Sales Revenue

#### Business Objective

Calculate total sales revenue after applying transaction-level discounts.

This KPI measures the monetary value of sales and supports revenue performance analysis across product categories, warehouses, and reporting periods.

#### DAX Measure

```dax
Total Sales Revenue =
SUMX(
    'public sales',
    'public sales'[quantity]
        * 'public sales'[unit_price]
        * (1 - 'public sales'[discount_pct] / 100)
)
```

**Calculation Logic:**

- `SUMX()` iterates through sales transactions and sums the calculated results.
- `quantity * unit_price` calculates gross revenue for each transaction.
- `discount_pct / 100` converts the stored percentage into a decimal fraction.
- The final expression calculates revenue after discounts.

#### PostgreSQL Validation Query

```sql
SELECT
    ROUND(
        SUM(
            quantity * unit_price * (1 - discount_pct / 100)
        ),
        2
    ) AS total_sales_revenue
FROM sales;
```

#### Validation Results

| Validation Component | Result |
|---|---:|
| Power BI DAX | 4,108,169,450.00 |
| PostgreSQL SQL | 4,108,169,450.00 |
| Difference | 0.00 |
| Validation Status | PASS |

**Validation Conditions:**

- The Power BI Card was evaluated without filters affecting the sales data.
- The SQL query aggregated the complete `sales` table.
- Both calculations applied transaction-level discounts using the same formula.

#### Business Interpretation

The dataset records **4,108,169,450.00 in total sales revenue after discounts**.

This KPI measures revenue, not gross profit or net profit. Profitability analysis requires additional cost calculations.

The KPI can be used to evaluate revenue contributions across product categories, warehouses, and reporting periods.

#### Power BI Implementation

- **Visual:** Card
- **Measure:** `Total Sales Revenue`
- **Display Units:** None
- **Decimal Places:** 2
- **Validation:** Passed

---

### 1.8 KPI 03 — Closing Inventory Value

#### Business Objective

Calculate the total value of closing inventory using the latest available stock date within the active reporting context.

This KPI measures the monetary value of inventory on hand based on product unit costs and supports inventory valuation and stock management decisions.

#### DAX Measure

```dax
Closing Inventory Value =
VAR LastStockDate =
    MAX('public vw_daily_inventory_balance'[stock_date])
RETURN
    CALCULATE(
        SUMX(
            'public vw_daily_inventory_balance',
            'public vw_daily_inventory_balance'[daily_closing_stock]
                * RELATED('public products'[unit_cost])
        ),
        'public vw_daily_inventory_balance'[stock_date] = LastStockDate
    )
```

**Calculation Logic:**

- `VAR` stores the latest stock date in the current filter context.
- `RETURN` evaluates the final inventory valuation expression.
- `CALCULATE()` applies the selected closing stock date.
- `SUMX()` multiplies stock quantity by product unit cost for each inventory record and sums the results.
- `RELATED()` retrieves the corresponding product unit cost through the active relationship.

#### PostgreSQL Validation Query

```sql
SELECT
    ROUND(
        SUM(
            v.daily_closing_stock * p.unit_cost
        ),
        2
    ) AS closing_inventory_value
FROM vw_daily_inventory_balance v
JOIN products p
    ON v.product_id = p.product_id
WHERE v.stock_date = '2025-12-31';
```

#### Validation Results

| Validation Component | Result |
|---|---:|
| Power BI DAX | 209,516,500.00 |
| PostgreSQL SQL | 209,516,500.00 |
| Difference | 0.00 |
| Validation Status | PASS |

**Validation Conditions:**

- The Power BI Card was evaluated without active report filters.
- The latest stock date was December 31, 2025.
- Inventory quantities were multiplied by their corresponding product unit costs.
- Both calculations returned identical results.

#### Business Interpretation

The closing inventory value on **December 31, 2025** was **209,516,500.00** in the dataset's monetary units.

This KPI represents the cost-based value of inventory remaining at the reporting date, not sales revenue or profit.

Closing Inventory Value is a **semi-additive measure**: it can be aggregated across products and warehouses for the same date, but values from different dates should not be summed together.

#### Power BI Implementation

- **Visual:** Card
- **Measure:** `Closing Inventory Value`
- **Reference Date:** December 31, 2025
- **Display Units:** None
- **Decimal Places:** 2
- **Validation:** Passed

---

### 1.9 KPI 04 — Inventory Turnover Ratio

#### Business Objective

Measure how efficiently inventory is converted into sales during the 2025 reporting period using estimated cost of goods sold and average inventory value.

#### Calculation Method

Inventory Turnover Ratio = Estimated COGS / Average Inventory Value

Average Inventory Value = (Opening Inventory Value + Closing Inventory Value) / 2

The calculation uses beginning and ending inventory values rather than an average of daily inventory balances.

#### Supporting DAX Measures

**Estimated COGS**

```dax
Estimated COGS =
SUMX(
    'public sales',
    'public sales'[quantity]
        * RELATED('public products'[unit_cost])
)
```

**Opening Inventory Value**

```dax
Opening Inventory Value =
SUMX(
    'public opening_inventory',
    'public opening_inventory'[opening_qty]
        * RELATED('public products'[unit_cost])
)
```

**Average Inventory Value**

```dax
Average Inventory Value =
DIVIDE(
    [Opening Inventory Value] + [Closing Inventory Value],
    2
)
```

#### Final DAX Measure

```dax
Inventory Turnover Ratio =
DIVIDE(
    [Estimated COGS],
    [Average Inventory Value]
)
```

#### PostgreSQL Validation Query

```sql
WITH estimated_cogs AS (
    SELECT
        SUM(s.quantity * p.unit_cost) AS total_cogs
    FROM sales s
    JOIN products p
        ON s.product_id = p.product_id
),
opening_value AS (
    SELECT
        SUM(o.opening_qty * p.unit_cost) AS opening_inventory_value
    FROM opening_inventory o
    JOIN products p
        ON o.product_id = p.product_id
),
closing_value AS (
    SELECT
        SUM(v.daily_closing_stock * p.unit_cost) AS closing_inventory_value
    FROM vw_daily_inventory_balance v
    JOIN products p
        ON v.product_id = p.product_id
    WHERE v.stock_date = '2025-12-31'
)
SELECT
    ROUND(
        c.total_cogs /
        NULLIF(
            (o.opening_inventory_value + cl.closing_inventory_value) / 2,
            0
        ),
        2
    ) AS inventory_turnover_ratio
FROM estimated_cogs c
CROSS JOIN opening_value o
CROSS JOIN closing_value cl;
```

#### Validation Results

| Component | PostgreSQL / Power BI Result |
|---|---:|
| Estimated COGS | 3,218,678,000.00 |
| Opening Inventory Value | 350,900,000.00 |
| Closing Inventory Value | 209,516,500.00 |
| Average Inventory Value | 280,208,250.00 |
| Inventory Turnover Ratio (SQL) | 11.49 |
| Inventory Turnover Ratio (DAX) | 11.49 |
| Displayed Difference | 0.00 |
| Validation Status | PASS — 2 Decimal Places |

#### Business Interpretation

The estimated inventory turnover ratio for 2025 was **11.49 times**.

This indicates that the annual estimated cost of goods sold was approximately 11.49 times the average inventory value calculated from beginning and ending inventory balances.

The result should be interpreted alongside stockout risk, demand patterns, and industry benchmarks.

#### Methodology and Limitations

- Estimated COGS uses the current product unit cost rather than historical transaction-level costs.
- Average Inventory Value uses two inventory valuation points: beginning and end of 2025.
- The KPI has been validated for the full-year 2025 reporting context without active filters.
- Additional modeling may be required for accurate turnover calculations under arbitrary date slicers.
- Closing inventory is semi-additive across time.

#### Power BI Implementation

- **Visual:** Card
- **Measure:** `Inventory Turnover Ratio`
- **Display Units:** None
- **Decimal Places:** 2
- **Validation:** Passed

---

### 1.10 KPI 05 — Days Inventory Outstanding (DIO)

#### Business Objective

Estimate the number of days that average inventory value represents relative to the annual cost of goods sold during 2025.

This KPI supports inventory efficiency analysis, working capital evaluation, and inventory management decisions.

#### Calculation Method

Days Inventory Outstanding = (Average Inventory Value / Estimated COGS) × 365

The calculation uses the full 2025 reporting period of 365 days.

#### DAX Measure

```dax
Days Inventory Outstanding =
DIVIDE(
    [Average Inventory Value] * 365,
    [Estimated COGS]
)
```

**Calculation Logic:**

- `[Average Inventory Value]` retrieves the previously validated average inventory valuation.
- `[Estimated COGS]` retrieves the previously validated estimated cost of goods sold.
- `365` represents the number of days in the 2025 reporting period.
- `DIVIDE()` performs the division and safely handles zero or blank denominators.

#### PostgreSQL Validation Query

```sql
WITH estimated_cogs AS (
    SELECT
        SUM(s.quantity * p.unit_cost) AS total_cogs
    FROM sales s
    JOIN products p
        ON s.product_id = p.product_id
),
opening_value AS (
    SELECT
        SUM(o.opening_qty * p.unit_cost) AS opening_inventory_value
    FROM opening_inventory o
    JOIN products p
        ON o.product_id = p.product_id
),
closing_value AS (
    SELECT
        SUM(v.daily_closing_stock * p.unit_cost) AS closing_inventory_value
    FROM vw_daily_inventory_balance v
    JOIN products p
        ON v.product_id = p.product_id
    WHERE v.stock_date = '2025-12-31'
)
SELECT
    ROUND(
        (
            (o.opening_inventory_value + cl.closing_inventory_value) / 2
        ) * 365.0 / NULLIF(c.total_cogs, 0),
        2
    ) AS days_inventory_outstanding
FROM estimated_cogs c
CROSS JOIN opening_value o
CROSS JOIN closing_value cl;
```

#### Validation Results

| Validation Component | Result |
|---|---:|
| Estimated COGS | 3,218,678,000.00 |
| Average Inventory Value | 280,208,250.00 |
| PostgreSQL SQL | 31.78 |
| Power BI DAX | 31.78 |
| Displayed Difference | 0.00 |
| Validation Status | PASS — 2 Decimal Places |

**Validation Conditions:**

- Reporting period: January 1–December 31, 2025.
- The calculation was evaluated without active report filters.
- Average Inventory Value uses beginning and ending inventory valuations.
- Both SQL and DAX calculations use unrounded intermediate values.

#### Business Interpretation

The estimated Days Inventory Outstanding for 2025 was **31.78 days**.

This indicates that the average inventory value was equivalent to approximately 31.78 days of estimated cost of goods sold.

DIO is an aggregate financial efficiency indicator and does not represent the actual storage duration of each individual product.

#### Methodology and Limitations

- Estimated COGS is calculated using product unit costs rather than historical transaction-level costs.
- Average Inventory Value uses opening and closing inventory values rather than daily average balances.
- The measure is validated for the full-year 2025 reporting context.
- The fixed 365-day multiplier assumes a full-year reporting period; additional DAX logic would be required for arbitrary date selections.
- DIO should be interpreted alongside inventory turnover, stockout exposure, and business operating conditions.

#### Power BI Implementation

- **Visual:** Card
- **Measure:** `Days Inventory Outstanding`
- **Display Units:** None
- **Decimal Places:** 2
- **Unit:** Days
- **Validation:** Passed

---

### 1.11 KPI 06 — Zero Stock Exposure (%)

#### Business Objective

Measure the percentage of daily inventory observations where closing stock equals zero across product–warehouse combinations during the 2025 reporting period.

This KPI helps identify inventory availability risks and provides a foundation for further stockout exposure analysis.

#### Calculation

Zero Stock Exposure (%) = (Zero Stock Observations / Total Stock Observations) × 100

**Validated Results:**
- Total Stock Observations: 43,800
- Zero Stock Observations: 126
- Zero Stock Exposure: 0.29%

**Interpretation:**

Approximately 0.29% of daily inventory observations recorded zero closing stock during 2025. This metric represents zero-stock exposure, not confirmed lost sales or unmet customer demand.

#### DAX Measure

```dax
Zero Stock Exposure (%) =
DIVIDE(
    CALCULATE(
        COUNTROWS('public vw_daily_inventory_balance'),
        'public vw_daily_inventory_balance'[daily_closing_stock] = 0
    ),
    COUNTROWS('public vw_daily_inventory_balance'),
    0
)
```

**Measure Format:**
- Data type: Decimal number
- Format: Percentage
- Decimal places: 2

#### PostgreSQL Validation

```sql
SELECT
    COUNT(*) AS total_stock_observations,
    COUNT(*) FILTER (
        WHERE daily_closing_stock = 0
    ) AS zero_stock_observations,
    ROUND(
        COUNT(*) FILTER (
            WHERE daily_closing_stock = 0
        ) * 100.0 / NULLIF(COUNT(*), 0),
        2
    ) AS zero_stock_exposure_pct
FROM vw_daily_inventory_balance;
```

**Validation Results:**

| Metric | PostgreSQL | Power BI |
|---|---:|---:|
| Zero Stock Exposure (%) | 0.29% | 0.29% |

**Validation Status:** PASSED — PostgreSQL and Power BI results match to two decimal places.

**Technical Notes:**
- Each observation represents one product–warehouse–date combination.
- The calculation uses daily closing stock, not opening stock.
- The DAX measure responds to the applicable Power BI filter context.
- Zero stock does not necessarily indicate lost sales or unmet customer demand.

### 1.12 KPI 07 — Total Stock on Hand

#### Business Objective

Measure the total quantity of inventory remaining across all product–warehouse combinations at the end of the reporting period.

This KPI provides visibility into physical inventory levels and complements Closing Inventory Value, which measures inventory in monetary terms.

#### Calculation

Total Stock on Hand = SUM(Daily Closing Stock at the Latest Reporting Date)

**Validated Results:**
- Reporting Date: 2025-12-31
- Total Stock on Hand: 13,729 units

#### Business Interpretation

At the end of 2025, the company recorded 13,729 units of closing inventory across its product–warehouse combinations.

This KPI helps management understand the quantity of inventory remaining at the reporting date and supports inventory monitoring and operational planning.

**Important Considerations:**
- Inventory quantities are calculated at the latest reporting date, not accumulated across all historical dates.
- Summing stock quantities across different products assumes their units of measurement are comparable.
- Total Stock on Hand represents recorded closing inventory, not necessarily inventory available for immediate sale.

#### DAX Measure

```dax
Total Stock on Hand =
VAR LastStockDate =
    MAX('public vw_daily_inventory_balance'[stock_date])
RETURN
    CALCULATE(
        SUM('public vw_daily_inventory_balance'[daily_closing_stock]),
        'public vw_daily_inventory_balance'[stock_date] = LastStockDate
    )
```

**Measure Format:**
- Data type: Numeric
- Format: Whole number
- Decimal places: 0
- Display units: None

#### PostgreSQL Validation

```sql
SELECT
    stock_date,
    SUM(daily_closing_stock) AS total_stock_on_hand
FROM vw_daily_inventory_balance
WHERE stock_date = (
    SELECT MAX(stock_date)
    FROM vw_daily_inventory_balance
)
GROUP BY stock_date;
```

**Validation Results:**

| Metric | PostgreSQL | Power BI |
|---|---:|---:|
| Total Stock on Hand | 13,729 | 13,729 |

**Validation Status:** PASSED — PostgreSQL and Power BI results match.

**Technical Notes:**
- The measure uses the latest stock date within the applicable filter context.
- Inventory quantities are summed only for the selected reporting date to prevent double counting across historical dates.
- The measure is designed to respond to applicable report filters.
- Results under product, warehouse, or date filters should be tested during dashboard development.
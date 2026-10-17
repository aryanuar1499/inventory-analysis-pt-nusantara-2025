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

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

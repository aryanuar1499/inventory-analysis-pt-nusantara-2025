# Phase 04 — Inventory KPI & Stock Performance Analysis

**Project:** Inventory Analysis — PT Nusantara Distribution
**Analysis Period:** January 1 – December 31, 2025
**Database:** PostgreSQL
**SQL Reference:** `sql/05_inventory_kpi.sql`
**Status:** In Progress — Interim Analysis Documentation

## 1. Analysis Objectives

This phase evaluates inventory efficiency, stock availability, and potential inventory risks across products and warehouses.

The analysis focuses on:

- Measuring inventory valuation and turnover performance.
- Estimating Days Inventory Outstanding (DIO).
- Reconstructing daily inventory balances from opening stock and inventory transactions.
- Identifying zero-stock exposure and recurring stockout episodes.
- Comparing end-of-day stock availability across warehouses.

The findings are based on a synthetic 2025 operational dataset and are intended to demonstrate reproducible SQL analysis and business interpretation.

## 2. Analysis Scope and Methodology

The analysis uses five PostgreSQL tables: `opening_inventory`, `inventory_transactions`, `products`, `sales`, and `warehouses`.

Inventory movements are classified as follows:

- **Stock increases:** `INBOUND` and `RETURN`.
- **Stock decreases:** `OUTBOUND` and `DAMAGE`.

Daily inventory balances are reconstructed for each product–warehouse combination using opening stock, aggregated daily movements, and PostgreSQL window functions.

Inventory valuation and estimated COGS use the product `unit_cost`, assumed constant throughout 2025.

Stock availability and stockout episodes are measured using **end-of-day inventory balances**. These metrics do not directly measure intraday availability, lost sales, or customer order fulfillment.

The SQL documentation retains both initial learning queries and improved dynamic versions to demonstrate the progression toward reproducible analysis.

## 3. Inventory KPI Results

### 3.1 Inventory Valuation

| Metric | Value |
|---|---:|
| Opening Inventory Quantity | 22,520 units |
| Closing Inventory Quantity | 13,729 units |
| Opening Inventory Value | IDR 350,900,000 |
| Closing Inventory Value | IDR 209,516,500 |
| Average Inventory Value | IDR 280,208,250 |

The opening inventory value represents the estimated cost of inventory available at the beginning of 2025.

The closing inventory value is reconstructed by combining opening quantities with net inventory movements throughout the year and applying product unit costs.

The average inventory value is calculated using the arithmetic mean of opening and closing inventory values. This is a two-point annual estimate rather than an average of daily inventory values.

### 3.2 Estimated Cost of Goods Sold (COGS)

| Metric | Value |
|---|---:|
| Sales Transactions | 28,169 |
| Units Sold | 209,924 |
| Estimated COGS | IDR 3,218,678,000 |

Estimated COGS is calculated by multiplying recorded sales quantities by their corresponding product unit costs.

The calculation uses the `sales` table rather than assuming that all `OUTBOUND` inventory transactions represent sales.

Because historical unit-cost changes are not modeled, this figure should be interpreted as an estimated COGS rather than an audited accounting measure.

### 3.3 Inventory Turnover Ratio

**Inventory Turnover: 11.49 times per year**

Inventory turnover is calculated by dividing estimated annual COGS by the average inventory value.

The result indicates that annual estimated COGS was approximately 11.49 times the average inventory value during 2025.

This is an aggregate value-based performance indicator and does not mean that every individual product physically rotated 11.49 times.

### 3.4 Days Inventory Outstanding (DIO)

**DIO: 31.78 days**

DIO is calculated by dividing average inventory value by estimated annual COGS and multiplying by 365 days.

The result suggests that the company's average inventory investment was equivalent to approximately 31.78 days of estimated COGS.

This figure does not represent the exact storage duration of individual products. Product-level analysis is required to identify differences in inventory movement and holding patterns.

### 3.5 Preliminary Business Interpretation

The aggregate inventory turnover and DIO metrics provide an initial view of inventory efficiency across the distribution network.

However, these indicators alone are insufficient to determine whether inventory performance is optimal.

Further analysis should consider product-level turnover, demand patterns, stock availability, and replenishment practices before drawing operational conclusions.

## 4. Stock Availability & Stockout Analysis

### 4.1 Daily Inventory Reconstruction

Daily inventory balances were reconstructed using the `vw_daily_inventory_balance` PostgreSQL view.

The analysis covers 40 products across three warehouses for the full 365 days of 2025.

| Stock Status | Product–Warehouse–Days |
|---|---:|
| Positive Closing Stock | 43,674 |
| Zero Closing Stock | 126 |
| Negative Closing Stock | 0 |
| **Total Observations** | **43,800** |

The reconstructed inventory balances show that 43,674 observations had positive end-of-day stock, while 126 observations recorded zero closing stock.

No negative end-of-day inventory balances were identified.

The absence of negative balances supports the internal consistency of the reconstructed stock movements but does not independently verify the accuracy of the underlying operational records.

### 4.2 Overall Stock Availability

**End-of-Day Stock Availability Rate: 99.71%**

Stock availability is measured as the percentage of product–warehouse–day observations with positive closing stock.

The corresponding zero-stock exposure rate is approximately 0.29%.

This result indicates that most product–warehouse combinations maintained positive end-of-day inventory throughout 2025.

However, this measure does not represent customer order fulfillment, service level, or intraday product availability.

### 4.3 Stockout Exposure by Warehouse

| Warehouse | Total Observations | Zero-Stock Days | Zero-Stock Rate | Availability Rate |
|---|---:|---:|---:|---:|
| WH001 | 14,600 | 35 | 0.24% | 99.76% |
| WH002 | 14,600 | 40 | 0.27% | 99.73% |
| WH003 | 14,600 | 51 | 0.35% | 99.65% |
| **Total** | **43,800** | **126** | **0.29%** | **99.71%** |

WH003 recorded the highest number of zero-stock observations, with 51 product–warehouse–days, followed by WH002 with 40 and WH001 with 35.

Although WH003 had the lowest measured end-of-day availability rate, the difference alone is insufficient to establish poorer warehouse management performance.

Differences in product demand, inventory allocation, replenishment timing, and operational conditions require further investigation.

### 4.4 Products with the Highest Stockout Exposure

The following product–warehouse combinations recorded the highest numbers of zero-stock days during 2025.

| Warehouse | Product ID | Zero-Stock Days | Stockout Episodes |
|---|---|---:|---:|
| WH001 | P034 | 9 | 2 |
| WH002 | P038 | 8 | 2 |
| WH001 | P040 | 7 | 2 |
| WH003 | P039 | 6 | 1 |
| WH001 | P038 | 5 | 1 |
| WH002 | P019 | 5 | 2 |
| WH002 | P035 | 5 | 2 |
| WH002 | P039 | 5 | 1 |
| WH002 | P040 | 5 | 1 |
| WH003 | P019 | 5 | 1 |

The combinations with the highest zero-stock exposure warrant further review of demand patterns, replenishment schedules, and inventory allocation.

A stockout episode represents a consecutive sequence of days with zero end-of-day stock for
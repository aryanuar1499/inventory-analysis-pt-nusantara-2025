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

## 5. Product-Level Inventory Turnover Analysis

### 5.1 Methodology

Product-level inventory turnover was calculated using estimated Cost of Goods Sold (COGS) divided by average inventory value.

Average inventory value was calculated using the opening and closing inventory values for 2025.

Estimated COGS was calculated from sales quantities multiplied by fixed product unit costs. Therefore, these values represent analytical estimates rather than accounting-verified COGS.

### 5.2 Key Findings

- Total Estimated COGS: **IDR 3,218,678,000**
- Average Inventory Value: **IDR 280,208,250**
- Overall Inventory Turnover: **11.49 times annually**
- Products analyzed: **40**

The highest product-level inventory turnover was recorded by **P004 — Beras Premium 5kg (16.32×)**, followed by **P021 — Detergen Bubuk 800g (16.21×)**.

The lowest inventory turnover was recorded by **P028 — Cairan Pembersih Kaca 500ml (5.79×)** and **P039 — Wadah Makanan Plastik (5.81×)**.

Product-level reconciliation confirmed that aggregated estimated COGS and average inventory values were consistent with company-level inventory KPIs.

## 6. Inventory Movement Classification

### 6.1 Classification Methodology

Products were classified using PostgreSQL's `NTILE(4)` window function, ranking annual inventory turnover from highest to lowest.

- **Fast-Moving:** Top 25% (10 products)
- **Medium-Moving:** Middle 50% (20 products)
- **Slow-Moving:** Bottom 25% (10 products)

This classification is relative to the analyzed product portfolio and does not represent universal industry thresholds.

### 6.2 Classification Results

| Classification | Products | Estimated COGS Contribution | Average Inventory Value Share |
|---|---:|---:|---:|
| Fast-Moving | 10 | 45.29% | 33.89% |
| Medium-Moving | 20 | 37.14% | 39.53% |
| Slow-Moving | 10 | 17.57% | 26.57% |

Fast-Moving products accounted for **45.29% of estimated COGS**, while representing **33.89% of average inventory value**.

In contrast, Slow-Moving products contributed **17.57% of estimated COGS**, while accounting for **26.57% of average inventory value**.

This indicates relatively slower inventory capital turnover within the Slow-Moving group.

### 6.3 Slow-Moving Inventory Priorities

The Slow-Moving group contained 10 products with a combined average inventory value of **IDR 74,455,500**.

Products with the highest inventory value exposure included:

1. **P035 — Rak Serbaguna 3 Tingkat:** IDR 13,387,500 (17.98%)
2. **P011 — Shampoo 170ml:** IDR 11,025,000 (14.81%)
3. **P039 — Wadah Makanan Plastik:** IDR 10,560,000 (14.18%)

The five products with the highest average inventory values accounted for approximately **68.68%** of the Slow-Moving group's average inventory value.

These products should be prioritized for further review of demand patterns, replenishment decisions, and inventory holding requirements.

### 6.4 Business Implications

The analysis suggests three areas for management consideration:

- **Fast-Moving products:** Review replenishment reliability and stock availability to reduce potential stockout exposure.
- **Medium-Moving products:** Maintain balanced inventory policies while monitoring changes in demand and turnover.
- **Slow-Moving products:** Evaluate inventory levels, purchasing frequency, and storage requirements before making stock reduction decisions.

Slow-Moving classification does not necessarily indicate unprofitability, dead stock, or realized financial losses. Further information on sales margins, demand variability, lead times, and holding costs would be needed to support specific operational decisions.

## 7. Inventory Risk Prioritization and Cross-Warehouse Availability

### 7.1 Analysis Objective

This analysis evaluates the relationship between product-level inventory turnover, zero-closing-stock exposure, and warehouse-level stock distribution.

The objective is to identify products requiring further inventory investigation and assess whether stock is available at other warehouses when a particular warehouse records zero closing stock.

### 7.2 Methodology

The analysis was conducted using four SQL queries:

- **SQL 5.4A — Product-Level Stockout Exposure:** Calculated zero-closing-stock warehouse-days and exposure percentages for each product.
- **SQL 5.4B — Inventory Turnover vs Stockout Exposure:** Combined inventory turnover classifications with zero-stock exposure.
- **SQL 5.4C — Warehouse-Level Stock Distribution:** Examined daily closing stock patterns for products P039 and P040 across three warehouses.
- **SQL 5.4D — Same-Date Cross-Warehouse Stock Availability:** Used a self-join to identify warehouses with positive closing stock when another warehouse recorded zero closing stock for the same product and date.

The analysis uses end-of-day inventory balances for the 2025 reporting period.

### 7.3 Key Findings

**Finding 1 — Zero-Stock Exposure Is Concentrated in Selected Products**

Out of 40 products, 22 experienced at least one zero-closing-stock warehouse-day, while 18 recorded no such observations.

The products with the highest zero-stock exposure were:

| Product | Zero-Stock Warehouse-Days | Exposure |
|---|---:|---:|
| P040 — Kotak Penyimpanan Plastik | 17 | 1.55% |
| P039 — Wadah Makanan Plastik | 14 | 1.28% |
| P038 — Gantungan Baju 10pcs | 13 | 1.19% |
| P019 — Cotton Buds 100pcs | 12 | 1.10% |
| P034 — Tempat Sampah 20L | 10 | 0.91% |

Each product was evaluated across 1,095 warehouse-day observations.

**Finding 2 — Slow-Moving Products Can Experience Zero-Stock Exposure**

P040 and P039 were classified as Slow-Moving, with annual inventory turnover ratios of 7.09× and 5.81×, respectively.

Despite their relatively low turnover, both products experienced zero closing stock at individual warehouses.

This demonstrates that company-level inventory movement classifications do not necessarily represent stock availability at each warehouse.

**Finding 3 — Warehouse-Level Stock Patterns Differ**

For P039, WH003 recorded six zero-stock days, compared with five at WH002 and three at WH001.

For P040, WH001 recorded seven zero-stock days, while WH002 and WH003 each recorded five.

These differences indicate that inventory availability varies by warehouse and reporting date.

**Finding 4 — Other Warehouses Held Positive Stock During All Observed Zero-Stock Events**

The same-date cross-warehouse analysis identified 31 zero-stock warehouse-day observations across P039 and P040.

For each observation, both other warehouses recorded positive closing stock on the same date.

The self-join returned 62 rows because each zero-stock warehouse-day matched two warehouses with positive closing stock.

This provides evidence of differences in inventory availability across warehouse locations and supports further investigation of potential inventory redistribution opportunities.

### 7.4 Business Implications

The results suggest that inventory management decisions should consider both product-level turnover and warehouse-level stock availability.

Products classified as Slow-Moving should not automatically be treated as overstocked at every location.

Before increasing purchasing quantities, management should evaluate whether existing inventory can be redistributed from other warehouses without creating additional shortages.

Priority should be given to investigating products with recurring zero-stock exposure, particularly P040 and P039.

### 7.5 Recommended Follow-Up

Management should assess warehouse-specific demand, safety stock requirements, replenishment lead times, and transfer costs before authorizing inventory transfers.

Future analysis could evaluate whether stock redistribution policies would reduce zero-stock exposure while maintaining sufficient inventory at supplying warehouses.

### 7.6 Analytical Limitations

- Zero closing stock does not establish the duration of stock unavailability during the day.
- Zero-stock observations do not directly measure lost sales or unmet customer demand.
- Positive stock in another warehouse does not prove that an internal transfer was operationally feasible.
- Inventory turnover is calculated using estimated COGS and a two-point average inventory valuation.
- The analysis identifies potential inventory distribution issues but does not establish their underlying causes.

## 8. Executive Summary & Strategic Recommendations

### 8.1 Executive Summary

The 2025 Inventory KPI & Stock Performance Analysis evaluated inventory valuation, turnover efficiency, stock availability, product movement classification, and warehouse-level inventory risks across PT Nusantara Distribution.

The analysis covered 40 products across three warehouses, using inventory transactions, sales records, opening inventory, and daily closing stock balances.

The results provide a quantitative foundation for evaluating inventory efficiency and identifying opportunities to improve inventory allocation and replenishment decisions.

### 8.2 Key Performance Indicators

| KPI | Result |
|---|---:|
| Opening Inventory Value | Rp350,900,000 |
| Closing Inventory Value | Rp209,516,500 |
| Average Inventory Value | Rp280,208,250 |
| Estimated COGS | Rp3,218,678,000 |
| Annual Inventory Turnover | 11.49× |
| Days Inventory Outstanding (DIO) | 31.78 days |
| End-of-Day Stock Availability | 99.71% |
| Zero-Stock Warehouse-Days | 126 |
| Negative Closing Stock Observations | 0 |

Inventory turnover and DIO were calculated using estimated COGS and the average of opening and closing inventory values.

Stock availability represents the percentage of product-warehouse-day observations with positive end-of-day inventory balances.

### 8.3 Product Movement Classification

Products were classified into relative inventory turnover quartiles:

| Classification | Products | Share of Estimated COGS |
|---|---:|---:|
| Fast-Moving | 10 | 45.29% |
| Medium-Moving | 20 | 37.14% |
| Slow-Moving | 10 | 17.57% |

Fast-Moving products accounted for 45.29% of estimated COGS while representing only 25% of the product portfolio.

Slow-Moving products accounted for 26.57% of average inventory value but contributed 17.57% of estimated COGS.

These findings suggest opportunities to review capital allocation across product groups without assuming that lower-turnover products are necessarily unprofitable.

### 8.4 Key Inventory Risks

The analysis identified 126 zero-closing-stock observations across the product-warehouse-day dataset.

Products P040 and P039 demonstrated relatively low inventory turnover alongside recurring warehouse-level zero-stock exposure.

Further investigation showed that both other warehouses maintained positive closing stock during all 31 zero-stock warehouse-day observations involving these two products.

This indicates differences in inventory availability between warehouse locations and supports a review of inventory distribution practices.

### 8.5 Strategic Recommendations

**Recommendation 1 — Prioritize Replenishment Based on Demand and Availability**

Develop product-level replenishment priorities using inventory turnover, warehouse-specific demand, stock availability, and replenishment lead times rather than turnover alone.

**Recommendation 2 — Review Cross-Warehouse Inventory Redistribution**

Investigate potential stock transfers for products experiencing zero-stock exposure while other warehouses retain positive stock.

Transfer decisions should account for safety stock, expected demand, transfer lead time, and logistics costs.

**Recommendation 3 — Review Slow-Moving Inventory Exposure**

Evaluate purchasing quantities and inventory holding policies for Slow-Moving products, particularly those contributing the largest average inventory values.

Any reduction in inventory should consider customer demand, supplier constraints, and service-level requirements.

**Recommendation 4 — Establish Routine Inventory KPI Monitoring**

Implement periodic monitoring of inventory turnover, DIO, end-of-day stock availability, and warehouse-level zero-stock exposure.

These indicators can support earlier identification of inventory risks and more consistent operational decision-making.

### 8.6 Analytical Limitations

The analysis is subject to several limitations:

- Estimated COGS is based on sales quantities multiplied by fixed product unit costs and is not an independently verified accounting COGS figure.
- Average inventory value uses opening and closing balances rather than a daily weighted average.
- Inventory turnover classifications are relative to the analyzed product portfolio.
- End-of-day stock availability does not measure order fulfillment or intraday stock availability.
- Zero closing stock does not independently establish lost sales.
- Positive stock at another warehouse does not guarantee that inventory can be transferred without affecting local service levels.
- Profitability, carrying costs, and financial returns cannot be fully evaluated without additional financial and operational data.

### 8.7 Final Conclusion

The analysis demonstrates that inventory efficiency and warehouse-level stock availability should be evaluated together.

Although overall end-of-day stock availability reached 99.71%, selected products experienced recurring zero-stock exposure while other warehouses held positive inventory.

The findings support a more targeted inventory management approach that combines turnover analysis, replenishment planning, and warehouse-level inventory allocation.

These results provide a foundation for subsequent business recommendations, reporting dashboards, and operational improvement initiatives.

# Phase 05 — Power BI Dashboard Design

## 1. Dashboard Overview

**Project:** Inventory Analysis PT Nusantara Distribution 2025  
**Tool:** Microsoft Power BI Desktop  
**Database:** PostgreSQL  
**Reporting Period:** January–December 2025  
**Development Status:** In Progress

### Business Objective

The dashboard is designed to provide management with a clear overview of inventory performance, sales activity, stock efficiency, and operational risks.

The primary objective is to transform validated inventory KPIs into actionable business insights through interactive visualizations.

## 2. Dashboard Architecture

The dashboard follows a multi-page architecture consisting of three planned report pages.

| Page | Dashboard Name | Business Purpose |
|---|---|---|
| 1 | Executive Overview | Summarize key inventory and sales performance indicators |
| 2 | Stock Performance | Analyze inventory movement and stock efficiency |
| 3 | Inventory Risk | Identify stockout exposure, damaged stock, and operational risks |

**Implementation Note:** The Executive Overview report page was created as a new page in the existing Power BI file. The original report page is retained for previously developed and validated KPI work.

## 3. Executive Overview — Design Specification

### Canvas Configuration

- Aspect Ratio: 16:9
- Background Color: `#F5F7FA`
- Design Style: Corporate Minimalist

### Header Configuration

- Header Background: `#17365D`
- Company Title: PT NUSANTARA DISTRIBUTION
- Title Font: Segoe UI, 22 pt, Bold
- Title Color: `#FFFFFF`
- Subtitle: Inventory Performance Dashboard | 2025
- Subtitle Font: Segoe UI, 12 pt, Regular
- Subtitle Color: `#DCE7F3`

### Planned Dashboard Components

1. Executive KPI Cards
2. Monthly Sales Performance
3. Warehouse Performance
4. Inventory Health Indicators
5. Interactive Filters

**Development Note:** The dashboard canvas and header have been implemented. KPI cards, charts, and interactive filters are planned for subsequent development steps.

## 4. Design Principles

- Business relevance before visual complexity.
- Consistent colors, typography, and spacing.
- Clear visual hierarchy for executive decision-making.
- Validated PostgreSQL and Power BI measures as the analytical foundation.
- Transparent separation between implemented features and planned components.

## 5. Development Checkpoint

**Step 142 — Dashboard Planning & Layout Design**

Completed:
- Multi-page dashboard architecture selected.
- Executive Overview report page created.
- Canvas aspect ratio configured to 16:9.
- Canvas background configured.
- Dashboard header rectangle implemented.
- Company title and dashboard subtitle added.
- Header alignment validated.
- Power BI file saved successfully.

Pending:
- Executive KPI cards.
- Sales trend visualization.
- Warehouse performance visualization.
- Inventory health indicators.
- Interactive slicers and filter validation.


## 6. Executive Overview — KPI Cards Implementation

### Development Step

Step 143 — Executive Overview: KPI Cards Development

### Implementation Summary

Seven validated KPI measures have been implemented as Power BI Card visuals on the Executive Overview report page.

The existing DAX measures were reused without modifying their underlying calculations.

| KPI | Validated Value | Dashboard Display |
|---|---:|---:|
| Total Sales Revenue | 4,108,169,450 | 4.11bn |
| Total Units Sold | 209,924 | 209,924 |
| Opening Inventory Value | 350,900,000 | 350.90M |
| Closing Inventory Value | 209,516,500 | 209.52M |
| Average Inventory Value | 280,208,250 | 280.21M |
| Inventory Turnover | 11.49 | 11.49 |
| Days Inventory Outstanding | 31.776 (display precision) | 31.78 |

### KPI Validation

All seven KPI Cards were checked against previously validated PostgreSQL results.

The DIO measure displays 31.776 with three decimal places and 31.78 with two decimal places. This difference is caused by display rounding rather than a change in the underlying DAX calculation.

### Dashboard Formatting

- Corporate Minimalist design style.
- Consistent KPI Card styling based on the Total Sales Revenue Card.
- Display units adjusted for readability.
- Card sizes and positions customized during dashboard development.
- Visual formatting does not alter underlying KPI calculations.

### Development Status

Completed:
- Seven KPI Cards implemented.
- KPI values validated.
- Initial formatting completed.

Next:
- Monthly Sales Trend Visualization.
- Warehouse Performance Visualization.
- Inventory Health and Risk Indicators.
- Interactive Slicer Implementation and Validation.


## 7. Monthly Sales Trend Visualization

### Development Step
Step 144 — Monthly Sales Trend Visualization

### Implementation
- Report Page: Executive Overview
- Visual Type: Line Chart
- X-axis: sales_date (Year and Month)
- Y-axis: Total Sales Revenue (DAX Measure)
- Analysis Period: January–December 2025

### Monthly Revenue Validation

| Month | Net Sales Revenue (IDR) |
|---|---:|
| January | 357,400,680 |
| February | 309,946,525 |
| March | 364,363,775 |
| April | 354,589,495 |
| May | 349,202,890 |
| June | 327,301,520 |
| July | 335,490,255 |
| August | 346,136,620 |
| September | 333,641,150 |
| October | 341,309,555 |
| November | 336,061,005 |
| December | 352,725,980 |

### Validation Results
- All 12 monthly revenue values matched PostgreSQL.
- Annual Net Sales Revenue: IDR 4,108,169,450.
- Difference between PostgreSQL and Power BI: IDR 0.
- Monthly aggregation and DAX measure behavior validated.

### Business Insights
1. March recorded the highest monthly revenue at IDR 364,363,775.
2. February recorded the lowest monthly revenue at IDR 309,946,525.
3. Revenue fluctuated throughout 2025 without a consistent month-over-month growth trend.
4. December revenue recovered compared with November, reaching IDR 352,725,980.
5. Further investigation is required to explain monthly fluctuations, including sales volume, discounts, product mix, and warehouse contributions.

### Status
Monthly Sales Trend Visualization — Completed and Validated.

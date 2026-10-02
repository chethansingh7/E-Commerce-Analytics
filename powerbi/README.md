# Power BI Dashboard

The Power BI report provides an interactive view of the SQL analysis and contains six analytical pages.

## Report Pages

### 1. Executive Overview

High-level business KPIs and overall sales performance.

### 2. Sales & Geography

Monthly sales trends and geographic sales contribution.

### 3. Customer Analysis

Customer counts, one-time versus repeat customers, and top customers by sales.

### 4. Product Analysis

Product sales, units sold, top products, and product-level sales versus volume.

### 5. Orders & Cancellations

Order value distribution and cancellation/return analysis.

### 6. RFM Segmentation

Customer segmentation based on Recency, Frequency, and Monetary value.

## Main Power BI Features Used

* Power Query
* DAX measures
* Calculated columns
* KPI cards
* Line charts
* Bar charts
* Donut charts
* Scatter charts
* Slicers
* Sorting and filtering
* Page-level filters

## Key Data Model Components

The report uses:

* `online_retail_clean` — cleaned positive-sales transaction data
* `online_retail` — raw transaction data used for cancellation analysis
* `Order_Summary` — order-level summary created in Power Query
* `RFM_Summary` — RFM segment summary used for the RFM dashboard

The `.pbix` file contains the complete Power BI report and data model used for the dashboard.

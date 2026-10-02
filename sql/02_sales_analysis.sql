/*
===========================================================
ONLINE RETAIL ANALYTICS
02_SALES_ANALYSIS.SQL

Purpose:
Analyze sales performance, monthly trends, growth, average
order value, and geographic contribution.

Database: SQLite
===========================================================
*/


/* =========================================================
1. OVERALL SALES KPI
========================================================= */

SELECT
    ROUND(SUM(Revenue), 2) AS SalesRevenue,
    SUM(CAST(Quantity AS INTEGER)) AS UnitsSold,
    COUNT(DISTINCT InvoiceNo) AS Orders,
    ROUND(
        SUM(Revenue) / COUNT(DISTINCT InvoiceNo),
        2
    ) AS AOV
FROM online_retail_clean;


/* =========================================================
2. MONTHLY SALES PERFORMANCE
========================================================= */

SELECT
    strftime('%Y-%m', InvoiceDate) AS SalesMonth,
    COUNT(DISTINCT InvoiceNo) AS Orders,
    SUM(CAST(Quantity AS INTEGER)) AS UnitsSold,
    ROUND(SUM(Revenue), 2) AS SalesRevenue,
    ROUND(
        SUM(Revenue) / COUNT(DISTINCT InvoiceNo),
        2
    ) AS AOV
FROM online_retail_clean
GROUP BY strftime('%Y-%m', InvoiceDate)
ORDER BY SalesMonth;


/* =========================================================
3. MONTH-OVER-MONTH SALES GROWTH
========================================================= */

WITH MonthlySales AS (
    SELECT
        strftime('%Y-%m', InvoiceDate) AS SalesMonth,
        ROUND(SUM(Revenue), 2) AS SalesRevenue
    FROM online_retail_clean
    GROUP BY strftime('%Y-%m', InvoiceDate)
),

SalesWithPreviousMonth AS (
    SELECT
        SalesMonth,
        SalesRevenue,
        LAG(SalesRevenue) OVER (
            ORDER BY SalesMonth
        ) AS PreviousMonthSales
    FROM MonthlySales
)

SELECT
    SalesMonth,
    SalesRevenue,
    PreviousMonthSales,
    ROUND(
        100.0 * (SalesRevenue - PreviousMonthSales)
        / PreviousMonthSales,
        2
    ) AS MoMGrowthPercent
FROM SalesWithPreviousMonth
ORDER BY SalesMonth;


/* =========================================================
4. SALES BY COUNTRY
========================================================= */

SELECT
    Country,
    COUNT(DISTINCT InvoiceNo) AS Orders,
    SUM(CAST(Quantity AS INTEGER)) AS UnitsSold,
    ROUND(SUM(Revenue), 2) AS SalesRevenue,
    ROUND(
        100.0 * SUM(Revenue)
        / (SELECT SUM(Revenue) FROM online_retail_clean),
        2
    ) AS SalesContributionPercent
FROM online_retail_clean
GROUP BY Country
ORDER BY SalesRevenue DESC;


/* =========================================================
5. TOP 10 COUNTRIES BY SALES
========================================================= */

SELECT
    Country,
    ROUND(SUM(Revenue), 2) AS SalesRevenue,
    COUNT(DISTINCT InvoiceNo) AS Orders,
    ROUND(
        100.0 * SUM(Revenue)
        / (SELECT SUM(Revenue) FROM online_retail_clean),
        2
    ) AS SalesContributionPercent
FROM online_retail_clean
GROUP BY Country
ORDER BY SalesRevenue DESC
LIMIT 10;


/* =========================================================
6. MONTHLY SALES RANKING
========================================================= */

WITH MonthlySales AS (
    SELECT
        strftime('%Y-%m', InvoiceDate) AS SalesMonth,
        ROUND(SUM(Revenue), 2) AS SalesRevenue
    FROM online_retail_clean
    GROUP BY strftime('%Y-%m', InvoiceDate)
)

SELECT
    SalesMonth,
    SalesRevenue,
    RANK() OVER (
        ORDER BY SalesRevenue DESC
    ) AS SalesRank
FROM MonthlySales
ORDER BY SalesRank;


/* =========================================================
7. CUMULATIVE SALES OVER TIME
========================================================= */

WITH MonthlySales AS (
    SELECT
        strftime('%Y-%m', InvoiceDate) AS SalesMonth,
        ROUND(SUM(Revenue), 2) AS SalesRevenue
    FROM online_retail_clean
    GROUP BY strftime('%Y-%m', InvoiceDate)
)

SELECT
    SalesMonth,
    SalesRevenue,
    ROUND(
        SUM(SalesRevenue) OVER (
            ORDER BY SalesMonth
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ),
        2
    ) AS CumulativeSales
FROM MonthlySales
ORDER BY SalesMonth;
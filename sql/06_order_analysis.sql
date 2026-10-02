/*
===========================================================
ONLINE RETAIL ANALYTICS
06_ORDER_ANALYSIS.SQL

Purpose:
Analyze order-level performance, order value, order size,
order frequency, and unusually large orders.

Database: SQLite
===========================================================
*/


/* 1. OVERALL ORDER KPI */

SELECT
    COUNT(DISTINCT InvoiceNo) AS Orders,
    ROUND(SUM(Revenue), 2) AS SalesRevenue,
    ROUND(
        SUM(Revenue) / COUNT(DISTINCT InvoiceNo),
        2
    ) AS AOV,
    ROUND(
        1.0 * SUM(CAST(Quantity AS INTEGER))
        / COUNT(DISTINCT InvoiceNo),
        2
    ) AS AvgUnitsPerOrder,
    ROUND(
        1.0 * COUNT(*)
        / COUNT(DISTINCT InvoiceNo),
        2
    ) AS AvgProductsPerOrder
FROM online_retail_clean;


/* 2. ORDER-LEVEL SALES PERFORMANCE */

SELECT
    InvoiceNo,
    MIN(InvoiceDate) AS OrderDate,
    COUNT(*) AS ProductLines,
    SUM(CAST(Quantity AS INTEGER)) AS UnitsSold,
    ROUND(SUM(Revenue), 2) AS OrderValue
FROM online_retail_clean
GROUP BY InvoiceNo
ORDER BY OrderValue DESC
LIMIT 20;


/* 3. ORDER VALUE DISTRIBUTION */

WITH OrderSummary AS (
    SELECT
        InvoiceNo,
        SUM(Revenue) AS OrderValue
    FROM online_retail_clean
    GROUP BY InvoiceNo
)
SELECT
    CASE
        WHEN OrderValue < 100 THEN 'Under £100'
        WHEN OrderValue < 500 THEN '£100-£499'
        WHEN OrderValue < 1000 THEN '£500-£999'
        WHEN OrderValue < 5000 THEN '£1,000-£4,999'
        ELSE '£5,000+'
    END AS OrderValueBand,
    COUNT(*) AS Orders,
    ROUND(SUM(OrderValue), 2) AS SalesRevenue,
    ROUND(
        100.0 * COUNT(*)
        / (SELECT COUNT(*) FROM OrderSummary),
        2
    ) AS OrderPercentage
FROM OrderSummary
GROUP BY OrderValueBand
ORDER BY
    CASE OrderValueBand
        WHEN 'Under £100' THEN 1
        WHEN '£100-£499' THEN 2
        WHEN '£500-£999' THEN 3
        WHEN '£1,000-£4,999' THEN 4
        WHEN '£5,000+' THEN 5
    END;


/* 4. ORDER SIZE DISTRIBUTION BY UNITS */

WITH OrderSummary AS (
    SELECT
        InvoiceNo,
        SUM(CAST(Quantity AS INTEGER)) AS UnitsSold
    FROM online_retail_clean
    GROUP BY InvoiceNo
)
SELECT
    CASE
        WHEN UnitsSold <= 10 THEN '1-10 Units'
        WHEN UnitsSold <= 50 THEN '11-50 Units'
        WHEN UnitsSold <= 100 THEN '51-100 Units'
        WHEN UnitsSold <= 500 THEN '101-500 Units'
        WHEN UnitsSold <= 1000 THEN '501-1,000 Units'
        ELSE '1,000+ Units'
    END AS OrderSizeBand,
    COUNT(*) AS Orders,
    SUM(UnitsSold) AS UnitsSold,
    ROUND(
        100.0 * COUNT(*)
        / (SELECT COUNT(*) FROM OrderSummary),
        2
    ) AS OrderPercentage
FROM OrderSummary
GROUP BY OrderSizeBand
ORDER BY
    CASE OrderSizeBand
        WHEN '1-10 Units' THEN 1
        WHEN '11-50 Units' THEN 2
        WHEN '51-100 Units' THEN 3
        WHEN '101-500 Units' THEN 4
        WHEN '501-1,000 Units' THEN 5
        WHEN '1,000+ Units' THEN 6
    END;


/* 5. TOP 20 ORDERS BY UNITS SOLD */

SELECT
    InvoiceNo,
    MIN(InvoiceDate) AS OrderDate,
    MAX(CustomerID) AS CustomerID,
    SUM(CAST(Quantity AS INTEGER)) AS UnitsSold,
    COUNT(*) AS ProductLines,
    ROUND(SUM(Revenue), 2) AS OrderValue
FROM online_retail_clean
GROUP BY InvoiceNo
ORDER BY UnitsSold DESC
LIMIT 20;


/* 6. TOP 20 ORDERS BY ORDER VALUE */

SELECT
    InvoiceNo,
    MIN(InvoiceDate) AS OrderDate,
    MAX(CustomerID) AS CustomerID,
    SUM(CAST(Quantity AS INTEGER)) AS UnitsSold,
    COUNT(*) AS ProductLines,
    ROUND(SUM(Revenue), 2) AS OrderValue
FROM online_retail_clean
GROUP BY InvoiceNo
ORDER BY OrderValue DESC
LIMIT 20;


/* 7. ORDER PRODUCT-LINE DISTRIBUTION */

WITH OrderSummary AS (
    SELECT
        InvoiceNo,
        COUNT(*) AS ProductLines
    FROM online_retail_clean
    GROUP BY InvoiceNo
)
SELECT
    CASE
        WHEN ProductLines = 1 THEN '1 Product Line'
        WHEN ProductLines BETWEEN 2 AND 5 THEN '2-5 Product Lines'
        WHEN ProductLines BETWEEN 6 AND 10 THEN '6-10 Product Lines'
        WHEN ProductLines BETWEEN 11 AND 20 THEN '11-20 Product Lines'
        ELSE '21+ Product Lines'
    END AS ProductLineBand,
    COUNT(*) AS Orders,
    ROUND(
        100.0 * COUNT(*)
        / (SELECT COUNT(*) FROM OrderSummary),
        2
    ) AS OrderPercentage
FROM OrderSummary
GROUP BY ProductLineBand
ORDER BY
    CASE ProductLineBand
        WHEN '1 Product Line' THEN 1
        WHEN '2-5 Product Lines' THEN 2
        WHEN '6-10 Product Lines' THEN 3
        WHEN '11-20 Product Lines' THEN 4
        WHEN '21+ Product Lines' THEN 5
    END;


/* 8. ORDER VALUE RANKING */

WITH OrderSummary AS (
    SELECT
        InvoiceNo,
        MIN(InvoiceDate) AS OrderDate,
        SUM(Revenue) AS OrderValue
    FROM online_retail_clean
    GROUP BY InvoiceNo
)
SELECT
    InvoiceNo,
    OrderDate,
    ROUND(OrderValue, 2) AS OrderValue,
    RANK() OVER (
        ORDER BY OrderValue DESC
    ) AS OrderValueRank
FROM OrderSummary
ORDER BY OrderValueRank
LIMIT 20;


/* 9. CUSTOMER ORDER FREQUENCY */

WITH CustomerOrders AS (
    SELECT
        CustomerID,
        COUNT(DISTINCT InvoiceNo) AS Orders
    FROM online_retail_clean
    WHERE CustomerID IS NOT NULL
      AND TRIM(CustomerID) <> ''
    GROUP BY CustomerID
)
SELECT
    CASE
        WHEN Orders = 1 THEN '1 Order'
        WHEN Orders BETWEEN 2 AND 5 THEN '2-5 Orders'
        WHEN Orders BETWEEN 6 AND 10 THEN '6-10 Orders'
        WHEN Orders BETWEEN 11 AND 20 THEN '11-20 Orders'
        ELSE '21+ Orders'
    END AS OrderFrequency,
    COUNT(*) AS Customers
FROM CustomerOrders
GROUP BY OrderFrequency
ORDER BY
    CASE OrderFrequency
        WHEN '1 Order' THEN 1
        WHEN '2-5 Orders' THEN 2
        WHEN '6-10 Orders' THEN 3
        WHEN '11-20 Orders' THEN 4
        WHEN '21+ Orders' THEN 5
    END;


/* 10. ORDER VALUE PERCENTILE */

WITH OrderSummary AS (
    SELECT
        InvoiceNo,
        SUM(Revenue) AS OrderValue
    FROM online_retail_clean
    GROUP BY InvoiceNo
)
SELECT
    InvoiceNo,
    ROUND(OrderValue, 2) AS OrderValue,
    ROUND(
        PERCENT_RANK() OVER (
            ORDER BY OrderValue
        ),
        4
    ) AS OrderValuePercentile
FROM OrderSummary
ORDER BY OrderValue DESC;


/* 11. CUMULATIVE ORDER SALES CONCENTRATION */

WITH OrderSummary AS (
    SELECT
        InvoiceNo,
        SUM(Revenue) AS OrderValue
    FROM online_retail_clean
    GROUP BY InvoiceNo
),
RankedOrders AS (
    SELECT
        InvoiceNo,
        OrderValue,
        SUM(OrderValue) OVER (
            ORDER BY OrderValue DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS CumulativeSales
    FROM OrderSummary
)
SELECT
    InvoiceNo,
    ROUND(OrderValue, 2) AS OrderValue,
    ROUND(CumulativeSales, 2) AS CumulativeSales,
    ROUND(
        100.0 * CumulativeSales
        / (SELECT SUM(OrderValue) FROM OrderSummary),
        2
    ) AS CumulativeSalesPercent
FROM RankedOrders
ORDER BY OrderValue DESC;
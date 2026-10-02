/*
===========================================================
ONLINE RETAIL ANALYTICS
07_RETURNS_ANALYSIS.SQL

Purpose:
Analyze cancellations/returns, their financial impact,
monthly patterns, country distribution, and affected products.

Important:
Returns/cancellations are analyzed from the raw
online_retail table because the cleaned sales table
contains only positive sales transactions.

Database: SQLite
===========================================================
*/


/* 1. OVERALL RETURNS / CANCELLATION KPI */

SELECT
    COUNT(DISTINCT InvoiceNo) AS CancellationInvoices,
    SUM(ABS(CAST(Quantity AS INTEGER))) AS CancelledUnits,
    ROUND(
        SUM(
            ABS(
                CAST(Quantity AS INTEGER)
                * CAST(UnitPrice AS REAL)
            )
        ),
        2
    ) AS CancellationValue
FROM online_retail
WHERE InvoiceNo LIKE 'C%'
  AND CAST(Quantity AS INTEGER) < 0;


/* 2. CANCELLATION RATE AND VALUE IMPACT */

WITH CancellationMetrics AS (
    SELECT
        COUNT(DISTINCT InvoiceNo) AS CancellationInvoices,
        SUM(
            ABS(CAST(Quantity AS INTEGER))
        ) AS CancelledUnits,
        SUM(
            ABS(
                CAST(Quantity AS INTEGER)
                * CAST(UnitPrice AS REAL)
            )
        ) AS CancellationValue
    FROM online_retail
    WHERE InvoiceNo LIKE 'C%'
      AND CAST(Quantity AS INTEGER) < 0
),
SalesMetrics AS (
    SELECT
        COUNT(DISTINCT InvoiceNo) AS SalesOrders,
        SUM(CAST(Quantity AS INTEGER)) AS UnitsSold,
        SUM(Revenue) AS SalesRevenue
    FROM online_retail_clean
)
SELECT
    CancellationInvoices,
    SalesOrders,
    ROUND(
        100.0 * CancellationInvoices / SalesOrders,
        2
    ) AS CancellationInvoiceRate,
    CancelledUnits,
    UnitsSold,
    ROUND(
        100.0 * CancelledUnits / UnitsSold,
        2
    ) AS CancelledUnitRate,
    ROUND(CancellationValue, 2) AS CancellationValue,
    ROUND(SalesRevenue, 2) AS SalesRevenue,
    ROUND(
        100.0 * CancellationValue / SalesRevenue,
        2
    ) AS CancellationValueRate
FROM CancellationMetrics, SalesMetrics;


/* 3. MONTHLY CANCELLATION ANALYSIS */

SELECT
    strftime('%Y-%m', InvoiceDate) AS ReturnMonth,
    COUNT(DISTINCT InvoiceNo) AS CancellationInvoices,
    SUM(ABS(CAST(Quantity AS INTEGER))) AS CancelledUnits,
    ROUND(
        SUM(
            ABS(
                CAST(Quantity AS INTEGER)
                * CAST(UnitPrice AS REAL)
            )
        ),
        2
    ) AS CancellationValue
FROM online_retail
WHERE InvoiceNo LIKE 'C%'
  AND CAST(Quantity AS INTEGER) < 0
GROUP BY strftime('%Y-%m', InvoiceDate)
ORDER BY ReturnMonth;


/* 4. CANCELLATIONS BY COUNTRY */

SELECT
    Country,
    COUNT(DISTINCT InvoiceNo) AS CancellationInvoices,
    SUM(ABS(CAST(Quantity AS INTEGER))) AS CancelledUnits,
    ROUND(
        SUM(
            ABS(
                CAST(Quantity AS INTEGER)
                * CAST(UnitPrice AS REAL)
            )
        ),
        2
    ) AS CancellationValue
FROM online_retail
WHERE InvoiceNo LIKE 'C%'
  AND CAST(Quantity AS INTEGER) < 0
GROUP BY Country
ORDER BY CancellationValue DESC;


/* 5. TOP 20 CANCELLED PRODUCTS BY VALUE */

SELECT
    StockCode,
    Description,
    SUM(ABS(CAST(Quantity AS INTEGER))) AS CancelledUnits,
    COUNT(DISTINCT InvoiceNo) AS CancellationInvoices,
    ROUND(
        SUM(
            ABS(
                CAST(Quantity AS INTEGER)
                * CAST(UnitPrice AS REAL)
            )
        ),
        2
    ) AS CancellationValue
FROM online_retail
WHERE InvoiceNo LIKE 'C%'
  AND CAST(Quantity AS INTEGER) < 0
GROUP BY StockCode, Description
ORDER BY CancellationValue DESC
LIMIT 20;


/* 6. TOP 20 CANCELLED PRODUCTS BY UNITS */

SELECT
    StockCode,
    Description,
    SUM(ABS(CAST(Quantity AS INTEGER))) AS CancelledUnits,
    COUNT(DISTINCT InvoiceNo) AS CancellationInvoices,
    ROUND(
        SUM(
            ABS(
                CAST(Quantity AS INTEGER)
                * CAST(UnitPrice AS REAL)
            )
        ),
        2
    ) AS CancellationValue
FROM online_retail
WHERE InvoiceNo LIKE 'C%'
  AND CAST(Quantity AS INTEGER) < 0
GROUP BY StockCode, Description
ORDER BY CancelledUnits DESC
LIMIT 20;


/* 7. CUSTOMERS WITH HIGHEST CANCELLATION VALUE */

SELECT
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS CancellationInvoices,
    SUM(ABS(CAST(Quantity AS INTEGER))) AS CancelledUnits,
    ROUND(
        SUM(
            ABS(
                CAST(Quantity AS INTEGER)
                * CAST(UnitPrice AS REAL)
            )
        ),
        2
    ) AS CancellationValue
FROM online_retail
WHERE InvoiceNo LIKE 'C%'
  AND CAST(Quantity AS INTEGER) < 0
  AND CustomerID IS NOT NULL
  AND TRIM(CustomerID) <> ''
GROUP BY CustomerID
ORDER BY CancellationValue DESC
LIMIT 20;


/* 8. LARGEST INDIVIDUAL CANCELLATION INVOICES */

SELECT
    InvoiceNo,
    MIN(InvoiceDate) AS ReturnDate,
    MAX(CustomerID) AS CustomerID,
    SUM(ABS(CAST(Quantity AS INTEGER))) AS CancelledUnits,
    COUNT(*) AS ProductLines,
    ROUND(
        SUM(
            ABS(
                CAST(Quantity AS INTEGER)
                * CAST(UnitPrice AS REAL)
            )
        ),
        2
    ) AS CancellationValue
FROM online_retail
WHERE InvoiceNo LIKE 'C%'
  AND CAST(Quantity AS INTEGER) < 0
GROUP BY InvoiceNo
ORDER BY CancellationValue DESC
LIMIT 20;
/*
===========================================================
ONLINE RETAIL ANALYTICS
01_DATA_QUALITY.SQL

Purpose:
Audit the raw transaction data, identify data-quality issues,
and validate the cleaned sales dataset.

Database: SQLite
===========================================================
*/


/* =========================================================
1. RAW DATASET SIZE
========================================================= */

SELECT
    COUNT(*) AS TotalRows
FROM online_retail;


/* =========================================================
2. TRANSACTION DATE RANGE
========================================================= */

SELECT
    MIN(InvoiceDate) AS FirstTransaction,
    MAX(InvoiceDate) AS LastTransaction
FROM online_retail;


/* =========================================================
3. MISSING CUSTOMER IDs
========================================================= */

SELECT
    COUNT(*) AS MissingCustomerIDRows,
    ROUND(
        100.0 * COUNT(*) / (SELECT COUNT(*) FROM online_retail),
        2
    ) AS MissingCustomerIDPercent
FROM online_retail
WHERE CustomerID IS NULL
   OR TRIM(CustomerID) = '';


/* =========================================================
4. UNIQUE CUSTOMER IDs
========================================================= */

SELECT
    COUNT(DISTINCT CustomerID) AS UniqueCustomers
FROM online_retail
WHERE CustomerID IS NOT NULL;


/* =========================================================
5. NEGATIVE QUANTITY TRANSACTIONS
========================================================= */

SELECT
    COUNT(*) AS NegativeQuantityRows,
    COUNT(DISTINCT InvoiceNo) AS AffectedInvoices
FROM online_retail
WHERE CAST(Quantity AS INTEGER) < 0;


/* =========================================================
6. CANCELLATION TRANSACTIONS
========================================================= */

SELECT
    COUNT(*) AS CancellationRows,
    COUNT(DISTINCT InvoiceNo) AS CancellationInvoices
FROM online_retail
WHERE InvoiceNo LIKE 'C%'
  AND CAST(Quantity AS INTEGER) < 0;


/* =========================================================
7. CANCELLATION VALUE
========================================================= */

SELECT
    SUM(
        ABS(
            CAST(Quantity AS INTEGER) *
            CAST(UnitPrice AS REAL)
        )
    ) AS CancellationValue
FROM online_retail
WHERE InvoiceNo LIKE 'C%'
  AND CAST(Quantity AS INTEGER) < 0;


/* =========================================================
8. NON-POSITIVE UNIT PRICES
========================================================= */

SELECT
    COUNT(*) AS InvalidUnitPriceRows
FROM online_retail
WHERE CAST(UnitPrice AS REAL) <= 0;


/* =========================================================
9. MISSING OR BLANK PRODUCT DESCRIPTIONS
========================================================= */

SELECT
    COUNT(*) AS MissingDescriptionRows
FROM online_retail
WHERE Description IS NULL
   OR TRIM(Description) = '';


/* =========================================================
10. BLANK DESCRIPTION + NEGATIVE QUANTITY + ZERO PRICE
========================================================= */

SELECT
    COUNT(*) AS SuspiciousRows
FROM online_retail
WHERE (Description IS NULL OR TRIM(Description) = '')
  AND CAST(Quantity AS INTEGER) < 0
  AND CAST(UnitPrice AS REAL) = 0;


/* =========================================================
11. CLEANED DATASET SIZE
========================================================= */

SELECT
    COUNT(*) AS CleanedRows
FROM online_retail_clean;


/* =========================================================
12. VALIDATE CLEANED QUANTITIES
========================================================= */

SELECT
    COUNT(*) AS NonPositiveQuantityRows
FROM online_retail_clean
WHERE CAST(Quantity AS INTEGER) <= 0;


/* =========================================================
13. VALIDATE CLEANED UNIT PRICES
========================================================= */

SELECT
    COUNT(*) AS NonPositiveUnitPriceRows
FROM online_retail_clean
WHERE CAST(UnitPrice AS REAL) <= 0;


/* =========================================================
14. FINAL CLEANED SALES KPI CHECK
========================================================= */

SELECT
    COUNT(*) AS CleanSalesRows,
    SUM(CAST(Quantity AS INTEGER)) AS UnitsSold,
    COUNT(DISTINCT InvoiceNo) AS Orders,
    ROUND(SUM(Revenue), 2) AS SalesRevenue
FROM online_retail_clean;
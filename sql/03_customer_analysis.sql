/*
===========================================================
ONLINE RETAIL ANALYTICS
03_CUSTOMER_ANALYSIS.SQL

Purpose:
Analyze customer coverage, customer value, repeat behavior,
customer concentration, and customer-level performance.

Database: SQLite
===========================================================
*/


/* 1. CUSTOMER KPI */

SELECT
    COUNT(DISTINCT CustomerID) AS IdentifiedCustomers,
    COUNT(DISTINCT CASE
        WHEN CustomerID IS NULL OR TRIM(CustomerID) = ''
        THEN InvoiceNo
    END) AS UnknownCustomerOrders
FROM online_retail_clean;


/* 2. IDENTIFIED VS UNKNOWN CUSTOMER SALES */

SELECT
    CASE
        WHEN CustomerID IS NULL OR TRIM(CustomerID) = ''
        THEN 'Unknown'
        ELSE 'Identified'
    END AS CustomerType,
    COUNT(DISTINCT InvoiceNo) AS Orders,
    SUM(CAST(Quantity AS INTEGER)) AS UnitsSold,
    ROUND(SUM(Revenue), 2) AS SalesRevenue,
    ROUND(
        100.0 * SUM(Revenue)
        / (SELECT SUM(Revenue) FROM online_retail_clean),
        2
    ) AS SalesContributionPercent
FROM online_retail_clean
GROUP BY CustomerType
ORDER BY SalesRevenue DESC;


/* 3. TOP 20 CUSTOMERS BY SALES */

SELECT
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS Orders,
    SUM(CAST(Quantity AS INTEGER)) AS UnitsSold,
    ROUND(SUM(Revenue), 2) AS SalesRevenue
FROM online_retail_clean
WHERE CustomerID IS NOT NULL
  AND TRIM(CustomerID) <> ''
GROUP BY CustomerID
ORDER BY SalesRevenue DESC
LIMIT 20;


/* 4. CUSTOMER ORDER FREQUENCY */

SELECT
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS Orders,
    ROUND(SUM(Revenue), 2) AS SalesRevenue
FROM online_retail_clean
WHERE CustomerID IS NOT NULL
  AND TRIM(CustomerID) <> ''
GROUP BY CustomerID
ORDER BY Orders DESC, SalesRevenue DESC
LIMIT 20;


/* 5. REPEAT VS ONE-TIME CUSTOMERS */

WITH CustomerOrders AS (
    SELECT
        CustomerID,
        COUNT(DISTINCT InvoiceNo) AS Orders,
        SUM(Revenue) AS SalesRevenue
    FROM online_retail_clean
    WHERE CustomerID IS NOT NULL
      AND TRIM(CustomerID) <> ''
    GROUP BY CustomerID
)
SELECT
    CASE
        WHEN Orders = 1 THEN 'One-Time'
        ELSE 'Repeat'
    END AS CustomerType,
    COUNT(*) AS Customers,
    ROUND(SUM(SalesRevenue), 2) AS SalesRevenue,
    ROUND(AVG(SalesRevenue), 2) AS AverageCustomerSales
FROM CustomerOrders
GROUP BY CustomerType
ORDER BY Customers;


/* 6. CUSTOMER SALES PERCENTILE RANK */

WITH CustomerSales AS (
    SELECT
        CustomerID,
        ROUND(SUM(Revenue), 2) AS SalesRevenue
    FROM online_retail_clean
    WHERE CustomerID IS NOT NULL
      AND TRIM(CustomerID) <> ''
    GROUP BY CustomerID
)
SELECT
    CustomerID,
    SalesRevenue,
    ROUND(
        PERCENT_RANK() OVER (
            ORDER BY SalesRevenue
        ),
        4
    ) AS SalesPercentile
FROM CustomerSales
ORDER BY SalesRevenue DESC;


/* 7. TOP 10% CUSTOMERS BY SALES */

WITH CustomerSales AS (
    SELECT
        CustomerID,
        SUM(Revenue) AS SalesRevenue
    FROM online_retail_clean
    WHERE CustomerID IS NOT NULL
      AND TRIM(CustomerID) <> ''
    GROUP BY CustomerID
),
RankedCustomers AS (
    SELECT
        CustomerID,
        SalesRevenue,
        NTILE(10) OVER (
            ORDER BY SalesRevenue DESC
        ) AS SalesDecile
    FROM CustomerSales
)
SELECT
    SalesDecile,
    COUNT(*) AS Customers,
    ROUND(SUM(SalesRevenue), 2) AS SalesRevenue
FROM RankedCustomers
GROUP BY SalesDecile
ORDER BY SalesDecile;


/* 8. CUSTOMER AVERAGE ORDER VALUE */

SELECT
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS Orders,
    ROUND(SUM(Revenue), 2) AS SalesRevenue,
    ROUND(
        SUM(Revenue) / COUNT(DISTINCT InvoiceNo),
        2
    ) AS CustomerAOV
FROM online_retail_clean
WHERE CustomerID IS NOT NULL
  AND TRIM(CustomerID) <> ''
GROUP BY CustomerID
ORDER BY CustomerAOV DESC
LIMIT 20;


/* 9. CUSTOMER UNITS AND SALES */

SELECT
    CustomerID,
    SUM(CAST(Quantity AS INTEGER)) AS UnitsSold,
    ROUND(SUM(Revenue), 2) AS SalesRevenue,
    ROUND(
        SUM(Revenue) / SUM(CAST(Quantity AS INTEGER)),
        2
    ) AS SalesPerUnit
FROM online_retail_clean
WHERE CustomerID IS NOT NULL
  AND TRIM(CustomerID) <> ''
GROUP BY CustomerID
ORDER BY SalesRevenue DESC
LIMIT 20;


/* 10. CUSTOMER FIRST AND LAST PURCHASE */

SELECT
    CustomerID,
    MIN(InvoiceDate) AS FirstPurchase,
    MAX(InvoiceDate) AS LastPurchase,
    COUNT(DISTINCT InvoiceNo) AS Orders,
    ROUND(SUM(Revenue), 2) AS SalesRevenue
FROM online_retail_clean
WHERE CustomerID IS NOT NULL
  AND TRIM(CustomerID) <> ''
GROUP BY CustomerID
ORDER BY LastPurchase;


/* 11. CUSTOMER PURCHASE LIFESPAN */

SELECT
    CustomerID,
    MIN(InvoiceDate) AS FirstPurchase,
    MAX(InvoiceDate) AS LastPurchase,
    ROUND(
        julianday(MAX(InvoiceDate))
        - julianday(MIN(InvoiceDate)),
        1
    ) AS CustomerLifespanDays,
    COUNT(DISTINCT InvoiceNo) AS Orders,
    ROUND(SUM(Revenue), 2) AS SalesRevenue
FROM online_retail_clean
WHERE CustomerID IS NOT NULL
  AND TRIM(CustomerID) <> ''
GROUP BY CustomerID
ORDER BY CustomerLifespanDays DESC;


/* 12. CUSTOMER MONTHLY PURCHASE ACTIVITY */

SELECT
    CustomerID,
    strftime('%Y-%m', InvoiceDate) AS SalesMonth,
    COUNT(DISTINCT InvoiceNo) AS Orders,
    ROUND(SUM(Revenue), 2) AS SalesRevenue
FROM online_retail_clean
WHERE CustomerID IS NOT NULL
  AND TRIM(CustomerID) <> ''
GROUP BY
    CustomerID,
    strftime('%Y-%m', InvoiceDate)
ORDER BY CustomerID, SalesMonth;


/* 13. CUSTOMER ORDER NUMBER SEQUENCE */

WITH CustomerOrders AS (
    SELECT DISTINCT
        CustomerID,
        InvoiceNo,
        InvoiceDate
    FROM online_retail_clean
    WHERE CustomerID IS NOT NULL
      AND TRIM(CustomerID) <> ''
)
SELECT
    CustomerID,
    InvoiceNo,
    InvoiceDate,
    ROW_NUMBER() OVER (
        PARTITION BY CustomerID
        ORDER BY InvoiceDate
    ) AS CustomerOrderNumber
FROM CustomerOrders
ORDER BY CustomerID, CustomerOrderNumber;


/* 14. CUSTOMER PURCHASE GAPS */

WITH CustomerOrders AS (
    SELECT DISTINCT
        CustomerID,
        InvoiceNo,
        InvoiceDate
    FROM online_retail_clean
    WHERE CustomerID IS NOT NULL
      AND TRIM(CustomerID) <> ''
),
PreviousOrders AS (
    SELECT
        CustomerID,
        InvoiceNo,
        InvoiceDate,
        LAG(InvoiceDate) OVER (
            PARTITION BY CustomerID
            ORDER BY InvoiceDate
        ) AS PreviousPurchase
    FROM CustomerOrders
)
SELECT
    CustomerID,
    InvoiceNo,
    InvoiceDate,
    PreviousPurchase,
    ROUND(
        julianday(InvoiceDate)
        - julianday(PreviousPurchase),
        1
    ) AS DaysSincePreviousPurchase
FROM PreviousOrders
WHERE PreviousPurchase IS NOT NULL
ORDER BY DaysSincePreviousPurchase DESC;


/* 15. CUSTOMER PURCHASE MONTHS */

SELECT
    CustomerID,
    COUNT(DISTINCT strftime('%Y-%m', InvoiceDate)) AS ActivePurchaseMonths,
    COUNT(DISTINCT InvoiceNo) AS Orders,
    ROUND(SUM(Revenue), 2) AS SalesRevenue
FROM online_retail_clean
WHERE CustomerID IS NOT NULL
  AND TRIM(CustomerID) <> ''
GROUP BY CustomerID
ORDER BY ActivePurchaseMonths DESC, SalesRevenue DESC;


/* 16. CUSTOMER SALES RANK */

WITH CustomerSales AS (
    SELECT
        CustomerID,
        SUM(Revenue) AS SalesRevenue
    FROM online_retail_clean
    WHERE CustomerID IS NOT NULL
      AND TRIM(CustomerID) <> ''
    GROUP BY CustomerID
)
SELECT
    CustomerID,
    ROUND(SalesRevenue, 2) AS SalesRevenue,
    RANK() OVER (
        ORDER BY SalesRevenue DESC
    ) AS SalesRank
FROM CustomerSales
ORDER BY SalesRank;


/* 17. CUSTOMER ORDER FREQUENCY DISTRIBUTION */

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


/* 18. CUSTOMER SALES CONTRIBUTION */

WITH CustomerSales AS (
    SELECT
        CustomerID,
        SUM(Revenue) AS SalesRevenue
    FROM online_retail_clean
    WHERE CustomerID IS NOT NULL
      AND TRIM(CustomerID) <> ''
    GROUP BY CustomerID
)
SELECT
    CustomerID,
    ROUND(SalesRevenue, 2) AS SalesRevenue,
    ROUND(
        100.0 * SalesRevenue
        / (SELECT SUM(SalesRevenue) FROM CustomerSales),
        2
    ) AS CustomerSalesContributionPercent
FROM CustomerSales
ORDER BY SalesRevenue DESC;


/* 19. TOP 20 CUSTOMERS BY UNITS SOLD */

SELECT
    CustomerID,
    SUM(CAST(Quantity AS INTEGER)) AS UnitsSold,
    COUNT(DISTINCT InvoiceNo) AS Orders,
    ROUND(SUM(Revenue), 2) AS SalesRevenue
FROM online_retail_clean
WHERE CustomerID IS NOT NULL
  AND TRIM(CustomerID) <> ''
GROUP BY CustomerID
ORDER BY UnitsSold DESC
LIMIT 20;


/* 20. CUSTOMER VALUE SUMMARY */

WITH CustomerSummary AS (
    SELECT
        CustomerID,
        COUNT(DISTINCT InvoiceNo) AS Orders,
        SUM(CAST(Quantity AS INTEGER)) AS UnitsSold,
        SUM(Revenue) AS SalesRevenue,
        MIN(InvoiceDate) AS FirstPurchase,
        MAX(InvoiceDate) AS LastPurchase
    FROM online_retail_clean
    WHERE CustomerID IS NOT NULL
      AND TRIM(CustomerID) <> ''
    GROUP BY CustomerID
)
SELECT
    COUNT(*) AS IdentifiedCustomers,
    ROUND(SUM(SalesRevenue), 2) AS SalesRevenue,
    SUM(UnitsSold) AS UnitsSold,
    ROUND(AVG(SalesRevenue), 2) AS AverageCustomerSales,
    ROUND(AVG(Orders), 2) AS AverageOrdersPerCustomer,
    ROUND(
        AVG(
            julianday(LastPurchase)
            - julianday(FirstPurchase)
        ),
        2
    ) AS AverageCustomerLifespanDays
FROM CustomerSummary;
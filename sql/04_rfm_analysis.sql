/*
===========================================================
ONLINE RETAIL ANALYTICS
04_RFM_ANALYSIS.SQL

Purpose:
Segment identified customers using Recency, Frequency,
and Monetary value.

RFM Metrics:
Recency  = Days since the customer's last purchase
Frequency = Number of distinct orders
Monetary  = Total customer sales

Segmentation thresholds:
Recency   <= 50 days  = Recent
Orders    >= 2        = Frequent
GrossSales >= 674.49  = High Value

Database: SQLite
===========================================================
*/


/* 1. CUSTOMER RFM METRICS */

WITH customer_metrics AS (
    SELECT
        CustomerID,
        MAX(InvoiceDate) AS LastPurchase,
        COUNT(DISTINCT InvoiceNo) AS Orders,
        ROUND(SUM(Revenue), 2) AS GrossSales
    FROM online_retail_clean
    WHERE CustomerID IS NOT NULL
      AND TRIM(CustomerID) <> ''
      AND CAST(Quantity AS INTEGER) > 0
      AND CAST(UnitPrice AS REAL) > 0
    GROUP BY CustomerID
)
SELECT
    CustomerID,
    LastPurchase,
    ROUND(
        julianday(
            (SELECT MAX(InvoiceDate) FROM online_retail_clean)
        ) - julianday(LastPurchase),
        1
    ) AS RecencyDays,
    Orders,
    GrossSales
FROM customer_metrics
ORDER BY RecencyDays;


/* 2. CUSTOMER RFM GROUPS */

WITH customer_metrics AS (
    SELECT
        CustomerID,
        MAX(InvoiceDate) AS LastPurchase,
        COUNT(DISTINCT InvoiceNo) AS Orders,
        ROUND(SUM(Revenue), 2) AS GrossSales
    FROM online_retail_clean
    WHERE CustomerID IS NOT NULL
      AND TRIM(CustomerID) <> ''
      AND CAST(Quantity AS INTEGER) > 0
      AND CAST(UnitPrice AS REAL) > 0
    GROUP BY CustomerID
),
customer_rfm AS (
    SELECT
        CustomerID,
        ROUND(
            julianday(
                (SELECT MAX(InvoiceDate) FROM online_retail_clean)
            ) - julianday(LastPurchase),
            1
        ) AS RecencyDays,
        Orders,
        GrossSales
    FROM customer_metrics
)
SELECT
    CASE
        WHEN RecencyDays <= 50
         AND Orders >= 2
         AND GrossSales >= 674.49
            THEN 'Recent / Frequent / High Value'

        WHEN RecencyDays > 50
         AND Orders >= 2
         AND GrossSales >= 674.49
            THEN 'Less Recent / Frequent / High Value'

        WHEN RecencyDays <= 50
         AND Orders >= 2
         AND GrossSales < 674.49
            THEN 'Recent / Frequent / Lower Value'

        WHEN RecencyDays > 50
         AND Orders >= 2
         AND GrossSales < 674.49
            THEN 'Less Recent / Frequent / Lower Value'

        WHEN RecencyDays <= 50
         AND Orders = 1
         AND GrossSales >= 674.49
            THEN 'Recent / Infrequent / High Value'

        WHEN RecencyDays > 50
         AND Orders = 1
         AND GrossSales >= 674.49
            THEN 'Less Recent / Infrequent / High Value'

        WHEN RecencyDays <= 50
         AND Orders = 1
         AND GrossSales < 674.49
            THEN 'Recent / Infrequent / Lower Value'

        WHEN RecencyDays > 50
         AND Orders = 1
         AND GrossSales < 674.49
            THEN 'Less Recent / Infrequent / Lower Value'

        ELSE 'Unclassified'
    END AS RFMGroup,
    COUNT(*) AS Customers,
    ROUND(SUM(GrossSales), 2) AS GrossSales
FROM customer_rfm
GROUP BY RFMGroup
ORDER BY GrossSales DESC;


/* 3. BUSINESS-READABLE RFM SEGMENTS */

WITH customer_metrics AS (
    SELECT
        CustomerID,
        MAX(InvoiceDate) AS LastPurchase,
        COUNT(DISTINCT InvoiceNo) AS Orders,
        ROUND(SUM(Revenue), 2) AS GrossSales
    FROM online_retail_clean
    WHERE CustomerID IS NOT NULL
      AND TRIM(CustomerID) <> ''
      AND CAST(Quantity AS INTEGER) > 0
      AND CAST(UnitPrice AS REAL) > 0
    GROUP BY CustomerID
),
customer_rfm AS (
    SELECT
        CustomerID,
        ROUND(
            julianday(
                (SELECT MAX(InvoiceDate) FROM online_retail_clean)
            ) - julianday(LastPurchase),
            1
        ) AS RecencyDays,
        Orders,
        GrossSales
    FROM customer_metrics
),
segmented_customers AS (
    SELECT
        CustomerID,
        RecencyDays,
        Orders,
        GrossSales,
        CASE
            WHEN RecencyDays <= 50
             AND Orders >= 2
             AND GrossSales >= 674.49
                THEN 'Champions'

            WHEN RecencyDays > 50
             AND Orders >= 2
             AND GrossSales >= 674.49
                THEN 'High-Value At Risk'

            WHEN RecencyDays > 50
             AND Orders = 1
             AND GrossSales >= 674.49
                THEN 'High-Value Dormant'

            WHEN RecencyDays <= 50
             AND Orders >= 2
             AND GrossSales < 674.49
                THEN 'Loyal / Growing'

            WHEN RecencyDays <= 50
             AND Orders = 1
             AND GrossSales >= 674.49
                THEN 'New High-Value'

            WHEN RecencyDays <= 50
             AND Orders = 1
             AND GrossSales < 674.49
                THEN 'Recent / New Customers'

            WHEN RecencyDays > 50
             AND Orders >= 2
             AND GrossSales < 674.49
                THEN 'Regular Low-Value'

            WHEN RecencyDays > 50
             AND Orders = 1
             AND GrossSales < 674.49
                THEN 'Low-Engagement / Dormant'

            ELSE 'Unclassified'
        END AS CustomerSegment
    FROM customer_rfm
)
SELECT
    CustomerSegment,
    COUNT(*) AS Customers,
    ROUND(SUM(GrossSales), 2) AS GrossSales,
    ROUND(
        100.0 * SUM(GrossSales)
        / (SELECT SUM(GrossSales) FROM segmented_customers),
        2
    ) AS SalesPercentage
FROM segmented_customers
GROUP BY CustomerSegment
ORDER BY GrossSales DESC;
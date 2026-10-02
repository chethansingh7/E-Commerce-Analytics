/*
===========================================================
ONLINE RETAIL ANALYTICS
05_PRODUCT_ANALYSIS.SQL

Purpose:
Analyze product-level sales performance, product demand,
sales contribution, order frequency, and high-volume products.

Merchandise exclusions:
M
AMAZONFEE
POST
CRUK
BANK CHARGES
D
S

Database: SQLite
===========================================================
*/


/* 1. PRODUCT KPI */
SELECT
    COUNT(DISTINCT StockCode) AS MerchandiseProducts,
    ROUND(SUM(Revenue), 2) AS SalesRevenue,
    SUM(CAST(Quantity AS INTEGER)) AS UnitsSold,
    ROUND(
        SUM(Revenue) / COUNT(DISTINCT StockCode),
        2
    ) AS AverageProductSales
FROM online_retail_clean
WHERE StockCode NOT IN (
    'DOT',
    'M',
    'POST',
    'AMAZONFEE',
    'B',
    'C2',
    '23444',
    'BANK CHARGES',
    '23574',
    'S'
);

/* 2. PRODUCT SALES PERFORMANCE */
SELECT
    StockCode,
    Description,
    COUNT(DISTINCT InvoiceNo) AS Orders,
    SUM(CAST(Quantity AS INTEGER)) AS UnitsSold,
    ROUND(SUM(Revenue), 2) AS SalesRevenue
FROM online_retail_clean
WHERE StockCode NOT IN (
    'DOT',
    'M',
    'POST',
    'AMAZONFEE',
    'B',
    'C2',
    '23444',
    'BANK CHARGES',
    '23574',
    'S'
)
GROUP BY StockCode, Description
ORDER BY SalesRevenue DESC;

/* 3. TOP 20 PRODUCTS BY SALES */
SELECT
    StockCode,
    Description,
    COUNT(DISTINCT InvoiceNo) AS Orders,
    SUM(CAST(Quantity AS INTEGER)) AS UnitsSold,
    ROUND(SUM(Revenue), 2) AS SalesRevenue
FROM online_retail_clean
WHERE StockCode NOT IN (
    'DOT',
    'M',
    'POST',
    'AMAZONFEE',
    'B',
    'C2',
    '23444',
    'BANK CHARGES',
    '23574',
    'S'
)
GROUP BY StockCode, Description
ORDER BY SalesRevenue DESC
LIMIT 20;

/* 4. PRODUCT SALES CONTRIBUTION */

WITH ProductSales AS (
    SELECT
        StockCode,
        Description,
        SUM(Revenue) AS SalesRevenue
    FROM online_retail_clean
    WHERE StockCode NOT IN (
        'DOT',
        'M',
        'POST',
        'AMAZONFEE',
        'B',
        'C2',
        '23444',
        'BANK CHARGES',
        '23574',
        'S'
    )
    GROUP BY StockCode, Description
)
SELECT
    StockCode,
    Description,
    ROUND(SalesRevenue, 2) AS SalesRevenue,
    ROUND(
        100.0 * SalesRevenue
        / (SELECT SUM(SalesRevenue) FROM ProductSales),
        2
    ) AS SalesContributionPercent
FROM ProductSales
ORDER BY SalesRevenue DESC;

/* 5. PRODUCT ORDER FREQUENCY */

SELECT
    StockCode,
    Description,
    COUNT(DISTINCT InvoiceNo) AS Orders,
    SUM(CAST(Quantity AS INTEGER)) AS UnitsSold,
    ROUND(SUM(Revenue), 2) AS SalesRevenue
FROM online_retail_clean
WHERE StockCode NOT IN (
    'DOT',
    'M',
    'POST',
    'AMAZONFEE',
    'B',
    'C2',
    '23444',
    'BANK CHARGES',
    '23574',
    'S'
)
GROUP BY StockCode, Description
ORDER BY Orders DESC, SalesRevenue DESC;

/* 6. TOP 20 PRODUCTS BY UNITS SOLD */

SELECT
    StockCode,
    Description,
    SUM(CAST(Quantity AS INTEGER)) AS UnitsSold,
    COUNT(DISTINCT InvoiceNo) AS Orders,
    ROUND(SUM(Revenue), 2) AS SalesRevenue
FROM online_retail_clean
WHERE StockCode NOT IN (
    'DOT',
    'M',
    'POST',
    'AMAZONFEE',
    'B',
    'C2',
    '23444',
    'BANK CHARGES',
    '23574',
    'S'
)
GROUP BY StockCode, Description
ORDER BY UnitsSold DESC
LIMIT 20;

/* 7. PRODUCT AVERAGE ORDER QUANTITY */

SELECT
    StockCode,
    Description,
    SUM(CAST(Quantity AS INTEGER)) AS UnitsSold,
    COUNT(DISTINCT InvoiceNo) AS Orders,
    ROUND(
        1.0 * SUM(CAST(Quantity AS INTEGER))
        / COUNT(DISTINCT InvoiceNo),
        2
    ) AS AvgUnitsPerOrder,
    ROUND(SUM(Revenue), 2) AS SalesRevenue
FROM online_retail_clean
WHERE StockCode NOT IN (
    'DOT',
    'M',
    'POST',
    'AMAZONFEE',
    'B',
    'C2',
    '23444',
    'BANK CHARGES',
    '23574',
    'S'
)
GROUP BY StockCode, Description
HAVING COUNT(DISTINCT InvoiceNo) >= 2
ORDER BY AvgUnitsPerOrder DESC;

/* 8. PRODUCT SALES PER UNIT */
SELECT
    StockCode,
    Description,
    SUM(CAST(Quantity AS INTEGER)) AS UnitsSold,
    ROUND(SUM(Revenue), 2) AS SalesRevenue,
    ROUND(
        SUM(Revenue)
        / SUM(CAST(Quantity AS INTEGER)),
        2
    ) AS SalesPerUnit
FROM online_retail_clean
WHERE StockCode NOT IN (
    'DOT',
    'M',
    'POST',
    'AMAZONFEE',
    'B',
    'C2',
    '23444',
    'BANK CHARGES',
    '23574',
    'S'
)
GROUP BY StockCode, Description
HAVING SUM(CAST(Quantity AS INTEGER)) > 0
ORDER BY SalesRevenue DESC;


/* 9. PRODUCTS WITH REPEAT ORDERS */

SELECT
    StockCode,
    Description,
    COUNT(DISTINCT InvoiceNo) AS Orders,
    SUM(CAST(Quantity AS INTEGER)) AS UnitsSold,
    ROUND(SUM(Revenue), 2) AS SalesRevenue
FROM online_retail_clean
WHERE StockCode NOT IN (
    'DOT',
    'M',
    'POST',
    'AMAZONFEE',
    'B',
    'C2',
    '23444',
    'BANK CHARGES',
    '23574',
    'S'
)
GROUP BY StockCode, Description
HAVING COUNT(DISTINCT InvoiceNo) >= 2
ORDER BY SalesRevenue DESC;

/* 10. PRODUCT SALES RANK */

WITH ProductSales AS (
    SELECT
        StockCode,
        Description,
        SUM(Revenue) AS SalesRevenue
    FROM online_retail_clean
    WHERE StockCode NOT IN (
        'DOT',
        'M',
        'POST',
        'AMAZONFEE',
        'B',
        'C2',
        '23444',
        'BANK CHARGES',
        '23574',
        'S'
    )
    GROUP BY StockCode, Description
)
SELECT
    StockCode,
    Description,
    ROUND(SalesRevenue, 2) AS SalesRevenue,
    RANK() OVER (
        ORDER BY SalesRevenue DESC
    ) AS SalesRank
FROM ProductSales
ORDER BY SalesRank;

/* 11. PRODUCT SALES PERCENTILE */

WITH ProductSales AS (
    SELECT
        StockCode,
        Description,
        SUM(Revenue) AS SalesRevenue
    FROM online_retail_clean
    WHERE StockCode NOT IN (
        'DOT',
        'M',
        'POST',
        'AMAZONFEE',
        'B',
        'C2',
        '23444',
        'BANK CHARGES',
        '23574',
        'S'
    )
    GROUP BY StockCode, Description
)
SELECT
    StockCode,
    Description,
    ROUND(SalesRevenue, 2) AS SalesRevenue,
    ROUND(
        PERCENT_RANK() OVER (
            ORDER BY SalesRevenue
        ),
        4
    ) AS SalesPercentile
FROM ProductSales
ORDER BY SalesRevenue DESC;

/* 12. BULK-ORDER PRODUCTS */
SELECT
    StockCode,
    Description,
    SUM(CAST(Quantity AS INTEGER)) AS UnitsSold,
    COUNT(DISTINCT InvoiceNo) AS Orders,
    ROUND(SUM(Revenue), 2) AS SalesRevenue,
    ROUND(
        1.0 * SUM(CAST(Quantity AS INTEGER))
        / COUNT(DISTINCT InvoiceNo),
        2
    ) AS AvgUnitsPerOrder
FROM online_retail_clean
WHERE StockCode NOT IN (
    'DOT',
    'M',
    'POST',
    'AMAZONFEE',
    'B',
    'C2',
    '23444',
    'BANK CHARGES',
    '23574',
    'S'
)
GROUP BY StockCode, Description
HAVING COUNT(DISTINCT InvoiceNo) >= 2
ORDER BY AvgUnitsPerOrder DESC
LIMIT 20;

/* 13. PRODUCT SALES CONCENTRATION */

WITH ProductSales AS (
    SELECT
        StockCode,
        SUM(Revenue) AS SalesRevenue
    FROM online_retail_clean
    WHERE StockCode NOT IN (
        'DOT',
        'M',
        'POST',
        'AMAZONFEE',
        'B',
        'C2',
        '23444',
        'BANK CHARGES',
        '23574',
        'S'
    )
    GROUP BY StockCode
),
RankedProducts AS (
    SELECT
        StockCode,
        SalesRevenue,
        SUM(SalesRevenue) OVER (
            ORDER BY SalesRevenue DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS CumulativeSales
    FROM ProductSales
)
SELECT
    StockCode,
    ROUND(SalesRevenue, 2) AS SalesRevenue,
    ROUND(CumulativeSales, 2) AS CumulativeSales,
    ROUND(
        100.0 * CumulativeSales
        / (SELECT SUM(SalesRevenue) FROM ProductSales),
        2
    ) AS CumulativeSalesPercent
FROM RankedProducts
ORDER BY SalesRevenue DESC;
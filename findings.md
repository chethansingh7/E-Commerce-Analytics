# Online Retail Analytics — Key Findings

## 1. Overall Sales Performance

- Total SalesRevenue: £10,666,684.54
- Total Orders: 19,960
- Total Units Sold: 5,588,376
- Average Order Value (AOV): £534.40
- Average Units per Order: 279.98

## 2. Sales Trend

- Highest full-month SalesRevenue: November 2011 — £1,509,496.33
- September 2011: £1,058,590.17
- October 2011: £1,154,979.30
- December 2011: £638,792.68, but the dataset only contains data through December 9, so it is a partial month.
- Sales increased strongly during September–November 2011.

## 3. Customer Analysis

- Identified customers: 4,338
- Unknown-customer orders: 1,428
- Identified-customer SalesRevenue: £8,911,407.90
- Unknown-customer SalesRevenue: £1,755,276.64
- One-time customers: 1,493
- Repeat customers: 2,845
- Repeat customers generated £8,295,096.17, or 93.08% of identified-customer sales.

## 4. RFM Segmentation

- Champions: 1,420 customers / £6,787,394.77
- High-Value At Risk: 603 / £1,161,750.49
- Low-Engagement / Dormant: 1,015 / £262,479.09
- High-Value Dormant: 120 / £230,443.06
- Regular Low-Value: 435 / £179,715.90
- Loyal / Growing: 387 / £166,235.01
- Recent / New Customers: 332 / £89,536.94
- New High-Value: 26 / £33,852.64

## 5. Product Analysis

- Merchandise products analyzed: 3,912 in the Power BI product view.
- Merchandise SalesRevenue: £10,270,816.42
- Units sold: 5,577,044
- Average product SalesRevenue: £2,625.46

Top products by SalesRevenue included:

- Regency Cakestand 3 Tier — £174,484.74
- Paper Craft, Little Birdie — £168,469.60
- White Hanging Heart T-Light Holder — £104,340.29
- Party Bunting — £99,504.33
- Jumbo Bag Red Retrospot — £94,340.05

The Paper Craft, Little Birdie product generated £168,469.60 from a single order containing 80,995 units and should be treated as an extreme bulk-order observation rather than removed automatically.

## 6. Geography

- United Kingdom SalesRevenue: £9,025,222.08
- UK contribution: 84.61%
- Netherlands: £285,446.34
- EIRE: £283,453.96
- Germany: £228,867.14
- France: £209,715.11

The UK represents the largest share of both sales activity and customer orders.

## 7. Order Analysis

- Orders: 19,960
- AOV: £534.40
- Average units/order: 279.98
- Average product lines/order: 26.56
- 62.62% of orders contain 11 or more product lines.
- Orders valued between £100 and £499 account for 61.66% of all orders.

The largest order was invoice 581483:

- £168,469.60
- 80,995 units
- 1 product line

## 8. Cancellations / Returns

- Cancellation invoices: 3,836
- Cancelled units: 277,574
- Cancellation value: £896,812.49
- Cancellation invoice rate: 19.22%
- Cancelled unit rate: 4.97%
- Cancellation value rate: 8.41%

The United Kingdom accounted for £815,291.60 of cancellation value.

The largest cancellation was invoice C581484:

- £168,469.60
- 80,995 units
- 1 product line

## 9. Data Quality Observations

- CustomerID contains missing/blank values in the raw dataset.
- December 2011 is a partial month.
- Several StockCodes represent administrative or non-merchandise transactions, including postage, manual adjustments, fees and charges.
- StockCode 22197 appears with more than one product description.
- Some extreme bulk transactions have a large effect on individual product/order metrics and should be documented rather than automatically removed.

/*
============================================================
PROJECT: E-Commerce Sales & Customer Insights Dashboard
SCRIPT: 02_ecommerce_business_analysis.sql

OBJECTIVE:
Perform business analysis using the cleaned e-commerce dataset to identify sales trends, product performance, customer behaviour, and business opportunities.

TOOLS:
Microsoft SQL Server / T-SQL

DATABASE:
EcommerceSalesDB

SOURCE TABLE:
dbo.EcommerceSales

============================================================
*/

USE EcommerceSalesDB;
GO

/*============================================================
1. OVERALL BUSINESS PERFORMANCE KPIs
============================================================*/

-- 1.1 Calculate the main business performance indicators.
--
-- TotalRecords       : Total product/order records.
-- TotalOrders        : Number of distinct orders.
-- TotalCustomers     : Number of distinct customers.
-- TotalUnitsSold     : Total quantity of products sold.
-- GrossSales         : Sales before discounts.
-- TotalDiscounts     : Total discount amount.
-- NetSales           : Sales after discounts.
-- AverageOrderValue  : Net sales divided by distinct orders.

SELECT
    COUNT(*) AS TotalRecords,
    COUNT(DISTINCT OrderID) AS TotalOrders,
    COUNT(DISTINCT CustomerID) AS TotalCustomers,
    SUM(Quantity) AS TotalUnitsSold,
    SUM(GrossSales) AS GrossSales,
    SUM(DiscountAmount) AS TotalDiscounts,
    SUM(NetSales) AS NetSales,
    CAST(
        SUM(NetSales) / NULLIF(COUNT(DISTINCT OrderID), 0) AS DECIMAL(14, 2)
    ) AS AverageOrderValue
FROM dbo.EcommerceSales;

-- 1.2 Calculate the overall discount percentage.
--
-- Discount Percentage = (Total Discounts / Gross Sales) * 100
--
-- This measures how much of the gross sales value was deducted through discounts.

SELECT
    SUM(GrossSales) AS GrossSales,
    SUM(DiscountAmount) AS TotalDiscounts,
    CAST(
        SUM(DiscountAmount) * 100.0 / NULLIF(SUM(GrossSales), 0) AS DECIMAL(10, 2)
    ) AS OverallDiscountPercentage
FROM dbo.EcommerceSales;

/*============================================================
2. MONTHLY AND YEARLY SALES TRENDS
============================================================*/

-- 2.1 Analyse monthly sales, order volume and units sold.
--
-- Business Question:
-- How does the company's sales performance change each month?
--
-- DATEFROMPARTS() creates a consistent month-start date.
-- COUNT(DISTINCT OrderID) prevents duplicate order counting.

SELECT
    YEAR(OrderDate) AS SalesYear,
    MONTH(OrderDate) AS SalesMonth,
    DATEFROMPARTS (
        YEAR(OrderDate),
        MONTH(OrderDate),
        1
    ) AS MonthStart,
    COUNT(DISTINCT OrderID) AS TotalOrders,
    SUM(Quantity) AS UnitsSold,
    SUM(GrossSales) AS GrossSales,
    SUM(DiscountAmount) AS TotalDiscounts,
    SUM(NetSales) AS NetSales
FROM dbo.EcommerceSales
GROUP BY
    YEAR(OrderDate),
    MONTH(OrderDate),
    DATEFROMPARTS (
        YEAR(OrderDate),
        MONTH(OrderDate),
        1
    )
ORDER BY SalesYear, SalesMonth;

-- 2.2 Compare yearly business performance.
--
-- Business Question:
-- Which year generated the highest net sales?
--
-- A customer is counted once within each year.
-- A customer appearing in multiple years is counted
-- once in each respective year's results.

SELECT
    YEAR(OrderDate) AS SalesYear,
    COUNT(DISTINCT OrderID) AS TotalOrders,
    COUNT(DISTINCT CustomerID) AS TotalCustomers,
    SUM(Quantity) AS UnitsSold,
    SUM(GrossSales) AS GrossSales,
    SUM(DiscountAmount) AS TotalDiscounts,
    SUM(NetSales) AS NetSales,
    CAST(
        SUM(NetSales) / NULLIF(COUNT(DISTINCT OrderID), 0) AS DECIMAL(14, 2)
    ) AS AverageOrderValue
FROM dbo.EcommerceSales
GROUP BY
    YEAR(OrderDate)
ORDER BY SalesYear;

/*============================================================
3. PRODUCT PERFORMANCE ANALYSIS
============================================================*/

-- 3.1 Identify the top 10 products by net sales.
--
-- Business Question:
-- Which products generate the highest revenue?
--
-- SUM(NetSales) calculates total revenue per product.
-- TOP (10) returns the ten highest-performing products.

SELECT
    TOP (10) ProductID,
    ProductName,
    SUM(Quantity) AS UnitsSold,
    SUM(NetSales) AS TotalNetSales
FROM dbo.EcommerceSales
GROUP BY
    ProductID,
    ProductName
ORDER BY TotalNetSales DESC;

-- 3.2 Identify the top 10 products by units sold.
--
-- Business Question:
-- Which products have the highest sales volume?
--
-- SUM(Quantity) calculates the total units sold per product.

SELECT
    TOP (10) ProductID,
    ProductName,
    SUM(Quantity) AS UnitsSold,
    SUM(NetSales) AS TotalNetSales
FROM dbo.EcommerceSales
GROUP BY
    ProductID,
    ProductName
ORDER BY UnitsSold DESC;

-- 3.3 Identify products with the highest average selling price.
--
-- Business Question:
-- Which products have the highest average selling price
-- after discounts?
--
-- NetSales / Quantity calculates the effective selling price
-- per unit across all product records.

SELECT
    ProductID,
    ProductName,
    SUM(Quantity) AS UnitsSold,
    SUM(NetSales) AS TotalNetSales,
    CAST(
        SUM(NetSales) / NULLIF(SUM(Quantity), 0) AS DECIMAL(12, 2)
    ) AS AverageSellingPrice
FROM dbo.EcommerceSales
GROUP BY
    ProductID,
    ProductName
ORDER BY AverageSellingPrice DESC;

-- 3.4 Identify the bottom 10 products by net sales.
--
-- Business Question:
-- Which products generate the lowest revenue?
--
-- This helps management identify products that may need
-- pricing, promotion or inventory strategy reviews.

SELECT
    TOP (10) ProductID,
    ProductName,
    SUM(Quantity) AS UnitsSold,
    SUM(NetSales) AS TotalNetSales
FROM dbo.EcommerceSales
GROUP BY
    ProductID,
    ProductName
ORDER BY TotalNetSales ASC;

/*============================================================
4. PRODUCT CATEGORY PERFORMANCE ANALYSIS
============================================================*/

-- 4.1 Analyse net sales by product category.
--
-- Business Question:
-- Which product categories generate the highest revenue?

SELECT
    Category,
    COUNT(DISTINCT ProductID) AS TotalProducts,
    SUM(Quantity) AS UnitsSold,
    SUM(NetSales) AS TotalNetSales
FROM dbo.EcommerceSales
GROUP BY
    Category
ORDER BY TotalNetSales DESC;

-- 4.2 Identify the highest-selling categories by units.
--
-- Business Question:
-- Which product categories have the highest sales volume?

SELECT
    Category,
    SUM(Quantity) AS UnitsSold,
    SUM(NetSales) AS TotalNetSales
FROM dbo.EcommerceSales
GROUP BY
    Category
ORDER BY UnitsSold DESC;

-- 4.3 Calculate each category's contribution to total net sales.
--
-- Business Question:
-- What percentage of overall revenue does each category generate?
--
-- The CTE calculates category-level sales first.
-- The outer query calculates each category's revenue contribution.

WITH
    CategorySales AS (
        SELECT Category, SUM(NetSales) AS TotalNetSales
        FROM dbo.EcommerceSales
        GROUP BY
            Category
    )
SELECT
    Category,
    TotalNetSales,
    CAST(
        TotalNetSales * 100.0 / NULLIF(SUM(TotalNetSales) OVER (), 0) AS DECIMAL(10, 2)
    ) AS RevenueContributionPercentage
FROM CategorySales
ORDER BY TotalNetSales DESC;

-- 4.4 Calculate the average selling price by category.
--
-- Business Question:
-- Which categories generate the highest net revenue per unit?

SELECT
    Category,
    SUM(Quantity) AS UnitsSold,
    SUM(NetSales) AS TotalNetSales,
    CAST(
        SUM(NetSales) / NULLIF(SUM(Quantity), 0) AS DECIMAL(12, 2)
    ) AS AverageSellingPrice
FROM dbo.EcommerceSales
GROUP BY
    Category
ORDER BY AverageSellingPrice DESC;

/*============================================================
5. CUSTOMER PURCHASING BEHAVIOUR
============================================================*/

-- 5.1 Analyse purchasing behaviour at customer level.
--
-- Business Question:
-- How frequently do customers purchase, and how much
-- revenue does each customer generate?
--
-- COUNT(DISTINCT OrderID) calculates unique orders.
-- SUM(Quantity) calculates total units purchased.
-- AverageOrderValue calculates revenue per customer order.

SELECT
    CustomerID,
    COUNT(DISTINCT OrderID) AS TotalOrders,
    SUM(Quantity) AS TotalUnitsPurchased,
    SUM(NetSales) AS TotalNetSales,
    CAST(
        SUM(NetSales) / NULLIF(COUNT(DISTINCT OrderID), 0) AS DECIMAL(12, 2)
    ) AS AverageOrderValue
FROM dbo.EcommerceSales
GROUP BY
    CustomerID
ORDER BY TotalNetSales DESC;

-- 5.2 Identify the top 10 customers by total net sales.
--
-- Business Question:
-- Which customers contribute the most revenue?

SELECT
    TOP (10) CustomerID,
    COUNT(DISTINCT OrderID) AS TotalOrders,
    SUM(Quantity) AS TotalUnitsPurchased,
    SUM(NetSales) AS TotalNetSales
FROM dbo.EcommerceSales
GROUP BY
    CustomerID
ORDER BY TotalNetSales DESC;

-- 5.3 Identify customers with the highest order frequency.
--
-- Business Question:
-- Which customers place the greatest number of orders?

SELECT
    TOP (10) CustomerID,
    COUNT(DISTINCT OrderID) AS TotalOrders,
    SUM(NetSales) AS TotalNetSales
FROM dbo.EcommerceSales
GROUP BY
    CustomerID
ORDER BY TotalOrders DESC, TotalNetSales DESC;

-- 5.4 Analyse customer spending segments.
--
-- Business Question:
-- How are customers distributed across spending levels?
--
-- Spending segments are based on total net sales:
-- High Value   : 1,500 or more
-- Medium Value : 750 to less than 1,500
-- Low Value    : Less than 750

WITH
    CustomerSpending AS (
        SELECT CustomerID, SUM(NetSales) AS TotalNetSales
        FROM dbo.EcommerceSales
        GROUP BY
            CustomerID
    )
SELECT
    CASE
        WHEN TotalNetSales >= 1500 THEN 'High Value'
        WHEN TotalNetSales >= 750 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS CustomerSegment,
    COUNT(*) AS TotalCustomers,
    CAST(
        SUM(TotalNetSales) AS DECIMAL(14, 2)
    ) AS SegmentNetSales
FROM CustomerSpending
GROUP BY
    CASE
        WHEN TotalNetSales >= 1500 THEN 'High Value'
        WHEN TotalNetSales >= 750 THEN 'Medium Value'
        ELSE 'Low Value'
    END
ORDER BY SegmentNetSales DESC;

/*============================================================
6. REPEAT CUSTOMER ANALYSIS
============================================================*/

-- 6.1 Classify customers as one-time or repeat customers.
--
-- Business Question:
-- How many customers have made more than one purchase?
--
-- One-Time Customer : 1 distinct order.
-- Repeat Customer   : 2 or more distinct orders.

WITH
    CustomerOrders AS (
        SELECT CustomerID, COUNT(DISTINCT OrderID) AS TotalOrders
        FROM dbo.EcommerceSales
        GROUP BY
            CustomerID
    )
SELECT
    CASE
        WHEN TotalOrders >= 2 THEN 'Repeat Customer'
        ELSE 'One-Time Customer'
    END AS CustomerType,
    COUNT(*) AS TotalCustomers
FROM CustomerOrders
GROUP BY
    CASE
        WHEN TotalOrders >= 2 THEN 'Repeat Customer'
        ELSE 'One-Time Customer'
    END
ORDER BY TotalCustomers DESC;

-- 6.2 Calculate the repeat customer rate.
--
-- Business Question:
-- What percentage of customers have placed multiple orders?
--
-- Repeat Customer Rate =
-- (Repeat Customers / Total Customers) * 100

WITH
    CustomerOrders AS (
        SELECT CustomerID, COUNT(DISTINCT OrderID) AS TotalOrders
        FROM dbo.EcommerceSales
        GROUP BY
            CustomerID
    )
SELECT
    COUNT(*) AS TotalCustomers,
    SUM(
        CASE
            WHEN TotalOrders >= 2 THEN 1
            ELSE 0
        END
    ) AS RepeatCustomers,
    CAST(
        SUM(
            CASE
                WHEN TotalOrders >= 2 THEN 1.0
                ELSE 0
            END
        ) * 100.0 / COUNT(*) AS DECIMAL(10, 2)
    ) AS RepeatCustomerRate
FROM CustomerOrders;

-- 6.3 Compare revenue generated by one-time and repeat customers.
--
-- Business Question:
-- Which customer group contributes more net sales?

WITH
    CustomerOrders AS (
        SELECT
            CustomerID,
            COUNT(DISTINCT OrderID) AS TotalOrders,
            SUM(NetSales) AS TotalNetSales
        FROM dbo.EcommerceSales
        GROUP BY
            CustomerID
    )
SELECT
    CASE
        WHEN TotalOrders >= 2 THEN 'Repeat Customer'
        ELSE 'One-Time Customer'
    END AS CustomerType,
    COUNT(*) AS TotalCustomers,
    SUM(TotalOrders) AS TotalOrders,
    CAST(
        SUM(TotalNetSales) AS DECIMAL(14, 2)
    ) AS TotalNetSales
FROM CustomerOrders
GROUP BY
    CASE
        WHEN TotalOrders >= 2 THEN 'Repeat Customer'
        ELSE 'One-Time Customer'
    END
ORDER BY TotalNetSales DESC;

-- 6.4 Analyse the distribution of customer order frequency.
--
-- Business Question:
-- How many customers place 1, 2, 3 or more orders?
--
-- This helps identify the purchasing frequency
-- across the customer base.

WITH
    CustomerOrders AS (
        SELECT CustomerID, COUNT(DISTINCT OrderID) AS TotalOrders
        FROM dbo.EcommerceSales
        GROUP BY
            CustomerID
    )
SELECT TotalOrders, COUNT(*) AS TotalCustomers
FROM CustomerOrders
GROUP BY
    TotalOrders
ORDER BY TotalOrders;

/*============================================================
7. REGIONAL AND COUNTRY PERFORMANCE ANALYSIS
============================================================*/

-- 7.1 Analyse net sales by region.
--
-- Business Question:
-- Which geographical regions generate the highest revenue?

SELECT
    Region,
    COUNT(DISTINCT OrderID) AS TotalOrders,
    COUNT(DISTINCT CustomerID) AS TotalCustomers,
    SUM(Quantity) AS UnitsSold,
    SUM(NetSales) AS TotalNetSales
FROM dbo.EcommerceSales
GROUP BY
    Region
ORDER BY TotalNetSales DESC;

-- 7.2 Identify the top 10 countries by net sales.
--
-- Business Question:
-- Which countries contribute the most revenue?

SELECT
    TOP (10) Country,
    COUNT(DISTINCT OrderID) AS TotalOrders,
    COUNT(DISTINCT CustomerID) AS TotalCustomers,
    SUM(NetSales) AS TotalNetSales
FROM dbo.EcommerceSales
GROUP BY
    Country
ORDER BY TotalNetSales DESC;

-- 7.3 Compare order volumes across regions.
--
-- Business Question:
-- Which regions have the highest number of orders?

SELECT
    Region,
    COUNT(DISTINCT OrderID) AS TotalOrders,
    SUM(Quantity) AS UnitsSold
FROM dbo.EcommerceSales
GROUP BY
    Region
ORDER BY TotalOrders DESC;

-- 7.4 Calculate each region's contribution to total net sales.
--
-- Business Question:
-- What percentage of overall revenue does each region generate?

WITH
    RegionalSales AS (
        SELECT Region, SUM(NetSales) AS TotalNetSales
        FROM dbo.EcommerceSales
        GROUP BY
            Region
    )
SELECT
    Region,
    TotalNetSales,
    CAST(
        TotalNetSales * 100.0 / NULLIF(SUM(TotalNetSales) OVER (), 0) AS DECIMAL(10, 2)
    ) AS RevenueContributionPercentage
FROM RegionalSales
ORDER BY TotalNetSales DESC;

-- ============================================================
-- 8. PAYMENT METHOD ANALYSIS
-- ============================================================

-- 8.1 Analyse net sales generated by each payment method.
--
-- Business Question:
-- Which payment methods generate the highest net sales?
--
-- SUM(NetSales) measures the sales attributed to each
-- payment method at the product/order-record level.

SELECT
    PaymentMethod,
    COUNT(*) AS TotalRecords,
    COUNT(DISTINCT OrderID) AS TotalOrders,
    SUM(NetSales) AS TotalNetSales
FROM dbo.EcommerceSales
GROUP BY
    PaymentMethod
ORDER BY TotalNetSales DESC;

-- 8.2 Calculate average net sales per record by payment method.
--
-- Business Question:
-- Which payment methods have the highest average
-- net sales value per product/order record?
--
-- AVG(NetSales) calculates the average at record level.
-- This is not average order value because an order may
-- contain multiple records and payment methods.

SELECT
    PaymentMethod,
    COUNT(*) AS TotalRecords,
    SUM(NetSales) AS TotalNetSales,
    AVG(NetSales) AS AverageNetSalesPerRecord
FROM dbo.EcommerceSales
GROUP BY
    PaymentMethod
ORDER BY AverageNetSalesPerRecord DESC;

-- 8.3 Calculate each payment method's contribution
-- to overall net sales.
--
-- Business Question:
-- What percentage of total net sales is contributed
-- by each payment method?
--
-- The denominator uses total net sales across the
-- complete dataset.

SELECT
    PaymentMethod,
    SUM(NetSales) AS TotalNetSales,
    CAST(
        SUM(NetSales) * 100.0 / SUM(SUM(NetSales)) OVER () AS DECIMAL(6, 2)
    ) AS RevenueContributionPercentage
FROM dbo.EcommerceSales
GROUP BY
    PaymentMethod
ORDER BY RevenueContributionPercentage DESC;

-- 8.4 Analyse the distribution of records across payment methods.
--
-- Business Question:
-- How frequently is each payment method represented
-- in the sales dataset?
--
-- RecordContributionPercentage measures each payment
-- method's share of all product/order records.

SELECT
    PaymentMethod,
    COUNT(*) AS TotalRecords,
    CAST(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(6, 2)
    ) AS RecordContributionPercentage
FROM dbo.EcommerceSales
GROUP BY
    PaymentMethod
ORDER BY RecordContributionPercentage DESC;

-- ============================================================
-- 9. RETURN ANALYSIS
-- ============================================================

-- 9.1 Analyse the distribution of returned and
-- non-returned product/order records.
--
-- Business Question:
-- How many sales records have been returned,
-- and what percentage of records does each status represent?
--
-- Return rate is calculated at product/order-record level,
-- not at distinct order level.

SELECT
    ReturnStatus,
    COUNT(*) AS TotalRecords,
    CAST(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(6, 2)
    ) AS RecordPercentage
FROM dbo.EcommerceSales
GROUP BY
    ReturnStatus
ORDER BY TotalRecords DESC;

-- 9.2 Analyse return rates across product categories.
--
-- Business Question:
-- Which product categories have the highest return rates?
--
-- Return rate is calculated as returned records
-- divided by all records within each category.

SELECT
    Category,
    COUNT(*) AS TotalRecords,
    SUM(
        CASE
            WHEN ReturnStatus = 'Returned' THEN 1
            ELSE 0
        END
    ) AS ReturnedRecords,
    CAST(
        SUM(
            CASE
                WHEN ReturnStatus = 'Returned' THEN 1.0
                ELSE 0
            END
        ) * 100.0 / COUNT(*) AS DECIMAL(6, 2)
    ) AS ReturnRatePercentage
FROM dbo.EcommerceSales
GROUP BY
    Category
ORDER BY ReturnRatePercentage DESC;

-- 9.3 Analyse return rates across countries.
--
-- Business Question:
-- Which countries have the highest product return rates?
--
-- Return rate is calculated as returned records
-- divided by all records within each country.

SELECT
    Country,
    COUNT(*) AS TotalRecords,
    SUM(
        CASE
            WHEN ReturnStatus = 'Returned' THEN 1
            ELSE 0
        END
    ) AS ReturnedRecords,
    CAST(
        SUM(
            CASE
                WHEN ReturnStatus = 'Returned' THEN 1.0
                ELSE 0
            END
        ) * 100.0 / COUNT(*) AS DECIMAL(6, 2)
    ) AS ReturnRatePercentage
FROM dbo.EcommerceSales
GROUP BY
    Country
ORDER BY ReturnRatePercentage DESC;

/*============================================================
10. FINAL DATA VALIDATION AND RECONCILIATION
============================================================*/

-- 10.1 Reconcile the final dataset against the main project KPIs.
--
-- Business Purpose:
-- Confirm that the SQL dataset contains the expected number
-- of records, orders and customers, and that the main
-- financial metrics are consistent.
--
-- These figures can also be compared with the Python EDA.

SELECT
    COUNT(*) AS TotalRecords,
    COUNT(DISTINCT OrderID) AS TotalOrders,
    COUNT(DISTINCT CustomerID) AS TotalCustomers,
    COUNT(DISTINCT ProductID) AS TotalProducts,
    SUM(Quantity) AS TotalUnitsSold,
    CAST(
        SUM(GrossSales) AS DECIMAL(14, 2)
    ) AS GrossSales,
    CAST(
        SUM(DiscountAmount) AS DECIMAL(14, 2)
    ) AS TotalDiscounts,
    CAST(
        SUM(NetSales) AS DECIMAL(14, 2)
    ) AS NetSales,
    CAST(
        SUM(NetSales) / NULLIF(COUNT(DISTINCT OrderID), 0) AS DECIMAL(14, 2)
    ) AS AverageOrderValue,
    MIN(OrderDate) AS FirstOrderDate,
    MAX(OrderDate) AS LastOrderDate
FROM dbo.EcommerceSales;

-- 10.2 Check critical fields for missing values.
--
-- Business Purpose:
-- Identify missing values in fields required for
-- sales, customer and product analysis.

SELECT
    SUM(
        CASE
            WHEN OrderID IS NULL THEN 1
            ELSE 0
        END
    ) AS MissingOrderIDs,
    SUM(
        CASE
            WHEN OrderDate IS NULL THEN 1
            ELSE 0
        END
    ) AS MissingOrderDates,
    SUM(
        CASE
            WHEN CustomerID IS NULL THEN 1
            ELSE 0
        END
    ) AS MissingCustomerIDs,
    SUM(
        CASE
            WHEN ProductID IS NULL THEN 1
            ELSE 0
        END
    ) AS MissingProductIDs,
    SUM(
        CASE
            WHEN Quantity IS NULL THEN 1
            ELSE 0
        END
    ) AS MissingQuantities,
    SUM(
        CASE
            WHEN UnitPrice IS NULL THEN 1
            ELSE 0
        END
    ) AS MissingUnitPrices,
    SUM(
        CASE
            WHEN NetSales IS NULL THEN 1
            ELSE 0
        END
    ) AS MissingNetSales
FROM dbo.EcommerceSales;

-- 10.3 Validate business rules and data consistency.
--
-- Business Purpose:
-- Identify records that violate expected business rules.
--
-- Note:
-- ReturnDate is expected to be NULL for records
-- that have not been returned.

SELECT
    SUM(
        CASE
            WHEN Quantity <= 0 THEN 1
            ELSE 0
        END
    ) AS InvalidQuantities,
    SUM(
        CASE
            WHEN UnitPrice < 0 THEN 1
            ELSE 0
        END
    ) AS NegativeUnitPrices,
    SUM(
        CASE
            WHEN DiscountPct < 0
            OR DiscountPct > 100 THEN 1
            ELSE 0
        END
    ) AS InvalidDiscountPercentages,
    SUM(
        CASE
            WHEN CustomerRegistrationDate > OrderDate THEN 1
            ELSE 0
        END
    ) AS InvalidCustomerRegistrationDates,
    SUM(
        CASE
            WHEN ReturnStatus = 'Returned'
            AND ReturnDate IS NULL THEN 1
            WHEN ReturnStatus = 'Not Returned'
            AND ReturnDate IS NOT NULL THEN 1
            ELSE 0
        END
    ) AS InconsistentReturnDates
FROM dbo.EcommerceSales;

-- 10.4 Check for duplicate product/order records.
--
-- Business Purpose:
-- Identify exact duplicate records that could inflate
-- sales, quantity and revenue calculations.

WITH
    DuplicateRecords AS (
        SELECT
            OrderID,
            OrderDate,
            CustomerID,
            CustomerRegistrationDate,
            ProductID,
            ProductName,
            Category,
            Quantity,
            UnitPrice,
            DiscountPct,
            GrossSales,
            DiscountAmount,
            NetSales,
            Region,
            Country,
            PaymentMethod,
            ReturnStatus,
            ReturnDate,
            COUNT(*) AS DuplicateCount
        FROM dbo.EcommerceSales
        GROUP BY
            OrderID,
            OrderDate,
            CustomerID,
            CustomerRegistrationDate,
            ProductID,
            ProductName,
            Category,
            Quantity,
            UnitPrice,
            DiscountPct,
            GrossSales,
            DiscountAmount,
            NetSales,
            Region,
            Country,
            PaymentMethod,
            ReturnStatus,
            ReturnDate
        HAVING
            COUNT(*) > 1
    )
SELECT
    COUNT(*) AS DuplicateRecordGroups,
    COALESCE(SUM(DuplicateCount - 1), 0) AS ExtraDuplicateRecords
FROM DuplicateRecords;

-- 10.5 Validate financial calculations.
--
-- Business Purpose:
-- Identify discrepancies between stored financial values
-- and their expected calculations.
--
-- Expected calculations:
-- GrossSales     = Quantity * UnitPrice
-- DiscountAmount = GrossSales * DiscountPct / 100
-- NetSales       = GrossSales - DiscountAmount
--
-- A tolerance greater than 0.01 is used to avoid flagging
-- minor rounding differences between Python and SQL Server.
--
-- This is a diagnostic check, not an automatic data correction.

SELECT
    SUM(
        CASE
            WHEN ABS(
                GrossSales - (Quantity * UnitPrice)
            ) > 0.01 THEN 1
            ELSE 0
        END
    ) AS GrossSalesMismatches,
    SUM(
        CASE
            WHEN ABS(
                DiscountAmount - ROUND(
                    GrossSales * DiscountPct / 100.0,
                    2
                )
            ) > 0.01 THEN 1
            ELSE 0
        END
    ) AS DiscountAmountMismatches,
    SUM(
        CASE
            WHEN ABS(
                NetSales - (GrossSales - DiscountAmount)
            ) > 0.01 THEN 1
            ELSE 0
        END
    ) AS NetSalesMismatches
FROM dbo.EcommerceSales;

-- 10.6 Display the final validation summary.
--
-- Business Purpose:
-- Provide a final overview of the dataset's size,
-- financial performance and return distribution.

SELECT
    COUNT(*) AS TotalRecords,
    COUNT(DISTINCT OrderID) AS TotalOrders,
    COUNT(DISTINCT CustomerID) AS TotalCustomers,
    COUNT(DISTINCT ProductID) AS TotalProducts,
    COUNT(DISTINCT Category) AS TotalCategories,
    COUNT(DISTINCT Country) AS TotalCountries,
    SUM(
        CASE
            WHEN ReturnStatus = 'Returned' THEN 1
            ELSE 0
        END
    ) AS ReturnedRecords,
    SUM(
        CASE
            WHEN ReturnStatus = 'Not Returned' THEN 1
            ELSE 0
        END
    ) AS NonReturnedRecords,
    CAST(
        SUM(NetSales) AS DECIMAL(14, 2)
    ) AS FinalNetSales
FROM dbo.EcommerceSales;
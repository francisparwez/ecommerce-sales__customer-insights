/*
============================================================
PROJECT: E-Commerce Sales & Customer Insights Dashboard
SCRIPT: 01_ecommerce_analysis.sql

OBJECTIVE:
1. Create the SQL Server database only if it does not exist.
2. Create the e-commerce sales table only if it does not exist.
3. Import the cleaned CSV dataset.
4. Perform initial data inspection.
5. Validate data quality and consistency.
6. Investigate financial calculation discrepancies.

TOOLS:
Microsoft SQL Server / T-SQL
============================================================
*/

/*============================================================
1. DATABASE AVAILABILITY AND SELECTION
============================================================*/

-- 1.1 Create EcommerceSalesDB only if it does not already exist.
--
-- IMPORTANT:
-- This script does not drop, reset or overwrite an existing database.
-- Existing database contents are preserved.

IF DB_ID ('EcommerceSalesDB') IS NULL BEGIN
CREATE DATABASE EcommerceSalesDB;

END;
GO

-- 1.2 Set EcommerceSalesDB as the active database.

USE EcommerceSalesDB;
GO

/*============================================================
2. MAIN TABLE CREATION
============================================================*/

-- 2.1 Create dbo.EcommerceSales only if it does not already exist.
--
-- IMPORTANT:
-- An existing table and its data are preserved.
-- The column order matches the cleaned CSV file because
-- BULK INSERT maps CSV fields to table columns by position.

IF OBJECT_ID ('dbo.EcommerceSales', 'U') IS NULL BEGIN
CREATE TABLE dbo.EcommerceSales (
    OrderID VARCHAR(30),
    OrderDate DATE,
    CustomerID VARCHAR(30),
    CustomerRegistrationDate DATE,
    ProductID VARCHAR(30),
    ProductName NVARCHAR (100),
    Category NVARCHAR (50),
    Quantity INT,
    UnitPrice DECIMAL(12, 2),
    DiscountPct DECIMAL(6, 2),
    GrossSales DECIMAL(14, 2),
    DiscountAmount DECIMAL(14, 2),
    NetSales DECIMAL(14, 2),
    Region NVARCHAR (50),
    Country NVARCHAR (100),
    PaymentMethod NVARCHAR (50),
    ReturnStatus NVARCHAR (30),
    ReturnDate DATE NULL
);

END;
GO

/*============================================================
3. CLEANED CSV DATA IMPORT
============================================================*/

-- 3.1 Import the cleaned CSV dataset into dbo.EcommerceSales.
--
-- FORMAT = 'CSV'       : Reads the source file as CSV.
-- FIRSTROW = 2         : Skips the header row.
-- FIELDQUOTE = '"'     : Recognises double quotes as text qualifiers.
-- CODEPAGE = '65001'   : Uses UTF-8 encoding.
-- TABLOCK              : Acquires a table-level lock during import.

-- Import only when the target table is empty.
--
-- This prevents duplicate rows if the script is run again
-- after the cleaned dataset has already been imported.

IF NOT EXISTS (
    SELECT 1
    FROM dbo.EcommerceSales
) BEGIN BULK
INSERT
    dbo.EcommerceSales
FROM 'C:\Users\franc\OneDrive\Desktop\DATA SCIENCE\INTERNLYTIC - Project\ecommerce-sales__customer-insights\Dataset\Cleaned\ecommerce_sales_customer_cleaned.csv'
WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2,
        FIELDQUOTE = '"',
        CODEPAGE = '65001',
        TABLOCK
    );

END ELSE BEGIN PRINT 'Import skipped: dbo.EcommerceSales already contains data.';

END;
GO

/*============================================================
4. INITIAL DATA INSPECTION
============================================================*/

-- 4.1 Preview the first 10 imported records.

SELECT TOP 10 * FROM dbo.EcommerceSales;

-- 4.2 Count total records, unique orders and unique customers.

SELECT
    COUNT(*) AS TotalRecords,
    COUNT(DISTINCT OrderID) AS UniqueOrders,
    COUNT(DISTINCT CustomerID) AS UniqueCustomers
FROM dbo.EcommerceSales;

-- 4.3 Identify the earliest and latest order dates.
-- Also count records with a missing ReturnDate.
--
-- Missing ReturnDate values are expected for products
-- that have not been returned.

SELECT
    MIN(OrderDate) AS FirstOrderDate,
    MAX(OrderDate) AS LastOrderDate,
    SUM(
        CASE
            WHEN ReturnDate IS NULL THEN 1
            ELSE 0
        END
    ) AS MissingReturnDates
FROM dbo.EcommerceSales;

-- 4.4 Check for invalid numerical values.
--
-- NegativePrices     : Negative UnitPrice values.
-- InvalidQuantities  : Zero or negative Quantity values.
-- InvalidDiscounts   : DiscountPct values above 100%.

SELECT
    SUM(
        CASE
            WHEN UnitPrice < 0 THEN 1
            ELSE 0
        END
    ) AS NegativePrices,
    SUM(
        CASE
            WHEN Quantity <= 0 THEN 1
            ELSE 0
        END
    ) AS InvalidQuantities,
    SUM(
        CASE
            WHEN DiscountPct > 100 THEN 1
            ELSE 0
        END
    ) AS InvalidDiscounts
FROM dbo.EcommerceSales;

-- 4.5 Inspect sample order, customer registration
-- and return dates.

SELECT
    TOP 10 OrderID,
    OrderDate,
    CustomerID,
    CustomerRegistrationDate,
    ReturnDate
FROM dbo.EcommerceSales;

/*============================================================
5. ORDER-LEVEL CONSISTENCY VALIDATION
============================================================*/

-- 5.1 Check whether each OrderID is associated with exactly
-- one CustomerID and one OrderDate.
--
-- GROUP BY      : Groups records belonging to the same order.
-- COUNT(DISTINCT): Counts unique customers and order dates.
-- HAVING        : Returns only orders violating either condition.
--
-- EXPECTED RESULT: Zero rows.

SELECT
    OrderID,
    COUNT(DISTINCT CustomerID) AS CustomerCount,
    COUNT(DISTINCT OrderDate) AS OrderDateCount
FROM dbo.EcommerceSales
GROUP BY
    OrderID
HAVING
    COUNT(DISTINCT CustomerID) > 1
    OR COUNT(DISTINCT OrderDate) > 1;

/*============================================================
6. MISSING VALUE VALIDATION
============================================================*/

-- 6.1 Count missing values in important columns.
--
-- ReturnDate is excluded because NULL is expected
-- for products that have not been returned.
--
-- EXPECTED RESULT: Zero for all checked columns.

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
            WHEN CustomerRegistrationDate IS NULL THEN 1
            ELSE 0
        END
    ) AS MissingRegistrationDates,
    SUM(
        CASE
            WHEN ProductID IS NULL THEN 1
            ELSE 0
        END
    ) AS MissingProductIDs,
    SUM(
        CASE
            WHEN ProductName IS NULL THEN 1
            ELSE 0
        END
    ) AS MissingProductNames,
    SUM(
        CASE
            WHEN Category IS NULL THEN 1
            ELSE 0
        END
    ) AS MissingCategories,
    SUM(
        CASE
            WHEN Region IS NULL THEN 1
            ELSE 0
        END
    ) AS MissingRegions,
    SUM(
        CASE
            WHEN Country IS NULL THEN 1
            ELSE 0
        END
    ) AS MissingCountries,
    SUM(
        CASE
            WHEN PaymentMethod IS NULL THEN 1
            ELSE 0
        END
    ) AS MissingPaymentMethods,
    SUM(
        CASE
            WHEN ReturnStatus IS NULL THEN 1
            ELSE 0
        END
    ) AS MissingReturnStatuses
FROM dbo.EcommerceSales;

/*============================================================
7. DUPLICATE RECORD VALIDATION
============================================================*/

-- 7.1 Identify exact duplicate records.
--
-- ROW_NUMBER() assigns a sequence number to records
-- having identical values across all 18 columns.
--
-- RowNum > 1 identifies duplicate occurrences.
--
-- EXPECTED RESULT: Zero duplicate records.

WITH
    DuplicateRecords AS (
        SELECT *, ROW_NUMBER() OVER (
                PARTITION BY
                    OrderID, OrderDate, CustomerID, CustomerRegistrationDate, ProductID, ProductName, Category, Quantity, UnitPrice, DiscountPct, GrossSales, DiscountAmount, NetSales, Region, Country, PaymentMethod, ReturnStatus, ReturnDate
                ORDER BY OrderID
            ) AS RowNum
        FROM dbo.EcommerceSales
    )
SELECT COUNT(*) AS DuplicateRecords
FROM DuplicateRecords
WHERE
    RowNum > 1;

/*============================================================
8. DATE CONSISTENCY VALIDATION
============================================================*/

-- 8.1 Identify records with invalid date relationships.
--
-- Condition 1: Customer registration occurred after the order date.
-- Condition 2: ReturnDate occurred before the order date.
--
-- EXPECTED RESULT: Zero rows.

SELECT
    OrderID,
    CustomerID,
    OrderDate,
    CustomerRegistrationDate,
    ReturnDate
FROM dbo.EcommerceSales
WHERE
    CustomerRegistrationDate > OrderDate
    OR ReturnDate < OrderDate;

/*============================================================
9. RETURN STATUS VALIDATION
============================================================*/

-- 9.1 Identify inconsistencies between ReturnStatus and ReturnDate.
--
-- Returned records should have a ReturnDate.
-- Not Returned records should have a NULL ReturnDate.
--
-- EXPECTED RESULT: Zero rows.

SELECT
    OrderID,
    ProductID,
    ReturnStatus,
    ReturnDate
FROM dbo.EcommerceSales
WHERE (
        ReturnStatus = 'Returned'
        AND ReturnDate IS NULL
    )
    OR (
        ReturnStatus = 'Not Returned'
        AND ReturnDate IS NOT NULL
    );

/*============================================================
10. FINANCIAL CALCULATION VALIDATION
============================================================*/

-- 10.1 Verify the three financial calculations.
--
-- GrossSales      = Quantity * UnitPrice
-- DiscountAmount  = GrossSales * DiscountPct / 100
-- NetSales        = GrossSales - DiscountAmount
--
-- ROUND(..., 2) accounts for the two-decimal
-- precision used in the financial columns.
--
-- EXPECTED RESULT: Zero rows.

SELECT
    OrderID,
    ProductID,
    GrossSales,
    DiscountAmount,
    NetSales
FROM dbo.EcommerceSales
WHERE
    ROUND(Quantity * UnitPrice, 2) <> GrossSales
    OR ROUND(
        GrossSales * DiscountPct / 100,
        2
    ) <> DiscountAmount
    OR ROUND(
        GrossSales - DiscountAmount,
        2
    ) <> NetSales;

/*============================================================
11. PRODUCT-CATEGORY CONSISTENCY VALIDATION
============================================================*/

-- 11.1 Check whether each ProductID is associated
-- with more than one Category.
--
-- COUNT(DISTINCT Category) identifies the number
-- of different categories assigned to each product.
--
-- EXPECTED RESULT: Zero rows.

SELECT ProductID, COUNT(DISTINCT Category) AS CategoryCount
FROM dbo.EcommerceSales
GROUP BY
    ProductID
HAVING
    COUNT(DISTINCT Category) > 1;

/*============================================================
12. FINANCIAL DISCREPANCY INVESTIGATION
============================================================*/

-- 12.1 Display records with financial calculation discrepancies.
--
-- Expected financial values are recalculated for comparison.
-- ValidationIssue identifies the first failing calculation.

SELECT
    OrderID,
    ProductID,
    Quantity,
    UnitPrice,
    DiscountPct,
    GrossSales,
    DiscountAmount,
    NetSales,
    ROUND(Quantity * UnitPrice, 2) AS ExpectedGrossSales,
    ROUND(
        GrossSales * DiscountPct / 100,
        2
    ) AS ExpectedDiscountAmount,
    ROUND(
        GrossSales - DiscountAmount,
        2
    ) AS ExpectedNetSales,
    CASE
        WHEN ROUND(Quantity * UnitPrice, 2) <> GrossSales THEN 'GrossSales Mismatch'
        WHEN ROUND(
            GrossSales * DiscountPct / 100,
            2
        ) <> DiscountAmount THEN 'DiscountAmount Mismatch'
        WHEN ROUND(
            GrossSales - DiscountAmount,
            2
        ) <> NetSales THEN 'NetSales Mismatch'
        ELSE 'No Mismatch'
    END AS ValidationIssue
FROM dbo.EcommerceSales
WHERE
    ROUND(Quantity * UnitPrice, 2) <> GrossSales
    OR ROUND(
        GrossSales * DiscountPct / 100,
        2
    ) <> DiscountAmount
    OR ROUND(
        GrossSales - DiscountAmount,
        2
    ) <> NetSales;

-- 12.2 Count discrepancies separately for each calculation.

SELECT
    SUM(
        CASE
            WHEN ROUND(Quantity * UnitPrice, 2) <> GrossSales THEN 1
            ELSE 0
        END
    ) AS GrossSalesMismatches,
    SUM(
        CASE
            WHEN ROUND(
                GrossSales * DiscountPct / 100,
                2
            ) <> DiscountAmount THEN 1
            ELSE 0
        END
    ) AS DiscountAmountMismatches,
    SUM(
        CASE
            WHEN ROUND(
                GrossSales - DiscountAmount,
                2
            ) <> NetSales THEN 1
            ELSE 0
        END
    ) AS NetSalesMismatches
FROM dbo.EcommerceSales;

-- 12.3 Retrieve records with incorrect GrossSales calculations.

SELECT
    OrderID,
    ProductID,
    Quantity,
    UnitPrice,
    GrossSales,
    ROUND(Quantity * UnitPrice, 2) AS ExpectedGrossSales,
    GrossSales - ROUND(Quantity * UnitPrice, 2) AS Difference
FROM dbo.EcommerceSales
WHERE
    ROUND(Quantity * UnitPrice, 2) <> GrossSales;

-- 12.4 Inspect the previously identified affected record.

SELECT
    OrderID,
    ProductID,
    Quantity,
    UnitPrice,
    DiscountPct,
    GrossSales,
    DiscountAmount,
    NetSales
FROM dbo.EcommerceSales
WHERE
    OrderID = 'ORD006679'
    AND ProductID = 'P001';

/*============================================================
13. CLEANED CSV VERSUS SQL TABLE COMPARISON
============================================================*/

-- 13.1 Create the temporary staging table if it does not exist.
--
-- If it already exists in this SSMS session, clear its rows
-- so the CSV can be loaded again without dropping the table.

IF OBJECT_ID('tempdb..#OriginalCSV') IS NULL
BEGIN
    CREATE TABLE #OriginalCSV (
    OrderID VARCHAR(30),
    OrderDate DATE,
    CustomerID VARCHAR(30),
    CustomerRegistrationDate DATE,
    ProductID VARCHAR(30),
    ProductName NVARCHAR(100),
    Category NVARCHAR(50),
    Quantity INT,
    UnitPrice DECIMAL(12, 2),
    DiscountPct DECIMAL(6, 2),
    GrossSales DECIMAL(14, 2),
    DiscountAmount DECIMAL(14, 2),
    NetSales DECIMAL(14, 2),
    Region NVARCHAR(50),
    Country NVARCHAR(100),
    PaymentMethod NVARCHAR(50),
    ReturnStatus NVARCHAR(30),
    ReturnDate DATE NULL
    );

END
ELSE
BEGIN
    TRUNCATE TABLE #OriginalCSV;
END;

-- 13.2 Import the cleaned CSV into the temporary staging table.

BULK INSERT #OriginalCSV
FROM 'C:\Users\franc\OneDrive\Desktop\DATA SCIENCE\INTERNLYTIC - Project\ecommerce-sales__customer-insights\Dataset\Cleaned\ecommerce_sales_customer_cleaned.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    CODEPAGE = '65001',
    TABLOCK
);

-- 13.3 Compare the original cleaned CSV values
-- with the corresponding SQL table values.
--
-- This verifies that the SQL import preserved the values.

SELECT Original.OrderID, Original.ProductID,

-- Original cleaned CSV values
Original.UnitPrice AS CSV_UnitPrice,
Original.GrossSales AS CSV_GrossSales,
Original.DiscountAmount AS CSV_DiscountAmount,
Original.NetSales AS CSV_NetSales,

-- Imported SQL table values
Imported.UnitPrice AS SQL_UnitPrice,
Imported.GrossSales AS SQL_GrossSales,
Imported.DiscountAmount AS SQL_DiscountAmount,
Imported.NetSales AS SQL_NetSales
FROM #OriginalCSV AS Original
    INNER JOIN dbo.EcommerceSales AS Imported ON Original.OrderID = Imported.OrderID
    AND Original.ProductID = Imported.ProductID
WHERE
    Original.OrderID = 'ORD006679'
    AND Original.ProductID = 'P001';

/*============================================================
14. ORIGINAL RAW CSV INVESTIGATION
============================================================*/

-- 14.1 Create the raw staging table if it does not exist.
--
-- If it already exists in this SSMS session, clear its rows
-- before loading the original raw CSV again.

IF OBJECT_ID('tempdb..#RawCSV') IS NULL
BEGIN
    CREATE TABLE #RawCSV (
    OrderID VARCHAR(30),
    OrderDate DATE,
    CustomerID VARCHAR(30),
    CustomerRegistrationDate DATE,
    ProductID VARCHAR(30),
    ProductName NVARCHAR(100),
    Category NVARCHAR(50),
    Quantity INT,
    UnitPrice DECIMAL(12, 2),
    DiscountPct DECIMAL(6, 2),
    GrossSales DECIMAL(14, 2),
    DiscountAmount DECIMAL(14, 2),
    NetSales DECIMAL(14, 2),
    Region NVARCHAR(50),
    Country NVARCHAR(100),
    PaymentMethod NVARCHAR(50),
    ReturnStatus NVARCHAR(30),
    ReturnDate DATE NULL
    );

END
ELSE
BEGIN
    TRUNCATE TABLE #RawCSV;
END;

-- 14.2 Import the original raw CSV into the staging table.

BULK INSERT #RawCSV
FROM 'C:\Users\franc\OneDrive\Desktop\DATA SCIENCE\INTERNLYTIC - Project\ecommerce-sales__customer-insights\Dataset\Raw\ecommerce_sales_customer.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    CODEPAGE = '65001',
    TABLOCK
);

-- 14.3 Inspect the original raw values for the affected record.

SELECT
    OrderID,
    ProductID,
    Quantity,
    UnitPrice,
    DiscountPct,
    GrossSales,
    DiscountAmount,
    NetSales,
    ROUND(Quantity * UnitPrice, 2) AS ExpectedGrossSales
FROM #RawCSV
WHERE
    OrderID = 'ORD006679'
    AND ProductID = 'P001';

/*============================================================
15. PRODUCT MEDIAN-PRICE INVESTIGATION
============================================================*/

-- 15.1 Compare the financial values for all records
-- belonging to Product P001 in the imported SQL table.

SELECT
    OrderID,
    ProductID,
    Quantity,
    UnitPrice,
    DiscountPct,
    GrossSales,
    DiscountAmount,
    NetSales,
    ROUND(Quantity * UnitPrice, 2) AS ExpectedGrossSales
FROM dbo.EcommerceSales
WHERE
    ProductID = 'P001'
ORDER BY OrderID;

-- 15.2 Calculate the median valid UnitPrice for Product P001
-- using the original raw dataset.
--
-- PERCENTILE_CONT(0.5) calculates the continuous median.

SELECT DISTINCT
    ProductID,
    PERCENTILE_CONT (0.5) WITHIN GROUP (
        ORDER BY UnitPrice
    ) OVER (
        PARTITION BY
            ProductID
    ) AS MedianUnitPrice
FROM #RawCSV
WHERE
    ProductID = 'P001'
    AND UnitPrice > 0;

-- 15.3 Inspect the median alongside the number of valid
-- price records and the minimum and maximum prices.

WITH
    ProductMedian AS (
        SELECT
            ProductID,
            COUNT(*) OVER (
                PARTITION BY
                    ProductID
            ) AS ValidPriceRecords,
            MIN(UnitPrice) OVER (
                PARTITION BY
                    ProductID
            ) AS MinimumUnitPrice,
            MAX(UnitPrice) OVER (
                PARTITION BY
                    ProductID
            ) AS MaximumUnitPrice,
            PERCENTILE_CONT (0.5) WITHIN GROUP (
                ORDER BY UnitPrice
            ) OVER (
                PARTITION BY
                    ProductID
            ) AS MedianUnitPrice
        FROM #RawCSV
        WHERE
            ProductID = 'P001'
            AND UnitPrice > 0
    )
SELECT DISTINCT
    ProductID,
    ValidPriceRecords,
    MinimumUnitPrice,
    MaximumUnitPrice,
    CAST(
        MedianUnitPrice AS DECIMAL(18, 6)
    ) AS ExactMedianUnitPrice
FROM ProductMedian;

/*============================================================
END OF SCRIPT
============================================================*/
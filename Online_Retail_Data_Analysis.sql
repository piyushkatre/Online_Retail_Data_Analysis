/* -----------------------------------------------------
   ONLINE RETAIL SALES ANALYSIS PROJECT
   Skills Used:
   - Data Cleaning
   - Data Transformation
   - Aggregate Functions
   - Window Functions
   - CTEs
   - Business Analysis
------------------------------------------------------ */

USE PortfolioProject;





/* -----------------------------------------------------
   DATA EXPLORATION
----------------------------------------------------- */

SELECT *
FROM PortfolioProject..Online_Retail;

EXEC sp_help 'PortfolioProject.dbo.Online_Retail';

-- Count Missing Customer IDs
SELECT COUNT(*) AS Missing_CustomerID_Count
FROM PortfolioProject..Online_Retail
WHERE CustomerID IS NULL;

-- Count Missing Invoice Numbers
SELECT COUNT(*) AS Missing_InvoiceNo_Count
FROM PortfolioProject..Online_Retail
WHERE InvoiceNo IS NULL;

-- Check Distinct Products
SELECT COUNT(DISTINCT Description) AS Total_Products
FROM PortfolioProject..Online_Retail;

-- Check Negative Quantities
SELECT *
FROM PortfolioProject..Online_Retail
WHERE Quantity < 0;

-- Check Invalid Unit Prices
SELECT *
FROM PortfolioProject..Online_Retail
WHERE UnitPrice <= 0;





/* --------------------------------------------------------
   DATA CLEANING & TRANSFORMATION
-------------------------------------------------------- */

-- Convert InvoiceDate to Date Format
SELECT 
    InvoiceDate,
    CONVERT(DATE, InvoiceDate) AS InvoiceDateConverted
FROM PortfolioProject..Online_Retail;


ALTER TABLE PortfolioProject..Online_Retail
ADD InvoiceDateConverted DATE;


UPDATE PortfolioProject..Online_Retail
SET InvoiceDateConverted = CONVERT(DATE, InvoiceDate);


SELECT 
    InvoiceDate,
    InvoiceDateConverted
FROM PortfolioProject..Online_Retail;





/* --------------------------------------------------------
   CREATE CLEANED TABLE
-------------------------------------------------------- */

SELECT *
INTO Online_Retail_Cleaned
FROM PortfolioProject..Online_Retail
WHERE CustomerID IS NOT NULL
AND InvoiceNo IS NOT NULL
AND Quantity > 0
AND UnitPrice > 0;


SELECT TOP 5 *
FROM Online_Retail_Cleaned;


SELECT *
FROM PortfolioProject..Online_Retail_Cleaned
WHERE CustomerID IS NULL
OR InvoiceNo IS NULL
OR Quantity < 0
OR UnitPrice <= 0;





/* --------------------------------------------------------
   REVENUE COLUMN CREATION
-------------------------------------------------------- */


SELECT 
    InvoiceNo,
    Quantity,
    UnitPrice,
    Quantity * UnitPrice AS Revenue
FROM Online_Retail_Cleaned;


ALTER TABLE Online_Retail_Cleaned
ADD Revenue DECIMAL(10,2);


UPDATE Online_Retail_Cleaned
SET Revenue = Quantity * UnitPrice;





/* --------------------------------------------------------
   KPI ANALYSIS
-------------------------------------------------------- */

-- Total Revenue, Total Customers, Average Transaction Value
SELECT 
    SUM(Revenue) AS Total_Revenue,
    COUNT(DISTINCT CustomerID) AS Total_Customers,
    AVG(Revenue) AS Avg_Transaction_Value
FROM Online_Retail_Cleaned;





/* --------------------------------------------------------
   SALES TREND ANALYSIS
-------------------------------------------------------- */

-- Monthly Sales Trend
SELECT
    YEAR(InvoiceDateConverted) AS Year_No,
    MONTH(InvoiceDateConverted) AS Month_No,
    SUM(Revenue) AS Total_Revenue
FROM Online_Retail_Cleaned
GROUP BY
    YEAR(InvoiceDateConverted),
    MONTH(InvoiceDateConverted)
ORDER BY
    Year_No,
    Month_No;





/* --------------------------------------------------------
   PRODUCT ANALYSIS
-------------------------------------------------------- */

-- Top 10 Products by Revenue
SELECT TOP 10
    Description,
    SUM(Revenue) AS Total_Revenue
FROM Online_Retail_Cleaned
WHERE Description IS NOT NULL
GROUP BY Description
ORDER BY Total_Revenue DESC;

-- Top 10 Frequently Ordered Products
SELECT TOP 10
    Description,
    SUM(Quantity) AS Total_Quantity
FROM Online_Retail_Cleaned
WHERE Description IS NOT NULL
GROUP BY Description
ORDER BY Total_Quantity DESC;





/* --------------------------------------------------------
   CUSTOMER ANALYSIS
-------------------------------------------------------- */

-- Top 10 Customers by Spending
SELECT TOP 10
    CustomerID,
    SUM(Revenue) AS Total_Revenue
FROM Online_Retail_Cleaned
GROUP BY CustomerID
ORDER BY Total_Revenue DESC;

-- Repeat Customers
SELECT
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS Total_Orders
FROM Online_Retail_Cleaned
GROUP BY CustomerID
HAVING COUNT(DISTINCT InvoiceNo) > 1
ORDER BY Total_Orders DESC;

-- Customer Segmentation
SELECT
    CustomerID,
    SUM(Revenue) AS Total_Spending,
    CASE
        WHEN SUM(Revenue) > 10000 THEN 'High Value'
        WHEN SUM(Revenue) BETWEEN 5000 AND 10000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS Customer_Category
FROM Online_Retail_Cleaned
GROUP BY CustomerID
ORDER BY Total_Spending DESC;





/* --------------------------------------------------------
   COUNTRY ANALYSIS
-------------------------------------------------------- */

-- Top 10 Countries by Revenue
SELECT TOP 10
    Country,
    SUM(Revenue) AS Total_Revenue
FROM Online_Retail_Cleaned
WHERE Country IS NOT NULL
GROUP BY Country
ORDER BY Total_Revenue DESC;

-- Country-wise Revenue Contribution
SELECT
    Country,
    SUM(Revenue) AS Total_Revenue,
    ROUND(
        (SUM(Revenue) * 100.0) /
        SUM(SUM(Revenue)) OVER(),
        2
    ) AS Revenue_Percentage
FROM Online_Retail_Cleaned
WHERE Country IS NOT NULL
GROUP BY Country
ORDER BY Total_Revenue DESC;





/* --------------------------------------------------------
   ADVANCED ANALYSIS
-------------------------------------------------------- */

-- Monthly Growth Analysis
WITH MonthlySales AS (
    SELECT
        YEAR(InvoiceDateConverted) AS Year_No,
        MONTH(InvoiceDateConverted) AS Month_No,
        SUM(Revenue) AS Total_Revenue
    FROM Online_Retail_Cleaned
    GROUP BY
        YEAR(InvoiceDateConverted),
        MONTH(InvoiceDateConverted)
)

SELECT *,
    LAG(Total_Revenue) OVER(
        ORDER BY Year_No, Month_No
    ) AS Previous_Month_Revenue
FROM MonthlySales;




SELECT TOP 5 *
FROM Online_Retail_Cleaned;
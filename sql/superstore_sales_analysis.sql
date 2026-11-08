/*
SUPERSTORE SALES ANALYSIS — SQL statements transcribed verbatim from the report.
Source: https://medium.com/@dumoaby/superstore-sales-analysis-52dbe6710270

Microsoft SQL Server (T-SQL). The source report's SQL snippets are preserved in sequence.
Before dimension creation, import the CSV into dbo.Superstore in SuperstoreDB.
The report's city/state-only location joins can multiply records if values are not unique.
The original margin expression and sales aliases are retained as published.
See README.md for interpretation and known limitations.
*/


/* ===== Create database ===== */
CREATE DATABASE SuperstoreDB;


/* ===== Create DimDate ===== */
SELECT DISTINCT
Order_Date,
YEAR(Order_Date) AS Year,
MONTH(Order_Date) AS Month_Number,
DAY(Order_Date) AS Day_Number,
DATENAME(MONTH, Order_Date) AS Month_Name,
DATENAME(WEEKDAY, Order_Date) AS Day_Name,
LEFT(DATENAME(MONTH, Order_Date),3) AS Month_Short,
LEFT(DATENAME(WEEKDAY, Order_Date),3) AS Day_Short
INTO DimDate
FROM [dbo].[Superstore];


/* ===== Create DimProduct ===== */
SELECT DISTINCT
Product_ID, Product_Name, Category, Sub_Category
INTO DimProduct
FROM [dbo].[Superstore];


/* ===== Create DimCustomer ===== */
SELECT DISTINCT
Customer_ID, Customer_Name, Segment
INTO DimCustomer
FROM [dbo].[Superstore];


/* ===== Create DimLocation ===== */
SELECT DISTINCT
Country, City, State, Postal_Code, Region
INTO DimLocation
FROM [dbo].[Superstore];


/* ===== Product profit margin ===== */
---Calculate Profit Margin of the Product
SELECT Product_Name,
(Profit/Sales) *100 AS Profit_Margin
FROM [dbo].[Superstore];


/* ===== Sales and profit by category ===== */
---What are the sales and profit for each product category?
---Note: If you are joining two tables, you have to give them "Alias"
---We need Superstore, DimProduct
---Superstore(alias S)
----DimProduct(alias P)
SELECT P.Category,
SUM(S.Sales) AS Total_Sales,
SUM(S.Profit) AS Total_Profit
FROM Superstore AS S
INNER JOIN DimProduct AS P
ON S.Product_ID = P.Product_ID
GROUP BY P.Category
ORDER BY Total_Sales DESC;


/* ===== Annual sales ===== */
---Which year recorded the highest sales?
---DimDate, Superstore
---DimDate(alias D)
---Superstore(alias S)
SELECT D.[Year],
SUM(S.Sales) AS Total_Sales
FROM Superstore AS S
INNER JOIN DimDate AS D
ON S.Order_Date = D.Order_Date
GROUP BY D.[Year]
ORDER BY Total_Sales DESC;


/* ===== Sales by city ===== */
---Which city generate the most sales?
---DimLocation(alias L) -City
---Superstore(alias S) -Sales
SELECT L.City,
ROUND(SUM(S.Sales), 2) AS Total_Sales
FROM Superstore AS S
INNER JOIN DimLocation AS L
ON S.City = L.City
GROUP BY L.City
ORDER BY Total_Sales DESC;


/* ===== Average sales by customer segment ===== */
---Which segment has the highest average sales? (average-AVG)
----DimCustomer (alias C)
----Superstore(alias S)
SELECT C.Segment,
ROUND(AVG(S.Sales), 2) AS Avg_Sales
FROM Superstore AS S
INNER JOIN DimCustomer AS C
ON S.Customer_ID = C.Customer_ID
GROUP BY C.Segment
ORDER BY Avg_Sales DESC;


/* ===== Highest-spending customer ===== */
---Find the customer with the highest purchase?
---DimCustomer(alias C) -Customer_ID, Customer_Name
---Superstore(alias S) -Sales
SELECT TOP 1 C.Customer_ID, C.Customer_Name,
SUM(S.Sales) AS Total_Sales
FROM Superstore AS S
INNER JOIN DimCustomer AS C
ON S.Customer_ID = C.Customer_ID
GROUP BY C.Customer_ID, C.Customer_Name
ORDER BY Total_Sales DESC;


/* ===== Los Angeles customer sales ===== */
---Find Los Angeles customers and display the highest purchaser
---Superstore(alias S) -Sales, Customer_Name
---Location(alias L) -City
SELECT S.Customer_Name, L.City,
SUM(S.Sales) AS Total_Purchase
FROM Superstore AS S
JOIN DimLocation AS L
ON S.City = L.City
WHERE L.City = 'Los Angeles'
GROUP BY S.Customer_Name, L.City
ORDER BY Total_Purchase DESC;


/* ===== Five most profitable products ===== */
---Show 5 most profitable product(High Profit)
----Superstore(alias S)
----DimProduct(alias P)
SELECT TOP 5 P.Product_ID, P.Product_Name,
SUM(S.Profit) AS Total_Profit
FROM Superstore AS S
JOIN DimProduct AS P
ON S.Product_ID = P.Product_ID
GROUP BY P.Product_ID, P.Product_Name
ORDER BY Total_Profit DESC;


/* ===== Top three Texas customers ===== */
--Find Texas customers and display the top 3 highest purchasers
---Superstore(alias S) -Sales, Customer_Name
----Location (alias L) -State
SELECT TOP 3 S.Customer_Name, L.State,
SUM(S.Sales) AS Total_Purchase
FROM Superstore AS S
JOIN DimLocation AS L
ON S.State =L.State
WHERE L.State ='Texas'
GROUP BY S.Customer_Name, L.State
ORDER BY Total_Purchase DESC


/* ===== Five products with highest sales ===== */
---Find the TOP 5 highest priced products
---Superstore(alias S) -Sales
----DimProduct(alias P)
SELECT TOP 5 P.Product_ID,
SUM(S.Sales) AS Price
FROM Superstore AS S
JOIN DimProduct AS P
ON S.Product_ID = P.Product_ID
GROUP BY P.Product_ID
ORDER BY Price DESC;


/* ===== Three products with lowest sales ===== */
--Find the Least 3 Cheapest products
---Superstore(alias S) -Sales
---DimProduct(alias P) -Product
SELECT TOP 3 P.Product_ID,P.Product_Name,
SUM(S.Sales) AS Price
FROM Superstore AS S
JOIN DimProduct AS P
ON S.Product_ID =P.Product_ID
GROUP BY P.Product_ID,P.Product_Name
ORDER BY Price ASC;

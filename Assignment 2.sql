--How many products can you find in the Production.Product table?
SELECT COUNT(p.ProductID)
FROM Production.Product as p;

-- Write a query that retrieves the number of products in the Production.Product table that are included in a subcategory. The rows that have NULL in column ProductSubcategoryID are considered to not be a part of any subcategory.
SELECT COUNT(p.ProductSubcategoryID)
FROM Production.Product as p;

/*How many Products reside in each SubCategory? Write a query to display the results with the following titles.

ProductSubcategoryID CountedProducts

-------------------- ---------------*/
SELECT p.ProductSubcategoryID, COUNT(*) as CountedProducts
FROM Production.Product as p
GROUP BY p.ProductSubcategoryID;

--How many products that do not have a product subcategory.
SELECT COUNT(*)
FROM Production.Product as p
WHERE p.ProductSubcategoryID IS NULL;

--Write a query to list the sum of products quantity in the Production.ProductInventory table.
SELECT p.ProductID, SUM(p.Quantity) as TotalQuantity
FROM Production.ProductInventory as p
GROUP BY p.ProductID;

/*Write a query to list the sum of products in the Production.ProductInventory table and LocationID set to 40 and limit the result to include just summarized quantities less than 100.

              ProductID    TheSum

              -----------        ----------*/

SELECT p.ProductID, SUM(p.Quantity) as TheSum
FROM Production.ProductInventory as p
WHERE p.LocationID = 40
GROUP BY p.ProductID
HAVING SUM(p.Quantity) <100

/*7.    Write a query to list the sum of products with the shelf information in the Production.ProductInventory table and LocationID set to 40 and limit the result to include just summarized quantities less than 100

    Shelf      ProductID    TheSum

    ----------   -----------        -----------*/
SELECT p.Shelf, p.ProductID, SUM(p.Quantity) as TheSum
FROM Production.ProductInventory as p
WHERE p.LocationID = 40
GROUP BY p.ProductID, p.Shelf
HAVING SUM(p.Quantity) <100;

--Write the query to list the average quantity for products where column LocationID has the value of 10 from the table Production.ProductInventory table
SELECT AVG(p.Quantity) as TheAverage
FROM Production.ProductInventory as p
WHERE p.LocationID = 10;

/*9.    Write query  to see the average quantity  of  products by shelf  from the table Production.ProductInventory

    ProductID   Shelf      TheAvg

    ----------- ---------- -----------*/

SELECT p.ProductID, p.Shelf ,AVG(p.Quantity) as TheAvg
FROM Production.ProductInventory as p
GROUP BY p.ProductID, p.Shelf;

/* Write query  to see the average quantity  of  products by shelf excluding rows that has the value of N/A in the column Shelf from the table Production.ProductInventory

    ProductID   Shelf      TheAvg

    ----------- ---------- -----------*/

SELECT p.ProductID, p.Shelf ,AVG(p.Quantity) as TheAvg
FROM Production.ProductInventory as p
WHERE p.Shelf != 'N/A'
GROUP BY p.ProductID, p.Shelf;

/*List the members (rows) and average list price in the Production.Product table. This should be grouped independently over the Color and the Class column. Exclude the rows where Color or Class are null.

    Color                        Class              TheCount          AvgPrice

    -------------- - -----    -----------            ---------------------*/
SELECT p.Color, p.Class, COUNT(Color) as TheCount, AVG(p.ListPrice) as AvgPrice
FROM Production.Product as p
WHERE p.Color IS NOT NULL AND p.Class IS NOT NULL
GROUP BY p.Color, p.Class

    
/*12.   Write a query that lists the country and province names from person. CountryRegion and person. StateProvince tables. Join them and produce a result set similar to the following.

    Country                        Province

    ---------                          ----------------------*/
SELECT cr.Name AS Country, sp.Name AS Province
FROM Person.StateProvince AS sp
JOIN Person.CountryRegion AS cr
ON sp.CountryRegionCode = cr.CountryRegionCode
ORDER BY cr.Name, sp.Name;


/*13.  Write a query that lists the country and province names from person. CountryRegion and person. StateProvince tables and list the countries filter them by Germany and Canada. Join them and produce a result set similar to the following.

 

    Country                        Province

    ---------                          ----------------------*/

SELECT cr.Name AS Country, sp.Name AS Province
FROM Person.StateProvince AS sp
JOIN Person.CountryRegion AS cr
ON sp.CountryRegionCode = cr.CountryRegionCode
WHERE cr.Name IN ('Germany', 'Canada')
ORDER BY cr.Name, sp.Name;
 /*Using Northwnd Database: (Use aliases for all the Joins)*/

--14.  List all Products that has been sold at least once in last 27 years.

SELECT DISTINCT p.ProductID, p.ProductName
FROM dbo.Products as p
JOIN dbo.[Order Details] as od
ON p.ProductID = od.ProductID
JOIN dbo.Orders as o
ON od.OrderID = o.OrderID
WHERE o.OrderDate >= DATEADD(YEAR, -27, GETDATE());

--15.  List top 5 locations (Zip Code) where the products sold most.
SELECT TOP 5 o.ShipPostalCode as ZipCode, SUM(od.Quantity) as TotalQuantity
FROM dbo.[Order Details] as od
JOIN dbo.Orders as o
ON od.OrderID = o.OrderID
WHERE o.ShipPostalCode IS NOT NULL
GROUP BY o.ShipPostalCode
ORDER BY TotalQuantity DESC;

--16.  List top 5 locations (Zip Code) where the products sold most in last 27 years.
SELECT TOP 5 o.ShipPostalCode as ZipCode, SUM(od.Quantity) as TotalQuantity
FROM dbo.[Order Details] as od
JOIN dbo.Orders as o
ON od.OrderID = o.OrderID
WHERE o.ShipPostalCode IS NOT NULL AND o.OrderDate >= DATEADD(YEAR, -27, GETDATE())
GROUP BY o.ShipPostalCode
ORDER BY TotalQuantity DESC;

--17.   List all city names and number of customers in that city. 
SELECT c.City, COUNT(*) as CustomerCount
FROM dbo.Customers c
GROUP BY c.City;

--18.  List city names which have more than 2 customers, and number of customers in that city
SELECT c.City, COUNT(*) as CustomerCount
FROM dbo.Customers c
GROUP BY c.City
HAVING COUNT(*) > 2;

--19.  List the names of customers who placed orders after 1/1/98 with order date.
SELECT DISTINCT c.ContactName
FROM dbo.Customers c
JOIN dbo.Orders o
ON c.CustomerID = o.CustomerID
WHERE o.OrderDate > '1998-01-01'

--20.  List the names of all customers with most recent order dates
SELECT DISTINCT c.ContactName, MAX(o.OrderDate) as MostRecentOrderDate
FROM dbo.Customers c
JOIN dbo.Orders o
ON c.CustomerID = o.CustomerID
GROUP BY c.ContactName
ORDER BY MostRecentOrderDate DESC

--21.  Display the names of all customers  along with the  count of products they bought
SELECT c.ContactName, SUM(od.Quantity) as TotalProducts
FROM dbo.Customers c
JOIN dbo.Orders o
ON c.CustomerID = o.CustomerID
JOIN dbo.[Order Details] od 
ON o.OrderID = od.OrderID
GROUP BY c.ContactName;

--22.  Display the customer ids who bought more than 100 Products with count of products.
SELECT o.CustomerID, SUM(od.Quantity) as TotalProducts
FROM dbo.Orders o
JOIN dbo.[Order Details] od 
ON o.OrderID = od.OrderID
GROUP BY o.CustomerID
HAVING SUM(od.Quantity) >100;

/*23.  List all of the possible ways that suppliers can ship their products. Display the results as below

    Supplier Company Name                Shipping Company Name

    ---------------------------------            ----------------------------------*/
SELECT DISTINCT s.CompanyName AS [Supplier Company Name], sh.CompanyName AS [Shipping Company Name]
FROM dbo.Suppliers AS s
JOIN dbo.Products AS p 
ON s.SupplierID = p.SupplierID
JOIN dbo.[Order Details] AS od 
ON p.ProductID = od.ProductID
JOIN dbo.Orders AS o 
ON od.OrderID = o.OrderID
JOIN dbo.Shippers AS sh
ON o.ShipVia = sh.ShipperID
ORDER BY s.CompanyName, sh.CompanyName;



--24.  Display the products order each day. Show Order date and Product Name.
SELECT o.OrderDate, p.ProductName
FROM dbo.Orders AS o
JOIN dbo.[Order Details] AS od 
ON o.OrderID = od.OrderID
JOIN dbo.Products AS p 
ON od.ProductID = p.ProductID
ORDER BY o.OrderDate, p.ProductName;

--25.  Displays pairs of employees who have the same job title.
SELECT 
  e1.EmployeeID AS Employee1ID,
  e1.FirstName + ' ' + e1.LastName AS Employee1Name,
  e2.EmployeeID AS Employee2ID,
  e2.FirstName + ' ' + e2.LastName AS Employee2Name,
  e1.Title
FROM dbo.Employees AS e1
JOIN dbo.Employees AS e2 
  ON e1.Title = e2.Title 
  AND e1.EmployeeID < e2.EmployeeID
ORDER BY e1.Title, Employee1Name, Employee2Name;


--26.  Display all the Managers who have more than 2 employees reporting to them.
SELECT e1.FirstName + ' ' + e1.LastName AS ManagerName, e2.ReportCount
FROM dbo.Employees AS e1
JOIN (
    SELECT e.ReportsTo, COUNT(*) AS ReportCount
    FROM dbo.Employees AS e 
    WHERE e.ReportsTo IS NOT NULL
    GROUP BY e.ReportsTo
    HAVING COUNT(*) > 2
) AS e2
ON e1.EmployeeID = e2.ReportsTo;


/*27.  Display the customers and suppliers by city. The results should have the following columns

City

Name

Contact Name,

Type (Customer or Supplier)

*/

SELECT City,CompanyName AS Name, ContactName, 'Customer' AS Type
FROM dbo.Customers

UNION ALL

SELECT City, CompanyName AS Name, ContactName, 'Supplier' AS Type
FROM dbo.Suppliers

ORDER BY City, Type, Name;

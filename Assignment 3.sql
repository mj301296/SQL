--1.      List all cities that have both Employees and Customers.

SELECT e.City
FROM dbo.Employees e

INTERSECT

SELECT c.City
FROM dbo.Customers c

--2.      List all cities that have Customers but no Employee.

--a.      Use sub-query
SELECT DISTINCT c.City
FROM dbo.Customers c
WHERE c.City NOT IN (SELECT DISTINCT e.City
FROM dbo.Employees e)

--b.      Do not use sub-query
SELECT DISTINCT c.City
FROM dbo.Customers c
EXCEPT
SELECT DISTINCT e.City
FROM dbo.Employees e





--3.      List all products and their total order quantities throughout all orders.
SELECT p.ProductName, SUM(od.Quantity) as TotalQuantity
FROM dbo.Products p 
JOIN dbo.[Order Details] od 
ON p.ProductID = od.ProductID
GROUP BY p.ProductName

--4.      List all Customer Cities and total products ordered by that city.
SELECT c.City, SUM(od.Quantity) AS TotalProductsOrdered
FROM dbo.Customers c
JOIN Orders o 
ON c.CustomerID = o.CustomerID
JOIN dbo.[Order Details] od 
ON o.OrderID = od.OrderID
GROUP BY c.City;

--5.      List all Customer Cities that have at least two customers.
SELECT c.City
FROM dbo.Customers c
GROUP BY c.City
HAVING COUNT(c.CustomerID) >= 2;

--6.      List all Customer Cities that have ordered at least two different kinds of products.
SELECT c.City
FROM dbo.Customers c
JOIN Orders o 
ON c.CustomerID = o.CustomerID
JOIN dbo.[Order Details] od 
ON o.OrderID = od.OrderID
GROUP BY c.City
HAVING COUNT(DISTINCT od.ProductID) >= 2;

--7.      List all Customers who have ordered products, but have the ‘ship city’ on the order different from their own customer cities.
SELECT DISTINCT c.CustomerID, c.CompanyName, c.City
FROM dbo.Customers c
JOIN dbo.Orders o 
ON c.CustomerID = o.CustomerID
WHERE c.City <> o.ShipCity;
--8.      List 5 most popular products, their average price, and the customer city that ordered most quantity of it.
WITH TopProducts AS (
    SELECT TOP 5 od.ProductID, SUM(od.Quantity) AS TotalQty
    FROM dbo.[Order Details] od
    GROUP BY od.ProductID
    ORDER BY TotalQty DESC
),
CityProductTotals AS (
    SELECT 
        od.ProductID,
        c.City,
        SUM(od.Quantity) AS Qty,
        AVG(od.UnitPrice) AS AvgPrice
    FROM dbo.[Order Details] od
    JOIN dbo.Orders o 
    ON od.OrderID = o.OrderID
    JOIN dbo.Customers c 
    ON o.CustomerID = c.CustomerID
    WHERE od.ProductID IN (SELECT ProductID FROM TopProducts)
    GROUP BY od.ProductID, c.City
),
TopCityPerProduct AS (
    SELECT *
    FROM CityProductTotals
    WHERE Qty = (
        SELECT MAX(Qty)
        FROM CityProductTotals cp2
        WHERE cp2.ProductID = CityProductTotals.ProductID
    )
)
SELECT ProductID, City, AvgPrice
FROM TopCityPerProduct;


--9.      List all cities that have never ordered something but we have employees there.

--a.      Use sub-query
SELECT DISTINCT e.City
FROM dbo.Employees e
WHERE e.City NOT IN (
    SELECT DISTINCT c.City
    FROM dbo.Customers c
    WHERE c.CustomerID IN(
        SELECT DISTINCT o.CustomerID
        FROM dbo.Orders o
    )
);

--b.      Do not use sub-query
SELECT DISTINCT e.City
FROM dbo.Employees e
LEFT JOIN dbo.Customers c ON e.City = c.City
LEFT JOIN dbo.Orders o ON c.CustomerID = o.CustomerID
WHERE o.OrderID IS NULL;
--10.  List one city, if exists, that is the city from where the employee sold most orders (not the product quantity) is, and also the city of most total quantity of products ordered from. (tip: join  sub-query)
-- City with most orders by employee
WITH EmpOrderCount AS (
    SELECT e.City AS EmpCity, COUNT(o.OrderID) AS OrderCount
    FROM dbo.Employees e
    JOIN dbo.Orders o ON e.EmployeeID = o.EmployeeID
    GROUP BY e.City
),
TopEmpCity AS (
    SELECT TOP 1 EmpCity FROM EmpOrderCount ORDER BY OrderCount DESC
),

-- City with most quantity ordered
CustCityQty AS (
    SELECT c.City AS CustCity, SUM(od.Quantity) AS TotalQty
    FROM dbo.Customers c
    JOIN dbo.Orders o ON c.CustomerID = o.CustomerID
    JOIN dbo.[Order Details] od ON o.OrderID = od.OrderID
    GROUP BY c.City
),
TopCustCity AS (
    SELECT TOP 1 CustCity FROM CustCityQty ORDER BY TotalQty DESC
)

-- Final result if same city appears in both
SELECT t1.EmpCity
FROM TopEmpCity t1
JOIN TopCustCity t2 ON t1.EmpCity = t2.CustCity;

--11. How do you remove the duplicates record of a table?
/*Use the GROUP BY clause along with MIN(SN) to retain one unique row for each duplicate group. 
This method identifies the first occurrence of each duplicate combination based on the SN (serial number) and deletes the other duplicate rows.*/
DELETE FROM TableName
WHERE ID NOT IN (
    SELECT MIN(ID)
    FROM TableName
    GROUP BY col1, col2, col3
);

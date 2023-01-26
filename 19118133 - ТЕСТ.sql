USE DBProgrammingPubs
GO 

create table Sales2008 
(ProductID int PRIMARY KEY,
ProductName nvarchar(40),
TotalSales money)
go

INSERT INTO Sales2008
select p.ProductID,p.ProductName,SUM(od.Quantity*od.UnitPrice)as SumOfQU
from NorthWind.dbo.Products p inner join NorthWind.dbo.[Order Details] od on p.ProductID = od.ProductID
								inner join NorthWind.dbo.Orders o on o.OrderID = od.OrderID
where YEAR(OrderDate) = 2008
group by p.ProductID,ProductName
go

DELETE FROM Sales2008
WHERE TotalSales < 50000
go

DROP TABLE Sales2008
go

CREATE VIEW schema_19118133.ProductView
AS
SELECT ProductID,ProductName, CompanyName,Origin = 
											CASE 
												WHEN Country = 'USA' THEN 'USA'
												ELSE 'Not USA'
												END
FROM NorthWind.dbo.Products P inner join NorthWind.dbo.Suppliers s on p.SupplierID = s.SupplierID
go


SELECT	CompanyName,Origin,SUM(Quantity*UnitPrice) AS SumQU
FROM ProductView PV inner join NorthWind.dbo.[Order Details] od on pv.ProductID = od.ProductID
WHERE Origin = 'USA'
GROUP BY ProductName,CompanyName,Origin
ORDER BY SumQU DESC 
go

DROP VIEW ProductView
go

CREATE FUNCTION schema_19118133.Sum_Customer_Sales(@customer_id nvarchar(5))
RETURNS money 
as 
begin 
	declare @sumQU money 
	select @sumQU = Quantity*UnitPrice 
	from NorthWind.dbo.[Order Details] od inner join NorthWind.dbo.Orders o on od.OrderID = o.OrderID
											inner join NorthWind.dbo.Customers C on c.CustomerID = o.CustomerID
	WHERE c.CustomerID = @customer_id
	IF @sumQU IS NULL 
	SET @sumQU = 0 
RETURN @sumQU
END
go

SELECT CustomerID,CompanyName,Country,schema_19118133.Sum_Customer_Sales(CustomerID) as SumOfQu
FROM NorthWind.dbo.Customers 
WHERE Country IN('Spain','France','Portugal')
go


DROP FUNCTION schema_19118133.Sum_Customer_Sales
go



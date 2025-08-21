CREATE OR ALTER FUNCTION
	dbo.ufn_customer_category(@CustomerID char(5))
RETURNS CHAR(5) AS
BEGIN
	DECLARE @total_amount DECIMAL(18,2);
	DECLARE @category CHAR(10);

	SELECT @total_amount = SUM([Freight])
	FROM Orders
	WHERE customerid = @CustomerId;

	IF @total_amount < 500000
		SET @category = 'REGULAR';
	ELSE IF @total_amount < 1000000
		SET @category = 'GOLD';
	ELSE
		SET @category = 'PLATINUM';

	RETURN @category;
END

ALTER DATABASE NWIND SET COMPATIBILITY_LEVEL = 120;
ALTER DATABASE NWIND SET COMPATIBILITY_LEVEL = 160;

SELECT * FROM sys.sql_modules
WHERE object_id = OBJECT_ID('ufn_customer_category')
GO

set statistics io, time on
--Plan beobachten

SELECT TOP 1000
		Customerid, Companyname,
       dbo.ufn_customer_category(Customerid) AS [Fracht]
FROM Customers
ORDER BY Customerid
OPTION (RECOMPILE,USE HINT('DISABLE_TSQL_SCALAR_UDF_INLINING'));
GO
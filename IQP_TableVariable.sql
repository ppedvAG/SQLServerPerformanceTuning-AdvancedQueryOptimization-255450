ALTER DATABASE NWIND SET COMPATIBILITY_LEVEL = 120;  --1
ALTER DATABASE NWIND SET COMPATIBILITY_LEVEL = 130; --1
ALTER DATABASE NWIND SET COMPATIBILITY_LEVEL = 140; --1
ALTER DATABASE NWIND SET COMPATIBILITY_LEVEL = 150;
GO

set statistics io, time on

DECLARE @OrderDet TABLE
	([Orderid] BIGINT NOT NULL,
	 Quantity INT NOT NULL
	);
	INSERT @OrderDet
	SELECT [Orderid], [Quantity]
	FROM [Order Details]
		WHERE  [Quantity] > 99;


-- Look at estimated rows, speed, join algorithm
SELECT oh.orderid, oh.orderdate,
   oh.freight
FROM orders AS oh
INNER JOIN @OrderDet AS o 	ON o.orderid = oh.orderid
WHERE oh.freight < 10.10
ORDER BY oh.freight DESC;
GO



ALTER DATABASE NWIND SET COMPATIBILITY_LEVEL = 120;
ALTER DATABASE NWIND SET COMPATIBILITY_LEVEL = 160;

use nwind;
GO


create or alter function dbo.fn_Rsumme (@oderid as int)
returns money
as
begin
return (select sum(unitprice*quantity) from [Order Details]
		where orderid = @oderid)
end;
GO


set statistics io, time on

select top 100000 
			orderid, freight, customerid, orderdate ,
			dbo.fn_Rsumme(orderid)
from orders
OPTION (RECOMPILE,USE HINT('DISABLE_TSQL_SCALAR_UDF_INLINING'));
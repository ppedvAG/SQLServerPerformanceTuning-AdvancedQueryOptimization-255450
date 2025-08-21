---Function

--Funktion .. super praktisch , aber immer zu überdenken

--sql server kann ab einer bestimmten Verion 2017 /2022
--Funktionen im Hintergrund optimieren.

--verzögerte Kompilierung
--F() in UNterabfragen.. ohne die Anwendung selbst zu beeinflussen
--aber das alles nur in Grenzen

--Daher .. wenn möglich auf F() verzichten oder zumindest regelm
--auf Performance kontrollieren
--Plan, Seiten , Dauer etc.

--F() werden auch nicht paralleisiert
--F() in Where um eine Spalte fürht immer zu einem SCAN

ALTER DATABASE [northwind] SET COMPATIBILITY_LEVEL = 120
GO

set statistics io, time on


create function fbrutto (@par1 int) returns int
as
Begin 
	return (select @par1 *1.19)
end
GO

select dbo.fbrutto(100)

select *, dbo.fbrutto(freight) from orders 
where dbo.fbrutto(freight) > 100



create function fRngSumme(@BestId int) returns money
as
begin 
	return
	(select sum(unitprice*quantity) from [Order Details]
	where orderid = @BestId		
	)
end


--Wie komme ich zur Rechnungssumme

select sum(unitprice*quantity) from [Order Details]
where orderid = 10248



select orderid, dbo.frngsumme(orderid) from orders 
where dbo.frngsumme(orderid) > 10000
order by orderid

--Crazy Plan und Statistics. Wo ist die Order details

--mit 
ALTER DATABASE [northwind] SET COMPATIBILITY_LEVEL = 160
GO
--Problem vorerst verschwunden

dbcc freeproccache
alter table orders add RngSumme as dbo.frngsumme(orderid)

select dbo.frngsumme(orderid),* from orders
where rngsumme > 10000

--Problem wieder da...

--F() im where


select * from customers where customerid like 'A%'

select * from customers where left(customerid, 1) = 'A'

--zeige alle Ang die jetzt in Rente sind (Rente ab 65 Jahren)
select * from employees
--				where datediff(yy, Birthdate,Getdate()) >= 65
				where  Birthdate <=  dateadd(yy, -65, Getdate())
--				where 


declare @Rententag as datetime
set  @Rententag =  dateadd(yy, -65, Getdate())



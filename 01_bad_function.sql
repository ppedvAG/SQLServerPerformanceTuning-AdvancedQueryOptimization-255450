---Function

--Funktion .. super praktisch , aber immer zu überdenken

--sql server kann ab einer besteitmmten Verion 2017 /2022
--Funktionen im Hintergrund optimieren.
--verfögerte Kompilierung
--F() in UNterabfragen.. ohne die Anwendung selbst zu beeinflussen
--aber das alles nur in Grenzen

--Daher .. wenn möglich auf F() verzichten oder zumindest regelm
--auf Performance kontrollieren
--Plan, Seiten , Dauer etc.

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

dbcc freeproccache
alter table orders add RngSumme as dbo.frngsumme(orderid)

select dbo.frngsumme(orderid),* from orders
where rngsumme > 10000

set statistics io, time on

select * from orders
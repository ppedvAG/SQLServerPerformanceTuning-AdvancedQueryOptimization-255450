create view VName
as
--nur 1 SELECT 

/*
a) ad hoc
b) Sicht 
c) Proc
f) f()

-----------------------> schnell
dcba

d      a|b     c


create proc gpName @par int
as
sel
ins
up
del





*/



create table slf
	(id int,
	 stadt int,
	 land int)


insert into slf
select 1,10,100
UNION ALL
select 2,20,200
UNION ALL
select 3,30,300


select * from slf


create or alter view vslf
as
select * from slf;
GO


select * from vslf

select * from slf


alter table slf add fluss int

update slf set fluss = id *1000

alter table slf drop column land

--besser so:
 drop table slf
 drop view vslf

create table slf
	(id int,
	 stadt int,
	 land int)


insert into slf
select 1,10,100
UNION ALL
select 2,20,200
UNION ALL
select 3,30,300


select * from slf


create or alter view vslf with schemabinding
as
select id, stadt, land from dbo.slf;	 --kein *  , angabe der DB Schemas
GO


select * from vslf

select * from slf


alter table slf add fluss int

update slf set fluss = id *1000

alter table slf drop column land




--------------------------------------
--weils bequem ist..
--------------------------------------

Create View vKundeUmsatz
as
SELECT   Customers.CustomerID, Customers.CompanyName, Customers.ContactName, Customers.ContactTitle, Customers.City, Customers.Country, Orders.EmployeeID, Orders.OrderDate, Orders.ShipVia, Orders.Freight, Orders.ShipCity, Orders.ShipCountry, [Order Details].OrderID, [Order Details].ProductID, [Order Details].UnitPrice, 
             [Order Details].Quantity, Products.ProductName, Products.UnitsInStock, Employees.LastName, Employees.FirstName
FROM     Customers INNER JOIN
         Orders ON Customers.CustomerID = Orders.CustomerID INNER JOIN
         [Order Details] ON Orders.OrderID = [Order Details].OrderID INNER JOIN
         Products ON [Order Details].ProductID = Products.ProductID INNER JOIN
         Employees ON Orders.EmployeeID = Employees.EmployeeID


 select  distinct companyname , productname from vkundeumsatz


 --Wieviele Kunden gibts in Germany   ?

 select * from vKundeUmsatz

 --falsches Ergtebnis

 --verwende die Sicht nur dann, webnn du alle Tabellen benötigst
 --, die in der Sicht abgefragt werden
 select count(*) from vKundeUmsatz where country = 'Germany'
 select count(*) from Customers where country = 'Germany'




select * from sys.views

select * from [INFORMATION_SCHEMA].[VIEWS]
where VIEW_DEFINITION like '%schemabinding%'






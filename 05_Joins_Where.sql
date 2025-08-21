--Reihenfolge von JOINs wichtig?
--Where im JOIN vorteilhaft?



Select * from customers c left join orders o on
	c.CustomerID=o.CustomerID
where o.ShipRegion='BC'


Select * from customers c left join orders o on
	c.CustomerID=o.CustomerID and o.shipregion = 'BC'

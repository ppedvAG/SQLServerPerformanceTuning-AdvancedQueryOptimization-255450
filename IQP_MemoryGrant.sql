-- Aktiviere den tatsächlichen Ausführungsplan (in SSMS)
--messen
set statistics io, time on
ALTER DATABASE Nwind SET COMPATIBILITY_LEVEL = 120;
ALTER DATABASE Nwind SET COMPATIBILITY_LEVEL = 160;

--MemroryGrantInfo beobachten

-- Speicherintensive Abfrage mit Sort und Aggregation
SELECT TOP 10000
    o.OrderID,
    o.OrderDate,
    c.CompanyName,
    SUM(od.UnitPrice * od.Quantity) AS Gesamt
FROM 
    Orders o
JOIN 
    [Order Details] od ON o.OrderID = od.OrderID
JOIN 
    Customers c ON o.CustomerID = c.CustomerID
GROUP BY 
    o.OrderID, o.OrderDate, c.CompanyName
ORDER BY 
    Gesamt DESC;
    583600

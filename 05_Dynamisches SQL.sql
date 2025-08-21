--1. Einfaches dynamisches SQL mit EXEC()

USE Northwind;
GO

DECLARE @sql NVARCHAR(MAX);

SET @sql = 'SELECT ProductID, ProductName, UnitPrice 
            FROM Products 
            WHERE UnitPrice > 30
            ORDER BY UnitPrice DESC;';

EXEC(@sql);
-- 💡 Hier wird einfach ein kompletter SQL-String zusammengesetzt und ausgeführt. 
-- Nachteil: Keine Parametrisierung → potenziell unsicher bei Benutzereingaben.

-- 2. Parametrisiertes dynamisches SQL mit sp_executesql
USE Northwind;
GO

DECLARE @sql NVARCHAR(MAX);
DECLARE @PriceLimit MONEY = 50;

SET @sql = N'SELECT ProductID, ProductName, UnitPrice
             FROM Products
             WHERE UnitPrice > @MinPrice
             ORDER BY UnitPrice DESC;';

EXEC sp_executesql @sql, N'@MinPrice MONEY', @MinPrice = @PriceLimit;
-- 💡 Vorteil: SQL-Injection-Schutz durch Parametrisierung.

--3. Dynamische Spaltenauswahl
USE Northwind;
GO

DECLARE @ColumnName SYSNAME = 'CompanyName';
DECLARE @sql NVARCHAR(MAX);

SET @sql = N'SELECT ' + QUOTENAME(@ColumnName) + N' 
            FROM Customers
            ORDER BY ' + QUOTENAME(@ColumnName) + ';';

EXEC(@sql);
-- 💡 QUOTENAME() sorgt dafür, dass nur gültige Spaltennamen verwendet werden → Schutz vor Injection.
-- und gibt Begrenzer an

-- 4. Dynamische Tabellenauswahl

USE Northwind;
GO

DECLARE @TableName SYSNAME = 'Orders';
DECLARE @sql NVARCHAR(MAX);

SET @sql = N'SELECT TOP 5 * 
            FROM ' + QUOTENAME(@TableName) + N'
            ORDER BY 1;';

EXEC(@sql);
-- 💡 Nützlich, wenn der Tabellenname erst zur Laufzeit bekannt ist.


-- 5. Dynamische WHERE-Bedingungen (flexible Filter)
USE Northwind;
GO

DECLARE @Country NVARCHAR(50) = 'Germany';
DECLARE @MinOrders INT = 5;
DECLARE @sql NVARCHAR(MAX);

SET @sql = N'SELECT c.CustomerID, c.CompanyName, COUNT(o.OrderID) AS OrderCount
            FROM Customers c
            JOIN Orders o ON c.CustomerID = o.CustomerID
            WHERE 1 = 1';

IF @Country IS NOT NULL
    SET @sql += N' AND c.Country = @Country';

SET @sql += N'
            GROUP BY c.CustomerID, c.CompanyName
            HAVING COUNT(o.OrderID) >= @MinOrders
            ORDER BY OrderCount DESC;';

EXEC sp_executesql 
    @sql,
    N'@Country NVARCHAR(50), @MinOrders INT',@Country = @Country, @MinOrders = @MinOrders;

-- 💡 Sehr praktisch, wenn optionale Filter dynamisch hinzugefügt werden sollen.

-- "Dynamisches SQL auf Steroiden".
--  Mini-Report-Generator in T-SQL, der mit der Northwind-Datenbank dynamisch
-- Tabelle, Spalten, Filter, Sortierung zur Laufzeit steuert.

--> (mit QUOTENAME + Parametern) und flexibel 

-- 💡 Mini-Report-Generator – Dynamisches SQL
USE Northwind;
GO

DECLARE 
    @TableName SYSNAME        = 'Products',           -- Tabelle
    @ColumnList NVARCHAR(MAX) = 'ProductID, ProductName, UnitPrice', -- Spalten
    @FilterCol SYSNAME        = 'UnitPrice',          -- Filterspalte
    @FilterOp NVARCHAR(10)    = '>',                  -- Vergleichsoperator
    @FilterVal SQL_VARIANT    = 20,                   -- Vergleichswert
    @SortCol SYSNAME          = 'UnitPrice',          -- Sortierspalte
    @SortDir NVARCHAR(4)      = 'DESC';               -- ASC / DESC

DECLARE @sql NVARCHAR(MAX);

-- Grundgerüst
SET @sql = N'SELECT ' + @ColumnList + 
           N' FROM ' + QUOTENAME(@TableName) + 
           N' WHERE ' + QUOTENAME(@FilterCol) + ' ' + @FilterOp + ' @FilterVal' +
           N' ORDER BY ' + QUOTENAME(@SortCol) + ' ' + @SortDir + ';';

-- Ausführen mit Parametrisierung
EXEC sp_executesql
    @sql,  N'@FilterVal SQL_VARIANT',     @FilterVal = @FilterVal;
-- 🔍 Wie das funktioniert
-- Tabelle & Spalten werden über QUOTENAME() geschützt → keine SQL-Injection über Objekt-Namen.

-- Wertfilter (@FilterVal) läuft als Parameter → sicher gegen Injection.
-- Operator (>, <, =) und Sortierrichtung werden nicht parametrisiert, da SQL Server das nicht zulässt 
-- sie werden aber geprüft (kann man mit CASE/IF validieren).
-- Spaltenliste könnte man ebenfalls validieren, wenn Benutzer-Eingaben aus einer UI kommen.
EXECUTE sp_executesql 
        N'SELECT * FROM orders   WHERE orderid = @level'
        , N'@level INT'
        , @level = 102489;


declare @sqlstr as nvarchar(50)
set @sqlstr = N'Select * from orders where orderid = @oid'

declare @paramDef as nvarchar(50)
set @paramDef = N'@oid as int'

declare @wert as int = 10248

execute sp_executesql @sqlstr, @paramDef, @wert

--ab SQL 2017: ALTER DATABASE SCOPED CONFIGURATION SET OPTIMIZED_SP_EXECUTESQL = ON;

--  aktiviert auf Datenbank-Ebene ein neues Verhalten für sp_executesql. 
-- Konkret führt der erste Aufruf einer bestimmten Abfrage über sp_executesql dazu, 
-- dass der Ausführungsplan kompiliert und anschließend im Plan-Cache hinterlegt wird. 
-- Weitere gleichartige Aufrufe müssen dann warten, bis der Plan verfügbar ist, 
-- und verwenden ihn direkt – anstatt parallel neue Pläne zu generieren 


-- Vorteil: 
-- Dies reduziert sogenannte Compilation Storms, also die gleichzeitige Kompilierung 
-- identischer Abfragen in mehreren Sessions. Dadurch sinkt der Overhead durch 
-- mehrfaches Kompilieren und durch redundante Einträge im Plan-Cache 
-- – das spart Ressourcen und kann die Performance verbessern

--Empfehlung:
-- Diese Einstellung sorgt dafür, dass Statistiken asynchron und 
-- ohne blockierende Sperren aktualisiert werden – was zusammen mit der 
-- Compile-Serialisierung Performance-Engpässe deutlich weiter minimieren kann 

ALTER DATABASE SCOPED CONFIGURATION SET ASYNC_STATS_UPDATE_WAIT_AT_LOW_PRIORITY = ON;





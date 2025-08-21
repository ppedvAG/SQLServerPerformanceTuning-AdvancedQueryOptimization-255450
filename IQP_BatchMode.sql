-- WICHTIG: Kompatibilitätslevel 160 aktivieren (SQL Server 2022)
--BactMode verarbeitet Paketweise (900) .. effizienter im Umgang mit CPU und RAM
--gut bei : Gruppierungen, Aggregationen, Window Functions etc.

/*
SQL Server Version	Batch Mode verfügbar für
SQL Server 2012	Nur bei Columnstore-Operatoren
SQL Server 2016+	Breitere Unterstützung, z. B. bei Hash Joins
SQL Server 2019	Einführung von Batch Mode on Rowstore (ohne Columnstore!)
SQL Server 2022	Noch bessere Integration, inkl. Adaptive Join & IQP
*/


ALTER DATABASE Nwind SET COMPATIBILITY_LEVEL = 120;
ALTER DATABASE Nwind SET COMPATIBILITY_LEVEL = 160;


-- Execution Plan anzeigen!
--und messen
SET STATISTICS io, time  ON;

-- Query, die Batch Mode auslösen kann (Aggregation über große Datenmenge)
USE NWIND
SELECT 
    Customerid,
    COUNT(*) AS Anzahl,
    AVG(freight) AS Durchschnittspreis
FROM 
    dbo.orders where customerid like 'A%'
GROUP BY 
    Customerid;


 --SelfDemo

-- Neue Demo-Tabelle
DROP TABLE IF EXISTS dbo.BatchModeDemo;
CREATE TABLE dbo.BatchModeDemo (
    ID INT NOT NULL PRIMARY KEY,
    CategoryID INT NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    Description NVARCHAR(100) NULL
);

-- Testdaten einfügen: 1 Million Zeilen
;WITH E1(N) AS (SELECT 1 UNION ALL SELECT 1),
E2(N) AS (SELECT 1 FROM E1 a, E1 b),       -- 4
E3(N) AS (SELECT 1 FROM E2 a, E2 b),       -- 16
E4(N) AS (SELECT 1 FROM E3 a, E3 b),       -- 256
E5(N) AS (SELECT 1 FROM E4 a, E4 b),       -- 65,536
E6(N) AS (SELECT 1 FROM E5 a, E5 b),       -- 262,144
E7(N) AS (SELECT 1 FROM E6 a, E6 b),       -- 262,144
Nums AS (
    SELECT TOP (1000000)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS ID
    FROM E6
)
INSERT INTO dbo.BatchModeDemo (ID, CategoryID, Price, Description)
SELECT 
    ID,
    ID % 20, -- 20 Kategorien
    1.00 + (ID % 100) * 0.5,
    'Produkt ' + CAST(ID AS NVARCHAR)
FROM Nums;

select count( *)  from BatchModeDemo


ALTER DATABASE Nwind SET COMPATIBILITY_LEVEL = 120;
select avg(price), categoryID from BatchModeDemo	
where price < 10000 and CategoryID < 5
group by CategoryID

ALTER DATABASE Nwind SET COMPATIBILITY_LEVEL = 160;
select avg(price), categoryID from BatchModeDemo	
where price < 10000 and CategoryID < 5
group by CategoryID
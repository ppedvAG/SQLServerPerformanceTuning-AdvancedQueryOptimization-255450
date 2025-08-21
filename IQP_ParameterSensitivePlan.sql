										 /*
Parameter Sensitivity Plan

 bezieht sich auf einen Prozess, wobei SQL Server 
 die aktuellen Parameter w�hrend der Kompilierung oder Neukompilierung 
 ermittelt und diese an den Abfrageoptimierer �bermittelt
 , sodass sie zum Generieren potenziell effizienter 
 Abfrageausf�hrungspl�ne verwendet werden k�nnen.

 Parameterwerte werden w�hrend der Kompilierung oder Neukompilierung 
    f�r die folgenden Batchtypen ermittelt:

- Gespeicherten Prozeduren
- Abfragen, die �ber sp_executesql �bermittelt werden
- Vorbereitete Abfragen



 Mit OPTION (RECOMPILE) kann der Optimierer einen optimalen 
 Abfrageplan generieren, der auf die spezifischen Werte 
 zugeschnitten ist und die besten zugrunde liegenden Indizes 
 zur Laufzeit nutzen kann. Bei Parametern bezieht sich dieser 
 Prozess nicht auf die Werte, die urspr�nglich an die 
 Batch- oder gespeicherte Prozedur �bergeben wurden
 , sondern auf ihre Werte zum Zeitpunkt der Neukompilierung. 
 Diese Werte wurden m�glicherweise innerhalb der Prozedur ge�ndert
 , bevor Sie die anweisung erreichen, die enth�lt RECOMPILE. 
 Dieses Verhalten kann die Leistung f�r Abfragen mit 
 stark variablen oder schiefen Eingabedaten verbessern.
 
 Lokale Variablen
Wenn eine Abfrage lokale Variablen verwendet, 
kann SQL Server ihre Werte zur Kompilierungszeit nicht ermitteln, 
sodass sie die Kardinalit�t
mithilfe verf�gbarer Statistiken oder Heuristiken sch�tzt. 

10% Selektivit�t f�r Gleichheitspr�dikate und 
30% f�r Ungleichheiten und Bereiche. Dies kann zu 
weniger genauen Ausf�hrungspl�nen f�hren. 
Hier ist ein Beispiel f�r eine Abfrage, die eine lokale Variable verwendet.

Optimierung des Parameterempfindlichkeitsplans (Parameter Sensitivity Plan, PSP) 

 Dieser wurde f�r Szenarios entwickelt, in denen ein 
 einzelner zwischengespeicherter Plan f�r eine parametrisierte 
 Abfrage nicht f�r alle m�glichen eingehenden Parameterwerte optimal ist. 
 Dies ist bei uneinheitlichen Datenverteilungen der Fall. 

 Die PSP-Optimierung aktiviert automatisch mehrere aktive 
 zwischengespeicherte Pl�ne f�r eine einzelne parametrisierte 
 Anweisung. Zwischengespeicherte Ausf�hrungspl�ne decken verschiedene
 Datengr��en basierend  auf den kundenseitig angegebenen 
 Laufzeitparameterwert(en) ab.

 Implementierung der PSP-Optimierung

 W�hrend der anf�nglichen Kompilierung werden �ber 
 Spaltenstatistikhistogramme uneinheitliche Verteilungen 
 identifiziert und bis zu drei der am st�rksten gef�hrdeten 
 parametrisierten Pr�dikate bewertet.

 Optionale PSP-Optimierung

 derzeit nur mit Gleichheitspr�dikaten.
 ?  Suche in eine Tabelle durchgef�hrt oder gescannt werden muss?

 WHERE column1 = @p OR @p IS NULL;

 --> immer SCAN

 Die Optionale Parameterplanoptimierung (OPPO) 
    verwendet die Adaptive Planoptimierungsinfrastruktur (Multiplan), 
    die mit der Optimierung des Parametersensitiven Plans eingef�hrt 
    wurde und mehrere Pl�ne aus einer einzigen Anweisung generiert. 
    Dadurch kann das Feature unterschiedliche Annahmen abh�ngig 
    von den parameterwerten vornehmen, die in der Abfrage verwendet 
    werden. W�hrend der Abfrageausf�hrung w�hlt OPPO den 
    entsprechenden Plan aus:

Wenn der Parameterwert IS NOT NULL erf�llt ist
    , wird ein Suchplan verwendet oder ein Plan
    , der optimaler ist als ein vollst�ndiger Scanplan.
wobei der Parameterwert lautet NULL, wird ein Scanplan verwendet.

Voraussetzung

Die Datenbank muss die Kompatibilit�tsebene 170 verwenden.
Die OPTIONAL_PARAMETER_OPTIMIZATION Konfiguration 
    mit Datenbankbereich muss aktiviert sein.

*/


USE [master];
GO

ALTER DATABASE [PSP]
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

DROP DATABASE [PSP];

GO
-- Create database PSP
CREATE DATABASE [PSP]
GO
USE PSP
-- Set recovery model to SIMPLE
ALTER DATABASE [PSP] SET RECOVERY SIMPLE;
GO

ALTER DATABASE CURRENT SET COMPATIBILITY_LEVEL = 140; /* 2017 */
GO
/* Turn on actual execution plans and: */
SET STATISTICS IO, TIME OFF;

GO
DROP TABLE IF EXISTS dbo.Tab_A;
GO
CREATE TABLE dbo.Tab_A
(
  Col1 INTEGER
  ,Col2 INTEGER
  ,Col3 BINARY(2000)
);
GO
-- Insert some data into the sample table
SET NOCOUNT ON;
BEGIN
  BEGIN TRANSACTION;
DECLARE @i INTEGER = 0;
WHILE (@i < 10000)
  BEGIN
    INSERT INTO dbo.Tab_A (Col1, Col2) VALUES (@i, @i);
    SET @i+=1;
  END;
COMMIT TRANSACTION;
END;
GO
-- There are much more rows with value 1 than rows with other values
declare @i as int=1
Begin TRAN
WHILE 1=1
begin
    INSERT INTO dbo.Tab_A (Col1, Col2) VALUES (1, 1)
    set @i+=1
    IF @i=500000 break
end
commit

SET NOCOUNT OFF;
GO
-- Create indexes
CREATE INDEX IDX_Tab_A_Col1 ON dbo.Tab_A
(  [Col1] );
GO
CREATE INDEX IDX_Tab_A_Col2 ON dbo.Tab_A
(  [Col2] );
GO


--Tab A: 500001 x 1

CREATE OR ALTER PROCEDURE dbo.Tab_A_Search
(   @ACol1 INTEGER    ,   @ACol2 INTEGER    )
AS BEGIN
  SELECT * FROM dbo.Tab_A WHERE (Col1 = @ACol1) AND (Col2 = @ACol2);
END


SELECT   sh.* FROM  sys.stats AS s
CROSS APPLY
                    sys.dm_db_stats_histogram(s.object_id, s.stats_id) AS sh
WHERE
   (name = 'IDX_Tab_A_Col1') AND (s.object_id = OBJECT_ID('dbo.Tab_A'));
GO


EXEC dbo.Tab_A_Search @ACol1 = 1, @ACol2 = 1;

EXEC dbo.Tab_A_Search @ACol1 = 33, @ACol2 = 33;
GO
EXEC dbo.Tab_A_Search @ACol1 = 33, @ACol2 = 25;
GO

SELECT
  usecounts  ,plan_handle  ,objtype  ,text
FROM
    sys.dm_exec_cached_plans 
CROSS APPLY
    sys.dm_exec_sql_text (plan_handle)
WHERE
  (text LIKE '%Tab_A%')
AND
  (objtype = 'Prepared');
GO

 --mit SQL 2019
 ALTER DATABASE CURRENT SET COMPATIBILITY_LEVEL = 150; /* 2017 */
 dbcc freeproccache
  ALTER DATABASE CURRENT SET COMPATIBILITY_LEVEL = 160; /* 2017 */
 dbcc freeproccache

 --SQL 2025
SET STATISTICS IO, TIME ON;

-- OPPO
DBCC FREEPROCCACHE
ALTER DATABASE CURRENT SET COMPATIBILITY_LEVEL = 170;
ALTER DATABASE SCOPED CONFIGURATION SET OPTIONAL_PARAMETER_OPTIMIZATION = ON;

create proc OPO @par int
as
select top 100  col1, col2 from Tab_A 
where       (Col2=@par or @par is null)
             AND
             (Col1=@par or @par is null)
order by col3;
GO

select col2, count(*) from Tab_A group by col2;
GO

update top ( 1000 ) tab_a set col2 = 2 where col1=1;
GO 


exec OPO 1
exec OPO 2
exec OPO 44




1. Was ist ein Linked Server?
Ein Linked Server ist eine Funktion in SQL Server
, um direkt auf externe Datenquellen 
(andere SQL Server oder auch Oracle, MySQL, Excel, CSV, OLE DB–Quellen usw.) 
zuzugreifen, als wären sie Teil der eigenen Instanz.

Die Verbindung wird über OLE DB Provider hergestellt.

Objekte werden über den Vier-Teil-Namen referenziert:

SELECT * 
FROM [RemoteServer].[RemoteDB].[Schema].[Table];

Du kannst sowohl SELECT als auch INSERT/UPDATE/DELETE 
über Linked Server ausführen.

Auch Stored Procedures auf dem Remote-Server lassen sich per EXEC ausführen.

2. Wie richtet man einen Linked Server ein?
Beispiel für einen anderen SQL Server:


EXEC sp_addlinkedserver   
    @server = N'RemoteServer',   
    @srvproduct=N'',  
    @provider=N'SQLNCLI',  
    @datasrc=N'RemoteSQLInstance';  

EXEC sp_addlinkedsrvlogin   
    @rmtsrvname = N'RemoteServer',   
    @useself = N'False',   
    @locallogin = NULL,   
    @rmtuser = N'RemoteUser',   
    @rmtpassword = N'StrongPassword';




3. Wie verarbeitet SQL Server Linked-Server-Abfragen?
SQL Server versucht, so viel wie möglich zur Remotequelle 
zu pushen (Remote Query Execution).

Falls der Optimizer es nicht kann, werden Daten lokal gezogen 
und gefiltert 
→ schlechte Performance, besonders bei großen Datenmengen.

Funktionen, Joins, oder WHERE-Bedingungen, 
die nicht auf der Remoteseite ausführbar sind,
verursachen massives Datenziehen.

Linked Server kann Distributed Transactions verwenden (MSDTC), 
wenn Schreiboperationen auf beiden Seiten stattfinden 
→ overhead!

4. Methoden im Umgang mit Linked Server – was ist gut, was schlecht?
Empfohlene Methoden (Performance-günstig):
-->OPENQUERY verwenden
Schreibt die Remote-Abfrage direkt im Dialekt des Zielservers.

Alles wird auf dem Remote-Server ausgeführt, 
nur das Resultset kommt zurück:


SELECT * 
FROM OPENQUERY(RemoteServer, 'SELECT CustomerID, Name 
                FROM RemoteDB.dbo.Customers WHERE Country = ''DE''');

Vorteil: 
Kein Pushdown-Problem, der Optimizer kann nichts „zerstören“.

Nachteil: 
Query ist als String → weniger flexibel / schwieriger dynamisch zu bauen.

Ergebnisse auf Remote-Seite vorfiltern und aggregieren

Besser: ein kleines Resultset ziehen als ganze Tabellen.

Remote-Stored Procedures oder Views anlegen 
und nur das Notwendige übertragen:
zB:
EXEC RemoteServer.RemoteDB.dbo.usp_GetFilteredData @Region = 'EU';

Nur lesende Szenarien bevorzugen
Schreiboperationen über Linked Server mit MSDTC vermeiden 
(Transaktions-Overhead sehr groß).

Lokale Staging-Tabellen verwenden

Daten in eine temporäre Tabelle oder Staging-DB importieren 
und lokal joinen, anstatt Cross-Server-Joins on-the-fly auszuführen.

Weniger empfehlenswerte Methoden (Performance-schädlich):
Vier-Teil-Namen mit komplexen Joins


SELECT a.Col, b.Col 
FROM LocalTable a
JOIN RemoteServer.RemoteDB.dbo.Table b ON a.Key = b.Key;
→ SQL Server zieht oft komplette Remote-Tabellen lokal 
und join’t dann → sehr langsam.

Funktionen oder nicht deterministische Ausdrücke im WHERE
→ verhindern Pushdown, alles wird gezogen.

Verteilte Updates / Deletes mit MSDTC
→ Transaktionskoordinierung + Logging macht es extrem teuer 
    und fehleranfällig.

5. Alternativen zu Linked Server
ETL / ELT Tools (SSIS, Azure Data Factory, o. ä.)

-Regelmäßige Datenübernahme statt Ad-hoc-Joins.
Gut für geplante Workflows mit großem Datenvolumen.
-Replikation oder Change Data Capture (CDC)

Daten aus der Fremddatenbank werden synchronisiert → kein Cross-Server Join notwendig.

PolyBase (ab SQL Server 2016+)
Kann externe Datenquellen (Hadoop, Oracle, Azure Blob, auch SQL) spaltenorientiert und optimiert ansprechen.
Bessere Performance und Pushdown als klassische Linked Server, besonders bei Big Data.

EXTERNAL TABLEs (SQL Server Big Data Clusters)
Für sehr große Datenmengen, mit Predicate Pushdown und Parallelisierung.
 API-basierte Integration
 Anwendungslogik statt Datenbankverbindung: Microservices, REST, OData – für Echtzeit-Datenabrufe, wenn Abfragemuster klar definiert sind.

6. Zusammenfassung
Linked Server = direktes Abfragen fremder Datenbanken.

Gut: OPENQUERY, Remote-Stored Procedures, Filterung/Aggregation auf der Quellseite.

Schlecht: komplexe Joins oder Funktionen im Vier-Teil-Namen, verteilte Transaktionen.

Alternativen: ETL (SSIS), Replikation, PolyBase, API-basierte Integration.

Faustregel: Linked Server ist für kleine, gezielte Datenmengen OK – nicht für Massendaten oder OLTP-Workloads.
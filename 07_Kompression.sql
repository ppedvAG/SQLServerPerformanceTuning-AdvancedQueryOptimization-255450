1) Rowstore-Datenkompression (ROW & PAGE)
ROW-Kompression
Was passiert intern?
Feste Datentypen (z. B. INT, CHAR(100)) werden intern variabel gespeichert.
Führende Nullen/Leerstellen werden weggelassen, 
NULL/0 werden sehr kompakt codiert.
Geringerer Zeilenheader.

Vorteile
Meist spürbar weniger Speicher/IO, ohne allzu großen CPU-Mehrbedarf.
Gut für OLTP-Tabellen mit vielen Lesezugriffen und moderaten Updates.
Minimiert Seitenanzahl → bessere Buffer-Pool-Nutzung, weniger Cache-Misses.

Nachteile
Zusätzlicher (De-)Komprimierungs-CPU-Aufwand pro Zugriff.
Komprimiert weniger stark als PAGE.

Wann einsetzen?
„Hot“ OLTP-Tabellen/Indizes, die häufig gelesen und regelmäßig aktualisiert werden.
Guter Standard-Startpunkt, wenn du Kompression erstmal breit einführen willst.

PAGE-Kompression
Was passiert intern? (baut auf ROW auf)
Prefix Compression: Gemeinsame Präfixe in einer Spalte 
auf einer Seite werden einmalig abgelegt.
Dictionary Compression: Wiederholte Werte/Teile werden 
in ein Seitendictionary ausgelagert und per Referenz gespeichert.

Vorteile
Höchste Einsparung bei Rowstore (oft deutlich > ROW).
Ideal für read-mostly / „kalte“ Daten, Historien, Archiv-Partitionen.

Nachteile
Höherer CPU-Aufwand als ROW – besonders bei DML (UPDATE/INSERT), 
da Seiten neu „verdichtet“ werden müssen.
Kann Page-Splits begünstigen, wenn Werte wachsen (z. B. durch Updates).
Bei sehr schreibintensiven Tabellen kann der Nettovorteil kippen.

Wann einsetzen?
Große, überwiegend lesende Workloads: Reporting-Tabellen,
„kalte“ Partitions (z. B. Vormonate), Dimensionstabellen mit wenig DML.

Häufig in Kombination: aktuelle Partitionen = ROW, 
                        historische Partitionen = PAGE.

2) Columnstore-Kompression (COLUMNSTORE & COLUMNSTORE_ARCHIVE)
Wie funktioniert’s?

Daten werden spaltenweise und in Rowgroups 
(typ. bis ca. 1 Mio. Zeilen) gespeichert.

Pro Spaltensegment nutzt SQL Server passende Algorithmen 
(z. B. Run-Length, Dictionary, Bit-Packing).

Segment-Meta (Min/Max, Bitmaps) ermöglicht „Segment Elimination“ 
→ weniger IO.

Verfügbar als Clustered Columnstore Index (CCI) oder 
Nonclustered Columnstore Index (NCCI).

Varianten
DATA_COMPRESSION = COLUMNSTORE (Standard): 
sehr gute Kompression + Batch Mode (sehr schnell für Analytik).

DATA_COMPRESSION = COLUMNSTORE_ARCHIVE: 
noch stärkere Kompression, dafür merklich mehr CPU beim Scannen/Komprimieren → für kalte Daten.

Vorteile
Sehr hohe Kompression (oft Faktor 5–15), massiv weniger IO.
Extrem schnelle analytische Scans & Aggregationen im Batch Mode.
Gut für sehr breite Tabellen und spalten mit vielen Wiederholungen.

Nachteile
Punktabfragen/Singleton Lookups nicht so effizient wie Rowstore.
DML: Heutige Versionen sind deutlich besser, 
aber viele kleine Updates/Inserts bleiben teurer (Delta Store, Tuple Mover).

Nicht jede Abfrage profitiert (z. B. OLTP-Muster mit vielen Key-Lookups).

Wann einsetzen?
Data-Warehouse/Facts, Reporting-Workloads, große Historien.

ARCHIVE für selten gelesene Alt-Partitionen.
Für OLTP: ggf. NCCI auf große Faktentabellen für Hybrid-Szenarien 
(gemischte Workloads).

3) Backup-Kompression
Wie funktioniert’s?

Komprimiert den Backup-Datenstrom (Full/Diff/Log).
Kein Einfluss auf die physische Tabellen-/Indexspeicherung.

Vorteile
Kleinere Backups, schnellere Sicherung/Wiederherstellung (weniger Bytes lesen/schreiben).
Spart Storage & Netzwerkbandbreite (Offsite/DR).

Nachteile
Erhöhte CPU-Last während Backup/Restore.
Kompressionsgrad stark abhängig von den Daten (bereits „randomisierte“/binäre Daten komprimieren schlechter).

Wann einsetzen?
Fast immer sinnvoll, sofern CPU-Budget während Backup/Restore vorhanden ist.

Auf produktiven Systemen oft außerhalb der Spitzenzeiten.

4) Manuelle Datenkompression auf Spaltenebene (COMPRESS/DECOMPRESS)
Was ist das?

T-SQL-Funktionen COMPRESS(varbinary | nvarchar | varchar | …) → varbinary(max) und DECOMPRESS(varbinary(max)).

Du speicherst selbst komprimierte Payloads 
(z. B. große JSONs, Textblöcke, BLOB-ähnliche Inhalte).

Vorteile
Sehr hohe Einsparung bei stark redundanten oder textlastigen Spalten.

Keine Änderung des Index-Typs nötig.

Nachteile
Inhalte sind nicht such-/filterbar ohne Dekomprimierung 
→ keine Index-Nutzung darauf.
CPU-Kosten bei jeder (De-)Kompression.
Anwendung/Abfragen müssen damit umgehen.

Wann einsetzen?
Große Text-/JSON-Spalten, die selten gefiltert werden (
nur „holen und anzeigen“).

Archivdaten im Rowstore, wenn Columnstore nicht passt.

5) Auswahl & Vorgehen in der Praxis
A) Kandidaten finden
Schreib-/Leseprofil je Objekt:


SELECT TOP 50 DB_NAME() AS db, OBJECT_NAME(i.object_id) AS obj, i.name AS idx,
       s.user_seeks + s.user_scans + s.user_lookups AS reads,
       s.user_updates AS writes
FROM sys.indexes i
LEFT JOIN sys.dm_db_index_usage_stats s
       ON s.object_id = i.object_id AND s.index_id = i.index_id
       AND s.database_id = DB_ID()
WHERE i.object_id > 100
ORDER BY (s.user_seeks + s.user_scans + s.user_lookups) DESC;

--Große Objekte/Partitionen identifizieren (Seiten/MB):
SELECT OBJECT_SCHEMA_NAME(p.object_id) AS sch, OBJECT_NAME(p.object_id) AS obj,
       i.name AS idx, p.index_id, p.partition_number,
       au.total_pages/128.0 AS size_mb
FROM sys.partitions p
JOIN sys.allocation_units au ON au.container_id = p.hobt_id
JOIN sys.indexes i ON i.object_id = p.object_id AND i.index_id = p.index_id
ORDER BY size_mb DESC;

B) Einsparung schätzen (ohne Risiko)

EXEC sp_estimate_data_compression_savings
     @schema_name = N'dbo',
     @object_name = N'Orders',
     @index_id    = NULL,           -- NULL = alle
     @partition_number = NULL,
     @data_compression = 'ROW';     -- auch 'PAGE', 'COLUMNSTORE', 'COLUMNSTORE_ARCHIVE'

Vergleiche Ist-Größe vs. geschätzte Größe 
→ schnell sehen, ob ROW/PAGE lohnt.

C) Regeln für die Entscheidung
OLTP & „hot“ 
Daten: zuerst ROW, nicht PAGE.

Read-mostly, Historien, Alt-Partitionen: 
PAGE oder COLUMNSTORE_ARCHIVE.

Reporting / DW / breite Tabellen: 
(Clustered) COLUMNSTORE.

Große Text-/JSON-Spalten ohne Filteranforderungen: 
COMPRESS() speichern.

Backups: Backup-Kompression standardmäßig aktivieren, 
wenn CPU-Fenster vorhanden.

D) Umsetzung (objekt- oder partitionsweise)
Rowstore (ganzer Index/Heap):


ALTER INDEX [IX_MyIdx] ON dbo.MyTable
  REBUILD WITH (DATA_COMPRESSION = ROW);  -- oder PAGE

Partitionsweise:
ALTER INDEX [IX_FactDate] ON dbo.Fact
  REBUILD PARTITION = 1 WITH (DATA_COMPRESSION = ROW);

ALTER INDEX [IX_FactDate] ON dbo.Fact
  REBUILD PARTITION = 2 WITH (DATA_COMPRESSION = PAGE);


Columnstore:
-- CCI erstellen
CREATE CLUSTERED COLUMNSTORE INDEX CCI_Fact ON dbo.Fact
  WITH (DATA_COMPRESSION = COLUMNSTORE);

-- Kalte Partition archivieren
ALTER INDEX CCI_Fact ON dbo.Fact
  REBUILD PARTITION = 10 WITH (DATA_COMPRESSION = COLUMNSTORE_ARCHIVE);

E) Kontrolle & Monitoring
Status abfragen:

SELECT OBJECT_SCHEMA_NAME(p.object_id) AS sch, OBJECT_NAME(p.object_id) AS obj,
       i.name AS idx, p.partition_number, p.data_compression_desc
FROM sys.partitions p
JOIN sys.indexes i ON i.object_id = p.object_id AND i.index_id = p.index_id
ORDER BY obj, idx, partition_number;

Wirkung messen:

SET STATISTICS IO, TIME ON; → IO/CPU vor/nachher vergleichen.

Ausführungspläne prüfen (Operatoren, Batch Mode bei Columnstore).
CPU- und Wartezeiten beobachten 
    (z. B. SOS_SCHEDULER_YIELD, PAGEIOLATCH_*, RESOURCE_SEMAPHORE).

6) Typische Stolpersteine & Tipps
CPU vs. IO-Trade-off: Kompression spart IO/Cache, kostet CPU. 
Bei CPU-Engpässen konservativer vorgehen (ROW > PAGE).

DML-lastige Tabellen: 
PAGE kann Inserts/Updates verlangsamen (Rekomprimierung, Page-Splits). 
→ ROW bevorzugen; PAGE nur auf kalten Partitionen.

LOB-Spalten ((n)varchar(max), varbinary(max)): 
werden durch ROW/PAGE kaum erfasst (Off-Row). 
Eher Columnstore (wenn sinnvoll) oder COMPRESS().

Fillfactor & Fragmentierung: 
Mit PAGE kann ein zu hoher Fillfactor Page-Splits verstärken. 
Für write-heavy Indizes Fillfactor senken.

Wartung:
REBUILD erhält/ändert Kompression gemäß DATA_COMPRESSION.
REORGANIZE erhält die aktuelle Kompression.

Columnstore: 
REORGANIZE kann Rowgroups zusammenführen, 
REBUILD encodiert alles neu (besser, aber teurer).

Mischbetrieb: 
Häufig sinnvoll: Primärschlüssel/Clustered = ROW, 
große Nicht-clustered Indizes = PAGE, 
Fact-Tabellen = CCI, kalte Partitionen = Archive.

7) Quick-Guides (Daumenregeln)
Wenn du unsicher bist: 
Starte mit ROW auf den größten/leseintensivsten Indizes.

DW / Reporting: 
CCI als Default; 
„Nearline“ = CCI, 
„Deep Archive“ = CCI-ARCHIVE.

Historische OLTP-Partitionen: PAGE.

Große Textfelder ohne Filterbedarf: 
COMPRESS() verwenden.

Backups: Komprimieren – außer die CPU ist zur Backupzeit knapp.



-- Tabelle mit großer Textspalte
CREATE TABLE dbo.Logs
(
    LogID int IDENTITY PRIMARY KEY,
    LogDataCompressed varbinary(max)
);

-- Text komprimiert ablegen
INSERT INTO dbo.Logs(LogDataCompressed)
VALUES (COMPRESS(N'Really long text or JSON ...'));

-- Dekomprimieren beim Lesen
SELECT LogID,
       CAST(DECOMPRESS(LogDataCompressed) AS nvarchar(max)) AS LogText
FROM dbo.Logs;

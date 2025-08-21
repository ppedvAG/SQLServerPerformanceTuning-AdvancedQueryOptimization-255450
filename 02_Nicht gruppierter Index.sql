/*

Nicht gr IX

Ein nicht gruppierter Index (non-clustered index) in SQL Server ist eine separate Datenstruktur
, die Zeiger (Row Locator) auf die tatsächlichen Datenzeilen in der Tabelle enthält.
Er funktioniert ähnlich wie ein Inhaltsverzeichnis in einem TelefonBuch: 
Er enthält die Werte einer oder mehrerer Spalten und verweist auf die Speicherorte der vollständigen Datenzeilen.

Funktionsweise:
Der nicht gruppierte Index speichert die Indexspalten in sortierter Reihenfolge.

Jede Indexzeile enthält einen Verweis (Row ID bei Heaps oder Clustered Key bei Tabellen mit Clustered Index)
auf die eigentliche Datenzeile.	   (1:409:03)

Mehrere nicht gruppierte Indizes sind auf einer Tabelle erlaubt. bis etwa 1000

Geeignet für:
Schneller Zugriff auf bestimmte Spalten oder Werte (z. B. bei WHERE = , JOIN, ORDER BY, GROUP BY).

Selektive Abfragen, die nur einen kleinen Teil der Daten zurückgeben.	
(Vor allem bei Lookups! )

Abfragen mit häufig verwendeten Suchkriterien auf Spalten ohne Clustered Index.

Abfragen mit Index-Only-Zugriff (wenn alle benötigten Spalten im Index enthalten sind → „Covering Index“).

Nicht geeignet für:
Tabellen mit vielen Schreibvorgängen (INSERT, UPDATE, DELETE)
, da der Index ständig aktualisiert werden muss.

Spalten mit niedriger Selektivität (z. B. Geschlecht, Ja/Nein)
, da der Index wenig Vorteil bringt.

Wenn bereits viele Indizes vorhanden sind – zusätzliche Indizes erhöhen den Wartungsaufwand und Speicherverbrauch.


Ein nicht gruppierter Index verbessert gezielt die Abfrageleistung auf bestimmten Spalten
, ist aber bei vielen Änderungen oder geringer Selektivität nicht effizient.

--Kopie von Daten in sortierter Form
--pro Tabelle: ca 1000

--muss evtl Lookup machen, wenn Spalten nicht iX enthalten sind

--Lookup sind teuer... je mehr desto schlechter

*/

set statistics io, time on

--Im Plan: Scan oder seek.. reiner Heap ohne IX--> Table scan
select id from kundeumsatz where id = 117
--Seiten ca 41000 Dauer 50ms  CPU 170ms

--Schlüsselspalte = where Spalte
--nun NIX_ID eindeutig
select id from kundeumsatz where id = 117

--nun im Plan: SEEK
--Seiten 3 0 ms

--Plan: IX Seek mit Lookup
select id, freight from kundeumsatz where id = 117
--Seiten 4 0ms

select id, freight from kundeumsatz where id < 117
--seiten 119.. Lookup wird schon 99% der Kosten haben

--Bei ca 10650 geht der SQL von IX Seek wg Lookup auf Table Scan
select id, freight from kundeumsatz where id < 10650

--nun NIX_ID_FR_u
select id, freight from kundeumsatz where id < 920000

--Hauptsache KEIN LOOKUP

--bäh.. wieder Lookup
select id, freight, country, city from kundeumsatz where id < 10650

--IX mit eingeschl Spalten
--daher:_ NIX_ID_inkl_CICYFR_u
--reiner Seek
select id, freight, country, city from kundeumsatz where id < 10650

--Where Spalten kommt zu den 
--Indexschlüsselspalten, Spalten des Select zu den eingeschlossenen

select		country, city, sum(unitprice*quantity)
from		kundeumsatz
where		employeeid = 3 and freight < 2
group by	country, city

--NIX_FR_EM_inkl_CICYUPQU

--bei OR Bedingungen schlägt SQL nichts mehr vor
--evtl 2 Ind


select		country, city, sum(unitprice*quantity)
from		kundeumsatz
where		employeeid = 3 or freight < 2 and Shipcountry = 'UK'
group by	country, city
-- ! Klammern!!!!! and ist immer stärker bindend
--erst klammern dann IX


--nur IX die man wirklich braucht.. alle anderen kosten Leistung bei INS UP DEL

--wie finde ich Indizes, die keiner verwendet

select * from sys.dm_db_index_usage_stats








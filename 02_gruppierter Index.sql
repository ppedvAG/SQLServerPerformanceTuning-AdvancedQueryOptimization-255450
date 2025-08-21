/* CLUSTERED INDEX

Ein gruppierter Index (clustered index) in SQL Server 
bestimmt die physikalische Sortierung der Daten in einer Tabelle. 
Es gibt nur einen gruppierten Index pro Tabelle
, da die Datenzeilen selbst in der Reihenfolge des Index gespeichert werden.

Funktionsweise:
Die Datenzeilen der Tabelle sind selbst der Index.
Die Zeilen werden physisch nach dem Wert der Indexspalte(n) sortiert gespeichert.
Der gruppierte Index enth�lt daher direkt die Daten, kein zus�tzlicher Zeiger ist n�tig.


Geeignet f�r:
Abfragen mit Bereichssuchen (BETWEEN, <, >, etc.), da die Daten physisch sortiert sind.

Spalten mit hoher Selektivit�t, die h�ufig in WHERE, JOIN, ORDER BY oder GROUP BY verwendet werden.

Tabellen mit h�ufigem Lesen gro�er Datenmengen oder Sortieroperationen.

Tabellen mit eindeutigem Prim�rschl�ssel � dieser wird oft als gruppierter Index implementiert.
Aber auch h�ufig als PK falsch. Denn daruch k�nnen HotSpots am Ende der Tabelle entstehen
, was zu Latches f�hren w�rde.

Nicht geeignet f�r:
Tabellen mit h�ufigen Einf�geoperationen in der Mitte der Sortierreihenfolge
, da das Umordnen von Seiten (Page Splits) erforderlich ist.

Tabellen mit h�ufigen �nderungen an den Werten der Indexspalte
, da dies zu physikalischer Umsortierung f�hrt.

Sehr breite Tabellen mit vielen Spalten
, wenn viele Indizes erstellt werden sollen � der Clustered Key ist Teil jedes nicht gruppierten Index.

Kurz gesagt:
Ein gruppierter Index sortiert und speichert die Datenzeilen direkt. 
Er eignet sich hervorragend f�r schnelle Bereichsabfragen und sortierte Ergebnisse, ist aber bei vielen �nderungen in den Indexspalten oder bei schreibintensiven Workloads weniger vorteilhaft

--Gruppierter Index = Tabelle in immer sortierter Form
--HEAP exitiert nicht mehr... kein Lookup bei Verwendung des CL IX

--Grupp Index sollte immer �berlegt sein
--also immer zuerst Gr IX setzen.. alles andere kann nur NIcht gruppiert werden

--PK wird gerne als Gr Ix implementiert.. nmuss aber nicht sein
-- kann Verschwendung bedeuten, aber auch zu h�ufigen Page Splits f�rehn


*/


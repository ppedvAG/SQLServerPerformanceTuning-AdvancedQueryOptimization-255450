Ein Deadlock in SQL Server ist eine Situation, 
in der zwei (oder mehr) Sessions sich gegenseitig blockieren, 
weil jede eine Sperre hält, die die andere braucht. 
SQL Server erkennt Deadlocks automatisch und beendet 
einen der Prozesse (der sog. Deadlock-Opfer), um die Blockade aufzulösen.

Wie entstehen Deadlocks?

A. Durch Benutzer-Logik
Unterschiedliche Sperrreihenfolge:
Session A sperrt zuerst Tabelle X und will dann Tabelle Y.
Session B sperrt zuerst Tabelle Y und will dann Tabelle X. 
→ klassischer Deadlock.

Transaktionen zu lange offen:
Benutzer sperrt viele Zeilen/Tabellen und wartet 
(z. B. auf Input aus der Anwendung).

Explizite Sperranweisungen:
SELECT ... WITH (XLOCK) oder manuelle BEGIN TRAN ohne klaren Commit.

B. Durch Indizes (oder fehlende Indizes)
Fehlende Indizes:
SQL Server muss einen Table Scan machen und sperrt 
unnötig viele Zeilen oder ganze Seiten 
→ mehr Sperren, mehr Konfliktpotenzial.

Falsche Indizes:
Wenn der Ausführungsplan mehrere Indizes gleichzeitig 
nutzen muss (z. B. Key Lookup + Update), 
kann er Sperren in unterschiedlicher Reihenfolge anfordern.

Nicht-deterministische Zugriffsreihenfolge:
Wenn ein Index nicht eindeutig ist oder die Query-Optimierung 
den Join-Zugriff wechselt, können Sessions 
unterschiedliche Sperrpfade wählen.



Wie Deadlocks erkennen und analysieren?
SQL Server beendet einen Prozess und meldet einen Fehler:

Transaction (Process ID X) was deadlocked 
on resources with another process and 
has been chosen as the deadlock victim.

Schritt 1 – Deadlock-Information aktivieren
SQL Server Profiler / Extended Events:

-Event "deadlock graph" aufzeichnen.
 Zeigt grafisch, welche Sessions, Objekte und Sperren beteiligt sind.

SQL Trace (veraltet) / System Health Session (Standard in SQL Server):
Extended Events Session „system_health“ 
läuft standardmäßig und zeichnet Deadlocks schon auf.

Mit folgendem Query abrufen:

SELECT XEvent.query('(event/data/value/deadlock)') AS DeadlockGraph
FROM sys.fn_xe_file_target_read_file('system_health*.xel', NULL, NULL, NULL)
CROSS APPLY (SELECT CAST(event_data AS XML) AS XEvent) AS XEventData
WHERE XEvent.value('(event/@name)[1]', 'varchar(50)') = 'xml_deadlock_report';


etwas älter:
DBCC TRACEON(1222, -1); -- Deadlock-Details im SQL Error Log

Schritt 2 – Deadlock-Graph analysieren

Im Deadlock-Graph siehst du:
 SPID (Session IDs) → welche Verbindungen beteiligt sind
 Objekte/Indizes → auf welchen Tabellen/Indizes gesperrt wird
 Lock Types → z. B. Key Lock, Page Lock, RID Lock
 Resource-Order → wer wartet auf was
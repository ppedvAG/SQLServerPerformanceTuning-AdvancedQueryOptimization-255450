 1) Struktur der Deadlock-XML verstehen
    Eine typische Deadlock-XML hat drei Hauptteile:

<victim-list>
– enthält die Process-ID (nicht SPID!), 
    die SQL Server als Opfer beendet hat.

<process-list>
– eine Liste aller beteiligten Sitzungen/Prozesse 
    mit Details: spid, loginname, hostname, isolationlevel, 
    waitresource, waittime, transactionname, lasttranstarted, 
    <executionStack> (Prozedur/Zeile), <inputbuf> (Batch/Statement).

<resource-list>
– zeigt die gesperrten Ressourcen 
    (z. B. keylock, pagelock, objectlock, ridlock, exchangeEvent), 
    jeweils mit <owner-list> (wer hält welche Sperre) und <waiter-list> 
    (wer wartet auf welche Sperre). Dort siehst du Lock-Modus
    (z. B. S, X, U, IX, SIX) und die betroffenen Objekte 
    (Tabelle/Index, HOBT-ID).

2) Schritt-für-Schritt interpretieren
Schritt A – Opfer identifizieren
    Öffne <victim-list> → notiere die id (z. B. process12b8c0).

Suche dieselbe id unter <process-list> 
→ dort findest du SPID, App, Login, Isolationlevel etc.

Schritt B – Wer blockiert wen?
In <resource-list>:
 Unter <owner-list> siehst du, wer (process-id) welche Sperre hält (z. B. mode="X").
 Unter <waiter-list> siehst du, wer worauf wartet und welchen Modus er anfordert 
    (z. B. requestType="wait" mode="X").
 Die Zyklen ergeben sich aus „A hält etwas, das B will“ und „B hält etwas, das A will“.

Schritt C – Welche Statements waren es genau?
Im <process-list>:
  <executionStack> 
    → enthält Frames mit procname, line, ggf. den genauen T-SQL-Ausschnitt.
  <inputbuf> 
    → zeigt das übermittelte Statement/Batch (hilfreich bei Ad-hoc SQL).

So findest du die konkrete Zeile in einer Prozedur 
oder das exakte Statement bei Ad-hoc-Queries.

Schritt D – Welche Objekte/Indizes?
In <resource-list> stehen je nach Lock-Typ:
          objectlock → oft objectname="dbo.Orders".
          keylock / pagelock / ridlock 
          → häufig nur HOBT-IDs (hobtid="720575940...").

Auflösen der HOBT-ID in Tabelle/Index:

DECLARE @hobt_id BIGINT = 72057594046054400; -- aus der XML

SELECT
    s.name  AS schema_name,
    o.name  AS table_name,
    i.name  AS index_name,
    p.index_id,
    p.hobt_id
FROM sys.partitions AS p
JOIN sys.objects   AS o ON o.object_id = p.object_id
JOIN sys.schemas   AS s ON s.schema_id = o.schema_id
LEFT JOIN sys.indexes AS i ON i.object_id = p.object_id AND i.index_id = p.index_id
WHERE p.hobt_id = @hobt_id;

--hobt_id heap or Tree ID
SELECT object_id, index_id, partition_id, hobt_id 
FROM sys.partitions
WHERE object_id = OBJECT_ID('dbo.customers');                                                                                                                                                                                                                                    


→ Jetzt weißt du welche Tabelle/Index den Konflikt verursacht hat.

Schritt E – Lock-Modi deuten (Konflikt erkennen)
    Vergleiche Owner-Modus und Waiter-Modus:

    Häufige Muster:
      U ↔ X (zwei Updates mit Konvertierung zu X)
      S/IS/IX/SIX ↔ X (Leser vs. Schreiber)

    Prüfe, ob zwei Session dieselben Objekte in 
    unterschiedlicher Reihenfolge anfassen (klassischer Deadlock).

Schritt F – Zeitlicher Kontext
    In <process>: lasttranstarted (Zeitpunkt der letzten Transaktion)
    und waittime (ms) helfen zu sehen, wer „länger“ unterwegs war 
    und ob lange Transaktionen Deadlocks begünstigen.

3) Mini-Beispiel (auszugsweise) – was du woran erkennst

    <deadlock>
      <victim-list>
        <victimProcess id="process2f1c8" />
      </victim-list>

      <process-list>
        <process id="process2f1c8" spid="57" isolationlevel="read committed"
                 waitresource="KEY: 7:72057594040287232 (ce3a0d8a1b9b)" waittime="3567">
          <executionStack>
            <frame procname="dbo.UpdateOrder" line="42" />
          </executionStack>
          <inputbuf>exec dbo.UpdateOrder @OrderID=11000, @Qty=2</inputbuf>
        </process>

        <process id="process3a7e0" spid="62" isolationlevel="read committed"
                 waitresource="PAGE: 7:1:12345" waittime="3412">
          <executionStack>
            <frame procname="adhoc" />
          </executionStack>
          <inputbuf>UPDATE dbo.Orders SET Freight = Freight + 1 WHERE OrderID=11000</inputbuf>
        </process>
      </process-list>
      <resource-list>
        <keylock hobtid="72057594040287232" objectname="dbo.Orders" indexname="IX_Orders_Cust" mode="X">
          <owner-list>
            <owner id="process3a7e0" mode="X"/>
          </owner-list>
          <waiter-list>
            <waiter id="process2f1c8" mode="X" requestType="wait"/>
          </waiter-list>
        </keylock>
        <pagelock dbid="7" fileid="1" pageid="12345" mode="IX">
          <owner-list>
            <owner id="process2f1c8" mode="IX"/>
          </owner-list>
          <waiter-list>
            <waiter id="process3a7e0" mode="X" requestType="wait"/>
          </waiter-list>
        </pagelock>
      </resource-list>
</deadlock>

So liest du das:

Opfer: process2f1c8 (SPID 57).

Ressource 1 (keylock): SPID 62 hält X, SPID 57 will X.

Ressource 2 (pagelock): SPID 57 hält IX, SPID 62 will X.
→ Zyklus: 57 ↔ 62 (klassischer Deadlock).

4) Spickzettel: Lock-Ressourcen & Modi
Ressourcen

OBJECT → ganze Tabelle
PAGE → Datenseite
RID → Heap-Zeile
KEY → Zeile in B-Tree (Index)
HOBT → „Heap Or B-Tree“ (interne ID für Index/Heap)

METADATA, EXCHANGE → seltener, z. B. Parallelismus

Modi (vereinfacht)
    S (Shared) – Lesen
    U (Update) – Lesend, will evtl. zu X konvertieren
    X (Exclusive) – Schreiben
    IS/IX/SIX – Intent Locks (zeigen Absicht auf tieferer Ebene an)
    Sch-S/Sch-M – Schema-Locks (Kompatibilität eingeschränkt)

Typische Konflikte
    S vs X, U vs U (Konvertierungsdeadlocks), IX/SIX vs X

5) Häufige Ursachen ableiten (aus der XML)
Unterschiedliche Zugriffsreihenfolge:
    Aus der <executionStack>/<inputbuf>**+**Objekten siehst du, 
    dass zwei Prozeduren Tabelle A dann B vs. B dann A sperren.

Fehlende/ungeeignete Indizes:
    pagelock/ridlock + Scans deuten auf breite Sperren hin 
    → Index nachrüsten kann Deadlocks reduzieren.

Update-Konvertierungen (U→X):
    Zwei UPDATE auf denselben Satz → U-Locks greifen untereinander.

Lange Transaktionen:
    Hohe waittime, großer lasttranstarted→ Sperren halten lange.

6) Nützliche T-SQL-Snippets für die Analyse

    A) system_health nach Deadlocks durchsuchen


SELECT CAST(XEvent.query('.') AS XML) AS DeadlockReport
FROM sys.fn_xe_file_target_read_file('system_health*.xel', NULL, NULL, NULL)
CROSS APPLY (SELECT CAST(event_data AS XML) AS XEvent) AS X
WHERE XEvent.value('(event/@name)[1]', 'varchar(50)') = 'xml_deadlock_report';

B) HOBT-ID → Tabelle/Index (siehe Schritt D)


-- @hobt_id aus der XML
SELECT s.name AS schema_name, o.name AS table_name, i.name AS index_name, p.hobt_id
FROM sys.partitions p
JOIN sys.objects o ON o.object_id = p.object_id
JOIN sys.schemas s ON s.schema_id = o.schema_id
LEFT JOIN sys.indexes i ON i.object_id = p.object_id AND i.index_id = p.index_id
WHERE p.hobt_id = @hobt_id;

C) SPID-Kontext zur Laufzeit prüfen (wenn der Deadlock live wäre)


-- sp_WhoIsActive (Community Tool) liefert sehr gute Live-Diagnose zu Locks/Abfragen
EXEC sp_WhoIsActive @get_locks = 1, @get_plans = 1;

7) Von der Interpretation zur Abhilfe (Kurzleitfaden)
    -Einheitliche Sperrreihenfolge in allen Prozeduren.
    -Passende Indizes (Zugriff gezielt statt Scans → weniger breite Sperren).
    -Transaktionen kurz halten (nur nötige Statements umschließen).
    -READ COMMITTED SNAPSHOT/SNAPSHOT erwägen (reduziert Leserschreiber-Deadlocks).
    -Gezielte Lock-Hints nur, wenn du wirklich weißt, warum (z. B. UPDLOCK, HOLDLOCK zur Reihenfolge-Stabilisierung).
1. Aktivitätsmonitor
Wann einsetzen:
Schnelle Ad-hoc-Diagnose, wenn z. B. eine Anwendung „hängt“ oder plötzliche Performanceprobleme auftreten.
Um Live-Übersicht zu Sessions, Sperren, Ausführungsplänen und Ressourcennutzung zu bekommen.

Vorteile:
Sofort verfügbar, visuell, einfach zu bedienen.
Gut für Einsteiger oder schnelle Checks.

Nachteile:
Erhöht leicht den Overhead auf dem Server.
Kein Logging über längere Zeit.
Eingeschränkte Detailtiefe.

2. Dynamische Verwaltungssichten (DMVs)
Wann einsetzen:
Für detaillierte Analysen direkt in T-SQL.
Bei Performance Tuning (z. B. Abfrage-Statistiken, Index-Nutzung, Wait-Statistiken).
Für eigene Monitoring-Skripte oder Berichte.
Vorteile:
Sehr granular, flexibel kombinierbar.
Kein oder kaum spürbarer Overhead.
Nachteile:
Erfordert SQL-Know-how.
Viele Werte sind Momentaufnahmen oder werden beim Server-Neustart zurückgesetzt.

3. Ablaufverfolgung & SQL Server Profiler
(Legacy – heute eher XEvents bevorzugen)
Wann einsetzen:
Wenn ältere Skripte oder Prozesse zwingend Profiler nutzen.
Für zielgerichtete Nachverfolgung einzelner Abfragen oder Events in Testumgebungen.
Vorteile:
Einfach einzurichten, sofortige Live-Anzeige.
Nachteile:
Hoher Overhead in produktiven Systemen.
Microsoft stuft es als veraltet ein – für neue Szenarien besser XEvents nutzen.

4. Windows Systemmonitor (Perfmon)
Wann einsetzen:
Wenn SQL Server- und OS-Metriken gemeinsam betrachtet werden müssen (CPU, RAM, Disk-I/O, Netzwerk).
Für Langzeitaufzeichnungen und historische Performance-Analysen.
Vorteile:
Betriebssystem- und SQL-Leistungsindikatoren in einem Tool.
Sehr geringe Systemlast, ideal für Dauerlogging.
Nachteile:
Weniger tiefe SQL-spezifische Details.
Auswertung kann sperrig sein (CSV-Export/Analyse nötig).

5. Statistische Systemfunktionen
Wann einsetzen:
Für schnelle Einzelwerte oder Ad-hoc-Abfragen innerhalb von Skripten.
Wenn DMVs zu „schwer“ erscheinen und nur ein konkreter Wert gebraucht wird (z. B. @@CPU_BUSY, @@IO_BUSY, @@PACK_RECEIVED).
Vorteile:
Extrem schnell, keine Zusatzlast.
Leicht in Skripte integrierbar.
Nachteile:
Sehr begrenzte Aussagekraft.
Keine Historie oder Korrelation mit anderen Daten.

6. Extended Events (XEvents)
Wann einsetzen:
Für moderne, flexible und performante Event-Nachverfolgung.
Um lang laufende Abfragen, Deadlocks, Wait-Events oder bestimmte Fehler präzise zu loggen.
Wenn Profiler-Funktionalität benötigt wird – aber effizienter.
Vorteile:
Geringer Overhead, auch produktiv nutzbar.
Sehr granular konfigurierbar.
Speicherung im Ring-Buffer oder Datei möglich.
Nachteile:
Einarbeitung nötig (GUI in SSMS oder T-SQL-Definitionen).
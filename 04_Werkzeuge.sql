1. Aktivit�tsmonitor
Wann einsetzen:
Schnelle Ad-hoc-Diagnose, wenn z. B. eine Anwendung �h�ngt� oder pl�tzliche Performanceprobleme auftreten.
Um Live-�bersicht zu Sessions, Sperren, Ausf�hrungspl�nen und Ressourcennutzung zu bekommen.

Vorteile:
Sofort verf�gbar, visuell, einfach zu bedienen.
Gut f�r Einsteiger oder schnelle Checks.

Nachteile:
Erh�ht leicht den Overhead auf dem Server.
Kein Logging �ber l�ngere Zeit.
Eingeschr�nkte Detailtiefe.

2. Dynamische Verwaltungssichten (DMVs)
Wann einsetzen:
F�r detaillierte Analysen direkt in T-SQL.
Bei Performance Tuning (z. B. Abfrage-Statistiken, Index-Nutzung, Wait-Statistiken).
F�r eigene Monitoring-Skripte oder Berichte.
Vorteile:
Sehr granular, flexibel kombinierbar.
Kein oder kaum sp�rbarer Overhead.
Nachteile:
Erfordert SQL-Know-how.
Viele Werte sind Momentaufnahmen oder werden beim Server-Neustart zur�ckgesetzt.

3. Ablaufverfolgung & SQL Server Profiler
(Legacy � heute eher XEvents bevorzugen)
Wann einsetzen:
Wenn �ltere Skripte oder Prozesse zwingend Profiler nutzen.
F�r zielgerichtete Nachverfolgung einzelner Abfragen oder Events in Testumgebungen.
Vorteile:
Einfach einzurichten, sofortige Live-Anzeige.
Nachteile:
Hoher Overhead in produktiven Systemen.
Microsoft stuft es als veraltet ein � f�r neue Szenarien besser XEvents nutzen.

4. Windows Systemmonitor (Perfmon)
Wann einsetzen:
Wenn SQL Server- und OS-Metriken gemeinsam betrachtet werden m�ssen (CPU, RAM, Disk-I/O, Netzwerk).
F�r Langzeitaufzeichnungen und historische Performance-Analysen.
Vorteile:
Betriebssystem- und SQL-Leistungsindikatoren in einem Tool.
Sehr geringe Systemlast, ideal f�r Dauerlogging.
Nachteile:
Weniger tiefe SQL-spezifische Details.
Auswertung kann sperrig sein (CSV-Export/Analyse n�tig).

5. Statistische Systemfunktionen
Wann einsetzen:
F�r schnelle Einzelwerte oder Ad-hoc-Abfragen innerhalb von Skripten.
Wenn DMVs zu �schwer� erscheinen und nur ein konkreter Wert gebraucht wird (z. B. @@CPU_BUSY, @@IO_BUSY, @@PACK_RECEIVED).
Vorteile:
Extrem schnell, keine Zusatzlast.
Leicht in Skripte integrierbar.
Nachteile:
Sehr begrenzte Aussagekraft.
Keine Historie oder Korrelation mit anderen Daten.

6. Extended Events (XEvents)
Wann einsetzen:
F�r moderne, flexible und performante Event-Nachverfolgung.
Um lang laufende Abfragen, Deadlocks, Wait-Events oder bestimmte Fehler pr�zise zu loggen.
Wenn Profiler-Funktionalit�t ben�tigt wird � aber effizienter.
Vorteile:
Geringer Overhead, auch produktiv nutzbar.
Sehr granular konfigurierbar.
Speicherung im Ring-Buffer oder Datei m�glich.
Nachteile:
Einarbeitung n�tig (GUI in SSMS oder T-SQL-Definitionen).
# SQLServerPerformanceTuning-AdvancedQueryOptimization-255450
KursRepository zu Kurs SQL Server Performance Tuning &amp; Advanced Query Optimization der ppedv AG


Adhoc Abfragen, Sichten , Funktionen, Prozeduren
Kurzer Rückblick:. Was ist das für ein Zeug?
Welche eklatanten Fehler können in Sichten passieren?
Warum lügt uns SQL Server bei Funktionen an?

Indizes
Von Heaps, Clustered und Non Clustered Indizes
und warum muss man das Zeug kennen.
Arten von Indizes und wo sind die Vorteile und wo die Nachteile?
Warum sollte man diese gut und täglich pflegen

Was ist der Ausführungsplan und warum brauch ich den
Logische Schritte der Abfrageausführung
Ausführungspläne verstehen
Gespeicherte Prozeduren - und warum sind die schneller und manchmal extrem langsam
..und wo kann man da nachschauen..

Werkzeuge und Indikatoren zur Messung – und wann verwende ich was
Aktivitätsmonitor
Dynamische Verwaltungssichten
Ablaufverfolgung und der SQL Server Profiler
Windows Systemmonitor
Statistische Systemfunktionen
XEvents

Intelligente Abfrageverarbeitung in SQL
Warum ist mir die Reihenfolge der JOINS rel egal..und wenn schon, dann in welcher Reihenfolge
SQL Server kann ab Version x Abfragen optimieren – was aber wenn ich eine ältere Version verwende ☹

Daten komprimieren

Abfragen analysieren und optimieren
Ausführungspläne und Plancache

Die Rolle von Statistiken

Parametrisierte Abfragen ausführen
Parameter Sniffing

Physikalische JOIN-Operatoren

Auffinden geeigneter Indizes
Auffinden problematischer Abfragen
Dynamische Verwaltungssichten
Mit dem Profiler arbeiten
Datenauflistungen einsetzen
Erweiterte Ereignisse verwenden

Physischen Datenbankentwurf optimieren
Indexüberwachung mit Datenauflistungen
Partitionierung mit Indizes

###############Eure Stichwortliste###################
Dynamisches SQL
Was ist ok und was nicht.. Was haben wir bei den Ausführungsplänen gelernt

Linked Server
How to Linked Server
Wann eignet sich ein Linked Server
Warum kann ein Linked Server tierisch langsam sein

Cursor
Wann setzt man einen Cursor ein und wann nicht.
Wie funktioniert ein Cursor?
Besser Schleife oder Cursor – beantworte selber😉

SQL DBs
Must Settings on DB
Security – best practice
Monitoring Performance – siehe auch Tools weiter oben
SQL Debugging
😊
Deadlocks
Wie kann es zu Deadlocks kommen… (Code oder Backgroundprozesse)
Wie kann man „schnell“ herausfinden, wie es dazu kommt?
Verarbeitungshinweise
..und warum man sie – wenn überhaupt) sparsam einsetzen sollte

Adhoc Abfragen, Sichten , Funktionen, Prozeduren: (inkl Gespeicherte Prozeduren – wann schnell und wann langsam)
) 1h
Indizes: 2h
Ausführungsplan + Messung 10min (wird eh permanent gebraucht)
Werkzeuge und Indikatoren zur Messung (hier unbedingt den QueryStore mit rein) 1h
IQP: 30min
Daten komprimieren 30min
Abfragen analysieren und optimieren 1h
Auffinden problematischer Abfragen 30min
Physischen Datenbankentwurf optimieren (1h)
Dynamisches SQL (wie kann man das optimieren) 0,5
Linked Server (was ist zu tun, damit es ein bisschen schneller geht)  0,5
Cursor (wann und wann nicht vs Whil und Window functions) 0,5
SQL DBs (best settings) 0,75
Deadlocks (woher und was tun) 0,5
Verarbeitungshinweise (wann, wo) 0,5 

--INNER JOIN

Nested Loops Join 🔁
Dies ist die einfachste und grundlegendste Join-Methode. Man kann es sich wie eine verschachtelte Schleife vorstellen:

Der Abfrageoptimierer wählt eine Tabelle als "äußere" Tabelle und eine andere als "innere" Tabelle aus.

Für jede Zeile in der äußeren Tabelle durchläuft der Abfrageoptimierer die gesamte innere Tabelle oder sucht mithilfe eines Index nach passenden Zeilen.

Wenn eine passende Zeile gefunden wird, werden die Zeilen kombiniert und an die Ausgabe gesendet.

Der Nested Loops Join ist besonders effizient, wenn:

Die äußere Tabelle sehr klein ist.

Die innere Tabelle einen Index auf der Join-Spalte hat, was die Suche nach passenden Zeilen extrem schnell macht (Index Seek).

Merge Join 🤝
Der Merge Join ist eine sehr effiziente Methode, die jedoch eine 
wichtige Voraussetzung hat: Beide Tabellen müssen bereits auf der 
Join-Spalte sortiert sein.

Beide Tabellen werden gleichzeitig gelesen.
Der Abfrageoptimierer vergleicht die erste Zeile jeder Tabelle.
Wenn die Join-Spalten übereinstimmen, werden die Zeilen kombiniert 
und beide Cursor bewegen sich zur nächsten Zeile.

Wenn die Werte nicht übereinstimmen, wird der Cursor der Tabelle 
mit dem kleineren Wert weiterbewegt, bis die Werte wieder gleich oder größer sind.

Wenn die Tabellen nicht vorsortiert sind, muss der SQL Server 
vor dem Join-Vorgang einen zusätzlichen Sortierschritt durchführen, 
was die Leistung beeinträchtigen kann. Merge Join ist oft die beste Wahl für sehr große Datasets, die bereits sortiert sind (z. B. durch einen Cluster-Index).

Hash Join 🥣
Der Hash Join eignet sich am besten für große, unsortierte Datasets. 
Der Prozess läuft in zwei Phasen ab:

Build-Phase: Der SQL Server wählt die kleinere der beiden Tabellen aus 
(die sogenannte "Build-Eingabe"). Er scannt diese Tabelle und 
erstellt einen In-Memory-Hash-Tabelle auf Basis der Join-Spalte.

Probe-Phase: Anschließend wird die größere Tabelle (die "Probe-Eingabe") 
gescannt. Für jede Zeile der Probe-Eingabe wird der Hash-Wert der 
Join-Spalte berechnet und in der Hash-Tabelle nach einer Übereinstimmung gesucht. Wenn eine Übereinstimmung gefunden wird, werden die Zeilen kombiniert.

Der Hash Join kann viel Speicher verbrauchen, wenn die Build-Eingabe 
zu groß ist, da die Hash-Tabelle in den Arbeitsspeicher geladen werden muss.

Es gibt auch noch den Adaptive Join, der in SQL Server 2017 eingeführt wurde. 
Dieser kann zur Laufzeit entscheiden, ob er einen Nested Loops Join 
oder einen Hash Join verwendet, basierend auf der tatsächlichen Anzahl 
der Zeilen, die verarbeitet werden müssen. Dies bietet eine größere 
Flexibilität und verbessert die Leistung in Situationen, in denen 
der Abfrageoptimierer vor der Ausführung keine genaue Schätzung 
über die Zeilenanzahl hat.


Remote Join 🌐
Ein Remote Join ist kein physikalischer Join-Operator im eigentlichen Sinne, 
sondern beschreibt eine Situation, in der ein JOIN über eine Linked 
Server-Verbindung ausgeführt wird. Dabei liegen die beteiligten Tabellen 
nicht auf demselben SQL Server-Instanz, sondern auf verschiedenen Servern.

Funktionsweise: Wenn du eine Abfrage mit einem Join auf eine Tabelle 
auf einem Remote Server absetzt, muss SQL Server entscheiden, 
wo der Join ausgeführt werden soll.

Option A (lokaler Join): Der SQL Server holt alle notwendigen Daten 
der Remote-Tabelle über das Netzwerk zum lokalen Server und führt 
den Join dort aus. Dies kann ineffizient sein, wenn die Remote-Tabelle sehr groß ist.

Option B (Remote Join): Der Abfrageoptimierer erkennt, 
dass es effizienter wäre, den Join auf dem Remote Server auszuführen. 
Er sendet die Anweisungen für den Join zur Remote-Instanz, 
und der Remote Server führt die Operation durch und schickt nur 
das Endergebnis zurück.

Optimierung: SQL Server versucht in der Regel, den Join so nah wie 
möglich an den Daten auszuführen. Du kannst das Verhalten aber auch 
mit dem REMOTE Join-Hint beeinflussen, um den Remote Join explizit 
zu erzwingen. Dies ist jedoch selten nötig, da der Abfrageoptimierer 
meistens die richtige Entscheidung trifft.




select * from  customers c
	inner merge join 
			   orders o		on c.CustomerID=o.CustomerID

select * from  customers c
	inner loop join 
			   orders o		on c.CustomerID=o.CustomerID

select * from  customers c
	inner hash join 
			   orders o		on c.CustomerID=o.CustomerID
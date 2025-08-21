/*

🔎 1. Gefilterter Index (Filtered Index)
💡 Definition:
Ein gefilterter Index ist ein nicht gruppierter Index
, der nur auf einen Teil der Daten angewendet wird – nämlich solche Zeilen
, die eine bestimmte Bedingung erfüllen (über WHERE definiert).

🛠 Syntax-Beispiel:

CREATE NONCLUSTERED INDEX IX_Status_Active
ON Auftraege (Status)
WHERE Status = 'Aktiv';
✅ Vorteile:
Weniger Speicherbedarf

Schneller beim Zugriff auf selten genutzte Werte (z. B. NULL, bestimmte Stati)

Weniger Wartungsaufwand (nur Teilmenge wird aktualisiert)

❌ Nicht geeignet:
Wenn die Filterbedingung häufig wechselt

Wenn der Index viele Zeilen enthält → dann kaum Vorteil gegenüber regulärem Index

🧩 2. Zusammengesetzter Index (Composite / Multi-Column Index)
💡 Definition:
Ein zusammengesetzter Index enthält mehrere Spalten in einer festen Reihenfolge. Er ist hilfreich für Abfragen, die über mehrere Spalten gleichzeitig filtern oder sortieren.

🛠 Syntax-Beispiel:

CREATE NONCLUSTERED INDEX IX_Kunde_Datum
ON Bestellungen (KundeID, Bestelldatum);
✅ Vorteile:
Optimal für Abfragen, die genau in dieser Spaltenreihenfolge filtern oder sortieren.

Kann mehrere Einzelindizes ersetzen.

❗Wichtig:
Nur die linksbasierten Spalten werden effektiv verwendet.

Obiges Beispiel hilft bei WHERE KundeID = ... AND Bestelldatum = ...,
aber nicht bei WHERE Bestelldatum = ... allein.

📦 3. Index mit eingeschlossenen Spalten (Included Columns)
💡 Definition:
Ein Index mit eingeschlossenen Spalten enthält zusätzlich zu den Indexschlüsselspalten weitere Spalten, die nicht sortiert oder zur Suche verwendet werden, aber im Index mitgeführt werden.

🛠 Syntax-Beispiel:

CREATE NONCLUSTERED INDEX IX_Email_Include
ON Kunden (Email)
INCLUDE (Vorname, Nachname);
✅ Vorteile:
Macht Index zu einem „Covering Index“ → die Abfrage kann alle benötigten Daten direkt aus dem Index lesen (keine Bookmark Lookup nötig).

Spart I/O und verbessert die Performance erheblich bei häufigen Lesezugriffen.

🔍 Hinweis:
Die INCLUDE-Spalten werden nicht sortiert und müssen nicht eindeutig sein.

Ideal für große Tabellen mit vielen Spalten, wenn nur wenige regelmäßig gebraucht werden.

🔚 Fazit:
Index-Typ	Zielsetzung	Vorteil
Gefilterter Index	Nur bestimmte Zeilen indexieren	Spart Speicher & erhöht Performance bei Spezialfällen
Zusammengesetzter Index	Kombination mehrerer Spalten	Optimiert komplexe WHERE/ORDER BY
Included Columns	Weitere Daten im Index „mitliefern“	Erspart Lookup – schneller bei SELECT

Bei Bedarf kann man diese auch kombinieren, z. B. ein gefilterter zusammengesetzter Index mit eingeschlossenen Spalten.


*/
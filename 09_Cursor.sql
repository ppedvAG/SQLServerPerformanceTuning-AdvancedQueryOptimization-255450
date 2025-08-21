
--Vorteile von Cursors
Feinsteuerung: 
Du kannst Zeilen einzeln behandeln und 
komplexe Logik anwenden.

Notwendig bei bestimmten Algorithmen: 
Z. B. bei iterativen Berechnungen, die stark voneinander abhängen.

Gut bei Prototyping oder Ad-Hoc-Abfragen: 
Wenn du mal schnell Daten durchgehen willst.

Nachteile von Cursors
Performance-Probleme:

Cursors arbeiten zeilenweise → langsam bei großen Datenmengen.

Speicherintensiv, da SQL Server Zeilen puffern muss.

Komplexität: 
Mehr Code, mehr Fehlerpotenzial.

Set-Based-Ansatz fast immer schneller: 
Viele Cursor-Szenarien lassen sich mit Joins, 
Window Functions oder UPDATE ... FROM ... besser lösen.

Wann Cursors sinnvoll sind   :
Wenn jede Zeile abhängig von vorherigen Zeilen verarbeitet werden muss.
vs Window Functions

Wenn externe Aufrufe pro Zeile erforderlich sind 
(z. B. Prozeduraufrufe oder Logging).

Wenn du ein algorithmisches Problem hast,
das sich schwer in SQL-Mengenoperationen abbilden lässt.



--Wie gehts?

--Schritt 1    Cursor definieren
DECLARE myCursor CURSOR FOR
SELECT CustomerID, CompanyName 
FROM Customers;


--Schritt 2      Cursor öffnen
OPEN myCursor;

--Schritt 3       Cursor Durchlauf
DECLARE @CustomerID NCHAR(5), @CompanyName NVARCHAR(40);

FETCH NEXT FROM myCursor INTO @CustomerID, @CompanyName;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Kunde: ' + @CustomerID + ' - ' + @CompanyName;

    -- nächste Zeile abrufen
    FETCH NEXT FROM myCursor INTO @CustomerID, @CompanyName;
END


--Schritt 4        Cursor schließen und entfernen
CLOSE myCursor;
DEALLOCATE myCursor;



--Komplettes Beispiel

DECLARE @ProductID INT, @Price MONEY;

DECLARE priceCursor CURSOR FOR
SELECT ProductID, UnitPrice
FROM Products;

OPEN priceCursor;

FETCH NEXT FROM priceCursor INTO @ProductID, @Price;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Beispiel: Erhöhe alle Preise um 10 %
    --UPDATE Products
    --SET UnitPrice = @Price * 1.10
    --WHERE ProductID = @ProductID;
    select * from products where productid = @ProductID

    FETCH NEXT FROM priceCursor INTO @ProductID, @Price;
END

CLOSE priceCursor;
DEALLOCATE priceCursor;


--Bewegungen im Cursor:

SCROLL         → Bewegung im Cursor
STATIC         → Kopie der Daten, scrollen möglich  man sieht keine Änderungen
KEYSET         → Änderungen an Zeilen sind sichtbar, scrollen möglich
                 Zeilenmenge fix, Updates sichtbar, 
                 Inserts nicht, Deletes bleiben als „Lücken
DYNAMIC        → immer aktuelle Daten, scrollen möglich
                 Immer live, alle Änderungen
                 (Insert, Update, Delete) sofort sichtbar, 
                 Reihenfolge kann sich ändern.
FORWARD_ONLY   → (Standard) → nur vorwärts, kein Rückwärtsblättern

USE Northwind;
GO

DECLARE @CustomerID NCHAR(5), @CompanyName NVARCHAR(40);

DECLARE custCursor CURSOR SCROLL FOR
SELECT CustomerID, CompanyName
FROM Customers
ORDER BY CustomerID;

OPEN custCursor;

-- Erste Zeile
FETCH FIRST FROM custCursor INTO @CustomerID, @CompanyName;
PRINT 'FIRST: ' + @CustomerID + ' - ' + @CompanyName;

-- 5. Zeile direkt
FETCH ABSOLUTE 5 FROM custCursor INTO @CustomerID, @CompanyName;
PRINT 'ABSOLUTE 5: ' + @CustomerID + ' - ' + @CompanyName;

-- Eine Zeile zurück
FETCH PRIOR FROM custCursor INTO @CustomerID, @CompanyName;
PRINT 'PRIOR: ' + @CustomerID + ' - ' + @CompanyName;

-- Drei Zeilen vorwärts relativ
FETCH RELATIVE 3 FROM custCursor INTO @CustomerID, @CompanyName;
PRINT 'RELATIVE +3: ' + @CustomerID + ' - ' + @CompanyName;

CLOSE custCursor;
DEALLOCATE custCursor;



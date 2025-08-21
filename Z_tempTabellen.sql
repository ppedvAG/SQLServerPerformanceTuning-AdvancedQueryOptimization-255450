/*
 #t lokale temp Tabelle
 ##t globale temp Tabellen



solange sie verwendet wird

nur in der ersteller Session bei #t
*/

select * into #t from sysdatabases
select * into ##t from sysdatabases

select * from #t
select * from ##t

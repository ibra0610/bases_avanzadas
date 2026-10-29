--verifique que el nombre del servidor sea mssql-subscriber-2
SELECT @@SERVERNAME

USE master;

CREATE DATABASE Sales_Replica_2;

---------------------------------------------------

USE Sales_Replica_2;

SELECT * FROM Sales;
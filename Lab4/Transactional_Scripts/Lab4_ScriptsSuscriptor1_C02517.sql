--verifique que el nombre del servidor sea mssql-subscriber-1
SELECT @@SERVERNAME

USE master;

CREATE DATABASE Sales_Replica_1;

-----------------------------------------------------------

USE Sales_Replica_1;

SELECT * FROM Sales;

-----------------------------------------------------------

--verifique que el nombre del servidor sea mssql-subscriber-1
SELECT @@SERVERNAME

USE Sales_Replica_1;

SELECT *
FROM dbo.Sales
WHERE Id = 1;

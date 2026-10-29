--verifique que el nombre del servidor sea mssql-subscriber-2
SELECT @@SERVERNAME

USE master;

CREATE DATABASE Sales_Replica_2;

---------------------------------------------------

--verifique que el nombre del servidor sea mssql-subscriber-2
SELECT @@SERVERNAME

USE Sales_Replica_2;

INSERT INTO dbo.Sales (Id, Customer, Amount, Note)
VALUES (4, N'Client 4', 1000.00, 'replica 2');

INSERT INTO dbo.Sales (Id, Customer, Amount, Note)
VALUES (5, N'Client 5', 1000.00, 'replica 2');

SELECT *
FROM Sales;

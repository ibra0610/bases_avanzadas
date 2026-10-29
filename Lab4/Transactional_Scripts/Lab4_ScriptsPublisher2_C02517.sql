--verifique que el nombre del servidor sea mssql-publisher
SELECT @@SERVERNAME

USE Sales;

SELECT *
FROM dbo.Sales
WHERE Id = 1;

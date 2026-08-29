-- Script con Waitfor
USE BD_Demo_Recovery;
GO

BEGIN TRANSACTION;

UPDATE dbo.Sales 
SET Amount = Amount - 50 
WHERE Id = 1;

WAITFOR DELAY '00:05:00';

--------------------------------------------

-- Select Sales Id = 1

USE BD_Demo_Recovery;
GO

SELECT Amount
FROM dbo.Sales 
WHERE Id = 1;

-----------------------------------------
--Revisar historico de operaciones de recuperacion

USE BD_Demo_Recovery;
GO
SELECT COUNT(*) AS TotalFilas
FROM fn_dblog(null, null);

SELECT DISTINCT [AllocUnitName]
FROM fn_dblog(null, null)
WHERE [AllocUnitName] IS NOT NULL;





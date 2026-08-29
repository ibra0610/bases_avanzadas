-- Query 3
USE BD_Demo_Recovery;
GO

BEGIN TRANSACTION;

UPDATE dbo.Sales 
SET Amount = Amount + 50 
WHERE Id = 2;

COMMIT;

WAITFOR DELAY '00:05:00';

-- Verificar amount con id=2

USE BD_Demo_Recovery;
GO

SELECT Amount
FROM dbo.Sales 
WHERE Id = 2;

-----------------------------------------
--Revisar historico de operaciones de recuperacion

USE BD_Demo_Recovery;
GO
SELECT [Current LSN], [Operation], [Transaction ID], [Context], [AllocUnitName], [Description]
FROM fn_dblog(null, null)
WHERE [AllocUnitName] LIKE '%Sales%'
ORDER BY [Current LSN];


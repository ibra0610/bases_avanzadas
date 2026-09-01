-- Consultar bitacora --
USE BD_Demo_Recovery;
SELECT 
	DB_NAME(),
	log_min_lsn,
	log_end_lsn,
	total_log_size_mb,
	log_checkpoint_lsn,
	log_since_last_checkpoint_mb
FROM sys.dm_db_log_stats(DB_ID());

SELECT 
	DB_NAME(), 
	[Current LSN], 
	Operation, 
	[Checkpoint Begin],
	[Checkpoint End]
FROM fn_dblog(null, null)
WHERE [Operation] like '%CKPT'

--------------------------------------------------------------------

-- Creacion de base de datos BD_Demo_Recovery

-- limpiar base de datos
USE master;
GO

IF DB_ID(N'BD_Demo_Recovery') IS NOT NULL
BEGIN
    ALTER DATABASE BD_Demo_Recovery SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE BD_Demo_Recovery;
END;

-- crear base de datos
CREATE DATABASE BD_Demo_Recovery
GO

USE BD_Demo_Recovery;
GO

-- crear accounts
CREATE TABLE dbo.Sales
(
    Id INT IDENTITY PRIMARY KEY,
    Customer VARCHAR(100) NOT NULL,
    Amount DECIMAL(12,2) NOT NULL,
    Note VARCHAR(200) NULL,
    Registration DATETIME2 NULL DEFAULT (SYSUTCDATETIME())
);
GO

INSERT INTO dbo.Sales (Customer, Amount, Note)
VALUES (N'Client 1', 1000.00, 'seed'), (N'Client 2', 1000.00, 'seed');

-- crear datas
CREATE TABLE dbo.Datas
(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Pad CHAR(4000) NOT NULL DEFAULT 'X'
);

USE master;
GO
------------------------------------------------------------

-- Establecer modo de recuperacion FULL

USE master;
GO
ALTER DATABASE BD_Demo_Recovery SET RECOVERY FULL;
GO

---------------------------------------------------------------

-- Insercion en tabla Datas
-- Script Insertar Datas

USE BD_Demo_Recovery;
GO

SET NOCOUNT ON;

DECLARE @i INT = 1;
WHILE @i <= 2048
BEGIN
    INSERT INTO dbo.Datas DEFAULT VALUES;
    SET @i += 1;
END

-------------------------------------------------------

-- Crear un checkpoint manual

USE BD_Demo_Recovery;
GO

CHECKPOINT;

GO

----------------------------------------------------

-- Consulta de TARGET_RECOVERY_TIME

SELECT name, target_recovery_time_in_seconds
FROM sys.databases
WHERE name = 'BD_Demo_Recovery';

----------------------------------------------------

-- Modificar TARGET_RECOVERY_TIME a 5 segundos

ALTER DATABASE BD_Demo_Recovery SET TARGET_RECOVERY_TIME = 5 SECONDS;

-----------------------------------------------------------------

-- Modificar TARGET_RECOVERY_TIME a 120 segundos

ALTER DATABASE BD_Demo_Recovery SET TARGET_RECOVERY_TIME = 120 SECONDS;

-----------------------------------------------------------------

-- Respaldo FULL de la base de datos
USE master;
GO
BACKUP DATABASE BD_Demo_Recovery TO DISK = 'C:\Users\Ibra\Desktop\UCR\Bases Avanzadas\bases_avanzadas\Lab1\C02517_BD_Demo_Recovery_FULL.bak'

--------------------------------------------------------------
-- Simular cambios en base de datos

USE BD_Demo_Recovery;
GO
INSERT INTO dbo.Sales (Customer, Amount, Note)
VALUES (N'Client 3', 1000.00, 'pre diff 1');

--------------------------------------------------------------
-- Respaldo diferencial de la base de datos

USE master;
GO
BACKUP DATABASE BD_Demo_Recovery TO DISK = 'C:\Users\Ibra\Desktop\UCR\Bases Avanzadas\bases_avanzadas\Lab1\C02517_BD_Demo_Recovery_DIFF.bak' WITH DIFFERENTIAL;
--------------------------------------------------------------
-- Simular cambios en base de datos
USE BD_Demo_Recovery;
GO
INSERT INTO dbo.Sales (Customer, Amount, Note)
VALUES (N'Client 4', 1000.00, 'pre diff 2');

--------------------------------------------------------------
-- Segundo respaldo diferencial de la base de datos
USE master;
GO
BACKUP DATABASE BD_Demo_Recovery TO DISK = 'C:\Users\Ibra\Desktop\UCR\Bases Avanzadas\bases_avanzadas\Lab1\C02517_BD_Demo_Recovery_DIFF2.bak' WITH DIFFERENTIAL;

--------------------------------------------------------------
-- Simular cambios en base de datos
USE BD_Demo_Recovery;
GO
INSERT INTO dbo.Sales (Customer, Amount, Note)
VALUES (N'Client 5', 1000.00, 'pre log 1');

--------------------------------------------------------------
-- Respaldo de log de transacciones de la base de datos

USE master;
GO
BACKUP LOG BD_Demo_Recovery TO DISK = 'C:\Users\Ibra\Desktop\UCR\Bases Avanzadas\bases_avanzadas\Lab1\C02517_BD_Demo_Recovery_LOG1.trn';

--------------------------------------------------------------
-- Simular cambios en base de datos
USE BD_Demo_Recovery;
GO
INSERT INTO dbo.Sales (Customer, Amount, Note)
VALUES (N'Client 6', 1000.00, 'pre log 2');

--------------------------------------------------------------
-- Segundo respaldo de log de transacciones de la base de datos
USE master;
GO
BACKUP LOG BD_Demo_Recovery TO DISK = 'C:\Users\Ibra\Desktop\UCR\Bases Avanzadas\bases_avanzadas\Lab1\C02517_BD_Demo_Recovery_LOG2.trn';

--------------------------------------------------------------
-- Simular cambios en base de datos
USE BD_Demo_Recovery;
GO
INSERT INTO dbo.Sales (Customer, Amount, Note)
VALUES (N'Client 7', 1000.00, 'final');

--------------------------------------------------------------
-- Verificar datos en tabla Sales
USE BD_Demo_Recovery;
GO
SELECT * FROM dbo.Sales;

--------------------------------------------------------------
-- Simular fallo catastrófico

USE master;

IF DB_ID(N'BD_Demo_Recovery') IS NOT NULL
BEGIN
    ALTER DATABASE BD_Demo_Recovery SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE BD_Demo_Recovery;
END;
--------------------------------------------------------------
-- Recuperacion de la base de datos usando los respaldos creados

USE MASTER;
GO

RESTORE DATABASE BD_Demo_Recovery FROM DISK = 'C:\Users\Ibra\Desktop\UCR\Bases Avanzadas\bases_avanzadas\Lab1\C02517_BD_Demo_Recovery_FULL.bak' WITH NORECOVERY;
GO
RESTORE DATABASE BD_Demo_Recovery FROM DISK = 'C:\Users\Ibra\Desktop\UCR\Bases Avanzadas\bases_avanzadas\Lab1\C02517_BD_Demo_Recovery_DIFF2.bak' WITH NORECOVERY;
GO
RESTORE LOG BD_Demo_Recovery FROM DISK = 'C:\Users\Ibra\Desktop\UCR\Bases Avanzadas\bases_avanzadas\Lab1\C02517_BD_Demo_Recovery_LOG1.trn' WITH NORECOVERY;
GO
RESTORE LOG BD_Demo_Recovery FROM DISK = 'C:\Users\Ibra\Desktop\UCR\Bases Avanzadas\bases_avanzadas\Lab1\C02517_BD_Demo_Recovery_LOG2.trn' WITH RECOVERY;

--------------------------------------------------------------
-- Verificar datos en tabla Sales
USE BD_Demo_Recovery;
GO
SELECT * FROM dbo.Sales;

----------------------------------------------------------------
-- Paso adicional, backup de Tail log

USE MASTER;
GO

-- PASO ADICIONAL:
BACKUP LOG BD_Demo_Recovery
TO DISK = 'C:\Users\Ibra\Desktop\UCR\Bases Avanzadas\bases_avanzadas\Lab1\C02517_BD_Demo_Recovery_TAIL.trn'
WITH NORECOVERY;
GO

RESTORE DATABASE BD_Demo_Recovery FROM DISK = 'C:\Users\Ibra\Desktop\UCR\Bases Avanzadas\bases_avanzadas\Lab1\C02517_BD_Demo_Recovery_FULL.bak' WITH NORECOVERY;
GO
RESTORE DATABASE BD_Demo_Recovery FROM DISK = 'C:\Users\Ibra\Desktop\UCR\Bases Avanzadas\bases_avanzadas\Lab1\C02517_BD_Demo_Recovery_DIFF2.bak' WITH NORECOVERY;
GO
RESTORE LOG BD_Demo_Recovery FROM DISK = 'C:\Users\Ibra\Desktop\UCR\Bases Avanzadas\bases_avanzadas\Lab1\C02517_BD_Demo_Recovery_LOG1.trn' WITH NORECOVERY;
GO
RESTORE LOG BD_Demo_Recovery FROM DISK = 'C:\Users\Ibra\Desktop\UCR\Bases Avanzadas\bases_avanzadas\Lab1\C02517_BD_Demo_Recovery_LOG2.trn' WITH NORECOVERY;

-- PASO ADICIONAL:
-- Restaurar el TAIL LOG que contiene las transacciones
RESTORE LOG BD_Demo_Recovery
FROM DISK = 'C:\Users\Ibra\Desktop\UCR\Bases Avanzadas\bases_avanzadas\Lab1\C02517_BD_Demo_Recovery_TAIL.trn'
WITH RECOVERY;
GO
---------------------------------------------------------------
--verifique que el nombre del servidor sea mssql-publisher
SELECT @@SERVERNAME

USE master;

CREATE DATABASE Sales;
GO

USE Sales;

CREATE TABLE dbo.Sales
(
    Id INT IDENTITY PRIMARY KEY,
    Customer VARCHAR(100) NOT NULL,
    Amount DECIMAL(12,2) NOT NULL,
    Note VARCHAR(200) NULL,
    Registration DATETIME2 NULL DEFAULT (SYSUTCDATETIME())
);

INSERT INTO dbo.Sales (Customer, Amount, Note)
VALUES (N'Client 1', 1000.00, 'seed'), (N'Client 2', 1000.00, 'seed');

-----------------------------------------------

--verifique que el nombre del servidor sea mssql-publisher
SELECT @@SERVERNAME

USE master;

EXEC sp_adddistributor
    @distributor = @@SERVERNAME;

EXEC sp_adddistributiondb
    @database = N'distribution';

EXEC sp_adddistpublisher
	@publisher       = @@SERVERNAME,
	@distribution_db = N'distribution',
	@working_directory = N'/var/opt/mssql/replication'

-----------------------------------------------

--verifique que el nombre del servidor sea mssql-publisher
SELECT @@SERVERNAME

USE Sales;

EXEC sp_replicationdboption
    @dbname  = N'Sales',
    @optname = N'publish',
    @value   = N'true';

-----------------------------------------------

SELECT @@SERVERNAME

USE Sales;

EXEC sp_addpublication
  @publication = N'Sales-Publication',
  @repl_freq = N'continuous', -- esto hace que la replicación sea transaccional
  @status = N'active';

EXEC sp_addpublication_snapshot
  @publication = N'Sales-Publication',
  @frequency_type = 1;

EXEC sp_addarticle
  @publication = N'Sales-Publication',
  @article = N'dbo_Sales',
  @source_owner = N'dbo',
  @source_object = N'Sales';

  ---------------------------------------------

  --verifique que el nombre del servidor sea mssql-publisher
SELECT @@SERVERNAME

USE Sales;

EXEC sp_addsubscription
  @publication    = N'Sales-Publication',
  @subscriber     = N'mssql-subscriber-1',
  @destination_db = N'Sales_Replica_1';
   
EXEC sp_addpushsubscription_agent
  @publication               = N'Sales-Publication',
  @subscriber                = N'mssql-subscriber-1',
  @subscriber_db             = N'Sales_Replica_1',
  @subscriber_security_mode  = 0,
  @subscriber_login          = N'sa',
  @subscriber_password       = N'DEMO123*';

  --------------------------------------------------------

  --verifique que el nombre del servidor sea mssql-publisher
SELECT @@SERVERNAME

USE Sales;

EXEC sp_addsubscription
  @publication    = N'Sales-Publication',
  @subscriber     = N'mssql-subscriber-2',
  @destination_db = N'Sales_Replica_2';
   
EXEC sp_addpushsubscription_agent
  @publication               = N'Sales-Publication',
  @subscriber                = N'mssql-subscriber-2',
  @subscriber_db             = N'Sales_Replica_2',
  @subscriber_security_mode  = 0,
  @subscriber_login          = N'sa',
  @subscriber_password       = N'DEMO123*';

  ------------------------------------------------------

  --verifique que el nombre del servidor sea mssql-publisher
SELECT @@SERVERNAME

USE Sales;

EXEC sp_startpublication_snapshot @publication = N'Sales-Publication';

--------------------------------------------------------

--verifique que el nombre del servidor sea mssql-publisher
SELECT @@SERVERNAME

USE Sales;

INSERT INTO dbo.Sales (Customer, Amount, Note)
VALUES (N'Client 3', 1000.00, 'post configuration');

--------------------------------------------------------

--verifique que el nombre del servidor sea mssql-publisher
SELECT @@SERVERNAME

USE Sales;

INSERT INTO dbo.Sales (Customer, Amount, Note)
VALUES (N'Client 4', 1000.00, 'recovery');

--------------------------------------------------------

--verifique que el nombre del servidor sea mssql-publisher
SELECT @@SERVERNAME

USE Sales;
GO

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

BEGIN TRANSACTION;

UPDATE dbo.Sales
SET Amount = Amount + 1000
WHERE Id = 1;

COMMIT


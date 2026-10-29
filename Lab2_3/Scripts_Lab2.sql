CREATE DATABASE WWI_DW;
GO
USE WWI_DW;
GO

CREATE TABLE dbo.DimTiempo (
	TiempoKey INT NOT NULL PRIMARY KEY,
	Ano SMALLINT NOT NULL,
	Mes TINYINT NOT NULL,
	NombreMes NVARCHAR(20) NOT NULL,
	CONSTRAINT UQ_DimTiempo UNIQUE (Ano, Mes)
);

CREATE TABLE dbo.DimEstadoProvincia (
	EstadoProvinciaKey INT IDENTITY(1,1) PRIMARY KEY,
	StateProvinceID INT NOT NULL UNIQUE,
	Nombre NVARCHAR(50) NOT NULL,
	Codigo NVARCHAR(5) NULL,
	Pais NVARCHAR(60) NULL
);

CREATE TABLE dbo.DimProducto (
	ProductoKey INT IDENTITY(1,1) PRIMARY KEY,
	StockItemID INT NOT NULL UNIQUE,
	NombreProducto NVARCHAR(100) NOT NULL,
);

CREATE TABLE dbo.DimCategoriaCliente (
	CategoriaClienteKey INT IDENTITY(1,1) PRIMARY KEY,
	CustomerCategoryID INT NOT NULL UNIQUE,
	NombreCategoria NVARCHAR(50) NOT NULL
);

CREATE TABLE dbo.FactVentas (
	FactVentasKey BIGINT IDENTITY(1,1) PRIMARY KEY,
	InvoicesLineID INT NOT NULL UNIQUE,
	InvoiceID INT NOT NULL,
	TiempoKey INT NOT NULL REFERENCES dbo.DimTiempo(TiempoKey),
	EstadoProvinciaKey INT NOT NULL REFERENCES dbo.DimEstadoProvincia(EstadoProvinciaKey),
	ProductoKey INT NOT NULL REFERENCES dbo.DimProducto(ProductoKey),
	CategoriaClienteKey INT NOT NULL REFERENCES dbo.DimCategoriaCliente(CategoriaClienteKey),
	Cantidad INT NOT NULL,
	PrecioUnitario DECIMAL(18, 2) NOT NULL,
	MontoVenta DECIMAL(18, 2) NOT NULL
);

--  Datos simulados --

-- Tiempo: 2013-2016
;WITH m AS (
    SELECT CAST('2013-01-01' AS DATE) AS f
    UNION ALL SELECT DATEADD(MONTH,1,f) FROM m WHERE f < '2016-12-01'
)
INSERT dbo.DimTiempo (TiempoKey, Ano, Mes, NombreMes)
SELECT YEAR(f)*100+MONTH(f), YEAR(f), MONTH(f), DATENAME(MONTH,f) FROM m
OPTION (MAXRECURSION 100);

INSERT dbo.DimEstadoProvincia (StateProvinceID, Nombre, Codigo, Pais)
SELECT n, CONCAT('Estado ', n), CONCAT('E', n), 'United States'
FROM (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10)) v(n);

INSERT dbo.DimProducto (StockItemID, NombreProducto)
SELECT n, CONCAT('Producto ', n)
FROM (VALUES (1),(2),(3),(4),(5),(6),(7),(8)) v(n);

INSERT dbo.DimCategoriaCliente (CustomerCategoryID, NombreCategoria)
VALUES (1,'Minorista'),(2,'Mayorista'),(3,'Novelty Shop'),(4,'Supermercado');

-- Hechos

SELECT TOP (20000)
    ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn,
    ABS(CHECKSUM(NEWID())) AS r1, ABS(CHECKSUM(NEWID())) AS r2,
    ABS(CHECKSUM(NEWID())) AS r3, ABS(CHECKSUM(NEWID())) AS r4,
    ABS(CHECKSUM(NEWID())) AS r5, ABS(CHECKSUM(NEWID())) AS r6,
    ABS(CHECKSUM(NEWID())) AS r7
INTO #tmp
FROM sys.all_objects a CROSS JOIN sys.all_objects b;

INSERT dbo.FactVentas (InvoicesLineID, InvoiceID, TiempoKey, EstadoProvinciaKey, ProductoKey, CategoriaClienteKey, Cantidad, PrecioUnitario, MontoVenta)
SELECT rn, (rn+2)/3, (2013 + r1 % 4)*100 + (1 + r2 % 12), 1 + r3 % 10, 1 + r4 % 8, 1 + r5 % 4, q.Cant, q.Precio, q.Cant * q.Precio
FROM #tmp
CROSS APPLY (SELECT 1 + r6 % 20 AS Cant,
                    CAST(5 + (r7 % 9500)/100.0 AS DECIMAL(18,2)) AS Precio) q;

DROP TABLE #tmp;


--Create a table using collation Latin1_General_CI_AS and add some data to it 
CREATE TABLE MyTable1
(
    ID INT IDENTITY(1, 1), 
    Comments VARCHAR(100) COLLATE Latin1_General_CI_AS
)
INSERT INTO MyTable1 (Comments) VALUES ('Chiapas')
INSERT INTO MyTable1 (Comments) VALUES ('Colima')
 
--Create a second table using collation Traditional_Spanish_CI_AS and add some data to it 
CREATE TABLE MyTable2
(
    ID INT IDENTITY(1, 1), 
    Comments VARCHAR(100) COLLATE Traditional_Spanish_CI_AS
)
INSERT INTO MyTable2 (Comments) VALUES ('Chiapas')
INSERT INTO MyTable2 (Comments) VALUES ('Colima')
  
SELECT * FROM MyTable1 ORDER BY Comments
SELECT * FROM MyTable2 ORDER BY Comments
GO

--Retrives the properties for the two collations as defined within SQL
SELECT * FROM fn_helpcollations()
GO

SELECT 'SQL_Latin1_General_CP1_CI_AS' AS 'Collation',
    COLLATIONPROPERTY('SQL_Latin1_General_CP1_CI_AS', 'CodePage') AS 'CodePage', 
    COLLATIONPROPERTY('SQL_Latin1_General_CP1_CI_AS', 'LCID') AS 'LCID',
    COLLATIONPROPERTY('SQL_Latin1_General_CP1_CI_AS', 'ComparisonStyle') AS 'ComparisonStyle', 
    COLLATIONPROPERTY('SQL_Latin1_General_CP1_CI_AS', 'Version') AS 'Version'
UNION ALL
SELECT 'Latin1_General_CI_AS' AS 'Collation', 
    COLLATIONPROPERTY('Latin1_General_CI_AS', 'CodePage') AS 'CodePage', 
    COLLATIONPROPERTY('Latin1_General_CI_AS', 'LCID') AS 'LCID',
    COLLATIONPROPERTY('Latin1_General_CI_AS', 'ComparisonStyle') AS 'ComparisonStyle', 
    COLLATIONPROPERTY('Latin1_General_CI_AS', 'Version') AS 'Version'
GO

--Clean up previous query
IF EXISTS(SELECT 1 FROM sys.tables WHERE Name = 'MyTable1')
    DROP TABLE MyTable1
 
IF EXISTS(SELECT 1 FROM sys.tables WHERE Name = 'MyTable2')
    DROP TABLE MyTable2
 
--Create a table using collation Latin1_General_CI_AS and add some data to it 
CREATE TABLE MyTable1
(
    ID INT IDENTITY(1, 1), 
    Comments VARCHAR(100) COLLATE Latin1_General_CI_AS
)
INSERT INTO MyTable1 (Comments) VALUES ('Chiapas')
INSERT INTO MyTable1 (Comments) VALUES ('Colima')
 
--Create a second table using collation SQL_Latin1_General_CP1_CI_AS and add some data to it 
CREATE TABLE MyTable2
(
    ID INT IDENTITY(1, 1), 
    Comments VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS
)
INSERT INTO MyTable2 (Comments) VALUES ('Chiapas')
INSERT INTO MyTable2 (Comments) VALUES ('Colima')
GO
  
--Join both tables on a column with differing collations - this will throw an exception
SELECT * FROM MyTable1 M1
INNER JOIN MyTable2 M2 ON M1.Comments = M2.Comments
 
GO

CREATE INDEX IX_Comments ON  MyTable1(Comments)
CREATE INDEX IX_Comments ON  MyTable2(Comments)
GO

--Show the differences with the query plans with these queries
DBCC FREEPROCCACHE
GO
SELECT Comments FROM MyTable1 WHERE Comments = 'Colima'
GO
DBCC FREEPROCCACHE
GO
SELECT Comments FROM MyTable2 WHERE Comments = 'Colima'
GO

DBCC FREEPROCCACHE
GO
SELECT Comments FROM MyTable1 WHERE Comments =  (SELECT N'Colima' COLLATE Latin1_General_CI_AS)
GO
DBCC FREEPROCCACHE
GO
SELECT Comments FROM MyTable2 WHERE Comments = N'Colima'
GO

--Create a third table and add data with a character than can be expanded
CREATE TABLE MyTable3
(
	ID INT IDENTITY(1, 1), 
	Comments VARCHAR(100)
)

INSERT INTO MyTable3 (Comments) VALUES ('strasse')
INSERT INTO MyTable3 (Comments) VALUES ('straﬂe')
GO

--query returns both records using windows collation
SELECT * FROM MyTable3 WHERE Comments COLLATE Latin1_General_CI_AS = 'strasse'
SELECT * FROM MyTable3 WHERE Comments COLLATE Latin1_General_CI_AS = 'straﬂe'
GO

--query returns single record using SQL collation
SELECT * FROM MyTable3 WHERE Comments COLLATE SQL_Latin1_General_CP1_CI_AS = 'strasse'
SELECT * FROM MyTable3 WHERE Comments COLLATE SQL_Latin1_General_CP1_CI_AS = 'straﬂe'
GO

--query returns both records using SQL collation but unicode comparison (nvarchar)
SELECT * FROM MyTable3 WHERE Comments COLLATE SQL_Latin1_General_CP1_CI_AS = N'strasse'
SELECT * FROM MyTable3 WHERE Comments COLLATE SQL_Latin1_General_CP1_CI_AS = N'straﬂe'
GO

drop table MyTable1
drop table MyTable2
drop table MyTable3
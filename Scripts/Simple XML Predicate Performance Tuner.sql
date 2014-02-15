--Create example table
CREATE TABLE XmlTable 
(
	Id INT IDENTITY(1, 1) PRIMARY KEY CLUSTERED,
	MyXml XML NOT NULL
)

--Populate table with a large xml blob
DECLARE @XmlData XML
SET @XmlData = (SELECT * FROM sys.tables FOR XML PATH('Table'), ROOT('Tables'))

INSERT INTO XmlTable (MyXml)
VALUES (@XmlData)


--Query 1: use element name in predicate
SELECT *
FROM XmlTable
WHERE MyXml.exist('/Tables/Table[name = "XmlTable"]') = 1

--Query 2: use dot in predicate
SELECT *
FROM XmlTable
WHERE MyXml.exist('/Tables/Table/name [. = "XmlTable"]') = 1

--Clean up
DROP TABLE XmlTable
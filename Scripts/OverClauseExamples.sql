USE tempdb
GO

--OVER() - Day 1
CREATE TABLE _tmp_SomeCustomerData
(
	CustomerId VARCHAR(10),
	StatsDate DATETIME,
	SomeValue INT
)

--Insert some test data
INSERT INTO _tmp_SomeCustomerData (CustomerId, StatsDate, SomeValue)
VALUES ('Cust001', '2012-09-01 10:00:54.341', 12),
	('Cust002', '2012-09-01 10:01:12.236', 4),
	('Cust005', '2012-09-01 10:10:53.247', 16)

INSERT INTO _tmp_SomeCustomerData (CustomerId, StatsDate, SomeValue)
VALUES ('Cust001', '2012-09-01 11:01:19.753', 14),
	('Cust003', '2012-09-01 11:02:34.467', 10),
	('Cust004', '2012-09-01 11:04:29.766', 16)
	
INSERT INTO _tmp_SomeCustomerData (CustomerId, StatsDate, SomeValue)
VALUES ('Cust002', '2012-09-01 12:00:02.216', 1),
	('Cust003', '2012-09-01 12:03:21.731', 16)

INSERT INTO _tmp_SomeCustomerData (CustomerId, StatsDate, SomeValue)
VALUES ('Cust001', '2012-09-01 13:00:42.227', 10),
	('Cust002', '2012-09-01 13:01:11.063', 2),
	('Cust003', '2012-09-01 13:02:51.457', 17)

--get the data that we require, namely the last value based on the date for each customer
;WITH xCTE AS
(
	SELECT ROW_NUMBER() OVER (PARTITION BY CustomerId ORDER BY StatsDate DESC) RowNo
		, CustomerId
		, StatsDate
		, SomeValue
	FROM _tmp_SomeCustomerData
)
SELECT CustomerId 
	, StatsDate
	, SomeValue
FROM xCTE
WHERE RowNo = 1

DROP TABLE _tmp_SomeCustomerData
GO

--OVER() - Day 2

--create table + add data
CREATE TABLE _tmp_SomeCustomerData
(
	Id INT IDENTITY(1,1),
	CustomerId VARCHAR(10),
	NoteNumber INT
)

INSERT INTO _tmp_SomeCustomerData (CustomerId, NoteNumber)
VALUES ('CUST001', 1),
	('CUST001', 2),
	('CUST001', 4),
	('CUST001', 5),
	('CUST001', 6),
	('CUST001', 7),
	('CUST001', 9),
	('CUST002', 2),
	('CUST002', 3),
	('CUST002', 6),
	('CUST002', 7),
	('CUST002', 10),
	('CUST003', 4),
	('CUST003', 5)

--data before	
SELECT * FROM _tmp_SomeCustomerData	

--Fix data
;WITH xCTE
AS
(
	SELECT ROW_NUMBER() OVER (PARTITION BY CustomerId ORDER BY Id) AS 'NewNoteNumber'
		, Id
	FROM _tmp_SomeCustomerData
)
UPDATE _tmp_SomeCustomerData SET NoteNumber = NewNoteNumber
FROM xCTE
WHERE xCTE.Id = _tmp_SomeCustomerData.Id

--data after
SELECT * FROM _tmp_SomeCustomerData

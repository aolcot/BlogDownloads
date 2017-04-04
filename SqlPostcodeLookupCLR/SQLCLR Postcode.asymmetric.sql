/*
Ensure that CLR is enabled within the SQL server instance
*/
USE master
GO
CREATE ASYMMETRIC KEY LookupPostcodedll_Key 
FROM EXECUTABLE FILE = 'C:\SQLCLR_Postcode_Lookup.dll'

CREATE LOGIN CLR_LookupPostcode_Login FROM ASYMMETRIC KEY LookupPostcodedll_Key

GRANT EXTERNAL ACCESS ASSEMBLY TO [CLR_LookupPostcode_Login]
GO
USE MyDb
GO

CREATE USER CLR_LookupPostcode_Login FOR LOGIN CLR_LookupPostcode_Login
GO

CREATE ASSEMBLY SQLCLR_Postcode_Lookup FROM 'C:\SQLCLR_Postcode_Lookup.dll'
WITH PERMISSION_SET=EXTERNAL_ACCESS

GO
CREATE FUNCTION [dbo].[LookupPostcode]
(@Postcode NVARCHAR (4000), @ThrowExceptions BIT)
RETURNS 
     TABLE (
        [Postcode]  NVARCHAR (9)     NULL,
        [Latitude]  DECIMAL (18, 15) NULL,
        [Longitude] DECIMAL (18, 15) NULL,
        [Easting]   DECIMAL (10, 1)  NULL,
        [Northing]  DECIMAL (10, 1)  NULL,
        [Geohash]   NVARCHAR (200)   NULL)
AS
EXTERNAL NAME [SQLCLR_Postcode_Lookup].[UserDefinedFunctions].[LookupPostcode]

GO

SELECT * FROM dbo.LookupPostcode('RG6 1WG', 1)

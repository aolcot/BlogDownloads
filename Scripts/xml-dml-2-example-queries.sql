--Declare/assign our example xml blob
DECLARE @XMLData XML
SET @XMLData = '
<Person Id="1234">
	<Fullname></Fullname>
    <Surname>Smith</Surname>
    <Forenames>John Peter</Forenames>
    <Address>
        <AddressLine>1 Church Lane</AddressLine>
        <AddressLine>Littlewood</AddressLine> 
        <AddressLine>Upper Westshire</AddressLine>
        <AddressLine>England</AddressLine>
    </Address>    
    <HasDrivingLicense/>
	<HasPostcode>Unknown</HasPostcode>
</Person>'

--Update <Surname> with new value of "Jones"
SET @XMLData.modify('
    replace value of
        (/Person[1]/Surname[1]/text()[1])
    with
        ("Jones")
')

--Declare/assign our example xml blob
DECLARE @XMLDataMultiTextNode XML
SET @XMLDataMultiTextNode = '
<Person Id="1234">
	<Forenames>John <b>The Strong</b> Peter</Forenames>
</Person>
'

--Update the second text node in <Forenames>
SET @XMLDataMultiTextNode.modify('
    replace value of
        (/Person[1]/Forenames[1]/text()[2])
    with
        ("Paul")
')
SELECT @XMLDataMultiTextNode

--use a variable and update <Surname> with it
DECLARE @Surname VARCHAR(50)
SET @Surname = 'West'

SET @XMLData.modify('
    replace value of
        (/Person[1]/Surname[1]/text()[1])
    with
        ( sql:variable("@Surname") )

')

--Update <Forenames by creating a sequence of <Forenames> and "Kevin"
SET @XMLData.modify('
    replace value of
        (/Person[1]/Forenames[1]/text()[1])
    with
        ( string(/Person[1]/Forenames[1]), "Kevin" )
')

--Test to see if <PostCode> exists and then update <HasPostcode>
SET @XMLData.modify('
    replace value of
        (/Person[1]/HasPostcode[1]/text()[1])
    with
        ( 
			if ( /Person[1]/Address[1]/PostCode[1] ) then 
				"True"
			else
				"False"
		)
')

--Test to see if <PostCode> exists and then update <HasPostcode> with new value only if node exists
SET @XMLData.modify('
    replace value of
        (/Person[1]/HasPostcode[1]/text()[1])
    with
        ( 
			if ( /Person[1]/Address[1]/PostCode[1] != "") then 
				"True"
			else
				( data(/Person[1]/HasPostcode[1]) )
		)
')

--Same query as above but re-written with a predicate and not if...then...else
SET @XMLData.modify('
    replace value of
        (/Person[1][ Address[1]/PostCode[1] ]/HasPostcode[1]/text()[1])
    with
        ( 
			"True"
		)

')

SELECT @XMLData

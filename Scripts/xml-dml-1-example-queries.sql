--Declare/assign our example xml blob
DECLARE @XMLData XML
SET @XMLData = '
<Person Id="1234">
	<Surname>Smith</Surname>
	<Forenames>John Peter</Forenames>
	<Address>
		<AddressLine>1 Church Lane</AddressLine>
		<AddressLine>Littlewood</AddressLine>
		<AddressLine>Upper Westshire</AddressLine>
		<AddressLine>England</AddressLine>
	</Address>	
	<HasDrivingLicense/>
</Person>'


--Example to show "as last" term
SET @XMLData.modify('
    insert      
        (<Postcode>3FG 2MP</Postcode>)
    as last into
        (/Person[1]/Address[1])
')
 
SELECT @XMLData


--Example to show "after" term
SET @XMLData.modify('
    insert      
        (<DateOfBirth>1950-06-01</DateOfBirth>)
    after
        (/Person[1]/Forenames[1])
')
 
SELECT @XMLData


--Example to show "before" term
SET @XMLData.modify('
    insert      
        (<Gender>Male</Gender>)
    before
        (/Person[1]/DateOfBirth[1])
')
 
SELECT @XMLData


--The two examples (gender & date of birth) could have been written as the following using a sequence
/*
SET @XMLData.modify('
    insert      
        (
            <Gender>Male</Gender>,
            <DateOfBirth>1950-06-01</DateOfBirth>
        )
    after
        (/Person[1]/Forenames[1])
')
*/


--The two examples (gender & date of birth) could have been written as the following using a sequence & variables
/*
DECLARE @Gender VARCHAR(6)
DECLARE @DoB DATETIME
 
SELECT @Gender = 'Male', @DoB = '1950-06-01'
 
SET @XMLData.modify('
    insert      
        (
            <Gender>{ sql:variable("@Gender") }</Gender>,
            <DateOfBirth>{ substring(string(sql:variable("@DoB")), 1, 10) }</DateOfBirth>
        )
    after
        (/Person[1]/Forenames[1])
')
*/


--Example to insert an xml document into our xml document using a variable
DECLARE @PreviousAddress XML
SET @PreviousAddress = '
<PreviousAddress>
    <AddressLine>10 Lakes Lane</AddressLine>
    <AddressLine>Largehill</AddressLine>
    <AddressLine>Lower Eastford</AddressLine>
    <AddressLine>England</AddressLine>
</PreviousAddress>'
 
SET @XMLData.modify('
    insert      
        (
            sql:variable("@PreviousAddress")
        )
    after
        (/Person[1]/Address[1])
')
 
SELECT @XMLData


--Example that references existing data in XML document and creates a sequence from multiple XPath expressions
SET @XMLData.modify('
    insert      
        (
            <FullName>
                { data(/Person[1]/Forenames[1]), data(/Person[1]/Surname[1]) }
            </FullName>
        )
    as first into
        (/Person[1])
')
 
SELECT @XMLData


--Example that references existing data in XML document and creates a sequence from a single XPath expressions
SET @XMLData.modify('
    insert      
        (
            <FullAddress>
                { data(/Person[1]/Address[1]/AddressLine) }
            </FullAddress>
        )
    as first into
        (/Person[1])
')
 
SELECT @XMLData


--Example to insert an attribute using the attribute constructor keyword
SET @XMLData.modify('
    insert      
        (
            attribute HasRegistered {"True"}
        )
    as first into
        (/Person[1])
')
 
SELECT @XMLData


--Example to insert an element using the element constructor keyword
SET @XMLData.modify('
    insert      
        (
            element IsActiveUser {"False"}
        )
    as first into
        (/Person[1])
')
 
SELECT @XMLData


--Example to insert a text node into the existing empty <HasDrivingLicense> node
SET @XMLData.modify('
    insert      
        (
            text{"True"}
        )
    as first into
        (/Person[1]/HasDrivingLicense[1])
')
 
SELECT @XMLData


--Exmple using the if...then...else statement but with no "else" expression
SET @XMLData.modify('
    insert      
        (
            if (xs:integer(substring(/Person[1]/DateOfBirth[1], 1, 4)) < 1960)
            then
                attribute YearOfBirth1 { substring(/Person[1]/DateOfBirth[1], 1, 4) }
            else
                ()
        )
    as last into
        (/Person[1])
')
 
SELECT @XMLData


--Example showing the same query as above but written using a predicate and not the if...then...else
SET @XMLData.modify('
    insert      
        (
            attribute YearOfBirth2 { substring(/Person[1]/DateOfBirth[1], 1, 4) }
        )
    as last into
        (/Person[xs:integer(substring(DateOfBirth[1], 1, 4)) < 1960][1])
')
 
SELECT @XMLData


--Exmple using the if...then...else statement 
SET @XMLData.modify('
    insert  
        if (count(/Person[1]/Address[1]/AddressLine) = 5)
        then
            attribute AddressComplete {"True"}
        else
            element AddressLine {""}
    as last into
        (/Person[1]/Address[1])
')
 
SELECT @XMLData

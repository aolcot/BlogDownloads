--Declare/assign our example xml blob
DECLARE @XMLData XML
SET @XMLData = '
<Person Id="1234">
	<?Demographics 18099105?>
	<!-- Comment Number 1 -->
	<Fullname></Fullname>
    <Surname>Smith</Surname>
    <Forenames>John Peter</Forenames>
    <Address>
		<!-- Comment Number 2 -->
		<AddressLine>1 Church Lane</AddressLine>
        <AddressLine>Littlewood</AddressLine> 
        <AddressLine>Upper Westshire</AddressLine>
        <AddressLine>England</AddressLine>
        <Postcode>AA1 1ZZ</Postcode>
    </Address>    
    <!-- Comment Number 3 -->
	<HasPostcode>Unknown</HasPostcode>
</Person>'



--Delete <Fullname> node
SET @XMLData.modify('
    delete (/Person/Fullname)
')

SELECT @XMLData




--Delete multiple nodes
SET @XMLData.modify('
    delete (/Person/Address/AddressLine)
')

SELECT @XMLData




--Delete <Surname> node if contents = 'Jones' by using a variable
DECLARE @Surname VARCHAR(20)
SET @Surname = 'Jones'

SET @XMLData.modify('
    delete /Person/Surname[. = sql:variable("@Surname")]
')

SELECT @XMLData




--Delete sequence, both <Surname> and <Forenames>
SET @XMLData.modify('
    delete (
		/Person/Forenames, 
		/Person/@Id,
		/Person/Surname[. = "Jones"]
		)
')

SELECT @XMLData



--Delete text node from <HasPostcode>
SET @XMLData.modify('
    delete (/Person/HasPostcode/text()[1])
')

SELECT @XMLData




--Delete all element nodes under /Person/Address
SET @XMLData.modify('
    delete /Person/Address/*
')

SELECT @XMLData




--Delete all nodes under /Person/Address
SET @XMLData.modify('
    delete /Person/Address/node()
')

SELECT @XMLData




--Delete all comment nodes under /Person and the "Demographics" PI node
SET @XMLData.modify('
    delete (
		/Person/comment(),
		/Person/processing-instruction("Demographics")
		)
')

SELECT @XMLData


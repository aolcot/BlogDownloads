/*   example xml   */
DECLARE @XML XML
SET @XML = '
<Data>
	<Colour>Red</Colour>
	<Colour>Green</Colour>
	<Colour>Green</Colour>
	<Colour>Blue</Colour>
	<OtherColour>Red</OtherColour>
	<OtherColour>Green</OtherColour>
	<OtherColour>Green</OtherColour>
	<OtherColour>Yellow</OtherColour>
</Data>
'

--Query 1
/*  query to return all distinct values from <Colour> nodes  */
SELECT @XML.query('<Data>{ distinct-values(//Colour/text()) }</Data>')

--Query 2
/*  query to return all distinct values from <Colour> and <OtherColour> nodes combined  */
SELECT @XML.query('<Data>{ distinct-values( (//Colour/text(), //OtherColour/text()) ) }</Data>')

GO


/*   example xml   */
DECLARE @XML XML
SET @XML = '
<Data>
	<Customer>
		<AccountNumber>111</AccountNumber>
		<Name>Green IT</Name>
	</Customer>
	<Customer>
		<AccountNumber>111</AccountNumber>
		<Name>Green IT</Name>
	</Customer>
	<Customer>
		<AccountNumber>222</AccountNumber>
		<Name>Red IT</Name>
	</Customer>
	<Customer>
		<AccountNumber>333</AccountNumber>
		<Name>Blue IT</Name>
	</Customer>
</Data>
'

--Query 3
/*  query to get distinct <Customer> nodes based on <AccountNumber> nodes */
SELECT @XML.query('
<Data>
	{
		for $x in distinct-values(//Customer/AccountNumber/text())
		return
			(//Customer[AccountNumber = $x])[1]
	}
</Data>
')

GO


/*   example xml   */
DECLARE @XML XML
SET @XML = '
<Data>
	<Customer>
		<AccountNumber>111</AccountNumber>
		<Name>Green IT</Name>
		<Location>USA</Location>
	</Customer>
	<Customer>
		<AccountNumber>111</AccountNumber>
		<Name>Green IT</Name>
		<Location>USA</Location>
	</Customer>
	<Customer>
		<AccountNumber>111</AccountNumber>
		<Name>Green IT</Name>
		<Location>France</Location>
	</Customer>
	<Customer>
		<AccountNumber>333</AccountNumber>
		<Name>Blue IT</Name>
		<Location>Russia</Location>
	</Customer>	
	<Customer>
		<AccountNumber>222</AccountNumber>
		<Name>Red IT</Name>
		<Location>Germany</Location>
	</Customer>
	<Customer>
		<AccountNumber>222</AccountNumber>
		<Name>Red IT</Name>
		<Location>Germany</Location>
	</Customer>	
	<Customer>
		<AccountNumber>333</AccountNumber>
		<Name>Blue IT</Name>
		<Location>Australia</Location>
	</Customer>
</Data>'

--Query 4
/*  query to compare the node contents and eliminate any duplicate nodes  */
SELECT @XML.query('
<Data>
	{
		for $x in (//Customer)
		return
			if ($x is (//Customer)[. = $x][1]) then
				$x
			else ()
	}
</Data>
')

--Query 5
/*  query to compare the node contents and only return nodes that have been duplicated  */
SELECT @XML.query('
<Data>
	{
		for $x in (//Customer)
		return
			if ($x is (//Customer)[. = $x][2]) then
				$x
			else ()
	}
</Data>
')
GO


/*   example xml   */
DECLARE @XML XML
SET @XML = '
<Data>
	<Customer AccountNumber="111">
		<Name>Green IT</Name>
		<Location>USA</Location>
	</Customer>
	<Customer AccountNumber="222">
		<Name>Green IT</Name>
		<Location>USA</Location>
	</Customer>
	<Customer AccountNumber="222">
		<Name>Green IT</Name>
		<Location>USA</Location>
	</Customer>	
</Data>'

--Query 6
/*  query to eliminate duplicate nodes that contain attributes*/
SELECT @XML.query('
<Data>
	{
		for $x in (//Customer)
		return
			if ($x is (//Customer)[. = $x]
					[$x/@AccountNumber = ./@AccountNumber][1]) then
				$x
			else ()
	}
</Data>
')

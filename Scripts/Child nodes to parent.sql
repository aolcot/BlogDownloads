--Declare our XML
DECLARE @XML XML
SET @XML = '<Book>
  <BookFormats>
    <NumberOfBookFormats>2</NumberOfBookFormats>
    <Format Type="Kindle">
      <Price>5.00</Price>
      <Currency>£</Currency>
      <AvailableDate>2010-05-01</AvailableDate>
    </Format>
    <Format Type="Paperback">
      <Price>8.00</Price>
      <Currency>£</Currency>
      <AvailableDate>2010-03-20</AvailableDate>
    </Format>
  </BookFormats>
</Book>
'

--Rather dodgy way of removing the <BookFormats> node
SELECT CAST(REPLACE(REPLACE(CAST(@XML AS NVARCHAR(MAX)), '<BookFormats>', ''), '</BookFormats>', '') AS XML)

--Remove the <BookFormats> node by using XQuery
SELECT @XML.query('for $x in (/Book) 
		return 
			<Book>
				{$x/BookFormats/*}
			</Book>
')

--Remove the <BookFormats> node and <NumberOfBookFormats> by using XQuery with a predicate
SELECT @XML.query('for $x in (/Book) 
		return 
			<Book>
				{$x/BookFormats/*[local-name(.) != "NumberOfBookFormats"]}
			</Book>
')
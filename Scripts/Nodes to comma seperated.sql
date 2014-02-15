--Declare our XML
DECLARE @XML XML
SET @XML = '
<BookAuthors>
	<Author>John Green</Author>
	<Author>Linda Blue</Author>
	<Author>Peter Red</Author>
	<Author>Jill White</Author>
</BookAuthors>
'

--Original Xml
SELECT @XML

--New Xml after xquery transformation
SELECT @XML.query('
<BookAuthors>
      <Authors>
            {
                  for $x in /BookAuthors/Author
                  return
                        if (not( ($x) is (/BookAuthors/Author[last()])[1] )) then
                              concat($x, ",")
                        else
                              string($x)
            }
      </Authors>
</BookAuthors>
')

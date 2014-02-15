--Some poorly constructed xml
DECLARE @xml XML
SET @xml = '
<Data>
    <SomeElement>Item 1</SomeElement>
    <SomeElement>Red</SomeElement>
    <SomeElement>Item 2</SomeElement>
    <SomeElement>Green</SomeElement>
    <SomeElement>Item 3</SomeElement>
    <SomeElement>Blue</SomeElement>
</Data>';

--shred to a single column table
SELECT t.c.value('(./text())[1]', 'varchar(10)') AS 'SomeElementValue'
FROM @xml.nodes('//SomeElement') AS T(c);

--transform xml and shred to three column table, known node name
WITH xCTE AS
(
SELECT @xml.query('
    <Data>
        {
            for $x in (/Data/SomeElement) 
            return
                <SomeElement>
                    <Value>{data($x)}</Value>
                    <PrevValue>{data(/Data/SomeElement[. << $x][last()])}</PrevValue>
                    <NextValue>{data(/Data/SomeElement[. >> $x][1])}</NextValue>
                </SomeElement>
        }
    </Data>
        ') AS DocXml
)
SELECT t.c.value('(Value/text())[1]', 'varchar(10)') AS 'SomeElementValue'
    , t.c.value('(PrevValue/text())[1]', 'varchar(10)') AS 'PreviousSomeElementValue'
    , t.c.value('(NextValue/text())[1]', 'varchar(10)') AS 'NextSomeElementValue'
FROM xCTE
CROSS APPLY DocXml.nodes('/Data/SomeElement') AS T(c);

--set xml to structure with random node names
SET @xml = '
<Data>
    <SomeElement1>Item 1</SomeElement1>
    <SomeElement2>Red</SomeElement2>
    <SomeElement3>Item 2</SomeElement3>
    <SomeElement4>Green</SomeElement4>
    <SomeElement5>Item 3</SomeElement5>
    <SomeElement6>Blue</SomeElement6>
</Data>';

--transform xml and shred to three column table, unknown node name
WITH xCTE AS
(
SELECT @xml.query('
    <Data>
        {
            for $x in (/Data/*) 
            return
                <SomeElement>
                    <Value>{data($x)}</Value>
                    <PrevValue>{data(/Data/*[. << $x][last()])}</PrevValue>
                    <NextValue>{data(/Data/*[. >> $x][1])}</NextValue>
                </SomeElement>
        }
    </Data>
        ') AS DocXml
)
SELECT t.c.value('(Value/text())[1]', 'varchar(10)') AS 'SomeElementValue'
    , t.c.value('(PrevValue/text())[1]', 'varchar(10)') AS 'PreviousSomeElementValue'
    , t.c.value('(NextValue/text())[1]', 'varchar(10)') AS 'NextSomeElementValue'
FROM xCTE
CROSS APPLY DocXml.nodes('/Data/SomeElement') AS T(c);

